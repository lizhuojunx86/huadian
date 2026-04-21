# T-P0-019 α Stage 2 — F1 Pronoun Hard DELETE

> **Sprint**: T-P0-019 α (β tail cleanup)
> **Stage**: 2 of 3
> **Date**: 2026-04-21
> **Role**: Pipeline Engineer (execute) + Chief Architect (Gate ACK + ruling)

---

## Summary

Hard-deleted 6 NER-polluted pronoun/title-only rows from `person_names`.

- 帝 (shun), 帝 (yao), 王 (tang), 王 (wu-ding), 朕 (tang), 予一人 (tang)
- All had: `is_primary=false`, `source_evidence_id=NULL`, 0 FK back-references
- V7 96.37% → **97.49%** (+1.12pp, mechanical — see note below)

---

## Architect Ruling: Hard DELETE vs Soft-Delete

**Decision**: Plan A (hard DELETE). Rationale:

1. **NER pollution ≠ ADR-014 names-stay**. The names-stay principle protects legitimate name variants (private name / courtesy / posthumous / temple / etc.). Pronouns (朕, 予一人) and bare title characters (帝, 王) are not person names — they are NER classification errors. Soft-deleting them would pollute read-side aggregation logic (requiring an additional "filter out garbage" layer).

2. **Three-element test for NER pollution cleanup**:
   - ✅ No evidence back-chain (`source_evidence_id = NULL`)
   - ✅ No legitimate person-name semantics (pronouns / self-references / bare honorific characters)
   - ✅ No FK downstream dependencies (0 tables reference `person_names` per `information_schema.table_constraints`)

3. **Plan B (add `deleted_at` column) disproportionate cost**: Requires schema migration + query-wide `WHERE deleted_at IS NULL` filter + ADR-013 partial UNIQUE semantics update + test coverage + GraphQL layer filter. This is an independent "person_names soft-delete strategy" decision deserving its own ADR — not warranted by 6 garbage rows.

4. **Recovery path**: pg_dump anchor + `stage2-pre.json` 6-row snapshot sufficient for forensic reconstruction.

**Precedent**: This ruling establishes the three-element test for future NER pollution cleanups. To be formalized in ADR-022 (planned post-Sprint).

---

## V7 Mechanical Uplift Note

V7 changed from 96.37% (505/524) → 97.49% (505/518).

**This is NOT an extraction improvement.** The numerator (505 names with evidence) is unchanged. The denominator shrank by 6 because we removed 6 rows that had `source_evidence_id = NULL` and were never eligible for evidence coverage. The V7 metric is now semantically cleaner — it measures coverage of actual person names, not NER garbage.

---

## Gate 0 — pg_dump Anchor

```
File: /tmp/before-T-P0-019-stage2.dump
Format: custom (-Fc)
SHA-256: f32964f4d2822ac0ba8d0020a4739c8687aea4bc6b8c08a9d0b1ddea718f0417
```

## Gate 0b — Dependency Audit

| name | person_slug | is_primary | sibling_names | other_primary | source_evidence_id |
|------|-------------|------------|---------------|---------------|-------------------|
| 帝 | shun | false ✅ | 7 ✅ | 1 ✅ | NULL ✅ |
| 帝 | yao | false ✅ | 5 ✅ | 1 ✅ | NULL ✅ |
| 王 | tang | false ✅ | 5 ✅ | 1 ✅ | NULL ✅ |
| 王 | wu-ding | false ✅ | 3 ✅ | 1 ✅ | NULL ✅ |
| 朕 | tang | false ✅ | 5 ✅ | 1 ✅ | NULL ✅ |
| 予一人 | tang | false ✅ | 5 ✅ | 1 ✅ | NULL ✅ |

All three release conditions met:
1. None are `is_primary=true`
2. Each person has ≥3 sibling names
3. `evidence_backlinks = 0` (all `source_evidence_id = NULL`)

## Gate 0c — FK Audit (Extended Scope)

```sql
SELECT ... FROM information_schema.table_constraints ...
WHERE ccu.table_name = 'person_names';
-- Result: 0 rows
```

Tables checked for person-related FKs:
- `source_evidences` — no FK to person_names (relationship is reverse: person_names → source_evidences)
- `identity_hypotheses` — FK to `persons` only (canonical_person_id, hypothesis_person_id)
- `relationships` — FK to `persons` only (person_a_id, person_b_id)
- `mentions` — no person-related FK
- `events` — no person-related FK
- `person_relationships` / `event_participants` / `identity_candidates` — tables do not exist

**Conclusion**: 0 tables reference `person_names` via FK. DELETE has zero cascade risk.

## Gate 1 — Pre-State Snapshot

File: `docs/tasks/T-P0-019/stage2-pre.json` (6 rows, 1167 bytes)

## Gate 2 — Dry-Run

```
BEGIN;
DELETE 6;
F1 remaining = 0
V1=0, V2=0, V3=0, V4=0, V5=0, V6=0
V7 = 97.49% (505/518)
ROLLBACK;
```

## Gate 3 — Irreversibility Declaration

**Hard DELETE, recovery via pg_dump anchor only.** 6 NER-polluted rows permanently removed. Architect ruling: NER pollution cleanup (three-element test satisfied) does not fall under ADR-014 names-stay protection. pg_dump SHA-256 `f32964f4...` + `stage2-pre.json` provide full forensic trail.

## Gate 4 — Execute + V1-V7

### SQL Executed

```sql
BEGIN;

DELETE FROM person_names WHERE id IN (
  '16fff91e-d78b-4327-a028-d02c65bc7fc3',  -- shun 帝 (nickname)
  '34bde727-66e5-4d23-a1b1-d309e19cc06d',  -- yao 帝 (nickname)
  'cd98d890-51ac-4d98-8ca6-38fb87a635b7',  -- tang 王 (nickname)
  '77af3b31-a408-4ea6-88ea-39b4623f95eb',  -- wu-ding 王 (nickname)
  'acb1d71f-5314-43dd-9339-c458a36e5248',  -- tang 朕 (self_ref)
  '0da61057-d0ed-4a8f-9808-a18b924ee25d'   -- tang 予一人 (self_ref)
);

-- V1-V7 all passed → COMMIT;
```

### V1-V7 Post-Execute Results

| Invariant | Result | Notes |
|-----------|--------|-------|
| F1 pronoun residuals | **0** ✅ | 6 → 0 |
| V1 single-primary | **0** ✅ | No regression |
| V2 name completeness | **0** ✅ | No regression |
| V3 FK integrity | **0** ✅ | No regression |
| V4 model-B leakage | **0** ✅ | No regression |
| V5 active definition | **0** ✅ | No regression |
| V6 alias≠is_primary | **0** ✅ | Stable (Stage 1 fix holds) |
| V7 evidence coverage | **97.49%** ✅ | 96.37% → 97.49% (+1.12pp mechanical) |

### Post-State Snapshot

File: `docs/tasks/T-P0-019/stage2-post.json` — 4 affected persons with remaining names:

| slug | total_names | primary_count | remaining names |
|------|-------------|---------------|-----------------|
| shun | 7 | 1 | 舜(primary), 帝舜, 帝舜之后, 有虞, 虞帝, 虞舜, 重华 |
| tang | 3 | 1 | 汤(primary), 成汤, 武王 |
| wu-ding | 3 | 1 | 武丁(primary), 帝武丁, 高宗 |
| yao | 5 | 1 | 尧(primary), 帝尧, 帝尧之后, 放勋, 陶唐 |

---

## Debt Resolution

- **F1** (pronoun pollution): **RESOLVED** by this stage.
