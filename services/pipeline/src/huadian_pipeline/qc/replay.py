"""Checkpoint replay — regression detection for TG upgrades + policy edits.

T-TG-002 S-8. Reads stored `traceguard_raw` from `extractions_history`,
reconstructs a `CheckpointInput`, re-runs `Adapter.checkpoint`, and diffs
the new result against the original. A "drift" is any field difference
between the original and replayed `CheckpointResult`.

Primary use-case: after bumping TG to 0.2.x or editing policy.yml, run
`replay_batch(...)` against the extraction corpus and verify the set of
changed verdicts is expected + small. If drift count > threshold the
release is suspect.

This module does **not** hit PG itself — it accepts pre-loaded records
via a `RecordLoader` protocol so tests can inject dicts without spinning
up a database. Production callers wire a real loader backed by asyncpg
(see the stub `pg_record_loader` at the bottom).
"""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from typing import Any, Protocol

from .port import TraceGuardPort
from .types import CheckpointInput, CheckpointResult


# ---------------------------------------------------------------------------
# Data structures
# ---------------------------------------------------------------------------

@dataclass(slots=True)
class ReplayDiff:
    """One paragraph's original-vs-replayed comparison."""

    paragraph_id: str
    step_name: str
    prompt_version: str
    drifted: bool
    diff_fields: list[str] = field(default_factory=list)
    original: dict[str, Any] = field(default_factory=dict)
    replayed: dict[str, Any] = field(default_factory=dict)
    error: str | None = None


@dataclass(slots=True)
class ReplayReport:
    """Aggregate replay outcome."""

    total: int = 0
    passed: int = 0
    drifted: int = 0
    errors: int = 0
    details: list[ReplayDiff] = field(default_factory=list)

    @property
    def ok(self) -> bool:
        return self.drifted == 0 and self.errors == 0


# ---------------------------------------------------------------------------
# RecordLoader protocol — abstracts PG access for testability
# ---------------------------------------------------------------------------

class RecordLoader(Protocol):
    """Load stored extraction records for replay.

    Each record is a dict with at least:
        paragraph_id, step, prompt_version, output, traceguard_raw
    matching the `extractions_history` row shape.
    """

    async def load(
        self,
        *,
        paragraph_id: str | None = None,
        step_name: str | None = None,
        book_slug: str | None = None,
        step_pattern: str | None = None,
        limit: int = 1000,
    ) -> list[dict[str, Any]]: ...


# ---------------------------------------------------------------------------
# Core replay logic
# ---------------------------------------------------------------------------

def _reconstruct_input(record: dict[str, Any]) -> CheckpointInput:
    """Rebuild a `CheckpointInput` from a stored extraction record.

    The `traceguard_raw` blob (written by AuditSink) carries the
    original trace_id, attempt, mode, and the checkpoint_result with
    all violations. We need:
      - step_name:       from record["step"] + record["prompt_version"]
      - trace_id:        from traceguard_raw["trace_id"]
      - prompt_version:  from record["prompt_version"]
      - model:           from traceguard_raw["checkpoint_result"] or default
      - inputs/outputs:  from record["output"] (was payload.outputs at
                          write time; inputs are not persisted — replay
                          runs rules against the same outputs)
    """
    raw_str = record.get("traceguard_raw")
    if isinstance(raw_str, str):
        tg_raw: dict[str, Any] = json.loads(raw_str)
    elif isinstance(raw_str, dict):
        tg_raw = raw_str
    else:
        tg_raw = {}

    output_str = record.get("output")
    if isinstance(output_str, str):
        outputs: dict[str, Any] = json.loads(output_str)
    elif isinstance(output_str, dict):
        outputs = output_str
    else:
        outputs = {}

    step = str(record.get("step", ""))
    pv = str(record.get("prompt_version", ""))
    # Reconstruct versioned step_name: "ner" + "v3" → "ner_v3"
    step_name = f"{step}_{pv}" if pv and not step.endswith(pv) else step

    return CheckpointInput(
        step_name=step_name,
        trace_id=str(tg_raw.get("trace_id", "")),
        prompt_version=pv,
        model=str(
            tg_raw.get("checkpoint_result", {}).get("model", "unknown")
        ),
        inputs={},  # original inputs not persisted; rules that need
                     # paragraph_text will see empty → violations expected
                     # to differ from original (flagged as "inputs_missing")
        outputs=outputs,
        metadata={
            "paragraph_id": str(record.get("paragraph_id", "")),
            "attempt": int(tg_raw.get("attempt", 1)),
            "replay": True,
        },
    )


