import { z } from "zod";

// -- Reality status (persons, events, places, etc.) --
export const realityStatusEnum = z.enum([
  "historical",
  "legendary",
  "mythical",
  "fictional",
  "composite",
  "uncertain",
]);
export type RealityStatus = z.infer<typeof realityStatusEnum>;

// -- Provenance tier (C-2 constitutional requirement) --
export const provenanceTierEnum = z.enum([
  "primary_text",
  "scholarly_consensus",
  "ai_inferred",
  "crowdsourced",
  "unverified",
]);
export type ProvenanceTier = z.infer<typeof provenanceTierEnum>;

// -- Person name types --
export const nameTypeEnum = z.enum([
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
export type NameType = z.infer<typeof nameTypeEnum>;

// -- Mention types --
export const mentionTypeEnum = z.enum([
  "explicit",
  "implicit",
  "allusion",
  "metaphor",
  "pun",
  "pseudonym",
  "title_only",
  "anonymous",
]);
export type MentionType = z.infer<typeof mentionTypeEnum>;

// -- Mention entity types --
export const mentionEntityTypeEnum = z.enum([
  "person",
  "place",
  "event",
  "allusion",
  "artifact",
  "institution",
]);
export type MentionEntityType = z.infer<typeof mentionEntityTypeEnum>;

// -- Conflict types (account_conflicts) --
export const conflictTypeEnum = z.enum([
  "factual",
  "chronological",
  "interpretive",
  "omission",
  "attribution",
]);
export type ConflictType = z.infer<typeof conflictTypeEnum>;

// -- Book credibility tiers --
export const credibilityTierEnum = z.enum([
  "primary_official",
  "primary_unofficial",
  "secondary_compilation",
  "tertiary_reference",
  "folk",
]);
export type CredibilityTier = z.infer<typeof credibilityTierEnum>;

// -- Book genre --
export const bookGenreEnum = z.enum([
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
export type BookGenre = z.infer<typeof bookGenreEnum>;

// -- License types --
export const licenseEnum = z.enum([
  "CC0",
  "CC-BY",
  "public_domain",
  "proprietary",
  "unknown",
]);
export type License = z.infer<typeof licenseEnum>;

// -- Inference basis (mentions) --
export const inferenceBasisEnum = z.enum([
  "rule",
  "context",
  "llm",
  "human",
]);
export type InferenceBasis = z.infer<typeof inferenceBasisEnum>;

// -- Allusion semantic shift --
export const semanticShiftEnum = z.enum([
  "faithful",
  "extended",
  "ironic",
  "subverted",
]);
export type SemanticShift = z.infer<typeof semanticShiftEnum>;

// -- Intertextual link types --
export const intertextualLinkTypeEnum = z.enum([
  "quote",
  "paraphrase",
  "rebuttal",
  "imitation",
  "parody",
]);
export type IntertextualLinkType = z.infer<typeof intertextualLinkTypeEnum>;

// -- Variant char types --
export const variantCharTypeEnum = z.enum([
  "simplified",
  "traditional",
  "tongjia",
  "yitizi",
  "taboo",
]);
export type VariantCharType = z.infer<typeof variantCharTypeEnum>;

// -- Textual note types --
export const textualNoteTypeEnum = z.enum([
  "emendation",
  "annotation",
  "parallelism",
  "commentary",
]);
export type TextualNoteType = z.infer<typeof textualNoteTypeEnum>;

// -- Pipeline step --
export const pipelineStepEnum = z.enum([
  "ingestion",
  "preprocessing",
  "ner",
  "relations",
  "events",
  "disambiguation",
  "geocoding",
  "validation",
]);
export type PipelineStep = z.infer<typeof pipelineStepEnum>;

// -- Pipeline run status --
export const pipelineStatusEnum = z.enum([
  "pending",
  "running",
  "success",
  "failure",
  "skipped",
]);
export type PipelineStatus = z.infer<typeof pipelineStatusEnum>;

// -- LLM call status --
export const llmCallStatusEnum = z.enum([
  "success",
  "failure",
  "retry",
  "degraded",
]);
export type LlmCallStatus = z.infer<typeof llmCallStatusEnum>;

// -- Feedback types --
export const feedbackTypeEnum = z.enum([
  "factual_error",
  "misleading",
  "missing_evidence",
  "suggestion",
  "praise",
]);
export type FeedbackType = z.infer<typeof feedbackTypeEnum>;

// -- Entity revision actor types --
export const actorTypeEnum = z.enum([
  "llm",
  "rule",
  "human",
  "pipeline",
]);
export type ActorType = z.infer<typeof actorTypeEnum>;

// -- Relationship types (from v1) --
export const relationshipTypeEnum = z.enum([
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
export type RelationshipType = z.infer<typeof relationshipTypeEnum>;

// -- Event type --
export const eventTypeEnum = z.enum([
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
export type EventType = z.infer<typeof eventTypeEnum>;

// -- Text diff types --
export const diffTypeEnum = z.enum([
  "char",
  "word",
  "phrase",
  "structure",
]);
export type DiffType = z.infer<typeof diffTypeEnum>;

// -- Identity hypothesis relation types --
export const hypothesisRelationTypeEnum = z.enum([
  "same_person",
  "possibly_same",
  "conflated",
  "distinct_despite_similar_name",
]);
export type HypothesisRelationType = z.infer<typeof hypothesisRelationTypeEnum>;

// -- Place admin levels --
export const adminLevelEnum = z.enum([
  "dao",
  "lu",
  "fu",
  "zhou",
  "jun",
  "xian",
  "guan",
  "other",
]);
export type AdminLevel = z.infer<typeof adminLevelEnum>;
