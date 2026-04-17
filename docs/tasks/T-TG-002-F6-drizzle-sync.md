# T-TG-002-F6: Drizzle Schema 同步（traceguard_raw + UNIQUE INDEX + 列注释）

- **状态**：backlog
- **主导角色**：后端工程师
- **协作角色**：DevOps（根级 pytest importmode 同步）
- **依赖任务**：T-TG-002 ✅（pipeline-side migration 已就位）
- **所属 Phase**：Phase 0
- **创建日期**：2026-04-17
- **来源**：T-TG-002 S-7 审计层 Q-A1 / Q-A3 / Q-A5

---

## 背景

T-TG-002 S-7 在 Python pipeline 侧落地了 `migrations/0001_add_traceguard_raw_and_idempotent_idx.sql`（idempotent DDL），但 Drizzle schema（TS 侧）未同步。两侧 schema 漂移会导致 `drizzle-kit generate` 产出空 migration 而非增量。

## 范围

### 1. `packages/db-schema/src/schema/pipeline.ts` — `extractionsHistory` 表

```diff
+ traceguardRaw: jsonb("traceguard_raw"),
```

并在 table builder 中添加 unique index：

```diff
+ uniqueIndex("idx_ext_hist_idempotent").on(table.paragraphId, table.step, table.promptVersion),
```

### 2. `packages/db-schema/src/schema/pipeline.ts` — `llmCalls` 表

更新 `traceguardCheckpointId` 列注释（语义变更）：

```diff
- traceguardCheckpointId: uuid("traceguard_checkpoint_id"),
+ traceguardCheckpointId: uuid("traceguard_checkpoint_id"),
+ // Semantic: 华典 adapter-generated uuid4 per checkpoint invocation
+ // (not TG-native — TG has no checkpoint ID concept as of 0.1.0).
+ // Used to join llm_calls ↔ extractions_history.traceguard_raw.checkpoint_run_id.
```

### 3. 运行 `drizzle-kit generate`

生成增量 migration SQL，验证与 pipeline-side `0001_*.sql` 等价。

### 4. 根级 `pyproject.toml` pytest importmode 同步

如果根级 `pyproject.toml` 有 `[tool.pytest.ini_options]`，添加 `import_mode = "prepend"` 以与 `services/pipeline/pyproject.toml` 保持一致。

## 验收标准

1. `pnpm drizzle-kit generate` 不产生多余 diff（schema 和 DB 已对齐）
2. `pnpm -r build && pnpm -r typecheck` 全绿
3. `traceguard_checkpoint_id` 列注释已更新
4. 根级 pytest config 已同步（若适用）

## 相关链接

- T-TG-002 S-7 audit.py：`services/pipeline/src/huadian_pipeline/qc/audit.py`
- Pipeline-side migration：`services/pipeline/migrations/0001_add_traceguard_raw_and_idempotent_idx.sql`
- Drizzle schema：`packages/db-schema/src/schema/pipeline.ts`
