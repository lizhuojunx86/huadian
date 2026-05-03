# Sprint P 衍生债 — v0.2 押后到 Sprint Q+ 的残余清单

> Status: registered（押后状态）
> 来源 sprint: Sprint P Stage 4 closeout (2026-04-30)
> 优先级: 6 项 P3（Sprint Q+ 触发条件成熟时处理）
> 触发条件: 见每项 §"处理时机"

---

## 0. 总览

Sprint P (v0.2 release) 收口 8 项 v0.2 patch（1 P2 + 7 P3），剩余 6 项押后到 Sprint Q+。

押后理由（统一）：这 6 项在 Sprint M-O 已识别但属于"大工作"或"等外部触发"，强行打包进 Sprint P (v0.2 release sprint) 会拉长 sprint scope 违反"清债 sprint 应保持轻量"的设计原则。

合并 Sprint L+M+N+O+P 累计 v0.2 状态：**20 项候选 / 14 项已 patch / 6 项 v0.2 押后**。

---

## DGF-N-03 + DGF-O-02 — pytest 单元测试缺失（2 模块）

### 描述

Sprint N 的 `framework/identity_resolver/` 和 Sprint O 的 `framework/invariant_scaffold/` 两个 code 模块都缺 pytest 单元测试套件。当前依赖：
- in-script 一行 sanity（Sprint N 抽象时验证 import / 基本 flow）
- dogfood 验证（byte-identical Sprint N / soft-equivalent Sprint O）

但没有：
- conftest.py（pytest fixture）
- 各 module 单独 test file（test_types.py / test_runner.py / test_*.py）
- CI 集成可跑的测试

### 影响

- 重构时缺乏快速回归（每次改动只能跑慢的 dogfood）
- 跨领域 fork 案例方缺 testing 范本
- CI 集成困难（dogfood 依赖完整 production DB）

### 修改建议

**identity_resolver**:
```
framework/identity_resolver/tests/
  conftest.py
  test_types.py
  test_entity.py
  test_union_find.py
  test_guards.py
  test_rules.py (8 rules)
  test_canonical.py
  test_resolve.py (orchestration smoke)
  test_apply_merges.py
  test_examples_huadian.py (smoke import)
```
~30 tests / ~600 lines

**invariant_scaffold**:
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
~25 tests / ~500 lines

### 处理时机

Sprint Q+ — 形态选项：

- **选项 A**：合并到 Sprint Q 候选 A（audit_triage 抽象）一并做（Stage 1 加"补 N+O+Q 三模块测试"批）
- **选项 B**：单独"测试 sprint"（Sprint Q+0.5），1 会话内完成两模块测试
- **选项 C**（不推荐）：押到 v0.3 release 前批量

**推荐 A**（与 audit_triage 同 sprint 落地，避免单独 sprint overhead）。

---

## DGF-N-04 + DGF-O-03 — 跨领域 reference impl 缺失（2 领域 × 2 模块）

### 描述

cross-domain-mapping.md 设计 6 领域适配，但只有 huadian 真跑了 dogfood：
- identity_resolver：14 huadian_classics examples 完整；其他领域 0 案例
- invariant_scaffold：13 huadian_classics examples 完整；其他领域 0 案例

### 影响

- 跨领域 mapping 只是 design intent，未实证
- 5 pattern + R1-R6 + guard chain 的跨领域 valid 论证只有 huadian 1 case
- 跨领域案例方 fork 时无 reference impl 可参考（只有华典智谱古籍数据）

### 修改建议

至少加 1 个跨领域 reference impl：

**legal**（推荐，简单业务 schema 适合示范）：
- examples/legal_contracts/ for identity_resolver（合同方实体 R1-R6 适配）
- examples/legal_contracts/ for invariant_scaffold（合同完整性 5 pattern）

**medical**（备选，PHI 处理偏复杂）：
- examples/medical_records/ for identity_resolver（患者实体匹配，R5 alias 复杂）
- examples/medical_records/ for invariant_scaffold（处方 vs 药物 formulary 包含关系等）

### 处理时机

**等触发条件成熟**：
- A. 跨领域案例方主动接触（GitHub Issue / Email）→ 优先做对方领域 reference impl
- B. 主动起 1 个 legal example sprint（Sprint Q+1 或更晚）—— 这是 D-route Layer 3 第二案例的下一刀，但需要明确目标受众

