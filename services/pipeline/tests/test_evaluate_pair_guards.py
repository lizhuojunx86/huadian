"""Unit tests for evaluate_pair_guards rule-aware dispatch (T-P1-028 / ADR-025).

This file implements the test matrix specified in **ADR-025 §2.6**:

  Test 1 — R1 + cross_dynasty guard 命中（跨 dynasty 同 surface → blocked）
  Test 2 — R1 + cross_dynasty guard 不命中（同 dynasty 同 surface → pass）
  Test 3 — R6 vs R1 阈值差异（500yr R6 pass / 200yr R1 block，gap 在中间）
  Test 4 — dynasty 字段缺映射时 fallback（unregistered dynasty → None）
  Test 5 — V11 invariant 依赖回归（BlockedMerge pair-order 满足 DB CHECK）
  Test 6 — R6 既有路径回归（evaluate_guards → evaluate_pair_guards(R6) 等价）

Each test method docstring tags the corresponding ADR-025 §2.6 item number
("ADR-025 §2.6 #N") so review can be reconciled one-to-one against the ADR.
"""

from __future__ import annotations

import warnings

import pytest

from huadian_pipeline.r6_seed_match import R6Status
from huadian_pipeline.r6_temporal_guards import (
    GUARD_THRESHOLDS,
    cross_dynasty_guard,
    evaluate_guards,
    evaluate_pair_guards,
    reset_dynasty_cache,
)
from huadian_pipeline.resolve import R6PrePassResult, _detect_r6_merges
from huadian_pipeline.resolve_rules import PersonSnapshot

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _snap(
    *,
    id: str = "00000000-0000-0000-0000-000000000001",  # noqa: A002
    name: str = "测试",
    slug: str = "test",
    dynasty: str = "",
    surface_forms: set[str] | None = None,
    r6_result: R6PrePassResult | None = None,
) -> PersonSnapshot:
    """Create a minimal PersonSnapshot for guard testing."""
    return PersonSnapshot(
        id=id,
        name=name,
        slug=slug,
        dynasty=dynasty,
        surface_forms=surface_forms if surface_forms is not None else set(),
        identity_notes=[],
        created_at="2026-01-01T00:00:00",
        r6_result=r6_result,
    )


# ---------------------------------------------------------------------------
# ADR-025 §2.6 #1 + #2 — R1 guard hit / pass
# ---------------------------------------------------------------------------


class TestR1GuardHit:
    """ADR-025 §2.6 #1 — R1 + cross_dynasty guard 命中."""

    def setup_method(self) -> None:
        reset_dynasty_cache()

    def test_r1_blocks_zhanguo_vs_xizhou(self) -> None:
        """ADR-025 §2.6 #1 — 战国 vs 西周: gap 561yr > 200yr → R1 blocked.

        Real-world case (秦γ G2 / 项羽δ G1): 周成王(西周) ↔ 楚成王(春秋)
        with shared surface "成王". Constructed here with 西周/战国 to
        amplify gap and make the test stable across yaml tweaks.
        """
        a = _snap(id="aaaa", name="周成王", dynasty="西周", surface_forms={"成王", "周成王"})
        b = _snap(id="bbbb", name="楚成王", dynasty="战国", surface_forms={"成王", "楚成王"})
        result = evaluate_pair_guards(a, b, rule="R1")
        assert result is not None
        assert result.blocked is True
        assert result.guard_type == "cross_dynasty"
        assert result.payload["dynasty_a"] == "西周"
        assert result.payload["dynasty_b"] == "战国"
        assert result.payload["gap_years"] > 200
        assert result.payload["threshold"] == 200  # R1 threshold

    def test_r1_blocks_xizhou_vs_chunqiu(self) -> None:
        """ADR-025 §2.6 #1 — 西周 vs 春秋: gap 286yr > 200yr → R1 blocked.

        Direct historian-data case (项羽δ G1/G3/G6/G7): standard cross-period
        boundary that 200yr threshold should catch.
        """
        a = _snap(id="aaaa", name="周成王", dynasty="西周")
        b = _snap(id="bbbb", name="楚成王", dynasty="春秋")
        result = evaluate_pair_guards(a, b, rule="R1")
        assert result is not None
        assert result.blocked is True
        assert result.payload["gap_years"] == 286


