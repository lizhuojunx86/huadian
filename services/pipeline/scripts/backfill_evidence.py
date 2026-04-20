"""Backfill source_evidences for pre-ADR-015 books.

Mode: backfill (Path A) — reuse existing llm_call responses to create
source_evidences and link them to existing person_names.

Usage:
    cd services/pipeline
    uv run python scripts/backfill_evidence.py --book shangshu-yao-dian --dry-run
    uv run python scripts/backfill_evidence.py --book shangshu-yao-dian shangshu-shun-dian --dry-run

Hard constraints (ADR / architect directive):
  - E: Never create new persons or person_names
  - Only UPDATE person_names.source_evidence_id WHERE currently NULL
  - Only INSERT source_evidences rows
  - dry_run=True by default; --execute required for real writes
"""

from __future__ import annotations

import argparse
import asyncio
import hashlib
import json
import logging
import os
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "src"))

import asyncpg

from huadian_pipeline.extract import _parse_response
from huadian_pipeline.load import MergedPerson, _filter_pronoun_surfaces
from huadian_pipeline.slug import generate_slug

# --- Config ---

DEFAULT_DSN = "postgresql://huadian:huadian_dev@localhost:5433/huadian"
PROMPT_VERSION = "ner/v1-r4"

# --- Logging (JSON to stderr, no external deps) ---


class _JsonFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        obj: dict[str, Any] = {
            "ts": self.formatTime(record, "%Y-%m-%dT%H:%M:%S"),
            "level": record.levelname.lower(),
            "event": record.getMessage(),
        }
        if hasattr(record, "extra_fields"):
            obj.update(record.extra_fields)  # type: ignore[arg-type]
        return json.dumps(obj, ensure_ascii=False)


_handler = logging.StreamHandler(sys.stderr)
_handler.setFormatter(_JsonFormatter())

slog = logging.getLogger("backfill_evidence")
slog.addHandler(_handler)
slog.setLevel(logging.DEBUG)
slog.propagate = False

# Suppress noisy library loggers
logging.basicConfig(level=logging.WARNING, stream=sys.stderr)


def _log(level: int, event: str, **kwargs: Any) -> None:
    """Emit a structured JSON log line."""
    record = slog.makeRecord(slog.name, level, "", 0, event, (), None)
    record.extra_fields = kwargs  # type: ignore[attr-defined]
    slog.handle(record)


# --- Data types ---


@dataclass
class ParagraphResult:
    """Result of processing one paragraph."""

    paragraph_no: int
    raw_text_id: str
    llm_call_id: str | None = None
    persons_in_response: int = 0
    will_link: int = 0
    skip: int = 0
    no_match: int = 0
    error: str | None = None


@dataclass
class BackfillStats:
    """Aggregate stats for a book backfill run."""

    book_slug: str = ""
    book_id: str = ""
    paragraphs_total: int = 0
    paragraphs_processed: int = 0
    paragraphs_skipped: int = 0
    se_created: int = 0
    names_linked: int = 0
    names_skipped: int = 0
    no_match_total: int = 0
    errors: list[str] = field(default_factory=list)
    paragraph_results: list[ParagraphResult] = field(default_factory=list)


# --- Core functions ---


def compute_input_hash(text: str) -> str:
    """SHA-256 of raw input text (mirrors ai/hashing.py:input_hash)."""
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


async def find_llm_call_by_hash(
    conn: Any, hash_val: str, prompt_version: str
) -> dict[str, Any] | None:
    """Find llm_call by input_hash. R1: fail loud on multiple matches.

    Returns dict with keys: id, response, created_at.
    Raises RuntimeError if >1 match found.
    """
    rows = await conn.fetch(
        """
        SELECT id, response, created_at
        FROM llm_calls
        WHERE input_hash = $1 AND prompt_version = $2
        ORDER BY created_at DESC
        LIMIT 2
        """,
        hash_val,
        prompt_version,
    )

    if not rows:
        return None

    if len(rows) > 1:
        ids = [str(r["id"]) for r in rows]
        _log(
            logging.ERROR,
            "multiple_llm_calls_for_hash",
            input_hash=hash_val,
            prompt_version=prompt_version,
            llm_call_ids=ids,
        )
        raise RuntimeError(f"R1 violation: multiple llm_calls for hash {hash_val[:16]}...: {ids}")

    row = rows[0]
    return {
        "id": str(row["id"]),
        "response": row["response"],
        "created_at": row["created_at"],
    }


async def find_active_person_by_slug(conn: Any, slug: str) -> str | None:
    """Find active person ID by slug. Returns None if not found."""
    row = await conn.fetchval(
        "SELECT id FROM persons WHERE slug = $1 AND deleted_at IS NULL",
        slug,
    )
    return str(row) if row else None


