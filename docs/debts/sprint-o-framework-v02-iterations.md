# Sprint O 衍生债 — framework v0.1 → v0.2 候选清单

> Status: registered
> 来源 sprint: Sprint O Stage 1.13 dogfood + Stage 4 retro (2026-04-30)
> 优先级: 1 项 P2（升级自 Sprint N P3）/ 3 项 P3
> 触发条件: Sprint P 启动时**优先**处理 P2；P3 留 v0.2 release 前批量

---

## 0. 总览

Sprint O 是 framework/invariant_scaffold/ 的**第一次自审 dogfood**。dogfood 中触发 Stop Rule #1 一次（与 Sprint N 同 path bug 复发），当场修复。留下 **4 项新候选 + 1 项升级**。

合并 Sprint L+M+N+O 累计：**20 项 v0.2 候选**（6 项 Sprint M 已 patch / 14 项待 v0.2 release 前批量 / 其中 1 项 P2 优先处理）。

---

## DGF-O-01 ⚠️ P2 升级（Sprint N DGF-N-02 复发）— framework examples 路径硬编码改环境变量

### 描述

Sprint O 跑 dogfood 时 slug_format 报 135 violations。根因：

```python
# invariants_slug.py 原代码
path = Path(__file__).resolve().parents[5] / "data" / "tier-s-slugs.yaml"
```

`parents[5]` 错算（应该 `[4]`）。这是 **Sprint N 同样的 bug 复发** — DGF-N-02 已经登记但优先级 P3 + 跨 sprint 未处理 → Sprint O 又踩一遍。

### 影响

- 跨 sprint 复发 → 这是 systemic 问题不是 isolated bug
- examples 中其他文件可能也有同问题（dynasty_guard.py / state_prefix_guard.py 在 Sprint N 已修过）
- 跨领域案例方 fork 时高概率踩同样坑

### 修改建议

**优先级 P2**（升级自 P3）— Sprint P 启动时**优先**处理：

1. 加 `HUADIAN_DATA_DIR` 环境变量为主路径
2. 加构造函数参数 `data_dir: Path | None = None` 让案例方 inject
3. `parents[N]` fallback 仅作为最后手段
4. 全 examples 审查（identity_resolver + invariant_scaffold 两模块共 ~5 处 path 用法）

```python
def _default_data_dir() -> Path:
    """Locate huadian data directory.

    Priority: HUADIAN_DATA_DIR env > project_root/data fallback.
    """
    env = os.environ.get("HUADIAN_DATA_DIR")
    if env:
        return Path(env)
    return Path(__file__).resolve().parents[4] / "data"
```

### 处理时机

**Sprint P 启动时优先**（不再等 v0.2 release 批量）。

---

## DGF-O-02 — framework/invariant_scaffold/ 加 conftest.py + pytest 单元测试

### 描述

Sprint O 有 sanity tests（10 个 in-script python -c oneliners）+ dogfood validation，但没有 pytest 单元测试。Sprint N DGF-N-03 同 pattern。

### 影响

- 重构时缺乏快速回归
- 跨领域 fork 时缺 testing 范本
- CI 集成困难

### 修改建议

```
framework/invariant_scaffold/tests/
  conftest.py
  test_types.py
  test_invariant.py
  test_patterns_*.py (5 patterns)
  test_runner.py
  test_self_test.py
  test_examples_huadian.py
```

每个 test 文件 3-5 个 cases。

### 处理时机

v0.2 release 前批量 / 与 Sprint N DGF-N-03 一并处理。

---

## DGF-O-03 — examples/legal/ + examples/medical/ 跨领域 reference impl

### 描述

cross-domain-mapping.md 设计 6 领域 5 pattern 适配，但只有 huadian 真跑了。Sprint N DGF-N-04 同 pattern。

### 影响

- 跨领域 mapping 只是 design intent，未实证
- 5 pattern 跨领域 valid 的论证只有 1 case

### 修改建议

至少加 1 个跨领域 reference impl（建议 legal — 简单业务 schema 可示范完整 5 pattern）。

### 处理时机

跨领域案例方主动接触 → 优先做。或 Sprint Q+ 候选议程。

---

## DGF-O-04 — Containment in_python_predicate 用 `inspect.isawaitable()` 替代 `hasattr`

### 描述

当前代码：

```python
async def query_violations(self, port):
    rows = await port.fetch(self._sql)
    for row in rows:
        result = self._predicate(row)
        if hasattr(result, "__await__"):  # ← 用 hasattr 检测 awaitable
            result = await result
```

`hasattr(result, "__await__")` 是 idiomatic 但不是最 robust 的方法。`inspect.isawaitable()` 是标准库官方推荐。

### 影响

- 极少边缘 case 下（如自定义对象有 `__await__` 但不是真 awaitable）可能误判
- code quality nit，非 critical

### 修改建议

```python
import inspect

async def query_violations(self, port):
    rows = await port.fetch(self._sql)
    for row in rows:
        result = self._predicate(row)
        if inspect.isawaitable(result):
            result = await result
```

### 处理时机

v0.2 release 前批量 / nice-to-have。

---

## 押后项（Stage 2-3）

| 押后项 | 触发条件 |
|--------|---------|
| framework/invariant_scaffold/ 外部工程师走通验证 | 1-2 个朋友 / 跨领域案例方主动接触 |
| 跨领域案例方真用 cross-domain-mapping.md 做 instantiation | 同上 / 与 DGF-O-03 联动 |

---

## 与 Sprint L + M + N 衍生债合并视图

| Sprint | 总 v0.2 候选 | 已 patch | 仍待 v0.2 |
|--------|-----------|---------|----------|
| L (T-P3-FW-001~004) | 4 | 0 | 4 |
| M (DGF-M-01~07) | 7 | 6 | 1 |
| N (DGF-N-01~05) | 5 | 0 | 5 |
| O (DGF-O-01~04) | 4 | 0 | 4 (含 1 P2 升级) |
| **合计** | **20** | **6** | **14** |

---

## v0.2 release 触发条件评估（Sprint O 后状态）

Sprint O closeout §2.4 给出 v0.2 release 候选条件：

- ✅ ≥ 4 个抽象资产稳定（4 模块完整）
- ✅ byte-identical (Sprint N) + soft-equivalent (Sprint O) 双 dogfood 通过
- ✅ 累计 ≥ 15 项 v0.2 候选（已达 20）
- ⏳ Sprint P 处理 P2 + P3 (推荐优先 v0.2 patch sprint)
- ⏳ Sprint P 完成后 → 正式 v0.2 release

→ **v0.2 release 完全准备好**，仅待 Sprint P 清债。

---

**本债务清单 sprint O 起草于 2026-04-30 / Sprint O Stage 4 closeout**
