# ADR-008: License 策略（GraphQL Book.license + Workspace 包 license 字段）

- **状态**：accepted
- **日期**：2026-04-17
- **提议人**：后端工程师（T-P0-003 F-1 遗留）
- **决策人**：首席架构师
- **影响范围**：`packages/shared-types` licenseEnum / GraphQL SDL / 全部 workspace 包 `package.json` + `pyproject.toml`
- **Supersedes**：无
- **Superseded by**：无
- **触发**：T-P0-003 遗留 L-1（`Book.license` 暂用 String）+ F-1（package.json 缺 license 字段）

## 背景

T-P0-003 GraphQL 骨架实现时发现两个 license 相关问题：

### 问题 1：GraphQL Book.license 无法用 enum

`packages/shared-types/src/enums.ts` 的 `licenseEnum` 包含 `"CC-BY"`，其中的连字符在 GraphQL enum 值语法中不合法（enum 值只允许 `[_A-Za-z][_0-9A-Za-z]*`）。因此 T-P0-003 暂将 `Book.license` 暴露为 `String!` 而非 enum。

需要裁决规范化方式（Option A/B/C 见下）。

### 问题 2：Workspace 包缺 license 字段

`services/api/package.json`（及多数 workspace 包）未声明 `"license"` 字段。项目未来可能开源或商业化（ADR-006 U-04：付费墙推迟到 Phase 3），需要统一方案。

## 选项

### 问题 1 选项

**Option A**：shared-types 的 `"CC-BY"` 改为 `"CC_BY"`（下划线），GraphQL 侧用 `License` enum

- 优点：GraphQL 层类型安全；enum 可做 introspection / 文档自生成；前后端强一致
- 缺点：`CC_BY` 不是标准 SPDX 表达式（标准为 `CC-BY-4.0`）；需要在 DB 存储层 / API 层做双向映射
- 影响：shared-types `licenseEnum` 改值 → Pydantic 模型重生成 → 已有种子数据中 `license` 字段需更新（目前无已入库数据）

**Option B**：保留 `String!` + zod 校验（resolver 返回值仍匹配 licenseEnum，但 GraphQL 层不做 enum 约束）

- 优点：零改动；前端用 TypeScript union type（from codegen）即可；SPDX 标识符原样保留
- 缺点：GraphQL 层无 enum introspection；前端 schema explorer 看不到合法值列表
- 影响：无

**Option C**：自定义 scalar `License`（需要突破 R-3 白名单限制）

- 优点：灵活
- 缺点：R-3 明确限制自定义标量白名单，新增需开 ADR（本 ADR 可覆盖，但动机不足）
- 影响：需修改 R-3 白名单

### 问题 2 选项

**Option X**：所有 workspace 包统一声明 `"license": "UNLICENSED"`

- 含义：明确声明"此代码未授权他人使用"（npm 语义）
- 适用于：私有仓库、不打算开源的阶段

**Option Y**：声明 `"license": "proprietary"`

- 含义：等价于 UNLICENSED 但更直白
- 注意：`proprietary` 不是有效 SPDX，npm/pnpm 会发 warning

**Option Z**：声明具体 SPDX（如 `"license": "MIT"` 或 `"Apache-2.0"`）

- 适用于：确定开源方向后
- 问题：ADR-006 U-04 明确将开源/商业化推迟到 Phase 3，现在选 SPDX 可能过早

## 决策

### 裁决 1：GraphQL Book.license → **Option A**（`CC_BY` 下划线规范化）

理由：
1. **类型安全优先**：C-10 要求端到端类型一致，`String!` 是逃逸舱而非终态
2. **Phase 0 无数据迁移成本**：`licenseEnum` 尚未有任何数据入库，改值零风险
3. **映射简单**：`CC-BY` → `CC_BY` 是纯字符串替换，在 DTO 层单点处理
4. **SPDX 兼容性**：我们存储的是华典内部 enum 值，不是 SPDX 标识符本身；如果未来需要对外暴露 SPDX 格式，在 API 层做 `CC_BY → CC-BY-4.0` 映射即可

具体变更：
- `packages/shared-types/src/enums.ts`：`licenseEnum` 的 `"CC-BY"` → `"CC_BY"`
- `services/api/src/schema/enums.graphql`：新增 `enum License { CC0 CC_BY PUBLIC_DOMAIN PROPRIETARY UNKNOWN }`
- `services/api/src/schema/a-sources.graphql`：`Book.license: String!` → `Book.license: License!`
- graphql-codegen 重跑
- Pydantic 模型重生成

