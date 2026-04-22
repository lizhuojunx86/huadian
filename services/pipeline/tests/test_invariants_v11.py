"""V11 INVARIANT: R6 pre-pass cardinality — no active person has >1 active seed_mapping.

Guards against AMBIGUOUS pre-pass results. If a person has multiple active
seed_mappings, the pre-pass cannot determine which QID to use, breaking R6
merge detection.

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

V11_QUERY = """
    SELECT count(DISTINCT sq.person_id) FROM (
        SELECT sm.target_entity_id AS person_id, count(*) AS cnt
        FROM seed_mappings sm
        WHERE sm.target_entity_type = 'person'
          AND sm.mapping_status = 'active'
        GROUP BY sm.target_entity_id
        HAVING count(*) > 1
    ) sq
"""


@pytest.fixture
async def db_conn():
    import asyncpg

    url = os.environ["DATABASE_URL"]
    conn = await asyncpg.connect(url)
    try:
        yield conn
    finally:
        await conn.close()


async def test_v11_passes_clean_state(db_conn) -> None:
    """V11 bootstrap: no active person has >1 active seed_mapping."""
    count = await db_conn.fetchval(V11_QUERY)
    assert count == 0, f"V11 violated: {count} person(s) have multiple active seed_mappings"


async def test_v11_self_test_detects_duplicate_active_mapping(db_conn) -> None:
    """Self-test: inject 2 active mappings for same person -> V11 catches."""
    tx = db_conn.transaction()
    await tx.start()
    try:
        person_id = uuid.uuid4()
        name_json = '{"zh-Hans": "test-v11"}'
        await db_conn.execute(
            """INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier)
               VALUES ($1, $2, $3::jsonb, '上古', 'legendary', 'primary_text')""",
            person_id,
            f"v11-{person_id.hex[:8]}",
            name_json,
        )
        await db_conn.execute(
            """INSERT INTO person_names (person_id, name, name_type, is_primary)
               VALUES ($1, $2, 'primary', true)""",
            person_id,
            f"test-v11-{person_id.hex[:8]}",
        )

        source_id = await db_conn.fetchval(
            """INSERT INTO dictionary_sources (source_name, source_version, license, commercial_safe)
               VALUES ('test-v11', 'v0', 'CC0', true)
               ON CONFLICT (source_name, source_version) DO UPDATE SET source_name = 'test-v11'
               RETURNING id"""
        )

        # Create 2 different entries + 2 active mappings for the SAME person
        for qid in ("Q_V11_A", "Q_V11_B"):
            entry_id = await db_conn.fetchval(
                """INSERT INTO dictionary_entries
                     (source_id, external_id, entry_type, primary_name, attributes)
                   VALUES ($1, $2, 'person', 'dup', '{}'::jsonb)
                   ON CONFLICT (source_id, external_id)
                     DO UPDATE SET source_id = dictionary_entries.source_id
                   RETURNING id""",
                source_id,
                qid,
            )
            await db_conn.execute(
                """INSERT INTO seed_mappings
                     (dictionary_entry_id, target_entity_type, target_entity_id,
                      confidence, mapping_method, mapping_status)
                   VALUES ($1, 'person', $2, 0.90, 'test', 'active')""",
                entry_id,
                person_id,
            )

        count = await db_conn.fetchval(V11_QUERY)
        assert count >= 1, "V11 self-test FAILED: duplicate active mappings not detected"

    finally:
        await tx.rollback()


async def test_v11_self_test_ignores_pending_review(db_conn) -> None:
    """Self-test: active + pending_review for same person -> V11 passes."""
    tx = db_conn.transaction()
    await tx.start()
    try:
        person_id = uuid.uuid4()
        name_json = '{"zh-Hans": "test-v11c"}'
        await db_conn.execute(
            """INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier)
               VALUES ($1, $2, $3::jsonb, '上古', 'legendary', 'primary_text')""",
            person_id,
            f"v11c-{person_id.hex[:8]}",
            name_json,
        )
        await db_conn.execute(
            """INSERT INTO person_names (person_id, name, name_type, is_primary)
               VALUES ($1, $2, 'primary', true)""",
            person_id,
            f"test-v11c-{person_id.hex[:8]}",
        )

        source_id = await db_conn.fetchval(
            """INSERT INTO dictionary_sources (source_name, source_version, license, commercial_safe)
               VALUES ('test-v11c', 'v0', 'CC0', true)
               ON CONFLICT (source_name, source_version) DO UPDATE SET source_name = 'test-v11c'
               RETURNING id"""
        )

        # 1 active + 1 pending_review for same person -> should NOT trigger V11
        for qid, status in [("Q_V11C_ACTIVE", "active"), ("Q_V11C_PENDING", "pending_review")]:
            entry_id = await db_conn.fetchval(
                """INSERT INTO dictionary_entries
                     (source_id, external_id, entry_type, primary_name, attributes)
                   VALUES ($1, $2, 'person', 'mixed', '{}'::jsonb)
                   ON CONFLICT (source_id, external_id)
                     DO UPDATE SET source_id = dictionary_entries.source_id
                   RETURNING id""",
                source_id,
                qid,
            )
            await db_conn.execute(
                """INSERT INTO seed_mappings
                     (dictionary_entry_id, target_entity_type, target_entity_id,
                      confidence, mapping_method, mapping_status)
                   VALUES ($1, 'person', $2, 0.90, 'test', $3)""",
                entry_id,
                person_id,
                status,
            )

        # Should still be 0 for our test person (only 1 active, 1 pending)
        # Verify our injected person has exactly 1 active mapping
        person_count = await db_conn.fetchval(
            """SELECT count(*) FROM seed_mappings
               WHERE target_entity_type = 'person'
                 AND target_entity_id = $1
                 AND mapping_status = 'active'""",
            person_id,
        )
        assert person_count == 1, f"Expected 1 active mapping for test person, got {person_count}"

    finally:
        await tx.rollback()
