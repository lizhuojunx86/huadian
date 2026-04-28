/* eslint-disable */
import type { TypedDocumentNode as DocumentNode } from '@graphql-typed-document-node/core';
export type Maybe<T> = T | null;
export type InputMaybe<T> = T | null | undefined;
export type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]?: Maybe<T[SubKey]> };
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]: Maybe<T[SubKey]> };
export type MakeEmpty<T extends { [key: string]: unknown }, K extends keyof T> = { [_ in K]?: never };
export type Incremental<T> = T | { [P in keyof T]?: P extends ' $fragmentName' | '__typename' ? T[P] : never };
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: { input: string; output: string; }
  String: { input: string; output: string; }
  Boolean: { input: boolean; output: boolean; }
  Int: { input: number; output: number; }
  Float: { input: number; output: number; }
  /**
   * ISO 8601 date-time string (UTC, e.g. 2026-04-16T11:16:00Z).
   * Provided by graphql-scalars' DateTimeResolver.
   */
  DateTime: { input: string; output: string; }
  /**
   * Arbitrary JSON value. Use sparingly — prefer concrete types.
   * Provided by graphql-scalars' JSONResolver.
   */
  JSON: { input: unknown; output: unknown; }
  /**
   * Positive integer (>= 1).
   * Provided by graphql-scalars' PositiveIntResolver.
   */
  PositiveInt: { input: number; output: number; }
  /**
   * RFC 4122 UUID string (v4).
   * Provided by graphql-scalars' UUIDResolver.
   */
  UUID: { input: string; output: string; }
};

/**
 * AccountConflict — structured disagreement between two EventAccounts.
 * Replaces v1 version_conflicts (architect Q-2 on T-P0-002). Required for
 * the dual-account story to be usable (architect T-P0-003 #4).
 *
 * diffSummary / analysis remain JSON at Phase 0; a concrete type will be
 * defined alongside the conflict-resolution UI in Phase 1.
 */
export type AccountConflict = {
  __typename?: 'AccountConflict';
  accountAId: Scalars['UUID']['output'];
  accountBId: Scalars['UUID']['output'];
  analysis?: Maybe<Scalars['JSON']['output']>;
  conflictType?: Maybe<ConflictType>;
  createdAt: Scalars['DateTime']['output'];
  diffSummary?: Maybe<Scalars['JSON']['output']>;
  eventId: Scalars['UUID']['output'];
  id: Scalars['ID']['output'];
};

/** Administrative level for historical places / polities (D layer). */
export type AdminLevel =
  | 'dao'
  | 'fu'
  | 'guan'
  | 'jun'
  | 'lu'
  | 'other'
  | 'xian'
  | 'zhou';

/**
 * Book — ancient text metadata (one row per distinct work).
 * Backs packages/db-schema/src/schema/sources.ts → books.
 *
 * Traceable compliance note:
 *   The books table does not carry a dedicated provenanceTier column; the
 *   Traceable.provenanceTier resolver defaults to primary_text (a Book IS the
 *   primary source) and MAY be narrowed by a future resolver that reads
 *   credibilityTier → provenanceTier mapping. sourceEvidenceId resolves to
 *   a representative evidence row for the book (subtask 4 stubs as
 *   NOT_IMPLEMENTED).
 *
 * License note:
 *   The shared-types licenseEnum includes the value "CC-BY" which contains
 *   a hyphen that is illegal in GraphQL enum values. The field is therefore
 *   exposed as String here; resolver guarantees the value matches one of
 *   CC0 / CC-BY / public_domain / proprietary / unknown. A future ADR will
 *   decide whether to rename the shared-types case to CC_BY so we can lift
 *   this back to a typed enum (tracked as L-1 in subtask 7 docs).
 */
export type Book = Traceable & {
  __typename?: 'Book';
  authorPersonId?: Maybe<Scalars['UUID']['output']>;
  authoritativeVersion?: Maybe<Scalars['String']['output']>;
  credibilityTier: CredibilityTier;
  dynasty?: Maybe<Scalars['String']['output']>;
  genre?: Maybe<BookGenre>;
  id: Scalars['ID']['output'];
  license: Scalars['String']['output'];
  metadata?: Maybe<Scalars['JSON']['output']>;
  provenanceTier: ProvenanceTier;
  slug: Scalars['String']['output'];
  sourceEvidenceId?: Maybe<Scalars['ID']['output']>;
  title: MultiLangText;
  updatedAt: Scalars['DateTime']['output'];
};

/** Book genre (A layer). */
export type BookGenre =
  | 'classic'
  | 'encyclopedia'
  | 'geography'
  | 'medical'
  | 'military'
  | 'official_history'
  | 'other'
  | 'philosophy'
  | 'poetry'
  | 'unofficial_history';

/**
 * Conflict type between two event accounts (C layer).
 * Backs account_conflicts.conflict_type.
 */
export type ConflictType =
  | 'attribution'
  | 'chronological'
  | 'factual'
  | 'interpretive'
  | 'omission';

/** Book credibility tier (A layer). */
export type CredibilityTier =
  | 'folk'
  | 'primary_official'
  | 'primary_unofficial'
  | 'secondary_compilation'
  | 'tertiary_reference';

/**
 * Date precision classifier used by HistoricalDate.precision.
 * Case MUST match the "precision" enum in
 * packages/shared-types/src/historical-date.ts (R-1 mirror rule extended
 * to shared value types).
 */
export type DatePrecision =
  | 'day'
  | 'decade'
  | 'era'
  | 'month'
  | 'unknown'
  | 'year'
  | 'year_range';

/**
 * DictionaryEntry — projection of `dictionary_entries` row used by
 * SeedMappingTriage detail page. Read-only.
 */
export type DictionaryEntry = {
  __typename?: 'DictionaryEntry';
  aliases?: Maybe<Scalars['JSON']['output']>;
  attributes: Scalars['JSON']['output'];
  entryType: Scalars['String']['output'];
  externalId: Scalars['String']['output'];
  id: Scalars['ID']['output'];
  primaryName?: Maybe<Scalars['String']['output']>;
  source: DictionarySource;
};

/**
 * DictionarySource — projection of `dictionary_sources` row used by
 * SeedMappingTriage detail page. Read-only (no Mutation paths in V1).
 */
export type DictionarySource = {
  __typename?: 'DictionarySource';
  commercialSafe: Scalars['Boolean']['output'];
  id: Scalars['ID']['output'];
  license: Scalars['String']['output'];
  sourceName: Scalars['String']['output'];
  sourceVersion: Scalars['String']['output'];
};

/**
 * Event — abstract event anchor (see ADR-002). One Event may have multiple
 * EventAccount narratives across different source texts; AccountConflict
 * records structured disagreements between two accounts.
 * Backs packages/db-schema/src/schema/events.ts → events.
 *
 * Related collections (resolved lazily, DataLoader territory per architect #3):
 *   - accounts:  [EventAccount!]!     event_accounts WHERE event_id = this.id
 *   - conflicts: [AccountConflict!]!  account_conflicts WHERE event_id = this.id
 */
