# T-P0-020: persons CHECK 约束 — merged_into_id ↔ deleted_at 成对

- **状态**：done（2026-04-19，commit c43aaf9）
- **主导角色**：后端工程师
- **协作角色**：管线工程师（存量数据验证）、架构师（schema 变更审批）
- **所属 Phase**：Phase 0
- **关联 debt**：F3（`docs/debts/T-P0-006-beta-followups.md`）
- **创建日期**：2026-04-19

## 背景

T-P0-006-β followup F3：T-P0-015 帝鸿氏 partial-merge bug 暴露 schema 缺少强制约束——`merged_into_id` 被设置但 `deleted_at` 未同步设置（或反之），导致数据形态不一致。

目标 CHECK 约束：

```sql
ALTER TABLE persons ADD CONSTRAINT persons_soft_merge_paired
  CHECK ((merged_into_id IS NULL) = (deleted_at IS NULL));
```

此约束确保两列始终成对：要么都 NULL（active person），要么都非 NULL（soft-merged person）。

参见 `docs/debts/T-P0-006-beta-followups.md` F3 条目。

## 实施发现

Stage 0 前置扫描发现 5 行 `deleted_without_merge` 违反原拟议的双向等价 CHECK（T-P0-014 R3-non-person 产生的纯 soft-delete）。架构师裁决改为单向蕴涵 `merged_into_id IS NULL OR deleted_at IS NOT NULL`，保留 pure soft-delete 合法性。约束名从 `persons_soft_merge_paired` 改为 `persons_merge_requires_delete`。详见 ADR-010 Supplement 2026-04-19。

CHECK SQL 最终版本：
```sql
ALTER TABLE persons ADD CONSTRAINT persons_merge_requires_delete
  CHECK (merged_into_id IS NULL OR deleted_at IS NOT NULL);
```

## 验收标准

- Drizzle schema 中 `persons` 表新增 CHECK 约束 `persons_soft_merge_paired`
- 对应 Drizzle migration 生成并可在干净 DB 上 migrate 成功
- 全表现有数据验证通过（无行违反约束）
- `apply_merges()` 测试在 CHECK 约束存在的情况下仍然全绿
- non-person soft-delete（R3 规则）在 CHECK 约束存在的情况下仍然全绿
- 至少 1 条测试验证：直接写 `merged_into_id` 而不写 `deleted_at` 会被 CHECK 拒绝

## 关联

- 前置：T-P0-022（α 存量 primary 修复）— 需先确认存量数据无违反
- 阻塞：T-P0-019-F4（active 定义统一，依赖 CHECK 约束使两种定义等价）
