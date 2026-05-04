# Invariant Pattern — V1-V11 Formal Data Correctness for KE Projects

> Status: **Draft v0.1**
> Date: 2026-04-29
> Owner: 首席架构师
> Source: 华典智谱 V1-V11 真实实现 + ADR-023 / ADR-024 / Sprint F/H/I

---

## 0. TL;DR

KE 项目的"数据是否对"问题不能靠 review 兜底，必须形式化为 **invariant**：项目数据**永远必须满足**的约束，每次 sprint 收口必跑全绿，违反 = sprint 阻塞。

AKE 框架将 invariant 抽象为 **5 大类 pattern**（领域无关）：

| Pattern | 一句话 | 华典智谱实例 |
|---------|-------|-------------|
| Upper-bound | 某属性的上限 | V1: each person ≤ 1 primary name |
| Lower-bound | 某属性的下限 | V9: each active person ≥ 1 primary name |
| Containment | 集合 A ⊆ 集合 B | V8: short name ⊆ long name prefixes |
| Orphan detection | 无下游引用的孤立行 | V10 子规则: orphan target / orphan entry |
| Cardinality bound | 关联表的行数边界 | V11: anti-ambiguity count constraint |

实证：22 单元测试覆盖 V1-V11，每次 sprint 收口必跑全绿。Sprint A-K 累计修复多次因 invariant 触发的 bug（V1=94→0 / V8 prefix-containment / V9 bootstrap 等）。

本文件给出：(1) Invariant 设计原则；(2) 5 大类 pattern 详解；(3) 设计契约；(4) 跨领域指南；(5) 反模式。

---

## 1. Invariant 与 QC Rule 的区别

很多 KE 项目混淆了 **invariant** 和 **QC rule**。AKE 框架严格区分：

| 维度 | Invariant | QC Rule |
|------|-----------|---------|
| 性质 | 形式化约束（"必须满足"）| 启发式规则（"通常应该满足"）|
| 违反时 | 阻断 commit / sprint | 警告 / 报告，不阻断 |
| 修复要求 | 立即修复或 rollback | 排进 backlog 处理 |
| 实现 | 单元测试 / DB 约束 / pre-commit hook | 定时报告 / dashboard / alert |
| 数量 | 少而精（华典智谱 11 个）| 多（华典智谱 ~30 个 QC-D / QC-P 规则）|
| 例子 | "active person 必须有 primary name" | "active person 应有 birth_year" |

**核心判断**：如果"违反"是 schema 错误而非业务异常 → 是 invariant；如果"违反"是质量问题而非结构问题 → 是 QC rule。

---

## 2. 5 大类 Invariant Pattern（领域无关）

### 2.1 Upper-bound — 某属性的上限

**模板**：

```sql
-- 任何 entity 的 X 属性数量必须 ≤ N
SELECT entity_id, COUNT(*) AS x_count
FROM entity_attributes
GROUP BY entity_id
HAVING COUNT(*) > N;
-- 必须返回 0 行
```

**华典智谱实例**：

| Invariant | 描述 | N |
|-----------|------|---|
| V1 | 每个 person 至多 1 个 primary name | 1 |
| (V2 retired) | — | — |

**跨领域示例**：

- 法律：每份合同至多 1 个 primary 当事方
- 医疗：每个病例至多 1 个主诊断
- 专利：每个专利至多 1 个 first 发明人

### 2.2 Lower-bound — 某属性的下限

**模板**：

```sql
-- 任何 active entity 必须有 ≥ N 个 X 属性
SELECT e.id, e.slug
FROM entities e
WHERE e.deleted_at IS NULL
  AND NOT EXISTS (
      SELECT 1 FROM entity_attributes ea
      WHERE ea.entity_id = e.id AND ea.x_type = 'X'
  );
-- 必须返回 0 行
```

**华典智谱实例**：

| Invariant | 描述 | N |
|-----------|------|---|
| V9 | 每个 active person 至少 1 个 primary name | 1 |

**跨领域示例**：

- 法律：每个 active 合同至少 1 个 当事方
- 医疗：每个 active 病例至少 1 个主诊断
- 专利：每个 active 专利至少 1 个 发明人

### 2.3 Containment — 集合 A ⊆ 集合 B

**模板**：

```sql
-- 集合 A 必须是集合 B 的子集
SELECT a.id FROM table_a a
WHERE NOT EXISTS (
    SELECT 1 FROM table_b b WHERE matches_predicate(a, b)
);
-- 必须返回 0 行
```

