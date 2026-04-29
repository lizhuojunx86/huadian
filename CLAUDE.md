# CLAUDE.md — 华典智谱 (HuaDian) 项目入口

> 这是 Claude Code / Cowork 进入本项目时**首读**的文件。
> 任何 agent 在动手之前，必须先走本文件规定的"开工三步"。

---

## 0. 开工三步（强制）

任何 Claude Code 会话开始时，在你做任何实质工作之前：

1. **读 `docs/STATUS.md`** — 了解项目当前阶段、进行中的任务、阻塞项
2. **读 `docs/CHANGELOG.md` 最近 5 条** — 了解最近的变更上下文
3. **如果你是新协作者第一次进入本项目**：还需读 `README.md` + `docs/strategy/D-route-positioning.md` + `docs/decisions/ADR-028-strategic-pivot-to-methodology.md`，了解项目 D-route 战略方向
4. **根据你当前要承担的角色，读 `.claude/agents/{role}.md`** — 明确你的职责边界（如不确定自己是哪个角色，先问用户）

未完成上述步骤前，不要修改任何文件、不要运行任何命令。

---

## 1. 项目概述

华典智谱是 **Agentic Knowledge Engineering 工程框架 + 史记参考实现**（D-route，2026-04-29 经 ADR-028 战略转型）。

- **定位**：一个用 AI agent 团队严谨、可审计、可复用地构建可信知识库的开源工程框架；以《史记》知识库作为参考实现案例
- **形态**：4 层路线（详见 `docs/strategy/D-route-positioning.md`）
  - **Layer 1 (6-12mo)** 框架代码抽象 — 单仓内子目录，从 Sprint A-K 已建工程资产抽出领域无关核心
  - **Layer 2 (12-18mo)** 方法论文档 — 月度决策日记 + 季度方法论文章
  - **Layer 3 (持续)** 案例库 — 华典智谱史记主案例 + 鼓励 1-2 个跨领域第三方案例
  - **Layer 4 (机会主义)** 社区 / 培训 / 商业 — 视前 3 layer 反响打开
- **代号**：HuaDian（华典）
- **仓库**：**GitHub public**（https://github.com/lizhuojunx86/huadian）
- **许可证**：双许可证结构
  - 代码 → Apache License 2.0（`LICENSE`）
  - 数据 / 文档 / 方法论 → CC BY 4.0（`LICENSE-DATA`）
  - 第三方 attribution → `NOTICE`
  - 决策依据：`docs/decisions/ADR-029-licensing-policy.md`
- **战略锚点**：`docs/decisions/ADR-028-strategic-pivot-to-methodology.md` + `docs/strategy/D-route-positioning.md`
- **公开入口**：`README.md` / 贡献者指南：`CONTRIBUTING.md`

### 1.1 D-route Mental Model（重要）

本项目**不是**："另一个 AI 古籍知识库"。
本项目**是**："如何用 AI agent 团队严谨地构建知识库"的工程框架，史记是**用来证明这个框架真的 work** 的案例。

这意味着**所有工作的优先级判断**都要回到一个问题：

> 这件事**对框架抽象**有什么价值？还是只对"做完史记数据"有价值？

如果只对后者有价值（即纯 case 完整度 / 纯产品功能），通常应当 **降级或 sunset**。详见 `docs/strategy/D-route-positioning.md` §7 "Negative Space"。

---

## 2. 文档入口（按"为什么读"分层）

### 2.1 入门 / 现状（每个新 session 都该看）
- `README.md` — public-facing 项目介绍 + quick start
- `docs/STATUS.md` — 实时状态板（永远最新）
- `docs/CHANGELOG.md` — 变更日志（按时间倒序）

### 2.2 战略 / 方向（决策前必读）
- `docs/strategy/D-route-positioning.md` — 项目定位 / 差异化 / 4-Layer 路线图 / Negative Space
- `docs/decisions/ADR-028-strategic-pivot-to-methodology.md` — 战略转型决策记录
- `docs/decisions/ADR-029-licensing-policy.md` — 许可证策略
- `docs/00_项目宪法.md` — **不可变原则**（C-1~C-24，违反必须修宪）

### 2.3 协作 / 流程（动手前必读）
- `docs/03_多角色协作框架.md` — 10 个角色的边界与交接
- `docs/04_工作流与进度机制.md` — Sprint / Stage / Gate 工作流
- `docs/05_质检与监控体系.md` — V1-V11 invariants + 质检体系
- `CONTRIBUTING.md` — 外部贡献者入门（inbound = outbound 等）

### 2.4 架构 / 实现（深入时读）
- `华典智谱_架构设计文档_v2.0.md` — 双轴架构（框架层 + 案例实现层）
- `archive/华典智谱_架构设计文档_v1.0.md` — v1.0 归档（D-route 转型前的"古籍知识平台"架构，仅供历史参考）
- `docs/decisions/` — 全部 ADR（ADR-001~ADR-029，按编号读）
- `docs/06_TraceGuard集成方案.md` — 管线 QA 运行时底座

