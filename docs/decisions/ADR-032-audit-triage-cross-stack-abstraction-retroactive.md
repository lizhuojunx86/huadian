# ADR-032 — audit_triage Cross-Stack Abstraction Decision (Retroactive)

- **Status**: accepted (retroactive)
- **Original decision date**: 2026-04-30（Sprint Q Stage 1 批 1 起草 audit_triage v0.1）
- **ADR drafted date**: 2026-04-30（Sprint V 批 1 历史回填 / per Sprint U retro §3.2 触发）
- **Authors**: 首席架构师
- **Related**:
  - ADR-027（Pending Triage UI Workflow Protocol）— audit_triage 抽象的 design intent 锚点
  - ADR-028（D-route 战略转型）— framework 抽象的战略基础
  - ADR-030（v0.3 release timing）— audit_triage v0.1 → v0.3 跳跃式 bump 的统一版本号决策
  - methodology/05-audit-trail-pattern.md v0.1.1（与本 ADR 同步起草 / Sprint Q 批 5）
  - methodology/07-cross-stack-abstraction-pattern.md v0.1（Sprint U 起草 / 抽出本 ADR 的 cross-stack pattern 通用化）
  - Sprint Q closeout §3.7（统一版本号策略 / Sprint P 模式延续）
  - Sprint U retro §3.2（识别"应起 ADR 但未起"gap → 触发本 ADR 回填）
- **Supersedes**: 无
- **Triggered by retroactive drafting**: methodology/06-adr-pattern-for-ke.md v0.1.1 §8.2 实证锚点表标注 "Sprint Q audit_triage 抽象 / 应起 ADR 但未起" → identified gap → Sprint U 触发 v0.4 候选 T-V04-FW-004 → Sprint V 批 1 land

---

## 0. 为什么这是一个 retroactive ADR

正常 ADR 流程是：决策**之前**起草 ADR / accept / 实施。

但 Sprint Q（2026-04-30）audit_triage 抽象的决策**未起 ADR**，原因：
- Sprint Q brief §1.3 是 "single-actor / 抽象 sprint" 形态
- 当时直接执行抽象（per methodology/05 design + ADR-027 业务流程）
- 未识别"跨 stack 抽象本身需要 ADR 决策记录"（per methodology/06 v0.1.1 §8.3 跨域 fork 启示后才识别）

Sprint U 完成 methodology/06 v0.1.1 + /07 v0.1（cross-stack abstraction pattern first-class doc）后，回看 Sprint Q：

- methodology/06 v0.1.1 §8.3 显式："跨 stack 抽象应起 ADR"
- methodology/07 v0.1 §1 显式：cross-stack 抽象是 first-class 决策（不是简单移植）
- methodology/02 v0.1.1 §13.5 显式：跨 stack 抽象**不替换生产实现**（重大决策 / 应有 ADR）

→ 触发本 ADR-032 历史回填。**回填 ADR 不是 fix bug，是补完整性**——让跨外部 reviewer / 未来案例方可以看到 Sprint Q 的决策记录（vs 仅 sprint-q closeout / retro 中提及）。

---

## 1. Context

### 1.1 Sprint Q 时刻状态

Sprint Q 启动时（2026-04-30 / per Sprint Q brief）：

- framework v0.2.0 已 release（Sprint P / 4 模块统一）
- audit_triage 是 framework 抽象的第 5 模块（per methodology/02 §12 5 模块齐备阈值预期）
- 生产实现：`services/api/src/services/triage.service.ts`（TypeScript / 922 行 / Drizzle ORM / Postgres-js）
- 生产 ADR：ADR-027 已记录 Pending Triage UI Workflow Protocol（业务流程 / 不涉及 stack 选择）

### 1.2 抽象目标 stack 的选择空间

3 个候选路径：

| 选项 | 路径 | 含义 |
|------|------|------|
| A | TypeScript framework | 与生产同 stack / byte-identical dogfood 可能 / 但 TS 在 KE / 数据科学 / 跨域 fork 案例方中较少 |
| B | Python framework | 跨 stack / soft-equivalent dogfood / Python 是 KE / 跨域案例方"普遍 stack"（per methodology/07 v0.1 §1.3）|
| C | Java / Rust / Go framework | 完全偏离 framework 既有 stack（Sprint N/O 已是 Python）/ 不连贯 |

### 1.3 Plugin Protocol 设计空间

