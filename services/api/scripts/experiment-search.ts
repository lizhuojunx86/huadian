/**
 * experiment-search.ts — Run strategy experiments for T-P1-003
 *
 * Tests 4 strategies (A-D) by directly executing SQL against the DB,
 * using the same golden set and metric functions as bench-search.ts.
 *
 * Usage:
 *   tsx scripts/experiment-search.ts
 */

import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { sql, inArray } from "drizzle-orm";
import { persons } from "@huadian/db-schema";

import type { DrizzleClient } from "../src/context.js";

// ----------------------------------------------------------------
// Config
// ----------------------------------------------------------------

const __dirname = dirname(fileURLToPath(import.meta.url));
const GOLDEN_PATH = resolve(__dirname, "../tests/fixtures/search-golden.json");
const BENCHMARKS_DIR = resolve(__dirname, "../benchmarks");
const DOCS_DIR = resolve(__dirname, "../../../docs/benchmarks");

const DATABASE_URL =
  process.env.DATABASE_URL ??
  "postgres://huadian:huadian_dev@127.0.0.1:5433/huadian";

const dateStr = new Date().toISOString().slice(0, 10);

// ----------------------------------------------------------------
// Types
// ----------------------------------------------------------------

interface GoldenCase {
  id: string;
  query: string;
  expected_slugs: string[];
  disallowed_slugs: string[];
  rationale: string;
}

interface QueryResult {
  id: string;
  query: string;
  expected_slugs: string[];
  disallowed_slugs: string[];
  returned_slugs: string[];
  precision: number;
  recall: number;
  f1: number;
  disallowed_hits: string[];
}

interface ExperimentReport {
  label: string;
  date: string;
  macro_precision: number;
  macro_recall: number;
  macro_f1: number;
  disallowed_violation_count: number;
  perfect_count: number;
  total_queries: number;
  queries: QueryResult[];
}

// ----------------------------------------------------------------
// Metrics
// ----------------------------------------------------------------

function computeMetrics(expected: string[], returned: string[], disallowed: string[]) {
  const returnedSet = new Set(returned);
  const expectedSet = new Set(expected);

  if (expectedSet.size === 0 && returnedSet.size === 0) {
    return { precision: 1, recall: 1, f1: 1, disallowed_hits: [] as string[] };
  }
  if (expectedSet.size === 0 && returnedSet.size > 0) {
    return {
      precision: 0, recall: 1, f1: 0,
      disallowed_hits: disallowed.filter((s) => returnedSet.has(s)),
    };
  }

  const tp = [...expectedSet].filter((s) => returnedSet.has(s)).length;
  const precision = returnedSet.size > 0 ? tp / returnedSet.size : 0;
  const recall = expectedSet.size > 0 ? tp / expectedSet.size : 1;
  const f1 = precision + recall > 0 ? (2 * precision * recall) / (precision + recall) : 0;
  return { precision, recall, f1, disallowed_hits: disallowed.filter((s) => returnedSet.has(s)) };
}

// ----------------------------------------------------------------
// Strategy implementations (direct SQL)
// ----------------------------------------------------------------

type SearchFn = (db: DrizzleClient, term: string) => Promise<string[]>;

/** Strategy A: raise threshold to 0.4 */
const strategyA: SearchFn = async (db, term) => {
  const likePattern = `%${term}%`;
  const result = await db.execute(sql`
    SELECT COALESCE(p.merged_into_id, p.id) AS id
    FROM persons p
    LEFT JOIN person_names pn ON pn.person_id = p.id
    WHERE (p.deleted_at IS NULL OR p.merged_into_id IS NOT NULL)
      AND (
        similarity(pn.name, ${term}) > 0.4
        OR p.name->>'zh-Hans' ILIKE ${likePattern}
      )
    GROUP BY COALESCE(p.merged_into_id, p.id)
    ORDER BY MAX(GREATEST(
      COALESCE(similarity(pn.name, ${term}), 0),
      CASE WHEN p.name->>'zh-Hans' ILIKE ${likePattern} THEN 0.5 ELSE 0 END
    )) DESC
    LIMIT 100
  `);
  const ids = (result as unknown as Array<{ id: string }>).map(r => r.id);
  return idsToSlugs(db, ids);
};

