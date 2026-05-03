"""V11 invariant — no active person has > 1 active seed_mapping.

Pattern: CardinalityBoundInvariant (exact_total — count of offenders == 0).

Source: services/pipeline/tests/test_invariants_v11.py

Background:
    Guards against AMBIGUOUS R6 pre-pass results. If a person has multiple
    active seed_mappings, the pre-pass cannot determine which QID to use,
    breaking R6 merge detection.
"""

from __future__ import annotations

from framework.invariant_scaffold import CardinalityBoundInvariant

V11_SQL = """
    SELECT count(DISTINCT sq.person_id) FROM (
        SELECT sm.target_entity_id AS person_id, count(*) AS cnt
        FROM seed_mappings sm
        WHERE sm.target_entity_type = 'person'
          AND sm.mapping_status = 'active'
        GROUP BY sm.target_entity_id
        HAVING count(*) > 1
    ) sq
"""


def make_v11() -> CardinalityBoundInvariant:
    """Build the V11 invariant (no >1 active seed_mapping per person)."""
    return CardinalityBoundInvariant.from_template(
        name="V11",
        description="no active person has > 1 active seed_mapping (R6 pre-pass anti-ambiguity)",
        sql=V11_SQL,
        mode="exact_total",
        expected_count=0,
        violation_explanation_fmt=("{count} person(s) have multiple active seed_mappings"),
        severity="critical",
    )
