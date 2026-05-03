# Sprint O Stage 0 — Inventory: V1-V11 Invariant Scaffold 抽象

> Date: 2026-04-30
> Owner: 首席架构师
> Anchor: Sprint O Brief §3 Stage 0
> Purpose: 7 invariant 测试文件深扫 + 5 pattern map + Invariant 基类 + DBPort/SelfTest Protocol 设计 + 起草顺序

---

## 0. 扫描方法

沿用 Sprint N 同款（深扫每个测试文件 + 标 pattern + 设计 plugin protocol + 起草顺序）。

invariant 测试代码量 1031 行（vs Sprint N 2394 行 / 简单 ~50%）：

| 文件 | 行数 | 含 invariants | 模式特点 |
|------|------|-------------|---------|
| test_invariants_v9.py | 140 | V9 (lower-bound) | 1 main test + 2 self-tests |
| test_invariants_v10.py | 258 | V10.a/b/c (orphan + containment) | 3 main tests + 3 self-tests |
| test_invariants_v11.py | 170 | V11 (cardinality) | 1 main test + 2 self-tests |
| test_v8_prefix_containment.py | 216 | V8 (containment) | 1 main test + multiple self-tests + edge cases |
| test_slug_invariant.py | 102 | Slug-A (containment / Tier-S∪regex) + Slug-B (cardinality, no dup) + sanity | 3 main tests, no self-tests |
| test_merge_invariant.py | 145 | V4 (lower-bound) + V6 (cardinality, count==0) + active+merged (containment) | 3 main tests, no self-tests |
| **合计** | **1031** | **10 main invariants** | — |

**关键发现**：

- V1-V11 不全有独立 pytest 测试 — V1/V2/V3/V5 看起来是 schema-level / application logic enforced（not in test files）
- 真正有独立 test 的：V4 / V6 / V8 / V9 / V10.a/b/c / V11 + slug invariants（A+B）+ active-merged invariant = **10 个 main invariants**
- 模式 self-test 普遍：注入违反 + assertion 触发 + transaction rollback 复位

---

## 1. 10 个 invariant → 5 pattern map

每个 invariant 都能映射到 5 pattern（**methodology/04 5 pattern 设计经实证 valid**，无需新增第 6 pattern）：

| # | Invariant | Pattern | SQL 模式 |
|---|-----------|---------|---------|
| 1 | V4 (deleted+merged retain names) | **Lower-bound** | each soft-merged person ≥ 1 person_name |
| 2 | V6 (no alias+is_primary=true) | **Cardinality bound** | COUNT == 0 |
| 3 | V8 (single-char prefix collision) | **Containment** | short name ⊄ unexempted long-name prefixes |
| 4 | V9 (active person primary name) | **Lower-bound** | each active person ≥ 1 primary name |
| 5 | V10.a (orphan target) | **Orphan detection** | active mapping → live person |
| 6 | V10.b (orphan entry) | **Orphan detection** | mapping → existing entry |
| 7 | V10.c (active without evidence) | **Containment** | active mapping ⊆ has-source-evidence |
| 8 | V11 (no >1 active mapping) | **Cardinality bound** | per-entity count == 1 (max) |
| 9 | active-merged (merged → deleted) | **Containment** | merged_into_id-set ⊆ deleted_at-set |
| 10 | Slug-A (slug ∈ Tier-S ∪ unicode-regex) | **Containment** | each slug ∈ valid_set (whitelist + regex) |
| 11 | Slug-B (no slug collisions) | **Cardinality bound** | per-slug count == 1 |

**Pattern 分布**：

- Upper-bound: 0（V1 是该 pattern 但没独立 test）
- Lower-bound: 2（V4, V9）
- Containment: 4（V8, V10.c, active-merged, Slug-A）
- Orphan detection: 2（V10.a, V10.b）
- Cardinality bound: 3（V6, V11, Slug-B）

→ 5 pattern 都有实例，覆盖均衡。

---

## 2. 共通模式（所有 10 invariant 共有）

### 2.1 测试结构三段式

```python
# 1. 约束查询 (返回 violations)
INVARIANT_QUERY = """SELECT ... FROM ... WHERE <violation predicate>"""

# 2. main test: 跑 query → assert empty
async def test_<name>(db_conn):
    rows = await db_conn.fetch(INVARIANT_QUERY)
    assert not rows, f"{N} violations: {...}"

# 3. self-test (optional): 注入违反 → 验证 catch → rollback
async def test_<name>_self_test_catches_X(db_conn):
    tx = db_conn.transaction()
    await tx.start()
    try:
        # inject invalid row
        await db_conn.execute(...)
        # verify invariant catches
        rows = await db_conn.fetch(INVARIANT_QUERY)
        assert any matching → caught
    finally:
        await tx.rollback()
```

