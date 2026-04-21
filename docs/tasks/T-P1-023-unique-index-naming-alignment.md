# T-P1-023: Drizzle uniqueIndex 命名与 raw SQL UNIQUE 约束不一致

- **状态**: registered
- **优先级**: P2（审美性/治理性 nit，零功能影响）
- **主导角色**: 后端工程师
- **所属 Phase**: Phase 0 tail / Phase 1 head
- **发现来源**: T-P0-025 Stage 0b review（commit 199e8ba, 2026-04-21）
- **创建日期**: 2026-04-21

---

## 1. 背景

T-P0-025 migration 0009（dictionary_sources / dictionary_entries / seed_mappings）采用 ADR-017 双写模式：
- Raw SQL 侧（`services/pipeline/migrations/0009_*.sql`）：用 `UNIQUE (col_a, col_b)` 语法，PG 自动命名为 `<table>_<col_a>_<col_b>_key`
- Drizzle 侧（`packages/db-schema/src/schema/seeds.ts`）：用 `uniqueIndex("uq_*")` 显式命名

结果：三表在 DB 实际创建了**两条等价 UNIQUE 约束/索引**（一条 PG 自动命名 + 一条 Drizzle 命名），功能等价但浪费存储，且下次 `pnpm db:migrate:generate` 会检测到命名 diff。

### 1.1 三张表受影响清单

| Table | Raw SQL 产生的自动名 | Drizzle 产生的显式名 |
|-------|-------------------|-------------------|
| dictionary_sources | `dictionary_sources_source_name_source_version_key` | `uq_dictionary_sources_name_version` |
| dictionary_entries | `dictionary_entries_source_id_external_id_key` | `uq_dictionary_entries_source_external` |
| seed_mappings | `seed_mappings_dictionary_entry_id_target_entity_type_target_entity_id_mapping_status_key` | `uq_seed_mappings_entry_target_status` |

---

## 2. 修复方案

### 方案 A — Raw SQL 加显式 CONSTRAINT 名

改 migration 0009：

```sql
-- 改前
UNIQUE (source_name, source_version)

-- 改后
CONSTRAINT uq_dictionary_sources_name_version UNIQUE (source_name, source_version)
```

三表照做。**问题**：0009 已 push 到 main，改 migration 文件等于改历史。不可行。

### 方案 B — 新 migration 0010 rename/消重（推荐）

`services/pipeline/migrations/0010_seed_unique_index_alignment.sql`：

```sql
BEGIN;
-- dictionary_sources
ALTER TABLE dictionary_sources DROP CONSTRAINT dictionary_sources_source_name_source_version_key;
-- （Drizzle uq_dictionary_sources_name_version 保留）

-- dictionary_entries
ALTER TABLE dictionary_entries DROP CONSTRAINT dictionary_entries_source_id_external_id_key;

-- seed_mappings
ALTER TABLE seed_mappings DROP CONSTRAINT seed_mappings_dictionary_entry_id_target_entity_type_target_entity_id_mapping_status_key;

COMMIT;
```

**前提**：上线时三表仍空表或数据极少，DROP CONSTRAINT 秒级操作。

### 方案 C — 接受双写，只加注释

在 seeds.ts 加注释说明双重 unique 是已知情况，不修。**成本最低，但长期审计/migration diff 会反复触发**。不推荐。

---

## 3. 建议执行时机

**Sprint B 收尾前**（Stage 5 一起做），方案 B：

- 如果 Stage 2 已往三表写入真实数据，DROP 自动名约束需要先验证没有其他代码/工具引用该约束名（例如 ON CONFLICT 语句用 `ON CONSTRAINT <name>`）
- 当前三表空表，可在 Stage 2 启动前立即做，把窗口期关掉

---

## 4. 验收标准

- [ ] migration 0010 落 prod（方案 B）
- [ ] 三表各仅保留一条 UNIQUE（Drizzle 命名的）
- [ ] `pnpm db:migrate:generate` 无 diff
- [ ] seeds.ts 无需改动
- [ ] Pipeline tests 无回归

---

## 5. 关联

- **发现来源**：T-P0-025 Stage 0b review（commit 199e8ba）
- **前置**：无（可独立执行）
- **建议捆绑**：T-P0-025 Sprint B Stage 5 收尾
- **相关 ADR**：ADR-017（Drizzle + pipeline SQL 双轨模式）

---

## 6. 备注

- 本 debt 是 ADR-017 双写模式的隐性副作用之一：两侧命名惯例不同时，DB 会出现命名冗余。T-P1-005（统一 migration 入口）长期解决方向是取消双写、单一入口，本 debt 届时一并消化。
- 当前优先级 P2：不阻塞任何功能，不影响任何查询性能（两条等价 index 共用底层 B-tree 结构时 PG 自行合并的可能性低但影响不大，占用 kB 级存储）。
