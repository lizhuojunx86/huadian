# ADR-015 — Evidence 链填充方案（source_evidence_id 激活与渐进式回填）

- **Status**: Accepted
- **Date**: 2026-04-19
- **Authors**: 首席架构师
- **Related**:
  - ADR-009（Traceable nullable 放宽）—— 本 ADR 部分恢复 ADR-009 承诺的"渐进填充"路径
  - ADR-014（canonical merge execution model）§3 —— evidence 锚点对模型 A 的价值
  - T-P0-006-β retro §L3 —— evidence 链实际空壳的发现
  - docs/debts/T-P0-006-beta-followups.md F8 —— 本 ADR 起源
  - docs/decisions/rfc/evidence-chain-investigation-2026-04-19.md —— 技术现状调研
  - docs/00_项目宪法.md §C-1 / C-2 —— 数据第一性

---

## 1. Context

### 1.1 问题规模升级 — 不只是一列 NULL

T-P0-006-β followup F8 最初登记的问题是 `person_names.source_evidence_id` 全表 NULL（279 行，调研校正为 282 行）。2026-04-19 技术现状调研披露更严重的事实：

- `source_evidences` **表本身** 0 行
- `evidence_links` 表 0 行
- `feedback.evidence_id` 从未被写入
- `extractions_history` 0 行（C-11 违规，另案处理）

**整个 evidence 子系统从未被激活。** 这不是"给已有 INSERT 加一列值"，而是"首次启用一个空壳子系统"。

### 1.2 位置信息就在代码里，但被丢弃

调研 §B1 揭示：`_insert_person_names()` 调用时，`MergedPerson` 已携带 `chunk_ids: list[str]`（raw_texts.id）和 `paragraph_nos: list[int]`，但 INSERT 完全省略了 `source_evidence_id` 列。段落级定位所需的全部信息**已在内存中**，只差最后一步写入。这意味着"新行填段落级 evidence"的实装成本极低（~73 LOC）。

### 1.3 宪法 C-1 / C-2 的实质未满足

ADR-009 把 `Traceable.sourceEvidenceId` 从 non-null 放宽为 nullable，原设"渐进填充"。但 Phase 0 全部管线跑完，**渐进填充路径从未被走过**。C-2 勉强合规（`provenanceTier='primary_text'` 是枚举值占位），但 C-1 的"一次结构化 N 次衍生"**受到实质挑战** —— 衍生产品（原文定位高亮、搜索结果上下文、知识图谱溯源跳转）都需要真实 evidence 链支撑。

### 1.4 β 是第一个踩到后果的任务

β S-5 rollback 后用纯文本 INSERT 重建 3 行 person_names，发现全表 evidence 都是 NULL 后才意识到这是 pre-existing gap。β 暴露了该 gap 在 cross-book 压力下的副作用：无法对"此 name 源自哪段原文"给出机器化回答。

### 1.5 α 扩量会放大问题

α 路线规划 10+ 本书。若 evidence 链继续空置，α 结束时 person_names 规模可能达到数千行、全 NULL，回填成本将从"~300 行"放大到"数千行"，且越晚做越难。

---

## 2. Decision

### 2.1 总纲：渐进式激活 evidence 子系统

Evidence 子系统的激活采用**三阶段渐进式**策略，**不做一次性大爆炸**：

- **Stage 1**（本 ADR 生效起，α 第一本书启动前）：新行必填段落级 evidence；存量保持 NULL
- **Stage 2**（α 第一本书 ingest 期间）：存量 text-search 回填 + provenance tier 降级
- **Stage 3**（α 稳定后 / 按需）：span 粒度升级 + llm_calls.response replay 提纯

每阶段独立成任务卡 / 子 ADR。本 ADR 只确立框架与 Stage 1 的技术约束。

### 2.2 Stage 1：新行必填段落级 evidence（本 ADR 生效起强制）

**适用范围**：所有未来经 `load.py` 写入 `person_names` 的新行。

**强制要求**：

1. `_insert_person_names()` 每插入一行 person_names，必须**先**在 `source_evidences` 创建对应行，再以返回的 UUID 填入 `person_names.source_evidence_id`
2. `source_evidences` 行至少填写：
   - `raw_text_id` ← `MergedPerson.chunk_ids[0]`（first-seen 段落）
   - `book_id` ← 调用链透传
   - `provenance_tier` = `'primary_text'`
   - `prompt_version` ← `ExtractionResult.prompt_version`
   - `llm_call_id` ← 透传（需改 extract→load 透传链）
3. **不要求** `position_start` / `position_end` / `quoted_text`（Stage 3 再做，此阶段允许 NULL）
4. 变更必须通过 V5 invariant（§2.5）

**特殊情况**：

