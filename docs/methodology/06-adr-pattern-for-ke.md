# ADR Pattern for KE Projects — Architecture Decision Records Adapted to Knowledge Engineering

> Status: **Draft v0.1**
> Date: 2026-04-29
> Owner: 首席架构师
> Source: 华典智谱 27+ ADRs (ADR-001 ~ ADR-029) + Sprint A-K 实战

---

## 0. TL;DR

ADR（Architecture Decision Record）是软件工程成熟实践，但 KE 项目使用 ADR 时需要额外关注几个**领域特性**：

1. **不可逆点**显式标注 — KE 项目的数据 mutation 经常不可逆（merge / split / cascade）
2. **阻塞条件**预先列出 — 触发即重评 ADR
3. **数据迁移路径** — schema-touching ADR 必须含 migration 草案
4. **跨 sprint 沿用** — 一个 ADR 通常服务多个 sprint，需 addendum 而非 supersede

AKE 框架的 ADR 模板基于经典 ADR（Michael Nygard 2011）扩展，加上 6 个 KE-specific 字段。

实证：华典智谱 4-6 周累积 27+ ADRs，从 schema 到协议到战略转型，全部经此模板。

本文件给出：(1) AKE ADR 模板；(2) 6 个 KE 特有字段；(3) Addendum vs Supersede 决策；(4) ADR 编号紧急插队规则；(5) 反模式。

---

## 1. 为什么 KE 项目 ADR 需要适配

### 1.1 软件工程 ADR 的典型形态

经典 ADR（Michael Nygard 2011）：

```
# ADR-NNN: 标题

## Status
proposed / accepted / deprecated / superseded

## Context
为什么需要这个决策

## Decision
我们决定做 X

## Consequences
正面 / 负面影响
```

短小精悍，适合软件功能决策。

### 1.2 KE 项目的额外复杂度

| 维度 | 软件项目 | KE 项目 |
|------|---------|--------|
| 决策影响 | 主要影响代码 | 经常影响**数据**（已存在的 entity / merge / split）|
| 回滚成本 | git revert | 可能需要复杂数据 recovery |
| 时效性 | 决策一般持续 1+ 年 | 决策可能跨多个 sprint，需 addendum 演化 |
| 阻塞条件 | 较少 | 经常需要预先列出"什么情况下重评" |
| 数据迁移 | 偶尔有 | 频繁有（schema-touching ADR 几乎都有）|

→ KE 项目的 ADR 必须更**重**、更**细**、更**前瞻**。

---

## 2. AKE ADR 模板（领域无关）

### 2.1 完整模板

```markdown
# ADR-NNN — {标题}

- **Status**: proposed / accepted / deprecated / superseded
- **Date**: YYYY-MM-DD
- **Authors**: {role(s)}
- **Related**:
  - 项目宪法 C-N（如触发修宪）
  - 既有 ADR-XXX（如 supersedes / addendums / extends）
  - 任务卡 T-NNN
- **Supersedes**: ADR-XXX（如有）
- **Superseded by**: ADR-YYY（如有）

---

## 1. Context

### 1.1 触发事件
（什么 sprint / 什么观察触发了这个决策）

### 1.2 现状
（当前数据 / 代码 / 工作流的状态）

### 1.3 缺口
（哪些痛点需要解决）

## 2. Decision

### 2.1 选定方案
（一句话说选了什么）

### 2.2 详细设计
（schema / 接口 / 协议 / 等）

### 2.3 不选其他方案的理由
（A / B / C 各自被拒原因）

## 3. Consequences

### 3.1 Positive
（好处）

### 3.2 Negative / Risk
（代价 / 风险）

### 3.3 What Changes
（落地时改哪些文件 / 表 / 接口）

### 3.4 What Doesn't Change
（保持不变的部分，避免误改）

## 4. 不可逆点（KE-specific）

### 4.1 已不可逆（本 ADR 接受后即生效）
（不可撤回的部分）

### 4.2 可逆但需新 ADR
（如何撤销 / 改变）

### 4.3 必须等触发条件成熟才决定
（暂时不决定的部分）

## 5. 阻塞条件（KE-specific）
（≥ 5 条触发本 ADR 重评的具体条件）

## 6. 后续 ADR 触发条件（KE-specific）
（本 ADR 接受后预期会触发哪些 follow-up ADR）

## 7. 数据迁移路径（如涉及 schema/data）
（migration 草案 / data backfill / rollback 策略）

## 8. Implementation Checklist
（落地具体步骤的 checkbox）

## 9. 决策签字
- {role}: __ACK YYYY-MM-DD__

---

## Appendix A. 不选 X 的理由（decision negative space）
（详细说明拒绝的方案）

## Appendix B. 历史背景 / 相关案例
（实证、引用）

---

**本 ADR 起草于 YYYY-MM-DD / Sprint X**
```

