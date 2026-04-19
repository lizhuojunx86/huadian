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
