"""HuaDian Pipeline CLI — ingest, extract, load, pilot.

Usage (via Makefile wrapper for PYTHONPATH):
  make pipeline ARGS="ingest --book shiji --chapter wu-di-ben-ji"
  make pipeline ARGS="pilot --book shiji --chapter wu-di-ben-ji"
"""

from __future__ import annotations

import argparse
import asyncio
import logging
import os
import sys

logger = logging.getLogger("huadian_pipeline")

# Default DB DSN (matches docker/compose.dev.yml)
DEFAULT_DSN = "postgresql://huadian:huadian_dev@localhost:5433/huadian"


def main() -> None:
    parser = argparse.ArgumentParser(description="HuaDian Pipeline CLI")
    parser.add_argument(
        "--log-level",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR"],
        help="Logging level",
    )

    sub = parser.add_subparsers(dest="command", required=True)

    # ingest
    p_ingest = sub.add_parser("ingest", help="Ingest raw text into DB")
    p_ingest.add_argument("--book", default="shiji", help="Book slug")
    p_ingest.add_argument("--chapter", required=True, help="Chapter slug (e.g. wu-di-ben-ji)")

    # extract
    p_extract = sub.add_parser("extract", help="Run LLM NER extraction")
    p_extract.add_argument("--book-id", required=True, help="Book UUID from DB")
    p_extract.add_argument("--chapter", default="", help="Chapter name for logging")
    p_extract.add_argument("--budget", type=float, default=5.0, help="Max cost in USD")

    # pilot (ingest + extract + load)
    p_pilot = sub.add_parser("pilot", help="Run full ingest → extract → load pipeline")
    p_pilot.add_argument("--book", default="shiji", help="Book slug")
    p_pilot.add_argument("--chapter", required=True, help="Chapter slug")
    p_pilot.add_argument("--budget", type=float, default=5.0, help="Max cost in USD")
    p_pilot.add_argument("--seed-output", default="", help="Path for seed SQL dump")

    # seed-dump
    p_seed = sub.add_parser("seed-dump", help="Export persons as SQL seed")
    p_seed.add_argument("--book-id", required=True, help="Book UUID")
    p_seed.add_argument("--output", required=True, help="Output SQL file path")

    args = parser.parse_args()

    logging.basicConfig(
        level=getattr(logging, args.log_level),
        format="%(asctime)s [%(name)s] %(levelname)s %(message)s",
        datefmt="%H:%M:%S",
    )

    dsn = os.environ.get("DATABASE_URL", DEFAULT_DSN)

    if args.command == "ingest":
        asyncio.run(_cmd_ingest(args, dsn))
    elif args.command == "extract":
        asyncio.run(_cmd_extract(args, dsn))
    elif args.command == "pilot":
        asyncio.run(_cmd_pilot(args, dsn))
    elif args.command == "seed-dump":
        asyncio.run(_cmd_seed_dump(args, dsn))


async def _cmd_ingest(args: argparse.Namespace, dsn: str) -> None:
    import asyncpg

    from .ingest import ingest_chapter
    from .sources.ctext import load_chapter

    chapter = load_chapter(args.book, args.chapter)
    print(f"Loaded {chapter.title_zh}: {len(chapter.paragraphs)} paragraphs")

    pool = await asyncpg.create_pool(dsn, min_size=1, max_size=3)
    try:
        result = await ingest_chapter(pool, chapter)
        print("Ingest complete:")
        print(f"  Book ID: {result.book_id}")
        print(f"  Inserted: {result.paragraphs_inserted}")
        print(f"  Skipped: {result.paragraphs_skipped}")
    finally:
        await pool.close()


async def _cmd_extract(args: argparse.Namespace, dsn: str) -> None:
    import asyncpg

    from .extract import extract_persons

    pool = await asyncpg.create_pool(dsn, min_size=1, max_size=3)
    gateway = _create_gateway(dsn)
    try:
        result = await extract_persons(
            pool,
            gateway,
            book_id=args.book_id,
            chapter_name=args.chapter or args.book_id,
            budget_usd=args.budget,
        )
        _print_extraction_summary(result)
    finally:
        await pool.close()