### 2.2 必含 vs 可选字段

**必含**：1. Context / 2. Decision / 3. Consequences / 9. 决策签字

**KE 特有，必含**：4. 不可逆点 / 5. 阻塞条件

**KE 特有，强烈建议**：6. 后续 ADR 触发条件 / 7. 数据迁移路径

**可选**：Appendix（详细到一定程度才加）

---

## 3. 6 个 KE 特有字段详解

### 3.1 不可逆点

**为什么需要**：KE 项目的 schema / data 决策经常不可逆。如果不预先标识"哪些是不可逆的"，未来想改时才发现成本爆炸。

**3 类不可逆**：

1. **已不可逆**（接受即生效）— 历史发布的 license / 已 merge 的 entities / 已 commit 的 audit row
2. **可逆但需新 ADR** — schema 字段重命名 / 配置参数调整
3. **必须等触发条件成熟才决定** — 框架命名 / Layer 4 商业化形态 / 等

**实例**（ADR-028 §4）：

```markdown
### 4.1 已不可逆
- 项目战略主轴 = D-route methodology framework（非 C 端产品）
- 案例服务于框架，不反过来

### 4.2 可逆但需新 ADR
- Q1 降级程度 → ADR-XXX 升级到持续级
- Q2 单仓策略 → ADR-XXX 分仓
- ...

### 4.3 必须等触发条件成熟才决定
- 框架命名（→ ADR-029，后顺移到 ADR-030）
- Layer 4 商业化形态
```

### 3.2 阻塞条件

**为什么需要**：决策不应该"一锤定音永不改变"。预先列出"什么情况触发重评"让决策有 sunset path。

**实例**（ADR-028 §5）：

```markdown
1. shiji-kb 团队 6 个月内宣布做"团队级方法论框架" → 我们需重新差异化
2. 字节识典古籍开源其知识工程框架 → 同上
3. Anthropic 发布官方"Agentic KE 框架" → 同上
4. 华典智谱史记案例无法支撑框架抽象 → 重评 Q3
5. Architect 持续 3 个月无法投入战略 / 写作 → Q5 节律重订或本 ADR 整体重评
```

### 3.3 后续 ADR 触发条件

**为什么需要**：一个 ADR 经常会引出后续 ADR。预先列出让决策有连续性。

**实例**（ADR-028 §6）：

```markdown
| 事件 | 触发 ADR | 时机预估 |
|------|----------|---------|
| 决定框架命名 + repo 形态 | ADR-030 | Sprint M 启动时 |
| 决定首篇方法论文章主题 + 发布平台 | ADR-031 | Layer 1 第 1 个抽象稳定后 |
| 与 shiji-kb 团队建立合作关系 | ADR-032 | 用户主动接触后 |
| ...
```

### 3.4 数据迁移路径

**为什么需要**：schema-touching ADR 必须想清楚 migration / backfill / rollback 才能 accepted。

**实例**（ADR-027 §3 引用 migration 0014）：

```markdown
## 3. Schema 设计
... triage_decisions table 创建 ...

## 7. 数据迁移路径
- migration: services/pipeline/migrations/0014_add_triage_decisions.sql
- backfill: 历史 git commit 散落的决策 → triage_decisions（详见 backfill_*.py 脚本）
- rollback: pre-Sprint K Stage 2 pg_dump anchor
```

### 3.5 Implementation Checklist

**为什么需要**：ADR 接受后，落地是多步骤。Checklist 让"是否完成"可量化。

**实例**（ADR-029 §7）：

```markdown
## 7. Implementation Checklist

Stage A.5 落地（本 ADR 接受后立即执行）：

- [x] LICENSE (Apache 2.0)
- [x] LICENSE-DATA (CC BY 4.0)
- [x] NOTICE
- [x] README.md 重写（含 license 段）
- [x] CONTRIBUTING.md
- [x] ADR-029-licensing-policy.md (本文件)
- [ ] ADR-028 §6 序号修订
- [ ] CLAUDE.md §1 微更新
```

