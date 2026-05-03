"""Active+merged invariant — every person with merged_into_id must have deleted_at.

Pattern: ContainmentInvariant (merged_into_id-set ⊆ deleted_at-set).

Source: services/pipeline/tests/test_merge_invariant.py:test_no_active_but_merged
Bug history: T-P0-015 帝鸿氏 bug — partial merges (merged_into_id set,
            deleted_at NULL) double-count in active-person queries.
"""

from __future__ import annotations

from framework.invariant_scaffold import ContainmentInvariant

ACTIVE_MERGED_SQL = """
    SELECT p.id::text, p.slug, p.name->>'zh-Hans' as name_zh
    FROM persons p
    WHERE p.deleted_at IS NULL
      AND p.merged_into_id IS NOT NULL
    ORDER BY p.slug
"""


def make_active_merged() -> ContainmentInvariant:
    """Build the active+merged invariant (no partial merges)."""
    return ContainmentInvariant.from_template(
        name="active_merged",
        description="every person with merged_into_id must also have deleted_at set",
        sql=ACTIVE_MERGED_SQL,
        violation_explanation_fmt=(
            "person {slug} ({name_zh}) has merged_into_id set but deleted_at IS NULL"
        ),
        severity="critical",
    )
