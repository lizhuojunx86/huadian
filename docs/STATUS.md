# 华典智谱 · 项目状态板

> **本文件是项目的"现在时刻"快照，每次会话开始 / 结束都应阅读或更新。**

- **最近更新**：2026-04-18
- **更新人**：首席架构师 + 管线工程师 + 古籍/历史专家（Claude Opus）
- **当前阶段**：Phase 0 — **DB Schema ✅ + 字典批次 1 ✅ + TraceGuard Adapter ✅ + GraphQL 骨架 ✅ + LLM Gateway ✅ + API Person Query ✅ + Web MVP Person Card ✅ + Web Person Search/List ✅ + Pipeline 基础设施 + 真书 Pilot ✅ + 跨 chunk 身份消歧 ✅ + Web 首页 + 全局导航 ✅**

---

## 当前在哪

**T-P0-002（DB Schema 落地）已完成（2026-04-16）。**

数据库已具备：
- 33 张业务表（9 层：文本源 / 身份 / 事件 / 地理时间 / 关系引用 / 物品 / 嵌入审计 / 管线 / 反馈）
- Drizzle ORM schema 按业务域拆分为 10 个文件
- pgEnum 定义 22 个枚举类型
- PostGIS GEOMETRY + pgvector vector(1024) customType
- shared-types：HistoricalDate / MultiLangText / EventRefs / 全量枚举（zod → JSON Schema → Pydantic 全链路）
- 初始迁移 `0000_lame_roughhouse.sql`（551 行），在干净 PG 上 migrate 成功
- ADR-005 errata：entity_id 从 BIGINT 修正为 UUID

**下一步推进建议**（可并行）：
- **T-P0-003（GraphQL schema 骨架）** — 后端工程师
- **T-P0-004（历史专家字典初稿）** — 历史专家
- **T-P0-005（LLM Gateway + TraceGuard）** — 管线工程师

---

## 已完成

