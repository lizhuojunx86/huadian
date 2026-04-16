# T-P0-002: DB Schema 落地（Drizzle 真实表定义 + 迁移）

- **状态**：**done**（2026-04-16）
- **主导角色**：后端工程师
- **协作角色**：首席架构师（评审）、历史专家（字段语义校准）、DevOps（DB 配置）
- **所属 Phase**：Phase 0
- **依赖任务**：T-P0-001 ✅、ADR-001 ✅、ADR-002 ✅、ADR-005 ✅
- **预估工时**：3 人日（后端主）+ 0.5 人日（架构师评审）
- **创建日期**：2026-04-15
- **开始日期**：2026-04-16
- **完成日期**：2026-04-16

## 目标（Why）

将 `docs/02_数据模型修订建议_v2.md` 中设计的全部表结构落地为 Drizzle ORM schema，使后续任务（T-P0-003 GraphQL 骨架、T-P0-005 管线集成、T-P0-006 Pipeline MVP）有真实可用的数据库。

这是 Phase 0 地基的核心一步：没有 schema，后续所有任务都无法推进。

## 范围（IN SCOPE）

### 包含

1. **Drizzle schema 全量定义**（`packages/db-schema/src/schema/` 按模块拆分）
2. **Drizzle 迁移生成**（`drizzle-kit generate` + `drizzle-kit migrate`，作为唯一 DDL 来源）
3. **shared-types 同步**（`packages/shared-types/src/` 中定义 `HistoricalDate`、`MultiLangText`、JSONB 结构 schema、枚举等 TS 类型）
4. **跨语言类型同步**（gen-types.sh 跑通：zod → JSON Schema → Pydantic）
5. **DB reset 验证**（`scripts/db-reset.sh` 能清空并重建全部表）
6. **基础约束**（NOT NULL / UNIQUE / FK / CHECK）+ 关键索引
7. **文档更新**（STATUS.md / CHANGELOG.md / T-000-index.md）

### 不包含（重要！防止 scope creep）

- ❌ **不写种子数据**（polities / reign_eras / books 等字典数据由 T-P0-004 历史专家负责）
- ❌ **不写 GraphQL schema**（T-P0-003）
- ❌ **不写 resolver / service 层**（T-P0-007）
- ❌ **不写 PG 触发器 / 存储过程**（T-QC-001）
- ❌ **不做性能调优**（索引策略只做基础版，Phase 1 按真实查询 pattern 优化）
- ❌ **不实现 embedding 分表**（Phase 0 先用单表 `entity_embeddings` + `vector(1024)`）
- ❌ **不接入 OTel / TraceGuard**（T-P0-005）
- ❌ **不写手动 SQL init 脚本**（DDL 单一真源 = Drizzle，见架构师 R-9）

---

## 架构师评审裁定（2026-04-15）

### Q-1 裁定：A — 只保留 JSONB，不建 `event_places` / `event_participants`

v1 的 `event_places` 和 `event_participants` **正式废弃**。叙述级参与者/地点内嵌在 `event_accounts` 的 JSONB 字段中。

**附加要求**：JSONB 字段必须有结构化 schema 约束——在 `shared-types` 中定义：
- `EventParticipantRef`：`{ person_id: string, role: string, action?: string }`
- `EventPlaceRef`：`{ place_id: string, role: string }`
- `EventSequenceStep`：`{ order: number, description: MultiLangText, time?: HistoricalDate }`

### Q-2 裁定：正式废弃 `version_conflicts`

`account_conflicts` 是完整替代，不建 `version_conflicts`。

### Q-3 裁定：同意统一升级，但区分"展示文本"与"历史原始数据"

所有 v1 保留表统一应用 slug / provenance_tier / soft-delete / timestamps。

**但**：`reign_eras.name`、`person_names.name` 等历史原始数据保持 **TEXT**（不转 JSONB）。年号和古人名号是专有名词，不应有"英文版"。后端工程师需逐表逐字段判断哪些是"user-facing 展示文本"（→ JSONB），哪些是"历史原始数据"（→ TEXT）。

### Q-4 裁定：`entity_embeddings` 用 `BIGSERIAL` 主键

ADR-005 的 `entity_id BIGINT` 是笔误，实现时按 `entity_id UUID NOT NULL` 处理。ADR-005 errata 待补。

### Q-5 裁定：同意拆分，微调目录

- `books.ts` 合入 `sources.ts`
- 新增 `enums.ts`（所有枚举统一定义，不散落各文件）

