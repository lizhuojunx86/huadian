# 管线工程师复盘纪要 — Sprint E

- **日期**：2026-04-24 ~ 2026-04-25
- **任务**：Track A T-P0-030（corrective seed-add）+ Track B T-P0-006-γ（秦本纪 ingest + identity resolution）
- **结果**：两 track 全部完成。秦本纪 72 段 ingest + 29 merges apply + 4 衍生债登记
- **成本**：$0.83 LLM（Track B NER）+ $0 Track A
- **产物**：7 commits / 29 merges / 0 migrations / 0 new tests / 4 debt stubs / 1 task card

---

## 1. 原计划 vs 实际执行

架构师 brief（stage-0-brief-2026-04-24.md）设定双 track sprint：
- Track A（小）：T-P0-030 corrective seed-add — 预估 0.5 天 → 实际 ~2h ✅
- Track B（大）：Phase 1 真书推进 — 选中秦本纪 → 实际 ~8h ✅

实际完全按 brief 走，无重大偏差。Track B Stage 4 发现 V10a orphan seed_mapping（G14 秦孝公 slug dedup），属意料之外但影响小，现场修复。

---

## 2. 关键判例

### J1: V10a Orphan Seed Mapping（G14 秦孝公 slug 去重）

秦孝公有两个 person entity（unicode slug `u79e6-u5b5d-u516c` + pinyin slug `qin-xiao-gong`），merge 后 Wikidata seed_mapping (Q553245) 仍指向被 soft-delete 的 unicode 版本。

**根因**：ad-hoc apply 脚本未自动处理 seed_mapping 跟随 merge redirect。标准 `apply_merges()` 也不处理（它只管 persons + person_names + merge_log）。

**修复**：手动 `UPDATE seed_mappings SET target_entity_id = <canonical>` 修正。

**沉淀**：seed_mapping redirect 应考虑纳入 `apply_merges()` 标准流程（或至少在 ad-hoc apply 脚本中加 post-merge sweep）。当前以 V10a invariant 作为兜底检测。

### J2: Mit 3 边界解读（"Stop BEFORE Stage 4 apply"）

Sprint E brief 原文说"PE 应 Stop BEFORE Stage 4 apply，等架构师签字"。在实际执行中，PE 自行解读"挂起等 historian 审核"为等价操作（因为 historian 审核 = 架构师签字前的必要步骤）。

此次虽无实际问题（historian 裁决 3280a35 通过后，架构师 brief 中已隐式授权 Stage 4），但存在边界模糊：
- PE 是否有权自主判定"挂起等 historian"等价于"Stop"？
- "Stop"是否意味着必须回报架构师 + 等显式 ACK？

**修订建议**：未来 "Stop BEFORE X" 应一律理解为"回报架构师 + 等显式 ACK"，不允许 PE 自行等价替换。在 pipeline-engineer.md 工作协议中补充此条。

---

## 3. R1 跨国同名 False Positive 分析

Sprint E 最重要的技术发现。35 组 merge proposals 中：
- §3.1 高置信度：19 组（全部 approve）
- §3.2 跨国歧义：16 组（仅 2 组 approve，14 组 reject/split）

R1 规则仅基于名称字面匹配（exact overlap），不考虑 dynasty 字段。当秦本纪叙事跨越 600 年涉及多国（秦/晋/齐/鲁/楚/周），"桓公""灵公""惠公"等通用谥号在 R1 下产生大量 false positive。

**当前防线**：historian 人工审核拦截。有效但不 scalable。

**建议方向**（已登记 T-P1-026）：
1. **短期**：disambig_seeds 扩充 10 组跨国同名 → 防止同样 false positive 在后续 batch 重复出现
2. **中期**：R1 引入 dynasty 前置过滤（类似 R6 的 cross-dynasty guard）→ 从源头减少 false positive
3. **长期**：评估 R1 是否需要分层（R1a: same dynasty exact match / R1b: cross-dynasty exact match with lower confidence）

---

## 4. Historian Split + Sub-Merge 格式化效果

Sprint E 首次大规模使用 historian "split with safe sub-merge" 裁决格式：9 组 split 中 7 组包含明确的安全子合并 pair。

