/**
 * A layer — Text & Source tables.
 * books / raw_texts / source_evidences / evidence_links / textual_notes / text_variants / variant_chars
 */
import {
  pgTable,
  uuid,
  text,
  integer,
  jsonb,
  timestamp,
  index,
} from "drizzle-orm/pg-core";
import {
  credibilityTierEnum,
  bookGenreEnum,
  licenseEnum,
  provenanceTierEnum,
  variantCharTypeEnum,
  textualNoteTypeEnum,
  diffTypeEnum,
} from "./enums";

// JSONB type hints — runtime type from shared-types
interface MultiLangText {
  "zh-Hans": string;
  "zh-Hant"?: string;
  en?: string;
}

// ============================================================
// A1: books — Ancient text metadata
// ============================================================
export const books = pgTable("books", {
  id: uuid("id").defaultRandom().primaryKey(),
  title: jsonb("title").$type<MultiLangText>().notNull(),
  authorPersonId: uuid("author_person_id"), // FK added after persons table
  dynasty: text("dynasty"),
  genre: bookGenreEnum("genre"),
  credibilityTier: credibilityTierEnum("credibility_tier").notNull(),
  license: licenseEnum("license").notNull(),
  authoritativeVersion: text("authoritative_version"),
  slug: text("slug").unique().notNull(),
  metadata: jsonb("metadata").default({}),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
  deletedAt: timestamp("deleted_at", { withTimezone: true }),
});

// ============================================================
// A2: raw_texts — Source text paragraphs
// ============================================================
export const rawTexts = pgTable("raw_texts", {
  id: uuid("id").defaultRandom().primaryKey(),
  sourceId: text("source_id").notNull(),
  bookId: uuid("book_id").references(() => books.id),
  volume: text("volume"),
  chapter: text("chapter"),
  paragraphNo: integer("paragraph_no"),
  rawText: text("raw_text").notNull(), // Simplified Chinese (search-friendly)
  textOriginal: text("text_original"), // Original traditional (R-8)
  variantOfId: uuid("variant_of_id"), // Self-reference for variants
  textVersion: text("text_version"),
  // tsv tsvector — kept for full-text search (R-8)
  // Note: Drizzle doesn't natively support tsvector GENERATED columns.
  // We define the column in SQL via Drizzle migration customization.
  // embedding column removed (R-8) — moved to entity_embeddings
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
  deletedAt: timestamp("deleted_at", { withTimezone: true }),
});

// ============================================================
// A3: source_evidences — Evidence provenance chain
// ============================================================
export const sourceEvidences = pgTable("source_evidences", {
  id: uuid("id").defaultRandom().primaryKey(),
  rawTextId: uuid("raw_text_id").references(() => rawTexts.id),
  positionStart: integer("position_start"),
  positionEnd: integer("position_end"),
  quotedText: text("quoted_text"),
  provenanceTier: provenanceTierEnum("provenance_tier").notNull().default("primary_text"),
  textVersion: text("text_version"),
  bookId: uuid("book_id").references(() => books.id),
  promptVersion: text("prompt_version"),
  llmCallId: uuid("llm_call_id"), // FK to llm_calls added in pipeline.ts
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
});

// ============================================================
// A4: evidence_links — Evidence-Entity polymorphic association
// ============================================================
export const evidenceLinks = pgTable("evidence_links", {
  id: uuid("id").defaultRandom().primaryKey(),
  evidenceId: uuid("evidence_id").references(() => sourceEvidences.id).notNull(),
  entityType: text("entity_type").notNull(), // person / event / relationship / allusion / ...
  entityId: uuid("entity_id").notNull(),
  role: text("role"), // subject / predicate / context
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(), // R-5
});

// ============================================================
// A5: textual_notes — Scholarly annotations & emendations
// ============================================================
export const textualNotes = pgTable("textual_notes", {
  id: uuid("id").defaultRandom().primaryKey(),
  rawTextId: uuid("raw_text_id").references(() => rawTexts.id).notNull(),
  positionStart: integer("position_start"),
  positionEnd: integer("position_end"),
  noteType: textualNoteTypeEnum("note_type"),
  commentator: text("commentator"),
  content: jsonb("content").$type<MultiLangText>(),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
});

// ============================================================
// A6: text_variants — Cross-version text comparison
// ============================================================
export const textVariants = pgTable("text_variants", {
  id: uuid("id").defaultRandom().primaryKey(),
  rawTextAId: uuid("raw_text_a_id").references(() => rawTexts.id).notNull(),
  rawTextBId: uuid("raw_text_b_id").references(() => rawTexts.id).notNull(),
  diffPosition: integer("diff_position"),
  diffType: diffTypeEnum("diff_type"),
  diffContent: jsonb("diff_content"),
  notes: text("notes"),
});

// ============================================================
// A7: variant_chars — Tongjia / variant character dictionary
// ============================================================
export const variantChars = pgTable("variant_chars", {
  id: uuid("id").defaultRandom().primaryKey(),
  charCanonical: text("char_canonical").notNull(),
  charVariant: text("char_variant").notNull(),
  variantType: variantCharTypeEnum("variant_type"),
  dynastyScope: text("dynasty_scope"),
  notes: text("notes"),
}, (table) => [
  index("idx_variant_chars_pair").on(table.charCanonical, table.charVariant),
]);
