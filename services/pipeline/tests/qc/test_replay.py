"""Unit tests for replay module (T-TG-002 S-8).

All tests use MockTraceGuardPort + in-memory RecordLoader. No PG needed
— S-7 already validated the persistence layer.
"""

from __future__ import annotations

import json
import uuid
from typing import Any

import pytest

from huadian_pipeline.qc.mock import MockTraceGuardPort
from huadian_pipeline.qc.replay import (
    replay_batch,
    replay_one,
)
from huadian_pipeline.qc.types import CheckpointInput, CheckpointResult, Violation


# ---------------------------------------------------------------------------
# In-memory RecordLoader
# ---------------------------------------------------------------------------

class MemoryLoader:
    """Trivial RecordLoader backed by a list of dicts."""

    def __init__(self, records: list[dict[str, Any]]) -> None:
        self._records = records

    async def load(
        self,
        *,
        paragraph_id: str | None = None,
        step_name: str | None = None,
        book_slug: str | None = None,
        step_pattern: str | None = None,
        limit: int = 1000,
    ) -> list[dict[str, Any]]:
        out = self._records
        if paragraph_id is not None:
            out = [r for r in out if str(r.get("paragraph_id")) == paragraph_id]
        if step_name is not None:
            out = [r for r in out if r.get("step") == step_name]
        return out[:limit]


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _make_stored_record(
    *,
    para_id: str | None = None,
    step: str = "ner",
    pv: str = "v3",
    status: str = "pass",
    action: str = "pass_through",
    confidence: float = 0.95,
    violations: list[dict[str, Any]] | None = None,
    trace_id: str = "trace-1",
) -> dict[str, Any]:
    """Simulate a row from extractions_history with traceguard_raw."""
    pid = para_id or str(uuid.uuid4())
    return {
        "paragraph_id": pid,
        "step": step,
        "prompt_version": pv,
        "output": json.dumps({"entities": [{"surface_form": "项羽", "entity_type": "PERSON"}]}),
        "traceguard_raw": json.dumps({
            "checkpoint_run_id": str(uuid.uuid4()),
            "trace_id": trace_id,
            "attempt": 1,
            "mode": "enforce",
            "guardian_decision": {},
            "checkpoint_result": {
                "status": status,
                "action": action,
                "confidence": confidence,
                "duration_ms": 5,
                "violations": violations or [],
            },
        }),
    }


# ---------------------------------------------------------------------------
# Tests — replay_one
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_replay_one_no_drift_when_adapter_matches() -> None:
    """If the adapter returns the same verdict, drift=False."""
    record = _make_stored_record(status="pass", action="pass_through", confidence=0.95)
    # Mock adapter returns identical result
    mock = MockTraceGuardPort(
        default_response=CheckpointResult(
            status="pass",
            action="pass_through",
            confidence=0.95,
            violations=[],
        )
    )
    diff = await replay_one(record, mock)
    assert not diff.drifted
    assert diff.diff_fields == []
    assert diff.error is None


@pytest.mark.asyncio
async def test_replay_one_detects_action_drift() -> None:
    """If adapter now returns retry instead of pass_through, drift is caught."""
    record = _make_stored_record(action="pass_through")
    mock = MockTraceGuardPort(
        default_response=CheckpointResult(
            status="fail",
            action="retry",
            confidence=0.5,
            violations=[Violation(rule_id="x", severity="major", message="m")],
        )
    )
    diff = await replay_one(record, mock)
    assert diff.drifted
    assert "action" in diff.diff_fields
    assert "status" in diff.diff_fields


@pytest.mark.asyncio
async def test_replay_one_detects_violation_count_drift() -> None:
    """New rule fires → violation_count drifts."""
    record = _make_stored_record(violations=[])
    mock = MockTraceGuardPort(
        default_response=CheckpointResult(
            status="fail",
            action="pass_through",  # action same
            confidence=0.95,        # confidence same
            violations=[Violation(rule_id="new.rule", severity="minor", message="m")],
        )
    )
    diff = await replay_one(record, mock)
    assert diff.drifted
    assert "violation_count" in diff.diff_fields or "violation_ids" in diff.diff_fields


@pytest.mark.asyncio
async def test_replay_one_reports_adapter_exception_as_error() -> None:
    """If the adapter raises, the diff carries an error string (not drifted)."""

    def _boom(payload: CheckpointInput) -> CheckpointResult:
        raise RuntimeError("TG down")

    mock = MockTraceGuardPort(factory=_boom)
    record = _make_stored_record()
    diff = await replay_one(record, mock)
    assert diff.error is not None
    assert "TG down" in diff.error
    assert not diff.drifted


