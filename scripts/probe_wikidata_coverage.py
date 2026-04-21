#!/usr/bin/env python3
"""T-P0-025 Gate 0a — Wikidata coverage probe for HuaDian persons.

One-shot probe script. NOT production code — lives in scripts/, not
services/pipeline/src/.

Usage:
    uv run python scripts/probe_wikidata_coverage.py              # full run
    uv run python scripts/probe_wikidata_coverage.py --dry-run    # first 10 only
    uv run python scripts/probe_wikidata_coverage.py --batch-size 5  # custom batch

Requires:
    - DATABASE_URL env var (or defaults to local dev DSN)
    - httpx, asyncpg (already in project deps)

Output:
    - docs/research/T-P0-025-gate-0a-wikidata-probe-details.json
    - docs/research/T-P0-025-gate-0a-wikidata-probe-report.md
"""

from __future__ import annotations

import argparse
import asyncio
import json
import logging
import os
import time
from dataclasses import asdict, dataclass, field
from pathlib import Path

import asyncpg
import httpx

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

WIKIDATA_ENDPOINT = "https://query.wikidata.org/sparql"
USER_AGENT = (
    "HuaDian-Probe/0.1 (https://github.com/lizhuojunx86/huadian; T-P0-025-gate-0a) httpx/0.28"
)
DEFAULT_DSN = "postgresql://huadian:huadian_dev@localhost:5433/huadian"
RATE_LIMIT_SECS = 1.1  # slightly over 1 req/sec for safety
MAX_RETRIES = 3
BATCH_SIZE = 15  # names per SPARQL VALUES batch

PROJECT_ROOT = Path(__file__).resolve().parent.parent
REPORT_DIR = PROJECT_ROOT / "docs" / "research"
DETAILS_PATH = REPORT_DIR / "T-P0-025-gate-0a-wikidata-probe-details.json"
REPORT_PATH = REPORT_DIR / "T-P0-025-gate-0a-wikidata-probe-report.md"


# ---------------------------------------------------------------------------
# Data types
# ---------------------------------------------------------------------------


@dataclass
class PersonRecord:
    person_id: str
    slug: str
    canonical_name: str
    dynasty: str | None
    reality_status: str
    aliases: list[str] = field(default_factory=list)


@dataclass
class WikidataHit:
    qid: str
    label_zh: str
    description_zh: str = ""


@dataclass
class MatchResult:
    person_slug: str
    canonical_name: str
    dynasty: str | None
    reality_status: str
    round1_hits: list[dict] = field(default_factory=list)
    round2_alias_hits: list[dict] = field(default_factory=list)
    round2_alias_used: str = ""
    match_tier: str = "no_match"  # round1_single / round1_multi / round2 / no_match
    error: str = ""


# ---------------------------------------------------------------------------
# DB
# ---------------------------------------------------------------------------


async def load_persons(dsn: str) -> list[PersonRecord]:
    """Load active persons + their aliases from DB."""
    conn = await asyncpg.connect(dsn)
    try:
        rows = await conn.fetch("""
            SELECT p.id::text as person_id, p.slug,
                   COALESCE(pn.name, p.name->>'zh-Hans') as canonical_name,
                   p.dynasty, p.reality_status
            FROM persons p
            LEFT JOIN person_names pn ON pn.person_id = p.id AND pn.is_primary = true
            WHERE p.deleted_at IS NULL AND p.merged_into_id IS NULL
            ORDER BY p.slug
        """)
        persons = {
            r["person_id"]: PersonRecord(
                person_id=r["person_id"],
                slug=r["slug"],
                canonical_name=r["canonical_name"],
                dynasty=r["dynasty"],
                reality_status=r["reality_status"],
            )
            for r in rows
        }

        alias_rows = await conn.fetch("""
            SELECT pn.person_id::text, pn.name
            FROM person_names pn
            JOIN persons p ON p.id = pn.person_id
            WHERE p.deleted_at IS NULL AND p.merged_into_id IS NULL
              AND pn.is_primary = false
              AND pn.name_type IN ('primary', 'alias', 'nickname', 'posthumous', 'temple')
            ORDER BY pn.person_id, pn.name
        """)
        for ar in alias_rows:
            pid = ar["person_id"]
            if pid in persons:
                persons[pid].aliases.append(ar["name"])

        return list(persons.values())
    finally:
        await conn.close()


