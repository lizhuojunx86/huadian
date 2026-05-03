"""Tests for framework.identity_resolver.types — frozen dataclass shapes."""

from __future__ import annotations

import pytest

from framework.identity_resolver.types import (
    BlockedMerge,
    HypothesisProposal,
    MatchResult,
    MergeGroup,
    MergeProposal,
    ResolveResult,
)


def test_match_result_is_frozen_and_round_trips():
    from dataclasses import FrozenInstanceError

    m = MatchResult(rule="R1", confidence=0.95, evidence={"shared": ["X"]})
    assert m.rule == "R1"
    assert m.confidence == 0.95
    assert m.evidence == {"shared": ["X"]}
    # frozen dataclass — assignment must raise FrozenInstanceError
    with pytest.raises(FrozenInstanceError):
        m.confidence = 0.5  # type: ignore[misc]


def test_merge_proposal_holds_pair_metadata():
    m = MatchResult(rule="R1", confidence=0.95, evidence={})
    p = MergeProposal(
        entity_a_id="a",
        entity_b_id="b",
        entity_a_name="周成王",
        entity_b_name="楚成王",
        match=m,
    )
    assert (p.entity_a_id, p.entity_b_id) == ("a", "b")
    assert p.match.rule == "R1"


def test_merge_group_lists_are_independent_per_instance():
    """Mutable defaults must not bleed across MergeGroup instances."""
    g1 = MergeGroup(
        canonical_id="c1",
        canonical_name="A",
        canonical_slug="a",
        merged_ids=[],
        merged_names=[],
        merged_slugs=[],
        reason="",
        proposals=[],
    )
    g2 = MergeGroup(
        canonical_id="c2",
        canonical_name="B",
        canonical_slug="b",
        merged_ids=[],
        merged_names=[],
        merged_slugs=[],
        reason="",
        proposals=[],
    )
    g1.merged_ids.append("x")
    assert g2.merged_ids == []


def test_resolve_result_aggregates_groups_hypotheses_blocked():
    rr = ResolveResult(
        run_id="run-1",
        total_entities=10,
        merge_groups=[],
        hypotheses=[],
        blocked_merges=[],
        r6_distribution={},
    )
    assert rr.run_id == "run-1"
    assert rr.total_entities == 10
    assert rr.merge_groups == []
    assert rr.r6_distribution == {}


def test_blocked_merge_carries_guard_payload():
    b = BlockedMerge(
        entity_a_id="a",
        entity_b_id="b",
        entity_a_name="周成王",
        entity_b_name="楚成王",
        proposed_rule="R1",
        guard_type="cross_dynasty",
        guard_payload={"gap_years": 250, "reason": "周 vs 楚 midpoint > 200yr"},
        evidence={"shared_name": "成王"},
    )
    assert b.guard_type == "cross_dynasty"
    assert b.guard_payload["gap_years"] == 250
    assert b.proposed_rule == "R1"
    assert b.evidence["shared_name"] == "成王"


def test_hypothesis_proposal_is_below_merge_threshold():
    """Hypotheses are weak signals — they exist as a separate type."""
    h = HypothesisProposal(
        entity_a_id="a",
        entity_b_id="b",
        entity_a_name="X",
        entity_b_name="Y",
        match=MatchResult(rule="R5", confidence=0.6, evidence={}),
    )
    assert h.match.confidence < 0.85  # below default MERGE_CONFIDENCE_THRESHOLD
