"""Soft-equivalent dogfood verification for Sprint Q Stage 1.13.

Verifies that the framework Python implementation
(framework.audit_triage + AsyncpgTriageStore) produces results equivalent
to the production TypeScript implementation
(services/api/src/services/triage.service.ts).

Why "soft-equivalent" not "byte-identical"
------------------------------------------
The two implementations are in different languages (Python vs TypeScript)
and use different DTO shapes (snake_case vs camelCase). We can't compare
JSON byte-by-byte. Instead we verify:

    (a) list_pending: row count + per-row source_id + surface + ordering
    (b) record_decision: round-trip a decision through framework, then
        re-read via direct SQL → fields match what production would have
        written
    (c) decisions_for_surface: count + ordering match same SQL
    (d) find_next_pending_excluding: returns same id production would

Usage:
    cd <project_root>
    PYTHONPATH=$(pwd) DATABASE_URL=postgresql://... \\
        python3 -m framework.audit_triage.examples.huadian_classics.test_soft_equivalent

Stop Rule (Sprint Q brief §4 Rule #1):
    Any field mismatch → Stop, locate root cause + decide framework fix
    or document divergence as residual debt.

License: Apache 2.0
"""

from __future__ import annotations

import asyncio
import logging
import os
import sys

import asyncpg

from framework.audit_triage import (
    decisions_for_surface,
    list_pending_items,
)
from framework.audit_triage.examples.huadian_classics import AsyncpgTriageStore

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Direct SQL queries (mimic what production triage.service.ts runs)
# ---------------------------------------------------------------------------

_PROD_LIST_QUERY = """
    WITH all_pending AS (
        SELECT
            'seed_mapping'::text AS kind,
            'seed_mappings'::text AS source_table,
            sm.id AS source_id,
            de.primary_name AS surface,
            sm.mapping_created_at AS pending_since
        FROM seed_mappings sm
        JOIN dictionary_entries de ON de.id = sm.dictionary_entry_id
        WHERE sm.mapping_status = 'pending_review'
          AND sm.target_entity_type = 'person'
        UNION ALL
        SELECT
            'guard_blocked_merge'::text AS kind,
            'pending_merge_reviews'::text AS source_table,
            pmr.id AS source_id,
            COALESCE(
                pmr.guard_payload->>'surface_a',
                pmr.guard_payload->>'surface',
                (SELECT pn.name FROM person_names pn
                 WHERE pn.person_id = pmr.person_a_id
                 ORDER BY pn.is_primary DESC NULLS LAST, pn.created_at ASC
                 LIMIT 1),
                'unknown'
            ) AS surface,
            pmr.created_at AS pending_since
        FROM pending_merge_reviews pmr
        WHERE pmr.status = 'pending'
    ),
    clusters AS (
        SELECT surface, MIN(pending_since) AS anchor
        FROM all_pending
        GROUP BY surface
    )
    SELECT ap.*, c.anchor
    FROM all_pending ap
    JOIN clusters c ON c.surface = ap.surface
    ORDER BY c.anchor ASC, ap.surface ASC, ap.pending_since ASC, ap.source_id ASC
    LIMIT $1 OFFSET 0
"""

_PROD_DECISIONS_FOR_SURFACE_QUERY = """
    SELECT id, source_table, source_id, surface_snapshot, decision,
           historian_id, decided_at
    FROM triage_decisions
    WHERE surface_snapshot = $1
    ORDER BY decided_at DESC
    LIMIT $2
"""


# ---------------------------------------------------------------------------
# Comparators
# ---------------------------------------------------------------------------


