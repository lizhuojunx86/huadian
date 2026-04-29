# Agentic Knowledge Engineering Framework — Overview

> Status: **Draft v0.1**
> Date: 2026-04-29
> Owner: 首席架构师
> Anchor: ADR-028 战略转型 + 华典智谱_架构设计文档_v2.0

---

## 0. 一句话

> **Agentic Knowledge Engineering (AKE)** 是一套用 AI agent 团队严谨、可审计、可复用地构建可信知识库的工程框架。

它解决的是当前 AI 应用层缺失的一个核心环节：**怎么让多 AI agent + 多人协作团队，长期、严谨地"造"出值得信赖的结构化知识**。

---

## 1. 为什么需要这个框架

### 1.1 时代的核心稀缺

> 在 AI 让"做事"变得几乎免费的时代，"做对的事"和"团队做对的事"反而成为最稀缺的能力。

具体到知识工程：单人 + AI 已被证明可以高产（参见 [shiji-kb](https://github.com/baojie/shiji-kb) — 一个超级专家在 55 小时内完成了 130 篇史记的结构化）。但要扩展到：

- **大规模**：4600 万字级二十四史 / 上亿字法律案例库 / 全球佛经
- **多机构合作**：北大 + 中华书局 + 字节 + 民间 / 多家律所共建判例库
- **多领域**：古籍 / 法律 / 医疗 / 专利 / 地方志 / 族谱
- **长期维护**：10 年级数据持续修正、随研究进展演化

…… 单人 SKILL 范式撑不住。需要 **团队级工程纪律 + 可审计协作流程 + 形式化质量约束**。

### 1.2 当前市场的空白象限

| | 取知识（已造好的）| 造知识（从零造）|
|---|---|---|
| 单人 / 小团队 | LangChain / LlamaIndex / RAG 类工具 | shiji-kb / SKILL playbooks |
| 大团队 / 长期协作 | 字节识典古籍 / Notion AI | **空白象限 ← AKE 占位** |

### 1.3 类比：知识工程的 Scrum

软件工程的方法论标准（Scrum / TDD / DDD / SRE）经过几十年沉淀，让任何团队都能用同一套工程纪律协作。但**知识工程**没有等价物——这就是 AKE 想填的位置。

---

## 2. 框架的 6 大核心抽象

AKE 框架 = 6 类工程模式的组合，全部从 **华典智谱史记参考实现（Sprint A-K，4-6 周真实工作）** 中提炼。

| # | 抽象 | 解决的问题 | 详细文档 |
|---|------|----------|---------|
| 1 | Multi-role coordination | 角色边界 + tagged sessions + 跨 session 协作信号 | [01-role-design-pattern.md](01-role-design-pattern.md) |
| 2 | Sprint governance | Sprint / Stage / Gate / Stop Rule 治理框架 | [02-sprint-governance-pattern.md](02-sprint-governance-pattern.md) |
| 3 | Identity resolver | R1-R6 + GUARD_CHAINS 实体歧义解析 | [03-identity-resolver-pattern.md](03-identity-resolver-pattern.md) |
| 4 | Invariant catalog | V1-V11 五大类 invariant 形式化数据正确性 | [04-invariant-pattern.md](04-invariant-pattern.md) |
| 5 | Audit trail | pending_review + audit log + triage UI 人机协作可追溯 | [05-audit-trail-pattern.md](05-audit-trail-pattern.md) |
| 6 | ADR pattern | ADR 在 KE 项目的适配（不可逆点 / 阻塞条件 / addendum）| [06-adr-pattern-for-ke.md](06-adr-pattern-for-ke.md) |

---

## 3. 框架的形态（什么不是什么）

### 3.1 框架**是什么**

- **代码** — 单仓内 `framework/`（待 Sprint L 抽出）+ 模板项目 + invariant scaffold + role definitions + sprint templates
- **文档** — 7 份 `docs/methodology/*.md`（含本文件）+ 跨案例 mapping 表 + cookbook 风格指南
- **案例** — 华典智谱史记主案例（5-10 篇典型章节）+ 鼓励 1-2 个跨领域第三方案例（佛经 / 法律 / 医疗 / etc）
- **协议** — multi-agent 项目协作的事实标准（角色边界 / commit 习惯 / ADR 规范）

### 3.2 框架**不是什么**

- ❌ **不是 LLM 应用框架**（不是 LangChain / LlamaIndex 的同类）
- ❌ **不是 agent 互调用框架**（不是 AutoGen / CrewAI 的同类）
- ❌ **不是闭源平台 / SaaS 服务**（不是字节识典古籍的同类）
- ❌ **不是 C 端产品**（不是 shiji-kb 之类的"知识库阅读器"）
- ❌ **不是 Anthropic Cowork / SubAgent 的替代品**（反而是它们之上的方法论 — 我们用 Anthropic 工具作 substrate）

---

## 4. 与近邻项目的关系

### 4.1 LangChain / LlamaIndex / AutoGen / CrewAI

它们解决 *"用 LLM 做事"*（取知识 / 工具调用）；我们解决 *"严谨地造知识"*（造知识 / 团队治理）。

**下游互补**：用 AKE 框架构造的知识库 → 用 LangChain 接到应用。两层不冲突，反而协同。

### 4.2 shiji-kb / SKILL playbooks

shiji-kb 是单人英雄主义模式的高水平实践，AKE 是团队工业化模式的工程纪律。**互补不冲突**：

- shiji-kb 证明了"AI 能把数十年压缩到几周"
- AKE 解决"如何让多人 + 多 agent 持续协作做这件事 5-10 年"

类比：他是车库手工匠，我们是流水线设计师。两者都需要存在。

### 4.3 字节识典古籍 / 大厂 B2B 服务

字节是中心化大厂闭源 B 端服务（"古籍 AWS"），AKE 是开源框架 + 工程师 DIY 路径（"古籍 Kubernetes"）。差异化基于交付形态而非内容深度。

### 4.4 Anthropic Cowork / SubAgent / Claude Code

这些是我们的 substrate（基础设施层）。AKE 用 Anthropic 工具作为 multi-agent 协作的 runtime，但 AKE 关心的是"用这些工具时怎么协作得严谨"。

如果将来 Anthropic 推出官方"Agentic KE"框架，AKE 可能：
- (a) 被并入 / 互参
- (b) 演化为它的 community 实践
- (c) 保持为另一种风格（更工程化 / 更长期主义）的同类

不主动制造对立（C-25 互补不竞争）。

### 4.5 软件工程方法论（Scrum / Agile / DDD / SRE）

它们是软件项目的方法论；AKE 借用了它们的形式（Sprint 节奏 / DDD 角色边界 / SRE invariant 思维）但调整到知识工程项目场景。预期在知识工程领域起到类似 Scrum 在软件工程领域的"事实标准"作用。

---

## 5. 4-Layer 路线（D-route）

| Layer | 时间窗 | 主要交付 | 当前状态 |
|-------|--------|----------|---------|
| L1 框架代码抽象 | 6-12mo | 单仓内 `framework/` + starter template + 7 份 `docs/methodology/` | 🟡 Stage C 起草中（本文件 = L2 入口）|
| L2 方法论文档 | 12-18mo | 月度决策日记 + 季度方法论文章 | 🟡 草案待起草 |
| L3 案例库 | 持续 | 华典智谱史记（5-10 篇典型章节）+ 鼓励 1-2 跨领域 | 🟢 主案例 4 篇已完成 |
| L4 社区 / 培训 / 商业 | 机会主义 | 视 L1-L3 反响逐步打开 | ⚪ 未启动 |

---

## 6. 上手路径（不同读者）

### 6.1 给"想用 AKE 做新案例"的工程师

```
1. Read README.md（本仓库根入口）
2. Read docs/methodology/00-framework-overview.md（本文件）
3. Read docs/strategy/D-route-positioning.md
4. Read docs/methodology/01-role-design-pattern.md（角色 / 边界 / 协作）
5. Read docs/methodology/02-sprint-governance-pattern.md（Sprint 治理）
6. 决定：把哪个史记案例作为参考 → 翻 docs/sprint-logs/sprint-{a..k}/ 找最接近你领域的 sprint
7. 启动你的领域 Sprint A
```

### 6.2 给"想理解 AKE 设计哲学"的研究者

```
1. Read 本文件（00-framework-overview）
2. Read docs/decisions/ADR-028-strategic-pivot-to-methodology.md（战略动机）
3. Read 01-06 各份 methodology pattern 文档（按编号顺序）
4. Read 一份完整 sprint log（推荐 sprint-k，含 5 角色协同 + ADR-027 + Hist E2E）
```

### 6.3 给"项目管理者 / 想抄作业"的人

```
1. Read 本文件
2. Read docs/methodology/02-sprint-governance-pattern.md
3. Read docs/methodology/06-adr-pattern-for-ke.md
4. Look at 任意 sprint brief + retro 模板
5. Adapt 模板 + 4 件套（STATUS / CHANGELOG / ADR / Tasks）到你的项目
```

### 6.4 给"数据科学家 / 知识图谱人"的工程师

```
1. Read docs/methodology/03-identity-resolver-pattern.md（R1-R6 + GUARD_CHAINS 抽象）
2. Read docs/methodology/04-invariant-pattern.md（V1-V11 设计模式）
3. Read docs/methodology/05-audit-trail-pattern.md（人机协作 audit）
4. Look at services/pipeline/src/ 真实代码引用
```

---

## 7. 长期愿景

> 让 AKE 在知识工程领域起到 Scrum 在软件工程领域的作用：
>
> 任何团队启动一个新的知识工程项目，第一反应是"用 AKE 框架"，就像今天启动一个新的软件项目第一反应是"敏捷开发 + 4 周 sprint + Git PR review"。

具体衡量（5 年视野）：

1. 至少 5-10 个跨领域案例使用 AKE 框架（佛经 / 法律 / 医疗 / 专利 / 地方志 等）
2. 中文 / 英文知识工程社区将 AKE 作为参考方法论
3. 形成"AKE 项目的招聘标签"（"懂 AKE 工作流的工程师"成为可识别人群）
4. AKE 方法论书出版（或成为开源在线书）
5. 至少 1 篇被引用的方法论文章

但 D-route 短期不强求这些。先把华典智谱史记案例做扎实 + 框架抽象做出来 + 让方法论文档真正可读。社区认可是慢工出细活的副产品。

---

## 8. 参与方式

详见 [CONTRIBUTING.md](../../CONTRIBUTING.md)。简短版：

- **使用 AKE 做新案例** → 最大欢迎；GitHub Issue 标 `cross-domain-case`
- **完善方法论草案** → fork + PR 加 review comment / 改写部分 / 新增案例
- **报告 bug / 修复案例数据** → 走标准 PR 流程
- **写自己用 AKE 的经验** → 不必引用我们；让 KE 社区共同生长

---

## 9. 修订历史

| Version | Date | Author | Change |
|---------|------|--------|--------|
| Draft v0.1 | 2026-04-29 | 首席架构师 | 初稿（Stage C-4 of D-route doc realignment）|

---

> 本文档是 AKE 框架的 **公开入口**。任何来访者读完应该能在 5 分钟内理解：
> (1) 框架是什么 / 解决什么问题
> (2) 不是什么 / 不解决什么问题
> (3) 上手路径 / 如何参与
>
> 如果做不到，本文档需要修订。