### 裁决 2：Workspace 包 license → **Option X**（`UNLICENSED`）

理由：
1. **ADR-006 U-04**：开源/商业化推迟到 Phase 3，现在不选 SPDX
2. **npm 语义明确**：`UNLICENSED` 是 npm 认可的声明，不会触发 warning（不同于 `proprietary`）
3. **Python 侧**：`pyproject.toml` 的 `license` 字段设为 `"LicenseRef-Proprietary"`（PEP 639 / SPDX 扩展语法）
4. **Phase 3 时统一切换**：届时如果选择 MIT / Apache-2.0 / 商业许可，在一个 PR 里统一改所有包的 license 字段

具体变更：
- 所有 `package.json`（10 个包）：添加 `"license": "UNLICENSED"`
- `services/pipeline/pyproject.toml`：添加 `license = "LicenseRef-Proprietary"`
- 根 `package.json`（如有）：同上

### 裁决 3：shared-types `licenseEnum` 无需额外兼容层

`CC-BY` → `CC_BY` 是非向后兼容变更，但：
1. Phase 0 无消费者（无前端页面使用 `Book.license`、无管线写入 `books.license`）
2. 种子数据 `data/dictionaries/` 中无 `books` 种子（仅 persons / places / polities / reign_eras / disamb）
3. 因此直接改值，不需要迁移脚本或 alias

---

## 影响

- **shared-types**：`licenseEnum` 值变更 → Pydantic 模型重生成
- **GraphQL SDL**：新增 `License` enum，`Book.license` 从 `String!` 改为 `License!`（**breaking change**，但 Phase 0 无消费者）
- **graphql-codegen**：TypeScript `License` enum 类型自动生成
- **graphql-inspector**：会报 breaking change（`String!` → `License!`），但在 warn-only 模式下不阻断
- **Package.json**：全部 workspace 包新增 license 字段（无功能影响）

---

## 实施 Checklist

以下步骤供后端工程师在 T-P0-003-F1 session 中执行：

### Phase 1：shared-types 变更
- [ ] `packages/shared-types/src/enums.ts`：`"CC-BY"` → `"CC_BY"`
- [ ] `pnpm --filter @huadian/shared-types build`
- [ ] `scripts/gen-types.sh`（重生成 JSON Schema + Pydantic）
- [ ] 确认 `services/pipeline/src/huadian_pipeline/generated/` 中 Pydantic 模型更新

### Phase 2：GraphQL SDL 变更
- [ ] `services/api/src/schema/enums.graphql`：新增 `enum License { CC0 CC_BY PUBLIC_DOMAIN PROPRIETARY UNKNOWN }`
- [ ] `services/api/src/schema/a-sources.graphql`：`license: String!` → `license: License!`
- [ ] `pnpm --filter @huadian/api codegen`（重生成 TS types）
- [ ] `pnpm --filter @huadian/api schema:merge`（重生成 snapshot）
- [ ] 确认 `services/api/src/__generated__/graphql.ts` 中有 `License` enum

### Phase 3：Package license 字段
- [ ] 所有 `package.json`（`apps/web` / `services/api` / `packages/*`）添加 `"license": "UNLICENSED"`
- [ ] `services/pipeline/pyproject.toml` 添加 `license = "LicenseRef-Proprietary"`
- [ ] 根 `package.json`（如有）添加 `"license": "UNLICENSED"`

### Phase 4：验证
- [ ] `pnpm -r build && pnpm lint && pnpm typecheck` 全绿
- [ ] `pnpm -r codegen && git diff --exit-code` 通过
- [ ] basedpyright（Pipeline）0/0/0

---

## 回滚方案

1. shared-types `licenseEnum` 改回 `"CC-BY"` + GraphQL `Book.license` 改回 `String!`
2. 删除 `enums.graphql` 中的 `License` enum
3. 删除各包的 `"license"` 字段
4. 重跑 codegen

Phase 0 无数据迁移，回滚零成本。

## 相关链接

- **触发文件**：`docs/tasks/T-P0-003-F1-license-field.md`
- **宪法**：C-10（类型端到端一致）、C-14（许可证与版权前置）
- **前置 ADR**：ADR-006（U-04 商业化推迟 Phase 3）、ADR-007（Monorepo 包结构）
- **SDL 白名单**：T-P0-003 R-3（本 ADR 不突破白名单，新增 enum 非 scalar）