export type Event = Traceable & {
  __typename?: 'Event';
  accounts: Array<EventAccount>;
  canonicalAccountId?: Maybe<Scalars['UUID']['output']>;
  conflicts: Array<AccountConflict>;
  eventType?: Maybe<EventType>;
  id: Scalars['ID']['output'];
  importanceScore?: Maybe<Scalars['Float']['output']>;
  placeId?: Maybe<Scalars['UUID']['output']>;
  provenanceTier: ProvenanceTier;
  realityStatus: RealityStatus;
  significance?: Maybe<MultiLangText>;
  slug: Scalars['String']['output'];
  sourceEvidenceId?: Maybe<Scalars['ID']['output']>;
  summary?: Maybe<MultiLangText>;
  timePeriodEnd?: Maybe<HistoricalDate>;
  timePeriodStart?: Maybe<HistoricalDate>;
  title: MultiLangText;
  updatedAt: Scalars['DateTime']['output'];
};

/**
 * EventAccount — one specific narrative of an Event from one source.
 * ADR-002 core table: multi-account coexistence is a constitutional
 * requirement (C-3).
 *
 * JSONB embedded fields (participants / places / sequence) are modeled as
 * typed GraphQL Object Types mirroring shared-types zod schemas; the key
 * mapping from snake_case persisted keys (person_id, place_id) to
 * camelCase GraphQL fields (personId, placeId) happens in resolvers.
 */
export type EventAccount = {
  __typename?: 'EventAccount';
  createdAt: Scalars['DateTime']['output'];
  eventId: Scalars['UUID']['output'];
  id: Scalars['ID']['output'];
  isCanonical: Scalars['Boolean']['output'];
  narrative: MultiLangText;
  participants: Array<EventParticipantRef>;
  places: Array<EventPlaceRef>;
  provenanceTier: ProvenanceTier;
  reliabilityScore?: Maybe<Scalars['Float']['output']>;
  sequence: Array<EventSequenceStep>;
  sourceBookId?: Maybe<Scalars['UUID']['output']>;
  sourceEvidenceIds: Array<Scalars['UUID']['output']>;
  updatedAt: Scalars['DateTime']['output'];
};

/** Participant within an EventAccount narrative. */
export type EventParticipantRef = {
  __typename?: 'EventParticipantRef';
  action?: Maybe<Scalars['String']['output']>;
  personId: Scalars['UUID']['output'];
  role: Scalars['String']['output'];
};

/** Place reference within an EventAccount narrative. */
export type EventPlaceRef = {
  __typename?: 'EventPlaceRef';
  placeId: Scalars['UUID']['output'];
  role: Scalars['String']['output'];
};

/** Ordered step inside the sequence of an EventAccount. */
export type EventSequenceStep = {
  __typename?: 'EventSequenceStep';
  description: MultiLangText;
  order: Scalars['Int']['output'];
  time?: Maybe<HistoricalDate>;
};

/** Event type (C layer). */
export type EventType =
  | 'cultural'
  | 'diplomatic'
  | 'economic'
  | 'military'
  | 'natural_disaster'
  | 'other'
  | 'political'
  | 'religious'
  | 'social';

/**
 * GuardBlockedMergeTriage — pending row from `pending_merge_reviews`
 * (status='pending'). Surface = a stable representative name from the pair
 * (resolver convention: shorter of personA/personB primary name).
 */
export type GuardBlockedMergeTriage = Traceable & TriageItem & {
  __typename?: 'GuardBlockedMergeTriage';
  evidence: Scalars['JSON']['output'];
  guardPayload: Scalars['JSON']['output'];
  guardType: Scalars['String']['output'];
  historicalDecisions: Array<TriageDecision>;
  id: Scalars['ID']['output'];
  pendingSince: Scalars['DateTime']['output'];
  personA: Person;
  personB: Person;
  proposedRule: Scalars['String']['output'];
  provenanceTier: ProvenanceTier;
  sourceEvidenceId?: Maybe<Scalars['ID']['output']>;
  sourceId: Scalars['ID']['output'];
  sourceTable: Scalars['String']['output'];
  suggestedDecision?: Maybe<TriageDecisionType>;
  surface: Scalars['String']['output'];
  updatedAt: Scalars['DateTime']['output'];
};

/**
 * HistoricalDate — flexible historical date model that supports open-ended
 * ranges, lunar calendar, sexagenary cycle, and reign-era references.
 * Mirrors the JSONB structure defined by historicalDateSchema in
 * @huadian/shared-types.
 *
 * Field name mapping (GraphQL camelCase ↔ JSONB snake_case):
 *   yearMin         ↔  year_min
 *   yearMax         ↔  year_max
 *   reignEra        ↔  reign_era
 *   reignYear       ↔  reign_year
 *   polityId        ↔  polity_id
 *   lunarMonth      ↔  lunar_month
 *   lunarDay        ↔  lunar_day
 *   sexagenaryYear  ↔  sexagenary_year
 *   originalText    ↔  original_text
 */
export type HistoricalDate = {
  __typename?: 'HistoricalDate';
  day?: Maybe<Scalars['Int']['output']>;
  lunarDay?: Maybe<Scalars['Int']['output']>;
  lunarMonth?: Maybe<Scalars['Int']['output']>;
  month?: Maybe<Scalars['Int']['output']>;
  originalText?: Maybe<Scalars['String']['output']>;
  polityId?: Maybe<Scalars['UUID']['output']>;
  precision: DatePrecision;
  reignEra?: Maybe<Scalars['String']['output']>;
  reignYear?: Maybe<Scalars['PositiveInt']['output']>;
  season?: Maybe<Scalars['String']['output']>;
  sexagenaryYear?: Maybe<Scalars['String']['output']>;
  yearMax?: Maybe<Scalars['Int']['output']>;
  yearMin?: Maybe<Scalars['Int']['output']>;
};

/**
 * Identity hypothesis relation type (B layer).
 * See docs/02 §2.2 for examples (Laozi / Li Er / Lao Laizi).
 */
export type HypothesisRelationType =
  | 'conflated'
  | 'distinct_despite_similar_name'
  | 'possibly_same'
  | 'same_person';

/**
 * IdentityHypothesis — scholarly hypothesis about whether two Person
 * records refer to the same historical figure (e.g. Laozi / Li Er /
 * Lao Laizi). See docs/02 §2.2 and ADR-001.
 *
 * evidenceIds is a JSONB string[] of source_evidences.id UUIDs backing
 * the hypothesis; the architect #3 ruling defers turning this into an
 * embedded SourceEvidence collection to a later DataLoader pass.
 */
export type IdentityHypothesis = {
  __typename?: 'IdentityHypothesis';
  acceptedByDefault?: Maybe<Scalars['Boolean']['output']>;
  canonicalPersonId: Scalars['UUID']['output'];
  createdAt: Scalars['DateTime']['output'];
  evidenceIds: Array<Scalars['UUID']['output']>;
  hypothesisPersonId?: Maybe<Scalars['UUID']['output']>;
  id: Scalars['ID']['output'];
  notes?: Maybe<Scalars['String']['output']>;
  relationType: HypothesisRelationType;
  scholarlySupport?: Maybe<Scalars['String']['output']>;
};

/**
 * Multi-language text for user-facing display fields (constitutional
 * requirement C-12). Mirrors the JSONB structure defined by
 * multiLangTextSchema in @huadian/shared-types.
 *
 * Field name mapping between GraphQL (camelCase) and the persisted JSONB
 * keys (language tags with hyphens):
 *   zhHans  ↔  "zh-Hans"  (REQUIRED in source data)
 *   zhHant  ↔  "zh-Hant"
 *   en      ↔  "en"
 */
export type MultiLangText = {
  __typename?: 'MultiLangText';
  en?: Maybe<Scalars['String']['output']>;
  zhHans: Scalars['String']['output'];
  zhHant?: Maybe<Scalars['String']['output']>;
};

