"""Tests for apply_merges() demotion of is_primary alongside name_type.

Validates T-P0-016: when apply_merges() demotes source person's primary names
to alias, it must simultaneously set is_primary=false to prevent
nameType=alias + isPrimary=true UX contradiction.

Requires DATABASE_URL env var pointing to the huadian DB.
These tests commit real data and clean up after each test.
"""

from __future__ import annotations

import os
import uuid

import pytest

pytestmark = pytest.mark.skipif(
    not os.environ.get("DATABASE_URL"),
    reason="DATABASE_URL not set — skipping DB integration tests",
)


@pytest.fixture
async def db_pool():
    """Create a connection pool for apply_merges tests."""
    import asyncpg

    url = os.environ["DATABASE_URL"]
    pool = await asyncpg.create_pool(url, min_size=1, max_size=2)
    try:
        yield pool
    finally:
        await pool.close()


@pytest.fixture
async def test_persons(db_pool):
    """Create isolated test persons + names, committed so apply_merges can see them.

    Cleanup runs unconditionally after the test (even on failure).
    Uses unique slugs with uuid prefix to avoid collision with real data.
    """
    canonical_id = str(uuid.uuid4())
    source_id = str(uuid.uuid4())
    canonical_name_id = str(uuid.uuid4())
    source_name_id = str(uuid.uuid4())
    tag = uuid.uuid4().hex[:8]

    async with db_pool.acquire() as conn:
        # Commit test data so apply_merges (separate connection) can see it
        await conn.execute(
            """
            INSERT INTO persons (id, slug, name, provenance_tier)
            VALUES ($1, $2, '{"zh-Hans": "test-canonical"}'::jsonb, 'primary_text')
            """,
            canonical_id,
            f"test-canonical-{tag}",
        )
        await conn.execute(
            """
            INSERT INTO person_names (id, person_id, name, name_type, is_primary)
            VALUES ($1, $2, $3, 'primary', true)
            """,
            canonical_name_id,
            canonical_id,
            f"canonical_name_{tag}",
        )
        await conn.execute(
            """
            INSERT INTO persons (id, slug, name, provenance_tier)
            VALUES ($1, $2, '{"zh-Hans": "test-source"}'::jsonb, 'primary_text')
            """,
            source_id,
            f"test-source-{tag}",
        )
        await conn.execute(
            """
            INSERT INTO person_names (id, person_id, name, name_type, is_primary)
            VALUES ($1, $2, $3, 'primary', true)
            """,
            source_name_id,
            source_id,
            f"source_name_{tag}",
        )

    data = {
        "canonical_id": canonical_id,
        "source_id": source_id,
        "canonical_name_id": canonical_name_id,
        "source_name_id": source_name_id,
    }

    try:
        yield data
    finally:
        # Cleanup: delete test data in correct FK order
        async with db_pool.acquire() as conn:
            await conn.execute(
                "DELETE FROM person_merge_log WHERE canonical_id = $1 OR merged_id = $1 "
                "OR canonical_id = $2 OR merged_id = $2",
                canonical_id,
                source_id,
            )
            await conn.execute(
                "DELETE FROM person_names WHERE person_id IN ($1, $2)",
                canonical_id,
                source_id,
            )
            await conn.execute(
                "DELETE FROM persons WHERE id IN ($1, $2)",
                canonical_id,
                source_id,
            )


def _make_resolve_result(canonical_id: str, source_id: str):
    """Build a minimal ResolveResult for a single merge group."""
    from huadian_pipeline.resolve_types import (
        MatchResult,
        MergeGroup,
        MergeProposal,
        ResolveResult,
    )

    match = MatchResult(rule="R1", confidence=0.95, evidence={"test": True})
    proposal = MergeProposal(
        person_a_id=canonical_id,
        person_b_id=source_id,
        person_a_name="canonical",
        person_b_name="source",
        match=match,
    )
    group = MergeGroup(
        canonical_id=canonical_id,
        canonical_name="canonical",
        canonical_slug="test-canonical",
        merged_ids=[source_id],
        merged_names=["source"],
        merged_slugs=["test-source"],
        reason="test merge",
        proposals=[proposal],
    )
    return ResolveResult(
        run_id=str(uuid.uuid4()),
        total_persons=2,
        merge_groups=[group],
    )


