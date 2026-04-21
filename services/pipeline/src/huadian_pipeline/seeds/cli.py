"""CLI for seed dictionary loading.

Usage:
    uv run python -m huadian_pipeline.seeds.cli load --source wikidata --dry-run
    uv run python -m huadian_pipeline.seeds.cli load --source wikidata --mode execute

ADR: ADR-021 / T-P0-025 Stage 1-2
"""

from __future__ import annotations

import argparse
import asyncio
import json
import logging
import os
import time
import uuid
from pathlib import Path

import asyncpg

from .matcher import MatchResult, PersonInput, run_matching
from .wikidata_adapter import WikidataAdapter

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

DEFAULT_DSN = "postgresql://huadian:huadian_dev@localhost:5433/huadian"
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent.parent.parent


async def load_persons_from_db(dsn: str) -> list[PersonInput]:
    """Load active persons + all their names from DB."""
    conn = await asyncpg.connect(dsn)
    try:
        # Load persons with canonical name (is_primary=true, fallback to name JSONB)
        rows = await conn.fetch("""
            SELECT p.id::text as person_id, p.slug,
                   COALESCE(pn_primary.name, p.name->>'zh-Hans') as canonical_name,
                   p.dynasty, p.reality_status
            FROM persons p
            LEFT JOIN person_names pn_primary
              ON pn_primary.person_id = p.id AND pn_primary.is_primary = true
            WHERE p.deleted_at IS NULL AND p.merged_into_id IS NULL
            ORDER BY p.slug
        """)

        persons: dict[str, PersonInput] = {}
        for r in rows:
            persons[r["person_id"]] = PersonInput(
                person_id=r["person_id"],
                slug=r["slug"],
                canonical_name=r["canonical_name"],
                dynasty=r["dynasty"],
                reality_status=r["reality_status"],
            )

        # Load all names for R2/R3
        name_rows = await conn.fetch("""
            SELECT pn.person_id::text, pn.name, pn.name_type, pn.is_primary
            FROM person_names pn
            JOIN persons p ON p.id = pn.person_id
            WHERE p.deleted_at IS NULL AND p.merged_into_id IS NULL
              AND pn.is_primary = false
            ORDER BY pn.person_id, pn.name_type, pn.name
        """)

        for nr in name_rows:
            pid = nr["person_id"]
            if pid not in persons:
                continue
            p = persons[pid]
            p.all_names.append(nr["name"])
            if nr["name_type"] in ("primary", "alias", "nickname", "posthumous", "temple"):
                p.alias_names.append(nr["name"])

        return list(persons.values())
    finally:
        await conn.close()


async def write_seed_data(
    dsn: str,
    results: list[MatchResult],
    source_version: str,
) -> dict:
    """Write matching results to dictionary_sources/entries/seed_mappings.

    Only writes single-match results (r1/r2/r3). Multi-hit and no-match
    are skipped.

    Returns summary dict of row counts.
    """
    conn = await asyncpg.connect(dsn)
    try:
        async with conn.transaction():
            # 1. Ensure dictionary_source exists
            source_id = await conn.fetchval(
                """
                INSERT INTO dictionary_sources
                  (source_name, source_version, license, commercial_safe, access_url)
                VALUES ('wikidata', $1, 'CC0', true, 'https://query.wikidata.org/sparql')
                ON CONFLICT (source_name, source_version) DO UPDATE SET source_name = 'wikidata'
                RETURNING id
            """,
                source_version,
            )

            entries_written = 0
            mappings_written = 0
            skipped = 0

            for r in results:
                if r.match_round not in ("r1", "r2", "r3"):
                    skipped += 1
                    continue
                if not r.hits:
                    skipped += 1
                    continue

                hit = r.hits[0]  # single match
                qid = hit["qid"]

                # 2. Insert dictionary_entry (ON CONFLICT skip)
                entry_id = await conn.fetchval(
                    """
                    INSERT INTO dictionary_entries
                      (source_id, external_id, entry_type, primary_name, attributes)
                    VALUES ($1, $2, 'person', $3, $4::jsonb)
                    ON CONFLICT (source_id, external_id) DO UPDATE
                      SET source_id = dictionary_entries.source_id
                    RETURNING id
                """,
                    source_id,
                    qid,
                    hit.get("label_zh", ""),
                    json.dumps(
                        {"description_zh": hit.get("description_zh", "")}, ensure_ascii=False
                    ),
                )
                entries_written += 1

                # 3. Insert seed_mapping
                existing = await conn.fetchval(
                    """
                    SELECT id FROM seed_mappings
                    WHERE dictionary_entry_id = $1
                      AND target_entity_type = 'person'
                      AND target_entity_id = $2::uuid
                      AND mapping_status = 'active'
                """,
                    entry_id,
                    uuid.UUID(r.person_id),
                )

                if not existing:
                    await conn.execute(
                        """
                        INSERT INTO seed_mappings
                          (dictionary_entry_id, target_entity_type, target_entity_id,
                           confidence, mapping_method, mapping_status)
                        VALUES ($1, 'person', $2::uuid, $3, $4, 'active')
                    """,
                        entry_id,
                        uuid.UUID(r.person_id),
                        r.confidence,
                        r.mapping_method,
                    )
                    mappings_written += 1

            return {
                "source_id": str(source_id),
                "entries_written": entries_written,
                "mappings_written": mappings_written,
                "skipped": skipped,
            }
    finally:
        await conn.close()


