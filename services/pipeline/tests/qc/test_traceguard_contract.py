"""ADR-004 §Errata E-4 — 3 contract tests guarding the TG/Adapter seam.

These tests are intentionally defensive: if TG ships a 0.2.x that changes
the public surface or emits a new action literal, **CI must break** and
the Adapter owner must consciously bump the pin + update the mapping.
They are NOT testing Adapter semantics — that is what
`test_adapter.py` (future) is for.

Why three tests, in order:

  1. `test_tg_exports_only_4_symbols` — locks the upstream's frozen
     public API (`guardian.__all__`). Any new / renamed / removed
     top-level symbol trips the wire.

  2. `test_every_tg_action_maps_correctly` — feeds every TG action
     literal through the Adapter's translator and asserts the exact
     ADR-004 ActionType per Mismatch #1. Detects accidental edits to
     the mapping table.

  3. `test_tg_action_set_exhaustive` — pins the TG action vocabulary.
     If TG 0.2.x introduces `degrade` natively (for instance), this
     fails until someone revisits Mismatch #1.
"""

from __future__ import annotations

import guardian  # type: ignore[import-untyped]
import pytest

from huadian_pipeline.qc.action_map import (
    TG_ACTION_SET,
    UnknownTGActionError,
    translate,
)

# ---------------------------------------------------------------------------
# Contract #1 — public symbol surface
# ---------------------------------------------------------------------------

_EXPECTED_TG_EXPORTS: frozenset[str] = frozenset(
    {"evaluate_async", "StepOutput", "GuardianConfig", "GuardianDecision"}
)


def test_tg_exports_only_4_symbols() -> None:
    """`guardian.__all__` must stay frozen at the 4 baseline symbols.

    If this fails: TG upstream shipped a new / renamed / removed public
    symbol. Do NOT edit _EXPECTED_TG_EXPORTS to make the test pass —
    first review the upstream change, update `_imports.py`, update
    Mismatch tables + ADR-004 errata, then adjust this set in lockstep.
    """
    actual = frozenset(guardian.__all__)
    missing = _EXPECTED_TG_EXPORTS - actual
    extra = actual - _EXPECTED_TG_EXPORTS
    assert not missing, (
        f"TG removed expected symbol(s): {sorted(missing)}. "
        "Revise Adapter before bumping the pin."
    )
    assert not extra, (
        f"TG added new symbol(s): {sorted(extra)}. "
        "Review semantics and decide whether to surface via _imports."
    )


# ---------------------------------------------------------------------------
# Contract #2 — action translation (Mismatch #1)
# ---------------------------------------------------------------------------

# Source of truth for the per-literal expected mapping. Duplicated here
# (rather than imported from action_map._BASE_MAP) on purpose: if someone
# edits _BASE_MAP without updating this table, the test catches it.
_EXPECTED_MAPPING: dict[str, str] = {
    "pass":        "pass_through",
    "passthrough": "pass_through",
    "retry":       "retry",
    "abort":       "fail_fast",
    "alert":       "human_queue",
}


@pytest.mark.parametrize(
    ("tg_action", "adr_action"),
    list(_EXPECTED_MAPPING.items()),
    ids=list(_EXPECTED_MAPPING.keys()),
)
def test_every_tg_action_maps_correctly(tg_action: str, adr_action: str) -> None:
    """Every TG literal translates per Mismatch #1 (no drift)."""
    assert translate(tg_action) == adr_action


def test_translate_rejects_unknown_literals() -> None:
    """Unknown TG literal must raise — silent defaults would mask drift."""
    with pytest.raises(UnknownTGActionError):
        translate("yolo")


# ---------------------------------------------------------------------------
# Contract #3 — TG action vocabulary exhaustive
# ---------------------------------------------------------------------------

def test_tg_action_set_exhaustive() -> None:
    """TG's set of action literals is exactly the five we pinned.

    If this fails, TG has either added or removed an action literal in
    its `ActionConfig` model. Decide (with the architect) whether to
    fold / route the new literal, then update `TG_ACTION_SET`, `_BASE_MAP`,
    and this test together.
    """
    assert frozenset(
        {"pass", "passthrough", "retry", "abort", "alert"}
    ) == TG_ACTION_SET
    # And it matches the keys of the translation table so the two can
    # never drift apart without the mapping tests also failing.
    assert frozenset(_EXPECTED_MAPPING.keys()) == TG_ACTION_SET
