/**
 * Drizzle schema — pure definition layer.
 * NO drizzle.config.ts here. Execution (migrate/push/studio) lives in services/api.
 * See ADR-007 §R-3.
 *
 * This is a Phase 0 stub. Real tables will be defined in T-P0-002.
 */
import { pgTable, uuid, text, integer, jsonb, timestamp } from "drizzle-orm/pg-core";

export const persons = pgTable("persons", {
  id: uuid("id").defaultRandom().primaryKey(),
  name: jsonb("name").$type<{ zh: string; en?: string }>().notNull(),
  dynasty: text("dynasty"),
  birthYear: integer("birth_year"),
  deathYear: integer("death_year"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
});
