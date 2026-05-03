# Sandbox / CI Dogfood Postgres (Sprint T T-V03-FW-005)

> Status: v0.3.0 (Sprint T Stage 1 批 1 first abstraction / 2026-04-30)
> Files: `dogfood-postgres-compose.yml` + `dogfood-bootstrap.sql` + `dogfood-seed.sql`
> Goal: Let framework dogfood scripts run **without** access to the production DB

---

## 0. 这是什么

3 个文件让任何贡献者（包括 sandbox / CI 环境）能在本地启一个最小化 Postgres 容器，加载与生产 schema **结构兼容** 的 7 张表 + 一组 minimal seed fixtures，然后跑 framework dogfood 脚本。

vs 之前必须在 user local Terminal 跑 dogfood（因为生产 DB 在 `localhost:5433`，sandbox / CI 不可达）。

---

## 1. 文件清单

| 文件 | 内容 |
|------|------|
| `dogfood-postgres-compose.yml` | Docker compose / 1 service：`postgres:16-alpine` on **port 5434**（避开生产 5433）|
| `dogfood-bootstrap.sql` | Schema：7 表（persons / person_names / dictionary_sources / dictionary_entries / seed_mappings / pending_merge_reviews / triage_decisions）+ 索引 + CHECK 约束 |
| `dogfood-seed.sql` | Seed 数据：5 persons + 8 person_names + 1 dict_source + 3 dict_entries + 3 seed_mappings + 3 pending_merge_reviews + 5 triage_decisions |

---

## 2. Quick Start

```bash
# 1. 在 sandbox / CI / 你的 local 环境（任何有 docker 的地方）启动 dogfood DB
cd scripts
docker compose -f dogfood-postgres-compose.yml up -d

# 2. 等待容器 healthy
docker ps --filter "name=huadian-dogfood-postgres" --format 'table {{.Names}}\t{{.Status}}'

# 3. 从项目根跑 framework dogfood（注意 5434 端口 + huadian_dogfood DB 名）
cd ..
PYTHONPATH=$(pwd) \
    DATABASE_URL=postgresql://huadian:huadian_dev@localhost:5434/huadian_dogfood \
    python3 -m framework.audit_triage.examples.huadian_classics.test_soft_equivalent

# 4. 完成后清理（-v 删除 volume / 数据消失，重新 up 会重新 seed）
cd scripts
docker compose -f dogfood-postgres-compose.yml down -v
```

期望输出（最后一行）：

```
✓ SOFT-EQUIVALENT — Sprint Q Stage 1.13 dogfood gate PASSED
  framework path == production path on this DB snapshot
```

详细 dogfood 数据点（基于本 seed）：

| 调用 | framework 返回 | production 直 SQL 返回 | 结果 |
|------|---------------|---------------------|------|
| `list_pending(limit=20)` | 3 + 3 = **6 items**（3 seed_mapping + 3 guard_blocked_merge）| 同 | ✓ 一致 |
| `decisions_for_surface('周成王', limit=5)` | **4 decisions** | 同 | ✓ 一致 |
| `decisions_for_surface('楚成王', limit=5)` | **0 decisions** | 同 | ✓ 一致 |
| `decisions_for_surface('成王', limit=5)` | **0 decisions** | 同 | ✓ 一致（surface_snapshot exact match）|
| `decisions_for_surface('项羽', limit=5)` | **1 decision** | 同 | ✓ 一致 |

---

## 3. 设计取舍

### 3.1 Approach B（最小 schema 子集 / 非完整生产 schema）

**采用**：仅 7 张表（framework dogfood 实际触及的）。

**未采用**：复用 `services/api/migrations/0000_lame_roughhouse.sql` (36 表) + `services/pipeline/migrations/0001..0014` (14 incremental)。

**理由**：
- 生产 schema 涉及 36+ 表，多数与 framework dogfood 无关（events / artifacts / extractions_history / etc）
- Approach B 让 dogfood DB 启动 < 5s（vs 全量 schema 可能 30s+）
- Approach B 让 `dogfood-bootstrap.sql` 单文件可读（~150 行 vs 552 行 0000）
- 跨域 fork 案例方更易理解 + 改用自己的 schema

### 3.2 端口 5434（vs 生产 5433）

**采用**：5434。

**理由**：让 dogfood DB 与生产 DB **可同时跑**——你在做 dogfood 的同时不用关生产 Postgres 容器。

