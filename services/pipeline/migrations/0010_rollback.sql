-- Rollback for migration 0010 (seed_mappings pending_review status)
-- ADR-017: forward-only + pg_dump anchor + guard

BEGIN;

-- Guard: refuse to downgrade if pending_review rows exist
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM seed_mappings WHERE mapping_status = 'pending_review') THEN
    RAISE EXCEPTION 'Cannot rollback: % rows have mapping_status=pending_review. Triage first.',
      (SELECT count(*) FROM seed_mappings WHERE mapping_status = 'pending_review');
  END IF;
END $$;

ALTER TABLE seed_mappings
  DROP CONSTRAINT IF EXISTS seed_mappings_mapping_status_check;

ALTER TABLE seed_mappings
  ADD CONSTRAINT seed_mappings_mapping_status_check
  CHECK (mapping_status IN ('active', 'superseded', 'rejected'));

COMMIT;
