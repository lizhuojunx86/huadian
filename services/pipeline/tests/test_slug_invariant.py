"""Slug invariant test — enforces ADR-011 across the entire DB.

INVARIANT: Every persons.slug must be either:
  (a) a value in the Tier-S whitelist (data/tier-s-slugs.yaml), OR
  (b) a unicode hex slug matching ^u[0-9a-f]{4,5}(-u[0-9a-f]{4,5})*$

This test runs against a live PostgreSQL database.
It catches regressions where a new ingest or migration introduces
a slug that doesn't conform to either format.

Requires DATABASE_URL env var pointing to the huadian DB.
"""

from __future__ import annotations

import os
import re

import pytest

# Skip entire module if no DATABASE_URL is set (e.g. in CI without DB)
pytestmark = pytest.mark.skipif(
    not os.environ.get("DATABASE_URL"),
    reason="DATABASE_URL not set — skipping DB invariant tests",
)

UNICODE_SLUG_RE = re.compile(r"^u[0-9a-f]{4,5}(-u[0-9a-f]{4,5})*$")


@pytest.fixture
def tier_s_slugs() -> set[str]:
    """Load Tier-S whitelist slug values."""
    from huadian_pipeline.slug import get_tier_s_whitelist

    return set(get_tier_s_whitelist().values())


@pytest.fixture
async def all_active_slugs() -> list[tuple[str, str]]:
    """Fetch all (slug, name_zh) from active persons."""
    import asyncpg

    url = os.environ["DATABASE_URL"]
    conn = await asyncpg.connect(url)
    try:
        rows = await conn.fetch(
            """
            SELECT slug, name->>'zh-Hans' as name_zh
            FROM persons
            WHERE merged_into_id IS NULL AND deleted_at IS NULL
            ORDER BY slug
            """
        )
        return [(r["slug"], r["name_zh"]) for r in rows]
    finally:
        await conn.close()


async def test_all_slugs_conform_to_invariant(
    tier_s_slugs: set[str],
    all_active_slugs: list[tuple[str, str]],
) -> None:
    """Every active person's slug must be Tier-S pinyin OR unicode hex."""
    violations: list[str] = []

    for slug, name_zh in all_active_slugs:
        is_tier_s = slug in tier_s_slugs
        is_unicode = bool(UNICODE_SLUG_RE.match(slug))

        if not is_tier_s and not is_unicode:
            violations.append(f"  {slug} ({name_zh})")

    assert not violations, (
        f"Found {len(violations)} slug(s) violating ADR-011 invariant "
        f"(not in Tier-S whitelist and not unicode hex):\n" + "\n".join(violations)
    )


async def test_no_slug_collisions(
    all_active_slugs: list[tuple[str, str]],
) -> None:
    """No two active persons share the same slug."""
    slugs = [s for s, _ in all_active_slugs]
    dupes = [s for s in slugs if slugs.count(s) > 1]
    assert not dupes, f"Duplicate slugs: {set(dupes)}"


async def test_slug_count_sanity(
    all_active_slugs: list[tuple[str, str]],
) -> None:
    """At least 100 active persons exist (sanity check)."""
    assert len(all_active_slugs) >= 100, (
        f"Expected ≥100 active persons, got {len(all_active_slugs)}"
    )
