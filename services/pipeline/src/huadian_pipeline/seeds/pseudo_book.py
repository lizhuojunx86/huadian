"""Pseudo-book helper for Wikidata seed source_evidences.

Creates a placeholder book + raw_text entry to anchor source_evidences
rows with provenance_tier='seed_dictionary'. Idempotent — safe to call
multiple times with the same dump_version.

ADR: ADR-015 §6.1 / T-P0-025 Stage 2
"""

from __future__ import annotations

import json
import logging
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    import asyncpg

logger = logging.getLogger(__name__)


async def ensure_wikidata_pseudo_book(
    conn: asyncpg.Connection,
    dump_version: str,
) -> tuple[str, str]:
    """Ensure a pseudo-book and raw_text exist for Wikidata seed evidence.

    Args:
        conn: Active DB connection (must be inside a transaction).
        dump_version: Version string, e.g. '20260422'.

    Returns:
        Tuple of (book_id, raw_text_id) as strings.
    """
    slug = f"wikidata-dump-{dump_version}"
    title = json.dumps(
        {"zh-Hans": f"Wikidata dump {dump_version}", "en": f"Wikidata dump {dump_version}"},
        ensure_ascii=False,
    )

    # Upsert book
    book_id = await conn.fetchval(
        """
        INSERT INTO books (slug, title, credibility_tier, license, genre, metadata)
        VALUES ($1, $2::jsonb, 'tertiary_reference', 'CC0', 'encyclopedia',
                '{"type": "wikidata_seed_pseudo_book"}'::jsonb)
        ON CONFLICT (slug) DO UPDATE SET slug = books.slug
        RETURNING id
        """,
        slug,
        title,
    )

    # Upsert raw_text (one per dump version)
    source_id = f"wikidata-seed-{dump_version}"
    raw_text_id = await conn.fetchval(
        """
        INSERT INTO raw_texts (source_id, book_id, raw_text, chapter)
        VALUES ($1, $2, $3, 'seed')
        ON CONFLICT ON CONSTRAINT raw_texts_pkey DO NOTHING
        RETURNING id
        """,
        source_id,
        book_id,
        f"Wikidata SPARQL seed extraction, dump version {dump_version}",
    )

    if raw_text_id is None:
        # Already existed, fetch it
        raw_text_id = await conn.fetchval(
            "SELECT id FROM raw_texts WHERE source_id = $1 AND book_id = $2",
            source_id,
            book_id,
        )

    logger.info("Pseudo-book: slug=%s book_id=%s raw_text_id=%s", slug, book_id, raw_text_id)
    return str(book_id), str(raw_text_id)
