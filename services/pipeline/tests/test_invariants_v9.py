"""V9 INVARIANT: at-least-one-primary lower-bound check.

Every active person (deleted_at IS NULL, merged_into_id IS NULL)
must have at least one person_names row with is_primary = true.

Complements V1 (upper bound: at most one primary) to enforce
exactly-one-primary semantics. See ADR-024.

Requires DATABASE_URL env var pointing to the huadian DB.
"""

from __future__ import annotations

import os
import uuid

import pytest

pytestmark = pytest.mark.skipif(
    not os.environ.get("DATABASE_URL"),
    reason="DATABASE_URL not set — skipping DB invariant tests",
)

V9_QUERY = """
    SELECT p.id, p.slug
    FROM persons p
    WHERE p.deleted_at IS NULL
      AND p.merged_into_id IS NULL
      AND NOT EXISTS (
        SELECT 1 FROM person_names pn
        WHERE pn.person_id = p.id AND pn.is_primary = true
      )
"""


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


async def test_v9_bootstrap_zero(db_conn) -> None:
    """V9: every active person has at least one is_primary=true name.

    Bootstrap expectation: 0 violations. Sprint F Stage 2 backfill
    cleared all 33 historical violations before V9 introduction.
    """
    rows = await db_conn.fetch(V9_QUERY)
    violations = [f"  {r['slug']}" for r in rows]
    assert not violations, (
        f"V9 violated: {len(violations)} active person(s) have zero "
        f"is_primary=true names:\n" + "\n".join(violations)
    )


async def test_v9_self_test_catches_missing_primary(db_conn) -> None:
    """Self-test: inject a person with zero is_primary=true and verify V9 catches it.

    Creates a test person with one person_name row where is_primary=false.
    V9 must flag this person. Transaction rolls back after the test.
    """
    tx = db_conn.transaction()
    await tx.start()
    try:
        person_id = uuid.uuid4()
        name_json = '{"zh-Hans": "test-v9"}'

        await db_conn.execute(
            """INSERT INTO persons (id, slug, name, dynasty,
               reality_status, provenance_tier)
               VALUES ($1, $2, $3::jsonb, '上古', 'legendary',
                       'primary_text')""",
            person_id,
            f"test-v9-{person_id.hex[:8]}",
            name_json,
        )

        # Insert a name with is_primary=false — should trigger V9
        await db_conn.execute(
            """INSERT INTO person_names (person_id, name, name_type, is_primary)
               VALUES ($1, '测试人物', 'alias', false)""",
            person_id,
        )

        rows = await db_conn.fetch(V9_QUERY)
        poison_hits = [r for r in rows if r["id"] == person_id]
        assert len(poison_hits) == 1, (
            "V9 self-test FAILED: injected person with zero is_primary=true "
            "was not detected by V9 query. Check query logic."
        )

    finally:
        await tx.rollback()


async def test_v9_self_test_deleted_person_exempt(db_conn) -> None:
    """Self-test: soft-deleted persons are exempt from V9.

    A person with deleted_at set and no is_primary=true name should
    NOT be flagged — V9 only covers active persons.
    """
    tx = db_conn.transaction()
    await tx.start()
    try:
        person_id = uuid.uuid4()
        name_json = '{"zh-Hans": "test-v9-deleted"}'

        await db_conn.execute(
            """INSERT INTO persons (id, slug, name, dynasty,
               reality_status, provenance_tier, deleted_at)
               VALUES ($1, $2, $3::jsonb, '上古', 'legendary',
                       'primary_text', NOW())""",
            person_id,
            f"test-v9-del-{person_id.hex[:8]}",
            name_json,
        )

        # Insert a name with is_primary=false on deleted person
        await db_conn.execute(
            """INSERT INTO person_names (person_id, name, name_type, is_primary)
               VALUES ($1, '已删除人物', 'alias', false)""",
            person_id,
        )

        rows = await db_conn.fetch(V9_QUERY)
        false_hits = [r for r in rows if r["id"] == person_id]
        assert len(false_hits) == 0, (
            "V9 self-test FAILED: soft-deleted person incorrectly flagged. "
            "V9 should only cover active persons (deleted_at IS NULL)."
        )

    finally:
        await tx.rollback()
