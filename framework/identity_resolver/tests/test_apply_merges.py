"""Tests for framework.identity_resolver.apply_merges — filter helper."""

from __future__ import annotations

from framework.identity_resolver import MergeGroup, MergeProposal
from framework.identity_resolver.apply_merges import filter_groups_by_skip_rules
from framework.identity_resolver.types import MatchResult


def _proposal(rule: str) -> MergeProposal:
    return MergeProposal(
        entity_a_id="a",
        entity_b_id="b",
        entity_a_name="A",
        entity_b_name="B",
        match=MatchResult(rule=rule, confidence=0.9, evidence={}),
    )


def _group(name: str, *rules: str) -> MergeGroup:
    return MergeGroup(
        canonical_id=f"id-{name}",
        canonical_name=name,
        canonical_slug=name.lower(),
        merged_ids=["x"],
        merged_names=["Y"],
        merged_slugs=["y"],
        reason="test",
        proposals=[_proposal(r) for r in rules],
    )


def test_filter_drops_groups_whose_proposals_are_all_skipped():
    g_only_r6 = _group("g1", "R6")
    g_mixed = _group("g2", "R6", "R1")
    g_no_r6 = _group("g3", "R1")
    out = filter_groups_by_skip_rules(
        [g_only_r6, g_mixed, g_no_r6],
        skip_rules={"R6"},
    )
    # g_only_r6 dropped; g_mixed kept (has R1); g_no_r6 kept
    names = [g.canonical_name for g in out]
    assert names == ["g2", "g3"]


def test_filter_with_empty_skip_rules_is_a_no_op():
    groups = [_group("g1", "R1"), _group("g2", "R6")]
    out = filter_groups_by_skip_rules(groups, skip_rules=set())
    assert out == groups
