/**
 * Triage service — T-P0-028 Sprint K Stage 2.5 / ADR-027 §4-§5.
 *
 * V1 zero-downstream contract (ADR-027 §2.5 + §5):
 *   - listPendingItems / getTriageItem / getDecisionsForSurface read from
 *     seed_mappings + pending_merge_reviews + triage_decisions ONLY
 *   - recordDecision INSERTs into triage_decisions ONLY (does NOT mutate
 *     seed_mappings.mapping_status / pending_merge_reviews.status / persons)
 *   - merge-iron-rule (ADR-014) inheritance: any path that would touch
 *     persons / person_names / merge state is reserved for V2 PE async job
 */
import {
  triageDecisions,
  dictionaryEntries,
  dictionarySources,
  persons,
  sourceEvidences,
} from "@huadian/db-schema";
import { and, desc, eq, sql } from "drizzle-orm";

import type { DrizzleClient } from "../context.js";
import type {
  TriageDecision as GqlTriageDecision,
  TriageDecisionType,
  TriageItemTypeFilter,
  ProvenanceTier,
  RecordTriageDecisionPayload,
  RecordTriageDecisionInput,
  TriageItemConnection,
} from "../__generated__/graphql.js";

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/**
 * Historian allowlist — MUST stay in sync with apps/web/lib/historian-allowlist.yaml
 * (the source-of-truth) and apps/web/lib/historian-allowlist.ts (FE edge-runtime mirror).
 *
 * V2 SSO upgrade path: replace this constant with SSO assertion; the yaml + both
 * mirrors are retired together. Tracked as derivative debt (T-P1-XXX: move to
 * packages/historian-allowlist/ shared package).
 */
const HISTORIAN_ALLOWLIST: ReadonlySet<string> = new Set([
  "chief-historian",
  "backfill-script",
  "e2e-test",
  "historical-backfill",
]);

/**
 * Allowed reasonSourceType values per ADR-027 §3 column comment.
 * NULL is allowed (V1 hist may omit when QUICK_TEMPLATE not used).
 */
const REASON_SOURCE_TYPES: ReadonlySet<string> = new Set([
  "in_chapter",
  "other_classical",
  "wikidata",
  "scholarly",
  "structural",
  "historical-backfill",
]);

const SOURCE_TABLE_SEED = "seed_mappings";
const SOURCE_TABLE_GUARD = "pending_merge_reviews";

// ---------------------------------------------------------------------------
// ID encoding (composite GraphQL ID = `<kind>:<uuid>`)
// ---------------------------------------------------------------------------

type ItemKind = "seed_mapping" | "guard_blocked_merge";

interface DecodedItemId {
  kind: ItemKind;
  sourceId: string;
}

export function encodeTriageItemId(
  kind: ItemKind,
  sourceId: string,
): string {
  return `${kind}:${sourceId}`;
}

export function decodeTriageItemId(itemId: string): DecodedItemId | null {
  const [kind, sourceId, ...rest] = itemId.split(":");
  if (rest.length > 0 || !sourceId) return null;
  if (kind === "seed_mapping" || kind === "guard_blocked_merge") {
    return { kind, sourceId };
  }
  return null;
}

function kindToSourceTable(kind: ItemKind): string {
  return kind === "seed_mapping" ? SOURCE_TABLE_SEED : SOURCE_TABLE_GUARD;
}

// ---------------------------------------------------------------------------
// Drizzle row → GraphQL DTO mappers
// ---------------------------------------------------------------------------

type TriageDecisionRow = typeof triageDecisions.$inferSelect;

function mapDecisionRow(row: TriageDecisionRow): GqlTriageDecision {
  return {
    id: row.id,
    sourceTable: row.sourceTable,
    sourceId: row.sourceId,
    surfaceSnapshot: row.surfaceSnapshot,
    decision: dbDecisionToGql(row.decision),
    reasonText: row.reasonText,
    reasonSourceType: row.reasonSourceType,
    historianId: row.historianId,
    historianCommitRef: row.historianCommitRef,
    architectAckRef: row.architectAckRef,
    decidedAt: row.decidedAt.toISOString(),
    downstreamApplied: row.downstreamApplied,
  };
}