async def cmd_load(args: argparse.Namespace) -> None:
    """Execute the load command."""
    dsn = os.environ.get("DATABASE_URL", DEFAULT_DSN)

    logger.info("Loading persons from DB...")
    persons = await load_persons_from_db(dsn)
    logger.info("Loaded %d active persons", len(persons))

    if args.limit:
        persons = persons[: args.limit]
        logger.info("Limited to %d persons (--limit)", args.limit)

    start = time.monotonic()
    async with WikidataAdapter() as adapter:
        results, summary = await run_matching(
            persons,
            adapter,
            skip_r3=args.skip_r3,
        )
    elapsed = time.monotonic() - start

    # Print summary
    total_matched = summary.r1_single + summary.r2_alias + summary.r3_scan
    print(f"\n{'=' * 60}")
    print(f"MATCHING COMPLETE ({elapsed:.0f}s)")
    print(f"  Total: {summary.total}")
    print(f"  R1 single: {summary.r1_single}")
    print(f"  R1 multi (manual review): {summary.r1_multi}")
    print(f"  R2 alias: {summary.r2_alias}")
    print(f"  R3 scan: {summary.r3_scan}")
    print(f"  No match: {summary.no_match}")
    print(f"  Hit rate: {100 * total_matched / summary.total:.1f}%")
    print(f"  HTTP requests: {summary.http_requests}")
    print(f"  Errors: {summary.errors}")
    print(f"{'=' * 60}")

    if args.mode == "dry-run":
        # Save results to JSON for review
        output_path = PROJECT_ROOT / "docs" / "research" / "T-P0-025-stage1-dry-run.json"
        output_path.parent.mkdir(parents=True, exist_ok=True)
        details = [r.to_dict() for r in results]
        output_path.write_text(json.dumps(details, ensure_ascii=False, indent=2) + "\n")
        logger.info("Dry-run results saved to %s", output_path)
        print(f"\nDRY RUN — no DB writes. Results saved to {output_path}")

    elif args.mode == "execute":
        source_version = time.strftime("%Y%m%d")
        logger.info("Writing seed data to DB (source_version=%s)...", source_version)
        write_summary = await write_seed_data(dsn, results, source_version)
        print("\nDB WRITES:")
        print(f"  Source ID: {write_summary['source_id']}")
        print(f"  Entries written: {write_summary['entries_written']}")
        print(f"  Mappings written: {write_summary['mappings_written']}")
        print(f"  Skipped (multi/none): {write_summary['skipped']}")


def main() -> None:
    """CLI entry point."""
    parser = argparse.ArgumentParser(
        description="HuaDian seed dictionary loader",
        prog="huadian_pipeline.seeds.cli",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    load_parser = subparsers.add_parser("load", help="Load seeds from external source")
    load_parser.add_argument(
        "--source",
        required=True,
        choices=["wikidata"],
        help="External source to load from",
    )
    load_parser.add_argument(
        "--mode",
        default="dry-run",
        choices=["dry-run", "execute"],
        help="dry-run (no DB writes) or execute (write to DB)",
    )
    load_parser.add_argument(
        "--limit",
        type=int,
        default=0,
        help="Limit to first N persons (0 = all)",
    )
    load_parser.add_argument(
        "--skip-r3",
        action="store_true",
        help="Skip Round 3 full person_names scan",
    )

    args = parser.parse_args()
    if args.command == "load":
        asyncio.run(cmd_load(args))


if __name__ == "__main__":
    main()
