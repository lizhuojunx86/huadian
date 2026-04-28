/**
 * Triage service tests — T-P0-028 Sprint K Stage 2.7 / ADR-027.
 *
 * Mix of unit (pure helpers) + integration (real PG, fixtures).
 *
 * Integration fixtures:
 *   - 2 persons (target-A, person-pair-A, person-pair-B)
 *   - 1 dictionary_source + 2 dictionary_entries
 *   - 2 seed_mappings WHERE mapping_status='pending_review'
 *   - 1 pending_merge_reviews WHERE status='pending'
 *   Cleanup runs after each test to keep state isolated; we wipe ONLY rows we
 *   created (FIXTURE_IDS), never the global pending queues.
 */
import {
  dictionaryEntries,
  dictionarySources,
  pendingMergeReviews,
  persons,
  seedMappings,
  triageDecisions,
} from "@huadian/db-schema";
import { eq, inArray } from "drizzle-orm";
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import { afterAll, afterEach, beforeAll, describe, expect, it } from "vitest";

import type { DrizzleClient } from "../src/context.js";
import {
  __test,
  encodeTriageItemId,
  findPersonRowById,
  findTriageItemById,
  listPendingItemRows,
  recordTriageDecision,
} from "../src/services/triage.service.js";

// ----------------------------------------------------------------
// Test infra
// ----------------------------------------------------------------

const DATABASE_URL =
  process.env.DATABASE_URL ??
  "postgres://huadian:huadian_dev@127.0.0.1:5433/huadian";

let sql_: ReturnType<typeof postgres>;
let db: DrizzleClient;

// Deterministic UUIDs — distinct from person.integration.test.ts namespace
const FX = {
  // persons
  personA: "dddddddd-0028-4000-8000-000000000001",
  personB: "dddddddd-0028-4000-8000-000000000002",
  personC: "dddddddd-0028-4000-8000-000000000003", // for second seed mapping
  // dictionary
  dictSource: "eeeeeeee-0028-4000-8000-000000000001",
  dictEntry1: "eeeeeeee-0028-4000-8000-000000000002", // surface = 测试甲
  dictEntry2: "eeeeeeee-0028-4000-8000-000000000003", // surface = 测试乙
  // seed_mappings
  seed1: "ffffffff-0028-4000-8000-000000000001",
  seed2: "ffffffff-0028-4000-8000-000000000002",
  // pending_merge_reviews
  pmr1: "11111111-0028-4000-8000-000000000001",
};

async function seedFixtures() {
  await db.insert(persons).values([
    {
      id: FX.personA,
      slug: "fx-triage-person-a",
      name: { "zh-Hans": "测试甲A", en: "Test A" },
      realityStatus: "historical",
      provenanceTier: "primary_text",
    },
    {
      id: FX.personB,
      slug: "fx-triage-person-b",
      name: { "zh-Hans": "测试甲B", en: "Test B" },
      realityStatus: "historical",
      provenanceTier: "primary_text",
    },
    {
      id: FX.personC,
      slug: "fx-triage-person-c",
      name: { "zh-Hans": "测试乙", en: "Test C" },
      realityStatus: "historical",
      provenanceTier: "primary_text",
    },
  ]);

  await db.insert(dictionarySources).values({
    id: FX.dictSource,
    sourceName: "test-source",
    sourceVersion: "v1",
    license: "CC0",
    commercialSafe: true,
  });

  await db.insert(dictionaryEntries).values([
    {
      id: FX.dictEntry1,
      sourceId: FX.dictSource,
      externalId: "TEST-1",
      entryType: "person",
      primaryName: "测试甲",
      attributes: {},
    },
    {
      id: FX.dictEntry2,
      sourceId: FX.dictSource,
      externalId: "TEST-2",
      entryType: "person",
      primaryName: "测试乙",
      attributes: {},
    },
  ]);

  // Seed mappings — pending_review
  // seed1: surface=测试甲, target=personA, created earliest
  // seed2: surface=测试乙, target=personC, created later
  // surface-cluster sort should put seed1 first (anchor 1000), then seed2 (anchor 2000)
  await db.insert(seedMappings).values([
    {
      id: FX.seed1,
      dictionaryEntryId: FX.dictEntry1,
      targetEntityType: "person",
      targetEntityId: FX.personA,
      confidence: "0.85",
      mappingMethod: "test_method",
      mappingStatus: "pending_review",
      mappingCreatedAt: new Date("2026-04-21T00:00:00Z"),
    },
    {
      id: FX.seed2,
      dictionaryEntryId: FX.dictEntry2,
      targetEntityType: "person",
      targetEntityId: FX.personC,
      confidence: "0.65",
      mappingMethod: "test_method",
      mappingStatus: "pending_review",
      mappingCreatedAt: new Date("2026-04-22T00:00:00Z"),
    },
  ]);

  // pending_merge_reviews — surface=测试甲 too (forms cluster with seed1)
  // pendingSince later than seed1 → cluster anchor stays seed1's pending_since
  // CHECK constraint requires personA < personB (UUID order), our FX UUIDs satisfy this
  await db.insert(pendingMergeReviews).values({
    id: FX.pmr1,
    personAId: FX.personA,
    personBId: FX.personB,
    proposedRule: "R1",
    guardType: "cross_dynasty",
    guardPayload: {
      surface_a: "测试甲",
      dynasty_a: "X",
      dynasty_b: "Y",
      gap_years: 300,
    },
    evidence: { source_evidence_id: null },
    status: "pending",
    createdAt: new Date("2026-04-23T00:00:00Z"),
  });
}

