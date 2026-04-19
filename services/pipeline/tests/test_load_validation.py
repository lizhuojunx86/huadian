"""Unit tests for load.py single-primary validation (T-P1-004 / ADR-012).

Tests _enforce_single_primary() — the pure validation/correction logic
that runs before any DB writes.
"""

from __future__ import annotations

from huadian_pipeline.extract import SurfaceForm
from huadian_pipeline.load import MergedPerson, _enforce_single_primary


def _person(
    name_zh: str,
    forms: list[tuple[str, str]],
) -> MergedPerson:
    """Helper: create a MergedPerson with given surface_forms."""
    return MergedPerson(
        name_zh=name_zh,
        slug=f"test-{name_zh}",
        surface_forms=[SurfaceForm(text=t, name_type=nt) for t, nt in forms],
        dynasty="上古",
        reality_status="legendary",
        briefs=[],
        identity_notes=[],
        confidence=0.9,
        chunk_ids=["c1"],
        paragraph_nos=[1],
    )


def _types(forms: list[SurfaceForm]) -> dict[str, str]:
    """Return {text: name_type} map for easy assertion."""
    return {sf.text: sf.name_type for sf in forms}


# ---------------------------------------------------------------------------
# Case 1: exactly 1 primary → no change
# ---------------------------------------------------------------------------


class TestSinglePrimaryPassThrough:
    def test_single_primary_unchanged(self) -> None:
        p = _person("黄帝", [("黄帝", "nickname"), ("轩辕", "primary"), ("公孙", "alias")])
        result = _enforce_single_primary(p)
        types = _types(result)
        assert types["轩辕"] == "primary"
        assert types["黄帝"] == "nickname"
        assert types["公孙"] == "alias"

    def test_single_primary_with_di_prefix(self) -> None:
        p = _person("南庚", [("南庚", "primary"), ("帝南庚", "nickname")])
        result = _enforce_single_primary(p)
        types = _types(result)
        assert types["南庚"] == "primary"
        assert types["帝南庚"] == "nickname"


# ---------------------------------------------------------------------------
# Case 2: >1 primary → auto-demotion
# ---------------------------------------------------------------------------


class TestMultiPrimaryDemotion:
    def test_two_primaries_name_zh_match_wins(self) -> None:
        """尧/放勋 — 尧 matches name_zh, so 放勋 demoted to alias."""
        p = _person("尧", [("尧", "primary"), ("放勋", "primary")])
        result = _enforce_single_primary(p)
        types = _types(result)
        assert types["尧"] == "primary"
        assert types["放勋"] == "alias"

    def test_two_primaries_di_prefix_demoted(self) -> None:
        """南庚/帝南庚 — both primary, 帝南庚 demoted (帝X never wins)."""
        p = _person("南庚", [("南庚", "primary"), ("帝南庚", "primary")])
        result = _enforce_single_primary(p)
        types = _types(result)
        assert types["南庚"] == "primary"
        assert types["帝南庚"] == "alias"

    def test_three_primaries_multiple_demotion(self) -> None:
        """微子启/微子/启 — name_zh match wins, rest demoted."""
        p = _person(
            "微子启",
            [("微子启", "primary"), ("微子", "primary"), ("启", "primary")],
        )
        result = _enforce_single_primary(p)
        types = _types(result)
        assert types["微子启"] == "primary"
        assert types["微子"] == "alias"
        assert types["启"] == "alias"

    def test_no_name_zh_match_shortest_wins(self) -> None:
        """name_zh not in primaries — shortest non-帝X wins.
        When lengths equal, alphabetical tiebreaker applies."""
        p = _person("汤", [("商汤", "primary"), ("天乙", "primary")])
        result = _enforce_single_primary(p)
        types = _types(result)
        # Both 2-char; 商汤 < 天乙 lexicographically → 商汤 wins
        assert types["商汤"] == "primary"
        assert types["天乙"] == "alias"

    def test_di_prefix_both_primaries_bare_wins(self) -> None:
        """帝沃甲/沃甲 — both primary, 帝X filtered, 沃甲 wins."""
        p = _person("沃甲", [("帝沃甲", "primary"), ("沃甲", "primary")])
        result = _enforce_single_primary(p)
        types = _types(result)
        assert types["沃甲"] == "primary"
        assert types["帝沃甲"] == "alias"

    def test_non_primary_forms_untouched(self) -> None:
        """Other name_types should not be affected by demotion."""
        p = _person(
            "颛顼",
            [
                ("颛顼", "primary"),
                ("高阳", "primary"),
                ("帝颛顼", "nickname"),
            ],
        )
        result = _enforce_single_primary(p)
        types = _types(result)
        assert types["颛顼"] == "primary"
        assert types["高阳"] == "alias"
        assert types["帝颛顼"] == "nickname"  # unchanged

    def test_variant_chars_shortest_wins(self) -> None:
        """倕/垂 — both primary, shortest (垂) wins."""
        p = _person("倕", [("倕", "primary"), ("垂", "primary")])
        result = _enforce_single_primary(p)
        types = _types(result)
        # Both are 1 char; name_zh match (倕) wins
        assert types["倕"] == "primary"
        assert types["垂"] == "alias"


