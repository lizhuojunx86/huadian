# CLAUDE.md — 华典智谱 (HuaDian) 项目入口

> 这是 Claude Code / Cowork 进入本项目时**首读**的文件。
> 任何 agent 在动手之前，必须先走本文件规定的"开工三步"。

---

## 0. 开工三步（强制）

任何 Claude Code 会话开始时，在你做任何实质工作之前：

1. **读 `docs/STATUS.md`** — 了解项目当前阶段、进行中的任务、阻塞项
2. **读 `docs/CHANGELOG.md` 最近 5 条** — 了解最近的变更上下文
3. **根据你当前要承担的角色，读 `.claude/agents/{role}.md`** — 明确你的职责边界

未完成上述三步前，不要修改任何文件、不要运行任何命令。

---

## 1. 项目概述

华典智谱是"中国古籍 AI 知识平台"，将古籍文本结构化为可探索、可交互、可查询的知识系统。

- **定位**：一次结构化，N 次衍生。底层 8 类实体知识图谱，上层多产品共享
- **形态**：MVP 为 Web 应用，未来可延展为移动 APP / API 开放平台 / 商业版
- **代号**：HuaDian（华典）
- **仓库**：GitHub private（未来可能开源 / 商业化）

## 2. 文档入口

- `华典智谱_架构设计文档_v1.0.md` — 完整架构（v1）
- `docs/00_项目宪法.md` — **不可变原则**（锚）
- `docs/01_风险与决策清单_v2.md` — 早期决策清单（含身份建模、历法、隐喻、史源冲突等）
- `docs/02_数据模型修订建议_v2.md` — 基于风险的 schema 修订
- `docs/03_多角色协作框架.md` — 10 个角色的边界与交接
- `docs/04_工作流与进度机制.md` — 如何跨会话接续工作
- `docs/05_质检与监控体系.md` — 全链路质检 + 埋点 + 反馈闭环
- `docs/06_TraceGuard集成方案.md` — 管线 QA 运行时底座
- `docs/decisions/` — 架构决策记录（ADR）
- `docs/tasks/` — 任务卡

## 3. 技术栈（摘要，详见架构文档）

- **前端**：Next.js 14+ / TypeScript / Tailwind / shadcn/ui / MapLibre GL
- **API**：Node.js + TypeScript / GraphQL (Yoga) / Drizzle ORM
- **数据管线**：Python 3.12+ / Prefect / Anthropic SDK / TraceGuard
- **数据库**：PostgreSQL 16（pgvector / PostGIS / pg_trgm）
- **缓存**：Redis 7
- **部署**：Docker Compose → K8s（需要时）
- **Monorepo**：pnpm workspace + Turborepo（TS）；uv 管 Python
- **可观测性**：OpenTelemetry + PostHog + Sentry + TraceGuard

## 4. 多角色协作（关键）

项目以"中型开发团队"的方式运作。**角色之间严格解耦，不得越位。**

| 角色 | 文件 | 主要职责 | 禁区 |
|------|------|---------|------|
| 首席架构师 | `.claude/agents/chief-architect.md` | 架构决策、ADR、风险识别、仲裁 | 不写业务代码 |
| 产品经理 | `.claude/agents/product-manager.md` | PRD、功能取舍、商业化决策 | 不改 schema / 不改视觉 |
| 古籍专家 | `.claude/agents/historian.md` | 数据正确性、实体歧义仲裁、术语库 | 不写代码 |
| UI/UX 设计师 | `.claude/agents/ui-ux-designer.md` | 视觉、交互原型、组件规范 | 不决定数据结构 |
| 后端工程师 | `.claude/agents/backend-engineer.md` | API / Drizzle schema / 服务层 | 不决定产品取舍 |
| 管线工程师 | `.claude/agents/pipeline-engineer.md` | 数据摄入 / LLM 抽取 / TraceGuard | 不决定实体定义 |
| 前端工程师 | `.claude/agents/frontend-engineer.md` | React 组件实现 / GraphQL 调用 | 不决定视觉 |
| QA 工程师 | `.claude/agents/qa-engineer.md` | 测试、质检规则、黄金集 | 不决定架构 |
| DevOps | `.claude/agents/devops-engineer.md` | CI/CD、Docker、监控基建 | 不改业务代码 |
| 数据分析师 | `.claude/agents/data-analyst.md` | 埋点、A/B、反馈分析 | 不改数据模型 |

**跨角色协作规则**：
- 每个任务卡指定主导角色，其他角色只能"提议 / 评审"，不能直接改
- 冲突 → 升级到架构师仲裁 → 记入 ADR
- 交接物必须符合对方约定格式（见各角色文档）

## 5. 危险操作红线（来自用户个人规则）

以下操作**必须先说明影响范围，等用户明确同意后才执行**：

1. 删除文件或目录（含目录级移动）
2. 覆盖已有文件（说明改前改后差异）
3. 批量重命名（先展示旧→新映射表）
4. `git force push` / `rebase` / `reset --hard`
5. 修改系统级配置（~/.zshrc、crontab、/etc/ 下）
6. 数据库破坏性操作（DROP / TRUNCATE / DELETE / ALTER TABLE）
7. 停止 / 重启正在运行的服务或容器
8. 修改防火墙 / 网络配置

**永远不要**在未确认的情况下：
- 删除 `.git` 目录
- 把 API key / token 写入 git 追踪的文件
- 修改 `~/.ssh/`
- 执行 `rm -rf` 或类似递归强制删除

**确认格式**：
```
⚠️ 需要确认：[操作简述]
📁 影响范围：[具体路径/对象]
💥 后果：[不可逆后果]
🔄 回滚：[能否恢复，如何恢复]
是否继续？
```

## 6. 工作风格

- **直接执行，少说废话**：能做的事直接做（除非命中红线）
- **并行优先**：独立任务并行执行
- **先做后报**：完成后给简洁结果摘要
- **出错自修**：依赖缺失、路径问题等可自行解决的错误直接修复
- **中文交流**，代码注释和 commit 用英文
- **Commit message 格式**：Conventional Commits（`feat:` / `fix:` / `refactor:` / `docs:` / `chore:`），不自动 push、不自动 merge
- **每完成一个独立功能点建议 commit**

## 7. 常用命令（Phase 0 以后可用）

```bash
# 开发
pnpm install
pnpm dev
docker compose up -d              # 启动 postgres + redis
pnpm db:migrate
pnpm db:seed

# 管线（Python）
cd services/pipeline
uv sync
uv run python -m src.cli ingest --source ctext --book 史记
uv run python -m src.cli extract --book 史记 --steps ner,relations,events
uv run python -m src.cli validate --book 史记

# 质检
pnpm qc:all                        # 运行全部数据质检规则
uv run python -m src.qc.run        # 管线质检

# 测试
pnpm test
pnpm test:e2e
```

## 8. 会话接续模板

如果你是用户/我自己，在新的 Claude Code 会话里推进本项目，把下面这段贴进去即可：

```
继续推进华典智谱项目。请按以下顺序启动：
1. Read CLAUDE.md（本文件）
2. Read docs/STATUS.md
3. Read docs/CHANGELOG.md 最近 5 条
4. 告诉我你看到的当前阶段、最近一次完成的工作、建议的下一步
5. 等我确认推进的任务 ID 后，读对应的 docs/tasks/T-NNN-*.md 和 .claude/agents/{role}.md，再动手
```

---

> 本文件一旦违反项目宪法（docs/00_项目宪法.md）就必须修订。
> 任何对本文件的修改都应同步记入 CHANGELOG.md 并打上 `docs:` 提交。
