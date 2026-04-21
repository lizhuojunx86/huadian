# T-P0-019 α Stage 1 — V6 Zeroing

> **Sprint**: T-P0-019 α (β tail cleanup: V6 zeroing)
> **Stage**: 1 of 3
> **Date**: 2026-04-21
> **Role**: Pipeline Engineer (execute) + Chief Architect (Gate ACK)

---

## Summary

Cleared all 28 V6 violations (`is_primary=true AND name_type != 'primary'` on active persons).

- **TYPE-A** (10 persons): swapped `is_primary` from non-primary name_type row to existing `name_type='primary'` row
- **TYPE-B** (18 persons): promoted `name_type` from nickname/posthumous/temple → `'primary'`

Result: V6 28 → **0**. V1-V7 all green, V7 unchanged at 96.37%.

---

## Gate 0 — pg_dump Anchor

```
File: /tmp/before-T-P0-019-stage1.dump
Format: custom (-Fc)
SHA-256: 426d195f9451c6ce7f8a4b1b087c2a57a924be9901a5f38187a56dd3d9b6062d
PG version: PostgreSQL 16 (huadian-postgres container)
```

## Gate 1 — Pre-State Snapshot

File: `docs/tasks/T-P0-019/stage1-pre.json` (28 rows, 4942 bytes)

All 28 rows had `is_primary=true` with `name_type` ∈ {nickname(22), posthumous(5), temple(1)}.
Each violated person had `true_primary_count = 0` (no row with both `name_type='primary' AND is_primary=true`).

## Gate 2 — Dry-Run

```
BEGIN;
-- TYPE-A Step 1: UPDATE 10 (V6 rows → is_primary=false)
-- TYPE-A Step 2: UPDATE 10 (target primary rows → is_primary=true)
-- TYPE-B:        UPDATE 18 (name_type → 'primary')
-- V1=0, V2=0, V3=0, V4=0, V5=0, V6=0, V7=96.37%
ROLLBACK;
```

All invariants passed in dry-run. Zero regressions.

## Gate 3 — Irreversible Declaration

**irreversible: names-stay**. Original non-primary-typed names (帝喾, 后稷, 黄帝, 桀, 周武王, etc.) are demoted from `is_primary=true` (TYPE-A) or have their `name_type` corrected (TYPE-B). No names are deleted. ADR-014 read-side aggregation ensures all name variants remain visible in the display layer.

## Gate 4 — Execute + V1-V7

### SQL Executed

```sql
BEGIN;

-- TYPE-A Step 1: V6 rows → is_primary=false (10 rows)
UPDATE person_names SET is_primary = false
WHERE id IN (
  'efbfcbd2-ac9d-42e9-9707-3d08081bec69',  -- di-ku 帝喾 (nickname)
  'cbea21d3-eddc-4bd5-a220-e0e17008e277',  -- hou-ji 后稷 (nickname)
  '6869aa73-ed9b-4448-b128-0d7b580f0567',  -- huang-di 黄帝 (nickname)
  '122360d4-926b-4315-8b96-c3d8ebfc2d67',  -- jie 桀 (posthumous)
  '442736cf-3988-4dac-a80e-04912eb526f8',  -- zhou-wu-wang 周武王 (posthumous)
  'a828d66d-fc82-4984-9735-e5beec9bfa89',  -- 帝外壬 (nickname)
  '54aa8a38-72af-4ea7-bdb0-4a286378f8da',  -- 帝庚丁 (posthumous)
  '503c6f30-828e-4739-9d90-a7988849c08f',  -- 帝挚 (nickname)
  '8b8e67b2-5ffc-4459-b5df-a8fe6aa807f9',  -- 帝相 (nickname)
  '30ac4c4b-daed-4e00-9b35-e0e396c328ab'   -- zhou-xin 纣 (posthumous)
);

-- TYPE-A Step 2: target primary rows → is_primary=true (10 rows)
UPDATE person_names SET is_primary = true
WHERE id IN (
  '7c4e6533-a55b-4dd3-8a54-b4f2553f5eb1',  -- di-ku → 高辛
  '6e990b7e-8091-4dc1-9817-6d1a46f78e58',  -- hou-ji → 弃
  'd3bf0088-204e-46b1-9512-b8c98e569e27',  -- huang-di → 轩辕 (architect pick)
  'efc1973d-8ecd-4a0c-82b0-b1ae19b80ca8',  -- jie → 帝履癸
  '0cc08865-1007-42f8-ad7f-3436d979c174',  -- zhou-wu-wang → 发
  'd04358fa-41db-4d50-a9e5-33d97a169d77',  -- 帝外壬 → 外壬
  'bc1fe57e-464e-491f-9b17-83666faf0b7b',  -- 帝庚丁 → 庚丁
  '02987f1e-ed2c-48dc-a68d-5b3c8d4ca485',  -- 帝挚 → 挚
  '364e8621-9599-4223-b806-464a68b511c7',  -- 帝相 → 相
  '1160cf2e-f323-44e8-9faa-72a7b4113a0a'   -- zhou-xin → 辛
);

-- TYPE-B: promote name_type to 'primary' (18 rows)
UPDATE person_names SET name_type = 'primary'
WHERE id IN (
  '09c63058-9440-4b5a-9a7e-0f031af905f5',  -- peng-zu 彭祖
  '0d34210b-117e-444d-a23f-06815803f4f3',  -- 周公
  '85c608d5-0199-422e-b600-dd94629a8b46',  -- 帝不降
  'a71b2738-2196-4af3-8787-2ffa77f6f10b',  -- 帝乙
  '8efb2d59-83a1-4876-82eb-8cf4330183e1',  -- 帝予
  '45ffc3dd-7703-4715-bb77-588d2e59ded4',  -- 帝廑
  '080f4ba4-27f0-45fd-9294-8b8cd6891f16',  -- 帝廪辛
  '1025ae21-2252-4a40-a756-82d1a5b41b26',  -- 帝扃
  '7c09cd7d-46a6-49ec-95fa-109339f9dad1',  -- 帝槐
  '0a7cfed8-a023-45b4-9fa5-c76194d41c97',  -- 帝泄
  '9d427169-1455-45a7-bf2f-889659c0cd6d',  -- 帝芒
  '79d04c03-be27-4c0b-98a5-9d08abaed7b8',  -- 梼杌
  '62151be8-64a2-4853-b1dc-b7322f95bf86',  -- 浑沌
  '281c6d5f-4416-44a0-b1ab-d3a934789d5e',  -- 穷奇
  '237db603-99c8-42cb-b94a-e6c6ce79cee8',  -- 管叔
  '43c69ff9-7e97-4bc0-bf63-577681bc6ce6',  -- 蔡叔
  '1663d36c-bf8e-4153-916b-bdc50938c1ba',  -- 饕餮
  '944cd706-901c-4dce-b936-29e4886af6ec'   -- 炎帝
);

-- V1-V7 verification (all passed) → COMMIT;
```

