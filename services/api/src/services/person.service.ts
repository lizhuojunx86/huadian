import {
  persons,
  personNames,
  identityHypotheses,
} from "@huadian/db-schema";
import { eq, isNull, desc, sql, inArray } from "drizzle-orm";

import type {
  Person as GqlPerson,
  PersonName as GqlPersonName,
  IdentityHypothesis as GqlIdentityHypothesis,
  PersonSearchResult,
  RealityStatus,
  ProvenanceTier,
  NameType,
  HypothesisRelationType,
} from "../__generated__/graphql.js";
import type { DrizzleClient } from "../context.js";

// ----------------------------------------------------------------
// Drizzle row types (inferred from select)
// ----------------------------------------------------------------
type PersonRow = typeof persons.$inferSelect;
type PersonNameRow = typeof personNames.$inferSelect;
type IdentityHypothesisRow = typeof identityHypotheses.$inferSelect;

// ----------------------------------------------------------------
// JSONB → GraphQL key mapping helpers
// ----------------------------------------------------------------

interface MultiLangTextJsonb {
  "zh-Hans": string;
  "zh-Hant"?: string;
  en?: string;
}

function mapMultiLangText(raw: unknown): GqlPerson["name"] {
  const obj = raw as MultiLangTextJsonb;
  return {
    zhHans: obj["zh-Hans"],
    zhHant: obj["zh-Hant"] ?? null,
    en: obj?.en ?? null,
  };
}

function mapMultiLangTextNullable(raw: unknown): GqlPerson["biography"] {
  if (raw == null) return null;
  return mapMultiLangText(raw);
}

interface HistoricalDateJsonb {
  year_min?: number;
  year_max?: number;
  month?: number;
  day?: number;
  precision: string;
  reign_era?: string;
  reign_year?: number;
  polity_id?: string;
  lunar_month?: number;
  lunar_day?: number;
  sexagenary_year?: string;
  season?: string;
  original_text?: string;
}

function mapHistoricalDate(raw: unknown): GqlPerson["birthDate"] {
  if (raw == null) return null;
  const d = raw as HistoricalDateJsonb;
  return {
    yearMin: d.year_min ?? null,
    yearMax: d.year_max ?? null,
    month: d.month ?? null,
    day: d.day ?? null,
    precision: d.precision as GqlPerson["birthDate"] extends null ? never : NonNullable<GqlPerson["birthDate"]>["precision"],
    reignEra: d.reign_era ?? null,
    reignYear: d.reign_year ?? null,
    polityId: d.polity_id ?? null,
    lunarMonth: d.lunar_month ?? null,
    lunarDay: d.lunar_day ?? null,
    sexagenaryYear: d.sexagenary_year ?? null,
    season: d.season ?? null,
    originalText: d.original_text ?? null,
  };
}

// ----------------------------------------------------------------
// DTO mappers: Drizzle row → GraphQL type
// ----------------------------------------------------------------

export function toGraphQLPerson(row: PersonRow): Omit<GqlPerson, "names" | "identityHypotheses"> & { __typename: "Person" } {
  return {
    __typename: "Person",
    id: row.id,
    slug: row.slug,
    name: mapMultiLangText(row.name),
    dynasty: row.dynasty,
    realityStatus: row.realityStatus as RealityStatus,
    birthDate: mapHistoricalDate(row.birthDate),
    deathDate: mapHistoricalDate(row.deathDate),
    biography: mapMultiLangTextNullable(row.biography),
    provenanceTier: row.provenanceTier as ProvenanceTier,
    sourceEvidenceId: null, // persons table has no source_evidence_id column (ADR-009)
    updatedAt: row.updatedAt.toISOString(),
  };
}

export function toGraphQLPersonName(row: PersonNameRow): GqlPersonName {
  return {
    id: row.id,
    personId: row.personId,
    name: row.name,
    namePinyin: row.namePinyin,
    nameType: row.nameType as NameType,
    startYear: row.startYear,
    endYear: row.endYear,
    isPrimary: row.isPrimary,
    sourceEvidenceId: row.sourceEvidenceId,
    createdAt: row.createdAt.toISOString(),
  };
}

export function toGraphQLHypothesis(row: IdentityHypothesisRow): GqlIdentityHypothesis {
  return {
    id: row.id,
    canonicalPersonId: row.canonicalPersonId,
    hypothesisPersonId: row.hypothesisPersonId,
    relationType: row.relationType as HypothesisRelationType,
    scholarlySupport: row.scholarlySupport,
    evidenceIds: (row.evidenceIds ?? []) as string[],
    acceptedByDefault: row.acceptedByDefault,
    notes: row.notes,
    createdAt: row.createdAt.toISOString(),
  };
}

// ----------------------------------------------------------------
// Service functions
// ----------------------------------------------------------------

