/**
 * B layer — Identity tables.
 * persons / person_names / identity_hypotheses / disambiguation_seeds / role_appellations
 */
import {
  pgTable,
  uuid,
  text,
  integer,
  jsonb,
  timestamp,
  boolean,
  index,
} from "drizzle-orm/pg-core";
import { sql } from "drizzle-orm";
import {
  realityStatusEnum,
  provenanceTierEnum,
  nameTypeEnum,
  hypothesisRelationTypeEnum,
} from "./enums";
import { sourceEvidences } from "./sources";

// JSONB type hints
interface MultiLangText {
  "zh-Hans": string;
  "zh-Hant"?: string;
  en?: string;
}

interface HistoricalDate {
  year_min?: number;
  year_max?: number;
  precision: string;
  [key: string]: unknown;
}

// ============================================================
// B1: persons — Core person entities
// ============================================================
export const persons = pgTable("persons", {
  id: uuid("id").defaultRandom().primaryKey(),
  slug: text("slug").unique().notNull(),
  name: jsonb("name").$type<MultiLangText>().notNull(),
  dynasty: text("dynasty"),
  realityStatus: realityStatusEnum("reality_status").notNull().default("historical"),
  birthDate: jsonb("birth_date").$type<HistoricalDate>(),
  deathDate: jsonb("death_date").$type<HistoricalDate>(),
  biography: jsonb("biography").$type<MultiLangText>(),
  provenanceTier: provenanceTierEnum("provenance_tier").notNull().default("primary_text"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
  deletedAt: timestamp("deleted_at", { withTimezone: true }),
});

// ============================================================
// B2: person_names — Multiple names/titles per person (Q-3: name stays TEXT)
// ============================================================
export const personNames = pgTable("person_names", {
  id: uuid("id").defaultRandom().primaryKey(),
  personId: uuid("person_id").references(() => persons.id, { onDelete: "cascade" }).notNull(),
  name: text("name").notNull(), // Historical original — TEXT, not JSONB (Q-3)
  namePinyin: text("name_pinyin"),
  nameType: nameTypeEnum("name_type").notNull(),
  startYear: integer("start_year"),
  endYear: integer("end_year"),
  isPrimary: boolean("is_primary").default(false),
  sourceEvidenceId: uuid("source_evidence_id").references(() => sourceEvidences.id),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
}, (table) => [
  // GIN trigram index for fuzzy search — uses gin_trgm_ops operator class
  // Drizzle doesn't support operator classes natively, so we use raw SQL
  index("idx_person_names_search").using("gin", sql`${table.name} gin_trgm_ops`),
  index("idx_person_names_person").on(table.personId),
]);

// ============================================================
// B3: identity_hypotheses — "Laozi might be Li Er / Lao Laizi / Taishi Dan"
// ============================================================
export const identityHypotheses = pgTable("identity_hypotheses", {
  id: uuid("id").defaultRandom().primaryKey(),
  canonicalPersonId: uuid("canonical_person_id").references(() => persons.id).notNull(),
  hypothesisPersonId: uuid("hypothesis_person_id").references(() => persons.id),
  relationType: hypothesisRelationTypeEnum("relation_type").notNull(),
  scholarlySupport: text("scholarly_support"),
  evidenceIds: jsonb("evidence_ids").$type<string[]>().default([]),
  acceptedByDefault: boolean("accepted_by_default").default(false),
  notes: text("notes"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
}, (table) => [
  index("idx_hypotheses_canonical").on(table.canonicalPersonId),
]);

// ============================================================
// B4: disambiguation_seeds — Known ambiguous names
// ============================================================
export const disambiguationSeeds = pgTable("disambiguation_seeds", {
  id: uuid("id").defaultRandom().primaryKey(),
  name: text("name").notNull(),
  personId: uuid("person_id").references(() => persons.id),
  dynastyHint: text("dynasty_hint"),
  contextHint: text("context_hint"),
  priority: integer("priority").default(100),
}, (table) => [
  index("idx_disamb_name").on(table.name),
]);

// ============================================================
// B5: role_appellations — Title/role-based name resolution dictionary
// ============================================================
export const roleAppellations = pgTable("role_appellations", {
  id: uuid("id").defaultRandom().primaryKey(),
  appellation: text("appellation").unique().notNull(),
  resolveRule: jsonb("resolve_rule").notNull(),
});