**不建议在无外部触发时主动起**——避免 maintainer 单方面"猜"跨领域需求。

---

## DGF-N-05 — EntityLoader.load_subset feature

### 描述

当前 `EntityLoader` 只支持 `load_all()` —— 全表加载所有 active entities。

跨领域案例方可能需要：
- 按 dimension 子集加载（如 "只解析 dynasty in (周, 春秋, 战国)" 的 person 子集）
- 按时间窗口加载（"近 30 天新增 entities 的 incremental resolve"）
- 按 entity_type 加载（multi-tenant schema）

### 影响

- 增量 resolve 能力缺失 → 数据规模 ≥ 100k entities 时性能瓶颈
- 多租户 / 多领域共表场景无法分别 resolve

### 修改建议

```python
class EntityLoader(Protocol):
    async def load_all(self) -> list[EntitySnapshot]: ...

    # 新增（v0.3 候选）
    async def load_subset(
        self,
        *,
        filter_predicate: Callable[[EntitySnapshot], bool] | None = None,
        sql_where_clause: str | None = None,
    ) -> list[EntitySnapshot]: ...
```

PySQL where clause + Python predicate 二者择一或叠加。

### 处理时机

**等用户提需求**。当前 huadian 数据量 ~700 person，全量加载性能不是瓶颈；跨领域案例方若数据量大会自然触发。

不主动做，免得设计 over-engineered。

---

## 押后项 vs 处理时机汇总

| ID | 描述 | 推荐 sprint | 触发条件 |
|----|------|-----------|---------|
| DGF-N-03 + DGF-O-02 | pytest tests for identity_resolver + invariant_scaffold | **Sprint Q（合并 audit_triage 抽象）** | 与候选 A 同 sprint |
| DGF-N-04 + DGF-O-03 | examples/legal/ or /medical/ 跨领域 reference impl | **Sprint Q+N（条件触发）** | 跨领域案例方主动接触 |
| DGF-N-05 | EntityLoader.load_subset | **不定**（用户驱动）| 用户 / 案例方提需求 |

---

## 6 项押后清单与 v0.3 release 路径

按当前估算，6 项押后处理路径：

```
Sprint Q (audit_triage 抽象)
├─ Stage 1 主体: audit_triage 抽出
├─ Stage 1.X 加批: 补 identity_resolver + invariant_scaffold pytest tests (DGF-N-03 + DGF-O-02)
└─ Sprint Q closeout: 6 项 → 4 项

Sprint Q+1 ~ Q+3（视触发）
├─ legal example sprint（如跨领域接触）→ DGF-N-04 + DGF-O-03 落地
├─ EntityLoader.load_subset（如用户提需求）→ DGF-N-05 落地

Sprint Q+N (审视 v0.3 release)
└─ 当 6 项全 land + 累计新 patch ≥ 5-10 项 → 触发 v0.3 release sprint
```

---

## 与 Sprint L+M+N+O+P 衍生债合并视图（最终）

| Sprint | 总 v0.2 候选 | 已 patch | 押后到 v0.2 后 |
|--------|-----------|---------|--------------|
| L (T-P3-FW-001~004) | 4 | 4 ✓ | 0 |
| M (DGF-M-01~07) | 7 | 7 ✓ | 0 |
| N (DGF-N-01~05) | 5 | 2 | 3 |
| O (DGF-O-01~04) | 4 | 3 | 1 |
| P (新增) | 0 | 0 | 0 |
| **合计** | **20** | **14** ✅ Sprint P release 收口 | **6** ⏳ Sprint Q+ |

---

## v0.3 release 触发条件（前瞻）

参考 Sprint O closeout §2.4 的 v0.2 release 触发条件，v0.3 release 候选条件假设：

- ⏳ 押后 6 项全 land
- ⏳ 累计新 v0.3 候选 ≥ 5（当前 0；retro §6 已记 2 项 T-V03-FW-001 / -002）
- ⏳ 5 模块完整（含 Sprint Q audit_triage）
- ⏳ ≥ 1 个跨领域 reference impl（legal 或 medical）
- ⏳ Sprint Q+N 完成后正式 v0.3 release sprint

→ **预估 v0.3 release**：Sprint Q + 3-5 sprint 后（约 2026-06 ~ 2026-08，与 D-route 路线图 2026-08 milestone 对齐）。

---

**本债务清单 Sprint P 起草于 2026-04-30 / Stage 4 closeout / Architect Opus**