/** Strategy B: exact/prefix first, trigram fallback (short query → LIKE 'q%' priority) */
const strategyB: SearchFn = async (db, term) => {
  const likePattern = `%${term}%`;
  const prefixPattern = `${term}%`;
  // Score: exact=1.0, prefix=0.8, ILIKE_contains=0.5, trigram=raw_sim
  const result = await db.execute(sql`
    SELECT COALESCE(p.merged_into_id, p.id) AS id
    FROM persons p
    LEFT JOIN person_names pn ON pn.person_id = p.id
    WHERE (p.deleted_at IS NULL OR p.merged_into_id IS NOT NULL)
      AND (
        pn.name = ${term}
        OR pn.name LIKE ${prefixPattern}
        OR similarity(pn.name, ${term}) > 0.3
        OR p.name->>'zh-Hans' ILIKE ${likePattern}
      )
    GROUP BY COALESCE(p.merged_into_id, p.id)
    ORDER BY MAX(GREATEST(
      CASE WHEN pn.name = ${term} THEN 1.0 ELSE 0 END,
      CASE WHEN pn.name LIKE ${prefixPattern} THEN 0.8 ELSE 0 END,
      COALESCE(similarity(pn.name, ${term}), 0),
      CASE WHEN p.name->>'zh-Hans' ILIKE ${likePattern} THEN 0.5 ELSE 0 END
    )) DESC
    LIMIT 100
  `);
  const ids = (result as unknown as Array<{ id: string }>).map(r => r.id);
  return idsToSlugs(db, ids);
};

/** Strategy C: length-weighted threshold (short query → higher threshold) */
const strategyC: SearchFn = async (db, term) => {
  const likePattern = `%${term}%`;
  // For Chinese characters: each char is typically 3 bytes, so char_length
  const charLen = [...term].length;
  // Short (1-2 chars): threshold 0.5; Medium (3 chars): 0.4; Long (4+): 0.3
  const threshold = charLen <= 2 ? 0.5 : charLen <= 3 ? 0.4 : 0.3;

  const result = await db.execute(sql`
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
    LIMIT 100
  `);
  const ids = (result as unknown as Array<{ id: string }>).map(r => r.id);
  return idsToSlugs(db, ids);
};

/** Strategy D: three-stage: exact → prefix → fuzzy (with raised threshold 0.4) */
const strategyD: SearchFn = async (db, term) => {
  const likePattern = `%${term}%`;
  const prefixPattern = `${term}%`;

  // Stage 1: exact match on person_names.name
  const exactResult = await db.execute(sql`
    SELECT DISTINCT COALESCE(p.merged_into_id, p.id) AS id
    FROM persons p
    JOIN person_names pn ON pn.person_id = p.id
    WHERE (p.deleted_at IS NULL OR p.merged_into_id IS NOT NULL)
      AND pn.name = ${term}
  `);
  const exactIds = new Set((exactResult as unknown as Array<{ id: string }>).map(r => r.id));

  // Stage 2: prefix match on person_names.name
  const prefixResult = await db.execute(sql`
    SELECT DISTINCT COALESCE(p.merged_into_id, p.id) AS id
    FROM persons p
    JOIN person_names pn ON pn.person_id = p.id
    WHERE (p.deleted_at IS NULL OR p.merged_into_id IS NOT NULL)
      AND pn.name LIKE ${prefixPattern}
      AND pn.name != ${term}
  `);
  const prefixIds = new Set((prefixResult as unknown as Array<{ id: string }>).map(r => r.id));

  // Stage 3: fuzzy (trigram + ILIKE, threshold 0.4)
  const fuzzyResult = await db.execute(sql`
    SELECT COALESCE(p.merged_into_id, p.id) AS id,
      MAX(GREATEST(
        COALESCE(similarity(pn.name, ${term}), 0),
        CASE WHEN p.name->>'zh-Hans' ILIKE ${likePattern} THEN 0.5 ELSE 0 END
      )) AS score
    FROM persons p
    LEFT JOIN person_names pn ON pn.person_id = p.id
    WHERE (p.deleted_at IS NULL OR p.merged_into_id IS NOT NULL)
      AND (
        similarity(pn.name, ${term}) > 0.4
        OR p.name->>'zh-Hans' ILIKE ${likePattern}
      )
    GROUP BY COALESCE(p.merged_into_id, p.id)
    ORDER BY score DESC
    LIMIT 100
  `);
  const fuzzyIds = (fuzzyResult as unknown as Array<{ id: string; score: number }>)
    .filter(r => !exactIds.has(r.id) && !prefixIds.has(r.id))
    .map(r => r.id);

  // Combine: exact first, then prefix, then fuzzy
  const allIds = [...exactIds, ...prefixIds, ...fuzzyIds];
  // Deduplicate preserving order
  const seen = new Set<string>();
  const uniqueIds = allIds.filter(id => {
    if (seen.has(id)) return false;
    seen.add(id);
    return true;
  });

  return idsToSlugs(db, uniqueIds);
};

