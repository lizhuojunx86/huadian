"""Tests for framework.identity_resolver.guards — chain dispatch + payload swap."""

from __future__ import annotations

from framework.identity_resolver import EntitySnapshot, GuardResult
from framework.identity_resolver.guards import evaluate_pair_guards
from framework.identity_resolver.utils import swap_ab_payload


def _make_e(id: str, name: str = "X", slug: str = "x") -> EntitySnapshot:  # noqa: A002
    return EntitySnapshot(
        id=id,
        name=name,
        slug=slug,
        surface_forms={name},
        created_at="2026-01-01T00:00:00Z",
    )


def _blocking_guard(reason: str = "blocked"):
    def _g(a, b):
        return GuardResult(
            guard_type="t1",
            blocked=True,
            reason=reason,
            payload={"a_id": a.id, "b_id": b.id},
        )

    return _g


def _passing_guard():
    def _g(a, b):
        return GuardResult(
            guard_type="t2",
            blocked=False,
            reason="ok",
            payload={},
        )

    return _g


def _none_guard():
    def _g(a, b):  # noqa: ARG001
        return None

    return _g


def test_first_blocking_guard_wins():
    a, b = _make_e("a"), _make_e("b")
    chain = [_passing_guard(), _blocking_guard("first-blocker"), _blocking_guard("second")]
    result = evaluate_pair_guards(a, b, rule="R1", guard_chains={"R1": chain})
    assert result is not None
    assert result.blocked is True
    assert result.reason == "first-blocker"


def test_returns_none_when_no_guard_blocks():
    a, b = _make_e("a"), _make_e("b")
    chain = [_passing_guard(), _none_guard()]
    result = evaluate_pair_guards(a, b, rule="R1", guard_chains={"R1": chain})
    assert result is None


def test_rule_without_registered_chain_returns_none():
    """Guards are opt-in per rule — unregistered rule = no guard."""
    a, b = _make_e("a"), _make_e("b")
    result = evaluate_pair_guards(a, b, rule="Rxx", guard_chains={"R1": []})
    assert result is None


def test_chain_runs_each_guard_with_correct_pair():
    a, b = _make_e("a"), _make_e("b")
    seen: list[tuple[str, str]] = []

    def recording_guard(_a, _b):
        seen.append((_a.id, _b.id))
        return None

    chain = [recording_guard, recording_guard]
    evaluate_pair_guards(a, b, rule="R1", guard_chains={"R1": chain})
    assert seen == [("a", "b"), ("a", "b")]


def test_swap_ab_payload_swaps_conventional_keys():
    """swap_ab_payload (utils) flips dynasty_a/_b, name_a/_b, raw_state_a/_b."""
    payload = {
        "dynasty_a": "周",
        "dynasty_b": "楚",
        "name_a": "X",
        "name_b": "Y",
        "raw_state_a": "晋",
        "raw_state_b": "齐",
        "other": "unchanged",
    }
    swapped = swap_ab_payload(payload)
    assert swapped["dynasty_a"] == "楚" and swapped["dynasty_b"] == "周"
    assert swapped["name_a"] == "Y" and swapped["name_b"] == "X"
    assert swapped["raw_state_a"] == "齐" and swapped["raw_state_b"] == "晋"
    assert swapped["other"] == "unchanged"
    # Original must be untouched (immutable in spirit)
    assert payload["dynasty_a"] == "周"