**华典智谱实例**：

| Invariant | 描述 |
|-----------|------|
| V8 | 短名（prefix）必须包含于长名（full name）的某个前缀 |

实证：`管` 是 `管叔鲜` 的合法 prefix；`蔡` 是 `蔡叔度` 的合法 prefix。如果数据库出现 `管` 但没有任何 `管X` 长名，这是结构问题。

**跨领域示例**：

- 佛经：术语短形必须包含于全称集合（"般若" ⊆ "般若波罗蜜多")
- 法律：合同短名（A 与 B）必须包含于完整当事方列表
- 医疗：诊断缩写必须包含于 ICD-10 全称表

### 2.4 Orphan detection — 无下游引用的孤立行

**模板**：

```sql
-- 任何被引用的实体不应在源表 deleted_at IS NOT NULL
SELECT s.id, s.target_id
FROM source_table s
JOIN target_table t ON s.target_id = t.id
WHERE t.deleted_at IS NOT NULL;  -- orphan reference
-- 必须返回 0 行

-- 任何 active 引用必须指向 active 目标
-- 任何 alias 必须有对应的 primary
-- ...
```

**华典智谱实例（V10）**：

| Sub-rule | 描述 |
|----------|------|
| V10a | seed_mapping.target_id 必须指向 active person（无 orphan target）|
| V10b | seed_mapping 必须有对应 dictionary_entry（无 orphan entry）|
| V10c | 每个 active seed_mapping 必须有 ≥ 1 active source_evidence |

**跨领域示例**：

- 法律：判例引用的法条必须存在
- 医疗：处方引用的药品必须未下架
- 专利：claim 引用的 prior art 必须有效

### 2.5 Cardinality bound — 关联表的行数边界

**模板**：

```sql
-- 某关联表的行数必须 ≤ N（或 ≥ M / between M and N）
SELECT a_id, COUNT(*) AS rel_count
FROM relations
WHERE relation_type = 'X'
GROUP BY a_id
HAVING COUNT(*) NOT BETWEEN M AND N;
-- 必须返回 0 行
```

**华典智谱实例**：

| Invariant | 描述 |
|-----------|------|
| V11 | Anti-ambiguity cardinality（disambiguation_seeds 反向歧义防御）|

**跨领域示例**：

- 法律：每份合同的修订版本数必须有上限
- 医疗：每个手术的参与医生数必须有上下限
- 专利：每个专利的 claim 数必须有合理上限

---

## 3. Invariant 设计契约（C-23 应用）

### 3.1 必须满足的设计要求

任何新 invariant 必须满足：

1. **领域无关接口**：函数签名不含 domain-specific 类型；用 generic `Entity`, `Relation`, `Attribute` 等
2. **domain-specific 参数显式化**：领域规则 = 配置文件 / yaml / json 注入，**不硬编码**
3. **失败可追溯**：违反时必须输出违反行的标识符（如 person.id），不能只说"有错"
4. **测试覆盖 ≥ 3 case**：positive / negative / boundary 各 1
5. **触发时机文档化**：每次 sprint 收口 / 每次相关代码合入 / 等
6. **修复路径文档化**：违反后**怎么修**（rollback / data fix / etc）必须在 ADR 中说明

### 3.2 invariant 命名约定

`V{N}_{short_purpose}.py`：

- V1 — primary_name_upper_bound
- V8 — prefix_containment
- V9 — at_least_one_primary
- ...

测试文件 `test_invariants_v{N}.py`。

### 3.3 实现模板

```python
# Pseudocode template
import pytest

INVARIANT_QUERY = """
    SELECT id, slug
    FROM entities
    WHERE [your invariant violation predicate]
"""

@pytest.mark.skipif(
    not os.environ.get("DATABASE_URL"),
    reason="DATABASE_URL not set",
)
def test_v_N_bootstrap():
    """Invariant V_N must hold over current DB state."""
    rows = query(INVARIANT_QUERY)
    assert len(rows) == 0, f"V_N violations: {rows}"

def test_v_N_synthetic_violation():
    """Verify the invariant catches a known bad state."""
    # insert violating row → run query → assert violation found

def test_v_N_synthetic_compliance():
    """Verify the invariant accepts a known good state."""
    # insert compliant row → run query → assert no violation
```

### 3.4 Invariant 上线流程

```
1. ADR：proposes the invariant
   - 5 大 pattern 选一
   - SQL query draft
   - 修复路径
2. 实现 + 3 测试 case
3. Bootstrap 测试：current DB 必须 = 0 violations（如果有，先 fix）
4. 集成到 Sprint Gate
5. 每次 sprint 收口必跑
```

