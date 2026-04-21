-- Migration 0009: Dictionary seed schema (3 tables)
-- T-P0-025 Stage 0b / ADR-021 §2.5
-- DDL source: docs/research/T-P0-026-dictionary-seed-feasibility.md §5.2
--
-- Three tables:
--   dictionary_sources  — external dictionary registry
--   dictionary_entries  — raw external entity records
--   seed_mappings       — entry → HuaDian entity mapping (revocable)

BEGIN;

-- ============================================================
-- 1. dictionary_sources
-- ============================================================

CREATE TABLE IF NOT EXISTS dictionary_sources (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_name         TEXT NOT NULL,                        -- 'wikidata', 'cbdb', 'self-curated'
  source_version      TEXT NOT NULL,                        -- '20260421' / 'v0.1.0'
  license             TEXT NOT NULL,                        -- 'CC0', 'CC-BY-NC-SA-4.0', 'project-owned'
  commercial_safe     BOOLEAN NOT NULL,                     -- gate for production ingestion
  access_url          TEXT,                                 -- SPARQL endpoint / SQLite path / internal path
  ingested_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  notes               JSONB,
  UNIQUE (source_name, source_version)
);

-- ============================================================
-- 2. dictionary_entries
-- ============================================================

CREATE TABLE IF NOT EXISTS dictionary_entries (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_id           UUID NOT NULL REFERENCES dictionary_sources(id),
  external_id         TEXT NOT NULL,                        -- Q-number / CBDB ID / self-ref
  entry_type          TEXT NOT NULL,                        -- 'person', 'place', 'polity', 'reign_era', 'office'
  primary_name        TEXT,                                 -- recommended zh display name
  aliases             JSONB,                                -- [{name, language, source_note}]
  attributes          JSONB NOT NULL DEFAULT '{}'::jsonb,   -- source fields preserved as-is
  ingested_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (source_id, external_id),
  CHECK (entry_type IN ('person', 'place', 'polity', 'reign_era', 'office'))
);

CREATE INDEX IF NOT EXISTS idx_dictionary_entries_source
  ON dictionary_entries (source_id);

CREATE INDEX IF NOT EXISTS idx_dictionary_entries_primary_name
  ON dictionary_entries (primary_name);

-- ============================================================
-- 3. seed_mappings
-- ============================================================

CREATE TABLE IF NOT EXISTS seed_mappings (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dictionary_entry_id     UUID NOT NULL REFERENCES dictionary_entries(id),
  target_entity_type      TEXT NOT NULL,                    -- 'person', 'place', ...
  target_entity_id        UUID NOT NULL,                    -- persons.id / places.id / ... (polymorphic, no FK)
  confidence              NUMERIC(3,2),                     -- 0.00 - 1.00
  mapping_method          TEXT NOT NULL,                    -- 'exact_name' / 'manual_review' / 'llm_hinted'
  mapping_created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  mapping_status          TEXT NOT NULL DEFAULT 'active',   -- 'active' / 'superseded' / 'rejected'
  notes                   JSONB,
  UNIQUE (dictionary_entry_id, target_entity_type, target_entity_id, mapping_status),
  CHECK (confidence >= 0.00 AND confidence <= 1.00),
  CHECK (mapping_status IN ('active', 'superseded', 'rejected'))
);

CREATE INDEX IF NOT EXISTS idx_seed_mappings_target
  ON seed_mappings (target_entity_type, target_entity_id)
  WHERE mapping_status = 'active';

COMMIT;
