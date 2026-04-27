# V12 Invariant 候选评估报告

> **角色**：管线工程师 (Opus 4.7 / 1M)
> **日期**：2026-04-27
> **关联**：
> - Sprint H stage-0 brief §4.1（V12 候选评估要求）
> - ADR-025 §6.3（V12 invariant 候选 — Phase 2+ Future Work）
> - ADR-026 §9（V12 invariant 候选 — P1 Sprint I follow-up）
> - T-P0-031 楚怀王 entity-split（V12 想要预防的问题类）
> **状态**：Sprint H Stage 4.7 评估完成；不实施本 sprint，登记为 backlog
> **Stop Rule #5 检查**：V12 实施需要 schema 变更 → 触发，不本 sprint 实施

---

## 1. V12 候选定义

> **V12（候选）**：无 entity 包含跨 ≥500yr 的 mentions

设计意图：在 entity-level 防止"楚怀王类"跨人聚合（熊槐 -296 vs 熊心 -206 / 90 年）的更广义形态（跨 dynasty 大跨度）。是 ADR-025（防未来 merge proposal）+ ADR-026（修当下 entity-split）之外的第三层防御。

---

## 2. 数据基础调研

### 2.1 现有可用 dynasty / time 信号

| 表 / 字段 | 含义 | 覆盖率 | 用于 V12 价值 |
|----------|------|--------:|---------------|
| `persons.dynasty` | entity 整体所属朝代 | 100%（663 active） | 单值，无法表达"该 entity 内 mentions 跨朝代" |
| `person_names` 列 | mention 文本 / type / SE | 100% name + name_type | **无 dynasty / 时代字段** ❌ |
| `source_evidences.book_id` | 该 mention 所在书 | 全部有 | 9 distinct books（仅《史记》本纪 + 《尚书》），书的"时代"由 books.dynasty 给出 |
| `books.dynasty` | 书的成书时代 | 9/9 books | "成书时代" ≠ "mention 描述对象时代"（如《史记·秦本纪》成书=西汉，但描述秦国跨春秋至秦） |
| `events` 表 | 历史事件（含时间） | **空表**（per Sprint D inventory） | ❌ 不可用 |

### 2.2 楚怀王 case 在各信号下的可拦截性

| 数据信号 | 是否能识别"楚怀王 entity 包含熊槐+熊心"问题? |
|---------|-------------------------------------------|
| persons.dynasty | ❌ 单值（修复前=战国），无法表达"内部跨代" |
| books.dynasty | ❌ 楚怀王的 mentions 全来自《史记》（西汉成书），无跨书差异 |
| source_evidences.book_id 跨度 | ❌ 仅秦本纪 + 项羽本纪两本纪，都《史记》，差异不显著 |
| 任何 mention-level dynasty 字段 | ✅ **唯一可拦截信号**（但 schema 不存在） |

**结论**：当前 schema **无 mention-level 时代信号**，V12 不可实施。

---

## 3. 实施方案对比

| 方案 | 路径 | schema 变更 | NER 改动 | 历史回填 | 实施成本 | 拦截 楚怀王 case? |
|------|------|:------------:|:---------:|:---------:|---------|:-----------------:|
| **A** Books-based weak V12 | entity 关联 SE 跨 ≥2 books AND books.dynasty midpoint 距离 > 500yr | 无 | 无 | 无 | **低**（< 2h） | ❌（同《史记》） |
| **B** Mention dynasty inferred via events | events 表关联 person，年代距离 | events 表激活 | 无 | events 表 ingest | 高 | ⚠️（待 events 数据） |
| **C** SE-level chapter dynasty 注释 | source_evidences 加 chapter_dynasty 字段 + 章节级注释 | +1 字段 + 注释表 | NER prompt 加章节 dynasty 推断 | 全 SE 回填 | 高 | ✅ |
| **D** Mention dynasty 字段（true V12） | person_names 加 mention_dynasty + mention_year_min/max | +3 字段 | NER prompt 升 v1-r6 加 mention dynasty | 全 person_names 回填 | **高**（≥ 2 sprints） | ✅（理想） |

**Stop Rule #5 触发**：方案 B/C/D 全部需要 schema 变更或大规模 NER 改动；不在本 sprint 实施。

