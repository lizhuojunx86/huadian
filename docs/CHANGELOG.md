# 华典智谱 · CHANGELOG

> 按时间倒序追加。每次任务完成、决策变更、文档修订都应在此留痕。
> 格式参考 [Keep a Changelog](https://keepachangelog.com/) + Conventional Commits。

---

## 2026-04-15（夜 · 五批）

### [feat] T-P0-001 完成 — Monorepo 骨架落地
- **角色**：DevOps 工程师（执行）+ 首席架构师（评审）
- **任务**：T-P0-001
- **变更**：
  - 根级工具链：`package.json`（pnpm 9.15.4）/ `pnpm-workspace.yaml` / `turbo.json` / `tsconfig.base.json` / `pyproject.toml`（uv workspace）/ `Makefile` / `.nvmrc`（Node 20）/ `.python-version`（3.12）
  - 共享配置包：`packages/config-typescript/`（base / nextjs / node 三套 tsconfig）/ `packages/config-eslint/`（index / nextjs / node / python-ignore 四入口）/ `.eslintrc.cjs` / `.prettierrc` / `.editorconfig` / `ruff.toml`
  - 10 个子包骨架：`apps/web`（Next.js 14）/ `services/api`（GraphQL Yoga + Drizzle 执行层）/ `services/pipeline`（Python + basedpyright）/ `packages/{shared-types, db-schema, design-tokens, ui-core, analytics-events, qc-schemas}`
  - 容器：`docker/compose.dev.yml`（PG 16 + Redis 7.2 + OTel Collector 0.103.0）/ `docker/postgres/Dockerfile`（pgvector + PostGIS）/ `db/init/01-extensions.sql`（vector / postgis / postgis_topology / pg_trgm）
  - 环境：`.env.example`（全 key 覆盖）/ `.pre-commit-config.yaml`（gitleaks + lint-staged + trailing-whitespace）
  - CI：`.github/workflows/ci.yml`（八步：lint → typecheck → codegen:verify → test → build → docker-smoke → secret-scan → graphql:breaking）/ `.github/workflows/pre-commit.yml` / `.github/CODEOWNERS` / `.github/dependabot.yml`（四生态）/ PR + Issue 模板
  - 脚本：`scripts/{dev.sh, db-reset.sh, smoke.sh, gen-types.sh}`
  - 文档：`docs/runbook/RB-001-local-dev.md` / `README.md` 扩写 / `data/README.md`
  - 跨语言类型生成：zod → JSON Schema → Pydantic 全链路跑通
  - `pnpm-lock.yaml` / `uv.lock` 入库
- **架构师评审修正**：
  - 子任务组 4：`deploy.replicas: 0` 不生效于非 Swarm → 改用 Compose `profiles: ["observability"]`
  - 子任务组 6：CI step 7 docker-smoke 与 secret-scan 拆为独立并行 job
  - 子任务组 8：`analytics-events` / `qc-schemas` tsconfig 改 extends base（非 node）；`config-eslint` 补 `eslint-import-resolver-typescript`
- [decision] SigNoz 接入推迟到 T-P0-005a（镜像版本号 0.88.25 不存在于 Docker Hub；SigNoz 0.40+ 重构了镜像命名；正确做法是配合真实 trace 流量联调验证版本，而非盲 pin）
  - SigNoz 四服务在 `compose.dev.yml` 中注释保留
  - OTel Collector 降级为 logging exporter（trace → stdout）
  - 新增任务卡 `docs/tasks/T-P0-005a-signoz-pinning.md`
  - DoD #4 标记 deferred
- **下一步**：T-P0-002（DB Schema 落地）由后端工程师主导

### [fix] 端口映射调整避让本机其他项目
- **角色**：DevOps 工程师
- **任务**：T-P0-001 follow-up
- **变更**：
  - `docker/compose.dev.yml`：PG host 端口 5432→5433，Redis 6379→6380，均支持 env 覆盖（`HUADIAN_PG_PORT` / `HUADIAN_REDIS_PORT`）
  - `.env.example`：同步端口 + DATABASE_URL / REDIS_URL
  - `docs/runbook/RB-001-local-dev.md`：新增"端口约定"段
- **原因**：宿主机已有其他项目（qav2 timescaledb / redis）占用 5432 / 6379，`make up` 会报 `bind: address already in use`
- **影响**：容器内端口不变（5432 / 6379），仅 host 映射变；通过 `DATABASE_URL` / `REDIS_URL` 读取，不需改代码

---

## 2026-04-15（夜 · 四批）

### [decision] ADR-007 Monorepo 布局与包管理 accepted
- **角色**：DevOps（提议）+ 首席架构师（评审签字）
- **任务**：T-P0-001 前置
- **变更**：
  - 新增 `docs/decisions/ADR-007-monorepo-layout.md`（两轮评审后 accepted）
  - 新增 `docs/tasks/T-P0-001-monorepo-skeleton.md`（状态 ready）
  - 更新 `docs/decisions/ADR-000-index.md`（7 条 accepted / 9 条 planned）
  - 更新 `docs/tasks/T-000-index.md`（T-P0-001 进当前活跃；T-000~T-003 / T-001 / T-TG-001 归已完成）
- **核心决定**：
  - 单 monorepo；pnpm（Node 20 LTS）+ uv（Python 3.12）+ Turborepo
  - 目录三分：`apps/` / `services/` / `packages/`；`data/` 归历史专家 owner
  - 类型源头二分：业务 = zod（`packages/shared-types`）；持久 = Drizzle（`packages/db-schema`）；手写 DTO 对接，不自动互通
  - DB 编排：定义归 `packages/db-schema`，执行归 `services/api`
  - 本地可观测：SigNoz 社区版通过 docker-compose profile 可切
  - Python 类型检查：basedpyright（Phase 0）；ty 稳定后再评估
  - 镜像全部具名小版本；Dependabot 自动升级；Renovate 作备选
  - CI 八步（lint/typecheck/codegen:verify/build/test/docker smoke/secret-scan/graphql:breaking 告警）；主分支保护 1~7 必过
  - CODEOWNERS 按 agent 角色预埋路径，当前全指 @x86
- **修订过程**：架构师评审回合 1 提出 R-1~R-8（8 项）+ Q-1~Q-2（2 项澄清），DevOps 全部落实；回合 2 通过。遗留 F-1/F-2/F-3 作 Phase 0 follow-up，不阻塞签字
- **下一步**：用户决定何时启动 T-P0-001 实际落地（本会话不动手）

---

## 2026-04-15（晚 · 三批）

### [decision] ADR-001 ~ ADR-006 首批架构决策封版
- **角色**：首席架构师（用户授权代为封版 U-01~U-07 与 TraceGuard 7 问）
- **任务**：T-002 / T-003 / T-TG-001
- **变更**：
  - 新增 `docs/decisions/ADR-001-single-postgresql.md`
  - 新增 `docs/decisions/ADR-002-event-account-split.md`
  - 新增 `docs/decisions/ADR-003-multi-role-framework.md`
  - 新增 `docs/decisions/ADR-004-traceguard-integration-contract.md`（Port/Adapter 模式，取代 docs/06 §十 7 问）
  - 新增 `docs/decisions/ADR-005-embedding-multi-slot.md`
  - 新增 `docs/decisions/ADR-006-undecided-items-closure.md`（U-01~U-07 封版）
  - 更新 `docs/decisions/ADR-000-index.md`（6 条 accepted，10 条 planned）
  - 更新 `docs/06_TraceGuard集成方案.md` §十一，指向 ADR-004
- **核心决定**：
  - **ADR-001**：单 PostgreSQL 16 + pgvector + PostGIS + pg_trgm，5 条切出触发器
  - **ADR-002**：Event 抽象锚 + EventAccount 具体叙述 + account_conflicts 冲突表
  - **ADR-003**：10 角色 agent 框架正式启用
  - **ADR-004**：TraceGuard 以 Port/Adapter 契约集成；动作编排 / 存储 / 规则组合均由华典侧 Adapter 实现，不绑定 TraceGuard 原生 API
  - **ADR-005**：Embedding 多槽位表，初始用 bge-large-zh-v1.5（开源、1024 维、可本地部署）
  - **ADR-006**：U-01~U-07 封版（Wiki→Phase3 / 默认叙述→credibility_tier+人工 / 模拟器→保留+ai_inference 徽标 / 付费墙→Phase3 / 拼音→Phase2 / 错题集→Phase3 / 商业版 SLA→Phase4）
- **影响**：
  - 阻塞项 B-01 / B-02 关闭
  - Phase 0 编码前置条件全部解除
  - 新增子任务 T-TG-002（Adapter 实现），在 T-004 之后启动
- **下一步**：T-004（Monorepo 骨架）+ T-005（DB Schema 落地）

---

## 2026-04-15（晚 · 二批）

### [docs] T-001 完成 — 10 个 Agent 角色定义文件落地
- **角色**：首席架构师（Claude Opus）
- **任务**：T-001
- **变更**：在 `.claude/agents/` 下创建 10 个角色定义文件
  - `chief-architect.md`（首席架构师）
  - `product-manager.md`（产品经理）
  - `historian.md`（历史/古籍专家）
  - `ui-ux-designer.md`（UI/UX 设计师）
  - `backend-engineer.md`（后端工程师）
  - `pipeline-engineer.md`（数据管线工程师）
  - `frontend-engineer.md`（前端工程师）
  - `qa-engineer.md`（QA / 质检工程师）
  - `devops-engineer.md`（DevOps / SRE 工程师）
  - `data-analyst.md`（数据分析师）
- **统一结构**：YAML frontmatter + 角色定位 / 工作启动 / 核心职责 / 输入 / 输出 / 决策权限 / 协作关系 / 禁区 / 工作风格 / 标准开发流程
- **影响**：
  - Claude Code 在该项目下可通过 sub-agent 机制按角色分派任务
  - 每个 agent 启动必须先读 STATUS / CHANGELOG / 本角色文件，保证跨会话不掉线
  - 角色禁区强约束：禁止前端工程师做设计决策、禁止管线工程师改 schema、禁止 QA 改业务代码等
- **关闭阻塞**：B-03（agent 角色文件缺失）已关闭
- **下一步**：等待用户审阅 docs/00~06 + 答复 TraceGuard 7 个接口问题 + 决策 U-01~U-07，然后进入 T-002（首批 ADR）

---

## 2026-04-15

### [docs] 架构设计文档地基 v2 落地
- **角色**：首席架构师（Claude Opus）
- **任务**：pre-T-000 架构设计第二轮
- **变更**：
  - 新增 `CLAUDE.md`（项目入口）
  - 新增 `.gitignore`
  - 新增 `docs/00_项目宪法.md`
  - 新增 `docs/01_风险与决策清单_v2.md`（扩展到 12 大类 ~50 个风险点）
  - 新增 `docs/02_数据模型修订建议_v2.md`（新增 17 表、修改 8 表）
  - 新增 `docs/03_多角色协作框架.md`（10 角色、RACI 矩阵）
  - 新增 `docs/04_工作流与进度机制.md`（STATUS/CHANGELOG/ADR/任务卡四件套）
  - 新增 `docs/05_质检与监控体系.md`（五层质检 + 埋点 + A/B + 反馈闭环）
  - 新增 `docs/06_TraceGuard集成方案.md`（确立为管线 QA 运行时底座）
  - 新增 `docs/STATUS.md`
  - 新增 `docs/CHANGELOG.md`（本文件）
- **影响**：整个项目后续所有开发工作必须遵循本批次文档
- **原因**：基于用户反馈扩展 v1 架构在身份建模、历法、隐喻引用、史源冲突、认识论分层、演进锁定等方面的覆盖度；建立多角色协作与进度跟踪机制以适配用户编程不熟练的现实
- **下一步**：等待用户审阅；审阅通过后进入 T-001（补 agent 定义）和 T-002（补初始 ADR）

### [decision] TraceGuard 定位确认
- **角色**：首席架构师
- **决定**：将 TraceGuard 确立为华典智谱**数据管线 QA 运行时底座**（一等公民组件），非可选工具
- **位置**：集成在 LLM Gateway 层、每个管线步骤后、agent handoff 边界、API response contract
- **待确认**：TraceGuard 作者（用户）回答 `docs/06 §十` 的 7 个接口细节问题后进入 ADR-004 签字

### [decision] 华典智谱架构原则（写入项目宪法）
- **决策**：21 条不可变原则写入 `docs/00_项目宪法.md`
- **核心**：
  - C-1 一次结构化 N 次衍生
  - C-2 所有实体必须可溯源
  - C-3 多源共存优于单源定论（Event-Account 拆分）
  - C-7 无黑盒 LLM 调用
  - C-8 质检嵌入每一层
  - C-15 角色解耦

### [decision] 数据模型 v2 核心变化
- **拆分**：`events` → `events + event_accounts`（支持多叙述并存）
- **新增**：`person_names` 承载多号 / `identity_hypotheses` 表达身份假说
- **新增**：`mentions` 表解决隐式/典故/化用/代称引用
- **新增**：`entity_embeddings` 多槽位表支持多模型共存
- **字段**：所有 user-facing 文本字段改为 JSONB 多语言
- **地理**：`places.coordinates POINT` → `geometry GEOMETRY`（支持点/线/面）
- **时间**：单值年份 → 区间 + precision + 原始字符串保留

### [docs] 项目目录创建
- **变更**：创建 `docs/decisions/` 和 `docs/tasks/` 占位目录
- **下一步**：T-002 批量补齐首批 ADR；T-000 签收后批量创建任务卡

---

## （向上追加新条目）
