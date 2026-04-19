/**
 * T-P1-002: Integration tests for person_names dedup + primary demotion.
 *
 * Tests the read-side dedup in findPersonNamesWithMerged (via findPersonBySlug)
 * and verifies the aggregated names view is correct for merged persons.
 *
 * Requires a running PostgreSQL with schema applied.
 */
import { persons, personNames } from "@huadian/db-schema";
import { inArray } from "drizzle-orm";
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

import type { DrizzleClient } from "../src/context.js";
import {
  findPersonBySlug,
  findPersonNamesByPersonId,
} from "../src/services/person.service.js";

// ----------------------------------------------------------------
// Test infra
// ----------------------------------------------------------------

const DATABASE_URL =
  process.env.DATABASE_URL ??
  "postgres://huadian:huadian_dev@127.0.0.1:5433/huadian";

let sqlClient: ReturnType<typeof postgres>;
let db: DrizzleClient;

// Deterministic fixture IDs
const FIX = {
  // Scenario 1: 尧 (canonical) + merged person with duplicate "尧" + extra primary "放勋"
  yao:           "dd000001-0001-4000-8000-000000000001",
  yaoMerged:     "dd000001-0001-4000-8000-000000000002",
  yaoName1:      "dd000001-0002-4000-8000-000000000001", // 尧 primary (canonical)
  yaoName2:      "dd000001-0002-4000-8000-000000000002", // 放勋 primary (merged, pre-backfill)
  yaoName3:      "dd000001-0002-4000-8000-000000000003", // 尧 primary (merged, cross-person dup)

  // Scenario 2: 黄帝 (canonical) + merged 帝鸿氏 with duplicate alias
  huangdi:       "dd000002-0001-4000-8000-000000000001",
  dihong:        "dd000002-0001-4000-8000-000000000002",
  huangdiName1:  "dd000002-0002-4000-8000-000000000001", // 黄帝 primary
  huangdiName2:  "dd000002-0002-4000-8000-000000000002", // 帝鸿氏 alias (canonical side)
  dihongName1:   "dd000002-0002-4000-8000-000000000003", // 帝鸿氏 alias (merged side, dup)
  dihongName2:   "dd000002-0002-4000-8000-000000000004", // 帝鸿 nickname (unique to merged)

  // Scenario 3: dedup priority — source_evidence_id presence
  canonA:        "dd000003-0001-4000-8000-000000000001",
  mergedB:       "dd000003-0001-4000-8000-000000000002",
  canonAName1:   "dd000003-0002-4000-8000-000000000001", // 共享名 (no source_evidence_id)
  mergedBName1:  "dd000003-0002-4000-8000-000000000002", // 共享名 (has source_evidence_id)
  mergedBName2:  "dd000003-0002-4000-8000-000000000003", // unique name
  fakeSrcEvId:   "dd000003-0003-4000-8000-000000000001", // fake source_evidence_id
};

const ALL_PERSON_IDS = [
  FIX.yao, FIX.yaoMerged,
  FIX.huangdi, FIX.dihong,
  FIX.canonA, FIX.mergedB,
];

const ALL_NAME_IDS = [
  FIX.yaoName1, FIX.yaoName2, FIX.yaoName3,
  FIX.huangdiName1, FIX.huangdiName2, FIX.dihongName1, FIX.dihongName2,
  FIX.canonAName1, FIX.mergedBName1, FIX.mergedBName2,
];

const now = new Date("2026-04-19T10:00:00Z");
const earlier = new Date("2026-04-18T10:00:00Z");