# ---------------------------------------------------------------------------
# Case 3: 0 primaries + name_zh match → auto-promotion
# ---------------------------------------------------------------------------


class TestZeroPrimaryPromotion:
    def test_zero_primary_name_zh_promoted(self) -> None:
        p = _person("蚩尤", [("蚩尤", "alias"), ("蚩", "nickname")])
        result = _enforce_single_primary(p)
        types = _types(result)
        assert types["蚩尤"] == "primary"
        assert types["蚩"] == "nickname"


# ---------------------------------------------------------------------------
# Case 4: 0 primaries + no name_zh match → promote shortest + WARNING
# ---------------------------------------------------------------------------


class TestZeroPrimaryNoMatchFallback:
    def test_zero_primary_no_match_shortest_promoted(self) -> None:
        """name_zh not in surface_forms at all — shortest gets promoted."""
        p = _person("某人", [("某人甲", "alias"), ("甲", "nickname")])
        result = _enforce_single_primary(p)
        types = _types(result)
        assert types["甲"] == "primary"
        assert types["某人甲"] == "alias"

    def test_zero_primary_no_match_only_one_form(self) -> None:
        p = _person("某人", [("某甲", "alias")])
        result = _enforce_single_primary(p)
        types = _types(result)
        assert types["某甲"] == "primary"


# ---------------------------------------------------------------------------
# Invariant: result always has exactly 1 primary
# ---------------------------------------------------------------------------


class TestInvariantExactlyOnePrimary:
    """Parametric-style tests ensuring the invariant holds for all cases."""

    def _assert_one_primary(self, forms: list[SurfaceForm]) -> None:
        primaries = [sf for sf in forms if sf.name_type == "primary"]
        assert len(primaries) == 1, f"Expected 1 primary, got {len(primaries)}: {primaries}"

    def test_invariant_single(self) -> None:
        p = _person("尧", [("尧", "primary"), ("帝尧", "nickname")])
        self._assert_one_primary(_enforce_single_primary(p))

    def test_invariant_multi(self) -> None:
        p = _person("舜", [("舜", "primary"), ("重华", "primary")])
        self._assert_one_primary(_enforce_single_primary(p))

    def test_invariant_zero_with_match(self) -> None:
        p = _person("禹", [("禹", "alias"), ("文命", "alias")])
        self._assert_one_primary(_enforce_single_primary(p))

    def test_invariant_zero_no_match(self) -> None:
        p = _person("某", [("甲", "alias"), ("乙", "nickname")])
        self._assert_one_primary(_enforce_single_primary(p))
