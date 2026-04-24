# Sprint D 复盘 — T-P0-029 R6 Cross-Dynasty Guard

> **日期**：2026-04-24
> **主导角色**：管线工程师
> **架构师参与**：brief + 2 次签字（α 选型 + Stage 2/3 放行）
> **总用时**：~3h（单会话）

---

## §1 Sprint 总账

| 指标 | 值 |
|------|-----|
| Commits | 4（inventory + Stage 1 impl + apply pass + closeout） |
| New tests | 22 |
| New table | pending_merge_reviews（migration 0012） |
| New module | r6_temporal_guards.py |
| New data | dynasty-periods.yaml（12 entries） |
| Active persons | 319（unchanged） |
| Pending merge reviews | 0（bootstrap） |
| LLM cost | $0 |
| Stop Rules triggered | 2 of 5（#2 baseline change + #5 α≠δ） |
| Stop Rules blocking | 0（both accepted） |

---

## §2 Stop Rules 复盘

### Stop Rule #2 — dry-run 拦截 0 个

**触发原因**：Sprint C path A 已将唯一的跨代 seed_mapping（wei-zi-qi → Q186544）从 active 降级为 pending_review。R6 pre-pass 只查 active mappings → 该 pair 不再出现在 detection 池中。

**架构师裁决**：接受为 "clean baseline change"，不是实施缺陷。22 unit tests + 4 integration tests 充分覆盖 guard 逻辑。

**Best practice 记入**：对于"预防性基础设施"类卡（guard/circuit breaker/rate limiter），干跑结果为 0 是合法的——基础设施不需要当下有活跃案例才有价值。未来类似 brief 应在 Stop Rule 中增加"if root cause = baseline change, accept without blocking"条款。

### Stop Rule #5 — 选型 α ≠ brief δ

**触发原因**：Stage 0 inventory 证实 β（events）表空 + γ（dictionary_entries dateOfBirth）未抓 → δ 退化为纯 α，hybrid 分支为死代码。

**架构师裁决**：α 通过。KISS 原则 > 假设性未来鲁棒性。

**Best practice 记入**：未来类似 brief 应增加"数据假设"段，明确列出各方案依赖的字段及其预期覆盖率。当假设被 Stage 0 数据推翻时，快速切换到 data-driven 方案。

---

## §3 架构得失

### 得

1. **新表 pending_merge_reviews 概念清晰**：pair-level blocked merge ≠ mapping-level pending_review，分离存储避免语义污染
2. **evaluate_guards() chain 可扩展**：`_GUARD_CHAIN` 列表添加新 guard 函数即可，不动主入口
3. **dynasty-periods.yaml 外部化**：historian 可独立增补朝代映射，不需改 Python 代码
4. **BlockedMerge 走 ResolveResult**：detection 纯函数 + DB write 在 apply 路径，关注点分离

### 失 / 待改进

1. **V1 FAIL=30 仍未收口**：T-P1-022 债务积累中，需尽快安排
2. **dynasty 粒度粗**：midpoint 距离对"商末周初 vs 西周"等边界案例精度有限（本卡无影响，但随数据增长可能需 events 补充）
3. **Pipeline migrations 双轨仍在**：T-P1-005 债务——pending_merge_reviews 又是 pipeline migration 建的表，与 Drizzle 管理的核心表不在同一入口

### 不开 ADR

pending_merge_reviews + guard pattern 目前只服务 R6 一个规则。等 T-P0-028 落地 + 模式增长后再考虑 ADR-024 "Guard-Blocked Merge Review Pattern"。

---

## §4 Sprint 流程改进建议

1. **Brief 增加"数据假设"段**：列明各候选方案依赖的字段 + 预期覆盖率，Stage 0 inventory 可直接对标
2. **Stop Rule 增加"baseline change"子句**：预防性基础设施类卡，dry-run 0 命中 + 根因为上游已修复 → accept without blocking
3. **retro 数据不需要回溯写入新表**：架构师裁决正确——seed_mapping 降级 ≠ guard-blocked merge，强行回填污染概念边界

---

## §5 Follow-up

| 任务 | 优先级 | 说明 |
|------|--------|------|
| T-P0-028 | 中 | Triage UI 同时读 seed_mappings(pending_review) + pending_merge_reviews(pending) |
| T-P0-030 | 中 | Corrective seed-add wei-zi-qi → Q855012（独立 track） |
| T-P1-022 | 中 | V1 下界 30 violations 收口 |

---

> 管线工程师签名：pipeline-engineer (Claude Opus)　日期：2026-04-24