- 字典合成身份的 name 行：`source_evidence_id` 保持 NULL，但 `persons.provenance_tier` 必须明确为 `'seed_dictionary'`（新枚举值，§2.6），不得走 `'primary_text'`
- β rollback 重建的 3 行（`3e4f389a`）：保持 Stage 2 处理范围

### 2.3 Stage 2：存量 text-search 回填（α 第一本书期间完成）

**适用范围**：当前 282 行存量 + Stage 1 之前新增的任何遗留行。

**执行策略**：

1. 扫描 active person 的 person_names（约 242 行可回填），按 `(name, book_id)` 在 `raw_texts.raw_text` 做 `LIKE '%name%'` 反查，取**第一次命中**段落作为 evidence 锚
2. 写入 `source_evidences` 行，`provenance_tier = 'ai_inferred'`（**不得**用 `primary_text`——这是计算推断，不是 NER 原始输出）
3. `person_names.source_evidence_id` 指向该 evidence 行
4. Soft-deleted persons 的 33 行 name：同样 text-search 回填（价值有限但完整性优先）
5. 字典合成身份的行（司马迁 / 周成王 / 其他）：保持 NULL，在审计表备注

**禁止策略**：

- **禁止**在 Stage 2 启用 `evidence_links` 多对多表（延后到 Stage 3 或按需）
- **禁止**合成无意义的 `source_evidences` 行（沿袭 ADR-009 原则）
- **禁止**用 Stage 2 的回填冒充 Stage 3 的 span 粒度

**触发条件**：Stage 2 独立任务卡（T-P0-024），在 α 第一本书 ingest 开始前完成 Stage 1 实装，在 α 第一本书 ingest 期间（不阻塞）完成 Stage 2 回填。

### 2.4 Stage 3：span 粒度升级 + llm_calls.response replay（α 后视需求）

**条件触发**（非本 ADR 强制）：

- 产品需求需要 span 级高亮（如原文定位功能）
- 或 provenance 审计需要把 Stage 2 的 `ai_inferred` 行提纯为 `primary_text`

**主要动作**：

- NER prompt v1-r5 改版：要求 LLM 输出 `offset_start` / `offset_end`
- `llm_calls.response` replay 工具：parse 34+ 条历史响应，把 Stage 2 回填的 `ai_inferred` 行提纯为 `primary_text`
- `source_evidences` 行补 `position_start` / `position_end` / `quoted_text`

Stage 3 需要独立 ADR（预计 ADR-020+）。本 ADR 只保留升级路径的兼容性。

### 2.5 Schema 与 invariant

**schema 不变**：`source_evidences` 表结构已支持三级粒度（book / paragraph / span），本 ADR 不要求任何 schema migration（除 §2.6 的枚举扩展）。

**V5 invariant（新增）**：

```sql
-- V5: active persons 的 NER 派生 name 必须有 evidence 锚
-- （字典合成身份除外）
SELECT COUNT(*) FROM person_names pn
JOIN persons p ON p.id = pn.person_id
WHERE p.deleted_at IS NULL
  AND p.provenance_tier != 'seed_dictionary'
  AND pn.source_evidence_id IS NULL;
-- 期望：Stage 1 生效后新增行 = 0；Stage 2 完成后全库 = 0
```

V5 加入 `tests/test_merge_invariant.py`，初始**警告级**（报告数字不 fail），在 Stage 2 完成后升级**强制级**（fail build）。

### 2.6 `provenance_tier` 枚举扩展

当前 `provenance_tier` 枚举已有 5 个值：`'primary_text' | 'scholarly_consensus' | 'ai_inferred' | 'crowdsourced' | 'unverified'`（经 Stage 0 schema 核查确认）。

**本 ADR 扩展**：新增 `'seed_dictionary'` 值，用于字典种子合成身份（40 人字典种子、identity_resolver 生成的无 NER 来源的 alias 等）。

**与既有 `unverified` 的区分**：`unverified` 用于"未经任何来源确认"的条目；`seed_dictionary` 则用于字典种子合成身份——后者经 historian 签收，来源明确（字典本身），只是不来自 NER 抽取。两者语义不重叠，不可合并。

枚举扩展对应一个独立 migration。因是**新增值**而非改变，不触发 ADR-017 的"破坏性 schema 操作"条款，按常规 forward-only 走。

---

## 3. Rationale

### 3.1 为什么段落粒度先行

调研 §F3：段落粒度改动成本 S（~73 LOC），不改 prompt、不引入 LLM offset 精度风险，足以满足 C-1 / C-2 最低要求。Span 粒度（M ~133 LOC + prompt v1-r5）在 Phase 0 尾声不值得。

### 3.2 为什么 Stage 2 用 `ai_inferred` 而非 `primary_text`

存量回填本质是"基于 surface 文本反查段落"—— 计算推断而非 NER 原始输出。若标 `primary_text` 会掩盖"这段 evidence 不是抽取时刻捕获的"事实，混淆未来审计。`ai_inferred` 保留真实 provenance 语义，也为 Stage 3 replay 提纯提供明确目标（`ai_inferred` → `primary_text`）。

