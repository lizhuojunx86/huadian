/**
 * K layer — Pending Merge Reviews (guard-blocked merge candidates).
 *
 * T-P0-029: R6 cross-dynasty guard stores blocked merges here.
 * T-P0-028: Triage UI reads this table as its sole data source.
 *
 * Migration: services/pipeline/migrations/0012_add_pending_merge_reviews.sql
 */
import {
  pgTable,
  uuid,
  text,
  jsonb,
  timestamp,
  uniqueIndex,
  index,
  check,
} from "drizzle-orm/pg-core";
import { sql } from "drizzle-orm";
import { persons } from "./persons";

export const pendingMergeReviews = pgTable(
  "pending_merge_reviews",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    personAId: uuid("person_a_id")
      .notNull()
      .references(() => persons.id),
    personBId: uuid("person_b_id")
      .notNull()
      .references(() => persons.id),
    proposedRule: text("proposed_rule").notNull(),
    guardType: text("guard_type").notNull(),
    guardPayload: jsonb("guard_payload").notNull(),
    evidence: jsonb("evidence").notNull(),
    status: text("status").notNull().default("pending"),
    createdAt: timestamp("created_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
    resolvedAt: timestamp("resolved_at", { withTimezone: true }),
    resolvedBy: text("resolved_by"),
    resolvedNotes: text("resolved_notes"),
  },
  (table) => [
    uniqueIndex("pending_merge_reviews_pair_uniq")
      .on(table.personAId, table.personBId, table.proposedRule, table.guardType)
      .where(sql`status = 'pending'`),
    index("pending_merge_reviews_status_created").on(
      table.status,
      table.createdAt,
    ),
    check(
      "pending_merge_reviews_pair_order",
      sql`${table.personAId} < ${table.personBId}`,
    ),
    check(
      "pending_merge_reviews_resolution_consistent",
      sql`(${table.status} = 'pending' AND ${table.resolvedAt} IS NULL AND ${table.resolvedBy} IS NULL) OR (${table.status} IN ('accepted', 'rejected', 'deferred') AND ${table.resolvedAt} IS NOT NULL AND ${table.resolvedBy} IS NOT NULL)`,
    ),
  ],
);
