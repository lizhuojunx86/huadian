# audit_triage — Conceptual Model

> Companion to README.md. Covers the **why** behind the design.
> Source: 华典智谱 Sprint K 实战 + ADR-027 + methodology/05-audit-trail-pattern.md
> Status: v0.1 (Sprint Q)

## 0. 本文件目标

README.md 告诉你 **怎么用**。本文件告诉你 **为什么这样设计**。

如果你只是要 fork 框架做你自己领域的 instantiation，README 够了。
如果你要：
- 修改 framework 本身
- 跨 stack port 框架（如 Java / Go）
- 评判设计取舍 / 写 ADR
- 在 docs/methodology/05-audit-trail-pattern.md 之上做迭代

→ 本文件是必读。

---

## 1. 三表协作模式（核心抽象）

### 1.1 三表的角色

```
┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│  pending_review  │ →  │ triage_decisions │ →  │   audit_log      │
│    队列          │    │  人决策审计      │    │  执行不可变记录  │
└──────────────────┘    └──────────────────┘    └──────────────────┘
       PE 写                 Hist 写                 PE V0.2 写
       Hist 读              Hist + PE + Architect   All 读
                            读
```

| 表 | 例（华典）| 写者 | 读者 | 不变性 |
|----|-----|------|------|------|
| `pending_review` | seed_mappings + pending_merge_reviews | Pipeline (insert) + V0.2 PE async (update status) | Domain Expert via UI | 可状态迁移（pending → decided）|
| `triage_decisions` | triage_decisions | Domain Expert via UI | Architect / Pipeline / cross-sprint hint | **append-only**（只插不删不改）|
| `audit_log` | merge_log + entity_split_log | Pipeline V0.2 apply | All（invariant test / 数据回溯）| **append-only** |

### 1.2 为什么是 3 表而不是 1 表 / 2 表

#### 反方案 A：1 表（candidate + decision + applied 同一行）

❌ 同一行多用途：
- candidate = pending state（应可被 PE update）
- decision = audit state（必须 immutable）
- applied = data layer state（V2 hook）

3 个生命周期挤一行 = schema 撕裂 / 索引膨胀 / migration 灾难。

#### 反方案 B：2 表（pending_review + audit_log，无 triage_decisions）

❌ 决策记录散落：
- approve → 直接进 audit_log（merge 行）
- reject → ？写哪？只能写 pending_review.notes 字段
- defer → ？无地方放

→ 3 个决策 verdict 中 reject + defer 没有 first-class 表，跨 sprint 回查靠 grep。

#### 正方案 C：3 表

✅ 每个表职责单一 + 每个 verdict 都有 first-class 行 + cross-sprint hint banner 自然落地。

**这是 audit_triage 框架的核心抽象**——任何一个 KE 项目，但凡涉及"AI candidate + 人决策 + 异步 apply"的工作流，3 表协作都是底层模式。

---

## 2. 复合 ItemId 设计 — `<kind>:<source_id>`

### 2.1 为什么不直接用 source_id

`pending_review` 在 HuaDian 是两张表的 UNION（seed_mappings + pending_merge_reviews）。这两张表的 UUID 命名空间**独立**——理论上可能 collision（实际 UUIDv4 几乎不可能但语义上不该 rely on）。

→ 所以暴露给 UI / API 的 ID 必须含 `kind` 信息。

### 2.2 选 colon-separated 而不是 JSON / 元组

- HTTP/GraphQL 友好（URL safe / scalar string）
- 人读友好（debug log / error message 可直接读懂）
- 向后兼容（增加 kind 不破坏 prefix-by-source_id 的查询）

### 2.3 Cross-domain 适用性

法律：`contract_party_match:abc-uuid` / 医疗：`drug_substitution:def-uuid` / etc。框架不绑定 kind 的具体取值，只约束 colon-separated 的 wire format。

---

## 3. Surface-cluster + FIFO 排序（V1 inbox 算法）

### 3.1 为什么不直接 FIFO

纯 FIFO（按 pending_since DESC）的痛点：

> Hist 上午看一个"周成王"的 candidate，决策完。下午 inbox 里又出现"周成王"的另一个 candidate（来自不同 source_table）。Hist 已经忘记上午的决策细节，又要重新 grep 几个 sprint 的 markdown。

→ V1 算法把同一 surface 的所有 candidates 聚到一起：

