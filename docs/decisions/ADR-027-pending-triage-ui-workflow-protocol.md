# ADR-027 — Pending Triage UI Workflow Protocol

- **Status**: accepted
- **Date**: 2026-04-29
- **Authors**: 首席架构师（起草）+ Backend / Frontend / Pipeline / Historian 工程师（Stage 0 inventory 联合输入）
- **Related**:
  - **ADR-014**（Canonical Merge Execution Model — names-stay 铁律）— 本 ADR §5 明文继承"merge 铁律"，V1/V2 都不允许 BE/FE 直接 SQL UPDATE persons
  - **ADR-021**（Dictionary Seed Strategy — TIER 分级）— pending_review seed_mappings 是 TIER-4 self-curated 的 historian 复核入口
  - **ADR-026**（Entity Split Protocol）— 同为 historian 工作流 schema-level 契约，本 ADR 沿用其"sprint-logs file + commit hash 双签"形式
  - T-P0-028（本 ADR 首应用）

---

## 1. Context

### 1.1 触发

Sprint G/H/I/J 累计两类 pending 数据，等 historian 决策：

| 数据源 | 当前数量 | 来源 sprint |
|--------|---------|------------|
| `seed_mappings WHERE mapping_status='pending_review'` | 45 条（DB 实际） | Sprint B 起累积 |
| `pending_merge_reviews WHERE status='pending'` | 0 条（DB 实际，Sprint K 补跑后预计 ~16 条） | Sprint H/I/J 起 |

**Stage 0 PE 调研发现**：apply_resolve.py 路径在 Sprint G/H/I/J 内容续推被旁路 → guard 拦截 candidate 未持久化进 pending_merge_reviews。本 ADR Stage 2 PE 工作含补跑脚本回灌真实数据（详 §9.1）。

### 1.2 现状痛点（Hist Stage 0 inventory §1，8 条）

Top 3：
1. **跨 sprint 重复审同 surface 簇**（判断疲劳 + 时间浪费 90-120min/sprint）— 周成王↔楚成王↔成 在 Sprint G/J/项羽δ 三连 reject，惠公/怀公/灵公族同样三连
2. **决策记录散落 4+ markdown**（跨 sprint 查阅靠 grep）
3. **context 不足时切多 SELECT 自查**（楚怀王 mention bucketing 需 4 次 SQL）

### 1.3 缺口

需要：
1. 统一 triage UI 入口（替代手 SQL）
2. 决策持久化 + 跨 sprint 查询能力（解决痛点 #1 hint banner / 痛点 #2 唯一时间线）
3. 详情页一站式 context 展示（解决痛点 #3）
4. ADR 授权 BE 服务直接写 triage_decisions（不属 ADR-014 merge 铁律范围；但需明文边界）

---

## 2. Decision

### 2.1 引入新表 `triage_decisions`

存储 historian 对 pending_review 数据的决策记录，**多值审计**（同 source_id 可有多条决策记录，用于 defer → 重审 → approve 的状态演进）。

Schema 详 §3。

### 2.2 GraphQL interface 抽象（不用 union）

```graphql
interface TriageItem implements Traceable { ... }
type SeedMappingTriage implements TriageItem & Traceable { ... }
type GuardBlockedMergeTriage implements TriageItem & Traceable { ... }
```

**理由**（vs union type）：
- interface 在 GraphQL 已有 __typename discriminator，前端 type narrow 可用
- V2 加新 triage 类型不需扩 union（只需 implements interface）
- 前端 switch on __typename 比 inline fragment 简洁

**TS 约束**：codegen 生成 discriminated interface，前端必须 select __typename + switch handler，未实现的类型 fallback 渲染。

### 2.3 Mutation 设计含 inbox hook

```graphql
input RecordTriageDecisionInput {
    itemId: ID!
    decision: TriageDecisionType!  # APPROVE | REJECT | DEFER
    reasonText: String
    reasonSourceType: String
    historianId: String!  # from auth cookie
}

type RecordTriageDecisionPayload {
    triageDecision: TriageDecision!
    nextPendingItemId: ID  # null if queue empty
}
```

**inbox 模式 V1 必须实现**（Hist 痛点 #1 解决依赖）。最小算法：
- 同 surface 簇（surface_snapshot match）优先
- fallback FIFO（pending_since ASC）
- 跨 type filter 不区分（V1 不分 SeedMapping/GuardBlockedMerge 类型限制）

### 2.4 Auth 简化（V1）

