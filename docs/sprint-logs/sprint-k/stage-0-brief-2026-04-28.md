# Sprint K Brief — T-P0-028 Pending Review Triage UI（首跨三角 sprint）

## 0. 元信息

- **架构师**: Chief Architect
- **Brief 日期**: 2026-04-28
- **Sprint 形态**: 首个跨三角 sprint（Backend + Frontend + Pipeline + Historian + 架构师协同）
- **预估工时**: 5-7 天
- **任务卡**: T-P0-028（已延期 3 sprints，本卡正式启动）
- **MVP 路径**: 完整 MVP（16-24 周）下 triage UI 是 Phase 0 → Phase 1 桥梁，本卡是 Phase 0 tail 必经模块

## 1. 背景

Sprint G/H/I/J 累计产出两类 pending triage 数据，当前积压 60+ 条等 historian 决策：

| 数据源 | 表 | 当前数量 | 来源 sprint | 类型 |
|--------|-----|---------|------------|------|
| seed_mappings 待审 | `seed_mappings WHERE mapping_status='pending_review'` | ~50 条 | Sprint B 起累积 | TIER-4 self-curated mappings 待 historian 复核 |
| Guard 拦截 merge | `pending_merge_reviews WHERE status='pending'` | ~16 条 | Sprint H/I 起 | cross_dynasty / state_prefix / split_for_safety guard blocks |

