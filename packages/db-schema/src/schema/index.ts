/**
 * Unified re-export of all Drizzle schema tables.
 * Import from "@huadian/db-schema" to access all tables.
 */

// Enums
export * from "./enums";

// Common column helpers
export * from "./common";

// A layer — Text & Source
export {
  books,
  rawTexts,
  sourceEvidences,
  evidenceLinks,
  textualNotes,
  textVariants,
  variantChars,
} from "./sources";

// B layer — Identity
export {
  persons,
  personNames,
  identityHypotheses,
  disambiguationSeeds,
  roleAppellations,
} from "./persons";

// C layer — Events
export {
  events,
  eventAccounts,
  accountConflicts,
  eventCausality,
} from "./events";

// D layer — Geography & Time
export {
  places,
  placeNames,
  placeHierarchies,
  polities,
  reignEras,
} from "./places";

// E layer — Relations & References
export {
  relationships,
  mentions,
  allusions,
  allusionEvolution,
  allusionUsages,
  intertextualLinks,
  institutions,
  institutionChanges,
} from "./relations";

// F layer — Artifacts
export { artifacts } from "./artifacts";

// G layer — Embeddings & Audit
export {
  entityEmbeddings,
  entityRevisions,
} from "./embeddings";

// H layer — Pipeline & LLM
export {
  llmCalls,
  pipelineRuns,
  extractionsHistory,
} from "./pipeline";

// I layer — Feedback
export { feedback } from "./feedback";

// J layer — Dictionary Seeds
export {
  dictionarySources,
  dictionaryEntries,
  seedMappings,
} from "./seeds";

// K layer — Pending Merge Reviews (guard-blocked candidates)
export { pendingMergeReviews } from "./pendingMergeReviews";

// L layer — Entity Split Log (ADR-026 audit)
export { entitySplitLog } from "./entitySplitLog";

// M layer — Triage Decisions (ADR-027 historian triage UI)
export { triageDecisions } from "./triageDecisions";
