import { persons, personNames } from "@huadian/db-schema";
import { eq } from "drizzle-orm";
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

import type { DrizzleClient } from "../src/context.js";
import { searchPersons } from "../src/services/person.service.js";

// ----------------------------------------------------------------
// Test infra: connect to real PG
// ----------------------------------------------------------------

const DATABASE_URL =
  process.env.DATABASE_URL ??
  "postgres://huadian:huadian_dev@127.0.0.1:5433/huadian";

let pgClient: ReturnType<typeof postgres>;
let db: DrizzleClient;

// Fixture IDs (deterministic, non-overlapping with T-P0-007 fixtures)
const FX = {
  liBai:      "dddddddd-0009-4000-8000-000000000001",
  duFu:       "dddddddd-0009-4000-8000-000000000002",
  wangWei:    "dddddddd-0009-4000-8000-000000000003",
  liShangyin: "dddddddd-0009-4000-8000-000000000004",
  deleted:    "dddddddd-0009-4000-8000-000000000005",
  // person_names
  liBaiName1: "eeeeeeee-0009-4000-8000-000000000001",
  liBaiName2: "eeeeeeee-0009-4000-8000-000000000002",
  duFuName1:  "eeeeeeee-0009-4000-8000-000000000003",
};

async function seedFixtures() {
  await db.insert(persons).values([
    {
      id: FX.liBai,
      slug: "test-search-li-bai",
      name: { "zh-Hans": "李白", en: "Li Bai" },
      dynasty: "唐",
      realityStatus: "historical",
      provenanceTier: "primary_text",
    },
    {
      id: FX.duFu,
      slug: "test-search-du-fu",
      name: { "zh-Hans": "杜甫", en: "Du Fu" },
      dynasty: "唐",
      realityStatus: "historical",
      provenanceTier: "primary_text",
    },
    {
      id: FX.wangWei,
      slug: "test-search-wang-wei",
      name: { "zh-Hans": "王维", en: "Wang Wei" },
      dynasty: "唐",
      realityStatus: "historical",
      provenanceTier: "primary_text",
    },
    {
      id: FX.liShangyin,
      slug: "test-search-li-shangyin",
      name: { "zh-Hans": "李商隐", en: "Li Shangyin" },
      dynasty: "唐",
      realityStatus: "historical",
      provenanceTier: "primary_text",
    },
    {
      id: FX.deleted,
      slug: "test-search-deleted",
      name: { "zh-Hans": "已删除搜索" },
      realityStatus: "historical",
      provenanceTier: "unverified",
      deletedAt: new Date("2026-01-01T00:00:00Z"),
    },
  ]);

  await db.insert(personNames).values([
    {
      id: FX.liBaiName1,
      personId: FX.liBai,
      name: "李太白",
      namePinyin: "Li Taibai",
      nameType: "courtesy",
      isPrimary: false,
    },
    {
      id: FX.liBaiName2,
      personId: FX.liBai,
      name: "青莲居士",
      namePinyin: "Qinglian Jushi",
      nameType: "alias",
      isPrimary: false,
    },
    {
      id: FX.duFuName1,
      personId: FX.duFu,
      name: "杜子美",
      namePinyin: "Du Zimei",
      nameType: "courtesy",
      isPrimary: false,
    },
  ]);
}

async function cleanupFixtures() {
  for (const id of [FX.liBaiName1, FX.liBaiName2, FX.duFuName1]) {
    await db.delete(personNames).where(eq(personNames.id, id));
  }
  for (const id of [FX.liBai, FX.duFu, FX.wangWei, FX.liShangyin, FX.deleted]) {
    await db.delete(persons).where(eq(persons.id, id));
  }
}

// ----------------------------------------------------------------
// Setup / Teardown
// ----------------------------------------------------------------

beforeAll(async () => {
  pgClient = postgres(DATABASE_URL, { max: 2 });
  db = drizzle(pgClient);

  await cleanupFixtures().catch(() => {});
  await seedFixtures();
});

