"""Apply identity resolution merges (non-dry-run).

Usage:
    cd services/pipeline
    uv run python scripts/apply_resolve.py
"""

from __future__ import annotations

import asyncio
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "src"))

import asyncpg

from huadian_pipeline.resolve import (
    apply_merges,
    generate_dry_run_report,
    resolve_identities,
)


async def main() -> None:
    db_url = os.environ.get(
        "DATABASE_URL",
        "postgresql://huadian:huadian_dev@localhost:5433/huadian",
    )
    pool = await asyncpg.create_pool(db_url, min_size=1, max_size=2)
    assert pool is not None

    try:
        result = await resolve_identities(pool)

        # Print report before applying
        report = generate_dry_run_report(result)
        print(report)
        print()

        # Apply for real
        summary = await apply_merges(pool, result, dry_run=False)
        print("=== APPLIED ===")
        print(f"run_id:              {summary['run_id']}")
        print(f"groups:              {summary['groups']}")
        print(f"persons_soft_deleted: {summary['persons_soft_deleted']}")
        print(f"log_rows_inserted:   {summary['log_rows_inserted']}")
        print(f"errors:              {summary['errors']}")
    finally:
        await pool.close()


if __name__ == "__main__":
    asyncio.run(main())
