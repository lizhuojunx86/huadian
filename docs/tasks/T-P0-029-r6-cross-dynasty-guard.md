# T-P0-029 — R6 Cross-Dynasty / Temporal Guard

- **状态**: **done**（Sprint D 落地 ✅；Sprint H 通过 ADR-025 evaluate_pair_guards 兼容性扩展，R6 既有行为不变）
- **优先级**: P1 中（仅 1 例 false positive，不阻塞 Phase 1）
- **主导角色**: 管线工程师 + 首席架构师
- **所属 Phase**: Phase 0 tail
- **依赖**: T-P0-027（R6 集成 ✅）
- **创建日期**: 2026-04-22
- **完成日期**: 2026-04-24（Sprint D）
- **Sprint H follow-up**: ADR-025 evaluate_pair_guards rule-aware 接口将 R6 调用从 `evaluate_guards(a,b)` 迁移到 `evaluate_pair_guards(a,b,rule="R6")`；deprecated 包装保留至 Sprint I 收口；R6 行为零变化（22 既有 R6 测试全绿）
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

## 4. Historian 建议（T-P0-027 Stage 5 路径 A，ruling 98de7bc）

> 来源：historian 判定卡 `docs/sprint-logs/T-P0-027/historian-ruling-qi-vs-weizi-qi.md` §3.4

- 同一 QID 但跨朝代 > 500 年的 merge 候选应自动降级为 pending_review，避免类似 false positive 再次发生
- 架构师注：500 年为参考起点，阈值由 T-P0-029 设计阶段细化
- 建议同时考虑 dynasty 显式不匹配（如"夏" vs "商"）作为第二个 trigger，覆盖 dynasty 字段非空的情况

### 首例证据

- 启（夏朝，~前 2070 年）↔ 微子启（商末周初，~前 1100 年）→ 跨 ~1000 年
- Wikidata Q186544 = 夏启；微子启正确 QID = Q855012
- seed_mapping 误判原因：Sprint B matcher R2 alias 匹配路径把"启"作为微子启的别名触发了对 Q186544 的命中

## 5. 不在本卡范围

- Wikidata 上游 bug 修复（非我方可控）
- seed_mappings schema 变更
- corrective seed-add（→ T-P0-030）