async def check_existing_se(conn: Any, person_id: str, raw_text_id: str, llm_call_id: str) -> bool:
    """R2: Check if a source_evidence already exists for this (person, raw_text, llm_call).

    Uses: person_names.source_evidence_id → source_evidences.(raw_text_id, llm_call_id).
    """
    exists = await conn.fetchval(
        """
        SELECT 1
        FROM source_evidences se
        JOIN person_names pn ON pn.source_evidence_id = se.id
        WHERE pn.person_id = $1::uuid
          AND se.raw_text_id = $2::uuid
          AND se.llm_call_id = $3::uuid
        LIMIT 1
        """,
        person_id,
        raw_text_id,
        llm_call_id,
    )
    return exists is not None


async def find_uncovered_names(
    conn: Any, person_id: str, surface_texts: set[str]
) -> list[dict[str, Any]]:
    """Find person_names for this person where source_evidence_id IS NULL
    and name is in the given surface_texts set.
    """
    if not surface_texts:
        return []

    rows = await conn.fetch(
        """
        SELECT id, name
        FROM person_names
        WHERE person_id = $1::uuid
          AND source_evidence_id IS NULL
          AND name = ANY($2)
        """,
        person_id,
        list(surface_texts),
    )
    return [{"id": str(r["id"]), "name": r["name"]} for r in rows]


async def insert_source_evidence(
    conn: Any,
    *,
    raw_text_id: str,
    book_id: str,
    prompt_version: str,
    llm_call_id: str,
) -> str:
    """Insert a source_evidence row. Returns new SE id."""
    se_id = await conn.fetchval(
        """
        INSERT INTO source_evidences
          (raw_text_id, book_id, provenance_tier, prompt_version, llm_call_id)
        VALUES ($1::uuid, $2::uuid, 'ai_inferred'::provenance_tier, $3, $4::uuid)
        RETURNING id
        """,
        raw_text_id,
        book_id,
        prompt_version,
        llm_call_id,
    )
    return str(se_id)


async def update_names_evidence(conn: Any, name_ids: list[str], se_id: str) -> int:
    """Update person_names.source_evidence_id for given name IDs."""
    result = await conn.execute(
        """
        UPDATE person_names
        SET source_evidence_id = $1::uuid
        WHERE id = ANY($2::uuid[])
          AND source_evidence_id IS NULL
        """,
        se_id,
        name_ids,
    )
    # result is like "UPDATE N"
    return int(result.split()[-1])


# --- Main backfill logic ---


async def backfill_book(
    pool: asyncpg.Pool,
    book_slug: str,
    *,
    dry_run: bool = True,
) -> BackfillStats:
    """Backfill source_evidences for one book using existing llm_call responses."""

    stats = BackfillStats(book_slug=book_slug)

    async with pool.acquire() as conn:
        # Get book_id
        book_row = await conn.fetchrow("SELECT id FROM books WHERE slug = $1", book_slug)
        if not book_row:
            stats.errors.append(f"Book not found: {book_slug}")
            return stats
        stats.book_id = str(book_row["id"])

        # Fetch raw_texts
        raw_texts = await conn.fetch(
            """
            SELECT id, paragraph_no, raw_text
            FROM raw_texts
            WHERE book_id = $1::uuid AND deleted_at IS NULL
            ORDER BY paragraph_no
            """,
            stats.book_id,
        )
        stats.paragraphs_total = len(raw_texts)

    # Process each paragraph
    for rt in raw_texts:
        pr = ParagraphResult(
            paragraph_no=rt["paragraph_no"],
            raw_text_id=str(rt["id"]),
        )

        try:
            await _process_paragraph(pool, rt, stats, pr, dry_run=dry_run)
        except Exception as e:
            pr.error = str(e)
            stats.errors.append(f"§{rt['paragraph_no']}: {e}")
            _log(
                logging.ERROR,
                "paragraph_error",
                paragraph_no=rt["paragraph_no"],
                book=book_slug,
                error=str(e),
            )

        stats.paragraph_results.append(pr)

    return stats