---

## 4. 跨领域使用指南

### 4.1 启动新案例时设计 invariants

**Step 1: 列出领域的"数据正确性铁律"**

业务专家口述 → 工程师整理：

例：法律领域可能有

- "任何 active 合同至少 1 个当事方"
- "签署日期不晚于解除日期"
- "未解除合同不能有 dissolved_at 字段"
- ...

**Step 2: 把每条铁律映射到 5 大 pattern**

| 铁律 | Pattern |
|------|---------|
| 至少 1 个当事方 | Lower-bound |
| 签署日期 ≤ 解除日期 | Cardinality（特殊版：单行内字段约束）|
| 未解除合同不能有 dissolved_at | (其实是 SQL CHECK 约束，不是 invariant pattern) |

注意：5/5 pattern 都套不进的 → 多半是 QC rule 或 schema 约束，不是 invariant。

**Step 3: 实现 + 测试 + 集成**

```bash
mkdir -p tests/invariants/
touch tests/invariants/test_v1_at_least_one_party.py
# 按 §3.3 模板填充
```

**Step 4: Sprint Gate 集成**

```bash
# 在 sprint 收口 checklist 加：
pytest tests/invariants/ → 必须全绿
```

### 4.2 Invariant 数量建议

- 启动期（Sprint A-C）：3-5 个最关键 invariant
- 中期（Sprint D-G）：扩展到 7-10 个
- 成熟期（Sprint H+）：10-15 个

超过 15 个通常说明：
- 部分 invariant 是 QC rule，应转移
- 部分 invariant 应改为 schema CHECK 约束
- 或领域复杂度本身要求多 invariant

---

## 5. 实证：Sprint F V1=94→0 修复

### 5.1 触发

Sprint E 后例行 V1 检测发现 **94 violations**（每个 person 至多 1 primary，但出现 N 个 person 有 ≥ 2 primary）。

### 5.2 根因诊断

PE 调查发现是 `load.py` 中 `_insert_person_names` 函数的 2 个 bug：

1. **Bug 1**：name_zh 默认 `is_primary=true` → 导致同一 person 多次插入时累积多个 primary
2. **Bug 2**：is_primary 字段硬编码 → 后续修订时不更新

### 5.3 修复路径

```
Stage 0: 根因诊断 + 数据基线
Stage 1: load.py 修复（~15 行 + 函数级 guard + 3 unit tests）
Stage 2: V1 94→0 回填（125 行 UPDATE 单事务 + pg_dump anchor）
Stage 3: V9 invariant 上线（lower-bound, 防止反向）
Stage 4: 既有数据小修（tongjia / disambig_seeds 扩充）
Stage 5: 验证 V1=0 / V9=0 / V10=0 / V11=0
```

### 5.4 抽象洞察

V1 invariant 的**存在**让 bug 被发现（如果没 invariant，可能很久才察觉）。
V9 invariant 的**新增**防止反向问题（修了 Bug 1+2 后可能反方向出现"无 primary"）。

→ Invariant 不只是检测，是"双向保险"。

---

## 6. 反模式

### 6.1 反模式：把 QC rule 当 invariant

❌ "每个 person 应该有 birth_year" 设为 invariant

✅ 这是 QC rule，记录违反但不阻断；很多历史人物本身没有 birth_year 数据

### 6.2 反模式：硬编码领域规则

❌ invariant SQL 里写 `WHERE dynasty IN ('汉', '唐')`

✅ 领域常量从配置文件加载

### 6.3 反模式：跳过 bootstrap 测试

❌ 新 invariant 上线时不做 current DB bootstrap test

✅ 必须先 verify current DB = 0 violations；否则上线即违反

### 6.4 反模式：无修复路径文档

❌ "violation 了，请 fix" — 但不说"怎么 fix"

✅ ADR 中明确：发现 violation 时是 rollback / data backfill / etc 哪条路径

### 6.5 反模式：太多 invariants

❌ 30+ 个 invariants，每次 sprint 收口跑 30+ 个测试

✅ 控制在 10-15 个核心 invariants；其余降级为 QC rules

---

## 7. Framework Implementation（v0.1.1 新增）

本模式的 v0.1 框架实现位于 `framework/invariant_scaffold/`（Sprint O Stage 1 首次抽象 / dogfood PASSED 11/11 + 4/4）：