async function seedFixtures() {
  // --- Persons ---
  await db.insert(persons).values([
    // Scenario 1: 尧 canonical
    {
      id: FIX.yao,
      slug: "test-dd-yao",
      name: { "zh-Hans": "尧" },
      realityStatus: "historical",
      provenanceTier: "primary_text",
      createdAt: earlier,
      updatedAt: earlier,
    },
    // Scenario 1: merged person
    {
      id: FIX.yaoMerged,
      slug: "test-dd-yao-merged",
      name: { "zh-Hans": "放勋" },
      realityStatus: "historical",
      provenanceTier: "primary_text",
      mergedIntoId: FIX.yao,
      deletedAt: now,
      createdAt: earlier,
      updatedAt: now,
    },
    // Scenario 2: 黄帝 canonical
    {
      id: FIX.huangdi,
      slug: "test-dd-huang-di",
      name: { "zh-Hans": "黄帝" },
      realityStatus: "historical",
      provenanceTier: "primary_text",
      createdAt: earlier,
      updatedAt: earlier,
    },
    // Scenario 2: 帝鸿氏 merged
    {
      id: FIX.dihong,
      slug: "test-dd-di-hong",
      name: { "zh-Hans": "帝鸿氏" },
      realityStatus: "historical",
      provenanceTier: "primary_text",
      mergedIntoId: FIX.huangdi,
      deletedAt: now,
      createdAt: earlier,
      updatedAt: now,
    },
    // Scenario 3: canonical A
    {
      id: FIX.canonA,
      slug: "test-dd-canon-a",
      name: { "zh-Hans": "甲某" },
      realityStatus: "historical",
      provenanceTier: "primary_text",
      createdAt: earlier,
      updatedAt: earlier,
    },
    // Scenario 3: merged B
    {
      id: FIX.mergedB,
      slug: "test-dd-merged-b",
      name: { "zh-Hans": "甲某别名" },
      realityStatus: "historical",
      provenanceTier: "primary_text",
      mergedIntoId: FIX.canonA,
      deletedAt: now,
      createdAt: earlier,
      updatedAt: now,
    },
  ]);

  // --- person_merge_log (raw SQL, not in Drizzle schema) ---
  const nowIso = now.toISOString();
  await sqlClient`
    INSERT INTO person_merge_log (id, run_id, canonical_id, merged_id, merge_rule, confidence, merged_by, merged_at)
    VALUES
      (gen_random_uuid(), gen_random_uuid(), ${FIX.yao}, ${FIX.yaoMerged}, 'R1', 0.95, 'test', ${nowIso}::timestamptz),
      (gen_random_uuid(), gen_random_uuid(), ${FIX.huangdi}, ${FIX.dihong}, 'R4-honorific-alias', 0.95, 'test', ${nowIso}::timestamptz),
      (gen_random_uuid(), gen_random_uuid(), ${FIX.canonA}, ${FIX.mergedB}, 'R1', 0.90, 'test', ${nowIso}::timestamptz)
  `;

  // --- Person Names ---
  await db.insert(personNames).values([
    // Scenario 1: 尧 names
    {
      id: FIX.yaoName1,
      personId: FIX.yao,
      name: "尧",
      nameType: "primary",
      isPrimary: true,
      createdAt: earlier,
    },
    {
      id: FIX.yaoName2,
      personId: FIX.yaoMerged,
      name: "放勋",
      nameType: "primary", // pre-backfill: still primary on merged person
      isPrimary: true,
      createdAt: earlier,
    },
    {
      id: FIX.yaoName3,
      personId: FIX.yaoMerged,
      name: "尧",
      nameType: "primary", // cross-person-id duplicate
      isPrimary: true,
      createdAt: now, // newer than canonical's
    },

    // Scenario 2: 黄帝 + 帝鸿氏 duplicate alias
    {
      id: FIX.huangdiName1,
      personId: FIX.huangdi,
      name: "黄帝",
      nameType: "primary",
      isPrimary: true,
      createdAt: earlier,
    },
    {
      id: FIX.huangdiName2,
      personId: FIX.huangdi,
      name: "帝鸿氏",
      nameType: "alias",
      isPrimary: false,
      createdAt: now,
    },
    {
      id: FIX.dihongName1,
      personId: FIX.dihong,
      name: "帝鸿氏", // duplicate with canonical side
      nameType: "alias",
      isPrimary: false,
      createdAt: earlier,
    },
    {
      id: FIX.dihongName2,
      personId: FIX.dihong,
      name: "帝鸿",
      nameType: "nickname",
      isPrimary: false,
      createdAt: earlier,
    },

    // Scenario 3: source_evidence_id priority
    {
      id: FIX.canonAName1,
      personId: FIX.canonA,
      name: "共享名",
      nameType: "alias",
      isPrimary: false,
      sourceEvidenceId: null,
      createdAt: earlier,
    },
    {
      id: FIX.mergedBName1,
      personId: FIX.mergedB,
      name: "共享名", // duplicate, but has source_evidence_id
      nameType: "alias",
      isPrimary: false,
      sourceEvidenceId: null, // can't use fake ID due to FK constraint
      createdAt: now,
    },
    {
      id: FIX.mergedBName2,
      personId: FIX.mergedB,
      name: "甲某别名",
      nameType: "alias",
      isPrimary: false,
      createdAt: earlier,
    },
  ]);
}

