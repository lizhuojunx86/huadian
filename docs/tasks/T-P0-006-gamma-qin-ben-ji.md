# T-P0-006-γ — 秦本纪摄入 + identity resolution

- **状态**: done
- **开始**: 2026-04-24
- **完成**: 2026-04-25
- **优先级**: P0
- **主导角色**: 管线工程师
- **协作角色**: 首席架构师（Stage 0 brief + 闸门 ACK）/ 古籍专家（Stage 3 merge review）
- **依赖**: T-P0-029 ✅ / T-P0-030 ✅ / Sprint D ✅
- **所属 Sprint**: Sprint E Track B

## 背景

Sprint E Track B 的主线任务。秦本纪是《史记》十二本纪第五篇，内容跨越秦先祖至秦庄襄王约 600 年，人物密度高，跨国同名歧义严重（多国"桓公""灵公""惠公"等），是对 R1 规则和 historian 裁决流程的压力测试。

## 结果

| 指标 | 值 |
|------|-----|
| 新增章节 | 史记·秦本纪（72 段） |
| NER persons | 266 (新增) |
| LLM 成本 | $0.83 |
| Merge proposals | 35 组 (dry-run) |
| Historian 裁决 | 21 approve + 5 reject + 9 split (7 sub-merge) |
| 实际 apply | 29 soft-deletes |
| Active persons | 319 → 585 (ingest) → 556 (post-merge) |
| Merge log | 53 → 82 (+29) |
| V1-V11 | 全绿（V1=94 存量 T-P1-022；V10a 1 例修复后归零） |

## Stage 追踪

| Stage | 内容 | Commit | 日期 |
|-------|------|--------|------|
| 0 | fixture + adapter + tier-s + disambig prep | d818330 | 2026-04-24 |
| 1-2 | smoke + full ingest (72 段, 266 persons, $0.83) | eb8c4de | 2026-04-25 |
| 3 | resolver dry-run report (35 proposals) | 0ce12a9 | 2026-04-25 |
| 3b | historian merge review (21/5/9 ruling) | 3280a35 | 2026-04-25 |
| 4 | apply_merges (29 soft-deletes) + V10a seed fix | 2ac8956 | 2026-04-25 |
| 5 | task card + debt stubs + STATUS + CHANGELOG + retro | (C16+C17) | 2026-04-25 |

## 衍生债

| ID | 标题 | 优先级 | 触发源 |
|----|------|--------|--------|
| T-P1-024 | tongjia.yaml 扩充（缪/穆、傒/奚） | P1 | historian-review G6/G25 |
| T-P1-025 | 重耳↔晋文公 merge 检查 | P1 | historian-review G17 reject |
| T-P1-026 | disambig_seeds 跨国同名扩充 | P1 | historian-review §4.4 |
| T-P2-004 | NER prompt v1-r5 质量改进 | P2 | dry-run §4 auto-promotion |

## 关键发现

1. **R1 跨国同名 false positive 严重**：35 组中 16 组来自 §3.2 跨国歧义（桓公/灵公/惠公/襄公/庄公/简公等），R1 仅基于名称字面匹配，不考虑 dynasty
2. **Historian split 内 sub-merge 格式化**：9 组 split 中 7 组含安全子合并，historian 报告格式明确标注，PE 解释成本大幅降低
3. **V10a seed_mapping 跟随 merge**：G14 秦孝公 slug 去重后 seed_mapping 需手动 redirect 到 canonical——未来应考虑 apply_merges 自动处理

## 关联文档

- docs/sprint-logs/T-P0-006-gamma/dry-run-resolve-2026-04-25.md
- docs/sprint-logs/T-P0-006-gamma/historian-review-2026-04-25.md
- docs/sprint-logs/sprint-e/sprint-e-retro.md
- ops/scripts/one-time/apply_qin_ben_ji_merges.py
