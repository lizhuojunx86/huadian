# 华典智谱 · 项目状态板

> **本文件是项目的"现在时刻"快照，每次会话开始 / 结束都应阅读或更新。**

- **最近更新**：2026-04-19
- **更新人**：管线工程师（Claude Opus）
- **当前阶段**：Phase 0 — **DB Schema ✅ + 字典批次 1 ✅ + TraceGuard Adapter ✅ + GraphQL 骨架 ✅ + LLM Gateway ✅ + API Person Query ✅ + Web MVP Person Card ✅ + Web Person Search/List ✅ + Pipeline 基础设施 + 真书 Pilot ✅ + 跨 chunk 身份消歧 ✅ + Web 首页 + 全局导航 ✅ + 非人实体清理 ✅ + 帝鸿氏归并 ✅ + β 尚书摄入 ✅ + F10 残留 demote ✅ + persons CHECK 约束 ✅ + is_primary 同步 ✅**

---

## 当前在哪

**Phase 0 α-blocking 推进期。距 α 第一本书 ingest 还差 2 张卡。**

今日交付 3 个 sprint（7 commits）：
- **T-P0-022**：F10 α merge source primary 残留 demote（8 行）
- **T-P0-020**：persons_merge_requires_delete CHECK 约束上线（单向蕴涵）
- **T-P0-016**：apply_merges + load.py W1 双路径 is_primary 同步 + backfill 18 行

**里程碑：V1-V6 全套 invariant 首次集体绿——数据层一致性达项目最佳。**

**下一步**：T-P0-023（ADR-015 Evidence 链 Stage 1 实装，α 阻塞必做，涉及 Drizzle migration + extract→load 链改造）

---

## 已完成

### T-P0-016 apply_merges + load.py W1 双路径 is_primary 同步（2026-04-19）
- [x] Stage 0：4 闸门 + 写路径审计发现第二活跃路径（W1）
- [x] Stage 1a：resolve.py apply_merges SET 子句加 is_primary=false（4 测试）
- [x] Stage 1b：load.py W1 is_primary_value = primary_name_type == "primary"（2 测试）
- [x] Stage 2：Migration 0007 backfill 18 行 → 0（V6 TDD red→green）
- [x] Stage 3：book-keeping + F12 debt 登记
- 结果：18 行违规清零；V1-V6 首次全绿；269 pipeline + 61 api + 55 web = 385 tests
- 附带发现：W2 路径对称违规（F12），11 行 active 基线
- 累计：4 commits / 7 new tests / 1 migration / 1 new debt (F12)

### T-P0-022 + T-P0-020 合并 Sprint — F10 残留清理 + persons CHECK 约束（2026-04-19）
- [x] Stage 0：共用 4 闸门 + 双预扫描（T-P0-020 发现 5 行 partial-delete 违反原 CHECK）
- [x] Stage 1（T-P0-022）：Migration 0005 demote 8 行 merge source primary→alias
- [x] Stage 2（T-P0-020）：Migration 0006 ALTER TABLE persons_merge_requires_delete CHECK（架构师裁决双向→单向）
- [x] Stage 3：ADR-010 supplement + book-keeping + F3/F4/F10 resolved
- 结果：F10 清零；persons 三态语义确立（active/merge/pure）；V1-V5 全 PASS
- Drizzle schema 同步 persons.ts
- 累计：3 commits / 2 migrations / 0 new tests / ADR-010 supplement

### T-P0-006-β《尚书·尧典 + 舜典》摄入 — β 路线跨书归并压力测试（2026-04-19）
- [x] S-0：任务卡 + 6 问架构师预裁
- [x] S-1：fixtures 准备 + ctext adapter 扩展 + DB 现状对照表
- [x] S-2：Ingest（2 books / 27 raw_texts / 1700 字）
- [x] S-3a：smoke v1-r3 → 发现"帝" surface 污染 → 停机
- [x] S-3a-bis：v1-r4 prompt + _filter_pronoun_surfaces + prompt caching（双保险方案 C）
- [x] S-3b：全量 NER v1-r4（$0.12 含 cache）+ load 入库（5 new persons）
- [x] S-3b-fix：ADR-013 partial unique index（修 slug 冲突）+ 弃/垂 retry
- [x] S-4：Dry-run identity resolver（2 auto + 1 manual + 1 α-fix）
- [x] S-5：Merge apply → model-B 误用 → rollback + apply_merges() rerun per ADR-014
- [x] S-6：CI 全绿 + V1-V4 invariant 全 PASS
- 结果：153 active persons（151α + 5β - 3 merged）；2 new（殳斨/伯与）
- 核心验证：R3 tongjia 跨书触发（垂→倕）端到端通过 ✅
- 过程产出：ADR-013（partial unique）+ ADR-014（model-A merge）+ NER v1-r4 + 7 pronoun filter tests + V4 invariant
- 衍生债：11 条 followups（见 docs/debts/T-P0-006-beta-followups.md）
- 累计成本：~$0.28（NER API）
- 累计：8 commits / 7 new tests / 4 DB merges / 2 ADRs / 1 migration

