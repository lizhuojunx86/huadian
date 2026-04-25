"""T-P0-006-δ Stage 4 — Apply historian-approved merges for 项羽本纪.

7 approve groups + 2 split sub-merges (G13: 怀王→熊心, 义帝→熊心) = 9 soft-deletes.

Historian review: commit fdfb7cb
  docs/sprint-logs/T-P0-006-delta/historian-review-2026-04-25.md
Sprint G brief: docs/sprint-logs/sprint-g/stage-0-brief-2026-04-25.md
Dry-run report: Run ID b2d0d357-a256-433e-8da6-7b8c24cb1254
  docs/sprint-logs/T-P0-006-delta/dry-run-resolve-2026-04-25.md

Architect rulings (2026-04-26):
  - G13 canonical=熊心 accepted as historian domain override (personal-name vs posthumous-title
    convention; see Sprint G retro for precedent note).
  - pg_dump anchor at ops/rollback/pre-T-P0-006-delta-stage-4.sql

Each group runs in its own transaction. Failure in one group does NOT
roll back other groups (per task spec).

G15 (项籍→项羽) is the 2nd manual_textbook_fact case; per Sprint F retro,
the 3rd case triggers an ADR-014 addendum.
"""

from __future__ import annotations

import asyncio
import json
import os
import uuid
from dataclasses import dataclass
from datetime import UTC, datetime

import asyncpg

RUN_ID = "fdfb7cb0-0006-4000-d000-000000000004"  # deterministic UUID: historian commit prefix + delta + stage4
MERGED_BY = "pipeline:stage4-historian-fdfb7cb"
HISTORIAN_COMMIT = "fdfb7cb"
DRY_RUN_ID = "b2d0d357-a256-433e-8da6-7b8c24cb1254"


@dataclass
class MergePair:
    group: str  # e.g. "G2", "G13a"
    merged_id: str  # person to soft-delete
    canonical_id: str  # person to keep
    merge_rule: str  # e.g. "R1+historian-confirm"
    description: str  # human-readable


# fmt: off
MERGE_PAIRS: list[MergePair] = [
    # ── 7 Approve groups ──────────────────────────────────────────────

    # G2: 穆王(满) → 周穆王
    # Note: merged person has primary="满" (姬满) + posthumous="穆王".
    # R1 triggered via "穆王" surface overlap with "周穆王".
    MergePair("G2",  "2eba9b3e-b6e0-4a83-b355-0404342198ac", "ee05a798-3884-4c0e-b48a-12ae0010fb90", "R1+historian-confirm", "穆王(满) → 周穆王"),

    # G15: 项籍 → 项羽 (manual_textbook_fact — 2nd precedent)
    # 《史记·项羽本纪》: "项籍者，下相人也，字羽。" 名/字关系，无学术争议。
    # Precedent #2 (cf. T-P1-025 重耳→晋文公, commit bdb8941). 3rd case triggers ADR-014 addendum.
    MergePair("G15", "825190a0-4bc1-4373-a766-dbe93169ad30", "fcd414bd-ad3f-4316-b17b-071a76cf29b7", "manual_textbook_fact",  "项籍 → 项羽 (名→字, textbook fact)"),

    # G16: 武信君 → 项梁
    MergePair("G16", "5042f904-5453-4984-a188-c71d42acbcf9", "54f6c58e-3c65-4b5c-b498-1dc7f7453be7", "R1+historian-confirm", "武信君 → 项梁"),

    # G17: 陈王 → 陈胜
    MergePair("G17", "11be805b-04ac-4374-bcae-700a3e125c69", "dc2ed852-b882-42af-bd49-0b414799d1fb", "R1+historian-confirm", "陈王 → 陈胜"),

    # G19: 韩王成 → 韩成
    MergePair("G19", "bc6a0b7e-6814-4c75-a775-4e93bd09a156", "03aedfa1-3900-4158-b665-325574c3007f", "R1+historian-confirm", "韩王成 → 韩成"),

    # G20: 太公 → 刘太公
    MergePair("G20", "14783ef6-4fbb-4787-aab2-f175e0afb57d", "bf5120bb-7306-4fe2-9be9-13e0bd99aea6", "R1+historian-confirm", "太公 → 刘太公"),

    # G21: 吕后 → 吕雉
    MergePair("G21", "d79ce542-fd6e-4462-a2d0-5dcd2e74f62b", "1f2c5497-96af-4337-95a9-25e4cc5857d5", "R1+historian-confirm", "吕后 → 吕雉"),

    # ── 2 Split sub-merges (G13: 楚怀王 cluster) ──────────────────────
    # Only these 2 safe merges from G13 are applied in Stage 4.
    # The 楚怀王 entity-level split (熊槐 vs 熊心) is deferred to T-P0-031.
    # Canonical=熊心 is historian domain override (personal-name vs posthumous-title
    # convention; architect ACK 2026-04-26; see Sprint G retro §historian-override).

    # G13a: 怀王 → 熊心
    # 项羽本纪语境中"怀王"特指秦末楚怀王熊心（非战国楚怀王熊槐）
    MergePair("G13a", "d40d6efe-a716-456c-8663-ffbed32a0a36", "48061967-7058-47d2-9657-15c57a0b866b", "R1+historian-split-sub", "怀王 → 熊心 (G13 sub-merge)"),

    # G13b: 义帝 → 熊心
    # 《史记·项羽本纪》: "项王使人徙义帝……乃阴令……击杀之江中。" 义帝=熊心后期称号。
    MergePair("G13b", "2b953715-7745-4a1b-9792-3e63249cce15", "48061967-7058-47d2-9657-15c57a0b866b", "R1+historian-split-sub", "义帝 → 熊心 (G13 sub-merge)"),
]
# fmt: on