### [W-8] CI 基建修复 — DB schema apply + turbo env passthrough（2026-04-18）
- [x] S-1：调查 Drizzle vs pipeline raw SQL 覆盖范围 + extension 依赖验证
- [x] S-2：ci.yml 改用自定义 PG 镜像（`docker/postgres/Dockerfile`）+ Step 4b `db:migrate`
- [x] S-4.5：skip T-P1-001 已知隔离 2 case + 登记 `docs/debts/T-P1-001-test-isolation.md`
- [x] S-2b：turbo.json `passThroughEnv: ["DATABASE_URL", "REDIS_URL"]`（strict env mode 修复）
- CI Run [24600242038](https://github.com/lizhuojunx86/huadian/actions/runs/24600242038) 全绿（3 jobs success）
- 累计：3 commits / 0 新测试 / 2 case skip（T-P1-001 债）
- 衍生技术债：[T-P1-001](../docs/debts/T-P1-001-test-isolation.md)（API integration test isolation）

### T-P0-012 Web 首页 + 全局导航（2026-04-18）
- [x] S-1：布局骨架（Header + Footer → layout.tsx，子页面 `<main>` → `<div>` 修正）
- [x] S-2：首页 Hero（站名 + 定位语 + HeroSearch 搜索框）
- [x] S-3：知名人物区（6 slug 硬编码 + FeaturedPersonCard + Promise.all 并发 fetch）
- [x] S-4：数据概览（SDL `stats: Stats!` + API resolver 3× COUNT + StatsBlock 组件）
- [x] S-5：探索全部 CTA（→ /persons）
- [x] S-6：/about 页（项目简介 + 技术栈 + 状态 + 联系方式）
- [x] S-7：SEO metadata（首页 + /about OG 标签）
- [x] S-8：vitest 17 cases（Header 4 + Footer 3 + FeaturedPersonCard 5 + StatsBlock 2 + HeroSearch 3）
- [x] S-9：Playwright E2E 3 cases（推荐卡片 + 搜索跳转 + 导航关于）
- [x] S-10：STATUS / CHANGELOG / index 更新
- 累计：7 commits / 17 new unit tests / 3 E2E tests / 1 SDL 扩展（Stats type）
- 原 T-P0-012（冗余实体 soft-delete）重编号为 T-P0-014

### T-P0-011 跨 Chunk 身份消歧（2026-04-18）
- [x] Phase 1：ADR-010 起草 + v2 修订（评分函数/字典/soft merge/可逆性）
- [x] Phase 3：Schema migration（persons.merged_into_id + person_merge_log）
- [x] Phase 3：字典文件（tongjia.yaml + miaohao.yaml，带 source 字段）
- [x] Phase 3：identity_resolver 模块（resolve.py / resolve_rules.py / resolve_types.py）
- [x] Phase 3：R1 stop words + cross-dynasty guard（修复 3 个 false positive）
- [x] Phase 3：单元测试 34 cases 全绿
- [x] Phase 3：帝舜 data fix（Related Fix #2）
- [x] Phase 3：Dry-run 11 组全绿（169→157）
- [x] Phase 4：Apply merges（run_id=39b495d0，12 persons soft-merged）
- [x] Phase 4：API resolveCanonical（搜索穿透 + slug 透明返回 + 别名聚合）
- [x] Phase 4：Historian 抽样 5/5 正确
- [x] Phase 4：Web API 端到端验证 5/5 通过
- 累计：ADR-010 accepted / 3 schema migrations / 5 new Python modules / 2 YAML dicts / 34 pipeline tests / 6 commits

### T-P0-010 Pipeline 基础设施 + 真书 Pilot（2026-04-18）
- [x] S-prep 1~8：管线基础设施从零建设（8 模块，8 commits）
  - Python 模块导入修复 / ctext adapter + fixtures / ingest / NER prompt v1 / extract / load / CLI / seed dump
- [x] Phase A：五帝本纪 smoke（29 段，62 persons，$0.54）
  - 精确率 ~94%，召回率 ~100%
  - Historian 抽检 8/10 正确
- [x] Prompt v1-r2：A-class fixes（帝X校验 / 姓氏规则 / 部族排除 / 合称规则）
- [x] Phase B：夏本纪 + 殷本纪 扩容（70 段，107 new persons，$1.23）
  - 精确率 ~93%，召回率 ~100%，抽样正确率 90%（改善）
  - 帝X 误归 Phase A→1 处 → Phase B→0 处（修复验证）
- [x] 发现问题清单 + T-P0-011 建立
- 累计产出：3 books / 169 persons / 273 names / $1.77 总成本

### T-P0-009 Web 人物搜索/列表页（2026-04-18）
- [x] S-0：任务卡起草
- [x] S-1：SDL 扩展 — persons(search, limit, offset): PersonSearchResult
- [x] S-2：service + resolver — pg_trgm similarity + ILIKE fallback
- [x] S-3：集成测试 13 cases（精确/模糊/空结果/分页/soft-delete）
- [x] S-4：Web codegen + PersonsSearchQuery typed document
- [x] S-5：/persons 路由 + Server Component（searchParams → SSR fetch）
- [x] S-6：SearchBar 客户端组件（300ms debounce + router.replace）
- [x] S-7：PersonListItem + PersonList 组件
- [x] S-8：Pagination 组件（上一页/下一页 + total 显示）
- [x] S-9：loading 骨架屏 / error 重试 / 空结果提示
- [x] S-10：vitest 15 cases + Playwright E2E 2 cases
- [x] Q-1~Q-7 预裁决策全部落地
- [x] lint / typecheck / build / codegen 全绿

### T-P0-008 Web MVP — 人物卡片页（2026-04-18）
- [x] S-0：Tailwind CSS v3 + shadcn/ui 初始化 + 全依赖安装
- [x] S-1：GraphQL codegen 前端管线（client-preset typed documents）
- [x] S-2：路由 `/persons/[slug]` + async Server Component + generateMetadata
- [x] S-3：PersonCard + HistoricalDateDisplay 组件
- [x] S-4：PersonNames + PersonHypotheses 分区（含空状态占位）
- [x] S-5：Loading 骨架屏 / Error 重试 / notFound 404
- [x] S-6：vitest 单元测试 23 cases 全绿
- [x] S-7：Playwright E2E 冒烟 2 cases（需 API + DB）
- [x] Q-1 架构师豁免：Phase 0 暂免 UI/UX 角色参与
- [x] lint 0 errors / typecheck / build / codegen 全绿

### T-P0-007 API MVP — person query（2026-04-18）
- [x] S-0.5：SDL nullable 变更（ADR-009 实施）— 6 文件 `sourceEvidenceId: ID!` → `ID` + codegen
- [x] S-1：slug 验证工具函数 `src/utils/slug.ts` + 9 单元测试
- [x] S-2：Service layer + DTO 映射 `src/services/person.service.ts`（findPersonBySlug eager / findPersons pagination）
- [x] S-3：Resolver 实现（person/persons 真实查询 + Person field resolvers for names/identityHypotheses）
- [x] S-4：Integration 测试（真 PG + 4 fixture persons + 8 test cases）
- [x] S-5：lint + typecheck + build + codegen 全绿
- [x] vitest 测试框架引入（31 tests 全绿：9 slug + 7 DTO mapper + 7 resolver + 8 integration）
- [x] tsconfig.test.json + eslint 配置支持 tests 目录

### T-P0-005 LLM Gateway + TraceGuard 基础集成（2026-04-17）
- [x] `services/pipeline/src/huadian_pipeline/ai/` 子包：6 个源文件
- [x] `types.py`：LLMResponse / LLMGatewayError / PromptSpec
- [x] `gateway.py`：LLMGateway Protocol
- [x] `hashing.py`：prompt_hash / input_hash（SHA-256 确定性）
- [x] `anthropic_provider.py`：AnthropicGateway 实现
  - AsyncAnthropic SDK + HTTP 层指数退避 retry（429/529/5xx）
  - TraceGuard checkpoint 内置（Q-1 裁定 A）：action 路由 pass/retry/degrade/fail
  - Token 定价 hardcode 成本计算（Q-3）
  - Best-effort audit writer hook
- [x] `audit.py`：LLMCallAuditWriter（asyncpg → llm_calls 表，Q-2）
- [x] 新增依赖 `anthropic>=0.40.0`（架构师批准）
- [x] 46 条 ai/ 测试全绿 + basedpyright 0/0/0
- [x] 全量 128 测试通过（ai/ 46 + qc/ 82）

### T-P0-003 GraphQL schema 骨架（2026-04-17）
- [x] SDL 骨架：8 个 .graphql 文件（scalars / enums / common / a-sources / b-persons / c-events / d-places / queries + _bootstrap）
- [x] 12 entity types（Book / SourceEvidence / Person / PersonName / IdentityHypothesis / Event / EventAccount / AccountConflict / Place / PlaceName / Polity / ReignEra）+ 3 JSONB ref types + Traceable interface
- [x] 5 implements Traceable（Book / SourceEvidence / Person / Event / Place）— R-1 三字段（sourceEvidenceId / provenanceTier / updatedAt）
- [x] 5 Query 入口（person / persons / event / place / sourceEvidence）全抛 NOT_IMPLEMENTED（Q-10）
- [x] graphql-codegen（SDL → 1020 行 TS types）+ 确定性 schema:merge 快照
- [x] HuadianGraphQLError + 6 codes + GraphQLContext（db / requestId / tracer）
- [x] CI graphql-breaking.yml（drift check + graphql-inspector diff warn-only）
- [x] pnpm -r build / lint / typecheck / codegen 全绿；GraphiQL 本地验证通过

### T-TG-002 TraceGuard Adapter 实现（2026-04-17）
- [x] Port/Adapter 六边形架构（`src/huadian_pipeline/qc/`）
- [x] `_imports.py` 唯一 TG ingress（4 冻结符号）+ 3 条契约测试
- [x] `action_map.py` Mismatch #1 翻译 + `ActionEscalator` Protocol
- [x] `types.py` ADR-004 协议（CheckpointInput / CheckpointResult / Violation）
- [x] `adapter.py` 完整决策链：TG eval → rules → policy → audit → result
- [x] `rule_registry.py` + 5 条首批规则（common ×2 / ner ×2 / relation ×1）
- [x] `policy.py` + `traceguard_policy.yml`（defaults / by_severity / by_step 三段）
- [x] `audit.py` 双写 llm_calls + extractions_history（ON CONFLICT DO UPDATE 幂等）
- [x] `replay.py` 回放回归检测（ReplayReport / ReplayDiff / drift detection）
- [x] 82 条测试全绿 + basedpyright 0/0/0
- [x] follow-up F-6：Drizzle schema 同步 deferred to 后端

### T-P0-004 历史专家字典初稿 · 批次 1（2026-04-16）
- [x] `data/dictionaries/_NOTES.md` — 架构师 5 点裁决 + 5 条工作约束（C-01~C-05）+ TODO-001（T-P0-006 stub 前置要求）
- [x] `data/dictionaries/polities.seed.json` — 5 条（秦 / 西汉 / 新 / 更始 / 东汉）
- [x] `data/dictionaries/reign_eras.seed.json` — 89 条 + `_datingGapNote` 7 节（秦无年号 / 西汉前五朝无命名 / 武帝以降全覆盖 / 边界年歧义 / 公元零年 / 共治并存 / 献帝 189 年五改元）
- [x] `data/dictionaries/disambiguation_seeds.seed.json` — 10 组 surface / 26 行（韩信 / 刘秀 / 淮南王 / 楚王 / 赵王 / 公孙 / 霍将军 / 窦将军 / 王大将军 / 韩王）
- [x] `data/dictionaries/persons.seed.json` — 40 人（秦 3 / 秦末楚汉 11 / 西汉初—武帝 14 / 西汉末—新—更始 5 / 东汉 7；鸿门宴 NER 必要角色齐全）
- [x] `data/dictionaries/places.seed.json` — 25 处（都城 5 / 封国郡国核心 10 / 战役典故 7 / 人物籍贯 3）
- [x] 裁决落地：BC -202 西汉起始年 / 更始独立 polity / "后元"三撞靠 (emperor, name) 二元组 / "甘露"跨代入 T-P0-002 F-5 / slug 两阶段加载 + DEFERRABLE FK

### T-P0-002 DB Schema 落地（2026-04-16）
- [x] shared-types：HistoricalDate / MultiLangText / EventRefs / 22 枚举 zod schema
- [x] db-schema：10 个 schema 文件（common / enums / sources / persons / events / places / relations / artifacts / embeddings / pipeline / feedback）
- [x] 33 张表 Drizzle 定义 + pgEnum
- [x] PostGIS GEOMETRY customType + pgvector vector(1024) customType
- [x] gen-types.sh 全链路：6 JSON Schema + 6 Pydantic 模型
- [x] drizzle-kit generate + migrate 成功
- [x] pnpm -r build / lint / typecheck 全绿
- [x] ADR-005 errata（entity_id UUID）

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

无。等待用户选择下一任务。（T-P0-012 刚完成）

---

## 下一步候选（按建议优先级）

| 优先级 | 任务 ID | 描述 | 主导角色 | 依赖 | 状态 |
|--------|---------|------|---------|------|------|
| 🔴 高 | T-P0-014 | 冗余实体 soft-delete（姒氏/昆吾氏/羲氏/和氏/荤粥） | 管线 + historian | T-P0-011 ✅ | planned |
| 🔴 高 | T-P0-013 | Canonical 选择算法优化（帝X 前缀偏差） | 管线 | T-P0-011 ✅ | planned |
| 🟡 中 | T-P0-005a | SigNoz 版本对齐与接入 | DevOps + 管线 | T-P0-005 ✅ | planned |
| 🟡 中 | T-P0-004 批次 2 | 字典扩展（秦汉二线人物 + 更多封国/战役地 + slug 补齐） | 历史专家 | T-P0-004 批次 1 ✅ | planned |
| 🟡 中 | T-P0-006 | Pipeline：扩量跑（周本纪及以后） | 管线工程师 | T-P0-011 ✅ | planned |
| 🟢 低 | T-P1-001 | API 集成测试 isolation 修复（hasMore + ordering 2 case） | 后端 | — | registered（[debt doc](../docs/debts/T-P1-001-test-isolation.md)） |

---

## 阻塞项

| # | 描述 | 等待 | 建议处理 |
|---|------|------|---------|
| （无当前阻塞） | — | — | T-P0-003 / T-P0-004 / T-P0-005 可并行启动 |

---

## 最近决策（ADR · 已接受）

- `ADR-001` — 单 PostgreSQL 16 + pgvector + PostGIS + pg_trgm
- `ADR-002` — 事件双层建模（Event + EventAccount）
- `ADR-003` — 多角色协作框架启用（10 角色）
- `ADR-004` — TraceGuard 集成合同（Port/Adapter 契约）
- `ADR-005` — Embedding 多槽位与模型切换策略（errata：entity_id UUID）
- `ADR-006` — 未决项 U-01~U-07 封版决策
- `ADR-007` — Monorepo 布局与包管理（pnpm + uv + Turborepo）
- `ADR-008` — License 策略（GraphQL Book.license `CC_BY` 规范化 + workspace 包 `UNLICENSED`）
- `ADR-009` — Person sourceEvidenceId Traceability（Traceable 接口 `sourceEvidenceId` nullable 放宽；R-1 修订）

---

## 健康度指标

- 📘 文档覆盖度：核心 7/7 ✅
- 🧭 ADR 数量：10 accepted / 9 planned
- 📋 任务卡数量：T-P0-001~T-P0-012 done（12）；T-P0-005a / T-P0-013 / T-P0-014 planned
- 👥 Agent 角色定义：10/10 ✅
- 🏗️ 子包 build：10/10 全绿
- 🐳 Docker：PG + Redis 健康；33 张表 migrate 成功；SigNoz deferred；端口约定 5433/6380
- 📚 字典种子：185 条（polities 5 / reign_eras 89 / disamb 26 / persons 40 / places 25）@ 0.1.0-draft 静躺待 T-P0-006 加载
- 🧪 测试覆盖：246 passed + 2 skipped（ai/ 46 + qc/ 82 + resolve/ 34 + api/ 43(2 T-P1-001 skip) + web/ 55）；E2E 7 specs
- 🔗 合并状态：157 canonical persons（12 soft-merged via T-P0-011, run_id=39b495d0）
- 🚦 阻塞项数量：0 ✅

---

## 更新日志（STATUS 文件本身的）

- 2026-04-15：初始化
- 2026-04-15：T-001 / T-002 / T-003 / T-TG-001 完成
- 2026-04-15：ADR-007 accepted；T-P0-001 ready
- 2026-04-15：T-P0-001 done — Monorepo 骨架落地；SigNoz deferred to T-P0-005a；T-P0-002 进入 ready
- 2026-04-16：T-P0-002 done — DB Schema 落地（33 表 + Drizzle 迁移 + shared-types + ADR-005 errata）
- 2026-04-16：T-P0-004 批次 1 done — 字典种子 185 条（polities/reign_eras/disamb/persons/places）+ _NOTES.md（5 裁决 + 5 约束 + TODO-001）
- 2026-04-17：T-P0-007 / T-P0-005 任务卡就绪（ready）；ADR-008 accepted（License 策略）
- 2026-04-17：T-TG-002 done — TraceGuard Adapter 实现（Port/Adapter + 5 rules + policy + audit + replay；82 tests；6 commits）
- 2026-04-17：ADR-009 accepted — Traceable.sourceEvidenceId nullable 放宽（T-P0-007 Q-5 裁决）；T-P0-007 任务卡 v2 更新（新增 S-0.5 SDL 变更子任务）
- 2026-04-17：T-P0-003 done — GraphQL schema 骨架（12 entity types + Traceable + 5 Query + codegen + CI graphql:breaking；6 commits）
- 2026-04-18：T-P0-007 done — API Person Query（SDL nullable ADR-009 + slug 验证 + service layer + resolver + 31 tests；5 commits）
- 2026-04-18：T-P0-008 done — Web MVP 人物卡片页（Tailwind + shadcn + codegen + /persons/[slug] + 4 组件 + 23 tests + 2 E2E；8 commits）
- 2026-04-17：T-P0-005 done — LLM Gateway + TraceGuard 基础集成（ai/ 子包 6 文件 + anthropic SDK + 46 tests；4 commits）
- 2026-04-18：T-P0-009 done — Web 人物搜索/列表页（SDL PersonSearchResult + pg_trgm search + /persons 路由 + SearchBar + Pagination + 28 新增 tests + 2 E2E；7 commits）
- 2026-04-18：T-P0-011 done — 跨 chunk 身份消歧（ADR-010 + identity_resolver 5 规则 + 2 YAML 字典 + schema migration + API resolveCanonical；11 组合并 169→157 persons；34 pipeline tests + 5 web 验证；6 commits）
- 2026-04-18：T-P0-012 done — Web 首页 + 全局导航（Header/Footer layout + Hero + FeaturedPersonCard×6 + Stats SDL 扩展 + StatsBlock + /about + SEO；17 unit tests + 3 E2E；7 commits）；原 T-P0-012 冗余实体 soft-delete 重编号为 T-P0-014
- 2026-04-18：W-8 done — CI 基建修复（自定义 PG 镜像 + db:migrate + turbo passThroughEnv；Run 24600242038 全绿；3 commits）；衍生债 T-P1-001 registered
