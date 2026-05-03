"""V4 invariant — every soft-merged person retains at least one person_name.

Pattern: LowerBoundInvariant.

Source: services/pipeline/tests/test_merge_invariant.py:test_v4_no_model_b_leakage
ADR: ADR-014 (canonical merge execution model)

Background:
    Per ADR-014 model A: when person A is merged into person B, A's names
    stay on A (A.deleted_at = now, A.merged_into_id = B.id). The names are
    NOT migrated to B. This lets findPersonNamesWithMerged() aggregate them.
    If a merged person has zero names, model B has leaked → bug.
"""

from __future__ import annotations

from framework.invariant_scaffold import LowerBoundInvariant

V4_SQL = """
    SELECT p.id::text, p.slug, p.name->>'zh-Hans' as name_zh
    FROM persons p
    WHERE p.deleted_at IS NOT NULL
      AND p.merged_into_id IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM person_names WHERE person_id = p.id)
    ORDER BY p.slug
"""


def make_v4() -> LowerBoundInvariant:
    """Build the V4 invariant (model-A compliance for soft-merged persons)."""
    return LowerBoundInvariant.from_template(
        name="V4",
        description="every soft-merged person retains ≥ 1 person_name (ADR-014 model A)",
        sql=V4_SQL,
        min_count=1,
        violation_explanation_fmt="merged person {slug} ({name_zh}) has zero person_names",
        severity="critical",
    )
