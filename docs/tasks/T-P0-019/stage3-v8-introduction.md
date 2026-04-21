# T-P0-019 α Stage 3 — V8 Prefix-Containment Invariant

> **Sprint**: T-P0-019 α (β tail cleanup)
> **Stage**: 3 of 3
> **Date**: 2026-04-21
> **Role**: Pipeline Engineer (implement) + Chief Architect (ruling + ADR-023)

---

## Summary

Original Stage 3 plan (hard DELETE 3 F2 rows per ADR-022) was **blocked at Gate 0b**: all 3 rows had non-null `source_evidence_id` (T-P0-024 α backfill had correctly linked them to text passages). ADR-022 three-criteria test #1 (evidence chain zero-dep) failed → hard DELETE not applicable.

Historian confirmed rows are **legitimate 古汉語 anaphoric short-forms** (伯→伯夷, 管→管叔, 蔡→蔡叔), not NER pollution. Scope pivoted from data deletion to **rule refinement**: V8 invariant introduced with evidence + alias exemptions.

Result: F2 resolved via QC rule, not DELETE. V8 = 0 violations. 3 rows preserved as legitimate data.

---

## Gate 0b Blocking Event

### Dependency Audit (3 F2 Rows)

| name | person_slug | source_evidence_id | name_type | ADR-022 #1 (evidence=NULL) |
|------|-------------|-------------------|-----------|---------------------------|
| 伯 | bo-yi | 24c69695-... | alias | **FAIL** (non-NULL) |
| 管 | u7ba1-u53d4 | 075108f7-... | alias | **FAIL** (non-NULL) |
| 蔡 | u8521-u53d4 | 241a922b-... | alias | **FAIL** (non-NULL) |

All 3 rows failed ADR-022 §2.1 criterion #1. Pipeline engineer correctly stopped and escalated.

### Historian Verdict

Original text evidence confirmed all 3 as **anaphoric short-form references**:

- **伯** (尚书·舜典 §15): "佥曰：伯夷！" → "咨！伯，汝作秩宗" → "伯拜稽首" — same-paragraph full-name-then-short-form anaphora
- **管** (史记·周本纪 §22): "管叔、蔡叔群弟疑周公" → "管、蔡畔周" — paratactic contraction (fixed idiom-level abbreviation in pre-Qin/Qin-Han texts)
- **蔡** (同上 §22): mirror of 管

Verdict: **legitimate aliases**, not NER pollution. Data already correctly classified (`name_type='alias'`, `is_primary=false`, `provenance_tier='ai_inferred'`, `prompt_version='ner/v1-r4'`).

---

## V8 Invariant Design

### SQL Definition

```sql
SELECT a.name AS short_name, pa.slug AS short_slug,
       b.name AS colliding_name, pb.slug AS colliding_slug
FROM person_names a
JOIN persons pa ON pa.id = a.person_id AND pa.deleted_at IS NULL
JOIN person_names b ON b.person_id != a.person_id
  AND length(b.name) > 1
  AND b.name LIKE a.name || '%'
JOIN persons pb ON pb.id = b.person_id AND pb.deleted_at IS NULL
WHERE length(a.name) = 1
  AND a.source_evidence_id IS NULL      -- filter α: no evidence
  AND a.name_type NOT IN ('alias')      -- filter β: non-alias
```

### Exemption Logic

A single-char name must fail BOTH exemptions to be flagged:
- **α (evidence-backed)**: `source_evidence_id IS NOT NULL` → exempt (evidence chain = "real text occurrence")
- **β (alias-typed)**: `name_type = 'alias'` → exempt (already classified as legitimate variant)

### Probe Results (Pre-Exemption)

Without exemptions, 3 rows produce 10 cross-person prefix collisions:

| Short | Owner | Collisions | Targets |
|-------|-------|------------|---------|
| 伯 | bo-yi | 7 | 伯与/伯士/伯服/伯禹/伯臩/伯阳/伯阳甫 |
| 管 | u7ba1-u53d4 | 2 | 管仲/管叔鲜 |
| 蔡 | u8521-u53d4 | 1 | 蔡叔度 |

With exemptions: **V8 = 0 violations** (all 3 double-exempted by α AND β).

### Test Coverage

| Test | Validates | Result |
|------|-----------|--------|
| `test_v8_no_prefix_containment_violations` | Production data V8=0 | ✅ |
| `test_v8_self_test_catches_pollution` | Injected nickname+no-evidence single-char → V8 detects; then add evidence → V8 exempts | ✅ |
| `test_v8_self_test_alias_exemption` | Injected alias+no-evidence single-char → V8 exempts (β filter) | ✅ |

Full suite: 282 passed, 0 failed.

---

## Side Finding: Canonical Merge Missed Pairs

V8 probe exposed 2 suspected same-person duplicate pairs:

| Short-form person | Full-form person | Historical identity |
|-------------------|-----------------|-------------------|
| u7ba1-u53d4 (管叔) | u7ba1-u53d4-u9c9c (管叔鲜) | Same person (周公弟，名鲜) |
| u8521-u53d4 (蔡叔) | u8521-u53d4-u5ea6 (蔡叔度) | Same person (周公弟，名度) |

Tracked as **T-P1-021** (canonical merge missed pairs). Not in Sprint scope.

Note: 管叔 also collides with 管仲 (guan-zhong) — different historical person, not a merge candidate.

---

## ADR References

- **ADR-022** (af7581d): NER pollution cleanup vs names-stay — three-criteria test blocked hard DELETE
- **ADR-023** (2dd53c9): V8 prefix-containment invariant — evidence + alias exemptions

---

## Debt Resolution

- **F2** (prefix-containment residuals): **RESOLVED** via V8 rule refinement (not DELETE)
- **T-P1-021** (canonical merge missed pairs): **REGISTERED** as side finding
