# ADR-009: Person sourceEvidenceId Traceability — Traceable 接口 nullable 放宽

- **状态**：accepted
- **日期**：2026-04-17
- **提议人**：首席架构师（Q-5 裁决，T-P0-007 阻塞项）
- **决策人**：首席架构师
- **影响范围**：`Traceable` interface（SDL `common.graphql`）+ 全部 5 个 implementor type（Book / SourceEvidence / Person / Event / Place）+ R-1 修订
- **Supersedes**：无（修订 T-P0-003 R-1 最小字段集定义）
- **Superseded by**：无
- **触发**：T-P0-007 Q-5 — `Person implements Traceable` 承诺 `sourceEvidenceId: ID!`（non-null），但 `persons` 表无 `source_evidence_id` 列；字典种子 40 人为合成身份，无单一 source evidence

## 背景

### 问题

T-P0-003 定义了 `Traceable` interface（R-1 最小字段集）：

```graphql
interface Traceable {
  sourceEvidenceId: ID!     # non-null
  provenanceTier: ProvenanceTier!
  updatedAt: DateTime!
}
```

5 个 entity type 实现了此接口：Book / SourceEvidence / Person / Event / Place。

当 T-P0-007 后端工程师准备实现 `person(slug)` resolver 时，发现：

1. **`persons` 表没有 `source_evidence_id` 列** — Drizzle schema 中无此字段
2. **`books`、`events`、`places` 表同样没有 `source_evidence_id` 列** — 这是系统性缺口，不是 Person 特例
3. **DB 设计通过 `evidence_links` 表实现实体→证据的多对多关联**，而非在每个实体表上放单一 FK
4. **T-P0-004 批次 1 的 40 人字典种子**是从多部古籍综合而成的规范身份，没有单一 source evidence 可指向
5. 仅 `SourceEvidence` 本身可自引用（`sourceEvidenceId = parent.id`）；其余 4 个实体在现有 DB 设计下无法满足 non-null 承诺

resolver 若返回 null → GraphQL 引擎拒绝响应（non-null 违约）→ 首个真实 query 即崩溃。

### 宪法约束

C-2 原文：
> 任何向用户展示的事实、关系、推断都必须能回溯到至少一条 SourceEvidence，**或**清晰标注为 AI 推断 / 学界共识 / 众包贡献（provenance tier）。

关键词是"**或**"。`provenanceTier` 本身就是 C-2 的合规路径之一。因此 `sourceEvidenceId` 为 null + `provenanceTier` 非 null = **C-2 合规**。

## 选项

### Option alpha：给实体表加 `source_evidence_id NOT NULL` 列

- **alpha-1**（每实体生成合成 SourceEvidence）：为 40 人各生成一条空壳 SourceEvidence（rawTextId=null, quotedText=null, positionStart=null）作为 FK 目标
- **alpha-2**（sentinel UUID 单例）：创建一条 "dictionary synthesis" SourceEvidence（id=`00000000-0000-0000-0000-000000000000`），所有字典实体共用

**否决理由**：
1. SourceEvidence 的语义是"一段来自特定文本的引用证据"（rawTextId + position + quotedText）。空壳记录违背其语义，污染核心溯源表
2. alpha-1 为 40 人创建 40 条无内容记录，且 books/events/places 也需同样处理 — 数据膨胀无信息增益
3. alpha-2 的 sentinel UUID 是经典反模式：下游代码必须硬编码判断"这个 UUID 其实代表 null"，泄漏抽象
4. 两种子选项都需要在 `persons`/`books`/`events`/`places` 四张表上加列 + NOT NULL + backfill — 改动量大且方向错误
5. 如果 Phase 1 pipeline 开始产生真实的 entity→evidence 关联，这些合成记录就变成需要清理的历史包袱

### Option beta：Traceable.sourceEvidenceId 改为 nullable（`ID` 去掉 `!`）

- SDL 变更：`sourceEvidenceId: ID!` → `sourceEvidenceId: ID`
- 所有 5 个 implementor 的 `sourceEvidenceId` 字段同步改为 `ID`
- DB schema 不变；`evidence_links` 继续作为 entity→evidence 多对多关联的主通道
- SourceEvidence resolver 仍返回 `parent.id`（runtime 始终 non-null，但类型允许 null）

### Option gamma：resolver 层兼容（DB 允许 null，GraphQL 返回 sentinel 或抛错）

- 让 resolver 对 null 返回 `"__pending__"` 或抛 `VALIDATION_ERROR`

**否决理由**：
1. 返回 `"__pending__"` 是 magic string — 比 sentinel UUID 更隐蔽的反模式
2. 抛 `VALIDATION_ERROR` 意味着合法的字典人物查询永远失败 — 自相矛盾
3. DB 和 GraphQL 类型不一致 → 违反 C-10（端到端类型一致）

## 决策

### 采纳 Option beta

**将 `Traceable.sourceEvidenceId` 从 `ID!` 放宽为 `ID`（nullable）。**

修订后的 Traceable 接口：

```graphql
interface Traceable {
  sourceEvidenceId: ID       # nullable — entity may trace via evidence_links or provenanceTier
  provenanceTier: ProvenanceTier!
  updatedAt: DateTime!
}
```

### R-1 修订