### 3.3 为什么不在本 ADR 处理 C-11

`extractions_history` 0 行是独立宪法违规，与 evidence 链填充**技术上耦合但决策上独立**：

- 技术耦合：Stage 3 的 replay 依赖有结构的 NER 历史
- 决策独立：evidence 链填充不需要先解决 C-11（Stage 1 用内存数据、Stage 2 用文本搜索均不依赖）

C-11 应另立 ADR（预计 ADR-018）+ 独立任务卡。

### 3.4 为什么渐进式而非一次性

调研 §C1 显示 282 行存量涉及复杂 case（β rollback 重建、字典合成、soft-deleted merged sources）。一次性回填即一次性对所有边角情况做决策，风险高 —— 正是 β S-5 一次性 ad-hoc SQL 踩的坑。分阶段把"新行 vs 存量"解耦，每阶段独立有 V5 快照做验证，回滚范围可控。

---

## 4. Consequences

### 正面

- 宪法 C-1 / C-2 从"最低合规"升级到"实质满足"
- ADR-009 "渐进填充"承诺开始兑现
- α 扩量时新 ingest 自动带 evidence（不放大问题）
- V5 invariant 把 evidence 空壳状态显式化，防止回退
- 为 Stage 3 的 span / replay 保留清洁升级路径

### 负面

- Stage 1 要求 extract→load 链透传 `llm_call_id`，涉及 NER 模块 refactor
- Stage 2 回填的"first-seen"是启发式决策（真正"首次出现"应由 historian 审定，成本过高）
- `seed_dictionary` 枚举扩展需协调 GraphQL schema 与前端
- Stage 2 的 `ai_inferred` 行在 UI 上需与 `primary_text` 作区别呈现（前端 follow-up）

### 风险

- Stage 1 若 book_id / llm_call_id 透传链出问题可能导致新 ingest 失败 → 4 闸门协议兜底
- Stage 2 对单字 surface（如"弃"）可能误匹配 → 缓解：search 必须 `(name, book_id)` 双键 + 单字 surface 需 historian 抽查

---

## 5. Non-goals

本 ADR **不**：

- 解决 C-11（`extractions_history` 0 行）—— 另立 ADR-018
- 激活 `evidence_links` 多对多表 —— Stage 3 按需
- 升级 NER prompt 到 v1-r5 —— Stage 3 按需
- 处理 `feedback.evidence_id` FK —— 等 feedback pipeline 实装（WARN C-21）
- 合成无语义的 `SourceEvidence` 记录以满足 non-null —— 明确拒绝（沿袭 ADR-009）
- 强制要求 `extractions_history` 写入 —— C-11 独立处理

---

## 6. Alternatives Considered

### 6.1 一次性全填（rejected）

把 Stage 1 + Stage 2 合并。拒绝理由：一次性面对所有边角情况风险高；β S-5 反面教材；V5 分阶段验证价值会丢失。

### 6.2 维持现状 + 扩展 provenanceTier 语义（rejected）

不激活 `source_evidences`，只扩展枚举使 NULL 不再空壳。拒绝理由：直接违反 C-1；ADR-009 明确禁止"magic string 代替 null"；合规形式上降级。

### 6.3 先做 F9（NER 落盘）再填 evidence（rejected as blocker）

拒绝理由：F9 不是 Stage 1 的必要前置（Stage 1 用内存数据）。F9 耦合会延迟 evidence 链激活。Stage 3 时 F9 可作 llm_calls.response replay 的替代品。

### 6.4 直接上 span 粒度（rejected）

拒绝理由：M cost + prompt 改版 + LLM 精度校验在 Phase 0 尾声不值得；分阶段可让 span 粒度在 α 数据量验证后再升级。

---

## 7. Compliance

本 ADR 生效后：

1. **Stage 1 实装为 T-P0-023** —— α 第一本书启动前必须完成
2. **V5 invariant 加入 CI 测试**（初始警告级）
3. **`load.py` / `extract.py` 改动走 4 闸门协议**（pipeline-engineer.md）
4. **Stage 2 回填为 T-P0-024** —— α 第一本书期间完成
5. **Stage 3 需另立 ADR**（预计 ADR-020+）

---

## 8. 后续任务

| 任务 | 说明 | 阶段 | 触发 |
|------|------|------|------|
| T-P0-023 | Stage 1：load.py evidence 写入 + extract→load llm_call_id 透传 + `seed_dictionary` 枚举 + V5 invariant | Stage 1 | 本 ADR 生效后立即 |
| T-P0-024 | Stage 2：存量 text-search 回填 + V5 升级为强制 | Stage 2 | α 第一本书期间 |
| ADR-018（建议） | `extractions_history` 违规处置 —— C-11 专项 | 独立 | 本 ADR 之后起草 |
