# Sprint K Stage 0 — Backend Inventory（T-P0-028 Triage UI）

- **角色**: Backend Engineer（Opus 4.7 / 1M）
- **日期**: 2026-04-28
- **会话标签**: 【BE】
- **关联 brief**: docs/sprint-logs/sprint-k/stage-0-brief-2026-04-28.md（§3 Stage 0 Backend 段 + §6 V1 scope + §10 ADR-027 候选）
- **scope**: 只读调研 + 文档；不动 GraphQL schema、Drizzle、migration

---

## §1 GraphQL Schema 现状

### 1.1 已暴露的 user-facing 类型

source: `services/api/src/schema/*.graphql`（merge → `__snapshot__/schema.graphql` → `__generated__/graphql.ts` 由 codegen 出 `services/api/codegen.ts` + 前端 `apps/web/codegen.ts`）

| Layer | 类型 | 文件 | Traceable | 状态 |
|------|------|------|-----------|------|
| A | `Book` | `a-sources.graphql` | ✅ | 类型已定义，无 Query 入口 |
| A | `SourceEvidence` | `a-sources.graphql` | ✅（self-ref） | `Query.sourceEvidence(id: UUID!)` 是 NOT_IMPLEMENTED stub |
| B | `Person` | `b-persons.graphql` | ✅ | `Query.person(slug)` + `Query.persons(search, limit, offset)` 已上线 |
| B | `PersonName` | `b-persons.graphql` | ❌ (sourceEvidenceId 可空) | 通过 `Person.names` 字段 resolver 暴露 |
| B | `IdentityHypothesis` | `b-persons.graphql` | ❌ | 通过 `Person.identityHypotheses` 字段 resolver 暴露 |
| B | `PersonSearchResult` | `b-persons.graphql` | n/a | `{ items, total, hasMore }` — pagination 模板 |
| C | `Event` / `EventAccount` / `AccountConflict` | `c-events.graphql` | ✅/❌/❌ | `Query.event(slug)` 是 NOT_IMPLEMENTED stub |
| D | `Place` / `PlaceName` / `Polity` / `ReignEra` | `d-places.graphql` | ✅/❌/❌/❌ | `Query.place(slug)` 是 NOT_IMPLEMENTED stub |
| 共享 | `MultiLangText` / `HistoricalDate` / `Traceable` interface | `common.graphql` | n/a | 全部 user-facing 类型必须 implements `Traceable`（C-2 宪法） |
| 共享 | `EventParticipantRef` / `EventPlaceRef` / `EventSequenceStep` | `common.graphql` | n/a | JSONB embedded 类型 |
| Enums | `ProvenanceTier` / `RealityStatus` / `NameType` / `HypothesisRelationType` / `EventType` / `ConflictType` / `AdminLevel` / `CredibilityTier` / `BookGenre` / `DatePrecision` | `enums.graphql` | n/a | case 与 `packages/shared-types/src/enums.ts` 严格 mirror（R-1） |
| Scalars | `DateTime` / `UUID` / `JSON` / `PositiveInt` | `scalars.graphql` | n/a | R-3 白名单，新增需 ADR |

### 1.2 与 triage 相关但**未暴露**的类型

下列实体在 Drizzle schema 已存在，但 GraphQL 层**完全没有**对应类型 / Query / Mutation：

| Drizzle 表 | Drizzle 文件 | GraphQL 现状 |
|-----------|-------------|-------------|
| `seed_mappings`（J3） | `packages/db-schema/src/schema/seeds.ts` | **未暴露** |
| `dictionary_entries`（J2） | `seeds.ts` | **未暴露** |
| `dictionary_sources`（J1） | `seeds.ts` | **未暴露** |
| `pending_merge_reviews`（K） | `pendingMergeReviews.ts` | **未暴露**（但 0012 migration 注释里点名"T-P0-028 triage UI 唯一数据源"） |
| `entity_split_log`（L） | `entitySplitLog.ts` | **未暴露** |
| `mentions`（E） | `relations.ts`（推断） | **未暴露**（V1 不需要，记一笔） |

### 1.3 关键发现 — 项目首次出现的 GraphQL pattern

grep 结果：
- `services/api/src/schema/*.graphql` 中 **`union` keyword 0 命中**
- `services/api/src/schema/*.graphql` 中 **`Mutation` keyword 0 命中**
- `__typename` 只在 `traceable.ts` resolver 内部检查 interface 类型（不是 union discriminator）