- **Framework core**（18 files / ~1335 lines）：types / port / invariant + 5 pattern subclass + runner + self_test + __init__
- **examples/huadian_classics/**（13 files / ~946 lines）：11 invariants + 4 self-tests + asyncpg adapter
- **4 Plugin Protocol**：DBPort / Invariant ABC / SelfTest / SelfTestRunner
- **3 份文档**：README / CONCEPTS / cross-domain-mapping（5 pattern × 6 领域）

跨领域案例方应**先复制 framework/invariant_scaffold/ 改填**，再回过头读本文件理解设计哲学。

| 本文件章节 | framework/invariant_scaffold/ 对应实现 |
|---------|--------------------------------|
| §2.1 Upper-bound | patterns/upper_bound.py + V1 (huadian implicit) |
| §2.2 Lower-bound | patterns/lower_bound.py + V4 / V9 (huadian) |
| §2.3 Containment | patterns/containment.py + V8 / V10.c / active_merged / slug_format (huadian) |
| §2.4 Orphan detection | patterns/orphan_detection.py + V10.a / V10.b (huadian) |
| §2.5 Cardinality bound | patterns/cardinality_bound.py + V6 / V11 / slug_no_collision (huadian) |
| §3 Bootstrap pattern | examples/huadian_classics/runner_setup.py |
| §4 Self-test 模式 | self_test.py（SelfTest Protocol + SelfTestRunner）+ examples self_tests.py |

**dogfood 实证**：11 huadian invariants 跑 production data 全 0 violations + 4 self-tests 注入违反全 catch。详见 `docs/sprint-logs/sprint-o/stage-1-dogfood-2026-04-30.md`。

---

## 8. Self-Test Pattern（v0.2 新增 / Sprint X 批 2 / first-class 抽出）

§3.3 实现模板 + §4 Self-test 模式 + §7 Framework Implementation + §9.3 self-test 强化措施散落论及 self-test。本节抽出 first-class，定义 self-test 在 invariant pattern 内的独立地位。

### 8.1 定义

**Self-Test Pattern** = 在 invariant 实现的同一框架内，**主动注入违反 → verify catch → auto-rollback** 的测试模式。区别于"被动等价性测试"（byte-identical / soft-equivalent），self-test 是"主动 dogfood"。

核心机制：
1. 在 transaction 中**故意制造违反 SQL invariant 的数据状态**
2. 跑 invariant query → assert 命中违反（catch）
3. transaction rollback → production data 安全

### 8.2 vs byte-identical / soft-equivalent dogfood — 第 4 个 dogfood 等级

| 等级 | 模式 | 验证目标 | 实证 |
|------|------|---------|------|
| L1 byte-identical | 跑 framework + production 双路径 / 字段逐字一致 | 抽象未引入差异 | Sprint N identity_resolver |
| L2 soft-equivalent (同 stack) | 跑 framework + production / 业务等价但字段允许变（数据状态） | 抽象语义一致 | Sprint O invariant_scaffold (production 11 invariants 0 violations) |
| L3 soft-equivalent (跨 stack) | 跑 Python framework + TypeScript production / 字段一致 | 跨 stack 抽象未引入差异 | Sprint Q audit_triage |
| **L4 self-test (主动)** | **transaction 内主动注入违反 / verify catch / auto-rollback** | **invariant query 真的在 check（防 false-pass）** | **Sprint O invariant_scaffold 4/4 catch ⭐** |

L4 与 L1-L3 **互补 ≠ 替代**。invariant 类 framework 推荐 L2/L3 + L4 **并行**。

### 8.3 SelfTest Protocol 设计契约（per Sprint O 实证）

```python
class SelfTest(Protocol):
    name: str  # e.g., "v9_lower_bound_self_test"
    target_invariant: str  # e.g., "v9"

    async def setup_violation(self, conn) -> None:
        """在 transaction 内插入违反 invariant 的数据."""

    # framework 自动跑 invariant query → assert 命中
    # framework 自动 ROLLBACK transaction
```

`SelfTestRunner`：
1. `BEGIN`
2. `setup_violation(conn)`
3. 跑对应 invariant query
4. assert violations > 0（"catch"）
5. `ROLLBACK`（强制）

### 8.4 何时必须配 self-test

**必须配**：
- ✅ Critical 严重度 invariant（违反 = 数据完整性破坏 / e.g. V1 V9 V10）
- ✅ 涉及 SQL 阈值的 invariant（e.g. cardinality bound / 阈值改错容易 false-pass）
- ✅ 跨 stack 抽象的 invariant（per §9.3 / production stack ≠ framework stack / catch SQL 方言差异）

**可省**：
- ❌ 低严重度 invariant（违反不阻断 / 可能其实是 QC rule / per §1）
- ❌ 仅 schema CHECK 约束（DB 自身保证）

### 8.5 跨 invariant 类 framework 启示

self-test 是 **invariant 类 framework 独有的强化模式**。identity_resolver / audit_triage 没有同等 pattern，因为：

- identity_resolver: byte-identical 已经是最强等价测试（足够）
- audit_triage: 跨 stack soft-equivalent 但 audit 是不可变 append-only（没有"主动注入违反"的对应概念）

invariant 类 framework 的特殊之处：query 写错 / 阈值改错 → "绿但其实没在 check"。self-test 是这类 false-pass 的唯一防御。

### 8.6 详细实证 + 反模式 (deferred to v0.2.1)

> 8.6.1 Sprint O 4/4 catch 详细实证 + 8.6.2 self-test 反模式 章节按 Sprint X brief §7 Stop Rule 应对方案 B 押后到 v0.2.1（控制 v0.2 doc 体量在 Stop Rule #4 阈值 450 行内）。
>
> 当前可参考：§7 Framework Implementation + §9.3 self-test 强化措施段（已含核心实证锚点）。

---

## 9. 与 methodology/02 跨 stack 抽象 pattern 的关系（v0.1.2 新增 / Sprint S 批 4 / v0.2 §8.x 重编 §9.x）

methodology/02-sprint-governance-pattern.md v0.1.1 (Sprint R) §13 提出"跨 stack 抽象 pattern"。本文件描述的 invariant_scaffold 是该 pattern 的**首批实证**之一（Sprint O 同 stack soft-equivalent / 与 Sprint Q audit_triage 跨 stack soft-equivalent 形成对比）。

### 9.1 跨 stack 抽象 pattern 在 invariant_scaffold 的实证（Sprint O）

Sprint O 把 services/pipeline/tests/test_invariants_*.py + qc/* 的 11 invariants 抽象到 framework/invariant_scaffold/（Python → Python，**同 stack**）。但与 Sprint N identity_resolver 的 byte-identical 不同，invariant_scaffold 走 **soft-equivalent + self-test 注入** 双 dogfood：

- production query: 11 invariants 直接跑 services/pipeline 实现 → 0 violations
- framework path: 11 invariants 跑 framework/invariant_scaffold + examples/huadian_classics adapter → 0 violations
- self-test 注入: 4 SelfTest impl 通过 SelfTestRunner 在 transaction 中注入违反 → 4/4 catch + auto-rollback

**与 §02 §13 的关系**：
- methodology/02 §13.3 Step 1 (SQL 逐字 port) → invariant_scaffold **完全采用**：5 pattern subclass 内的 SQL 模板与 production 一一对应
- methodology/02 §13.3 Step 2 (业务逻辑分层) → invariant_scaffold **简化**：Invariant ABC + 5 pattern subclass + DBPort Protocol + Runner / SelfTestRunner / 4 Plugin Protocol（vs identity_resolver 9 Protocol）
- methodology/02 §13.3 Step 3 (dogfood 走 soft-equivalent) → invariant_scaffold **采用**：业务逻辑可能因数据状态变化而 violations 数变（例如 V9 在新 person 加入时短暂触发），所以不强求 byte-identical

→ invariant_scaffold 是 methodology/02 §13 的 **soft-equivalent 同 stack 变体**（vs Sprint N 的 byte-identical 同 stack vs Sprint Q 的 soft-equivalent 跨 stack）。3 种组合都实证可行。

### 9.2 vs Sprint N + Sprint Q 跨 stack 抽象对比

| 维度 | identity_resolver (N) | invariant_scaffold (O) | audit_triage (Q) |
|------|----------------------|------------------------|------------------|
| 生产 stack | Python | Python | TypeScript |
| framework stack | Python | Python | Python |
| stack 关系 | 同 stack | 同 stack | **跨 stack** |
| 等价性测试 | byte-identical | soft-equivalent + self-test 注入 | soft-equivalent |
| dogfood 强度 | 729 persons / 17 guards / 0 字段差异 | 11 invariants × 729 persons / 0 violations + 4 self-tests catch | 64 pending / 7 historical / 字段一致 |
| Plugin Protocol 数 | 9 | **4**（DBPort + 3 SelfTest 协议）| 6 |
| 案例耦合点 | 9 dictionary / dynasty / etc | **5 SQL 模板**（领域 schema specific）+ 4 self-test scenario | source_table / reason_source_type vocabulary |

→ 3 种组合对应 3 种 dogfood 等级：byte-identical（最强 / 同 stack 才可行）→ soft-equivalent（同 stack 但数据状态可变）→ soft-equivalent（跨 stack）。

### 9.3 self-test pattern 是 invariant_scaffold 独有的强化措施 (v0.2 已抽出 first-class §8 / 见 §8.5)

Sprint O 在 framework 中加了 SelfTest + SelfTestRunner（per §4 Self-test 模式）—— 在 transaction 中**主动注入违反**，验证 invariant 真的会 catch。这是 invariant 类 framework 特有的 **dogfood 强化模式**：

- 与 byte-identical / soft-equivalent 等"被动等价性"测试互补
- 防止 invariant 因 SQL 写错 / 阈值改错 而 false-pass（"绿但其实没在 check"）
- transaction auto-rollback 保证 production data 安全

跨 stack 抽象 pattern (per §02 §13) 在 invariant 类 framework 中可以**额外加 SelfTest**（identity_resolver / audit_triage 没有同等 pattern）。

### 9.4 跨域 fork 案例方启示（同 §02 §13.4 反模式）

本文件（invariant_scaffold）跨域 fork 时：

- ✅ 改 examples/your_domain/ — 实现 5 pattern subclass 的 SQL 模板（必要的 DBPort + SelfTest impl）
- ✅ 写你的领域的 V1-Vn invariants（每个用相应 pattern）
- ✅ 写 ≥ 1 SelfTest per critical invariant（self-test 是 invariant 类 framework 的"质保")
- ❌ 不要复用 huadian_classics 的 SQL（schema 不同 / 必须 rewrite）
- ❌ 不要跳过 self-test（特别是 critical 严重度的 invariant）

### 9.5 实证锚点（Sprint O + 跨 sprint 数据）

| Sprint | 实证 | 数据点 |
|--------|------|--------|
| O (soft-equivalent + self-test) | 11 invariants × 729 persons / 0 violations + 4 self-tests / 4/4 catch | `docs/sprint-logs/sprint-o/stage-1-dogfood-2026-04-30.md` |
| Q (audit_triage soft-equivalent / 跨 stack) | 64 pending / 字段一致 | `framework/audit_triage/examples/huadian_classics/test_soft_equivalent.py` |

→ 与 methodology/03 §9.2 表对比 / 跨 stack 抽象 pattern (per §02 §13) 在 identity + invariant + audit_triage 三个 framework 各自实证。

---

## 10. 修订历史

| Version | Date | Author | Change |
|---------|------|--------|--------|
| Draft v0.1 | 2026-04-29 | 首席架构师 | 初稿（Stage C-8 of D-route doc realignment）|
| Draft v0.1.1 | 2026-04-30 | 首席架构师 | Sprint O Stage 1 cross-reference §7 加（紧密化 framework/invariant_scaffold/）|
| Draft v0.1.2 | 2026-04-30 | 首席架构师 | Sprint S 批 4 polish：加 §9 (原 §8) 与 methodology/02 跨 stack 抽象 pattern 的关系（5 段 cross-ref + 3 种 dogfood 组合对比 + self-test 强化模式 + 跨域 fork 启示）|
| **v0.2** | **2026-04-30** | **首席架构师** | **Sprint X 批 2 大 bump：加 §8 Self-Test Pattern first-class（定义 + L4 dogfood 等级 + SelfTest Protocol 设计契约 + 何时必须配 + 跨 framework 启示）；§8.6 详细实证 + 反模式按方案 B 押后 v0.2.1（控制 doc 体量 / Sprint X brief §7 Stop Rule 应对）；§修订历史 §9 → §10 重编号** |

---

> 本文档描述的 Invariant Pattern 是 AKE 框架的 Layer 1 核心资产之一。
> V1-V11 实证细节见 `services/pipeline/tests/test_invariants_*.py`。
> Sprint O 是其首次框架抽象 + dogfood PASSED（11/11 + 4/4）。
> Sprint S §9 (原 §8) 把它链接回 methodology/02 §13 跨 stack 抽象 pattern + 与 identity / audit_triage 形成 3 种 dogfood 组合对比。
> Sprint X §8 抽出 Self-Test Pattern first-class（L4 主动 dogfood 等级）+ §8.6 押后 v0.2.1。