middleware-based URL token：
- 入口：`?historian=name` query param
- middleware (apps/web/middleware.ts) 写 30-day httpOnly cookie + strip query
- 后续 RSC / Server Action 用 `cookies()` 读
- `apps/web/lib/historian-allowlist.yaml` 硬编码 ≤10 个 historian id

**V2 升级路径**（不在本 ADR scope）：替换 middleware 实现为 SSO 集成，cookie 协议保持。

### 2.5 决策不直接触发下游（V1 零侵入）

**V1**：mutation 仅写 `triage_decisions` + 不变 source 表（既有 `seed_mappings.mapping_status` / `pending_merge_reviews.status` 不动）

**V2 hook**（不在本 ADR scope，仅预留）：
- triage_decisions 含 `downstream_applied` 字段
- PE 异步 job 周期扫 `WHERE downstream_applied=false AND decision='APPROVE'`
- approve seed_mapping → 触发 R6 prepass 重跑
- approve merge → 产生 candidate.json 走 ADR-014 4 闸门人工流程
- 推荐方案：PE 异步 job + 显式 endpoint，不用 PG NOTIFY (over-engineering)

### 2.6 Historian 历史 review markdown backfill（V1 必须）

Hint banner feature 数据基础。Stage 2 PE 实施 backfill 脚本：
- 解析 docs/sprint-logs/T-P0-006-*/historian-review-*.md
- 提取每条 ruling（group_id / decision / source_type / 一句理由 / commit hash）
- 关联 dry-run report group → DB row UUID
- INSERT triage_decisions 标 `historian_id='historical-backfill', historian_commit_ref=<commit hash>`

预计回灌 80-100 条历史决策，覆盖 Sprint G/H/I/J。

---

## 3. Schema：`triage_decisions`（migration 0014）

```sql
CREATE TABLE triage_decisions (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_table             TEXT NOT NULL,           -- 'seed_mappings' | 'pending_merge_reviews'
    source_id                UUID NOT NULL,           -- FK 不约束（避免 historical-backfill 跨表 FK 复杂度）
    surface_snapshot         TEXT NOT NULL,           -- 决策时的 surface text snapshot（防源 row 删除/修改）
    decision                 TEXT NOT NULL,           -- 'approve' | 'reject' | 'defer'
    reason_text              TEXT,                    -- 决策理由（markdown）
    reason_source_type       TEXT,                    -- 'in_chapter' | 'other_classical' | 'wikidata' | 'scholarly' | 'structural' | 'historical-backfill'
    historian_id             TEXT NOT NULL,           -- 决策者 id
    historian_commit_ref     TEXT,                    -- 引用的 historian-review commit hash（如 backfill 或交叉引用）
    architect_ack_ref        TEXT,                    -- 架构师 inline ACK commit hash（如适用）
    decided_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
    downstream_applied       BOOLEAN NOT NULL DEFAULT false,  -- V2 hook 字段
    downstream_applied_at    TIMESTAMPTZ,
    downstream_applied_by    TEXT,                    -- V2 异步 job 标识
    notes                    TEXT,

    CONSTRAINT triage_decisions_source_table_chk CHECK (source_table IN ('seed_mappings', 'pending_merge_reviews')),
    CONSTRAINT triage_decisions_decision_chk CHECK (decision IN ('approve', 'reject', 'defer')),
    CONSTRAINT triage_decisions_downstream_chk CHECK (
        (downstream_applied = false AND downstream_applied_at IS NULL AND downstream_applied_by IS NULL) OR
        (downstream_applied = true AND downstream_applied_at IS NOT NULL AND downstream_applied_by IS NOT NULL)
    )
);

CREATE INDEX idx_triage_decisions_source ON triage_decisions(source_table, source_id);
CREATE INDEX idx_triage_decisions_surface ON triage_decisions(surface_snapshot);
CREATE INDEX idx_triage_decisions_historian ON triage_decisions(historian_id);
CREATE INDEX idx_triage_decisions_pending_apply ON triage_decisions(downstream_applied, decided_at) WHERE downstream_applied = false;

COMMENT ON TABLE triage_decisions IS 'Historian decisions on pending review items (seed_mappings + pending_merge_reviews). Multi-row audit per source_id allowed (defer → revisit → approve).';
COMMENT ON COLUMN triage_decisions.source_id IS 'Logical FK to source_table.id; not enforced via SQL FK due to backfill cross-table complexity. Application layer ensures integrity.';
COMMENT ON COLUMN triage_decisions.surface_snapshot IS 'Snapshot at decision time; source row surface may change later (e.g., soft-delete + names-stay).';
COMMENT ON COLUMN triage_decisions.downstream_applied IS 'V2 hook: PE async job sets to true after applying decision to source data layer.';
```

