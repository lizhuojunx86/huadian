"""Tests for framework.identity_resolver.canonical — select_canonical priority."""

from __future__ import annotations

from framework.identity_resolver import EntitySnapshot
from framework.identity_resolver.canonical import select_canonical


def _e(id, slug, surface=None, created_at="2026-01-01T00:00:00Z"):  # noqa: A002
    return EntitySnapshot(
        id=id,
        name=id,
        slug=slug,
        surface_forms=set(surface) if surface else {id},
        created_at=created_at,
    )


def test_select_canonical_prefers_pinyin_slug_over_unicode_fallback():
    """Priority 1: has_pinyin_slug=True wins over =False."""
    pinyin = _e("pinyin", slug="liu-bang")
    fallback = _e("fallback", slug="u67d0")
    chosen = select_canonical([pinyin, fallback])
    assert chosen is pinyin


def test_select_canonical_prefers_more_surface_forms_then_earlier_created_at():
    """Priority 3 then 4: more surface_forms wins, then earlier created_at."""
    a = _e("a", slug="liu-bang", surface={"a", "x", "y"}, created_at="2026-03-01T00:00:00Z")
    b = _e("b", slug="liu-bang", surface={"b"}, created_at="2026-01-01T00:00:00Z")
    # a has more surface_forms → priority 3 wins → a chosen
    assert select_canonical([a, b]) is a

    # When surface_forms tie, earlier created_at wins
    c = _e("c", slug="liu-bang", surface={"c", "y"}, created_at="2026-02-01T00:00:00Z")
    d = _e("d", slug="liu-bang", surface={"d", "z"}, created_at="2026-01-01T00:00:00Z")
    assert select_canonical([c, d]) is d
