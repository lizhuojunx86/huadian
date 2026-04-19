# T-P1-005: 统一 migration 入口（Drizzle + pipeline SQL 双轨合一）

- **状态**：registered
- **主导角色**：DevOps + 后端工程师
- **所属 Phase**：Phase 1（技术债）
- **依赖任务**：无
- **创建日期**：2026-04-19
- **登记来源**：CI 基建修复（b55beb8 / 0a4aa78）衍生债

## 目标

消除 Drizzle schema 迁移（`services/api/src/db-migrate.ts`）与 pipeline 独占 SQL 迁移
（`services/pipeline/migrations/*.sql`）并行双入口的漂移风险，让 `pnpm db:migrate`
和 `pnpm db:reset` 单一入口即可把数据库带到"完整 schema"状态。

## 背景

**双轨现状**：
- **Drizzle 轨**：`services/api/drizzle/*` 由 `drizzle-kit generate` 产出，`pnpm --filter @huadian/api db:migrate` 应用；覆盖 33 张业务表
- **Pipeline 轨**：`services/pipeline/migrations/0002_add_identity_merge_support.sql` 等；创建 pipeline 独占对象：
  - `person_merge_log` 表（T-P0-011 跨 chunk 身份消歧，ADR-010 可逆性审计）
  - `idx_persons_merged_into` 部分索引
  - 0003 定点 DELETE 数据修复（T-P0-015 相关）
  - （未来可能扩展：qc_violations、llm_call_audit 等 pipeline 专属表）

**触发事件**：2026-04-19 CI #76/#77 红灯 — T-P1-002 引入 `person-names-dedup.integration.test.ts`，
其中 `INSERT INTO person_merge_log` 在 CI 触发 `relation "person_merge_log" does not exist`。
根因是 CI 从来没跑过 pipeline SQL 迁移；本地手工 `psql -f` 习惯掩盖漏洞。

**临时修复**：ci.yml 新增 Step 4c for-loop `psql -f` 跑 `services/pipeline/migrations/*.sql`（b55beb8）。
该修复只解决 CI；本地 `pnpm db:migrate` / `db:reset` 仍只覆盖 Drizzle 一半。

## 范围（IN SCOPE）

1. `pnpm db:migrate` 在 Drizzle 迁移后串联 pipeline SQL 迁移
2. `pnpm db:reset` 同步更新（drop-all → Drizzle migrate → pipeline SQL）
3. CI ci.yml Step 4c 退化为一句 `pnpm db:migrate`（一致性）
4. 文档更新：`docs/development.md` 或 README 说明"单入口"约定
5. 迁移执行幂等性 re-check（防止重复 apply 报错）

## 范围（OUT OF SCOPE）

- 把 pipeline 独占表迁入 Drizzle schema 管理（破坏 pipeline 独占边界的重大决策，需单独 ADR）
- 引入 sqitch/flyway 等第三方 migration runner（过重，Phase 1 不必要）
- 迁移文件命名统一（Drizzle 用数字前缀，pipeline 也用 0002/0003 — 已兼容，无需改）

## 方案候选

### 方向 A：追加执行（推荐）

`services/api/src/db-migrate.ts` 在 drizzle migrate 完成后：
```ts
// After drizzle migrate
const pipelineMigrationsDir = path.resolve(__dirname, "../../pipeline/migrations");
const files = fs.readdirSync(pipelineMigrationsDir)
  .filter(f => f.endsWith(".sql"))
  .sort();
for (const f of files) {
  const sql = fs.readFileSync(path.join(pipelineMigrationsDir, f), "utf8");
  await pgClient.query(sql);
  console.info(`[pipeline-migrate] applied ${f}`);
}
```

**优点**：单入口；pipeline 独占边界保留；改动局部；CI Step 4c 可删
**缺点**：api 包读 pipeline 包的文件路径，耦合增加（可接受）
**幂等性**：pipeline 迁移已用 IF NOT EXISTS / 定点 WHERE 写成幂等，重复 apply 安全

### 方向 B：Drizzle 接管（重）

把 `person_merge_log`、`idx_persons_merged_into` 等搬进 Drizzle schema 定义，
删除 `services/pipeline/migrations/*.sql`。

**优点**：真正的单轨
**缺点**：违反 pipeline 独占表边界；需重生成 Drizzle 迁移；需新 ADR 定性决策

### 方向 C：独立 runner（过重）

引入 sqitch/flyway/goose 统一 apply Drizzle-generated SQL + pipeline SQL。

**优点**：正统
**缺点**：引入新依赖 + 新学习曲线；Phase 1 阶段投入产出比低

## 建议决策

**方向 A**。低风险、局部改动、消除 CI Step 4c 临时 workaround，完整保留 pipeline 独占设计。

## 风险

| 风险 | 缓解 |
|------|------|
| pipeline 迁移顺序假设（与 Drizzle 后）变化 | 在 db-migrate.ts 注释固化顺序 + 在 pipeline migrations 顶部声明依赖 |
| 某条 pipeline 迁移意外非幂等 | S-3 前逐条 re-verify 幂等性，必要时改写 |
| 本地 `pnpm db:reset` 旧行为改变 | CHANGELOG 明示；保留一个兼容 flag 过渡 |

## 工作流

### S-0：任务卡
本文件。

### S-1：现状调研
- 盘点 `services/pipeline/migrations/*.sql` 所有文件的幂等性
- 验证 `pnpm db:migrate` 当前行为（日志路径）
- 交付：短报告（哪些迁移、幂等性状态）

### S-2：方案设计
- 决策方向 A / B / C
- 选定后写 ADR 或短决策记录（如选 A，可省 ADR 只记 CHANGELOG）

### S-3：实施
- 3.1 修改 `services/api/src/db-migrate.ts` 追加 pipeline SQL 应用步骤
- 3.2 修改 `services/api/src/db-reset.ts`（如有）同步
- 3.3 退化 `.github/workflows/ci.yml` Step 4c → 删除，让 Step 4b `pnpm db:migrate` 全包
- 3.4 文档更新（README / docs/development.md）

### S-4：验证
- 本地 `pnpm db:reset` 验证全量 schema 正确
- CI 跑一轮验证不依赖 Step 4c 也能绿
- integration tests 全绿

### S-5：收尾
- STATUS / CHANGELOG 更新
- 关闭本任务，CI Step 4c workaround 标记为 superseded

## 验收标准

- [ ] `pnpm db:migrate` 在 fresh DB 上一次性产出 Drizzle + pipeline 全部 schema
- [ ] `pnpm db:reset` 行为一致
- [ ] CI 不再需要 Step 4c（或 Step 4c 简化为 `pnpm db:migrate`）
- [ ] `person-names-dedup.integration.test.ts` 在只跑 Drizzle migrate 的环境下仍能通过（反向验证）
- [ ] 所有现有测试保持全绿

## 备注

- 本任务不阻塞 β 路线（《尚书·尧典/舜典》摄入），但建议在 T-P0-006 扩量跑之前闭环
- CI Step 4c 作为临时修复已在 b55beb8 登记，移除时需同步清理 ci.yml 注释
