/**
 * C layer — Event tables.
 * events / event_accounts / account_conflicts / event_causality
 *
 * Key decisions:
 * - ADR-002: Event + EventAccount dual-layer modeling
 * - Q-1: No standalone event_participants/event_places tables (JSONB in event_accounts)
 * - Q-2: No version_conflicts table (account_conflicts replaces it)
 * - Q-8: event_causality gains source_evidence_id + provenance_tier
 */
import {
  pgTable,
  uuid,
  text,
  jsonb,
  timestamp,
  boolean,
  real,
  index,
} from "drizzle-orm/pg-core";
import {
  realityStatusEnum,
  provenanceTierEnum,
  eventTypeEnum,
  conflictTypeEnum,
} from "./enums";
import { books, sourceEvidences } from "./sources";

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

interface EventParticipantRef {
  person_id: string;
  role: string;
  action?: string;
}

interface EventPlaceRef {
  place_id: string;
  role: string;
}

interface EventSequenceStep {
  order: number;
  description: MultiLangText;
  time?: HistoricalDate;
}

// ============================================================
// C1: events — Abstract event anchor (dual-layer: Event + EventAccount)
// ============================================================
export const events = pgTable("events", {
  id: uuid("id").defaultRandom().primaryKey(),
  slug: text("slug").unique().notNull(),
  title: jsonb("title").$type<MultiLangText>().notNull(),
  summary: jsonb("summary").$type<MultiLangText>(),
  significance: jsonb("significance").$type<MultiLangText>(),
  timePeriodStart: jsonb("time_period_start").$type<HistoricalDate>(),
  timePeriodEnd: jsonb("time_period_end").$type<HistoricalDate>(),
  placeId: uuid("place_id"), // FK to places added after places table defined
  eventType: eventTypeEnum("event_type"),
  importanceScore: real("importance_score"),
  canonicalAccountId: uuid("canonical_account_id"), // FK back-reference, set after event_accounts
  realityStatus: realityStatusEnum("reality_status").notNull().default("historical"),
  provenanceTier: provenanceTierEnum("provenance_tier").notNull().default("primary_text"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
  deletedAt: timestamp("deleted_at", { withTimezone: true }),
});

// ============================================================
// C2: event_accounts — Specific narrative per source (ADR-002 core)
// JSONB fields have structured zod schemas in shared-types (R-7)
// ============================================================
export const eventAccounts = pgTable("event_accounts", {
  id: uuid("id").defaultRandom().primaryKey(),
  eventId: uuid("event_id").references(() => events.id).notNull(),
  sourceBookId: uuid("source_book_id").references(() => books.id),
  narrative: jsonb("narrative").$type<MultiLangText>().notNull(),
  participants: jsonb("participants").$type<EventParticipantRef[]>(),
  places: jsonb("places").$type<EventPlaceRef[]>(),
  sequence: jsonb("sequence").$type<EventSequenceStep[]>(),
  sourceEvidenceIds: jsonb("source_evidence_ids").$type<string[]>().default([]),
  reliabilityScore: real("reliability_score").default(0.5),
  isCanonical: boolean("is_canonical").default(false), // ADR-002: checked field name
  provenanceTier: provenanceTierEnum("provenance_tier").notNull().default("primary_text"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(), // R-3
  deletedAt: timestamp("deleted_at", { withTimezone: true }), // R-3
}, (table) => [
  index("idx_accounts_event").on(table.eventId),
  // Partial index for canonical accounts will be added via SQL in migration customization
]);

// ============================================================
// C3: account_conflicts — Structured conflict between narratives
// Replaces v1 version_conflicts (Q-2)
// ============================================================
export const accountConflicts = pgTable("account_conflicts", {
  id: uuid("id").defaultRandom().primaryKey(),
  eventId: uuid("event_id").references(() => events.id).notNull(),
  accountAId: uuid("account_a_id").references(() => eventAccounts.id).notNull(),
  accountBId: uuid("account_b_id").references(() => eventAccounts.id).notNull(),
  conflictType: conflictTypeEnum("conflict_type"),
  diffSummary: jsonb("diff_summary"),
  analysis: jsonb("analysis"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  deletedAt: timestamp("deleted_at", { withTimezone: true }), // R-3
});

// ============================================================
// C4: event_causality — Cause-effect chains between events
// Enhanced with source_evidence_id + provenance_tier (Q-8)
// ============================================================
export const eventCausality = pgTable("event_causality", {
  causeEventId: uuid("cause_event_id").references(() => events.id).notNull(),
  effectEventId: uuid("effect_event_id").references(() => events.id).notNull(),
  confidence: real("confidence").default(0.5),
  sourceEvidenceId: uuid("source_evidence_id").references(() => sourceEvidences.id), // Q-8
  provenanceTier: provenanceTierEnum("provenance_tier").notNull().default("primary_text"), // Q-8
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
});