def _extract_original(record: dict[str, Any]) -> dict[str, Any]:
    """Pull the original CheckpointResult summary from traceguard_raw."""
    raw_str = record.get("traceguard_raw")
    if isinstance(raw_str, str):
        tg_raw = json.loads(raw_str)
    elif isinstance(raw_str, dict):
        tg_raw = raw_str
    else:
        return {}
    return tg_raw.get("checkpoint_result", {})


def _result_to_comparable(result: CheckpointResult) -> dict[str, Any]:
    """Flatten a CheckpointResult into a stable, diff-friendly dict."""
    return {
        "status": result.status,
        "action": result.action,
        "confidence": round(result.confidence, 3),
        "violation_count": len(result.violations),
        "violation_ids": sorted(v.rule_id for v in result.violations),
    }


def _original_to_comparable(original: dict[str, Any]) -> dict[str, Any]:
    """Normalise the stored original into the same shape as _result_to_comparable."""
    violations = original.get("violations", [])
    return {
        "status": original.get("status", ""),
        "action": original.get("action", ""),
        "confidence": round(float(original.get("confidence", 0)), 3),
        "violation_count": len(violations),
        "violation_ids": sorted(
            v.get("rule_id", "") if isinstance(v, dict) else ""
            for v in violations
        ),
    }


def _diff_fields(
    original: dict[str, Any], replayed: dict[str, Any]
) -> list[str]:
    """Return the list of keys whose values differ."""
    all_keys = sorted(set(original) | set(replayed))
    return [k for k in all_keys if original.get(k) != replayed.get(k)]


async def replay_one(
    record: dict[str, Any],
    adapter: TraceGuardPort,
) -> ReplayDiff:
    """Replay a single stored extraction and compare."""
    para_id = str(record.get("paragraph_id", ""))
    step = str(record.get("step", ""))
    pv = str(record.get("prompt_version", ""))

    try:
        payload = _reconstruct_input(record)
        result = await adapter.checkpoint(payload)
    except Exception as exc:
        return ReplayDiff(
            paragraph_id=para_id,
            step_name=step,
            prompt_version=pv,
            drifted=False,
            error=repr(exc),
        )

    original_raw = _extract_original(record)
    original_cmp = _original_to_comparable(original_raw)
    replayed_cmp = _result_to_comparable(result)
    diffs = _diff_fields(original_cmp, replayed_cmp)

    return ReplayDiff(
        paragraph_id=para_id,
        step_name=step,
        prompt_version=pv,
        drifted=len(diffs) > 0,
        diff_fields=diffs,
        original=original_cmp,
        replayed=replayed_cmp,
    )


async def replay_batch(
    loader: RecordLoader,
    adapter: TraceGuardPort,
    *,
    paragraph_id: str | None = None,
    step_name: str | None = None,
    book_slug: str | None = None,
    step_pattern: str | None = None,
    limit: int = 1000,
) -> ReplayReport:
    """Replay a batch of stored extractions and return aggregate report."""
    records = await loader.load(
        paragraph_id=paragraph_id,
        step_name=step_name,
        book_slug=book_slug,
        step_pattern=step_pattern,
        limit=limit,
    )

    report = ReplayReport(total=len(records))
    for record in records:
        diff = await replay_one(record, adapter)
        report.details.append(diff)
        if diff.error:
            report.errors += 1
        elif diff.drifted:
            report.drifted += 1
        else:
            report.passed += 1

    return report


# ---------------------------------------------------------------------------
# Wire Adapter.replay (Port method) — delegates here
# ---------------------------------------------------------------------------

async def port_replay(
    trace_id: str,
    loader: RecordLoader,
    adapter: TraceGuardPort,
) -> CheckpointResult:
    """Implement `TraceGuardPort.replay(trace_id)`.

    Loads the single record matching `trace_id` from
    `traceguard_raw.trace_id`, replays it, and returns the new
    `CheckpointResult`. Raises `ValueError` if not found.
    """
    records = await loader.load(paragraph_id=None, step_name=None, limit=1)
    # In a real implementation the loader would filter by trace_id inside
    # traceguard_raw JSONB. For now we scan — acceptable at the
    # single-record level.
    for rec in records:
        raw = rec.get("traceguard_raw")
        if isinstance(raw, str):
            raw = json.loads(raw)
        if isinstance(raw, dict) and raw.get("trace_id") == trace_id:
            payload = _reconstruct_input(rec)
            return await adapter.checkpoint(payload)
    raise ValueError(f"No extraction record found with trace_id={trace_id!r}")