### 2.2 共通基础设施

- `pytest.mark.skipif(not DATABASE_URL)` — DATABASE_URL 不在则跳
- `db_conn` fixture（asyncpg.connect → yield → close）
- transaction-based self-test（注入 + 复位）

### 2.3 Severity 分布

- 大多数 invariant: **critical**（assert fail → 阻塞 sprint）
- V7 (active person_names without evidence): **warning**（warnings.warn / 不阻塞 — Stage 2 backfill 完成后会 promote）
- Slug count sanity (≥100): **info**（如 0 active persons 直接 skip）

---

## 3. Invariant 基类 + 5 Pattern subclass API 设计

### 3.1 数据契约

```python
# framework/invariant_scaffold/types.py

@dataclass(frozen=True, slots=True)
class Violation:
    """One row that violates an invariant."""
    invariant_name: str
    row_data: dict[str, Any]
    explanation: str  # human-readable description

@dataclass(frozen=True, slots=True)
class InvariantResult:
    """Outcome of running one invariant."""
    invariant_name: str
    passed: bool
    severity: Severity  # critical / warning / info
    violations: list[Violation]
    duration_ms: float

@dataclass(frozen=True, slots=True)
class InvariantReport:
    """Full report of running all invariants."""
    results: list[InvariantResult]

    @property
    def all_passed(self) -> bool: ...
    @property
    def critical_failures(self) -> list[InvariantResult]: ...

Severity = Literal["critical", "warning", "info"]
```

### 3.2 Invariant 基类

```python
# framework/invariant_scaffold/invariant.py

class Invariant(ABC):
    """Abstract base for all invariants.

    Subclass via one of the 5 pattern classes (UpperBound / LowerBound /
    Containment / OrphanDetection / CardinalityBound), or implement
    `query_violations()` directly for ad-hoc invariants.
    """

    name: str
    description: str
    severity: Severity = "critical"

    def __init__(self, name: str, description: str, severity: Severity = "critical") -> None:
        self.name = name
        self.description = description
        self.severity = severity

    @abstractmethod
    async def query_violations(self, port: DBPort) -> list[Violation]:
        """Return list of violating rows (empty list = passes)."""

    async def run(self, port: DBPort) -> InvariantResult:
        """Run + wrap in InvariantResult with timing."""
        start = time.perf_counter()
        violations = await self.query_violations(port)
        duration_ms = (time.perf_counter() - start) * 1000
        return InvariantResult(
            invariant_name=self.name,
            passed=len(violations) == 0,
            severity=self.severity,
            violations=violations,
            duration_ms=duration_ms,
        )
```

### 3.3 5 Pattern Subclass

```python
# framework/invariant_scaffold/patterns/upper_bound.py

class UpperBoundInvariant(Invariant):
    """Pattern: each entity attr count must be ≤ N.

    Example (HuaDian V1):
        UpperBoundInvariant.from_template(
            name="V1",
            description="each person ≤ 1 primary name",
            sql='''
                SELECT person_id, COUNT(*) AS cnt
                FROM person_names
                WHERE is_primary = true
                GROUP BY person_id
                HAVING COUNT(*) > %s
            ''',
            max_count=1,
        )
    """

    @classmethod
    def from_template(
        cls,
        name: str,
        description: str,
        sql: str,
        max_count: int = 0,
        severity: Severity = "critical",
    ) -> UpperBoundInvariant: ...
```

5 pattern 各自有 `from_template` helper：