```
ORDER BY cluster_anchor ASC,         -- cluster = 同 surface 的最早 pending_since
         surface ASC,                 -- cluster 内 stable
         pending_since ASC,           -- cluster 内 FIFO
         source_id ASC                -- 终极 tiebreaker (idempotent)
```

### 3.2 cluster_anchor 是怎么算的

```sql
SELECT surface, MIN(pending_since) AS anchor
FROM all_pending
GROUP BY surface
```

cluster_anchor = "这个 surface 最早什么时候首次 pending"。这样：
- 老问题先解决
- 同一 surface 的所有 candidates 一起处理（缓解上下文切换）

### 3.3 V2+ 备选算法（不在 v0.1）

- **AI suggested_decision 排序**：把模型自动建议的"高确定性 reject"优先（让 Hist 快速过批）
- **Domain Expert 偏好**：让 Hist 自定义 "今天我先看 X 类型的 candidates"
- **协作锁**：多个 Hist 时 cluster-level 锁（避免重复审）

V1 / V0.1 故意保持简单——首先证明三表协作 + Surface-cluster 解决主要痛点。

---

## 4. 多值审计（per source_id）

### 4.1 必要性：defer → revisit → approve workflow

真实场景（Sprint G 实证）：
- Day 1: Hist 看到 candidate → 资料不够 → defer
- Day 5: 翻完《左传》补到证据 → revisit 同一 candidate → approve

→ 同一 source_id 必须允许 ≥ 2 行决策记录。

### 4.2 为什么不用 status update

```sql
-- 反方案：UPDATE triage_decisions SET decision='approve' WHERE ...
```

❌ 丢失 defer 的轨迹。Audit trail 失去意义。

### 4.3 应用层的"effective decision"

应用层查"当前有效决策"用：

```sql
SELECT * FROM triage_decisions
WHERE source_table=$1 AND source_id=$2
ORDER BY decided_at DESC
LIMIT 1
```

→ 最新一行 = effective verdict。

---

## 5. Surface 冻结（surface_snapshot）

### 5.1 痛点：源行 surface 变化

真实场景（Sprint H 楚怀王 entity-split）：
- Day 1: pending_merge_reviews 行 surface = "楚怀王"
- Day 3: PE 在 entity-split 后改了 surface 为 "楚怀王 (前期)"
- Day 4: Hist 想看 "楚怀王" 的 hint banner → 搜 "楚怀王" 找不到 day 1 的 candidate（surface 变了）

### 5.2 解决：决策时立即冻结

`triage_decisions.surface_snapshot` = 决策那一刻 `pending_review.surface` 的快照。源行后续修改 / 删除 / split 都不影响 hint banner 查询。

→ Hist 永远能用 "原始 surface 字符串" 找到所有历史决策。

### 5.3 代价

冗余 storage（每行都存 surface）+ 索引（idx_triage_decisions_surface）。

但 `triage_decisions` 行数级别为 100s ~ 10k（每个 sprint 几十到几百），冗余可忽略。

---

## 6. 6 quick-template reasons（DEFAULT_REASON_SOURCE_TYPES）

### 6.1 为什么需要

Hist 写 reason_text 是 markdown free-form，但**统计时需要分类**：

> "这个 sprint Hist reject 60%, 主要 reason source 是什么？"
> "跨 sprint 同 surface 簇的 reject reason 是否一致？"

→ free-form text 需要 NLP 才能分类；引入 controlled vocabulary 让 Hist 在 UI 上选 + tag。

### 6.2 6 个 default tags 怎么选的

来自 Sprint G/H/I/J 实证 Hist 真实写过的 reason source：

1. **`in_chapter`** — 同章节内的明确互称 / 上下文证据
2. **`other_classical`** — 其他古籍的交叉引用
3. **`wikidata`** — 结构化知识库
4. **`scholarly`** — 现代学术（论文 / 注本）
5. **`structural`** — schema 级结论（slug-dedup / split-for-safety）
6. **`historical-backfill`** — Sprint K Stage 2.5 的批量回填 artifact

### 6.3 跨域扩展

法律可能用：`contract_text` / `case_law` / `regulatory` / `client_communication`
医疗可能用：`patient_record` / `clinical_guideline` / `peer_consultation` / `imaging`