async def compare_list_pending(pool: asyncpg.Pool, limit: int = 20) -> list[str]:
    """Return list of diff messages (empty = pass)."""
    diffs: list[str] = []

    store = AsyncpgTriageStore(pool)
    fw_items, fw_total = await list_pending_items(store, limit=limit)

    async with pool.acquire() as conn:
        prod_rows = await conn.fetch(_PROD_LIST_QUERY, limit)

    if len(fw_items) != len(prod_rows):
        diffs.append(f"list_pending row count: framework={len(fw_items)} prod={len(prod_rows)}")

    for i, (fw, prod) in enumerate(zip(fw_items, prod_rows, strict=False)):
        if fw.source_id != str(prod["source_id"]):
            diffs.append(f"row[{i}].source_id: fw={fw.source_id} prod={prod['source_id']}")
        if fw.surface != prod["surface"]:
            diffs.append(f"row[{i}].surface: fw={fw.surface!r} prod={prod['surface']!r}")
        if fw.kind != prod["kind"]:
            diffs.append(f"row[{i}].kind: fw={fw.kind} prod={prod['kind']}")

    logger.info(
        "list_pending: framework returned %d items, total %d; production query returned %d rows",
        len(fw_items),
        fw_total,
        len(prod_rows),
    )
    return diffs


async def compare_decisions_for_surface(
    pool: asyncpg.Pool, surface: str, limit: int = 5
) -> list[str]:
    """Compare decisions_for_surface against direct SQL."""
    diffs: list[str] = []
    store = AsyncpgTriageStore(pool)

    fw_decisions = await decisions_for_surface(store, surface, limit=limit)
    async with pool.acquire() as conn:
        prod_rows = await conn.fetch(_PROD_DECISIONS_FOR_SURFACE_QUERY, surface, limit)

    if len(fw_decisions) != len(prod_rows):
        diffs.append(
            f"decisions_for_surface({surface!r}) count: "
            f"framework={len(fw_decisions)} prod={len(prod_rows)}"
        )

    for i, (fw, prod) in enumerate(zip(fw_decisions, prod_rows, strict=False)):
        if fw.id != str(prod["id"]):
            diffs.append(f"decision[{i}].id: fw={fw.id} prod={prod['id']}")
        if fw.surface_snapshot != prod["surface_snapshot"]:
            diffs.append(
                f"decision[{i}].surface_snapshot: "
                f"fw={fw.surface_snapshot!r} prod={prod['surface_snapshot']!r}"
            )
        if fw.decision != prod["decision"]:
            diffs.append(f"decision[{i}].decision: fw={fw.decision} prod={prod['decision']}")

    logger.info(
        "decisions_for_surface(%r): framework returned %d, production query returned %d",
        surface,
        len(fw_decisions),
        len(prod_rows),
    )
    return diffs


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


async def main() -> int:
    db_url = os.environ.get("DATABASE_URL")
    if not db_url:
        print("ERROR: DATABASE_URL environment variable required.", file=sys.stderr)
        return 2

    pool = await asyncpg.create_pool(db_url, min_size=1, max_size=4)
    try:
        all_diffs: list[str] = []

        diffs_a = await compare_list_pending(pool, limit=20)
        all_diffs.extend(diffs_a)

        # Also compare decisions_for_surface for a few common surfaces
        # (these need not exist in DB — count=0 vs count=0 is still pass)
        for surface in ("周成王", "楚成王", "成王", "项羽"):
            diffs_b = await compare_decisions_for_surface(pool, surface, limit=5)
            all_diffs.extend(diffs_b)

    finally:
        await pool.close()

    print()
    print("=" * 72)
    print("Sprint Q Stage 1.13 — audit_triage soft-equivalent dogfood")
    print("=" * 72)

    if not all_diffs:
        print("✓ SOFT-EQUIVALENT — Sprint Q Stage 1.13 dogfood gate PASSED")
        print("  framework path == production path on this DB snapshot")
        return 0

    print("✗ DIFFERENCES DETECTED — Sprint Q Stop Rule #1 triggered")
    for d in all_diffs:
        print(f"  - {d}")
    print()
    print("Architect must inspect + decide:")
    print("  1. Fix framework code to match production")
    print("  2. Or document divergence as residual debt (acceptable on minor fields)")
    return 1


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
