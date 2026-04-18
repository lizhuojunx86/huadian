# T-P1-001 — Turbo monorepo test isolation for API integration tests

> **RESOLVED 2026-04-19** — Fixed by scoping assertions to own fixtures and probing actual DB total; root cause was global-count assumption + field mismatch (updatedAt vs createdAt). Commit `be4f59b`.

## Symptom

- `pnpm --filter @huadian/api test` → 45/45 pass (isolated run)
- `pnpm test` (turbo full monorepo) → 43/45 pass, 2 fixed failures:
  1. `person-search.integration.test.ts` > "returns hasMore=false when at the end"
  2. `person.integration.test.ts` > "returns persons ordered by created_at desc"

## Impact

- Does **not** affect code correctness — all business logic assertions pass
- Only affects CI signal stability — 2 case-level failures make CI red

## Root Cause (not yet confirmed)

Suspected: turbo runs all packages' test suites, and the execution order or
concurrency causes fixture data from one test file to leak into another's
assertions. The two failing cases assume the database contains **only** their
own fixtures, but cross-file fixture residue inflates counts (hasMore) and
disrupts ordering expectations.

Possible contributing factors:
- vitest runs all test files in the same process; `beforeAll`/`afterAll`
  cleanup timing may overlap
- Turbo's parallel execution model may start a new test file before the
  previous one's `afterAll` cleanup completes

## Temporary Fix

2 cases marked `it.skip(...)` with `[T-P1-001]` tag (W-8, 2026-04-18).

## Repair Candidates

1. **vitest.config: force sequential** — `pool: 'forks'` + `poolOptions.forks.singleFork: true`
2. **Fixture prefix isolation** — each test file uses a non-overlapping slug/name prefix and filters only its own data
3. **Per-suite schema isolation** — each test file creates/drops its own PG schema (`CREATE SCHEMA test_xxx`)
4. **Transaction rollback** — wrap each test file in a transaction and rollback in `afterAll`

Option 2 is the lowest-risk fix; option 4 is the most robust.

## Timeline

- **Created**: 2026-04-18, derived from W-8 (CI database migration fix)
- **Priority**: P1 (medium) — CI is green with `.skip`, no data risk
- **Owner**: unassigned
