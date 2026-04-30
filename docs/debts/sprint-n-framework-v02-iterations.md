# Sprint N 衍生债 — framework/identity_resolver/ v0.1 → v0.2 候选清单

> Status: registered
> 来源 sprint: Sprint N Stage 1.13 dogfood + Stage 4 retro (2026-04-30)
> 优先级: 全部 P3（不主动启动；遇到机会 batch 处理）
> 触发条件: Sprint O+ 启动时如顺手即处理；或外部反馈批量驱动；或 framework v0.2 release 前批量收尾

---

## 0. 总览

Sprint N 是 framework/identity_resolver/ 的**第一次自审 dogfood**（byte-identical 严格等价验证）。dogfood 中触发 Stop Rule #1 两次但都当场修复，留下 5 项 v0.2 候选。

合并 Sprint L+M+N 累计：**16 项 v0.2 候选**（6 项 Sprint M 已 patch / 10 项待 v0.2 release 前批量）。

---

## DGF-N-01 — test_byte_identical.py compare() 加 `__field_aliases__` 通用机制

### 描述

Sprint N dogfood 第二轮跑时，所有数据等价但 test 报字段名差异（`total_persons` vs `total_entities`）。当时 hard-fix 是在 compare() 函数加 alias 处理：

```python
prod_total = prod.get("total_persons", prod.get("total_entities"))
fw_total = fw.get("total_entities", fw.get("total_persons"))
```

但这是 ad-hoc 处理 — framework 跨领域时还会有更多类似 alias（如 `r6_distribution` 在某些案例叫 `external_anchor_distribution` 等）。

### 影响

外部跨领域案例方做自己的 byte-identical test 时需要重写 compare() 函数 —— 不通用。

### 修改建议

v0.2 加通用 alias 机制：

```python
# In test_byte_identical.py or helper module
DEFAULT_ALIASES = {
    "total_persons": "total_entities",
    "person_a_id": "entity_a_id",
    "person_b_id": "entity_b_id",
    # ...
}

def compare(prod, fw, *, field_aliases=DEFAULT_ALIASES):
    """Compare with bidirectional alias support."""
    for prod_key, fw_key in field_aliases.items():
        prod_val = prod.get(prod_key, prod.get(fw_key))
        fw_val = fw.get(fw_key, fw.get(prod_key))
        ...
```

### 处理时机

未来跨领域 case domain 用 byte-identical 测自己的 framework 抽象时优先做。

---

## DGF-N-02 — examples/huadian_classics/ 路径硬编码改环境变量 / 构造函数参数

### 描述

3 个文件用 `Path(__file__).resolve().parents[4] / "data" / ...`：

- `dictionary_loaders.py` (parents[4] / "data" / "dictionaries")
- `dynasty_guard.py` (parents[4] / "data" / "dynasty-periods.yaml")
- `state_prefix_guard.py` (parents[4] / "data" / "states.yaml")

Sprint N 起草时**算错了** — 用 `parents[5]` 跳过项目根，导致 dogfood 第一轮所有 dict / guards 加载失败 → Stop Rule #1 临时触发。

### 影响

文件结构如再变动（如 framework/ 移到 packages/ 子目录），3 个文件都得改 `parents[N]` — fragile。跨领域案例方 fork 时也容易踩同样的坑。

### 修改建议

v0.2：

```python
# In dictionary_loaders.py
def __init__(
    self,
    dict_dir: Path | None = None,
) -> None:
    if dict_dir is None:
        # Try env var first, then fallback to parents-based default
        env_dir = os.environ.get("HUADIAN_DATA_DIR")
        if env_dir:
            dict_dir = Path(env_dir) / "dictionaries"
        else:
            dict_dir = Path(__file__).resolve().parents[4] / "data" / "dictionaries"
    self._dict_dir = dict_dir
```

加 `HUADIAN_DATA_DIR` 环境变量为主路径，构造函数参数为次路径，硬编码为 fallback。

### 处理时机

- v0.2 release 前批量处理
- 或：跨领域案例方 fork 时如踩同样坑触发 priority 升级

---

## DGF-N-03 — framework/identity_resolver/ 加 conftest.py + 单元测试

### 描述

Sprint N 有 sanity tests（10 个，shell oneliner）+ byte-identical dogfood，但没有**结构化 pytest 单元测试**。

### 影响

- 未来 framework 重构时缺乏快速回归测试
- 跨领域案例方做 fork 时缺乏 testing 范本
- CI 集成困难（pytest 是事实标准）

### 修改建议

v0.2 加：

