# ADR-023 — V8 Invariant 引入：Prefix-Containment 检测 + Evidence/Alias 豁免

- **Status**: Accepted
- **Date**: 2026-04-21
- **Authors**: 首席架构师（决策）+ 管线工程师（执行 + V8 SQL + self-test）
- **Related**:
  - ADR-022（NER 污染清理 vs Names-Stay 准则 — 互补，非 supersede）
  - ADR-014（canonical merge — names-stay 原则）
  - ADR-013（persons.slug partial UNIQUE — soft-deleted 过滤前例）
  - T-P0-019 α Stage 3（V8 引入的触发场景）
  - T-P1-015（F2 prefix residuals debt — 本 ADR 以规则精化方式关闭，非数据修改）
  - T-P1-022（canonical merge missed pairs — 本 ADR probe 顺手发现，单独追踪）

---

## 1. Context

### 1.1 触发

T-P0-019 α Stage 3 原本按照 F2 "短名污染" 假设计划硬 DELETE 3 行（伯 / 管 / 蔡）。Gate 0b 审计发现：

- 3 行全部 `source_evidence_id IS NOT NULL`（T-P0-024 α evidence 回填产出）
- 3 行原文上下文均为**古汉语 anaphoric short-form**（帝舜对伯夷的回指、史记"管蔡畔周"的并列缩略）
- `name_type='alias'`，已被正确分类
- ADR-022 三要素测试的 #1（Evidence 链零依赖）不满足 → 不适用硬 DELETE

### 1.2 根本问题

"F2" 本就不是正式规则——Stage 0a 用 ad-hoc SQL 手工识别候选。三个路径可选：

| 路径 | 做法 | 评价 |
|------|------|------|
| A. 直接 DELETE | 违反 ADR-022 | ❌ 错误 |
| B. 仅任务卡记录不处理 | F2 violation 保留 3（但其实是规则过度敏感） | ⚠️ 未来 ingest 可能重新制造同类问题，缺乏防御 |
| C. 立 V8 正式不变量 | prefix-containment + α/β 豁免 | ✅ 规则层精化 + 防未来回归 |

### 1.3 古汉语短形指代（Anaphoric Short-Form）的语义

上古—秦汉汉语文本中，**名已立则复指可省字**是成熟修辞现象：

- **《尚书·舜典》§15**：佥曰"伯夷！"帝曰"咨！伯，汝作秩宗"——同段立名后短形回指
- **《史记·周本纪》§22**："管叔、蔡叔群弟疑周公"→"管、蔡畔周"——并列缩略
- 此类写法在先秦—秦汉文献中**非罕见**，属合法修辞

LLM extractor 在 evidence 回填阶段正确识别并链接到段落证据。这些单字条目**不是** NER 分词错误，**是**合法别名。

---

## 2. Decision

### 2.1 新增 V8 不变量（与 V1-V7 同级）

**V8 definition**: "单字 person_name 若与另一 person 的长名构成前缀包含关系，且无 α/β 豁免，则视为违反。"

**SQL** (实际实现版本，已通过 282 tests)：

```sql
SELECT a.name AS short_name, pa.slug AS short_slug,
       b.name AS colliding_name, pb.slug AS colliding_slug
FROM person_names a
JOIN persons pa ON pa.id = a.person_id AND pa.deleted_at IS NULL
JOIN person_names b ON b.person_id != a.person_id
  AND length(b.name) > 1
  AND b.name LIKE a.name || '%'
JOIN persons pb ON pb.id = b.person_id AND pb.deleted_at IS NULL
WHERE length(a.name) = 1
  AND a.source_evidence_id IS NULL   -- filter α: no evidence backlink
  AND a.name_type NOT IN ('alias');  -- filter β: non-alias name_type
```

### 2.2 豁免语义

α 与 β 是 **OR 组合**（任一满足即豁免）。SQL 中表现为两条过滤条件的 AND（违反 = 同时不被 α 和 β 豁免），逻辑等价。

- **α 豁免（evidence-backed）**：`source_evidence_id IS NOT NULL`。语义：evidence 链是"实际文本出现"的客观信号。
- **β 豁免（alias-typed）**：`name_type = 'alias'`。语义：已被人工或 LLM 分类为合法别名。

任一独立信号均足以判定该行为合法别名。双重豁免（3 行现况）是"更稳妥"的证据，不是强制要求。

### 2.3 执行位置

- **与 V1-V7 同级**：每次 ingest / commit 触发；不走 TraceGuard sample-based QC
- **迁移/测试**：新增 V8 check SQL 到 invariants 套件，纳入 CI 回归门
- **Self-test 强制**：V8 实现必须带以下三测试，防御"沉默的 V8"：
  1. 生产数据 V8 = 0
  2. 注入无 evidence / 非 alias / 触发 prefix-containment 数据 → V8 抓到
  3. 注入 alias 单字 → V8 不报（β 豁免）

