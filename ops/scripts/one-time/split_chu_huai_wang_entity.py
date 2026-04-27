"""T-P0-031 Stage 3 — 楚怀王 entity-split (ADR-026 first application).

Background:
  Sprint G T-P0-006-δ historian review (commit fdfb7cb §2.2 Group 13)
  found that the "楚怀王" entity is shared across two historically distinct
  persons: 熊槐 (战国楚怀王, died -296 in Qin) and 熊心 (秦末楚怀王, alive
  -208 to -206). Sprint G G13 sub-merges already produced the canonical
  "熊心" entity (48061967-7058-47d2-9657-15c57a0b866b). This script
  performs the mention-level redirect / split_for_safety on the remaining
  two ambiguous person_names rows on the source entity (777778a4 楚怀王).

Historian ruling (commit a117fbf §5):
  - 8fb2afc3 (楚怀王 / primary / 秦本纪 §65)        → keep on source
  - 7a68ff90 (怀王   / posthumous / 项羽本纪 §6)    → split_for_safety
  - 2afc61fc (楚王   / nickname / 项羽本纪 §6)      → split_for_safety

ADR-026 protocol (architect ACK 2026-04-27):
  - Decision A: split_for_safety = source row kept + target INSERT (shared SE)
  - Option X: entity_split_log records data-change rows only (keep-case
    NOT logged; lives in historian commit hash)
  - 4 gates + dual sign-off (architect commit hash + historian commit hash)
  - Single transaction; V1-V11 invariant run after COMMIT

Two modes:
  --dry-run: BEGIN; INSERT ... RETURNING *; ROLLBACK; — for architect read.
  --apply : BEGIN; INSERT ...; INSERT entity_split_log; COMMIT;

Stop Rule (S4.5): RETURNING person_names INSERT count != 2
              OR  RETURNING entity_split_log INSERT count != 2
              -> abort, report architect.

Usage:
    cd services/pipeline  # for env / DSN, or set DATABASE_URL
    uv run python ../../ops/scripts/one-time/split_chu_huai_wang_entity.py --dry-run
    uv run python ../../ops/scripts/one-time/split_chu_huai_wang_entity.py --apply \
        --pg-dump-anchor "ops/rollback/pre-t-p0-031-stage-3-<timestamp>.dump:<sha256-12>" \
        --architect-ack-ref "<commit-hash-of-S4.6>"
"""

from __future__ import annotations

import argparse
import asyncio
import os
import sys
import uuid
from dataclasses import dataclass

import asyncpg

# ── Constants ─────────────────────────────────────────────────────────────

# Deterministic run_id for this entity-split run (audit anchor).
# UUID format: a117fbf prefix (historian ruling commit) + 0031 (task) + 0003 (stage)
RUN_ID = "a117fbf0-0031-4000-8000-000000000003"

APPLIED_BY = "pipeline:t-p0-031-stage-3"
HISTORIAN_RULING_REF = "a117fbf §5"  # commit a117fbf, section 5

SOURCE_PERSON_ID = "777778a4-bc13-4f91-b2c3-6f8efd1b0e72"  # 楚怀王 (战国, 熊槐)
TARGET_PERSON_ID = "48061967-7058-47d2-9657-15c57a0b866b"  # 熊心 (秦末)


@dataclass
class SplitMention:
    """One person_names row to split_for_safety."""

    source_pn_id: str  # the existing person_names row on source entity
    name: str  # surface form (snapshot for audit)
    name_type: str  # snapshot for audit
    source_evidence_id: str  # SE shared between source row and INSERTed target row
    notes: str  # human-readable justification


# Per historian ruling commit a117fbf §5
SPLIT_MENTIONS: list[SplitMention] = [
    SplitMention(
        source_pn_id="7a68ff90-454c-4878-b674-368a45b63cb8",
        name="怀王",
        name_type="posthumous",
        source_evidence_id="73e39311-dfa7-4968-a608-b6a65e587d8f",
        notes=(
            "split_for_safety per historian a117fbf §4.1 §5: "
            "SE 73e39311 (项羽本纪 §6) contains both 熊槐 (sentence 1: '自怀王入秦不反') "
            "and 熊心 (sentence 4: '与怀王都盱台') references. INSERT copy on 熊心 entity "
            "to preserve both entities' alias coverage."
        ),
    ),
    SplitMention(
        source_pn_id="2afc61fc-4efe-4621-aac3-516125620490",
        name="楚王",
        name_type="nickname",
        source_evidence_id="73e39311-dfa7-4968-a608-b6a65e587d8f",
        notes=(
            "split_for_safety + NER QC flag per historian a117fbf §4.2 §5 §6.2: "
            "surface '楚王' does NOT appear as independent token in raw_text 84d1087b "
            "(NER half-hallucination from '楚……王' compound forms). Conservative split: "
            "keep on source, INSERT on target. Future cleanup via T-P2-005 NER v1-r6 "
            "+ corpus-wide '楚王' surface audit."
        ),
    ),
]

