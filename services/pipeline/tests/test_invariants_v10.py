"""V10 INVARIANT: seed_mapping consistency checks (3 sub-rules).

V10.a — Active/pending seed_mappings must point to live (non-deleted,
        non-merged) persons.
V10.b — seed_mappings.dictionary_entry_id must reference an existing
        dictionary_entries row.
V10.c — Active seed_mappings must have a corresponding source_evidence
        with provenance_tier='seed_dictionary'.

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

V10A_QUERY = """
    SELECT count(*) FROM seed_mappings sm
    LEFT JOIN persons p ON p.id = sm.target_entity_id
    WHERE sm.target_entity_type = 'person'
      AND sm.mapping_status IN ('active', 'pending_review')
      AND (p.id IS NULL OR p.deleted_at IS NOT NULL OR p.merged_into_id IS NOT NULL)
"""

V10B_QUERY = """
    SELECT count(*) FROM seed_mappings sm
    LEFT JOIN dictionary_entries de ON de.id = sm.dictionary_entry_id
    WHERE de.id IS NULL
"""

V10C_QUERY = """
    SELECT count(*) FROM seed_mappings sm
    JOIN dictionary_entries de ON de.id = sm.dictionary_entry_id
    WHERE sm.mapping_status = 'active'
      AND NOT EXISTS (
        SELECT 1 FROM source_evidences se
        WHERE se.provenance_tier = 'seed_dictionary'
          AND se.quoted_text LIKE 'wikidata:' || de.external_id || '%%'
      )
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


async def test_v10a_no_orphan_target(db_conn) -> None:
    """V10.a: active/pending seed_mappings point to live persons."""
    count = await db_conn.fetchval(V10A_QUERY)
    assert count == 0, f"V10.a violated: {count} seed_mapping(s) point to dead/merged persons"


async def test_v10b_no_orphan_entry(db_conn) -> None:
    """V10.b: seed_mappings.dictionary_entry_id references existing entries."""
    count = await db_conn.fetchval(V10B_QUERY)
    assert count == 0, (
        f"V10.b violated: {count} seed_mapping(s) reference missing dictionary_entries"
    )


async def test_v10c_active_seed_has_evidence(db_conn) -> None:
    """V10.c: active seed_mappings have seed_dictionary source_evidence."""
    count = await db_conn.fetchval(V10C_QUERY)
    assert count == 0, (
        f"V10.c violated: {count} active seed_mapping(s) lack seed_dictionary evidence"
    )


async def test_v10a_self_test_detects_orphan(db_conn) -> None:
    """Self-test: inject an orphan mapping targeting a merged person → V10.a catches it."""
    tx = db_conn.transaction()
    await tx.start()
    try:
        # Create a person, then soft-merge it (making it "dead")
        dead_person = uuid.uuid4()
        live_person = uuid.uuid4()
        name_json = '{"zh-Hans": "test-v10"}'

        for pid, slug in [
            (dead_person, f"v10-dead-{dead_person.hex[:8]}"),
            (live_person, f"v10-live-{live_person.hex[:8]}"),
        ]:
            await db_conn.execute(
                """INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier)
                   VALUES ($1, $2, $3::jsonb, '上古', 'legendary', 'primary_text')""",
                pid,
                slug,
                name_json,
            )
            await db_conn.execute(
                """INSERT INTO person_names (person_id, name, name_type, is_primary)
                   VALUES ($1, $2, 'primary', true)""",
                pid,
                f"test-{slug}",
            )

        # Soft-merge dead_person into live_person
        await db_conn.execute(
            "UPDATE persons SET deleted_at = now(), merged_into_id = $1 WHERE id = $2",
            live_person,
            dead_person,
        )

        # Create seed infrastructure
        source_id = await db_conn.fetchval(
            """INSERT INTO dictionary_sources (source_name, source_version, license, commercial_safe)
               VALUES ('test-v10', 'v0', 'CC0', true)
               ON CONFLICT (source_name, source_version) DO UPDATE SET source_name = 'test-v10'
               RETURNING id"""
        )
        entry_id = await db_conn.fetchval(
            """INSERT INTO dictionary_entries (source_id, external_id, entry_type, primary_name, attributes)
               VALUES ($1, 'Q_V10_ORPHAN', 'person', 'orphan', '{}'::jsonb)
               ON CONFLICT (source_id, external_id) DO UPDATE SET source_id = dictionary_entries.source_id
               RETURNING id""",
            source_id,
        )

        # Create active mapping pointing to the dead (merged) person → V10.a should catch
        await db_conn.execute(
            """INSERT INTO seed_mappings
               (dictionary_entry_id, target_entity_type, target_entity_id,
                confidence, mapping_method, mapping_status)
               VALUES ($1, 'person', $2, 0.90, 'test', 'active')""",
            entry_id,
            dead_person,
        )

        count = await db_conn.fetchval(V10A_QUERY)
        assert count >= 1, "V10.a self-test FAILED: orphan mapping to merged person not detected"

    finally:
        await tx.rollback()