**含义**：Sprint K 引入的 `TriageItem` union 是**项目首个 GraphQL union type**；`recordTriageDecision` 是**项目首个 mutation root**。两件事都需要 ADR-027 / 架构师 Stage 1 拍板。

### 1.4 Query root 当前形态

source: `queries.graphql`（`extend type Query` 模式，bootstrap 来自 `_bootstrap.graphql`）

```graphql
extend type Query {
  person(slug: String!): Person
  persons(search: String, limit: Int = 20, offset: Int = 0): PersonSearchResult!
  event(slug: String!): Event             # NOT_IMPLEMENTED
  place(slug: String!): Place             # NOT_IMPLEMENTED
  sourceEvidence(id: UUID!): SourceEvidence  # NOT_IMPLEMENTED
  stats: Stats!
}
```

**没有 `personById(id: UUID!)`** — 这是 triage 详情页的潜在缺口（详见 §3）。

---

## §2 Drizzle Schema 字段清单

### 2.1 `seed_mappings`（J3）

source: `packages/db-schema/src/schema/seeds.ts:84-121` + `services/pipeline/migrations/0009_dictionary_seed_schema.sql:55-72` + `0010_seed_mappings_add_pending_review_status.sql` + `0011_seed_unique_index_naming_alignment.sql`

| 字段 | 类型 | 约束 | 备注 |
|------|------|------|------|
| `id` | UUID | PK，default `gen_random_uuid()` | |
| `dictionary_entry_id` | UUID | NOT NULL，FK → `dictionary_entries.id` | |
| `target_entity_type` | TEXT | NOT NULL | `'person' / 'place' / 'polity' / 'reign_era' / 'office'`（多态） |
| `target_entity_id` | UUID | NOT NULL | **多态指针，无 hard FK**（per ADR-021，与 `evidence_links` 同模式） |
| `confidence` | NUMERIC(3,2) | CHECK `>= 0.00 AND <= 1.00`（nullable） | |
| `mapping_method` | TEXT | NOT NULL | `'exact_name' / 'manual_review' / 'llm_hinted' / 'historian_correction'` 等枚举字符串 |
| `mapping_created_at` | TIMESTAMPTZ | NOT NULL，default `now()` | |
| `mapping_status` | TEXT | NOT NULL，default `'active'`，CHECK IN (`'active' / 'superseded' / 'rejected' / 'pending_review'`)（migration 0010 扩展） | **triage UI 唯一关心 `pending_review` 状态** |
| `notes` | JSONB | nullable | 自由 metadata（如 historian commit ref / disambiguation context） |

**唯一索引**：
- `uq_seed_mappings_entry_target_status` UNIQUE (dictionary_entry_id, target_entity_type, target_entity_id, mapping_status)（migration 0011 改名后）

**部分索引**：
- `idx_seed_mappings_target` ON (target_entity_type, target_entity_id) WHERE `mapping_status = 'active'`（active mapping 反查）

**无 status 部分索引覆盖 `pending_review`** — triage queue 查询走全表 scan + filter，规模 50 条可接受；规模上 1k 后建议加 `WHERE mapping_status = 'pending_review'` 部分索引（V2 优化候选）。

### 2.2 `pending_merge_reviews`（K）

source: `packages/db-schema/src/schema/pendingMergeReviews.ts:22-61` + `services/pipeline/migrations/0012_add_pending_merge_reviews.sql`

| 字段 | 类型 | 约束 | 备注 |
|------|------|------|------|
| `id` | UUID | PK，default `gen_random_uuid()` | |
| `person_a_id` | UUID | NOT NULL，FK → `persons.id` | |
| `person_b_id` | UUID | NOT NULL，FK → `persons.id` | |
| `proposed_rule` | TEXT | NOT NULL | `'R1' / 'R6'`（resolver 规则编号） |
| `guard_type` | TEXT | NOT NULL | `'cross_dynasty' / 'state_prefix' / 'split_for_safety'`（guard chain 名） |
| `guard_payload` | JSONB | NOT NULL | guard 输出 `{ rule, guard, dynasty_a, dynasty_b, gap_years, threshold_years, ... }`（参见 Sprint J `_swap_ab_payload` fix） |
| `evidence` | JSONB | NOT NULL | resolver merge proposal 携带的 evidence 对象（含 source_evidence_ids、surface forms、context excerpts） |
| `status` | TEXT | NOT NULL，default `'pending'` | 隐式枚举（CHECK 内联）：`'pending' / 'accepted' / 'rejected' / 'deferred'` |
| `created_at` | TIMESTAMPTZ | NOT NULL，default `NOW()` | |
| `resolved_at` | TIMESTAMPTZ | nullable | 必须与 status 一致（CHECK） |
| `resolved_by` | TEXT | nullable | historian 标识，必须与 status 一致 |
| `resolved_notes` | TEXT | nullable | historian 自由理由 |