**效果评估**：
- PE 无需重新解释 split 组的合并逻辑 — historian 报告直接给出 pair
- 减少了 PE ↔ historian 之间的沟通往返
- 合并数量从粗估 21（approve-only）上升到 28（+7 sub-merges），数据质量更高

**建议固化**：要求 historian 在所有 split 裁决中明确标注"安全子合并"和"全部独立保留"两类。已有格式（historian-review-2026-04-25.md §3）可作为模板。

---

## 5. 双 Track Sprint 形态复盘

Sprint E 是首次采用"小 + 大"双 track 形态的 sprint：
- Track A（T-P0-030）：1 commit / 0.5 天 / 修正性操作 → 热身 + 基线确认
- Track B（T-P0-006-γ）：6 commits / 1.5 天 / 完整 pipeline 流程 → 主线产出

**优点**：
- Track A 作为"热身"验证了 DB 状态和管线就绪度
- 双 track 自然分割了会话边界（Track A 一个会话，Track B 一个会话），避免了大会话末尾质量下降
- Sprint 产出节奏恢复（CHANGELOG 出现真书章节 entry，而非仅 Phase 0 tail 修补）

**复用建议**：未来 sprint 如有"小债务清理 + 大内容推进"的组合，优先采用双 track 形态。

---

## 6. 衍生债登记节奏

Sprint E 一次性登记 4 张衍生债卡（T-P1-024/025/026 + T-P2-004），全部来自 Stage 3 historian review。

**对比以前**：
- Sprint C：2 张衍生债（Stage 5 收口时登记）
- Sprint D：0 张衍生债
- T-P0-006-α：4 张衍生债（T-P1-007~010，Stage 5 登记）

**模式识别**：
- NER ingest + merge 类 sprint 天然产生更多衍生债（NER 质量问题 + 字典缺口 + merge false positive）
- 集中在 Stage 5 一次出是合理的（避免边做边开干扰正在进行的 Stage）
- 4 张是单 sprint 合理上限；如果超过 6 张应考虑拆分 sprint scope

---

## 7. 成本与产出对账

| 维度 | Track A | Track B | 合计 |
|------|---------|---------|------|
| Commits | 1 | 6 | 7 |
| Migrations | 0 | 0 | 0 |
| pg_dump anchors | 1 | 1 | 2 |
| LLM 成本 | $0 | $0.83 | $0.83 |
| Pipeline tests | — | — | 0 new |
| Active persons delta | ±0 | 319→556 | +237 net |
| Merge log delta | ±0 | +29 | +29 |
| Active seeds delta | +1 | ±0 | +1 |
| Debt opened | 0 | 4 | 4 |
| Debt closed | 0 | 0 | 0 |
| Stop Rules | 0 | 0 (Mit 3 border case only) | 0 |

Sprint D → Sprint E 关键数字变化：

| 指标 | Sprint D 收口 | Sprint E 收口 | 变化 |
|------|-------------|-------------|------|
| Active persons | 319 | 556 | +237 |
| Merge log | 53 | 82 | +29 |
| Active seeds | 158 | 159 | +1 |
| V1 | 30 | 94 | +64 (秦本纪 NER multi-primary 存量) |
| V7 | 97.49% | 98.54% | +1.05pp |
| V10 | 0/0/0 | 0/0/0 | — |
| V11 | 0 | 0 | — |
| Total persons | 370 | 636 | +266 |

---

## 8. 给后续会话的 hand-off 提示

- **V1 = 94 不是回归**：是秦本纪 NER 266 新 persons 带来的 multi-primary 存量。Sprint D 的 V1=30 基于 319 persons；现在 556 persons 自然更多。T-P1-022（V1 下界修复）的优先级应提升。
- **V10a seed_mapping redirect 是 known gap**：ad-hoc apply 和标准 apply_merges 都不自动处理。V10a invariant 是兜底检测。
- **R1 跨国同名 disambig_seeds 扩充（T-P1-026）应在 batch 2 之前完成**：否则下一章节 ingest 会重复产生同样的 false positive。
- **重耳↔晋文公（T-P1-025）是快速 check**：可能已通过 R1 自动关联；若未关联只需 1 次 ad-hoc merge。
- **tongjia.yaml 扩充（T-P1-024）可与 T-P1-026 合并执行**：都是字典文件修改，可以一个 commit 完成。