function dbDecisionToGql(value: string): TriageDecisionType {
  // GraphQL TriageDecisionType uses UPPER_CASE; DB stores lower-case (CHECK
  // constraint enforces 'approve' | 'reject' | 'defer'). Generated TS enum
  // values are PascalCase strings ('Approve' | 'Reject' | 'Defer').
  switch (value) {
    case "approve":
      return "Approve" as TriageDecisionType;
    case "reject":
      return "Reject" as TriageDecisionType;
    case "defer":
      return "Defer" as TriageDecisionType;
    default:
      throw new Error(`Unrecognized DB decision value: ${value}`);
  }
}

function gqlDecisionToDb(value: TriageDecisionType): string {
  return String(value).toLowerCase();
}

// ---------------------------------------------------------------------------
// Provenance derivation (ADR-027 §4 architect ACK)
// ---------------------------------------------------------------------------

const ALLOWED_GQL_PROV_TIERS: ReadonlySet<string> = new Set([
  "primary_text",
  "scholarly_consensus",
  "ai_inferred",
  "crowdsourced",
  "unverified",
]);

/**
 * Map a DB provenance_tier value to a GraphQL-exposed value.
 * The DB has 6 enum values (incl. 'seed_dictionary' added by migration 0008
 * for ADR-021), but GraphQL ProvenanceTier exposes only 5. 'seed_dictionary'
 * and any future-added DB-only tier fall back to 'unverified'.
 *
 * Tracked as derivative debt T-P1-XXX (sync GraphQL + shared-types enum).
 */
export function deriveProvenanceTier(
  raw: string | null | undefined,
): ProvenanceTier {
  if (raw && ALLOWED_GQL_PROV_TIERS.has(raw)) {
    return raw as ProvenanceTier;
  }
  return "unverified" as ProvenanceTier;
}

// ---------------------------------------------------------------------------
// Pending item shape (internal — projected from SQL UNION ALL)
// ---------------------------------------------------------------------------

export interface PendingItemRow {
  itemId: string;
  kind: ItemKind;
  sourceTable: string;
  sourceId: string;
  surface: string;
  pendingSince: Date;
  // Provenance derivation inputs (resolved lazily by service helpers when
  // converting to GraphQL Item)
  rawTargetEntityId: string | null; // SeedMapping only
  rawDictionaryEntryId: string | null; // SeedMapping only
  rawConfidence: string | null; // SeedMapping only (NUMERIC -> string)
  rawMappingMethod: string | null; // SeedMapping only
  rawMappingNotes: unknown; // SeedMapping only
  rawPersonAId: string | null; // GuardBlockedMerge only
  rawPersonBId: string | null; // GuardBlockedMerge only
  rawProposedRule: string | null; // GuardBlockedMerge only
  rawGuardType: string | null; // GuardBlockedMerge only
  rawGuardPayload: unknown; // GuardBlockedMerge only
  rawEvidence: unknown; // GuardBlockedMerge only
}

interface ListFilter {
  filterByType: TriageItemTypeFilter | null;
  filterBySurface: string | null;
}

// ---------------------------------------------------------------------------
// Public API — fetchPendingItemsRows (raw projection)
// ---------------------------------------------------------------------------

/**
 * Fetch pending items as raw row projections (pre-GraphQL DTO).
 * Internal API used by both list endpoint and recordDecision's
 * nextPendingItemId computation.
 *
 * Surface-cluster sort algorithm (ADR-027 §2.3 V1 minimal):
 *   1. Compute earliest pending_since per surface across BOTH tables (cluster anchor)
 *   2. Order rows: (cluster_anchor ASC, surface ASC, pending_since ASC)
 *   3. Apply limit / offset
 *
 * Total count: COUNT across both tables matching filter (without limit/offset).
 */
