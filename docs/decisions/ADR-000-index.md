# ADR 索引 (Architecture Decision Records)

> 本目录记录华典智谱所有重要架构决策。
> 命名规则：`ADR-NNN-kebab-title.md`
> 状态枚举：`proposed / accepted / deprecated / superseded`
> 一旦提交不修改原内容；变更用新 ADR 标注 `supersedes`。

---

## 索引

### 已接受

| # | 标题 | 日期 | 决策人 |
|---|------|------|--------|
| [ADR-001](ADR-001-single-postgresql.md) | 单 PostgreSQL 数据库策略（含切出触发器） | 2026-04-15 | 架构师 |
| [ADR-002](ADR-002-event-account-split.md) | 事件双层建模（Event + EventAccount） | 2026-04-15 | 架构师 + 历史专家 |
| [ADR-003](ADR-003-multi-role-framework.md) | 多角色协作框架启用 | 2026-04-15 | 用户 + 架构师 |
| [ADR-004](ADR-004-traceguard-integration-contract.md) | TraceGuard 集成合同（Port/Adapter） | 2026-04-15 | 架构师（用户授权）|
| [ADR-005](ADR-005-embedding-multi-slot.md) | Embedding 多槽位与模型切换策略 | 2026-04-15 | 架构师 |
| [ADR-006](ADR-006-undecided-items-closure.md) | 未决项 U-01~U-07 封版决策 | 2026-04-15 | PM + 历史专家 + DevOps（用户授权）|
| [ADR-007](ADR-007-monorepo-layout.md) | Monorepo 布局与包管理（pnpm + uv + Turborepo） | 2026-04-15 | DevOps 提议 / 架构师签字 |
| [ADR-008](ADR-008-license-policy.md) | License 策略（GraphQL Book.license 规范化 + Workspace 包 license） | 2026-04-17 | 后端提议 / 架构师裁决 |
| [ADR-009](ADR-009-person-source-evidence-traceability.md) | Person sourceEvidenceId Traceability — Traceable 接口 nullable 放宽 | 2026-04-17 | 架构师（T-P0-007 Q-5 裁决） |
| [ADR-010](ADR-010-cross-chunk-identity-resolution.md) | Cross-Chunk Identity Resolution — 规则引擎 + soft merge | 2026-04-18 | 架构师 + 管线 + 历史专家 |
| [ADR-011](ADR-011-slug-naming-scheme.md) | Person Slug Naming Scheme — Tiered Whitelist（方向 3：Tier-S pinyin + unicode fallback） | 2026-04-19 | 用户 + 管线 + 后端 |
| [ADR-012](ADR-012-ner-single-primary-constraint.md) | NER Single-Primary Constraint — 三层防御（prompt + ingest auto-demotion + QC rule） | 2026-04-19 | 用户 + 管线 |
| [ADR-013](ADR-013-persons-slug-partial-unique.md) | persons.slug UNIQUE 约束改为 partial（排除 soft-deleted） | 2026-04-19 | 架构师 |
| [ADR-014](ADR-014-canonical-merge-execution-model.md) | Canonical Merge Execution Model（names-stay + read-side aggregation） | 2026-04-19 | 架构师 |
| [ADR-015](ADR-015-evidence-chain-fill-plan.md) | Evidence 链填充方案（staged activation + paragraph-level Stage 1） | 2026-04-19 | 架构师 |
| [ADR-017](ADR-017-migration-rollback-strategy.md) | Migration Rollback Strategy（forward-only + pg_dump anchor + 4 闸门） | 2026-04-19 | 架构师 |
| [ADR-021](ADR-021-dictionary-seed-strategy.md) | Dictionary Seed Strategy（open-data-first, Wikidata 作为唯一 TIER-1 源；CBDB 因 CC BY-NC-SA 延后） | 2026-04-21 | 架构师 |

### 已规划（尚未起草）

| # | 标题 | 状态 | 优先级 | 负责人 |
|---|------|------|--------|--------|
| ~~ADR-015~~ | ~~Evidence 链填充方案~~ | **accepted** | — | **见 accepted 区** |
| ADR-016 | 搜索召回策略回溯 | planned | 🟡 | 后端 + 架构师 |
| ADR-018 | extractions_history 违规处置（C-11 专项） | planned | 🔴 | 架构师 + 管线 |
| ~~ADR-017~~ | ~~迁移回滚策略（forward-only + pg_dump anchor）~~ | **accepted** | — | **见 accepted 区** |
| ~~ADR-018~~ | ~~Slug 规则与 URL 稳定性~~ | ~~planned~~ | — | **covered by ADR-011** |
| ADR-019 | 多语言字段 JSONB 结构 | planned | 🟡 | 架构师 + 前端 |
| ADR-020 | Prompt 版本化与缓存键 | planned | 🟡 | 管线 |

### 已废弃 / 已被取代

（暂无）

### 已重新分配编号的旧主题

以下主题曾预分配 ADR 编号，但编号已被其他 accepted ADR 占用。未来启动时需重新分配编号。

- ~~ADR-015 Identity Hypotheses~~ — 身份多假设候选机制；编号已占用；未来启动时需重新分配（当前 identity_resolver 单候选机制够用，见 ADR-010）
- ~~ADR-016 软删除策略~~ — 软删除的级联规则（FK / cache / search index）；编号已占用；ADR-013 已解决 slug 冲突子问题，完整级联策略未来需新 ADR
- ~~ADR-017 GraphQL schema 演进策略~~ — breaking change / deprecation / versioning 规范；编号已占用；CI `graphql:breaking` 暂作过渡手段，未来需新 ADR

> 旧 ADR-012（地理模糊性建模）/ ADR-013（历法与年号多政权建模）/ ADR-014（Mentions 表 vs Evidence_links 职责切分）同理，编号已被占用，主题保留但暂无新编号。

---

<!-- 2026-04-19 sync: ADR-012/013/014 落盘后清理。将三者从 planned 移入 accepted，planned 区重填 ADR-015/016/017 新主题，旧主题列入「已重新分配编号」小节。 -->

## 模板

新增 ADR 时拷贝 `docs/04_工作流与进度机制.md §二` 中的模板。
