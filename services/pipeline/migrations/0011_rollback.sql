-- Rollback for migration 0011 (unique index naming alignment)
-- Restores PG auto-named constraints

BEGIN;

ALTER TABLE dictionary_sources
  DROP CONSTRAINT IF EXISTS uq_dictionary_sources_name_version;
ALTER TABLE dictionary_sources
  ADD UNIQUE (source_name, source_version);

ALTER TABLE dictionary_entries
  DROP CONSTRAINT IF EXISTS uq_dictionary_entries_source_external;
ALTER TABLE dictionary_entries
  ADD UNIQUE (source_id, external_id);

ALTER TABLE seed_mappings
  DROP CONSTRAINT IF EXISTS uq_seed_mappings_entry_target_status;
ALTER TABLE seed_mappings
  ADD UNIQUE (dictionary_entry_id, target_entity_type, target_entity_id, mapping_status);

COMMIT;
