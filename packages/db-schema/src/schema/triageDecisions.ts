/**
 * M layer — Triage Decisions (ADR-027 §3 historian triage UI persistence).
 *
 * Records every historian decision on pending review items
 * (seed_mappings + pending_merge_reviews). Multi-row audit per source_id
 * is allowed: defer → revisit → approve workflow.
 *
 * Migration: services/pipeline/migrations/0014_add_triage_decisions.sql
 *
 * Schema rationale (ADR-027 §3):
 *   - source_id is a logical FK only (no SQL FK constraint) because
 *     backfill rows may reference rows that are later soft-deleted /
 *     entity-split / merged. Application layer ensures integrity.
 *   - surface_snapshot is mandatory: hint banner needs a stable value
 *     even if the source row's surface text mutates later.
 *   - downstream_applied is a V2 hook (PE async job will flip to true);
 *     V1 always inserts as false.
 */
import {
  pgTable,
  uuid,
  text,
  timestamp,
  boolean,
  index,
  check,
} from "drizzle-orm/pg-core";
import { sql } from "drizzle-orm";

export const triageDecisions = pgTable(
  "triage_decisions",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    sourceTable: text("source_table").notNull(),
    sourceId: uuid("source_id").notNull(),
    surfaceSnapshot: text("surface_snapshot").notNull(),
    decision: text("decision").notNull(),
    reasonText: text("reason_text"),
    reasonSourceType: text("reason_source_type"),
    historianId: text("historian_id").notNull(),
    historianCommitRef: text("historian_commit_ref"),
    architectAckRef: text("architect_ack_ref"),
    decidedAt: timestamp("decided_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
    downstreamApplied: boolean("downstream_applied").notNull().default(false),
    downstreamAppliedAt: timestamp("downstream_applied_at", {
      withTimezone: true,
    }),
    downstreamAppliedBy: text("downstream_applied_by"),
    notes: text("notes"),
  },
  (table) => [
    index("idx_triage_decisions_source").on(
      table.sourceTable,
      table.sourceId,
    ),
    index("idx_triage_decisions_surface").on(table.surfaceSnapshot),
    index("idx_triage_decisions_historian").on(table.historianId),
    index("idx_triage_decisions_pending_apply")
      .on(table.downstreamApplied, table.decidedAt)
      .where(sql`downstream_applied = false`),
    check(
      "triage_decisions_source_table_chk",
      sql`${table.sourceTable} IN ('seed_mappings', 'pending_merge_reviews')`,
    ),
    check(
      "triage_decisions_decision_chk",
      sql`${table.decision} IN ('approve', 'reject', 'defer')`,
    ),
    check(
      "triage_decisions_downstream_chk",
      sql`(${table.downstreamApplied} = false AND ${table.downstreamAppliedAt} IS NULL AND ${table.downstreamAppliedBy} IS NULL) OR (${table.downstreamApplied} = true AND ${table.downstreamAppliedAt} IS NOT NULL AND ${table.downstreamAppliedBy} IS NOT NULL)`,
    ),
  ],
);
