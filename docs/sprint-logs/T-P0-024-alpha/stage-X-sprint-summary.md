# T-P0-024 Alpha — Sprint Summary

- **Sprint**: T-P0-024 α — 历史章节证据链回填
- **Duration**: 2026-04-20 ~ 2026-04-21
- **Operator**: Pipeline Engineer (Claude Opus) + Chief Architect (user)
- **LLM cost**: $0.78 total (budget $2.00, 61% remaining)

---

## Goal vs Achievement

| Goal | Target | Actual | Status |
|------|--------|--------|--------|
| V7 evidence coverage | 80% hard / 90% stretch | **96.37%** | ✅✅ |
| V1-V5 no regression | 0 violations | 0 / 0 / 0 / 0 / 0 | ✅ |
| V6 no new violations | ≤28 | 28 | ✅ |
| Zero new persons/names | constraint E | 0 created | ✅ |
| Zero fail-loud events | 0 | 0 | ✅ |
| LLM cost within budget | ≤$2.00 | $0.78 | ✅ |

---

## Decision Tree Retrospective

### Path Selection: A / B / C

- **Stage 0a** discovered β has cached llm_calls (27§) but Phase A/B has none (99§)
- **Path A** (hash reuse): viable for β only → V7 ~58%, insufficient
- **Path B** (re-extract): needed for Phase A/B → requires LLM budget
- **Path C** (hybrid): A for β + B for Phase A/B → selected by architect

### Fast Lane Discovery

- Stage 2b Step 5 revealed: reextract dry-run writes to llm_calls audit table
- Q1-Q3 fast lane check: SHA-256 hashes align perfectly
- **Decision**: execute phase uses `--mode backfill` (hash reuse), not `--mode reextract`
- **Result**: $0 new LLM cost for C2 execute — fast lane fully validated

### AMBIGUOUS_SLUGS Audit Net

- Stage 2b Step 1 pre-check found 6 ambiguous names in DB
- Analysis: 3 safe (pronoun blacklist), 1 safe (α-only), 2 potentially reachable
- **Solution**: AMBIGUOUS_SLUGS constant + three-state name-fallback + fail-loud
- **Result**: 21 audit events, 100% dry-run/execute match, 0 false positives

---

## Surprises and Handling

| Surprise | Impact | Resolution |
|----------|--------|------------|
| Sprint name wrong (T-P0-019 → T-P0-024) | Naming only | Architect corrected at Stage 0a |
| V7 stop threshold set at 60.38% (based on biased dry-run) | C1 execute appeared to fail | Accepted as β ceiling; bias explained |
| 8 duplicate llm_calls (3 probe + 5 α narrow smoke) | R1 would fail-loud on 3 | DELETE 3 probe duplicates (architect-approved red-line op) |
| asyncpg returns JSONB as str not dict | Script crashed on first run | Fixed with json.loads() fallback |
| xia §33 dense succession list (12 kings in 1 paragraph) | 7 no_match (short names) | Accepted; registered T-P1-015 |

---

## Methodology Contributions

This Sprint introduced and validated several reusable patterns:

1. **Three-state name fallback**: slug-first → person_names.name → fail-loud (≥2)
2. **AMBIGUOUS_SLUGS audit net**: static whitelist + structured warning log
3. **Fast lane pattern**: dry-run writes llm_calls → execute reads via hash → zero-cost replay
4. **Dry-run vs execute precision calibration**: first-write-wins ratio tracked (C1: 68%, C2: 59%)
5. **4-gate protocol** for destructive DB operations (pg_dump → schema → cache → dry-run RETURNING)

---

## Legacy for Next Sprint

### 10 P1 Debts Registered

T-P1-011 through T-P1-020 (see `docs/tasks/` for full cards).

Key themes:
- **Data quality**: T-P1-011 (merged-alias evidence), T-P1-013 (V6 cleanup), T-P1-015 (短名夏王), T-P1-016 (微子)
- **Infrastructure**: T-P1-012 (dry-run model), T-P1-014 (wu-wang merge), T-P1-017 (SE 多源)
- **Automation**: T-P1-018 (auto-trigger), T-P1-019 (AMBIGUOUS DB migration), T-P1-020 (shared module)

### V7 Ceiling Analysis

Current: 505/524 = 96.37%. Theoretical max: 520/524 = 99.24% (4 pronoun permanently excluded).
Gap: 15 names (7 short-name kings + 2 微子 + 6 misc) — closable via T-P1-015/T-P1-016 if desired.
