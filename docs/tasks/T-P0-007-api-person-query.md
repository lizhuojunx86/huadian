# T-P0-007: API MVP — person query（首个真实 resolver）

- **状态**：ready
- **主导角色**：后端工程师
- **协作角色**：首席架构师（评审）、QA 工程师（integration test 评议）
- **所属 Phase**：Phase 0
- **依赖任务**：T-P0-003 ✅（GraphQL 骨架 + Person type + `person(slug)` 入口 + HuadianGraphQLError）
- **预估工时**：1.5 人日（后端主）+ 0.3 人日（架构师评审）
- **创建日期**：2026-04-17

## 目标（Why）

把 T-P0-003 留下的 `person(slug)` / `persons(limit, offset)` 两个 NOT_IMPLEMENTED stub 替换为**真实 Drizzle 查询**，完成华典智谱第一条从 DB 到 GraphQL 的端到端数据通路。

这是 Phase 0 的里程碑：证明 Drizzle → Service Layer → Resolver → GraphQL → 前端 codegen 链路在真实数据上跑通。后续所有 entity query（event / place / sourceEvidence）都将以本任务为范本。

**不含 Mutation / Subscription / DataLoader / 搜索。**

---

## 范围（What）

### 包含

1. **`person(slug: String!): Person` resolver**：
   - Drizzle `select` 查 `persons` 表 by slug
   - 同时加载 `person_names`（1:N）和 `identity_hypotheses`（1:N）
   - slug 不存在 → 抛 `NOT_FOUND`（HuadianErrorCode）
   - slug 格式非法（如含大写、空格、特殊字符）→ 抛 `VALIDATION_ERROR`
   - 被 soft-delete 的 person（`deleted_at IS NOT NULL`）视为 NOT_FOUND

2. **`persons(limit: Int, offset: Int): [Person!]!` resolver**：
   - 默认 `limit = 20`，最大 `limit = 100`
   - 按 `created_at DESC` 排序
   - 不含 soft-deleted 记录
   - 返回空数组而非 null（GraphQL `[Person!]!` 语义）

3. **Service layer**：
   - `services/api/src/services/person.service.ts`（或同等位置）
   - 封装 Drizzle 查询逻辑，resolver 只做参数解析 + 错误包装
   - DTO 映射：Drizzle row → GraphQL Person type（处理 JSONB → MultiLangText / HistoricalDate 的类型对齐）

4. **Slug 验证**：
   - 正则 `/^[a-z0-9]+(-[a-z0-9]+)*$/`（与 C-13 URL 稳定要求一致）
   - 验证逻辑提取为可复用函数（后续 event / place resolver 共享）

5. **测试**：
   - **Resolver 单元测试**（mock db）：覆盖 happy path / NOT_FOUND / VALIDATION_ERROR / soft-delete 过滤
   - **Integration 测试**（真 PG + 最小 fixture）：至少 1 个端到端用例（seed → query → 验证返回结构）
   - fixture 使用 T-P0-004 批次 1 的 persons.seed.json 中至少 3 条记录（如 liu-bang / xiang-yu / sima-qian）

6. **文档更新**：STATUS / CHANGELOG / T-000-index

### 不包含（防止 scope creep）

- ❌ **DataLoader / N+1 优化**：本任务先用 naive join 或 sequential query；DataLoader 在数据量增大时独立引入
- ❌ **Mutation**（Phase 1+）
- ❌ **全文搜索 / 模糊搜索**（Phase 1+ 搜索 query）
- ❌ **event / place / sourceEvidence resolver**（后续任务逐个接手）
- ❌ **Pagination metadata**（totalCount / hasNextPage 等推迟到 Phase 1 Relay cursor 迁移）
- ❌ **Auth / rate-limit**（Phase 1）
- ❌ **OTel span 注入**（T-P0-005 scope）

---

## 架构师决策点（Q-X 问题清单）

以下问题需后端工程师在开工前提议、架构师裁定：

### Q-1 数据来源：种子加载 vs fixture

T-P0-004 批次 1 的 40 人种子 JSON 目前静躺在 `data/dictionaries/persons.seed.json`，尚未被任何加载器导入 DB。

- **选项 A**：本任务自带一个最小 seed 脚本（读 JSON → `drizzle insert`），只 seed 测试所需的 3~5 人
- **选项 B**：等 T-P0-006（Pipeline 加载器）先实现种子加载，本任务 blockedBy T-P0-006
- **选项 C**：Integration 测试用 fixture（test setup 直接 insert），不依赖任何外部 seed 脚本
- **架构师倾向**：**C**。理由：
  1. 测试不应依赖外部 seed 管道（解耦）
  2. fixture 内容可以直接从 `persons.seed.json` 摘取子集，保证数据一致性
  3. 不阻塞 T-P0-006，两个任务可并行
  4. 如果后续需要 dev seed（开发环境预览），可以在 T-P0-006 或独立 `db:seed` 脚本中处理