原 R-1（T-P0-003）定义：
> Traceable 最小字段集为 3 个 non-null 字段：sourceEvidenceId / provenanceTier / updatedAt

修订为：
> Traceable 最小字段集为 3 个字段：sourceEvidenceId（nullable）/ provenanceTier（non-null）/ updatedAt（non-null）。traceability 由 provenanceTier（必填）+ sourceEvidenceId（选填直接链接）+ evidence_links（多对多关联）三者共同保证。

### 理由

1. **数据模型一致**：DB 设计已通过 `evidence_links` 实现多对多关联，4 个实体表均无 `source_evidence_id` 列。β 让 GraphQL SDL 与 DB schema 对齐，遵守 C-10
2. **C-2 合规**：宪法 C-2 明确允许 provenanceTier 作为独立的溯源路径。nullable `sourceEvidenceId` + non-null `provenanceTier` = 满足 C-2
3. **零数据污染**：不需要为字典种子 / 规范实体创建空壳 SourceEvidence 记录
4. **渐进式增强**：当 LLM pipeline 从文本中抽取实体时，可以填充 `sourceEvidenceId` 指向主抽取证据。字段从 null 自然过渡到有值，无需迁移
5. **最小改动**：仅修改 SDL（6 个文件中 `ID!` → `ID`）+ codegen re-run。无 DB migration、无 seed 改动、无 resolver 逻辑变更
6. **Phase 0 零消费者**：SDL breaking change（`ID!` → `ID`）在 Phase 0 没有前端消费者，影响为零。graphql-inspector 会报 breaking 但 warn-only 模式不阻断

### 不允许的后续行为

- 不得为满足 non-null 而创建语义空壳 SourceEvidence 记录
- 不得在 resolver 中返回 magic string 代替 null
- 如果未来 Phase 需要恢复 non-null 约束，必须通过新 ADR + 确认所有实体表已有列 + 所有行已有值

## 影响

### 需变更的文件（SDL 层）

| 文件 | 变更 |
|------|------|
| `services/api/src/schema/common.graphql` | `Traceable.sourceEvidenceId: ID!` → `ID` |
| `services/api/src/schema/a-sources.graphql` | `Book.sourceEvidenceId: ID!` → `ID`; `SourceEvidence.sourceEvidenceId: ID!` → `ID` |
| `services/api/src/schema/b-persons.graphql` | `Person.sourceEvidenceId: ID!` → `ID` |
| `services/api/src/schema/c-events.graphql` | `Event.sourceEvidenceId: ID!` → `ID` |
| `services/api/src/schema/d-places.graphql` | `Place.sourceEvidenceId: ID!` → `ID` |

变更后需执行 `pnpm --filter @huadian/api codegen` + `schema:merge` 重生成 TS types 和 schema 快照。

### 不需变更的

- DB schema（`packages/db-schema`）— 无新列、无 migration
- Seed data（`data/dictionaries/`）— 无需为种子生成 SourceEvidence
- Resolver 逻辑 — Person/Event/Place resolver 对无 `source_evidence_id` 的行自然返回 null
- SourceEvidence resolver — 继续返回 `parent.id`（runtime non-null，类型宽松但行为不变）

### 下游任务影响

| 任务 | 影响 | 行动 |
|------|------|------|
| **T-P0-007** API Person Query | **Q-5 解除阻塞**。resolver 对字典人物返回 `sourceEvidenceId: null` 即可 | 后端工程师在 S-1 开工前先执行 SDL 变更 + codegen（可作为 S-0.5 前置步骤） |
| **T-P0-006** Dictionary Loader | 不需要为 40 人生成 SourceEvidence 行 | 无额外工作 |
| **T-P0-005** LLM Gateway | 无直接影响 | 无 |
| **Pipeline NER/Extraction** | Pipeline 创建的 entity 应尽可能填充 `sourceEvidenceId`（指向抽取段落的 SourceEvidence） | 管线工程师在抽取 step 中将 primary evidence id 写入实体（推荐但非强制） |
| **Future Event/Place resolver** | 同 Person — 字典/规范实体返回 null，抽取实体返回真值 | 范本与 T-P0-007 一致 |
| **graphql-inspector CI** | 会报 `FIELD_TYPE_CHANGED` breaking warning | warn-only 模式，不阻断。后续 Phase 1 稳定后可收紧 |

### SDL 变更执行归属

SDL 变更（6 个文件 `ID!` → `ID` + codegen）由 **后端工程师** 在 T-P0-007 S-0.5 步骤执行。架构师不写代码（角色禁区）。

## 回滚方案

1. 将所有 `sourceEvidenceId: ID` 改回 `ID!`
2. 重跑 codegen
3. Phase 0 无数据迁移，回滚零成本

但注意：回滚后 `person(slug)` 等 resolver 会再次面临 non-null 违约问题，需同时实施 alpha 或 gamma 方案。

## 相关链接

- **触发**：T-P0-007 Q-5（`docs/tasks/T-P0-007-api-person-query.md`）
- **宪法**：C-2（可溯源 — OR 条件）、C-10（端到端类型一致）
- **修订**：T-P0-003 R-1（Traceable 最小字段集）
- **DB 关联表**：`evidence_links`（`packages/db-schema/src/schema/sources.ts` A4）
- **前置 ADR**：无
- **受影响 ADR**：无
