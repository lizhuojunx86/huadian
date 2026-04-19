# T-P1-005 — 统一 migration 入口（Drizzle + pipeline SQL 双轨合一）

- **优先级**：P1（中）
- **登记日期**：2026-04-19
- **来源**：CI 红灯修复（b55beb8 + 0a4aa78）
- **状态**：open

## 现象

`pnpm db:migrate`（对应 `services/api/src/db-migrate.ts`）只跑 Drizzle 迁移。
Pipeline 独占对象（`person_merge_log` 表、`idx_persons_merged_into` 部分索引等）
定义在 `services/pipeline/migrations/*.sql`，需要独立执行。

本地开发通过手工 `psql -f` 应用 pipeline SQL，掩盖了入口双轨问题。
CI 最初只跑 `pnpm db:migrate`，导致 `person_merge_log` 缺失，T-P1-002 的
`person-names-dedup.integration.test.ts` 在 CI #76/#77 撞红。

## 临时修复（已落地）

- **b55beb8** — `.github/workflows/ci.yml` 新增 Step 4c：Drizzle migrate 后
  for-loop `psql -v ON_ERROR_STOP=1 -f services/pipeline/migrations/*.sql`
- 所有 pipeline 迁移已写成幂等（IF NOT EXISTS / 定点 WHERE / UUID 级 DELETE）
- CI #79 / #80 验证全绿

## 影响范围

- **Local dev**：新人 onboarding 会踩坑（`pnpm db:reset` 后缺 `person_merge_log`）
- **CI**：临时 workaround 正常工作，但 ci.yml Step 4c 逻辑游离在 app 之外
- **Prod**：视部署脚本定义；若部署脚本仅跑 `pnpm db:migrate`，prod 也会缺表（需独立核查）

## 修复方向

参考 `docs/tasks/T-P1-005-unify-migration-entrypoint.md`：

1. **方向 A（推荐）**：`db-migrate.ts` 末尾追加 pipeline SQL 应用步骤 — 单入口、保留 pipeline 独占边界
2. **方向 B**：把 pipeline 独占表搬入 Drizzle schema — 违反边界，需单独 ADR
3. **方向 C**：引入 sqitch/flyway — 过重

## 建议触发时机

在 T-P0-006（扩量跑周本纪及以后）开始前闭环，避免 prod 环境漂移影响生产数据加载。

## 关联

- 触发 commit: b55beb8, 0a4aa78
- 触发 CI 红灯: #76, #77, #78
- 任务卡: `docs/tasks/T-P1-005-unify-migration-entrypoint.md`
- 相关 ADR: ADR-010（跨 chunk 身份消歧，引入 `person_merge_log`）
