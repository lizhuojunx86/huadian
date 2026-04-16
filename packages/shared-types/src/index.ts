// Core types
export {
  multiLangTextSchema,
  type MultiLangText,
} from "./multi-lang.js";

export {
  historicalDateSchema,
  type HistoricalDate,
} from "./historical-date.js";

// Event account JSONB refs (R-7)
export {
  eventParticipantRefSchema,
  type EventParticipantRef,
  eventPlaceRefSchema,
  type EventPlaceRef,
  eventSequenceStepSchema,
  type EventSequenceStep,
} from "./event-refs.js";

// Enums
export {
  realityStatusEnum,
  type RealityStatus,
  provenanceTierEnum,
  type ProvenanceTier,
  nameTypeEnum,
  type NameType,
  mentionTypeEnum,
  type MentionType,
  mentionEntityTypeEnum,
  type MentionEntityType,
  conflictTypeEnum,
  type ConflictType,
  credibilityTierEnum,
  type CredibilityTier,
  bookGenreEnum,
  type BookGenre,
  licenseEnum,
  type License,
  inferenceBasisEnum,
  type InferenceBasis,
  semanticShiftEnum,
  type SemanticShift,
  intertextualLinkTypeEnum,
  type IntertextualLinkType,
  variantCharTypeEnum,
  type VariantCharType,
  textualNoteTypeEnum,
  type TextualNoteType,
  pipelineStepEnum,
  type PipelineStep,
  pipelineStatusEnum,
  type PipelineStatus,
  llmCallStatusEnum,
  type LlmCallStatus,
  feedbackTypeEnum,
  type FeedbackType,
  actorTypeEnum,
  type ActorType,
  relationshipTypeEnum,
  type RelationshipType,
  eventTypeEnum,
  type EventType,
  diffTypeEnum,
  type DiffType,
  hypothesisRelationTypeEnum,
  type HypothesisRelationType,
  adminLevelEnum,
  type AdminLevel,
} from "./enums.js";

// Legacy — will be replaced when T-P0-002 schema is fully wired
export { personSchema, type Person } from "./person.js";