/**
 * Project-first Mutation root (T-P0-028 / ADR-027 §4.6). Constitutional
 * C-2 mandate to return provenanceTier on every mutation is waived for
 * this triage decision write per ADR-027 §4.6 (mutation operates on
 * audit metadata, not on traceable content entities).
 */
export type Mutation = {
  __typename?: 'Mutation';
  /**
   * Record a historian decision against a pending triage item.
   *
   * V1 zero-downstream: writes a row into triage_decisions and computes the
   * next pending item for the inbox redirect; does NOT mutate the source
   * table (seed_mappings / pending_merge_reviews stay untouched per
   * ADR-027 §2.5 + §5 merge-iron-rule).
   *
   * Errors are returned via payload.error (not thrown) so that the FE
   * Server Action can render a structured form-level error without
   * navigation.
   */
  recordTriageDecision: RecordTriageDecisionPayload;
};


/**
 * Project-first Mutation root (T-P0-028 / ADR-027 §4.6). Constitutional
 * C-2 mandate to return provenanceTier on every mutation is waived for
 * this triage decision write per ADR-027 §4.6 (mutation operates on
 * audit metadata, not on traceable content entities).
 */
export type MutationRecordTriageDecisionArgs = {
  input: RecordTriageDecisionInput;
};

/** Person name type (B layer). */
export type NameType =
  | 'alias'
  | 'art'
  | 'courtesy'
  | 'nickname'
  | 'posthumous'
  | 'primary'
  | 'self_ref'
  | 'studio'
  | 'temple';

/**
 * Person — canonical identity (one row per disambiguated historical or
 * legendary person). Backs packages/db-schema/src/schema/persons.ts → persons.
 *
 * Related collections (resolved lazily, DataLoader territory per architect #3):
 *   - names:              [PersonName!]!           person_names WHERE person_id = this.id
 *   - identityHypotheses: [IdentityHypothesis!]!   identity_hypotheses WHERE canonical_person_id = this.id
 */
export type Person = Traceable & {
  __typename?: 'Person';
  biography?: Maybe<MultiLangText>;
  birthDate?: Maybe<HistoricalDate>;
  deathDate?: Maybe<HistoricalDate>;
  dynasty?: Maybe<Scalars['String']['output']>;
  id: Scalars['ID']['output'];
  identityHypotheses: Array<IdentityHypothesis>;
  name: MultiLangText;
  names: Array<PersonName>;
  provenanceTier: ProvenanceTier;
  realityStatus: RealityStatus;
  slug: Scalars['String']['output'];
  sourceEvidenceId?: Maybe<Scalars['ID']['output']>;
  updatedAt: Scalars['DateTime']['output'];
};

/**
 * PersonName — one of multiple historical appellations for a Person
 * (courtesy name, posthumous name, nickname, etc.). The canonical name is
 * expressed on Person.name (MultiLangText); PersonName.name is the raw
 * historical string (kept as TEXT per architect Q-3 ruling on T-P0-002).
 *
 * Does not implement Traceable because sourceEvidenceId is nullable here.
 */
export type PersonName = {
  __typename?: 'PersonName';
  createdAt: Scalars['DateTime']['output'];
  endYear?: Maybe<Scalars['Int']['output']>;
  id: Scalars['ID']['output'];
  isPrimary?: Maybe<Scalars['Boolean']['output']>;
  name: Scalars['String']['output'];
  namePinyin?: Maybe<Scalars['String']['output']>;
  nameType: NameType;
  personId: Scalars['UUID']['output'];
  sourceEvidenceId?: Maybe<Scalars['UUID']['output']>;
  startYear?: Maybe<Scalars['Int']['output']>;
};

/** Paginated search result for persons. Returned by Query.persons. */
export type PersonSearchResult = {
  __typename?: 'PersonSearchResult';
  /** True when there are more rows beyond the current page. */
  hasMore: Scalars['Boolean']['output'];
  /** Matching Person rows for the current page. */
  items: Array<Person>;
  /** Total number of matching rows (across all pages). */
  total: Scalars['Int']['output'];
};

/**
 * Place — geographic entity. The PostGIS GEOMETRY column is exposed here
 * as the opaque JSON scalar for Phase 0 (task card explicit non-goal);
 * a typed Geometry model will be introduced in a Phase 1 ADR.
 *
 * Related collections (resolved lazily, DataLoader territory per architect #3):
 *   - names: [PlaceName!]!  place_names WHERE place_id = this.id
 */
export type Place = Traceable & {
  __typename?: 'Place';
  ancientName?: Maybe<Scalars['String']['output']>;
  fuzziness?: Maybe<Scalars['Float']['output']>;
  geometry?: Maybe<Scalars['JSON']['output']>;
  id: Scalars['ID']['output'];
  modernCountry?: Maybe<Scalars['String']['output']>;
  modernName?: Maybe<MultiLangText>;
  names: Array<PlaceName>;
  provenanceTier: ProvenanceTier;
  realityStatus: RealityStatus;
  slug: Scalars['String']['output'];
  sourceEvidenceId?: Maybe<Scalars['ID']['output']>;
  updatedAt: Scalars['DateTime']['output'];
};

/**
 * PlaceName — a historical name for a Place valid during a specific
 * dynasty / year range. name stays as raw TEXT per architect Q-3 on
 * T-P0-002 (historical proper nouns are not translated).
 *
 * Does not implement Traceable because sourceEvidenceId is nullable here.
 */
export type PlaceName = {
  __typename?: 'PlaceName';
  createdAt: Scalars['DateTime']['output'];
  dynasty?: Maybe<Scalars['String']['output']>;
  geometryVariant?: Maybe<Scalars['JSON']['output']>;
  id: Scalars['ID']['output'];
  name: Scalars['String']['output'];
  placeId: Scalars['UUID']['output'];
  sourceEvidenceId?: Maybe<Scalars['UUID']['output']>;
  yearEnd?: Maybe<Scalars['Int']['output']>;
  yearStart?: Maybe<Scalars['Int']['output']>;
};

/**
 * Polity — dynasty or political entity (e.g. 秦, 西汉, 新, 更始, 东汉).
 * Backed by the T-P0-004 batch-1 seed data.
 */
export type Polity = {
  __typename?: 'Polity';
  capitalPlaceId?: Maybe<Scalars['UUID']['output']>;
  createdAt: Scalars['DateTime']['output'];
  dynasty?: Maybe<Scalars['String']['output']>;
  id: Scalars['ID']['output'];
  metadata?: Maybe<Scalars['JSON']['output']>;
  name: MultiLangText;
  slug: Scalars['String']['output'];
  updatedAt: Scalars['DateTime']['output'];
  yearEnd?: Maybe<Scalars['Int']['output']>;
  yearStart?: Maybe<Scalars['Int']['output']>;
};

/**
 * Provenance tier — constitutional requirement C-2.
 * Required by the Traceable interface (R-1).
 */
export type ProvenanceTier =
  | 'ai_inferred'
  | 'crowdsourced'
  | 'primary_text'
  | 'scholarly_consensus'
  | 'unverified';

