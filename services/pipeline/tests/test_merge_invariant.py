"""Merge model invariant tests — enforces ADR-014 / ADR-015 across the entire DB.

V4 INVARIANT (ADR-014): Every soft-deleted person that has merged_into_id
must retain at least one person_name row. This ensures model-A compliance:
names stay on the source person for read-side aggregation via
findPersonNamesWithMerged().

V7 INVARIANT (ADR-015): Active person_names should reference a
source_evidences row. Warning-level (does not fail CI); will be promoted
to error-level when Stage 2 backfill completes.

Requires DATABASE_URL env var pointing to the huadian DB.
"""

from __future__ import annotations

import os
import warnings

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


async def test_no_alias_with_is_primary_true(db_conn) -> None:
    """V6: no person_name row should have name_type='alias' AND is_primary=true.

    This combination is a semantic contradiction that leaks into GraphQL
    as nameType=alias + isPrimary=true. All demotion paths (apply_merges,
    load.py _enforce_single_primary) must sync is_primary with name_type.
    See T-P0-016 / ADR-014 F5/F11.
    """
    count = await db_conn.fetchval(
        "SELECT COUNT(*) FROM person_names WHERE name_type = 'alias' AND is_primary = true"
    )
    assert count == 0, (
        f"V6 violated: {count} person_name row(s) have name_type='alias' AND "
        f"is_primary=true (semantic contradiction)"
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


async def test_v7_evidence_chain_coverage_warning(db_conn) -> None:
    """V7 (ADR-015 Stage 1) warning-level invariant.

    Active person_names should reference a source_evidences row via
    source_evidence_id. This invariant emits a UserWarning — not a
    hard failure — because:

    - Legacy rows pre-dating ADR-015 Stage 1e are uncovered by design;
      Stage 2 (text-search back-fill, separate sprint) will remediate.
    - Stage 1e production path writes evidence for every new ingest,
      so coverage only grows going forward.

    Threshold 0.3 is deliberately low to tolerate the legacy backlog
    during Stage 1 rollout. Will be raised to 1.0 and promoted to
    error-level (assert) when Stage 2 back-fill completes.

    To treat as error in CI: pytest -W error::UserWarning.
    """
    threshold = 0.3
    row = await db_conn.fetchrow(
        """
        SELECT
            COUNT(*) AS total,
            COUNT(pn.source_evidence_id) AS covered
        FROM person_names pn
        JOIN persons p ON pn.person_id = p.id
        WHERE p.deleted_at IS NULL
        """
    )
    total = row["total"]
    covered = row["covered"]
    coverage = (covered / total) if total else 1.0

    if coverage < threshold:
        warnings.warn(
            f"V7: evidence chain coverage {coverage:.1%} "
            f"({covered}/{total} active person_names) below threshold "
            f"{threshold:.0%}. Legacy rows pending ADR-015 Stage 2 "
            f"backfill — verify new ingests produce source_evidences.",
            UserWarning,
            stacklevel=2,
        )
