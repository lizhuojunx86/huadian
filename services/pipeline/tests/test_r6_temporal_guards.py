"""Unit tests for R6 temporal guards (T-P0-029).

Tests:
  - DynastyPeriod loading from YAML
  - cross_dynasty_guard: blocking and pass-through scenarios
  - evaluate_pair_guards(rule="R6"): chain execution
  - _detect_r6_merges integration: guard-blocked pairs vs proposals
  - BlockedMerge pair ordering (DB CHECK constraint)
"""

from __future__ import annotations

import pytest

from huadian_pipeline.r6_seed_match import R6Status
from huadian_pipeline.r6_temporal_guards import (
    CROSS_DYNASTY_THRESHOLD_YEARS,
    GuardResult,
    _get_dynasty_periods,
    _load_dynasty_periods,
    cross_dynasty_guard,
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
    r6_result: R6PrePassResult | None = None,
) -> PersonSnapshot:
    """Create a minimal PersonSnapshot for testing."""
    return PersonSnapshot(
        id=id,
        name=name,
        slug=slug,
        dynasty=dynasty,
        surface_forms=set(),
        identity_notes=[],
        created_at="2026-01-01T00:00:00",
        r6_result=r6_result,
    )


# ---------------------------------------------------------------------------
# Dynasty period loading
# ---------------------------------------------------------------------------


class TestDynastyPeriodLoading:
    """Tests for dynasty-periods.yaml loading."""

    def setup_method(self) -> None:
        reset_dynasty_cache()

    def test_load_returns_non_empty(self) -> None:
        periods = _load_dynasty_periods()
        assert len(periods) > 0

    def test_xia_period_present(self) -> None:
        periods = _load_dynasty_periods()
        assert "夏" in periods
        xia = periods["夏"]
        assert xia.start_year == -2070
        assert xia.end_year == -1600
        assert xia.midpoint == -1835

    def test_shang_period_present(self) -> None:
        periods = _load_dynasty_periods()
        assert "商" in periods
        shang = periods["商"]
        assert shang.start_year == -1600
        assert shang.end_year == -1046

    def test_alias_lookup(self) -> None:
        """Aliases should resolve to the same DynastyPeriod as the name."""
        periods = _load_dynasty_periods()
        assert "殷" in periods
        assert periods["殷"] is periods["商"]

    def test_all_11_base_dynasties_present(self) -> None:
        """All 11 dynasty values from Phase 0 DB should be in the mapping."""
        periods = _load_dynasty_periods()
        expected = [
            "上古",
            "夏",
            "商",
            "商末周初",
            "先周",
            "西周",
            "周",
            "春秋",
            "东周",
            "战国",
            "秦",
            "西汉",
        ]
        for name in expected:
            assert name in periods, f"Missing dynasty: {name}"

    def test_cached_singleton(self) -> None:
        """Repeated calls return the same dict object."""
        p1 = _get_dynasty_periods()
        p2 = _get_dynasty_periods()
        assert p1 is p2


# ---------------------------------------------------------------------------
# cross_dynasty_guard
# ---------------------------------------------------------------------------