### 3.3 仅支持 `test_soft_equivalent.py`，不支持 `test_byte_identical.py`

**采用**：只让 audit_triage soft-equivalent dogfood 跑通。

**未采用**：让 identity_resolver byte-identical dogfood 也用 Docker DB。

**理由**：
- byte-identical 需要 **真生产数据**（729 active persons + 17 guard 拦截 + 实际 dict 内容）
- Fake fixtures 5 persons 无法保证 framework path == production path 的 byte-level 等价
- → byte-identical 保持 user-local-only；soft-equivalent 走 Docker

`test_byte_identical.py` 仍然在 user local Terminal 跑（连接生产 5433）；不是本 sprint 的 scope。

---

## 4. Sync 责任

per `.pre-commit-config.yaml` hook `services-framework-audit-triage-sync` + `methodology/02-sprint-governance-pattern.md` v0.1.1 §13 跨 stack 抽象 pattern：

当生产 schema (`services/api/migrations/0000_*.sql` 或 `services/pipeline/migrations/00XX_*.sql`) 改动涉及本 7 张表时，需评估 `dogfood-bootstrap.sql` 是否同步。

**已知偏离**（为简化 / fixture 性质 / 不阻塞 dogfood 等价性）：

| 字段 | 生产 | dogfood | 影响 |
|------|------|--------|------|
| `persons.name` | 复杂 i18n JSONB schema (≥ 10 keys) | 简化 `{"zh-Hans": "...", "en": "..."}` 2 keys | 无（test_soft_equivalent 不读 name 字段细节）|
| FK constraints | 完整 ON DELETE CASCADE / RESTRICT 配置 | 仅 dictionary_sources → dictionary_entries / persons → person_names 加 CASCADE；其他用 logical FK | 无（test_soft_equivalent 不删数据）|
| index 集 | 生产有 ~40 索引（含 GIN / pg_trgm 等）| dogfood 仅 ~8 关键索引 | dogfood 性能略低，但 5 行数据不感知 |

如发现新偏离破坏 dogfood，请加到本表 + retro §3.x。

---

## 5. 跨域 fork 案例方启示

如果你 fork framework 到你的领域（per methodology/02 §13.4），dogfood 基础设施可以这样做：

1. 复制本目录为 `scripts/dogfood-postgres-compose.yml` + 改 image 名 + 改 DB 名（`huadian_dogfood` → `your_domain_dogfood`）
2. 改 `dogfood-bootstrap.sql`：仅保留你的领域 framework dogfood 触及的表（每个 framework 模块的 `examples/your_domain/asyncpg_store.py` 决定表清单）
3. 改 `dogfood-seed.sql`：你的领域典型 entity 5-10 个 + 各 review 表 ≥ 1 行
4. 改 `test_soft_equivalent.py` 中 SQL 直 query（`_PROD_LIST_QUERY` 等）→ 你的领域生产 SQL 等价

整套 infra 是 fork 友好的（200 行 SQL + 50 行 yaml + 100 行 README，1-2 小时即可改完）。

---

## 6. 故障排查

### 6.1 容器起不来 / port 5434 被占

```bash
docker ps --filter "publish=5434"
# 如果有别的进程占 5434，改 dogfood-postgres-compose.yml 的 port mapping
```

### 6.2 `test_soft_equivalent.py` 报 `connection refused`

- 确认容器 healthy（见 §2 step 2）
- 确认 `DATABASE_URL` 端口写对（5434 not 5433）
- 确认 DB 名 `huadian_dogfood` 拼写正确

### 6.3 `test_soft_equivalent.py` 行数 mismatch

- 重启容器 + `-v` 删除 volume 重新 seed：`docker compose -f dogfood-postgres-compose.yml down -v && up -d`
- 检查 `dogfood-seed.sql` 有没有被 production migration 执行后覆盖（不应该 / 端口隔离应保证）

---

## 7. 版本信息

| Version | Date | Sprint | Change |
|---------|------|--------|--------|
| v0.3.0 | 2026-04-30 | Sprint T 批 1 (T-V03-FW-005) | 初版（compose + bootstrap.sql 7 表 + seed.sql + 本 README）|

---

> 本目录是 framework v0.3.0 release 的 dogfood 基础设施一部分。
> 详见 `framework/RELEASE_NOTES_v0.3.md` + `docs/sprint-logs/sprint-t/`.
