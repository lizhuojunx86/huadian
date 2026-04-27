-- Migration 0013: entity_split_log
-- ADR-026 §4 Entity Split Protocol audit table.
-- Records every mention-level person_names operation produced by an
-- entity-split run (T-P0-031 楚怀王 entity-split is the first application).
--
-- Schema rationale (ADR-026 §4.2):
--   - One row per data-change action (option X — keep-case NOT logged;
--     keep decisions live in historian ruling commit hash references).
--   - Snapshot fields (redirected_name / redirected_name_type) survive
--     subsequent person_names UPDATE.
--   - Double sign-off references (historian_ruling_ref / architect_ack_ref)
--     are mandatory and trace back to commit hashes.
--   - ON DELETE RESTRICT on FK columns: audit log not cascade-cleaned.

BEGIN;

CREATE TABLE IF NOT EXISTS entity_split_log (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    run_id                  UUID NOT NULL,
    operation               TEXT NOT NULL,                     -- 'redirect' | 'split_for_safety'
    source_person_id        UUID NOT NULL REFERENCES persons(id) ON DELETE RESTRICT,
    target_person_id        UUID NOT NULL REFERENCES persons(id) ON DELETE RESTRICT,
    person_name_id          UUID NOT NULL REFERENCES person_names(id) ON DELETE RESTRICT,
    redirected_name         TEXT NOT NULL,                     -- snapshot
    redirected_name_type    TEXT NOT NULL,                     -- snapshot
    source_evidence_id      UUID REFERENCES source_evidences(id) ON DELETE RESTRICT,
    historian_ruling_ref    TEXT NOT NULL,                     -- '<commit-hash> §<section>'
    architect_ack_ref       TEXT NOT NULL,                     -- '<commit-hash>' or PR comment ref
    pg_dump_anchor          TEXT NOT NULL,                     -- 'ops/rollback/<file>.dump (sha256 first 12 chars)'
    applied_by              TEXT NOT NULL,                     -- 'pipeline:t-p0-031-stage-3'
    applied_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    notes                   TEXT,

    CONSTRAINT entity_split_log_pair_distinct
        CHECK (source_person_id <> target_person_id),
    CONSTRAINT entity_split_log_operation_valid
        CHECK (operation IN ('redirect', 'split_for_safety'))
);

CREATE INDEX IF NOT EXISTS idx_entity_split_log_run
    ON entity_split_log (run_id);

CREATE INDEX IF NOT EXISTS idx_entity_split_log_source
    ON entity_split_log (source_person_id);

CREATE INDEX IF NOT EXISTS idx_entity_split_log_target
    ON entity_split_log (target_person_id);

COMMIT;