/**
 * Resolve a potentially merged person to its canonical person.
 * Follows the merged_into_id chain (max 5 hops to prevent infinite loops).
 * Returns null if the chain leads to a deleted non-merged person.
 */
async function resolveCanonical(
  db: DrizzleClient,
  row: PersonRow,
): Promise<PersonRow | null> {
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
  // Only return if the final person is active (not deleted or is itself canonical)
  if (current.deletedAt != null && !current.mergedIntoId) return null;
  return current;
}

/**
 * Find a single person by slug. Returns null if not found.
 * If slug matches a merged person, resolves to its canonical person.
 * Eager-loads person_names from both canonical AND merged persons,
 * plus identity_hypotheses (Q-4 ruling A for single entity).
 */
export async function findPersonBySlug(
  db: DrizzleClient,
  slug: string,
): Promise<(GqlPerson & { __typename: "Person"; _namesLoaded: boolean; _hypothesesLoaded: boolean; _redirectedFrom?: string }) | null> {
  const rows = await db
    .select()
    .from(persons)
    .where(eq(persons.slug, slug))
    .limit(1);

  const row = rows[0];
  if (!row) return null;

  // If this person is merged, resolve to canonical
  let canonical = row;
  let redirectedFrom: string | undefined;
  if (row.mergedIntoId || row.deletedAt != null) {
    if (!row.mergedIntoId) return null; // deleted but not merged
    const resolved = await resolveCanonical(db, row);
    if (!resolved) return null;
    canonical = resolved;
    redirectedFrom = slug;
  }

  // Load names from canonical + all persons merged into it
  const [nameRows, hypothesisRows] = await Promise.all([
    findPersonNamesWithMerged(db, canonical.id),
    db
      .select()
      .from(identityHypotheses)
      .where(eq(identityHypotheses.canonicalPersonId, canonical.id)),
  ]);

  return {
    ...toGraphQLPerson(canonical),
    names: nameRows,
    identityHypotheses: hypothesisRows.map(toGraphQLHypothesis),
    _namesLoaded: true,
    _hypothesesLoaded: true,
    _redirectedFrom: redirectedFrom,
  };
}

/**
 * List persons with offset-based pagination.
 * Returns base Person fields with empty names/identityHypotheses arrays;
 * field resolvers (Q-4 ruling B) lazy-load them when requested.
 */
export async function findPersons(
  db: DrizzleClient,
  limit: number,
  offset: number,
): Promise<Array<GqlPerson & { __typename: "Person" }>> {
  const clampedLimit = Math.max(1, Math.min(limit, 100));
  const clampedOffset = Math.max(0, offset);

  const rows = await db
    .select()
    .from(persons)
    .where(isNull(persons.deletedAt))
    .orderBy(desc(persons.createdAt))
    .limit(clampedLimit)
    .offset(clampedOffset);

  return rows.map((row) => ({
    ...toGraphQLPerson(row),
    names: [],
    identityHypotheses: [],
  }));
}

/**
 * Load person_names for a canonical person, including names from all persons
 * merged into it (soft merge — person_names.person_id stays on the original
 * person, we resolve via persons.merged_into_id).
 */
export async function findPersonNamesByPersonId(
  db: DrizzleClient,
  personId: string,
): Promise<GqlPersonName[]> {
  return findPersonNamesWithMerged(db, personId);
}

/**
 * Internal: load names from canonical person + all persons merged into it.
 */
async function findPersonNamesWithMerged(
  db: DrizzleClient,
  canonicalId: string,
): Promise<GqlPersonName[]> {
  // Find all person IDs that belong to this canonical group:
  // the canonical itself + any person whose merged_into_id points to it
  const mergedRows = await db
    .select({ id: persons.id })
    .from(persons)
    .where(eq(persons.mergedIntoId, canonicalId));

  const allIds = [canonicalId, ...mergedRows.map(r => r.id)];

  const rows = await db
    .select()
    .from(personNames)
    .where(inArray(personNames.personId, allIds));

  return rows.map(toGraphQLPersonName);
}

/**
 * Load identity_hypotheses for a given person ID (used by field resolver on persons list).
 */
export async function findHypothesesByPersonId(
  db: DrizzleClient,
  personId: string,
): Promise<GqlIdentityHypothesis[]> {
  const rows = await db
    .select()
    .from(identityHypotheses)
    .where(eq(identityHypotheses.canonicalPersonId, personId));
  return rows.map(toGraphQLHypothesis);
}

// ----------------------------------------------------------------
// Search (T-P0-009)
// ----------------------------------------------------------------

type PersonItem = GqlPerson & { __typename: "Person" };