async function cleanupFixtures() {
  // Delete in FK-safe reverse order
  await db
    .delete(triageDecisions)
    .where(inArray(triageDecisions.sourceId, [FX.seed1, FX.seed2, FX.pmr1]));
  await db
    .delete(pendingMergeReviews)
    .where(eq(pendingMergeReviews.id, FX.pmr1));
  await db
    .delete(seedMappings)
    .where(inArray(seedMappings.id, [FX.seed1, FX.seed2]));
  await db
    .delete(dictionaryEntries)
    .where(inArray(dictionaryEntries.id, [FX.dictEntry1, FX.dictEntry2]));
  await db
    .delete(dictionarySources)
    .where(eq(dictionarySources.id, FX.dictSource));
  await db
    .delete(persons)
    .where(inArray(persons.id, [FX.personA, FX.personB, FX.personC]));
}

beforeAll(async () => {
  sql_ = postgres(DATABASE_URL, { max: 2 });
  db = drizzle(sql_);
  await cleanupFixtures().catch(() => undefined);
  await seedFixtures();
});

afterAll(async () => {
  await cleanupFixtures().catch(() => undefined);
  await sql_.end();
});

// Each test removes any triage_decisions it created against our fixtures so
// nextPendingItemId computations stay stable across tests.
afterEach(async () => {
  await db
    .delete(triageDecisions)
    .where(inArray(triageDecisions.sourceId, [FX.seed1, FX.seed2, FX.pmr1]));
});

// ----------------------------------------------------------------
// Unit tests (pure)
// ----------------------------------------------------------------

describe("deriveProvenanceTier (unit)", () => {
  it("maps recognized GraphQL-exposed tier values 1:1", () => {
    expect(__test.deriveProvenanceTier("primary_text")).toBe("primary_text");
    expect(__test.deriveProvenanceTier("scholarly_consensus")).toBe(
      "scholarly_consensus",
    );
    expect(__test.deriveProvenanceTier("ai_inferred")).toBe("ai_inferred");
    expect(__test.deriveProvenanceTier("unverified")).toBe("unverified");
  });

  it("falls back to 'unverified' for DB-only 'seed_dictionary' (ADR-021 enum gap)", () => {
    expect(__test.deriveProvenanceTier("seed_dictionary")).toBe("unverified");
  });

  it("falls back to 'unverified' for null / undefined / unknown", () => {
    expect(__test.deriveProvenanceTier(null)).toBe("unverified");
    expect(__test.deriveProvenanceTier(undefined)).toBe("unverified");
    expect(__test.deriveProvenanceTier("future_added_tier")).toBe("unverified");
  });
});

