"""Tests for R6 seed-match rule.

Uses real DB with test fixtures inserted in a transaction (rolled back after).

Covers:
1. QID hit active conf=0.85 → matched
2. QID hit active conf=0.70 → below_cutoff
3. QID hit pending_review → not_found (pending filtered)
4. QID unknown → not_found
5. Name single hit → matched
6. Name multi hit → ambiguous
"""

from __future__ import annotations

import os
import uuid

import pytest

from huadian_pipeline.r6_seed_match import R6Status, r6_seed_match

pytestmark = pytest.mark.skipif(
    not os.environ.get("DATABASE_URL"),
    reason="DATABASE_URL not set — skipping DB tests",
)


@pytest.fixture
async def db_conn():
    import asyncpg

    url = os.environ["DATABASE_URL"]
    conn = await asyncpg.connect(url)
    try:
        yield conn
    finally:
        await conn.close()


@pytest.fixture
async def seed_fixtures(db_conn):
    """Set up test seed data inside a transaction (rolled back after)."""
    tx = db_conn.transaction()
    await tx.start()

    # Create test persons
    person_a = uuid.uuid4()
    person_b = uuid.uuid4()
    for pid, slug, name in [
        (person_a, f"test-r6-a-{person_a.hex[:8]}", "测试人物甲"),
        (person_b, f"test-r6-b-{person_b.hex[:8]}", "测试人物乙"),
    ]:
        await db_conn.execute(
            """INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier)
               VALUES ($1, $2, $3::jsonb, '上古', 'legendary', 'primary_text')""",
            pid,
            slug,
            f'{{"zh-Hans": "{name}"}}',
        )
        await db_conn.execute(
            """INSERT INTO person_names (person_id, name, name_type, is_primary)
               VALUES ($1, $2, 'primary', true)""",
            pid,
            name,
        )

    # Create dictionary source
    source_id = await db_conn.fetchval(
        """INSERT INTO dictionary_sources (source_name, source_version, license, commercial_safe)
           VALUES ('wikidata', 'test-r6', 'CC0', true)
           ON CONFLICT (source_name, source_version) DO UPDATE SET source_name = 'wikidata'
           RETURNING id"""
    )

    # Entry 1: Q_HIGH (conf 0.85 active → matched)
    entry_high = await db_conn.fetchval(
        """INSERT INTO dictionary_entries (source_id, external_id, entry_type, primary_name, attributes)
           VALUES ($1, 'Q_HIGH_R6', 'person', '测试人物甲', '{}'::jsonb)
           ON CONFLICT (source_id, external_id) DO UPDATE SET source_id = dictionary_entries.source_id
           RETURNING id""",
        source_id,
    )
    await db_conn.execute(
        """INSERT INTO seed_mappings (dictionary_entry_id, target_entity_type, target_entity_id,
           confidence, mapping_method, mapping_status)
           VALUES ($1, 'person', $2, 0.85, 'r2_alias', 'active')""",
        entry_high,
        person_a,
    )

    # Entry 2: Q_LOW (conf 0.70 active → below_cutoff)
    entry_low = await db_conn.fetchval(
        """INSERT INTO dictionary_entries (source_id, external_id, entry_type, primary_name, attributes)
           VALUES ($1, 'Q_LOW_R6', 'person', '低信人物', '{}'::jsonb)
           ON CONFLICT (source_id, external_id) DO UPDATE SET source_id = dictionary_entries.source_id
           RETURNING id""",
        source_id,
    )
    await db_conn.execute(
        """INSERT INTO seed_mappings (dictionary_entry_id, target_entity_type, target_entity_id,
           confidence, mapping_method, mapping_status)
           VALUES ($1, 'person', $2, 0.70, 'r3_name_scan', 'active')""",
        entry_low,
        person_b,
    )

    # Entry 3: Q_PENDING (pending_review → should be invisible to R6)
    entry_pending = await db_conn.fetchval(
        """INSERT INTO dictionary_entries (source_id, external_id, entry_type, primary_name, attributes)
           VALUES ($1, 'Q_PENDING_R6', 'person', '待审人物', '{}'::jsonb)
           ON CONFLICT (source_id, external_id) DO UPDATE SET source_id = dictionary_entries.source_id
           RETURNING id""",
        source_id,
    )
    await db_conn.execute(
        """INSERT INTO seed_mappings (dictionary_entry_id, target_entity_type, target_entity_id,
           confidence, mapping_method, mapping_status)
           VALUES ($1, 'person', $2, 0.00, 'r1_exact_multi', 'pending_review')""",
        entry_pending,
        person_a,
    )

    # Entry 4: Q_AMBIG (same primary_name as Q_HIGH for ambiguity test)
    entry_ambig = await db_conn.fetchval(
        """INSERT INTO dictionary_entries (source_id, external_id, entry_type, primary_name, attributes)
           VALUES ($1, 'Q_AMBIG_R6', 'person', '测试人物甲', '{}'::jsonb)
           ON CONFLICT (source_id, external_id) DO UPDATE SET source_id = dictionary_entries.source_id
           RETURNING id""",
        source_id,
    )
    await db_conn.execute(
        """INSERT INTO seed_mappings (dictionary_entry_id, target_entity_type, target_entity_id,
           confidence, mapping_method, mapping_status)
           VALUES ($1, 'person', $2, 0.90, 'r1_exact', 'active')""",
        entry_ambig,
        person_b,
    )

    yield {
        "person_a": person_a,
        "person_b": person_b,
        "source_id": source_id,
    }

    await tx.rollback()


