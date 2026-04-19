"""Tests for slug generation module (T-P2-002, ADR-011).

Covers:
  - Tier-S whitelist loading and lookup
  - Unicode slug generation (BMP + supplementary planes)
  - generate_slug() unified entry point
  - classify_slug() bucket classification
  - Edge cases (empty string, single char, mixed)
"""

from __future__ import annotations

import re

from huadian_pipeline.slug import (
    UNICODE_SLUG_RE,
    VALID_SLUG_RE,
    classify_slug,
    generate_slug,
    get_tier_s_whitelist,
    is_tier_s_slug,
    is_unicode_slug,
    is_valid_slug,
    unicode_slug,
)

# ── Whitelist loading ─────────────────────────────────────────


class TestWhitelistLoading:
    """Test Tier-S whitelist YAML loading."""

    def test_whitelist_is_nonempty(self) -> None:
        wl = get_tier_s_whitelist()
        assert len(wl) >= 58, f"Expected ≥58 entries, got {len(wl)}"

    def test_whitelist_contains_known_entries(self) -> None:
        wl = get_tier_s_whitelist()
        assert wl["黄帝"] == "huang-di"
        assert wl["尧"] == "yao"
        assert wl["舜"] == "shun"
        assert wl["禹"] == "yu"
        assert wl["汤"] == "tang"
        assert wl["西伯昌"] == "xi-bo-chang"

    def test_whitelist_values_are_valid_slugs(self) -> None:
        wl = get_tier_s_whitelist()
        for name, slug in wl.items():
            assert VALID_SLUG_RE.match(slug), f"{name} → {slug!r} is not a valid slug"

    def test_whitelist_no_duplicate_slugs(self) -> None:
        wl = get_tier_s_whitelist()
        slugs = list(wl.values())
        assert len(slugs) == len(set(slugs)), "Duplicate slugs in whitelist"

    def test_whitelist_returns_copy(self) -> None:
        """Mutation of returned dict does not affect the cache."""
        wl1 = get_tier_s_whitelist()
        wl1["TEST"] = "test"
        wl2 = get_tier_s_whitelist()
        assert "TEST" not in wl2


# ── Unicode slug generation ───────────────────────────────────


class TestUnicodeSlug:
    """Test unicode hex slug generation."""

    def test_bmp_two_char(self) -> None:
        assert unicode_slug("中丁") == "u4e2d-u4e01"

    def test_bmp_single_char(self) -> None:
        assert unicode_slug("微") == "u5fae"

    def test_bmp_three_char(self) -> None:
        assert unicode_slug("司马迁") == "u53f8-u9a6c-u8fc1"

    def test_matches_unicode_regex(self) -> None:
        slug = unicode_slug("周武王")
        assert UNICODE_SLUG_RE.match(slug)

    def test_empty_string_returns_unknown(self) -> None:
        slug = unicode_slug("")
        assert slug.startswith("unknown-")

    def test_result_is_lowercase_alphanumeric_hyphens(self) -> None:
        slug = unicode_slug("黄帝")
        assert re.match(r"^[a-z0-9-]+$", slug)


# ── generate_slug() unified entry ─────────────────────────────


class TestGenerateSlug:
    """Test the unified generate_slug() function."""

    def test_tier_s_name_returns_pinyin(self) -> None:
        assert generate_slug("黄帝") == "huang-di"

    def test_tier_s_name_yao(self) -> None:
        assert generate_slug("尧") == "yao"

    def test_non_tier_s_returns_unicode(self) -> None:
        slug = generate_slug("周公")
        assert slug == "u5468-u516c"
        assert UNICODE_SLUG_RE.match(slug)

    def test_all_results_are_valid_slugs(self) -> None:
        names = ["黄帝", "尧", "周公", "司马迁", "微", "孔子"]
        for name in names:
            slug = generate_slug(name)
            assert VALID_SLUG_RE.match(slug), f"{name} → {slug!r} invalid"

    def test_deterministic(self) -> None:
        """Same input always produces same output."""
        assert generate_slug("黄帝") == generate_slug("黄帝")
        assert generate_slug("周公") == generate_slug("周公")

    def test_backward_compat_with_old_pinyin_map(self) -> None:
        """All entries from the old _PINYIN_MAP produce identical slugs."""
        old_map = {
            "黄帝": "huang-di",
            "炎帝": "yan-di",
            "蚩尤": "chi-you",
            "神农氏": "shen-nong-shi",
            "龙": "long",
            "汤": "tang",
            "西伯昌": "xi-bo-chang",
            "简狄": "jian-di",
        }
        for name, expected_slug in old_map.items():
            assert generate_slug(name) == expected_slug, f"{name} mismatch"


# ── classify_slug() ───────────────────────────────────────────


class TestClassifySlug:
    """Test slug classification."""

    def test_pinyin_slug(self) -> None:
        assert classify_slug("huang-di") == "pinyin"

    def test_unicode_slug(self) -> None:
        assert classify_slug("u4e2d-u4e01") == "unicode"

    def test_unknown_slug(self) -> None:
        assert classify_slug("some-random-thing") == "unknown"

    def test_is_tier_s_slug(self) -> None:
        assert is_tier_s_slug("huang-di") is True
        assert is_tier_s_slug("u4e2d-u4e01") is False

    def test_is_unicode_slug(self) -> None:
        assert is_unicode_slug("u4e2d-u4e01") is True
        assert is_unicode_slug("huang-di") is False

    def test_is_valid_slug(self) -> None:
        assert is_valid_slug("huang-di") is True
        assert is_valid_slug("u4e2d-u4e01") is True
        assert is_valid_slug("INVALID") is False
        assert is_valid_slug("") is False
        assert is_valid_slug("-leading") is False