### 3.6 决策签字

**为什么需要**：Architect 是 Accountable 角色，明确签字让 ADR 真生效。

```markdown
## 9. 决策签字

- 首席架构师：__ACK 2026-04-29__
- 信号：本 ADR 接受 → Stage A.5 实施完成 → Stage B 启动
```

---

## 4. Addendum vs Supersede 决策

### 4.1 何时用 Addendum

如果 ADR 的**核心决策不变**，只是**扩展或细化**，用 Addendum：

```markdown
# ADR-025 Addendum — state_prefix_guard for R1

> Date: 2026-04-28
> Status: accepted

## 5.3 Addendum: state_prefix_guard

（在原 ADR-025 文件末尾追加，不删除已有内容）
```

实例：
- ADR-014 §2.1 footnote（引入 ADR-026 例外，不推翻 ADR-014）
- ADR-025 §5.3（新增 state_prefix_guard 在 GUARD_CHAINS 框架内）

### 4.2 何时用 Supersede

如果**核心决策被推翻**，用 Supersede：

```markdown
# ADR-XXX — Replace ADR-YYY

- Status: accepted
- Supersedes: ADR-YYY (now: superseded)

（在 ADR-YYY 文件顶部加 banner: "Superseded by ADR-XXX"）
```

实例：
- 暂无（华典智谱 27+ ADRs 中没有真正 supersede 的，只有 addendum）

### 4.3 决策树

```
core decision still valid?
  ├─ YES + 只是补充 → Addendum
  ├─ YES + 例外情况 → Addendum + footnote in supersede candidate
  └─ NO + 替代方案 → Supersede
```

---

## 5. ADR 编号 + 紧急插队规则

### 5.1 顺序编号

ADR 按时间顺序编号 ADR-001 / ADR-002 / ...，不允许"跳号占位"。

### 5.2 紧急插队（实战经验）

**问题**：ADR-028 §6 表格预约 "ADR-029 = 框架命名"。但 2026-04-29 项目转 public 触发紧急许可证决策，许可证比框架命名更紧急。

**处理**：ADR-029 用于许可证（紧急插队），框架命名顺移到 ADR-030。

**记录方式**：
1. 新 ADR-029 自身在 §1.2 写明"因紧急插队"
2. 旧 ADR-028 §6 表格更新（ADR-029 → ADR-030 全表 +1）
3. ADR-028 §2.5 加内联 note 说明紧急插队

### 5.3 抽象到框架

**编号占位 ≠ 实际编号**。ADR-NNN 表格中预约的编号只是"预测"，实际编号视紧急程度调整。任何调整必须在受影响 ADR 中显式记录。

---

## 6. 跨领域使用指南

### 6.1 ADR 模板高度领域无关

§2.1 模板可直接复用到任何 KE 项目（甚至非 KE 项目）。

### 6.2 编号空间建议

每个项目独立编号 ADR-001 起。不与其他项目共享编号空间。

### 6.3 何时启动 ADR

经验法则：**当一个决策"将来有可能被质问'当时为什么这么做'"** 时，写 ADR。

实证：
- ✅ schema 设计选择 → ADR
- ✅ 跨角色协议 → ADR
- ✅ 战略转型 → ADR
- ✅ 许可证选择 → ADR
- ❌ 单条 SQL bug fix → 不需要 ADR
- ❌ commit message 笔误修订 → 不需要 ADR

### 6.4 ADR 数量预期

- Phase 0（初期 1-3 个月）：~10 个 ADR
- 成熟期（每 3-6 个月）：稳定增长 5-10 个 ADR
- 总数 30-50 个时往往是项目"工程成熟度"的信号

华典智谱 4-6 周累积 27+ ADRs（密度高，符合 KE 项目复杂度）。

---

## 7. 反模式

### 7.1 反模式：决策不写 ADR

❌ 在 PR 描述里说"这是个架构选择，但不值得 ADR"

✅ 任何会被人质问"为什么这么设计"的决策都应有 ADR

### 7.2 反模式：ADR 太长

❌ 单个 ADR 5000 字 + 多个 appendix + 无关历史背景

✅ ADR 主体 ≤ 2000 字；细节进 appendix 或 link 到 sprint logs

### 7.3 反模式：ADR 跨决策范围

❌ ADR-NNN 同时决策 schema + UI + GraphQL + migration

