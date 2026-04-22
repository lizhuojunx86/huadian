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
| T-P0-012 | Web 首页 + 全局导航（/ + /about + Header/Footer） | **done** | 前端 + 后端 | Phase 0 |
| T-P0-013 | Canonical 选择算法优化（帝X 前缀偏差） | **done** | 管线 | Phase 0 |
| T-P0-014 | 冗余实体 soft-delete（姒氏/昆吾氏/羲氏/和氏/荤粥） | **done** | 管线 + historian | Phase 0 |
| T-P0-005a | SigNoz 版本对齐与接入 | **planned** | DevOps + 管线 | Phase 0 |
| T-P0-019 | [β 尾巴清理](T-P0-019-beta-tail-cleanup.md)（F1/F2/F4 合并） | **planned** | 管线 | Phase 0 |
| T-P0-021 | [NER 输出持久化](T-P0-021-ner-output-persistence.md)（F9 JSONL 落盘 + replay） | **planned** | 管线 | Phase 0 |
| T-P0-023 | [Evidence 链 Stage 1（新行必填 + 段落粒度）](T-P0-023-evidence-chain-stage-1.md) | **planned** | 管线 + 后端 | Phase 0 |
| T-P0-024 | [Evidence 链 Stage 2（存量 text-search 回填）](T-P0-024-evidence-chain-stage-2-backfill.md) | **planned** | 管线 + historian | Phase 0 |
| T-P1-005 | 统一 migration 入口（Drizzle + pipeline SQL 双轨合一） | **planned** | DevOps + 后端 | Phase 1 |
| T-P0-027 | Resolver orchestration（R1-R6 全集成主调度） | **planned** | 管线 + 架构师 | Phase 0/1 桥接 |
| T-P0-028 | Manual triage UI for pending_review mappings | **planned** | 管线 + 历史专家 + 前端 | Phase 0 tail |

## 已完成
| 任务 ID | 标题 | 完成日期 | 主导角色 |
|---------|------|---------|---------|
| T-P0-016 | apply_merges + load.py W1 双路径 is_primary 同步（F5/F11 根治；backfill 18 行；V6 上线；首次 V1-V6 全绿） | 2026-04-19 | 管线 |
| T-P0-022 | α 源 primary 未 demote（F10 扫描 + 补丁；8 行 name_type primary→alias；V1-V5 PASS） | 2026-04-19 | 管线 |
| T-P0-020 | persons CHECK 约束（F3/F4 根治；单向蕴涵 `persons_merge_requires_delete`；Drizzle 同步；V1-V5 PASS） | 2026-04-19 | 后端 + 管线 |
| T-P0-006-β | [《尚书·尧典+舜典》摄入](T-P0-006-beta-shangshu.md)（β 跨书归并压力测试；R3 tongjia 端到端 ✅；ADR-013/014；153 active persons；$0.28；11 followup debts） | 2026-04-19 | 管线 + historian + 架构师 |
| T-P1-004 | NER 单人多 primary 约束（ADR-012 三层防御：prompt + ingest + QC；32 tests；4 commits；tip a50c2f9） | 2026-04-19 | 管线 + QA |
| T-P2-002 | persons.slug 命名一致性（方向 3 分层白名单：tier-s-slugs.yaml 74 条 + slug.py + ADR-011；26 tests + 3 invariant） | 2026-04-19 | 管线 + 后端 |
| T-P1-002 | person_names 降级+去重+UNIQUE（方向 C 混合：backfill 17 行 + resolve.py demote + 读端 dedup；9 tests） | 2026-04-19 | 管线 + 后端 |
| T-P0-015 | 帝鸿氏/缙云氏 Canonical 归并裁决（(c) 混合：帝鸿氏 MERGE R4 + 缙云氏 KEEP；152→151 persons） | 2026-04-19 | historian + 管线 |
| T-P1-003 | 搜索召回精度调优（length-weighted threshold + alias fallback；F1 95.6%→100%；7 tests） | 2026-04-19 | 后端 + QA |
| T-P0-014 | 非人实体清理（is_likely_non_person 规则 + HONORIFIC_SHI_WHITELIST；5 soft-deleted 157→152；22 tests） | 2026-04-19 | 管线 + historian |
| T-P0-013 | Canonical 选择算法优化（has_di_prefix_peer 惩罚项；1 组反转帝中丁→中丁；11 tests） | 2026-04-18 | 管线 |
| T-P0-012 | Web 首页 + 全局导航（Header/Footer + Hero + FeaturedPersonCard + Stats API + /about + SEO；17 tests + 3 E2E；7 commits） | 2026-04-18 | 前端 + 后端 |
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
- T-P0-025b TIER-4 self-curated seed patch（task card 已落地，backlog）
- T-P0-027 Resolver orchestration（Sprint C 主线，task card stub 已立，待 Stage 0 brief）
- T-P0-028 pending_review triage UI（Sprint C 候选独立 track，task card stub 已立）
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