**约束**：
- CHECK `pending_merge_reviews_pair_order`：`person_a_id < person_b_id`（保证去重稳定）
- CHECK `pending_merge_reviews_resolution_consistent`：`status='pending' ↔ resolved_at/resolved_by 都为 NULL`；`status IN ('accepted','rejected','deferred') ↔ 都非 NULL`

**索引**：
- `pending_merge_reviews_pair_uniq` UNIQUE (person_a_id, person_b_id, proposed_rule, guard_type) WHERE `status = 'pending'`（同一对 pair + rule + guard 不能重复 pending；resolved 后可再次 pending）
- `pending_merge_reviews_status_created` ON (status, created_at)（triage queue list newest first）

---

## §3 现有 Queries 复用评估

### 3.1 `Query.person(slug: String!)` — **复用价值高**

`services/api/src/services/person.service.ts:findPersonBySlug` 已实现：
- merge chain resolution（`mergedIntoId` 跳到 canonical，最多 5 跳）
- `person_names` 跨 merge group 拉齐 + dedup（T-P1-002 algo）
- `identityHypotheses` 一并加载

**triage 详情页 BE 端需求**：展示 `personA` / `personB` 的 name / dynasty / names 列表 / hypotheses / merged_into_id（用于 hist 判断是否已 merge）。

**问题**：`pending_merge_reviews.person_a_id / person_b_id` 是 UUID，而既有 `Query.person` 仅接受 `slug`。两条路：

- **方案 A（推荐）**：新增 `Query.personById(id: UUID!): Person`，复用 `findPersonBySlug` 的 canonical resolution 逻辑（BE 侧改一个 service helper 即可，~0.25 天）
- **方案 B**：在 GraphQL `GuardBlockedMergeTriage` resolver 里 join `persons.slug`，前端继续用 slug 调 `Query.person`（前端少一跳，但 BE resolver 多一次 lookup）

→ 推荐 **A + B 同时**：union 成员把完整 `personA: Person!` / `personB: Person!` 直接返回（GraphQL field resolver join），前端不需要再触发 `Query.person`；保留 `personById` 作为公共 API 提供能力（也可被未来 entity-split / merge_log UI 复用）。

### 3.2 `Query.persons(search, limit, offset)` — **不直接相关**

triage queue 自身要分页，但分页参数模板可复用：返回 `{ items, total, hasMore }`（参见 `PersonSearchResult`）。

### 3.3 `Query.sourceEvidence(id: UUID!)` — **stub 状态**

`pending_merge_reviews.evidence` JSONB 内可能含 `source_evidence_ids`，详情页若要展开 evidence 详情就需要落实这个 stub。

**建议**：本 sprint 顺手把 `sourceEvidence(id)` resolver 落实（比 stub 状态多 ~0.5 天，但不阻塞 V1）；或登记 T-P1-XXX 衍生债，V1 详情页 evidence 仅展示 raw JSONB（hist 反馈可接受度）。

### 3.4 不复用 / 不影响

- `Query.event` / `Query.place`：与 triage 无关
- `Query.stats`：与 triage 无关（但 V1 后期可加 `Stats.pendingTriageCount`）

---

## §4 Union Type vs 分 Query 对比 + 推荐

### 4.1 优劣对比表