**字段设计要点**：
- `source_id` 不走 SQL FK：因 backfill 跨 sprint historic data 可能引用已 soft-deleted 行；application layer 在 service 兜底校验
- `surface_snapshot` 必须：源行 surface 可能后续改变（如 entity-split / merge），决策时 snapshot 是 hint banner 显示的稳定值
- 多决策行允许：defer → 重审支持，service 层 query 取 latest per source_id
- `architect_ack_ref` 字段：留架构师 inline ACK 场景（如 Sprint J Stage 4.3 dynasty bug 误判 verification）

---

## 4. GraphQL Schema 详细

### 4.1 接口

```graphql
"""
A pending item awaiting historian triage.
Two implementing types as of V1: SeedMappingTriage, GuardBlockedMergeTriage.
"""
interface TriageItem implements Traceable {
    id: ID!
    sourceTable: String!
    sourceId: ID!
    surface: String!  # for inbox grouping & hint banner cross-reference
    pendingSince: DateTime!
    historicalDecisions: [TriageDecision!]!  # for hint banner cross-sprint context
    suggestedDecision: TriageDecisionType  # heuristic from data, may be null
    provenanceTier: ProvenanceTier!  # from Traceable
    sourceEvidenceId: ID  # from Traceable, nullable
}
```

### 4.2 SeedMappingTriage

```graphql
type SeedMappingTriage implements TriageItem & Traceable {
    # TriageItem fields
    id: ID!
    sourceTable: String!
    sourceId: ID!
    surface: String!
    pendingSince: DateTime!
    historicalDecisions: [TriageDecision!]!
    suggestedDecision: TriageDecisionType
    provenanceTier: ProvenanceTier!
    sourceEvidenceId: ID

    # SeedMapping-specific
    targetPerson: Person!
    dictionaryEntry: DictionaryEntry!
    confidence: Float!
    mappingMethod: String!
    mappingMetadata: JSON
}
```

### 4.3 GuardBlockedMergeTriage

```graphql
type GuardBlockedMergeTriage implements TriageItem & Traceable {
    # TriageItem fields
    id: ID!
    sourceTable: String!
    sourceId: ID!
    surface: String!
    pendingSince: DateTime!
    historicalDecisions: [TriageDecision!]!
    suggestedDecision: TriageDecisionType
    provenanceTier: ProvenanceTier!
    sourceEvidenceId: ID

    # GuardBlockedMerge-specific
    personA: Person!
    personB: Person!
    proposedRule: String!
    guardType: String!
    guardPayload: JSON!
    evidence: JSON!
}
```

### 4.4 TriageDecision

```graphql
type TriageDecision {
    id: ID!
    sourceTable: String!
    sourceId: ID!
    surfaceSnapshot: String!
    decision: TriageDecisionType!
    reasonText: String
    reasonSourceType: String
    historianId: String!
    historianCommitRef: String
    architectAckRef: String
    decidedAt: DateTime!
    downstreamApplied: Boolean!
}

enum TriageDecisionType {
    APPROVE
    REJECT
    DEFER
}
```

### 4.5 Queries

```graphql
extend type Query {
    pendingTriageItems(
        limit: Int = 50,
        offset: Int = 0,
        filterByType: TriageItemTypeFilter,
        filterBySurface: String  # for surface cluster grouping
    ): TriageItemConnection!

    triageItem(id: ID!): TriageItem

    triageDecisionsForSurface(
        surface: String!,
        limit: Int = 10
    ): [TriageDecision!]!  # for hint banner cross-sprint lookup

    personById(id: ID!): Person  # 新增（BE inventory §3 推荐），uuid 寻人
}

type TriageItemConnection {
    items: [TriageItem!]!
    totalCount: Int!
    hasMore: Boolean!
}

enum TriageItemTypeFilter {
    SEED_MAPPING
    GUARD_BLOCKED_MERGE
    ALL
}
```

### 4.6 Mutation

```graphql
extend type Mutation {
    recordTriageDecision(input: RecordTriageDecisionInput!): RecordTriageDecisionPayload!
}

input RecordTriageDecisionInput {
    itemId: ID!
    decision: TriageDecisionType!
    reasonText: String
    reasonSourceType: String
    historianId: String!  # validated against allowlist server-side
}

type RecordTriageDecisionPayload {
    triageDecision: TriageDecision!
    nextPendingItemId: ID  # null if inbox empty
    error: TriageDecisionError  # validation/auth errors
}

type TriageDecisionError {
    code: String!  # 'UNAUTHORIZED' | 'INVALID_TRANSITION' | 'ITEM_NOT_FOUND' | 'INVALID_REASON_SOURCE_TYPE'
    message: String!
}
```