async def test_apply_merges_demotes_is_primary_on_source(db_pool, test_persons):
    """Source's primary/is_primary=true becomes alias/is_primary=false after merge."""
    from huadian_pipeline.resolve import apply_merges

    result = _make_resolve_result(test_persons["canonical_id"], test_persons["source_id"])
    summary = await apply_merges(db_pool, result, dry_run=False, merged_by="test")

    assert summary["persons_soft_deleted"] == 1

    async with db_pool.acquire() as conn:
        row = await conn.fetchrow(
            "SELECT name_type, is_primary FROM person_names WHERE id = $1",
            test_persons["source_name_id"],
        )
    assert row["name_type"] == "alias", f"Expected alias, got {row['name_type']}"
    assert row["is_primary"] is False, f"Expected is_primary=false, got {row['is_primary']}"


async def test_apply_merges_preserves_canonical_primary(db_pool, test_persons):
    """Canonical's primary/is_primary=true must remain untouched after merge."""
    from huadian_pipeline.resolve import apply_merges

    result = _make_resolve_result(test_persons["canonical_id"], test_persons["source_id"])
    await apply_merges(db_pool, result, dry_run=False, merged_by="test")

    async with db_pool.acquire() as conn:
        row = await conn.fetchrow(
            "SELECT name_type, is_primary FROM person_names WHERE id = $1",
            test_persons["canonical_name_id"],
        )
    assert row["name_type"] == "primary", f"Expected primary, got {row['name_type']}"
    assert row["is_primary"] is True, f"Expected is_primary=true, got {row['is_primary']}"


async def test_apply_merges_handles_already_false_is_primary(db_pool, test_persons):
    """Source with primary/is_primary=false (cheng-tang pattern) -> alias/is_primary=false."""
    from huadian_pipeline.resolve import apply_merges

    # Pre-set source name to is_primary=false (simulates cheng-tang historical state)
    async with db_pool.acquire() as conn:
        await conn.execute(
            "UPDATE person_names SET is_primary = false WHERE id = $1",
            test_persons["source_name_id"],
        )

    result = _make_resolve_result(test_persons["canonical_id"], test_persons["source_id"])
    await apply_merges(db_pool, result, dry_run=False, merged_by="test")

    async with db_pool.acquire() as conn:
        row = await conn.fetchrow(
            "SELECT name_type, is_primary FROM person_names WHERE id = $1",
            test_persons["source_name_id"],
        )
    assert row["name_type"] == "alias"
    assert row["is_primary"] is False


async def test_apply_merges_idempotent_no_new_violations(db_pool, test_persons):
    """Calling apply_merges twice on the same merge produces no new violations."""
    from huadian_pipeline.resolve import apply_merges

    result = _make_resolve_result(test_persons["canonical_id"], test_persons["source_id"])

    # First call — real merge
    await apply_merges(db_pool, result, dry_run=False, merged_by="test")

    # Count alias+is_primary=true before second call
    async with db_pool.acquire() as conn:
        before = await conn.fetchval(
            """
            SELECT COUNT(*) FROM person_names
            WHERE person_id IN ($1, $2)
              AND name_type = 'alias' AND is_primary = true
            """,
            test_persons["canonical_id"],
            test_persons["source_id"],
        )

    # Second call — source already soft-deleted, should be no-op
    await apply_merges(db_pool, result, dry_run=False, merged_by="test")

    async with db_pool.acquire() as conn:
        after = await conn.fetchval(
            """
            SELECT COUNT(*) FROM person_names
            WHERE person_id IN ($1, $2)
              AND name_type = 'alias' AND is_primary = true
            """,
            test_persons["canonical_id"],
            test_persons["source_id"],
        )

    assert after == before == 0, (
        f"Idempotency violation: alias+is_primary=true count changed {before} -> {after}"
    )
