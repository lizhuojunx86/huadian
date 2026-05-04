# Cross-Stack Abstraction Pattern — Production Stack ≠ Framework Stack

> Status: **Draft v0.1**
> Date: 2026-04-30
> Owner: 首席架构师
> Source: 华典智谱 Sprint Q audit_triage（TS prod → Python framework）+ Sprint T T-V03-FW-005 Docker dogfood + methodology/02 v0.1.1 §13 cross-stack abstraction pattern（首次提出 / 本 doc 详细抽象）

---

## 0. TL;DR

> **Cross-Stack Abstraction Pattern** = 当 framework 抽象的目标 stack 与生产实现的 stack 不同时（如 production = TypeScript / framework = Python），如何**保留生产正确性 + 提供 framework 可 fork 性 + dogfood 可验证**的工程模式。

methodology/02 v0.1.1 §13 首次提出此 pattern（4 段简介 + Sprint Q audit_triage 实证锚点）。本文件是 **first-class 详细抽象**：

1. 何时该用 cross-stack 抽象（vs same-stack 简单移植 / vs 跨 stack rewrite）
2. 标准三步做法（SQL 逐字 port + 业务逻辑分层 + soft-equivalent dogfood）
3. 3 种 dogfood 等价性等级（byte-identical / soft-equivalent + self-test / soft-equivalent 跨 stack）
4. 3 种 stack 关系组合的对应实证（华典智谱 Sprint N + O + Q）
5. dogfood infra 选项（user local DB vs Docker compose / per Sprint T 实证）
6. 跨域 fork 案例方启示
7. 反模式 5 项

实证（华典智谱）：
- Sprint Q audit_triage 抽象 = 跨 stack first 实证（TS prod 922 lines → Python framework 14 files / soft-equivalent dogfood ✅ user local PASSED）
- Sprint T T-V03-FW-005 Docker dogfood infra = sandbox / CI 可跑 framework dogfood（Approach B 7 表 minimum subset / dogfood ✅ user local Docker PASSED）

---

## 1. 何时该用 cross-stack 抽象

### 1.1 三种触发情境

| 情境 | 推荐做法 |
|------|---------|
| 生产代码与 framework **同 stack**（如都是 Python）| Same-stack 简单移植 + byte-identical dogfood（per methodology/03 §9.1 identity_resolver 实证 / Sprint N）|
| 生产代码与 framework **不同 stack**（如 TS prod / Python framework）| **Cross-stack abstraction pattern（本 doc）**（per methodology/05 §7 audit_triage 实证 / Sprint Q）|
| 生产代码 stack **重写到 framework stack** | Cross-stack rewrite — 不是抽象 / 不在本 doc scope |

### 1.2 为什么不直接 rewrite

跨 stack rewrite（把生产 TS 重写成 Python）有 3 个 critical issue：

1. **生产用户被破坏**：生产 stack 已被 BE 工程师 / 现有用户依赖；强迫切换 stack 是非战略性 disruption
2. **维护成本翻倍**：生产 + framework 各自维护各自的 bug fix / feature
3. **跨 stack 抽象的 framework 价值损失**：若 rewrite 完成 framework 就只有 1 个 stack 实证，对跨域 fork 案例方价值降低（vs 跨 stack 抽象证明"框架可在多 stack 实例化"）

→ **Cross-stack 抽象保留两个 stack** + 通过 dogfood 保证等价性 + framework Python 是给"跨 stack 案例方 fork"用的（不是给生产用的）。

### 1.3 案例方典型场景

| 场景 | 实例 |
|------|------|
| 生产 BE 是 TS / 跨域 fork 案例方更熟 Python | 华典智谱 Sprint Q audit_triage（TS prod → Python framework）|
| 生产 BE 是 Java / 跨域 fork 案例方用 Rust | （hypothetical）法律领域 contract review framework |
| 生产 BE 是 Go / 跨域 fork 案例方用 Python | （hypothetical）医疗 PHI processing framework |

