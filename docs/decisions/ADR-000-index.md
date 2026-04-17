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

### 已规划（尚未起草）

| # | 标题 | 状态 | 优先级 | 负责人 |
|---|------|------|--------|--------|
| ADR-009 | Slug 规则与 URL 稳定性 | planned | 🟡 | 架构师 + 历史专家 |
| ADR-010 | 多语言字段 JSONB 结构 | planned | 🟡 | 架构师 + 前端 |
| ADR-011 | Prompt 版本化与缓存键 | planned | 🟡 | 管线 |
| ADR-012 | 地理模糊性建模（Point/Line/Polygon + fuzziness） | planned | 🟢 | 架构师 + 历史专家 |
| ADR-013 | 历法与年号多政权建模 | planned | 🟢 | 历史专家 + 架构师 |
| ADR-014 | Mentions 表 vs Evidence_links 的职责切分 | planned | 🟢 | 架构师 |
| ADR-015 | Identity Hypotheses 表达机制 | planned | 🟢 | 历史专家 + 架构师 |
| ADR-016 | 软删除与修订审计策略 | planned | 🟢 | 架构师 + DevOps |
| ADR-017 | GraphQL schema 演进与废弃策略 | planned | 🟡 | 后端 + 架构师 |

### 已废弃 / 已被取代

（暂无）

---

## 模板

新增 ADR 时拷贝 `docs/04_工作流与进度机制.md §二` 中的模板。