# ---------------------------------------------------------------------------
# SPARQL
# ---------------------------------------------------------------------------


def _sparql_round1_batch(names: list[str]) -> str:
    """Build Round 1 SPARQL: exact zh label match, instance of human."""
    values = " ".join(f'"{n}"@zh' for n in names)
    return f"""
SELECT ?item ?itemLabel ?name ?description WHERE {{
  VALUES ?name {{ {values} }}
  ?item rdfs:label ?name ;
        wdt:P31 wd:Q5 .
  OPTIONAL {{ ?item schema:description ?description .
              FILTER(LANG(?description) = "zh") }}
  SERVICE wikibase:label {{ bd:serviceParam wikibase:language "zh,en" }}
}}
"""


def _sparql_round2_single(alias: str) -> str:
    """Build Round 2 SPARQL: altLabel match for a single alias."""
    return f"""
SELECT ?item ?itemLabel ?description WHERE {{
  ?item skos:altLabel "{alias}"@zh ;
        wdt:P31 wd:Q5 .
  OPTIONAL {{ ?item schema:description ?description .
              FILTER(LANG(?description) = "zh") }}
  SERVICE wikibase:label {{ bd:serviceParam wikibase:language "zh,en" }}
}}
LIMIT 5
"""


async def query_sparql(client: httpx.AsyncClient, sparql: str, *, retry: int = 0) -> list[dict]:
    """Execute SPARQL query with retry + rate limit."""
    try:
        resp = await client.get(
            WIKIDATA_ENDPOINT,
            params={"query": sparql, "format": "json"},
            timeout=30.0,
        )
        if resp.status_code == 429:
            wait = 2 ** (retry + 1)
            logger.warning("429 Too Many Requests, backing off %ds", wait)
            await asyncio.sleep(wait)
            if retry < MAX_RETRIES:
                return await query_sparql(client, sparql, retry=retry + 1)
            return []
        resp.raise_for_status()
        data = resp.json()
        return data.get("results", {}).get("bindings", [])
    except (httpx.HTTPError, json.JSONDecodeError, KeyError) as e:
        if retry < MAX_RETRIES:
            wait = 2**retry
            logger.warning("SPARQL error (%s), retry %d in %ds", e, retry + 1, wait)
            await asyncio.sleep(wait)
            return await query_sparql(client, sparql, retry=retry + 1)
        logger.error("SPARQL failed after %d retries: %s", MAX_RETRIES, e)
        return []


def _parse_qid(uri: str) -> str:
    """Extract Q-number from Wikidata URI."""
    return uri.rsplit("/", 1)[-1] if "/" in uri else uri


def _bindings_to_hits(bindings: list[dict]) -> dict[str, list[WikidataHit]]:
    """Group SPARQL bindings by label text → list of hits."""
    by_name: dict[str, list[WikidataHit]] = {}
    for b in bindings:
        name_val = b.get("name", {}).get("value", "")
        if not name_val:
            name_val = b.get("itemLabel", {}).get("value", "")
        qid = _parse_qid(b.get("item", {}).get("value", ""))
        label = b.get("itemLabel", {}).get("value", "")
        desc = b.get("description", {}).get("value", "")
        if name_val not in by_name:
            by_name[name_val] = []
        # Deduplicate by QID within same name
        if not any(h.qid == qid for h in by_name[name_val]):
            by_name[name_val].append(WikidataHit(qid=qid, label_zh=label, description_zh=desc))
    return by_name


# ---------------------------------------------------------------------------
# Probe engine
# ---------------------------------------------------------------------------