### T-P1-004 NER 阶段单人多 primary 约束 — 三层防御（2026-04-19）
- [x] S-0：任务卡创建
- [x] S-1：现状分析（14 NER-source 多 primary，4 类冲突模式）
- [x] S-2：规则设计 + ADR-012 初稿
- [x] S-3：实施
  - NER prompt v1-r3：`## name_type 唯一性约束（严格）` + 反�� few-shot
  - `load.py _enforce_single_primary()`：auto-demotion 4 case（>1 primary / 0+match / 0+no-match / pass）
  - QC 规则 `ner.single_primary_per_person`（severity=major）
  - 共享 `is_di_honorific()` 从 resolve_rules.py 抽取
  - 32 new tests（load 18 + QC 8 + is_di_honorific 6）
- [x] S-4：跳过（不加 DB partial unique index，NER + ingest 两层足够）
- [x] S-5：验证全绿（ruff 0 / basedpyright 0/0/0 / 250 pipeline + 61 api + 55 web tests）
- 结果：single-primary 成为管线不变量；ADR-012 accepted；零 DB 变更
- 累计：4 commits / 32 new tests / 0 DB changes / 1 QC rule / 1 shared utility

### T-P2-002 persons.slug 命名一致性清理 — 分层白名单（2026-04-19）
- [x] S-0：任务卡创建
- [x] S-1：现状调研（151 active persons: 88 unicode + 63 pinyin, 0 collisions）
- [x] S-2：方向裁决 → 方向 3（分层白名单：Tier-S pinyin + unicode fallback）
- [x] S-3：实施
  - `data/tier-s-slugs.yaml`（74 条 Tier-S 白名单，含治理规则注释）
  - `services/pipeline/src/huadian_pipeline/slug.py`（generate_slug / unicode_slug / classify_slug）
  - `load.py` 重构（删除 `_PINYIN_MAP` + `_generate_slug`，改用 slug 模块）
  - ADR-011 accepted（分层白名单决策 + 扩列治理 + 不变量保证）
  - 23 unit tests（test_slug.py）+ 3 invariant tests（test_slug_invariant.py）
- [x] S-4：跳过（方向 3 无 DB 变更）
- [x] S-5：验证全绿（ruff 0 / basedpyright 0/0/0 / 218 pipeline + 61 api + 55 web tests）
- 结果：slug 规则明文化为 YAML 白名单；不变量测试 CI 保证；零 DB 变更；零 URL 变更
- 累计：3 commits / 26 new tests / 0 DB changes / 1 new dependency (pyyaml) / ADR-011

### T-P1-002 person_names 降级 + 去重 + UNIQUE 约束（2026-04-19）
- [x] S-0：任务卡创建
- [x] S-1：现状调研（17 person_id 多 primary + 11 对跨 person_id 重复 + 0 per-person_id 重复）
- [x] S-2：方向裁决 → C（混合）：写端 primary 降级 + 读端 name 文本 dedup
- [x] S-3：实施（Drizzle schema UNIQUE + backfill SQL + resolve.py demote + API dedup + 9 integration tests）
- [x] S-4：DB 执行（17 行 primary→alias + UNIQUE INDEX uq_person_names_person_name）
- [x] S-5：V1-V3 验证通过 + STATUS/CHANGELOG 更新
- 结果：17 行降级；19 canonical 多 primary → 0；11 对跨 person_id 重复由读端兜住
- 衍生债：T-P1-004（NER 单人多 primary 约束）
- 累计：2 commits / 9 new tests / 17 DB UPDATE / 1 schema migration

