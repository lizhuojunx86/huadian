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

## 7. 修订历史

| Version | Date | Author | Change |
|---------|------|--------|--------|
| Draft v0.1 | 2026-04-29 | 首席架构师 | 初稿（Stage C-8 of D-route doc realignment）|

---

> 本文档描述的 Invariant Pattern 是 AKE 框架的 Layer 1 核心资产之一。
> V1-V11 实证细节见 `services/pipeline/tests/test_invariants_*.py`.
