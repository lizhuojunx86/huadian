# Role Design Pattern — Multi-Role Coordination for Agentic Knowledge Engineering

> Status: **Draft v0.1**
> Date: 2026-04-29
> Owner: 首席架构师
> Source: 华典智谱 Sprint A-K 真实协作经验 + `.claude/agents/*.md` + `docs/03_多角色协作框架.md`

---

## 0. TL;DR

**多角色协作不是组织美学，是工程刚需**。单 LLM session 装入"全栈知识工程师"上下文等于上下文坍缩 + 决策模糊。AKE 把工程团队拆成 10 个角色，每个角色：

- 拥有**独占的决策权**（在自己专业领域）
- 有**明确的禁区**（不得越位）
- 通过**结构化交接物**与其他角色协作
- 启动 session 时按 tag 标识（`【BE】`、`【PE】`等）

本文件给出：(1) 角色设计原则；(2) 10 个角色的领域无关抽象 + 跨领域 mapping；(3) 跨 session 协作协议；(4) 冲突升级机制；(5) 设计反模式。

---

## 1. 设计原则

### 1.1 LLM 窗口 = 角色边界的物理基础

LLM context window 有限。一个 session 装入"角色定义 + 任务卡 + 项目状态 + 既有代码 + 协作历史"已经接近上限。再让它"既懂古籍又懂 GraphQL 又懂 UI 又懂 SRE"，每一面都浅。

**结论**：角色拆分不是组织手段，是 LLM 本身的物理约束推出的必然结论。

### 1.2 决策权 vs 执行权

**核心区分**：

- **决策权**（A — Accountable）：在专业领域内"这件事怎么做"的最终判断
- **执行权**（R — Responsible）：动手实现 / 编写 / 审查的人

一个角色可以是"决策者 + 执行者"（如管线工程师对 NER prompt），也可以只是"决策者"（如架构师对 ADR）或"执行者"（如前端对组件实现）。

跨角色协作 = 决策权和执行权的明确传递。

### 1.3 RACI 矩阵作为契约

每个任务必须有：

- 唯一 `A`（最终责任方）
- 一个或多个 `R`（执行者，但必须明确主导）
- 一些 `C`（咨询方）和 `I`（知会方）

这个矩阵是**契约**，越界 = 违约。

### 1.4 越位禁区强制化

每个角色都有明确的**不得做**清单：

| 角色 | 典型禁区 |
|------|---------|
| 架构师 | 不写业务代码 |
| 产品经理 | 不改 schema / 不决定技术栈 |
| Domain Expert | 不写代码（只能提议）|
| 后端工程师 | 不决定产品功能取舍 / 不改视觉 |
| 前端工程师 | 不决定视觉 / 不改 schema |
| ... | ... |

违反禁区视为**严重违规**，必须立即停止并升级到架构师仲裁。

---

## 2. 10 个角色的领域无关抽象

下表展示华典智谱角色定义如何在 AKE 框架层抽象为领域无关角色，以及在跨领域案例中如何 instantiate：

| # | AKE 抽象角色 | 华典智谱 instantiation | 佛经案例 instantiation | 法律案例 instantiation | 医疗案例 instantiation |
|---|------------|---------------------|--------------------|-------------------|-------------------|
| 1 | Chief Architect | 首席架构师 | 同名 | 同名 | 同名 |
| 2 | **Domain Expert** | 古籍专家 | 佛学专家 | 法律专家 / 律师 | 临床专家 / 医生 |
| 3 | Pipeline Engineer | 管线工程师 | 同（NER prompt 替换为佛经术语 prompt）| 同（替换为法律实体 prompt）| 同（替换为临床术语 prompt）|
| 4 | Backend Engineer | 后端工程师 | 同 | 同 | 同 |
| 5 | Frontend Engineer | 前端工程师 | 同 | 同 | 同 |
| 6 | Product Manager | 产品经理 | 同 | 同 | 同 |
| 7 | UI/UX Designer | UI/UX 设计师 | 同 | 同 | 同 |
| 8 | QA Engineer | QA 工程师 | 同 | 同 | 同 |
| 9 | DevOps Engineer | DevOps 工程师 | 同 | 同 | 同 |
| 10 | Data Analyst | 数据分析师 | 同 | 同 | 同 |

**关键观察**：10 个角色中 9 个**完全领域无关**（名字、职责、边界完全一致），只有 #2 Domain Expert 需要根据领域 instantiate。

这意味着：**角色定义 = 框架层 Layer 1 资产**；只有 Domain Expert 内容是案例层 Layer 3 资产。

### 2.1 角色定义模板（领域无关）

每个角色的定义应包含：

