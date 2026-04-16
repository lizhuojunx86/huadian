# T-P0-003: GraphQL Schema 骨架（SDL + 核心类型 + Query 入口）

- **状态**：**in_progress**（2026-04-16 起）
- **主导角色**：后端工程师
- **协作角色**：首席架构师（评审）、前端工程师（契约评议）、管线工程师（Extraction payload 契约评议）
- **所属 Phase**：Phase 0
- **依赖任务**：T-P0-001 ✅、T-P0-002 ✅、ADR-007 ✅
- **预估工时**：2 人日（后端主）+ 0.3 人日（架构师评审）
- **创建日期**：2026-04-16
- **开始日期**：2026-04-16
- **完成日期**：

## 目标（Why）

在 T-P0-002 已落地的 Drizzle schema（33 表）之上，搭好 GraphQL 契约层的**骨架**：

1. 把"业务类型源头"（`packages/shared-types` 的 zod）与"持久层类型"（`packages/db-schema` 的 Drizzle）之间的 **GraphQL SDL 这一薄层**落地 —— 这是 ADR-007 §四 bis 明确的边界。
2. 为后续任务（T-P0-007 Person Query、T-P0-008 人物卡片页、T-P0-005 管线结构化输出契约）提供**可演进的入口**。
3. 固化一批**暂不可回退**的架构决策：schema-first vs code-first、错误码、pagination、自定义标量、codegen、graphql:breaking CI 门禁。

这是 Phase 0 最后一块地基。**没有 GraphQL 契约，前后端就无法并行，管线的结构化输出也无处落。**

本任务不实现真实 resolver（读库由 T-P0-007 接手）。

---

## 范围（What）

### 包含

1. **架构决策落地**（见 §架构师决策点 Q-1~Q-11）
2. **目录结构**：`services/api/src/schema/` 下 SDL 分域；`services/api/src/resolvers/` 按类型分文件
3. **自定义标量**：`DateTime` / `UUID` / `JSON` / `MultiLangText` / `HistoricalDate`（部分做 object type，见 Q-4）
4. **GraphQL 枚举**：对齐 `packages/shared-types/src/enums.ts` 的 22 个枚举（至少 Phase 0 骨架用到的子集）
5. **核心输出类型骨架**（字段对齐 Drizzle，不含内部审计列）：
   - `Person` / `PersonName` / `IdentityHypothesis`（B 层）
   - `Event` / `EventAccount` / `AccountConflict`（C 层）
   - `Place` / `PlaceName` / `Polity` / `ReignEra`（D 层）
   - `Book` / `SourceEvidence`（A 层，供溯源引用）
6. **Query 入口**（最少 5 个，全部按 slug 取单体 + 列表，返回 mock 或抛 `NOT_IMPLEMENTED`）：
   - `person(slug: String!): Person`
   - `persons(limit: Int, offset: Int): [Person!]!`
   - `event(slug: String!): Event`
   - `place(slug: String!): Place`
   - `sourceEvidence(id: UUID!): SourceEvidence`
7. **Context 类型**：`{ db, requestId, tracer: null }`（tracer 在 T-P0-005 接入，此处留 hole）
8. **错误码规范**：`GraphQLError` + `extensions.code`（见 Q-9）
9. **codegen**：`graphql-codegen` 把 SDL → TS 类型，产物落 `services/api/src/__generated__/graphql.ts`（Q-6）
10. **CI**：`graphql:breaking` 用 `graphql-inspector` 对比 base branch（ADR-007 §六 第 8 步告警，不阻断）
11. **GraphiQL/Yoga playground** 本地可访问并验证 3 个 query
12. **文档更新**：STATUS / CHANGELOG / T-000-index / `docs/runbook/RB-002-graphql-dev.md`（可选，若骨架涉及非平凡启动步骤）

### 不包含（防止 scope creep）