```
packages/db-schema/src/
  schema/
    index.ts          # re-export all
    common.ts         # 共享列定义函数（timestamps / softDelete / provenanceTier / slugField）
    enums.ts          # 所有枚举（pgEnum 或 CHECK 约束）
    sources.ts        # A 层（books + raw_texts + source_evidences + evidence_links + textual_notes + text_variants + variant_chars）
    persons.ts        # B 层
    events.ts         # C 层
    places.ts         # D 层
    relations.ts      # E 层（relationships + mentions + allusions + allusion_evolution + allusion_usages + intertextual_links + institutions + institution_changes）
    artifacts.ts      # F 层
    embeddings.ts     # G 层（entity_embeddings + entity_revisions）
    pipeline.ts       # H 层
    feedback.ts       # I 层
  schema.ts           # 兼容 re-export
  index.ts
```

### Q-6（架构师追加）：v1 保留表升级映射

子任务 6 开始前，在本文件中补一节"v1 保留表升级映射"（每张表的每个字段改动），交架构师快速确认后再写代码。

### Q-7（架构师追加）：`source_evidences` 保持 UUID

该表是被多张表 FK 引用的核心枢纽，改 BIGSERIAL 会导致 FK 类型不一致。

### Q-8（架构师追加）：`event_causality` 需补溯源字段

v1 只有 `confidence`，需补充 `source_evidence_id UUID REFERENCES source_evidences(id)` + `provenance_tier`（C-2 宪法）。

---

## 架构师修订要求（R 系列）

| # | 修订 | 状态 |
|---|------|------|
| R-1 | `polities` 补 slug/deleted_at/created_at/updated_at；`reign_eras` 补 deleted_at/created_at/updated_at | 待实现 |
| R-2 | `entity_embeddings.vector` Phase 0 定义为 `vector(1024)`，不做动态维度 | 待实现 |
| R-3 | `event_accounts` 补 updated_at + deleted_at；`account_conflicts` 补 deleted_at | 待实现 |
| R-4 | `mentions` 补 deleted_at + updated_at | 待实现 |
| R-5 | `evidence_links` 补 created_at | 待实现 |
| R-6 | `books` 补 created_at / updated_at / deleted_at | 待实现 |
| R-7 | `event_accounts.participants/places/sequence` JSONB 在 shared-types 中定义 zod schema | 待实现 |
| R-8 | `raw_texts` 移除 v1 的 embedding 列；保留 tsv tsvector 列 | 待实现 |
| R-9 | 取消手写 SQL init 脚本，Drizzle migration 是唯一 DDL 来源 | 已反映在范围中 |

---

## 表清单（共 ~33 张表）

### A. 文本 & 源层（7 张）— `sources.ts`

| # | 表名 | 来源 | 说明 |
|---|------|------|------|
| A1 | `books` | v2 新增 | 古籍元数据，credibility_tier + R-6 时间戳 |
| A2 | `raw_texts` | v1 修改 | +text_original / +variant_of_id / +deleted_at / 保留 tsv / 移除 embedding（R-8） |
| A3 | `source_evidences` | v1 增强 | +provenance_tier / +book_id / +prompt_version / +llm_call_id / UUID 主键（Q-7） |
| A4 | `evidence_links` | v1 保留 | 证据-实体多态关联 + R-5 created_at |
| A5 | `textual_notes` | v2 新增 | 校勘注释 |
| A6 | `text_variants` | v2 新增 | 文本变体对比 |
| A7 | `variant_chars` | v2 新增 | 通假/异体字字典 |

### B. 身份层（5 张）— `persons.ts`

| # | 表名 | 来源 | 说明 |
|---|------|------|------|
| B1 | `persons` | v1 大改 | 去扁平名号、+slug / +reality_status / +HistoricalDate / +provenance_tier |
| B2 | `person_names` | v2 新增 | 多名号表（核心）；name 保持 TEXT（Q-3） |
| B3 | `identity_hypotheses` | v2 新增 | 身份假说 |
| B4 | `disambiguation_seeds` | v2 新增 | 消歧种子 |
| B5 | `role_appellations` | v2 新增 | 称谓词典 |

### C. 事件层（4 张）— `events.ts`

| # | 表名 | 来源 | 说明 |
|---|------|------|------|
| C1 | `events` | v1 大改 | +slug / +canonical_account_id / +reality_status / JSONB 多语言 |
| C2 | `event_accounts` | v2 新增（核心）| ADR-002 双层；JSONB 有 zod schema（R-7）；+updated_at/deleted_at（R-3）|
| C3 | `account_conflicts` | v2 新增 | 替代 v1 version_conflicts（Q-2）；+deleted_at（R-3）|
| C4 | `event_causality` | v1 增强 | +source_evidence_id / +provenance_tier（Q-8）|

