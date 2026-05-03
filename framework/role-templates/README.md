# framework/role-templates — Multi-Role Coordination Templates

> Status: **v0.2.0 (Sprint P release / 2026-04-30)**
> First abstraction: Sprint M Stage 1, 2026-04-29
> Date: 2026-04-30
> License: Apache 2.0 (代码/模板) / CC BY 4.0 (文档)
> Source: 华典智谱 `.claude/agents/*.md` 10 份角色定义 + `docs/methodology/01-role-design-pattern.md` + Sprint K (T-P0-028 Triage UI V1) 5 角色协同实战

---

## 0. 这是什么

一套**领域无关**的 10 角色 KE 团队协作模板，让任何 Knowledge Engineering 项目可以直接复用 AKE 框架的多角色 / 多 session 协作模式。

不需要写代码，**只需要复制本目录到你的项目，改填占位字段，即可启动你的 multi-role agent 团队**。

**核心观察**（来自 `docs/methodology/01-role-design-pattern.md` §2）：

> 10 个 AKE 角色中，9 个**完全领域无关**（角色名、职责、决策权、禁区跨领域 KE 项目完全不变）。只有 1 个 **Domain Expert** 需要按领域 instantiate（重命名 + 大段重写）。

→ **跨领域迁移成本极低**：90% 的角色定义可以零修改复用。

---

## 1. 何时用这套模板

✅ **适合**：

- 多人 / 多 agent 协作的 KE 项目（数据完整性敏感、领域知识深、决策权易冲突）
- 已有项目想引入工程化角色协作（替代单 LLM session 装入"全栈"模式）
- 跨领域 KE 项目快速 bootstrap（古籍 / 佛经 / 法律 / 医疗 / 专利 / 地方志 / etc）

❌ **不适合**：

- 单人短期项目（1-2 周内完成；不需要协议）
- 普通软件项目（Scrum / Kanban 已成熟）
- 纯 RAG / chatbot 应用（用 LangChain 等工具足够）

---

## 2. 文件清单

| 文件 | 用途 | 跨领域复制 |
|------|------|----------|
| `README.md` | 本文件 | 复制一次（每项目）|
| `chief-architect.md` | Chief Architect 角色定义 | 直接复制 + 改少量路径名 |
| `pipeline-engineer.md` | Pipeline Engineer 角色定义 | 直接复制 + 改路径 / 抽取任务名 / 等 |
| `backend-engineer.md` | Backend Engineer 角色定义 | 直接复制 + 改技术栈名 |
| `frontend-engineer.md` | Frontend Engineer 角色定义 | 直接复制 + 改技术栈 / 删领域美学段 |
| `domain-expert.md` | **唯一需 instantiate 的角色**（重命名 + 大段重写）| 重命名为 lawyer.md / physician.md / etc |
| `product-manager.md` | Product Manager 角色定义 | 直接复制（最干净）|
| `ui-ux-designer.md` | UI/UX Designer 角色定义 | 直接复制 + 删领域美学段 |
| `qa-engineer.md` | QA Engineer 角色定义 | 直接复制 + 改黄金集文件名 |
| `devops-engineer.md` | DevOps Engineer 角色定义 | 直接复制 + 改技术栈名 |
| `data-analyst.md` | Data Analyst 角色定义 | 直接复制 + 删领域问题清单 |
| `tagged-sessions-protocol.md` | Multi-session 协调协议 | 直接复制（含 Sprint K 实证案例）|
| `cross-domain-mapping.md` | 6 领域 instantiation 速查表 | 复制一次（每项目，用于查询）|

---

## 3. 5 分钟快速上手

```bash
# 1. 复制本目录到你的项目
cp -r /path/to/huadian/framework/role-templates /path/to/your-project/.claude/agents

# 2. 重命名 Domain Expert 文件
cd /path/to/your-project/.claude/agents
mv domain-expert.md ⚠️FILL.md   # 如 lawyer.md / physician.md / buddhologist.md / patent-attorney.md

# 3. 编辑 domain-expert.md（重命名后）
#    按文件内 ⚠️FILL 占位符提示填写：
#    - 角色名 / 项目名 / 领域名
#    - 字典文件清单
#    - 黄金集格式 example
#    - 实体歧义 / 来源可信度评级 等具体含义

# 4. 编辑其他 9 个角色文件
#    按文件内 ⚠️FILL 占位符提示改填路径名 / 技术栈名

# 5. 在 qa-engineer.md §反馈分诊流程 同步更新 routing
#    把 "factual_error → Domain Expert" 改为 "factual_error → ⚠️FILL 你的角色名"

# 6. 阅读 tagged-sessions-protocol.md §1-§4
#    了解 multi-session 启动 / 收尾 / handoff 协议

# 7. 启动你的 Sprint A
#    第一个 session 用 【Architect】 tag（主 session，不并行）
#    后续按 brief 调度子 session（【PE】/【BE】/【FE】/【你的 Domain Expert tag】/etc）
```

---

## 4. 跨领域使用指南

### 4.1 必须 instantiate 的字段

每个模板用 `⚠️FILL-XXX` 标注**领域专属**字段。这些字段必须按你的领域填写，不能照抄华典智谱史记案例。

最常见 instantiate 场景：

