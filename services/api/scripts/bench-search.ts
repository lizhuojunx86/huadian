/**
 * bench-search.ts — Search benchmark harness for T-P1-003
 *
 * Runs golden test cases against the searchPersons implementation,
 * computes per-query precision/recall/F1, and outputs:
 *   - benchmarks/<label>.json  (machine-readable)
 *   - docs/benchmarks/T-P1-003-<label>-<date>.md (human-readable)
 *
 * Usage:
 *   tsx scripts/bench-search.ts [--label baseline]
 *   tsx scripts/bench-search.ts --label experiment-A
 */

import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

import { searchPersons } from "../src/services/person.service.js";
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

const label = process.argv.includes("--label")
  ? process.argv[process.argv.indexOf("--label") + 1]!
  : "baseline";

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

interface GoldenFile {
  cases: GoldenCase[];
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
  rationale: string;
}

interface BenchmarkReport {
  label: string;
  date: string;
  timestamp: string;
  total_queries: number;
  macro_precision: number;
  macro_recall: number;
  macro_f1: number;
  disallowed_violation_count: number;
  perfect_count: number;
  queries: QueryResult[];
}

// ----------------------------------------------------------------
// Metric helpers
// ----------------------------------------------------------------

function computeMetrics(
  expected: string[],
  returned: string[],
  disallowed: string[],
): { precision: number; recall: number; f1: number; disallowed_hits: string[] } {
  const returnedSet = new Set(returned);
  const expectedSet = new Set(expected);

  // Edge case: both empty → perfect
  if (expectedSet.size === 0 && returnedSet.size === 0) {
    return { precision: 1, recall: 1, f1: 1, disallowed_hits: [] };
  }
  // Expected empty but returned non-empty → precision 0
  if (expectedSet.size === 0 && returnedSet.size > 0) {
    return {
      precision: 0,
      recall: 1, // nothing to miss
      f1: 0,
      disallowed_hits: disallowed.filter((s) => returnedSet.has(s)),
    };
  }

  const tp = [...expectedSet].filter((s) => returnedSet.has(s)).length;
  const precision = returnedSet.size > 0 ? tp / returnedSet.size : 0;
  const recall = expectedSet.size > 0 ? tp / expectedSet.size : 1;
  const f1 =
    precision + recall > 0 ? (2 * precision * recall) / (precision + recall) : 0;

  const disallowed_hits = disallowed.filter((s) => returnedSet.has(s));

  return { precision, recall, f1, disallowed_hits };
}

// ----------------------------------------------------------------
// Main
// ----------------------------------------------------------------

async function main() {
  console.log(`[bench-search] label=${label} date=${dateStr}`);

  // Read golden set
  const golden: GoldenFile = JSON.parse(readFileSync(GOLDEN_PATH, "utf-8"));
  console.log(`[bench-search] ${golden.cases.length} golden cases loaded`);

  // Connect to DB
  const pgClient = postgres(DATABASE_URL, { max: 1 });
  const db: DrizzleClient = drizzle(pgClient);

  const results: QueryResult[] = [];

  for (const c of golden.cases) {
    const searchResult = await searchPersons(db, c.query, 100, 0);
    const returnedSlugs = searchResult.items.map((item) => item.slug);

    const metrics = computeMetrics(
      c.expected_slugs,
      returnedSlugs,
      c.disallowed_slugs,
    );

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
      rationale: c.rationale,
    });
  }

  // Compute macro averages
  const macro_precision =
    results.reduce((s, r) => s + r.precision, 0) / results.length;
  const macro_recall =
    results.reduce((s, r) => s + r.recall, 0) / results.length;
  const macro_f1 =
    results.reduce((s, r) => s + r.f1, 0) / results.length;
  const disallowed_violation_count = results.filter(
    (r) => r.disallowed_hits.length > 0,
  ).length;
  const perfect_count = results.filter(
    (r) => r.f1 === 1 && r.disallowed_hits.length === 0,
  ).length;

  const report: BenchmarkReport = {
    label,
    date: dateStr,
    timestamp: new Date().toISOString(),
    total_queries: results.length,
    macro_precision: Math.round(macro_precision * 10000) / 10000,
    macro_recall: Math.round(macro_recall * 10000) / 10000,
    macro_f1: Math.round(macro_f1 * 10000) / 10000,
    disallowed_violation_count,
    perfect_count,
    queries: results,
  };

  // Write JSON
  mkdirSync(BENCHMARKS_DIR, { recursive: true });
  const jsonPath = resolve(BENCHMARKS_DIR, `T-P1-003-${label}.json`);
  writeFileSync(jsonPath, JSON.stringify(report, null, 2) + "\n");
  console.log(`[bench-search] JSON → ${jsonPath}`);

  // Write markdown
  mkdirSync(DOCS_DIR, { recursive: true });
  const mdPath = resolve(DOCS_DIR, `T-P1-003-${label}-${dateStr}.md`);
  writeFileSync(mdPath, generateMarkdown(report));
  console.log(`[bench-search] MD   → ${mdPath}`);

  // Summary
  console.log(`\n=== ${label.toUpperCase()} SUMMARY ===`);
  console.log(`Macro Precision: ${(macro_precision * 100).toFixed(1)}%`);
  console.log(`Macro Recall:    ${(macro_recall * 100).toFixed(1)}%`);
  console.log(`Macro F1:        ${(macro_f1 * 100).toFixed(1)}%`);
  console.log(`Perfect queries: ${perfect_count}/${results.length}`);
  console.log(`Disallowed violations: ${disallowed_violation_count}`);

  // Print failures
  const failures = results.filter(
    (r) => r.f1 < 1 || r.disallowed_hits.length > 0,
  );
  if (failures.length > 0) {
    console.log(`\n--- Non-perfect queries ---`);
    for (const f of failures) {
      console.log(
        `  ${f.id} "${f.query}" P=${f.precision} R=${f.recall} F1=${f.f1}` +
          (f.disallowed_hits.length > 0
            ? ` DISALLOWED=[${f.disallowed_hits.join(",")}]`
            : ""),
      );
    }
  }

  await pgClient.end();
  process.exit(0);
}

