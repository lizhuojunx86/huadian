# T-P1-021: Canonical Merge Missed Pairs (管叔/管叔鲜, 蔡叔/蔡叔度)

- **状态**: registered
- **优先级**: P1 (housekeeping)
- **主导角色**: 管线工程师 + 历史学家
- **所属 Phase**: Phase 1
- **发现来源**: T-P0-019 α Stage 3 V8 prefix-containment probe (2026-04-21)
- **创建日期**: 2026-04-21

## 背景

T-P0-019 α Stage 3 的 V8 probe 暴露两对疑似同人重复条目：

| 短名 person | 长名 person | 关系 |
|------------|------------|------|
| u7ba1-u53d4 (管叔) | u7ba1-u53d4-u9c9c (管叔鲜) | 管叔 = 管叔鲜（周公弟，封管国，名鲜） |
| u8521-u53d4 (蔡叔) | u8521-u53d4-u5ea6 (蔡叔度) | 蔡叔 = 蔡叔度（周公弟，封蔡国，名度） |

两对在历史上都是**同一人**的省称与全称：
- "管叔" = "管叔鲜"（《史记·管蔡世家》：管叔鲜）
- "蔡叔" = "蔡叔度"（《史记·管蔡世家》：蔡叔度）

这些是 T-P0-006 α 周本纪 ingest 时产生的——NER 在不同段落分别提取了省称和全称，identity resolver 未能识别出它们是同一人（因为 R1 stop-word 匹配对"叔X"类型的包含关系不敏感）。

## 验收标准

- [ ] Historian 裁决确认两对为同人（预期确认，但需走 ADR-014 流程）
- [ ] 通过 `apply_merges()` 执行归并（管叔 → 管叔鲜 OR 管叔鲜 → 管叔，取 historian 裁决）
- [ ] 同理蔡叔/蔡叔度
- [ ] V1-V8 全绿
- [ ] person_names 上的短形别名（管/蔡）随归并自然迁移到 canonical person

## 关联

- 前置：无（可独立执行）
- 关联 ADR：ADR-014 (canonical merge execution model)
- 关联 probe：T-P0-019 α Stage 3 V8 prefix-containment probe（管 → 管仲/管叔鲜 碰撞列表）
- 关联 identity resolver gap：R1 stop-word 对"叔X"/"叔X名"包含模式不敏感 → 可能需要 resolver 规则扩展（但本任务 scope 仅限 data fix）

## 备注

- 管叔 还碰撞到 管仲（guan-zhong），但管叔 ≠ 管仲（不同历史人物），不在本任务 scope
- 本任务属 Phase 1 housekeeping，不阻塞 Phase 0 路线