当前 historian 唯一通道：直接 SELECT DB + 在 sprint-logs/historian-rulings/*.md 写 markdown 文件 + commit。**问题**：
- 工作流碎片化（每 sprint 单独裁决，不复用判定经验）
- 跨 sprint 同 surface 重复 reject（Sprint G/J historian 报告中 "秦γ 残留" 重复出现）
- Hist 无统一 dashboard 概览待办量
- 不可移交：手动 SELECT 路径要求 hist 懂 PostgreSQL，新 historian 无法快速接手

T-P0-028 目标：建立 historian 专用 triage UI，统一两类 pending 数据 + 持久化决策 + 审计追溯。

## 2. 范围（V1 scope）

### V1 必做
1. **统一 triage queue 视图**（GraphQL + UI）
   - 列出 pending_review 两源数据合并为单 queue
   - 按 guard_type / mapping_method / 创建时间分组
   - 卡片展示核心字段（surface form / 上下文 / 推荐决策）
2. **决策持久化**（per-item approve/reject/defer）
   - 写 `triage_decisions` 表（migration 0014 候选）
   - 关联 historian 标识（简化：URL token / X-User header / 配置项）
3. **审计 trail**
   - 每个决策记录历史决策者 + 时间 + 理由
   - 支持回滚（mark deferred → 可重审）
4. **Historian E2E 验证**
   - 真实 historian 用 UI triage 5-10 条历史 pending 数据
   - 验证决策正确持久化 + 下游可消费

### V1 不做
- ❌ 决策 → 自动 apply 下游操作（如 approve seed_mapping 不自动写 active；approve merge 不自动 soft-delete）—— 留 V2 / Sprint L
- ❌ 多用户并发冲突解决（单 historian 模型）
- ❌ 高级 UI（kanban / 分析 dashboard / bulk 操作）
- ❌ 真正 auth / SSO（简化 token）
- ❌ 跨 historian 协作 / approval workflow

### V2+ 候选（不在 Sprint K）
- approve seed_mapping → 自动 UPDATE status='active' + 触发 R6 prepass
- approve merge → 自动调 apply_merges() 路径
- bulk approve（同类型一次决策多条）
- historian 决策回放 / 数据分析

## 3. Stages

### Stage 0 — 联合 inventory + 设计（架构师 + 4 工程师 + Hist 共同 read 上下文，0.5 天）

各角色 inventory 任务：

**Backend**：
1. 当前 GraphQL schema 中 person / mention / source_evidence 类型现状
2. seed_mappings + pending_merge_reviews 表 Drizzle schema 完整字段
3. 现有 GraphQL queries 是否可复用（如 personById / mentionsByPerson）
4. 推荐：新建 `triageItem` union type 还是分开两 query

**Frontend**：
1. 现有 Next.js app 路由结构（/persons / /persons/[slug] / 首页）
2. 现有 shadcn/ui 组件库已用哪些（Card / Table / Button etc.）
3. 推荐：/triage 路由结构（/triage 列表 + /triage/[id] 详情？）
4. Tailwind / shadcn 是否需补新组件

**Pipeline**：
1. seed_mappings + pending_merge_reviews 当前实际数据采样（≥10 条各类型）
2. 决策"approve" 在 V1 仅 mark status，但下游 apply 路径设计要明确（V2 衔接点）
3. 评估：approve/reject/defer 后续是否影响现有 resolver / R6 prepass 路径

**Historian**：
1. 当前手工 triage 痛点列表（5-10 条具体 case）
2. 理想 UI 设计（列表 → 详情 → 决策 三步 vs 其他模式）
3. 重要 metadata 需求（哪些上下文字段对决策最关键）
4. E2E 验证愿景：能用 UI 完成什么场景

输出：docs/sprint-logs/sprint-k/inventory-2026-04-XX.md（共同文档，4 段各角色填）

### Stage 1 — 架构师设计 + ADR-027（如需）

1.1 基于 Stage 0 inventory，架构师产出：
- 数据模型设计（triage_decisions 表 schema + GraphQL union type）
- API 接口契约（queries / mutations / response shapes）
- UI 流程图（伪 wireframe，文字描述）
- Auth 简化方案（V1 用什么）
- migration 0014 草案（如需）

1.2 ADR-027 起草（候选标题："Pending Triage UI Workflow Protocol"）：
- 是否需要新 ADR？评估：
  - 如仅 schema + 标准 CRUD → 不需新 ADR（task card 即可）
  - 如涉及 auth 模型 / 跨表 union 抽象 / 持续性 hist 工作流变更 → 需 ADR
- 默认倾向：**起草 ADR-027**，因 historian 工作流是项目长期模式，需正式化

1.3 各角色签字：BE/FE 确认接口契约可实现 + Hist 确认 UI 流程符合需求 + PE 确认下游兼容

### Stage 2 — Backend 实施（BE 主导，可与 Stage 3 并行）

2.1 migration 0014: triage_decisions 表（如设计需要）+ Drizzle schema 同步
2.2 GraphQL schema 扩展：
- `TriageItem` union type（SeedMappingTriage | GuardBlockedMergeTriage）
- `Query.pendingTriageItems(limit, offset, filterByType)`
- `Mutation.recordTriageDecision(itemId, decision, reason, historianId)`
2.3 Service 层实现 + 单元测试 ≥5
2.4 GraphQL codegen 同步前端类型

### Stage 3 — Frontend 实施（FE 主导，与 Stage 2 并行）

3.1 /triage 路由 + 列表页（按 guard_type 分组 + 每条卡片）
3.2 /triage/[itemId] 详情页（上下文展示 + 决策 form）
3.3 决策提交 → GraphQL mutation
3.4 简化 auth（V1：URL `?historian=name` query param 或固定 token）
3.5 E2E test ≥2（覆盖主流程：查看 → 决策 → 验证持久化）

### Stage 4 — Pipeline 集成（PE，Stage 2 完成后）

4.1 评估：approve/reject/defer 是否需要触发 pipeline 端行为（V1 仅 status 变化，不触发；但需确认下游 query 路径不破坏）
4.2 单元测试：决策 status 变更后 resolver / R6 prepass 行为不变
4.3 文档：V1 → V2 演进清单（哪些决策类型在 V2 触发 auto-apply）

### Stage 5 — Historian E2E 验证（Hist）

5.1 真实 historian 启动 UI（PE 协助本地起服务）
5.2 用 UI triage 5-10 条 historical pending（来自 Sprint G/H/I/J 累积）
5.3 反馈记录到 docs/sprint-logs/sprint-k/historian-e2e-feedback-2026-04-XX.md
5.4 重大 UX 问题 → 立即修；微调登记 V1.1 / V2 follow-up

### Stage 6 — 收档

6.1 T-P0-028 task card done + Sprint K retro
6.2 STATUS / CHANGELOG
6.3 衍生债 stub（V2 candidates / UX 调整 / 性能优化）
6.4 Phase 0 graduation 评估（triage UI 上线后 Phase 0 还差什么？）

## 4. Stop Rules

1. **Stage 0 inventory 4 角色任一延误 > 0.5 天** → Stop，架构师协调
2. **Stage 1 ADR-027 设计与某角色 inventory 严重冲突**（如 FE 反映组件库不支持某 UI 流程）→ Stop 重设计
3. **Stage 2 GraphQL union type 引入 breaking change** → Stop，评估对前端既有页面影响
4. **Stage 3 E2E test 无法跑通**（环境问题 / shadcn 组件 bug）→ Stop，DevOps 协助
5. **Stage 4 V1 决策 status 变更影响现有 resolver / R6 prepass 路径** → Stop，回归 Stage 1 设计
6. **Stage 5 Historian E2E 反馈核心流程不可用** → Stop，Stage 3 修复后重 E2E
7. **任一 V invariant 回归** → Stop（决策 mutation 不应破坏现有数据约束）

## 5. 角色边界

| 角色 | 主导 Stage | 模型建议 |
|------|----------|---------|
| Backend Engineer (BE) | Stage 2 主导 / Stage 0 + 1 协同 | Opus（首次 GraphQL union 抽象） |
| Frontend Engineer (FE) | Stage 3 主导 / Stage 0 + 1 协同 | Opus（首跨三角 + Next.js + shadcn 复杂场景） |
| Pipeline Engineer (PE) | Stage 4 主导 / Stage 0 + 1 协同 | Sonnet（pattern 已稳） |
| Historian (Hist) | Stage 5 主导 / Stage 0 协同 | Opus（UX feedback 需要深度判断） |
| 架构师 | Stage 1 主导 + 各 stage 闸门 ACK + ADR-027 起草 | (Cowork 自身) |

## 6. 收口判定

- ✅ /triage UI 上线，列表 + 详情 + 决策 三层流程可用
- ✅ historian E2E 完成 5-10 条 triage decisions（数据持久化验证）
- ✅ migration 0014 + Drizzle schema sync + GraphQL codegen 链路完整
- ✅ V1-V11 全绿不回归
- ✅ ADR-027（如起草）落地
- ✅ V2 演进清单清晰（auto-apply 等延后功能 backlog 登记）
- ✅ Historian 反馈核心流程"可用"（V1 不要求"完美"，要求"可用 + 反馈通畅"）

## 7. 节奏建议（5-7 天总长）

**Day 1**：Stage 0 inventory（4 角色并行各自 inventory，半天完成；下午架构师汇总）
**Day 2**：Stage 1 架构师设计 + ADR-027 + 各角色签字
**Day 3-4**：Stage 2（BE）+ Stage 3（FE）并行
**Day 5**：Stage 4（PE 集成）+ 集成 smoke
**Day 6**：Stage 5 Historian E2E
**Day 7**：Stage 6 收档 + retro

并行 sessions：Stage 0 时 4 角色完全并行（4 session）；Stage 2-3 时 BE/FE 并行（2 session）；其他 stage 单 session。

## 8. Session 标签扩展

本 sprint 引入 4 个新 session 标签：
- 【BE】Backend Engineer
- 【FE】Frontend Engineer
- 【PE】Pipeline Engineer（既有）
- 【Hist】Historian（既有）

最多并行 4 session（Stage 0），常规 1-2 session（Stage 2-5）。

## 9. 衍生债预期

Sprint K 完成后预计产出 V2+ 候选：
- T-P0-028.V2 — 决策 → 自动 apply 下游（V1 仅 mark status）
- T-P0-028.V3 — bulk operations / 跨 historian 协作 / 分析 dashboard
- T-P1-XXX — auth / SSO 正式化（V1 简化 token）
- T-P0-028.UX — 基于 Historian E2E feedback 的 UI 调整

## 10. ADR 候选

ADR-027 候选标题："Pending Triage UI Workflow Protocol"
- 内容：triage_decisions 表 schema / GraphQL union 抽象 / historian sign-off 形式 / V1 → V2 演进路径
- 起草时机：Stage 1（架构师设计阶段）
- 关联 ADR：ADR-026（entity-split protocol，与本 ADR 都是 historian 工作流的 schema-level 契约）

## 11. Phase 0 Graduation 评估准备

Sprint K 是 Phase 0 tail 最后一块大模块。完成后架构师本侧应在 retro 中评估：
- Phase 0 还剩什么必经模块？
- Phase 1 启动条件 met 否？
- 完整 MVP 路径 Sprint K 后预计还有多少 sprint？

Phase 0 graduation 不在本 sprint scope，但 retro 段要为下一回合架构师本侧分析备料。