class TestR1GuardPass:
    """ADR-025 §2.6 #2 — R1 + cross_dynasty guard 不命中."""

    def setup_method(self) -> None:
        reset_dynasty_cache()

    def test_r1_passes_same_dynasty_same_state(self) -> None:
        """ADR-025 §2.6 #2 — 同朝代同国: cross_dynasty(gap=0→None) + state_prefix(same→None).

        Uses 秦穆公↔秦桓公 (same state 秦): all guards in R1 GUARD_CHAIN pass.
        Sprint I update: 鲁桓公↔秦桓公 is now correctly blocked by state_prefix_guard
        (ADR-025 §5.3 — gap=0 cross-state FP resolution). The §2.6 #2 intent is
        preserved by using a same-state pair that should proceed to MergeProposal.
        """
        a = _snap(id="aaaa", name="秦穆公", dynasty="春秋")
        b = _snap(id="bbbb", name="秦桓公", dynasty="春秋")
        result = evaluate_pair_guards(a, b, rule="R1")
        assert result is None  # same dynasty + same state → no guard fires

    def test_r1_passes_within_threshold(self) -> None:
        """ADR-025 §2.6 #2 — 战国 vs 秦末: gap 140yr < 200yr → pass.

        Known limitation: 楚怀王(熊槐 战国) ↔ 熊心(秦末) gap 140yr is
        below R1 threshold; this case is handled by T-P0-031 data fix
        path, not by guard.
        """
        a = _snap(id="aaaa", name="熊槐", dynasty="战国")
        b = _snap(id="bbbb", name="熊心", dynasty="秦末")
        result = evaluate_pair_guards(a, b, rule="R1")
        assert result is None  # gap=140 < 200, guard passes


# ---------------------------------------------------------------------------
# ADR-025 §2.6 #3 — Threshold differentiation between R1 and R6
# ---------------------------------------------------------------------------


class TestR1VsR6ThresholdDifferentiation:
    """ADR-025 §2.6 #3 — R1=200yr vs R6=500yr 阈值差异验证."""

    def setup_method(self) -> None:
        reset_dynasty_cache()

    def test_r1_blocks_but_r6_passes_at_intermediate_gap(self) -> None:
        """ADR-025 §2.6 #3 — Same pair, gap=275yr: R1 blocks / R6 passes.

        春秋(-623) vs 战国(-348) gap=275yr is between 200 (R1) and 500 (R6).
        Same PersonSnapshot pair must produce divergent guard outcomes
        based purely on `rule` argument — proving rule-aware dispatch
        works as designed.
        """
        a = _snap(id="aaaa", name="孔子", dynasty="春秋")
        b = _snap(id="bbbb", name="商鞅", dynasty="战国")

        r1_result = evaluate_pair_guards(a, b, rule="R1")
        assert r1_result is not None
        assert r1_result.blocked is True
        assert r1_result.payload["gap_years"] == 275
        assert r1_result.payload["threshold"] == 200

        r6_result = evaluate_pair_guards(a, b, rule="R6")
        assert r6_result is None  # 275 < 500, R6 passes

    def test_guard_thresholds_registry_values(self) -> None:
        """ADR-025 §2.6 #3 — GUARD_THRESHOLDS configuration matches ADR §2.2."""
        assert GUARD_THRESHOLDS["R1"] == 200
        assert GUARD_THRESHOLDS["R6"] == 500


# ---------------------------------------------------------------------------
# ADR-025 §2.6 #4 — Missing dynasty mapping fallback
# ---------------------------------------------------------------------------


