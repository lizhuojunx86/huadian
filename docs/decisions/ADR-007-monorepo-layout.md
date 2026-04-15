# ADR-007: Monorepo 布局与包管理（pnpm + uv + Turborepo）

- **状态**：accepted
- **日期**：2026-04-15
- **提议人**：DevOps 工程师
- **决策人**：首席架构师（已签字，第二轮评审通过）
- **影响范围**：整个仓库结构、所有子包的 package.json / pyproject.toml、CI/CD、开发本地工具链
- **Supersedes**：无
- **Superseded by**：无

## 背景

华典智谱同时包含 TypeScript（前端 Next.js + Node GraphQL API）和 Python（数据管线、LLM 抽取、TraceGuard Adapter）两套技术栈，且需要若干**跨栈共享的包**（共享类型、设计 token、埋点字典）。必须一次性定型：

1. **仓库布局**：单仓（monorepo）还是多仓
2. **TS 包管理器**：pnpm / npm / yarn
3. **Python 包管理器**：uv / poetry / pip
4. **TS 构建编排**：Turborepo / Nx / Rush
5. **跨语言共享机制**：TS 类型如何穿越到 Python
6. **依赖收敛与版本锁定**策略

此决策一旦定型，几乎不可回退——任何后续调整都会牵动全部子包。

## 选项

### 仓库结构
- **A1**：单 monorepo（所有代码在一个仓） ← 提议采用
- **A2**：三仓（frontend / backend / pipeline），通过 npm publish 共享
- **A3**：两仓（TS 一仓 + Python 一仓）

### 包管理器
- **B-TS**：pnpm（workspace 原生支持、硬链接省盘、确定性安装） ← 采用（`CLAUDE.md §3` 既定）
- **B-Py**：uv（Rust 写的 pip + virtualenv + pyproject + workspace，极快） ← 采用（`CLAUDE.md §3` 既定）

### 构建编排（仅 TS 侧需要）
- **C1**：Turborepo（本地/远程缓存、并行、任务图简洁） ← 采用（`CLAUDE.md §3` 既定）
- **C2**：Nx（功能强但学习曲线陡，单人开发过重）
- **C3**：pnpm 原生 `-r` + script（最简，无缓存，中规模后力不从心）

### 跨语言类型共享
- **D1**：TS 为源头 → 用 `json-schema-to-typescript` / `quicktype` 生成 Python Pydantic 模型
- **D2**：Python 为源头 → Pydantic → JSON Schema → TS 类型
- **D3**：双源并行，手工同步
- **提议**：**D1**。理由：GraphQL SDL 已是 TS 侧事实源头，`packages/shared-types` 的 zod/JSON Schema 再派生到 Python 自然

## 决策

### 一、仓库结构（采用 A1）

```
huadian/
├── .claude/                          # agent 角色定义 + Claude Code 本地配置（部分不入库）
│   └── agents/*.md
├── .github/
│   ├── workflows/                    # CI/CD
│   ├── CODEOWNERS                    # 按目录派单 reviewer（未来对接 GitHub 团队）
│   ├── ISSUE_TEMPLATE/
│   └── PULL_REQUEST_TEMPLATE.md
├── apps/
│   └── web/                          # Next.js 14+ App Router
├── services/
│   ├── api/                          # Node GraphQL API (Yoga + Drizzle)
│   └── pipeline/                     # Python 数据管线（uv 子项目）
├── packages/
│   ├── shared-types/                 # TS 类型源头（zod + JSON Schema 导出）
│   ├── db-schema/                    # Drizzle schema 与迁移（TS）
│   ├── design-tokens/                # 设计 token JSON（跨前端/设计师）
│   ├── ui-core/                      # 跨 app 的核心 UI 组件（shadcn 封装）
│   ├── analytics-events/             # 埋点字典（TS，供前端 + 分析师）
│   ├── config-eslint/                # 共享 ESLint 配置
│   ├── config-typescript/            # 共享 tsconfig 基座
│   └── qc-schemas/                   # TraceGuard 规则输入/输出 schema（TS → Python 生成）
├── db/
│   └── init/                         # docker 首次启动自动跑的 SQL（扩展启用等）
├── docker/
│   ├── compose.dev.yml
│   ├── compose.prod.yml
│   └── postgres/Dockerfile           # 若需自定义 PG 镜像（含 pgvector/PostGIS）
├── scripts/
│   ├── dev.sh
│   ├── db-reset.sh
│   ├── smoke.sh
│   └── gen-types.sh                  # zod → JSON Schema → Pydantic 流水
├── docs/                             # 已存在
├── data/                             # owner：历史专家（historian role），非 DevOps
│   ├── golden/                       # 黄金集 JSONL，入 git；单文件 > 10 MB 触发 LFS 评估（新 ADR）
│   └── dictionaries/                 # polities / reign_eras / disambiguation_seeds 等 YAML/JSONL，入 git
├── .env.example                      # 环境变量模板（无真值）
├── .editorconfig
├── .eslintrc.cjs                     # 根级 ESLint，extend packages/config-eslint
├── .prettierrc
├── .pre-commit-config.yaml           # gitleaks + lint-staged
├── .gitignore                        # 已存在
├── .nvmrc                            # 锁 Node 版本
├── .python-version                   # 锁 Python 版本（uv 读）
├── package.json                      # 根 workspace
├── pnpm-workspace.yaml
├── turbo.json
├── tsconfig.json                     # 仅 IDE 索引用，不被任何子包 extends
├── tsconfig.base.json                # 历史保留，不推荐新建 extends；新子包 extends packages/config-typescript/*
├── pyproject.toml                    # 根 uv workspace
├── uv.lock
├── Makefile                          # 可选入口别名
├── CLAUDE.md                         # 已存在
└── README.md                         # 已存在（Phase 0 期间扩写）
```