async def _cmd_pilot(args: argparse.Namespace, dsn: str) -> None:
    import asyncpg

    from .extract import extract_persons
    from .ingest import ingest_chapter
    from .load import load_persons, merge_persons
    from .seed_dump import dump_seed_sql
    from .sources.ctext import load_chapter

    # Step 1: Ingest
    print(f"=== INGEST: {args.book}/{args.chapter} ===")
    chapter = load_chapter(args.book, args.chapter)
    print(f"Loaded {chapter.title_zh}: {len(chapter.paragraphs)} paragraphs")

    pool = await asyncpg.create_pool(dsn, min_size=1, max_size=3)
    try:
        ingest_result = await ingest_chapter(pool, chapter)
        print(
            f"Ingested: {ingest_result.paragraphs_inserted} new, {ingest_result.paragraphs_skipped} skipped"
        )

        # Step 2: Extract
        print("\n=== EXTRACT: NER with LLM Gateway ===")
        gateway = _create_gateway(dsn)
        extract_result = await extract_persons(
            pool,
            gateway,
            book_id=ingest_result.book_id,
            chapter_name=chapter.title_zh,
            budget_usd=args.budget,
        )
        _print_extraction_summary(extract_result)

        if extract_result.budget_exceeded:
            print("Budget exceeded, stopping pipeline.")
            sys.exit(1)

        # Step 3: Load
        print("\n=== LOAD: Writing persons to DB ===")
        merged = merge_persons(extract_result.persons)
        print(f"Merged {len(extract_result.persons)} extractions → {len(merged)} unique persons")

        load_result = await load_persons(pool, merged, book_id=ingest_result.book_id)
        print(
            f"Loaded: {load_result.persons_inserted} new, {load_result.persons_updated} updated, {load_result.names_inserted} names"
        )

        if load_result.errors:
            print(f"Load errors: {len(load_result.errors)}")
            for err in load_result.errors[:5]:
                print(f"  - {err}")

        # Step 4: Seed dump (optional)
        seed_path = args.seed_output
        if not seed_path:
            seed_path = f"seeds/pilot-shiji-benji/{args.chapter.replace('-', '_')}.sql"

        print(f"\n=== SEED DUMP: {seed_path} ===")
        count = await dump_seed_sql(
            pool,
            book_id=ingest_result.book_id,
            output_path=seed_path,
            prompt_version=extract_result.prompt_version,
            model=extract_result.model,
            total_cost_usd=extract_result.total_cost_usd,
        )
        print(f"Dumped {count} persons to {seed_path}")

        # Summary
        print("\n=== PILOT SUMMARY ===")
        print(f"Chapter: {chapter.title_zh}")
        print(f"Paragraphs: {extract_result.total_paragraphs}")
        print(f"Persons extracted: {len(extract_result.persons)}")
        print(f"Persons merged: {len(merged)}")
        print(f"Cost: ${extract_result.total_cost_usd:.4f}")
        print(f"Model: {extract_result.model}")
        print(f"Prompt: {extract_result.prompt_version}")

    finally:
        await pool.close()


async def _cmd_seed_dump(args: argparse.Namespace, dsn: str) -> None:
    import asyncpg

    from .seed_dump import dump_seed_sql

    pool = await asyncpg.create_pool(dsn, min_size=1, max_size=3)
    try:
        count = await dump_seed_sql(
            pool,
            book_id=args.book_id,
            output_path=args.output,
        )
        print(f"Dumped {count} persons to {args.output}")
    finally:
        await pool.close()


def _create_gateway(dsn: str) -> object:
    """Create an AnthropicGateway with TraceGuard adapter."""
    from .ai.anthropic_provider import AnthropicGateway
    from .ai.audit import LLMCallAuditWriter
    from .qc.adapter import TraceGuardAdapter

    tg = TraceGuardAdapter(mode="shadow")
    audit = LLMCallAuditWriter(dsn=dsn)
    return AnthropicGateway(tg=tg, audit_writer=audit)


def _print_extraction_summary(result: object) -> None:
    """Print extraction result summary."""
    from .extract import ExtractionResult

    if not isinstance(result, ExtractionResult):
        return

    print("Extraction complete:")
    print(
        f"  Paragraphs: {result.processed_paragraphs}/{result.total_paragraphs} processed, {result.failed_paragraphs} failed"
    )
    print(f"  Persons: {len(result.persons)}")
    print(f"  Cost: ${result.total_cost_usd:.4f}")
    print(f"  Tokens: {result.total_input_tokens} in / {result.total_output_tokens} out")
    print(f"  Model: {result.model}")
    print(f"  Prompt: {result.prompt_version} (hash: {result.prompt_file_hash[:12]}...)")

    if result.errors:
        print(f"  Errors: {len(result.errors)}")
        for err in result.errors[:5]:
            print(f"    - {err}")

    if result.budget_exceeded:
        print("  ⚠️  BUDGET EXCEEDED")


if __name__ == "__main__":
    main()