export async function listPendingItemRows(
  db: DrizzleClient,
  limit: number,
  offset: number,
  filter: ListFilter,
): Promise<{ items: PendingItemRow[]; total: number }> {
  const includeSeed =
    !filter.filterByType ||
    filter.filterByType === ("All" as TriageItemTypeFilter) ||
    filter.filterByType === ("SeedMapping" as TriageItemTypeFilter);
  const includeGuard =
    !filter.filterByType ||
    filter.filterByType === ("All" as TriageItemTypeFilter) ||
    filter.filterByType === ("GuardBlockedMerge" as TriageItemTypeFilter);

  // We assemble with raw SQL because Drizzle's typed query builder does not
  // express UNION ALL with mixed schemas cleanly (different column counts).
  const surfaceFilter = filter.filterBySurface ?? null;

  // Build per-source SELECTs
  const seedSelect = includeSeed
    ? sql`
        SELECT
          'seed_mapping'::text                     AS kind,
          ${SOURCE_TABLE_SEED}::text               AS source_table,
          sm.id                                    AS source_id,
          de.primary_name                          AS surface,
          sm.mapping_created_at                    AS pending_since,
          sm.target_entity_id                      AS raw_target_entity_id,
          sm.dictionary_entry_id                   AS raw_dictionary_entry_id,
          sm.confidence::text                      AS raw_confidence,
          sm.mapping_method                        AS raw_mapping_method,
          sm.notes                                 AS raw_mapping_notes,
          NULL::uuid                               AS raw_person_a_id,
          NULL::uuid                               AS raw_person_b_id,
          NULL::text                               AS raw_proposed_rule,
          NULL::text                               AS raw_guard_type,
          NULL::jsonb                              AS raw_guard_payload,
          NULL::jsonb                              AS raw_evidence
        FROM seed_mappings sm
        JOIN dictionary_entries de ON de.id = sm.dictionary_entry_id
        WHERE sm.mapping_status = 'pending_review'
          AND sm.target_entity_type = 'person'
          ${surfaceFilter ? sql`AND de.primary_name = ${surfaceFilter}` : sql``}
      `
    : null;

  const guardSelect = includeGuard
    ? sql`
        SELECT
          'guard_blocked_merge'::text              AS kind,
          ${SOURCE_TABLE_GUARD}::text              AS source_table,
          pmr.id                                   AS source_id,
          COALESCE(
            pmr.guard_payload->>'surface_a',
            pmr.guard_payload->>'surface',
            (SELECT pn.name FROM person_names pn WHERE pn.person_id = pmr.person_a_id ORDER BY pn.is_primary DESC NULLS LAST, pn.created_at ASC LIMIT 1),
            'unknown'
          )                                        AS surface,
          pmr.created_at                           AS pending_since,
          NULL::uuid                               AS raw_target_entity_id,
          NULL::uuid                               AS raw_dictionary_entry_id,
          NULL::text                               AS raw_confidence,
          NULL::text                               AS raw_mapping_method,
          NULL::jsonb                              AS raw_mapping_notes,
          pmr.person_a_id                          AS raw_person_a_id,
          pmr.person_b_id                          AS raw_person_b_id,
          pmr.proposed_rule                        AS raw_proposed_rule,
          pmr.guard_type                           AS raw_guard_type,
          pmr.guard_payload                        AS raw_guard_payload,
          pmr.evidence                             AS raw_evidence
        FROM pending_merge_reviews pmr
        WHERE pmr.status = 'pending'
          ${
            surfaceFilter
              ? sql`AND COALESCE(pmr.guard_payload->>'surface_a', pmr.guard_payload->>'surface') = ${surfaceFilter}`
              : sql``
          }
      `
    : null;

  // Compose UNION ALL when both branches included
  const unionPart =
    seedSelect && guardSelect
      ? sql`(${seedSelect}) UNION ALL (${guardSelect})`
      : (seedSelect ?? guardSelect);

  if (!unionPart) {
    return { items: [], total: 0 };
  }

  // Total count
  const countResult = await db.execute(sql`
    WITH all_pending AS (${unionPart})
    SELECT count(*)::int AS total FROM all_pending
  `);
  const total = (countResult as unknown as Array<{ total: number }>)[0]?.total ?? 0;

  // Ordered + paginated rows with cluster anchor
  const dataResult = await db.execute(sql`
    WITH all_pending AS (${unionPart}),
         clusters AS (
           SELECT surface, MIN(pending_since) AS anchor
           FROM all_pending
           GROUP BY surface
         )
    SELECT ap.*, c.anchor
    FROM all_pending ap
    JOIN clusters c ON c.surface = ap.surface
    ORDER BY c.anchor ASC, ap.surface ASC, ap.pending_since ASC, ap.source_id ASC
    LIMIT ${limit}
    OFFSET ${offset}
  `);

  type RawRow = {
    kind: string;
    source_table: string;
    source_id: string;
    surface: string;
    pending_since: Date | string;
    raw_target_entity_id: string | null;
    raw_dictionary_entry_id: string | null;
    raw_confidence: string | null;
    raw_mapping_method: string | null;
    raw_mapping_notes: unknown;
    raw_person_a_id: string | null;
    raw_person_b_id: string | null;
    raw_proposed_rule: string | null;
    raw_guard_type: string | null;
    raw_guard_payload: unknown;
    raw_evidence: unknown;
  };

  const items: PendingItemRow[] = (dataResult as unknown as RawRow[]).map(
    (r) => ({
      itemId: encodeTriageItemId(r.kind as ItemKind, r.source_id),
      kind: r.kind as ItemKind,
      sourceTable: r.source_table,
      sourceId: r.source_id,
      surface: r.surface,
      pendingSince:
        r.pending_since instanceof Date
          ? r.pending_since
          : new Date(r.pending_since),
      rawTargetEntityId: r.raw_target_entity_id,
      rawDictionaryEntryId: r.raw_dictionary_entry_id,
      rawConfidence: r.raw_confidence,
      rawMappingMethod: r.raw_mapping_method,
      rawMappingNotes: r.raw_mapping_notes,
      rawPersonAId: r.raw_person_a_id,
      rawPersonBId: r.raw_person_b_id,
      rawProposedRule: r.raw_proposed_rule,
      rawGuardType: r.raw_guard_type,
      rawGuardPayload: r.raw_guard_payload,
      rawEvidence: r.raw_evidence,
    }),
  );

  return { items, total };
}

