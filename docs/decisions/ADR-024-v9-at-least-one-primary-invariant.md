# ADR-024 — V9 Invariant: At-Least-One-Primary Lower-Bound Check

- **Status**: Accepted
- **Date**: 2026-04-25
- **Authors**: 首席架构师（决策 + brief）+ 管线工程师（执行 + V9 SQL + self-test）
- **Related**:
  - T-P1-022（V1 下界缺失 debt — 本 ADR 的发现来源）
  - Sprint F Stage 0 root cause diagnosis（v1-root-cause-2026-04-25.md）
  - Sprint F Stage 1 load.py fix（acc9451）
  - ADR-023（V8 Prefix-Containment — 同级 invariant 引入前例）
  - ADR-022（NER 污染清理准则 — 互补哲学）

---

## 1. Context

### 1.1 Trigger

T-P0-025 Gate 0a (Sprint B, 2026-04-21) probe discovered 27 active persons with 0 `is_primary=true` names. Sprint E 秦本纪 ingest grew this to 94 name_type violations + 33 is_primary violations (124 unique persons).

Sprint F Stage 0 root cause analysis confirmed:
- **100% of violations originated in `load.py _insert_person_names`**
- Bug 1: `name_zh` defaulted to `name_type='primary'` when absent from surface_forms (92 MULTI_NAMETYPE)
- Bug 2: surface_forms loop hardcoded `is_primary=false` (33 TYPE_A/B)

Stage 1 fixed both bugs. Stage 2 backfilled all 125 affected rows to V1=0.

### 1.2 Gap in Invariant Coverage

V1 ("single-primary") enforces `COUNT(is_primary=true) <= 1` — the **upper bound**. No invariant enforces `>= 1` — the **lower bound**. The fixed load.py includes a runtime guard (`RuntimeError` if `primary_count != 1`), but this only protects the ingest path. Ad-hoc SQL fixups, migration errors, or future code paths could silently break the lower bound without detection.

---

## 2. Decision

### 2.1 New V9 Invariant (Same Tier as V1-V8)

**V9 definition**: "Every active person must have at least one `person_names` row with `is_primary = true`."

**SQL**:

```sql
SELECT p.id, p.slug
FROM persons p
WHERE p.deleted_at IS NULL
  AND p.merged_into_id IS NULL
  AND NOT EXISTS (
    SELECT 1 FROM person_names pn
    WHERE pn.person_id = p.id AND pn.is_primary = true
  );
```

### 2.2 Design: Single-Responsibility

- **V1**: upper bound (`<= 1 primary`) — no more than one primary per person
- **V9**: lower bound (`>= 1 primary`) — at least one primary per person
- Combined, V1 + V9 enforce `COUNT(is_primary=true) = 1` for every active person

Splitting into two invariants follows the project's existing philosophy (V10a/V10b/V10c are also single-responsibility sub-checks).

### 2.3 Execution

- **Same tier as V1-V8**: runs on every commit/ingest, not sample-based
- **Error level**: hard assert (not warning like V7's initial rollout)
- **Bootstrap**: V9 = 0 violations on the day of introduction (Stage 2 backfill already cleared all violations)
- **Self-test mandatory**: 3 tests to prevent "silent V9" (same pattern as ADR-023 V8)

---

## 3. Rationale

### 3.1 Why not extend V1 to cover both bounds

V1's SQL and test fixtures have been stable since project inception. Changing its semantics from `> 1` to `!= 1` would break existing test assertions and mental models. A separate invariant is cleaner.

### 3.2 Why error-level, not warning

V7 launched as warning-level because legacy data had legitimate gaps (pre-ADR-015 rows without evidence). V9 has no such legacy gap — Stage 2 backfill eliminated all violations before V9 introduction. Bootstrap = 0 is the gold standard.

### 3.3 Why needed despite the load.py runtime guard

The load.py guard (S1.3) catches violations during `_insert_person_names` only. V9 catches violations from any source: ad-hoc SQL, migration scripts, future code paths, or manual DB edits. Defense in depth.

---

## 4. Consequences

### 4.1 Positive

- Complete primary-name coverage: V1 + V9 = exactly-one-primary invariant
- Future regressions from any write path are caught at commit time
- Sprint F root cause fix verified: V9 bootstrap = 0 proves Stage 1+2 completeness

### 4.2 Negative / Accepted

- Invariant suite grows from V1-V8 to V1-V9 (CI/docs/migration scope +1)
- V9 SQL adds one subquery per active person; negligible at Phase 0-1 scale

### 4.3 Rollback

- Remove V9 from invariant suite if ever proven over-sensitive
- V1 upper-bound coverage unaffected

---

## 5. Applied Examples

### 5.1 Sprint F Stage 2 (First Application)

- **Pre-fix**: 33 active persons had 0 `is_primary=true` names
- **Post-fix (Stage 2 backfill)**: 0 violations
- **V9 bootstrap**: 0 (gold standard)

---

## 6. Known Follow-ups

- None. V9 is a terminal invariant — no planned extensions or Phase 2 evolution.
