# T-P0-025 Stage 2 — Execute Report

> **Date**: 2026-04-22
> **Elapsed**: 143s (matching) + ~1s (DB writes)
> **HTTP errors**: 0

---

## 1. Matching Summary (vs dry-run)

| Metric | Dry-run | Execute | Delta |
|--------|---------|---------|-------|
| R1 single | 149 | 149 | 0 |
| R1 multi | 8 | 8 | 0 |
| R2 alias | 4 | 4 | 0 |
| R2 multi | 7 | 7 | 0 |
| R3 scan | 6 | 6 | 0 |
| R3 multi | 1 | 1 | 0 |
| No match | 145 | 145 | 0 |
| **Hit rate** | 49.7% | 49.7% | 0 |

Dry-run ↔ execute: **0 divergence**. Deterministic.

## 2. DB Write Summary

| Table | Rows | Notes |
|-------|------|-------|
| dictionary_sources | 1 | `wikidata / 20260422 / CC0 / commercial_safe=true` |
| dictionary_entries | 201 | 159 unique persons + multi-hit candidate Q entries |
| seed_mappings (active) | **159** | R1=149 + R2=4 + R3=6 |
| seed_mappings (pending_review) | **44** | R1-multi=8 persons (~17 rows) + R2-multi=7 (~25 rows) + R3-multi=1 (~3 rows) |
| seed_mappings (total) | 203 | 159 active + 44 pending |
| source_evidences (seed_dictionary) | **159** | = active mappings count |
| books (pseudo) | 1 | `slug=wikidata-dump-20260422 / genre=encyclopedia / license=CC0` |
| raw_texts (pseudo) | 1 | Anchors source_evidences |

## 3. Invariant Verification

| Invariant | Result |
|-----------|--------|
| V1 single-primary | 0 ✅ |
| V2 name completeness | 0 ✅ |
| V3 FK integrity | 0 ✅ |
| V4 model-B leakage | 0 ✅ |
| V5 active definition | 0 ✅ |
| V6 alias≠is_primary | 0 ✅ |
| V7 evidence coverage | **97.49%** ✅ (unchanged) |
| V8 prefix-containment | 0 ✅ |
| V10 seed_mapping orphan | **0** ✅ |

**V7 unchanged**: Seed evidence rows go into `source_evidences` table, not into `person_names.source_evidence_id`. V7 measures person_names coverage — seed evidence is a parallel layer, confirming the architect's prediction.

## 4. Confidence Distribution

| mapping_method | confidence | count |
|---------------|-----------|-------|
| r1_exact | 1.00 | 149 |
| r2_alias | 0.85 | 4 |
| r3_name_scan | 0.70 | 6 |
| (pending_review) | 0.00 | 44 |

## 5. Pipeline Tests

302 passed, 0 failed. No regression.