**包边界规则**：
- `apps/*` 不允许被其他包依赖（叶子）
- `services/*` 不允许被 `apps/*` 直接 import（通过 GraphQL 网络调用）
- `packages/*` 可被 `apps/*` / `services/*` 依赖
- `packages/*` 之间**允许**单向依赖，禁止循环
- Python 包仅位于 `services/pipeline` 与（未来）`services/*`；**Python 不反向依赖 TS**

**DB 编排归属（R-3 明确）**：
- `packages/db-schema`：**纯定义层**。存放 Drizzle schema TS 源 + 自动生成的迁移 SQL（`packages/db-schema/migrations/*.sql`）。不拥有 DATABASE_URL、不直接执行任何 DB 命令、不读 `.env`
- `services/api`：**执行层**。持有 `drizzle-kit` CLI 入口、读取 DATABASE_URL、实际执行 `db:generate / db:migrate / db:push / db:studio`
- 根脚本 `scripts/db-reset.sh`：仅作薄封装，委托给 `pnpm --filter @huadian/api db:reset`
- `pnpm -w run db:migrate` 的含义 = 在 `services/api` workspace 里跑 `drizzle-kit migrate`
- 管线（Python）读 DB 只走**通用 PG 驱动**（asyncpg/psycopg），不依赖 Drizzle；schema 真实性以 `packages/db-schema` 为源

### 二、包管理器（B-TS: pnpm / B-Py: uv）

- **Node 版本**：`.nvmrc` 锁定 Node 20 LTS（长期支持至 2026 年 4 月后延长至 2026 末）；Phase 1 评估切 Node 22 LTS
- **pnpm 版本**：`packageManager` 字段锁定（package.json `"packageManager": "pnpm@9.x"`）
- **Python 版本**：`.python-version` 锁定 3.12.x
- **uv 版本**：CI 与本地 `uv self update` 对齐；通过 `scripts/dev.sh` 启动时检测
- **锁文件入库**：`pnpm-lock.yaml` 与 `uv.lock` **必须**提交
- **依赖策略**：
  - 同一依赖跨包必须同版本（pnpm 的 `overrides` 强制）
  - Phase 0 禁加 Phase 0 范围外的依赖；新增依赖必须在 PR 描述里说明理由
  - 严禁 `latest` / 没 semver 的 git URL 依赖
- **安装命令**：
  - 根 `pnpm install` 一键装 TS 端所有包
  - 根 `uv sync --all-packages` 装 Python workspace 所有成员

### 三、Turborepo 编排（C1）

`turbo.json` 定义三级任务：
- `lint` / `typecheck` / `test` / `build`：标准前端/后端任务
- `codegen`：GraphQL schema → 类型；zod → JSON Schema；JSON Schema → Pydantic
- `db:migrate` / `db:seed`：后端独立，不走 turbo 缓存（有副作用）
- **远程缓存**：Phase 0 不启用；Phase 1 评估自托管 turbo-remote-cache 或 Vercel

任务依赖（关键几条）：
```json
"build": { "dependsOn": ["^build", "codegen"] }
"test": { "dependsOn": ["build"] }
"codegen": { "outputs": ["packages/shared-types/dist/**", "services/pipeline/src/shared_types/**"] }
```

### 四、跨语言类型共享（D1）