方案 A 本 sprint 可即时落地，但**不拦楚怀王 case**（因为楚怀王 mentions 全在《史记》），实用性低。

---

## 4. 阈值建议（如未来实施）

| 场景 | 推荐阈值 | 理由 |
|------|----------|------|
| 方案 D（mention-level） | **500yr** | 与 ADR-025 R6 cross_dynasty_guard 一致；保守起点（mention 跨 500yr 是非常罕见的真实情况） |
| 方案 A（books-based） | **500yr 同 + 且必须同时跨 ≥2 books** | 防误报（单书跨长时代描述常见，如《史记》本身是这样） |

---

## 5. 实施成本估算（方案 D，理想路径）

| 阶段 | 工时 | 风险 |
|------|------|------|
| ADR-NNN（V12 设计） | 0.5 day | 低 |
| Schema migration（person_names + 3 字段） | 0.5 day | 中（涉及 ~3000 person_names 行回填） |
| NER prompt v1-r6（每 mention 输出 dynasty 推断） | 1 day | 中（dynasty 推断准确率需黄金集验证） |
| 全 corpus 回填脚本 + LLM 调用成本 | 1 day + ~$2 LLM | 中（成本可控） |
| V12 invariant SQL + self-tests（≥3） | 0.5 day | 低 |
| 联跑回归测试 + 全绿验证 | 0.5 day | 低 |
| **合计** | **4 days** | — |

如方案 D 用 mention-level dynasty 替代 ADR-025 R1 dynasty filter（方案融合），可降低重复成本。

---

## 6. 决议（per Stage-0 brief §4.1 + Stop Rule #5）

### 6.1 不在 Sprint H 实施 V12

理由：
- Stop Rule #5（schema 变更）触发
- 当前 ADR-025（防未来）+ ADR-026（修当下）已组成 2 层防御；V12 是第 3 层 belt-and-suspenders
- 楚怀王 case 是当前已知唯一案例（n=1），不足以驱动 schema 改动
- 实施成本（4 days + ~$2 LLM）远超 Sprint H 节奏

### 6.2 登记为 backlog follow-up（衍生债）

- **T-P2-008（候选）** ：V12 invariant — entity-level cross-time mention detection
  - 优先级：**P2**
  - 触发上调条件：未来再发现 ≥2 例同号异人 entity-split case
  - 推荐方案：方案 D（mention dynasty 字段，真 V12 语义）
  - 关联前置：ADR-025 +T-P0-031 已完成；events 表激活（独立 task）
  - 估算工时：4 days + ~$2 LLM 成本
  - 风险等级：中（NER dynasty 推断准确率需黄金集验证）

### 6.3 短期补强（已落地 Sprint H Stage 2）

ADR-025 R1 dynasty filter（threshold=200yr，pending_merge_reviews 集成）**已在 Sprint H Stage 2 落地**（commit 8501ab9 + dry-run 验证 commit 2b7cd0c），为"防未来"提供了结构性防御。

T-P0-031 楚怀王 entity-split 已在本 sprint Stage 3-6 完成数据校正（commit 14eb2f5），ADR-026 entity_split_log 提供了"修当下"的审计基础设施。

V12 仅在两层防御都漏检的极端 case 才需要触发；当前数据基础不支持立即实施。

---

## 7. 关联 ADR / 任务 影响

| 文件 | 是否需修订 | 内容 |
|------|:----------:|------|
| ADR-025 §6.3 | 否 | 已登记 V12 候选作 Phase 2+ Future Work |
| ADR-026 §9 | 否 | 已登记 V12 候选作 Sprint I follow-up |
| 本 sprint debt | ✅ | 加 T-P2-008 stub（V12 invariant，P2，触发条件 ≥2 例同号异人） |

---

## 8. 总结

| 维度 | 决议 |
|------|------|
| Sprint H 实施 | **否** |
| Stop Rule #5 触发 | **是**（schema 变更需求） |
| Backlog 登记 | T-P2-008（P2，触发条件 ≥2 例同号异人） |
| 推荐方案 | 方案 D（mention dynasty 字段，true V12） |
| 阈值 | 500yr（与 ADR-025 R6 一致） |
| 估算工时 | 4 days + ~$2 LLM |
| 当前替代防御 | ADR-025 R1 200yr guard（防未来）+ ADR-026 entity-split（修当下） |