audit_triage 业务逻辑包括：
- DB I/O（pending review queue + decision audit table）
- 历史决策者 authz
- 决策理由词汇校验
- ItemKind → source_table 映射
- V0.2 hook：决策 → 数据 mutation

5-7 个 Plugin Protocol 是合理范围（vs Sprint N identity_resolver 9 个 / Sprint O invariant_scaffold 4 个）。

---

## 2. Decision

**采用：选项 B（Python framework / 跨 stack）+ Approach B 最小 schema 子集 + 6 Plugin Protocol。**

详细：

### 2.1 Stack 选择 = Python

理由：
- 与 Sprint N identity_resolver / Sprint O invariant_scaffold 同 framework stack（连贯）
- Python 是 KE / 跨域 fork 案例方"普遍 stack"（per methodology/07 v0.1 §1.3）
- 生产 TS 实现保留（不替换 / per methodology/07 v0.1 §1.2 + §7.2 反模式）
- soft-equivalent dogfood 已被 Sprint O 实证可行（vs 跨 stack byte-identical 不可能）

### 2.2 6 Plugin Protocol 设计

| Protocol | 必要 | 职责 | 设计依据 |
|----------|------|------|---------|
| `TriageStore` | ✅ | DB I/O（list / find / insert / decisions queries） | 抽出 services/api triage.service.ts 17 functions 的 DB 触及部分 |
| `HistorianAllowlist` | ✅ | 决策者 authz | 抽出生产 HISTORIAN_ALLOWLIST 常量 + Sprint K 5 角色协作 |
| `ReasonValidator` | ⚪ | reason_source_type 校验 | 抽出生产 REASON_SOURCE_TYPES 6 元素 / 给案例方域 vocabulary 灵活度 |
| `ItemKindRegistry` | ⚪ | kind → source_table 映射 | 抽出生产 kindToSourceTable 函数 / 案例方域可扩 ItemKind |
| `DecisionApplier` | ⚪ | V0.2 hook：决策 → 数据 mutation | per ADR-027 §2.5 zero-downstream V1 / V0.2 留 hook |
| (默认实现) `StaticAllowlist` + `DefaultReasonValidator` | — | 给案例方"开箱即用" | 简化 fork 案例方启动 |

### 2.3 Approach B 最小 schema 子集（Sprint T 后追加 / 同 stack design）

per Sprint T T-V03-FW-005，dogfood infra 用 7 表 minimum 子集（vs 36+ 生产表）。本 ADR 同时 retroactive 记录此设计（Sprint T 完成后 Sprint Q 抽象的 dogfood path 完整化）。

### 2.4 V0.1 zero-downstream contract

per ADR-027 §2.5 + methodology/05 §3：record_decision 仅写 triage_decisions / 不动数据层。V0.2 通过 DecisionApplier 异步 hook（本 ADR §2.2 留接口 / 不实现）。

---

## 3. Consequences

### 3.1 已实证（Sprint Q + T）

| 维度 | 结果 |
|------|------|
| framework 模块完整性 | 5 模块齐备（per methodology/02 v0.1.1 §12）⭐ |
| dogfood ✅ | Sprint Q user local PASSED（list_pending 20/20 + decisions_for_surface 4 surfaces 全一致）|
| dogfood ✅ Docker | Sprint T sandbox PASSED（list_pending 6/6 + 4 surfaces 全一致）|
| Plugin Protocol 数 | 6 个（vs Sprint N 9 / Sprint O 4 / 适中）|
| 抽出代码量 | framework/audit_triage/ 14 files / 2553 行（含 examples + docs）|
| 抽出 vs 生产 ABI 兼容 | 完全保留生产 TS 不变（per methodology/07 §1.2 反模式 ✓）|
| 跨外部 fork 可读性 | scripts/README §5 跨域 fork 启示 + framework/audit_triage/cross-domain-mapping.md（7 领域指南）|

### 3.2 未实证 / 押后

- 真跨域案例方接触（DGF-N-04 / 等触发）→ 当前仅 huadian_classics 1 case
- audit_triage v0.2 DecisionApplier hook 实现 → 等业务方需求触发

### 3.3 触发的连锁决策

