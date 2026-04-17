# 华典智谱 · CHANGELOG

> 按时间倒序追加。每次任务完成、决策变更、文档修订都应在此留痕。
> 格式参考 [Keep a Changelog](https://keepachangelog.com/) + Conventional Commits。

---

## 2026-04-17

### [feat] T-P0-003 完成 — GraphQL Schema 骨架（12 entity types, 5 Traceable, CI codegen:verify + graphql:breaking）
- **角色**：后端工程师（执行）+ 首席架构师（评审 Q-1~Q-11 + R-1/R-2/R-3）
- **任务**：T-P0-003
- **变更**：
  - `services/api/src/schema/` 新增 8 个 SDL 文件（scalars / enums / common / a-sources / b-persons / c-events / d-places / queries + _bootstrap）
  - 12 个 GraphQL entity types：Book / SourceEvidence / Person / PersonName / IdentityHypothesis / Event / EventAccount / AccountConflict / Place / PlaceName / Polity / ReignEra
  - 3 个 JSONB ref types：EventParticipantRef / EventPlaceRef / EventSequenceStep
  - `Traceable` interface（R-1：sourceEvidenceId / provenanceTier / updatedAt）；5 个实现（Book / SourceEvidence / Person / Event / Place）
  - 9 个 GraphQL enums 对齐 `packages/shared-types/src/enums.ts`（ProvenanceTier / RealityStatus / NameType / HypothesisRelationType / EventType / ConflictType / AdminLevel / CredibilityTier / BookGenre）
  - 自定义标量白名单 R-3：DateTime / UUID / JSON / PositiveInt（via graphql-scalars）
  - `MultiLangText` + `HistoricalDate` 暴露为 GraphQL Object Types（Q-4 裁定 B）
  - 5 个 Query 入口：`person(slug)` / `persons(limit,offset)` / `event(slug)` / `place(slug)` / `sourceEvidence(id)` — 全抛 NOT_IMPLEMENTED（Q-10）
  - `src/context.ts`：GraphQLContext（db: DrizzleClient / requestId: uuid v4 / tracer: null）
  - `src/errors.ts`：HuadianGraphQLError + 6 HuadianErrorCode（NOT_IMPLEMENTED / NOT_FOUND / VALIDATION_ERROR / INTERNAL_ERROR / UNAUTHORIZED / RATE_LIMITED）；extensions = { code, traceId }
  - `src/resolvers/{index,query,scalars,traceable}.ts`：resolver 骨架
  - `codegen.ts` + `scripts/merge-schema.ts`：graphql-codegen 全链路（SDL → 合并快照 → TS types）
  - `src/index.ts` 改造：SDL loadFilesSync + mergeTypeDefs + createSchema<GraphQLContext> + drizzle lazy DB
  - `.github/workflows/graphql-breaking.yml`：独立 CI workflow（drift check + graphql-inspector diff warn-only）
  - `.github/workflows/ci.yml`：Step 8 stub 迁移为指向独立 workflow 的注释
  - 依赖新增（架构师全批准）：graphql-scalars / @graphql-tools/load-files / @graphql-tools/merge / @graphql-codegen/{cli,typescript,typescript-resolvers,add} / @graphql-inspector/cli
- **架构师裁定**：Q-1~Q-11 全部按后端提议采纳；追加 R-1（Traceable 最小字段集）/ R-2（SDL 拼装 + breaking 检测双层）/ R-3（自定义标量白名单）
- **遗留**：
  - L-1：Book.license 暂用 String（shared-types licenseEnum 含 `CC-BY` 连字符不合 GraphQL enum）；需后续 ADR 决定规范化方式
  - F-1：services/api/package.json 缺 license 字段（backlog，见 `docs/tasks/T-P0-003-F1-license-field.md`）
- **下一步**：T-P0-007（API Person Query 首个真实 resolver）/ T-P0-005（LLM Gateway）可并行启动

### [feat] T-TG-002 完成 — TraceGuard Adapter（Port/Adapter 六边形架构，82 tests 全绿）
- **角色**：管线工程师（执行）+ 首席架构师（评审 Q-D1~Q-D7 + Mismatch 表 + 契约测试要求）
- **任务**：T-TG-002（S-1 调研 → S-2 依赖 → S-3 骨架 → S-4 规则 → S-5 adapter → S-6 policy → S-7 audit → S-8 replay）
- **变更**：
  - `services/pipeline/src/huadian_pipeline/qc/`：11 个源文件 + `rules/` 子包 3 文件
  - `_imports.py`：唯一 TG ingress（4 冻结符号）+ 3 条契约测试锁定上游 `guardian.__all__`
  - `action_map.py`：Mismatch #1 翻译表 + `ActionEscalator` Protocol + `UnknownTGActionError` 防御
  - `types.py`：ADR-004 协议（`CheckpointInput` / `CheckpointResult` / `Violation` / `ActionType`）
  - `adapter.py`：完整决策链 TG eval → registry → policy → audit → result；mode off/shadow/enforce 三态
  - `rule_registry.py`：`RuleRegistry` + `RuleSet` + fnmatch step 路由 + severity/rule_id 注册时覆盖
  - `rules/{common,ner,relation}_rules.py`：5 条首批规则（json_schema / confidence_threshold / surface_in_source / no_duplicate_entities / participants_exist）
  - `policy.py`：`ActionPolicy.from_yaml` / `resolve` / `make_escalator`（closure 填 Protocol 坑）
  - `config/traceguard_policy.yml`：ADR-004 §五 三段策略（defaults / by_severity / by_step）
  - `audit.py`：`AuditSink` 双写 `llm_calls` + `extractions_history`（ON CONFLICT DO UPDATE 幂等）
  - `migrations/0001_add_traceguard_raw_and_idempotent_idx.sql`：pipeline-side idempotent DDL
  - `replay.py`：`replay_one` / `replay_batch` / `ReplayReport` / `ReplayDiff` drift detection
  - `mock.py`：`MockTraceGuardPort`（零 TG 依赖单测桩）
  - `pyproject.toml`：`pipeline-guardian` git+tag pin + `asyncpg` + `testcontainers[postgres]` dev dep + `allow-direct-references`
  - 82 条测试（8 contract + 30 rules/registry + 22 policy + 10 audit/PG + 12 replay）+ basedpyright 0/0/0
- **follow-up**：T-TG-002-F6（Drizzle schema 同步 traceguard_raw + UNIQUE INDEX + 列注释）deferred to 后端工程师
- **解除阻塞**：T-P0-005（LLM Gateway）可启动

---

## 2026-04-16

### [feat] T-P0-004 批次 1 完成 — 历史专家字典种子初稿（秦汉 185 条）
- **角色**：历史专家（执行）+ 首席架构师（5 点裁决）
- **任务**：T-P0-004（批次 1，Phase 0 范围：秦汉）
- **变更**：
  - `data/dictionaries/_NOTES.md`：架构师 5 点裁决原文（Ruling-001 西汉起始年 BC -202 / Ruling-002 更始独立 polity / Ruling-003 "后元"三撞用 (emperor, name) 二元组 / Ruling-004 "甘露"跨代入 T-P0-002 F-5 / Ruling-005 slug 两阶段加载 + DEFERRABLE FK）+ 5 条工作约束（C-01 `_` 前缀忽略 / C-02 公元年份编码 / C-03 slug 命名 / C-04 slug 写死 / C-05 种子 semver）+ TODO-001（T-P0-006 加载器的 20 帝王 FK stub 前置要求表）+ 变更日志
  - `data/dictionaries/polities.seed.json`：5 条（`qin` / `han-western` / `xin` / `han-gengshi` / `han-eastern`），含 capital 历史变迁 / ruler 序列
  - `data/dictionaries/reign_eras.seed.json`：89 条 + `_datingGapNote` 7 节（秦无年号 / 西汉前五朝无命名 / 武帝以降全覆盖 / 边界年歧义 / 公元零年 / 共治并存 / 献帝 189 年五改元）
  - `data/dictionaries/disambiguation_seeds.seed.json`：10 组 surface / 26 行（韩信 / 刘秀 / 淮南王 / 楚王 / 赵王 / 公孙 / 霍将军 / 窦将军 / 王大将军 / 韩王）
  - `data/dictionaries/persons.seed.json`：40 人（秦 3 / 秦末楚汉 11 / 西汉初—武帝 14 / 西汉末—新—更始 5 / 东汉 7；覆盖全部 disambiguation FK + 鸿门宴 NER 必要角色 + 各朝锚点帝王）
  - `data/dictionaries/places.seed.json`：25 处（都城 5 / 封国郡国核心 10 / 战役典故地 7 / 人物籍贯 3），带 GeoJSON Point + fuzziness
- **架构师裁定（本会话 5 点）**：
  - Ruling-001：西汉起始年采 BC -202 称帝说；非主流说需开 ADR
  - Ruling-002：更始为独立 polity；CE 25 与东汉并存由 event_accounts.sequence_step + ruler_overlap 处理（属 T-P0-006 范畴）
  - Ruling-003：(emperorPersonSlug, name) 二元组识别；加载器 validate unique；前端强制带前缀
  - Ruling-004：甘露跨代记入 T-P0-002 follow-up F-5，本批不动 schema
  - Ruling-005：两阶段加载策略（Stage A 基础字典 / Stage B 依赖字典 / Stage C FK 回填），DEFERRABLE INITIALLY DEFERRED
- **生卒年采纳**：秦始皇 BC 259 / 刘邦 BC 256 / 项羽 BC 232 / 司马迁 range / 刘歆 range，均采《史记》索隐·集解主流说；非主流说需开 ADR
- **遗留**：
  - 20 位帝王 FK（东汉明/章/和/殇/安/顺/冲/质/桓/灵 + 秦二世/子婴 + 汉惠/吕后/昭/宣/元/成/哀/平/孺子婴）由 T-P0-006 加载器按 `_NOTES.md` TODO-001 stub 生成（slug + zh-Hans + dynasty 三字段）
  - 10 个父级郡国 slug（jingzhao-yin / henan-yin / chu-guo / zhao-guo / qi-guo / jiujiang-jun / si-shui-jun / linhuai-jun / donghai-jun / guangling-guo）按 C-04 记 WARN，批次 2 补齐
- **下一步**：可选启动 T-P0-004 批次 2（字典扩展）；或收工等 T-P0-006 拉种子；T-P0-003 / T-P0-005 并行不受影响

### [feat] TG-STAB-001 完成 — TraceGuard 上游稳定基线就绪
- **角色**：上游维护者（在 traceguard 仓内执行）+ 首席架构师（评审 / 拍板）
- **任务**：TG-STAB-001（华典侧不消耗代码改动，仅文档登记）
- **上游变更**（位于 `https://github.com/lizhuojunx86/traceguard`）：
  - annotated tag：`v0.1.0-huadian-baseline` @ SHA `0350b0a54ec646a96e3f25949b7ce604284c49eb`
  - 公开 API 冻结至 v0.2.0（`guardian.__all__` 仅 4 个符号）：`evaluate_async` / `StepOutput` / `GuardianConfig` / `GuardianDecision`
  - 上游 README 新增 "Stability for Downstream Integrators" 段，明确 internal 范围
  - 上游 CI 加固：Python 3.12 实证（`UV_PYTHON=3.12` job-level）/ ruff 加入 dev group / `uv sync --python 3.12 --extra mcp`
  - 上游契约测试 `tests/test_public_api.py`：4 符号面冻结，0.1.x 漂移立刻 CI 红
  - 上游 `.gitignore` 加固（IDE / macOS / DB / FUSE artifacts）+ `guardian/env.py` bug fix（embedding-only model 检测）
- **架构师裁定**：
  - 拒绝 TG 侧 alias（避免 TG `CheckpointResult` 与 ADR-004 §二 `CheckpointResult` 撞名误导下游）
  - 拒绝 TG 侧 facade（违反"baseline 不改业务逻辑"安全边界）
  - 选择"TG 用 TG 词汇 + 华典 Adapter 翻译"模型 → 见 ADR-004 §Errata 两张 Mismatch 表
- **影响**：
  - 解锁 T-TG-002 Adapter 实现（Session B 可基于上述 SHA 开工）
  - Q-D1 已决（仓库公开 + git rev pin 可行，T-TG-001 物理挂载降级为 fallback）
  - Q-D2 已决（不要求上游发 PyPI，git rev pin 充分）
  - Q-D5 / Q-D6 已决（见 ADR-004 §E-3 Mismatch #1）
- **下游 pin 坐标**（写入 `services/pipeline/pyproject.toml`）：
  - `pipeline-guardian @ git+https://github.com/lizhuojunx86/traceguard.git@v0.1.0-huadian-baseline`
- **CI 证据**：[run 24493213186](https://github.com/lizhuojunx86/traceguard/actions/runs/24493213186)（tag commit 自身跑过且绿，237 passed）
- **下一步**：T-TG-002 Adapter 实现（管线工程师 / Session B）

### [docs] ADR-004 errata — 新增 E-1~E-5
- **角色**：首席架构师
- **触发**：TG-STAB-001 调研 + 基线就绪
- **变更**：`docs/decisions/ADR-004-traceguard-integration-contract.md` 末尾新增 Errata 段
  - E-1：上游包名实测为 `pipeline-guardian` / import 名 `guardian`
  - E-2：上游公开 API 冻结基线（4 符号 + tag/SHA）
  - E-3：两张 Mismatch 表（Action 词汇 + 结果结构）作为 Adapter 翻译规范
  - E-4：3 条契约测试要求（华典侧防御性断言）
  - E-5：依赖坐标改为 git rev pin，T-TG-001 降级为 fallback
- **影响**：仅文档；ADR-004 正文 §一~§九 不变

### [feat] T-P0-002 完成 — DB Schema 落地（33 张表 + Drizzle 迁移）
- **角色**：后端工程师（执行）+ 首席架构师（评审）
- **任务**：T-P0-002
- **变更**：
  - `packages/shared-types/src/`：新增 `multi-lang.ts`（MultiLangText zod schema）、`historical-date.ts`（HistoricalDate）、`enums.ts`（22 个枚举）、`event-refs.ts`（EventParticipantRef / PlaceRef / SequenceStep）；更新 `index.ts` / `codegen.ts`
  - `packages/shared-types/schema/`：新增 6 个 JSON Schema 文件
  - `services/pipeline/src/huadian_pipeline/generated/`：新增 6 个 Pydantic 模型
  - `packages/db-schema/src/schema/`：按业务域拆分为 10 个文件（common / enums / sources / persons / events / places / relations / artifacts / embeddings / pipeline / feedback）
  - 33 张业务表 Drizzle 定义：books / raw_texts / source_evidences / evidence_links / textual_notes / text_variants / variant_chars / persons / person_names / identity_hypotheses / disambiguation_seeds / role_appellations / events / event_accounts / account_conflicts / event_causality / places / place_names / place_hierarchies / polities / reign_eras / relationships / mentions / allusions / allusion_evolution / allusion_usages / intertextual_links / institutions / institution_changes / artifacts / entity_embeddings / entity_revisions / llm_calls / pipeline_runs / extractions_history / feedback
  - 22 个 pgEnum 类型定义
  - PostGIS GEOMETRY customType + pgvector vector(1024) customType
  - Drizzle 初始迁移 `services/api/migrations/0000_lame_roughhouse.sql`（551 行）
  - `services/api/drizzle.config.ts` schema 路径改为 glob pattern
- **架构师评审裁定**：
  - Q-1：废弃 `event_places` / `event_participants`，JSONB 内嵌 + zod schema 约束
  - Q-2：废弃 `version_conflicts`，`account_conflicts` 替代
  - Q-3：v1 保留表统一升级（JSONB / slug / soft-delete / provenance）；历史原始数据保持 TEXT
  - Q-4：`entity_embeddings` BIGSERIAL PK；entity_id UUID（ADR-005 errata）
  - Q-5：schema 文件按业务域拆分；books 合入 sources.ts；新增 enums.ts
  - Q-8：`event_causality` 补 source_evidence_id + provenance_tier
  - R-1~R-9：详见任务卡
- **修复**：
  - `person_names` GIN 索引需要 `gin_trgm_ops` operator class — Drizzle 不原生支持，用 `sql` 模板注入
  - schema 文件 import 去 `.js` 扩展名以兼容 drizzle-kit CJS require
- **下一步**：T-P0-003（GraphQL 骨架）/ T-P0-004（字典种子）/ T-P0-005（LLM Gateway）可并行启动

### [docs] ADR-005 errata — entity_id UUID 修正
- **角色**：后端工程师（提出）+ 首席架构师（确认）
- **变更**：`docs/decisions/ADR-005-embedding-multi-slot.md` 中 `entity_id BIGINT` 修正为 `entity_id UUID`
- **原因**：所有实体表主键为 UUID，引用时类型必须匹配；原文 BIGINT 为笔误
- **影响**：仅文档修正

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