### T-P0-015 帝鸿氏/缙云氏 Canonical 归并裁决（2026-04-19）
- [x] S-0：任务卡创建
- [x] S-1：证据调研（DB 快照 + 五帝本纪 P24 原文 + 古注四家训释）
- [x] S-2：Historian 裁决 → (c) 混合：帝鸿氏 MERGE，缙云氏 KEEP-independent
  - 帝鸿氏=黄帝：贾逵/杜预/服虔/张守节四家一致（"帝鸿，黄帝也"）
  - 缙云氏≠黄帝：杜预/贾逵训为"黄帝时官名"（从属关系非等同）+ P24 并列结构约束
- [x] S-3：dry-run JSON + merge SQL（R4-honorific-alias 新规则）
- [x] S-4：DB 执行（1 person merged, 1 merge_log, 1 person_name added）
- [x] S-5：V-1~V-5 验证全通过 + STATUS/CHANGELOG 更新
- 结果：152 → 151 active persons；黄帝 names 新增"帝鸿氏(alias)"
- 累计：1 commit / 0 new tests / 1 DB merge / 1 新 merge_rule (R4-honorific-alias)

### T-P1-003 搜索召回精度调优 — F1 95.6%→100%（2026-04-19）
- [x] S-1：searchPersons 实现调研（pg_trgm threshold=0.3 + ILIKE，GIN 索引确认）
- [x] S-2：黄金测试集 30 条（精确/短词FP/异写/前缀/不存在 6 维度）
- [x] S-3：基线 benchmark（P=93.9% R=100% F1=95.6%，3 disallowed violations）
- [x] S-4：4 策略实验（A 阈值提高 / B 前缀优先 / C 长度加权 / D 三段式）→ C 以 F1=100% 胜出
- [x] S-5：实施 Strategy C — `similarityThreshold()` 长度加权 + `aliasSubstringSearch()` fallback
- [x] S-6：最终 benchmark（P=100% R=100% F1=100%，0 violations）+ 7 条回归单测
- [x] S-7：5 commits / push / CI
- 修复 FP：帝中→中壬/中康、帝中丁→中壬/中康、帝武乙→武丁 全部消除
- 累计：5 commits / 7 new tests / 30 条黄金集 / 0 schema 变更

### T-P0-014 非人实体清理 — soft-delete 5 条（2026-04-19）
- [x] S-1：候选审计（157 persons 扫描 → 7 候选 A 类 + 9 B 类）
- [x] S-1 核查规程：surface_forms 裸名检查 + 原文上下文验证
  - 羲氏/和氏 触发裸名 guard → historian override → delete
  - 熊罴/龙 确认为舜臣 → KEEP
- [x] S-2：`is_likely_non_person()` 规则函数（HONORIFIC_SHI_WHITELIST 13 条 + _KNOWN_NON_PERSON_NAMES 词典 + X氏 suffix pattern + bare-name guard）
- [x] S-3：22 新 test cases（7 TP + 9 TN + 4 boundary + 1 whitelist sanity + 1 extra），67 total resolve
- [x] S-4：SQL soft-delete 5 条（荤粥/昆吾氏/姒氏/羲氏/和氏），person_merge_log 5 行（merge_rule='R3-non-person'）
- [x] S-5：V-1 lint/typecheck/test 全绿；V-2/V-3 DB 验证通过
- 结果：157 → 152 active persons
- 累计：5 commits / 22 new tests / 5 DB soft-deletes / 1 新规则函数
- 衍生债：T-P2-002（slug 命名不一致）

### T-P0-013 Canonical 选择策略优化 — 帝X 前缀去偏差（2026-04-18）
- [x] S-1：`has_di_prefix_peer()` 辅助函数 + `select_canonical()` sort_key 插入帝X惩罚项（priority #2）
- [x] S-2：11 新 test cases（TestSelectCanonical 6 + TestHasDiPrefixPeer 5），45 total pass
- [x] S-3：`verify_canonical.py` 验证全部 12 条 merge — 仅 1 组需改（帝中丁→中丁），武乙组旧规则已正确
- [x] S-4：SQL 反转帝中丁/中丁 canonical 方向（事务执行，V1/V2/V3 验证通过）
- [x] S-5：STATUS / CHANGELOG 更新
- ADR-010 Known Follow-up #1 闭环
- 累计：4 commits / 11 new tests / 1 DB data fix（canonical reversal）

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

