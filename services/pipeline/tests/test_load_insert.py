"""DB integration tests for load.py _insert_person_names is_primary logic.

Validates T-P0-016 step 1b: when _enforce_single_primary demotes name_zh
from primary to alias, the W1 INSERT must set is_primary=false (not hardcoded true).

Requires DATABASE_URL env var pointing to the huadian DB.
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
async def db_conn():
    """Create a DB connection for load insert tests."""
    import asyncpg

    url = os.environ["DATABASE_URL"]
    conn = await asyncpg.connect(url)
    try:
        yield conn
    finally:
        await conn.close()


@pytest.fixture
async def test_person_id(db_conn):
    """Create an isolated test person, cleaned up after test."""
    person_id = str(uuid.uuid4())
    tag = uuid.uuid4().hex[:8]

    await db_conn.execute(
        """
        INSERT INTO persons (id, slug, name, provenance_tier)
        VALUES ($1, $2, '{"zh-Hans": "test-load"}'::jsonb, 'primary_text')
        """,
        person_id,
        f"test-load-{tag}",
    )

    try:
        yield person_id
    finally:
        await db_conn.execute("DELETE FROM person_names WHERE person_id = $1", person_id)
        await db_conn.execute("DELETE FROM persons WHERE id = $1", person_id)


def _person(name_zh: str, forms: list[tuple[str, str]]):
    """Helper: create a MergedPerson with given surface_forms."""
    from huadian_pipeline.extract import SurfaceForm
    from huadian_pipeline.load import MergedPerson

    return MergedPerson(
        name_zh=name_zh,
        slug=f"test-{name_zh}",
        surface_forms=[SurfaceForm(text=t, name_type=nt) for t, nt in forms],
        dynasty="上古",
        reality_status="legendary",
        briefs=[],
        identity_notes=[],
        confidence=0.9,
        chunk_ids=["c1"],
        paragraph_nos=[1],
    )


async def test_load_primary_name_zh_keeps_is_primary_true(db_conn, test_person_id):
    """name_zh not demoted by _enforce_single_primary -> W1 INSERT is (primary, is_primary=true)."""
    from huadian_pipeline.load import _insert_person_names

    person = _person("黄帝", [("黄帝", "primary"), ("轩辕", "alias")])

    await _insert_person_names(db_conn, test_person_id, person)

    row = await db_conn.fetchrow(
        "SELECT name_type, is_primary FROM person_names WHERE person_id = $1 AND name = $2",
        test_person_id,
        "黄帝",
    )
    assert row is not None, "name_zh row not inserted"
    assert row["name_type"] == "primary"
    assert row["is_primary"] is True


async def test_load_demoted_name_zh_sets_is_primary_false(db_conn, test_person_id):
    """name_zh already alias in NER output -> W1 INSERT is (alias, is_primary=false).

    This is the V6 violation scenario fixed by T-P0-016 step 1b.
    Real-world path: NER returns name_zh as alias (not primary), with a different
    surface as the sole primary. _enforce_single_primary passes through (1 primary),
    but W1 INSERT previously hardcoded is_primary=true regardless of name_type.
    The 5 active violations (fu-yue / shen-nong-shi / 少暤氏 / 缙云氏 / 微子启)
    were all produced by this path.
    """
    from huadian_pipeline.load import _insert_person_names

    # name_zh="神農氏" is alias, "炎帝" is the sole primary
    # _enforce_single_primary: 1 primary → pass through
    # L353-357: finds "神農氏" → name_type = "alias"
    # W1 INSERT: name_type='alias', is_primary must be false (was hardcoded true)
    person = _person("神農氏", [("神農氏", "alias"), ("炎帝", "primary")])

    await _insert_person_names(db_conn, test_person_id, person)

    row = await db_conn.fetchrow(
        "SELECT name_type, is_primary FROM person_names WHERE person_id = $1 AND name = $2",
        test_person_id,
        "神農氏",
    )
    assert row is not None, "name_zh row not inserted"
    assert row["name_type"] == "alias", f"Expected alias, got {row['name_type']}"
    assert row["is_primary"] is False, (
        f"Expected is_primary=false after demotion, got {row['is_primary']}"
    )


# ---------------------------------------------------------------------------
# T-P0-023 Stage 1e: source_evidences two-step INSERT tests
# ---------------------------------------------------------------------------


@pytest.fixture
async def evidence_fixtures(db_conn):
    """Create book + raw_text fixtures for evidence chain tests. Cleaned up after."""
    book_id = str(uuid.uuid4())
    raw_text_id = str(uuid.uuid4())
    llm_call_id = str(uuid.uuid4())

    await db_conn.execute(
        """
        INSERT INTO books (id, title, credibility_tier, license, slug)
        VALUES ($1, '{"zh-Hans": "test-book"}'::jsonb, 'primary_official', 'CC0', $2)
        """,
        book_id,
        f"test-book-{uuid.uuid4().hex[:8]}",
    )
    await db_conn.execute(
        """
        INSERT INTO raw_texts (id, source_id, book_id, paragraph_no, raw_text)
        VALUES ($1, 'test-src', $2, 1, '黄帝者，少典之子')
        """,
        raw_text_id,
        book_id,
    )

    try:
        yield {
            "book_id": book_id,
            "raw_text_id": raw_text_id,
            "llm_call_id": llm_call_id,
        }
    finally:
        await db_conn.execute(
            "DELETE FROM person_names WHERE source_evidence_id IN "
            "(SELECT id FROM source_evidences WHERE book_id = $1)",
            book_id,
        )
        await db_conn.execute("DELETE FROM source_evidences WHERE book_id = $1", book_id)
        await db_conn.execute(
            "DELETE FROM person_names WHERE person_id IN "
            "(SELECT id FROM persons WHERE slug LIKE 'test-evi-%')"
        )
        await db_conn.execute("DELETE FROM persons WHERE slug LIKE 'test-evi-%'")
        await db_conn.execute("DELETE FROM raw_texts WHERE book_id = $1", book_id)
        await db_conn.execute("DELETE FROM books WHERE id = $1", book_id)


def _person_with_evidence(
    name_zh: str,
    forms: list[tuple[str, str]],
    raw_text_id: str,
    llm_call_id: str | None = None,
):
    """Helper: create a MergedPerson with evidence chain fields populated."""
    from huadian_pipeline.extract import SurfaceForm
    from huadian_pipeline.load import MergedPerson

    return MergedPerson(
        name_zh=name_zh,
        slug=f"test-evi-{uuid.uuid4().hex[:8]}",
        surface_forms=[SurfaceForm(text=t, name_type=nt) for t, nt in forms],
        dynasty="上古",
        reality_status="legendary",
        briefs=[],
        identity_notes=[],
        confidence=0.9,
        chunk_ids=[raw_text_id],
        paragraph_nos=[1],
        llm_call_ids=[llm_call_id] if llm_call_id else [],
    )


async def test_load_creates_source_evidence_per_person(db_conn, evidence_fixtures):
    """load_persons creates one source_evidences row per person, linked to all names."""
    import asyncpg

    from huadian_pipeline.load import load_persons

    fx = evidence_fixtures
    person = _person_with_evidence(
        "黄帝",
        [("黄帝", "primary"), ("轩辕", "alias")],
        fx["raw_text_id"],
        fx["llm_call_id"],
    )

    pool = await asyncpg.create_pool(os.environ["DATABASE_URL"], min_size=1, max_size=2)
    try:
        result = await load_persons(
            pool,
            [person],
            book_id=fx["book_id"],
            prompt_version="ner/v1-r4",
        )
    finally:
        await pool.close()

    assert result.persons_inserted == 1
    assert result.names_inserted == 2  # primary + alias

    # Verify source_evidences row
    evi = await db_conn.fetchrow(
        "SELECT * FROM source_evidences WHERE book_id = $1",
        fx["book_id"],
    )
    assert evi is not None, "source_evidences row not created"
    assert str(evi["raw_text_id"]) == fx["raw_text_id"]
    assert str(evi["book_id"]) == fx["book_id"]
    assert evi["provenance_tier"] == "ai_inferred"
    assert evi["prompt_version"] == "ner/v1-r4"
    assert str(evi["llm_call_id"]) == fx["llm_call_id"]
    assert evi["position_start"] is None
    assert evi["position_end"] is None
    assert evi["quoted_text"] is None
    assert evi["text_version"] is None

    # Verify all person_names point to the same evidence
    names = await db_conn.fetch(
        "SELECT source_evidence_id FROM person_names WHERE person_id = "
        "(SELECT id FROM persons WHERE slug = $1)",
        person.slug,
    )
    assert len(names) == 2
    evi_id = str(evi["id"])
    for n in names:
        assert str(n["source_evidence_id"]) == evi_id, "All names must share one evidence"


async def test_load_handles_null_llm_call_ids(db_conn, evidence_fixtures):
    """load_persons succeeds with empty llm_call_ids; evidence has llm_call_id NULL."""
    import asyncpg

    from huadian_pipeline.load import load_persons

    fx = evidence_fixtures
    person = _person_with_evidence("舜", [("舜", "primary")], fx["raw_text_id"], llm_call_id=None)

    pool = await asyncpg.create_pool(os.environ["DATABASE_URL"], min_size=1, max_size=2)
    try:
        result = await load_persons(
            pool,
            [person],
            book_id=fx["book_id"],
            prompt_version="ner/v1-r4",
        )
    finally:
        await pool.close()

    assert result.persons_inserted == 1
    assert len(result.errors) == 0

    evi = await db_conn.fetchrow(
        "SELECT llm_call_id FROM source_evidences WHERE book_id = $1 "
        "ORDER BY created_at DESC LIMIT 1",
        fx["book_id"],
    )
    assert evi is not None
    assert evi["llm_call_id"] is None


async def test_load_per_person_transaction_isolates_failures(db_conn, evidence_fixtures):
    """Failed person (FK violation) is rolled back; successful person is committed."""
    import asyncpg

    from huadian_pipeline.load import load_persons

    fx = evidence_fixtures
    bad_raw_text_id = str(uuid.uuid4())  # non-existent → FK violation

    person_bad = _person_with_evidence(
        "坏人", [("坏人", "primary")], bad_raw_text_id, fx["llm_call_id"]
    )
    person_good = _person_with_evidence(
        "好人", [("好人", "primary")], fx["raw_text_id"], fx["llm_call_id"]
    )

    pool = await asyncpg.create_pool(os.environ["DATABASE_URL"], min_size=1, max_size=2)
    try:
        result = await load_persons(
            pool,
            [person_bad, person_good],
            book_id=fx["book_id"],
            prompt_version="ner/v1-r4",
        )
    finally:
        await pool.close()

    # Bad person failed, good person succeeded
    assert len(result.errors) == 1
    assert result.persons_inserted == 1

    # Bad person fully rolled back (no person, no names, no evidence)
    bad_count = await db_conn.fetchval(
        "SELECT COUNT(*) FROM persons WHERE slug = $1", person_bad.slug
    )
    assert bad_count == 0, "Failed person must be fully rolled back"

    # Good person fully committed
    good_count = await db_conn.fetchval(
        "SELECT COUNT(*) FROM persons WHERE slug = $1", person_good.slug
    )
    assert good_count == 1, "Successful person must be committed"

    good_evi = await db_conn.fetchval(
        "SELECT COUNT(*) FROM source_evidences WHERE book_id = $1",
        fx["book_id"],
    )
    assert good_evi >= 1, "Good person's evidence must exist"