~~C5 `event_participants`~~ — 已废弃（Q-1 裁定 A）
~~C6 `event_places`~~ — 已废弃（Q-1 裁定 A）

### D. 地理 & 时间层（5 张）— `places.ts`

| # | 表名 | 来源 | 说明 |
|---|------|------|------|
| D1 | `places` | v1 大改 | POINT→GEOMETRY / +slug / +fuzziness / +reality_status |
| D2 | `place_names` | v1 增强 | +geometry_variant / +source_evidence_id |
| D3 | `place_hierarchies` | v2 新增 | 朝代行政层级 |
| D4 | `polities` | v2 新增 | 朝代政权；+slug/deleted_at/timestamps（R-1）|
| D5 | `reign_eras` | v2 新增 | 年号；name 保持 TEXT（Q-3）；+deleted_at/timestamps（R-1）|

### E. 关系 & 引用层（8 张）— `relations.ts`

| # | 表名 | 来源 | 说明 |
|---|------|------|------|
| E1 | `relationships` | v1 增强 | +provenance_tier / +deleted_at / +updated_at |
| E2 | `mentions` | v2 新增（核心）| 引用/隐指标注；+deleted_at/updated_at（R-4）|
| E3 | `allusions` | v1 增强 | +slug / JSONB 多语言 / +provenance_tier / +deleted_at |
| E4 | `allusion_evolution` | v1 保留 | 典故含义演变 |
| E5 | `allusion_usages` | v2 新增 | 典故用法实例 |
| E6 | `intertextual_links` | v2 新增 | 互文关联 |
| E7 | `institutions` | v1 增强 | +slug / JSONB 多语言 / +provenance_tier / +deleted_at |
| E8 | `institution_changes` | v1 保留 | 制度演变 |

### F. 物品层（1 张）— `artifacts.ts`

| # | 表名 | 来源 | 说明 |
|---|------|------|------|
| F1 | `artifacts` | v1 增强 | +slug / JSONB 多语言 / +provenance_tier / +deleted_at |

### G. Embedding & 审计层（2 张）— `embeddings.ts`

| # | 表名 | 来源 | 说明 |
|---|------|------|------|
| G1 | `entity_embeddings` | v2 新增 | ADR-005 多槽位；BIGSERIAL 主键（Q-4）；vector(1024)（R-2）|
| G2 | `entity_revisions` | v2 新增 | 审计日志（C-4 宪法） |

### H. 管线 & LLM 层（3 张）— `pipeline.ts`

| # | 表名 | 来源 | 说明 |
|---|------|------|------|
| H1 | `llm_calls` | v2 新增 | LLM 调用记录（C-7 宪法） |
| H2 | `pipeline_runs` | v2 新增 | 管线运行记录 |
| H3 | `extractions_history` | v2 新增 | 抽取结果历史 |

### I. 反馈层（1 张）— `feedback.ts`

| # | 表名 | 来源 | 说明 |
|---|------|------|------|
| I1 | `feedback` | v2 新增 | 用户反馈（C-21 宪法） |

---

## 子任务拆解

### 1. 共享类型 & 枚举定义（0.3 天）
- [ ] `packages/shared-types/src/historical-date.ts` — HistoricalDate zod schema
- [ ] `packages/shared-types/src/multi-lang.ts` — MultiLangText zod schema
- [ ] `packages/shared-types/src/enums.ts` — reality_status / provenance_tier / mention_type / conflict_type / name_type 等枚举
- [ ] `packages/shared-types/src/event-refs.ts` — EventParticipantRef / EventPlaceRef / EventSequenceStep（R-7）
- [ ] `packages/db-schema/src/schema/common.ts` — 共享列定义函数（timestamps / softDelete / provenanceTier / slugField）
- [ ] `packages/db-schema/src/schema/enums.ts` — Drizzle pgEnum 或 CHECK 约束定义
- [ ] 跑 gen-types.sh 确认 zod → JSON Schema → Pydantic 链路通
- [ ] **Checkpoint commit**

### 2. 文本 & 源层 schema（0.3 天）
- [ ] `sources.ts`：books / raw_texts / source_evidences / evidence_links / textual_notes / text_variants / variant_chars
- [ ] raw_texts：保留 tsv tsvector、移除 v1 embedding 列（R-8）
- [ ] 关键索引：GIN(name gin_trgm_ops) on variant_chars
- [ ] `pnpm -r build` 验证