- ❌ **真实 resolver 实现**（T-P0-007 及之后逐个接手）
- ❌ **Mutation / Subscription**（Phase 1+）
- ❌ **Dataloader / N+1 优化**（T-P0-007 首个真实 query 时引入）
- ❌ **E 层类型**（`mentions` / `allusions` / `relationships` 等引用/关系类型的 GraphQL 暴露推迟到 Phase 1；Phase 0 只为 B/C/D + 部分 A 出骨架）
- ❌ **F 层 `artifacts`、G 层 embedding/audit、H 层 pipeline、I 层 feedback 的 GraphQL 暴露**（embedding/pipeline/audit 不对外；feedback Phase 1；artifacts Phase 1）
- ❌ **搜索 / 图遍历 / 地图几何 query**（Phase 1+）
- ❌ **Relay cursor connection**（Phase 0 用 offset，见 Q-5）
- ❌ **权限 / auth / rate-limit**（Phase 1）
- ❌ **OTel span / TraceGuard hook**（T-P0-005）
- ❌ **DTO adapter 业务代码**（T-P0-007 真实 resolver 时写；本任务仅占位类型签名）
- ❌ **PostGIS GEOMETRY 的 GraphQL 暴露形式**（Q-4 只定 HistoricalDate；Place.geometry 骨架用 `JSON` 占位，Phase 1 独立 ADR 细化）

---

## 架构师评审裁定（2026-04-16）

**状态**：**已通过**。Q-1~Q-11 全部按后端提议采纳；追加 R-1 / R-2 / R-3 修订；依赖全批准。

### Q 裁定速览

| # | 裁定 | 说明 |
|---|------|------|
| Q-1 | **A** | Schema-first（SDL + graphql-codegen） |
| Q-2 | **B** | SDL 按 A/B/C/D 层拆分 + `graphql-tools` 合并 |
| Q-3 | **A** | 引入 `graphql-scalars`（标量白名单见 R-3） |
| Q-4 | **B** | `MultiLangText` / `HistoricalDate` 作为 GraphQL Object Type |
| Q-5 | **A** | offset / limit pagination；Phase 1 迁 Relay cursor（独立 ADR） |
| Q-6 | **A** | 本任务接入 `@graphql-codegen/*` 全家桶 |
| Q-7 | **A** | 本任务接 `graphql-inspector` breaking 检测（告警不阻断） |
| Q-8 | **A** | 骨架覆盖 A 层（Book/SourceEvidence）+ B/C/D 全部 |
| Q-9 | **采纳** | `HuadianGraphQLError` + `HuadianErrorCode` 清单（见原提议） |
| Q-10 | **A** | Query resolver 统一抛 `NOT_IMPLEMENTED`，前端 MSW mock |
| Q-11 | **A** | 抽取 `Traceable` interface（字段清单见 R-1） |

### R-1 — Traceable 最小字段集（架构师原文）

凡实现 Traceable interface 的 GraphQL 类型必须暴露三个字段：

```graphql
interface Traceable {
  sourceEvidenceId: ID!
  provenanceTier: ProvenanceTier!
  updatedAt: DateTime!
}
```

`ProvenanceTier` enum 的 case 与 `packages/shared-types/src/enums.ts` 的同名 zod enum 保持一致（由 codegen 同步，手工改任一端都会被另一端打爆）。

### R-2 — SDL 拼装 + breaking 检测双层（架构师原文）

**(a)** 按 A/B/C/D 层拆后，用 `@graphql-tools` 的 `loadFilesSync` + `mergeTypeDefs` 组装成单一 executable schema。

**(b)** CI 的 `codegen:verify` 跑两级检查：
1. 合并结果与仓库中 `schema.graphql` 快照 `git diff --exit-code` 一致
2. `graphql-inspector diff` 对比上一个 main commit 的 schema，breaking change 仅 PR 评论不阻断（与 Q-7 一致）

### R-3 — 自定义标量白名单（架构师原文）

本任务允许的自定义标量**仅限** `graphql-scalars` 提供的 `DateTime` / `UUID` / `JSON` / `PositiveInt`。

任何新增自定义标量（含把 `HistoricalDate` / `MultiLangText` 从 Object Type 改为 scalar）**必须开新 ADR**。

### 依赖批准清单

以下依赖全部批准（commit message 需写明 `T-P0-003 架构师批准`）：

- `graphql-scalars`
- `@graphql-codegen/cli`
- `@graphql-codegen/typescript`
- `@graphql-codegen/typescript-resolvers`
- `@graphql-codegen/add`
- `graphql-inspector`

**pin 位置**：按 SDL 源文件归属决定（本任务 SDL 全部在 `services/api/src/schema/`，故依赖装入 `services/api`；若未来前端侧引 Apollo/urql codegen，再在 `apps/web` 单独 pin）。

---

## 架构师决策点 · 提议原文（已裁定，留档）

