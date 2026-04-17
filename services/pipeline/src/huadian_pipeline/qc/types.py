"""ADR-004 Port data structures.

These dataclasses are the 华典-owned wire format between the pipeline
and any quality-assurance backend (today: TraceGuard via `adapter.py`;
tomorrow: possibly something else). They are intentionally free of any
upstream import.

Deviations from ADR-004 v1 (captured by the T-TG-002 architect spec,
"Mismatch #2" table):

  - `CheckpointResult.score` renamed to `confidence` (the architect's
    own word per the spec). TG's `GuardianDecision.score` pass-through
    lands here; TG `semantic_score` / `semantic_status` stay in `raw`.

  - `duration_ms` is Adapter-computed (time.perf_counter around the TG
    call); TG itself does not report it.

  - `Violation` is a 华典 concept; TG emits unstructured `issues: list[str]`.
    The Adapter wraps each TG issue as a single `Violation` with
    `rule_id="traceguard.structural"`.

  - `ActionType` is imported from `action_map.py` to avoid drift: that
    module is the Mismatch #1 authority.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Literal

from .action_map import ActionType  # Mismatch #1 single source of truth

__all__ = [
    "ActionType",
    "CheckpointInput",
    "CheckpointResult",
    "CheckpointStatus",
    "Severity",
    "Violation",
]

CheckpointStatus = Literal["pass", "fail", "warn"]
Severity = Literal["critical", "major", "minor", "info"]


@dataclass(slots=True)
class CheckpointInput:
    """Payload submitted to a checkpoint.

    Mirrors ADR-004 §二 verbatim. Deliberately an input-only record —
    the Adapter never mutates it.
    """

    step_name: str  # e.g. "ner_v3"
    trace_id: str  # threaded through the whole pipeline run
    prompt_version: str  # e.g. "ner_v3.json#sha256:abc..."
    model: str  # e.g. "claude-opus-4-6"
    inputs: dict[str, Any]  # upstream step outputs / prompt inputs
    outputs: dict[str, Any]  # this step's outputs (subject of checks)
    parent_trace_id: str | None = None
    metadata: dict[str, Any] = field(default_factory=dict)  # book_id, paragraph_id, attempt, ...


@dataclass(slots=True)
class Violation:
    """A single rule-level finding.

    Structured replacement for TG's `issues: list[str]`. 华典 Python
    rules produce these directly; TG issues are wrapped by the Adapter
    at a fixed `rule_id` (see adapter.py).
    """

    rule_id: str  # e.g. "ner.surface_in_source"
    severity: Severity  # critical / major / minor / info
    message: str  # human-readable
    location: dict[str, Any] = field(default_factory=dict)  # e.g. {"field": "entities[2]"}
    suggested_fix: str | None = None  # TG retry_hint lands here when applicable


@dataclass(slots=True)
class CheckpointResult:
    """Translated verdict — the Adapter's return value.

    Field-by-field correspondence with TG's `GuardianDecision` is
    documented in the Mismatch #2 table (see T-TG-002 task card).
    """

    status: CheckpointStatus
    action: ActionType  # translated via action_map.translate
    violations: list[Violation] = field(default_factory=list)
    confidence: float = 1.0  # ← TG `score` lands here (0.0 – 1.0)
    duration_ms: int = 0  # Adapter-computed
    raw: dict[str, Any] = field(default_factory=dict)
    # ^ Holds everything we do NOT promote to a first-class field:
    #     raw["tg_action"]          — original TG literal (distinguishes
    #                                  `pass` vs `passthrough` after fold)
    #     raw["tg_decision"]        — the GuardianDecision as dict
    #     raw["semantic_score"]     — TG int 1-5 when evaluated
    #     raw["semantic_status"]    — TG status string when evaluated