### 3. 身份层 schema（0.3 天）
- [ ] `persons.ts`：persons / person_names / identity_hypotheses / disambiguation_seeds / role_appellations
- [ ] person_names.name 保持 TEXT（Q-3）
- [ ] 关键索引：GIN(name gin_trgm_ops) on person_names
- [ ] `pnpm -r build` 验证

### 4. 事件层 schema（0.3 天）
- [ ] `events.ts`：events / event_accounts / account_conflicts / event_causality
- [ ] event_causality 补 source_evidence_id + provenance_tier（Q-8）
- [ ] 关键索引：partial index on event_accounts WHERE is_canonical
- [ ] `pnpm -r build` 验证

### 5. 地理 & 时间层 schema（0.4 天）
- [ ] **PoC 先行**：最小验证 PostGIS GEOMETRY customType（只 places.geometry 一列，跑通 drizzle-kit generate）
- [ ] `places.ts`：places / place_names / place_hierarchies / polities / reign_eras
- [ ] polities 补 slug / deleted_at / timestamps（R-1）
- [ ] reign_eras.name 保持 TEXT（Q-3）；补 deleted_at / timestamps（R-1）
- [ ] PostGIS GEOMETRY + GIST 索引
- [ ] `pnpm -r build` 验证

### 6. 关系 & 引用 & 物品层 schema（0.4 天）
- [ ] **前置检查点**：补"v1 保留表升级映射"清单（Q-6），交架构师确认
- [ ] `relations.ts`：relationships / mentions / allusions / allusion_evolution / allusion_usages / intertextual_links / institutions / institution_changes
- [ ] `artifacts.ts`：artifacts
- [ ] mentions 补 deleted_at / updated_at（R-4）
- [ ] 关键索引：mentions 多维度索引
- [ ] `pnpm -r build` 验证

### 7. Embedding & 审计 & 管线 & 反馈层 schema（0.4 天）
- [ ] **PoC 先行**：最小验证 pgvector vector(1024) customType（只 entity_embeddings.embedding 一列，跑通 drizzle-kit generate）
- [ ] `embeddings.ts`：entity_embeddings（BIGSERIAL 主键 + vector(1024)）/ entity_revisions
- [ ] `pipeline.ts`：llm_calls / pipeline_runs / extractions_history
- [ ] `feedback.ts`：feedback
- [ ] 关键索引：llm_calls 缓存 / pipeline_runs 状态 / feedback 未解决
- [ ] `pnpm -r build` 验证

### 8. Drizzle 迁移 & 全量验证（0.3 天）
- [ ] `schema/index.ts` 统一 re-export
- [ ] `packages/db-schema/src/schema.ts` 兼容 re-export
- [ ] `packages/db-schema/src/index.ts` 更新导出
- [ ] `drizzle-kit generate` 生成初始迁移
- [ ] `drizzle-kit migrate` 在干净数据库上执行成功
- [ ] `scripts/db-reset.sh` 验证清空+重建流程
- [ ] `pnpm -r build && pnpm lint && pnpm typecheck` 全绿
- [ ] `psql` 验证全部表存在、结构正确

### 9. 收尾（0.2 天）
- [ ] 更新 `docs/STATUS.md`
- [ ] 更新 `docs/CHANGELOG.md`
- [ ] 更新 `docs/tasks/T-000-index.md`
- [ ] git commit: `feat(db): implement full schema (T-P0-002)`

---

## 验收标准（DoD）

1. `packages/db-schema/src/schema/` 下包含全部 ~33 张表的 Drizzle 定义
2. `pnpm -r build` 全绿（db-schema 包编译通过）
3. `pnpm lint && pnpm typecheck` 全绿
4. `docker compose down -v && docker compose up -d` 后，`psql` 能看到全部表
5. `drizzle-kit migrate` 在干净数据库上执行成功
6. `scripts/db-reset.sh` 能清空并重建
7. `\d+ persons` 等关键表结构与 docs/02 + 架构师裁定一致
8. 所有 user-facing TEXT 字段已改为 JSONB（C-12）；历史原始数据保持 TEXT（Q-3）
9. 所有 8 类实体表有 `slug TEXT UNIQUE NOT NULL`（C-13）
10. 所有实体表有 soft-delete（C-4）+ provenance_tier（C-2）
11. `entity_embeddings` 有 pgvector `vector(1024)` 列（ADR-005 + R-2）
12. `places` 有 PostGIS `GEOMETRY` 列（ADR-001）
13. `gen-types.sh` 跑通：shared-types 中的新类型成功导出为 JSON Schema + Pydantic
14. 所有 FK 关系正确（无孤儿引用）
15. STATUS.md / CHANGELOG.md / T-000-index.md 已更新
16. `event_accounts.participants / places / sequence` JSONB 有对应 zod schema（R-7）
17. 每张实体表的 slug 列有 UNIQUE + NOT NULL 约束
18. `drizzle-kit generate` 产出的 migration SQL 可在干净 PG 上独立执行成功