async function cleanupFixtures() {
  // Clean in reverse dependency order
  await sqlClient`
    DELETE FROM person_merge_log
    WHERE canonical_id = ANY(${ALL_PERSON_IDS}::uuid[])
       OR merged_id = ANY(${ALL_PERSON_IDS}::uuid[])
  `;
  await db.delete(personNames).where(inArray(personNames.id, ALL_NAME_IDS));
  await db.delete(persons).where(inArray(persons.id, ALL_PERSON_IDS));
}

// ----------------------------------------------------------------
// Setup / Teardown
// ----------------------------------------------------------------

beforeAll(async () => {
  sqlClient = postgres(DATABASE_URL, { max: 2 });
  db = drizzle(sqlClient);
  await cleanupFixtures().catch(() => { /* ignore */ });
  await seedFixtures();
});

afterAll(async () => {
  await cleanupFixtures().catch(() => { /* ignore */ });
  await sqlClient.end();
});

// ----------------------------------------------------------------
// Tests
// ----------------------------------------------------------------

describe("T-P1-002: read-side name dedup", () => {
  it("尧: cross-person-id '尧' duplicate is deduped to 1 row", async () => {
    const result = await findPersonBySlug(db, "test-dd-yao");
    expect(result).not.toBeNull();

    const yaoNames = result!.names.filter(n => n.name === "尧");
    expect(yaoNames).toHaveLength(1);
    // The retained row should be from canonical side (priority rule a)
    expect(yaoNames[0].personId).toBe(FIX.yao);
  });

  it("尧: merged person's unique name '放勋' is still included", async () => {
    const result = await findPersonBySlug(db, "test-dd-yao");
    expect(result).not.toBeNull();

    const fangxun = result!.names.filter(n => n.name === "放勋");
    expect(fangxun).toHaveLength(1);
  });

  it("尧: total names = 2 (尧 deduped + 放勋 unique)", async () => {
    const result = await findPersonBySlug(db, "test-dd-yao");
    expect(result).not.toBeNull();
    expect(result!.names).toHaveLength(2);
  });

  it("黄帝: '帝鸿氏' alias × 2 is deduped to 1 row", async () => {
    const result = await findPersonBySlug(db, "test-dd-huang-di");
    expect(result).not.toBeNull();

    const dihongNames = result!.names.filter(n => n.name === "帝鸿氏");
    expect(dihongNames).toHaveLength(1);
  });

  it("黄帝: unique merged name '帝鸿' is still included", async () => {
    const result = await findPersonBySlug(db, "test-dd-huang-di");
    expect(result).not.toBeNull();

    const dihong = result!.names.filter(n => n.name === "帝鸿");
    expect(dihong).toHaveLength(1);
  });

  it("黄帝: total names = 3 (黄帝 + 帝鸿氏 deduped + 帝鸿)", async () => {
    const result = await findPersonBySlug(db, "test-dd-huang-di");
    expect(result).not.toBeNull();
    expect(result!.names).toHaveLength(3);
  });

  it("dedup prefers canonical-side row (priority rule a)", async () => {
    const result = await findPersonBySlug(db, "test-dd-canon-a");
    expect(result).not.toBeNull();

    const shared = result!.names.filter(n => n.name === "共享名");
    expect(shared).toHaveLength(1);
    // Canonical-side row should win
    expect(shared[0].personId).toBe(FIX.canonA);
  });

  it("merged person's unique names survive dedup", async () => {
    const result = await findPersonBySlug(db, "test-dd-canon-a");
    expect(result).not.toBeNull();

    const unique = result!.names.filter(n => n.name === "甲某别名");
    expect(unique).toHaveLength(1);
    expect(unique[0].personId).toBe(FIX.mergedB);
  });

  it("findPersonNamesByPersonId also applies dedup", async () => {
    const names = await findPersonNamesByPersonId(db, FIX.yao);
    const yaoNames = names.filter(n => n.name === "尧");
    expect(yaoNames).toHaveLength(1);
    expect(yaoNames[0].personId).toBe(FIX.yao);
  });
});
