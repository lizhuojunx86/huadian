# framework/invariant_scaffold — Invariant Checking Framework

> Status: **v0.2.0 (Sprint P release / 2026-04-30)**
> First abstraction: Sprint O Stage 1, 2026-04-30
> Date: 2026-04-30
> License: Apache 2.0 (代码) / CC BY 4.0 (文档)
> Source: 华典智谱 V4/V6/V8/V9/V10/V11/slug/active-merged 测试 (1031 行) 抽象 (Sprint O)

---

## 0. 这是什么

一套**领域无关**的 invariant checking 框架，让任何 KE 项目用 5 大 pattern 注入自己的 SQL，统一跑数据正确性检查 + 自动化 self-test 验证 invariant 真能 catch 违反。

不需要写新代码框架，**只需要写 SQL 模板 + 注入到 5 pattern subclass，即可启动你的 V1-VN invariant 体系**。

---

## 1. 何时用这套框架

✅ **适合**：

- 任何需要"数据正确性铁律"的 KE 项目（违反必须阻塞 commit / sprint）
- 5 大 pattern（Upper/Lower-bound / Containment / Orphan / Cardinality）能覆盖大部分约束
- 已有 SQL DB（PostgreSQL / MySQL / SQLite / etc）+ asyncpg / aiopg / async DB driver

❌ **不适合**：

- 纯应用层验证（用 Pydantic / similar 库）
- 实时流式检查（本框架是 batch / 跑收口 gate）
- 启发式规则（"通常应该满足"）→ 用 QC rule 系统（不是 invariant）

---

## 2. 文件清单

```
framework/invariant_scaffold/
  __init__.py                       — 14 exports，统一入口
  types.py                          — Severity / Violation / InvariantResult / etc
  port.py                           — DBPort Protocol
  invariant.py                      — Invariant ABC + run() wrapper
  patterns/
    upper_bound.py                  — entity attr count ≤ N
    lower_bound.py                  — entity must have ≥ N attrs
    containment.py                  — A ⊆ B (含可选 python predicate)
    orphan_detection.py             — 引用必须指向存在行 (count + row 双 mode)
    cardinality_bound.py            — count == exact OR per-entity range
  runner.py                         — InvariantRunner + assert_all_pass
  self_test.py                      — SelfTest Protocol + SelfTestRunner
  examples/huadian_classics/        — 完整 reference impl（11 invariants + 4 self-tests）
  README.md                         — 本文件
  CONCEPTS.md                       — 5 pattern + bootstrap + self-test 概念
  cross-domain-mapping.md           — 6 领域 invariants 适配速查
```

---

## 3. 5 分钟快速上手

### Step 1: 复制框架

```bash
git clone https://github.com/lizhuojunx86/huadian.git
# → from huadian.framework.invariant_scaffold import ...
```

或 fork + cp 到自己项目。

### Step 2: 实现 DBPort

```python
# your_project/db_port.py
from framework.invariant_scaffold import DBPort

class MyAsyncpgPort:  # implements DBPort
    def __init__(self, pool): self._pool = pool
    async def fetch(self, sql, *args):
        async with self._pool.acquire() as c:
            return [dict(r) for r in await c.fetch(sql, *args)]
    async def fetchval(self, sql, *args): ...
    async def execute(self, sql, *args): ...
    def transaction(self):
        from contextlib import asynccontextmanager
        @asynccontextmanager
        async def _ctx():
            async with self._pool.acquire() as c, c.transaction():
                yield
        return _ctx()
```

参考完整版：`examples/huadian_classics/db_port.py`。

### Step 3: 注入 invariants 到 runner

```python
from framework.invariant_scaffold import (
    InvariantRunner,
    UpperBoundInvariant,
    LowerBoundInvariant,
    OrphanDetectionInvariant,
)

runner = InvariantRunner(port=MyAsyncpgPort(pool))

runner.register(UpperBoundInvariant.from_template(
    name="V1",
    description="each entity ≤ 1 primary attribute",
    sql="SELECT entity_id, COUNT(*) AS cnt FROM ... HAVING COUNT(*) > $1",
    max_count=1,
    violation_explanation_fmt="entity {entity_id} has {cnt} primaries",
))

runner.register(LowerBoundInvariant.from_template(
    name="V9",
    description="each active entity ≥ 1 primary attribute",
    sql="SELECT id FROM entities WHERE deleted_at IS NULL AND NOT EXISTS (...)",
))

# ... more invariants ...
```

### Step 4: 跑 + 检查报告

```python
report = await runner.run_all()
print(report.format_summary())

# 在 sprint 收口 / CI gate
runner.assert_all_pass(report)  # 抛 AssertionError on critical 失败
```

### Step 5: 加 self-test 验证 invariant 真能 catch

```python
from framework.invariant_scaffold import SelfTest, SelfTestRunner

class MyV9SelfTest:
    name = "v9_missing_primary"
    invariant_name = "V9"

    async def setup_violation(self, port):
        # 注入一个违反 V9 的 entity
        await port.execute("INSERT INTO entities (...) VALUES (...)")
        await port.execute("INSERT INTO attributes (...) VALUES (..., is_primary=false)")

    def expected_violation_predicate(self, violation):
        # 验证返回的 violation 是注入的那行
        return violation.row_data.get("id", "").startswith("test-")

self_runner = SelfTestRunner(port=MyAsyncpgPort(pool), invariants=runner.invariants)
result = await self_runner.verify(MyV9SelfTest())
assert result.caught
```

