"""Unit tests for state_prefix_guard (ADR-025 §5.3.9).

This file implements the test matrix specified in ADR-025 §5.3.9 (minimum 7):

  Test 1 — state_prefix 命中（核心目标）：鲁桓公 ↔ 秦桓公 → blocked
  Test 2 — state_prefix 不命中（同 state）：秦穆公 ↔ 秦桓公 → None
  Test 3 — 裸谥号 fall through：桓公 ↔ 鲁桓公 → None（单方不命中）
  Test 4 — dynasty + state 双 guard 协同（dynasty 短路）
  Test 5 — dynasty 缺映射 + state 拦截（state_prefix 独立兜底）
  Test 6 — alias 等价：唐X公 ↔ 晋X公 → state==晋 → 不拦
  Test 7 — R6 路径回归：R6 chain 不挂 state_prefix → same-dynasty 跨国 None
"""

from __future__ import annotations

from huadian_pipeline.r6_temporal_guards import (
    evaluate_pair_guards,
    reset_dynasty_cache,
)
from huadian_pipeline.resolve import R6PrePassResult
from huadian_pipeline.resolve_rules import PersonSnapshot
from huadian_pipeline.state_prefix_guard import (
    RULER_TITLES,
    SHIHAO_CHARS,
    reset_states_cache,
    state_prefix_guard,
)

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


def setup_function() -> None:
    reset_dynasty_cache()
    reset_states_cache()


# ---------------------------------------------------------------------------
# Test 1 — state_prefix 命中（核心目标）
# ---------------------------------------------------------------------------


class TestStatePrefixHit:
    """ADR-025 §5.3.9 #1 — 同朝代不同国 FP → state_prefix blocked."""

    def setup_method(self) -> None:
        reset_dynasty_cache()
        reset_states_cache()

    def test_lu_vs_qin_huan_gong(self) -> None:
        """鲁桓公 ↔ 秦桓公: same dynasty (春秋), different state → blocked.

        This is the canonical gap=0 case that cross_dynasty_guard cannot catch
        (ADR-025 §4.2 known limitation). state_prefix_guard is specifically
        designed to cover this class of FP.
        """
        a = _snap(id="aaaa", name="鲁桓公", dynasty="春秋")
        b = _snap(id="bbbb", name="秦桓公", dynasty="春秋")
        result = state_prefix_guard(a, b)
        assert result is not None
        assert result.blocked is True
        assert result.guard_type == "state_prefix"
        assert result.payload["state_a"] == "鲁"
        assert result.payload["state_b"] == "秦"

    def test_jin_vs_qi_dao_gong(self) -> None:
        """晋悼公 ↔ 齐悼公: different state → blocked."""
        a = _snap(id="aaaa", name="晋悼公", dynasty="春秋")
        b = _snap(id="bbbb", name="齐悼公", dynasty="春秋")
        result = state_prefix_guard(a, b)
        assert result is not None
        assert result.blocked is True
        assert result.guard_type == "state_prefix"

    def test_via_evaluate_pair_guards_r1(self) -> None:
        """R1 chain includes state_prefix: 鲁桓公 ↔ 秦桓公 → blocked via evaluate_pair_guards."""
        a = _snap(id="aaaa", name="鲁桓公", dynasty="春秋")
        b = _snap(id="bbbb", name="秦桓公", dynasty="春秋")
        result = evaluate_pair_guards(a, b, rule="R1")
        assert result is not None
        assert result.blocked is True
        assert result.guard_type == "state_prefix"


# ---------------------------------------------------------------------------
# Test 2 — state_prefix 不命中（同 state）
# ---------------------------------------------------------------------------


class TestStatePrefixSameState:
    """ADR-025 §5.3.9 #2 — 同 state → guard 不拦，进 R1 正常流程."""

    def setup_method(self) -> None:
        reset_dynasty_cache()
        reset_states_cache()

    def test_qin_mu_vs_qin_huan(self) -> None:
        """秦穆公 ↔ 秦桓公: same state 秦 → None (guard does not block)."""
        a = _snap(id="aaaa", name="秦穆公", dynasty="春秋")
        b = _snap(id="bbbb", name="秦桓公", dynasty="春秋")
        result = state_prefix_guard(a, b)
        assert result is None

    def test_chu_zhuang_vs_chu_ling(self) -> None:
        """楚庄王 ↔ 楚灵王: same state 楚 → None."""
        a = _snap(id="aaaa", name="楚庄王", dynasty="春秋")
        b = _snap(id="bbbb", name="楚灵王", dynasty="春秋")
        result = state_prefix_guard(a, b)
        assert result is None