### Q-2 Service layer 位置与职责边界

- **选项 A**：`services/api/src/services/person.service.ts` — 按实体一个文件
- **选项 B**：`services/api/src/services/index.ts` 统一导出 — 扁平结构
- **架构师倾向**：**A**。与 Drizzle schema 按实体拆分一致，后续扩展不挤在一个文件里。

### Q-3 DTO 映射策略

Drizzle 返回的 JSONB 列（`name` / `birthDate` / `deathDate` / `biography`）在 JS 运行时已经是 object，但 GraphQL 层的 `MultiLangText` / `HistoricalDate` 是 object type，需要显式映射。

- **选项 A**：在 service layer 做显式 mapper 函数（`toGraphQLPerson(drizzleRow)`）
- **选项 B**：直接返回 Drizzle row，依赖 GraphQL resolver 的 field resolver 惰性展开
- **架构师倾向**：**A**。显式映射是防御性编程，避免 DB 列名变更悄悄穿透到前端。

### Q-4 person_names / identity_hypotheses 加载方式

- **选项 A**：在 `person(slug)` resolver 中 eager load（一次查询用 join 或两次 sequential query）
- **选项 B**：用 GraphQL field resolver 惰性加载（只在前端请求 `names` / `identityHypotheses` 时查）
- **选项 C**：DataLoader batch（Phase 0 可能过度设计）
- **架构师倾向**：**A** for `person(slug)` 单体查询（N 通常 < 20，两次 sequential query 即可）；`persons(limit, offset)` 列表查询先只返回 Person 基础字段，`names` / `identityHypotheses` 字段触发 field resolver（**B**），为将来 DataLoader 留口。

### Q-5 sourceEvidenceId 在 Person 上的处理

GraphQL `Person implements Traceable` 要求 `sourceEvidenceId: ID!`（non-null），但 Drizzle `persons` 表没有 `source_evidence_id` 列。T-P0-003 定义了这个字段但未说明数据来源。

- **选项 A**：在 `persons` 表追加 `source_evidence_id UUID REFERENCES source_evidences(id)` 列（schema 变更）
- **选项 B**：Person resolver 返回一个 sentinel 值（如 `"__pending__"`）并在前端隐藏
- **选项 C**：把 `Traceable.sourceEvidenceId` 改为 nullable（SDL breaking change）
- **需要架构师裁决**。这是本任务最大的设计问题。

---

## 子任务拆解

### S-0 架构师评审（开工前）
- [ ] 后端工程师提交本文件
- [ ] 架构师裁定 Q-1~Q-5
- [ ] 用户确认后开工

### S-1 Slug 验证工具函数（0.2 天）
- [ ] `services/api/src/utils/slug.ts`：`validateSlug(slug: string): void`（抛 VALIDATION_ERROR）
- [ ] 单元测试：合法 slug / 非法 slug / 边界 case
- [ ] **Checkpoint commit**

### S-2 Service layer + DTO 映射（0.4 天）
- [ ] `services/api/src/services/person.service.ts`
- [ ] `findBySlug(db, slug)` — Drizzle select + person_names + identity_hypotheses
- [ ] `findMany(db, { limit, offset })` — Drizzle select with pagination
- [ ] DTO mapper：`toGraphQLPerson(row)` / `toGraphQLPersonName(row)` / `toGraphQLHypothesis(row)`
- [ ] 单元测试（mock Drizzle client）

### S-3 Resolver 实现（0.3 天）
- [ ] 替换 `services/api/src/resolvers/query.ts` 中 `person` / `persons` 的 NOT_IMPLEMENTED stub
- [ ] 接入 slug 验证 + service layer
- [ ] 错误处理：NOT_FOUND / VALIDATION_ERROR / INTERNAL_ERROR
- [ ] `persons` field resolvers for `names` / `identityHypotheses`（Q-4 裁定后确定是 eager 还是 lazy）

### S-4 Integration 测试（0.4 天）
- [ ] 测试基础设施：真 PG 容器（testcontainers 或项目 docker-compose test profile）
- [ ] Fixture：从 `persons.seed.json` 摘取 3~5 人 + 对应 person_names + 至少 1 条 identity_hypothesis
- [ ] 端到端用例：seed fixture → GraphQL query → 验证返回结构 + 字段值
- [ ] 覆盖 edge case：slug 不存在 / soft-delete 过滤 / `persons` 分页

### S-5 本地验证（0.1 天）
- [ ] `pnpm --filter @huadian/api dev` 启动
- [ ] GraphiQL 中执行 `person(slug: "liu-bang")` 验证真实数据返回
- [ ] `pnpm -r build / lint / typecheck` 全绿
- [ ] `pnpm -r codegen && git diff --exit-code` 通过