✅ 每个 ADR 一个核心决策；多决策拆多 ADR

### 7.4 反模式：跳过 Status 字段

❌ 不写 Status / 一直 proposed / 没有 accepted timestamp

✅ Status 是 ADR 生命周期的关键状态机

### 7.5 反模式：违反 ADR 不修订

❌ 实现违反了 ADR 但没人修 ADR / 没人 accept addendum

✅ 实现必须与 accepted ADR 一致；不一致 → 修实现或修 ADR

### 7.6 反模式：ADR 不签字

❌ 多个 stakeholder 都同意但没 explicit ACK

✅ ADR §9 决策签字必须有明确 ACK 时间

---

## 8. ADR Template Comparison Pattern（v0.2 新增 / Sprint X 批 1）

§2.1 给出 AKE ADR 通用模板。但 KE 项目实战识别出 **3 类专用 ADR 模板**，各有触发条件 / 必含独有字段 / 反模式。本节抽出 first-class，便于跨域使用。

### 8.1 三类专用 ADR 模板速览

| Template | 实证 ADR | 触发条件 | 必含独有字段 | 何时用 |
|----------|---------|---------|------------|-------|
| **Release-trigger ADR** | ADR-030 (v0.3.0 release timing) | v0.x → v0.(x+1) release 时机决策 | §3 ≥ 5 触发条件 + §5 Validation Criteria（半填充 / release sprint 后回填）| release sprint 启动前 |
| **Release-eval ADR** | ADR-031 (v1.0 candidate evaluation) | v(x).0 → v(x+1).0 候选议程评估 | §3 ≥ 7 触发条件（多维度）+ §5 路径预测（≥ 2 路径乐观/保守）| 候选议程评估时 |
| **Retroactive ADR** | ADR-032 (audit_triage cross-stack) | 回填 sprint 应起未起的 ADR | Status: `accepted (retroactive)` + §5 retroactive lessons | gap 识别后回填 |

3 类专用模板**互补 ≠ 替代**基础模板（§2.1 始终是核心）。差异在"独有字段 + 何时用"。

### 8.2 Release-trigger ADR

**触发条件**：准备 release v0.x → v0.(x+1) 时；决策"是否 release / 何时 release / 哪些 patch 要 land"。

**必含独有字段**：
- §3 触发条件清单（≥ 5 条 / 每条独立可量化 / e.g. "framework 5 模块齐备 ✅" / "v0.2 patch ≥ 80% land ✅"）
- §5 Validation Criteria（半填充 / release sprint 完成后回填实际值）

**实证 ADR-030**（per Sprint S）：6/6 触发条件全达成 → Sprint T release sprint 完成后回填 §5 5/6 ✅ + 1 待 push tag → Sprint T closeout 阶段 fold 第 6 项（push tag → 6/6 ✅）。

**反模式**：
- ❌ 触发条件 < 5 条（"看 vibe 决定要 release"）
- ❌ Validation Criteria 全填充无回填路径（设计上无法被 sprint 验证）
- ❌ release sprint 完成后不回过来 ACK ADR §5

### 8.3 Release-eval ADR

**触发条件**：评估 v(x).0 → v(x+1).0 候选议程时（如 v1.0 候选）；不是 release 决策本身，而是"我们距 release 多远 / 需要补什么"。

**必含独有字段**：
- §3 触发条件清单（≥ 7 条 / 包含成熟度 + 跨域 + 累计 patch + zero-trigger 等多维度）
- §5 路径预测（≥ 2 路径：乐观 / 保守 / 各自时间锚 + 阻塞条件）

**实证 ADR-031**（per Sprint U）：7 触发条件 / 当前 2/7 ✅ + 2/7 ⏳ + 3/7 ❌；2 路径预测 2026-10 (乐观) ~ 2027-04 (保守)；后续每 sprint 更新触发条件状态（per STATUS §1.1 Layer 表 zero-trigger 计数 + methodology v0.2 cycle 进度）。

**反模式**：
- ❌ 触发条件不可量化（"feel mature enough"）
- ❌ 路径预测无锚点（无具体时间区间 / 无阻塞条件）
- ❌ eval ADR 与 trigger ADR 混淆（前者评估"距 release 多远"，后者执行"何时 release"）

### 8.4 Retroactive ADR

**触发条件**：识别"应起未起的 ADR" gap（per §6.3 何时启动 ADR）。通常在 retro / 第三方 review / cross-domain 准备时识别。