/**
 * High-level wrapper used by the GraphQL Query.pendingTriageItems resolver.
 * Returns a TriageItemConnection-shaped object plus the raw rows for
 * field resolvers to lazy-load related entities.
 */
export async function listPendingTriageItems(
  db: DrizzleClient,
  limit: number,
  offset: number,
  filter: ListFilter,
): Promise<
  Omit<TriageItemConnection, "__typename" | "items"> & {
    rawRows: PendingItemRow[];
  }
> {
  const clampedLimit = Math.max(1, Math.min(limit, 200));
  const clampedOffset = Math.max(0, offset);
  const { items, total } = await listPendingItemRows(
    db,
    clampedLimit,
    clampedOffset,
    filter,
  );
  return {
    rawRows: items,
    totalCount: total,
    hasMore: clampedOffset + clampedLimit < total,
  };
}

// ---------------------------------------------------------------------------
// getTriageItem — resolve composite ID
// ---------------------------------------------------------------------------

/**
 * Fetch one pending triage item by composite id.
 * Returns null when the source row is no longer pending or the id format is invalid.
 */
export async function findTriageItemById(
  db: DrizzleClient,
  itemId: string,
): Promise<PendingItemRow | null> {
  const decoded = decodeTriageItemId(itemId);
  if (!decoded) return null;

  if (decoded.kind === "seed_mapping") {
    const rows = await db.execute(sql`
      SELECT
        'seed_mapping'::text         AS kind,
        ${SOURCE_TABLE_SEED}::text   AS source_table,
        sm.id                        AS source_id,
        de.primary_name              AS surface,
        sm.mapping_created_at        AS pending_since,
        sm.target_entity_id          AS raw_target_entity_id,
        sm.dictionary_entry_id       AS raw_dictionary_entry_id,
        sm.confidence::text          AS raw_confidence,
        sm.mapping_method            AS raw_mapping_method,
        sm.notes                     AS raw_mapping_notes
      FROM seed_mappings sm
      JOIN dictionary_entries de ON de.id = sm.dictionary_entry_id
      WHERE sm.id = ${decoded.sourceId}
        AND sm.mapping_status = 'pending_review'
        AND sm.target_entity_type = 'person'
    `);
    const r = (rows as unknown as Array<Record<string, unknown>>)[0];
    if (!r) return null;
    return rawRowToPendingItem(r, "seed_mapping");
  }

  const rows = await db.execute(sql`
    SELECT
      'guard_blocked_merge'::text  AS kind,
      ${SOURCE_TABLE_GUARD}::text  AS source_table,
      pmr.id                       AS source_id,
      COALESCE(
        pmr.guard_payload->>'surface_a',
        pmr.guard_payload->>'surface',
        (SELECT pn.name FROM person_names pn WHERE pn.person_id = pmr.person_a_id ORDER BY pn.is_primary DESC NULLS LAST, pn.created_at ASC LIMIT 1),
        'unknown'
      )                            AS surface,
      pmr.created_at               AS pending_since,
      pmr.person_a_id              AS raw_person_a_id,
      pmr.person_b_id              AS raw_person_b_id,
      pmr.proposed_rule            AS raw_proposed_rule,
      pmr.guard_type               AS raw_guard_type,
      pmr.guard_payload            AS raw_guard_payload,
      pmr.evidence                 AS raw_evidence
    FROM pending_merge_reviews pmr
    WHERE pmr.id = ${decoded.sourceId}
      AND pmr.status = 'pending'
  `);
  const r = (rows as unknown as Array<Record<string, unknown>>)[0];
  if (!r) return null;
  return rawRowToPendingItem(r, "guard_blocked_merge");
}