async def run_probe(
    persons: list[PersonRecord],
    *,
    dry_run: bool = False,
    batch_size: int = BATCH_SIZE,
) -> list[MatchResult]:
    """Run Round 1 + Round 2 matching."""
    if dry_run:
        persons = persons[:10]
        logger.info("DRY RUN: limiting to %d persons", len(persons))

    results: dict[str, MatchResult] = {}
    for p in persons:
        results[p.slug] = MatchResult(
            person_slug=p.slug,
            canonical_name=p.canonical_name,
            dynasty=p.dynasty,
            reality_status=p.reality_status,
        )

    headers = {"User-Agent": USER_AGENT, "Accept": "application/sparql-results+json"}
    async with httpx.AsyncClient(headers=headers) as client:
        # ── Round 1: batch exact label match ──
        logger.info("=== Round 1: exact zh label match (%d persons) ===", len(persons))
        batches = [persons[i : i + batch_size] for i in range(0, len(persons), batch_size)]
        round1_http = 0

        for bi, batch in enumerate(batches):
            names = [p.canonical_name for p in batch]
            sparql = _sparql_round1_batch(names)
            bindings = await query_sparql(client, sparql)
            round1_http += 1

            if not bindings and len(batch) > 0:
                # Might be a timeout on large batch; fall back to individual
                logger.warning(
                    "Batch %d returned 0 bindings, falling back to individual queries", bi
                )
                for p in batch:
                    individual_sparql = _sparql_round1_batch([p.canonical_name])
                    individual_bindings = await query_sparql(client, individual_sparql)
                    round1_http += 1
                    hits_map = _bindings_to_hits(individual_bindings)
                    hits = hits_map.get(p.canonical_name, [])
                    if hits:
                        r = results[p.slug]
                        r.round1_hits = [asdict(h) for h in hits]
                        r.match_tier = "round1_single" if len(hits) == 1 else "round1_multi"
                    await asyncio.sleep(RATE_LIMIT_SECS)
            else:
                hits_map = _bindings_to_hits(bindings)
                for p in batch:
                    hits = hits_map.get(p.canonical_name, [])
                    if hits:
                        r = results[p.slug]
                        r.round1_hits = [asdict(h) for h in hits]
                        r.match_tier = "round1_single" if len(hits) == 1 else "round1_multi"

            logger.info(
                "  batch %d/%d done (%d names, %d bindings)",
                bi + 1,
                len(batches),
                len(batch),
                len(bindings),
            )
            await asyncio.sleep(RATE_LIMIT_SECS)

        round1_hits = sum(1 for r in results.values() if r.match_tier.startswith("round1"))
        round1_misses = [p for p in persons if results[p.slug].match_tier == "no_match"]
        logger.info(
            "Round 1 complete: %d/%d hit (%.1f%%)",
            round1_hits,
            len(persons),
            100 * round1_hits / len(persons) if persons else 0,
        )

        # ── Round 2: alias match for misses ──
        logger.info("=== Round 2: alias match (%d persons) ===", len(round1_misses))
        round2_http = 0

        for pi, p in enumerate(round1_misses):
            # Deduplicate and skip canonical (already tried in R1)
            alias_candidates = list(dict.fromkeys(p.aliases))
            found = False

            for alias in alias_candidates:
                sparql = _sparql_round2_single(alias)
                bindings = await query_sparql(client, sparql)
                round2_http += 1

                hits = []
                for b in bindings:
                    qid = _parse_qid(b.get("item", {}).get("value", ""))
                    label = b.get("itemLabel", {}).get("value", "")
                    desc = b.get("description", {}).get("value", "")
                    if not any(h["qid"] == qid for h in hits):
                        hits.append({"qid": qid, "label_zh": label, "description_zh": desc})

                if hits:
                    r = results[p.slug]
                    r.round2_alias_hits = hits
                    r.round2_alias_used = alias
                    r.match_tier = "round2"
                    found = True
                    break  # first alias hit wins

                await asyncio.sleep(RATE_LIMIT_SECS)

            if (pi + 1) % 10 == 0 or pi == len(round1_misses) - 1:
                logger.info("  round2 progress: %d/%d", pi + 1, len(round1_misses))

            if not found:
                await asyncio.sleep(RATE_LIMIT_SECS * 0.5)  # lighter delay between persons

    total_hits = sum(1 for r in results.values() if r.match_tier != "no_match")
    logger.info(
        "=== FINAL: %d/%d hit (%.1f%%) | R1=%d R2=%d HTTP=%d+%d ===",
        total_hits,
        len(persons),
        100 * total_hits / len(persons) if persons else 0,
        round1_hits,
        total_hits - round1_hits,
        round1_http,
        round2_http,
    )

    return list(results.values())