### S-6 收尾（0.1 天）
- [ ] 更新 STATUS.md / CHANGELOG.md / T-000-index.md
- [ ] git commit

---

## 交付物（Deliverables）

- [ ] `services/api/src/utils/slug.ts` — slug 验证工具
- [ ] `services/api/src/services/person.service.ts` — Person 查询 + DTO 映射
- [ ] `services/api/src/resolvers/query.ts` — person / persons 真实 resolver
- [ ] 单元测试文件（slug 验证 + service layer + resolver）
- [ ] Integration 测试文件（真 PG + fixture）
- [ ] 文档更新：STATUS / CHANGELOG / T-000-index

---

## 完成定义（DoD）

1. `person(slug: "liu-bang")` 在 GraphiQL 中返回真实 Person 数据（含 names / identityHypotheses）
2. `person(slug: "nonexistent")` 返回 `NOT_FOUND` 错误码
3. `person(slug: "INVALID SLUG!")` 返回 `VALIDATION_ERROR` 错误码
4. `persons(limit: 5)` 返回最多 5 条 Person 记录
5. Soft-deleted person 不出现在任何 query 结果中
6. 单元测试全绿（≥ 8 个 test case）
7. Integration 测试全绿（≥ 3 个 test case，真 PG）
8. `pnpm -r build && pnpm lint && pnpm typecheck` 全绿
9. `pnpm -r codegen && git diff --exit-code` 通过
10. DTO 映射函数有类型签名（Drizzle row → GraphQL type）
11. STATUS.md / CHANGELOG.md / T-000-index.md 已更新

---

## 依赖分析

| 依赖 | 状态 | 阻塞？ |
|------|------|--------|
| T-P0-003 GraphQL 骨架 | ✅ done | 否 |
| T-P0-002 DB Schema（persons 表） | ✅ done | 否 |
| T-P0-004 批次 1 种子数据 | ✅ done（JSON 静躺） | 否（Q-1 裁定 C：fixture 自包含） |
| T-P0-006 Pipeline 加载器 | 未启动 | **否**（Q-1 裁定解耦） |

---

## 风险与缓解

| 风险 | 缓解 |
|------|------|
| Q-5 sourceEvidenceId 字段在 persons 表缺失，Traceable 接口要求 non-null | 需架构师裁决 schema 变更 vs SDL 调整 |
| Integration 测试依赖真 PG → CI 环境需 PG service | T-P0-001 CI 已有 docker-compose PG；或用 testcontainers |
| person_names 的 GIN trigram 索引在测试 PG 中需要 pg_trgm 扩展 | fixture setup 执行 `CREATE EXTENSION IF NOT EXISTS pg_trgm` |
| DTO 映射可能随 schema 演进频繁变动 | 映射函数集中在 service layer，变更局部化 |
| `persons` 列表在无 DataLoader 时，field resolver 触发 N+1 | Phase 0 数据量 < 100，可接受；DataLoader 作 Phase 1 优化 |

---

## 宪法条款检查清单

- [ ] **C-2** Traceable.sourceEvidenceId 保证溯源（需 Q-5 裁决）
- [ ] **C-6** Schema-first：先有 SDL（T-P0-003），本任务只写实现
- [ ] **C-10** Drizzle → Service → Resolver → GraphQL 类型链路一致
- [ ] **C-12** MultiLangText 字段通过 DTO 正确映射
- [ ] **C-13** Slug 作为 query 入参，验证格式
- [ ] **C-20** 错误码明确，不静默返回 null

---

## 协作交接

- **← T-P0-003**：Person type / `person(slug)` 入口 / HuadianErrorCode / GraphQLContext
- **← T-P0-002**：Drizzle schema `persons` / `person_names` / `identity_hypotheses`
- **→ T-P0-008**：前端基于本任务的真实 API 开发人物卡片页
- **→ 后续 entity query**：event / place / sourceEvidence resolver 以本任务为范本
- **→ QA**：integration 测试框架可复用

---

## 接续提示

```
本任务 ID：T-P0-007
你将担任：后端工程师
请先读：
1. CLAUDE.md → docs/STATUS.md → docs/CHANGELOG.md 最近 5 条
2. .claude/agents/backend-engineer.md
3. docs/tasks/T-P0-007-api-person-query.md（本文件）
4. services/api/src/resolvers/query.ts（现有 NOT_IMPLEMENTED stub）
5. packages/db-schema/src/schema/persons.ts（Drizzle 定义）
6. services/api/src/schema/b-persons.graphql（GraphQL Person type）
7. services/api/src/errors.ts（HuadianGraphQLError）

等架构师裁定 Q-1~Q-5 后，按子任务 S-1→S-6 顺序执行。
```

---

## 修订历史

- 2026-04-17 v1：首席架构师起草，状态 ready，待后端工程师评审 Q-1~Q-5