describe("encodeTriageItemId / decodeTriageItemId (unit)", () => {
  it("roundtrips seed_mapping kind", () => {
    const id = encodeTriageItemId(
      "seed_mapping",
      "550e8400-e29b-41d4-a716-446655440000",
    );
    expect(id).toBe("seed_mapping:550e8400-e29b-41d4-a716-446655440000");
    expect(__test.decodeTriageItemId(id)).toEqual({
      kind: "seed_mapping",
      sourceId: "550e8400-e29b-41d4-a716-446655440000",
    });
  });

  it("returns null for malformed ids", () => {
    expect(__test.decodeTriageItemId("invalid")).toBeNull();
    expect(__test.decodeTriageItemId("unknown_kind:abc")).toBeNull();
    expect(__test.decodeTriageItemId("seed_mapping:abc:xyz")).toBeNull();
  });
});

// ----------------------------------------------------------------
// Integration tests (real PG)
// ----------------------------------------------------------------

describe("listPendingItemRows (integration)", () => {
  it("returns surface-cluster ordered FIFO results across both source tables", async () => {
    const { items, total } = await listPendingItemRows(db, 100, 0, {
      filterByType: null,
      filterBySurface: null,
    });

    // Find our fixture rows in the result (DB may have other live rows).
    const fixtureItems = items.filter(
      (it) =>
        it.sourceId === FX.seed1 ||
        it.sourceId === FX.seed2 ||
        it.sourceId === FX.pmr1,
    );
    expect(fixtureItems.length).toBe(3);

    // Within fixtures: 测试甲 cluster anchor (seed1 @ 2026-04-21) precedes
    // 测试乙 cluster (seed2 @ 2026-04-22). Inside 测试甲, FIFO order: seed1 then pmr1.
    const fixtureIds = fixtureItems.map((it) => it.sourceId);
    expect(fixtureIds.indexOf(FX.seed1)).toBeLessThan(
      fixtureIds.indexOf(FX.pmr1),
    );
    expect(fixtureIds.indexOf(FX.pmr1)).toBeLessThan(
      fixtureIds.indexOf(FX.seed2),
    );

    // total reflects fixture rows (plus pre-existing live rows)
    expect(total).toBeGreaterThanOrEqual(3);

    // Check projected fields
    const seed1Item = fixtureItems.find((it) => it.sourceId === FX.seed1);
    expect(seed1Item?.kind).toBe("seed_mapping");
    expect(seed1Item?.surface).toBe("测试甲");
    expect(seed1Item?.itemId).toBe(
      `seed_mapping:${FX.seed1}`,
    );

    const pmrItem = fixtureItems.find((it) => it.sourceId === FX.pmr1);
    expect(pmrItem?.kind).toBe("guard_blocked_merge");
    expect(pmrItem?.surface).toBe("测试甲"); // from guard_payload.surface_a
  });
});

