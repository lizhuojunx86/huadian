# T-P0-003-F1: License 字段���范化

- **状态**：backlog
- **主导角色**：后端工程师 + 首席架构师
- **所属 Phase**：Phase 0（不阻塞后续��务）
- **来源**：T-P0-003 subtask 7 遗留 L-1
- **创建日期**：2026-04-17

## 问题描述

### 1. GraphQL Book.license 暂用 String 而非 Enum

`packages/shared-types/src/enums.ts` 的 `licenseEnum` 包含 `"CC-BY"`，其中的
连字符在 GraphQL enum 值语法中不合法（enum 值只允许 `[_A-Za-z][_0-9A-Za-z]*`）。

T-P0-003 暂将 `Book.license` 暴露为 `String!`（而非 `License` enum）以避免 SDL
解析失败。参见 `services/api/src/schema/a-sources.graphql` 内注释。

**需要架构师决定规范���方式**：
- **Option A**：shared-types 的 `CC-BY` 改为 `CC_BY`，GraphQL 侧用 `License` enum
- **Option B**：保留 String + zod 校验（resolver 返回值仍匹配 licenseEnum，但
  GraphQL 层不做 enum 约束）
- **Option C**：自定义 scalar `License`（需要新 ADR，R-3 白名单限制）

### 2. services/api/package.json 缺 license 字段

`services/api/package.json` 未声明 `"license"` 字段。虽然 `"private": true` 的包
不强制要求，但项目后续可能开源或商业化（ADR-006 U-04），建议架构师确定统一方案：
- `UNLICENSED`（私有、不授权）
- `proprietary`（私有、商业）
- 具体 SPDX 标识符（如 `MIT` / `Apache-2.0`）

同一决策应覆盖所有 workspace 包（apps/web / services/api / services/pipeline /
packages/*），建议开独立 ADR。

## 影响

- 不阻塞 T-P0-007 / T-P0-008 / T-P0-005
- 在 Phase 1 上线前决定即可
