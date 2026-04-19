# T-P0-022: α 源 merge source primary 未 demote — 扫描 + 补丁

- **状态**：planned
- **主导角色**：管线工程师
- **协作角色**：后端工程师（读端验证）
- **所属 Phase**：Phase 0
- **关联 debt**：F10（`docs/debts/T-P0-006-beta-followups.md`）
- **创建日期**：2026-04-19

## 背景

T-P0-006-β followup F10：α 路线 T-P0-011 的 12 条 merge 中，source person 的 `person_names` 仍有 `name_type='primary'` 未被 demote 的残留。

具体案例：hou-ji 聚合里 α 旧行 u5f03 的 `name_type='primary'` 未被 demote。

需要扫描全部 α 12 条 merge 的 source person_names，统计 `name_type='primary'` 残留数，批量补丁。

参见 `docs/debts/T-P0-006-beta-followups.md` F10 条目。

## 验收标准

- 扫描 SQL 确认 α 全部 merge source persons 的 `name_type='primary'` 残留行数
- 批量 `UPDATE SET name_type='alias', is_primary=false` 补丁执行（走 4 闸门协议）
- 补丁后全表扫描：`SELECT COUNT(*) FROM person_names pn JOIN persons p ON p.id = pn.person_id WHERE p.merged_into_id IS NOT NULL AND pn.name_type = 'primary'` 返回 0
- V1-V4 invariant 全 PASS
- 补丁记入 `person_merge_log`（rule = `backfill-primary-demotion`）或等价审计记录

## 关联

- 前置：T-P0-016（apply_merges() demote 联动，确保未来新 merge 不再产生此问题）
- 阻塞：T-P0-020（CHECK 约束添加前需确保存量数据 clean）
- 相关：T-P0-019-F4（active 定义统一）