# ---------------------------------------------------------------------------
# Test 3 — 裸谥号 fall through
# ---------------------------------------------------------------------------


class TestBareTitleFallThrough:
    """ADR-025 §5.3.9 #3 — 单方裸谥号（无国名前缀）→ fall through → None."""

    def setup_method(self) -> None:
        reset_dynasty_cache()
        reset_states_cache()

    def test_bare_title_vs_prefixed(self) -> None:
        """桓公 ↔ 鲁桓公: 桓公 does not match pattern → None (no over-block).

        Per ADR-025 §5.3.2 single-party semantic: both must match.
        Bare "桓公" should go through to historian review, not be blocked.
        """
        a = _snap(id="aaaa", name="桓公", dynasty="春秋")
        b = _snap(id="bbbb", name="鲁桓公", dynasty="春秋")
        result = state_prefix_guard(a, b)
        assert result is None

    def test_both_bare_titles(self) -> None:
        """武王 ↔ 桓公: neither matches full pattern → None."""
        a = _snap(id="aaaa", name="武王", dynasty="西周")
        b = _snap(id="bbbb", name="桓公", dynasty="春秋")
        result = state_prefix_guard(a, b)
        assert result is None


# ---------------------------------------------------------------------------
# Test 4 — dynasty + state 双 guard 协同（dynasty 短路）
# ---------------------------------------------------------------------------


class TestDynastyShortCircuitsStatePrefix:
    """ADR-025 §5.3.9 #4 — cross_dynasty fires first, state_prefix not reached."""

    def setup_method(self) -> None:
        reset_dynasty_cache()
        reset_states_cache()

    def test_xizhou_vs_chunqiu_dynasty_short_circuits(self) -> None:
        """秦桓公(西周) ↔ 楚桓公(春秋): gap=286>200 → cross_dynasty blocks first.

        Both names match state pattern (秦/楚 in states.yaml), so state_prefix
        would also fire — but dynasty takes precedence via GUARD_CHAIN ordering.
        The result guard_type must be "cross_dynasty", not "state_prefix".
        """
        a = _snap(id="aaaa", name="秦桓公", dynasty="西周")
        b = _snap(id="bbbb", name="楚桓公", dynasty="春秋")
        result = evaluate_pair_guards(a, b, rule="R1")
        assert result is not None
        assert result.blocked is True
        assert result.guard_type == "cross_dynasty"  # dynasty short-circuits
        assert result.payload["gap_years"] == 286


# ---------------------------------------------------------------------------
# Test 5 — dynasty 缺映射 + state 拦截（state_prefix 独立兜底）
# ---------------------------------------------------------------------------


class TestStatePrefixCoversNoDynastyMapping:
    """ADR-025 §5.3.9 #5 — dynasty missing → state_prefix provides fallback."""

    def setup_method(self) -> None:
        reset_dynasty_cache()
        reset_states_cache()

    def test_empty_dynasty_state_prefix_blocks(self) -> None:
        """鲁桓公(dynasty='') ↔ 秦桓公(dynasty=''): dynasty None → state fires.

        Covers the ADR-025 §4.2 / §5.3.6 key complementary point: the ~15%
        persons with dynasty='' (楚汉 era etc.) can now be partially guarded
        by state_prefix if both sides carry explicit state prefixes.
        """
        a = _snap(id="aaaa", name="鲁桓公", dynasty="")
        b = _snap(id="bbbb", name="秦桓公", dynasty="")
        result = evaluate_pair_guards(a, b, rule="R1")
        assert result is not None
        assert result.blocked is True
        assert result.guard_type == "state_prefix"

    def test_unknown_dynasty_state_prefix_blocks(self) -> None:
        """Both have unregistered dynasty → dynasty guard None, state_prefix fires."""
        a = _snap(id="aaaa", name="晋平公", dynasty="未知朝代")
        b = _snap(id="bbbb", name="齐平公", dynasty="未知朝代")
        result = evaluate_pair_guards(a, b, rule="R1")
        assert result is not None
        assert result.blocked is True
        assert result.guard_type == "state_prefix"