class TestCrossDynastyGuard:
    """Tests for cross_dynasty_guard function."""

    def setup_method(self) -> None:
        reset_dynasty_cache()

    def test_blocks_xia_vs_shang(self) -> None:
        """夏 vs 商: midpoint gap ~512yr > 500yr threshold -> blocked."""
        a = _snap(id="aaaa", name="启", dynasty="夏")
        b = _snap(id="bbbb", name="微子启", dynasty="商")
        result = cross_dynasty_guard(a, b, threshold_years=CROSS_DYNASTY_THRESHOLD_YEARS)
        assert result is not None
        assert result.blocked is True
        assert result.guard_type == "cross_dynasty"
        assert result.payload["dynasty_a"] == "夏"
        assert result.payload["dynasty_b"] == "商"
        assert result.payload["gap_years"] > CROSS_DYNASTY_THRESHOLD_YEARS

    def test_passes_same_dynasty(self) -> None:
        """西周 vs 西周: gap = 0 -> pass (no guard result)."""
        a = _snap(id="aaaa", name="周公", dynasty="西周")
        b = _snap(id="bbbb", name="周公旦", dynasty="西周")
        result = cross_dynasty_guard(a, b, threshold_years=CROSS_DYNASTY_THRESHOLD_YEARS)
        assert result is None

    def test_passes_adjacent_dynasties(self) -> None:
        """商末周初 vs 西周: close enough -> pass."""
        a = _snap(id="aaaa", name="微子", dynasty="商末周初")
        b = _snap(id="bbbb", name="周武王", dynasty="西周")
        result = cross_dynasty_guard(a, b, threshold_years=CROSS_DYNASTY_THRESHOLD_YEARS)
        # gap = |(-1050) - (-909)| = 141yr < 500yr -> pass
        assert result is None

    def test_blocks_shanggu_vs_xizhou(self) -> None:
        """上古 vs 西周: midpoint gap ~1626yr > 500yr -> blocked."""
        a = _snap(id="aaaa", name="伏羲", dynasty="上古")
        b = _snap(id="bbbb", name="周公", dynasty="西周")
        result = cross_dynasty_guard(a, b, threshold_years=CROSS_DYNASTY_THRESHOLD_YEARS)
        assert result is not None
        assert result.blocked is True
        assert result.payload["gap_years"] > 1000

    def test_skip_empty_dynasty(self) -> None:
        """Empty dynasty string -> None (cannot evaluate)."""
        a = _snap(id="aaaa", name="甲", dynasty="")
        b = _snap(id="bbbb", name="乙", dynasty="商")
        result = cross_dynasty_guard(a, b, threshold_years=CROSS_DYNASTY_THRESHOLD_YEARS)
        assert result is None

    def test_skip_unknown_dynasty(self) -> None:
        """Unknown dynasty value -> None (cannot evaluate)."""
        a = _snap(id="aaaa", name="甲", dynasty="外星")
        b = _snap(id="bbbb", name="乙", dynasty="商")
        result = cross_dynasty_guard(a, b, threshold_years=CROSS_DYNASTY_THRESHOLD_YEARS)
        assert result is None

    def test_passes_chunqiu_vs_zhanguo(self) -> None:
        """春秋 vs 战国: midpoint gap ~275yr < 500yr -> pass."""
        a = _snap(id="aaaa", name="孔子", dynasty="春秋")
        b = _snap(id="bbbb", name="白起", dynasty="战国")
        result = cross_dynasty_guard(a, b, threshold_years=CROSS_DYNASTY_THRESHOLD_YEARS)
        assert result is None

    def test_blocks_xia_vs_xihan(self) -> None:
        """夏 vs 西汉: midpoint gap ~1738yr > 500yr -> blocked."""
        a = _snap(id="aaaa", name="禹", dynasty="夏")
        b = _snap(id="bbbb", name="刘邦", dynasty="西汉")
        result = cross_dynasty_guard(a, b, threshold_years=CROSS_DYNASTY_THRESHOLD_YEARS)
        assert result is not None
        assert result.blocked is True


# ---------------------------------------------------------------------------
# evaluate_guards (chain)
# ---------------------------------------------------------------------------


class TestEvaluatePairGuardsR6Route:
    """Tests for evaluate_pair_guards(rule='R6') chain — replaces removed evaluate_guards wrapper.

    Updated per ADR-025 §2.4 removal at Sprint J closeout; coverage intent preserved
    at higher abstraction level (evaluate_pair_guards direct call).
    """

    def setup_method(self) -> None:
        reset_dynasty_cache()

    def test_returns_first_blocking_result(self) -> None:
        a = _snap(id="aaaa", name="启", dynasty="夏")
        b = _snap(id="bbbb", name="刘邦", dynasty="西汉")
        result = evaluate_pair_guards(a, b, rule="R6")
        assert result is not None
        assert result.guard_type == "cross_dynasty"

    def test_returns_none_when_all_pass(self) -> None:
        a = _snap(id="aaaa", name="周公", dynasty="西周")
        b = _snap(id="bbbb", name="召公", dynasty="西周")
        result = evaluate_pair_guards(a, b, rule="R6")
        assert result is None


# ---------------------------------------------------------------------------
# _detect_r6_merges integration with guards
# ---------------------------------------------------------------------------


