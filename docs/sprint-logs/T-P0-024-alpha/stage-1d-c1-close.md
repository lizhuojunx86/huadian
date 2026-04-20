# T-P0-024 Alpha — Stage 1d: C1 (Beta Path A) Close

- **Executed**: 2026-04-20T23:03+08:00
- **Operator**: Pipeline Engineer (Claude Opus)
- **Architect ACK**: Gate 3 explicit "执行" + Gate 4 ACCEPT

---

## Gate Summary

| Gate | Status | Key Data |
|------|--------|----------|
| 0 — pg_dump | ✅ | `ops/rollback/pre-t-p0-024-alpha-stage-1c-20260420-230358.dump` (253 KB, sha256: `a2673a99`) |
| 1 — pre-state | ✅ | V7=275/524=52.48%, SE=242, β names=5/47/52, β persons=19 |
| 2 — dry-run diff | ✅ | names_to_link=44, se_to_create=37, no_match=3, v7_proj=60.88% — all match 1b |
| 3 — irreversibility | ✅ | Acknowledged: UPDATE NULL→UUID not SQL-reversible, pg_restore only |
| 4 — execute | ✅ | names_linked=30, se_created=24, errors=0, V7=58.21% |

---

## Execution Result

```
Command: uv run python scripts/backfill_evidence.py --book shangshu-yao-dian shangshu-shun-dian --execute

shangshu-yao-dian:  7 §, 13 persons, 15 names linked, 1 skip, 0 no_match
shangshu-shun-dian: 20 §, 27 persons, 15 names linked, 12 skip, 3 no_match
Total: 30 names linked, 24 SE created, 3 no_match, 0 errors
```

---

## V1-V7 Invariant Matrix (Post-Execution)

| # | Invariant | Result | Notes |
|---|-----------|--------|-------|
| V1 | single is_primary per active person | ✅ 0 violations | |
| V2 | name completeness | ✅ 0 violations | |
| V3 | FK completeness | ✅ 0 violations | |
| V4 | Model-B leakage | ✅ 0 violations | |
| V5 | active-but-merged | ✅ 0 violations | |
| V6 | alias+is_primary=true | ⚠️ 28 pre-existing | All `source_evidence_id=NULL`; not introduced by this backfill; nickname(22)+posthumous(5)+temple(1) from Phase A/B era |
| V7 | evidence coverage | ✅ **305/524 = 58.21%** | +30 from 52.48% |

---

## Post-State Snapshot (vs Pre-State)

| # | Metric | Pre | Post | Delta |
|---|--------|-----|------|-------|
| 1 | V7 | 275/524 = 52.48% | 305/524 = 58.21% | **+30 names** |
| 2 | source_evidences total | 242 | 266 | **+24 rows** |
| 3 | β person_names (with/without/total) | 5/47/52 | 25/27/52 | +20 SE links |
| 4 | β active persons | 19 | 19 | unchanged |

---

## Dry-Run vs Actual Deviation Analysis

| Metric | Dry-Run | Actual | Gap | Root Cause |
|--------|---------|--------|-----|-----------|
| names_to_link | 44 | 30 | -14 | First-write-wins across multi-paragraph |
| se_to_create | 37 | 24 | -13 | Same person in multiple § → only 1 SE created for first § |
| V7 projection | 60.88% | 58.21% | -2.67pp | Same |

**Root cause**: dry-run does not execute writes, so `find_uncovered_names()` returns the same uncovered names for every paragraph a person appears in. In real execution, once yao-dian §1 covers 尧's 3 names, shun-dian §2 sees them as already covered → skip.

**Lesson**: dry-run prediction model has systematic positive bias proportional to person-paragraph overlap. Could be fixed by maintaining an in-memory "already covered" set during dry-run (T-P1-012).

---

## no_match Details (R4)

| Surface | Slug | Paragraph | Book | Reason |
|---------|------|-----------|------|--------|
| 弃 | u5f03 | §9 | shangshu-shun-dian | Merged into 后稷 (β identity resolution) |
| 弃 | u5f03 | §10 | shangshu-shun-dian | Same as above |
| 垂 | u5782 | §13 | shangshu-shun-dian | Merged into 倕 (tongjia R3 cross-book) |

All 3 are expected: these persons were soft-deleted via apply_merges during T-P0-006-β S-5. The NER correctly identified them, but their active person records no longer exist (merged into canonical forms).

---

## Derived Debt (to be collected in Sprint 5)

| ID | Description | Priority |
|----|-------------|----------|
| T-P1-011 | Merged-alias evidence backfill (弃→后稷, 垂→倕bury evidence chain for merged names) | P2 |
| T-P1-012 | Dry-run prediction model fix (track "already-covered" set in-memory) | P3 |
| T-P1-013 | V6 28 violations audit + fix (alias+is_primary=true from Phase A/B era) | P2 |

---

## Conclusion

Beta Path A (C1) complete. Mechanism validated:
- SHA-256 input_hash matching: 27/27 β paragraphs → llm_calls ✅
- source_evidence INSERT + person_names UPDATE: 24 SE + 30 name links ✅
- R1-R4 all exercised in production ✅
- V7 reached β ceiling (58.21%), monotonically up from 52.48% ✅
- Zero new persons/names created (constraint E honored) ✅
- Fully reversible via pg_dump anchor ✅

Next: C2 (Phase A/B Path B re-extract, 99 paragraphs, target V7 80%+).