无。（T-P0-016 刚完成）

**已锁定下一张**：T-P0-023（ADR-015 Evidence 链 Stage 1 实装），等 STATUS.md push 后开工。

---

## 下一步候选（按建议优先级）

| 优先级 | 任务 ID | 描述 | 主导角色 | 依赖 | 状态 |
|--------|---------|------|---------|------|------|
| 🔴 高 | T-P0-023 | Evidence 链 Stage 1（新行必填段落级 + seed_dictionary 枚举） | 管线 + 后端 | ADR-015 ✅ | planned |
| 🟡 中 | T-P0-019 | β 尾巴清理（F1 pronoun + F2 prefix-containment；F4 已由 ADR-010 supplement 统一） | 管线 | — | planned |
| 🟡 中 | T-P0-024 | Evidence 链 Stage 2 回填（存量 text-search 反查） | 管线 + historian | T-P0-023 | planned |
| 🟡 中 | T-P0-005a | SigNoz 版本对齐与接入 | DevOps + 管线 | T-P0-005 ✅ | planned |
| 🟡 中 | T-P0-004 批次 2 | 字典扩展（秦汉二线人物 + 封国/战役地 + slug 补齐） | 历史专家 | T-P0-004 批次 1 ✅ | planned |
| 🟡 中 | T-P0-006 | Pipeline：扩量跑（周本纪及以后） | 管线工程师 | T-P0-023 | planned |
| 🟡 中 | T-P1-005 | 统一 migration 入口（Drizzle + pipeline SQL 双轨合一） | DevOps + 后端 | — | registered |
| ⚪ 微 | T-P2-001 | codegen trailing newline 不一致 | DevOps | — | registered |

---

## 阻塞项

| # | 描述 | 等待 | 建议处理 |
|---|------|------|---------|
| （无当前阻塞） | — | — | T-P0-023 可立即开工 |

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
- `ADR-010` — 跨 chunk 身份消歧（5 规则评分函数 + 字典 + soft merge + 可逆性）
- `ADR-011` — Person Slug Naming Scheme — Tiered Whitelist（方向 3：Tier-S pinyin + unicode fallback；扩列治理；不变量测试）
- `ADR-012` — NER 单人多 primary 约束三层防御（prompt + ingest auto-demotion + QC rule）
- `ADR-013` — persons.slug partial unique index（排除 soft-deleted persons）
- `ADR-014` — Canonical Merge Execution Model（names-stay + read-side aggregation + apply_merges() 唯一入口）
- `ADR-015` — Evidence 链填充方案（staged activation + paragraph-level Stage 1）
- `ADR-017` — Migration Rollback Strategy（forward-only + pg_dump anchor + 4 闸门协议）
- `ADR-010 Supplement` — persons 表三态 soft-delete 语义 + 单向 CHECK 选型

---

## 健康度指标

- 📘 文档覆盖度：核心 7/7 ✅
- 🧭 ADR 数量：16 accepted（含 ADR-010 supplement）
- 📋 任务卡数量：T-P0-001~T-P0-016 + T-P0-019~T-P0-024 done/planned（20+）
- 👥 Agent 角色定义：10/10 ✅
- 🏗️ 子包 build：10/10 全绿
- 🐳 Docker：PG + Redis 健康；33 张表 migrate 成功；SigNoz deferred；端口约定 5433/6380
- 📚 字典种子：185 条（polities 5 / reign_eras 89 / disamb 26 / persons 40 / places 25）@ 0.1.0-draft 静躺待 T-P0-006 加载
- 🧪 测试覆盖：385 passed（pipeline 269 + api 61 + web 55）+ 0 skipped；E2E 7 specs
- 🔗 合并状态：153 active persons / 16 merge-soft-deleted / 5 pure-soft-deleted = 174 total
- 🗄️ Pipeline migrations：0001–0007（latest: 0007_t-p0-016-is-primary-backfill.sql）
- 🚦 阻塞项数量：0 ✅

### 数据层不变量矩阵

