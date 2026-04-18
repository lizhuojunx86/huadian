-- Migration: 0002_add_identity_merge_support
-- Task: T-P0-011 Cross-chunk identity resolution
-- Date: 2026-04-18
-- ADR: ADR-010
--
-- NOTE: The persons.merged_into_id column is managed by the API-side
-- Drizzle migration (0002_stale_impossible_man.sql). This pipeline
-- migration only creates:
--   1. Partial index on persons.merged_into_id (Drizzle doesn't support)
--   2. person_merge_log table (pipeline-only, not in Drizzle schema)
--
-- Rollback:
--   DROP INDEX IF EXISTS idx_persons_merged_into;
--   DROP TABLE IF EXISTS person_merge_log;

-- 1. Partial index on persons.merged_into_id for fast canonical lookups
CREATE INDEX IF NOT EXISTS idx_persons_merged_into
  ON persons(merged_into_id)
  WHERE merged_into_id IS NOT NULL;

-- 2. Create person_merge_log table (audit trail, pipeline-only)
CREATE TABLE IF NOT EXISTS person_merge_log (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  run_id        UUID NOT NULL,
  canonical_id  UUID NOT NULL REFERENCES persons(id),
  merged_id     UUID NOT NULL REFERENCES persons(id),
  merge_rule    TEXT NOT NULL,
  confidence    REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
  evidence      JSONB,
  merged_by     TEXT NOT NULL DEFAULT 'pipeline',
  merged_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  reverted_at   TIMESTAMPTZ,
  reverted_by   TEXT
);

CREATE INDEX IF NOT EXISTS idx_merge_log_canonical ON person_merge_log(canonical_id);
CREATE INDEX IF NOT EXISTS idx_merge_log_merged ON person_merge_log(merged_id);
CREATE INDEX IF NOT EXISTS idx_merge_log_run ON person_merge_log(run_id);