| 维度 | union type `TriageItem` | 分 query `pendingSeedMappings` + `pendingGuardBlocks` |
|------|------------------------|------------------------------------------------------|
| **前端列表渲染** | ✅ 单 query 拉全 queue + 排序统一；FE 一个 component switch `__typename` 渲染 | ❌ 两次请求（或 batch）；FE 列表需手动合并 + 排序 |
| **分页 / 总数** | ✅ 跨两源统一 limit/offset/total；`hasMore` 准确 | ❌ 跨表 total 不一致；需要前端自算 |
| **类型安全** | ⚠ TS codegen 生成 discriminated union；前端 **必须 select `__typename`** + 写 type guard，否则 narrow 失败拿到字段交集 | ✅ 两套独立强类型，FE 不需 type guard |
| **inline fragment 强制** | ⚠ FE query 必须 `... on SeedMappingTriage { ... }` + `... on GuardBlockedMergeTriage { ... }` | ✅ 平铺字段直接 select |
| **BE SQL 实现** | ⚠ 需 `UNION ALL` + 跨表 created_at 排序；filter by kind 走 WHERE 分支 | ✅ 两个独立 SELECT，索引复用现有 |
| **BE 排序索引** | ⚠ 两表已有各自 `created_at` 索引；UNION ALL 后 ORDER BY in-memory（V1 60 条规模无问题） | ✅ 单表索引直接用 |
| **V2 扩展（如 entity_split_log triage）** | ✅ 加 union 成员 + 一种 SQL 分支 | ❌ 又加一个 query，前端再加一次请求 |
| **Mutation 设计** | ✅ 单 `recordTriageDecision(itemId, kind, ...)`，kind 决定写哪张表 | ⚠ 也可单 mutation 用 itemId+kind，但分 query 思路下倾向两 mutation（重复） |
| **codegen 影响** | ⚠ 项目首个 union；client-preset 生成 `TriageItem = ({ __typename: 'SeedMappingTriage' } & ...) \| ({ __typename: 'GuardBlockedMergeTriage' } & ...)`；前端 generated 文件首次出现联合类型 | ✅ 沿用既有 query 类型生成模式，无新模式引入 |
| **ADR 触发** | 需 ADR-027（union 抽象 + V1→V2 演进） | 可能不需 ADR（标准 CRUD） |
| **工时差异** | BE +~2h（SQL UNION + 排序索引规划）；FE +~2h（type guard + inline fragment） | BE/FE 各 -~2h |

### 4.2 TypeScript / GraphQL codegen 具体约束（FE inventory §6 对齐参考）

`apps/web/codegen.ts` 用 `client-preset` + `enumsAsTypes: true`。union 类型在 client-preset 下：

1. **生成形态**（`apps/web/lib/graphql/generated/graphql.ts` 增量）：
   ```ts
   export type TriageItem =
     | ({ __typename: 'SeedMappingTriage' } & SeedMappingTriageFragment)
     | ({ __typename: 'GuardBlockedMergeTriage' } & GuardBlockedMergeTriageFragment);
   ```

2. **前端 query 必须显式 select `__typename`**：
   ```ts
   graphql(`
     query PendingTriage($limit: Int, $offset: Int) {
       pendingTriageItems(limit: $limit, offset: $offset) {
         items {
           __typename            # 必须 — discriminator
           id
           createdAt
           ... on SeedMappingTriage { ... }
           ... on GuardBlockedMergeTriage { ... }
         }
         total
         hasMore
       }
     }
   `)
   ```
   若不 select `__typename`，TS 类型 narrow 失败，前端只能拿到公共字段（id / createdAt）的交集。

3. **前端 type guard 模式**：
   ```ts
   function renderItem(item: TriageItem) {
     switch (item.__typename) {
       case 'SeedMappingTriage':
         return <SeedMappingCard mapping={item.dictionaryEntry} ... />;
       case 'GuardBlockedMergeTriage':
         return <MergeBlockCard personA={item.personA} ... />;
     }
   }
   ```
   TypeScript narrow 后可访问差异字段。FE 需建一个 `<TriageCard item={...} />` switch component。

4. **fragment-masking**：client-preset 默认开启 fragment masking，union 成员若用 fragment 引用，前端 `useFragment(SeedMappingTriageFragment, item)` 解包；本 sprint 可选关或保留默认（FE 自决）。

5. **interface 共字段补充**：可定义 `interface TriageItemBase { id, kind, createdAt, status }`，让两个成员都 `implements TriageItemBase`，前端能在不写 inline fragment 的情况下访问公共字段（codegen 会把 interface 字段提升到 union 公共部分）。**强烈建议加 interface**（小成本大收益）。

### 4.3 推荐方案 — **union type，含 `TriageItemBase` interface**

