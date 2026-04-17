import { persons, personNames, identityHypotheses } from "@huadian/db-schema";
import { eq } from "drizzle-orm";
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

import type { DrizzleClient } from "../src/context.js";
import {
  findPersonBySlug,
  findPersons,
} from "../src/services/person.service.js";

// ----------------------------------------------------------------
// Test infra: connect to real PG
// ----------------------------------------------------------------

const DATABASE_URL =
  process.env.DATABASE_URL ??
  "postgres://huadian:huadian_dev@127.0.0.1:5433/huadian";

let sql: ReturnType<typeof postgres>;
let db: DrizzleClient;

// Fixture IDs (deterministic for cleanup)
const FIXTURE_IDS = {
  liuBang: "aaaaaaaa-0001-4000-8000-000000000001",
  xiangYu: "aaaaaaaa-0001-4000-8000-000000000002",
  simaQian: "aaaaaaaa-0001-4000-8000-000000000003",
  deletedPerson: "aaaaaaaa-0001-4000-8000-000000000004",
  liuBangName1: "bbbbbbbb-0001-4000-8000-000000000001",
  liuBangName2: "bbbbbbbb-0001-4000-8000-000000000002",
  liuBangHyp: "cccccccc-0001-4000-8000-000000000001",
};

async function seedFixtures() {
  await db.insert(persons).values([
    {
      id: FIXTURE_IDS.liuBang,
      slug: "test-liu-bang",
      name: { "zh-Hans": "刘邦", "zh-Hant": "劉邦", en: "Liu Bang" },
      dynasty: "西汉",
      realityStatus: "historical",
      birthDate: { year_min: -256, year_max: -256, precision: "year" },
      deathDate: { year_min: -195, year_max: -195, precision: "year" },
      biography: { "zh-Hans": "汉高祖", en: "First emperor of Han dynasty" },
      provenanceTier: "primary_text",
    },
    {
      id: FIXTURE_IDS.xiangYu,
      slug: "test-xiang-yu",
      name: { "zh-Hans": "项羽", en: "Xiang Yu" },
      dynasty: "秦末楚汉",
      realityStatus: "historical",
      provenanceTier: "primary_text",
    },
    {
      id: FIXTURE_IDS.simaQian,
      slug: "test-sima-qian",
      name: { "zh-Hans": "司马迁", en: "Sima Qian" },
      dynasty: "西汉",
      realityStatus: "historical",
      provenanceTier: "primary_text",
    },
    {
      id: FIXTURE_IDS.deletedPerson,
      slug: "test-deleted-person",
      name: { "zh-Hans": "已删除" },
      realityStatus: "historical",
      provenanceTier: "unverified",
      deletedAt: new Date("2026-01-01T00:00:00Z"),
    },
  ]);

  await db.insert(personNames).values([
    {
      id: FIXTURE_IDS.liuBangName1,
      personId: FIXTURE_IDS.liuBang,
      name: "刘季",
      namePinyin: "Liu Ji",
      nameType: "alias",
      isPrimary: false,
    },
    {
      id: FIXTURE_IDS.liuBangName2,
      personId: FIXTURE_IDS.liuBang,
      name: "高祖",
      namePinyin: "Gaozu",
      nameType: "posthumous",
      isPrimary: true,
    },
  ]);

  await db.insert(identityHypotheses).values([
    {
      id: FIXTURE_IDS.liuBangHyp,
      canonicalPersonId: FIXTURE_IDS.liuBang,
      relationType: "same_person",
      scholarlySupport: "Sima Qian, Shiji",
      evidenceIds: [],
      acceptedByDefault: true,
    },
  ]);
}

async function cleanupFixtures() {
  await db.delete(identityHypotheses).where(
    eq(identityHypotheses.id, FIXTURE_IDS.liuBangHyp),
  );
  await db.delete(personNames).where(
    eq(personNames.id, FIXTURE_IDS.liuBangName1),
  );
  await db.delete(personNames).where(
    eq(personNames.id, FIXTURE_IDS.liuBangName2),
  );
  for (const id of [
    FIXTURE_IDS.liuBang,
    FIXTURE_IDS.xiangYu,
    FIXTURE_IDS.simaQian,
    FIXTURE_IDS.deletedPerson,
  ]) {
    await db.delete(persons).where(eq(persons.id, id));
  }
}

// ----------------------------------------------------------------
// Setup / Teardown
// ----------------------------------------------------------------

beforeAll(async () => {
  sql = postgres(DATABASE_URL, { max: 2 });
  db = drizzle(sql);

  await cleanupFixtures().catch(() => { /* ignore if fixtures don't exist */ });
  await seedFixtures();
});

afterAll(async () => {
  await cleanupFixtures().catch(() => { /* ignore cleanup errors */ });
  await sql.end();
});

// ----------------------------------------------------------------
// Tests
// ----------------------------------------------------------------

describe("findPersonBySlug (integration)", () => {
  it("returns person with names and hypotheses for valid slug", async () => {
    const result = await findPersonBySlug(db, "test-liu-bang");

    expect(result).not.toBeNull();
    expect(result!.__typename).toBe("Person");
    expect(result!.slug).toBe("test-liu-bang");
    expect(result!.name.zhHans).toBe("刘邦");
    expect(result!.name.en).toBe("Liu Bang");
    expect(result!.dynasty).toBe("西汉");
    expect(result!.realityStatus).toBe("historical");
    expect(result!.provenanceTier).toBe("primary_text");
    expect(result!.sourceEvidenceId).toBeNull();

    // birthDate JSONB mapping
    expect(result!.birthDate).not.toBeNull();
    expect(result!.birthDate!.yearMin).toBe(-256);
    expect(result!.birthDate!.precision).toBe("year");

    // Eager-loaded names
    expect(result!.names).toHaveLength(2);
    const aliasName = result!.names.find((n) => n.nameType === "alias");
    expect(aliasName).toBeDefined();
    expect(aliasName!.name).toBe("刘季");

    // Eager-loaded hypotheses
    expect(result!.identityHypotheses).toHaveLength(1);
    expect(result!.identityHypotheses[0].relationType).toBe("same_person");
  });

  it("returns null for non-existent slug", async () => {
    const result = await findPersonBySlug(db, "nonexistent-slug");
    expect(result).toBeNull();
  });

  it("returns null for soft-deleted person", async () => {
    const result = await findPersonBySlug(db, "test-deleted-person");
    expect(result).toBeNull();
  });
});

describe("findPersons (integration)", () => {
  it("returns paginated persons excluding soft-deleted", async () => {
    const result = await findPersons(db, 100, 0);

    const testSlugs = result.map((p) => p.slug).filter((s) => s.startsWith("test-"));
    expect(testSlugs).toContain("test-liu-bang");
    expect(testSlugs).toContain("test-xiang-yu");
    expect(testSlugs).toContain("test-sima-qian");
    expect(testSlugs).not.toContain("test-deleted-person");
  });

  it("respects limit parameter", async () => {
    const result = await findPersons(db, 2, 0);
    expect(result.length).toBeLessThanOrEqual(2);
  });

  it("clamps limit to max 100", async () => {
    const result = await findPersons(db, 999, 0);
    expect(result.length).toBeLessThanOrEqual(100);
  });

  it("returns empty array for offset beyond data", async () => {
    const result = await findPersons(db, 20, 99999);
    expect(result).toEqual([]);
  });

  it("returns persons ordered by created_at desc", async () => {
    const result = await findPersons(db, 100, 0);
    for (let i = 1; i < result.length; i++) {
      expect(result[i - 1].updatedAt >= result[i].updatedAt).toBe(true);
    }
  });
});