---

## 3. Rationale

### 3.1 为何比"所有单字名都查"更精准

V8 不瞄准"所有单字名"，只瞄准**确实可能造成歧义的**单字名（跨 person 前缀碰撞）。若未来语料引入真正的 1 字合法人名（罕见但可能），V8 不误伤。

### 3.2 为何 α/β 是 OR 不是 AND

- evidence 和 alias 分别是两个独立维度的合法性信号
- evidence = 客观文本证据；alias = 语义分类已审
- 强制 AND 会把"只被分类未被回填"或"已回填未被分类"的合法行误当违反
- OR 容忍两条路径任一成立

### 3.3 为何与 V1-V7 同级而非 TraceGuard QC

- V1-V7 是"永远 = 0"的硬不变量，每次 commit 都跑
- TraceGuard 是 sample-based，不保证覆盖
- Prefix-containment 未来静默回归（新 ingest 插入污染单字名）必须**当次被抓**，不能等下次 QC sweep
- Self-test 强制保证了 V8 检测路径的活性

### 3.4 为何不等 soft-delete 机制落地再处理

- Phase 0-1 规模小（3 行），用规则精化代替数据修改是最低成本路径
- soft-delete 机制落地的代价（schema + SELECT + ADR-013 联动）与收益严重不匹配
- V8 是防御未来污染的工具；今天没有污染，V8 也有价值

---

## 4. Consequences

### 4.1 正面

- Phase 0-1 F2 violations 归零（靠规则精化，不动数据）
- 未来 ingest 产生的同类污染**自动**被 V8 抓到，不需要人工 QC sweep
- 保留了 3 个合法古汉语短形别名（伯 / 管 / 蔡 → 伯夷 / 管叔 / 蔡叔）
- 与 ADR-022 互补：ADR-022 管硬 DELETE 准则，ADR-023 管检测规则，哲学共通（evidence 链是合法性的客观信号）

### 4.2 负面 / 需要接受

- invariants 套件扩一条（V1-V7 → V1-V8），CI / migration / docs 相应扩容
- V8 SQL 对 `persons.deleted_at` 双 JOIN，性能开销需在 Phase 2+ 数据量上重评（Phase 0-1 规模下无忧）
- 若未来需要把 α/β 豁免改 AND 或调整优先级，需新 ADR supersede 本 ADR

### 4.3 回滚路径

- V8 若在未来证明过度敏感或误伤：从 invariants 套件移除对应 check，CI 重新通过
- α/β 豁免逻辑若需调整：新 ADR 修订 §2.2，重新部署 SQL

---

## 5. Applied Examples

### 5.1 T-P0-019 α Stage 3（首次应用）

- **对象**：伯（bo-yi）/ 管（u7ba1-u53d4）/ 蔡（u8521-u53d4），3 行
- **Prefix-containment 碰撞**：
  - 伯 → 7 个碰撞对象（伯与 / 伯士 / 伯服 / 伯禹 / 伯臩 / 伯阳 / 伯阳甫）
  - 管 → 2 个（管仲 / 管叔鲜）
  - 蔡 → 1 个（蔡叔度）
- **豁免状态**：3 行均满足 α（source_evidence_id IS NOT NULL）和 β（name_type='alias'），V8 不报
- **结果**：V8 = 0 violations，3 行保留，无数据修改
- **副产品**：probe 暴露疑似 canonical merge 遗漏（管叔 vs 管叔鲜，蔡叔 vs 蔡叔度）→ T-P1-022

---

## 6. Known Follow-ups

- **T-P1-022**（本 ADR probe 发现）：canonical merge missed pairs（管叔/管叔鲜, 蔡叔/蔡叔度）需 ADR-014 execution model 覆盖处理
- **Phase 2+ 性能评估**：V8 SQL 的双 JOIN 在百万级 `person_names` 下的性能需重评，可能需要 index 优化或改查询形态
- **V8 expansion**：未来若发现其他 prefix-containment 边界情况（例如 2 字名的子串碰撞 1 字 alias），本 ADR 可能需升级或新 ADR 扩展

---

## 7. Relationship to ADR-022

ADR-022 和 ADR-023 共存，职责分工：

| 维度 | ADR-022 | ADR-023 |
|------|---------|---------|
| 对象 | 硬 DELETE 决策准则 | V8 invariant 定义 |
| 触发 | 架构师判定某行是否适用硬 DELETE | 每次 commit / ingest 自动检查 |
| 豁免哲学 | 三要素全满足才 DELETE（AND） | evidence OR alias 即豁免（OR） |
| 时机 | 一次性清理（retrospective） | 持续防御（prospective） |

两者都采纳 "evidence 链是合法性客观信号" 作为共同哲学。ADR-023 不 supersede ADR-022，是 supplement。
