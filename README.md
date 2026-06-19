# 华典智谱 (HuaDian)

> **给要用 AI agent 团队构建可信知识库的工程师**：用 LLM 做抽取很容易，难的是——实体合并错了没人发现、质量约束停留在口头、决策过程无法追溯。
> 本仓库把解决这三件事的工程实践抽成开源框架 **kb-forge**（纯 Python 核心，clone 后一条 `pytest` 即可验证：93 passed），配套 Sprint / 角色治理模板，并附一个全程跑通的《史记》知识库参考实现。
> **30 秒判据**：你在做"严谨地**造**可信知识"→ 这个仓库适合你；你在找 RAG / chatbot / 古籍阅读 App → 不适合，请看 [shiji-kb](https://github.com/baojie/shiji-kb) 等近邻项目。
>
> *Agentic Knowledge Engineering Framework + Reference Implementation on Sima Qian's Shiji*

[![License: Apache 2.0 (code)](https://img.shields.io/badge/License--Code-Apache%202.0-blue.svg)](LICENSE)
[![License: CC BY 4.0 (data/docs)](https://img.shields.io/badge/License--Data%20%26%20Docs-CC%20BY%204.0-lightgrey.svg)](LICENSE-DATA)
[![Status: framework v0.3.0 (kb-forge)](https://img.shields.io/badge/Status-framework%20v0.3.0%20(kb--forge)-brightgreen.svg)](docs/STATUS.md)

---

## 这个项目是什么

**简短版**：一个用 AI agent 团队构建知识库的工程框架 + 一个真实的实现案例（《史记》）。具体交付三样东西：可直接 `pytest` 验证的纯 Python 框架核心（`framework/`）、复制即用的 Sprint / 角色治理模板、以及完整公开的工程过程记录（34 ADRs + Sprint A-AA 全部日志）。

**长一点**：当前主流 AI 工具（LangChain / LlamaIndex / AutoGen / CrewAI 等）解决的是 *"用 LLM 做事"* — 取知识、调工具、跑 RAG。但 *"用 AI 团队严谨地构造可信知识"* 这件事，市场上没有通用方案。

单人 + AI 已被证明可以高产（参见 [shiji-kb](https://github.com/baojie/shiji-kb)），但要扩展到大规模、多机构、多领域、长期维护场景，单人 SKILL 范式撑不住。需要：

- **团队级工程纪律** — Sprint / Stage / Gate / Stop Rule
- **多角色协作 + 角色边界** — PE / BE / FE / Hist / Architect tagged sessions
- **可追溯的决策记录** — ADR-driven architecture
- **形式化质量约束** — V1-V11 invariants
- **人机协作审计** — pending_merge_reviews + triage_decisions audit trail
- **可观测性** — TraceGuard prompt versioning + cost/latency tracking

华典智谱提取这套实践为通用框架（Layer 1），同时持续以《史记》知识库案例验证（Layer 3），最终形成可复用的知识工程方法论（Layer 2）。

完整定位见 [`docs/strategy/D-route-positioning.md`](docs/strategy/D-route-positioning.md)。

---

## Quick start

### 路径 A — 只想用框架（推荐起点，~5 分钟，零服务依赖）

`framework/`（发行名 **kb-forge**）核心是 **pure-Python（stdlib only）** — 不需要数据库、不需要 Docker：

```bash
git clone https://github.com/lizhuojunx86/huadian.git && cd huadian
python -m venv .venv && source .venv/bin/activate
pip install -r framework/requirements-dev.txt

python -m pytest \
  framework/identity_resolver/tests \
  framework/invariant_scaffold/tests \
  framework/audit_triage/tests
# -> 93 passed
```

这就是可测量的"外部工程师 clone + 跑通"路径（目标 ≤ 1 小时）。下一步：

- 读 [`framework/README.md`](framework/README.md) — 5 个模块各是什么
- fork 到你的领域 — 每个 Python 包自带 `cross-domain-mapping.md` 改造指南

### 路径 B — 跑完整史记参考实现（全栈，需要 pnpm + uv + Docker）

```bash
# 1. Install dependencies
pnpm install && uv sync --all-packages

# 2. Install pre-commit hooks
pip install pre-commit --user && pre-commit install

# 3. Start infrastructure (PostgreSQL + Redis + SigNoz)
make up

# 4. Start dev servers
pnpm dev
# → API:  http://localhost:4000/graphql
# → Web:  http://localhost:3000
```

详细搭建说明：[`docs/runbook/RB-001-local-dev.md`](docs/runbook/RB-001-local-dev.md)

**Quick demo（路径 B setup 完毕后，5 分钟）** — 看 AKE 框架"真的 work"的活体证明，按 [`docs/runbook/RB-002-demo-walkthrough.md`](docs/runbook/RB-002-demo-walkthrough.md) 走通：

1. **Triage UI** — 浏览 `http://localhost:3000/triage?historian=chief-historian`，看 Sprint A-K 累积的 63 条真实 pending decisions + 跨 sprint 决策回查（Hint Banner）
2. **V1-V11 Invariants** — `pytest tests/test_invariants_*.py` → 全绿
3. **Identity Resolver Dry-Run** — `python scripts/dry_run_resolve.py` 看 R1-R6 + GUARD_CHAINS 实时拦截
4. **数据基线** — SQL 直查 729 active persons + 111 merge_log + 177 triage_decisions

Demo 不展示：C 端阅读器 / 移动端 / 完整史记 130 篇 / 公开 URL — 这些不在 D-route 范围（参见 [`docs/strategy/D-route-positioning.md §7`](docs/strategy/D-route-positioning.md) Negative Space）。如果你想要其中某项，请考虑 [shiji-kb](https://github.com/baojie/shiji-kb) 等近邻项目。

---

## 当前状态

**2026-06：framework v0.3.0（命名 `kb-forge`，[ADR-037](docs/decisions/ADR-037-framework-package-naming.md)）· 史记主案例 + 第二案例（中成药提取）双案例验证中**

Sprint A-AA 累计成果：

- 34 ADRs（架构决策记录，编号至 ADR-038）
- **`framework/` 5 模块就位（v0.3.0）** — identity_resolver / invariant_scaffold / audit_triage 三个 Python 包（各带 tests + examples，全套 **93 tests passed**）+ sprint-templates v0.3.2 + role-templates v0.3.1
- 729 active persons in DB；Identity resolver R1-R6 + GUARD_CHAINS（cross_dynasty + state_prefix guards）
- V1-V11 invariants 全绿
- Triage UI V1（pending_merge_reviews + triage_decisions audit）
- 3-4 篇本纪深度结构化（项羽 / 秦 / 高祖）
- **第二案例（中成药提取 QC）验证框架可移植性** — 独立 schema 演进（3 ADRs：033/034/035）+ TraceGuard E1-E3 真实 PoC + 应用层方法论文章 3 篇工作稿（见 `docs/methodology/08`-`10`）

战略方向：2026-04-29 经 [ADR-028](docs/decisions/ADR-028-strategic-pivot-to-methodology.md) 决定从「C 端古籍知识平台」转向「方法论框架 + 史记参考实现」(D-route)。

实时状态板：[`docs/STATUS.md`](docs/STATUS.md)
变更日志：[`docs/CHANGELOG.md`](docs/CHANGELOG.md)

---

## 框架抽象成果（Layer 1 / `framework/` = kb-forge）

D-route Layer 1 的核心产出 — **领域无关的 KE 工程内核 + 项目模板**，跨领域 KE 项目（佛经 / 法律 / 医疗 / 专利 / 地方志 / etc）可以直接复制 + 改填即用。

### 已抽象资产（v0.3.0）

| 模块 | 形态 | 抽象自 |
|------|-----|-------|
| [`framework/identity_resolver/`](framework/identity_resolver/) | Python 包 | R1-R6 跨 chunk 实体消解 + 可插拔 `GUARD_CHAINS` |
| [`framework/invariant_scaffold/`](framework/invariant_scaffold/) | Python 包 | V1-V11 形式化质量约束（invariant pattern）|
| [`framework/audit_triage/`](framework/audit_triage/) | Python 包 | pending-review 队列 + 不可变决策审计 + hint banner |
| [`framework/sprint-templates/`](framework/sprint-templates/) | 文档模板 v0.3.2 | Sprint / Stage / Gate 工作流 + Stop Rules |
| [`framework/role-templates/`](framework/role-templates/) | 文档模板 v0.3.1 | 10 个领域中立 agent 角色定义 + tagged-sessions protocol |

每个 Python 包自带 `README.md` + `CONCEPTS.md` + `cross-domain-mapping.md`（跨领域 fork 指南）+ `tests/` + `examples/huadian_classics/` 参考实现。

**命名**：框架发行名定为 **`kb-forge`**（[ADR-037](docs/decisions/ADR-037-framework-package-naming.md)，2026-06-07 accepted）；import root `framework.*` → `kb_forge.*` 的改名将在 v0.1 正式发布前的专门 sprint 完成。

### 跨领域使用门槛

10 个 AKE 角色中**只有 1 个**（Domain Expert）需要 instantiate（重命名 + 大段重写为你领域的等价 — 古籍 → Historian / 法律 → Lawyer / 医疗 → Physician / etc）。其他 9 个角色（Architect / PE / BE / FE / QA / DevOps / PM / Designer / Analyst）跨领域**完全不变**，复制即用。

### 自审 dogfood 验证

- Sprint L 用 framework/sprint-templates/ 给自己收档：覆盖度 90%
- Sprint M 用 framework/role-templates/ 回审 Sprint K 5 角色协同实战：覆盖度 **99.2%**
- Sprint N **byte-identical dogfood**：框架版 identity resolver 对 729 person 生产数据 **100% 等价**（17 guard 拦截一一对应）
- Sprint O：framework 版 invariants 11/11 + 4/4 self-tests 通过
- **第二领域验证**：中成药提取案例通过 TraceGuard E1-E3 真实 PoC + 第 2 个 domain config 验证可移植性

**诚实状态**：领域无关 LOC 比例当前实测 ~56-62%（目标 ≥ 70%，`examples/` 仍偏重）— 完整判据表见 [`framework/README.md`](framework/README.md)。

### 下一步（roadmap）

import root 改名 `kb_forge.*` → 领域无关 LOC 比例提升至 ≥ 70% → `pip install -e` 可安装打包（详见 [ADR-037](docs/decisions/ADR-037-framework-package-naming.md) + [`framework/README.md`](framework/README.md)）。

---

## 延伸阅读（项目实践文章）

来自本项目工程实践的文章（2026-06 起发布于知乎 / 掘金，源文件在 [`docs/articles/publish/`](docs/articles/publish/)）：

- 给 AI agent 团队设计"硬中断"：5 类 Stop Rule 与 4 个反模式 — [知乎](https://zhuanlan.zhihu.com/p/2049033957845607396) · [掘金](https://juejin.cn/post/7652526717098868751)
- 一个人 + AI 扮演 10 个角色：8 周、27 个 sprint、34 份 ADR 全程留痕之后，我学到了什么 — [知乎](https://zhuanlan.zhihu.com/p/2049056588497940839) · [掘金](https://juejin.cn/post/7652526717098885135)
- 另一个项目"抄"了我们的框架之后：4 条骨架活了下来，60% 的设计被扔掉 — [知乎](https://zhuanlan.zhihu.com/p/2049057076417126646) · [掘金](https://juejin.cn/post/7652630546754191360)
- LLM 抽出来的实体，为什么不能自动合并——一套"提议 + 人审"的消歧工程方案（待发布）

---

## 与相邻项目的关系

我们与几个优秀的近邻项目**互补不冲突**：

| 项目 | 他们做什么 | 我们做什么 |
|------|----------|-----------|
| [shiji-kb](https://github.com/baojie/shiji-kb) | 单人英雄主义 + SKILL 个人 playbook + 史记数据深度（130 篇）| 团队工业化 + ADR 治理 + 框架抽象 |
| 字节识典古籍 | 闭源大厂 B 端服务 | 开源框架 + 工程师 DIY 路径 |
| LangChain / AutoGen 等 | "用 LLM 做事"（取知识 / agent 调用）| "严谨地构造可信知识"（造知识 / 团队治理）|

详细差异化见 [`docs/strategy/D-route-positioning.md`](docs/strategy/D-route-positioning.md) §3。

---

## 项目结构

```
framework/             → **Layer 1 框架抽象产出 (kb-forge v0.3.0)**（跨领域 KE 项目复用）
  ├── identity_resolver/        → R1-R6 实体消解 + GUARD_CHAINS (Python 包)
  ├── invariant_scaffold/       → V1-V11 质量约束模式 (Python 包)
  ├── audit_triage/             → 审计 + triage 工作流 (Python 包)
  ├── sprint-templates/         → Sprint 治理模板 v0.3.2
  └── role-templates/           → 多角色协作模板 v0.3.1
apps/web/              → Next.js 14 frontend (含 triage UI + 阅读 demo)
services/api/          → GraphQL API (Yoga + Drizzle)
services/pipeline/     → Python data pipeline (uv + Anthropic SDK)
packages/              → Shared libraries (types, schema, UI, config)
docker/                → Docker Compose + custom images
data/                  → Curated reference data (historian-owned)
docs/
  ├── 00_项目宪法.md            → 不可变原则
  ├── 03_多角色协作框架.md       → 角色 + 协作模式
  ├── decisions/                → 34 ADRs
  ├── methodology/              → 方法论文档 (Layer 2)
  ├── cases/                    → 第二案例（中成药提取）等跨领域案例材料
  ├── strategy/                 → 战略文档 (含 D-route 定位)
  ├── sprint-logs/              → Sprint A-AA 完整执行记录
  ├── tasks/                    → 任务卡 (T-NNN-*.md)
  ├── retros/                   → 各 sprint 复盘
  ├── debts/                    → 衍生债 / framework 迭代候选清单
  └── STATUS.md                 → 实时状态板
.claude/agents/        → 10 个 agent 角色定义（华典智谱实例 / framework/role-templates 的具体 instantiation）
```

---

## 技术栈

| Layer | Stack |
|-------|-------|
| Frontend | Next.js 14, TypeScript, Tailwind, shadcn/ui |
| API | GraphQL Yoga, Drizzle ORM, Node.js |
| Pipeline | Python 3.12, Prefect, Anthropic SDK, TraceGuard |
| Database | PostgreSQL 16 (pgvector + PostGIS + pg_trgm) |
| Cache | Redis 7 |
| Observability | OpenTelemetry, SigNoz, Sentry, PostHog |
| Monorepo | pnpm workspaces, Turborepo, uv |

---

## 给 Claude Code / Cowork 用户

本项目天然为多 agent 协作设计。

- **会话接续模板**：[`CLAUDE.md §8`](CLAUDE.md#8-会话接续模板)
- **Agent 角色定义**：[`.claude/agents/`](.claude/agents/)
- **项目入口**：[`CLAUDE.md`](CLAUDE.md)

新 session 启动建议遵循"开工三步"（CLAUDE.md §0）：
1. 读 `docs/STATUS.md`（当前状态）
2. 读 `docs/CHANGELOG.md` 最近 5 条（变更上下文）
3. 读 `.claude/agents/{你的角色}.md`（角色边界）

---

## 文档导航

**入门 / 概览**：
- [README](README.md)（本文件）
- [项目入口 CLAUDE.md](CLAUDE.md)
- [实时状态板](docs/STATUS.md)
- [变更日志](docs/CHANGELOG.md)

**战略 / 方向**：
- [D-route 定位文档](docs/strategy/D-route-positioning.md)
- [ADR-028 战略转型决策](docs/decisions/ADR-028-strategic-pivot-to-methodology.md)
- [项目宪法](docs/00_项目宪法.md)

**框架抽象（Layer 1，可立即复用）**：
- [framework/](framework/) — kb-forge v0.3.0 总览（5 模块 + Quick start + 完成判据）
- [framework/sprint-templates/](framework/sprint-templates/) — Sprint 治理模板 v0.3.2
- [framework/role-templates/](framework/role-templates/) — 多角色协作模板 v0.3.1

**方法论（Layer 2，持续起草）**：
- [docs/methodology/](docs/methodology/) — 00-07 框架模式（v0.2）+ 08-11 案例应用篇（工作稿）+ decision-journals/ 月度决策日记

**架构 / 实现**：
- [架构设计文档 v2.0](华典智谱_架构设计文档_v2.0.md)（v1.0 已归档至 [docs/archive/](docs/archive/华典智谱_架构设计文档_v1.0.md)）
- [Architecture Decision Records](docs/decisions/)（34 ADRs）
- [Sprint logs](docs/sprint-logs/)（A-AA 完整记录）

**协作 / 流程**：
- [多角色协作框架](docs/03_多角色协作框架.md)
- [工作流与进度机制](docs/04_工作流与进度机制.md)
- [质检与监控体系](docs/05_质检与监控体系.md)

---

## 贡献

欢迎贡献！请先阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。

特别欢迎：
- **跨领域案例尝试** — 用本框架做佛经 / 法律 / 医疗 / 地方志等其他领域知识库；案例本身就是对方法论的最大反馈
- **方法论文档共著** — 见 docs/methodology/ 草案
- **框架抽象优化** — 见 ADR-028 Appendix B 已识别的 15 个工程模式
- **Bug 报告 + 修复 PR** — 任何对当前案例（华典智谱史记）的修订

---

## 许可证

本项目采用**双许可证**结构：

- **代码** (apps/, services/, packages/, scripts/, build configs)：[Apache License 2.0](LICENSE)
- **数据 / 文档 / 方法论** (docs/, data/, fixtures/sources/, *.md)：[CC BY 4.0](LICENSE-DATA)

**允许商业使用 + 必须保留来源声明**。详见 [LICENSE](LICENSE) / [LICENSE-DATA](LICENSE-DATA) / [NOTICE](NOTICE) 三份文件。

第三方源数据归属（《史记》原文 / Wikidata 字典等）见 [NOTICE](NOTICE)。

许可证决策依据见 [ADR-029](docs/decisions/ADR-029-licensing-policy.md)。

---

## 致谢

- **[Chinese Text Project (ctext.org)](https://ctext.org)** — 提供史记文本的开放数字化版本
- **Wikidata 社区** — CC0 字典数据使我们的框架得以开放
- **[shiji-kb](https://github.com/baojie/shiji-kb) 项目** — 在我们之前证明了"AI + 古籍"的可行性，给了我们站在巨人肩膀上的勇气
- **Anthropic** — Claude / Cowork mode / SubAgent 等工具是本框架的 substrate

---

**项目状态**：早期、活跃、欢迎参与 / 反馈 / fork。

**联系方式**：通过 [GitHub Issues](https://github.com/lizhuojunx86/huadian/issues)。

**项目地址**：https://github.com/lizhuojunx86/huadian
