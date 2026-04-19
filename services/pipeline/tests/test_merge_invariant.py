"""Merge model invariant tests — enforces ADR-014 across the entire DB.

V4 INVARIANT (ADR-014): Every soft-deleted person that has merged_into_id
must retain at least one person_name row. This ensures model-A compliance:
names stay on the source person for read-side aggregation via
findPersonNamesWithMerged().

Requires DATABASE_URL env var pointing to the huadian DB.
"""

from __future__ import annotations

import os

import pytest

pytestmark = pytest.mark.skipif(
    not os.environ.get("DATABASE_URL"),
    reason="DATABASE_URL not set — skipping DB invariant tests",
)


@pytest.fixture
async def db_conn():
    """Create a DB connection for invariant queries."""
    import asyncpg

    url = os.environ["DATABASE_URL"]
    conn = await asyncpg.connect(url)
    try:
        yield conn
    finally:
        await conn.close()


async def test_v4_no_model_b_leakage(db_conn) -> None:
    """ADR-014 V4: every deleted+merged person must retain at least one name.

    If a merged person has zero person_names, it means names were migrated
    (model B) instead of staying in place (model A). This breaks
    findPersonNamesWithMerged() read-side aggregation.
    """
    rows = await db_conn.fetch(
        """
        SELECT p.id::text, p.slug, p.name->>'zh-Hans' as name_zh
        FROM persons p
        WHERE p.deleted_at IS NOT NULL
          AND p.merged_into_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM person_names WHERE person_id = p.id)
        ORDER BY p.slug
        """
    )
    violations = [f"  {r['slug']} ({r['name_zh']})" for r in rows]
    assert not violations, (
        f"ADR-014 V4 violated: {len(violations)} deleted+merged person(s) "
        f"have zero person_names (model-B leakage):\n" + "\n".join(violations)
    )


async def test_no_active_but_merged(db_conn) -> None:
    """Every person with merged_into_id must also have deleted_at set.

    Partial merges (merged_into_id set, deleted_at NULL) break active-person
    queries and lead to double-counting. See T-P0-015 帝鸿氏 bug.
    """
    rows = await db_conn.fetch(
        """
        SELECT p.id::text, p.slug, p.name->>'zh-Hans' as name_zh
        FROM persons p
        WHERE p.deleted_at IS NULL
          AND p.merged_into_id IS NOT NULL
        ORDER BY p.slug
        """
    )
    violations = [f"  {r['slug']} ({r['name_zh']})" for r in rows]
    assert not violations, (
        f"Partial-merge bug: {len(violations)} person(s) have merged_into_id "
        f"set but deleted_at IS NULL:\n" + "\n".join(violations)
    )
