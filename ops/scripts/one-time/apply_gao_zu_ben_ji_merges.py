"""T-P0-006-ε Stage 4 — Apply historian-approved merges for 高祖本纪.

15 approve groups (17 soft-deletes) + 2 G7 split sub-merges = 19 soft-deletes total.

Historian review: commit 07db893
  docs/sprint-logs/sprint-j/historian-review-2026-04-28.md
Sprint J brief: docs/sprint-logs/sprint-j/stage-0-brief-2026-04-28.md
Dry-run report: Run ID c9f9a1d8-37e9-452c-8124-e61e4fb2ba03
  docs/sprint-logs/sprint-j/dry-run-resolve-2026-04-28.md
  §correction-2026-04-28: dry-run rows 11/18 dynasty columns were transposed
  (display bug only; guard math correct; DB values were correct throughout)

Architect rulings (2026-04-28, this session):
  - S4.3 dynasty fix skipped: DB values already correct (吕后=西汉, 刘盈=西汉)
  - T-P1-031 candidate NOT created (no real dynasty bug in DB)
  - G7 sub-merges use merge_rule='R1+historian-split-sub' (per Sprint J brief)
  - 田广 §4.5 slug dedup: SELECT confirms only 1 active 田广, no 20th SD needed
  - pg_dump anchor: ops/rollback/pre-T-P0-006-epsilon-stage-4.dump

Merge rules:
  manual_textbook_fact:   G8 (嬴政→始皇帝, #3) + G11 (陈胜→陈涉, #4)
  R1+historian-split-sub: G7a (怀王→熊心) + G7b (义帝→熊心)
  R1+structural-dedup:    G16 + G18 + G19 + G20a + G22 + G23 (6 slug dedup)
  R1+historian-confirm:   G3 + G9a + G9b + G12 + G14 + G15 + G17 + G20b + G21 (9 pairs)

Each group runs in its own transaction. Failure in one group does NOT
roll back other groups.

G21 note: 吕后 (id=2bb5c9ae) is the 高祖本纪 NER new person (cross-chapter
new instance). Sprint G T-P0-006-δ G21 already merged a different 吕后 entity
(id=d79ce542, deleted 2026-04-25) into 吕雉. No double-apply risk.

G7 note: 怀王 (id=23bbfc1c) is the 高祖本纪 NER new person. Sprint G T-P0-006-δ G13a
already merged a different 怀王 entity into 熊心. V1 self-check post-apply should
confirm alias surface uniqueness per ADR-014 names-stay model.
"""

from __future__ import annotations

import asyncio
import json
import os
import uuid
from dataclasses import dataclass
from datetime import UTC, datetime

import asyncpg

RUN_ID = "07db8930-0006-4000-e000-000000000019"  # historian commit prefix + epsilon + 19 SD
MERGED_BY = "pipeline:stage4-historian-07db893"
HISTORIAN_COMMIT = "07db893"
DRY_RUN_ID = "c9f9a1d8-37e9-452c-8124-e61e4fb2ba03"


@dataclass
class MergePair:
    group: str
    merged_id: str
    canonical_id: str
    merge_rule: str
    description: str