async def test_v10b_self_test_detects_orphan_entry(db_conn) -> None:
    """Self-test: drop FK, delete entry → mapping points to nothing → V10.b catches."""
    tx = db_conn.transaction()
    await tx.start()
    try:
        # Create infrastructure
        person_id = uuid.uuid4()
        name_json = '{"zh-Hans": "test-v10b"}'
        await db_conn.execute(
            """INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier)
               VALUES ($1, $2, $3::jsonb, '上古', 'legendary', 'primary_text')""",
            person_id,
            f"v10b-{person_id.hex[:8]}",
            name_json,
        )
        await db_conn.execute(
            """INSERT INTO person_names (person_id, name, name_type, is_primary)
               VALUES ($1, $2, 'primary', true)""",
            person_id,
            f"test-v10b-{person_id.hex[:8]}",
        )

        source_id = await db_conn.fetchval(
            """INSERT INTO dictionary_sources (source_name, source_version, license, commercial_safe)
               VALUES ('test-v10b', 'v0', 'CC0', true)
               ON CONFLICT (source_name, source_version) DO UPDATE SET source_name = 'test-v10b'
               RETURNING id"""
        )
        entry_id = await db_conn.fetchval(
            """INSERT INTO dictionary_entries (source_id, external_id, entry_type, primary_name, attributes)
               VALUES ($1, 'Q_V10B_ORPHAN', 'person', 'orphan-entry', '{}'::jsonb)
               ON CONFLICT (source_id, external_id) DO UPDATE SET source_id = dictionary_entries.source_id
               RETURNING id""",
            source_id,
        )
        await db_conn.execute(
            """INSERT INTO seed_mappings
               (dictionary_entry_id, target_entity_type, target_entity_id,
                confidence, mapping_method, mapping_status)
               VALUES ($1, 'person', $2, 0.90, 'test', 'active')""",
            entry_id,
            person_id,
        )

        # Temporarily drop FK so we can delete the entry without cascade
        await db_conn.execute(
            "ALTER TABLE seed_mappings DROP CONSTRAINT seed_mappings_dictionary_entry_id_fkey"
        )
        await db_conn.execute("DELETE FROM dictionary_entries WHERE id = $1", entry_id)

        count = await db_conn.fetchval(V10B_QUERY)
        assert count >= 1, "V10.b self-test FAILED: orphan entry reference not detected"

    finally:
        await tx.rollback()


async def test_v10c_self_test_detects_active_without_evidence(db_conn) -> None:
    """Self-test: active mapping with no source_evidence → V10.c catches."""
    tx = db_conn.transaction()
    await tx.start()
    try:
        person_id = uuid.uuid4()
        name_json = '{"zh-Hans": "test-v10c"}'
        await db_conn.execute(
            """INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier)
               VALUES ($1, $2, $3::jsonb, '上古', 'legendary', 'primary_text')""",
            person_id,
            f"v10c-{person_id.hex[:8]}",
            name_json,
        )
        await db_conn.execute(
            """INSERT INTO person_names (person_id, name, name_type, is_primary)
               VALUES ($1, $2, 'primary', true)""",
            person_id,
            f"test-v10c-{person_id.hex[:8]}",
        )

        source_id = await db_conn.fetchval(
            """INSERT INTO dictionary_sources (source_name, source_version, license, commercial_safe)
               VALUES ('wikidata', 'test-v10c', 'CC0', true)
               ON CONFLICT (source_name, source_version) DO UPDATE SET source_name = 'wikidata'
               RETURNING id"""
        )
        entry_id = await db_conn.fetchval(
            """INSERT INTO dictionary_entries (source_id, external_id, entry_type, primary_name, attributes)
               VALUES ($1, 'Q_V10C_NO_EVIDENCE', 'person', 'no-evidence', '{}'::jsonb)
               ON CONFLICT (source_id, external_id) DO UPDATE SET source_id = dictionary_entries.source_id
               RETURNING id""",
            source_id,
        )

        # Insert active mapping but DON'T insert source_evidence
        await db_conn.execute(
            """INSERT INTO seed_mappings
               (dictionary_entry_id, target_entity_type, target_entity_id,
                confidence, mapping_method, mapping_status)
               VALUES ($1, 'person', $2, 0.90, 'test', 'active')""",
            entry_id,
            person_id,
        )

        count = await db_conn.fetchval(V10C_QUERY)
        assert count >= 1, "V10.c self-test FAILED: active mapping without evidence not detected"

    finally:
        await tx.rollback()
