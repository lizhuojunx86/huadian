"""Tests for framework.identity_resolver.entity — EntitySnapshot + alias."""

from __future__ import annotations

from framework.identity_resolver import EntitySnapshot
from framework.identity_resolver.entity import PersonSnapshot


def test_all_names_returns_union_of_name_and_surface_forms():
    e = EntitySnapshot(
        id="e1",
        name="周成王",
        slug="zhou-cheng-wang",
        surface_forms={"成王", "姬诵"},
        created_at="2026-01-01T00:00:00Z",
    )
    assert e.all_names() == {"周成王", "成王", "姬诵"}


def test_has_pinyin_slug_distinguishes_pinyin_from_unicode_fallback():
    e_pinyin = EntitySnapshot(
        id="e1",
        name="刘邦",
        slug="liu-bang",
        surface_forms={"刘邦"},
        created_at="2026-01-01T00:00:00Z",
    )
    e_fallback = EntitySnapshot(
        id="e2",
        name="某",
        slug="u67d0",  # unicode hex fallback
        surface_forms={"某"},
        created_at="2026-01-01T00:00:00Z",
    )
    assert e_pinyin.has_pinyin_slug() is True
    assert e_fallback.has_pinyin_slug() is False


def test_person_snapshot_is_alias_of_entity_snapshot():
    """Backwards-compat: HuaDian-pipeline code uses PersonSnapshot."""
    assert PersonSnapshot is EntitySnapshot
    p = PersonSnapshot(
        id="p1",
        name="X",
        slug="x",
        surface_forms={"X"},
        created_at="2026-01-01T00:00:00Z",
    )
    assert isinstance(p, EntitySnapshot)
