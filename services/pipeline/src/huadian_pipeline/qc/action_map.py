"""Mismatch #1 — action vocabulary translation (TG → ADR-004).

Upstream TG emits one of five string literals. ADR-004 speaks a richer
five-member enum that TG cannot express natively (`degrade` / `human_queue`
are 华典 concepts). This module is the single source of truth for the
translation; `adapter.py` is the only caller, and the contract tests pin
the mapping against the upstream literal set.

Translation table (T-TG-002 architect spec, Mismatch #1):

    TG (Literal)   →  ADR-004 (ActionType)
    ──────────────────────────────────────
    pass           →  pass_through
    passthrough    →  pass_through          (two TG actions fold into one)
    retry          →  retry
    abort          →  fail_fast
    alert          →  human_queue
    —              →  degrade               (TG cannot emit; Adapter
                                             escalates via `maybe_escalate`)

If TG ever ships a new action literal, `translate()` raises
`UnknownTGActionError` and the contract test
`test_tg_action_set_exhaustive` fails — a loud break forces the Adapter
owner to review the new semantics before shipping.
"""

from __future__ import annotations

from typing import Literal, Protocol

# ---------------------------------------------------------------------------
# Upstream action set — pinned by contract test `test_tg_action_set_exhaustive`.
# Sourced from guardian.core.config.ActionConfig literal unions (TG 0.1.0).
# Update ONLY in lockstep with a TG version bump + test + ADR-004 errata.
# ---------------------------------------------------------------------------
TG_ACTION_SET: frozenset[str] = frozenset(
    {"pass", "passthrough", "retry", "abort", "alert"}
)

# ADR-004 ActionType. Mirrors qc/types.py::ActionType — duplicated here as
# a plain Literal so that action_map.py has no intra-package imports and
# can be unit-tested in isolation.
ActionType = Literal[
    "pass_through", "retry", "degrade", "human_queue", "fail_fast"
]

# ---------------------------------------------------------------------------
# Mismatch #1 table.
#
# Note the two-to-one fold: TG `pass` and `passthrough` both collapse to
# ADR-004 `pass_through`. The Adapter still records the original TG action
# in `CheckpointResult.raw["tg_action"]` so auditors can distinguish the
# two cases later (see adapter.py).
# ---------------------------------------------------------------------------
_BASE_MAP: dict[str, ActionType] = {
    "pass":        "pass_through",
    "passthrough": "pass_through",
    "retry":       "retry",
    "abort":       "fail_fast",
    "alert":       "human_queue",
}


class UnknownTGActionError(ValueError):
    """Raised when TG emits an action literal outside TG_ACTION_SET.

    Hard failure by design. See module docstring: we do NOT silently
    default to `fail_fast` because that would mask upstream API drift.
    A loud break forces the Adapter owner to audit the new literal
    before the pipeline ships.
    """

    def __init__(self, tg_action: str) -> None:
        super().__init__(
            f"Unknown TG action literal: {tg_action!r}. "
            f"Expected one of {sorted(TG_ACTION_SET)}. "
            f"If TG added a new action, update TG_ACTION_SET and _BASE_MAP "
            f"together, then re-run the contract tests."
        )
        self.tg_action = tg_action


class ActionEscalator(Protocol):
    """Policy hook that may escalate a translated action to `degrade`.

    Concrete implementations live in future `policy.py` (see T-TG-002 §8
    subtask S-6). Keeping this a Protocol lets action_map.py stay
    dependency-free and allows the Adapter to work without a policy file
    (degrade simply never fires until policy is wired).
    """

    def __call__(
        self,
        base_action: "ActionType",
        *,
        confidence: float,
        attempt: int,
    ) -> "ActionType": ...


def translate(tg_action: str) -> ActionType:
    """Translate a raw TG action literal into an ADR-004 ActionType.

    Pure word-for-word mapping. Escalation to `degrade` (which TG cannot
    emit) happens in `maybe_escalate` below, after a policy-level decision.
    """
    try:
        return _BASE_MAP[tg_action]
    except KeyError:
        raise UnknownTGActionError(tg_action) from None


def maybe_escalate(
    base_action: ActionType,
    *,
    confidence: float,
    attempt: int,
    escalator: ActionEscalator | None = None,
) -> ActionType:
    """Optionally escalate a translated action to `degrade`.

    TG has no `degrade` concept. 华典 escalation policy (ADR-004 §五) may
    decide, based on `confidence` and `attempt`, to downgrade the model
    tier instead of retrying / failing. That policy lives outside this
    module — pass an `escalator` callable to apply it.

    Without an escalator this function is the identity — keeps the base
    Adapter workable even before policy.yml lands.
    """
    if escalator is None:
        return base_action
    return escalator(base_action, confidence=confidence, attempt=attempt)