describe("recordTriageDecision (integration)", () => {
  it("persists a decision row and returns nextPendingItemId pointing to next queue item", async () => {
    const decisionInput = {
      itemId: encodeTriageItemId("seed_mapping", FX.seed1),
      decision: "REJECT" as const,
      reasonText: "test reject reason",
      reasonSourceType: "structural",
      historianId: "chief-historian",
    };
    const payload = await recordTriageDecision(
      db,
      decisionInput as never, // generated input type
    );
    expect(payload.error).toBeNull();
    expect(payload.triageDecision).not.toBeNull();
    expect(payload.triageDecision?.surfaceSnapshot).toBe("测试甲");
    expect(payload.triageDecision?.decision).toBe("REJECT");
    expect(payload.triageDecision?.historianId).toBe("chief-historian");

    // Verify persisted
    const row = await db
      .select()
      .from(triageDecisions)
      .where(eq(triageDecisions.id, String(payload.triageDecision?.id)))
      .limit(1);
    expect(row[0]).toBeDefined();
    expect(row[0]?.surfaceSnapshot).toBe("测试甲");
    expect(row[0]?.decision).toBe("reject"); // DB stores lowercase

    // nextPendingItemId should point to pmr1 or seed2 (next in queue), NOT
    // back to seed1 (we excluded it client-side).
    expect(payload.nextPendingItemId).not.toBe(
      encodeTriageItemId("seed_mapping", FX.seed1),
    );
    expect(payload.nextPendingItemId).not.toBeNull();
  });

  it("rejects with UNAUTHORIZED when historianId is not in allowlist", async () => {
    const payload = await recordTriageDecision(db, {
      itemId: encodeTriageItemId("seed_mapping", FX.seed1),
      decision: "APPROVE",
      reasonText: null,
      reasonSourceType: null,
      historianId: "unknown-historian",
    } as never);
    expect(payload.error?.code).toBe("UNAUTHORIZED");
    expect(payload.triageDecision).toBeNull();
    expect(payload.nextPendingItemId).toBeNull();

    // No row inserted
    const rows = await db
      .select()
      .from(triageDecisions)
      .where(eq(triageDecisions.sourceId, FX.seed1));
    expect(rows.length).toBe(0);
  });

  it("rejects with INVALID_REASON_SOURCE_TYPE for non-whitelisted source types", async () => {
    const payload = await recordTriageDecision(db, {
      itemId: encodeTriageItemId("seed_mapping", FX.seed1),
      decision: "DEFER",
      reasonText: "test",
      reasonSourceType: "made-up-type",
      historianId: "chief-historian",
    } as never);
    expect(payload.error?.code).toBe("INVALID_REASON_SOURCE_TYPE");
    expect(payload.triageDecision).toBeNull();
  });

  it("rejects with ITEM_NOT_FOUND for non-existent or non-pending source rows", async () => {
    const payload = await recordTriageDecision(db, {
      itemId: encodeTriageItemId(
        "seed_mapping",
        "00000000-0000-4000-8000-000000000000",
      ),
      decision: "APPROVE",
      reasonText: null,
      reasonSourceType: null,
      historianId: "chief-historian",
    } as never);
    expect(payload.error?.code).toBe("ITEM_NOT_FOUND");
  });

  it("allows multiple decisions on same source_id (defer → revisit → approve)", async () => {
    const baseInput = {
      itemId: encodeTriageItemId("seed_mapping", FX.seed1),
      historianId: "chief-historian",
      reasonText: null,
      reasonSourceType: null,
    };

    const r1 = await recordTriageDecision(db, {
      ...baseInput,
      decision: "DEFER",
    } as never);
    expect(r1.error).toBeNull();

    // Re-decide the same source_id
    const r2 = await recordTriageDecision(db, {
      ...baseInput,
      decision: "APPROVE",
    } as never);
    expect(r2.error).toBeNull();

    // Both rows persisted
    const rows = await db
      .select()
      .from(triageDecisions)
      .where(eq(triageDecisions.sourceId, FX.seed1))
      .orderBy(triageDecisions.decidedAt);
    expect(rows.length).toBe(2);
    expect(rows[0]?.decision).toBe("defer");
    expect(rows[1]?.decision).toBe("approve");
  });
});

describe("findTriageItemById (integration)", () => {
  it("returns null for malformed id", async () => {
    const r = await findTriageItemById(db, "garbage");
    expect(r).toBeNull();
  });

  it("returns the seed_mapping pending row by composite id", async () => {
    const r = await findTriageItemById(
      db,
      encodeTriageItemId("seed_mapping", FX.seed1),
    );
    expect(r).not.toBeNull();
    expect(r?.kind).toBe("seed_mapping");
    expect(r?.surface).toBe("测试甲");
    expect(r?.rawTargetEntityId).toBe(FX.personA);
  });

  it("returns null when seed_mapping is not pending_review", async () => {
    // Temporarily flip status; revert in this test
    await db
      .update(seedMappings)
      .set({ mappingStatus: "active" })
      .where(eq(seedMappings.id, FX.seed1));
    try {
      const r = await findTriageItemById(
        db,
        encodeTriageItemId("seed_mapping", FX.seed1),
      );
      expect(r).toBeNull();
    } finally {
      await db
        .update(seedMappings)
        .set({ mappingStatus: "pending_review" })
        .where(eq(seedMappings.id, FX.seed1));
    }
  });
});

describe("findPersonRowById (integration)", () => {
  it("returns active person directly", async () => {
    const r = await findPersonRowById(db, FX.personA);
    expect(r).not.toBeNull();
    expect(r?.slug).toBe("fx-triage-person-a");
  });

  it("returns null for missing id", async () => {
    const r = await findPersonRowById(
      db,
      "00000000-0000-4000-8000-000000000000",
    );
    expect(r).toBeNull();
  });
});