afterAll(async () => {
  await cleanupFixtures().catch(() => {});
  await pgClient.end();
});

// ----------------------------------------------------------------
// Tests: searchPersons
// ----------------------------------------------------------------

describe("searchPersons — no search term", () => {
  it("returns all non-deleted persons with total", async () => {
    const result = await searchPersons(db, null, 100, 0);

    const testSlugs = result.items.map(p => p.slug).filter(s => s.startsWith("test-search-"));
    expect(testSlugs).toContain("test-search-li-bai");
    expect(testSlugs).toContain("test-search-du-fu");
    expect(testSlugs).toContain("test-search-wang-wei");
    expect(testSlugs).toContain("test-search-li-shangyin");
    expect(testSlugs).not.toContain("test-search-deleted");
    expect(result.total).toBeGreaterThanOrEqual(4);
    expect(typeof result.hasMore).toBe("boolean");
  });

  it("respects pagination limit", async () => {
    const result = await searchPersons(db, null, 2, 0);
    expect(result.items.length).toBeLessThanOrEqual(2);
    expect(result.total).toBeGreaterThanOrEqual(4);
    expect(result.hasMore).toBe(true);
  });

  it("returns hasMore=false when at the end", async () => {
    // Probe total, then offset to near the end so remaining items < limit
    const probe = await searchPersons(db, null, 1, 0);
    const nearEnd = Math.max(0, probe.total - 3);
    const result = await searchPersons(db, null, 100, nearEnd);
    expect(result.hasMore).toBe(false);
    expect(result.items.length).toBeLessThanOrEqual(3);
  });

  it("returns empty items for offset beyond data", async () => {
    const result = await searchPersons(db, null, 20, 99999);
    expect(result.items).toEqual([]);
    expect(result.hasMore).toBe(false);
  });
});

describe("searchPersons — exact match (ILIKE on persons.name)", () => {
  it("finds person by canonical Chinese name", async () => {
    const result = await searchPersons(db, "李白", 20, 0);

    expect(result.total).toBeGreaterThanOrEqual(1);
    const slugs = result.items.map(p => p.slug);
    expect(slugs).toContain("test-search-li-bai");
  });

  it("exact match ranks first", async () => {
    // "李白" should rank higher than "李商隐" (which also contains "李")
    const result = await searchPersons(db, "李白", 20, 0);
    const liBaiIdx = result.items.findIndex(p => p.slug === "test-search-li-bai");
    const liShangyinIdx = result.items.findIndex(p => p.slug === "test-search-li-shangyin");

    // 李白 should appear; if 李商隐 also matches, 李白 should be first
    expect(liBaiIdx).toBeGreaterThanOrEqual(0);
    if (liShangyinIdx >= 0) {
      expect(liBaiIdx).toBeLessThan(liShangyinIdx);
    }
  });
});

describe("searchPersons — fuzzy match (pg_trgm on person_names)", () => {
  it("finds person via alias in person_names", async () => {
    // "李太白" is a person_name for 李白
    const result = await searchPersons(db, "李太白", 20, 0);

    const slugs = result.items.map(p => p.slug);
    expect(slugs).toContain("test-search-li-bai");
  });

  it("finds person via courtesy name", async () => {
    // "杜子美" is Du Fu's courtesy name
    const result = await searchPersons(db, "杜子美", 20, 0);

    const slugs = result.items.map(p => p.slug);
    expect(slugs).toContain("test-search-du-fu");
  });

  it("finds person via partial alias (ILIKE substring)", async () => {
    // "青莲" is a substring of "青莲居士" (Li Bai's alias)
    const result = await searchPersons(db, "青莲", 20, 0);

    const slugs = result.items.map(p => p.slug);
    expect(slugs).toContain("test-search-li-bai");
  });
});