```markdown
# {Role Name}

## 1. 职责 (Mission)
- 一句话描述角色存在的目的

## 2. 决策权 (Authority)
- 列出本角色独占的决策类型（≥ 3 项）

## 3. 执行权 (Responsibility)
- 列出本角色亲手做的工作类型（≥ 3 项）

## 4. 禁区 (No-fly Zone)
- 列出本角色不得做的事（≥ 3 项）

## 5. 交接契约 (Handoff Contract)
- 给到下游角色的标准产出物
- 期望从上游角色接收的标准输入

## 6. 升级条件 (Escalation)
- 何时把决策升级给架构师 / 用户

## 7. 工作启动模板 (Bootstrap)
- session 启动必读文件清单

## 8. 工作收尾模板 (Closeout)
- session 结束必更新文件清单
```

详见 `.claude/agents/{role}.md` 实例。

---

## 3. Tagged Sessions 协议

### 3.1 问题

当架构师同时在多个 Claude Code session 中调度不同角色（PE/BE/FE/Hist 并行推进）时，session 之间需要可识别的"身份标记"，否则容易混淆"哪个 session 在做什么"。

### 3.2 协议

每个子 session 的 prompt 用 `【{Role Tag}】Sprint X Stage Y` 开头：

| 角色 | 标签 |
|------|------|
| Backend | `【BE】` |
| Frontend | `【FE】` |
| Pipeline | `【PE】` |
| Domain Expert | `【Hist】` (or `【Lawyer】` / `【Doctor】` / etc 视领域) |
| QA | `【QA】` |
| DevOps | `【DevOps】` |
| Architect | 主 session，不并行 |

### 3.3 跨 Session 关键信号（Sprint K 实测）

不同角色 session 之间通过结构化"信号"交互。架构师作为协调者负责传递信号。

| 上游信号 | 下游 unblock |
|---------|------------|
| 【BE】SDL ready | 【FE】codegen unblock |
| 【BE】migration NNNN applied | 【PE】backfill apply unblock |
| 【PE】Stage 2 apply done | 【Architect】给 Hist 发 review prompt |
| 【Hist】review report done | 【Architect】给 PE 发 Stage 4 apply 指令 |
| 【Architect】Stop Rule 裁决 | 发回原触发 session |

### 3.4 收益（Sprint K 实测）

- Sprint K（T-P0-028 Triage UI V1）首次完整使用此协议
- 4 角色（PE/BE/FE/Hist）+ Architect 协同 5 个 stage
- 总耗时约 1 个工作日（vs 单 session 估约 3-5 天）
- 每个 session 上下文窗口压力都在合理范围
- 关键决策（Stop Rule、ADR-027 sign-off、provenanceTier 文案裁决）都通过架构师集中仲裁

---

## 4. 冲突升级机制

### 4.1 三级升级

```
Level 1: 任务卡评论区互相协商
    ↓ 仍冲突
Level 2: 升级到首席架构师仲裁（记入任务卡）
    ↓ 仲裁涉及架构宪法
Level 3: 升级到用户决策 + 修宪流程（docs/00_项目宪法.md）
```

### 4.2 仲裁记录格式

任何 Level 2 仲裁必须记录：

```markdown
## 仲裁记录
- 日期：YYYY-MM-DD
- 冲突角色：{A} vs {B}
- 冲突点：{一句话描述}
- A 立场：...
- B 立场：...
- 仲裁人：架构师
- 仲裁结论：...
- 仲裁依据：（引用 ADR / 项目宪法 / 历史案例）
```

如仲裁触发新 ADR，记入 `docs/decisions/`.

### 4.3 仲裁数据示例（华典智谱实证）

Sprint K 期间的仲裁案例：

- **PE 175 vs 179 backfill stop rule**（idempotency 跨 sprint 去重）→ 架构师裁决 R1+R3 混合（接受 + 透明度文档）
- **provenanceTier 文案 "未验证" vs "待补来源"**（FE 提出）→ 架构师裁决 Option A（统一"未验证"，避免 enum 内语义风格断裂）
- **GraphQL TriageItem interface vs union 类型**（BE/FE 协商）→ 架构师裁决 interface（实现 Traceable + lazy person load）

每次仲裁都记入对应任务卡 + 衍生债清单。

---

## 5. 工作启动与收尾的标准化

### 5.1 启动（每个角色 session 必做）

```
1. Read CLAUDE.md（项目入口）
2. Read docs/STATUS.md（当前状态）
3. Read docs/CHANGELOG.md 最近 5 条
4. Read .claude/agents/{role}.md（角色边界）
5. Read 任务卡 docs/tasks/T-NNN-*.md
6. 输出 TodoList，等架构师/用户确认后再动手
```

