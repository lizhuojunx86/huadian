"""V9 invariant — every active person has at least 1 person_names with is_primary=true.

Pattern: LowerBoundInvariant (NOT EXISTS subquery).

Source: services/pipeline/tests/test_invariants_v9.py
ADR: ADR-024

Background:
    Complements V1 (upper bound: at most 1 primary) to enforce
    exactly-one-primary semantics. Bootstrap (Sprint F) cleared all 33
    historical violations before V9 was introduced.
"""

from __future__ import annotations

from framework.invariant_scaffold import LowerBoundInvariant

V9_SQL = """
    SELECT p.id::text, p.slug
    FROM persons p
    WHERE p.deleted_at IS NULL
      AND p.merged_into_id IS NULL
      AND NOT EXISTS (
        SELECT 1 FROM person_names pn
        WHERE pn.person_id = p.id AND pn.is_primary = true
      )
"""


def make_v9() -> LowerBoundInvariant:
    """Build the V9 invariant (active person ≥ 1 primary name)."""
    return LowerBoundInvariant.from_template(
        name="V9",
        description="every active person has ≥ 1 person_name with is_primary=true",
        sql=V9_SQL,
        min_count=1,
        violation_explanation_fmt="active person {slug} has zero is_primary=true names",
        severity="critical",
    )
