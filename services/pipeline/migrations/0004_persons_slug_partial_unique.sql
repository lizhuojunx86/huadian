-- ADR-013: persons.slug partial unique (exclude soft-deleted)
-- Rationale: T-P0-011 soft-merge leaves deleted rows occupying slug namespace,
--            blocking new candidates from T-P0-006-β 尚书 ingest.
-- Idempotent: safe to re-apply.

BEGIN;

-- Drop legacy full-table unique constraint (Drizzle-generated)
ALTER TABLE persons DROP CONSTRAINT IF EXISTS persons_slug_unique;

-- Drop legacy full-table unique index (if recreated as index)
DROP INDEX IF EXISTS persons_slug_unique;

-- Recreate as partial unique, excluding soft-deleted rows
CREATE UNIQUE INDEX IF NOT EXISTS persons_slug_unique
  ON persons (slug)
  WHERE deleted_at IS NULL;

COMMIT;