/**
 * Search and paginate persons. When `search` is empty/null, returns all
 * persons ordered by created_at DESC. When non-empty, uses pg_trgm
 * similarity on person_names.name with length-weighted threshold
 * (≤2 chars: 0.5, 3 chars: 0.4, 4+ chars: 0.3) + ILIKE on
 * persons.name->>'zh-Hans', ordered by relevance score DESC.
 *
 * If the primary search returns no results, falls back to ILIKE substring
 * matching on person_names.name to catch partial alias matches
 * (e.g. "青莲" → "青莲居士").
 *
 * Falls back to pure ILIKE if pg_trgm extension is unavailable.
 */
export async function searchPersons(
  db: DrizzleClient,
  search: string | null | undefined,
  limit: number,
  offset: number,
): Promise<Omit<PersonSearchResult, "__typename">> {
  const clampedLimit = Math.max(1, Math.min(limit, 100));
  const clampedOffset = Math.max(0, offset);
  const term = search?.trim() ?? "";

  if (term === "") {
    return listAllPersons(db, clampedLimit, clampedOffset);
  }

  try {
    const result = await trigramSearch(db, term, clampedLimit, clampedOffset);
    // T-P1-003: if primary search found nothing, try ILIKE substring on
    // person_names.name as a fallback for partial alias matches.
    if (result.total === 0) {
      return aliasSubstringSearch(db, term, clampedLimit, clampedOffset);
    }
    return result;
  } catch (err) {
    // Fallback: pg_trgm not available → pure ILIKE
    if (err instanceof Error && err.message.includes("similarity")) {
      return ilikeSearch(db, term, clampedLimit, clampedOffset);
    }
    throw err;
  }
}

async function listAllPersons(
  db: DrizzleClient,
  limit: number,
  offset: number,
): Promise<Omit<PersonSearchResult, "__typename">> {
  const [countRows, dataRows] = await Promise.all([
    db.select({ total: sql<string>`count(*)` }).from(persons).where(isNull(persons.deletedAt)),
    db.select().from(persons).where(isNull(persons.deletedAt))
      .orderBy(desc(persons.createdAt)).limit(limit).offset(offset),
  ]);
  const total = Number(countRows[0]?.total ?? 0);
  return {
    items: dataRows.map(toPersonItem),
    total,
    hasMore: offset + limit < total,
  };
}

/**
 * Compute similarity threshold based on query length (in characters).
 * Short queries (1-2 chars) use a higher threshold to avoid false positives
 * from partial trigram overlaps (e.g. "帝中" matching "帝中壬"/"帝中康").
 * Longer queries can afford a lower threshold for fuzzy recall.
 *
 * T-P1-003: length-weighted threshold (Strategy C)
 */
function similarityThreshold(term: string): number {
  const charLen = [...term].length;
  if (charLen <= 2) return 0.5;
  if (charLen <= 3) return 0.4;
  return 0.3;
}

async function trigramSearch(
  db: DrizzleClient,
  term: string,
  limit: number,
  offset: number,
): Promise<Omit<PersonSearchResult, "__typename">> {
  const likePattern = `%${term}%`;
  const threshold = similarityThreshold(term);

  // Search through ALL persons' names (including merged ones).
  // Use COALESCE(p.merged_into_id, p.id) to resolve merged persons to their
  // canonical, so searching "垂" returns 倕 (canonical) instead of 垂 (merged).
  const [countResult, idsResult] = await Promise.all([
    db.execute(sql`
      SELECT count(DISTINCT COALESCE(p.merged_into_id, p.id))::int AS total
      FROM persons p
      LEFT JOIN person_names pn ON pn.person_id = p.id
      WHERE (p.deleted_at IS NULL OR p.merged_into_id IS NOT NULL)
        AND (
          similarity(pn.name, ${term}) > ${threshold}
          OR p.name->>'zh-Hans' ILIKE ${likePattern}
        )
    `),
    db.execute(sql`
      SELECT COALESCE(p.merged_into_id, p.id) AS id
      FROM persons p
      LEFT JOIN person_names pn ON pn.person_id = p.id
      WHERE (p.deleted_at IS NULL OR p.merged_into_id IS NOT NULL)
        AND (
          similarity(pn.name, ${term}) > ${threshold}
          OR p.name->>'zh-Hans' ILIKE ${likePattern}
        )
      GROUP BY COALESCE(p.merged_into_id, p.id)
      ORDER BY MAX(GREATEST(
        COALESCE(similarity(pn.name, ${term}), 0),
        CASE WHEN p.name->>'zh-Hans' ILIKE ${likePattern} THEN 0.5 ELSE 0 END
      )) DESC
      LIMIT ${limit} OFFSET ${offset}
    `),
  ]);

  const total = (countResult as unknown as Array<{ total: number }>)[0]?.total ?? 0;
  const matchedIds = (idsResult as unknown as Array<{ id: string }>).map(r => r.id);

  return fetchAndOrder(db, matchedIds, total, offset, limit);
}

