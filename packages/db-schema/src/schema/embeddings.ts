/**
 * G layer — Embedding & Audit tables.
 * entity_embeddings / entity_revisions
 *
 * Key decisions:
 * - ADR-005: Multi-slot embeddings, BIGSERIAL PK (Q-4)
 * - R-2: vector(1024) fixed for Phase 0
 * - ADR-005 errata: entity_id is UUID (not BIGINT)
 * - C-4: entity_revisions for audit trail
 */
import {
  pgTable,
  uuid,
  text,
  integer,
  jsonb,
  timestamp,
  boolean,
  bigserial,
  customType,
  uniqueIndex,
  index,
} from "drizzle-orm/pg-core";
import { actorTypeEnum } from "./enums";

// ============================================================
// pgvector custom type — vector(1024) for Phase 0 (R-2)
// ============================================================
const vector1024 = customType<{
  data: number[];
  driverData: string;
}>({
  dataType() {
    return "vector(1024)";
  },
  toDriver(value: number[]): string {
    return `[${value.join(",")}]`;
  },
  fromDriver(value: string): number[] {
    if (typeof value === "string") {
      return value
        .replace(/^\[|\]$/g, "")
        .split(",")
        .map(Number);
    }
    return value as unknown as number[];
  },
});

// ============================================================
// G1: entity_embeddings — Multi-model embedding storage (ADR-005)
// BIGSERIAL PK (Q-4); entity_id UUID (ADR-005 errata)
// ============================================================
export const entityEmbeddings = pgTable("entity_embeddings", {
  id: bigserial("id", { mode: "number" }).primaryKey(),
  entityType: text("entity_type").notNull(),
  entityId: uuid("entity_id").notNull(), // ADR-005 errata: UUID, not BIGINT
  modelId: text("model_id").notNull(),
  modelVersion: text("model_version").notNull(),
  dimension: integer("dimension").notNull(),
  embedding: vector1024("embedding"),
  contentHash: text("content_hash").notNull(),
  isActive: boolean("is_active").default(true),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
}, (table) => [
  uniqueIndex("idx_ee_entity_model").on(
    table.entityType,
    table.entityId,
    table.modelId,
    table.modelVersion,
  ),
]);

// ============================================================
// G2: entity_revisions — Audit log (C-4 constitutional requirement)
// ============================================================
export const entityRevisions = pgTable("entity_revisions", {
  id: uuid("id").defaultRandom().primaryKey(),
  entityType: text("entity_type").notNull(),
  entityId: uuid("entity_id").notNull(),
  revisionNo: integer("revision_no").notNull(),
  diff: jsonb("diff").notNull(), // JSON Patch format
  actorType: actorTypeEnum("actor_type").notNull(),
  actorId: text("actor_id"),
  reason: text("reason"),
  promptVersion: text("prompt_version"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
}, (table) => [
  index("idx_revisions_entity").on(table.entityType, table.entityId, table.revisionNo),
]);