→ Cross-stack 抽象的目标 stack 应该是**跨域 fork 案例方的"普遍 stack"**（如 Python 在 KE / 数据科学领域 / 医疗 / 学术等都是默认）。

---

## 2. 标准三步做法

参考 methodology/02 §13.3，详细展开：

### 2.1 Step 1 — SQL / 共享接口逐字 port（不重新设计）

DB 层 SQL 在两个 stack 间通常完全等价（PG / MySQL / SQLite 等的 dialect 差异可忽略）。**逐字复制**：

```python
# framework/audit_triage/examples/huadian_classics/asyncpg_store.py
_SEED_SELECT = """
    SELECT
        'seed_mapping'::text AS kind,
        ...
    FROM seed_mappings sm
    JOIN dictionary_entries de ON de.id = sm.dictionary_entry_id
    WHERE sm.mapping_status = 'pending_review'
      AND sm.target_entity_type = 'person'
"""
```

**为什么不重新设计 SQL**：
- 重新设计 = 给生产 TS 引入"为 framework 而做"的不必要风险
- 重新设计 = framework 与生产 query plan 可能不同 / dogfood 等价性难保证
- 逐字 port = 框架与生产共享 query plan / index 利用 / pg_stat 监控等

**例外**：生产 SQL 包含 ORM-specific 语法（如 Drizzle 的 ` sql\`...\` ` template literal）→ 需要去除模板符 / 但保留实际 SQL 字符串。

### 2.2 Step 2 — 业务逻辑分层

```
service.py    — 纯 Python，零 DB / 零 HTTP（与生产 TS 业务逻辑等价）
store.py      — Plugin Protocol（DB-agnostic / per PEP 544）
examples/     — 具体 stack 实现（asyncpg / aiosqlite / etc）
```