理由：
1. 前端列表渲染统一 / V2 扩展性优势对长期维护比短期 type guard 成本重要
2. interface 共字段抽象抵消 type guard 模板代码（公共字段平铺访问）
3. 60 条规模下 UNION ALL 排序成本可忽略
4. Sprint K 是 V1，趋势是后续会加更多 triage 类型（entity_split_log triage / 反馈 triage / mention triage 等）— union 是正确方向
5. ADR-027 起草本身就是 sprint scope 之一，借此机会把 union pattern 写入项目惯例

不采纳分 query 的关键反对：
- 前端列表合并 + 跨源排序逻辑下沉 FE 是**反模式**（违反 FE 不决定数据结构原则）
- V2 加第三类 triage 时返工成本高

### 4.4 推荐 schema 草案（提交架构师 Stage 1 设计参考）

```graphql
# enums.graphql 增补
enum TriageKind {
  seed_mapping
  guard_blocked_merge
}

enum TriageStatus {
  pending
  accepted
  rejected
  deferred
}

enum TriageDecision {
  accept
  reject
  defer
}

# 新文件 j-triage.graphql（暂定）

interface TriageItemBase {
  id: ID!
  kind: TriageKind!
  status: TriageStatus!
  createdAt: DateTime!
}

union TriageItem = SeedMappingTriage | GuardBlockedMergeTriage

type SeedMappingTriage implements TriageItemBase {
  id: ID!
  kind: TriageKind!
  status: TriageStatus!
  createdAt: DateTime!

  # SeedMapping-specific
  dictionaryEntry: DictionaryEntry!
  targetEntityType: String!     # 'person' / 'place' / ...
  targetPerson: Person          # nullable — 多态 target，仅 type='person' 时填
  confidence: Float
  mappingMethod: String!
  notes: JSON
}

type GuardBlockedMergeTriage implements TriageItemBase {
  id: ID!
  kind: TriageKind!
  status: TriageStatus!
  createdAt: DateTime!

  # GuardBlock-specific
  personA: Person!
  personB: Person!
  proposedRule: String!         # 'R1' / 'R6'
  guardType: String!            # 'cross_dynasty' / 'state_prefix' / ...
  guardPayload: JSON!
  evidence: JSON!
}

type DictionaryEntry {
  id: ID!
  source: DictionarySource!
  externalId: String!
  entryType: String!
  primaryName: String
  aliases: JSON
  attributes: JSON!
}

type DictionarySource {
  id: ID!
  sourceName: String!
  sourceVersion: String!
  license: String!
  commercialSafe: Boolean!
}

type TriagePage {
  items: [TriageItem!]!
  total: Int!
  hasMore: Boolean!
}

# queries.graphql 增补
extend type Query {
  pendingTriageItems(
    limit: Int = 20
    offset: Int = 0
    filterByKind: TriageKind
  ): TriagePage!

  triageItem(id: ID!, kind: TriageKind!): TriageItem  # 详情页

  # 顺带补 personById（详见 §3.1 推荐 A）
  personById(id: UUID!): Person
}

# 新 mutations.graphql（项目首个 mutation）
type Mutation {
  recordTriageDecision(input: RecordTriageDecisionInput!): TriageItem!
}

input RecordTriageDecisionInput {
  itemId: ID!
  kind: TriageKind!
  decision: TriageDecision!
  reason: String
  historianId: String!
}
```

> **架构师 Stage 1 待裁决点**：
> 1. union 成员是否要 implement `Traceable`？SeedMapping 链 dictionary_entry，GuardBlock 链 evidence；都不直接挂 source_evidence_id。倾向**不挂**（C-2 宪法语义不匹配 — triage 是工作流条目而非内容实体），但需架构师明确。
> 2. Mutation 是否要返 `provenance_tier`？— BE 角色文档要求"所有 mutation 必须返回 `provenance_tier`"。triage decision 不是内容生成，倾向**返 `null` 或 `unverified`**，待架构师定义新枚举值或豁免。
> 3. Auth 简化方案：`historianId: String!` input 字段 vs `X-User` header vs URL `?historian=name`？— 架构师 Stage 1 ADR-027 确定。

---

## §5 V1 实施工时估计

### 5.1 BE 段（自评）