# ---------------------------------------------------------------------------
# Report generation
# ---------------------------------------------------------------------------


def generate_report(results: list[MatchResult], elapsed: float, meta: dict) -> str:
    """Generate Markdown probe report."""
    total = len(results)
    r1_single = sum(1 for r in results if r.match_tier == "round1_single")
    r1_multi = sum(1 for r in results if r.match_tier == "round1_multi")
    r1_total = r1_single + r1_multi
    r2_total = sum(1 for r in results if r.match_tier == "round2")
    no_match = sum(1 for r in results if r.match_tier == "no_match")
    total_hit = r1_total + r2_total

    r1_pct = 100 * r1_total / total if total else 0
    total_pct = 100 * total_hit / total if total else 0

    # Decision bucket
    if total_pct >= 40:
        bucket = "≥ 40% → Sprint B 按 ADR-021 §2.1 全量推进"
    elif total_pct >= 20:
        bucket = "20%-40% → Sprint B 推进但 scope 收缩"
    else:
        bucket = "< 20% → Sprint B 暂停，优先启动 T-P0-025b"

    lines = [
        "# T-P0-025 Gate 0a — Wikidata Coverage Probe Report",
        "",
        f"> **Date**: {time.strftime('%Y-%m-%d %H:%M:%S')}",
        f"> **Persons**: {total}",
        f"> **Elapsed**: {elapsed:.0f}s",
        "",
        "---",
        "",
        "## 1. 执行摘要",
        "",
        "| 指标 | 值 |",
        "|------|-----|",
        f"| 全局命中率 | **{total_pct:.1f}%** ({total_hit}/{total}) |",
        f"| Round 1 精确命中 | {r1_pct:.1f}% ({r1_total}/{total}) |",
        f"| 　└ 单候选 | {r1_single} |",
        f"| 　└ 多候选 | {r1_multi} |",
        f"| Round 2 alias 贡献 | {r2_total} |",
        f"| 未命中 | {no_match} |",
        f"| **决策矩阵落桶** | **{bucket}** |",
        "",
        "---",
        "",
        "## 2. 分层命中率",
        "",
        "### 2.1 按 dynasty",
        "",
        "| Dynasty | Total | Hit | Hit% |",
        "|---------|-------|-----|------|",
    ]

    # Dynasty breakdown
    by_dynasty: dict[str, list[MatchResult]] = {}
    for r in results:
        d = r.dynasty or "(unknown)"
        by_dynasty.setdefault(d, []).append(r)
    for dynasty in sorted(by_dynasty.keys()):
        group = by_dynasty[dynasty]
        hits = sum(1 for r in group if r.match_tier != "no_match")
        pct = 100 * hits / len(group) if group else 0
        lines.append(f"| {dynasty} | {len(group)} | {hits} | {pct:.1f}% |")

    lines += [
        "",
        "### 2.2 按 reality_status",
        "",
        "| Status | Total | Hit | Hit% |",
        "|--------|-------|-----|------|",
    ]

    by_status: dict[str, list[MatchResult]] = {}
    for r in results:
        by_status.setdefault(r.reality_status, []).append(r)
    for status in sorted(by_status.keys()):
        group = by_status[status]
        hits = sum(1 for r in group if r.match_tier != "no_match")
        pct = 100 * hits / len(group) if group else 0
        lines.append(f"| {status} | {len(group)} | {hits} | {pct:.1f}% |")

    # Unmatched samples
    unmatched = [r for r in results if r.match_tier == "no_match"]
    lines += [
        "",
        "---",
        "",
        f"## 3. 未命中样本（前 30 / {len(unmatched)} 条）",
        "",
        "| # | slug | canonical_name | dynasty | reality_status |",
        "|---|------|---------------|---------|----------------|",
    ]
    for i, r in enumerate(unmatched[:30], 1):
        lines.append(
            f"| {i} | {r.person_slug} | {r.canonical_name} | {r.dynasty or ''} | {r.reality_status} |"
        )

    # Multi-candidate samples
    multi = [r for r in results if r.match_tier == "round1_multi"]
    lines += [
        "",
        "---",
        "",
        f"## 4. 多候选样本（前 10 / {len(multi)} 条）",
        "",
    ]
    for i, r in enumerate(multi[:10], 1):
        lines.append(f"### {i}. {r.canonical_name} ({r.person_slug})")
        lines.append("")
        for h in r.round1_hits[:5]:
            lines.append(f"- **{h['qid']}** {h['label_zh']}: {h.get('description_zh', '')}")
        lines.append("")

    # Alias contribution
    alias_hits = [r for r in results if r.match_tier == "round2"]
    lines += [
        "---",
        "",
        f"## 5. Alias 贡献（{len(alias_hits)} persons）",
        "",
    ]
    if alias_hits:
        lines.append("| slug | canonical_name | alias_used | QID |")
        lines.append("|------|---------------|------------|-----|")
        for r in alias_hits:
            qids = ", ".join(h["qid"] for h in r.round2_alias_hits[:3])
            lines.append(
                f"| {r.person_slug} | {r.canonical_name} | {r.round2_alias_used} | {qids} |"
            )
    else:
        lines.append("(none)")

    # Metadata
    lines += [
        "",
        "---",
        "",
        "## 6. 执行元数据",
        "",
        "| Key | Value |",
        "|-----|-------|",
        f"| Endpoint | `{WIKIDATA_ENDPOINT}` |",
        f"| Timestamp | {time.strftime('%Y-%m-%dT%H:%M:%S%z')} |",
        f"| Elapsed | {elapsed:.0f}s |",
        f"| HTTP requests | {meta.get('total_http', 'N/A')} |",
        f"| HTTP errors | {meta.get('http_errors', 0)} |",
        f"| Batch size | {meta.get('batch_size', BATCH_SIZE)} |",
        f"| Rate limit | {RATE_LIMIT_SECS}s |",
        "",
    ]

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