流水：
1. **源头**：`packages/shared-types/src/**/*.ts`（用 zod 定义）
2. **中间态**：`pnpm --filter shared-types codegen` 产出 `packages/shared-types/schema/*.json`（JSON Schema）
3. **Python 侧**：`scripts/gen-types.sh` 调 `datamodel-code-generator` 把 JSON Schema → Pydantic v2 类，写到 `services/pipeline/src/shared_types/`
4. Python 侧**只读不写**生成文件；若需要补字段，必须回到 TS 源头

这条流水在 CI 中作为 `codegen` 任务，**TS 与 Python 不同步时 CI 失败**。

**类型源头边界（Q-2 明确）**：

| 类型范畴 | 源头 | 流向 |
|---------|------|------|
| **业务类型**（GraphQL payload、API contract、QC 规则 I/O、埋点事件、LLM 抽取 schema） | `packages/shared-types/*.ts`（zod） | → JSON Schema → Pydantic（只读）；→ GraphQL SDL codegen 到 `services/api/__generated__` |
| **持久层类型**（DB 表、列类型、查询结果行） | `packages/db-schema/*.ts`（Drizzle schema） | 仅在 `services/api/src/repositories/*.ts` 内部使用；**不透出到 GraphQL 层**；不对外暴露给 Python |
| **管线内部类型**（抽取中间产物、handoff 消息） | `packages/qc-schemas/*.ts`（zod） | → Pydantic；供 `services/pipeline` 使用 |

**核心规则**：
- Drizzle schema **不是**业务类型源头；业务层需要的字段由 `services/api/src/services/*.ts` 手写 DTO adapter 从 Drizzle 行类型映射成 zod 业务类型
- 若 GraphQL payload 与 DB 列刚好形状一致，仍**不允许** resolver 直接透传 Drizzle 行，必须经 DTO（防未来 schema 变更意外泄漏字段）
- Pydantic 侧永远只消费"业务类型"与"管线内部类型"，**不接触持久层类型**
- 这条规则在 ADR-008（GraphQL 演进）落地时会进一步细化

### 四 bis、本地可观测后端（Q-1 决定）

- **Phase 0 采用 SigNoz 社区版**（自托管，docker-compose 额外拉 1~2 个服务：`signoz-otel-collector` + `signoz-query-service` + `clickhouse`）
- 放弃在 Phase 0 混搭 Grafana + Tempo + Loki 的理由：SigNoz 把 trace / log / metric 合在一个 UI，单人开发心智负担低
- **OTel Collector** 配置指向 SigNoz Collector endpoint；应用侧只对接 OTel 标准，**不锁死 SigNoz**（Phase 1 要切 Grafana Cloud / Honeycomb 仅改 Collector 出口）
- ClickHouse 占用资源较高（~1GB RAM），因此 `docker/compose.dev.yml` 中 SigNoz 子栈默认启用但文档提示可按需 `docker compose --profile no-signoz up -d` 跳过
- Phase 1 评估：若单人开发期用量极低，可直接切 Grafana Cloud 免费层（14 天 trace 保留），关掉本地 ClickHouse 腾资源

### 五、环境与秘钥

- `.env.example` 仅含 key 与占位值，**所有值为假**
- `.env.local` / `.env.production` 入 `.gitignore`（已有）
- 开发期：`.env.local` 手工维护
- 未来（Phase 1+）：接入 Doppler 或 1Password secret sync（独立 ADR）
- `pre-commit` 钩子跑 gitleaks，阻止 API key 入库

### 六、CI 流水（`.github/workflows/ci.yml` 初版）

矩阵任务（每条 PR 触发）：
1. `lint`：ESLint + Prettier + **ruff**（Python）
2. `typecheck`：`tsc --noEmit` + **basedpyright**（Python；见 R-6，取代 mypy，对 uv workspace 更友好，ty 稳定后再评估）
3. `codegen:verify`：跑 codegen 再 `git diff` 为空
4. `build`：`pnpm -r build` + `uv build`
5. `test:unit`：vitest + pytest
6. `docker:smoke`：`docker compose up -d` + 健康检查（PG/Redis 起得来、扩展加载成功）
7. `secret-scan`：gitleaks 全仓扫
8. `graphql:breaking`：**Phase 0 告警不阻断**（`graphql-inspector diff` vs base branch），Phase 1 ADR-008 落地后切门禁
9. （后续）`db:migrate:dryrun`、`lighthouse:ci`