| 子项 | 估时 | 备注 |
|------|------|------|
| migration 0014 `triage_decisions` 表 + Drizzle schema sync | 0.5 天 | 仿 0013 entity_split_log 模板；架构师 Stage 1 ADR-027 ack 后开工 |
| GraphQL SDL 扩展（j-triage.graphql + queries 增补 + 新 mutations.graphql） | 0.5 天 | 含 schema snapshot 重生 + codegen + traceable resolver 更新（如 union 成员要 implements Traceable） |
| Service 层 `triage.service.ts`（`fetchPendingTriageItems` / `findTriageItem` / `recordTriageDecision`） | 0.75 天 | 两表 SQL UNION ALL 排序 + 写 triage_decisions 与 UPDATE source 表的 transactional consistency |
| Resolver 层（query.ts 增 3 query / 新 mutation.ts） | 0.25 天 | |
| `personById(id: UUID!)` query 新增（service helper 拆出） | 0.25 天 | 复用 `findPersonBySlug` 模板 |
| Unit tests（≥5）：service 层 fetchPending / recordDecision happy + 三种 decision + idempotent | 0.5 天 | |
| Integration test：mutation 提交 + status 持久化 + UNIQUE 索引释放 + transactional rollback | 0.25 天 | |
| Codegen 同步前端：`apps/web/codegen.ts` 重生 + 新建 `lib/graphql/queries/triage.ts` template | 0.25 天 | FE 协同 |
| 跨角色协调（Hist 字段命名 review / FE codegen 联调 / PE V2 hook 接口确认） | 0.25 天 | |

**累计：~3.5 天 BE 段**（落在 brief 5-7 天总长内，与 FE 并行 Stage 2-3）

### 5.2 假设 / 风险

- **Stop Rule #1 触发**：Stage 0 inventory 任一角色延误 > 0.5 天 → 全局 stop
- **Stop Rule #3 触发**：union 引入对前端既有 person 页面破坏 → schema snapshot diff CI 应捕获，但需 FE 端跑 codegen 后 typecheck 一遍
- **架构师 ADR-027 内容**：若 ADR-027 引入额外约束（如要求 union 成员 implements Traceable + 新增 `triage` 作为 ProvenanceTier 枚举值），BE 工时 +0.25 天
- **Auth 简化方案**：若架构师选 X-User header 方案，BE 需在 GraphQL context 解析，~0.1 天；若选 input field，已含在 §5.1 工时中

### 5.3 triage_decisions 表草案（待 ADR-027 拍板）

```sql
-- 0014_add_triage_decisions.sql 候选
CREATE TABLE IF NOT EXISTS triage_decisions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  triage_kind     TEXT NOT NULL,    -- 'seed_mapping' | 'guard_blocked_merge'
  source_table    TEXT NOT NULL,    -- 'seed_mappings' | 'pending_merge_reviews'
  source_id       UUID NOT NULL,    -- FK 多态（无 hard FK，仿 evidence_links）
  decision        TEXT NOT NULL,    -- 'accept' | 'reject' | 'defer'
  reason          TEXT,
  historian_id    TEXT NOT NULL,
  decided_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  superseded_by   UUID REFERENCES triage_decisions(id),  -- 回滚 / 重审链
  CHECK (triage_kind IN ('seed_mapping', 'guard_blocked_merge')),
  CHECK (decision IN ('accept', 'reject', 'defer'))
);

CREATE INDEX idx_triage_decisions_source
  ON triage_decisions (source_table, source_id);

CREATE INDEX idx_triage_decisions_historian_recent
  ON triage_decisions (historian_id, decided_at DESC);
```

---

## §6 V1 → V2 演进衔接点（PE Stage 4 hook）

### 6.1 V1 范围（Sprint K）

- mutation `recordTriageDecision` 写两件事（同一事务内）：
  1. INSERT into `triage_decisions`（审计行）
  2. UPDATE `seed_mappings.mapping_status` 或 `pending_merge_reviews.status` + `resolved_at` + `resolved_by` + `resolved_notes`
- **不**触发任何下游 apply（不跑 R6 prepass、不调 apply_merges、不写 source_evidences）
- mutation 不破坏现有 V1-V11 invariant（不动 persons / person_names / person_merge_log）

### 6.2 V2 hook（Sprint L+ 候选）