assert len(MERGE_PAIRS) == 9, f"Expected 9 pairs, got {len(MERGE_PAIRS)}"


async def apply_one_merge(
    conn: asyncpg.Connection,
    pair: MergePair,
    now: datetime,
) -> dict:
    """Apply a single merge pair within an existing transaction."""
    # 1. Verify merged person exists and is active
    merged = await conn.fetchrow(
        "SELECT id, slug, deleted_at FROM persons WHERE id = $1",
        uuid.UUID(pair.merged_id),
    )
    if not merged:
        return {
            "group": pair.group,
            "status": "error",
            "reason": f"merged person {pair.merged_id} not found",
        }
    if merged["deleted_at"] is not None:
        return {
            "group": pair.group,
            "status": "error",
            "reason": f"merged person {pair.merged_id} already deleted",
        }

    # 2. Verify canonical person exists and is active
    canonical = await conn.fetchrow(
        "SELECT id, slug, deleted_at FROM persons WHERE id = $1",
        uuid.UUID(pair.canonical_id),
    )
    if not canonical:
        return {
            "group": pair.group,
            "status": "error",
            "reason": f"canonical person {pair.canonical_id} not found",
        }
    if canonical["deleted_at"] is not None:
        return {
            "group": pair.group,
            "status": "error",
            "reason": f"canonical person {pair.canonical_id} already deleted",
        }

    # 3. Soft-delete the merged person
    await conn.execute(
        """
        UPDATE persons
        SET deleted_at = $2, merged_into_id = $3
        WHERE id = $1 AND deleted_at IS NULL
        """,
        uuid.UUID(pair.merged_id),
        now,
        uuid.UUID(pair.canonical_id),
    )

    # 4. Demote merged person's primary names to alias + sync is_primary=false
    demoted = await conn.execute(
        """
        UPDATE person_names
        SET name_type = 'alias', is_primary = false
        WHERE person_id = $1 AND name_type = 'primary'
        """,
        uuid.UUID(pair.merged_id),
    )
    demoted_count = int(demoted.split()[-1]) if demoted else 0

    # 5. Insert merge log row
    log_id = str(uuid.uuid4())
    evidence = {
        "historian_review": "docs/sprint-logs/T-P0-006-delta/historian-review-2026-04-25.md",
        "historian_commit": HISTORIAN_COMMIT,
        "dry_run_id": DRY_RUN_ID,
        "group": pair.group,
        "description": pair.description,
    }
    await conn.execute(
        """
        INSERT INTO person_merge_log
            (id, run_id, canonical_id, merged_id,
             merge_rule, confidence, evidence,
             merged_by, merged_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7::jsonb, $8, $9)
        """,
        log_id,
        RUN_ID,
        uuid.UUID(pair.canonical_id),
        uuid.UUID(pair.merged_id),
        pair.merge_rule,
        1.0,
        json.dumps(evidence, ensure_ascii=False),
        MERGED_BY,
        now,
    )

    return {
        "group": pair.group,
        "status": "ok",
        "merged_slug": merged["slug"],
        "canonical_slug": canonical["slug"],
        "demoted_names": demoted_count,
    }


async def main() -> None:
    db_url = os.environ.get(
        "DATABASE_URL", "postgresql://huadian:huadian_dev@localhost:5433/huadian"
    )
    pool = await asyncpg.create_pool(db_url)

    now = datetime.now(UTC)
    results: list[dict] = []
    errors: list[dict] = []

    print("=== T-P0-006-δ Stage 4 Apply Merges ===")
    print(f"Run ID: {RUN_ID}")
    print(f"Timestamp: {now.isoformat()}")
    print(f"Total pairs: {len(MERGE_PAIRS)}")
    print(f"Historian commit: {HISTORIAN_COMMIT}")
    print()

    for pair in MERGE_PAIRS:
        # Each merge pair gets its own transaction
        async with pool.acquire() as conn, conn.transaction():
            result = await apply_one_merge(conn, pair, now)
            results.append(result)
            if result["status"] == "ok":
                print(
                    f"  ✓ {pair.group}: {pair.description} (demoted {result['demoted_names']} names)"
                )
            else:
                errors.append(result)
                print(f"  ✗ {pair.group}: {result['reason']}")

    print()
    print("=== Summary ===")
    ok_count = sum(1 for r in results if r["status"] == "ok")
    print(f"  Applied: {ok_count}/{len(MERGE_PAIRS)}")
    print(f"  Errors: {len(errors)}")

    if errors:
        print()
        print("  ERRORS:")
        for e in errors:
            print(f"    {e['group']}: {e['reason']}")
        print()
        print("  ⚠️  SOME MERGES FAILED — investigate before proceeding to Stage 5")
    else:
        print(f"  All {ok_count} merges applied successfully.")

    # Post-apply counts
    async with pool.acquire() as conn:
        active = await conn.fetchval("SELECT count(*) FROM persons WHERE deleted_at IS NULL")
        log_count = await conn.fetchval("SELECT count(*) FROM person_merge_log")
        new_logs = await conn.fetchval(
            "SELECT count(*) FROM person_merge_log WHERE run_id = $1", RUN_ID
        )
        print()
        print(f"  Active persons: {active}  (expected: 663 = 672 - 9)")
        print(f"  Merge log total: {log_count}  (expected: 92 = 83 + 9)")
        print(f"  New merge log rows (this run): {new_logs}  (expected: 9)")

    await pool.close()


if __name__ == "__main__":
    asyncio.run(main())
