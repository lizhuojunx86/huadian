"""Backfill source_evidences for pre-ADR-015 books.

Modes:
  backfill  (Path A) — reuse existing llm_call responses
  reextract (Path B) — re-run NER v1-r4 via LLM gateway, then backfill

Usage:
    cd services/pipeline
    uv run python scripts/backfill_evidence.py --book shangshu-yao-dian --dry-run
    uv run python scripts/backfill_evidence.py --book shiji-wu-di-ben-ji --mode reextract --dry-run

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

# Slugs that map to ≥2 active persons via person_names.name overlap.
# When slug-first lookup hits one of these, emit SLUG_MATCH_ON_AMBIGUOUS audit log.
# Maintained manually; derived from Stage 2b Step 1 ambiguity pre-check.
AMBIGUOUS_SLUGS: frozenset[str] = frozenset(
    {
        "qi",  # 夏启 vs 微子启
        "u5468-u6b66-u738b",  # 周武王 (also wu-wang)
        "wu-wang",  # 武王 (also zhou-wu-wang)
        "tang",  # 汤 (also has 武王 as posthumous)
        "wu-ding",  # 武丁 (also has 王 as nickname)
    }
)


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


class AmbiguousNameError(Exception):
    """Raised when name-fallback finds ≥2 active persons for the same name."""

    def __init__(self, name: str, candidates: list[dict[str, str]]) -> None:
        self.name = name
        self.candidates = candidates
        super().__init__(
            f"Ambiguous name '{name}': {len(candidates)} active persons: "
            + ", ".join(f"{c['slug']}({c['id'][:8]})" for c in candidates)
        )


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
    ambiguous_slug_audit: int = 0
    fail_loud: int = 0
    error: str | None = None


@dataclass
class BackfillStats:
    """Aggregate stats for a book backfill run."""

    book_slug: str = ""
    book_id: str = ""
    mode: str = "backfill"
    paragraphs_total: int = 0
    paragraphs_processed: int = 0
    paragraphs_skipped: int = 0
    se_created: int = 0
    names_linked: int = 0
    names_skipped: int = 0
    no_match_total: int = 0
    ambiguous_slug_audits: int = 0
    fail_loud_total: int = 0
    total_cost_usd: float = 0.0
    errors: list[str] = field(default_factory=list)
    paragraph_results: list[ParagraphResult] = field(default_factory=list)


# --- Core functions ---


def compute_input_hash(text: str) -> str:
    """SHA-256 of raw input text (mirrors ai/hashing.py:input_hash)."""
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


async def find_llm_call_by_hash(
    conn: Any, hash_val: str, prompt_version: str
) -> dict[str, Any] | None:
    """Find llm_call by input_hash. R1: fail loud on multiple matches."""
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
    return {"id": str(row["id"]), "response": row["response"], "created_at": row["created_at"]}


async def find_active_person_by_slug(conn: Any, slug: str) -> str | None:
    """Find active person ID by slug. Returns None if not found."""
    row = await conn.fetchval(
        "SELECT id FROM persons WHERE slug = $1 AND deleted_at IS NULL",
        slug,
    )
    return str(row) if row else None


async def find_active_person_by_name(conn: Any, name_zh: str) -> str | None:
    """Fallback: find active person by matching person_names.name.

    Three-state return:
      - None: 0 matches
      - str (person_id): exactly 1 match
      - raises AmbiguousNameError: ≥2 matches (fail loud)
    """
    rows = await conn.fetch(
        """
        SELECT DISTINCT p.id, p.slug
        FROM persons p
        JOIN person_names pn ON pn.person_id = p.id
        WHERE p.deleted_at IS NULL AND p.merged_into_id IS NULL
          AND pn.name = $1
        """,
        name_zh,
    )
    if not rows:
        return None
    if len(rows) == 1:
        return str(rows[0]["id"])
    # ≥2 matches → fail loud
    candidates = [{"id": str(r["id"]), "slug": r["slug"]} for r in rows]
    raise AmbiguousNameError(name_zh, candidates)


async def check_existing_se(conn: Any, person_id: str, raw_text_id: str, llm_call_id: str) -> bool:
    """R2: Check if a source_evidence already exists for this (person, raw_text, llm_call)."""
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
    """Find person_names where source_evidence_id IS NULL and name matches."""
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
    return int(result.split()[-1])


# --- Reextract support ---


def _create_gateway(dsn: str) -> Any:
    """Create AnthropicGateway with TraceGuard (mirrors cli.py)."""
    from huadian_pipeline.ai.anthropic_provider import AnthropicGateway
    from huadian_pipeline.ai.audit import LLMCallAuditWriter
    from huadian_pipeline.qc.adapter import TraceGuardAdapter

    tg = TraceGuardAdapter(mode="shadow")
    audit = LLMCallAuditWriter(dsn=dsn)
    return AnthropicGateway(tg=tg, audit_writer=audit)


async def extract_paragraph_via_gateway(
    gateway: Any,
    *,
    raw_text: str,
    paragraph_no: int,
    chunk_id: str,
    book_id: str,
) -> tuple[str | None, list[Any], float]:
    """Run NER v1-r4 on a single paragraph via LLM gateway.

    Returns (llm_call_id, persons, cost_usd).
    The call is audited to llm_calls table by the gateway's audit_writer.
    """
    from huadian_pipeline.extract import _extract_chunk
    from huadian_pipeline.prompts.loader import load_prompt

    prompt = load_prompt("ner", "v1-r4")
    persons, resp = await _extract_chunk(
        gateway,
        prompt,
        raw_text=raw_text,
        paragraph_no=paragraph_no,
        chunk_id=chunk_id,
        book_id=book_id,
    )
    return resp.call_id, persons, resp.cost_usd


# --- Person resolution (shared by both modes) ---


async def _resolve_person(
    conn: Any,
    extracted: Any,
    *,
    raw_text_id: str,
    paragraph_no: int,
    llm_call_id: str,
    book_slug: str,
    pr: ParagraphResult,
    stats: BackfillStats,
) -> tuple[str | None, str | None]:
    """Resolve an extracted person to an active person_id.

    Returns (person_id, matched_slug) or (None, None) on no_match/fail_loud.
    Handles slug-first lookup, ambiguity audit, name-fallback, and fail-loud.
    """
    slug = generate_slug(extracted.name_zh)
    person_id = await find_active_person_by_slug(conn, slug)

    if person_id:
        # Slug-first matched — check if it's an ambiguous slug
        if slug in AMBIGUOUS_SLUGS:
            # Fetch other candidates for audit log
            other_rows = await conn.fetch(
                """
                SELECT DISTINCT p.id, p.slug FROM persons p
                JOIN person_names pn ON pn.person_id = p.id
                WHERE p.deleted_at IS NULL AND p.merged_into_id IS NULL
                  AND pn.name = $1 AND p.id != $2::uuid
                """,
                extracted.name_zh,
                person_id,
            )
            other_candidates = [{"id": str(r["id"]), "slug": r["slug"]} for r in other_rows]
            pr.ambiguous_slug_audit += 1
            stats.ambiguous_slug_audits += 1
            _log(
                logging.WARNING,
                "SLUG_MATCH_ON_AMBIGUOUS",
                book=book_slug,
                paragraph=paragraph_no,
                llm_call_id=llm_call_id,
                llm_name_zh=extracted.name_zh,
                chosen_person_id=person_id,
                chosen_slug=slug,
                other_candidates_in_db=other_candidates,
            )
        return person_id, slug

    # Slug miss → try name-fallback
    try:
        person_id = await find_active_person_by_name(conn, extracted.name_zh)
    except AmbiguousNameError as e:
        pr.fail_loud += 1
        pr.no_match += 1
        stats.fail_loud_total += 1
        stats.no_match_total += 1
        _log(
            logging.ERROR,
            "ambiguous_name_in_fallback",
            name=e.name,
            candidates=e.candidates,
            book=book_slug,
            paragraph=paragraph_no,
            llm_call_id=llm_call_id,
        )
        return None, None

    if person_id:
        # Fallback matched — get slug for logging
        matched_slug = await conn.fetchval(
            "SELECT slug FROM persons WHERE id = $1::uuid", person_id
        )
        _log(
            logging.INFO,
            "name_fallback_matched",
            llm_name_zh=extracted.name_zh,
            original_slug=slug,
            matched_person_id=person_id,
            matched_slug=matched_slug,
            book=book_slug,
            paragraph=paragraph_no,
        )
        return person_id, matched_slug

    # No match at all
    pr.no_match += 1
    stats.no_match_total += 1
    _log(
        logging.INFO,
        "surface_not_in_persons",
        surface=extracted.name_zh,
        slug=slug,
        paragraph=paragraph_no,
        book=book_slug,
        llm_call_id=llm_call_id,
    )
    return None, None


async def _link_evidence_for_person(
    conn: Any,
    extracted: Any,
    person_id: str,
    matched_slug: str,
    *,
    raw_text_id: str,
    paragraph_no: int,
    llm_call_id: str,
    book_id: str,
    book_slug: str,
    pr: ParagraphResult,
    stats: BackfillStats,
    dry_run: bool,
) -> None:
    """Create source_evidence and link uncovered names for one person."""
    # Build surface_texts
    temp_merged = MergedPerson(
        name_zh=extracted.name_zh,
        slug=matched_slug,
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

    # R2: Check existing SE
    se_exists = await check_existing_se(conn, person_id, raw_text_id, llm_call_id)
    if se_exists:
        pr.skip += 1
        stats.names_skipped += 1
        return

    uncovered = await find_uncovered_names(conn, person_id, surface_texts)

    if not uncovered:
        pr.skip += 1
        stats.names_skipped += 1
        # R4: log surfaces that have no person_name at all
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
                    person_slug=matched_slug,
                    paragraph=paragraph_no,
                    book=book_slug,
                    llm_call_id=llm_call_id,
                )
        return

    if dry_run:
        pr.will_link += len(uncovered)
        stats.names_linked += len(uncovered)
        stats.se_created += 1
    else:
        async with conn.transaction():
            se_id = await insert_source_evidence(
                conn,
                raw_text_id=raw_text_id,
                book_id=book_id,
                prompt_version=PROMPT_VERSION,
                llm_call_id=llm_call_id,
            )
            name_ids = [n["id"] for n in uncovered]
            updated = await update_names_evidence(conn, name_ids, se_id)
            pr.will_link += updated
            stats.names_linked += updated
            stats.se_created += 1


# --- Main backfill logic ---


async def backfill_book(
    pool: asyncpg.Pool,
    book_slug: str,
    *,
    mode: str = "backfill",
    dry_run: bool = True,
    gateway: Any = None,
) -> BackfillStats:
    """Backfill source_evidences for one book."""
    stats = BackfillStats(book_slug=book_slug, mode=mode)

    async with pool.acquire() as conn:
        book_row = await conn.fetchrow("SELECT id FROM books WHERE slug = $1", book_slug)
        if not book_row:
            stats.errors.append(f"Book not found: {book_slug}")
            return stats
        stats.book_id = str(book_row["id"])

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

    for rt in raw_texts:
        pr = ParagraphResult(paragraph_no=rt["paragraph_no"], raw_text_id=str(rt["id"]))
        try:
            if mode == "backfill":
                await _process_paragraph_backfill(pool, rt, stats, pr, dry_run=dry_run)
            else:
                await _process_paragraph_reextract(
                    pool, rt, stats, pr, dry_run=dry_run, gateway=gateway
                )
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


async def _process_paragraph_backfill(
    pool: asyncpg.Pool,
    rt: Any,
    stats: BackfillStats,
    pr: ParagraphResult,
    *,
    dry_run: bool,
) -> None:
    """Process a paragraph in backfill mode (reuse existing llm_call)."""
    raw_text_id = str(rt["id"])
    paragraph_no = rt["paragraph_no"]

    hash_val = compute_input_hash(rt["raw_text"])
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

    async with pool.acquire() as conn:
        for extracted in persons:
            person_id, matched_slug = await _resolve_person(
                conn,
                extracted,
                raw_text_id=raw_text_id,
                paragraph_no=paragraph_no,
                llm_call_id=llm_call["id"],
                book_slug=stats.book_slug,
                pr=pr,
                stats=stats,
            )
            if not person_id:
                continue
            await _link_evidence_for_person(
                conn,
                extracted,
                person_id,
                matched_slug,
                raw_text_id=raw_text_id,
                paragraph_no=paragraph_no,
                llm_call_id=llm_call["id"],
                book_id=stats.book_id,
                book_slug=stats.book_slug,
                pr=pr,
                stats=stats,
                dry_run=dry_run,
            )

    stats.paragraphs_processed += 1


async def _process_paragraph_reextract(
    pool: asyncpg.Pool,
    rt: Any,
    stats: BackfillStats,
    pr: ParagraphResult,
    *,
    dry_run: bool,
    gateway: Any,
) -> None:
    """Process a paragraph in reextract mode (call LLM, then link evidence)."""
    raw_text_id = str(rt["id"])
    paragraph_no = rt["paragraph_no"]

    # Call LLM (always, even in dry-run — we need the output to estimate)
    llm_call_id, persons, cost_usd = await extract_paragraph_via_gateway(
        gateway,
        raw_text=rt["raw_text"],
        paragraph_no=paragraph_no,
        chunk_id=raw_text_id,
        book_id=stats.book_id,
    )
    stats.total_cost_usd += cost_usd
    pr.llm_call_id = llm_call_id
    pr.persons_in_response = len(persons)

    if not persons:
        stats.paragraphs_processed += 1
        return

    if not llm_call_id:
        pr.error = "no_llm_call_id_from_gateway"
        stats.paragraphs_skipped += 1
        return

    async with pool.acquire() as conn:
        for extracted in persons:
            person_id, matched_slug = await _resolve_person(
                conn,
                extracted,
                raw_text_id=raw_text_id,
                paragraph_no=paragraph_no,
                llm_call_id=llm_call_id,
                book_slug=stats.book_slug,
                pr=pr,
                stats=stats,
            )
            if not person_id:
                continue
            await _link_evidence_for_person(
                conn,
                extracted,
                person_id,
                matched_slug,
                raw_text_id=raw_text_id,
                paragraph_no=paragraph_no,
                llm_call_id=llm_call_id,
                book_id=stats.book_id,
                book_slug=stats.book_slug,
                pr=pr,
                stats=stats,
                dry_run=dry_run,
            )

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


def print_summary(all_stats: list[BackfillStats], v7_before: tuple[int, int], *, mode: str) -> None:
    """Print R3-compliant summary to stdout."""
    covered_before, total = v7_before
    total_linked = sum(s.names_linked for s in all_stats)
    covered_after = covered_before + total_linked

    print("\n" + "=" * 90)
    title = "REEXTRACT" if mode == "reextract" else "BACKFILL"
    print(f"{title} EVIDENCE — DRY-RUN SUMMARY")
    print("=" * 90)

    for stats in all_stats:
        print(f"\n📖 Book: {stats.book_slug} ({stats.paragraphs_total} paragraphs)")
        if stats.total_cost_usd > 0:
            print(f"   LLM cost: ${stats.total_cost_usd:.4f}")
        print("-" * 90)
        print(
            f"{'§':>4} | {'llm_call':36} | {'persons':>7} | {'link':>4} | "
            f"{'skip':>4} | {'no_match':>8} | {'ambig':>5} | {'fail':>4}"
        )
        print("-" * 90)

        for pr in stats.paragraph_results:
            call_id = pr.llm_call_id[:36] if pr.llm_call_id else "(none)".ljust(36)
            if pr.error and pr.error not in ("no_llm_call",):
                call_id = f"ERROR: {pr.error}"[:36]
            print(
                f"{pr.paragraph_no:>4} | {call_id} | {pr.persons_in_response:>7} | "
                f"{pr.will_link:>4} | {pr.skip:>4} | {pr.no_match:>8} | "
                f"{pr.ambiguous_slug_audit:>5} | {pr.fail_loud:>4}"
            )

        print("-" * 90)
        print(
            f"{'SUM':>4} | {'':36} | "
            f"{sum(p.persons_in_response for p in stats.paragraph_results):>7} | "
            f"{stats.names_linked:>4} | {stats.names_skipped:>4} | "
            f"{stats.no_match_total:>8} | {stats.ambiguous_slug_audits:>5} | "
            f"{stats.fail_loud_total:>4}"
        )

    # V7 projection
    print("\n" + "=" * 90)
    print("V7 PROJECTION")
    print("=" * 90)
    pct_before = 100.0 * covered_before / total if total else 0
    pct_after = 100.0 * covered_after / total if total else 0
    print(f"  v7_before:           {covered_before}/{total} = {pct_before:.2f}%")
    print(f"  names_to_link:       +{total_linked}")
    print(f"  v7_after_projection: {covered_after}/{total} = {pct_after:.2f}%")
    print(f"  se_to_create:        {sum(s.se_created for s in all_stats)}")
    print(f"  no_match_total:      {sum(s.no_match_total for s in all_stats)}")
    print(f"  ambig_slug_audits:   {sum(s.ambiguous_slug_audits for s in all_stats)}")
    print(f"  fail_loud_total:     {sum(s.fail_loud_total for s in all_stats)}")
    total_cost = sum(s.total_cost_usd for s in all_stats)
    if total_cost > 0:
        print(f"  llm_cost_usd:        ${total_cost:.4f}")
    print(f"  errors:              {sum(len(s.errors) for s in all_stats)}")
    print("=" * 90)

    # Disclaimer for dry-run
    print(
        "\n⚠️  DISCLAIMER: dry-run projection has systematic positive bias —\n"
        "    same person across multiple paragraphs is counted once per paragraph\n"
        "    in dry-run but only first-write-wins in real execution.\n"
        "    Actual V7 will be lower than projection. See T-P1-012."
    )

    # Structured log
    _log(
        logging.INFO,
        "backfill_summary",
        mode=mode,
        v7_before_pct=round(pct_before, 2),
        v7_after_pct=round(pct_after, 2),
        v7_before_num=covered_before,
        v7_after_num=covered_after,
        v7_denom=total,
        names_linked=total_linked,
        se_created=sum(s.se_created for s in all_stats),
        no_match_total=sum(s.no_match_total for s in all_stats),
        ambig_slug_audits=sum(s.ambiguous_slug_audits for s in all_stats),
        fail_loud_total=sum(s.fail_loud_total for s in all_stats),
        llm_cost_usd=round(total_cost, 4),
        books=[s.book_slug for s in all_stats],
    )


# --- CLI ---


async def async_main(args: argparse.Namespace) -> None:
    db_url = os.environ.get("DATABASE_URL", DEFAULT_DSN)
    pool = await asyncpg.create_pool(db_url, min_size=1, max_size=3)
    assert pool is not None

    gateway = None
    if args.mode == "reextract":
        gateway = _create_gateway(db_url)

    try:
        v7_before = await get_v7_current(pool)

        all_stats: list[BackfillStats] = []
        for book_slug in args.book:
            _log(
                logging.INFO,
                "backfill_start",
                book=book_slug,
                mode=args.mode,
                dry_run=args.dry_run,
            )
            stats = await backfill_book(
                pool, book_slug, mode=args.mode, dry_run=args.dry_run, gateway=gateway
            )
            all_stats.append(stats)
            _log(
                logging.INFO,
                "backfill_done",
                book=book_slug,
                mode=args.mode,
                se_created=stats.se_created,
                names_linked=stats.names_linked,
                no_match=stats.no_match_total,
                fail_loud=stats.fail_loud_total,
                llm_cost=round(stats.total_cost_usd, 4),
                errors=len(stats.errors),
            )

        print_summary(all_stats, v7_before, mode=args.mode)

    finally:
        await pool.close()


def main() -> None:
    parser = argparse.ArgumentParser(description="Backfill source_evidences for pre-ADR-015 books")
    parser.add_argument(
        "--book",
        nargs="+",
        required=True,
        help="Book slug(s) to backfill",
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
        choices=["backfill", "reextract"],
        default="backfill",
        help="backfill: reuse llm_calls; reextract: re-run NER via gateway",
    )

    args = parser.parse_args()
    if args.execute:
        args.dry_run = False

    asyncio.run(async_main(args))


if __name__ == "__main__":
    main()