每层职责：
- **service.py**：业务逻辑核心（如 `record_decision()` 的 6 步验证 + audit row 写入）/ 与生产 TS 的 `recordTriageDecision()` 函数体一一对应
- **store.py**：Protocol 定义（如 `TriageStore` 6 method）/ 由 examples 实现
- **examples/**：具体 stack 落地（如 `AsyncpgTriageStore`）/ 跨域 fork 案例方写自己的 examples/your_domain/

**关键约束**（per methodology/03 §9.2 + /05 §7）：
- service.py 不直接 import asyncpg / drizzle / 任何 ORM
- store.py 仅 Protocol 定义 / 不实现具体 DB 操作
- examples/ 可以 import 任何 stack-specific 库

### 2.3 Step 3 — dogfood 走 soft-equivalent（非 byte-identical）

跨 stack 不能 byte-identical（DTO 命名 / serialization 差别），所以走 **soft-equivalent**：
- 比对 row 数 / 主要字段值 / ordering
- 接受 DTO shape 差异（snake_case vs camelCase）
- 接受 timestamp 序列化差异（datetime vs ISO string）
- 接受 JSON encoding 差异（Python dict vs TS object）

实证（华典智谱 Sprint Q + T）：
```python
# framework/audit_triage/examples/huadian_classics/test_soft_equivalent.py

# Path A: framework Python
fw_items, fw_total = await list_pending_items(store, limit=20)

# Path B: production TS-equivalent SQL (executed via asyncpg directly)
async with pool.acquire() as conn:
    prod_rows = await conn.fetch(_PROD_LIST_QUERY, 20)

# Compare: row count + per-row source_id + surface + ordering
for i, (fw, prod) in enumerate(zip(fw_items, prod_rows)):
    if fw.source_id != str(prod["source_id"]):
        diffs.append(f"row[{i}].source_id mismatch")
    ...
```

→ Sprint Q user local PASSED（list_pending 20/20 + decisions_for_surface 4 surfaces 全部一致）；Sprint T Docker dogfood PASSED（list_pending 6/6 + 4 surfaces 全一致）。

---

## 3. 3 种 dogfood 等价性等级

跨 stack 抽象不是"一刀切" — 实证有 3 种 dogfood 等级（per methodology/03 §9.2 + /04 §8.2 对比表合并）：

| 等级 | 适用 | 实证 | dogfood 强度 |
|------|------|------|-----------|
| **byte-identical** | 同 stack（Python → Python）+ 数据状态稳定 | Sprint N identity_resolver / 729 person 完全等价 | 最强 / 0 字段差异 |
| **soft-equivalent + self-test** | 同 stack + 数据状态可变 + 业务逻辑复杂（如 invariants）| Sprint O invariant_scaffold / 11 invariants × 0 violations + 4 self-tests catch | 强 / 主要字段一致 + 主动注入验证 |
| **soft-equivalent (跨 stack)** | 不同 stack（TS → Python / etc）| Sprint Q audit_triage / 64 pending + 7 historical decisions / Sprint T Docker dogfood / 6 + 4 surfaces 一致 | 中 / row 数 + 主要字段一致 |

**选择依据**：
- 同 stack + 数据稳定 → byte-identical（最强）
- 同 stack + 数据可变 → soft-equivalent + self-test（强 + 自验证）
- 不同 stack → soft-equivalent (跨 stack)（中 / 是本 pattern 的核心 dogfood 形式）

---

## 4. 3 种 stack 关系组合实证（华典智谱 Sprint N + O + Q）

| 维度 | identity_resolver (N) | invariant_scaffold (O) | audit_triage (Q) |
|------|----------------------|------------------------|------------------|
| 生产 stack | Python (services/pipeline) | Python (services/pipeline + tests) | TypeScript (services/api) |
| framework stack | Python | Python | Python |
| stack 关系 | **同 stack** | **同 stack** | **跨 stack** ⭐ |
| 等价性测试 | byte-identical | soft-equivalent + self-test | soft-equivalent (跨 stack) |
| Plugin Protocol 数 | 9 | 4 | 5（含 1 stub）|
| 案例耦合点 | 9 dictionary / dynasty 域属性 | 5 SQL 模板 + 4 self-test scenario | source_table 命名 + reason_source_type vocabulary |
| dogfood 数据规模 | 729 persons / 17 guards | 11 invariants × 729 persons | 64 pending + 7 historical |
| dogfood 通过率 | 100%（0 字段差异）| 100%（11/11 + 4/4）| 100%（6/6 + 4 surfaces）|

→ 跨 stack 抽象的核心**不是 stack 选择**，而是 Plugin Protocol 边界设计 + dogfood 等价性策略选择。

---

## 5. dogfood infra 选项（per Sprint T T-V03-FW-005 实证）

跨 stack 抽象的 dogfood 需要可访问的"production-like DB"。两种选项：

### 5.1 选项 A — User local DB（Sprint Q 模式）

dogfood 脚本读取 `DATABASE_URL` 指向用户本地的生产 DB：

```bash
PYTHONPATH=$(pwd) DATABASE_URL=postgresql://user:pwd@localhost:5433/prod \
    python3 -m framework.<module>.examples.<domain>.test_soft_equivalent
```

**优点**：100% 真实生产数据 / 跨 stack 等价性最高保证
**缺点**：
- 必须 user local Terminal 跑（sandbox / CI 不可达）
- 生产数据敏感时需 sanitize
- 跨域 fork 案例方需自己有 production DB

### 5.2 选项 B — Docker compose 最小 schema 子集（Sprint T 模式）

`scripts/dogfood-postgres-compose.yml` + bootstrap.sql + seed.sql：

```bash
# Bring up Docker Postgres with minimum schema + seed
cd scripts && docker compose -f dogfood-postgres-compose.yml up -d
# Run dogfood against Docker (port 5434, NOT prod 5433)
PYTHONPATH=$(pwd) DATABASE_URL=postgresql://huadian:huadian_dev@localhost:5434/huadian_dogfood \
    python3 -m framework.<module>.examples.<domain>.test_soft_equivalent
```

**优点**：
- sandbox / CI 可跑（vs 选项 A 必须 user local）
- 跨域 fork 案例方一键启动 dogfood DB
- Approach B 7 表 minimum schema 子集让 bootstrap 简单可读

**缺点**：
- Seed 数据是 fake（不是真生产）
- 只能 soft-equivalent / 不能 byte-identical（per Sprint T scripts/README §3.3）
- Schema 与生产可能 drift / 需 sync hook（per Sprint R T-V03-FW-006 + Sprint T scripts/README §4）

### 5.3 推荐策略：选项 A + B 并行

per Sprint T T-V03-FW-005 实证：
- **byte-identical dogfood** （如 Sprint N identity_resolver）→ 仅选项 A（需真生产数据）
- **soft-equivalent dogfood** （如 Sprint Q audit_triage）→ 选项 A + B 都可跑
- **CI / sandbox 跑 dogfood** → 必须选项 B
- **跨域 fork 案例方** → 主要选项 B（自己改 bootstrap + seed）

---

## 6. 跨域 fork 案例方启示

如果你 fork framework 到不同 stack 的领域：

### 6.1 ✅ 应该做的

- **复制 examples/your_domain/**：实现 framework Plugin Protocol（必要的 Store + Authz；可选的 Validator / etc）
- **逐字 port 你的领域生产 SQL 到 examples/your_domain/asyncpg_store.py**（不重新设计 SQL）
- **改 cross-domain-mapping.md**：加你的领域行（如 法律 / 医疗 / etc）
- **写 ≥ 1 dogfood 脚本**：soft-equivalent vs 你的领域生产 query
- **如有 Docker dogfood 需要**：复制 scripts/dogfood-postgres-compose.yml + 改 schema + 改 seed（Approach B）

### 6.2 ❌ 不应该做的

- ❌ **不要 rewrite 生产代码到 framework stack**（cross-stack 抽象 ≠ rewrite / per §1.2）
- ❌ **不要 byte-identical dogfood 跨 stack**（DTO shape 差异永远存在 / 浪费工时 / 永远不通）
- ❌ **不要把 GraphQL / REST 接口层也 port 到 framework**（每 BE stack 不同 / 锁死案例方）
- ❌ **不要修改 framework 主代码**（除非你发现 framework 抽象不适用你的领域 → 那就不该 fork 这个框架）
- ❌ **不要跳过 dogfood**（cross-stack 抽象的等价性保证全靠 dogfood）

---

## 7. 反模式

### 7.1 反模式：跨 stack 想做 byte-identical

❌ Python framework `result.dict() == json.loads(ts_result.toJSON())`

✅ 跨 stack soft-equivalent：比对核心字段（id / source_id / surface / decision），接受 DTO shape 差异

### 7.2 反模式：framework Python 重写生产 TS

❌ "既然抽 framework，干脆把 services/api/triage.service.ts 也用 Python 重写"

✅ 生产保持原 stack / framework 抽 Python / 两者并行 + dogfood 保等价性

### 7.3 反模式：dogfood 数据不足

❌ Docker seed 0 行 / 等价性永远 trivially 一致 / 假绿

✅ Docker seed ≥ 5-10 rows per critical table / 含多条历史 decision 触发 hint banner / 真做实证（per Sprint T seed 设计）

### 7.4 反模式：framework 不维护 Plugin Protocol 边界

❌ framework service.py 直接 `import asyncpg` / 锁死 DB driver / 案例方不能 fork

✅ service.py 只 import Protocol / examples/ 才 import 具体 driver

### 7.5 反模式：dogfood 失败时降低 dogfood 标准

❌ 跑不通 → 把 `assert framework == prod` 改成 `assert abs(len(framework) - len(prod)) < 5`

✅ dogfood 失败 → 修因（framework 或 production 一边有 bug）/ 不放低标准

---

## 8. 与其他 methodology pattern 的关系

| methodology | 关系 |
|-------------|------|
| /00 框架总览 | 加 §2 7 大核心抽象的第 7 项（per Sprint U 批 4 sync）|
| /02 sprint governance | §13 首次提出本 pattern（简介 4 段）/ 本 doc 是 first-class 详细抽象；**v0.2 §15.3 Hybrid Release Sprint Pattern** 引用 cross-stack feature fold 进 release sprint 模式（per Sprint T 实证 / 见本 doc §9.4）|
| /03 identity-resolver-pattern §9 | 同 stack 实证锚点（Sprint N byte-identical）|
| /04 invariant-pattern §8 | 同 stack + self-test 实证锚点（Sprint O soft-equivalent + injection）|
| /05 audit-trail-pattern §7 + §8 | **跨 stack 实证锚点**（Sprint Q audit_triage / 与本 doc 互为印证）+ §8 v0.2 Audit Immutability Pattern（cross-stack dogfood 应验证 immutability 保留）|
| /06 ADR pattern §8 | 跨 stack 抽象本身需要 ADR 记录（per /06 §8.3 跨域 fork 启示）；ADR-032 retroactive 是首个跨 stack 抽象 ADR |

---

## 9. Tooling Pattern for Cross-Stack Abstraction（v0.2 新增 / Sprint W 批 2）⭐

> 跨 stack 抽象需要一组**工程工具**来让 SQL 逐字 port + soft-equivalent dogfood + 持续 sync 在 sandbox / CI 可行。本节抽出 Sprint R + T 实证的 4 个 tooling 子模式 first-class。

### 9.1 4 个 tooling 子模式总览

| 子模式 | 解决的问题 | 实证 |
|--------|---------|------|
| §9.2 SQL Syntax Validation 不起 DB | 跨 stack 抽象需要把生产 SQL port 到 framework / 验证语法不能等 DB 起来才知道 | Sprint T pglast 验证 dogfood-bootstrap.sql + dogfood-seed.sql / 19+7 stmts OK |
| §9.3 Minimum Schema Subset Docker | dogfood 必须有 production-like DB / 但生产 36+ 表过重 | Sprint T T-V03-FW-005 / Approach B 7 表子集 / Docker compose 起 < 5s |
| §9.4 Cross-Stack Sync Pre-commit Hook | 生产 stack 改动时提醒 framework stack 同步 | Sprint R T-V03-FW-006 / scripts/check-audit-triage-sync.sh |
| §9.5 Hybrid Release Sprint Pattern Adapt | release sprint 内 fold 跨 stack 大 feature | Sprint T fold T-V03-FW-005 进 v0.3 release sprint / per /02 v0.2 §15.3 |

### 9.2 SQL Syntax Validation 不起 DB（pglast / sqlglot 等）

**问题**：跨 stack 抽象写 dogfood-bootstrap.sql + dogfood-seed.sql 时，没有真 DB 跑 = 拼写错误 / SQL syntax 错只能等 Docker 起来后才暴露 = 浪费时间。

**做法**：用 SQL parser 库（如 Python 的 `pglast` / TS 的 `node-sql-parser`）静态验证：

```python
# Sprint T 实证模式
import pglast
for f in ["scripts/dogfood-bootstrap.sql", "scripts/dogfood-seed.sql"]:
    sql = open(f).read()
    parsed = pglast.parse_sql(sql)  # 抛 ParseError 即语法错
    print(f"{f}: {len(parsed)} statements parsed OK")
```

**收益**：
- Sprint T 实证：pglast 验证 19+7 stmts OK / 起 Docker 前 100% 语法正确
- 编辑 cycle 加速（vs 起 Docker 等 5-10s 后才知错）
- CI 可跑（vs Docker compose 在 sandbox 复杂）

**反模式**：
- ❌ 不验证 / 直接起 Docker / 失败后 debug docker entrypoint logs
- ❌ 用 `python -c "import sqlite3; sqlite3.connect(':memory:').execute(sql)"` — SQLite 与 PG 语法差别大（PG-specific syntax 如 `JSONB` / `UUID` / `gen_random_uuid()` 都不支持）

### 9.3 Minimum Schema Subset Docker（Approach B）

**问题**：跨 stack 抽象需要 dogfood DB / 生产 schema 36+ 表过重（启动 30s+）/ 维护多 stack 同步昂贵。

**做法**（per Sprint T T-V03-FW-005 实证）：
1. 识别 framework dogfood 实际触及的最小表集（Sprint T audit_triage = 7 表 vs 生产 36+）
2. 写独立 `dogfood-bootstrap.sql`（最小 schema / 不复用生产 migration）
3. 写 `dogfood-seed.sql`（最小 fixtures / 5-10 rows per critical table）
4. 用 deterministic UUID（`00000000-0000-4xxx-8xxx-NNNNNNNNNNNN` shape）让 re-seed 一致
5. Docker compose 端口与生产隔离（生产 5433 / dogfood 5434）

**收益**：
- Docker DB 起 < 5s（vs 全量 schema ~30s+）
- 单文件 bootstrap.sql 可读（~150 行 vs 552 行 0000）
- 跨域 fork 案例方易复制 + 改 schema

**反模式**：
- ❌ 直接复用生产 migration 文件（耦合生产 schema 演化 / 跨域 fork 时累赘）
- ❌ 用同一端口（生产 + dogfood 不能并行跑）
- ❌ Seed 0 行 / dogfood trivially 通过（假绿）

### 9.4 Cross-Stack Sync Pre-commit Hook

**问题**：跨 stack 抽象**两边并行存在**（生产 + framework）/ 生产 stack 改动时容易忘记同步 framework / 跨 sprint 漂移。

**做法**（per Sprint R T-V03-FW-006 实证）：
1. 识别生产 stack 文件 path（如 `services/api/.../triage.*`）+ framework example path（如 `framework/audit_triage/examples/huadian_classics/`）
2. 写 bash 脚本 categorize staged files：prod_changed / fw_example_changed / 都没改
3. 仅 prod_changed=1 AND fw_example_changed=0 时输出 warning（不阻塞 commit / informational only）
4. 加入 .pre-commit-config.yaml 的 `files:` regex 限制触发 scope

```bash
# scripts/check-audit-triage-sync.sh 节选
if [ "$prod_changed" -eq 1 ] && [ "$fw_example_changed" -eq 0 ]; then
    cat >&2 <<'WARN'
⚠️  services↔framework/audit_triage sync warning
You are committing changes to services/api/.../triage.* without any change to
framework/audit_triage/examples/huadian_classics/. Please review whether
SQL/business logic also need framework sync.
WARN
fi
exit 0  # informational only
```

**收益**：
- Sprint T 第 1 次实战 hook 触发（commit `b532341`）/ 自动 silent（pass）/ 0 false positive
- 跨外部贡献者也能受益（fork 后保留 hook = 持续提醒）

**反模式**：
- ❌ Hook 阻塞 commit（exit 1）— 用户不爽 / 倾向 `--no-verify` bypass / 反而不读 warning
- ❌ Hook 仅本地 / 不 fork 友好（应该把 hook script 跟仓库走 / 任何贡献者 install pre-commit 即生效）
- ❌ Hook 不分类 staged files / 总是输出 warning（噪音 / Hook fatigue）

### 9.5 Hybrid Release Sprint Pattern Adaptation

**问题**：跨 stack 抽象的大 feature（如 Docker compose dogfood infra）何时 land？单独 mini-sprint 太短（不值得起完整流程）/ 与 release sprint 合并担心 scope creep。

**做法**（per /02 v0.2 §15.3 Hybrid + Sprint T 实证）：
- 在 release sprint 批 1 fold 1 个押后大 feature（条件：feature ≥ 4h / 与 release 主题相关 / release 不急）
- 实证 Sprint T fold T-V03-FW-005 (Docker compose) 进 v0.3 release sprint：
  - 批 1: T-V03-FW-005 Docker compose ~3-4h
  - 批 2-5: 5 模块 README + RELEASE_NOTES + STATUS/CHANGELOG + sanity ~2h
  - 批 4: closeout
  - total: 2 sessions / 实际 ~3h（远低于估算）

**收益**：
- Release sprint 不空（仅 release prep 是 1 sprint 浪费）
- 大 feature 不必单独 mini-sprint（fold 进有 bookkeeping 优势）
- Sprint T 第 6 个 zero-trigger sprint 巩固稳定信号

**反模式**：
- ❌ Fold > 1 个大 feature 进 release sprint（scope creep / Stop Rule 触发风险）
- ❌ Fold 不相关 feature（如 release sprint 内 fold v0.4 maintenance / 主题混乱）
- ❌ Hybrid 但不 update release notes 写 fold 内容（让外部 reviewer 困惑）

### 9.6 Tooling Pattern 跨域 fork 启示

任何跨域 fork（per §6）都应该带这些 tooling：

- ✅ **复制 scripts/dogfood-postgres-compose.yml + 改 schema + 改 seed**（Approach B 模板）
- ✅ **保留 .pre-commit-config.yaml 的 cross-stack sync hook + 改 path regex**（Sprint R 实证可复用）
- ✅ **用 SQL parser 验证 your-domain bootstrap.sql + seed.sql**（per pglast / sqlglot / etc）
- ⚪ **如有跨 stack 大 feature push 进 release sprint 用 Hybrid 形态**（vs 单独 mini-sprint / 看主题 + 工时容忍度）

---

## 10. 修订历史

| Version | Date | Author | Change |
|---------|------|--------|--------|
| Draft v0.1 | 2026-04-30 | 首席架构师 | Sprint U 批 3 起草：first-class 详细抽象 cross-stack pattern（vs methodology/02 §13 简介）；§1-§7 含三步做法 + 3 种等级 + 3 种 stack 组合实证 + Docker dogfood infra + 跨域 fork 启示 + 反模式；§8 与其他 6 doc 关系；沉淀 Sprint Q audit_triage + Sprint T Docker dogfood 实证 |
| **v0.2** | **2026-04-30** | **首席架构师** | **Sprint W 批 2 大 bump（v0.x cycle 第 2 sprint / 第 3 doc → v0.2）：加 §9 Tooling Pattern for Cross-Stack Abstraction（4 子模式：SQL Syntax Validation 不起 DB / Minimum Schema Subset Docker / Cross-Stack Sync Pre-commit Hook / Hybrid Release Sprint Pattern Adaptation）+ §8 加 /02 v0.2 §15.3 + /05 v0.2 §8 引用更新 + 重组 修订历史 §9 → §10；§9 是新 first-class pattern（4 子模式）→ v0.x → v0.2 大 bump（vs v0.1.x polish）** |

---

> 本文档描述的 Cross-Stack Abstraction Pattern 是 AKE 框架的 Layer 1 第 7 大核心抽象（per methodology/00 §2 from Sprint U sync）。
> 实证锚点：framework/audit_triage/ (Sprint Q) + scripts/dogfood-postgres-compose.yml (Sprint T) + scripts/check-audit-triage-sync.sh (Sprint R) + pglast 验证（Sprint T）。
> Sprint W (§9 v0.2) 抽出 Tooling Pattern first-class（vs §5 dogfood infra 选项 + 散在各处的 tooling）。