### 2.5 方法论草案（Layer 2 持续起草）
- `docs/methodology/00-framework-overview.md` — 框架是什么 / 为什么 / 不是什么
- `docs/methodology/01-role-design-pattern.md` — 角色设计模式
- `docs/methodology/02-sprint-governance-pattern.md` — Sprint 治理模式
- `docs/methodology/03-identity-resolver-pattern.md` — R1-R6 + guard chain 抽象
- `docs/methodology/04-invariant-pattern.md` — V1-V11 抽象
- `docs/methodology/05-audit-trail-pattern.md` — Audit + triage 模式
- `docs/methodology/06-adr-pattern-for-ke.md` — ADR 在 KE 项目的适配
- 这些文件状态：Stage C 待起草

### 2.6 历史档案（视情况查阅）
- `docs/01_风险与决策清单_v2.md` — 早期决策清单
- `docs/02_数据模型修订建议_v2.md` — 早期 schema 修订建议
- `docs/sprint-logs/sprint-A` ~ `sprint-K/` — Sprint 完整执行记录
- `docs/retros/` — 各 sprint 复盘
- `docs/tasks/` — 任务卡（T-NNN-*.md）

---

## 3. 技术栈（摘要）

| Layer | Stack |
|-------|-------|
| 前端 | Next.js 14+ / TypeScript / Tailwind / shadcn/ui / MapLibre GL |
| API | Node.js + TypeScript / GraphQL (Yoga) / Drizzle ORM |
| 数据管线 | Python 3.12+ / Prefect / Anthropic SDK / TraceGuard |
| 数据库 | PostgreSQL 16（pgvector / PostGIS / pg_trgm）|
| 缓存 | Redis 7 |
| 部署 | Docker Compose → K8s（需要时）|
| Monorepo | pnpm workspace + Turborepo（TS）；uv 管 Python |
| 可观测性 | OpenTelemetry + PostHog + Sentry + TraceGuard |

**D-route 注**：技术栈本身不变。但任何新增依赖 / 新增子系统都要先问"对框架抽象的价值如何"——如果答案是"只对史记案例有用"，应慎重引入（避免框架与领域耦合）。

详见 `华典智谱_架构设计文档_v2.0.md`。

---

## 4. 多角色协作（关键）

项目以"中型开发团队"的方式运作。**角色之间严格解耦，不得越位**（项目宪法 C-15）。

### 4.1 角色清单 + 当前活跃度（D-route 调整）

ADR-028 §2.3 Q4 ACK 后，各角色活跃度按 D-route 重定：

| 角色 | 文件 | 主要职责 | 禁区 | **D-route 活跃度** |
|------|------|---------|------|-------------------|
| 首席架构师 | `.claude/agents/chief-architect.md` | 架构决策、ADR、风险识别、仲裁、**战略 + 写作** | 不写业务代码 | 🟢 **高（含战略+写作）** |
| 管线工程师 | `.claude/agents/pipeline-engineer.md` | 数据摄入 / LLM 抽取 / TraceGuard | 不决定实体定义 | 🟢 **主线持续**（延伸级 ingest + 框架抽象案例验证）|
| 后端工程师 | `.claude/agents/backend-engineer.md` | API / Drizzle schema / 服务层 | 不决定产品取舍 | 🟡 **维护模式**（仅响应方法论 / 案例需要）|
| 前端工程师 | `.claude/agents/frontend-engineer.md` | React 组件实现 / GraphQL 调用 | 不决定视觉 | 🟡 **维护模式**（同上）|
| 古籍专家 | `.claude/agents/historian.md` | 数据正确性、实体歧义仲裁、术语库 | 不写代码 | ⚪ **暂停**（仅框架需要 triage 案例验证时启用）|
| 产品经理 | `.claude/agents/product-manager.md` | PRD、功能取舍、商业化决策 | 不改 schema / 不改视觉 | ⚪ **暂停**（D-route 不主推 C 端产品）|
| UI/UX 设计师 | `.claude/agents/ui-ux-designer.md` | 视觉、交互原型、组件规范 | 不决定数据结构 | ⚪ **暂停** |
| QA 工程师 | `.claude/agents/qa-engineer.md` | 测试、质检规则、黄金集 | 不决定架构 | 🟡 **维护模式** |
| DevOps | `.claude/agents/devops-engineer.md` | CI/CD、Docker、监控基建 | 不改业务代码 | 🟡 **维护模式** |
| 数据分析师 | `.claude/agents/data-analyst.md` | 埋点、A/B、反馈分析 | 不改数据模型 | ⚪ **暂停**（无 DAU 衡量）|

🟢 高 / 🟡 维护 / ⚪ 暂停。任何"暂停"角色被启用都需要架构师批准并在 sprint brief 中说明。

### 4.2 跨角色协作铁律