---

## 5. Merge 铁律继承条款

per ADR-014 §2.2: "任何修改 `persons.deleted_at` / `merged_into_id` / `person_names.person_id` 的操作必须经过 `apply_merges()` 或经 ADR 授权"

**ADR-027 明文继承 ADR-014 铁律**：

✅ 本 ADR 授权范围（V1/V2）：
- `triage_decisions` 表 INSERT
- `triage_decisions.downstream_applied` UPDATE（V2 PE 异步 job 专用）

❌ 本 ADR **不授权**（必经其他通道）：
- `seed_mappings.mapping_status` UPDATE → V2 由 PE apply_resolve.py 路径执行
- `pending_merge_reviews.status` UPDATE → V2 由 PE apply_resolve.py 路径执行
- `persons.*` UPDATE → 必经 apply_merges() per ADR-014
- `person_names.person_id` UPDATE → 必经 apply_entity_split per ADR-026

BE service 层不得绕过 PE pipeline 路径直接 SQL UPDATE 上述表。

---

## 6. V1 → V2 演进路径

| 维度 | V1（本 sprint） | V2（候选 Sprint L+） |
|------|---------------|---------------------|
| 决策落地 | 仅 INSERT triage_decisions | + PE 异步 job 触发下游 apply |
| auth | URL token + cookie + allowlist yaml | SSO 集成 |
| inbox | FIFO 同 surface 簇优先 | 按 historian 偏好 / type filter |
| bulk operations | 不支持 | 同 surface 簇 N 选 1 / bulk reject |
| 多 historian 协作 | 单 historian 模式 | optimistic locking + conflict resolution |
| 分析 dashboard | 无 | 决策统计 / 趋势图 / disambig backlog 关联 |

---

## 7. Historian Sign-off 形式

沿用 ADR-026 §3.1 模式：sprint-logs file + commit hash 双签。

V1 hist E2E 反馈走 `docs/sprint-logs/sprint-k/historian-e2e-feedback-2026-04-XX.md`，commit hash 引用 + 架构师本侧 ACK。

未来 hist 决策不需要 sprint-logs file（直接走 UI），但跨 sprint 重大反馈仍走 sprint-logs commit。

---

## 8. Consequences

### 8.1 正面

- ✅ Hist 痛点 #1（跨 sprint 重复审）解决：hint banner + inbox 模式
- ✅ Hist 痛点 #2（决策散落）解决：triage_decisions 表统一审计
- ✅ Hist 痛点 #3（context 切 SELECT）解决：详情页一站式
- ✅ Phase 0 → Phase 1 桥接模块到位
- ✅ V1 零侵入 source 表（不破坏既有 resolver / R6 prepass / R1-R5 路径）
- ✅ ADR-014/026 铁律继承明文，BE 工程边界清晰

### 8.2 负面 / 需要接受

- ⚠️ migration 0014 + 新表 + 新 GraphQL schema = 跨三角协调成本（BE/FE/PE 三方 API 契约对齐）
- ⚠️ `surface_snapshot` 字段冗余（与 source row 可能同步更新困难）—— V2 评估是否引入触发器自动更新
- ⚠️ hint banner backfill 脚本质量决定 V1 user value—— Stage 2 PE 工时关键路径
- ⚠️ V1 不实施 V2 hook 但 schema 预留，schema 更改成本部分前置（接受）

### 8.3 回滚路径

- migration 0014 forward-only，回滚走新 migration `DROP TABLE triage_decisions`
- GraphQL schema 移除 TriageItem interface + 3 implements + 1 mutation + 4 queries
- FE /triage 路由 + middleware 删除
- backfill 数据通过 `WHERE historian_id='historical-backfill'` 反查清理

---

## 9. Stage 2 实施细则（PE/BE 共同消化）

### 9.1 pending_merge_reviews 补跑脚本（PE Stage 2）

目标：把 Sprint G/H/I/J 累计 dry-run 数据中的 guard_blocked candidates 回灌到 pending_merge_reviews（让 V1 hist E2E 有真实数据）。