| 决策类型 | V2 触发 | 影响 |
|---------|--------|------|
| `SeedMappingTriage` accept | `mapping_status='active'` → 触发 R6 prepass 重跑 | PE 端 |
| `SeedMappingTriage` reject | `mapping_status='rejected'` → no-op | 无 |
| `GuardBlockedMerge` accept | 调 `apply_merges()` 路径写 `person_merge_log` + soft-delete person | PE 端，影响 V1-V11 |
| `GuardBlockedMerge` reject | `status='rejected'` → 后续 resolver 不再提议 | resolver 端 |
| `*` defer | `status='deferred'` → 重审周期可重 pending（部分索引允许） | 无 |

### 6.3 V2 推荐设计接口（BE → PE 契约）

- **Option α（异步通知）**：BE mutation 写完 triage_decisions 后向 PostgreSQL `NOTIFY triage_apply, '{...}'`；PE 监听 channel 触发 apply。优点：解耦；缺点：PE 端需新建 daemon。
- **Option β（同步调用）**：BE mutation 在 transaction 内调 PE service（HTTP/gRPC）；PE 同步执行 apply。优点：原子性强；缺点：BE/PE 边界模糊（违反角色解耦）。
- **Option γ（队列）**：写入 Redis Stream 或专用 `triage_apply_queue` 表，PE 周期性 poll。**推荐**，与既有 `pipeline_runs` / `llm_calls` 异步模式一致。

→ V2 PE Stage 4 评估时由 PE 主导选择；本 sprint 只需保证 triage_decisions schema 字段足以驱动 V2 推断（`source_table` + `source_id` + `decision` 三字段够）。

### 6.4 V1 离线 reconciler（可选）

PE 提供脚本 `services/pipeline/scripts/reconcile_triage.py`：
- 对账 `triage_decisions` 与 `seed_mappings.mapping_status` / `pending_merge_reviews.status` 是否一致
- 报告 mismatched 行（应为 0）

不在 BE scope，记入 PE 衍生债。

---

## §7 跨角色依赖

### 7.1 向 Frontend Engineer

1. **TypeScript / codegen 约束（重要 — FE inventory §6 必读）**：
   - schema 用 union → `apps/web/lib/graphql/generated/graphql.ts` 增量出 discriminated union；前端 query **必须 select `__typename`** 否则 type narrow 失败
   - 前端列表渲染 **必须**写 type guard（`switch (item.__typename) { case 'SeedMappingTriage': ... }`）
   - inline fragment 强制（`... on SeedMappingTriage { ... }`）
   - 推荐建 `<TriageCard item={...} />` switch component（一个文件，~80 行）
   - 工时建议预留 **0.25 天**写 type-safe rendering switch（不算复杂）
   - fragment-masking 默认开（client-preset），union 成员若用 fragment 需 `useFragment(...)` 解包；可选关
2. **接口契约**：
   - `Query.pendingTriageItems(limit, offset, filterByKind)` 返回 `TriagePage { items, total, hasMore }`
   - `Query.triageItem(id, kind)` 详情页（接受 union discriminator）
   - `Mutation.recordTriageDecision(input)` 返 updated `TriageItem`（前端 optimistic update）
   - `Query.personById(id: UUID!)` 顺带补出
3. **codegen 流程**：BE 改完 schema → `pnpm --filter @huadian/api codegen` → snapshot 更新 → FE 跑 `pnpm --filter @huadian/web codegen` 同步
4. **请 FE 在 inventory §6 (跨角色依赖) 显式确认**：
   - shadcn/ui 是否需新增 Card / Dialog / Form 组件支持 triage UI
   - URL 路由设计（`/triage` 列表 + `/triage/[id]?kind=...` 详情）下 `kind` 作为 query param 还是 path segment

### 7.2 向 Pipeline Engineer

1. **数据采样请求**：≥10 条各类型样本，coverage：
   - seed_mappings.pending_review × 5（覆盖 Sprint B/C/E 各 mapping_method）
   - pending_merge_reviews.status='pending' × 5（覆盖 R1 cross_dynasty / R1 state_prefix / R6 cross_dynasty / split_for_safety）
   - 每条提供 surface forms + 上下文片段 + 推荐决策（hist 视角）
2. **V2 hook 接口确认**：PE Stage 4 评估 V2 触发路径（推荐 Option γ Redis Stream 或 triage_apply_queue 表）
3. **V1 不破坏验证**：PE 确认 mutation 写 status 后 resolver / R6 prepass 路径不破坏（V1-V11 invariant 不回归）
4. **Stage 1 协助**：PE review triage_decisions 表 schema（FK / 多态 / status 转换约束）
5. **请 PE 报清单**：
   - mapping_status `pending_review` 下的 mapping_method 分布（驱动 UI filter 设计）
   - guard_payload JSONB 的 schema 是否稳定（`_swap_ab_payload` fix 后是否还有变更预期）

