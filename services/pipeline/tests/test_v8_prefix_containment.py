"""V8 INVARIANT: single-char prefix-containment across active persons.

A single-character person_name on person A that is a prefix of a name
on a different person B creates search pollution and potential merge
confusion.

Exemptions (per ADR-023):
  α: source_evidence_id IS NOT NULL → evidence-backed short-form reference
  β: name_type = 'alias' → already classified as legitimate variant

A row must fail BOTH exemptions to be flagged as a V8 violation.

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

V8_QUERY = """
    SELECT a.name AS short_name, pa.slug AS short_slug,
           b.name AS colliding_name, pb.slug AS colliding_slug
    FROM person_names a
    JOIN persons pa ON pa.id = a.person_id AND pa.deleted_at IS NULL
    JOIN person_names b ON b.person_id != a.person_id
      AND length(b.name) > 1
      AND b.name LIKE a.name || '%'
    JOIN persons pb ON pb.id = b.person_id AND pb.deleted_at IS NULL
    WHERE length(a.name) = 1
      AND a.source_evidence_id IS NULL
      AND a.name_type NOT IN ('alias')
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


async def test_v8_no_prefix_containment_violations(db_conn) -> None:
    """V8: no unexempted single-char prefix collisions across persons.

    Evidence-backed aliases (source_evidence_id IS NOT NULL) and
    alias-typed names are exempt — they represent legitimate ancient
    Chinese short-form references (e.g. 伯 for 伯夷).
    """
    rows = await db_conn.fetch(V8_QUERY)
    violations = [
        f"  {r['short_name']} ({r['short_slug']}) collides with "
        f"{r['colliding_name']} ({r['colliding_slug']})"
        for r in rows
    ]
    assert not violations, (
        f"V8 violated: {len(violations)} unexempted single-char prefix "
        f"collision(s) found:\n" + "\n".join(violations)
    )


async def test_v8_self_test_catches_pollution(db_conn) -> None:
    """Self-test: inject a poison row and verify V8 detects it.

    Inserts a single-char name '甲' (name_type='nickname', no evidence)
    on a test person, while another person has a name '甲骨'. The V8
    query must flag this collision. Everything rolls back after the test.
    """
    tx = db_conn.transaction()
    await tx.start()
    try:
        # Create two test persons
        person_a_id = uuid.uuid4()
        person_b_id = uuid.uuid4()
        name_json = '{"zh-Hans": "test-v8"}'

        await db_conn.execute(
            """INSERT INTO persons (id, slug, name, dynasty,
               reality_status, provenance_tier)
               VALUES ($1, $2, $3::jsonb, '上古', 'legendary',
                       'primary_text')""",
            person_a_id,
            f"test-v8-a-{person_a_id.hex[:8]}",
            name_json,
        )
        await db_conn.execute(
            """INSERT INTO persons (id, slug, name, dynasty,
               reality_status, provenance_tier)
               VALUES ($1, $2, $3::jsonb, '上古', 'legendary',
                       'primary_text')""",
            person_b_id,
            f"test-v8-b-{person_b_id.hex[:8]}",
            name_json,
        )

        # Person A: single-char '甲' with nickname type, no evidence
        await db_conn.execute(
            """INSERT INTO person_names (person_id, name, name_type, is_primary)
               VALUES ($1, '甲', 'nickname', true)""",
            person_a_id,
        )
        # Person B: '甲骨' — creates prefix collision with '甲'
        await db_conn.execute(
            """INSERT INTO person_names (person_id, name, name_type, is_primary)
               VALUES ($1, '甲骨', 'primary', true)""",
            person_b_id,
        )

        # V8 should catch this
        rows = await db_conn.fetch(V8_QUERY)
        poison_hits = [r for r in rows if r["short_name"] == "甲" and r["colliding_name"] == "甲骨"]
        assert len(poison_hits) >= 1, (
            "V8 self-test FAILED: injected pollution (甲 → 甲骨) was not "
            "detected by V8 query. Check query logic."
        )

        # Verify exemption α works: add evidence and re-check
        se_id = uuid.uuid4()
        await db_conn.execute(
            """INSERT INTO source_evidences (id, provenance_tier)
               VALUES ($1, 'ai_inferred')""",
            se_id,
        )
        await db_conn.execute(
            """UPDATE person_names SET source_evidence_id = $1
               WHERE person_id = $2 AND name = '甲'""",
            se_id,
            person_a_id,
        )
        rows_after = await db_conn.fetch(V8_QUERY)
        poison_after = [
            r for r in rows_after if r["short_name"] == "甲" and r["colliding_name"] == "甲骨"
        ]
        assert len(poison_after) == 0, (
            "V8 self-test FAILED: evidence exemption (α) did not suppress "
            "the collision after adding source_evidence_id."
        )

    finally:
        await tx.rollback()


async def test_v8_self_test_alias_exemption(db_conn) -> None:
    """Self-test: verify alias-typed names are exempt from V8.

    Inserts a single-char alias '乙' (name_type='alias', no evidence)
    that collides with another person's '乙丑'. V8 should NOT flag
    this because filter β exempts alias-typed names.
    """
    tx = db_conn.transaction()
    await tx.start()
    try:
        person_a_id = uuid.uuid4()
        person_b_id = uuid.uuid4()
        name_json = '{"zh-Hans": "test-v8-alias"}'

        await db_conn.execute(
            """INSERT INTO persons (id, slug, name, dynasty,
               reality_status, provenance_tier)
               VALUES ($1, $2, $3::jsonb, '上古', 'legendary',
                       'primary_text')""",
            person_a_id,
            f"test-v8-c-{person_a_id.hex[:8]}",
            name_json,
        )
        await db_conn.execute(
            """INSERT INTO persons (id, slug, name, dynasty,
               reality_status, provenance_tier)
               VALUES ($1, $2, $3::jsonb, '上古', 'legendary',
                       'primary_text')""",
            person_b_id,
            f"test-v8-d-{person_b_id.hex[:8]}",
            name_json,
        )

        # Person A: '乙' as alias, no evidence — should be exempt by filter β
        await db_conn.execute(
            """INSERT INTO person_names (person_id, name, name_type, is_primary)
               VALUES ($1, '乙', 'alias', false)""",
            person_a_id,
        )
        # Also give person A a primary name to satisfy V1
        await db_conn.execute(
            """INSERT INTO person_names (person_id, name, name_type, is_primary)
               VALUES ($1, '乙某', 'primary', true)""",
            person_a_id,
        )
        # Person B: '乙丑'
        await db_conn.execute(
            """INSERT INTO person_names (person_id, name, name_type, is_primary)
               VALUES ($1, '乙丑', 'primary', true)""",
            person_b_id,
        )

        rows = await db_conn.fetch(V8_QUERY)
        poison_hits = [r for r in rows if r["short_name"] == "乙" and r["colliding_name"] == "乙丑"]
        assert len(poison_hits) == 0, (
            "V8 self-test FAILED: alias exemption (β) did not suppress "
            "the collision for name_type='alias'."
        )

    finally:
        await tx.rollback()