assert len(SPLIT_MENTIONS) == 2, (
    f"Historian ruling fixed at 2 split_for_safety; got {len(SPLIT_MENTIONS)}"
)


# ── DB operations ────────────────────────────────────────────────────────


async def fetch_source_row(conn: asyncpg.Connection, pn_id: str) -> asyncpg.Record | None:
    """Read the source person_names row; used for snapshot validation."""
    return await conn.fetchrow(
        """
        SELECT id, person_id, name, name_pinyin, name_type, start_year, end_year,
               is_primary, source_evidence_id
          FROM person_names
         WHERE id = $1
        """,
        uuid.UUID(pn_id),
    )


async def assert_no_unique_conflict(
    conn: asyncpg.Connection, target_person_id: str, name: str
) -> None:
    """Ensure target entity does not already carry this surface
    (uq_person_names_person_name)."""
    row = await conn.fetchrow(
        "SELECT id FROM person_names WHERE person_id = $1 AND name = $2",
        uuid.UUID(target_person_id),
        name,
    )
    if row is not None:
        raise RuntimeError(
            f"unique conflict: target person {target_person_id} already has name='{name}' "
            f"(existing pn_id={row['id']})"
        )


async def perform_split(
    conn: asyncpg.Connection,
    *,
    architect_ack_ref: str,
    pg_dump_anchor: str,
) -> tuple[list[asyncpg.Record], list[asyncpg.Record]]:
    """Execute the split inside an open transaction.

    Returns (person_names INSERT rows, entity_split_log INSERT rows).
    Caller decides COMMIT or ROLLBACK.
    """
    inserted_pn: list[asyncpg.Record] = []
    inserted_log: list[asyncpg.Record] = []

    for mention in SPLIT_MENTIONS:
        source_row = await fetch_source_row(conn, mention.source_pn_id)
        if source_row is None:
            raise RuntimeError(f"source person_names row not found: {mention.source_pn_id}")
        if str(source_row["person_id"]) != SOURCE_PERSON_ID:
            raise RuntimeError(
                f"source row {mention.source_pn_id} is not on expected source entity "
                f"{SOURCE_PERSON_ID}; found {source_row['person_id']}"
            )
        if source_row["name"] != mention.name:
            raise RuntimeError(
                f"source row name mismatch: expected '{mention.name}', got '{source_row['name']}'"
            )
        if source_row["name_type"] != mention.name_type:
            raise RuntimeError(
                f"source row name_type mismatch: expected '{mention.name_type}', "
                f"got '{source_row['name_type']}'"
            )
        if str(source_row["source_evidence_id"]) != mention.source_evidence_id:
            raise RuntimeError(
                f"source row SE mismatch: expected '{mention.source_evidence_id}', "
                f"got '{source_row['source_evidence_id']}'"
            )

        await assert_no_unique_conflict(conn, TARGET_PERSON_ID, mention.name)

        # INSERT split_for_safety row on target entity (shares SE with source).
        new_pn = await conn.fetchrow(
            """
            INSERT INTO person_names (
                person_id, name, name_pinyin, name_type,
                start_year, end_year, is_primary, source_evidence_id
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            RETURNING id, person_id, name, name_type, is_primary,
                      source_evidence_id, created_at
            """,
            uuid.UUID(TARGET_PERSON_ID),
            mention.name,
            source_row["name_pinyin"],
            mention.name_type,
            source_row["start_year"],
            source_row["end_year"],
            False,  # split_for_safety copy is never primary on target
            uuid.UUID(mention.source_evidence_id),
        )
        assert new_pn is not None
        inserted_pn.append(new_pn)

        # INSERT audit row in entity_split_log.
        log_row = await conn.fetchrow(
            """
            INSERT INTO entity_split_log (
                run_id, operation,
                source_person_id, target_person_id, person_name_id,
                redirected_name, redirected_name_type, source_evidence_id,
                historian_ruling_ref, architect_ack_ref, pg_dump_anchor,
                applied_by, notes
            ) VALUES ($1, 'split_for_safety',
                      $2, $3, $4,
                      $5, $6, $7,
                      $8, $9, $10,
                      $11, $12)
            RETURNING id, run_id, operation, source_person_id, target_person_id,
                      person_name_id, redirected_name, redirected_name_type,
                      source_evidence_id, applied_at
            """,
            uuid.UUID(RUN_ID),
            uuid.UUID(SOURCE_PERSON_ID),
            uuid.UUID(TARGET_PERSON_ID),
            new_pn["id"],
            mention.name,
            mention.name_type,
            uuid.UUID(mention.source_evidence_id),
            HISTORIAN_RULING_REF,
            architect_ack_ref,
            pg_dump_anchor,
            APPLIED_BY,
            mention.notes,
        )
        assert log_row is not None
        inserted_log.append(log_row)

    return inserted_pn, inserted_log


