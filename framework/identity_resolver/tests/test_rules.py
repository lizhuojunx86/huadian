"""Tests for framework.identity_resolver.rules — R1/R3/R4/R5 + score_pair + context."""

from __future__ import annotations

import re

from framework.identity_resolver import EntitySnapshot, build_score_pair_context
from framework.identity_resolver.rules import (
    DEFAULT_RULE_ORDER,
    MERGE_CONFIDENCE_THRESHOLD,
    ScorePairContext,
    rule_r1,
    rule_r3,
    rule_r4,
    rule_r5,
    score_pair,
)


def _e(id, name, slug=None, surface=None, dynasty=None, notes=None):  # noqa: A002
    return EntitySnapshot(
        id=id,
        name=name,
        slug=slug or name,
        surface_forms=set(surface) if surface else {name},
        created_at="2026-01-01T00:00:00Z",
        domain_attrs={"dynasty": dynasty} if dynasty else {},
        identity_notes=notes or [],
    )


def test_build_score_pair_context_with_no_plugins_yields_empty_dicts():
    ctx = build_score_pair_context()
    assert isinstance(ctx, ScorePairContext)
    assert ctx.synonym_dict == {}
    assert ctx.alias_dict == {}
    assert ctx.stop_words == frozenset()
    assert ctx.notes_patterns == []
    assert ctx.merge_threshold == MERGE_CONFIDENCE_THRESHOLD
    assert ctx.custom_rules == []


def test_build_score_pair_context_threads_custom_rules_through():
    def my_rule(a, b, ctx):  # noqa: ARG001
        return None

    ctx = build_score_pair_context(custom_rules=[my_rule])
    assert ctx.custom_rules == [my_rule]


def test_rule_r1_matches_when_meaningful_name_overlaps():
    """R1 fires when both entities share a non-stop-word name."""
    a = _e("a", "周成王", surface=["周成王", "成王"])
    b = _e("b", "成王传记", surface=["成王传记", "成王"])
    ctx = build_score_pair_context()
    result = rule_r1(a, b, ctx)
    # Without explicit stop words, "成王" should overlap → R1 fires
    assert result is not None
    assert result.rule == "R1"
    assert result.confidence >= 0.8


def test_rule_r1_returns_none_when_no_meaningful_overlap():
    a = _e("a", "周成王", surface={"周成王"})
    b = _e("b", "汉武帝", surface={"汉武帝"})
    ctx = build_score_pair_context()
    assert rule_r1(a, b, ctx) is None


def test_rule_r3_uses_synonym_dict_for_variant_chars():
    """R3 fires when names map through synonym_dict to the same canonical."""
    a = _e("a", "倕")
    b = _e("b", "垂")
    ctx = ScorePairContext(synonym_dict={"倕": "垂"})
    result = rule_r3(a, b, ctx)
    assert result is not None
    assert result.rule == "R3"


def test_rule_r3_returns_none_when_synonym_dict_empty():
    a = _e("a", "倕")
    b = _e("b", "垂")
    ctx = ScorePairContext()
    assert rule_r3(a, b, ctx) is None


def test_rule_r5_matches_aliases_through_alias_dict_with_dynasty_match():
    """R5 fires when alias_dict has the (a, b) pair and dynasties agree."""
    a = _e("a", "文王", dynasty="周")
    b = _e("b", "姬昌", dynasty="周")
    ctx = ScorePairContext(
        alias_dict={
            ("文王", "姬昌"): {
                "canonical": "文王",
                "alias": "姬昌",
                "dynasty": "周",
                "source": "miaohao",
            },
            ("姬昌", "文王"): {
                "canonical": "文王",
                "alias": "姬昌",
                "dynasty": "周",
                "source": "miaohao",
            },
        }
    )
    result = rule_r5(a, b, ctx)
    assert result is not None
    assert result.rule == "R5"


def test_rule_r4_matches_when_one_entity_notes_reference_the_other():
    """R4 fires when entity_a's identity_notes contain a reference to entity_b."""
    a = _e(
        "a",
        "刘邦",
        notes=["即位前称沛公，原名刘季"],
    )
    b = _e("b", "刘季")
    pattern = re.compile(r"(?:原名|又名|本名)([一-龥]+)")
    ctx = ScorePairContext(notes_patterns=[pattern])
    result = rule_r4(a, b, ctx)
    assert result is not None
    assert result.rule == "R4"


def test_score_pair_returns_first_matching_rule_in_default_order():
    """First-match-wins: R1 (surface) fires before R3 (synonym) when both apply."""
    a = _e("a", "成王", surface={"成王"})
    b = _e("b", "成王别号", surface={"成王别号", "成王"})
    ctx = build_score_pair_context()
    result = score_pair(a, b, ctx)
    assert result is not None
    assert result.rule == "R1"
    # default rule order has R1 first
    assert DEFAULT_RULE_ORDER[0] is rule_r1
