/**
 * Drizzle enum definitions.
 * All TEXT-based enums are centralized here (Q-5 / C-10).
 *
 * We use pgEnum for frequently queried/filtered columns.
 * This provides DB-level CHECK constraints and cleaner types.
 */
import { pgEnum } from "drizzle-orm/pg-core";

// -- Entity-level enums --

export const realityStatusEnum = pgEnum("reality_status", [
  "historical",
  "legendary",
  "mythical",
  "fictional",
  "composite",
  "uncertain",
]);

export const provenanceTierEnum = pgEnum("provenance_tier", [
  "primary_text",
  "scholarly_consensus",
  "ai_inferred",
  "crowdsourced",
  "unverified",
  "seed_dictionary",
]);

// -- Person name types --

export const nameTypeEnum = pgEnum("name_type", [
  "primary",
  "courtesy",
  "art",
  "studio",
  "posthumous",
  "temple",
  "nickname",
  "self_ref",
  "alias",
]);

// -- Identity hypothesis relation types --

export const hypothesisRelationTypeEnum = pgEnum("hypothesis_relation_type", [
  "same_person",
  "possibly_same",
  "conflated",
  "distinct_despite_similar_name",
]);

// -- Event types --

export const eventTypeEnum = pgEnum("event_type", [
  "political",
  "military",
  "cultural",
  "economic",
  "social",
  "religious",
  "diplomatic",
  "natural_disaster",
  "other",
]);

// -- Mention types --

export const mentionTypeEnum = pgEnum("mention_type", [
  "explicit",
  "implicit",
  "allusion",
  "metaphor",
  "pun",
  "pseudonym",
  "title_only",
  "anonymous",
]);

export const mentionEntityTypeEnum = pgEnum("mention_entity_type", [
  "person",
  "place",
  "event",
  "allusion",
  "artifact",
  "institution",
]);

// -- Conflict types --

export const conflictTypeEnum = pgEnum("conflict_type", [
  "factual",
  "chronological",
  "interpretive",
  "omission",
  "attribution",
]);

// -- Book enums --

export const credibilityTierEnum = pgEnum("credibility_tier", [
  "primary_official",
  "primary_unofficial",
  "secondary_compilation",
  "tertiary_reference",
  "folk",
]);

export const bookGenreEnum = pgEnum("book_genre", [
  "official_history",
  "unofficial_history",
  "poetry",
  "philosophy",
  "classic",
  "geography",
  "military",
  "medical",
  "encyclopedia",
  "other",
]);

export const licenseEnum = pgEnum("license", [
  "CC0",
  "CC-BY",
  "public_domain",
  "proprietary",
  "unknown",
]);

// -- Relationship types --

export const relationshipTypeEnum = pgEnum("relationship_type", [
  "parent_child",
  "spouse",
  "sibling",
  "teacher_student",
  "lord_vassal",
  "ally",
  "enemy",
  "colleague",
  "other",
]);

// -- Mention inference basis --

export const inferenceBasisEnum = pgEnum("inference_basis", [
  "rule",
  "context",
  "llm",
  "human",
]);

// -- Allusion semantic shift --

export const semanticShiftEnum = pgEnum("semantic_shift", [
  "faithful",
  "extended",
  "ironic",
  "subverted",
]);

// -- Intertextual link types --

export const intertextualLinkTypeEnum = pgEnum("intertextual_link_type", [
  "quote",
  "paraphrase",
  "rebuttal",
  "imitation",
  "parody",
]);

// -- Variant char types --

export const variantCharTypeEnum = pgEnum("variant_char_type", [
  "simplified",
  "traditional",
  "tongjia",
  "yitizi",
  "taboo",
]);

// -- Textual note types --

export const textualNoteTypeEnum = pgEnum("textual_note_type", [
  "emendation",
  "annotation",
  "parallelism",
  "commentary",
]);

// -- Text diff types --

export const diffTypeEnum = pgEnum("diff_type", [
  "char",
  "word",
  "phrase",
  "structure",
]);

// -- Place admin levels --

export const adminLevelEnum = pgEnum("admin_level", [
  "dao",
  "lu",
  "fu",
  "zhou",
  "jun",
  "xian",
  "guan",
  "other",
]);

// -- Pipeline enums --

export const pipelineStepEnum = pgEnum("pipeline_step", [
  "ingestion",
  "preprocessing",
  "ner",
  "relations",
  "events",
  "disambiguation",
  "geocoding",
  "validation",
]);

export const pipelineStatusEnum = pgEnum("pipeline_status", [
  "pending",
  "running",
  "success",
  "failure",
  "skipped",
]);

export const llmCallStatusEnum = pgEnum("llm_call_status", [
  "success",
  "failure",
  "retry",
  "degraded",
]);

// -- Feedback types --

export const feedbackTypeEnum = pgEnum("feedback_type", [
  "factual_error",
  "misleading",
  "missing_evidence",
  "suggestion",
  "praise",
]);

// -- Entity revision actor types --

export const actorTypeEnum = pgEnum("actor_type", [
  "llm",
  "rule",
  "human",
  "pipeline",
]);