```
framework/identity_resolver/
  tests/
    conftest.py
    test_types.py
    test_union_find.py
    test_rules.py
    test_canonical.py
    test_guards.py
    test_resolve.py
    test_examples_huadian_classics.py
```

每个 test_X.py 至少 3-5 个 pytest test cases。CI 加 `pytest framework/identity_resolver/tests/`。

### 处理时机

- Sprint O 启动时如顺手做
- 或：framework v0.2 release 前作为 quality gate

---

## DGF-N-04 — 至少加 examples/legal/ 或 examples/medical/ 跨领域 reference impl

### 描述

cross-domain-mapping.md 设计了 6 领域 R1-R6 适配（古籍 / 佛经 / 法律 / 医疗 / 专利 / 地方志），但**只有 huadian_classics 真的跑了**。其他 5 领域只有 mapping 表，没有完整 reference impl。

### 影响

- 跨领域 mapping table 是 design intent，不是实证
- "9 个 Plugin Protocol 跨领域可用"的论证只有 1 case（不充分）
- 外部使用者不知道法律 / 医疗领域 instantiation 真长什么样

### 修改建议

v0.2 加至少 1 个跨领域 reference impl：

```
framework/identity_resolver/examples/
  huadian_classics/  (existing)
  legal/             # new — Brown v. Board / 美国判例
    case_loader.py
    citation_dict_loader.py
    jurisdiction_guard.py
    ...
```

这是**最有价值的 v0.2 候选**（甚至可能跳到 v0.3 或独立 sprint）。

### 处理时机

- 跨领域案例方主动接触 → 优先做
- Sprint P 候选议程：跨领域案例 reference impl
- 或：framework v0.2 release 前作为 cross-domain validation

---

## DGF-N-05 — EntityLoader Protocol 加 `load_subset(filters)` 方法

### 描述

当前 `EntityLoader` 只有 `load_all()` — 每次 resolve 全量扫表。对 729 person 数据 OK，但跨领域案例方可能有 100K+ entities，每次全量不现实。

### 影响

- Scaling 受限（O(n²) pairwise + 全量扫表）
- 跨领域案例方做大规模 resolve 时只能自己实现 batching

### 修改建议

v0.2 加 optional 方法：

```python
class EntityLoader(Protocol):
    async def load_all(self) -> list[EntitySnapshot]: ...

    async def load_subset(
        self,
        *,
        modified_after: datetime | None = None,
        ids: list[str] | None = None,
        filters: dict[str, Any] | None = None,
    ) -> list[EntitySnapshot]:
        """Optional: load only a subset for incremental resolve.

        Default impl falls back to load_all() — case domains override
        for efficiency.
        """
        return await self.load_all()
```

resolve_identities() 加 `incremental: bool = False` 参数选择路径。

### 处理时机

- 当 framework 用户首次抱怨 scaling 时
- 或：v0.2 → v0.3 的 scaling 主题

---

## 押后项（Stage 2-3）

| 押后项 | 触发条件 |
|--------|---------|
| framework/identity_resolver/ 外部工程师走通验证 | 1-2 个朋友 / 跨领域案例方主动接触 |
| 跨领域案例方真用 cross-domain-mapping.md 做 instantiation | 同上 / 与 DGF-N-04 联动 |

---

## 与 Sprint L + M 衍生债合并视图

| Sprint | 总 v0.2 候选 | 已 patch | 仍待 v0.2 |
|--------|-----------|---------|----------|
| L (T-P3-FW-001~004) | 4 | 0 | 4 |
| M (DGF-M-01~07) | 7 | 6 (DGF-M-02~07) | 1 (DGF-M-01) |
| N (DGF-N-01~05) | 5 | 0 | 5 |
| **合计** | **16** | **6** | **10** |

---

## v0.2 release 触发条件评估

Sprint N closeout §2.4 给出 v0.2 release 候选条件：

- ✅ ≥ 3 个抽象资产稳定（sprint-templates + role-templates + identity_resolver）
- ✅ byte-identical 严格 dogfood 通过（framework 抽象正确性已证）
- ⏳ 累计 ≥ 15 项 v0.2 候选（已达 16）
- ⏳ Sprint O 完成（V1-V11 invariant scaffold） — 推荐时机
- ⏳ 跨领域案例方主动接触 — 触发立即处理 DGF-N-04 + 优先 release

→ **v0.2 release 准备状态**：条件成熟，等待 Sprint O 完成或外部反馈触发。

---

**本债务清单 sprint N 起草于 2026-04-30 / Sprint N Stage 4 closeout**
