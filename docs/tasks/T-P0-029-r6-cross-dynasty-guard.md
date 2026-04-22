# T-P0-029 — R6 Cross-Dynasty / Temporal Guard

- **状态**: planned（Sprint C 架构追责产物）
- **优先级**: P1 中（仅 1 例 false positive，不阻塞 Phase 1）
- **主导角色**: 管线工程师 + 首席架构师
- **所属 Phase**: Phase 0 tail
- **依赖**: T-P0-027（R6 集成 ✅）
- **创建日期**: 2026-04-22
- **触发事件**: Sprint C Stage 4 发现启(夏) ↔ 微子启(商) 映射到同一 Wikidata Q186544，纯 QID 锚点不够强

## 1. 背景

R6 当前仅用 "两个 active person 映射到同一 Wikidata QID" 判定 merge。但 TIER-1 数据源（Wikidata）自身存在跨实体编辑混淆，纯 QID 锚点对跨朝代同名人物的防护不足。

Sprint C Stage 4 唯一的 R6 MergeProposal（启 ↔ 微子启, Q186544）即为此类 false positive。

## 2. 候选实现

| 方案 | 描述 | 优 | 劣 |
|------|------|---|---|
| A | seed_mappings JOIN persons → era/dynasty 距离 > N 年 → 降级 pending_review | 自动化 | 需要 events.era 字段成熟度（Phase 0 可能不足） |
| B | 历史专家手工维护 QID blacklist | 轻量 | 需运维 |
| C | R6 merge 前强制 dynasty 一致性检查 | 最简 | 仅对 dynasty 字段非空时有效 |

## 3. Stages（占位，由架构师 brief 细化）

- Stage 0：Phase 0 数据 dynasty 覆盖率评估
- Stage 1：选型实施
- Stage 2：回归测试 + V11 扩展

## 4. 不在本卡范围

- Wikidata 上游 bug 修复（非我方可控）
- seed_mappings schema 变更
