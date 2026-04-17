# 华典智谱 · 项目状态板

> **本文件是项目的"现在时刻"快照，每次会话开始 / 结束都应阅读或更新。**

- **最近更新**：2026-04-17
- **更新人**：后端工程师（Claude Opus）
- **当前阶段**：Phase 0 — **DB Schema ✅ + 字典批次 1 ✅ + TraceGuard Adapter ✅ + GraphQL 骨架 ✅；API Person Query / LLM Gateway 待启动**

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

无。等待用户选择下一任务。

---

## 下一步候选（按建议优先级）

| 优先级 | 任务 ID | 描述 | 主导角色 | 依赖 |
|--------|---------|------|---------|------|
| 🔴 高 | T-P0-005 | LLM Gateway + TraceGuard 基础集成 | 管线工程师 | T-P0-002 ✅ / T-TG-002 ✅ |
| 🔴 高 | T-P0-007 | API MVP：person query（首个真实 resolver） | 后端工程师 | T-P0-003 ✅ |
| 🟡 中 | T-P0-005a | SigNoz 版本对齐与接入 | DevOps + 管线 | T-P0-005 |
| 🟡 中 | T-P0-004 批次 2 | 字典扩展（秦汉二线人物 + 更多封国/战役地 + 10 父级郡国 slug 补齐） | 历史专家 | T-P0-004 批次 1 ✅ / 可选启动 |
| 🟢 低 | T-P0-006 | Pipeline MVP：鸿门宴 NER（前置：T-P0-006 加载器须吸收 _NOTES.md TODO-001） | 管线工程师 | T-P0-005 + T-P0-004 批次 1 ✅ |

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

---

## 健康度指标

- 📘 文档覆盖度：核心 7/7 ✅
- 🧭 ADR 数量：7 accepted / 9 planned
- 📋 任务卡数量：T-P0-001 done；T-P0-002 done；T-P0-003 done；T-P0-004 批次 1 done；T-TG-002 done；T-P0-005a planned
- 👥 Agent 角色定义：10/10 ✅
- 🏗️ 子包 build：10/10 全绿
- 🐳 Docker：PG + Redis 健康；33 张表 migrate 成功；SigNoz deferred；端口约定 5433/6380
- 📚 字典种子：185 条（polities 5 / reign_eras 89 / disamb 26 / persons 40 / places 25）@ 0.1.0-draft 静躺待 T-P0-006 加载
- 🧪 测试覆盖：82 passed（qc/：契约 8 + 规则 30 + policy 22 + audit 10 + replay 12）
- 🚦 阻塞项数量：0 ✅

---

## 更新日志（STATUS 文件本身的）

- 2026-04-15：初始化
- 2026-04-15：T-001 / T-002 / T-003 / T-TG-001 完成
- 2026-04-15：ADR-007 accepted；T-P0-001 ready
- 2026-04-15：T-P0-001 done — Monorepo 骨架落地；SigNoz deferred to T-P0-005a；T-P0-002 进入 ready
- 2026-04-16：T-P0-002 done — DB Schema 落地（33 表 + Drizzle 迁移 + shared-types + ADR-005 errata）
- 2026-04-16：T-P0-004 批次 1 done — 字典种子 185 条（polities/reign_eras/disamb/persons/places）+ _NOTES.md（5 裁决 + 5 约束 + TODO-001）
- 2026-04-17：T-TG-002 done — TraceGuard Adapter 实现（Port/Adapter + 5 rules + policy + audit + replay；82 tests；6 commits）
- 2026-04-17：T-P0-003 done — GraphQL schema 骨架（12 entity types + Traceable + 5 Query + codegen + CI graphql:breaking；6 commits）