### Q-1 Schema-first vs Code-first
- **选项 A**：Schema-first。手写 `.graphql` SDL 文件 + `graphql-codegen` 生成 TS 类型 + resolvers 类型约束
- **选项 B**：Code-first（Pothos / TypeGraphQL）。schema 由 TS builder 生成
- **提议 A**，理由：
  1. ADR-007 §四 明确业务类型源头在 zod；若再引 Pothos，等于三处类型源（zod / Pothos / Drizzle）协调成本更高
  2. SDL 是跨语言契约资产，管线（Python）、前端（Apollo/urql codegen）都消费 SDL
  3. graphql-inspector 的 breaking diff 对 SDL 天然友好
  4. graphql-yoga 对两者都支持，不锁定
- **风险**：SDL + TS 类型同步需 codegen 自动化，漏跑会类型错位 → 用 CI `codegen:verify` 兜底（与 T-P0-001 现有 codegen 流水对齐）

### Q-2 SDL 文件组织
- **选项 A**：单文件 `services/api/src/schema/schema.graphql`
- **选项 B**：按业务域拆分 + `graphql-tools` `loadSchemaSync` 合并
  ```
  services/api/src/schema/
    scalars.graphql            # DateTime/UUID/JSON + HistoricalDate/MultiLangText
    enums.graphql              # 对齐 shared-types
    common.graphql             # Provenance 抽象、错误类型
    a-sources.graphql          # Book / SourceEvidence
    b-persons.graphql          # Person / PersonName / IdentityHypothesis
    c-events.graphql           # Event / EventAccount / AccountConflict
    d-places.graphql           # Place / PlaceName / Polity / ReignEra
    queries.graphql            # Query type，所有入口
  ```
- **提议 B**，与 Drizzle schema 分层（A/B/C/D）保持一致，便于与 `packages/db-schema/src/schema/*.ts` 一一对应排查

### Q-3 自定义标量来源
- **选项 A**：引入 `graphql-scalars`（社区维护，覆盖 DateTime/UUID/JSON/Void 等）
- **选项 B**：自写 4 个标量（DateTime/UUID/JSON/NonEmptyString）
- **提议 A**，理由：生态成熟；`graphql-scalars` 在 graphql-yoga 文档中是官方推荐组合
- **依赖新增**：`graphql-scalars@^1.24`（需架构师批准新依赖，C-15 无依赖红线但 CLAUDE.md 要求先征求同意）

### Q-4 HistoricalDate 如何映射 GraphQL？
底层 JSONB 形如 `{ year_min, year_max, precision, ... }`（`packages/shared-types/src/historical-date.ts`）。
- **选项 A**：作为自定义 scalar `HistoricalDate`，JSON serialize/parse 原样透出
- **选项 B**：定义为 GraphQL Object Type
  ```graphql
  type HistoricalDate {
    yearMin: Int
    yearMax: Int
    precision: DatePrecision!
    rawText: String
  }
  ```
  前端按字段取，强类型
- **选项 C**：既支持 scalar（输入）也暴露 object（输出） → 过度设计
- **提议 B**，理由：前端组件渲染"约前 145 年"需要分字段；scalar 透传让前端重复 JSON schema
- **对称决策**：`MultiLangText` 应同方案。提议：
  ```graphql
  type MultiLangText {
    zhHans: String!
    zhHant: String
    en: String
  }
  ```

### Q-5 Pagination 风格
- **选项 A**：offset / limit（简单，Phase 0 足够）
- **选项 B**：Relay cursor connection（跨前端 cache 友好，社区事实标准，但复杂）
- **提议 A** for Phase 0，Phase 1 真正上线列表页时迁 B（独立 ADR）
- **风险**：迁 B 是 breaking change；用 `graphql-inspector` 告警兜底

### Q-6 codegen 是否本任务引入？
- **选项 A**：本任务就接 `@graphql-codegen/cli` + `typescript` + `typescript-resolvers` preset，产 `services/api/src/__generated__/graphql.ts`
- **选项 B**：推迟到 T-P0-007（第一个真实 resolver 需要类型时才上）
- **提议 A**，理由：
  1. 没有 codegen 的 SDL 骨架等于"两个真源漂移的起点"
  2. T-P0-001 的 turbo `codegen` task 已占坑，本任务把 GraphQL codegen 补齐
  3. 让后续所有 resolver 任务起点就是类型安全
- **依赖新增**：
  - `@graphql-codegen/cli`
  - `@graphql-codegen/typescript`
  - `@graphql-codegen/typescript-resolvers`
  - `@graphql-codegen/add`（注释 header）