| # | Invariant | 描述 | 当前状态 | 转绿日期 |
|---|-----------|------|---------|---------|
| V1 | single-primary | 每 active person 恰 1 个 name_type='primary' | ✅ | 历史绿 |
| V2 | name completeness | 每 active person 至少 1 个 name | ✅ | 历史绿 |
| V3 | FK completeness | merged_into_id 指向存在的 person | ✅ | 历史绿 |
| V4 | model-B leakage | merged source 无 primary name | ✅ | 2026-04-19（T-P0-022） |
| V5 | active definition | 无 merged 但未 deleted（CHECK 约束保护） | ✅ | 2026-04-19（T-P0-020） |
| V6 | alias ≠ is_primary | 全表无 alias+is_primary=true | ✅ | 2026-04-19（T-P0-016） |

**V1-V6 全绿（首次达成 2026-04-19）**。

### 已知未处理违规（debt baseline）

| Debt | 描述 | 行数 | 优先级 |
|------|------|------|--------|
| F12 | primary + is_primary=false（W2 路径） | 11 行 active | P2 |

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
- 2026-04-18：T-P0-013 done — Canonical 帝X 前缀去偏差（has_di_prefix_peer + select_canonical 优先级链；1 组 canonical 反转 帝中丁→中丁；11 new tests → 45 resolve tests；4 commits）；ADR-010 Follow-up #1 闭环
- 2026-04-19：T-P0-014 done — 非人实体清理（is_likely_non_person 规则 + HONORIFIC_SHI_WHITELIST 13 条 + X氏 pattern；5 entities soft-deleted 157→152 persons；22 new tests → 67 resolve tests；5 commits）；衍生债 T-P2-002 registered
- 2026-04-19：T-P1-001 closed — API 集成测试隔离修复（2 skip → 0 skip；hasMore 断言改用 probe+offset、ordering 断言 scope 到 test-* fixtures；1 commit）
- 2026-04-19：T-P1-003 closed — 搜索召回精度调优（length-weighted threshold + alias fallback；F1 95.6%→100%；3 FP 消除；30 条黄金集 + 7 new tests → 52 api tests；5 commits）
- 2026-04-19：T-P2-003 closed — 清理 datamodel-codegen dash-case 死文件（5 untracked files 删除 + gen-types.sh 防御性 find-delete 兜底；1 commit）
- 2026-04-19：T-P0-015 done — 帝鸿氏归并入黄帝（historian 裁决 (c) 混合：帝鸿氏 MERGE R4-honorific-alias + 缙云氏 KEEP-independent；152→151 persons；1 commit）
- 2026-04-19：T-P1-002 closed — person_names 降级+去重+UNIQUE（方向 C 混合：写端 backfill 17 行 primary→alias + resolve.py demote；读端 name 文本 dedup 4 级排序；UNIQUE (person_id,name)；9 new tests → 61 api tests；2 commits）；衍生债 T-P1-004 registered
- 2026-04-19：T-P2-002 closed — slug 命名一致性清理（方向 3 分层白名单：data/tier-s-slugs.yaml 74 条 + slug.py 模块 + load.py 重构；ADR-011 accepted；26 new tests → 218 pipeline tests + 3 DB invariant；零 DB 变更；零 URL 变更；3 commits）
- 2026-04-19：T-P1-004 closed — NER 单人多 primary 约束（ADR-012 三层防御：NER prompt v1-r3 + load.py _enforce_single_primary auto-demotion + QC ner.single_primary_per_person；共享 is_di_honorific；32 new tests → 250 pipeline tests；零 DB 变更；4 commits；tip a50c2f9）
- 2026-04-19：CI 基建修复 — 堵上 pipeline SQL 迁移在 CI 未应用的漏洞（person_merge_log 不存在触发 #76/#77 红灯），ci.yml 新增 Step 4c 按文件名顺序 psql -f 跑 `services/pipeline/migrations/*.sql`；`test_slug_count_sanity` 加 `pytest.skip()` 兜底空 DB 环境（#78 红灯修复）；2 commits（b55beb8 + 0a4aa78）；#79 全绿；T-P1-004 rebase 上推 #80 全绿；衍生债 T-P1-005 registered
- 2026-04-19：T-P0-022 + T-P0-020 合并 sprint（F10 demote 8 行 + persons CHECK 约束 + ADR-010 supplement；tip 9a19140）
- 2026-04-19：T-P0-016 sprint（双路径 is_primary 同步 + backfill 18→0 + V6 invariant + F12 debt；tip 7566916）
- 2026-04-19：V1-V6 全套 invariant 首次集体绿；CI run #24629863280 全绿

