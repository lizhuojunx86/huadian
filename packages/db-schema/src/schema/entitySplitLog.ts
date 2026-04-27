/**
 * L layer — Entity Split Log (ADR-026 §4 audit table).
 *
 * Records mention-level person_names operations produced by entity-split runs
 * (T-P0-031 楚怀王 entity-split is the first application).
 *
 * Migration: services/pipeline/migrations/0013_add_entity_split_log.sql
 *
 * Schema rationale (ADR-026 §4.2):
 *   - One row per data-change action (option X — keep-case NOT logged).
 *   - Snapshot fields (redirectedName / redirectedNameType) survive
 *     subsequent person_names UPDATE.
 *   - Double sign-off references (historianRulingRef / architectAckRef)
 *     trace back to commit hashes.
 *   - ON DELETE RESTRICT on FK columns: audit log not cascade-cleaned.
 */
import {
  pgTable,
  uuid,
  text,
  timestamp,
  index,
  check,
} from "drizzle-orm/pg-core";
import { sql } from "drizzle-orm";
import { persons, personNames } from "./persons";
import { sourceEvidences } from "./sources";

export const entitySplitLog = pgTable(
  "entity_split_log",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    runId: uuid("run_id").notNull(),
    operation: text("operation").notNull(),
    sourcePersonId: uuid("source_person_id")
      .notNull()
      .references(() => persons.id, { onDelete: "restrict" }),
    targetPersonId: uuid("target_person_id")
      .notNull()
      .references(() => persons.id, { onDelete: "restrict" }),
    personNameId: uuid("person_name_id")
      .notNull()
      .references(() => personNames.id, { onDelete: "restrict" }),
    redirectedName: text("redirected_name").notNull(),
    redirectedNameType: text("redirected_name_type").notNull(),
    sourceEvidenceId: uuid("source_evidence_id").references(
      () => sourceEvidences.id,
      { onDelete: "restrict" },
    ),
    historianRulingRef: text("historian_ruling_ref").notNull(),
    architectAckRef: text("architect_ack_ref").notNull(),
    pgDumpAnchor: text("pg_dump_anchor").notNull(),
    appliedBy: text("applied_by").notNull(),
    appliedAt: timestamp("applied_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
    notes: text("notes"),
  },
  (table) => [
    index("idx_entity_split_log_run").on(table.runId),
    index("idx_entity_split_log_source").on(table.sourcePersonId),
    index("idx_entity_split_log_target").on(table.targetPersonId),
    check(
      "entity_split_log_pair_distinct",
      sql`${table.sourcePersonId} <> ${table.targetPersonId}`,
    ),
    check(
      "entity_split_log_operation_valid",
      sql`${table.operation} IN ('redirect', 'split_for_safety')`,
    ),
  ],
);
