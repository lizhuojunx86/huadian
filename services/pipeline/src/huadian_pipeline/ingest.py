"""Ingest module — loads source text into books + raw_texts tables.

Handles:
  1. Upsert book record (by slug)
  2. Insert raw_text paragraphs (by source_id + paragraph_no)
  3. Create pipeline_run record
"""

from __future__ import annotations

import logging
import uuid
from dataclasses import dataclass
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    import asyncpg

from .sources.ctext import ChapterData

logger = logging.getLogger(__name__)


@dataclass(slots=True)
class IngestResult:
    """Result of an ingest operation."""

    book_id: str
    book_slug: str
    chapter: str
    paragraphs_inserted: int
    paragraphs_skipped: int
    pipeline_run_id: str


async def ingest_chapter(pool: asyncpg.Pool, chapter: ChapterData) -> IngestResult:
    """Ingest a chapter into the database.

    Upserts the book, inserts raw_text paragraphs (skips duplicates),
    and records a pipeline_run.
    """
    async with pool.acquire() as conn, conn.transaction():
        # 1. Upsert book
        book_id = await _upsert_book(conn, chapter)

        # 2. Insert raw_texts
        inserted, skipped = await _insert_raw_texts(conn, book_id, chapter)

        # 3. Record pipeline_run
        run_id = await _record_pipeline_run(
            conn,
            book_id=book_id,
            step="ingestion",
            status="success" if inserted > 0 else "skipped",
        )

        logger.info(
            "Ingested %s: %d paragraphs inserted, %d skipped (book_id=%s)",
            chapter.title_zh,
            inserted,
            skipped,
            book_id,
        )

        return IngestResult(
            book_id=book_id,
            book_slug=chapter.book_slug,
            chapter=chapter.title_zh,
            paragraphs_inserted=inserted,
            paragraphs_skipped=skipped,
            pipeline_run_id=run_id,
        )


async def _upsert_book(conn: Any, chapter: ChapterData) -> str:
    """Upsert a book record, returning the book ID."""
    book_slug = f"{chapter.book_slug}-{chapter.chapter_slug}"
    title_json = {
        "zh-Hans": f"{chapter.book_title_zh}·{chapter.title_zh}",
    }
    if chapter.book_title_en:
        title_json["en"] = f"{chapter.book_title_en} - {chapter.title_en}"

    metadata = {
        "author": chapter.author,
        "volume": chapter.volume,
        "source_url": chapter.source_url,
        **chapter.extra_metadata,
    }

    row = await conn.fetchrow(
        """
        INSERT INTO books (id, title, dynasty, genre, credibility_tier, license, slug, metadata)
        VALUES ($1, $2::jsonb, $3, $4::book_genre, 'primary_official', 'public_domain', $5, $6::jsonb)
        ON CONFLICT (slug) DO UPDATE SET
            title = EXCLUDED.title,
            updated_at = NOW()
        RETURNING id
        """,
        str(uuid.uuid4()),
        _to_json(title_json),
        chapter.dynasty,
        chapter.genre,
        book_slug,
        _to_json(metadata),
    )
    assert row is not None, "INSERT ... RETURNING should always return a row"
    return str(row["id"])


async def _insert_raw_texts(
    conn: Any,
    book_id: str,
    chapter: ChapterData,
) -> tuple[int, int]:
    """Insert raw_text paragraphs, skipping duplicates. Returns (inserted, skipped)."""
    inserted = 0
    skipped = 0

    for para in chapter.paragraphs:
        # Check for existing paragraph with same source_id + paragraph_no
        existing = await conn.fetchval(
            """
            SELECT id FROM raw_texts
            WHERE source_id = $1 AND paragraph_no = $2 AND deleted_at IS NULL
            """,
            para.source_id,
            para.paragraph_no,
        )
        if existing:
            skipped += 1
            continue

        await conn.execute(
            """
            INSERT INTO raw_texts (id, source_id, book_id, volume, chapter, paragraph_no, raw_text, text_original)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            """,
            str(uuid.uuid4()),
            para.source_id,
            book_id,
            para.volume,
            para.chapter,
            para.paragraph_no,
            para.raw_text,
            para.text_original,
        )
        inserted += 1

    return inserted, skipped


async def _record_pipeline_run(
    conn: Any,
    *,
    book_id: str,
    step: str,
    status: str,
    paragraph_id: str | None = None,
    prompt_version: str | None = None,
    error: str | None = None,
) -> str:
    """Insert a pipeline_runs record."""
    run_id = str(uuid.uuid4())
    await conn.execute(
        """
        INSERT INTO pipeline_runs (id, book_id, paragraph_id, step, status, prompt_version, started_at, ended_at, error)
        VALUES ($1, $2, $3, $4::pipeline_step, $5::pipeline_status, $6, NOW(), NOW(), $7)
        """,
        run_id,
        book_id,
        paragraph_id,
        step,
        status,
        prompt_version,
        error,
    )
    return run_id


def _to_json(obj: dict[str, Any]) -> str:
    """Convert dict to JSON string for asyncpg JSONB parameter."""
    import json

    return json.dumps(obj, ensure_ascii=False)