### 7.3 向 Historian

1. **字段命名 review**：union 成员公共字段（`id` / `kind` / `status` / `createdAt`）+ 差异字段（`dictionaryEntry` vs `personA/personB`）的语义命名是否符合 historian 心智模型
2. **决策三态够否**：`accept` / `reject` / `defer` — 是否需要 `split` / `partial-accept` / `request-info` 等？brief V1 已限三态，但 hist 反馈优先级
3. **详情页关键 metadata 字段优先级**：哪些上下文最关键（surface forms / dynasty / 段落上下文 / merge log 历史 / 同 surface 已有决策 / 跨 sprint 同样 reject 记录），驱动 BE field selector 优先级
4. **决策回滚 / 重审场景**：V1 `superseded_by` chain 设计是否符合 hist 工作流；是否需要 "comment" 而不是 "decision"（轻量 trail）
5. **请 Hist 在 inventory 中报清单**：
   - 当前手工 triage 的 5-10 条具体痛点 case（驱动 BE 字段选择）
   - 理想列表 UI 的分组维度（按 guard_type / mapping_method / 创建时间 / surface form？— 决定 BE filter API）

### 7.4 向架构师

1. **ADR-027 起草**：union type 抽象 + triage_decisions schema + V1→V2 演进 + 项目首个 GraphQL mutation 引入 → 强烈建议起草（brief §10 默认倾向）
2. **Stage 1 待裁决点**（参见 §4.4 schema 草案下方）：
   - union 成员是否 `implements Traceable`？
   - Mutation 是否要返 `provenance_tier`？是否需新增 `triage` 作为 ProvenanceTier 枚举值（mirror 到 shared-types）？
   - Auth 简化方案：input field vs X-User header vs URL query param？
   - migration 0014 schema 草案 ack（§5.3）
3. **首个 Mutation root 引入**：可能触发 ADR addendum（C-2 宪法 mutation 形式约定）
4. **GraphQL schema 加 union 后 CI 流程**：snapshot diff（已有）+ codegen client-preset 重生（已有）；是否要新增 union 成员完整性检查（如 `forge-resolver-types`）？— 架构师评估
5. **跨角色 schema 评审会议**：Stage 1 BE/FE 同时 ack 接口契约（建议线上 sync 30min）

---

## 附录 A — 文件 / 行号索引

- `services/api/src/schema/queries.graphql:13-53` — Query root extend
- `services/api/src/schema/b-persons.graphql:18-88` — Person + PersonName + IdentityHypothesis
- `services/api/src/schema/common.graphql:82-86` — Traceable interface
- `services/api/src/services/person.service.ts:173-214` — findPersonBySlug + canonical resolution
- `packages/db-schema/src/schema/seeds.ts:84-121` — seedMappings table
- `packages/db-schema/src/schema/pendingMergeReviews.ts:22-61` — pendingMergeReviews table
- `services/pipeline/migrations/0009_dictionary_seed_schema.sql` — J 层建表
- `services/pipeline/migrations/0010_seed_mappings_add_pending_review_status.sql` — pending_review status 引入
- `services/pipeline/migrations/0012_add_pending_merge_reviews.sql` — K 层建表
- `services/pipeline/migrations/0013_add_entity_split_log.sql` — 0014 模板参考
- `apps/web/codegen.ts` — 前端 codegen 配置（client-preset，enumsAsTypes:true）
- `services/api/codegen.ts` — 后端 codegen 配置

---

## 附录 B — Stage 0 → Stage 1 BE 端 ACK 清单（架构师 Stage 1 收口检查项）

- [ ] union type 设计已采纳（含 `TriageItemBase` interface）
- [ ] triage_decisions migration 0014 schema ack
- [ ] Auth 简化方案确定
- [ ] union 成员 Traceable 归属确定
- [ ] mutation provenance_tier 处理确定
- [ ] `personById(id)` 增补确认
- [ ] FE/PE/Hist 三方接口契约 sign-off
- [ ] Stage 2 BE 实施允许开工

— 报 BE Stage 0 inventory 完。