**镜像钉版策略（R-5）**：
- docker-compose 与 Dockerfile 中所有 `image:` 必须指定**具名小版本**（如 `postgis/postgis:16-3.4`、`redis:7.2-alpine`、`otel/opentelemetry-collector-contrib:0.103.0`）
- Phase 0 允许暂不写 `@sha256:...` 摘要；Phase 1 起在 `.github/workflows/ci.yml` 新增一步校验"镜像摘要已登记"
- 接入 **Renovate**（或 Dependabot）自动发升级 PR，由 DevOps 人工审核合入
- 已知要点：`pgvector/pgvector:pg16` 与 `postgis/postgis:16-3.4` 不可同时作为 base；Phase 0 选择自定义 Dockerfile `FROM postgis/postgis:16-3.4`，再通过 `apt + pgvector source build` 或切 `pgvector/pgvector:pg16-postgis` 社区合并镜像（T-P0-001 §4.1 决策）

**CODEOWNERS 映射（R-7）**：按 agent 角色预埋路径 → 当前全指向 `@x86`，未来替换为真人/团队时改单行。具体见 `.github/CODEOWNERS`（任务卡 §3.6 落地）：

```
# 全局兜底
*                                      @x86
# 架构师
/docs/decisions/                       @x86
/docs/00_项目宪法.md                   @x86
/.claude/agents/chief-architect.md     @x86
# 后端
/services/api/                         @x86
/packages/db-schema/                   @x86
/packages/shared-types/                @x86
# 管线
/services/pipeline/                    @x86
/packages/qc-schemas/                  @x86
# 前端
/apps/web/                             @x86
/packages/ui-core/                     @x86
/packages/design-tokens/               @x86
# 数据分析师
/packages/analytics-events/            @x86
# 历史专家
/data/                                 @x86
# DevOps
/docker/                               @x86
/.github/                              @x86
/scripts/                              @x86
/docs/runbook/                         @x86
```

主分支保护：第 1~7 步必过，第 8 步仅告警。禁止无 PR 直推。

### 七、开发本地命令契约

| 命令 | 效果 |
|------|------|
| `pnpm install && uv sync --all-packages` | 装依赖 |
| `pnpm dev` | 启动 API + Web（turbo 并行） |
| `make up` / `docker compose up -d` | 起 PG + Redis + OTel Collector |
| `make down` | 停容器 |
| `make reset-db` | 清库 + 重跑迁移 + seed |
| `pnpm lint` / `pnpm typecheck` / `pnpm test` | 质量门 |
| `pnpm codegen` | 再生成跨语言类型 |
| `uv run --project services/pipeline python -m src.cli ...` | 跑管线 |

## 影响

- 正面：
  - 单仓单一事实源，跨包改动原子化
  - pnpm + uv 的安装速度对单人开发体验极友好
  - Turborepo 远程缓存可在 Phase 1 无缝接入，不需要重构
  - TS→Python 类型单向流避免双源漂移
- 负面：
  - 初次搭建步骤多（~50 个文件）
  - Python / TS 混搭意味着贡献者需双栈知识
  - Turborepo 配置错了会误缓存，需要对 `inputs`/`outputs` 严格
- 迁移成本：0（起始决策）

## 回滚方案

- 若 Turborepo 出问题，退化为 `pnpm -r` 原生（turbo.json 删除即可，无侵入）
- 若 uv 出问题，退化为 poetry（pyproject 兼容度高）
- 若单 monorepo 成为瓶颈（Phase 4 开源后各模块独立发版），按 `apps` / `services` / `packages` 分仓，每个子树可独立迁出（git subtree split）

## 待决项（不阻塞本 ADR 通过）

- 远程 turbo 缓存是否自托管 vs 用 Vercel 托管（Phase 1 起独立 ADR）
- Python 类型检查器：Phase 0 采用 **basedpyright**（R-6）；Phase 1 评估 ty 稳定度后再决定是否切换
- Git LFS 是否用于黄金集 JSONL（Phase 0 不启 LFS，超 10 MB 再发新 ADR）
- 依赖自动升级：Renovate vs Dependabot（Phase 0 先配 Dependabot 最小版，Phase 1 评估 Renovate 更灵活的规则）
- 本地可观测后端切云端的触发条件（Phase 1 独立 ADR）

## 修订历史

- 2026-04-15 v1：DevOps 起草
- 2026-04-15 v1.1：架构师评审回合 1；DevOps 按 R-1~R-8 / Q-1~Q-2 修订
- 2026-04-15 v1.1-accepted：架构师复评通过，状态转 accepted；遗留 F-1/F-2/F-3 作 Phase 0 follow-up，不阻塞签字

## 相关链接

- 任务卡：**T-P0-001（Monorepo 骨架）**
- 相关 ADR：ADR-001（单 PG → docker-compose 起 PG 含扩展）/ ADR-004（TraceGuard Adapter 位于 `services/pipeline/src/qc/`）/ ADR-008 未来 GraphQL 演进 / ADR-010 未来 Prompt 版本化
- 宪法条款：C-11（变更走 ADR）/ C-19（锁文件入库）