| 字段类型 | 古籍领域填法 | 法律领域填法 | 医疗领域填法 |
|---------|-----------|-----------|-----------|
| 项目名 | 华典智谱 | 法律 KE 项目 | 医疗 KE 项目 |
| Domain Expert 角色名 | Historian / 古籍专家 | Lawyer / 律师 | Physician / 临床医师 |
| Domain Expert tag | 【Hist】 | 【Lawyer】 | 【Doctor】 |
| 字典文件 | dynasty-periods.yaml / disambiguation_seeds.yaml | jurisdictions.yaml / case-citations.yaml | clinical-codes.yaml / drug-mappings.yaml |
| 主要 source 类型 | ctext / wikisource | LexisNexis / Westlaw | UpToDate / 临床指南 PDF |
| 黄金集格式 example | 项王 / 垓下 NER | 当事方 / 法条 NER | 患者 / 诊断 NER |

### 4.2 角色 tag 调整

10 个 AKE 角色中只有 Domain Expert 的 tag 需要 instantiate：

| 领域 | Domain Expert tag |
|------|------------------|
| 古籍（华典智谱）| 【Hist】 |
| 佛经 | 【Buddhist】 |
| 法律 | 【Lawyer】 |
| 医疗 | 【Doctor】 |
| 专利 | 【Patent】 |
| 地方志 | 【LocalHist】 |

其他 6 个 tag（【Architect】/【PE】/【BE】/【FE】/【QA】/【DevOps】）跨领域不变。

### 4.3 协议反模式跨领域复用

`tagged-sessions-protocol.md` §7 列出的 5 个反模式（万能角色 / 模糊决策权 / 跳级协作 / 口头交接 / 跳过升级机制）跨领域 100% 适用，无需 instantiate。

---

## 5. 设计哲学

本套模板基于以下信念（参见 `docs/methodology/01-role-design-pattern.md` §1 设计原则）：

### 5.1 LLM 窗口 = 角色边界的物理基础

LLM context window 有限。一个 session 装入"角色定义 + 任务卡 + 项目状态 + 既有代码 + 协作历史"已经接近上限。再让它"既懂古籍又懂 GraphQL 又懂 UI 又懂 SRE"，每一面都浅。

→ 角色拆分不是组织手段，是 LLM 物理约束推出的必然结论。

### 5.2 决策权 vs 执行权

- **决策权（A — Accountable）**：在专业领域内"这件事怎么做"的最终判断
- **执行权（R — Responsible）**：动手实现 / 编写 / 审查的人

跨角色协作 = 决策权和执行权的明确传递。

### 5.3 RACI 矩阵作为契约

每个任务必须有：

- 唯一 `A`（最终责任方）
- 一个或多个 `R`（执行者，但必须明确主导）
- 一些 `C`（咨询方）和 `I`（知会方）

这个矩阵是**契约**，越界 = 违约。

### 5.4 越位禁区强制化

每个角色都有明确的**不得做**清单。违反禁区视为**严重违规**，必须立即停止并升级到 Architect 仲裁。

---

## 6. 反模式（不要这么做）

读过 `tagged-sessions-protocol.md` §7 反模式，简短重申：

- ❌ **万能角色**：一个 session 同时扮演多个角色 → 上下文坍缩
- ❌ **模糊决策权**：两个角色一起决定一件事，没有唯一 A
- ❌ **跳级协作**：FE 直接改 schema（应该 issue 给 BE）
- ❌ **口头交接**：没有 audit trail 的协作 = 没协作
- ❌ **跳过升级机制**：两个角色绕过 Architect 私下达成共识

详见 `tagged-sessions-protocol.md` §7。

---

## 7. 反馈与贡献

本套模板从华典智谱 Sprint K 5 角色协同实战 + `.claude/agents/*` 10 份角色定义抽出，是 v0.1 状态。预期会随更多案例（包括跨领域）反馈而迭代。

如果你用本套模板做了你的项目，欢迎：

- **报告使用经验**（GitHub Issue 标 `role-templates-feedback`）
- **指出遗漏 / 不清楚的地方**（GitHub Issue 标 `role-templates-gap`）
- **贡献跨领域 instantiation 范例**（GitHub PR 加你的领域 Domain Expert 文件 + cross-domain-mapping.md 行）

详见华典智谱主项目 [CONTRIBUTING.md](https://github.com/lizhuojunx86/huadian/blob/main/CONTRIBUTING.md)。

---

## 8. 版本信息

| Version | Date | Source | Change |
|---------|------|--------|--------|
| v0.1 | 2026-04-29 | Sprint M Stage 1 (first abstraction) | 初版抽出（10 角色模板 + tagged-sessions-protocol + cross-domain-mapping）|
| v0.1.1 | 2026-04-29 | Sprint M Stage 4 follow-up patch | DGF-M-04 / DGF-M-05 / DGF-M-06 / DGF-M-07 落地：domain-expert + chief-architect §核心职责加单独条目；tagged-sessions-protocol §2.3 / §4.5 加协调模式区分注脚 |
| **v0.2.0** | **2026-04-30** | **Sprint P v0.2 release** | 内容无独立 patch；与 framework v0.2 release 同步发布（统一版本号便于跨模块引用）|
| v0.2.1 | 2026-04-30 | Sprint R 批 2 patch | chief-architect.md §工作风格 加"工程小细节"段（dataclass shape test 起草前先 grep target 字段 / "P3 复发升级 P2" 暗规则 / debt 文档 file count 用 grep 实数）— 来自华典智谱 Sprint P+Q retro 沉淀 (T-V03-FW-004) |

---

> 本套模板是 AKE 框架 Layer 1 的第二刀。第一刀是 `framework/sprint-templates/`（Sprint L Stage 1 完成）。
> 两套模板配合使用，构成 framework/ 下"治理类"双模块——sprint workflow + role coordination。
> 当前完整 framework 目录见华典智谱主项目 https://github.com/lizhuojunx86/huadian/tree/main/framework