// ----------------------------------------------------------------
// Helpers
// ----------------------------------------------------------------

async function idsToSlugs(db: DrizzleClient, ids: string[]): Promise<string[]> {
  if (ids.length === 0) return [];
  const rows = await db.select({ id: persons.id, slug: persons.slug })
    .from(persons)
    .where(inArray(persons.id, ids));
  const slugMap = new Map(rows.map(r => [r.id, r.slug]));
  return ids.map(id => slugMap.get(id)).filter((s): s is string => s != null);
}

// ----------------------------------------------------------------
// Runner
// ----------------------------------------------------------------

async function runExperiment(
  label: string,
  searchFn: SearchFn,
  db: DrizzleClient,
  cases: GoldenCase[],
): Promise<ExperimentReport> {
  const results: QueryResult[] = [];

  for (const c of cases) {
    const returnedSlugs = await searchFn(db, c.query);
    const metrics = computeMetrics(c.expected_slugs, returnedSlugs, c.disallowed_slugs);

    results.push({
      id: c.id,
      query: c.query,
      expected_slugs: c.expected_slugs,
      disallowed_slugs: c.disallowed_slugs,
      returned_slugs: returnedSlugs,
      precision: Math.round(metrics.precision * 10000) / 10000,
      recall: Math.round(metrics.recall * 10000) / 10000,
      f1: Math.round(metrics.f1 * 10000) / 10000,
      disallowed_hits: metrics.disallowed_hits,
    });
  }

  const mp = results.reduce((s, r) => s + r.precision, 0) / results.length;
  const mr = results.reduce((s, r) => s + r.recall, 0) / results.length;
  const mf = results.reduce((s, r) => s + r.f1, 0) / results.length;

  return {
    label,
    date: dateStr,
    macro_precision: Math.round(mp * 10000) / 10000,
    macro_recall: Math.round(mr * 10000) / 10000,
    macro_f1: Math.round(mf * 10000) / 10000,
    disallowed_violation_count: results.filter(r => r.disallowed_hits.length > 0).length,
    perfect_count: results.filter(r => r.f1 === 1 && r.disallowed_hits.length === 0).length,
    total_queries: results.length,
    queries: results,
  };
}

