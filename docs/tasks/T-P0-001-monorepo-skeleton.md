# T-P0-001: Monorepo 骨架落地

- **状态**：ready（ADR-007 已 accepted；等用户开新会话启动执行）
- **主导角色**：DevOps
- **协作角色**：后端工程师（校准 `services/api` 骨架）、管线工程师（校准 `services/pipeline` 骨架）、架构师（评审 ADR-007）
- **所属 Phase**：Phase 0
- **依赖任务**：ADR-007 accepted
- **预估工时**：3 人日（DevOps 主）+ 0.5 人日（后端+管线+前端校对）——含架构师评审回合修订项
- **创建日期**：2026-04-15
- **开始日期**：待定
- **完成日期**：—
- **别名**：STATUS.md 中的 T-004

## 目标

为华典智谱仓库搭建**可 `pnpm install && docker compose up -d && pnpm dev` 一键跑通**的 Monorepo 骨架，严格遵循 ADR-007 的布局与工具链。

## 范围（IN SCOPE）

1. 根级工具链配置：`package.json` / `pnpm-workspace.yaml` / `turbo.json` / `tsconfig.base.json` / `pyproject.toml` / `Makefile`
2. 版本锁文件：`.nvmrc` / `.python-version` / `packageManager` 字段
3. 子包骨架（`apps/web` / `services/api` / `services/pipeline` / `packages/{shared-types,db-schema,design-tokens,ui-core,analytics-events,config-eslint,config-typescript,qc-schemas}`），每个子包含最小可 build 的 stub
4. 共享配置包：`config-eslint`（被根继承）、`config-typescript`（被各子包 extends）
5. Docker Compose：`docker/compose.dev.yml`，启 PG 16（含 pgvector/PostGIS/pg_trgm）+ Redis 7 + OTel Collector 占位
6. DB 初始化：`db/init/01-extensions.sql` 自动启扩展
7. 环境变量：`.env.example` 全 key + 占位值
8. 代码风格：ESLint / Prettier / ruff / `.editorconfig`
9. Pre-commit：gitleaks + lint-staged 配置
10. CI：`.github/workflows/ci.yml` 第一版（lint / typecheck / build / smoke）
11. CI：`.github/workflows/pre-commit.yml`（secret scan）
12. 脚本：`scripts/{dev.sh, db-reset.sh, smoke.sh, gen-types.sh}`
13. 运维手册：`docs/runbook/RB-001-local-dev.md`
14. README 扩写：onboarding 入口（5 分钟上手）
15. 更新 `CHANGELOG.md` / `STATUS.md` / `T-000-index.md`

## 范围（OUT OF SCOPE）

- **不写业务代码**（Drizzle schema、GraphQL resolver、React 组件）——后续任务卡处理
- **不接入**真实 LLM API / TraceGuard（由 T-P0-005 负责）
- **不建**生产级 CI（部署 pipeline、staging 环境等由 Phase 1 处理）
- **不启用**Turborepo 远程缓存（ADR-007 明确 Phase 1 再谈）
- **不引入** Git LFS（黄金集未到 10 MB 阈值）

## 子任务拆解

### 1. 根级工具链（0.5 天）
- [ ] `package.json`（workspace + scripts + packageManager）
- [ ] `pnpm-workspace.yaml`
- [ ] `turbo.json`（lint/typecheck/test/build/codegen 任务图）
- [ ] `tsconfig.base.json`（strict）
- [ ] `pyproject.toml`（uv workspace，声明 members）
- [ ] `.nvmrc`（20.x）/ `.python-version`（3.12.x）
- [ ] `Makefile`（up / down / reset-db / dev / lint / typecheck / test / smoke）

### 2. 共享配置包（0.5 天）
- [ ] `packages/config-typescript/{package.json, tsconfig.base.json, tsconfig.nextjs.json, tsconfig.node.json}`
- [ ] `packages/config-eslint/{package.json, index.js, nextjs.js, node.js, python-ignore.js}`
- [ ] 根 `.eslintrc.cjs` extend config-eslint
- [ ] 根 `.prettierrc` / `.editorconfig` / `ruff.toml`
- [ ] **R-2**：根 `tsconfig.json` 仅为 IDE 索引，不被任何子包 extends；子包全部 extends `packages/config-typescript/*`；写入 `packages/config-typescript/README.md` 说明
- [ ] **R-6**：`services/pipeline/pyproject.toml` 依赖增加 `basedpyright`（dev-only）；`services/pipeline/pyrightconfig.json` 最小配置；去除原 mypy 占位

