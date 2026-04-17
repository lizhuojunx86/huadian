/**
 * E layer — Relationships, Mentions, Allusions, Institutions.
 * relationships / mentions / allusions / allusion_evolution / allusion_usages
 * / intertextual_links / institutions / institution_changes
 *
 * v1 retained tables upgraded per Q-3/Q-6 mapping:
 * - TEXT → JSONB for user-facing fields
 * - +slug for 8-entity types (allusions, institutions)
 * - +provenance_tier / +deleted_at / +timestamps
 */
import {
  pgTable,
  uuid,
  text,
  integer,
  jsonb,
  timestamp,
  boolean,
  real,
  index,
} from "drizzle-orm/pg-core";
import {
  provenanceTierEnum,
  relationshipTypeEnum,
  mentionTypeEnum,
  mentionEntityTypeEnum,
  inferenceBasisEnum,
  semanticShiftEnum,
  intertextualLinkTypeEnum,
} from "./enums";
import { rawTexts } from "./sources";
import { persons } from "./persons";
import { events } from "./events";

// JSONB type hints
interface MultiLangText {
  "zh-Hans": string;
  "zh-Hant"?: string;
  en?: string;
}

// ============================================================
// E1: relationships — Person-to-person relations (v1 upgraded)
// No slug (not one of the 8 entity types)
// ============================================================
export const relationships = pgTable("relationships", {
  id: uuid("id").defaultRandom().primaryKey(),
  personAId: uuid("person_a_id").references(() => persons.id).notNull(),
  personBId: uuid("person_b_id").references(() => persons.id).notNull(),
  relationshipType: relationshipTypeEnum("relationship_type").notNull(),
  description: jsonb("description").$type<MultiLangText>(), // v1 TEXT → JSONB
  confidence: real("confidence").default(0.5),
  sourceText: text("source_text"),
  provenanceTier: provenanceTierEnum("provenance_tier").notNull().default("primary_text"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
  deletedAt: timestamp("deleted_at", { withTimezone: true }),
});

// ============================================================
// E2: mentions — Text-level entity references (core v2 table)
// Handles explicit, implicit, allusion, metaphor, etc. (R-4: +deleted_at/updated_at)
// ============================================================
export const mentions = pgTable("mentions", {
  id: uuid("id").defaultRandom().primaryKey(),
  rawTextId: uuid("raw_text_id").references(() => rawTexts.id).notNull(),
  positionStart: integer("position_start").notNull(),
  positionEnd: integer("position_end").notNull(),
  surfaceText: text("surface_text").notNull(),
  entityType: mentionEntityTypeEnum("entity_type"),
  entityId: uuid("entity_id"), // Nullable — unresolved mentions
  mentionType: mentionTypeEnum("mention_type").notNull(),
  confidence: real("confidence").notNull().default(0.5),
  inferenceBasis: inferenceBasisEnum("inference_basis"),
  detectorVersion: text("detector_version"),
  humanVerified: boolean("human_verified").default(false),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(), // R-4
  deletedAt: timestamp("deleted_at", { withTimezone: true }), // R-4
}, (table) => [
  index("idx_mentions_rawtext").on(table.rawTextId, table.positionStart),
  index("idx_mentions_entity").on(table.entityType, table.entityId),
  index("idx_mentions_type").on(table.mentionType),
]);

// ============================================================
// E3: allusions — Classical allusion registry (v1 upgraded)
// ============================================================
export const allusions = pgTable("allusions", {
  id: uuid("id").defaultRandom().primaryKey(),
  slug: text("slug").unique().notNull(),
  name: jsonb("name").$type<MultiLangText>().notNull(), // v1 TEXT → JSONB
  originText: text("origin_text"),
  originalMeaning: jsonb("original_meaning").$type<MultiLangText>(), // v1 TEXT → JSONB
  modernMeaning: jsonb("modern_meaning").$type<MultiLangText>(), // v1 TEXT → JSONB
  relatedEventId: uuid("related_event_id").references(() => events.id),
  relatedPersonId: uuid("related_person_id").references(() => persons.id),
  provenanceTier: provenanceTierEnum("provenance_tier").notNull().default("primary_text"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
  deletedAt: timestamp("deleted_at", { withTimezone: true }),
});

// ============================================================
// E4: allusion_evolution — Meaning change over time (v1 upgraded)
// ============================================================
export const allusionEvolution = pgTable("allusion_evolution", {
  id: uuid("id").defaultRandom().primaryKey(),
  allusionId: uuid("allusion_id").references(() => allusions.id).notNull(),
  era: text("era"),
  evolvedMeaning: jsonb("evolved_meaning").$type<MultiLangText>(), // v1 TEXT → JSONB
  exampleText: text("example_text"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
});

// ============================================================
// E5: allusion_usages — Specific usage instances of allusions
// ============================================================
export const allusionUsages = pgTable("allusion_usages", {
  id: uuid("id").defaultRandom().primaryKey(),
  allusionId: uuid("allusion_id").references(() => allusions.id).notNull(),
  mentionId: uuid("mention_id").references(() => mentions.id).notNull(),
  semanticShift: semanticShiftEnum("semantic_shift"),
  notes: jsonb("notes"),
});

// ============================================================
// E6: intertextual_links — Cross-text references
// ============================================================
export const intertextualLinks = pgTable("intertextual_links", {
  id: uuid("id").defaultRandom().primaryKey(),
  sourceRawTextId: uuid("source_raw_text_id").references(() => rawTexts.id).notNull(),
  targetRawTextId: uuid("target_raw_text_id").references(() => rawTexts.id).notNull(),
  linkType: intertextualLinkTypeEnum("link_type").notNull(),
  overlapText: text("overlap_text"),
  confidence: real("confidence").default(0.5),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
});

// ============================================================
// E7: institutions — Government systems / organizations (v1 upgraded)
// ============================================================
export const institutions = pgTable("institutions", {
  id: uuid("id").defaultRandom().primaryKey(),
  slug: text("slug").unique().notNull(),
  name: jsonb("name").$type<MultiLangText>().notNull(), // v1 TEXT → JSONB
  institutionType: text("institution_type"),
  description: jsonb("description").$type<MultiLangText>(), // v1 TEXT → JSONB
  dynasty: text("dynasty"),
  yearStart: integer("year_start"),
  yearEnd: integer("year_end"),
  provenanceTier: provenanceTierEnum("provenance_tier").notNull().default("primary_text"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
  deletedAt: timestamp("deleted_at", { withTimezone: true }),
});

// ============================================================
// E8: institution_changes — Institutional evolution records (v1 upgraded)
// ============================================================
export const institutionChanges = pgTable("institution_changes", {
  id: uuid("id").defaultRandom().primaryKey(),
  institutionId: uuid("institution_id").references(() => institutions.id).notNull(),
  year: integer("year"),
  changeDescription: jsonb("change_description").$type<MultiLangText>(), // v1 TEXT → JSONB
  sourceText: text("source_text"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
});