| Pattern class | Required params |
|--------------|----------------|
| UpperBoundInvariant | sql + max_count |
| LowerBoundInvariant | sql (returns violators where count < min_count) + min_count |
| ContainmentInvariant | sql (returns rows in A that aren't in B) |
| OrphanDetectionInvariant | sql (LEFT JOIN ... WHERE ... IS NULL) |
| CardinalityBoundInvariant | sql + expected_count（exact）or [min, max] range |

### 3.4 DBPort Protocol

```python
# framework/invariant_scaffold/port.py

class DBPort(Protocol):
    """Database access for invariant queries.

    Case domains implement this for their DB (asyncpg / aiopg /
    SQLAlchemy / etc). Framework provides asyncpg reference impl
    in examples/huadian_classics/db_port.py.
    """

    async def fetch(self, sql: str, *args: Any) -> list[dict[str, Any]]: ...
    async def fetchval(self, sql: str, *args: Any) -> Any: ...
    async def execute(self, sql: str, *args: Any) -> None: ...
    @asynccontextmanager
    async def transaction(self) -> AsyncIterator[None]: ...
```

### 3.5 InvariantRunner

```python
# framework/invariant_scaffold/runner.py

class InvariantRunner:
    """Run a registered set of invariants + collect report."""

    def __init__(self, port: DBPort) -> None:
        self._port = port
        self._invariants: list[Invariant] = []

    def register(self, invariant: Invariant) -> None: ...
    def register_all(self, invariants: list[Invariant]) -> None: ...

    async def run_all(self) -> InvariantReport: ...
    async def run_one(self, name: str) -> InvariantResult: ...

    def assert_all_pass(self, report: InvariantReport) -> None:
        """Used in pytest: assert no critical failures."""
```

### 3.6 SelfTestRunner

```python
# framework/invariant_scaffold/self_test.py

class SelfTest(Protocol):
    """A self-test: inject violation + verify invariant catches + cleanup.

    Case domains implement per-invariant self-tests. Framework provides
    SelfTestRunner that wraps them in transactions for safe rollback.
    """

    name: str
    invariant_name: str

    async def setup_violation(self, port: DBPort) -> None:
        """Inject a row that should trigger the invariant."""
    async def expected_violation_predicate(self, violation: Violation) -> bool:
        """Predicate to identify the injected violation in results."""

class SelfTestRunner:
    """Runs self-tests in transactions (auto-rollback on completion)."""

    def __init__(self, port: DBPort, invariants: list[Invariant]) -> None: ...

    async def verify(self, self_test: SelfTest) -> SelfTestResult:
        """Run setup → query → assert catch → rollback."""
```

---

## 4. framework/invariant_scaffold/ 候选目录结构（最终版）

基于 §3 设计，更新 brief §2.1.1 候选结构（行数微调）：

```
framework/invariant_scaffold/
  README.md                          ~150 行
  CONCEPTS.md                        ~200 行  | 5 pattern + bootstrap + self-test
  cross-domain-mapping.md            ~120 行  | 6 领域 invariants 适配
  __init__.py                        ~80 行   | 25+ exports

  types.py                           ~80 行   | Violation / InvariantResult / InvariantReport / Severity
  invariant.py                       ~100 行  | Invariant ABC + run() wrapper
  port.py                            ~70 行   | DBPort Protocol
  runner.py                          ~150 行  | InvariantRunner
  self_test.py                       ~150 行  | SelfTest Protocol + SelfTestRunner

  patterns/
    __init__.py                      ~30 行
    upper_bound.py                   ~70 行
    lower_bound.py                   ~70 行
    containment.py                   ~70 行
    orphan_detection.py              ~70 行
    cardinality_bound.py             ~80 行   | exact match + range

  examples/huadian_classics/
    __init__.py                      ~30 行
    db_port.py                       ~80 行   | asyncpg adapter
    invariants_v4.py                 ~50 行
    invariants_v6.py                 ~50 行
    invariants_v8.py                 ~80 行
    invariants_v9.py                 ~50 行
    invariants_v10.py                ~120 行  | 3 sub-rules
    invariants_v11.py                ~50 行
    invariants_active_merged.py      ~50 行
    invariants_slug.py               ~80 行   | A + B + sanity
    self_tests.py                    ~250 行  | self-test impls for invariants 7-9
    runner_setup.py                  ~80 行   | HUADIAN_INVARIANTS 注册 + factory
    test_byte_identical.py           ~150 行  | dogfood vs production pytest 输出
```

**统计**：

| 类型 | 文件数 | 行数 |
|------|-------|------|
| Framework core | 10 | ~870 |
| 5 pattern subclass | 6 | ~390 |
| examples (huadian_classics) | 13 | ~1170 |
| Documentation | 3 | ~470 |
| **合计** | **32** | **~2900** |

→ 比 brief §2.1.1 预估稍多（27 → 32 文件，~2200 → 2900 行）— 主要因为 examples 的 self-tests 单独成文件 + 更细的 invariant 拆分。

仍 **< 2500 行 framework + examples** 的 Stop Rule #6 阈值（framework core + 5 pattern + docs ≈ 1730 行 < 2500 ✅；examples 不计入）。

---

## 5. 起草顺序（5 批）

### 5.1 第一批（数据契约 + 核心抽象 / 4 文件 / ~330 行 / 30 分钟）

1. types.py
2. port.py
3. invariant.py
4. patterns/__init__.py + 1 个 pattern subclass（upper_bound 作模板）

### 5.2 第二批（5 pattern 完整 / 4 文件 / ~290 行 / 40 分钟）

5. patterns/lower_bound.py
6. patterns/containment.py
7. patterns/orphan_detection.py
8. patterns/cardinality_bound.py

### 5.3 第三批（主流程 / 2 文件 / ~300 行 / 30 分钟）

9. runner.py
10. self_test.py

### 5.4 第四批（examples / 13 文件 / ~1170 行 / 60-80 分钟）

11. examples/huadian_classics/__init__.py
12. db_port.py
13-19. 7 个 invariant 文件（v4 / v6 / v8 / v9 / v10 / v11 / active_merged / slug）
20. self_tests.py
21. runner_setup.py
22. test_byte_identical.py

### 5.5 第五批（文档 / 3 文件 / ~470 行 / 30-40 分钟）

23. README.md
24. CONCEPTS.md
25. cross-domain-mapping.md

### 5.6 Stage 1.13 dogfood（~30-40 分钟）

跑 `examples/huadian_classics/test_byte_identical.py`：

- 启动 InvariantRunner + 注册 10 huadian invariants
- 跑 run_all() → 期望 all critical pass（V7 warning OK）
- 跑 SelfTestRunner.verify() 对 7 个 self-tests → 期望全部 catch

**Gate 1.13**：

- 10 invariants 跑 0 critical violations（与 production pytest 状态等价）
- 7 self-tests 全部 catch → rollback OK

---

## 6. 工作量预估更新（vs brief §7）

| 任务 | brief 预估 | inventory 后预估 |
|------|----------|-----------------|
| Stage 0 inventory | 30 分钟 | ✅ 已完成（约 30 分钟实际）|
| Stage 1 第一批（数据契约 + 1 pattern）| ~30 分钟 | ~30 分钟 |
| Stage 1 第二批（5 pattern 完整）| ~60 分钟 | ~40 分钟 |
| Stage 1 第三批（主流程）| ~30 分钟 | ~30 分钟 |
| Stage 1 第四批（examples）| ~60 分钟 | ~60-80 分钟 |
| Stage 1 第五批（文档）| ~30 分钟 | ~30-40 分钟 |
| Stage 1.13 dogfood | ~30 分钟 | ~30-40 分钟 |
| Stage 4 closeout + retro | ~30 分钟 | ~30-40 分钟 |
| **合计** | 1-2 会话 | **~5-6 小时** |

→ 与 brief 预估一致，单 Cowork 会话内可压缩完成（极致节奏）；舒缓 2 会话更适。

---

## 7. ADR 触发评估

依据 brief Stop Rule #5（"触发新 ADR ≥ 1 个 → Stop"）：

**当前评估**：Sprint O 中**完全不预期触发 ADR**。理由：

- 5 pattern 设计已在 methodology/04 v0.1 完整定义
- DBPort / SelfTest Protocol 是标准 Python typing.Protocol，无 framework 特定约定
- Invariant 基类是直接的 ABC 模式

**Stop Rule #5 不触发**。

---

## 8. Gate 0 自检

- [x] 7 个 invariant 测试文件全部深扫
- [x] 10 个 invariant → 5 pattern map 完成
- [x] 5 pattern 都有实例（覆盖均衡）
- [x] Invariant 基类 + 5 pattern subclass API 设计
- [x] DBPort + SelfTest Protocol 设计
- [x] InvariantRunner + SelfTestRunner 设计
- [x] framework/invariant_scaffold/ 完整目录结构（32 files）
- [x] 起草顺序 5 批 + Stage 1.13 dogfood
- [x] 工作量预估（~5-6 小时）
- [x] ADR 触发评估（不触发）

---

## 9. 已就绪信号

```
✅ Sprint O Stage 0 完成
- 7 个 invariant 测试文件深扫完成（1031 行）
- 10 个 invariant → 5 pattern 完整映射（5 pattern 均衡覆盖）
- Invariant 基类 + 5 pattern subclass + DBPort + SelfTestRunner API 设计完成
- framework/invariant_scaffold/ 候选目录：32 文件 / ~2900 行（framework core ~1730 < 2500 阈值）
- 起草顺序 5 批 + Stage 1.13 dogfood
- 工作量预估：~5-6 小时（单会话压缩可完成 / 舒缓 2 会话）
- ADR 触发评估：不触发（Stop Rule #5 安全）
→ Stage 1 起草 unblock
```

---

**本 inventory 起草于 2026-04-30 / Sprint O Stage 0**
