# T-P1-026 — disambig_seeds 跨国同名扩充

- **状态**: registered
- **优先级**: P1
- **主导角色**: 管线工程师 + 古籍专家
- **触发事件**: T-P0-006-γ historian-review-2026-04-25.md §4.4

## 背景

秦本纪 dry-run 暴露 R1 对跨国同名的大量 false positive（§3.2 中 16 组有 14 组）。根因是 R1 仅基于名称字面匹配，不考虑 dynasty。

短期应将本次 reject/split 的跨国同名对加入 disambig_seeds.seed.json，防止未来 batch 重复产生 false positive。

## 需补充的 disambig 组

| Surface | 涉及国家 |
|---------|---------|
| 桓公 | 秦/鲁/齐 |
| 灵公 | 秦/晋 |
| 悼公 | 晋/齐 |
| 庄公 | 秦/齐/郑 |
| 简公 | 秦/齐 |
| 惠公 | 秦/晋 |
| 襄公 | 秦/齐/晋 |
| 怀公 | 秦/晋 |
| 平公 | 晋/齐 |
| 成王 | 周/楚 |

## Scope

1. 在 `data/dictionaries/disambiguation_seeds.seed.json` 新增上述 10 组
2. 每组标注涉及的 person_id 和 dynasty
3. 建议在 batch 2 推进前完成

## 中期方向

评估 R1 规则是否应引入 dynasty 前置过滤（类似 R6 cross-dynasty guard），从源头减少 false positive。

## 验收标准

- [ ] disambig_seeds.seed.json 新增 10+ 组跨国同名条目
- [ ] historian 审核确认条目正确性
- [ ] 现有 resolver 测试通过（无回归）