function generateMd(report: ExperimentReport): string {
  const lines: string[] = [];
  lines.push(`# T-P1-003 Experiment: ${report.label}`);
  lines.push("");
  lines.push(`| Metric | Value |`);
  lines.push(`|--------|-------|`);
  lines.push(`| Macro P | ${(report.macro_precision * 100).toFixed(1)}% |`);
  lines.push(`| Macro R | ${(report.macro_recall * 100).toFixed(1)}% |`);
  lines.push(`| Macro F1 | ${(report.macro_f1 * 100).toFixed(1)}% |`);
  lines.push(`| Perfect | ${report.perfect_count}/${report.total_queries} |`);
  lines.push(`| Disallowed | ${report.disallowed_violation_count} |`);
  lines.push("");

  const failures = report.queries.filter(r => r.f1 < 1 || r.disallowed_hits.length > 0);
  if (failures.length > 0) {
    lines.push("## Non-Perfect");
    lines.push("");
    for (const f of failures) {
      lines.push(`- **${f.id} "${f.query}"**: P=${f.precision} R=${f.recall} F1=${f.f1}` +
        (f.disallowed_hits.length > 0 ? ` DISALLOWED=[${f.disallowed_hits}]` : "") +
        ` returned=[${f.returned_slugs.slice(0, 5).join(",")}]`);
    }
    lines.push("");
  }
  return lines.join("\n") + "\n";
}

// ----------------------------------------------------------------
// Main
// ----------------------------------------------------------------

async function main() {
  const golden = JSON.parse(readFileSync(GOLDEN_PATH, "utf-8")) as { cases: GoldenCase[] };
  console.log(`Loaded ${golden.cases.length} golden cases`);

  const pgClient = postgres(DATABASE_URL, { max: 1 });
  const db: DrizzleClient = drizzle(pgClient);

  const strategies: [string, SearchFn][] = [
    ["experiment-A", strategyA],
    ["experiment-B", strategyB],
    ["experiment-C", strategyC],
    ["experiment-D", strategyD],
  ];

  const allReports: ExperimentReport[] = [];

  for (const [label, fn] of strategies) {
    console.log(`\n=== Running ${label} ===`);
    const report = await runExperiment(label, fn, db, golden.cases);
    allReports.push(report);

    // Save JSON + MD
    mkdirSync(BENCHMARKS_DIR, { recursive: true });
    writeFileSync(
      resolve(BENCHMARKS_DIR, `T-P1-003-${label}.json`),
      JSON.stringify(report, null, 2) + "\n",
    );
    mkdirSync(DOCS_DIR, { recursive: true });
    writeFileSync(
      resolve(DOCS_DIR, `T-P1-003-${label}-${dateStr}.md`),
      generateMd(report),
    );

    console.log(`  P=${(report.macro_precision * 100).toFixed(1)}% R=${(report.macro_recall * 100).toFixed(1)}% F1=${(report.macro_f1 * 100).toFixed(1)}%`);
    console.log(`  Perfect: ${report.perfect_count}/${report.total_queries}, Disallowed: ${report.disallowed_violation_count}`);

    const failures = report.queries.filter(r => r.f1 < 1 || r.disallowed_hits.length > 0);
    for (const f of failures) {
      console.log(`    ${f.id} "${f.query}" P=${f.precision} R=${f.recall} F1=${f.f1}` +
        (f.disallowed_hits.length > 0 ? ` DISALLOWED=[${f.disallowed_hits}]` : ""));
    }
  }

  // Comparison table
  console.log("\n=== COMPARISON TABLE ===");
  console.log("Strategy        | Macro P | Macro R | Macro F1 | Perfect | Disallowed");
  console.log("----------------|---------|---------|----------|---------|----------");
  console.log(`baseline        | 93.9%   | 100.0%  | 95.6%    | 27/30   | 3`);
  for (const r of allReports) {
    console.log(
      `${r.label.padEnd(16)}| ${(r.macro_precision * 100).toFixed(1).padStart(5)}%  | ${(r.macro_recall * 100).toFixed(1).padStart(5)}%  | ${(r.macro_f1 * 100).toFixed(1).padStart(6)}%  | ${String(r.perfect_count).padStart(2)}/${r.total_queries}   | ${r.disallowed_violation_count}`,
    );
  }

  await pgClient.end();
  process.exit(0);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
