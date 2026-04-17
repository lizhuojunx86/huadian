/**
 * H layer — Pipeline & LLM tracking tables.
 * llm_calls / pipeline_runs / extractions_history
 *
 * Key requirements:
 * - C-7: No black-box LLM calls — all calls logged here
 * - C-11: Extractions preserved by prompt version
 */
import {
  pgTable,
  uuid,
  text,
  integer,
  jsonb,
  timestamp,
  numeric,
  index,
  uniqueIndex,
} from "drizzle-orm/pg-core";
import { pipelineStepEnum, pipelineStatusEnum, llmCallStatusEnum } from "./enums";
import { books, rawTexts } from "./sources";

// ============================================================
// H1: llm_calls — LLM invocation audit log (C-7)
// ============================================================
export const llmCalls = pgTable("llm_calls", {
  id: uuid("id").defaultRandom().primaryKey(),
  promptId: text("prompt_id").notNull(),
  promptVersion: text("prompt_version").notNull(),
  promptHash: text("prompt_hash").notNull(),
  inputHash: text("input_hash").notNull(),
  model: text("model").notNull(),
  modelVersion: text("model_version"),
  inputTokens: integer("input_tokens"),
  outputTokens: integer("output_tokens"),
  costUsd: numeric("cost_usd", { precision: 10, scale: 6 }),
  latencyMs: integer("latency_ms"),
  response: jsonb("response"),
  // Semantic: 华典 adapter-generated uuid4 per checkpoint invocation
  // (not TG-native — TG has no checkpoint ID concept as of 0.1.0).
  // Used to join llm_calls ↔ extractions_history.traceguard_raw.checkpoint_run_id.
  traceguardCheckpointId: uuid("traceguard_checkpoint_id"),
  status: llmCallStatusEnum("status"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
}, (table) => [
  index("idx_llm_calls_cache").on(table.promptHash, table.inputHash, table.model),
]);

// ============================================================
// H2: pipeline_runs — Pipeline step execution tracking
// ============================================================
export const pipelineRuns = pgTable("pipeline_runs", {
  id: uuid("id").defaultRandom().primaryKey(),
  bookId: uuid("book_id").references(() => books.id),
  paragraphId: uuid("paragraph_id").references(() => rawTexts.id),
  step: pipelineStepEnum("step").notNull(),
  status: pipelineStatusEnum("status").notNull(),
  promptVersion: text("prompt_version"),
  llmCallId: uuid("llm_call_id").references(() => llmCalls.id),
  startedAt: timestamp("started_at", { withTimezone: true }),
  endedAt: timestamp("ended_at", { withTimezone: true }),
  error: text("error"),
}, (table) => [
  uniqueIndex("idx_pipeline_run_unique").on(table.paragraphId, table.step, table.promptVersion),
  index("idx_pipeline_status").on(table.status, table.step),
]);

// ============================================================
// H3: extractions_history — Extraction results by prompt version (C-11)
// ============================================================
export const extractionsHistory = pgTable("extractions_history", {
  id: uuid("id").defaultRandom().primaryKey(),
  pipelineRunId: uuid("pipeline_run_id").references(() => pipelineRuns.id),
  paragraphId: uuid("paragraph_id").references(() => rawTexts.id).notNull(),
  step: pipelineStepEnum("step").notNull(),
  promptVersion: text("prompt_version").notNull(),
  output: jsonb("output").notNull(),
  traceguardRaw: jsonb("traceguard_raw"),
  confidence: numeric("confidence", { precision: 4, scale: 3 }),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
}, (table) => [
  uniqueIndex("idx_ext_hist_idempotent").on(table.paragraphId, table.step, table.promptVersion),
]);