### V1-V7 Post-Execute Results

| Invariant | Result | Notes |
|-----------|--------|-------|
| V1 single-primary | **0** ✅ | No regression |
| V2 name completeness | **0** ✅ | No regression |
| V3 FK integrity | **0** ✅ | No regression |
| V4 model-B leakage | **0** ✅ | No regression |
| V5 active definition | **0** ✅ | No regression |
| V6 alias≠is_primary | **0** ✅ | **28 → 0** (target achieved) |
| V7 evidence coverage | **96.37%** ✅ | No regression (unchanged) |

### Post-State Snapshot

File: `docs/tasks/T-P0-019/stage1-post.json` (38 rows — 28 modified + 10 swap targets)

---

## TYPE-A Swap Detail (10 persons)

| slug | Old is_primary name | New is_primary name | Principle |
|------|-------------------|-------------------|-----------|
| di-ku | 帝喾 (nickname) | 高辛 (primary) | Personal name > title; 《五帝本纪》: "帝喾高辛者" |
| hou-ji | 后稷 (nickname) | 弃 (primary) | Personal name > office title |
| huang-di | 黄帝 (nickname) | 轩辕 (primary) | Personal name > honorific; 《五帝本纪》: "名曰轩辕" |
| jie | 桀 (posthumous) | 帝履癸 (primary) | Personal name > posthumous |
| u5468-u6b66-u738b | 周武王 (posthumous) | 发 (primary) | Personal name > posthumous+polity |
| u5e1d-u5916-u58ec | 帝外壬 (nickname) | 外壬 (primary) | Personal name > 帝X prefix |
| u5e1d-u5e9a-u4e01 | 帝庚丁 (posthumous) | 庚丁 (primary) | Personal name > 帝X prefix |
| u5e1d-u631a | 帝挚 (nickname) | 挚 (primary) | Personal name > 帝X prefix |
| u5e1d-u76f8 | 帝相 (nickname) | 相 (primary) | Personal name > 帝X prefix |
| zhou-xin | 纣 (posthumous) | 辛 (primary) | Personal name > posthumous |

**huang-di dual-candidate resolution**: 轩辕 chosen over 黄帝之后 (derivative/descendant term). Architect + historian ratified.

## TYPE-B Promotion Detail (18 persons)

All 18 rows: `name_type` changed from nickname(16)/posthumous(1)/temple(1) → `'primary'`.

These persons had no existing `name_type='primary'` row. The sole `is_primary=true` name was incorrectly typed by Phase A/B NER. Promoting `name_type` corrects the semantic label without changing display behavior.

---

## Architect Review Notes

1. **SQL correction**: Original Stage 1 instruction specified TYPE-B as `SET is_primary = true`. Pipeline engineer correctly identified that TYPE-B rows already have `is_primary=true`; the actual V6 violation is the `name_type` column. Corrected SQL: `SET name_type = 'primary'`. Dry-run (V6 28→0, V1=0) validated correctness.

2. **Naming principle generalization**: TYPE-A swap follows a universal rule: **personal name (私名) takes `is_primary=true`; title/posthumous/temple names are demoted**. This is consistent with ADR-014 read-side aggregation (all name variants remain visible). Applies to all 10 swaps uniformly — no per-case override needed.

---

## Debt Resolution

- **T-P1-013** (alias+is_primary=true 28 rows): **RESOLVED** by this stage.
- Updated baseline: V6 violations = 0.