# ── Reporting ────────────────────────────────────────────────────────────


def format_pn_row(row: asyncpg.Record) -> str:
    return (
        f"  - id={row['id']} person_id={row['person_id']} name='{row['name']}' "
        f"name_type={row['name_type']} is_primary={row['is_primary']} "
        f"SE={row['source_evidence_id']}"
    )


def format_log_row(row: asyncpg.Record) -> str:
    return (
        f"  - id={row['id']} op={row['operation']} "
        f"source={row['source_person_id']} → target={row['target_person_id']} "
        f"pn_id={row['person_name_id']} name='{row['redirected_name']}' "
        f"type={row['redirected_name_type']} SE={row['source_evidence_id']}"
    )


def emit_returning_report(
    inserted_pn: list[asyncpg.Record], inserted_log: list[asyncpg.Record]
) -> None:
    print("=" * 72)
    print("RETURNING — person_names INSERTs")
    print("=" * 72)
    for row in inserted_pn:
        print(format_pn_row(row))
    print(f"  count: {len(inserted_pn)}")

    print()
    print("=" * 72)
    print("RETURNING — entity_split_log INSERTs")
    print("=" * 72)
    for row in inserted_log:
        print(format_log_row(row))
    print(f"  count: {len(inserted_log)}")

    print()
    print("Stop Rule (S4.5):")
    pn_ok = len(inserted_pn) == 2
    log_ok = len(inserted_log) == 2
    print(f"  person_names INSERT count == 2: {pn_ok}")
    print(f"  entity_split_log INSERT count == 2: {log_ok}")
    print(f"  → {'PASS' if pn_ok and log_ok else 'FAIL — abort, report architect'}")


# ── Main ─────────────────────────────────────────────────────────────────


async def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="T-P0-031 楚怀王 entity-split")
    parser.add_argument("--dry-run", action="store_true", help="ROLLBACK after RETURNING")
    parser.add_argument("--apply", action="store_true", help="COMMIT (irreversible)")
    parser.add_argument(
        "--pg-dump-anchor",
        default="dry-run-no-anchor",
        help="pg_dump file path + sha256 first 12 chars (required for --apply)",
    )
    parser.add_argument(
        "--architect-ack-ref",
        default="dry-run-pending-ack",
        help="architect ACK commit hash / PR ref (required for --apply)",
    )
    args = parser.parse_args(argv)

    if args.dry_run == args.apply:
        parser.error("exactly one of --dry-run or --apply is required")

    if args.apply:
        if args.pg_dump_anchor == "dry-run-no-anchor":
            parser.error("--apply requires --pg-dump-anchor")
        if args.architect_ack_ref == "dry-run-pending-ack":
            parser.error("--apply requires --architect-ack-ref")

    db_url = os.environ.get(
        "DATABASE_URL",
        "postgresql://huadian:huadian_dev@localhost:5433/huadian",
    )
    pool = await asyncpg.create_pool(db_url, min_size=1, max_size=2)
    assert pool is not None

    exit_code = 0
    try:
        async with pool.acquire() as conn:
            tx = conn.transaction()
            await tx.start()
            try:
                inserted_pn, inserted_log = await perform_split(
                    conn,
                    architect_ack_ref=args.architect_ack_ref,
                    pg_dump_anchor=args.pg_dump_anchor,
                )
                emit_returning_report(inserted_pn, inserted_log)

                # Stop Rule check (S4.5).
                if len(inserted_pn) != 2 or len(inserted_log) != 2:
                    print("\nABORT: Stop Rule triggered. Rolling back.")
                    await tx.rollback()
                    return 2

                if args.apply:
                    await tx.commit()
                    print("\nCOMMITTED. Run V1-V11 invariants now.")
                else:
                    await tx.rollback()
                    print("\nDRY-RUN: ROLLBACK done. No data written.")
            except Exception:
                await tx.rollback()
                raise
    finally:
        await pool.close()

    return exit_code


if __name__ == "__main__":
    sys.exit(asyncio.run(main(sys.argv[1:])))
