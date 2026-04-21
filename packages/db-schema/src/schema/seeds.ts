/**
 * J layer — Dictionary Seed tables.
 * dictionary_sources / dictionary_entries / seed_mappings
 *
 * DDL source: docs/research/T-P0-026-dictionary-seed-feasibility.md §5.2
 * ADR: ADR-021 §2.5
 * Migration: services/pipeline/migrations/0009_dictionary_seed_schema.sql
 */
import {
  pgTable,
  uuid,
  text,
  jsonb,
  timestamp,
  boolean,
  numeric,
  uniqueIndex,
  index,
  check,
} from "drizzle-orm/pg-core";
import { sql } from "drizzle-orm";

// ============================================================
// J1: dictionary_sources — External dictionary registry
// ============================================================
export const dictionarySources = pgTable(
  "dictionary_sources",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    sourceName: text("source_name").notNull(),
    sourceVersion: text("source_version").notNull(),
    license: text("license").notNull(),
    commercialSafe: boolean("commercial_safe").notNull(),
    accessUrl: text("access_url"),
    ingestedAt: timestamp("ingested_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
    notes: jsonb("notes"),
  },
  (table) => [
    uniqueIndex("uq_dictionary_sources_name_version").on(
      table.sourceName,
      table.sourceVersion,
    ),
  ],
);

// ============================================================
// J2: dictionary_entries — Raw external entity records
// ============================================================
export const dictionaryEntries = pgTable(
  "dictionary_entries",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    sourceId: uuid("source_id")
      .notNull()
      .references(() => dictionarySources.id),
    externalId: text("external_id").notNull(),
    entryType: text("entry_type").notNull(),
    primaryName: text("primary_name"),
    aliases: jsonb("aliases"),
    attributes: jsonb("attributes").notNull().default({}),
    ingestedAt: timestamp("ingested_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
  },
  (table) => [
    uniqueIndex("uq_dictionary_entries_source_external").on(
      table.sourceId,
      table.externalId,
    ),
    index("idx_dictionary_entries_source").on(table.sourceId),
    index("idx_dictionary_entries_primary_name").on(table.primaryName),
    check(
      "dictionary_entries_entry_type_check",
      sql`${table.entryType} IN ('person', 'place', 'polity', 'reign_era', 'office')`,
    ),
  ],
);

// ============================================================
// J3: seed_mappings — Entry → HuaDian entity mapping (revocable)
// ============================================================
export const seedMappings = pgTable(
  "seed_mappings",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    dictionaryEntryId: uuid("dictionary_entry_id")
      .notNull()
      .references(() => dictionaryEntries.id),
    targetEntityType: text("target_entity_type").notNull(),
    targetEntityId: uuid("target_entity_id").notNull(),
    confidence: numeric("confidence", { precision: 3, scale: 2 }),
    mappingMethod: text("mapping_method").notNull(),
    mappingCreatedAt: timestamp("mapping_created_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
    // Lifecycle: pending_review → active|rejected; active → superseded
    mappingStatus: text("mapping_status").notNull().default("active"),
    notes: jsonb("notes"),
  },
  (table) => [
    uniqueIndex("uq_seed_mappings_entry_target_status").on(
      table.dictionaryEntryId,
      table.targetEntityType,
      table.targetEntityId,
      table.mappingStatus,
    ),
    index("idx_seed_mappings_target")
      .on(table.targetEntityType, table.targetEntityId)
      .where(sql`mapping_status = 'active'`),
    check(
      "seed_mappings_confidence_check",
      sql`${table.confidence} >= 0.00 AND ${table.confidence} <= 1.00`,
    ),
    check(
      "seed_mappings_status_check",
      sql`${table.mappingStatus} IN ('active', 'superseded', 'rejected', 'pending_review')`,
    ),
  ],
);
