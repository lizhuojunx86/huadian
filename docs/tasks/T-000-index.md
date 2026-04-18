# 任务卡索引

> 本目录记录华典智谱所有任务卡。
> 命名规则：`T-NNN-kebab-title.md`
> 状态枚举：`pending / in_progress / review / done / blocked / cancelled`
> 模板见 `docs/04_工作流与进度机制.md §三`

---

## 当前活跃任务

| 任务 ID | 标题 | 状态 | 主导角色 | 所属 Phase |
|---------|------|------|---------|-----------|
| T-TG-002-F6 | Drizzle schema 同步（traceguard_raw + UNIQUE INDEX + 列注释） | **backlog** | 后端 + DevOps | Phase 0 |
| T-P0-007 | API MVP：person query（首个真实 resolver） | **done** | 后端工程师 | Phase 0 |
| T-P0-009 | Web 人物搜索/列表页（/persons search + list） | **done** | 前端 + 后端 | Phase 0 |
| T-P0-008 | Web MVP：人物卡片页（/persons/[slug]） | **done** | 前端工程师 | Phase 0 |
| T-P0-003-F1 | License 字段规范化（GraphQL enum 连字符 + package.json license） | **backlog** | 后端 + 架构师 | Phase 0 |
| T-P0-010 | Pipeline 基础设施 + 真书 Pilot（史记·本纪前 3 篇） | **done** | 管线 + 历史专家 | Phase 0 |
| T-P0-011 | 跨 chunk 身份消歧（identity_resolver） | **done** | 管线 + 架构师 + historian | Phase 0 |
| T-P0-012 | 冗余实体 soft-delete（姒氏/昆吾氏/羲氏/和氏/荤粥） | **planned** | 管线 + historian | Phase 0 |
| T-P0-013 | Canonical 选择算法优化（帝X 前缀偏差） | **planned** | 管线 | Phase 0 |
| T-P0-005a | SigNoz 版本对齐与接入 | **planned** | DevOps + 管线 | Phase 0 |

## 已完成
| 任务 ID | 标题 | 完成日期 | 主导角色 |
|---------|------|---------|---------|
| T-P0-011 | 跨 chunk 身份消歧（ADR-010 + identity_resolver + API resolveCanonical；11 组合并 169→157；6 commits） | 2026-04-18 | 架构师 + 管线 + historian |
| T-P0-010 | Pipeline 基础设施 + 真书 Pilot（8 模块 + 3 books / 169 persons / $1.77 / 14 commits） | 2026-04-18 | 管线 + 历史专家 | Phase 0 |
| T-P0-009 | Web 人物搜索/列表页（SDL PersonSearchResult + pg_trgm + /persons + 28 tests + 2 E2E） | 2026-04-18 | 前端 + 后端 | Phase 0 |
| T-P0-008 | Web MVP：人物卡片页（Tailwind + shadcn + codegen + 4 组件 + 23 tests + 2 E2E） | 2026-04-18 | 前端工程师 | Phase 0 |
| T-P0-007 | API MVP：person query（person/persons resolver + service + 31 tests） | 2026-04-18 | 后端工程师 | Phase 0 |
| T-P0-005 | LLM Gateway + TraceGuard 基础集成（ai/ 子包 + anthropic SDK + 46 tests） | 2026-04-17 | 管线工程师 | Phase 0 |
| T-P0-003 | GraphQL schema 骨架（12 types + Traceable + 5 Query + codegen + CI graphql:breaking） | 2026-04-17 | 后端工程师 | Phase 0 |
| T-TG-002 | TraceGuard Adapter 实现（Port/Adapter + 5 rules + policy + audit + replay；82 tests） | 2026-04-17 | 管线工程师 | Phase 0 |
| T-P0-004（批次 1） | 历史专家字典初稿（185 条：polities 5 / reign_eras 89 / disamb 26 / persons 40 / places 25） | 2026-04-16 | 历史专家 | Phase 0 |
| T-P0-002 | DB Schema 落地（33 表 Drizzle + 迁移） | 2026-04-16 | 后端工程师 | Phase 0 |
| T-P0-001 | Monorepo 骨架落地 | 2026-04-15 | DevOps | Phase 0 |
| T-TG-001 | TraceGuard 7 问封版（ADR-004） | 2026-04-15 | 架构师 |
| T-003 | U-01~U-07 未决项封版 | 2026-04-15 | 架构师代决 |
| T-002 | 首批 ADR-001~ADR-006 落地 | 2026-04-15 | 架构师 |
| T-001 | 补齐 10 个 agent 角色定义 | 2026-04-15 | 架构师 |
| T-000 | 用户审阅 docs/00~06 架构文档并签收 | 2026-04-15 | 用户 |

## 已规划（待签收后创建任务卡）

### Phase 0 — 地基
- ~~T-P0-001 Monorepo 骨架（DevOps + 后端）~~ ✅ done
- ~~T-P0-002 DB Schema 落地（后端）~~ ✅ done
- ~~T-P0-003 GraphQL schema 骨架（后端）~~ ✅ done（2026-04-17）
- ~~T-P0-004 历史专家字典初稿 批次 1（历史专家）~~ ✅ done（2026-04-16）
- T-P0-004 批次 2 字典扩展（秦汉二线人物 + 封国/战役地 + 10 父级郡国 slug 补齐）← 可选，不阻塞
- ~~T-P0-005 LLM Gateway + TraceGuard 集成（管线）~~ ✅ done（2026-04-17）
- T-P0-005a SigNoz 版本对齐与接入（DevOps + 管线）← 从 T-P0-001 拆出
- ~~T-TG-002 TraceGuard Adapter 实现（管线）~~ ✅ done（2026-04-17）
- T-TG-002-F6 Drizzle schema 同步（后端 + DevOps）← backlog，不阻塞
- T-P0-006 Pipeline MVP：鸿门宴 NER（管线）
- ~~T-P0-007 API MVP：person query（后端）~~ ✅ done（2026-04-18）
- ~~T-P0-008 Web MVP：人物卡片页（前端）~~ ✅ done（2026-04-18）
- T-P0-009 Docker Compose 一键启动验证（DevOps）
- T-P0-010 端到端验收（QA）

### Phase 1 — 已规划
- T-P1-XXX 真正的 ctext.org API adapter（替换 Phase 0 硬编码 fixtures）

### 质检 / 监控（横向，穿插各 Phase）
- T-QC-001 PG 约束与触发器
- T-QC-002 质检规则引擎脚手架
- T-QC-003 黄金集初始化
- T-AN-001 事件字典 + useAnalytics hook
- T-AN-002 analytics_events 表 + receiver
- T-AN-003 feedback 表 + QA 看板骨架
- T-OB-001 OpenTelemetry 接入
- T-OB-002 Sentry 接入

---

## 已阻塞 / 取消

（暂无）