**必含独有字段**：
- Status: `accepted (retroactive)` 显式标注
- §1.1 触发事件: 写明 gap 识别时机（哪个 sprint retro / 哪次 cross-domain 准备）
- §5 Retroactive Lessons Learned（编号策略 / 何时必要 / 何时不必要 / 见 §8.4.1）

#### 8.4.1 Retroactive ADR Lessons Learned (fold T-V05-FW-001 / per ADR-032 §5)

**编号策略**：retroactive ADR 用**新编号**（不抢占历史编号），在 §1.1 写明"回填于 Sprint X / 决策实际发生在 Sprint Q"。这保证 ADR 编号严格按时间顺序（per §5.1 §5.2），同时记录"决策的真实发生时间"。

**何时必要**：
- ✅ 跨 stack 抽象（per /02 §13 / Sprint Q audit_triage 实证 gap）
- ✅ 涉及多 sprint 的协议级决策（如 multi-row audit immutability / 影响 Sprint Q+R+T 多 sprint）
- ✅ 第三方 reviewer 首次 onboard 前（外部历史完整性 critical）

**何时不必要**：
- ❌ 单 sprint 内的实施细节（应进 sprint log / commit message）
- ❌ schema migration 历史（应进 migration file 自身 + 关联 ADR-XXX）
- ❌ commit message 笔误（per §7.6 反模式 / 不需 ADR）

**写作模式**：
- 不修改原 sprint log / commit history / 仅在新 ADR 中"回填"
- §3 Consequences 写"如果当时起 ADR / 我们会避免哪些 confusion"
- 滥用预防：retroactive ADR 应是**低频例外**（华典智谱预期 1-2 个 / 年）

**实证 ADR-032**（per Sprint V）：回填 Sprint Q 应起未起的跨 stack 抽象决策；§5 retroactive lessons 5 段；触发于 Sprint U retro §3.2 gap 识别。

#### 8.4.2 反模式

- ❌ Retroactive ADR 抢占历史编号（破坏 ADR 编号顺序 / 违反 §5.1）
- ❌ Retroactive ADR 修改原 sprint log / commit history（"重写历史"）
- ❌ Retroactive ADR 不写 lessons（仅是补登记 / 不学习）
- ❌ 滥用 retroactive（每 sprint 都补一堆 / 应是低频例外）

### 8.5 跨域 fork 启示

跨域 fork framework 时 ADR 模板选择：
- 抽象 sprint → 用基础模板（per §2.1 / 不需专用）
- release sprint → 用 release-trigger 模板（per §8.2）
- 候选议程评估 → 用 release-eval 模板（per §8.3）
- 识别 gap 回填 → 用 retroactive 模板（per §8.4）
- 跨 stack 抽象 → 强烈建议起 ADR（per Sprint Q 实证 gap / 否则触发 retroactive 补救）

---

## 9. 与 methodology/02 元 pattern 的关系（v0.1.1 新增 / Sprint U 批 2 / v0.2 §8.x 重编 §9.x）

methodology/02-sprint-governance-pattern.md v0.1.1 (Sprint R) §10-§13 沉淀了 4 段元 pattern。本文件 §1-§7 描述的是"ADR 在 KE 项目的适配"层；§8（v0.2 新增）抽出 3 类专用 ADR 模板 first-class；本节给出与 /02 元 pattern 的双向引用关系，让读者理解"ADR pattern vs sprint 治理"的耦合点。

### 9.1 跨 doc 引用速查

| methodology/02 §X | 对本文件的影响 |
|-------------------|--------------|
| §10 Maintenance Sprint Pattern | 本文件 §6.3 何时启动 ADR — maintenance sprint 内通常**不**起新 ADR（patch sprint 应该 zero ADR / per Stop Rule §5）；起 ADR 应该是 release / eval / 抽象 sprint |
| §11 P3 复发升级 P2 暗规则 | 本文件 §3 ADR 演化 — debt 跨 sprint 复发是 ADR addendum 的典型触发场景（vs case-level 一次性修订）|
| §12 5 模块齐备阈值 | 本文件 §4 ADR 编号策略 — framework 抽象阶段终点后，新 ADR 应该集中在 release / cross-domain / governance（而非新模块抽象）|
| §13 跨 stack 抽象 pattern | 本文件 §6.1 ADR 模板领域无关 — 跨 stack 抽象本身需要 ADR 记录（per Sprint Q audit_triage 实证 / 但 Sprint Q 当时未起 ADR / 触发 v0.4 候选 "应回填跨 stack 抽象决策记录"）|

