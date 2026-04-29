# 华典智谱 (HuaDian)

> **Agentic Knowledge Engineering Framework + Reference Implementation on Sima Qian's Shiji**
>
> 一个开源的工程框架，让 AI agent 团队能够严谨、可审计、可复用地构建可信知识库。
> 以《史记》知识库作为参考实现。

[![License: Apache 2.0 (code)](https://img.shields.io/badge/License--Code-Apache%202.0-blue.svg)](LICENSE)
[![License: CC BY 4.0 (data/docs)](https://img.shields.io/badge/License--Data%20%26%20Docs-CC%20BY%204.0-lightgrey.svg)](LICENSE-DATA)
[![Status: Phase 0 / Sprint K complete](https://img.shields.io/badge/Status-Phase%200%20%2F%20Sprint%20K-orange.svg)](docs/STATUS.md)

---

## 这个项目是什么

**简短版**：一个用 AI agent 团队构建知识库的工程框架 + 一个真实的实现案例（《史记》）。

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

## 当前状态

**Phase 0 — Sprint K 完成（2026-04-29）**

Sprint A-K 累计成果：
- 27 ADRs（架构决策记录）
- 729 active persons in DB
- Identity resolver R1-R6 + GUARD_CHAINS（cross_dynasty + state_prefix guards）
- V1-V11 invariants 全绿
- Triage UI V1（pending_merge_reviews + triage_decisions audit）
- 3-4 篇本纪深度结构化（项羽 / 秦 / 高祖）

战略方向：2026-04-29 经 [ADR-028](docs/decisions/ADR-028-strategic-pivot-to-methodology.md) 决定从「C 端古籍知识平台」转向「方法论框架 + 史记参考实现」(D-route)。

实时状态板：[`docs/STATUS.md`](docs/STATUS.md)
变更日志：[`docs/CHANGELOG.md`](docs/CHANGELOG.md)

---

## 与相邻项目的关系

我们与几个优秀的近邻项目**互补不冲突**：

| 项目 | 他们做什么 | 我们做什么 |
|------|----------|-----------|
| [shiji-kb](https://github.com/baojie/shiji-kb)（鲍捷）| 单人英雄主义 + SKILL 个人 playbook + 史记数据深度（130 篇）| 团队工业化 + ADR 治理 + 框架抽象 |
| 字节识典古籍 | 闭源大厂 B 端服务 | 开源框架 + 工程师 DIY 路径 |
| LangChain / AutoGen 等 | "用 LLM 做事"（取知识 / agent 调用）| "严谨地构造可信知识"（造知识 / 团队治理）|

详细差异化见 [`docs/strategy/D-route-positioning.md`](docs/strategy/D-route-positioning.md) §3。

---

## Quick start (5 minutes)

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

---

## 项目结构

```
apps/web/              → Next.js 14 frontend (含 triage UI + 阅读 demo)
services/api/          → GraphQL API (Yoga + Drizzle)
services/pipeline/     → Python data pipeline (uv + Anthropic SDK)
packages/              → Shared libraries (types, schema, UI, config)
docker/                → Docker Compose + custom images
data/                  → Curated reference data (historian-owned)
docs/
  ├── 00_项目宪法.md            → 不可变原则
  ├── 03_多角色协作框架.md       → 角色 + 协作模式
  ├── decisions/                → 27+ ADRs
  ├── methodology/              → 方法论草案 (Layer 2 sources)
  ├── strategy/                 → 战略文档 (含 D-route 定位)
  ├── sprint-logs/              → Sprint A-K 完整执行记录
  ├── tasks/                    → 任务卡 (T-NNN-*.md)
  ├── retros/                   → 各 sprint 复盘
  └── STATUS.md                 → 实时状态板
.claude/agents/        → 10 个 agent 角色定义 (Multi-role coordination)
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

**方法论（Layer 2，持续起草）**：
- [docs/methodology/](docs/methodology/) — 7 份草案（待起草）

**架构 / 实现**：
- [架构设计文档](华典智谱_架构设计文档_v1.0.md)（v1.0 待 Stage B 升级 v2.0）
- [Architecture Decision Records](docs/decisions/)（27+ ADRs）
- [Sprint logs](docs/sprint-logs/)（A-K 完整记录）

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
- **shiji-kb 项目（鲍捷）** — 在我们之前证明了"AI + 古籍"的可行性，给了我们站在巨人肩膀上的勇气
- **Anthropic** — Claude / Cowork mode / SubAgent 等工具是本框架的 substrate

---

**项目状态**：早期、活跃、欢迎参与 / 反馈 / fork。

**联系方式**：通过 [GitHub Issues](https://github.com/lizhuojunx86/huadian/issues)。

**项目地址**：https://github.com/lizhuojunx86/huadian
