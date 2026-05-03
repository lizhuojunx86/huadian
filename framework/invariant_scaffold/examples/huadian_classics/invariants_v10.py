"""V10 invariant — seed_mapping consistency (3 sub-rules).

V10.a — Active/pending seed_mappings must point to live persons (not deleted/merged).
V10.b — seed_mappings.dictionary_entry_id must reference an existing entry.
V10.c — Active seed_mappings must have a corresponding source_evidence with
        provenance_tier='seed_dictionary'.

Patterns:
    V10.a — OrphanDetectionInvariant (count_only)
    V10.b — OrphanDetectionInvariant (count_only)
    V10.c — ContainmentInvariant (returns rows missing evidence)

Source: services/pipeline/tests/test_invariants_v10.py
"""

from __future__ import annotations

from framework.invariant_scaffold import (
    ContainmentInvariant,
    OrphanDetectionInvariant,
)

V10A_SQL = """
    SELECT count(*) FROM seed_mappings sm
    LEFT JOIN persons p ON p.id = sm.target_entity_id
    WHERE sm.target_entity_type = 'person'
      AND sm.mapping_status IN ('active', 'pending_review')
      AND (p.id IS NULL OR p.deleted_at IS NOT NULL OR p.merged_into_id IS NOT NULL)
"""

V10B_SQL = """
    SELECT count(*) FROM seed_mappings sm
    LEFT JOIN dictionary_entries de ON de.id = sm.dictionary_entry_id
    WHERE de.id IS NULL
"""

V10C_SQL = """
    SELECT sm.id::text AS mapping_id,
           de.external_id AS qid,
           ds.source_name
    FROM seed_mappings sm
    JOIN dictionary_entries de ON de.id = sm.dictionary_entry_id
    JOIN dictionary_sources ds ON ds.id = de.source_id
    WHERE sm.mapping_status = 'active'
      AND NOT EXISTS (
        SELECT 1 FROM source_evidences se
        WHERE se.provenance_tier = 'seed_dictionary'
          AND se.quoted_text LIKE 'wikidata:' || de.external_id || '%'
      )
"""


def make_v10a() -> OrphanDetectionInvariant:
    """V10.a — active/pending seed_mapping → live person."""
    return OrphanDetectionInvariant.from_template(
        name="V10.a",
        description="active/pending seed_mappings must point to live persons",
        sql=V10A_SQL,
        count_only=True,
        violation_explanation_fmt="{count} seed_mapping(s) point to dead/merged persons",
        severity="critical",
    )


def make_v10b() -> OrphanDetectionInvariant:
    """V10.b — seed_mappings.dictionary_entry_id → existing dictionary_entries."""
    return OrphanDetectionInvariant.from_template(
        name="V10.b",
        description="seed_mappings.dictionary_entry_id must reference an existing entry",
        sql=V10B_SQL,
        count_only=True,
        violation_explanation_fmt="{count} seed_mapping(s) reference missing dictionary_entries",
        severity="critical",
    )


def make_v10c() -> ContainmentInvariant:
    """V10.c — active seed_mappings ⊆ has-source-evidence."""
    return ContainmentInvariant.from_template(
        name="V10.c",
        description="active seed_mappings must have a seed_dictionary source_evidence",
        sql=V10C_SQL,
        violation_explanation_fmt=(
            "mapping {mapping_id} for {source_name}:{qid} lacks seed_dictionary evidence"
        ),
        severity="critical",
    )
