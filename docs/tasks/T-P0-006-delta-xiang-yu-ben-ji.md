# T-P0-006-δ — 项羽本纪摄入 + identity resolution

- **状态**: done
- **开始**: 2026-04-25
- **完成**: 2026-04-26
- **优先级**: P0
- **主导角色**: 管线工程师
- **协作角色**: 首席架构师（Stage 0 brief + 闸门 ACK）/ 古籍专家（Stage 3 merge review）
- **依赖**: Sprint F ✅（V1 根因修复 + NER v1-r5 + V9 invariant）
- **所属 Sprint**: Sprint G

## 背景

Sprint G 主线任务。项羽本纪是《史记》十二本纪第八篇，聚焦秦末楚汉之际，人物密度高，以楚汉双方为主线。
与秦本纪（T-P0-006-γ）相比，跨朝代场景少（R6 guard 0 次拦截），但暴露了"同国同号跨时代"entity-level 歧义新类型（楚怀王 Group 13），升格 T-P0-031 独立处理。

Sprint F 修复（V1 根因 + NER v1-r5 + V9 invariant）在本 sprint 的生产数据上得到真实验证：
smoke 后 V1=0、V9=0 保持不变，是 Sprint F 修复有效性的核心证据。

## 结果

| 指标 | 值 |
|------|-----|
| 新增章节 | 史记·项羽本纪（45 段） |
| NER persons | 117 新增（ingest 后 555→672） |
| LLM 成本 | $0.60（$0.06 smoke + $0.54 stage2） |
| Merge proposals | 21 组（dry-run） |
| Historian 裁决 | 7 approve + 13 reject + 1 split |
| 实际 apply | 9 soft-deletes（7 approve + 2 G13 sub-merges） |
| Active persons | 555 → 672 (ingest) → 663 (post-merge) |
| Merge log | 83 → 92 (+9) |
| V1-V11 | 全绿（Sprint F 修复验证：新数据 V1+V9 +0） |

## Stage 追踪

| Stage | 内容 | Commit | 日期 |
|-------|------|--------|------|
| 0 | fixture + adapter + tier-s + disambig prep | 0b15f0e | 2026-04-25 |
| 1 | smoke (5 段, V1=0 验证 Sprint F 修复) | 76b3038 | 2026-04-25 |
| 2 | full ingest (45 段, 117 persons, $0.60) | 036e492 | 2026-04-25 |
| 3 | resolver dry-run report (21 proposals) | 727e37e | 2026-04-25 |
| 3b | historian merge review (7/13/1 ruling) | fdfb7cb | 2026-04-25 |
| 4 | apply_merges (9 soft-deletes) | e83a7a3 | 2026-04-26 |
| 5 | task card + debt stubs + STATUS + CHANGELOG + retro | (C32+C33) | 2026-04-26 |

## 衍生债

| ID | 标题 | 优先级 | 触发源 |
|----|------|--------|--------|
| T-P0-031 | 楚怀王 Entity Split (熊槐/熊心 同号异人) | **P0** | historian G13 split 裁决（已创建 stub） |
| T-P1-027 | disambig_seeds 楚汉多义封号扩充 | P1 | historian §4.3（齐王/楚王/汉王/怀王 多义） |
| T-P1-028 | R1 dynasty 前置过滤（减少跨国 FP） | P1 | historian §4.4（13/21 reject 根因） |
| T-P2-005 | NER v1-r6 楚汉封号+名 few-shot | P2 | historian §4.5（韩王成/齐王建模式） |

## 关键发现

1. **Sprint F 修复真实生产验证**：smoke + full ingest 全程 V1=0、V9=0，证明 load.py Bug 1+2 修复覆盖了楚汉时段 NER 输出（117 新增 persons，0 V1 新增）。
2. **楚怀王同号异人（CRITICAL）**：G13 暴露了"同国同号跨时代"entity-level 歧义——战国楚怀王·熊槐 vs 秦末楚怀王·熊心。R1 surface match 框架无法自动区分，需 historian 历史知识介入。升格 T-P0-031 P0。
3. **R1 false positive 延续**：21 组中 13 组（62%）为 reject（其中 12 组是秦γ 已裁决的残留），根因同秦γ——R1 不考虑 dynasty。T-P1-028 是根源改进路径。
4. **textbook-fact precedent 2/3**：G15 项籍→项羽（manual_textbook_fact）为第 2 个案例，再积 1 例触发 ADR-014 addendum。G13 canonical=熊心 是 historian 领域 override（personal-name 优先于 posthumous-title convention）。
5. **NER v1-r5 无回归**：新章节的楚汉人物 auto-promotion 告警（熊心/刘邦/韩成/田建/刘盈/吕雉/司马迁）均属正常 NER 行为（canonical name vs text surface form 不匹配），v1-r5 修复方向正确。
6. **R6 cross-dynasty guard = 0**：楚汉同时段（秦末/秦末汉初/西汉），0 次跨朝代拦截，符合 Sprint G brief 预期（stop rule #5 未触发）。

## 关联文档

- docs/sprint-logs/T-P0-006-delta/dry-run-resolve-2026-04-25.md
- docs/sprint-logs/T-P0-006-delta/historian-review-2026-04-25.md
- docs/sprint-logs/sprint-g/stage-0-brief-2026-04-25.md
- docs/sprint-logs/sprint-g/sprint-g-retro.md
- ops/scripts/one-time/apply_xiang_yu_ben_ji_merges.py
- ops/rollback/pre-T-P0-006-delta-stage-4.sql