describe("searchPersons — empty results", () => {
  it("returns empty for gibberish search", async () => {
    const result = await searchPersons(db, "xyzzyspoon", 20, 0);

    expect(result.items).toEqual([]);
    expect(result.total).toBe(0);
    expect(result.hasMore).toBe(false);
  });

  it("returns empty for whitespace-only search (treated as no search)", async () => {
    const result = await searchPersons(db, "   ", 100, 0);

    // Whitespace-only is treated as empty search → returns all persons
    expect(result.total).toBeGreaterThanOrEqual(4);
  });
});

describe("searchPersons — soft-delete exclusion", () => {
  it("excludes soft-deleted persons from search", async () => {
    const result = await searchPersons(db, "已删除搜索", 20, 0);

    const slugs = result.items.map(p => p.slug);
    expect(slugs).not.toContain("test-search-deleted");
  });
});

describe("searchPersons — pagination with search", () => {
  it("paginates search results correctly", async () => {
    // Search for "李" which should match at least 李白 and 李商隐
    const page1 = await searchPersons(db, "李", 1, 0);
    expect(page1.items).toHaveLength(1);
    expect(page1.total).toBeGreaterThanOrEqual(2);
    expect(page1.hasMore).toBe(true);

    const page2 = await searchPersons(db, "李", 1, 1);
    expect(page2.items).toHaveLength(1);
    // Different person on page 2
    expect(page2.items[0].slug).not.toBe(page1.items[0].slug);
  });
});

// ----------------------------------------------------------------
// T-P1-003: Search precision regression tests
// Tests against REAL production data (152 persons from Shiji).
// These verify that known FP cases are eliminated and true recalls preserved.
// ----------------------------------------------------------------

describe("searchPersons — T-P1-003 precision regression (real data)", () => {
  it("G04: '帝中' returns 中丁 but NOT 中壬 or 中康", async () => {
    const result = await searchPersons(db, "帝中", 100, 0);
    const slugs = result.items.map(p => p.slug);

    expect(slugs).toContain("u4e2d-u4e01"); // 中丁 (canonical for 帝中丁)
    expect(slugs).not.toContain("u4e2d-u58ec"); // 中壬 must NOT appear
    expect(slugs).not.toContain("zhong-kang"); // 中康 must NOT appear
  });

  it("G05: '帝中丁' returns 中丁 but NOT 中壬 or 中康", async () => {
    const result = await searchPersons(db, "帝中丁", 100, 0);
    const slugs = result.items.map(p => p.slug);

    expect(slugs).toContain("u4e2d-u4e01"); // 中丁
    expect(slugs).not.toContain("u4e2d-u58ec"); // 中壬
    expect(slugs).not.toContain("zhong-kang"); // 中康
  });

  it("G12: '帝武乙' returns 武乙 but NOT 武丁", async () => {
    const result = await searchPersons(db, "帝武乙", 100, 0);
    const slugs = result.items.map(p => p.slug);

    expect(slugs).toContain("u6b66-u4e59"); // 武乙
    expect(slugs).not.toContain("wu-ding"); // 武丁 must NOT appear
  });

  it("exact recall preserved: '黄帝' finds huang-di", async () => {
    const result = await searchPersons(db, "黄帝", 100, 0);
    const slugs = result.items.map(p => p.slug);

    expect(slugs).toContain("huang-di");
  });

  it("alias recall preserved: '虞舜' finds shun via person_name alias", async () => {
    const result = await searchPersons(db, "虞舜", 100, 0);
    const slugs = result.items.map(p => p.slug);

    expect(slugs).toContain("shun");
  });

  it("single-char recall preserved: '禹' finds yu", async () => {
    const result = await searchPersons(db, "禹", 100, 0);
    const slugs = result.items.map(p => p.slug);

    expect(slugs).toContain("yu");
    expect(slugs).toHaveLength(1); // only 禹, no noise
  });

  it("not-found: '项羽' returns empty", async () => {
    const result = await searchPersons(db, "项羽", 100, 0);

    expect(result.items).toHaveLength(0);
    expect(result.total).toBe(0);
  });
});