→ 框架通过 `ReasonValidator` Protocol + `DefaultReasonValidator(allowed=...)` 让案例方传自己的词汇。

---

## 7. 零下游 (zero-downstream) 设计

### 7.1 V0.1 strict contract

`record_decision` 只 INSERT `triage_decisions`，不动：
- pending_review 表的 status
- 数据层（persons / merge_log / 等）

### 7.2 为什么

3 个 reason：

1. **解耦决策行为 + 数据 mutation 的事务边界**
   - 决策本身要快（Hist 等 Triage UI 响应）
   - 数据 mutation 可能慢（merge 涉及 person_names / source_evidences / etc）
   - 同事务 = Hist 等数据库锁释放 / rollback 灾难

2. **测试 / dry-run 友好**
   - 测试只需要 mock TriageStore，不需要起完整数据层
   - dry-run 可以"决策但不 apply"做演练

3. **Architect ACK 二审能力**
   - Hist 决策后，Architect 可在 apply 前再审一遍 `triage_decisions`
   - 发现 Hist 误判 → 写 reverse decision 再 apply → 数据层无破坏

### 7.3 V0.2 路径

`DecisionApplier` Protocol + 异步 job 扫描 `WHERE downstream_applied=false`：
1. fetch 最新 effective verdict per source_id
2. 调用 `applier.apply(record)` 执行数据 mutation
3. UPDATE `downstream_applied=true / downstream_applied_at / by`

V0.2 仅 framework 提供 hook + scaffolding；具体 mutation 还是案例方实现（per `DecisionApplier` Protocol）。

---

## 8. Plugin Protocol 数 — 5 个 vs Sprint N 9 个 vs Sprint O 4 个

| Sprint | 模块 | Protocol 数 | 平均文件 line |
|--------|------|-----------|--------------|
| N | identity_resolver | 9 | ~200 |
| O | invariant_scaffold | 4 | ~120 |
| **Q** | **audit_triage** | **5** | **~230** |

audit_triage Protocol 数适中：
- 多于 invariant_scaffold（pattern 是 ABC 类层次 / 不需要 Protocol 那么多）
- 少于 identity_resolver（identity 是 R1-R6 + guards / 高 plugin 度）
- 与业务复杂度相称（store + authz + reasons + kind registry + applier hook）

---

## 9. 与 methodology/05-audit-trail-pattern.md 的关系

`methodology/05-audit-trail-pattern.md` v0.1（339 行）是**抽象方法论文档**：讨论"为什么需要这个 pattern" + "schema 抽象设计" + "跨域指南" + "反模式"。

`framework/audit_triage/` 是**该方法论的具体 Python 实现**：
- §2.2 schema 抽象 → `schema.sql` reference DDL
- §3 三表协作 → `TriageStore` Protocol + `service.py` orchestration
- §4 跨 sprint hint banner → `decisions_for_surface` API + `surface_snapshot` 冻结
- §5 反模式 → README §5 表格 mirror + framework 通过 Protocol design 防止陷入反模式

methodology/05 v0.1.1（Sprint Q 批 5 起草）将加 `§Framework Implementation` 段引用本框架。

---

## 10. 与 ADR-027 的关系

ADR-027 (Pending Triage UI Workflow Protocol, 488 行) 是 V1 落地决策记录：
- §2 V1 设计目标（surface-cluster + FIFO + 零下游 + hint banner）
- §3 schema decision rationale（多值审计 + surface 冻结 + downstream_applied）
- §4 GraphQL 接口（不在 framework 抽象范围）
- §5 V1 → V2 迁移路径（DecisionApplier hook）

→ ADR-027 是华典智谱项目内的"为什么这么落地"。
→ methodology/05 是把 ADR-027 抽象到"任何 KE 项目通用"。
→ framework/audit_triage/ 是把 methodology/05 落实成可运行的 Python 代码。

三者关系：

```
ADR-027 (项目决策)
    ↓ 抽象 / 通用化
methodology/05 (跨域方法论)
    ↓ 实现
framework/audit_triage/ (Python 代码)
    ↓ 实例化
examples/huadian_classics/ (回到原始案例)
```

闭环验证：framework 跑 dogfood 在 huadian_classics 上 = production behavior 等价 = 抽象正确。

---

**audit_triage CONCEPTS v0.1 / Sprint Q Stage 1 / 2026-04-30**
