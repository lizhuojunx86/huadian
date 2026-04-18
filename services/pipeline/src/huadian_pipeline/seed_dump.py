"""Seed dump utility — exports extracted data as reproducible SQL.

Output format:
  - Stable ordering by slug
  - Per-INSERT comments with chunk reference
  - File header with prompt version, model, extraction time, total cost
"""

from __future__ import annotations

import json
import logging
from datetime import UTC, datetime
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    import asyncpg

logger = logging.getLogger(__name__)


async def dump_seed_sql(
    pool: asyncpg.Pool,
    *,
    book_id: str,
    output_path: str,
    prompt_version: str = "",
    model: str = "",
    total_cost_usd: float = 0.0,
) -> int:
    """Dump persons + person_names for a book as SQL INSERT statements.

    Returns the number of persons dumped.
    """
    async with pool.acquire() as conn:
        # Fetch persons linked via raw_texts → extractions_history,
        # or just all persons (for Phase 0, we dump all non-deleted)
        persons = await conn.fetch(
            """
            SELECT id, slug, name, dynasty, reality_status, provenance_tier,
                   birth_date, death_date, biography, created_at
            FROM persons
            WHERE deleted_at IS NULL
            ORDER BY slug
            """
        )

        if not persons:
            logger.warning("No persons found to dump")
            return 0

        lines: list[str] = []

        # Header
        now = datetime.now(UTC).isoformat()
        lines.append("-- HuaDian Pipeline Seed Dump")
        lines.append(f"-- Generated: {now}")
        lines.append(f"-- Book ID: {book_id}")
        lines.append(f"-- Prompt: {prompt_version}")
        lines.append(f"-- Model: {model}")
        lines.append(f"-- Total cost: ${total_cost_usd:.4f}")
        lines.append(f"-- Persons: {len(persons)}")
        lines.append("")
        lines.append("BEGIN;")
        lines.append("")

        # Persons
        lines.append("-- ============================================================")
        lines.append("-- persons")
        lines.append("-- ============================================================")
        lines.append("")

        for p in persons:
            slug = p["slug"]
            lines.append(f"-- Person: {_json_field(p['name'], 'zh-Hans')} ({slug})")
            lines.append(
                f"INSERT INTO persons (id, slug, name, dynasty, reality_status, "
                f"provenance_tier, birth_date, death_date, biography) VALUES ("
                f"{_sql_str(str(p['id']))}, "
                f"{_sql_str(slug)}, "
                f"{_sql_jsonb(p['name'])}, "
                f"{_sql_str(p['dynasty'])}, "
                f"{_sql_str(p['reality_status'])}, "
                f"{_sql_str(p['provenance_tier'])}, "
                f"{_sql_jsonb(p['birth_date'])}, "
                f"{_sql_jsonb(p['death_date'])}, "
                f"{_sql_jsonb(p['biography'])}"
                f") ON CONFLICT (slug) DO NOTHING;"
            )
            lines.append("")

        # Person names
        lines.append("-- ============================================================")
        lines.append("-- person_names")
        lines.append("-- ============================================================")
        lines.append("")

        for p in persons:
            person_id = str(p["id"])
            slug = p["slug"]
            names = await conn.fetch(
                """
                SELECT id, name, name_pinyin, name_type, is_primary,
                       start_year, end_year
                FROM person_names
                WHERE person_id = $1
                ORDER BY is_primary DESC NULLS LAST, name
                """,
                p["id"],
            )

            for n in names:
                primary_marker = " [primary]" if n["is_primary"] else ""
                lines.append(f"-- Name for {slug}: {n['name']}{primary_marker}")
                lines.append(
                    f"INSERT INTO person_names (id, person_id, name, name_pinyin, "
                    f"name_type, is_primary, start_year, end_year) VALUES ("
                    f"{_sql_str(str(n['id']))}, "
                    f"{_sql_str(person_id)}, "
                    f"{_sql_str(n['name'])}, "
                    f"{_sql_str(n['name_pinyin'])}, "
                    f"{_sql_str(n['name_type'])}, "
                    f"{_sql_bool(n['is_primary'])}, "
                    f"{_sql_int(n['start_year'])}, "
                    f"{_sql_int(n['end_year'])}"
                    f") ON CONFLICT DO NOTHING;"
                )
            lines.append("")

        lines.append("COMMIT;")
        lines.append("")

        # Write to file
        import pathlib

        pathlib.Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w", encoding="utf-8") as f:
            f.write("\n".join(lines))

        logger.info("Dumped %d persons to %s", len(persons), output_path)
        return len(persons)


def _sql_str(val: str | None) -> str:
    """Format a string value for SQL."""
    if val is None:
        return "NULL"
    escaped = val.replace("'", "''")
    return f"'{escaped}'"


def _sql_jsonb(val: object) -> str:
    """Format a JSONB value for SQL."""
    if val is None:
        return "NULL"
    if isinstance(val, str):
        escaped = val.replace("'", "''")
        return f"'{escaped}'::jsonb"
    s = json.dumps(val, ensure_ascii=False).replace("'", "''")
    return f"'{s}'::jsonb"


def _sql_bool(val: bool | None) -> str:
    if val is None:
        return "NULL"
    return "true" if val else "false"


def _sql_int(val: int | None) -> str:
    if val is None:
        return "NULL"
    return str(val)


def _json_field(jsonb_val: object, key: str) -> str:
    """Extract a field from a JSONB dict, handling both dict and str types."""
    if isinstance(jsonb_val, dict):
        return str(jsonb_val.get(key, ""))
    if isinstance(jsonb_val, str):
        try:
            d = json.loads(jsonb_val)
            return str(d.get(key, ""))
        except (json.JSONDecodeError, AttributeError):
            return jsonb_val
    return str(jsonb_val) if jsonb_val else ""
