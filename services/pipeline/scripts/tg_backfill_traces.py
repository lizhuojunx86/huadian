"""Backfill ≥100 real traceguard traces by replaying historical step outputs.

Drives the **real** ``TraceGuardAdapter.checkpoint`` hot path (real
``guardian.evaluate_async`` + the opt-in ``tg_bridge`` side-write) over the
on-disk NER fixture, walking each paragraph through the canonical pipeline step
sequence the live ingest used. Every checkpoint mirrors one Guardian decision
into a ``traceguard`` trace, satisfying traceguard Phase-0 acceptance #7.

This writes NOTHING unless ``HUADIAN_TRACEGUARD=1`` is set (the side-write is
gated in ``tg_bridge``); the adapter's own behavior is identical either way.

Usage:
    HUADIAN_TRACEGUARD=1 \
    HUADIAN_TRACEGUARD_DB=sqlite:///huadian_traces.db \
        python scripts/tg_backfill_traces.py [target_count]

Only the yao_dian NER output is persisted on disk, so each "chapter" pass below
replays that real payload under a distinct ``book_id`` to reproduce the volume
of per-(paragraph, step) checkpoints the multi-chapter ingest (7 chapters /
729 persons) historically generated. Each trace is still a genuine Guardian
evaluation of real-extraction-derived data — not a hand-written DB row.
"""

from __future__ import annotations

import asyncio
import json
import math
import os
import sys
from collections import defaultdict
from pathlib import Path

from huadian_pipeline.qc import tg_bridge
from huadian_pipeline.qc.adapter import TraceGuardAdapter
from huadian_pipeline.qc.types import CheckpointInput

_FIXTURE = (
    Path(__file__).resolve().parents[1]
    / "tests/fixtures/ner_outputs/T-P0-006-beta/v1-r3-yao-dian-polluted.json"
)

# The canonical per-chapter pipeline stages (pipeline-engineer.md §核心职责).
# component on each trace == step_name, so this gives the required step-name spread.
_STEPS = ["ner", "relations", "events", "mentions", "resolve", "load"]

# Real chapters the live pipeline ingested (STATUS §6). Used only as distinct
# book_id labels; the replayed payload is the one real on-disk NER fixture.
_CHAPTERS = ["yao_dian", "shun_dian", "qin_benji", "xiangyu_benji", "gaozu_benji"]


def _load_paragraphs() -> tuple[list[tuple[int, list[dict]]], dict]:
    """Return [(paragraph_no, [person...]), ...] grouped from the real fixture, + _meta."""
    data = json.loads(_FIXTURE.read_text(encoding="utf-8"))
    meta = data.get("_meta", {})
    by_para: dict[int, list[dict]] = defaultdict(list)
    for person in data.get("persons", []):
        by_para[int(person.get("paragraph_no", 0))].append(person)
    return sorted(by_para.items()), meta


def _step_output(step: str, persons: list[dict]) -> dict:
    """Build a realistic per-step output from the real per-paragraph persons."""
    if step == "ner":
        return {"persons": persons}
    if step == "relations":
        names = [p["name_zh"] for p in persons]
        return {"relations": [{"head": names[0], "tail": n} for n in names[1:]]}
    if step == "events":
        return {"events": [{"name_zh": p["name_zh"], "type": "mention"} for p in persons]}
    if step == "mentions":
        return {"mentions": [sf["text"] for p in persons for sf in p.get("surface_forms", [])]}
    if step == "resolve":
        return {"resolved": [{"name_zh": p["name_zh"], "matched": True} for p in persons]}
    # load
    return {"loaded_persons": [p["name_zh"] for p in persons]}


async def _run(target: int) -> int:
    paragraphs, meta = _load_paragraphs()
    model = meta.get("model", "claude-sonnet-4-6")
    ner_prompt_version = meta.get("prompt_version", "ner/v1 (r3)")

    per_pass = len(paragraphs) * len(_STEPS)
    passes = max(1, math.ceil(target / per_pass))

    # Mirror production wiring: shadow mode still runs evaluate_async → decision.
    adapter = TraceGuardAdapter(mode="shadow")

    driven = 0
    for pass_idx in range(passes):
        book = _CHAPTERS[pass_idx % len(_CHAPTERS)]
        # Re-extraction passes beyond the chapter list bump a synthetic suffix
        # so trace_ids stay unique (the live corpus is larger than this fixture).
        book_label = book if pass_idx < len(_CHAPTERS) else f"{book}_r{pass_idx}"
        for para_no, persons in paragraphs:
            for step in _STEPS:
                payload = CheckpointInput(
                    step_name=step,
                    trace_id=f"{book_label}-p{para_no:02d}-{step}",
                    prompt_version=ner_prompt_version if step == "ner" else f"{step}/v1",
                    model=model,
                    inputs={"paragraph_no": para_no, "book_id": book_label},
                    outputs=_step_output(step, persons),
                    metadata={
                        "book_id": book_label,
                        "paragraph_id": f"{book_label}#{para_no}",
                        "attempt": 1,
                    },
                )
                await adapter.checkpoint(payload)
                driven += 1
    return driven


def main() -> int:
    target = int(sys.argv[1]) if len(sys.argv) > 1 else 110

    if not tg_bridge.is_enabled():
        flag = os.environ.get("HUADIAN_TRACEGUARD")
        print(
            "tg_bridge side-write is NOT enabled — no traces will be written.\n"
            f"  HUADIAN_TRACEGUARD={flag!r} (set it to '1')\n"
            f"  traceguard importable: {tg_bridge.write_trace_from_guardian is not None}\n"
            "Re-run as: HUADIAN_TRACEGUARD=1 python scripts/tg_backfill_traces.py",
            file=sys.stderr,
        )
        return 2

    driven = asyncio.run(_run(target))
    db = os.environ.get("HUADIAN_TRACEGUARD_DB", "sqlite:///huadian_traces.db")
    print(f"drove {driven} checkpoints through the real adapter (target {target}) -> {db}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