### 3. 子包骨架（0.5 天）
- [ ] `apps/web/`（Next.js 14 最小 `app/page.tsx` + `package.json` + `next.config.mjs`）
- [ ] `services/api/`（Node + TS + GraphQL Yoga 最小 `src/index.ts` 返回 `{ hello: "world" }`）
- [ ] `services/pipeline/`（`pyproject.toml` + `src/huadian_pipeline/__init__.py` + `src/huadian_pipeline/cli.py` 最小）
- [ ] `packages/shared-types/`（zod 最小示例 + JSON Schema 导出 stub）
- [ ] `packages/db-schema/`（Drizzle 最小 `schema.ts`，**不含** `drizzle.config.ts`；**R-3**：`drizzle.config.ts` 与 drizzle-kit 执行器归 `services/api` 所有；此包仅为纯定义）
- [ ] **R-3**：`services/api/drizzle.config.ts` + `services/api/package.json` 里的 `db:generate / db:migrate / db:push / db:studio / db:reset` scripts，实际读 `services/api/.env` 中的 DATABASE_URL
- [ ] `packages/design-tokens/`（色板 JSON 占位）
- [ ] `packages/ui-core/`（Button 占位组件）
- [ ] `packages/analytics-events/`（事件字典 stub）
- [ ] `packages/qc-schemas/`（TraceGuard 规则输入/输出 schema stub）
- [ ] **R-1**：创建 `data/golden/.gitkeep` + `data/dictionaries/.gitkeep` + `data/README.md`（说明 owner = 历史专家、单文件 > 10 MB 触发 Git LFS 评估、当前不启 LFS）

### 4. 容器与 DB（0.5 天）
- [ ] **R-5**：所有镜像指定**具名小版本**，不用 `:latest` 或浮动标签
- [ ] `docker/compose.dev.yml` 服务清单：
  - `postgres`：基础镜像选型决定（见下），固定版本
  - `redis`：`redis:7.2-alpine`
  - `otel-collector`：`otel/opentelemetry-collector-contrib:0.103.0`
  - `clickhouse`（SigNoz 依赖）：`clickhouse/clickhouse-server:24.1.2-alpine`
  - `signoz-query-service` + `signoz-otel-collector`：版本跟 SigNoz 官方 helm/compose 对齐
- [ ] **PG 镜像选型决策**（§4.1 之前写入 runbook）：
  - 首选：`pgvector/pgvector:pg16`（含 pgvector），再用 `docker/postgres/Dockerfile` `FROM pgvector/pgvector:pg16` 手动 `apt install postgis` 打自定义镜像
  - 备选：`postgis/postgis:16-3.4` 作基，源码编译 pgvector
  - **验收**：`\dx` 同时列出 `vector / postgis / pg_trgm`
- [ ] `docker/postgres/Dockerfile`（自定义镜像，落最终选型）
- [ ] `db/init/01-extensions.sql`：`CREATE EXTENSION IF NOT EXISTS vector; postgis; postgis_topology; pg_trgm;`
- [ ] `db/init/02-search-path.sql`（如需）
- [ ] OTel Collector 最小配置 `docker/otel/collector-config.yaml`（receivers: otlp；exporters: signoz）
- [ ] **Q-1**：SigNoz 子栈通过 docker-compose profile 切换：默认启用；`docker compose --profile no-signoz up -d` 可跳过以节省资源
- [ ] **R-3 对齐**：`scripts/db-reset.sh` 委托 `pnpm --filter @huadian/api db:reset`，不直接执行 drizzle-kit

### 5. 环境与秘钥（0.2 天）
- [ ] `.env.example`（数据库 URL、Redis URL、Anthropic Key 占位、OTel endpoint、PostHog key 占位等）
- [ ] `.pre-commit-config.yaml`（gitleaks + lint-staged）
- [ ] 安装 pre-commit hook 的说明写入 `docs/runbook/RB-001`

### 6. CI（0.5 天）
- [ ] `.github/workflows/ci.yml`：pnpm install → lint → **typecheck (tsc + basedpyright)** → test → build → docker smoke → secret-scan
- [ ] **R-4**：同一 workflow 里追加 `graphql:breaking` job（`graphql-inspector diff` vs base），Phase 0 **告警不阻断**（`continue-on-error: true`）；ADR-008 通过后切门禁
- [ ] `.github/workflows/pre-commit.yml`（gitleaks + lint-staged check）
- [ ] **R-7**：`.github/CODEOWNERS` 按 ADR-007 §六定义的路径映射落盘，当前全指 `@x86`
- [ ] `.github/PULL_REQUEST_TEMPLATE.md`（任务卡 ID / ADR 引用 / 测试证据 / checklist：是否改 schema / 是否改 prompt / 是否加依赖）
- [ ] `.github/ISSUE_TEMPLATE/`（bug / feature / feedback）
- [ ] `.github/dependabot.yml`（npm / pip / docker / github-actions 四个生态；Phase 1 评估切 Renovate）

### 7. 脚本 & 文档（0.4 天）
- [ ] `scripts/dev.sh`（环境检测 + 启动）
- [ ] `scripts/db-reset.sh`（清卷 + 委托 `pnpm --filter @huadian/api db:reset`，**不**直接调 drizzle-kit；R-3）
- [ ] `scripts/smoke.sh`（docker 起来后检测 PG/Redis/扩展 + SigNoz query-service 健康）
- [ ] `scripts/gen-types.sh`（TS zod → JSON Schema → Pydantic）
- [ ] `docs/runbook/RB-001-local-dev.md`（一页纸 onboarding；涵盖 pre-commit 安装、环境变量、启停、reset 流程）
- [ ] **R-8**：`README.md` 扩写（从 1 行 → 本地开发流程 + Phase 0 状态指示 + **"Claude Code / Cowork 会话接续"一节直接 link 到 `CLAUDE.md §8` 与 `.claude/agents/`**，不复述内容）