async def _process_paragraph(
    pool: asyncpg.Pool,
    rt: Any,
    stats: BackfillStats,
    pr: ParagraphResult,
    *,
    dry_run: bool,
) -> None:
    """Process a single paragraph for evidence backfill."""

    raw_text_id = str(rt["id"])
    paragraph_no = rt["paragraph_no"]
    raw_text_content = rt["raw_text"]

    # Step 1: Find llm_call by hash
    hash_val = compute_input_hash(raw_text_content)

    async with pool.acquire() as conn:
        llm_call = await find_llm_call_by_hash(conn, hash_val, PROMPT_VERSION)

    if not llm_call:
        pr.error = "no_llm_call"
        stats.paragraphs_skipped += 1
        _log(
            logging.WARNING,
            "no_llm_call_for_paragraph",
            paragraph_no=paragraph_no,
            book=stats.book_slug,
            input_hash=hash_val[:16],
        )
        return

    pr.llm_call_id = llm_call["id"]

    # Step 2: Parse response (asyncpg may return JSONB as str or dict)
    response_raw = llm_call["response"]
    if isinstance(response_raw, str):
        response_data = json.loads(response_raw) if response_raw else {}
    else:
        response_data = response_raw or {}
    content = response_data.get("content", "") if isinstance(response_data, dict) else ""
    if not content:
        pr.error = "empty_response"
        stats.paragraphs_skipped += 1
        return

    persons = _parse_response(content, paragraph_no, raw_text_id, llm_call_id=llm_call["id"])
    pr.persons_in_response = len(persons)

    if not persons:
        stats.paragraphs_processed += 1
        return

    # Step 3: For each person, match and link
    async with pool.acquire() as conn:
        for extracted in persons:
            slug = generate_slug(extracted.name_zh)
            person_id = await find_active_person_by_slug(conn, slug)

            if not person_id:
                pr.no_match += 1
                stats.no_match_total += 1
                _log(
                    logging.INFO,
                    "surface_not_in_persons",
                    surface=extracted.name_zh,
                    slug=slug,
                    paragraph=paragraph_no,
                    book=stats.book_slug,
                    llm_call_id=llm_call["id"],
                )
                continue

            # Build surface_texts set (name_zh + filtered surfaces)
            temp_merged = MergedPerson(
                name_zh=extracted.name_zh,
                slug=slug,
                surface_forms=list(extracted.surface_forms),
                dynasty=extracted.dynasty,
                reality_status=extracted.reality_status,
                briefs=[],
                identity_notes=[],
                confidence=extracted.confidence,
                chunk_ids=[raw_text_id],
                paragraph_nos=[paragraph_no],
            )
            filtered = _filter_pronoun_surfaces(temp_merged)
            surface_texts = {sf.text for sf in filtered}
            surface_texts.add(extracted.name_zh)

            # R4: Log each surface that doesn't match any person_name
            # (handled below after uncovered lookup)

            # R2: Check existing SE
            se_exists = await check_existing_se(conn, person_id, raw_text_id, llm_call["id"])
            if se_exists:
                pr.skip += 1
                stats.names_skipped += 1
                _log(
                    logging.DEBUG,
                    "se_already_present",
                    person_id=person_id,
                    raw_text_id=raw_text_id,
                    llm_call_id=llm_call["id"],
                )
                continue

            # Find uncovered names matching surface_texts
            uncovered = await find_uncovered_names(conn, person_id, surface_texts)

            if not uncovered:
                pr.skip += 1
                stats.names_skipped += 1
                # All names already have evidence or no matching names exist
                # R4: check which surfaces have no person_name at all
                for sf_text in surface_texts:
                    exists = await conn.fetchval(
                        "SELECT 1 FROM person_names WHERE person_id = $1::uuid AND name = $2 LIMIT 1",
                        person_id,
                        sf_text,
                    )
                    if not exists:
                        pr.no_match += 1
                        stats.no_match_total += 1
                        _log(
                            logging.INFO,
                            "surface_not_in_persons",
                            surface=sf_text,
                            person_slug=slug,
                            paragraph=paragraph_no,
                            book=stats.book_slug,
                            llm_call_id=llm_call["id"],
                        )
                continue

            # Perform write (or preview in dry-run)
            if dry_run:
                pr.will_link += len(uncovered)
                stats.names_linked += len(uncovered)
                stats.se_created += 1
            else:
                async with conn.transaction():
                    se_id = await insert_source_evidence(
                        conn,
                        raw_text_id=raw_text_id,
                        book_id=stats.book_id,
                        prompt_version=PROMPT_VERSION,
                        llm_call_id=llm_call["id"],
                    )
                    name_ids = [n["id"] for n in uncovered]
                    updated = await update_names_evidence(conn, name_ids, se_id)
                    pr.will_link += updated
                    stats.names_linked += updated
                    stats.se_created += 1

    stats.paragraphs_processed += 1


# --- Output formatting ---


async def get_v7_current(pool: asyncpg.Pool) -> tuple[int, int]:
    """Get current V7 numerator and denominator."""
    async with pool.acquire() as conn:
        row = await conn.fetchrow(
            """
            SELECT
              count(*) AS total,
              count(pn.source_evidence_id) AS covered
            FROM person_names pn
            JOIN persons p ON p.id = pn.person_id
            WHERE p.deleted_at IS NULL AND p.merged_into_id IS NULL
            """
        )
    return int(row["covered"]), int(row["total"])