export type Query = {
  __typename?: 'Query';
  /**
   * Returns the merged SDL snapshot build identifier.
   * Used by CI smoke and local health checks.
   */
  _schemaVersion: Scalars['String']['output'];
  /** Fetch one Event by stable slug. Returns null when absent. */
  event?: Maybe<Event>;
  /**
   * List pending triage items, ordered by surface cluster + FIFO inside cluster
   * (ADR-027 §2.3 inbox V1 algorithm).
   *
   * filterByType narrows to one implementing type; filterBySurface narrows to
   * exact surface match (used by detail page hint banner cross-reference).
   */
  pendingTriageItems: TriageItemConnection;
  /**
   * Fetch one Person by stable slug (C-13). Returns null when the slug
   * does not match any non-deleted row; an explicit NOT_FOUND error is
   * NOT raised, so that callers can distinguish "absent" from "server
   * error" without inspecting extensions.
   */
  person?: Maybe<Person>;
  /**
   * Fetch one Person by UUID (BE inventory §3.1 推荐). Resolves merged
   * persons to canonical via merged_into_id chain (max 5 hops). Returns
   * null when not found or chain ends in a deleted non-merged person.
   */
  personById?: Maybe<Person>;
  /**
   * Search and list Persons with offset-based pagination.
   *
   * Arguments:
   *   search optional text query; triggers pg_trgm similarity search
   *          on person_names.name (threshold 0.3) and ILIKE on
   *          persons.name->>'zh-Hans'. When omitted or empty, returns
   *          all persons ordered by created_at DESC.
   *   limit  maximum rows to return; clamped to [1, 100] server-side.
   *   offset number of rows to skip; MUST be non-negative.
   */
  persons: PersonSearchResult;
  /** Fetch one Place by stable slug. Returns null when absent. */
  place?: Maybe<Place>;
  /**
   * Fetch one SourceEvidence by UUID. SourceEvidence is keyed by UUID
   * (not slug) because individual quoted passages do not carry stable
   * human-readable identifiers.
   */
  sourceEvidence?: Maybe<SourceEvidence>;
  /**
   * Aggregate counts for the knowledge graph. Live COUNT queries
   * (no materialized view). Phase 0 scale (~200 persons) is fine.
   */
  stats: Stats;
  /**
   * Cross-sprint historical decisions for a given surface text. Powers the
   * detail page hint banner (ADR-027 §2.3 痛点 #1).
   */
  triageDecisionsForSurface: Array<TriageDecision>;
  /**
   * Fetch one triage item by id. The id is the GraphQL ID emitted by the
   * pendingTriageItems query (composite of source_table + source_id, see
   * resolver). Returns null when the source row is no longer pending.
   */
  triageItem?: Maybe<TriageItem>;
};


export type QueryEventArgs = {
  slug: Scalars['String']['input'];
};


export type QueryPendingTriageItemsArgs = {
  filterBySurface?: InputMaybe<Scalars['String']['input']>;
  filterByType?: InputMaybe<TriageItemTypeFilter>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
};


export type QueryPersonArgs = {
  slug: Scalars['String']['input'];
};


export type QueryPersonByIdArgs = {
  id: Scalars['ID']['input'];
};


export type QueryPersonsArgs = {
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
  search?: InputMaybe<Scalars['String']['input']>;
};


export type QueryPlaceArgs = {
  slug: Scalars['String']['input'];
};


export type QuerySourceEvidenceArgs = {
  id: Scalars['UUID']['input'];
};


export type QueryTriageDecisionsForSurfaceArgs = {
  limit?: InputMaybe<Scalars['Int']['input']>;
  surface: Scalars['String']['input'];
};


export type QueryTriageItemArgs = {
  id: Scalars['ID']['input'];
};

/**
 * Reality status — applied to persons, events, places, etc.
 * Distinguishes historical records from legend / myth / fiction / composite
 * identities / unknown-category entities.
 */
export type RealityStatus =
  | 'composite'
  | 'fictional'
  | 'historical'
  | 'legendary'
  | 'mythical'
  | 'uncertain';

/**
 * Input for Mutation.recordTriageDecision. historianId is validated against
 * apps/web/lib/historian-allowlist.yaml server-side (ADR-027 §2.4).
 */
export type RecordTriageDecisionInput = {
  decision: TriageDecisionType;
  historianId: Scalars['String']['input'];
  itemId: Scalars['ID']['input'];
  reasonSourceType?: InputMaybe<Scalars['String']['input']>;
  reasonText?: InputMaybe<Scalars['String']['input']>;
};

/**
 * Payload for Mutation.recordTriageDecision. nextPendingItemId enables
 * the FE inbox redirect (ADR-027 §2.3); null if the queue is empty after
 * this decision.
 */
export type RecordTriageDecisionPayload = {
  __typename?: 'RecordTriageDecisionPayload';
  error?: Maybe<TriageDecisionError>;
  nextPendingItemId?: Maybe<Scalars['ID']['output']>;
  triageDecision?: Maybe<TriageDecision>;
};

/**
 * ReignEra — named era (年号) within a Polity (e.g. 建元, 元封).
 * name stays as raw TEXT per architect Q-3 on T-P0-002.
 */
export type ReignEra = {
  __typename?: 'ReignEra';
  createdAt: Scalars['DateTime']['output'];
  emperorPersonId?: Maybe<Scalars['UUID']['output']>;
  id: Scalars['ID']['output'];
  name: Scalars['String']['output'];
  polityId: Scalars['UUID']['output'];
  updatedAt: Scalars['DateTime']['output'];
  yearEnd?: Maybe<Scalars['Int']['output']>;
  yearStart: Scalars['Int']['output'];
};

/**
 * SeedMappingTriage — pending review row from `seed_mappings`
 * (mapping_status='pending_review'). Surface = dictionaryEntry.primaryName.
 */
export type SeedMappingTriage = Traceable & TriageItem & {
  __typename?: 'SeedMappingTriage';
  confidence: Scalars['Float']['output'];
  dictionaryEntry: DictionaryEntry;
  historicalDecisions: Array<TriageDecision>;
  id: Scalars['ID']['output'];
  mappingMetadata?: Maybe<Scalars['JSON']['output']>;
  mappingMethod: Scalars['String']['output'];
  pendingSince: Scalars['DateTime']['output'];
  provenanceTier: ProvenanceTier;
  sourceEvidenceId?: Maybe<Scalars['ID']['output']>;
  sourceId: Scalars['ID']['output'];
  sourceTable: Scalars['String']['output'];
  suggestedDecision?: Maybe<TriageDecisionType>;
  surface: Scalars['String']['output'];
  targetPerson: Person;
  updatedAt: Scalars['DateTime']['output'];
};

/**
 * SourceEvidence — atomic unit of provenance (a quoted paragraph from a
 * specific textual version). All other entities link back to this table.
 * Backs packages/db-schema/src/schema/sources.ts → source_evidences.
 *
 * Traceable compliance note:
 *   SourceEvidence self-references: the Traceable.sourceEvidenceId field
 *   resolves to parent.id (evidence IS the evidence). This creates a
 *   deliberate fixed point in the provenance graph.
 */
export type SourceEvidence = Traceable & {
  __typename?: 'SourceEvidence';
  bookId?: Maybe<Scalars['UUID']['output']>;
  id: Scalars['ID']['output'];
  llmCallId?: Maybe<Scalars['UUID']['output']>;
  positionEnd?: Maybe<Scalars['Int']['output']>;
  positionStart?: Maybe<Scalars['Int']['output']>;
  promptVersion?: Maybe<Scalars['String']['output']>;
  provenanceTier: ProvenanceTier;
  quotedText?: Maybe<Scalars['String']['output']>;
  rawTextId?: Maybe<Scalars['UUID']['output']>;
  sourceEvidenceId?: Maybe<Scalars['ID']['output']>;
  textVersion?: Maybe<Scalars['String']['output']>;
  updatedAt: Scalars['DateTime']['output'];
};