# ---------------------------------------------------------------------------
# Test 6 — alias 等价
# ---------------------------------------------------------------------------


class TestAliasEquivalence:
    """ADR-025 §5.3.9 #6 — alias resolves to same canonical state → not blocked."""

    def setup_method(self) -> None:
        reset_dynasty_cache()
        reset_states_cache()

    def test_tang_alias_equals_jin(self) -> None:
        """唐桓公 ↔ 晋桓公: 唐 is alias for 晋 → canonical state==晋 → None.

        Per states.yaml: 晋 aliases: ["唐"] (唐叔虞封地早期称呼).
        Both persons would be from the same state (Jin / 晋) and should
        NOT be blocked by state_prefix_guard.
        """
        a = _snap(id="aaaa", name="唐桓公", dynasty="西周")
        b = _snap(id="bbbb", name="晋桓公", dynasty="西周")
        result = state_prefix_guard(a, b)
        assert result is None

    def test_jing_alias_equals_chu(self) -> None:
        """荆庄王 ↔ 楚庄王: 荆 is alias for 楚 → same state → None."""
        a = _snap(id="aaaa", name="荆庄王", dynasty="春秋")
        b = _snap(id="bbbb", name="楚庄王", dynasty="春秋")
        result = state_prefix_guard(a, b)
        assert result is None


# ---------------------------------------------------------------------------
# Test 7 — R6 路径回归（R6 chain 不挂 state_prefix）
# ---------------------------------------------------------------------------


class TestR6PathNoStatePrefix:
    """ADR-025 §5.3.9 #7 — R6 GUARD_CHAIN does not include state_prefix_guard.

    Sprint H 既有 28 tests must still pass (see test_r6_temporal_guards.py and
    test_evaluate_pair_guards.py). This class adds targeted regression for the
    specific state_prefix exclusion from R6.
    """

    def setup_method(self) -> None:
        reset_dynasty_cache()
        reset_states_cache()

    def test_r6_same_dynasty_different_state_not_blocked(self) -> None:
        """鲁桓公 ↔ 秦桓公 with rule="R6": dynasty gap=0, no state_prefix in R6 → None.

        If state_prefix were in the R6 chain, this would return blocked=True.
        Asserting None proves R6 chain excludes state_prefix_guard.
        """
        a = _snap(id="aaaa", name="鲁桓公", dynasty="春秋")
        b = _snap(id="bbbb", name="秦桓公", dynasty="春秋")
        result = evaluate_pair_guards(a, b, rule="R6")
        assert result is None  # R6: cross_dynasty(gap=0→None), no state_prefix

    def test_r1_blocks_where_r6_passes_same_state_pair(self) -> None:
        """Same pair: R1 → blocked (state_prefix), R6 → None (no state_prefix).

        Demonstrates the R1/R6 behavioral divergence due to GUARD_CHAIN difference.
        """
        a = _snap(id="aaaa", name="鲁桓公", dynasty="春秋")
        b = _snap(id="bbbb", name="秦桓公", dynasty="春秋")
        r1 = evaluate_pair_guards(a, b, rule="R1")
        r6 = evaluate_pair_guards(a, b, rule="R6")
        assert r1 is not None and r1.blocked is True and r1.guard_type == "state_prefix"
        assert r6 is None


# ---------------------------------------------------------------------------
# Bonus — constant validation
# ---------------------------------------------------------------------------


class TestConstants:
    """Sanity checks for SHIHAO_CHARS and RULER_TITLES (ADR-025 §5.3.4)."""

    def test_shihao_chars_not_empty(self) -> None:
        assert len(SHIHAO_CHARS) >= 25

    def test_ruler_titles_contains_expected(self) -> None:
        assert "王" in RULER_TITLES
        assert "公" in RULER_TITLES
        assert "侯" in RULER_TITLES

    def test_states_yaml_loads_17_states(self) -> None:
        """Verify states.yaml contains exactly 17 states (Sprint I §2.2)."""
        reset_states_cache()
        from huadian_pipeline.state_prefix_guard import _get_states

        entries, alias_to_canonical = _get_states()
        assert len(entries) == 17
        assert len(alias_to_canonical) >= 17  # at least 17 primary names
