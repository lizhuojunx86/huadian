# ADR-017 — Migration Rollback Strategy (forward-only + pg_dump anchor)

- **Status**: Accepted
- **Date**: 2026-04-19
- **Authors**: 首席架构师
- **Related**:
  - ADR-014（canonical merge execution model — 4 闸门协议的来源）
  - `.claude/agents/pipeline-engineer.md` §4 闸门敏感操作协议
  - T-P0-006-β retro（β rollback 实战验证 pg_dump + 4 闸门有效）
  - arch-audit FAIL #2（migration 无 DOWN 文件）

---

## 1. Context

### 1.1 arch-audit FAIL #2

项目 arch-audit 报告 FAIL #2：schema migration 缺少 `.down.sql`（回滚脚本）。当前项目使用两套 migration 入口：

- **Drizzle-kit**（`services/api/migrations/`）：forward-only，`drizzle-kit generate` 只产 up 文件
- **Pipeline raw SQL**（`services/pipeline/migrations/`）：手写幂等 DDL，无 down 对应物

### 1.2 β rollback 实战验证

T-P0-006-β S-5 的 model-B 误用触发了一次真实的数据 rollback。实际执行的回滚路径：

1. 从 pg_dump 快照确认数据可恢复边界
2. 手写 rollback SQL（`ops/rollback/T-P0-006-beta-s5-rollback.sql`）恢复 3 条 merge
3. 通过 `apply_merges()` 重跑正确模型
4. V1-V4 invariant 全绿验证

全程未使用任何 `.down.sql`，而是依赖 **pg_dump 快照 + 4 闸门协议 + 手写修复 SQL**。这套流程在 β 压力下实战验证有效。

### 1.3 `.down.sql` 的根本局限

写 reversible migration 在**数据层**无法保证安全回滚：

- `ALTER TABLE ADD COLUMN` 的 down 是 `DROP COLUMN`——但 column 可能已被写入数据，DROP 就是数据丢失
- `CREATE INDEX` 的 down 是 `DROP INDEX`——安全，但对 partial unique index（ADR-013）而言，down 可能引发 slug 冲突
- 任何涉及 `UPDATE` / `INSERT` 的 data-fixup migration 的 down 要求记住旧值——本质上是写一个 undo log，复杂度不亚于 migration 本身
- Drizzle-kit 本身不生成 down 文件，强行手写与工具链不一致

## 2. Decision

### 2.1 Schema migration forward-only

**Drizzle-kit**（`services/api/migrations/`）和 **pipeline raw SQL**（`services/pipeline/migrations/`）均采用 forward-only 策略，**不要求编写 `.down.sql`**。

### 2.2 回滚锚 = pg_dump 快照 + 4 闸门协议

回滚能力由以下机制组合保障：

1. **pg_dump 快照**：任何破坏性 schema 操作执行前，必须先完成 pg_dump（pipeline-engineer.md §4 闸门 1）。快照是回滚的唯一物理锚点。
2. **4 闸门协议**：pg_dump / schema 确认 / artifact 状态 / dry-run RETURNING，每个闸门须架构师显式 ACK（详见 pipeline-engineer.md §4 闸门）。
3. **手写修复 SQL**：当需要回滚时，基于 pg_dump 快照和操作记录手写 forward-fix SQL（而非 reverse），放入 `ops/rollback/` 目录。

### 2.3 破坏性 schema 操作的额外要求

以下操作类型在任务卡或 ADR 中**必须明示 rollback 路径与 pg_dump 时点**：

- `DROP TABLE` / `DROP COLUMN`
- `ALTER COLUMN ... SET NOT NULL`（可能因数据不满足而失败）
- `ALTER COLUMN ... TYPE`（类型转换可能有损）
- FK 改向（`ALTER CONSTRAINT` / `DROP + ADD FOREIGN KEY`）
- 批量 `DELETE` / `UPDATE`（data-fixup 类 migration）

明示格式：

```
⚠️ Rollback 路径
- pg_dump 时点：[闸门 1 的快照标识]
- 恢复方式：[pg_restore 全库 / 手写 forward-fix SQL / 特定表 restore]
- 预估恢复时间：[基于数据量的估算]
```

### 2.4 Data-fixup migration 建议 idempotent

Pipeline raw SQL migration（`services/pipeline/migrations/*.sql`）**建议**但不强制编写为 idempotent（`IF NOT EXISTS` / `ON CONFLICT DO NOTHING` / `WHERE NOT EXISTS` 等）。Idempotent migration 可安全重跑，降低 forward-fix 复杂度。

## 3. Rationale

| 维度 | forward-only + pg_dump | 写 `.down.sql` |
|------|----------------------|----------------|
| 数据安全 | pg_dump 是物理快照，恢复确定性 100% | down 只能恢复 schema，无法保证数据完整回滚 |
| 工具链一致性 | 与 Drizzle-kit forward-only 设计一致 | 需要额外手写，与 Drizzle 工作流脱节 |
| 维护成本 | 只需维护 pg_dump 流程 | 每个 migration 翻倍工作量，且 down 很少被测试 |
| 实战验证 | β rollback 已验证有效 | 从未被使用过，可信度低 |
| 复杂场景覆盖 | 通过手写 forward-fix SQL 灵活应对 | data-fixup 的 down 逻辑复杂度爆炸 |

## 4. Consequences

### 正面

- arch-audit FAIL #2 → PASS（有明文策略覆盖 migration 回滚）
- alpha 期间新 migration 走此协议，无需纠结写 down
- pg_dump 快照作为单一回滚锚点，职责清晰
- 4 闸门协议将回滚决策前置到操作前（预防优于补救）

### 负面

- pg_dump 快照需要存储空间（当前数据量小，可忽略；未来 GB 级需评估存储策略）
- 全库 pg_restore 在大数据量下恢复时间长（响应：可做 table-level restore 缩小范围）
- 放弃 `.down.sql` 意味着无法自动化 rollback（响应：手写 forward-fix SQL 更安全，自动化 rollback 在数据层本就是幻觉）

## 5. Non-goals

- 本 ADR **不替代**业务级 transaction rollback（应用层事务回滚由代码 `try/catch + ROLLBACK` 处理）
- 本 ADR **不要求**写 reversible migration（这正是本 ADR 拒绝的方案）
- 本 ADR **不覆盖**应用部署回滚（蓝绿 / 金丝雀等 K8s 层面策略，属 DevOps 范畴）
- 本 ADR **不处理** Drizzle-kit 与 pipeline SQL 的双轨统一（属 T-P1-005 范畴）

## 6. Alternatives Considered

### 6.1 写 `.down.sql`（rejected）

- 无法保证数据回滚（见 §1.3）
- 与 Drizzle-kit 工具链不一致
- 增加维护负担但几乎不被使用
- β 实战已验证 pg_dump 路径更可靠

### 6.2 使用 sqitch / flyway 等 migration 框架（rejected）

- 引入新依赖，增加技术栈复杂度
- 当前 Drizzle-kit + pipeline raw SQL 双轨已够用
- 统一入口是 T-P1-005 的范畴，不需要换框架

## 7. Compliance

本 ADR 生效后：

1. **新 migration 不需要写 `.down.sql`**——arch-audit 规则相应更新
2. **破坏性 schema 操作必须在任务卡/ADR 中明示 rollback 路径**（§2.3）
3. **所有高风险 DB 操作走 4 闸门协议**（引 pipeline-engineer.md §4 闸门）
4. **pg_dump 快照为唯一回滚物理锚点**——操作前必做，操作后保留至少到下一次成功验证
