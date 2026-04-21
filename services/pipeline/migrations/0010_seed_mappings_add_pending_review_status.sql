-- Migration 0010: Extend seed_mappings.mapping_status CHECK
-- ADR: ADR-021 §2.2 / T-P0-025 Stage 2
-- Purpose: Add 'pending_review' status for multi-hit candidates
--          awaiting manual review/triage.
-- Rollback: see 0010_rollback.sql

BEGIN;

ALTER TABLE seed_mappings
  DROP CONSTRAINT IF EXISTS seed_mappings_mapping_status_check;

ALTER TABLE seed_mappings
  ADD CONSTRAINT seed_mappings_mapping_status_check
  CHECK (mapping_status IN ('active', 'superseded', 'rejected', 'pending_review'));

COMMENT ON COLUMN seed_mappings.mapping_status IS
  'Lifecycle status: pending_review (multi-hit awaiting manual triage) / '
  'active (bound as authoritative seed) / superseded (replaced by newer mapping) / '
  'rejected (explicitly rejected by reviewer).';

COMMIT;