### Q-7 `graphql:breaking` CI 接入时机
- **选项 A**：本任务接入 `graphql-inspector diff` 告警（ADR-007 §六 第 8 步占坑）
- **选项 B**：推迟到 ADR-008 GraphQL 演进 ADR 时再接
- **提议 A**，理由：ADR-007 已明示 Phase 0 告警不阻断；本任务首次生成 SDL，此刻接入成本最低，Phase 1 切门禁只改 CI 一行
- **风险**：base branch 首次无 SDL，`diff` 会全绿；此时作用 = 兜底 + 习惯养成，无 breaking 历史

### Q-8 Phase 0 骨架覆盖哪些实体类型？
- **选项 A**（提议）：A 层（Book / SourceEvidence）+ B 层全部 + C 层全部 + D 层全部
- **选项 B**：仅 B 层（只暴露 Person 及其附属，最小够跑 T-P0-008 人物卡片）
- **选项 C**：全 33 表一次性暴露（scope creep）
- **提议 A**，理由：
  1. T-P0-008 人物卡片页需要 Person → 关联 Event、Place（即便先展示，后续填内容无需二次改 schema）
  2. A 层 Book/SourceEvidence 是 C-2 溯源宪法要求（任何实体字段 `provenanceTier` + 可跳转 evidence）
  3. 关系层（E）和管线层（H）不对外，延后

### Q-9 错误码命名与 extensions 结构
提议约定：
```typescript
class HuadianGraphQLError extends GraphQLError {
  constructor(message: string, code: HuadianErrorCode, extra?: Record<string, unknown>) {
    super(message, {
      extensions: {
        code,                      // UPPER_SNAKE_CASE
        requestId,                 // from context
        timestamp: new Date().toISOString(),
        ...extra,
      },
    });
  }
}

enum HuadianErrorCode {
  NOT_FOUND = "NOT_FOUND",
  NOT_IMPLEMENTED = "NOT_IMPLEMENTED",
  INVALID_INPUT = "INVALID_INPUT",
  INTERNAL = "INTERNAL",
  CONFLICT = "CONFLICT",
  UPSTREAM_LLM_FAILURE = "UPSTREAM_LLM_FAILURE",  // for future mutations
}
```
- **决策点**：是否同意该清单及命名？是否需要约束所有 resolver 必须 throw `HuadianGraphQLError` 而非原生 `Error`（由 ESLint 规则保障）？

### Q-10 Resolver 占位策略
- **选项 A**：全部 Query resolver 抛 `NOT_IMPLEMENTED`，前端拿到明确错误码
- **选项 B**：返回 `null` / `[]` 静默（前端误认"无数据"）
- **选项 C**：返回硬编码 mock（便于前端并行联调，但需明确 TTL）
- **提议 A**，理由：符合 C-20（不信任幻觉）精神，失败显式优于静默
- **例外**：若 T-P0-008 人物卡片开发时需 mock，临时在前端 MSW 层 mock，不污染后端

### Q-11 Provenance 暴露约定（C-2 宪法）
C-2 要求"所有实体必须可溯源"。GraphQL 层如何体现？
- **选项 A**：抽取 GraphQL `interface Traceable { provenanceTier: ProvenanceTier! }`，所有实体实现
- **选项 B**：各实体各自挂 `provenanceTier` 字段，不抽 interface
- **选项 C**：包一层 `type TraceableEntity<T> { data: T, provenance: Provenance! }`（Phase 0 过度）
- **提议 A**，理由：
  1. 前端可统一组件消费 Traceable
  2. Phase 1 加"跳转到源"按钮时只需查 Traceable 的 `sourceEvidences: [SourceEvidence!]!` 额外字段
  3. interface 在 GraphQL 演进中扩展字段不 breaking

---

## 子任务拆解

### 0. 架构师评审（已完成 2026-04-16）
- [x] 提交本文件至首席架构师评审
- [x] 收齐 Q-1~Q-11 裁定 + R-1/R-2/R-3 修订
- [x] 更新本文件 §架构师评审裁定
- [x] 用户批准后开工

### 1. 依赖与 codegen 基建（0.3 天）
- [x] `services/api` 新增依赖（按 pin 规则全部装 services/api）：
  - runtime：`graphql-scalars`、`@graphql-tools/load-files`（R-2a 明确 `loadFilesSync`）、`@graphql-tools/merge`
  - dev：`@graphql-codegen/cli` / `@graphql-codegen/typescript` / `@graphql-codegen/typescript-resolvers` / `@graphql-codegen/add` / `@graphql-inspector/cli`
