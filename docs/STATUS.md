# 华典智谱 · 项目状态板

> **本文件是项目的"现在时刻"快照，每次会话开始 / 结束都应阅读或更新。**

- **最近更新**：2026-04-15
- **更新人**：DevOps 工程师（Claude Opus）
- **当前阶段**：Phase 0 — **Monorepo 骨架已落地，进入 DB Schema 阶段**

---

## 当前在哪

**T-P0-001（Monorepo 骨架）已完成（2026-04-15）。**

仓库已具备：
- pnpm + uv + Turborepo 工具链
- 10 个子包骨架（全部可 `pnpm -r build`）
- Docker Compose：PG 16（pgvector + PostGIS + pg_trgm）+ Redis 7 + OTel Collector
- CI 八步流水线（lint / typecheck / codegen:verify / test / build / docker smoke / secret-scan / graphql:breaking）
- 跨语言类型生成：zod → JSON Schema → Pydantic
- pre-commit（gitleaks + lint-staged）
- CODEOWNERS + Dependabot + PR/Issue 模板

**SigNoz 子栈推迟到 T-P0-005a**（镜像版本问题，详见 CHANGELOG）。

**下一步推进建议**：**T-P0-002（DB Schema 落地）** 由后端工程师主导。

---

## 已完成

### T-P0-001 Monorepo 骨架落地（2026-04-15）
- [x] 根级工具链（package.json / pnpm-workspace / turbo.json / tsconfig / pyproject.toml / Makefile）
- [x] 共享配置包（config-typescript / config-eslint）
- [x] 10 个子包骨架（apps/web / services/api / services/pipeline / packages/*）
- [x] Docker Compose（PG + Redis + OTel Collector）
- [x] 环境变量（.env.example）+ pre-commit（gitleaks + lint-staged）
- [x] CI（ci.yml 八步 + pre-commit.yml + CODEOWNERS + dependabot）
- [x] 脚本（dev.sh / db-reset.sh / smoke.sh / gen-types.sh）
- [x] 文档（RB-001 本地开发 / README 扩写）

### 架构设计文档落地（2026-04-15）
- [x] 架构设计文档 v1.0
- [x] 项目宪法 `docs/00_项目宪法.md`
- [x] 七份核心文档 `docs/01~06`
- [x] 10 个 Agent 角色定义
- [x] ADR-001 ~ ADR-007（7 条 accepted）

---

## 进行中

无。等待用户启动 T-P0-002。

---

## 下一步候选（按建议优先级）

| 优先级 | 任务 ID | 描述 | 主导角色 | 依赖 |
|--------|---------|------|---------|------|
| 🔴 高 | T-P0-002 | DB Schema 落地（Drizzle 真实表定义 + 迁移） | 后端工程师 | T-P0-001 ✅ |
| 🟡 中 | T-P0-004 | 历史专家字典初稿（polities / reign_eras / disambiguation_seeds） | 历史专家 | T-003 ✅ |
| 🟡 中 | T-P0-005 | LLM Gateway + TraceGuard 基础集成 | 管线工程师 | T-P0-002 |
| 🟡 中 | T-P0-005a | SigNoz 版本对齐与接入 | DevOps + 管线 | T-P0-005 |
| 🟢 低 | T-P0-003 | GraphQL schema 骨架 | 后端工程师 | T-P0-002 |

---

## 阻塞项

| # | 描述 | 等待 | 建议处理 |
|---|------|------|---------|
| （无当前阻塞） | — | — | 可启动 T-P0-002 |

---

## 最近决策（ADR · 已接受）

- `ADR-001` — 单 PostgreSQL 16 + pgvector + PostGIS + pg_trgm
- `ADR-002` — 事件双层建模（Event + EventAccount）
- `ADR-003` — 多角色协作框架启用（10 角色）
- `ADR-004` — TraceGuard 集成合同（Port/Adapter 契约）
- `ADR-005` — Embedding 多槽位与模型切换策略
- `ADR-006` — 未决项 U-01~U-07 封版决策
- `ADR-007` — Monorepo 布局与包管理（pnpm + uv + Turborepo）

---

## 健康度指标

- 📘 文档覆盖度：核心 7/7 ✅
- 🧭 ADR 数量：7 accepted / 9 planned
- 📋 任务卡数量：T-P0-001 done；T-P0-002 ready；T-P0-005a planned
- 👥 Agent 角色定义：10/10 ✅
- 🏗️ 子包 build：10/10 全绿
- 🐳 Docker：PG + Redis 健康；SigNoz deferred
- 🧪 测试覆盖：N/A（Phase 0 无业务代码）
- 🚦 阻塞项数量：0 ✅

---

## 更新日志（STATUS 文件本身的）

- 2026-04-15：初始化
- 2026-04-15：T-001 / T-002 / T-003 / T-TG-001 完成
- 2026-04-15：ADR-007 accepted；T-P0-001 ready
- 2026-04-15：T-P0-001 done — Monorepo 骨架落地；SigNoz deferred to T-P0-005a；T-P0-002 进入 ready
