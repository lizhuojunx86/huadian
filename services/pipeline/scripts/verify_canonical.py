"""Verify new select_canonical() against all existing merge groups in DB.

T-P0-013 S-3: For each merge pair in person_merge_log, load full snapshots
and check whether the new canonical selection matches the current DB state.

Usage:
    cd services/pipeline
    uv run python scripts/verify_canonical.py
"""

from __future__ import annotations

import asyncio
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "src"))

import asyncpg

from huadian_pipeline.resolve import select_canonical
from huadian_pipeline.resolve_rules import PersonSnapshot


async def main() -> None:
    db_url = os.environ.get(
        "DATABASE_URL",
        "postgresql://huadian:huadian_dev@localhost:5433/huadian",
    )
    pool = await asyncpg.create_pool(db_url, min_size=1, max_size=2)
    assert pool is not None

    try:
        async with pool.acquire() as conn:
            # Get all active merge groups from merge_log
            log_rows = await conn.fetch(
                """
                SELECT
                    ml.canonical_id::text,
                    ml.merged_id::text,
                    c.name->>'zh-Hans' AS canonical_name,
                    c.slug AS canonical_slug,
                    m.name->>'zh-Hans' AS merged_name,
                    m.slug AS merged_slug,
                    ml.merge_rule
                FROM person_merge_log ml
                JOIN persons c ON c.id = ml.canonical_id
                JOIN persons m ON m.id = ml.merged_id
                WHERE ml.reverted_at IS NULL
                ORDER BY ml.merged_at
                """
            )

            changed = 0
            for row in log_rows:
                # Build PersonSnapshot for both canonical and merged person
                persons: list[PersonSnapshot] = []
                for pid, pname, pslug in [
                    (row["canonical_id"], row["canonical_name"], row["canonical_slug"]),
                    (row["merged_id"], row["merged_name"], row["merged_slug"]),
                ]:
                    name_rows = await conn.fetch(
                        "SELECT name FROM person_names WHERE person_id = $1::uuid",
                        pid,
                    )
                    sf = {r["name"] for r in name_rows}
                    p_row = await conn.fetchrow(
                        "SELECT COALESCE(dynasty, '') AS dynasty, "
                        "created_at::text FROM persons WHERE id = $1::uuid",
                        pid,
                    )
                    persons.append(
                        PersonSnapshot(
                            id=pid,
                            name=pname,
                            slug=pslug,
                            dynasty=p_row["dynasty"],
                            surface_forms=sf,
                            identity_notes=[],
                            created_at=p_row["created_at"],
                        )
                    )

                new_canonical = select_canonical(persons)
                old_canonical_name = row["canonical_name"]
                if new_canonical.name == old_canonical_name:
                    status = "✅"
                else:
                    status = f"🔄 CHANGED → {new_canonical.name}"
                    changed += 1

                print(
                    f"  {row['merge_rule']:4s}  "
                    f"old_canonical={old_canonical_name:6s}  "
                    f"merged={row['merged_name']:6s}  "
                    f"{status}"
                )

            print()
            print(f"Total: {len(log_rows)} merges, {changed} canonical changes needed")
    finally:
        await pool.close()


if __name__ == "__main__":
    asyncio.run(main())