- [x] `services/api/codegen.ts`（TS 配置，导出 `CodegenConfig`；scalars 白名单 R-3）
- [x] `services/api/scripts/merge-schema.ts`（R-2a：`loadFilesSync` + `mergeTypeDefs` → `src/schema/__snapshot__/schema.graphql`）
- [x] `services/api/package.json` scripts：`codegen` / `codegen:watch` / `schema:merge` / `schema:diff`
- [x] `.eslintrc.cjs` 忽略 `codegen.ts` / `scripts/**` / `src/__generated__/**`
- [x] 根 `turbo.json` 的 `codegen` task 补 `services/api/src/__generated__/**` + `services/api/src/schema/__snapshot__/**` outputs
- [ ] **Checkpoint commit**：`chore(api): add graphql-codegen + scalars deps (T-P0-003 架构师批准)`（等用户确认是否 commit）

### 2. SDL 目录与自定义标量（0.3 天）
- [ ] 按 Q-2 裁定创建 `services/api/src/schema/*.graphql`
- [ ] `scalars.graphql`：**仅** DateTime / UUID / JSON / PositiveInt（R-3 白名单）
- [ ] `common.graphql`：MultiLangText / HistoricalDate / DatePrecision enum / Traceable interface（字段遵 R-1：sourceEvidenceId ID! / provenanceTier ProvenanceTier! / updatedAt DateTime!）
- [ ] `enums.graphql`：对齐 shared-types 枚举（骨架范围内用到的子集）；ProvenanceTier case 与 `packages/shared-types/src/enums.ts` 一致（R-1）
- [ ] 用 `@graphql-tools` 的 `loadFilesSync` + `mergeTypeDefs` 组装（R-2a）
- [ ] 落地合并快照 `services/api/src/schema/__snapshot__/schema.graphql`（R-2b 第 ① 项）
- [ ] `codegen` 初跑 → 确认产物
- [ ] **Checkpoint commit**：`feat(api): define custom scalars + shared types (T-P0-003)`

### 3. A/B/C/D 层类型骨架（0.5 天）
- [ ] `a-sources.graphql`：Book / SourceEvidence（implements Traceable）
- [ ] `b-persons.graphql`：Person / PersonName / IdentityHypothesis（Person implements Traceable）
- [ ] `c-events.graphql`：Event / EventAccount / AccountConflict
- [ ] `d-places.graphql`：Place / PlaceName / Polity / ReignEra（Place.geometry 暂用 `JSON`）
- [ ] 字段严格对齐 Drizzle（排除审计列 `createdAt/updatedAt/deletedAt`、不透出 FK UUID 以外的内部字段）
- [ ] `codegen` 再跑 → 确认 TS 类型产出
- [ ] **Checkpoint commit**：`feat(api): add core entity types A/B/C/D layers (T-P0-003)`

### 4. Query 入口与 Context（0.3 天）
- [ ] `queries.graphql`：person / persons / event / place / sourceEvidence
- [ ] `services/api/src/context.ts`：GraphQLContext 类型（db / requestId / tracer 占位）
- [ ] `services/api/src/errors.ts`：`HuadianGraphQLError` + `HuadianErrorCode`
- [ ] `services/api/src/resolvers/`：按类型分文件，所有 Query resolver 抛 `NOT_IMPLEMENTED`（Q-10）
- [ ] `services/api/src/schema.ts`：`loadSchemaSync` 合并 SDL + 挂 resolvers
- [ ] `services/api/src/index.ts` 改造：挂新 schema，保留 /graphql endpoint
- [ ] **Checkpoint commit**：`feat(api): wire query entrypoints + error codes (T-P0-003)`

### 5. 本地验证（0.2 天）
- [ ] `pnpm --filter @huadian/api dev` 起服务
- [ ] GraphiQL 访问 `http://localhost:4000/graphql`
- [ ] 至少 3 个 query 跑通（返回 NOT_IMPLEMENTED 错误码，非崩溃）
- [ ] `pnpm -r build / lint / typecheck` 全绿
- [ ] `pnpm -r codegen && git diff` 无差异

