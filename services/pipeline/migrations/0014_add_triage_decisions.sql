-- Migration 0014: triage_decisions
-- T-P0-028 Sprint K Stage 2 — historian triage UI persistence layer.
-- ADR: ADR-027 §3 (Pending Triage UI Workflow Protocol)
--
-- Purpose:
--   Store historian decisions on pending review items (seed_mappings +
--   pending_merge_reviews). Multi-row audit per source_id allowed
--   (defer → revisit → approve workflow).
--
-- Schema rationale (ADR-027 §3):
--   - source_id is a logical FK only (no SQL FK constraint) because
--     backfill rows may reference rows that are later soft-deleted /
--     entity-split / merged. Application layer ensures integrity.
--   - surface_snapshot is mandatory: hint banner needs a stable value
--     even if the source row's surface text mutates later.
--   - Multiple rows per source_id allowed: service layer queries
--     "latest decision per source_id" via decided_at DESC.
--   - downstream_applied is a V2 hook (PE async job will flip to true);
--     V1 always inserts as false.
--   - architect_ack_ref reserved for architect inline ACK scenarios
--     (e.g. Sprint J Stage 4.3 dynasty bug verification cases).

BEGIN;

CREATE TABLE IF NOT EXISTS triage_decisions (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_table             TEXT NOT NULL,           -- 'seed_mappings' | 'pending_merge_reviews'
    source_id                UUID NOT NULL,           -- FK 不约束（避免 historical-backfill 跨表 FK 复杂度）
    surface_snapshot         TEXT NOT NULL,           -- 决策时的 surface text snapshot（防源 row 删除/修改）
    decision                 TEXT NOT NULL,           -- 'approve' | 'reject' | 'defer'
    reason_text              TEXT,                    -- 决策理由（markdown）
    reason_source_type       TEXT,                    -- 'in_chapter' | 'other_classical' | 'wikidata' | 'scholarly' | 'structural' | 'historical-backfill'
    historian_id             TEXT NOT NULL,           -- 决策者 id
    historian_commit_ref     TEXT,                    -- 引用的 historian-review commit hash（如 backfill 或交叉引用）
    architect_ack_ref        TEXT,                    -- 架构师 inline ACK commit hash（如适用）
    decided_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
    downstream_applied       BOOLEAN NOT NULL DEFAULT false,  -- V2 hook 字段
    downstream_applied_at    TIMESTAMPTZ,
    downstream_applied_by    TEXT,                    -- V2 异步 job 标识
    notes                    TEXT,

    CONSTRAINT triage_decisions_source_table_chk
        CHECK (source_table IN ('seed_mappings', 'pending_merge_reviews')),
    CONSTRAINT triage_decisions_decision_chk
        CHECK (decision IN ('approve', 'reject', 'defer')),
    CONSTRAINT triage_decisions_downstream_chk
        CHECK (
            (downstream_applied = false AND downstream_applied_at IS NULL AND downstream_applied_by IS NULL) OR
            (downstream_applied = true AND downstream_applied_at IS NOT NULL AND downstream_applied_by IS NOT NULL)
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

COMMENT ON TABLE triage_decisions IS
  'Historian decisions on pending review items (seed_mappings + pending_merge_reviews). Multi-row audit per source_id allowed (defer → revisit → approve).';

COMMENT ON COLUMN triage_decisions.source_id IS
  'Logical FK to source_table.id; not enforced via SQL FK due to backfill cross-table complexity. Application layer ensures integrity.';

COMMENT ON COLUMN triage_decisions.surface_snapshot IS
  'Snapshot at decision time; source row surface may change later (e.g., soft-delete + names-stay).';

COMMENT ON COLUMN triage_decisions.downstream_applied IS
  'V2 hook: PE async job sets to true after applying decision to source data layer.';

COMMIT;
