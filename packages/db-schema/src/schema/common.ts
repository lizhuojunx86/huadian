/**
 * Shared column definitions for Drizzle schema.
 * Provides reusable column builders for timestamps, soft-delete, provenance, and slug.
 */
import { uuid, text, timestamp } from "drizzle-orm/pg-core";

// Standard timestamps for all tables
export const timestamps = {
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
};

// Soft-delete column (C-4)
export const softDelete = {
  deletedAt: timestamp("deleted_at", { withTimezone: true }),
};

// Provenance tier (C-2) — required for all entity tables
export const provenanceTier = {
  provenanceTier: text("provenance_tier").notNull().default("primary_text"),
};

// UUID primary key — standard for all entity tables
export const uuidPk = {
  id: uuid("id").defaultRandom().primaryKey(),
};

// Slug field (C-13) — required for 8 entity types
export const slugField = {
  slug: text("slug").unique().notNull(),
};

// Reality status — for entities that may be historical/legendary/etc.
export const realityStatus = {
  realityStatus: text("reality_status").notNull().default("historical"),
};