function rawRowToPendingItem(
  r: Record<string, unknown>,
  kind: ItemKind,
): PendingItemRow {
  const pendingSinceVal = r.pending_since;
  const pendingSince =
    pendingSinceVal instanceof Date
      ? pendingSinceVal
      : new Date(String(pendingSinceVal));
  return {
    itemId: encodeTriageItemId(kind, String(r.source_id)),
    kind,
    sourceTable: String(r.source_table),
    sourceId: String(r.source_id),
    surface: String(r.surface),
    pendingSince,
    rawTargetEntityId: (r.raw_target_entity_id as string | null) ?? null,
    rawDictionaryEntryId:
      (r.raw_dictionary_entry_id as string | null) ?? null,
    rawConfidence: (r.raw_confidence as string | null) ?? null,
    rawMappingMethod: (r.raw_mapping_method as string | null) ?? null,
    rawMappingNotes: r.raw_mapping_notes ?? null,
    rawPersonAId: (r.raw_person_a_id as string | null) ?? null,
    rawPersonBId: (r.raw_person_b_id as string | null) ?? null,
    rawProposedRule: (r.raw_proposed_rule as string | null) ?? null,
    rawGuardType: (r.raw_guard_type as string | null) ?? null,
    rawGuardPayload: r.raw_guard_payload ?? null,
    rawEvidence: r.raw_evidence ?? null,
  };
}

// ---------------------------------------------------------------------------
// Decision audit lookups
// ---------------------------------------------------------------------------

/**
 * Fetch all triage_decisions rows for a given source row, newest first.
 * Used by TriageItem.historicalDecisions field resolver (per-row context).
 */
export async function findDecisionsForSource(
  db: DrizzleClient,
  sourceTable: string,
  sourceId: string,
): Promise<GqlTriageDecision[]> {
  const rows = await db
    .select()
    .from(triageDecisions)
    .where(
      and(
        eq(triageDecisions.sourceTable, sourceTable),
        eq(triageDecisions.sourceId, sourceId),
      ),
    )
    .orderBy(desc(triageDecisions.decidedAt));
  return rows.map(mapDecisionRow);
}

/**
 * Fetch all triage_decisions rows for a given surface across both source tables.
 * Powers Query.triageDecisionsForSurface (hint banner cross-sprint context).
 */
export async function findDecisionsForSurface(
  db: DrizzleClient,
  surface: string,
  limit: number,
): Promise<GqlTriageDecision[]> {
  const clampedLimit = Math.max(1, Math.min(limit, 100));
  const rows = await db
    .select()
    .from(triageDecisions)
    .where(eq(triageDecisions.surfaceSnapshot, surface))
    .orderBy(desc(triageDecisions.decidedAt))
    .limit(clampedLimit);
  return rows.map(mapDecisionRow);
}

