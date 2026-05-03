-- ============================================================
-- Sprint T T-V03-FW-005 — framework dogfood schema (minimum subset)
-- ============================================================
--
-- Run by docker-entrypoint-initdb.d on first container init.
--
-- Scope (per Sprint T brief §1.3 Approach B):
--   Only the ~7 tables that framework dogfood scripts touch.
--   The full 36+ table production schema is NOT replicated.
--
-- Tables created:
--   1. persons
--   2. person_names
--   3. dictionary_sources
--   4. dictionary_entries
--   5. seed_mappings
--   6. pending_merge_reviews
--   7. triage_decisions
--
-- Production schema in:
--   services/api/migrations/0000_lame_roughhouse.sql        (36 tables baseline)
--   services/pipeline/migrations/0001..0014                  (14 incremental)
--
-- Sync responsibility (per .pre-commit-config.yaml hook
-- services-framework-audit-triage-sync):
--   When production schema changes, review whether this file needs
--   matching update.
--
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- Required PG extensions
-- ────────────────────────────────────────────────────────────

CREATE EXTENSION IF NOT EXISTS pgcrypto;  -- for gen_random_uuid()

-- ────────────────────────────────────────────────────────────
-- 1. persons
-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS persons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT,
    name JSONB,                                 -- e.g., {"zh-Hans":"周成王"}
    merged_into_id UUID,                        -- NULL = canonical
    deleted_at TIMESTAMPTZ,                     -- NULL = active
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_persons_slug ON persons(slug);
CREATE INDEX IF NOT EXISTS idx_persons_active
    ON persons(id) WHERE merged_into_id IS NULL AND deleted_at IS NULL;

-- ────────────────────────────────────────────────────────────
-- 2. person_names
-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS person_names (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id UUID NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    is_primary BOOLEAN,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_person_names_person ON person_names(person_id);
CREATE INDEX IF NOT EXISTS idx_person_names_lookup
    ON person_names(person_id, is_primary, created_at);

-- ────────────────────────────────────────────────────────────
-- 3. dictionary_sources
-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS dictionary_sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_name TEXT NOT NULL,
    source_version TEXT,
    license TEXT,
    commercial_safe BOOLEAN
);

-- ────────────────────────────────────────────────────────────
-- 4. dictionary_entries
-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS dictionary_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id UUID REFERENCES dictionary_sources(id) ON DELETE CASCADE,
    external_id TEXT,
    entry_type TEXT,                            -- e.g., 'person'
    primary_name TEXT,                          -- the surface text
    aliases JSONB,
    attributes JSONB
);

CREATE INDEX IF NOT EXISTS idx_dict_entries_primary_name
    ON dictionary_entries(primary_name);

-- ────────────────────────────────────────────────────────────
-- 5. seed_mappings
-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS seed_mappings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    target_entity_id UUID,                      -- references persons(id) when target_entity_type='person'
    target_entity_type TEXT,                    -- 'person' | etc
    dictionary_entry_id UUID REFERENCES dictionary_entries(id) ON DELETE CASCADE,
    mapping_status TEXT,                        -- 'pending_review' | 'confirmed' | 'rejected' | etc
    mapping_method TEXT,                        -- e.g., 'wikidata-seed-match' / 'manual'
    confidence NUMERIC,                         -- 0.0-1.0
    notes JSONB,
    mapping_created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_seed_mappings_pending
    ON seed_mappings(mapping_status, target_entity_type)
    WHERE mapping_status = 'pending_review';

-- ────────────────────────────────────────────────────────────
-- 6. pending_merge_reviews
-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS pending_merge_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    person_a_id UUID NOT NULL,                  -- logical FK to persons(id)
    person_b_id UUID NOT NULL,                  -- logical FK to persons(id)
    proposed_rule TEXT,                         -- e.g., 'R1' / 'R6'
    guard_type TEXT,                            -- e.g., 'cross_dynasty' / 'state_prefix'
    guard_payload JSONB,
    evidence JSONB,
    status TEXT NOT NULL DEFAULT 'pending',     -- 'pending' | 'decided'
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pending_merge_status
    ON pending_merge_reviews(status, created_at)
    WHERE status = 'pending';

-- ────────────────────────────────────────────────────────────
-- 7. triage_decisions (mirror services/pipeline/migrations/0014)
-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS triage_decisions (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_table             TEXT NOT NULL,
    source_id                UUID NOT NULL,
    surface_snapshot         TEXT NOT NULL,
    decision                 TEXT NOT NULL,
    reason_text              TEXT,
    reason_source_type       TEXT,
    historian_id             TEXT NOT NULL,
    historian_commit_ref     TEXT,
    architect_ack_ref        TEXT,
    decided_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
    downstream_applied       BOOLEAN NOT NULL DEFAULT false,
    downstream_applied_at    TIMESTAMPTZ,
    downstream_applied_by    TEXT,
    notes                    TEXT,

    CONSTRAINT triage_decisions_source_table_chk
        CHECK (source_table IN ('seed_mappings', 'pending_merge_reviews')),
    CONSTRAINT triage_decisions_decision_chk
        CHECK (decision IN ('approve', 'reject', 'defer')),
    CONSTRAINT triage_decisions_downstream_chk
        CHECK (
            (downstream_applied = false AND downstream_applied_at IS NULL AND downstream_applied_by IS NULL) OR
            (downstream_applied = true  AND downstream_applied_at IS NOT NULL AND downstream_applied_by IS NOT NULL)
        )
);

CREATE INDEX IF NOT EXISTS idx_triage_decisions_source
    ON triage_decisions(source_table, source_id);
CREATE INDEX IF NOT EXISTS idx_triage_decisions_surface
    ON triage_decisions(surface_snapshot);
CREATE INDEX IF NOT EXISTS idx_triage_decisions_historian
    ON triage_decisions(historian_id);
CREATE INDEX IF NOT EXISTS idx_triage_decisions_pending_apply
    ON triage_decisions(downstream_applied, decided_at)
    WHERE downstream_applied = false;
