-- Migration 0011: Align seed table UNIQUE constraint names with Drizzle schema
-- ADR: T-P1-023 / Sprint B Stage 5
-- Purpose: Rename PG auto-generated *_key constraints to match
--          Drizzle uniqueIndex uq_* names in packages/db-schema/src/schema/seeds.ts

BEGIN;

-- dictionary_sources
ALTER TABLE dictionary_sources
  DROP CONSTRAINT IF EXISTS dictionary_sources_source_name_source_version_key;
ALTER TABLE dictionary_sources
  ADD CONSTRAINT uq_dictionary_sources_name_version
  UNIQUE (source_name, source_version);

-- dictionary_entries
ALTER TABLE dictionary_entries
  DROP CONSTRAINT IF EXISTS dictionary_entries_source_id_external_id_key;
ALTER TABLE dictionary_entries
  ADD CONSTRAINT uq_dictionary_entries_source_external
  UNIQUE (source_id, external_id);

-- seed_mappings
ALTER TABLE seed_mappings
  DROP CONSTRAINT IF EXISTS seed_mappings_dictionary_entry_id_target_entity_type_target_key;
ALTER TABLE seed_mappings
  ADD CONSTRAINT uq_seed_mappings_entry_target_status
  UNIQUE (dictionary_entry_id, target_entity_type, target_entity_id, mapping_status);

COMMIT;
