"""V8 invariant — single-char name should not prefix-collide with other person's name.

Pattern: ContainmentInvariant (rows returned ARE the violations).

Source: services/pipeline/tests/test_v8_prefix_containment.py
ADR: ADR-023 (V8 + exemptions)

Background:
    A single-character person_name on person A that is a prefix of a name
    on a different person B causes search pollution and merge confusion.

Exemptions (the SQL applies these — rows returned are unexempted):
    α: source_evidence_id IS NOT NULL (evidence-backed short-form ref)
    β: name_type = 'alias' (already classified as legitimate variant)
"""

from __future__ import annotations

from framework.invariant_scaffold import ContainmentInvariant

V8_SQL = """
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


def make_v8() -> ContainmentInvariant:
    """Build the V8 invariant (single-char prefix containment)."""
    return ContainmentInvariant.from_template(
        name="V8",
        description="unexempted single-char names should not prefix-collide with longer names",
        sql=V8_SQL,
        violation_explanation_fmt=(
            "{short_name} ({short_slug}) collides with {colliding_name} ({colliding_slug})"
        ),
        severity="critical",
    )