// ---------------------------------------------------------------------------
// Provenance derivation lookups
// ---------------------------------------------------------------------------

/**
 * Derive (provenanceTier, sourceEvidenceId) for a SeedMapping pending row.
 *
 * Strategy: look at the latest source_evidences row authored against the
 * mapping target_entity_id; this is what Sprint B's seed_dictionary writes
 * point at. If found, use SE.provenance_tier (with seed_dictionary →
 * unverified fallback per deriveProvenanceTier()). Otherwise fallback to
 * (unverified, null).
 */
export async function deriveSeedMappingProvenance(
  db: DrizzleClient,
  targetEntityId: string,
): Promise<{ provenanceTier: ProvenanceTier; sourceEvidenceId: string | null }> {
  const result = await db.execute(sql`
    SELECT se.id, se.provenance_tier
    FROM source_evidences se
    JOIN evidence_links el ON el.evidence_id = se.id
    WHERE el.entity_type = 'person'
      AND el.entity_id = ${targetEntityId}
    ORDER BY se.created_at DESC
    LIMIT 1
  `);
  const row = (result as unknown as Array<{ id: string; provenance_tier: string }>)[0];
  if (!row) {
    return { provenanceTier: deriveProvenanceTier(null), sourceEvidenceId: null };
  }
  return {
    provenanceTier: deriveProvenanceTier(row.provenance_tier),
    sourceEvidenceId: row.id,
  };
}

/**
 * Derive (provenanceTier, sourceEvidenceId) for a GuardBlockedMerge pending row.
 *
 * Strategy: look in pending_merge_reviews.evidence JSONB for a 'source_evidence_id'
 * key (resolver convention). If present and valid, fetch the SE row's provenance_tier.
 * Otherwise fallback to (unverified, null).
 */
export async function deriveGuardMergeProvenance(
  db: DrizzleClient,
  evidenceJsonb: unknown,
): Promise<{ provenanceTier: ProvenanceTier; sourceEvidenceId: string | null }> {
  const seId = extractSourceEvidenceId(evidenceJsonb);
  if (!seId) {
    return { provenanceTier: deriveProvenanceTier(null), sourceEvidenceId: null };
  }
  const rows = await db
    .select({
      id: sourceEvidences.id,
      provenanceTier: sourceEvidences.provenanceTier,
    })
    .from(sourceEvidences)
    .where(eq(sourceEvidences.id, seId))
    .limit(1);
  const row = rows[0];
  if (!row) {
    return { provenanceTier: deriveProvenanceTier(null), sourceEvidenceId: null };
  }
  return {
    provenanceTier: deriveProvenanceTier(row.provenanceTier as string),
    sourceEvidenceId: row.id,
  };
}

function extractSourceEvidenceId(evidence: unknown): string | null {
  if (!evidence || typeof evidence !== "object") return null;
  const obj = evidence as Record<string, unknown>;
  const direct = obj.source_evidence_id ?? obj.sourceEvidenceId;
  if (typeof direct === "string" && direct.length > 0) return direct;
  // arrays variant: source_evidence_ids[0]
  const arr = obj.source_evidence_ids ?? obj.sourceEvidenceIds;
  if (Array.isArray(arr) && typeof arr[0] === "string") return arr[0] as string;
  return null;
}

// ---------------------------------------------------------------------------
// Dictionary entry lookup (SeedMapping detail page)
// ---------------------------------------------------------------------------

export interface DictionaryEntryDto {
  id: string;
  externalId: string;
  entryType: string;
  primaryName: string | null;
  aliases: unknown;
  attributes: unknown;
  source: {
    id: string;
    sourceName: string;
    sourceVersion: string;
    license: string;
    commercialSafe: boolean;
  };
}

