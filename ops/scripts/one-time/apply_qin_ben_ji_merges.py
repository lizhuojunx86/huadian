"""T-P0-006-γ Stage 4 — Apply historian-approved merges for 秦本纪.

28 merge groups (21 approve + 7 sub-merges from split groups) = 29 soft-deletes.
G6 is a 3-person group (缪公 + 秦缪公 → 秦穆公), hence 29 not 28.

Historian review: commit 3280a35
  docs/sprint-logs/T-P0-006-gamma/historian-review-2026-04-25.md
Dry-run report: Run ID 789c0bcf-c0fb-4f23-b154-0f7644931919
  docs/sprint-logs/T-P0-006-gamma/dry-run-resolve-2026-04-25.md

Each group runs in its own transaction. Failure in one group does NOT
roll back other groups (per task spec).
"""

from __future__ import annotations

import asyncio
import json
import os
import uuid
from dataclasses import dataclass
from datetime import UTC, datetime

import asyncpg

RUN_ID = "3280a350-0006-4000-b000-000000000004"  # deterministic UUID: historian commit prefix + gamma + stage4
MERGED_BY = "pipeline:stage4-historian-3280a35"
HISTORIAN_COMMIT = "3280a35"
DRY_RUN_ID = "789c0bcf-c0fb-4f23-b154-0f7644931919"


@dataclass
class MergePair:
    group: str  # e.g. "G1", "G6a"
    merged_id: str  # person to soft-delete
    canonical_id: str  # person to keep
    merge_rule: str  # e.g. "R1+historian-confirm"
    description: str  # human-readable


