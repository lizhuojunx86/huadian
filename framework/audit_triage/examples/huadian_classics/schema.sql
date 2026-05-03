-- HuaDian classics — reference DDL for the audit_triage framework.
--
-- This is a copy of the production migration
-- ``services/pipeline/migrations/0014_add_triage_decisions.sql`` shipped
-- with the framework as a reference for case domains. Copy + edit for
-- your own schema (table name, FK targets, additional columns) — the
-- framework's ``TriageStore`` Protocol does not care about the exact
-- column set as long as the abstract contract (see
-- ``framework/audit_triage/store.py`` module docstring) is preserved.
--
-- Required columns for a minimal store impl:
--   id                       UUID PRIMARY KEY DEFAULT gen_random_uuid()
--   source_table             TEXT NOT NULL
--   source_id                UUID NOT NULL
--   surface_snapshot         TEXT NOT NULL
--   decision                 TEXT NOT NULL  CHECK ('approve','reject','defer')
--   historian_id             TEXT NOT NULL
--   decided_at               TIMESTAMPTZ NOT NULL DEFAULT now()
--
-- Optional but recommended (matches the framework DecisionRecord shape):
--   reason_text              TEXT
--   reason_source_type       TEXT
--   historian_commit_ref     TEXT
--   architect_ack_ref        TEXT
--   downstream_applied       BOOLEAN NOT NULL DEFAULT false
--   downstream_applied_at    TIMESTAMPTZ
--   downstream_applied_by    TEXT
--   notes                    TEXT
--
-- Multi-row audit per source_id is REQUIRED — do NOT add a UNIQUE on
-- source_id alone (defer → revisit → approve workflow).
--
-- ADR: ADR-027 §3 (Pending Triage UI Workflow Protocol)

BEGIN;

CREATE TABLE IF NOT EXISTS triage_decisions (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_table             TEXT NOT NULL,           -- e.g. 'seed_mappings' | 'pending_merge_reviews'
    source_id                UUID NOT NULL,           -- logical FK; not enforced via SQL FK (backfill safety)
    surface_snapshot         TEXT NOT NULL,           -- frozen at decision time
    decision                 TEXT NOT NULL,           -- 'approve' | 'reject' | 'defer'
    reason_text              TEXT,                    -- markdown
    reason_source_type       TEXT,                    -- one of REASON_SOURCE_TYPES (see framework/audit_triage/reasons.py)
    historian_id             TEXT NOT NULL,
    historian_commit_ref     TEXT,
    architect_ack_ref        TEXT,
    decided_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
    downstream_applied       BOOLEAN NOT NULL DEFAULT false,  -- V0.2 hook
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

COMMIT;