/** Platform-level aggregate statistics. */
export type Stats = {
  __typename?: 'Stats';
  /** Number of ingested books. */
  booksCount: Scalars['Int']['output'];
  /** Total number of person name records. */
  namesCount: Scalars['Int']['output'];
  /** Number of canonical (non-merged, non-deleted) persons. */
  personsCount: Scalars['Int']['output'];
};

/**
 * Traceable — GraphQL-layer enforcement of constitutional article C-2
 * (provenance tracking). Every user-facing entity type MUST implement this
 * interface.
 *
 * Architect ruling R-1 fixes the minimum field set to exactly three fields.
 * Additions / relaxations require a new ADR. The provenanceTier enum case
 * is synced with packages/shared-types/src/enums.ts via codegen; manual
 * edits on either side will be caught by CI.
 */
export type Traceable = {
  provenanceTier: ProvenanceTier;
  sourceEvidenceId?: Maybe<Scalars['ID']['output']>;
  updatedAt: Scalars['DateTime']['output'];
};

/**
 * TriageDecision — projection of `triage_decisions` row (migration 0014 / ADR-027 §3).
 * Multi-row audit per source_id allowed (defer → revisit → approve).
 */
export type TriageDecision = {
  __typename?: 'TriageDecision';
  architectAckRef?: Maybe<Scalars['String']['output']>;
  decidedAt: Scalars['DateTime']['output'];
  decision: TriageDecisionType;
  downstreamApplied: Scalars['Boolean']['output'];
  historianCommitRef?: Maybe<Scalars['String']['output']>;
  historianId: Scalars['String']['output'];
  id: Scalars['ID']['output'];
  reasonSourceType?: Maybe<Scalars['String']['output']>;
  reasonText?: Maybe<Scalars['String']['output']>;
  sourceId: Scalars['ID']['output'];
  sourceTable: Scalars['String']['output'];
  surfaceSnapshot: Scalars['String']['output'];
};

/**
 * Structured error for recordTriageDecision. When non-null, the mutation
 * did not persist; the FE should display message and keep the form state.
 * Codes: UNAUTHORIZED | INVALID_TRANSITION | ITEM_NOT_FOUND | INVALID_REASON_SOURCE_TYPE
 */
export type TriageDecisionError = {
  __typename?: 'TriageDecisionError';
  code: Scalars['String']['output'];
  message: Scalars['String']['output'];
};

/**
 * Decision verdict recorded against a pending triage item. Mirrors the
 * `triage_decisions.decision` CHECK in migration 0014 (lower-case zh values
 * in DB; GraphQL exposes UPPER_CASE per zod-mirror convention).
 */
export type TriageDecisionType =
  | 'APPROVE'
  | 'DEFER'
  | 'REJECT';

/**
 * A pending item awaiting historian triage.
 * Two implementing types as of V1: SeedMappingTriage, GuardBlockedMergeTriage.
 *
 * Implements Traceable (constitutional C-2): provenanceTier + sourceEvidenceId
 * are derived from the underlying source row by the resolver; on derivation
 * failure, fallback is provenanceTier='unverified' / sourceEvidenceId=null.
 *
 * updatedAt is populated from the latest triage_decisions.decided_at if any
 * exist for this source row, falling back to the source row's pendingSince.
 */
export type TriageItem = {
  historicalDecisions: Array<TriageDecision>;
  id: Scalars['ID']['output'];
  pendingSince: Scalars['DateTime']['output'];
  provenanceTier: ProvenanceTier;
  sourceEvidenceId?: Maybe<Scalars['ID']['output']>;
  sourceId: Scalars['ID']['output'];
  sourceTable: Scalars['String']['output'];
  suggestedDecision?: Maybe<TriageDecisionType>;
  surface: Scalars['String']['output'];
  updatedAt: Scalars['DateTime']['output'];
};

/**
 * Paginated queue wrapper for Query.pendingTriageItems. Mirrors
 * PersonSearchResult shape (architect Q-5 ruling A: offset / limit pagination).
 */
export type TriageItemConnection = {
  __typename?: 'TriageItemConnection';
  hasMore: Scalars['Boolean']['output'];
  items: Array<TriageItem>;
  totalCount: Scalars['Int']['output'];
};

/**
 * Filter narrowing the pending triage queue to one implementing type.
 * ALL returns both kinds interleaved (default).
 */
export type TriageItemTypeFilter =
  | 'ALL'
  | 'GUARD_BLOCKED_MERGE'
  | 'SEED_MAPPING';

export type FeaturedPersonQueryVariables = Exact<{
  slug: Scalars['String']['input'];
}>;


export type FeaturedPersonQuery = { __typename?: 'Query', person?: { __typename?: 'Person', id: string, slug: string, dynasty?: string | null, name: { __typename?: 'MultiLangText', zhHans: string, en?: string | null }, biography?: { __typename?: 'MultiLangText', zhHans: string } | null } | null };

export type PersonQueryVariables = Exact<{
  slug: Scalars['String']['input'];
}>;


export type PersonQuery = { __typename?: 'Query', person?: { __typename?: 'Person', id: string, slug: string, dynasty?: string | null, realityStatus: RealityStatus, provenanceTier: ProvenanceTier, name: { __typename?: 'MultiLangText', zhHans: string, zhHant?: string | null, en?: string | null }, birthDate?: { __typename?: 'HistoricalDate', yearMin?: number | null, yearMax?: number | null, precision: DatePrecision, originalText?: string | null, reignEra?: string | null, reignYear?: number | null } | null, deathDate?: { __typename?: 'HistoricalDate', yearMin?: number | null, yearMax?: number | null, precision: DatePrecision, originalText?: string | null, reignEra?: string | null, reignYear?: number | null } | null, biography?: { __typename?: 'MultiLangText', zhHans: string, en?: string | null } | null, names: Array<{ __typename?: 'PersonName', id: string, name: string, namePinyin?: string | null, nameType: NameType, isPrimary?: boolean | null, startYear?: number | null, endYear?: number | null }>, identityHypotheses: Array<{ __typename?: 'IdentityHypothesis', id: string, relationType: HypothesisRelationType, scholarlySupport?: string | null, acceptedByDefault?: boolean | null, notes?: string | null }> } | null };

export type PersonsSearchQueryVariables = Exact<{
  search?: InputMaybe<Scalars['String']['input']>;
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
}>;


export type PersonsSearchQuery = { __typename?: 'Query', persons: { __typename?: 'PersonSearchResult', total: number, hasMore: boolean, items: Array<{ __typename?: 'Person', id: string, slug: string, dynasty?: string | null, realityStatus: RealityStatus, provenanceTier: ProvenanceTier, name: { __typename?: 'MultiLangText', zhHans: string, en?: string | null } }> } };

export type StatsQueryVariables = Exact<{ [key: string]: never; }>;


export type StatsQuery = { __typename?: 'Query', stats: { __typename?: 'Stats', personsCount: number, namesCount: number, booksCount: number } };

export type TriageItemQueryVariables = Exact<{
  id: Scalars['ID']['input'];
}>;


