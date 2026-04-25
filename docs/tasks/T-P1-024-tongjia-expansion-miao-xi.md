# T-P1-024 — tongjia.yaml 扩充（缪/穆、傒/奚）

- **状态**: registered
- **优先级**: P1
- **主导角色**: 管线工程师 + 古籍专家
- **触发事件**: T-P0-006-γ historian-review-2026-04-25.md (G6, G25)

## 背景

秦本纪 historian 审核确认两对通假字关系，当前 tongjia.yaml 未收录：

1. **缪 → 穆**：上古音同属幽部明母，同音假借。段玉裁《说文解字注》记载。中华书局《史记》点校本注"缪音穆，即秦穆公"。
2. **傒 → 奚**：上古音同属支部匣母，声符替代型通假。《史记集解》引贾逵"傒，百里奚也"。

## Scope

- 在 `data/tongjia.yaml` 新增两条：
  - `variant: 缪, canonical: 穆, source: 段玉裁《说文解字注》幽部`
  - `variant: 傒, canonical: 奚, source: 《史记集解》引贾逵`
- R3 规则自动生效（无代码变更）
- 建议在 batch 2 推进前完成，确保后续 NER + resolve 可自动命中

## 验收标准

- [ ] tongjia.yaml 新增 2 条，source 字段标注学术来源
- [ ] 现有 R3 单元测试通过（无回归）
- [ ] 可选：新增 2 条 R3 unit test 覆盖 缪/穆 和 傒/奚
