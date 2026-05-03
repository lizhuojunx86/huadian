"""V6 invariant — no person_name has name_type='alias' AND is_primary=true.

Pattern: CardinalityBoundInvariant (exact_total mode, expected = 0).

Source: services/pipeline/tests/test_merge_invariant.py:test_no_alias_with_is_primary_true
ADR: ADR-014 F5/F11 (T-P0-016 demotion sync)

Background:
    is_primary should track name_type — when apply_merges() demotes a
    primary name to alias, both fields must update. Otherwise the
    GraphQL read side exposes nameType=alias + isPrimary=true (semantic
    contradiction).
"""

from __future__ import annotations

from framework.invariant_scaffold import CardinalityBoundInvariant

V6_SQL = """
    SELECT COUNT(*) FROM person_names
    WHERE name_type = 'alias' AND is_primary = true
"""


def make_v6() -> CardinalityBoundInvariant:
    """Build the V6 invariant (no alias+is_primary contradictions)."""
    return CardinalityBoundInvariant.from_template(
        name="V6",
        description="no person_name has name_type='alias' AND is_primary=true",
        sql=V6_SQL,
        mode="exact_total",
        expected_count=0,
        violation_explanation_fmt="{count} person_name row(s) violate alias/is_primary contract",
        severity="critical",
    )
