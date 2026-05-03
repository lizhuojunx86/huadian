# HuaDian Classics — audit_triage Reference Impl

> Status: v0.1 (Sprint Q Stage 1 first abstraction)
> Date: 2026-04-30
> License: Apache 2.0
> Source: production at `services/api/src/services/triage.service.ts` (TypeScript) + `services/pipeline/migrations/0014_add_triage_decisions.sql`

## 0. 目的

This directory is the **reference implementation** of the `audit_triage` framework for the HuaDian classics domain. It mirrors the production TypeScript implementation in Python + asyncpg, so that:

1. Cross-domain forks have a complete working example to copy + modify
2. The framework can be soft-equivalent dogfooded against production behavior
3. The Python framework stays in sync with production schema (any schema migration in HuaDian production triggers a parallel review of `schema.sql` here)

## 1. 文件清单

| 文件 | 职责 | 对应生产文件 |
|------|------|-------------|
| `asyncpg_store.py` | `TriageStore` impl using asyncpg pool | `services/api/src/services/triage.service.ts` (listPendingItemRows / recordTriageDecision / findNextPendingExcluding) |
| `allowlist.py` | `HistorianAllowlist` impl reading `historian-allowlist.yaml` | `services/api/src/services/triage.service.ts` HISTORIAN_ALLOWLIST + `apps/web/lib/historian-allowlist.yaml` |
| `schema.sql` | Reference DDL (copy + edit for new domain) | `services/pipeline/migrations/0014_add_triage_decisions.sql` (verbatim copy) |
| `__init__.py` | Package + public API export | — |

## 2. 与生产 TypeScript 实现的对应关系

| Framework Python | Production TypeScript |
|------------------|----------------------|
| `AsyncpgTriageStore.list_pending` | `listPendingItemRows` (services/api triage.service.ts:227) |
| `AsyncpgTriageStore.find_pending_by_id` | `findTriageItemById` (line 427) |
| `AsyncpgTriageStore.find_next_pending_excluding` | `findNextPendingExcluding` (line 860) |
| `AsyncpgTriageStore.find_decisions_for_source` | `findDecisionsForSource` (line 524) |
| `AsyncpgTriageStore.find_decisions_for_surface` | `findDecisionsForSurface` (line 546) |
| `AsyncpgTriageStore.insert_decision` | `recordTriageDecision` Step 4 INSERT (line 819) |
| `framework.audit_triage.service.record_decision` | `recordTriageDecision` orchestration (line 763) |
| `framework.audit_triage.service.encode_item_id` | `encodeTriageItemId` (line 78) |
| `framework.audit_triage.service.decode_item_id` | `decodeTriageItemId` (line 85) |
| `load_huadian_historian_allowlist` | `HISTORIAN_ALLOWLIST` constant (line 44) |
| `DEFAULT_REASON_SOURCE_TYPES` | `REASON_SOURCE_TYPES` constant (line 55) |

## 3. SQL 完全一致

`asyncpg_store.py` 中的 SQL 查询是 production TS 实现中 SQL 的**逐字 Python port**（Drizzle 的 `sql\`...\`` template literal → 普通 Python f-string）。这意味着：

- 同一 PostgreSQL 数据库，两个实现返回同样的行集（仅字段命名 camelCase vs snake_case 差别）
- `LIST` ordering 算法（surface-cluster + FIFO + tiebreaker source_id）严格一致
- INSERT 字段集 + 默认值（`downstream_applied=false` / `decided_at=now()`）一致

这是 Sprint Q Stage 1.13 dogfood `test_soft_equivalent.py` 的基础。

## 4. 与生产保持同步的责任

任何修改 production 的人都要查看本目录是否需要同步更新：

- `services/pipeline/migrations/00XX_*.sql` 改 schema → 同步更新 `schema.sql` + 评估 `asyncpg_store.py` SQL
- `services/api/src/services/triage.service.ts` 改业务逻辑 → 评估 framework `service.py` + `asyncpg_store.py`
- `services/api/src/services/triage.service.ts` 改 HISTORIAN_ALLOWLIST → 同步更新 `allowlist.py:_HARD_CODED_ALLOWLIST`
- `apps/web/lib/historian-allowlist.yaml` 改 → `allowlist.py` 自动从 yaml load，无需改代码

## 5. 跨域 fork checklist

如果你要把 audit_triage 框架 fork 到法律 / 医疗 / 等领域，把本目录复制为 `examples/your_domain/` 后改：

- [ ] `asyncpg_store.py` 中的 SOURCE_SELECT SQL 改成你的领域的 pending review 表（如法律的 `contract_party_match` / `clause_revision`）
- [ ] `_row_to_pending_item` 的 raw_payload 字段集合改成你的领域字段
- [ ] `allowlist.py` 改成你的领域 historian roster yaml 路径
- [ ] `schema.sql` 中的 `triage_decisions_source_table_chk` CHECK 改成你的领域表名
- [ ] 评估是否需要自定义 `ReasonValidator`（如法律可能用 `case_law` / `contract_text` / `regulatory` 等 tags）

跨域 mapping 的更详细指南见 `framework/audit_triage/cross-domain-mapping.md`（Sprint Q 批 3 起草）。

## 6. 运行 dogfood

```bash
cd /path/to/huadian
PYTHONPATH=$(pwd) DATABASE_URL=postgresql://huadian:huadian_dev@localhost:5433/huadian \
    uv run --directory services/pipeline python \
    -m framework.audit_triage.examples.huadian_classics.test_soft_equivalent
```

期望：framework path 与 production path 在同一 production DB 上的 query 结果完全等价（行集相同 / 字段值相同 / surface-cluster ordering 一致）。

## 7. 版本信息

| Version | Date | Source | Change |
|---------|------|--------|--------|
| v0.1 | 2026-04-30 | Sprint Q Stage 1 (first abstraction) | 初版抽出（asyncpg_store + allowlist + schema.sql + README）|