class TestMissingDynastyFallback:
    """ADR-025 §2.6 #4 — dynasty 字段缺映射时 fallback (no GuardResult)."""

    def setup_method(self) -> None:
        reset_dynasty_cache()

    def test_unregistered_dynasty_returns_none(self) -> None:
        """ADR-025 §2.6 #4 — Unknown dynasty → None (does not block).

        Per ADR-025 §4.2: yaml-missing dynasties cause silent fallback to
        None, allowing the merge proposal to proceed unchanged. This is
        a documented limitation; guard cannot evaluate without mapping.
        """
        a = _snap(id="aaaa", name="未知人甲", dynasty="不存在的朝代")
        b = _snap(id="bbbb", name="未知人乙", dynasty="春秋")
        result = evaluate_pair_guards(a, b, rule="R1")
        assert result is None  # missing yaml mapping → no guard fires

    def test_empty_dynasty_returns_none(self) -> None:
        """ADR-025 §2.6 #4 — Empty dynasty string → None.

        Persons created before dynasty was a required field will have
        dynasty='' (empty string). Guard must not raise / not block.
        """
        a = _snap(id="aaaa", name="甲", dynasty="")
        b = _snap(id="bbbb", name="乙", dynasty="春秋")
        result = evaluate_pair_guards(a, b, rule="R1")
        assert result is None

    def test_unregistered_rule_returns_none(self) -> None:
        """ADR-025 §2.6 #4 — Rule not in GUARD_THRESHOLDS → None.

        Guard registration is opt-in per rule. R2/R3/R5 currently have
        no entries; they should pass through unchanged.
        """
        a = _snap(id="aaaa", name="周成王", dynasty="西周")
        b = _snap(id="bbbb", name="刘邦", dynasty="西汉")
        # R3 not registered; even with huge gap, no guard fires
        result = evaluate_pair_guards(a, b, rule="R3")
        assert result is None


# ---------------------------------------------------------------------------
# ADR-025 §2.6 #5 — V11 invariant dependency regression (BlockedMerge pair order)
# ---------------------------------------------------------------------------


class TestBlockedMergePairOrderInvariant:
    """ADR-025 §2.6 #5 — V11 invariant 依赖回归.

    pending_merge_reviews has a DB CHECK (person_a_id < person_b_id) and a
    UNIQUE INDEX (person_a_id, person_b_id, proposed_rule, guard_type). The
    BlockedMerge dataclass + write path in resolve.py must preserve pair
    ordering regardless of which person is `a` and which is `b` in the
    pairwise loop. V11 invariant relies on this.
    """

    def setup_method(self) -> None:
        reset_dynasty_cache()

    def test_blocked_merge_via_resolver_normalizes_pair_order(self) -> None:
        """ADR-025 §2.6 #5 — _detect_r6_merges normalizes pair order.

        Same-QID pair where snapshot.id of "a" > snapshot.id of "b" must
        still produce a BlockedMerge with person_a_id < person_b_id.
        Tests the existing R6 normalization path remains correct after
        the rule-aware dispatch refactor (defends against regression
        from S2.3 import / function rename).
        """
        # Construct a pair where input order has a.id > b.id (DESCENDING uuid)
        # but they share the same QID and span dynasties large enough to
        # trigger R6 guard (500yr threshold).
        snap_high = _snap(
            id="ffff0000-0000-0000-0000-000000000001",  # higher uuid
            name="禹",
            dynasty="夏",
            r6_result=R6PrePassResult(
                status=R6Status.MATCHED, qid="Q11111", entry_id="ent1", confidence=0.95
            ),
        )
        snap_low = _snap(
            id="00000000-0000-0000-0000-000000000001",  # lower uuid
            name="刘邦",
            dynasty="西汉",
            r6_result=R6PrePassResult(
                status=R6Status.MATCHED, qid="Q11111", entry_id="ent1", confidence=0.95
            ),
        )

        # Pass them in REVERSE order (high id first) to stress-test
        # ordering normalization
        proposals, blocked = _detect_r6_merges([snap_high, snap_low])

        assert len(proposals) == 0
        assert len(blocked) == 1
        assert blocked[0].person_a_id < blocked[0].person_b_id  # CHECK constraint
        assert blocked[0].proposed_rule == "R6"
        assert blocked[0].guard_type == "cross_dynasty"