参考完整版：`examples/huadian_classics/self_tests.py`（4 个 self-tests，覆盖 V8 / V9 / V10.a / V11）。

---

## 4. 跨领域使用指南

### 4.1 5 pattern 跨领域 mapping 速查

| Pattern | 古籍 | 法律 | 医疗 | 专利 |
|---------|-----|------|------|------|
| Upper-bound | V1 each person ≤ 1 primary name | each contract ≤ 1 primary party | each case ≤ 1 main diagnosis | each patent ≤ 1 first inventor |
| Lower-bound | V9 active person ≥ 1 primary name | active contract ≥ 1 party | active case ≥ 1 diagnosis | active patent ≥ 1 inventor |
| Containment | V8 / V10.c / slug-format | every cited case ⊆ db | every drug ⊆ formulary | every prior-art ref ⊆ existing patents |
| Orphan detection | V10.a/b | citation IDs → real cases | drug IDs → formulary | prior-art IDs → patents |
| Cardinality bound | V6 / V11 / slug-no-collision | per-case primary cite count ≤ 1 | per-patient active rx in [0, 50] | per-invention indep claim ≥ 1 |

详见 `cross-domain-mapping.md` 完整 6 领域。

### 4.2 Plugin 注入门槛

| Plugin | 必需？ | 不实现的后果 |
|--------|------|-------------|
| `DBPort` | **必需** | runner 无法启动 |
| `SelfTest` | optional / per invariant | 无 self-test 验证（invariant SQL 可能有 bug 不被发现）|

→ vs Sprint N identity_resolver 的 9 个 Protocol，本框架更轻 — 只 2 个 Plugin。

---

## 5. 设计哲学

### 5.1 5 pattern 是 invariant 的 universal 集合

basis on `docs/methodology/04` Sprint O 实证 — HuaDian 11 个真实 invariants 100% 映射到 5 pattern。如果你的领域 invariants 不能 fit 进 5 pattern，先尝试拆解（如 active-merged = "merged ⊆ deleted" 是 Containment 而非新 pattern）。

### 5.2 SQL 是契约，不是实现细节

每个 invariant 用一条 SQL query 表达。SQL 直接传给 DBPort，框架不解析 / 不抽象 / 不 ORM-ify。case 域写自己的 SQL → framework 跑 → 报告。这种 thin abstraction 让案例方迁移最快。

### 5.3 Severity 分级

- `critical` — 默认 / 阻塞 sprint
- `warning` — 报告但不阻塞（如 V7 source_evidence 待 backfill）
- `info` — 诊断 / sanity check（如 row count guard）

### 5.4 Self-test 是抽象正确性的元检查

invariant SQL 可能写错（比如漏了 `WHERE deleted_at IS NULL`）→ 假装通过。Self-test 注入已知违反 + 验证 catch → 锁定抽象正确性。

vs Sprint N byte-identical dogfood，本框架的 self-test 是**等价但更轻**的验证（invariant 0 violations 状态 → "数据 OK" → soft equivalence）。

---

## 6. 反模式（不要这么做）

- ❌ **不要把 QC rule 当 invariant**（"通常应该有 birth_year" 是 QC rule，不是 invariant）
- ❌ **不要在 Python 写复杂业务逻辑**（用 SQL 表达约束 + 复杂的用 ContainmentInvariant.in_python_predicate）
- ❌ **不要跳过 self-test**（invariant SQL 没自检 → 永远不知道它是否 work）
- ❌ **不要让 invariant 自动修复违反**（invariant 是 detection / 修复是单独的 pipeline）

---

## 7. 反馈与贡献

本框架从华典智谱 Sprint A-K invariant 体系（1031 行测试）抽出，是 v0.1 状态。

- **报告使用经验**（GitHub Issue 标 `invariant-scaffold-feedback`）
- **指出遗漏**（标 `invariant-scaffold-gap`）
- **贡献跨领域 reference impl**（PR 加 `examples/your_domain/`）

---

## 8. 版本信息

| Version | Date | Source | Change |
|---------|------|--------|--------|
| v0.1 | 2026-04-30 | Sprint O Stage 1 (first abstraction) | 初版抽出（12 framework core + 13 huadian_classics examples）|
| **v0.2.0** | **2026-04-30** | **Sprint P v0.2 release** | DGF-O-01 (P2): `examples/huadian_classics/invariants_slug.py` 路径硬编码改 `HUADIAN_DATA_DIR` 环境变量优先；DGF-O-04: `ContainmentInvariant.query_violations` 用 `inspect.isawaitable()` 替换 `hasattr(result, "__await__")`（更 robust 的 awaitable 检测，避免边缘情形误判）；与 framework v0.2 release 同步发布 |

---

> 本框架是 AKE 框架 Layer 1 的**第四刀**。
> 第一刀 (L)：framework/sprint-templates/
> 第二刀 (M)：framework/role-templates/
> 第三刀 (N)：framework/identity_resolver/
> 第四刀 (O)：framework/invariant_scaffold/ ← 本框架