### 5.2 收尾（每个角色 session 必做）

```
1. 生成本任务的交付物摘要
2. 更新 docs/STATUS.md
3. 追加 docs/CHANGELOG.md 一条
4. 若产生新决策，追加 ADR
5. 若影响其他角色，在任务卡标注 "handoff_to: [role]"
```

### 5.3 抽象到框架

启动 / 收尾流程是**领域无关**的——任何 KE 项目都用同样的 6 步启动 + 5 步收尾。差异只在 `.claude/agents/{role}.md` 的领域内容。

---

## 6. 角色活跃度调整（D-route 阶段）

### 6.1 框架角色 vs 案例角色

不是所有角色在每个 sprint 都同等活跃。AKE 框架默认提供"角色活跃度调节"机制：

| 活跃度 | 含义 |
|--------|------|
| 🟢 高 | 主线持续，每个 sprint 都参与 |
| 🟡 维护模式 | 仅响应需要时启动；不主动启动新工作 |
| ⚪ 暂停 | 当前 phase 不参与；启动需架构师批准 |

### 6.2 华典智谱 D-route 实例

| 角色 | D-route 活跃度 |
|------|--------------|
| Chief Architect | 🟢 高（含战略+写作）|
| Pipeline Engineer | 🟢 主线持续 |
| Backend / Frontend Engineer | 🟡 维护模式 |
| QA / DevOps Engineer | 🟡 维护模式 |
| Domain Expert | ⚪ 暂停（仅 triage 需要时启用）|
| Product Manager / UI Designer / Data Analyst | ⚪ 暂停 |

### 6.3 跨领域案例的活跃度调整

新案例启动时，建议先评估：

1. 这是哪种 phase？数据 ingest 主线 / 框架抽象 / 产品化 demo？
2. 哪些角色是 phase critical？哪些是 supportive？
3. 哪些角色暂时不需要？

这是案例方在 ADR 中需要回答的问题（"我们为什么暂停 X 角色"）。

---

## 7. 设计反模式（Don'ts）

### 7.1 反模式 1：万能角色

❌ 让一个 session 同时扮演 Architect + Backend + Frontend + QA。理由：上下文坍缩 + 决策模糊。

✅ 拆成 4 个 tagged session 协作。

### 7.2 反模式 2：模糊决策权

❌ "PE 和 Hist 一起决定实体归类" → 决策权不明，扯皮

✅ "实体归类由 Hist 决定，PE 执行" 或反之，但不能混

### 7.3 反模式 3：跳级协作

❌ 前端工程师直接改 schema（理由"我看到一个 typo"）

✅ 前端工程师 issue 给后端 + 等后端处理

### 7.4 反模式 4：口头交接

❌ "我已经口头跟 BE 说过了" → 没有 audit trail

✅ 一切交接通过任务卡评论 / commit message / PR description / ADR / Sprint brief

### 7.5 反模式 5：跳过升级机制

❌ 两个角色绕过架构师私下达成共识然后改代码

✅ 任何跨角色决策必须公开 + 记入任务卡 / ADR

---

## 8. 跨领域使用指南（Migration Guide）

新领域案例如何 instantiate AKE 角色框架：

### Step 1: 复制角色定义

```bash
cp -r .claude/agents/ /path/to/new-case/.claude/agents/
```

### Step 2: 重命名 Domain Expert

把 `historian.md` 重命名为你领域的 expert（如 `lawyer.md` / `physician.md` / `buddhologist.md`）。

### Step 3: 修订 Domain Expert 内容

修改文件内容，把"古籍专家"职责替换为你领域的等价职责：
- "实体歧义仲裁" → 你领域的"歧义仲裁"
- "字典管理" → 你领域的"术语库管理"
- "历史事件 vs 神话区分" → 你领域的"事实 vs 推断区分"

### Step 4: 修订 Pipeline Engineer 注入参数

`pipeline-engineer.md` 内容大部分不动，但要更新：
- LLM prompt 模板（NER 范畴改为你领域的实体类别）
- domain-specific 配置文件路径（如 `data/dynasty-periods.yaml` → `data/case-categories.yaml`）

### Step 5: 启动你的 Sprint A

按 [02-sprint-governance-pattern.md](02-sprint-governance-pattern.md) 启动 Sprint A。

---

## 9. 修订历史

| Version | Date | Author | Change |
|---------|------|--------|--------|
| Draft v0.1 | 2026-04-29 | 首席架构师 | 初稿（Stage C-5 of D-route doc realignment）|

---

> 本文件描述的角色设计模式是 AKE 框架的 Layer 1 核心资产之一。
> 任何对本模式的修改建议，请通过 GitHub Issue + PR 走 ADR 流程。
