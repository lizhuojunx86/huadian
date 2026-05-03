# Concepts — 5 Pattern + Bootstrap + Self-test

> Status: v0.1 (Sprint O Stage 1)
> 框架核心概念。读完后再读 README §3 快速上手会更顺。

---

## 1. 核心问题

> KE 项目数据是否对 — 不能靠人工 review 兜底，必须形式化为约束 + 自动跑。

**Invariant** = 项目数据**永远必须满足**的约束。每次 sprint 收口 / CI gate / pre-commit 必跑全绿。

vs **QC Rule**（"通常应该满足"）：

| 维度 | Invariant | QC Rule |
|------|-----------|---------|
| 性质 | 形式化约束 | 启发式 |
| 违反时 | 阻塞 commit / sprint | 警告，不阻塞 |
| 数量 | 少而精（华典 11 个）| 多（华典 ~30 个）|

---

## 2. 5 大 Invariant Pattern

### 2.1 Upper-bound — 某属性的上限

```sql
SELECT entity_id, COUNT(*) AS cnt
FROM entity_attrs
GROUP BY entity_id
HAVING COUNT(*) > $1   -- max_count
```

**规则**：每个 entity 的某属性数量不能超过 N（典型 N=1，"恰好 1 个"语义）。

**Framework**：`UpperBoundInvariant.from_template(sql, max_count, ...)`

**HuaDian 示例**：V1 each person ≤ 1 primary name

### 2.2 Lower-bound — 某属性的下限

```sql
SELECT e.id, e.slug
FROM entities e
WHERE e.deleted_at IS NULL
  AND NOT EXISTS (SELECT 1 FROM attrs a WHERE a.entity_id = e.id AND ...)
```

**规则**：每个 active entity 必须有 ≥ N 个某属性（典型 N=1）。

**Framework**：`LowerBoundInvariant.from_template(sql, min_count=1, ...)`

**HuaDian 示例**：V9 active person ≥ 1 primary name / V4 merged person ≥ 1 person_name

### 2.3 Containment — A ⊆ B

```sql
SELECT a.id FROM table_a a
WHERE NOT EXISTS (SELECT 1 FROM table_b b WHERE matches_predicate(a, b))
```

**规则**：集合 A 必须是集合 B 的子集（rows 在 A 但不在 B = violations）。

**Framework**：`ContainmentInvariant.from_template(sql, in_python_predicate=optional, ...)`

**HuaDian 示例**：V8 short ⊄ unexempted long prefix / V10.c active mapping ⊆ has-evidence / active+merged / Slug-A

**双模式**：

- 纯 SQL：SELECT 直接返回 violations
- SQL + Python predicate：SQL 返回 candidate rows, 每行用 Python 检查（用于 regex / whitelist 等 SQL 不易表达的约束）

### 2.4 Orphan Detection — 引用必须指向存在行

```sql
-- count_only mode
SELECT count(*) FROM child c
LEFT JOIN parent p ON p.id = c.parent_id
WHERE p.id IS NULL OR p.deleted_at IS NOT NULL
```

**规则**：引用必须指向存在 + active 的行。

**Framework**：`OrphanDetectionInvariant.from_template(sql, count_only=True, ...)`

**HuaDian 示例**：V10.a active mapping → live person / V10.b mapping → existing entry

### 2.5 Cardinality Bound — 计数等于精确值或在范围内

```sql
-- exact_total mode
SELECT count(*) FROM bad_rows  -- expected 0

-- per_entity_range mode
SELECT entity_id, COUNT(*) AS cnt FROM ... GROUP BY entity_id  -- max=1
```

**规则**：

- `exact_total`：全表 count == expected（典型 expected=0，"必须为空"）
- `per_entity_range`：每个 entity 的 count ∈ [min, max]

**Framework**：`CardinalityBoundInvariant.from_template(sql, mode=..., ...)`

**HuaDian 示例**：V6 alias+is_primary 计数 == 0 / V11 per-person active mapping 计数 ≤ 1 / Slug-B per-slug 计数 == 1

---

## 3. Bootstrap 模式

每个 invariant 的引入分两阶段：

### Phase 1: Backfill

引入 invariant 前，先跑一次查询找出所有 historical violations，clean up 掉。然后跑一次 query 验证为 0。

### Phase 2: Lock-in

新代码加 invariant 测试到 sprint 收口 gate。任何引入新 violation 的代码 → 测试失败 → 阻塞 commit。