实施 spec：
1. 找到 4 个 sprint 的 dry-run-resolve-*.md 报告（Sprint G/J）+ historian-review-*.md（Sprint G/J）
2. 提取每个被 guard 拦截的 candidate（cross_dynasty / state_prefix / split_for_safety）
3. 按 ADR-026 §4 entity_split_log + brief §1 估计 ~16 条 → INSERT pending_merge_reviews
4. 标 `notes='retroactive-backfill, sprint-K-stage-2-prep'`
5. 跑后 V1-V11 全套（应保持全绿，pending_merge_reviews 是新数据写入，不影响其他表）

预计工时：0.5 天。

### 9.2 historian-review markdown backfill 脚本（PE Stage 2）

目标：把 Sprint G/H/I/J 历史 historian decisions 回灌 triage_decisions（hint banner 数据基础）。

实施 spec：
1. 解析 docs/sprint-logs/T-P0-006-*/historian-review-*.md（Sprint G/H/J）+ docs/sprint-logs/sprint-h/historian-chu-huai-wang-mentions-*.md
2. 每条 ruling 提取：group_id / decision / source_type / 一句理由 / commit hash
3. group_id → DB row UUID 映射：
   - 读对应 dry-run-resolve-*.md 中的 group → row id 表
   - JOIN markdown ruling group_id 与 dry-run group 行 id
4. INSERT triage_decisions:
   - `source_table` = 'pending_merge_reviews'（dry-run 数据来源）
   - `source_id` = JOIN 得到的 row id
   - `surface_snapshot` = markdown ruling 中的 surface text
   - `decision` / `reason_text` / `reason_source_type` = markdown 提取
   - `historian_id` = 'historical-backfill'
   - `historian_commit_ref` = markdown 文件所在 commit hash
   - `decided_at` = 该 sprint 的 historian-review commit timestamp
   - `downstream_applied` = false（V1 不区分历史已 apply 或未 apply）
5. 预计回灌 80-100 条
6. 跑后 SELECT 验证：每个 surface 至少一条 triage_decisions（hint banner 启动条件）

预计工时：1 天。

### 9.3 BE 实施关键路径（参 BE inventory §5 工时）

- migration 0014: 0.5 天
- GraphQL SDL 编写: 0.5 天
- service 层 + resolvers: 1 天
- personById query 新增: 0.25 天
- unit tests ≥ 5: 0.75 天
- codegen 同步前端类型: 0.25 天
- 协调（与 FE/PE/Hist）: 0.25 天
- 累计：~3.5 天

### 9.4 FE 实施关键路径（参 FE inventory §6）

- /triage 路由 + 列表页: 1 天
- /triage/[itemId] 详情页 + form: 1 天
- middleware + auth + cookie: 0.25 天
- 6 快捷模板（hist 详细 spec）: 0.5 天
- E2E test ≥ 2: 0.5 天
- inbox V1 实现（mutation 返 nextPendingItemId + Server Action redirect）: 0.5 天
- 累计：~3.75 天（FE inventory 估 V1 base 3.7 + V1.1 inbox 0.5）

---

## 10. Architect Sign-off

架构师已签字下列决策点：

- [x] **§2.2 GraphQL interface vs union**：interface 推荐
- [x] **§2.3 inbox 模式 V1 必须实现**：最小实现（FIFO + surface 簇 sort）
- [x] **§2.4 Auth 简化方案**：URL token + middleware + cookie + allowlist yaml
- [x] **§2.5 V1 决策不触发下游**：mutation 仅写 triage_decisions，零侵入 source 表
- [x] **§2.6 历史 markdown backfill V1 必须实施**：~80-100 条回灌
- [x] **§3 triage_decisions schema**：13 字段 + 4 索引 + 3 CHECK，多决策行允许
- [x] **§5 merge 铁律继承条款**：明文授权 INSERT triage_decisions + 禁止其他表 UPDATE
- [x] **§9.1 pending_merge_reviews 补跑**：PE Stage 2 实施

签字日期：2026-04-29
签字人：架构师
status: **accepted**（proposed → accepted）

---

## 11. Known Follow-ups

| ID 候选 | 描述 | 优先级 |
|---------|------|--------|
| T-P0-028.V2 | 决策 → 自动 apply 下游（PE 异步 job） | P1 — Sprint L 候选 |
| T-P0-028.UX | 基于 Hist E2E feedback 的 V1.1 UI 调整 | P1 — Sprint L early |
| T-P0-029 | bulk operations / multi-historian 协作 | P2 |
| T-P1-XXX | auth SSO 升级 | P2 — 用户增长后 |
| T-P2-XXX | rejected merge 重写隐患（PE inventory §3.4） | P2 — V2 同期处理 |
| T-P0-028.dashboard | 决策分析 dashboard | P2 — 长期 |