---

## 技术债索引

### ~~T-P1-002: merge 后 person_names 的 nameType 未降级 + 重复名未去重~~ — **closed 2026-04-19**

- **修复**：方向 C（混合）— 写端 backfill 17 行 primary→alias + resolve.py apply_merges() 自动降级；读端 findPersonNamesWithMerged() 按 name 文本去重（4 级排序：canonical-side → merge_at DESC → source_evidence_id → created_at）
- **结果**：19 canonical 多 primary → 0；11 对跨 person_id 重复由读端兜住；UNIQUE (person_id, name) 约束已添加
- **已知 tradeoff**：T-P0-015 帝鸿氏 alias 的 source_evidence_id 被 canonical-side null 行遮挡（dedup 规则 a 击穿规则 c 的副作用），非 bug

### ~~T-P1-004: NER 阶段单人多 primary 约束~~ — **closed 2026-04-19**

- **修复**：ADR-012 三层防御 — NER prompt v1-r3 单 primary 约束 + load.py `_enforce_single_primary()` auto-demotion + QC 规则 `ner.single_primary_per_person`
- **结果**：single-primary 成为管线不变量；共享 `is_di_honorific()` 帝X 检测；32 new tests；零 DB 变更
- **衍生**：无（DB partial unique index 评估后决定不加，ingest 两层防御足够）

### ~~T-P1-003: pg_trgm 搜索对"帝X"类查询召回过宽~~ — **closed 2026-04-19**

- **修复**：length-weighted similarity threshold（≤2 chars: 0.5, 3 chars: 0.4, 4+ chars: 0.3）+ aliasSubstringSearch fallback
- **结果**：F1 95.6%→100%，3 disallowed violations→0，30 条黄金集全部通过

### ~~T-P2-002: persons.slug 命名不一致~~ — **closed 2026-04-19**

- **修复**：方向 3（分层白名单）— Tier-S 人物用 pinyin slug（74 条白名单 `data/tier-s-slugs.yaml`），其余用 unicode hex fallback
- **结果**：slug 规则明文化；`slug.py` 模块化生成；不变量测试 CI 保证；零 DB 变更；零 URL 变更
- **治理**：新增白名单条目必须附带 ADR/CHANGELOG 记录（ADR-011）

### T-P1-005: 统一 migration 入口（Drizzle + pipeline SQL 双轨合一）— **registered 2026-04-19**

- **现状**：`pnpm db:migrate` 只跑 Drizzle 迁移（`services/api/src/db-migrate.ts`）；pipeline 独占表（`person_merge_log`、`idx_persons_merged_into` 等）存活在 `services/pipeline/migrations/*.sql`，需手工 `psql -f` 应用
- **触发事件**：CI #76/#77 因 `person_merge_log does not exist` 红灯 — pipeline SQL 迁移在 CI 从未被应用，本地依赖手工执行掩盖了漏洞；临时通过 ci.yml Step 4c for-loop 应用修复（b55beb8）
- **问题**：两个入口 + 两种执行习惯 → 环境漂移（local dev / CI / prod 可能各异）；db:reset 无法保证全量 schema
- **修复候选**：
  1. `pnpm db:migrate` 脚本末尾追加 pipeline SQL 应用步骤（简单、显式）
  2. 迁移 pipeline SQL → Drizzle 管理（需把 `person_merge_log` 等搬入 Drizzle schema，但破坏"pipeline 独占"边界）
  3. 引入统一 migration runner（如 sqitch/flyway）同时管理两侧（重）
- **建议**：方向 1（追加步骤）+ 保留 pipeline SQL 作为幂等补丁源
- **影响**：本地 `pnpm db:reset` / `db:migrate` 全量正确；CI Step 4c 可退化为 `pnpm db:migrate` 一句；新人 onboarding 不再踩手工 psql 坑
- **优先级**：P1 — 不阻塞 β 路线，但 T-P0-006（扩量跑）开始前建议闭环