def print_summary(all_stats: list[BackfillStats], v7_before: tuple[int, int]) -> None:
    """Print R3-compliant summary to stdout."""
    covered_before, total = v7_before
    total_linked = sum(s.names_linked for s in all_stats)
    covered_after = covered_before + total_linked

    print("\n" + "=" * 78)
    print("BACKFILL EVIDENCE — DRY-RUN SUMMARY")
    print("=" * 78)

    for stats in all_stats:
        print(f"\n📖 Book: {stats.book_slug} ({stats.paragraphs_total} paragraphs)")
        print("-" * 78)
        print(
            f"{'§':>4} | {'llm_call':36} | {'persons':>7} | {'link':>4} | {'skip':>4} | {'no_match':>8}"
        )
        print("-" * 78)

        for pr in stats.paragraph_results:
            call_id = pr.llm_call_id[:36] if pr.llm_call_id else "(none)".ljust(36)
            if pr.error and pr.error != "no_llm_call":
                call_id = f"ERROR: {pr.error}"[:36]
            print(
                f"{pr.paragraph_no:>4} | {call_id} | {pr.persons_in_response:>7} | "
                f"{pr.will_link:>4} | {pr.skip:>4} | {pr.no_match:>8}"
            )

        print("-" * 78)
        print(
            f"{'SUM':>4} | {'':36} | {sum(p.persons_in_response for p in stats.paragraph_results):>7} | "
            f"{stats.names_linked:>4} | {stats.names_skipped:>4} | {stats.no_match_total:>8}"
        )

    # Summary block
    print("\n" + "=" * 78)
    print("V7 PROJECTION")
    print("=" * 78)
    pct_before = 100.0 * covered_before / total if total else 0
    pct_after = 100.0 * covered_after / total if total else 0
    print(f"  v7_before:          {covered_before}/{total} = {pct_before:.2f}%")
    print(f"  names_to_link:      +{total_linked}")
    print(f"  v7_after_projection:{covered_after}/{total} = {pct_after:.2f}%")
    print(f"  se_to_create:       {sum(s.se_created for s in all_stats)}")
    print(f"  no_match_total:     {sum(s.no_match_total for s in all_stats)}")
    print(f"  errors:             {sum(len(s.errors) for s in all_stats)}")
    print("=" * 78)

    # Also emit as structured log
    _log(
        logging.INFO,
        "backfill_summary",
        v7_before_pct=round(pct_before, 2),
        v7_after_pct=round(pct_after, 2),
        v7_before_num=covered_before,
        v7_after_num=covered_after,
        v7_denom=total,
        names_linked=total_linked,
        se_created=sum(s.se_created for s in all_stats),
        no_match_total=sum(s.no_match_total for s in all_stats),
        books=[s.book_slug for s in all_stats],
    )


# --- CLI ---


async def async_main(args: argparse.Namespace) -> None:
    db_url = os.environ.get("DATABASE_URL", DEFAULT_DSN)
    pool = await asyncpg.create_pool(db_url, min_size=1, max_size=3)
    assert pool is not None

    try:
        # Get V7 baseline before backfill
        v7_before = await get_v7_current(pool)

        all_stats: list[BackfillStats] = []
        for book_slug in args.book:
            _log(logging.INFO, "backfill_start", book=book_slug, dry_run=args.dry_run)
            stats = await backfill_book(pool, book_slug, dry_run=args.dry_run)
            all_stats.append(stats)
            _log(
                logging.INFO,
                "backfill_done",
                book=book_slug,
                se_created=stats.se_created,
                names_linked=stats.names_linked,
                no_match=stats.no_match_total,
                errors=len(stats.errors),
            )

        print_summary(all_stats, v7_before)

    finally:
        await pool.close()


def main() -> None:
    parser = argparse.ArgumentParser(description="Backfill source_evidences for pre-ADR-015 books")
    parser.add_argument(
        "--book",
        nargs="+",
        required=True,
        help="Book slug(s) to backfill (e.g. shangshu-yao-dian)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        default=True,
        help="Preview only, no DB writes (default: True)",
    )
    parser.add_argument(
        "--execute",
        action="store_true",
        default=False,
        help="Actually write to DB (disables dry-run)",
    )
    parser.add_argument(
        "--mode",
        choices=["backfill"],
        default="backfill",
        help="Backfill mode (currently only 'backfill' supported)",
    )

    args = parser.parse_args()

    # --execute overrides --dry-run
    if args.execute:
        args.dry_run = False

    asyncio.run(async_main(args))


if __name__ == "__main__":
    main()
