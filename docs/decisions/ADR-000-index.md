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
| [ADR-022](ADR-022-ner-pollution-cleanup-principle.md) | NER 污染清理 vs Names-Stay 判定准则（三要素 AND：evidence 零依赖 + 非合法名语义 + FK 零引用 → 硬 DELETE + pg_dump anchor） | 2026-04-21 | 架构师 + 管线工程师 |
| [ADR-023](ADR-023-v8-prefix-containment-invariant.md) | V8 Invariant 引入：Prefix-Containment 检测（length=1 名 + 跨 person 前缀包含 → 违反；α evidence-backed 或 β alias-typed → 豁免） | 2026-04-21 | 架构师 + 管线工程师 |
| [ADR-024](ADR-024-v9-at-least-one-primary-invariant.md) | V9 Invariant：At-Least-One-Primary 下界检查（2026-07-16 审计发现本行缺失于索引，补回） | 2026-04 | 架构师 |
| [ADR-025](ADR-025-r-rule-pair-guards.md) | R Rule Pair Guards：通用 pair-level guard 接口（evaluate_pair_guards rule-aware；R1=200yr / R6=500yr cross_dynasty_guard 阈值；deprecated wrapper 保留至 Sprint I） | 2026-04-26 | 架构师 + 管线工程师 |
| [ADR-026](ADR-026-entity-split-protocol.md) | Entity Split Protocol：mention-level redirect 例外授权（ADR-014 supplement；person_names UPDATE/INSERT 双授权；entity_split_log migration 0013；split_for_safety 子场景；双签 + 4 闸门 + dry-run + pg_dump anchor + 单事务） | 2026-04-27 | 架构师 + 管线工程师 + 历史专家 |
| [ADR-027](ADR-027-pending-triage-ui-workflow-protocol.md) | Pending Triage UI Workflow Protocol（triage_decisions 表 migration 0014 + GraphQL interface TriageItem + 2 implements + 4 queries + 1 mutation；URL token + cookie auth；inbox V1 必须；historical markdown backfill V1 必须；merge 铁律继承条款明文授权范围） | 2026-04-29 | 架构师 + Backend / Frontend / Pipeline / Historian 工程师 |
| [ADR-028](ADR-028-strategic-pivot-to-methodology.md) | 战略转型：全栈知识产品 → 方法论框架（D-route / 4-Layer）— accepted；"核心交付物"表述 2026-07-16 由 ADR-041 修订 | 2026-04-29 | 架构师 + 用户 |
| [ADR-029](ADR-029-licensing-policy.md) | 开源许可证策略：代码 Apache 2.0 / 数据·文档·方法论 CC BY 4.0 | 2026-04-29 | 架构师 + 用户 |
| [ADR-030](ADR-030-v0.3-release-timing-decision.md) | framework v0.3 release 时点决策（选项 B / 6 触发条件） | 2026-04-30 | 架构师 + 用户 |
| [ADR-031](ADR-031-v1.0-release-candidate-agenda-evaluation.md) | framework v1.0 候选议程评估（7 触发条件；v0.1 release 锚 2026-07-16 由 ADR-041 A3 加触发门） | 2026-04-30 | 架构师 + 用户 |
| [ADR-032](ADR-032-audit-triage-cross-stack-abstraction-retroactive.md) | audit_triage 跨栈抽象决策（首个 retroactive ADR） | 2026-04-30 | 架构师 |
| [ADR-033](ADR-033-case-2-schema-v0.2-incoming-qc-subchannels.md) | Case-2 Schema v0.2：incoming_qc 纳入 + 下限指标子通道 | 2026-05-10 | 架构师 + 用户 |
| [ADR-034](ADR-034-case-2-schema-v0.3-multi-class-subchannels-and-P11.md) | Case-2 Schema v0.3：dual_limit 子通道 6 类 + P11 + 三维交互 + 时间维度 | 2026-05-10 | 架构师 + 用户 |
| [ADR-035](ADR-035-case-2-schema-v0.4-F004-finalization-and-F001-v0.4-lock.md) | Case-2 Schema v0.4：F-004 lock + F-001 三层精细化 + cross_form/cross_product scope（C-5/6/9 押后 v0.5） | 2026-05-15 | 架构师 + 用户 |
| [ADR-036](ADR-036-case-3-dao-de-jing-candidacy-evaluation.md) | Case-3 候选评估：《道德经》是否应作为第三个跨领域案例 — 登记为条件触发候选（不立即开案例 / 5 条触发条件 / 思想实验路径替代 / F-001 跨域映射保留） | 2026-05-17 | 架构师 + 用户 |
| [ADR-037](ADR-037-framework-package-naming.md) | 框架包命名（L1 distribution name）— **accepted**：`kb-forge`（web 核实无占用）/ 补 D-route §5 悬空命名判据（误指 ADR-029）/ import root `framework.*`→`kb_forge.*` 改名延到 v0.1 前 | 2026-06-07 | 架构师 + 用户 |
| [ADR-038](ADR-038-shiji-extension-milestone-superseded-by-case-2.md) | 2026-08 史记延伸级里程碑由 case-2 顶替 — **accepted**：消除 §4 Sunset 与 §6/roadmap §2 矛盾 / 史记重定义为冻结 dogfood 底物 / storyextractor 下游证据（消费模式非数据）/ 已改 §6 + roadmap | 2026-06-07 | 架构师 + 用户 |
| [ADR-039](ADR-039-l1-unfreeze-import-rename-and-criterion-redefinition.md) | L1 解冻 — **accepted**：① 解冻 ADR-037 defer，批准 import-root `framework.*`→`kb_forge.*` 改名（执行 gated 待用户对 §3 影响面给令 / 红线 #1·#3）② 领域无关判据从失真的"≥70% LOC"重定义为"core+tests 0 领域字样 + ≥2 domain 隔离"（现 1/2 🟡）| 2026-06-20 | 架构师 + 用户 |
| [ADR-040](ADR-040-retroactive-privacy-desensitization-program.md) | case-2 脱敏工程追认 + 二次收口 + 防回流机制 — **accepted (retroactive)**：追认 6 月脱敏五项决策（止血/假名化/filter-repo/re-public 闸/映射不落盘）；audit-2026-07-16 证伪"终验 0 命中"与"映射不落盘"→ 二次假名化 43 处 + 二次历史重写（当日执行完毕，见执行注）+ 终验升级为人员字段全枚举 + pre-commit 隐私 guard | 2026-07-16 | 架构师 + 用户 |
| [ADR-041](ADR-041-portfolio-alignment-and-dual-proposition-governance.md) | 组合档位对齐 + 双命题治理 — **accepted**：huadian 落档"声誉公共品 + 方法论兵工厂"（同步 2026-07-06 仓外裁定）；P1 KE 框架 / P2 制药数据完整性双命题正式宣告 + 离巢判据；kb_forge v0.1 release 锚冻结为"首个真实外部使用者"触发制；ADR-028 核心交付物表述修订；负空间季度重审 | 2026-07-16 | 架构师 + 用户 |
| [ADR-042](ADR-042-identity-inference-residual-risk-acceptance.md) | case-2 身份反推残余风险显式接受 — **accepted**：三路径×三受众枚举（R1 履历关联=接受+措辞缓解 / R2 数据指纹=接受、裁剪候选留决 / R3 残留人名=已消除）；承诺降级为"对公众不可识别/圈内低成本可推"；前雇主应对预案；闭环 case-2 strategy §7 OQ4 | 2026-07-16 | 架构师 + 用户 |
| [ADR-043](ADR-043-constitution-v1.2-and-quarterly-independent-audit.md) | 宪法 v1.2 修订 + 季度独立审计机制 — **accepted**：C-17 任务载体泛化（合法化 sprint brief 清单 + GO-* 日志）；C-9/C-21 挂起状态注 + C-11 ADR-017 等价实现注；独立审计季度化（runbook + 判据重定义必查 + 云端例行提醒） | 2026-07-17 | 架构师 + 用户 |

> 注：2026-07-16 审计整改——ADR-024 与 ADR-028~035 已全部补回本索引（原 backfill 债清零）。

### 已提议（待签字）

（暂无）

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