# fmt: off
MERGE_PAIRS: list[MergePair] = [
    # ── G3: 秦王 → 子婴 ─────────────────────────────────────────────────
    MergePair("G3",   "c5f0f89b-0a98-4419-84f3-4c2ae7853c41",
                      "6ea97184-d5d2-4b81-9fef-efa447e2e651",
              "R1+historian-confirm", "秦王 → 子婴"),

    # ── G8: 嬴政 → 始皇帝 (manual_textbook_fact #3) ──────────────────────
    # 《史记·秦始皇本纪》: "朕为始皇帝。" 名/尊号关系，textbook fact。
    # Precedent #3 (cf. T-P1-025 重耳→晋文公 #1, Sprint G G15 项籍→项羽 #2).
    # Sprint J G11 陈胜→陈涉 is #4 → cumulative 4 cases triggers ADR-014 addendum.
    MergePair("G8",   "2a63d8aa-8e38-421a-bf06-e827efb0c684",
                      "f6f9ae0c-29b3-4a2c-b4a2-25678d9edcc2",
              "manual_textbook_fact", "嬴政 → 始皇帝 (名→尊号, textbook fact #3)"),

    # ── G9a: 二世 → 秦二世 ───────────────────────────────────────────────
    # R1+historian-confirm (NOT manual_textbook_fact): bare "二世" without state
    # prefix is ambiguous (周二世/汉二世 etc.); textbook-fact requires unambiguous
    # surface. Historian ruling per historian-review-2026-04-28.md §G9.
    MergePair("G9a",  "208fa4bb-9d4b-406e-940a-c92e878b373c",
                      "ee902eef-865c-4051-ae30-3713bf313dbb",
              "R1+historian-confirm", "二世 → 秦二世 (排序代号→国号全称)"),

    # ── G9b: 胡亥 → 秦二世 ───────────────────────────────────────────────
    MergePair("G9b",  "57a05049-d840-487f-892d-344c1b60b85d",
                      "ee902eef-865c-4051-ae30-3713bf313dbb",
              "R1+historian-confirm", "胡亥 → 秦二世 (名→国号)"),

    # ── G11: 陈胜 → 陈涉 (manual_textbook_fact #4) ───────────────────────
    # 《史记·陈涉世家》: "陈胜者，阳城人也，字涉。" 名/字关系，textbook fact。
    # Precedent #4 → cumulative 4/3 triggers ADR-014 addendum (T-P1-030 candidate).
    # Note: 陈胜 (dc2ed852) was canonical for Sprint G G17 "陈王→陈胜". After this
    # merge, chain is: 陈王 (deleted→陈胜) → 陈胜 (deleted→陈涉) → 陈涉 (canonical).
    MergePair("G11",  "dc2ed852-b882-42af-bd49-0b414799d1fb",
                      "e03ae4af-c57d-4611-bdf1-fedd872b05f4",
              "manual_textbook_fact", "陈胜 → 陈涉 (名→字, textbook fact #4)"),

    # ── G12: 黥布 → 英布 ────────────────────────────────────────────────
    MergePair("G12",  "3da04593-a0dc-4ad6-b413-3314324e89c7",
                      "f731c679-eca7-4d97-9c4b-708e30083c4d",
              "R1+historian-confirm", "黥布 → 英布 (绰号→本名)"),

    # ── G14: 卿子冠军 → 宋义 ────────────────────────────────────────────
    MergePair("G14",  "4341f91e-c8c3-40d8-8d92-d900194d35b2",
                      "5b2be1c6-fa28-44d8-8e08-f1828ee5ae1f",
              "R1+historian-confirm", "卿子冠军 → 宋义 (封号→本名)"),

    # ── G15: 赵王歇 → 赵歇 ──────────────────────────────────────────────
    MergePair("G15",  "b3e2bd44-9b56-410a-b589-535bef5369a0",
                      "c9235dcc-4dc1-44e1-9833-05d00118fa9f",
              "R1+historian-confirm", "赵王歇 → 赵歇 (全称→简称)"),

    # ── G16: 纪信 unicode slug → pinyin slug ────────────────────────────
    MergePair("G16",  "726e1dfe-e353-4095-ac7d-1cbd2d1c8921",
                      "1ae1d86d-73e8-42a4-97f1-882b0a25f265",
              "R1+structural-dedup", "纪信 unicode(u7eaa-u4fe1) → pinyin(ji-xin) slug dedup"),

    # ── G17: 魏王豹 → 魏豹 ──────────────────────────────────────────────
    MergePair("G17",  "505132b7-bd2f-49de-996c-56572e041a79",
                      "5a90ae32-9bb5-4394-95a2-f91a8ab3a1ba",
              "R1+historian-confirm", "魏王豹 → 魏豹 (全称→简称)"),

    # ── G18: 郑昌 unicode slug → pinyin slug ────────────────────────────
    MergePair("G18",  "9fba6c33-f364-42f1-a64d-fc1fc671dbaa",
                      "281d72fb-ccd3-40c5-9456-f501563495f5",
              "R1+structural-dedup", "郑昌 unicode(u90d1-u660c) → pinyin(zheng-chang) slug dedup"),

    # ── G19: 田横 unicode slug → pinyin slug ────────────────────────────
    MergePair("G19",  "2710eed0-0794-4128-98a4-841614b28796",
                      "2c08e776-57b7-4359-8de9-b7ee418be708",
              "R1+structural-dedup", "田横 unicode(u7530-u6a2a) → pinyin(tian-heng) slug dedup"),

    # ── G20a: 刘太公 unicode slug → pinyin slug ─────────────────────────
    MergePair("G20a", "bf5120bb-7306-4fe2-9be9-13e0bd99aea6",
                      "03ed2906-eaef-46cc-8db3-93ec363dd97a",
              "R1+structural-dedup", "刘太公 unicode(u5218-u592a-u516c) → pinyin(liu-tai-gong) slug dedup"),

    # ── G20b: 太公 → 刘太公 ─────────────────────────────────────────────
    # 汉初语境"太公"唯一指刘邦之父；Sprint G T-P0-006-δ G20 apply 已合并项羽本纪
    # 的"太公→刘太公" entity. 本组为高祖本纪 NER 新实例（cross-chapter new person）.
    MergePair("G20b", "0072edf6-d34d-46b2-a4f6-716ee229e013",
                      "03ed2906-eaef-46cc-8db3-93ec363dd97a",
              "R1+historian-confirm", "太公 → 刘太公 (短称→全称, 汉初语境)"),

    # ── G21: 吕后(高祖本纪新实例) → 吕雉 ───────────────────────────────
    # Cross-chapter new person (高祖本纪 NER, created 2026-04-28).
    # Sprint G T-P0-006-δ G21 already merged a different 吕后 entity (id=d79ce542,
    # deleted 2026-04-25) into 吕雉. This is a new entity, not a double-apply.
    MergePair("G21",  "2bb5c9ae-13ad-417e-9412-6f902b19dfc4",
                      "1f2c5497-96af-4337-95a9-25e4cc5857d5",
              "R1+historian-confirm", "吕后(高祖本纪新实例) → 吕雉 (cross-chapter)"),

    # ── G22: 武涉 unicode slug → pinyin slug ────────────────────────────
    MergePair("G22",  "60d298e8-64e5-4bb1-8ac0-83d0115e652a",
                      "e72c5c78-88ab-4829-9083-abe3fcdeac79",
              "R1+structural-dedup", "武涉 unicode(u6b66-u6d89) → pinyin(wu-she) slug dedup"),

    # ── G23: 陆贾 unicode slug → pinyin slug ────────────────────────────
    MergePair("G23",  "7452b31b-7593-47ad-ad99-37f06daa7098",
                      "9db7fe9c-ece4-456c-8fd5-4f54aaede482",
              "R1+structural-dedup", "陆贾 unicode(u9646-u8d3e) → pinyin(lu-jia) slug dedup"),

    # ── G7a: 怀王(高祖本纪新实例) → 熊心 ───────────────────────────────
    # Split group sub-merge. 怀王 here is the 高祖本纪 NER new person (cross-chapter
    # new instance). Sprint G T-P0-006-δ G13a already merged a different 怀王 entity
    # into 熊心 (via R1+historian-split-sub). Sprint H T-P0-031 INSERTed "怀王" as
    # split_for_safety alias on 熊心 entity. Post-apply V1 self-check required:
    # if "怀王" alias surface already exists on 熊心 (from T-P0-031), the new
    # person_names alias row from names-stay model would create a duplicate.
    # Per architect ACK: this is acceptable data redundancy, not a V1 violation
    # (V1 = is_primary uniqueness, not alias uniqueness). Retro §lessons records
    # V13 candidate (alias uniqueness invariant, backlog until ≥3 occurrences).
    MergePair("G7a",  "23bbfc1c-0883-4da8-bcd6-4d17654d1e03",
                      "48061967-7058-47d2-9657-15c57a0b866b",
              "R1+historian-split-sub", "怀王(高祖本纪新实例) → 熊心 (G7 split sub-merge)"),

    # ── G7b: 义帝(高祖本纪新实例) → 熊心 ───────────────────────────────
    # Sprint G T-P0-006-δ G13b already merged a different 义帝 entity (项羽本纪 NER)
    # into 熊心. This 义帝 (db4264f9) is the 高祖本纪 NER new person.
    MergePair("G7b",  "db4264f9-e4a2-46ce-b88c-89478f14fc2c",
                      "48061967-7058-47d2-9657-15c57a0b866b",
              "R1+historian-split-sub", "义帝(高祖本纪新实例) → 熊心 (G7 split sub-merge)"),
]
# fmt: on