async def main() -> None:
    parser = argparse.ArgumentParser(description="T-P0-025 Wikidata coverage probe")
    parser.add_argument("--dry-run", action="store_true", help="Run first 10 only")
    parser.add_argument("--batch-size", type=int, default=BATCH_SIZE, help="Names per SPARQL batch")
    args = parser.parse_args()

    dsn = os.environ.get("DATABASE_URL", DEFAULT_DSN)
    logger.info("Loading persons from DB...")
    persons = await load_persons(dsn)
    logger.info("Loaded %d active persons", len(persons))

    start = time.monotonic()
    results = await run_probe(persons, dry_run=args.dry_run, batch_size=args.batch_size)
    elapsed = time.monotonic() - start

    # Write details JSON
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    details = [asdict(r) for r in results]
    DETAILS_PATH.write_text(json.dumps(details, ensure_ascii=False, indent=2) + "\n")
    logger.info("Details written to %s (%d records)", DETAILS_PATH, len(details))

    # Write report
    meta = {"total_http": "see logs", "http_errors": 0, "batch_size": args.batch_size}
    report = generate_report(results, elapsed, meta)
    REPORT_PATH.write_text(report)
    logger.info("Report written to %s", REPORT_PATH)

    # Print summary
    total = len(results)
    hits = sum(1 for r in results if r.match_tier != "no_match")
    print(f"\n{'=' * 60}")
    print(f"PROBE COMPLETE: {hits}/{total} = {100 * hits / total:.1f}% global hit rate")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    asyncio.run(main())