export async function findDictionaryEntry(
  db: DrizzleClient,
  entryId: string,
): Promise<DictionaryEntryDto | null> {
  const rows = await db
    .select({
      entry: dictionaryEntries,
      source: dictionarySources,
    })
    .from(dictionaryEntries)
    .innerJoin(
      dictionarySources,
      eq(dictionarySources.id, dictionaryEntries.sourceId),
    )
    .where(eq(dictionaryEntries.id, entryId))
    .limit(1);
  const row = rows[0];
  if (!row) return null;
  return {
    id: row.entry.id,
    externalId: row.entry.externalId,
    entryType: row.entry.entryType,
    primaryName: row.entry.primaryName,
    aliases: row.entry.aliases,
    attributes: row.entry.attributes,
    source: {
      id: row.source.id,
      sourceName: row.source.sourceName,
      sourceVersion: row.source.sourceVersion,
      license: row.source.license,
      commercialSafe: row.source.commercialSafe,
    },
  };
}

// ---------------------------------------------------------------------------
// Person lookup (Query.personById + SeedMapping/GuardMerge field resolvers)
// ---------------------------------------------------------------------------

type PersonRow = typeof persons.$inferSelect;

/**
 * Find a person by UUID, resolving merged → canonical via merged_into_id chain
 * (max 5 hops). Returns null if not found or the chain ends in a deleted
 * non-merged row.
 *
 * Mirrors findPersonBySlug logic from person.service.ts but accepts a UUID
 * (BE inventory §3.1 + ADR-027 §4.5).
 */
export async function findPersonRowById(
  db: DrizzleClient,
  id: string,
): Promise<PersonRow | null> {
  const initial = await db
    .select()
    .from(persons)
    .where(eq(persons.id, id))
    .limit(1);
  const row = initial[0];
  if (!row) return null;

  // If active and not merged, return directly
  if (!row.mergedIntoId && row.deletedAt == null) return row;
  // Pure soft-delete (no merge target) — return null
  if (!row.mergedIntoId) return null;

  // Walk merge chain
  let current = row;
  let hops = 0;
  while (current.mergedIntoId && hops < 5) {
    const next = await db
      .select()
      .from(persons)
      .where(eq(persons.id, current.mergedIntoId))
      .limit(1);
    if (!next[0]) return null;
    current = next[0];
    hops++;
  }
  if (current.deletedAt != null && !current.mergedIntoId) return null;
  return current;
}

// ---------------------------------------------------------------------------
// recordDecision — the only WRITE path in this service
// ---------------------------------------------------------------------------

/**
 * Record a historian decision against a pending triage item.
 *
 * V1 zero-downstream: writes a row into triage_decisions and computes the
 * next pending item for the inbox redirect; does NOT mutate the source
 * table per ADR-027 §2.5 + §5.
 *
 * Validation order (fail-fast, all errors returned via payload.error):
 *   1. UNAUTHORIZED        — historianId not in allowlist
 *   2. INVALID_REASON_SOURCE_TYPE — reasonSourceType (if provided) not in whitelist
 *   3. ITEM_NOT_FOUND      — itemId malformed OR source row not pending
 *   4. INSERT triage_decisions row
 *   5. Compute nextPendingItemId (FIFO of remaining queue, excluding the
 *      just-decided source row)
 */
export async function recordTriageDecision(
  db: DrizzleClient,
  input: RecordTriageDecisionInput,
): Promise<RecordTriageDecisionPayload> {
  // 1. Authz
  if (!HISTORIAN_ALLOWLIST.has(input.historianId)) {
    return {
      triageDecision: null,
      nextPendingItemId: null,
      error: {
        code: "UNAUTHORIZED",
        message: `historianId '${input.historianId}' is not in the allowlist`,
      },
    };
  }

  // 2. reasonSourceType (optional — null/undefined OK; rejected if non-null but unrecognized)
  if (
    input.reasonSourceType != null &&
    input.reasonSourceType !== "" &&
    !REASON_SOURCE_TYPES.has(input.reasonSourceType)
  ) {
    return {
      triageDecision: null,
      nextPendingItemId: null,
      error: {
        code: "INVALID_REASON_SOURCE_TYPE",
        message: `reasonSourceType '${input.reasonSourceType}' is not in the allowed set`,
      },
    };
  }

  // 3. Decode + verify source row pending
  const decoded = decodeTriageItemId(input.itemId);
  if (!decoded) {
    return {
      triageDecision: null,
      nextPendingItemId: null,
      error: {
        code: "ITEM_NOT_FOUND",
        message: `itemId '${input.itemId}' has invalid format (expected '<kind>:<uuid>')`,
      },
    };
  }
  const item = await findTriageItemById(db, input.itemId);
  if (!item) {
    return {
      triageDecision: null,
      nextPendingItemId: null,
      error: {
        code: "ITEM_NOT_FOUND",
        message: `triage item '${input.itemId}' does not exist or is no longer pending`,
      },
    };
  }

  // 4. INSERT triage_decisions
  const insertedRows = await db
    .insert(triageDecisions)
    .values({
      sourceTable: kindToSourceTable(decoded.kind),
      sourceId: decoded.sourceId,
      surfaceSnapshot: item.surface,
      decision: gqlDecisionToDb(input.decision),
      reasonText: input.reasonText ?? null,
      reasonSourceType: input.reasonSourceType ?? null,
      historianId: input.historianId,
    })
    .returning();
  const inserted = insertedRows[0];
  if (!inserted) {
    throw new Error("triage_decisions INSERT returned no rows");
  }

  // 5. Compute nextPendingItemId (queue order — same algorithm as listPendingItemRows)
  const next = await findNextPendingExcluding(
    db,
    decoded.kind,
    decoded.sourceId,
  );

  return {
    triageDecision: mapDecisionRow(inserted),
    nextPendingItemId: next,
    error: null,
  };
}