- 每个任务卡指定主导角色，其他角色只能"提议 / 评审"，不能直接改
- 冲突 → 升级到架构师仲裁 → 记入 ADR
- 交接物必须符合对方约定格式（见各角色文档）
- **D-route 新增**：每个 sprint 必须由架构师评估"对框架抽象的产出"，不只是"对案例完成度的产出"

---

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

---

## 6. 工作风格

### 6.1 通用工作风格（沿袭既有）

- **直接执行，少说废话**：能做的事直接做（除非命中红线）
- **并行优先**：独立任务并行执行
- **先做后报**：完成后给简洁结果摘要
- **出错自修**：依赖缺失、路径问题等可自行解决的错误直接修复
- **中文交流**，代码注释和 commit 用英文
- **Commit message 格式**：Conventional Commits（`feat:` / `fix:` / `refactor:` / `docs:` / `chore:`），不自动 push、不自动 merge
- **每完成一个独立功能点建议 commit**

### 6.2 D-route 工作纪律（新增）

- **案例服务于框架**：任何 sprint 设计都要回答"对框架抽象的价值"。纯 case-only 工作要么降级、要么变成框架抽象的"案例输入"
- **抽象优先于完成度**：3-4 篇本纪深度结构化（已完成）的价值 ≥ 50 篇浅度结构化的价值；前者验证框架，后者只是数据堆叠
- **写作节律软节律 (Q5 ACK)**：架构师每月 1 段决策日记 + 每季度 1 篇方法论文章。具体节律由架构师自主把握，但应有节律存在
- **承认能力短板**：用户写作偏弱，架构师（Claude）须主动 propose 文档框架 / 起草初稿 / 提示需要补充的角度，让用户的角色更接近"审稿 + 投放"而非"从零写"
- **不卷热门方向**：不做古人聊天 / 古地图 / Mobile / DAU 增长等 C 端方向（Negative Space，详见 D-route §7）

---

## 7. 常用命令（Phase 0+ 可用）

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

# Sprint 治理
ls docs/sprint-logs/sprint-{a..k}/                # 既有 sprint logs
cat docs/sprint-logs/sprint-l/stage-0-brief.md    # 当前 sprint brief（由 Stage D 起草）
```

---

## 8. 会话接续模板

如果你（用户/我自己）在新的 Claude Code 会话里推进本项目，把下面这段贴进去：

```
继续推进华典智谱项目。请按以下顺序启动：

1. Read CLAUDE.md（本文件）
2. Read README.md（如果是新协作者第一次进入）
3. Read docs/strategy/D-route-positioning.md（如果是新协作者）
4. Read docs/STATUS.md
5. Read docs/CHANGELOG.md 最近 5 条
6. 告诉我你看到的：
   - 项目当前 D-route Layer 位置（L1 / L2 / L3 / L4 各自进度）
   - 最近一次完成的工作
   - 建议的下一步
7. 等我确认推进的任务 ID 后，读对应的 docs/tasks/T-NNN-*.md 和 .claude/agents/{role}.md，再动手
```

### 8.1 多 session 并行规约

当架构师同时开多个 Claude Code session 让 PE / BE / FE / Hist 角色并行推进时，使用以下 tag 隔离：

- 【BE】Sprint X Stage Y — 给后端 session 的 prompt
- 【FE】Sprint X Stage Y — 给前端 session 的 prompt
- 【PE】Sprint X Stage Y — 给管线 session 的 prompt
- 【Hist】Sprint X Stage Y — 给古籍专家 session 的 prompt
- 【Architect】协调指令仅在主 session 内（即架构师本人）

跨 session 关键信号：
- 【BE】SDL ready → 【FE】codegen unblock
- 【BE】migration NNNN applied → 【PE】backfill apply unblock
- 【PE】Stage 2 apply done → 【Architect】Stage 3 historian review prompt
- 【Hist】review report done → 【Architect】Stage 4 apply 指令
- 【Architect】Stop Rule 裁决发回原 session

---

## 9. D-route 路线图速览

详见 `docs/strategy/D-route-positioning.md` §6。

| 时间锚 | 里程碑 |
|--------|--------|
| 2026-05 (1mo) | 文档体系全对齐（Stage A-D 完成）+ Sprint L 启动 |
| 2026-06 (2mo) | `docs/methodology/` 7 份草案完整版 |
| 2026-08 (4mo) | 华典智谱史记到 5-10 篇典型章节延伸级 + 产品化 demo 上线 |
| 2026-10 (6mo) | 第 1-2 篇方法论文章发布 |
| 2027-01 (9mo) | 框架代码抽象 v0.1 release |
| 2027-04 (12mo) | 第 2 个跨领域案例验证框架可移植性 |

---

> 本文件一旦违反项目宪法（`docs/00_项目宪法.md`）就必须修订。
> 任何对本文件的修改都应同步记入 `docs/CHANGELOG.md` 并打上 `docs:` 提交。
> D-route 战略锚点变化必须先改 `ADR-028` 或新开 ADR，再回过来改本文件。

**最后修订**：2026-04-29 / Stage B-1 of D-route doc realignment