// ----------------------------------------------------------------
// Markdown generator
// ----------------------------------------------------------------

function generateMarkdown(report: BenchmarkReport): string {
  const lines: string[] = [];
  lines.push(`# T-P1-003 Benchmark: ${report.label}`);
  lines.push("");
  lines.push(`- **Date**: ${report.date}`);
  lines.push(`- **Label**: ${report.label}`);
  lines.push(`- **Timestamp**: ${report.timestamp}`);
  lines.push(`- **Total queries**: ${report.total_queries}`);
  lines.push("");
  lines.push("## Summary");
  lines.push("");
  lines.push("| Metric | Value |");
  lines.push("|--------|-------|");
  lines.push(
    `| Macro Precision | ${(report.macro_precision * 100).toFixed(1)}% |`,
  );
  lines.push(
    `| Macro Recall | ${(report.macro_recall * 100).toFixed(1)}% |`,
  );
  lines.push(`| Macro F1 | ${(report.macro_f1 * 100).toFixed(1)}% |`);
  lines.push(
    `| Perfect queries | ${report.perfect_count}/${report.total_queries} |`,
  );
  lines.push(
    `| Disallowed violations | ${report.disallowed_violation_count} |`,
  );
  lines.push("");
  lines.push("## Per-Query Results");
  lines.push("");
  lines.push(
    "| ID | Query | P | R | F1 | Expected | Returned | Disallowed Hits |",
  );
  lines.push(
    "|----|-------|---|---|----|-----------|---------|----|",
  );
  for (const q of report.queries) {
    const exp = q.expected_slugs.length > 0 ? q.expected_slugs.join(", ") : "(empty)";
    const ret =
      q.returned_slugs.length > 0
        ? q.returned_slugs.slice(0, 5).join(", ") +
          (q.returned_slugs.length > 5
            ? ` (+${q.returned_slugs.length - 5})`
            : "")
        : "(empty)";
    const disHits =
      q.disallowed_hits.length > 0 ? q.disallowed_hits.join(", ") : "-";
    const f1Style = q.f1 < 1 ? `**${q.f1}**` : `${q.f1}`;
    lines.push(
      `| ${q.id} | ${q.query} | ${q.precision} | ${q.recall} | ${f1Style} | ${exp} | ${ret} | ${disHits} |`,
    );
  }
  lines.push("");

  // Non-perfect details
  const failures = report.queries.filter(
    (r) => r.f1 < 1 || r.disallowed_hits.length > 0,
  );
  if (failures.length > 0) {
    lines.push("## Non-Perfect Query Details");
    lines.push("");
    for (const f of failures) {
      lines.push(`### ${f.id}: "${f.query}"`);
      lines.push(`- **Rationale**: ${f.rationale}`);
      lines.push(`- **Expected**: [${f.expected_slugs.join(", ")}]`);
      lines.push(`- **Returned**: [${f.returned_slugs.join(", ")}]`);
      if (f.disallowed_hits.length > 0) {
        lines.push(
          `- **Disallowed Hits**: [${f.disallowed_hits.join(", ")}]`,
        );
      }
      lines.push("");
    }
  }

  return lines.join("\n") + "\n";
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