assert len(MERGE_PAIRS) == 19, f"Expected 19 pairs, got {len(MERGE_PAIRS)}"


async def apply_one_merge(
    conn: asyncpg.Connection,
    pair: MergePair,
    now: datetime,
) -> dict:
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

    await conn.execute(
        "UPDATE persons SET deleted_at = $2, merged_into_id = $3 WHERE id = $1 AND deleted_at IS NULL",
        uuid.UUID(pair.merged_id),
        now,
        uuid.UUID(pair.canonical_id),
    )

    demoted = await conn.execute(
        "UPDATE person_names SET name_type = 'alias', is_primary = false WHERE person_id = $1 AND name_type = 'primary'",
        uuid.UUID(pair.merged_id),
    )
    demoted_count = int(demoted.split()[-1]) if demoted else 0

    evidence = {
        "historian_review": "docs/sprint-logs/sprint-j/historian-review-2026-04-28.md",
        "historian_commit": HISTORIAN_COMMIT,
        "dry_run_id": DRY_RUN_ID,
        "group": pair.group,
        "description": pair.description,
    }
    await conn.execute(
        """
        INSERT INTO person_merge_log
            (id, run_id, canonical_id, merged_id, merge_rule, confidence, evidence, merged_by, merged_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7::jsonb, $8, $9)
        """,
        str(uuid.uuid4()),
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

    print("=== T-P0-006-ε Stage 4 Apply Merges ===")
    print(f"Run ID: {RUN_ID}")
    print(f"Timestamp: {now.isoformat()}")
    print(f"Total pairs: {len(MERGE_PAIRS)}")
    print(f"Historian commit: {HISTORIAN_COMMIT}")
    print()

    for pair in MERGE_PAIRS:
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

    async with pool.acquire() as conn:
        active = await conn.fetchval("SELECT count(*) FROM persons WHERE deleted_at IS NULL")
        log_count = await conn.fetchval("SELECT count(*) FROM person_merge_log")
        new_logs = await conn.fetchval(
            "SELECT count(*) FROM person_merge_log WHERE run_id = $1", RUN_ID
        )
        print()
        print(f"  Active persons: {active}  (expected: 729 = 748 - 19)")
        print(f"  Merge log total: {log_count}  (expected: 111 = 92 + 19)")
        print(f"  New merge log rows (this run): {new_logs}  (expected: 19)")

    await pool.close()


if __name__ == "__main__":
    asyncio.run(main())