### 6. CI 接入（0.2 天）
- [ ] `.github/workflows/ci.yml` 补 step 8 `graphql:breaking`（跑两级检查，对齐 R-2b）：
  - **① schema 快照 drift**：`pnpm --filter @huadian/api schema:merge` 后 `git diff --exit-code src/schema/__snapshot__/schema.graphql` → drift 则 FAIL
  - **② breaking diff**：`pnpm --filter @huadian/api schema:diff` 调 `graphql-inspector diff` 对比上一个 main commit 的快照 → breaking 仅 PR 评论，`continue-on-error: true`
- [ ] base branch 首次无 snapshot → step ② `|| true` 兜底（首次 main 合并后 snapshot 入仓即自动生效）
- [ ] Phase 1 切门禁在 ADR-008 落地时改 continue-on-error

### 7. 收尾（0.2 天）
- [ ] 更新 `docs/STATUS.md`
- [ ] 追加 `docs/CHANGELOG.md`
- [ ] 更新 `docs/tasks/T-000-index.md`
- [ ] （按需）`docs/runbook/RB-002-graphql-dev.md`：本地启动 / codegen 流程
- [ ] git commit：`docs: close T-P0-003 — graphql skeleton done`

---

## 交付物（Deliverables）

- [ ] SDL 文件：`services/api/src/schema/*.graphql`（按 Q-2 裁定）
- [ ] Resolver 骨架：`services/api/src/resolvers/*.ts`
- [ ] Context / Error：`services/api/src/context.ts` / `errors.ts`
- [ ] Codegen 产物：`services/api/src/__generated__/graphql.ts`
- [ ] Codegen 配置：`services/api/codegen.ts`（或 `.yml`）
- [ ] CI：`.github/workflows/ci.yml` 第 8 步启用
- [ ] 文档：STATUS / CHANGELOG / T-000-index 更新；RB-002（可选）
- [ ] （如需要新 ADR）ADR-008 GraphQL 演进骨架 —— 若架构师裁定本任务需配套 ADR，则在本任务内附带

---

## 完成定义（DoD）

1. `pnpm --filter @huadian/api dev` 启动后 `http://localhost:4000/graphql` 可访问 GraphiQL
2. 至少 5 个 Query（person / persons / event / place / sourceEvidence）在 GraphiQL 中可查到签名并返回带 `code: NOT_IMPLEMENTED` 的结构化错误
3. 自定义标量 DateTime / UUID / JSON 注册成功，introspection 可见
4. `MultiLangText` / `HistoricalDate` 以 GraphQL Object Type 形式暴露（Q-4 选 B）
5. `Traceable` interface + `provenanceTier` 字段覆盖 Person / Event / Place / Book（Q-11）
6. `graphql-codegen` 产物 `services/api/src/__generated__/graphql.ts` 包含 A/B/C/D 全部类型
7. `pnpm -r build && pnpm lint && pnpm typecheck` 全绿
8. `pnpm -r codegen && git diff --exit-code` 通过（CI `codegen:verify` 兜底）
9. CI 新增 `graphql:breaking` step（告警不阻断）
10. `HuadianGraphQLError` + `HuadianErrorCode` 导出可用；ESLint 规则（或至少 code-review checklist）要求 resolver 只抛 `HuadianGraphQLError`
11. Resolver 无任何真实 DB 访问（T-P0-007 才接入）
12. 枚举类型对齐 shared-types（骨架子集覆盖即可，其余 enum 留 Phase 1 增量）
13. STATUS.md / CHANGELOG.md / T-000-index.md 已更新
14. 所有新增依赖在 CHANGELOG 中列出 + 用户批准

---

## 宪法条款检查清单

- [ ] **C-2** Traceable interface + provenanceTier 保证溯源字段（Q-11）
- [ ] **C-3** Event + EventAccount 双层在 GraphQL 层面体现（EventAccount 作为独立类型，Event.accounts 返回列表）
- [ ] **C-6** Schema-first：先定 SDL，resolver 跟着走
- [ ] **C-10** Drizzle → shared-types → GraphQL SDL → codegen TS 链路不断
- [ ] **C-12** 所有 user-facing 文本字段用 `MultiLangText` 而非 `String`
- [ ] **C-13** 所有实体以 `slug` 作为 query 入参
- [ ] **C-20** 错误码明确，不静默返回 null

---

## 风险与缓解