class TestDetectR6MergesWithGuards:
    """Integration tests: _detect_r6_merges + temporal guards."""

    def setup_method(self) -> None:
        reset_dynasty_cache()

    def test_cross_dynasty_pair_blocked(self) -> None:
        """Sprint C case: 启(夏) ↔ 微子启(商) same QID -> blocked, not proposed."""
        a = _snap(
            id="aaaa",
            name="启",
            slug="qi",
            dynasty="夏",
            r6_result=R6PrePassResult(
                status=R6Status.MATCHED, qid="Q186544", entry_id="e1", confidence=1.0
            ),
        )
        b = _snap(
            id="bbbb",
            name="微子启",
            slug="wei-zi-qi",
            dynasty="商",
            r6_result=R6PrePassResult(
                status=R6Status.MATCHED, qid="Q186544", entry_id="e2", confidence=1.0
            ),
        )
        proposals, blocked = _detect_r6_merges([a, b])
        assert len(proposals) == 0
        assert len(blocked) == 1
        assert blocked[0].proposed_rule == "R6"
        assert blocked[0].guard_type == "cross_dynasty"
        assert blocked[0].evidence["external_id"] == "Q186544"

    def test_same_dynasty_pair_proposed(self) -> None:
        """同朝代 same QID -> proposed as MergeProposal (guard passes)."""
        a = _snap(
            id="aaaa",
            name="周公",
            slug="zhougong",
            dynasty="西周",
            r6_result=R6PrePassResult(
                status=R6Status.MATCHED, qid="Q468747", entry_id="e1", confidence=1.0
            ),
        )
        b = _snap(
            id="bbbb",
            name="周公旦",
            slug="zhougongdan",
            dynasty="西周",
            r6_result=R6PrePassResult(
                status=R6Status.MATCHED, qid="Q468747", entry_id="e2", confidence=0.70
            ),
        )
        # Note: person b has confidence < cutoff (0.80), so r6_result.status
        # should be BELOW_CUTOFF, not MATCHED. But in _detect_r6_merges we
        # only consider MATCHED. Let's set both to MATCHED for this test.
        proposals, blocked = _detect_r6_merges([a, b])
        assert len(proposals) == 1
        assert len(blocked) == 0
        assert proposals[0].match.rule == "R6"

    def test_blocked_pair_ordering(self) -> None:
        """BlockedMerge.person_a_id < person_b_id (DB CHECK constraint)."""
        # Give 'b' a smaller UUID so ordering is tested
        a = _snap(
            id="zzzz",
            name="启",
            dynasty="夏",
            r6_result=R6PrePassResult(
                status=R6Status.MATCHED, qid="Q186544", entry_id="e1", confidence=1.0
            ),
        )
        b = _snap(
            id="aaaa",
            name="微子启",
            dynasty="商",
            r6_result=R6PrePassResult(
                status=R6Status.MATCHED, qid="Q186544", entry_id="e2", confidence=1.0
            ),
        )
        _proposals, blocked = _detect_r6_merges([a, b])
        assert len(blocked) == 1
        assert blocked[0].person_a_id < blocked[0].person_b_id
        assert blocked[0].person_a_id == "aaaa"
        assert blocked[0].person_b_id == "zzzz"

    def test_mixed_three_way_one_blocked(self) -> None:
        """3 persons same QID: A(夏) B(商) C(商) -> B↔C proposed, A↔B and A↔C blocked."""
        a = _snap(
            id="aaaa",
            name="启",
            dynasty="夏",
            r6_result=R6PrePassResult(
                status=R6Status.MATCHED, qid="Q100", entry_id="e1", confidence=1.0
            ),
        )
        b = _snap(
            id="bbbb",
            name="微子",
            dynasty="商",
            r6_result=R6PrePassResult(
                status=R6Status.MATCHED, qid="Q100", entry_id="e2", confidence=1.0
            ),
        )
        c = _snap(
            id="cccc",
            name="微子启",
            dynasty="商",
            r6_result=R6PrePassResult(
                status=R6Status.MATCHED, qid="Q100", entry_id="e3", confidence=1.0
            ),
        )
        proposals, blocked = _detect_r6_merges([a, b, c])
        # B↔C: 商 vs 商 -> pass (1 proposal)
        # A↔B: 夏 vs 商 -> blocked
        # A↔C: 夏 vs 商 -> blocked
        assert len(proposals) == 1
        assert len(blocked) == 2
        # The proposal should be between B and C
        prop_ids = {proposals[0].person_a_id, proposals[0].person_b_id}
        assert "bbbb" in prop_ids
        assert "cccc" in prop_ids


# ---------------------------------------------------------------------------
# GuardResult dataclass
# ---------------------------------------------------------------------------


class TestGuardResult:
    """Tests for GuardResult frozen dataclass."""

    def test_immutable(self) -> None:
        r = GuardResult(
            guard_type="cross_dynasty",
            blocked=True,
            reason="test",
            payload={"k": "v"},
        )
        with pytest.raises(AttributeError):
            r.blocked = False  # type: ignore[misc]

    def test_payload_structure(self) -> None:
        r = GuardResult(
            guard_type="cross_dynasty",
            blocked=True,
            reason="gap 512yr",
            payload={
                "dynasty_a": "夏",
                "dynasty_b": "商",
                "midpoint_a": -1835,
                "midpoint_b": -1323,
                "gap_years": 512,
                "threshold": 500,
            },
        )
        assert r.payload["dynasty_a"] == "夏"
        assert r.payload["gap_years"] == 512
