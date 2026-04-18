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
 * Find a single person by slug. Returns null if not found or soft-deleted.
 * Eager-loads person_names and identity_hypotheses (Q-4 ruling A for single entity).
 */
export async function findPersonBySlug(
  db: DrizzleClient,
  slug: string,
): Promise<(GqlPerson & { __typename: "Person"; _namesLoaded: boolean; _hypothesesLoaded: boolean }) | null> {
  const rows = await db
    .select()
    .from(persons)
    .where(eq(persons.slug, slug))
    .limit(1);

  const row = rows[0];
  if (!row || row.deletedAt != null) return null;

  // Sequential queries for related data (N is small, Q-4 ruling A)
  const [nameRows, hypothesisRows] = await Promise.all([
    db
      .select()
      .from(personNames)
      .where(eq(personNames.personId, row.id)),
    db
      .select()
      .from(identityHypotheses)
      .where(eq(identityHypotheses.canonicalPersonId, row.id)),
  ]);

  return {
    ...toGraphQLPerson(row),
    names: nameRows.map(toGraphQLPersonName),
    identityHypotheses: hypothesisRows.map(toGraphQLHypothesis),
    _namesLoaded: true,
    _hypothesesLoaded: true,
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
 * Load person_names for a given person ID (used by field resolver on persons list).
 */
export async function findPersonNamesByPersonId(
  db: DrizzleClient,
  personId: string,
): Promise<GqlPersonName[]> {
  const rows = await db
    .select()
    .from(personNames)
    .where(eq(personNames.personId, personId));
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
 * similarity on person_names.name (threshold 0.3) + ILIKE on
 * persons.name->>'zh-Hans', ordered by relevance score DESC.
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
    return await trigramSearch(db, term, clampedLimit, clampedOffset);
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

async function trigramSearch(
  db: DrizzleClient,
  term: string,
  limit: number,
  offset: number,
): Promise<Omit<PersonSearchResult, "__typename">> {
  const likePattern = `%${term}%`;

  // Run count + paginated IDs in parallel
  const [countResult, idsResult] = await Promise.all([
    db.execute(sql`
      SELECT count(DISTINCT p.id)::int AS total
      FROM persons p
      LEFT JOIN person_names pn ON pn.person_id = p.id
      WHERE p.deleted_at IS NULL
        AND (
          similarity(pn.name, ${term}) > 0.3
          OR p.name->>'zh-Hans' ILIKE ${likePattern}
        )
    `),
    db.execute(sql`
      SELECT p.id
      FROM persons p
      LEFT JOIN person_names pn ON pn.person_id = p.id
      WHERE p.deleted_at IS NULL
        AND (
          similarity(pn.name, ${term}) > 0.3
          OR p.name->>'zh-Hans' ILIKE ${likePattern}
        )
      GROUP BY p.id
      ORDER BY MAX(GREATEST(
        COALESCE(similarity(pn.name, ${term}), 0),
        CASE WHEN p.name->>'zh-Hans' ILIKE ${likePattern} THEN 0.5 ELSE 0 END
      )) DESC, p.created_at DESC
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

  const [countResult, idsResult] = await Promise.all([
    db.execute(sql`
      SELECT count(DISTINCT p.id)::int AS total
      FROM persons p
      LEFT JOIN person_names pn ON pn.person_id = p.id
      WHERE p.deleted_at IS NULL
        AND (
          pn.name ILIKE ${likePattern}
          OR p.name->>'zh-Hans' ILIKE ${likePattern}
        )
    `),
    db.execute(sql`
      SELECT p.id
      FROM persons p
      LEFT JOIN person_names pn ON pn.person_id = p.id
      WHERE p.deleted_at IS NULL
        AND (
          pn.name ILIKE ${likePattern}
          OR p.name->>'zh-Hans' ILIKE ${likePattern}
        )
      GROUP BY p.id
      ORDER BY p.created_at DESC
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