# ---------------------------------------------------------------------------
# ADR-025 §2.6 #6 — R6 既有路径回归 (deprecated wrapper equivalence)
# ---------------------------------------------------------------------------


class TestR6DeprecatedWrapperEquivalence:
    """ADR-025 §2.6 #6 — evaluate_guards == evaluate_pair_guards(rule="R6")."""

    def setup_method(self) -> None:
        reset_dynasty_cache()

    def test_wrapper_emits_deprecation_warning(self) -> None:
        """ADR-025 §2.6 #6 — evaluate_guards emits DeprecationWarning.

        Per ADR-025 §2.4 the wrapper must signal removal-by-Sprint-I to
        any third-party caller still using the legacy signature.
        """
        a = _snap(id="aaaa", name="启", dynasty="夏")
        b = _snap(id="bbbb", name="刘邦", dynasty="西汉")
        with pytest.warns(DeprecationWarning, match="evaluate_guards"):
            evaluate_guards(a, b)

    def test_wrapper_blocks_same_as_r6_dispatch(self) -> None:
        """ADR-025 §2.6 #6 — Block path equivalence (legacy ↔ new API).

        For a pair that R6 (500yr) blocks, both call sites must return a
        GuardResult with identical guard_type + payload.
        """
        a = _snap(id="aaaa", name="禹", dynasty="夏")
        b = _snap(id="bbbb", name="刘邦", dynasty="西汉")

        with warnings.catch_warnings():
            warnings.simplefilter("ignore", DeprecationWarning)
            legacy = evaluate_guards(a, b)
        new = evaluate_pair_guards(a, b, rule="R6")

        assert legacy is not None
        assert new is not None
        assert legacy.guard_type == new.guard_type
        assert legacy.payload == new.payload
        assert legacy.blocked == new.blocked is True

    def test_wrapper_passes_same_as_r6_dispatch(self) -> None:
        """ADR-025 §2.6 #6 — Pass path equivalence (legacy ↔ new API)."""
        a = _snap(id="aaaa", name="周公", dynasty="西周")
        b = _snap(id="bbbb", name="召公", dynasty="西周")

        with warnings.catch_warnings():
            warnings.simplefilter("ignore", DeprecationWarning)
            legacy = evaluate_guards(a, b)
        new = evaluate_pair_guards(a, b, rule="R6")

        assert legacy is None
        assert new is None


# ---------------------------------------------------------------------------
# Bonus — cross_dynasty_guard threshold parameterization sanity
# ---------------------------------------------------------------------------


class TestThresholdParameterization:
    """Sanity coverage — cross_dynasty_guard threshold is now per-call.

    Not in ADR-025 §2.6 mandatory list but serves as a guard-rail for
    the keyword-only signature change introduced in S2.3.
    """

    def setup_method(self) -> None:
        reset_dynasty_cache()

    def test_threshold_required_keyword_argument(self) -> None:
        """Calling without threshold_years must raise TypeError."""
        a = _snap(id="aaaa", name="甲", dynasty="夏")
        b = _snap(id="bbbb", name="乙", dynasty="商")
        with pytest.raises(TypeError):
            cross_dynasty_guard(a, b)  # type: ignore[call-arg]

    def test_custom_threshold_independent_of_thresholds_dict(self) -> None:
        """Direct cross_dynasty_guard call with custom threshold works."""
        a = _snap(id="aaaa", name="孔子", dynasty="春秋")
        b = _snap(id="bbbb", name="商鞅", dynasty="战国")
        # gap=275yr; with custom threshold=100, blocks
        result_low = cross_dynasty_guard(a, b, threshold_years=100)
        assert result_low is not None
        assert result_low.blocked is True
        # with custom threshold=1000, passes
        result_high = cross_dynasty_guard(a, b, threshold_years=1000)
        assert result_high is None