export type TriageItemQuery = { __typename?: 'Query', triageItem?:
    | { __typename: 'GuardBlockedMergeTriage', proposedRule: string, guardType: string, guardPayload: unknown, evidence: unknown, id: string, sourceTable: string, sourceId: string, surface: string, pendingSince: string, updatedAt: string, provenanceTier: ProvenanceTier, sourceEvidenceId?: string | null, suggestedDecision?: TriageDecisionType | null, personA: { __typename?: 'Person', id: string, slug: string, dynasty?: string | null, realityStatus: RealityStatus, name: { __typename?: 'MultiLangText', zhHans: string, en?: string | null }, biography?: { __typename?: 'MultiLangText', zhHans: string } | null }, personB: { __typename?: 'Person', id: string, slug: string, dynasty?: string | null, realityStatus: RealityStatus, name: { __typename?: 'MultiLangText', zhHans: string, en?: string | null }, biography?: { __typename?: 'MultiLangText', zhHans: string } | null }, historicalDecisions: Array<{ __typename?: 'TriageDecision', id: string, decision: TriageDecisionType, decidedAt: string, historianId: string, historianCommitRef?: string | null, architectAckRef?: string | null, reasonText?: string | null, reasonSourceType?: string | null }> }
    | { __typename: 'SeedMappingTriage', confidence: number, mappingMethod: string, mappingMetadata?: unknown | null, id: string, sourceTable: string, sourceId: string, surface: string, pendingSince: string, updatedAt: string, provenanceTier: ProvenanceTier, sourceEvidenceId?: string | null, suggestedDecision?: TriageDecisionType | null, targetPerson: { __typename?: 'Person', id: string, slug: string, dynasty?: string | null, realityStatus: RealityStatus, name: { __typename?: 'MultiLangText', zhHans: string, en?: string | null }, biography?: { __typename?: 'MultiLangText', zhHans: string } | null }, dictionaryEntry: { __typename?: 'DictionaryEntry', id: string, externalId: string, entryType: string, primaryName?: string | null, aliases?: unknown | null, attributes: unknown, source: { __typename?: 'DictionarySource', sourceName: string, sourceVersion: string, license: string } }, historicalDecisions: Array<{ __typename?: 'TriageDecision', id: string, decision: TriageDecisionType, decidedAt: string, historianId: string, historianCommitRef?: string | null, architectAckRef?: string | null, reasonText?: string | null, reasonSourceType?: string | null }> }
   | null };

export type TriageDecisionsForSurfaceQueryVariables = Exact<{
  surface: Scalars['String']['input'];
  limit?: InputMaybe<Scalars['Int']['input']>;
}>;


export type TriageDecisionsForSurfaceQuery = { __typename?: 'Query', triageDecisionsForSurface: Array<{ __typename?: 'TriageDecision', id: string, sourceTable: string, sourceId: string, surfaceSnapshot: string, decision: TriageDecisionType, reasonText?: string | null, reasonSourceType?: string | null, historianId: string, historianCommitRef?: string | null, architectAckRef?: string | null, decidedAt: string, downstreamApplied: boolean }> };

export type PendingTriageItemsQueryVariables = Exact<{
  limit?: InputMaybe<Scalars['Int']['input']>;
  offset?: InputMaybe<Scalars['Int']['input']>;
  filterByType?: InputMaybe<TriageItemTypeFilter>;
  filterBySurface?: InputMaybe<Scalars['String']['input']>;
}>;


export type PendingTriageItemsQuery = { __typename?: 'Query', pendingTriageItems: { __typename?: 'TriageItemConnection', totalCount: number, hasMore: boolean, items: Array<
      | { __typename: 'GuardBlockedMergeTriage', proposedRule: string, guardType: string, id: string, sourceTable: string, sourceId: string, surface: string, pendingSince: string, updatedAt: string, provenanceTier: ProvenanceTier, suggestedDecision?: TriageDecisionType | null, personA: { __typename?: 'Person', id: string, slug: string, dynasty?: string | null, name: { __typename?: 'MultiLangText', zhHans: string } }, personB: { __typename?: 'Person', id: string, slug: string, dynasty?: string | null, name: { __typename?: 'MultiLangText', zhHans: string } }, historicalDecisions: Array<{ __typename?: 'TriageDecision', id: string, decision: TriageDecisionType, decidedAt: string, historianId: string }> }
      | { __typename: 'SeedMappingTriage', confidence: number, mappingMethod: string, id: string, sourceTable: string, sourceId: string, surface: string, pendingSince: string, updatedAt: string, provenanceTier: ProvenanceTier, suggestedDecision?: TriageDecisionType | null, targetPerson: { __typename?: 'Person', id: string, slug: string, dynasty?: string | null, name: { __typename?: 'MultiLangText', zhHans: string } }, dictionaryEntry: { __typename?: 'DictionaryEntry', id: string, externalId: string, primaryName?: string | null, source: { __typename?: 'DictionarySource', sourceName: string } }, historicalDecisions: Array<{ __typename?: 'TriageDecision', id: string, decision: TriageDecisionType, decidedAt: string, historianId: string }> }
    > } };

export type RecordTriageDecisionMutationVariables = Exact<{
  input: RecordTriageDecisionInput;
}>;


export type RecordTriageDecisionMutation = { __typename?: 'Mutation', recordTriageDecision: { __typename?: 'RecordTriageDecisionPayload', nextPendingItemId?: string | null, triageDecision?: { __typename?: 'TriageDecision', id: string, sourceTable: string, sourceId: string, decision: TriageDecisionType, decidedAt: string, historianId: string } | null, error?: { __typename?: 'TriageDecisionError', code: string, message: string } | null } };