### 9.2 实证锚点（Sprint A-U 累计 31 ADR + 演化数据点）

| Sprint | ADR 起 / 修 | pattern 类型 |
|--------|----------|------------|
| A-K | ADR-001 ~ ADR-027（27 ADRs / 抽象 + maintenance + V1-V11 invariant 引入）| 主线 ADR / per §3 ADR 演化模式 |
| K | ADR-027（Triage UI workflow / first-class）| 复杂业务流程 ADR |
| L | ADR-028（D-route 战略转型）| 战略级 ADR / 触发后续抽象 |
| L | ADR-029（许可证策略）| Release 必要 ADR |
| Q | （audit_triage 抽象 / **应起 ADR 但未起**）| Identified gap → v0.4 候选 |
| S | ADR-030（v0.3 release timing）| Release-trigger ADR / 模板复用 |
| **U (本 sprint)** | **ADR-031**（v1.0 release candidate evaluation）| **Release-eval ADR / 与 ADR-030 形成对比模板** |

**模式**：
- v0.x 早期（Sprint A-K）：ADR 多与"抽象决策"对应（每个新 framework 模块至少 1 ADR）
- v0.x 中期（Sprint L-T）：ADR 多与"治理决策"对应（D-route 战略 / 许可证 / release timing）
- v0.x 晚期（Sprint U+N，预测）：ADR 多与"release / 跨域 / 成熟度"对应（per ADR-031 §5 路径）

### 9.3 跨域 fork 案例方启示

如果你 fork framework 到你的领域（per methodology/02 §13.4）：

- **抽象 sprint** 起 ADR：每个新 framework 模块抽象至少 1 ADR（per Sprint A-K 实证）
- **maintenance sprint 应 zero ADR**（per methodology/02 §10.5 反模式 + 本文件 §6.3）
- **release sprint** 起 ADR：v0.x → v0.(x+1) 触发条件 + Validation Criteria（per §8.2 release-trigger 模板）
- **eval sprint** 起 ADR：v1.0 / 跨域 / 成熟度阈值评估（per §8.3 release-eval 模板）
- **跨 stack 抽象** 应起 ADR（vs Sprint Q audit_triage 当时未起 / 已通过 ADR-032 retroactive 回填 / per §8.4 retroactive 模板）

### 9.4 ADR 与 methodology cross-ref 的双向责任

ADR 是**点状决策**，methodology 是**结构化模式**。两者关系：

- ADR 验证或挑战 methodology pattern → 触发 methodology v0.x → v0.(x+1) iter（per /02 §10-§13 实证锚点）
- methodology 给 ADR 提供"为什么这么决策"的理论基础（per §6.3 何时启动 ADR）
- 两者通过 §修订历史 + cross-ref 表互相引用（per Sprint S /01 + /03 + /04 + Sprint U /06 polish 模式）

---

## 10. 修订历史

| Version | Date | Author | Change |
|---------|------|--------|--------|
| Draft v0.1 | 2026-04-29 | 首席架构师 | 初稿（Stage C-10 of D-route doc realignment）|
| Draft v0.1.1 | 2026-04-30 | 首席架构师 | Sprint U 批 2 polish：加 §9 (原 §8) 与 methodology/02 元 pattern 关系（4 段 cross-ref + Sprint A-U 31 ADR 演化数据点 + 跨域 fork 启示 5 条 + ADR↔methodology 双向责任段）|
| **v0.2** | **2026-04-30** | **首席架构师** | **Sprint X 批 1 大 bump：加 §8 ADR Template Comparison Pattern first-class（3 类专用模板 release-trigger / release-eval / retroactive 详解 + fold T-V05-FW-001 retroactive lessons + 跨域 fork 启示）；§修订历史 §9 → §10 重编号** |

---

> 本文档描述的 ADR Pattern for KE 是 AKE 框架的 Layer 1 核心资产之一。
> 32+ ADRs 实证细节见 `docs/decisions/ADR-001` ~ `ADR-032`.
> Sprint U §9 把它链接回 methodology/02 §10-§13 元 pattern + Sprint A-U ADR 演化数据点。
> Sprint X §8 抽出 3 类专用 ADR 模板 first-class（release-trigger / release-eval / retroactive）+ fold T-V05-FW-001。