| 风险 | 缓解 |
|------|------|
| `graphql-codegen` 与 `typescript-resolvers` 对 graphql-yoga 类型兼容性 | 子任务 1 结束跑一次 sanity，若不兼容切 `graphql-yoga` 官方文档推荐的 `TypedDocumentNode` 方案 |
| SDL 按域拆分 + loader 合并可能顺序敏感（interface 先定义） | codegen 初跑即暴露；按 `common → scalars → enums → entities → queries` 加载顺序 |
| `HistoricalDate` Object Type 与 Drizzle JSONB 的 adapter 归属不清 | Phase 0 不写 adapter（无真实 resolver）；T-P0-007 首次实现时在 `services/api/src/services/*.ts` 写 DTO，本任务只定 GraphQL 类型签名 |
| 前端已在 T-P0-008 期待某些字段，现在 schema 覆盖不足 | Q-8 裁定决定覆盖范围，若不足由前端工程师在 T-P0-008 kickoff 时提 enhancement，增量 PR |
| graphql-inspector 在 base branch 无 SDL 情况下跑挂 | step 标 `continue-on-error: true`，Phase 1 切门禁前必须首次跑过 |
| 新增依赖（graphql-scalars + codegen 全家桶）膨胀 | 所有新增在 CHANGELOG 中列出 + 架构师批准；Q-6 裁定 B 时可砍半 |

---

## 协作交接

- **← 架构师**：等待评审裁定 Q-1~Q-11 + R 系列
- **→ 前端工程师**：Q-4（MultiLangText/HistoricalDate 结构）与 Q-5（pagination 风格）是前端消费侧的契约，裁定后在 `.claude/agents/frontend-engineer.md` 锚定
- **→ 管线工程师**：无直接依赖；但若管线产出的结构化 payload 用 GraphQL mutation 回写（Phase 1），本任务的错误码约定是契约
- **→ T-P0-004 历史专家**：无依赖
- **→ T-P0-005 管线 LLM Gateway**：无依赖（除非裁定把 LLM 结果的 GraphQL 类型提前暴露）
- **→ T-P0-007 API Person Query**：本任务是直接前置；Person 类型、`person(slug)` 入口、错误码全由本任务定好
- **→ T-P0-008 Web 人物卡片页**：本任务是直接前置；前端基于本任务的 SDL 接 Apollo/urql codegen
- **→ DevOps**：CI 第 8 步 `graphql:breaking` 需配合验证

---

## 相关链接

- **ADR**：ADR-007（Monorepo §四 类型源头边界、§六 CI 第 8 步）
- **宪法**：C-2 / C-3 / C-6 / C-10 / C-12 / C-13 / C-20
- **数据模型**：`docs/02_数据模型修订建议_v2.md`
- **前置任务**：T-P0-001、T-P0-002
- **后续任务**：T-P0-007（Person Query）、T-P0-008（人物卡片页）
- **可能衍生 ADR**：ADR-008（GraphQL 演进策略，pagination / 版本化 / breaking 门禁时机）—— 若架构师裁定本任务需同步出 ADR-008 骨架则合并处理，否则延到 Phase 1

---

## 接续提示（给下一个会话 / 下一个 agent）

```
本任务 ID：T-P0-003
你将担任：后端工程师
请先读：
1. CLAUDE.md → docs/STATUS.md → docs/CHANGELOG.md 最近 5 条
2. .claude/agents/backend-engineer.md
3. docs/tasks/T-P0-003-graphql-skeleton.md（本文件）
4. docs/decisions/ADR-007-monorepo-layout.md §四 + §六
5. packages/db-schema/src/schema/（对齐字段时参考）
6. packages/shared-types/src/（MultiLangText / HistoricalDate / 枚举）

架构师裁定的 Q-1~Q-11 + R 系列见本文件"架构师评审裁定"节。
按子任务 1→7 顺序执行，每组结束跑 pnpm -r build / codegen / lint / typecheck。
所有新增依赖在 CHANGELOG 中列清并确认已获批。
```

---

## 讨论记录

### 2026-04-16 后端工程师
- 起草 v1 草案
- 待架构师评审裁定 Q-1~Q-11 + R 系列

---

## 修订历史

- 2026-04-16 v1：后端工程师起草，待架构师评审
- 2026-04-16 v1.1：架构师评审通过。Q-1~Q-11 全部按后端提议采纳；追加 R-1 Traceable 最小字段集、R-2 SDL 拼装+breaking 双层、R-3 自定义标量白名单；依赖全批准。状态 draft → in_progress