export const FeaturedPersonDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"query","name":{"kind":"Name","value":"FeaturedPerson"},"variableDefinitions":[{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"slug"}},"type":{"kind":"NonNullType","type":{"kind":"NamedType","name":{"kind":"Name","value":"String"}}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"person"},"arguments":[{"kind":"Argument","name":{"kind":"Name","value":"slug"},"value":{"kind":"Variable","name":{"kind":"Name","value":"slug"}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"slug"}},{"kind":"Field","name":{"kind":"Name","value":"name"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"zhHans"}},{"kind":"Field","name":{"kind":"Name","value":"en"}}]}},{"kind":"Field","name":{"kind":"Name","value":"dynasty"}},{"kind":"Field","name":{"kind":"Name","value":"biography"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"zhHans"}}]}}]}}]}}]} as unknown as DocumentNode<FeaturedPersonQuery, FeaturedPersonQueryVariables>;
export const PersonDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"query","name":{"kind":"Name","value":"Person"},"variableDefinitions":[{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"slug"}},"type":{"kind":"NonNullType","type":{"kind":"NamedType","name":{"kind":"Name","value":"String"}}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"person"},"arguments":[{"kind":"Argument","name":{"kind":"Name","value":"slug"},"value":{"kind":"Variable","name":{"kind":"Name","value":"slug"}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"slug"}},{"kind":"Field","name":{"kind":"Name","value":"name"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"zhHans"}},{"kind":"Field","name":{"kind":"Name","value":"zhHant"}},{"kind":"Field","name":{"kind":"Name","value":"en"}}]}},{"kind":"Field","name":{"kind":"Name","value":"dynasty"}},{"kind":"Field","name":{"kind":"Name","value":"realityStatus"}},{"kind":"Field","name":{"kind":"Name","value":"provenanceTier"}},{"kind":"Field","name":{"kind":"Name","value":"birthDate"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"yearMin"}},{"kind":"Field","name":{"kind":"Name","value":"yearMax"}},{"kind":"Field","name":{"kind":"Name","value":"precision"}},{"kind":"Field","name":{"kind":"Name","value":"originalText"}},{"kind":"Field","name":{"kind":"Name","value":"reignEra"}},{"kind":"Field","name":{"kind":"Name","value":"reignYear"}}]}},{"kind":"Field","name":{"kind":"Name","value":"deathDate"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"yearMin"}},{"kind":"Field","name":{"kind":"Name","value":"yearMax"}},{"kind":"Field","name":{"kind":"Name","value":"precision"}},{"kind":"Field","name":{"kind":"Name","value":"originalText"}},{"kind":"Field","name":{"kind":"Name","value":"reignEra"}},{"kind":"Field","name":{"kind":"Name","value":"reignYear"}}]}},{"kind":"Field","name":{"kind":"Name","value":"biography"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"zhHans"}},{"kind":"Field","name":{"kind":"Name","value":"en"}}]}},{"kind":"Field","name":{"kind":"Name","value":"names"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"name"}},{"kind":"Field","name":{"kind":"Name","value":"namePinyin"}},{"kind":"Field","name":{"kind":"Name","value":"nameType"}},{"kind":"Field","name":{"kind":"Name","value":"isPrimary"}},{"kind":"Field","name":{"kind":"Name","value":"startYear"}},{"kind":"Field","name":{"kind":"Name","value":"endYear"}}]}},{"kind":"Field","name":{"kind":"Name","value":"identityHypotheses"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"relationType"}},{"kind":"Field","name":{"kind":"Name","value":"scholarlySupport"}},{"kind":"Field","name":{"kind":"Name","value":"acceptedByDefault"}},{"kind":"Field","name":{"kind":"Name","value":"notes"}}]}}]}}]}}]} as unknown as DocumentNode<PersonQuery, PersonQueryVariables>;
export const PersonsSearchDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"query","name":{"kind":"Name","value":"PersonsSearch"},"variableDefinitions":[{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"search"}},"type":{"kind":"NamedType","name":{"kind":"Name","value":"String"}}},{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"limit"}},"type":{"kind":"NamedType","name":{"kind":"Name","value":"Int"}},"defaultValue":{"kind":"IntValue","value":"20"}},{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"offset"}},"type":{"kind":"NamedType","name":{"kind":"Name","value":"Int"}},"defaultValue":{"kind":"IntValue","value":"0"}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"persons"},"arguments":[{"kind":"Argument","name":{"kind":"Name","value":"search"},"value":{"kind":"Variable","name":{"kind":"Name","value":"search"}}},{"kind":"Argument","name":{"kind":"Name","value":"limit"},"value":{"kind":"Variable","name":{"kind":"Name","value":"limit"}}},{"kind":"Argument","name":{"kind":"Name","value":"offset"},"value":{"kind":"Variable","name":{"kind":"Name","value":"offset"}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"items"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"slug"}},{"kind":"Field","name":{"kind":"Name","value":"name"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"zhHans"}},{"kind":"Field","name":{"kind":"Name","value":"en"}}]}},{"kind":"Field","name":{"kind":"Name","value":"dynasty"}},{"kind":"Field","name":{"kind":"Name","value":"realityStatus"}},{"kind":"Field","name":{"kind":"Name","value":"provenanceTier"}}]}},{"kind":"Field","name":{"kind":"Name","value":"total"}},{"kind":"Field","name":{"kind":"Name","value":"hasMore"}}]}}]}}]} as unknown as DocumentNode<PersonsSearchQuery, PersonsSearchQueryVariables>;
export const StatsDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"query","name":{"kind":"Name","value":"Stats"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"stats"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"personsCount"}},{"kind":"Field","name":{"kind":"Name","value":"namesCount"}},{"kind":"Field","name":{"kind":"Name","value":"booksCount"}}]}}]}}]} as unknown as DocumentNode<StatsQuery, StatsQueryVariables>;
export const TriageItemDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"query","name":{"kind":"Name","value":"TriageItem"},"variableDefinitions":[{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"id"}},"type":{"kind":"NonNullType","type":{"kind":"NamedType","name":{"kind":"Name","value":"ID"}}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"triageItem"},"arguments":[{"kind":"Argument","name":{"kind":"Name","value":"id"},"value":{"kind":"Variable","name":{"kind":"Name","value":"id"}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"__typename"}},{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"sourceTable"}},{"kind":"Field","name":{"kind":"Name","value":"sourceId"}},{"kind":"Field","name":{"kind":"Name","value":"surface"}},{"kind":"Field","name":{"kind":"Name","value":"pendingSince"}},{"kind":"Field","name":{"kind":"Name","value":"updatedAt"}},{"kind":"Field","name":{"kind":"Name","value":"provenanceTier"}},{"kind":"Field","name":{"kind":"Name","value":"sourceEvidenceId"}},{"kind":"Field","name":{"kind":"Name","value":"suggestedDecision"}},{"kind":"Field","name":{"kind":"Name","value":"historicalDecisions"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"decision"}},{"kind":"Field","name":{"kind":"Name","value":"decidedAt"}},{"kind":"Field","name":{"kind":"Name","value":"historianId"}},{"kind":"Field","name":{"kind":"Name","value":"historianCommitRef"}},{"kind":"Field","name":{"kind":"Name","value":"architectAckRef"}},{"kind":"Field","name":{"kind":"Name","value":"reasonText"}},{"kind":"Field","name":{"kind":"Name","value":"reasonSourceType"}}]}},{"kind":"InlineFragment","typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"SeedMappingTriage"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"confidence"}},{"kind":"Field","name":{"kind":"Name","value":"mappingMethod"}},{"kind":"Field","name":{"kind":"Name","value":"mappingMetadata"}},{"kind":"Field","name":{"kind":"Name","value":"targetPerson"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"slug"}},{"kind":"Field","name":{"kind":"Name","value":"name"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"zhHans"}},{"kind":"Field","name":{"kind":"Name","value":"en"}}]}},{"kind":"Field","name":{"kind":"Name","value":"dynasty"}},{"kind":"Field","name":{"kind":"Name","value":"realityStatus"}},{"kind":"Field","name":{"kind":"Name","value":"biography"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"zhHans"}}]}}]}},{"kind":"Field","name":{"kind":"Name","value":"dictionaryEntry"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"externalId"}},{"kind":"Field","name":{"kind":"Name","value":"entryType"}},{"kind":"Field","name":{"kind":"Name","value":"primaryName"}},{"kind":"Field","name":{"kind":"Name","value":"aliases"}},{"kind":"Field","name":{"kind":"Name","value":"attributes"}},{"kind":"Field","name":{"kind":"Name","value":"source"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"sourceName"}},{"kind":"Field","name":{"kind":"Name","value":"sourceVersion"}},{"kind":"Field","name":{"kind":"Name","value":"license"}}]}}]}}]}},{"kind":"InlineFragment","typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"GuardBlockedMergeTriage"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"proposedRule"}},{"kind":"Field","name":{"kind":"Name","value":"guardType"}},{"kind":"Field","name":{"kind":"Name","value":"guardPayload"}},{"kind":"Field","name":{"kind":"Name","value":"evidence"}},{"kind":"Field","name":{"kind":"Name","value":"personA"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"slug"}},{"kind":"Field","name":{"kind":"Name","value":"name"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"zhHans"}},{"kind":"Field","name":{"kind":"Name","value":"en"}}]}},{"kind":"Field","name":{"kind":"Name","value":"dynasty"}},{"kind":"Field","name":{"kind":"Name","value":"realityStatus"}},{"kind":"Field","name":{"kind":"Name","value":"biography"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"zhHans"}}]}}]}},{"kind":"Field","name":{"kind":"Name","value":"personB"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"slug"}},{"kind":"Field","name":{"kind":"Name","value":"name"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"zhHans"}},{"kind":"Field","name":{"kind":"Name","value":"en"}}]}},{"kind":"Field","name":{"kind":"Name","value":"dynasty"}},{"kind":"Field","name":{"kind":"Name","value":"realityStatus"}},{"kind":"Field","name":{"kind":"Name","value":"biography"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"zhHans"}}]}}]}}]}}]}}]}}]} as unknown as DocumentNode<TriageItemQuery, TriageItemQueryVariables>;
export const TriageDecisionsForSurfaceDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"query","name":{"kind":"Name","value":"TriageDecisionsForSurface"},"variableDefinitions":[{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"surface"}},"type":{"kind":"NonNullType","type":{"kind":"NamedType","name":{"kind":"Name","value":"String"}}}},{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"limit"}},"type":{"kind":"NamedType","name":{"kind":"Name","value":"Int"}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"triageDecisionsForSurface"},"arguments":[{"kind":"Argument","name":{"kind":"Name","value":"surface"},"value":{"kind":"Variable","name":{"kind":"Name","value":"surface"}}},{"kind":"Argument","name":{"kind":"Name","value":"limit"},"value":{"kind":"Variable","name":{"kind":"Name","value":"limit"}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"sourceTable"}},{"kind":"Field","name":{"kind":"Name","value":"sourceId"}},{"kind":"Field","name":{"kind":"Name","value":"surfaceSnapshot"}},{"kind":"Field","name":{"kind":"Name","value":"decision"}},{"kind":"Field","name":{"kind":"Name","value":"reasonText"}},{"kind":"Field","name":{"kind":"Name","value":"reasonSourceType"}},{"kind":"Field","name":{"kind":"Name","value":"historianId"}},{"kind":"Field","name":{"kind":"Name","value":"historianCommitRef"}},{"kind":"Field","name":{"kind":"Name","value":"architectAckRef"}},{"kind":"Field","name":{"kind":"Name","value":"decidedAt"}},{"kind":"Field","name":{"kind":"Name","value":"downstreamApplied"}}]}}]}}]} as unknown as DocumentNode<TriageDecisionsForSurfaceQuery, TriageDecisionsForSurfaceQueryVariables>;
export const PendingTriageItemsDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"query","name":{"kind":"Name","value":"PendingTriageItems"},"variableDefinitions":[{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"limit"}},"type":{"kind":"NamedType","name":{"kind":"Name","value":"Int"}}},{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"offset"}},"type":{"kind":"NamedType","name":{"kind":"Name","value":"Int"}}},{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"filterByType"}},"type":{"kind":"NamedType","name":{"kind":"Name","value":"TriageItemTypeFilter"}}},{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"filterBySurface"}},"type":{"kind":"NamedType","name":{"kind":"Name","value":"String"}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"pendingTriageItems"},"arguments":[{"kind":"Argument","name":{"kind":"Name","value":"limit"},"value":{"kind":"Variable","name":{"kind":"Name","value":"limit"}}},{"kind":"Argument","name":{"kind":"Name","value":"offset"},"value":{"kind":"Variable","name":{"kind":"Name","value":"offset"}}},{"kind":"Argument","name":{"kind":"Name","value":"filterByType"},"value":{"kind":"Variable","name":{"kind":"Name","value":"filterByType"}}},{"kind":"Argument","name":{"kind":"Name","value":"filterBySurface"},"value":{"kind":"Variable","name":{"kind":"Name","value":"filterBySurface"}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"items"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"__typename"}},{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"sourceTable"}},{"kind":"Field","name":{"kind":"Name","value":"sourceId"}},{"kind":"Field","name":{"kind":"Name","value":"surface"}},{"kind":"Field","name":{"kind":"Name","value":"pendingSince"}},{"kind":"Field","name":{"kind":"Name","value":"updatedAt"}},{"kind":"Field","name":{"kind":"Name","value":"provenanceTier"}},{"kind":"Field","name":{"kind":"Name","value":"suggestedDecision"}},{"kind":"Field","name":{"kind":"Name","value":"historicalDecisions"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"decision"}},{"kind":"Field","name":{"kind":"Name","value":"decidedAt"}},{"kind":"Field","name":{"kind":"Name","value":"historianId"}}]}},{"kind":"InlineFragment","typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"SeedMappingTriage"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"confidence"}},{"kind":"Field","name":{"kind":"Name","value":"mappingMethod"}},{"kind":"Field","name":{"kind":"Name","value":"targetPerson"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"slug"}},{"kind":"Field","name":{"kind":"Name","value":"name"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"zhHans"}}]}},{"kind":"Field","name":{"kind":"Name","value":"dynasty"}}]}},{"kind":"Field","name":{"kind":"Name","value":"dictionaryEntry"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"externalId"}},{"kind":"Field","name":{"kind":"Name","value":"primaryName"}},{"kind":"Field","name":{"kind":"Name","value":"source"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"sourceName"}}]}}]}}]}},{"kind":"InlineFragment","typeCondition":{"kind":"NamedType","name":{"kind":"Name","value":"GuardBlockedMergeTriage"}},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"proposedRule"}},{"kind":"Field","name":{"kind":"Name","value":"guardType"}},{"kind":"Field","name":{"kind":"Name","value":"personA"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"slug"}},{"kind":"Field","name":{"kind":"Name","value":"name"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"zhHans"}}]}},{"kind":"Field","name":{"kind":"Name","value":"dynasty"}}]}},{"kind":"Field","name":{"kind":"Name","value":"personB"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"slug"}},{"kind":"Field","name":{"kind":"Name","value":"name"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"zhHans"}}]}},{"kind":"Field","name":{"kind":"Name","value":"dynasty"}}]}}]}}]}},{"kind":"Field","name":{"kind":"Name","value":"totalCount"}},{"kind":"Field","name":{"kind":"Name","value":"hasMore"}}]}}]}}]} as unknown as DocumentNode<PendingTriageItemsQuery, PendingTriageItemsQueryVariables>;
export const RecordTriageDecisionDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"mutation","name":{"kind":"Name","value":"RecordTriageDecision"},"variableDefinitions":[{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"input"}},"type":{"kind":"NonNullType","type":{"kind":"NamedType","name":{"kind":"Name","value":"RecordTriageDecisionInput"}}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"recordTriageDecision"},"arguments":[{"kind":"Argument","name":{"kind":"Name","value":"input"},"value":{"kind":"Variable","name":{"kind":"Name","value":"input"}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"triageDecision"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"id"}},{"kind":"Field","name":{"kind":"Name","value":"sourceTable"}},{"kind":"Field","name":{"kind":"Name","value":"sourceId"}},{"kind":"Field","name":{"kind":"Name","value":"decision"}},{"kind":"Field","name":{"kind":"Name","value":"decidedAt"}},{"kind":"Field","name":{"kind":"Name","value":"historianId"}}]}},{"kind":"Field","name":{"kind":"Name","value":"nextPendingItemId"}},{"kind":"Field","name":{"kind":"Name","value":"error"},"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"code"}},{"kind":"Field","name":{"kind":"Name","value":"message"}}]}}]}}]}}]} as unknown as DocumentNode<RecordTriageDecisionMutation, RecordTriageDecisionMutationVariables>;
