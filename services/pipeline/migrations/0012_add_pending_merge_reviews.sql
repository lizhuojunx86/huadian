-- T-P0-029 Stage 1: pending_merge_reviews table
-- Stores guard-blocked R6 merge candidates for historian triage.
-- This table is the sole data source for T-P0-028 triage UI.
--
-- Architecture decision: separate table (not seed_mappings.notes) because:
--   1. Guard operates on person-pairs; seed_mappings is name→QID single-row
--   2. Concept: "blocked merge queue" ≠ "mapping annotation"
--   3. T-P0-028 UI reads this table directly

CREATE TABLE IF NOT EXISTS pending_merge_reviews (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    person_a_id     UUID NOT NULL REFERENCES persons(id),
    person_b_id     UUID NOT NULL REFERENCES persons(id),
    proposed_rule   TEXT NOT NULL,
    guard_type      TEXT NOT NULL,
    guard_payload   JSONB NOT NULL,
    evidence        JSONB NOT NULL,
    status          TEXT NOT NULL DEFAULT 'pending',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at     TIMESTAMPTZ,
    resolved_by     TEXT,
    resolved_notes  TEXT,

    CONSTRAINT pending_merge_reviews_pair_order
        CHECK (person_a_id < person_b_id),
    CONSTRAINT pending_merge_reviews_resolution_consistent
        CHECK (
            (status = 'pending' AND resolved_at IS NULL AND resolved_by IS NULL) OR
            (status IN ('accepted', 'rejected', 'deferred') AND resolved_at IS NOT NULL AND resolved_by IS NOT NULL)
        )
);

-- Same pair + same rule + same guard cannot be pending twice;
-- resolved entries allow a new cycle to re-pend.
CREATE UNIQUE INDEX IF NOT EXISTS pending_merge_reviews_pair_uniq
    ON pending_merge_reviews(person_a_id, person_b_id, proposed_rule, guard_type)
    WHERE status = 'pending';

-- Triage UI: list all pending, newest first
CREATE INDEX IF NOT EXISTS pending_merge_reviews_status_created
    ON pending_merge_reviews(status, created_at);