/**
 * Compute the next pending item id excluding the just-decided source row.
 * Honors V1 surface-cluster + FIFO ordering.
 *
 * V1 simplification: even though recordDecision does NOT mutate
 * pending_review status (ADR-027 §2.5 zero-downstream), the just-decided
 * row would otherwise stay at the head of the queue. We exclude it
 * client-side here so the inbox redirect skips to the next real item.
 */
async function findNextPendingExcluding(
  db: DrizzleClient,
  kind: ItemKind,
  excludeSourceId: string,
): Promise<string | null> {
  const result = await db.execute(sql`
    WITH all_pending AS (
      SELECT
        'seed_mapping'::text       AS kind,
        sm.id                      AS source_id,
        de.primary_name            AS surface,
        sm.mapping_created_at      AS pending_since
      FROM seed_mappings sm
      JOIN dictionary_entries de ON de.id = sm.dictionary_entry_id
      WHERE sm.mapping_status = 'pending_review'
        AND sm.target_entity_type = 'person'
        AND NOT (sm.id = ${excludeSourceId} AND ${kind === "seed_mapping" ? sql`true` : sql`false`})
      UNION ALL
      SELECT
        'guard_blocked_merge'::text AS kind,
        pmr.id                      AS source_id,
        COALESCE(
          pmr.guard_payload->>'surface_a',
          pmr.guard_payload->>'surface',
          (SELECT pn.name FROM person_names pn WHERE pn.person_id = pmr.person_a_id ORDER BY pn.is_primary DESC NULLS LAST, pn.created_at ASC LIMIT 1),
          'unknown'
        )                           AS surface,
        pmr.created_at              AS pending_since
      FROM pending_merge_reviews pmr
      WHERE pmr.status = 'pending'
        AND NOT (pmr.id = ${excludeSourceId} AND ${kind === "guard_blocked_merge" ? sql`true` : sql`false`})
    ),
    clusters AS (
      SELECT surface, MIN(pending_since) AS anchor
      FROM all_pending
      GROUP BY surface
    )
    SELECT ap.kind, ap.source_id
    FROM all_pending ap
    JOIN clusters c ON c.surface = ap.surface
    ORDER BY c.anchor ASC, ap.surface ASC, ap.pending_since ASC, ap.source_id ASC
    LIMIT 1
  `);

  const row = (result as unknown as Array<{ kind: string; source_id: string }>)[0];
  if (!row) return null;
  return encodeTriageItemId(row.kind as ItemKind, row.source_id);
}

// ---------------------------------------------------------------------------
// Test exports — internal-only helpers exposed for unit tests
// ---------------------------------------------------------------------------

export const __test = {
  HISTORIAN_ALLOWLIST,
  REASON_SOURCE_TYPES,
  encodeTriageItemId,
  decodeTriageItemId,
  deriveProvenanceTier,
  dbDecisionToGql,
  gqlDecisionToDb,
  extractSourceEvidenceId,
};