async function ilikeSearch(
  db: DrizzleClient,
  term: string,
  limit: number,
  offset: number,
): Promise<Omit<PersonSearchResult, "__typename">> {
  const likePattern = `%${term}%`;

  // Same canonical resolution as trigramSearch
  const [countResult, idsResult] = await Promise.all([
    db.execute(sql`
      SELECT count(DISTINCT COALESCE(p.merged_into_id, p.id))::int AS total
      FROM persons p
      LEFT JOIN person_names pn ON pn.person_id = p.id
      WHERE (p.deleted_at IS NULL OR p.merged_into_id IS NOT NULL)
        AND (
          pn.name ILIKE ${likePattern}
          OR p.name->>'zh-Hans' ILIKE ${likePattern}
        )
    `),
    db.execute(sql`
      SELECT COALESCE(p.merged_into_id, p.id) AS id
      FROM persons p
      LEFT JOIN person_names pn ON pn.person_id = p.id
      WHERE (p.deleted_at IS NULL OR p.merged_into_id IS NOT NULL)
        AND (
          pn.name ILIKE ${likePattern}
          OR p.name->>'zh-Hans' ILIKE ${likePattern}
        )
      GROUP BY COALESCE(p.merged_into_id, p.id)
      ORDER BY MAX(p.created_at) DESC
      LIMIT ${limit} OFFSET ${offset}
    `),
  ]);

  const total = (countResult as unknown as Array<{ total: number }>)[0]?.total ?? 0;
  const matchedIds = (idsResult as unknown as Array<{ id: string }>).map(r => r.id);

  return fetchAndOrder(db, matchedIds, total, offset, limit);
}

/**
 * Fallback search: ILIKE substring match on person_names.name only.
 * Used when the primary trigramSearch returns zero results, to catch
 * partial alias matches (e.g. "青莲" finding "青莲居士").
 * Scored by query coverage ratio: length(query) / length(matched_name).
 *
 * T-P1-003: this runs ONLY when trigramSearch returns total=0,
 * so it cannot introduce FP on queries that already have matches.
 */
async function aliasSubstringSearch(
  db: DrizzleClient,
  term: string,
  limit: number,
  offset: number,
): Promise<Omit<PersonSearchResult, "__typename">> {
  const likePattern = `%${term}%`;

  const [countResult, idsResult] = await Promise.all([
    db.execute(sql`
      SELECT count(DISTINCT COALESCE(p.merged_into_id, p.id))::int AS total
      FROM persons p
      JOIN person_names pn ON pn.person_id = p.id
      WHERE (p.deleted_at IS NULL OR p.merged_into_id IS NOT NULL)
        AND pn.name ILIKE ${likePattern}
    `),
    db.execute(sql`
      SELECT COALESCE(p.merged_into_id, p.id) AS id
      FROM persons p
      JOIN person_names pn ON pn.person_id = p.id
      WHERE (p.deleted_at IS NULL OR p.merged_into_id IS NOT NULL)
        AND pn.name ILIKE ${likePattern}
      GROUP BY COALESCE(p.merged_into_id, p.id)
      ORDER BY MAX(
        CAST(char_length(${term}) AS float) / GREATEST(char_length(pn.name), 1)
      ) DESC
      LIMIT ${limit} OFFSET ${offset}
    `),
  ]);

  const total = (countResult as unknown as Array<{ total: number }>)[0]?.total ?? 0;
  const matchedIds = (idsResult as unknown as Array<{ id: string }>).map(r => r.id);

  return fetchAndOrder(db, matchedIds, total, offset, limit);
}

/**
 * Given ordered person IDs from a search query, fetch full rows via
 * Drizzle (proper type mapping) and re-order to preserve relevance.
 */
async function fetchAndOrder(
  db: DrizzleClient,
  orderedIds: string[],
  total: number,
  offset: number,
  limit: number,
): Promise<Omit<PersonSearchResult, "__typename">> {
  if (orderedIds.length === 0) {
    return { items: [], total, hasMore: false };
  }

  const rows = await db.select().from(persons)
    .where(inArray(persons.id, orderedIds));

  // Re-order to match the search relevance order
  const rowMap = new Map(rows.map(r => [r.id, r]));
  const items: PersonItem[] = orderedIds
    .map(id => rowMap.get(id))
    .filter((r): r is NonNullable<typeof r> => r != null)
    .map(toPersonItem);

  return {
    items,
    total,
    hasMore: offset + limit < total,
  };
}

function toPersonItem(row: PersonRow): PersonItem {
  return {
    ...toGraphQLPerson(row),
    names: [],
    identityHypotheses: [],
  };
}
