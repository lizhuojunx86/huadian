# Sprint J Stage 1 Smoke Report — 高祖本纪

- **日期**: 2026-04-28
- **Chapter**: 高祖本纪 smoke（前 5 段 / shiji-gao-zu-ben-ji-smoke）
- **Book ID**: 96afbeb1-29e4-4f01-9e65-7adae00de058
- **目标**: V1=0 / V9=0 / cost≤$0.10 / 无 Stop Rule 触发

---

## 结果

| 指标 | 值 | 阈值 | 状态 |
|------|----|------|------|
| V1 (多主名) | 0 | = 0 | ✅ |
| V9 (无主名) | 0 | = 0 | ✅ |
| Paragraphs processed | 5/5 | 5 | ✅ |
| Persons extracted | 20 | — | — |
| Persons merged | 14 unique | — | — |
| Persons inserted | 9 new | — | — |
| Persons updated | 5 existing | — | — |
| Cost | $0.0422 | ≤ $0.10 | ✅ |
| Prompt version | ner/v1-r5 | v1-r5 | ✅ |
| Active persons (post) | 672 | — | — |
| merge_log | 92 | 92 | ✅ |

## T-P1-004 Auto-promotions

3× CRITICAL auto-promotion（0 primaries, no name_zh match）：
- 刘太公 → promoted '太公'（NER 返回 name_zh=刘太公 但 surface_forms 无完全匹配）
- 秦始皇 → promoted '秦皇帝'（秦始皇 未出现在 surface_forms 中）
- 刘盈 → promoted '孝惠'（孝惠帝/刘盈 name_zh 与 surface 对不上）

这些 CRITICAL 是 **已知 NER 行为**（model 有时将 name_zh 设成规范名而非文本出现形式），
由 T-P1-004 load 层兜底处理，V9 不受影响。不触发 NER 回归 Stop Rule（原有章节无新违例）。

## Stop Rule 检查

| Rule | 条件 | 本次 | 触发？ |
|------|------|------|--------|
| #1 V1/V9 ≠ 0 | V1=0/V9=0 | 0/0 | ❌ |
| #2 cost > $0.10 | $0.0422 | — | ❌ |
| #3 NER regression | v1-r5 行为正常 | — | ❌ |
| #4 V invariant regression | 全绿 | — | ❌ |

## 下一步

Stage 2 baseline: active_persons = 672（含 smoke +9）。
Stage 2 Full ingest: 79 paragraphs, budget ≤ $1.80。
