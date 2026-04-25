# T-P1-025 — 重耳↔晋文公 merge 检查

- **状态**: registered
- **优先级**: P1
- **主导角色**: 管线工程师
- **触发事件**: T-P0-006-γ historian-review-2026-04-25.md (G17 reject + §4.2)

## 背景

G17 historian 裁决 reject（重耳 ↔ 秦文公 false positive）后，重耳 entity 独立保留。

重耳 = 晋文公（姬重耳，前697–前628），但 `jin-wen-gong` 已在 tier-s-slugs.yaml 中。需要检查：
- 重耳是否已通过 R1/R2 与 `jin-wen-gong` 关联？
- 若未关联，需补建 merge proposal 并 apply

## Scope

1. 查询 DB 确认 重耳 entity 和 jin-wen-gong entity 的关联状态
2. 若未关联：创建 merge proposal → historian 确认 → apply
3. 若已关联：close 本卡

## 验收标准

- [ ] 重耳 entity 与晋文公 entity 关联状态已确认
- [ ] 若需合并：merge proposal 创建 + historian 确认 + apply 完成