# fmt: off
MERGE_PAIRS: list[MergePair] = [
    # ── 21 Approve groups (22 pairs; G6 has 2) ──────────────────────

    # G1: 太史公 → 司马迁
    MergePair("G1",  "e9542991-4023-4a9d-82da-212749f8fc4e", "7128aa48-c9a1-43a1-a338-383370cd01c2", "R1+historian-confirm", "太史公 → 司马迁"),
    # G4: 孝王 → 周孝王
    MergePair("G4",  "4ffdaa98-c914-417c-92f7-82c10338455e", "be0ef800-e0de-4c62-98f9-1293131a818d", "R1+historian-confirm", "孝王(辟方) → 周孝王"),
    # G6a: 缪公 → 秦穆公
    MergePair("G6a", "dfbc851d-f3bc-4d4d-bdab-efd522f63865", "144a7a2c-4330-480c-a2cb-4cf09245de8f", "R1+R3-tongjia+historian-confirm", "缪公 → 秦穆公"),
    # G6b: 秦缪公 → 秦穆公
    MergePair("G6b", "a1d87a9d-ecde-4486-9285-aeba4a25e2d3", "144a7a2c-4330-480c-a2cb-4cf09245de8f", "R1+R3-tongjia+historian-confirm", "秦缪公 → 秦穆公"),
    # G12: 儋 → 太史儋
    MergePair("G12", "fbd9f46f-c652-4d14-ac8a-54fdf45e5b08", "d3cb56c4-7ae9-484e-8a03-0b0ad2a83384", "R1+historian-confirm", "儋 → 太史儋"),
    # G13: 献公 → 秦献公
    MergePair("G13", "ebcd8d48-2cda-49c9-9a6d-47267842dcec", "caa24f9d-5cea-4743-8690-e4b1a47b06a5", "R1+historian-confirm", "献公 → 秦献公"),
    # G14: 秦孝公(unicode) → 秦孝公(pinyin)
    MergePair("G14", "4624bb13-45fc-4b26-92da-aaac3bf14ca9", "9c1c50e3-6c4f-4963-960a-89d90a70ca67", "R1+historian-confirm", "秦孝公(unicode) → 秦孝公(pinyin)"),
    # G15: 幽王(you-wang) → 周幽王
    MergePair("G15", "56b3770d-997e-4d1f-92c2-d865e1114b42", "c54236c3-108b-484c-a31e-34967cbcb0bf", "R1+historian-confirm", "幽王 → 周幽王"),
    # G18: 宁公 → 秦宁公
    MergePair("G18", "30e9e183-8181-41b3-be5e-780f7c00ddcc", "00b70ef0-25af-483f-b896-5dd324736dc1", "R1+historian-confirm", "宁公 → 秦宁公"),
    # G19: 德公 → 秦德公
    MergePair("G19", "cc9aede7-93dc-48a5-a369-65abe1c90f85", "77726816-4189-4191-b8ae-ce9d4b6ae564", "R1+historian-confirm", "德公 → 秦德公"),
    # G20: 出子 → 秦出子
    MergePair("G20", "f0e68dde-3ef7-4af8-a815-89fbd42ae3b8", "38f5fd55-7ce9-48a6-bf96-fa3f73d76ed5", "R1+historian-confirm", "出子 → 秦出子"),
    # G21: 无知 → 公孙无知
    MergePair("G21", "7211e0a5-71ef-4f59-9c26-4054e3a2b63e", "442189d8-779f-4c24-af5b-e7490fc4ebcc", "R1+historian-confirm", "无知 → 公孙无知"),
    # G22: 宣公 → 秦宣公
    MergePair("G22", "4d22b414-afd8-4773-9e50-8fdd5b26623e", "d3b5caa1-36b2-4b27-a72f-841a2a6742f6", "R1+historian-confirm", "宣公 → 秦宣公"),
    # G23: 成公 → 秦成公
    MergePair("G23", "40906a0d-f843-455a-ae42-1fafacfb0464", "48061209-63f6-4d69-9eba-471de7985e25", "R1+historian-confirm", "成公 → 秦成公"),
    # G24: 申生 → 晋太子申生
    MergePair("G24", "d06e316e-dc9d-44d3-b216-6d5fd6cc5912", "647b1123-794a-42fd-985f-b34f9287a0e0", "R1+historian-confirm", "申生 → 晋太子申生"),
    # G25: 百里傒 → 百里奚
    MergePair("G25", "c9ac1302-73ca-418c-a911-47c87759f285", "8e9ed2e2-65e5-47be-b6de-8f321275a726", "R1+R3-tongjia+historian-confirm", "百里傒 → 百里奚"),
    # G27: 共公 → 秦共公
    MergePair("G27", "2b8b4d73-d627-4e1c-b888-4ae8acf2dc10", "6a954196-a878-49e5-a85b-f9a03b6f5ba3", "R1+historian-confirm", "共公 → 秦共公"),
    # G31: 厉共公 → 秦厉共公
    MergePair("G31", "8301e32d-186d-4f57-9729-4d9cc57dede9", "6a85ef15-5933-4cf7-98f5-257d90fa5f3a", "R1+historian-confirm", "厉共公 → 秦厉共公"),
    # G32: 昭子 → 秦昭子
    MergePair("G32", "8c0890b1-e82e-4895-ba71-c54ce3ac1a1a", "eda7daad-8b7b-40e7-9fa0-a2a5b8944218", "R1+historian-confirm", "昭子 → 秦昭子"),
    # G33: 卫鞅 → 商鞅
    MergePair("G33", "513377a3-bee4-43d4-9dc1-ab0086f277e0", "957e9a25-30f6-4fd6-a163-785231f1a3ed", "R1+historian-confirm", "卫鞅 → 商鞅"),
    # G34: 昭襄王 → 秦昭襄王
    MergePair("G34", "d7616ce7-a0a9-4dbf-9245-4e5a398f333c", "cfefc568-fe69-4625-9629-84fbf0cd7807", "R1+historian-confirm", "昭襄王 → 秦昭襄王"),
    # G35: 孝文王 → 秦孝文王
    MergePair("G35", "ae68feda-5705-4b96-a571-b71c96f95060", "d4b61e89-82a8-4921-a417-f0b9a67badcf", "R1+historian-confirm", "孝文王 → 秦孝文王"),

    # ── 7 Sub-merge groups (from split rulings) ─────────────────────

    # G5 sub: 桓公 → 秦桓公
    MergePair("G5-sub",  "4673104c-d9ce-4a4b-92ba-04206e6c7db3", "fe882af0-51f4-46a6-9a4f-61011d2f4c46", "R1+historian-split-sub", "桓公 → 秦桓公"),
    # G7 sub: 悼公 → 晋悼公
    MergePair("G7-sub",  "3903656e-c034-4e92-966d-e9bba54f3d18", "9318f515-2b0d-4200-9e50-0656e7e6c041", "R1+historian-split-sub", "悼公 → 晋悼公"),
    # G8 sub: 楚公子围 → 楚灵王
    MergePair("G8-sub",  "5b1d1dc0-98a0-41b7-8d2a-6a1a3f4725e5", "0937bb0d-82a0-477f-b3e6-508c7dccae2b", "R1+historian-split-sub", "楚公子围 → 楚灵王"),
    # G9 sub: 庄公 → 秦庄公
    MergePair("G9-sub",  "32a7c8ef-3f53-4eb2-9f60-402752301815", "82cca4dd-aa67-4760-9087-2e6de8a43722", "R1+historian-split-sub", "庄公 → 秦庄公"),
    # G10 sub: 简公 → 秦简公
    MergePair("G10-sub", "e6e9d27e-b800-4c54-8296-19ac3cfcec42", "bd7f9f66-b7c5-4d0c-b576-c4d08ddbb28a", "R1+historian-split-sub", "简公 → 秦简公"),
    # G16 sub: 夷吾 → 晋惠公
    MergePair("G16-sub", "c04e0814-6557-40af-b35d-5fec14bd80bb", "f1f48820-ebc7-41bd-8e87-2c5454bcad91", "R1+historian-split-sub", "夷吾 → 晋惠公"),
    # G26 sub: 子圉 → 太子圉
    MergePair("G26-sub", "4bdd2dd1-8e72-4f5a-915a-565367700490", "76591c5f-395c-4b8e-a94a-dab9aac644bc", "R1+historian-split-sub", "子圉 → 太子圉"),
]
# fmt: on

assert len(MERGE_PAIRS) == 29, f"Expected 29 pairs, got {len(MERGE_PAIRS)}"


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
        "historian_review": "docs/sprint-logs/T-P0-006-gamma/historian-review-2026-04-25.md",
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
    db_url = os.environ.get("DATABASE_URL", "postgresql://huadian:huadian@localhost:5433/huadian")
    pool = await asyncpg.create_pool(db_url)

    now = datetime.now(UTC)
    results: list[dict] = []
    errors: list[dict] = []

    print("=== T-P0-006-γ Stage 4 Apply Merges ===")
    print(f"Run ID: {RUN_ID}")
    print(f"Timestamp: {now.isoformat()}")
    print(f"Total pairs: {len(MERGE_PAIRS)}")
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
        print(f"  Active persons: {active}")
        print(f"  Merge log total: {log_count} (new: {new_logs})")

    await pool.close()


if __name__ == "__main__":
    asyncio.run(main())
