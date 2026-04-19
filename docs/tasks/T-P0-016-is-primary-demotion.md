# T-P0-016: apply_merges() 同步 demote is_primary

- **状态**：done（2026-04-19，commits 10575d3 / a44b2e8 / ebc7b03）
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

## 实施范围扩展

Stage 0 审计发现违规来源有两条活跃写路径，本 sprint 扩展范围涵盖两者：

1. **apply_merges()** demote 路径（resolve.py）——原任务卡主 scope，Stage 1a 修复
2. **load.py W1**（INSERT primary name）——NER 直接输出 name_zh 为 alias 时，
   硬编码 is_primary=true 产生违规。Stage 1b 修复。5 个 active 样本（fu-yue /
   shen-nong-shi / 少暤氏 / 缙云氏 / 微子启）均为此路径产物

附带发现：W2 路径（load.py 390-399，surface_forms 循环）对称存在
`primary + is_primary=false` 违规，机制为"NER name_zh 分 alias → _enforce_single_primary
promote 某 surface 为 primary → W2 硬编码 is_primary=false"。登记为 debt F12，
独立 sprint 处理。11 行基线（全 active）已捕获。

## 验收标准

- `apply_merges()` 在执行 `SET name_type = 'alias'` 的同一事务中同步执行 `SET is_primary = false`
- 全表扫描 `SELECT COUNT(*) FROM person_names WHERE name_type = 'alias' AND is_primary = true AND person_id IN (SELECT id FROM persons WHERE deleted_at IS NULL)` 返回 0
- 既有 β + α 存量数据中的 `alias + is_primary=true` 行全部修复（backfill）
- V1 single-primary invariant 仍然 PASS
- GraphQL `Person.names` 返回中不再出现 `nameType=alias, isPrimary=true` 组合
- 新增至少 3 条测试覆盖 demotion 联动逻辑

## 实施数据

Stage 0 基线：全表 `alias + is_primary=true` = 18 行
  - active: 5（W1 NER-alias 路径）
  - merge_softdelete: 11（T-P0-022 新增 7 + 预存 4）
  - pure_softdelete: 2（T-P0-014 非人实体）

Stage 2 backfill 后：0 行

测试覆盖：
  - apply_merges demotion 联动 4 条（tests/test_apply_merges.py）
  - load W1 is_primary 计算 2 条（tests/test_load_insert.py）
  - V6 全表 invariant 1 条（tests/test_merge_invariant.py::test_no_alias_with_is_primary_true）

首次达到 V1-V6 全套 invariant 绿。

## 关联

- 前置：无（可立即开工）
- 阻塞：alpha 扩量（T-P0-006 α route）
- 相关：T-P0-022（α 源 primary 未 demote — F10 扫描 + 补丁）
