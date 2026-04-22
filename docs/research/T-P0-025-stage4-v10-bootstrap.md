# T-P0-025 Stage 4 — V10 Bootstrap Report

> **Date**: 2026-04-22
> **Invariant**: V10 (seed_mapping consistency, 3 sub-rules)

---

## V10 Sub-Rules

### V10.a — Seed Mapping Orphan (target side)

Active/pending seed_mappings must point to live persons (not deleted, not merged).

```sql
SELECT count(*) FROM seed_mappings sm
LEFT JOIN persons p ON p.id = sm.target_entity_id
WHERE sm.target_entity_type = 'person'
  AND sm.mapping_status IN ('active', 'pending_review')
  AND (p.id IS NULL OR p.deleted_at IS NOT NULL OR p.merged_into_id IS NOT NULL)
```

**Bootstrap**: **0** ✅

### V10.b — Seed Mapping Orphan (entry side)

seed_mappings.dictionary_entry_id must reference an existing dictionary_entries row.

```sql
SELECT count(*) FROM seed_mappings sm
LEFT JOIN dictionary_entries de ON de.id = sm.dictionary_entry_id
WHERE de.id IS NULL
```

**Bootstrap**: **0** ���

### V10.c — Active Seed Must Have Evidence

Active seed_mappings must have a corresponding source_evidence with
provenance_tier='seed_dictionary'. Adapted from original brief (source_evidences
has no entity_id column; uses quoted_text pattern match instead).

```sql
SELECT count(*) FROM seed_mappings sm
JOIN dictionary_entries de ON de.id = sm.dictionary_entry_id
WHERE sm.mapping_status = 'active'
  AND NOT EXISTS (
    SELECT 1 FROM source_evidences se
    WHERE se.provenance_tier = 'seed_dictionary'
      AND se.quoted_text LIKE 'wikidata:' || de.external_id || '%'
  )
```

**Bootstrap**: **0** ✅

---

## Test Coverage

| Test | Validates | Result |
|------|-----------|--------|
| test_v10a_no_orphan_target | Production V10.a = 0 | ✅ |
| test_v10b_no_orphan_entry | Production V10.b = 0 | ✅ |
| test_v10c_active_seed_has_evidence | Production V10.c = 0 | ✅ |
| test_v10a_self_test_detects_orphan | Inject merged-person orphan → V10.a catches | ✅ |

## CI Integration

V10 tests in: `services/pipeline/tests/test_invariants_v10.py`
Same pattern as V4/V6/V7/V8 — asyncpg + DATABASE_URL, skipped without DB.
Pipeline suite: 312 passed (308 + 4 V10).

## Schema Adaptation Note

Original V10.c brief referenced `source_evidences.entity_type` and
`source_evidences.entity_id` columns which do not exist. Adapted to use
`quoted_text LIKE 'wikidata:{qid}%'` pattern matching against the
evidence rows written by Stage 2's write_seed_data(). This is fragile
to quoted_text format changes — a future V11 should validate the full
chain (source_evidence → book → dictionary_source) for robustness.
