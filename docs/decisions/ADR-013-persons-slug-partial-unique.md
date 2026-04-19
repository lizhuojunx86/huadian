# ADR-013: persons.slug UNIQUE 约束改为 partial（排除 soft-deleted）

## 状态
Accepted (2026-04-19)

## 背景
T-P0-011 引入跨 chunk identity_resolver + soft-merge（`deleted_at` +
`merged_into_id`），保留合并审计历史。但原 `persons_slug_unique` 是全表
唯一索引，未考虑 soft-deleted 行占位。

T-P0-006-β S-3b 摄入《尚书》时，"弃"/"垂"因 α 路线已 soft-deleted，新
candidate 的 slug 命中 deleted 行的 slug → INSERT 被拒，candidate
未入库，导致 S-4 dry-run 无法完整验证附录 B 预期归并清单（特别是 B-1
第 16 行：垂→倕 R3 tongjia 跨书触发）。

## 决策
`persons_slug_unique` 改为 partial unique index：

```sql
DROP INDEX IF EXISTS persons_slug_unique;
CREATE UNIQUE INDEX persons_slug_unique
  ON persons (slug)
  WHERE deleted_at IS NULL;
```

## 理由
- 对 T-P0-011 soft-merge 设计完整性的 bug fix，非新功能
- 允许新 candidate 复用已 soft-deleted 行的 slug；后续由 identity_resolver
  自然合并（走 R1 surface match 或 R3 tongjia）
- 保留 soft-deleted 行的 merged_into_id 审计价值（历史可查）
- 不影响 person_merge_log 或 identity_hypotheses 的 already-merged 关系

## 副作用
- 按 slug 查询如需包含 deleted 行，须显式 `OR deleted_at IS NOT NULL`
- Drizzle schema 同步需记入 T-TG-002-F6 backlog（保持双轨 migration）

## 迁移
- Pipeline migration: `services/pipeline/migrations/0004_persons_slug_partial_unique.sql`
- 幂等（DROP INDEX IF EXISTS / CREATE UNIQUE INDEX 带 WHERE）
- CI 通过 Step 4c workaround 自动应用（T-P1-005）

## 关联
- ADR-010（跨 chunk 身份消歧）— 原 soft-merge 设计引入
- T-P0-011（identity_resolver 实现）
- T-P1-005（migration 双轨问题，已 workaround）
- T-P0-006-β S-3b（本 case 触发）