class TestR6QidLookup:
    @pytest.mark.asyncio
    async def test_qid_hit_active_high_conf(self, db_conn, seed_fixtures) -> None:
        """QID with active mapping conf=0.85 → matched."""
        result = await r6_seed_match(db_conn, candidate_name="", candidate_qid="Q_HIGH_R6")
        assert result.status == R6Status.MATCHED
        assert result.person_id == str(seed_fixtures["person_a"])
        assert result.confidence == 0.85
        assert result.external_id == "Q_HIGH_R6"

    @pytest.mark.asyncio
    async def test_qid_hit_active_low_conf(self, db_conn, seed_fixtures) -> None:
        """QID with active mapping conf=0.70 → below_cutoff."""
        result = await r6_seed_match(db_conn, candidate_name="", candidate_qid="Q_LOW_R6")
        assert result.status == R6Status.BELOW_CUTOFF
        assert result.confidence == 0.70
        assert "cutoff" in result.detail.lower()

    @pytest.mark.asyncio
    async def test_qid_hit_pending_review(self, db_conn, seed_fixtures) -> None:
        """QID with pending_review mapping → not_found (pending filtered)."""
        result = await r6_seed_match(db_conn, candidate_name="", candidate_qid="Q_PENDING_R6")
        assert result.status == R6Status.NOT_FOUND

    @pytest.mark.asyncio
    async def test_qid_unknown(self, db_conn, seed_fixtures) -> None:
        """Unknown QID → not_found."""
        result = await r6_seed_match(db_conn, candidate_name="", candidate_qid="Q_NONEXISTENT")
        assert result.status == R6Status.NOT_FOUND


class TestR6NameLookup:
    @pytest.mark.asyncio
    async def test_name_single_hit(self, db_conn, seed_fixtures) -> None:
        """Name with single active mapping above cutoff → matched."""
        # "低信人物" has conf=0.70; lower cutoff to 0.60 so name path finds it
        result = await r6_seed_match(db_conn, candidate_name="低信人物", confidence_cutoff=0.60)
        assert result.status == R6Status.MATCHED
        assert result.external_id == "Q_LOW_R6"

    @pytest.mark.asyncio
    async def test_name_multi_hit(self, db_conn, seed_fixtures) -> None:
        """Name with multiple active mappings → ambiguous."""
        # "测试人物甲" has two active entries: Q_HIGH_R6 (conf 0.85) and Q_AMBIG_R6 (conf 0.90)
        result = await r6_seed_match(db_conn, candidate_name="测试人物甲")
        assert result.status == R6Status.AMBIGUOUS
        assert "Multiple" in result.detail