**HuaDian 实证**：V9 引入前清掉 33 个 historical violations（Sprint F），之后 lock-in。

---

## 4. Self-test 模式

### 4.1 问题

invariant SQL 可能写错（漏 WHERE / 错的 JOIN / etc）→ 假装通过 → bug 漏检。**单元测试也不容易抓**（数据状态本来就 OK）。

### 4.2 解决：注入式 self-test

```python
class V9MissingPrimarySelfTest:
    name = "v9_missing_primary"
    invariant_name = "V9"

    async def setup_violation(self, port):
        # 注入一个明确违反 V9 的 row
        await port.execute("INSERT INTO ... VALUES (...)")  # is_primary=false

    def expected_violation_predicate(self, violation):
        # 验证返回的 violation 是注入的那行
        return violation.row_data.get("id") == self._injected_id
```

`SelfTestRunner.verify(self_test)`：

1. begin transaction
2. setup_violation()
3. run target invariant
4. assert: invariant 返回的 violations 中至少一个 matches predicate
5. always rollback（_RollbackSentinel exception）

→ 如 invariant 没 catch 注入的违反 → self-test fail → 表明 invariant SQL 有 bug。

### 4.3 Cardinality / Orphan invariant 的 self-test 适配

count_only / exact_total invariants 不返回单行 → predicate 改为"count > 0"（验证从 0 → ≥ 1 的状态变化）。

---

## 5. 完整流程图

```
┌─────────────────────────────────────────────────────────────────┐
│                  Sprint 收口 / CI Gate                            │
└─────────────────────────────────────────────────────────────────┘

  build_huadian_runner(port)  → InvariantRunner
                                  ↓ register_all([V4, V6, V8, ...])
              await runner.run_all()
                                  ↓
  for each invariant:
    inv.run(port) → InvariantResult {passed, violations, duration_ms, severity}
                                  ↓
  InvariantReport {results, total_duration_ms,
                   all_passed, critical_failures, warning_failures}
                                  ↓
  runner.assert_all_pass(report)  → AssertionError if critical fail
                                  → log warnings
                                  → pass


┌─────────────────────────────────────────────────────────────────┐
│                  Self-test (CI / Dogfood)                         │
└─────────────────────────────────────────────────────────────────┘

  build_huadian_self_test_runner(port)  → SelfTestRunner
                                            ↓
  for each self_test:
    SelfTestRunner.verify(self_test):
      async with port.transaction():    # auto-rollback
        await self_test.setup_violation(port)
        result = await invariant.run(port)
        caught = any(self_test.predicate(v) for v in result.violations)
        raise _RollbackSentinel       # force rollback
                                  ↓
  SelfTestResult {caught, duration_ms, detail}
                                  ↓
  assert all results.caught         → pass
                                    → fail = invariant SQL has a bug
```

---

## 6. 与 huadian_pipeline 原 pytest 测试的对应

| Framework | huadian_pipeline 原 |
|-----------|---------------------|
| `Invariant` ABC | 散在 test_invariants_v*.py 各 test 函数 |
| `InvariantRunner.run_all()` | 每个 sprint 收口手动跑 pytest |
| `InvariantRunner.assert_all_pass()` | pytest assert + 收口 checklist |
| `SelfTestRunner.verify()` | test_v9_self_test_catches_missing_primary 等 |
| 5 pattern subclass | 抽象之前每 invariant 都自己写 SQL + assert |

抽象**不改算法行为**，只把"散在 7 个测试文件的 SQL + 注入逻辑"统一成"5 pattern subclass + 1 个 runner"。

---

## 7. 跨规则 severity 分级原则

每个 invariant 的 severity 反映**违反的影响**：

- `critical`（默认 / 阻塞）— V1/V4/V6/V8/V9/V10.a/b/c/V11/active-merged/slug-collision
- `warning`（报告 / 不阻塞）— V7 active person_names without source_evidence（Stage 2 backfill 完成后会 promote 到 critical）
- `info`（诊断 / 跳过 if 不适用）— slug count sanity（如 0 active persons 直接 skip）

跨领域案例方按"违反多严重"自定 severity。

---

## 8. 修订历史

| Version | Date | Change |
|---------|------|--------|
| v0.1 | 2026-04-30 | 初版（Sprint O Stage 1）|

---

> 本文件描述的概念是 framework/invariant_scaffold/ 的**理论基础**。具体使用方法见 README.md / 跨领域 mapping 见 cross-domain-mapping.md。