| 后续 ADR / decision | 关系 |
|--------------------|------|
| ADR-030（v0.3 release timing）| audit_triage v0.1 → v0.3 跳跃式 bump 对齐统一版本号 / 因本 ADR 决策的 stack 选择允许统一 |
| ADR-031（v1.0 候选议程评估）| 跨 stack 抽象成熟度是 v1.0 触发条件 #4 (≥ 1 跨域 reference impl) 的间接证明 |
| methodology/05 v0.1.1 §7 | Framework Implementation 段引用本决策（5 Protocol map / 6 default REASON_SOURCE_TYPES / DGF-N-03+O-02 测试范本）|
| methodology/07 v0.1 §4 + §5 | "3 种 stack 关系组合实证表"中"跨 stack 行 = audit_triage" / 本 ADR 是该实证的 first-class 决策记录 |

---

## 4. Validation Criteria（本 ADR 决策正确性）

回填时点已可全部验证（vs 起草前回填的 ADR 模板，本 ADR 是回填后即验证）：

- [x] **dogfood 通过**：Sprint Q user local + Sprint T Docker compose sandbox 双实证 ✓
- [x] **Plugin Protocol 数适中**：6 个（vs Sprint N 9 / Sprint O 4 / 落在 4-9 合理区间）✓
- [x] **跨域 fork 文档充分**：cross-domain-mapping.md 7 领域 + scripts/README §5 + methodology/07 v0.1 跨域 fork 启示 ✓
- [x] **生产 TS 未被破坏**：services/api triage.service.ts 自 Sprint Q 至 Sprint V 无变化 ✓
- [x] **统一版本号策略对齐**：audit_triage 0.1.0 (Sprint Q) → 0.3.0 (Sprint T) 跳跃式 bump 与 framework v0.3.0 release 同步（per ADR-030 §2.1 决策）✓
- [x] **methodology cross-ref 完整**：methodology/05 §7 + /07 §4 + /02 §13 + /06 §8 互相引用 ✓
- [ ] **跨域案例方采用** — 等触发（DGF-N-04 / 不阻塞本 ADR）

→ **6/6 ✅ + 1 待跨域案例方触发**（与 ADR-030 §5 同模式 / 决策实证 success）。

---

## 5. 历史回填的 lessons learned

本 ADR 是 framework v0.x 演进中**第一个 retroactive ADR**。沉淀 lessons：

### 5.1 何时 retroactive ADR 是必要的

- 决策已实施 + 实证已积累（vs 决策前未起 ADR / 不立即影响实施）
- 决策涉及 cross-cutting concern（如 stack 选择 / Plugin Protocol design / 影响后续 ≥ 2 sprint）
- 决策对跨外部 reviewer 不透明（仅 closeout / retro 提及 / 未独立成 first-class 文档）

### 5.2 何时 retroactive ADR 不必要

- 单 sprint 内的纯 patch / polish 决策（已在 retro / closeout 充分记录）
- 决策完全可被 methodology 文档覆盖（不需要 first-class ADR）
- 决策被后续 ADR superseded（直接修订后续 ADR 即可）

### 5.3 retroactive ADR 编号策略

本 ADR 用顺序号 ADR-032（vs ADR-029.5 / ADR-031.5 等"小数编号"）。理由：
- 编号 sequential 简单 / 检索友好
- Status: accepted (retroactive) 字段足以表达回填性质
- 未来类似回填可继续 sequential（避免小数编号膨胀）

→ 沉淀为 methodology/06 v0.2 候选段（ADR pattern 加 retroactive 子段）。

---

## 6. References

- Sprint Q Stage 0 brief / Stage 1 批 1（首次抽象）
- Sprint Q Stage 4 closeout §3.7（统一版本号策略）
- Sprint Q Stage 1.13 dogfood ✅ user local
- Sprint T Stage 1 批 1（T-V03-FW-005 Docker compose / sandbox dogfood ✓）
- Sprint U retro §3.2（触发本 ADR 回填）
- methodology/02 v0.1.1 §13（cross-stack abstraction pattern 首次提出）
- methodology/05 v0.1.1 §7（Framework Implementation 段引用本决策）
- methodology/06 v0.1.1 §8（ADR pattern 与 methodology/02 元 pattern 关系）
- methodology/07 v0.1 §1-§5（cross-stack abstraction pattern first-class 详细抽象）
- ADR-027 / ADR-028 / ADR-030 / ADR-031（前后关联 ADR）

---

**ADR-032 起草于 2026-04-30 / Sprint V Stage 1 批 1 / Architect Opus / status: accepted (retroactive)**
