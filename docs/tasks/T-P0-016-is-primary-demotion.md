# T-P0-016: apply_merges() 同步 demote is_primary

- **状态**：planned
- **主导角色**：管线工程师
- **协作角色**：后端工程师（API 读端验证）、QA（回归测试）
- **所属 Phase**：Phase 0
- **关联 debt**：F5 / F11（`docs/debts/T-P0-006-beta-followups.md`）
- **关联 ADR**：ADR-014（canonical merge execution model）
- **创建日期**：2026-04-19

## 背景

T-P0-006-β followup F5/F11 发现：`apply_merges()` 在 demote `name_type = 'alias'` 时，不同步设置 `is_primary = false`。导致 GraphQL 返回 `nameType=alias + isPrimary=true` 的语义矛盾组合（用户可见 UX 问题）。

ADR-014 §7 明确将此问题排除到 T-P0-016 处理。这是 alpha 扩量前的 must-have（retro §5 第 1 项）。

参见 `docs/debts/T-P0-006-beta-followups.md` F5 / F11 条目。

## 验收标准

- `apply_merges()` 在执行 `SET name_type = 'alias'` 的同一事务中同步执行 `SET is_primary = false`
- 全表扫描 `SELECT COUNT(*) FROM person_names WHERE name_type = 'alias' AND is_primary = true AND person_id IN (SELECT id FROM persons WHERE deleted_at IS NULL)` 返回 0
- 既有 β + α 存量数据中的 `alias + is_primary=true` 行全部修复（backfill）
- V1 single-primary invariant 仍然 PASS
- GraphQL `Person.names` 返回中不再出现 `nameType=alias, isPrimary=true` 组合
- 新增至少 3 条测试覆盖 demotion 联动逻辑

## 关联

- 前置：无（可立即开工）
- 阻塞：alpha 扩量（T-P0-006 α route）
- 相关：T-P0-022（α 源 primary 未 demote — F10 扫描 + 补丁）
