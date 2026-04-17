-- T-TG-002 S-7: audit sink prerequisites
--
-- 1. Add `traceguard_raw` JSONB to extractions_history so the Adapter can
--    store the full GuardianDecision + CheckpointResult per extraction.
-- 2. Add a unique index on (paragraph_id, step, prompt_version) to enable
--    idempotent ON CONFLICT DO UPDATE upserts.
--
-- These changes are additive and safe to run on a populated table.
-- They complement the initial Drizzle migration (0000_lame_roughhouse.sql).
--
-- TODO(backend): mirror these in the Drizzle schema
--   packages/db-schema/src/schema/pipeline.ts → extractionsHistory table
--   then run `pnpm drizzle-kit generate` to keep the TS migration in sync.

-- 1. New column
ALTER TABLE extractions_history
  ADD COLUMN IF NOT EXISTS traceguard_raw JSONB;

-- 2. Idempotent upsert index
CREATE UNIQUE INDEX IF NOT EXISTS idx_ext_hist_idempotent
  ON extractions_history (paragraph_id, step, prompt_version);
