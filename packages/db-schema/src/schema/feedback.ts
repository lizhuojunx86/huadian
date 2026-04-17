/**
 * I layer — User feedback table.
 * C-21: User feedback is a reverse pipeline.
 */
import {
  pgTable,
  uuid,
  text,
  timestamp,
  boolean,
  index,
} from "drizzle-orm/pg-core";
import { feedbackTypeEnum } from "./enums";
import { sourceEvidences } from "./sources";

// ============================================================
// I1: feedback — User reports and suggestions (C-21)
// ============================================================
export const feedback = pgTable("feedback", {
  id: uuid("id").defaultRandom().primaryKey(),
  userId: uuid("user_id"),
  anonSessionId: text("anon_session_id"),
  entityType: text("entity_type"),
  entityId: uuid("entity_id"),
  evidenceId: uuid("evidence_id").references(() => sourceEvidences.id),
  promptVersion: text("prompt_version"),
  modelVersion: text("model_version"),
  feedbackType: feedbackTypeEnum("feedback_type").notNull(),
  note: text("note"),
  userAgent: text("user_agent"),
  traceId: text("trace_id"),
  resolved: boolean("resolved").default(false),
  resolutionNote: text("resolution_note"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
}, (table) => [
  index("idx_feedback_entity").on(table.entityType, table.entityId),
]);