@pytest.mark.asyncio
async def test_replay_one_handles_missing_traceguard_raw() -> None:
    """Graceful handling of records without traceguard_raw."""
    record = {
        "paragraph_id": str(uuid.uuid4()),
        "step": "ner",
        "prompt_version": "v3",
        "output": "{}",
        "traceguard_raw": None,
    }
    mock = MockTraceGuardPort(
        default_response=CheckpointResult(status="pass", action="pass_through")
    )
    diff = await replay_one(record, mock)
    # Should not crash — original will be empty, likely drifted
    assert diff.error is None


# ---------------------------------------------------------------------------
# Tests — replay_batch
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_replay_batch_aggregates_correctly() -> None:
    """2 records: 1 pass, 1 drift."""
    records = [
        _make_stored_record(para_id="p1", action="pass_through", confidence=0.95),
        _make_stored_record(para_id="p2", action="retry", confidence=0.3),
    ]
    # Adapter always returns pass_through — matches p1, drifts p2
    mock = MockTraceGuardPort(
        default_response=CheckpointResult(
            status="pass", action="pass_through", confidence=0.95
        )
    )
    loader = MemoryLoader(records)
    report = await replay_batch(loader, mock)
    assert report.total == 2
    assert report.passed == 1
    assert report.drifted == 1
    assert report.errors == 0
    assert not report.ok  # drifted > 0


@pytest.mark.asyncio
async def test_replay_batch_all_pass_is_ok() -> None:
    records = [
        _make_stored_record(para_id=f"p{i}", action="pass_through", confidence=0.95)
        for i in range(3)
    ]
    mock = MockTraceGuardPort(
        default_response=CheckpointResult(
            status="pass", action="pass_through", confidence=0.95
        )
    )
    loader = MemoryLoader(records)
    report = await replay_batch(loader, mock)
    assert report.total == 3
    assert report.passed == 3
    assert report.ok


@pytest.mark.asyncio
async def test_replay_batch_empty_records() -> None:
    loader = MemoryLoader([])
    mock = MockTraceGuardPort()
    report = await replay_batch(loader, mock)
    assert report.total == 0
    assert report.ok


@pytest.mark.asyncio
async def test_replay_batch_filters_by_paragraph_id() -> None:
    records = [
        _make_stored_record(para_id="target", action="pass_through", confidence=0.95),
        _make_stored_record(para_id="other", action="pass_through", confidence=0.95),
    ]
    mock = MockTraceGuardPort(
        default_response=CheckpointResult(
            status="pass", action="pass_through", confidence=0.95
        )
    )
    loader = MemoryLoader(records)
    report = await replay_batch(loader, mock, paragraph_id="target")
    assert report.total == 1
    assert report.details[0].paragraph_id == "target"


@pytest.mark.asyncio
async def test_replay_batch_with_errors_counts_correctly() -> None:
    """1 normal + 1 error → total=2, errors=1, not ok."""
    records = [
        _make_stored_record(para_id="good", action="pass_through", confidence=0.95),
        _make_stored_record(para_id="bad", action="pass_through", confidence=0.95),
    ]
    call_count = {"n": 0}

    def _sometimes_fail(payload: CheckpointInput) -> CheckpointResult:
        call_count["n"] += 1
        if call_count["n"] == 2:
            raise RuntimeError("boom")
        return CheckpointResult(status="pass", action="pass_through", confidence=0.95)

    mock = MockTraceGuardPort(factory=_sometimes_fail)
    loader = MemoryLoader(records)
    report = await replay_batch(loader, mock)
    assert report.total == 2
    assert report.passed == 1
    assert report.errors == 1
    assert not report.ok


# ---------------------------------------------------------------------------
# Tests — _reconstruct_input
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_reconstructed_input_has_replay_marker() -> None:
    """Replayed payloads carry metadata.replay=True for downstream filtering."""
    record = _make_stored_record()
    mock = MockTraceGuardPort()
    await replay_one(record, mock)
    assert len(mock.calls) == 1
    assert mock.calls[0].metadata.get("replay") is True


@pytest.mark.asyncio
async def test_reconstructed_step_name_includes_version() -> None:
    """step="ner" + prompt_version="v3" → step_name="ner_v3"."""
    record = _make_stored_record(step="ner", pv="v3")
    mock = MockTraceGuardPort()
    await replay_one(record, mock)
    assert mock.calls[0].step_name == "ner_v3"