---

## 宪法条款检查清单

- [ ] C-2 所有实体 provenance_tier
- [ ] C-3 Event+EventAccount 双层
- [ ] C-4 soft-delete + entity_revisions
- [ ] C-6 schema-first（本任务就是 schema）
- [ ] C-7 llm_calls 表
- [ ] C-10 Drizzle → shared-types 链路一致
- [ ] C-11 迁移有 down 方案（Drizzle 支持）
- [ ] C-12 JSONB 多语言（user-facing 字段）
- [ ] C-13 slug 唯一
- [ ] C-14 books.license 字段

---

## 风险与缓解

| 风险 | 缓解 |
|------|------|
| Drizzle 不原生支持 PostGIS GEOMETRY 类型 | 子任务 5 先做 PoC 验证 customType；已有社区方案 |
| Drizzle 不原生支持 pgvector vector 类型 | 子任务 7 先做 PoC 验证 customType |
| 表数量多（~33张）一次性落地风险 | 按子任务分组逐层推进；每组完成后编译验证 |
| v1 保留表升级范围需逐字段确认 | 子任务 6 前置"升级映射"检查点（Q-6） |

---

## 协作交接

- **← 架构师**：已评审通过（2026-04-15），裁定 Q-1~Q-8、修订 R-1~R-9
- **← 历史专家**：确认 person_names.name_type / events.event_type / books.genre 等枚举值列表
- **→ T-P0-003**（后端工程师续接）：GraphQL schema 基于本任务产出的 Drizzle 定义
- **→ T-P0-004**（历史专家）：在本任务产出的表结构中填充种子数据
- **→ T-P0-005**（管线工程师）：基于 llm_calls / pipeline_runs / extractions_history 表结构接入管线
- **→ DevOps**：确认 Drizzle migration 可在 CI docker-smoke 中跑通

## 相关链接

- ADR：ADR-001（单 PG）/ ADR-002（Event+Account）/ ADR-005（Embedding 多槽位，待 errata：entity_id UUID）
- 数据模型设计：`docs/02_数据模型修订建议_v2.md`
- 项目宪法：`docs/00_项目宪法.md`（C-2/C-3/C-4/C-6/C-7/C-10/C-11/C-12/C-13/C-14）
- 前置任务：T-P0-001（Monorepo 骨架）
- 后续任务：T-P0-003（GraphQL 骨架）/ T-P0-004（字典种子）/ T-P0-005（LLM Gateway）

## 接续提示（给下一个会话 / 下一个 agent）

```
本任务 ID：T-P0-002
你将担任：后端工程师
请先读：
1. CLAUDE.md → docs/STATUS.md → docs/CHANGELOG.md
2. .claude/agents/backend-engineer.md
3. docs/tasks/T-P0-002-db-schema.md（本文件）
4. docs/02_数据模型修订建议_v2.md
5. docs/decisions/ADR-001, ADR-002, ADR-005
6. packages/db-schema/src/schema.ts（当前 stub）

架构师已裁定 Q-1~Q-8 + R-1~R-9（见本文件"架构师评审裁定"节）。
按子任务 1→9 顺序执行。每完成一组跑 pnpm -r build 验证。
子任务 5/7 需先做 PoC 验证 PostGIS/pgvector customType。
子任务 6 开始前需补 v1 保留表升级映射并交架构师确认。
```

## 修订历史

- 2026-04-15 v1：后端工程师起草
- 2026-04-15 v1.1：架构师评审——裁定 Q-1~Q-5，追加 Q-6~Q-8，修订 R-1~R-9；综合评价"需修订后通过"
- 2026-04-15 v1.2：后端工程师按评审意见更新——合并 R-1~R-9 到表清单和子任务；取消 SQL init 脚本（R-9）；调整目录结构（Q-5）；补充 DoD #16~#18；事件层从 5 张表减为 4 张（Q-1 废弃 event_places/event_participants）；总表数从 ~35 调整为 ~33
- 2026-04-16 v2.0：实施完成。GIN 索引修复（`person_names.idx_person_names_search` 需要 `gin_trgm_ops` operator class，Drizzle 不原生支持，用 `sql` 模板注入）。Drizzle import 去 `.js` 扩展名以兼容 drizzle-kit CJS require。迁移文件 `0000_lame_roughhouse.sql`（SHA1 cc26b48e）。33 张表在干净 PG 上 migrate 成功