### 8. 收尾（0.2 天）
- [ ] 跑通 `docker compose up -d && pnpm -r build && uv sync && pnpm test`，全绿
- [ ] 更新 `docs/STATUS.md`（T-P0-001 done；进入 T-P0-002）
- [ ] 更新 `docs/CHANGELOG.md`
- [ ] 更新 `docs/tasks/T-000-index.md` 状态
- [ ] git commit + 提 PR（当前单人：`feat: monorepo skeleton (T-P0-001)`）

## 验收标准（DoD）

1. `pnpm install` 在 M1/M2 Mac + Ubuntu 22 GitHub Actions 上都能无错完成
2. `docker compose up -d` 后：`psql` 连得上；`\dx` 能看到 `vector / postgis / pg_trgm`；Redis ping 返回 PONG
3. `docker compose --profile no-signoz up -d` 也能起（验证 profile 切换生效）
4. ~~SigNoz UI（`http://localhost:3301`）可访问，自监控 trace 有数据~~ → **deferred to T-P0-005a**（镜像版本 0.88.25 不存在；正确做法是配合真实 trace 流量联调验证版本）
5. `pnpm -r build` 全部包成功构建（无业务代码，只是 stub）
6. `uv sync --all-packages` 成功；`uv run --project services/pipeline python -c "import huadian_pipeline; print('ok')"`
7. `pnpm lint && pnpm typecheck`（tsc + basedpyright）全绿
8. `pnpm codegen` 跑通：TS zod 示例类型被导出到 JSON Schema，Python 侧 Pydantic 模型被生成；`git diff` 为空
9. `pnpm --filter @huadian/api db:migrate` 能跑通（空迁移也必须成功）；`scripts/db-reset.sh` 能清空并重建
10. CI 在 PR 上跑一轮：第 1~7 步全绿；`graphql:breaking` 作为 warning 可见（Phase 0 不阻断）
11. `docs/runbook/RB-001` 能让一个"未来的我"（或新 contributor）按步骤 15 分钟内跑起本地环境
12. 所有新增依赖版本入锁文件（`pnpm-lock.yaml` / `uv.lock`）并提交
13. pre-commit 跑 gitleaks 时不报任何真密钥
14. CODEOWNERS 存在且按 ADR-007 §六路径表配置
15. 所有 docker 镜像 tag 均为具名小版本（grep `:latest` 无命中）

## 风险与缓解

| 风险 | 缓解 |
|------|------|
| Docker 镜像 postgres+PostGIS+pgvector 不稳定 | 优先用 `postgis/postgis:16-3.4` 作基础镜像，init SQL 自行启 pgvector（需编译或用社区镜像 `pgvector/pgvector:pg16-postgis`） |
| Turborepo 配置错误导致错误缓存 | 先不配远程缓存；`inputs` 字段保守（宁错杀不漏）；CI 首次关缓存跑一次对照 |
| pnpm/uv 版本漂移 | `packageManager` 字段 + `.python-version` + CI 矩阵校验 |
| 首个子包 stub 可能被后续任务推翻 | stub 只保证可 build，不承诺 API；后续任务卡里允许整体替换 |

## 协作交接

- **→ 架构师**：评审 ADR-007 并签字
- **→ 后端工程师**：`services/api` 与 `packages/db-schema` 的 stub 需其确认"后续扩展不会冲突"
- **→ 管线工程师**：`services/pipeline` 的 uv 布局、`packages/qc-schemas` 的 stub 需其确认
- **→ 前端工程师**：`apps/web` 的 Next.js 最小样板需其确认
- **→ QA**：CI 流水最小步骤确认（后续 QA 会加黄金集回归）
- **→ 分析师**：`packages/analytics-events` 的 stub（后续填真事件）

## 相关链接

- ADR：ADR-007（Monorepo 布局与包管理）/ ADR-001（PG 扩展）/ ADR-004（TraceGuard Adapter 位于 `services/pipeline/src/qc/`）
- 后续任务：T-P0-002（DB Schema 落地）/ T-P0-005（LLM Gateway + TraceGuard 集成）
- 宪法条款：C-11 / C-19

## 修订历史

- 2026-04-15 v1：DevOps 创建
- 2026-04-15 v1.1：架构师评审回合 1；按 R-1~R-8 / Q-1~Q-2 修订（基础镜像决策、SigNoz 子栈、CODEOWNERS 路径、basedpyright、graphql:breaking 告警、DB 编排归属到 services/api、data/ owner、README 链接 CLAUDE.md §8）
- 2026-04-15 v1.2：DoD #4 deferred to T-P0-005a — SigNoz 镜像版本 0.88.25 不存在于 Docker Hub；架构师决策推迟到有真实 trace 流量时再对齐版本
- 2026-04-15 v1.3：端口冲突修正 — PG host 5432→5433，Redis 6379→6380，支持 env 覆盖；避让宿主机已有服务
