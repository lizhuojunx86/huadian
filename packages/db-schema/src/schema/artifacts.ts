/**
 * F layer — Artifact/Concept entities (v1 upgraded per Q-3/Q-6).
 */
import {
  pgTable,
  uuid,
  text,
  jsonb,
  timestamp,
} from "drizzle-orm/pg-core";
import { provenanceTierEnum } from "./enums";

// JSONB type hints
interface MultiLangText {
  "zh-Hans": string;
  "zh-Hant"?: string;
  en?: string;
}

// ============================================================
// F1: artifacts — Physical objects / concepts (v1 upgraded)
// ============================================================
export const artifacts = pgTable("artifacts", {
  id: uuid("id").defaultRandom().primaryKey(),
  slug: text("slug").unique().notNull(),
  name: jsonb("name").$type<MultiLangText>().notNull(), // v1 TEXT → JSONB
  artifactType: text("artifact_type"),
  description: jsonb("description").$type<MultiLangText>(), // v1 TEXT → JSONB
  dynasty: text("dynasty"),
  provenanceTier: provenanceTierEnum("provenance_tier").notNull().default("primary_text"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
  deletedAt: timestamp("deleted_at", { withTimezone: true }),
});
