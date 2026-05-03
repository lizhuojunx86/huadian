# Cross-Domain Mapping — 5 Pattern Adaptation Cheat Sheet

> Status: v0.1 (Sprint O Stage 1)
> Source: framework/role-templates/cross-domain-mapping.md + framework/identity_resolver/cross-domain-mapping.md 同款 6 领域 + 5 pattern 适配

---

## 0. 这是什么

跨领域 KE 项目的"5 invariant pattern instantiation 速查表"。给定 6 个常见领域，每个 pattern 在该领域怎么用、典型 SQL 是什么。

读完应该能回答："如果我做一个 X 领域 KE 项目，5 pattern 在我的 schema 上分别长什么样？"

---

## 1. 5 Pattern × 6 领域速查

### 1.1 Upper-bound（每 entity 某属性 ≤ N）

| 领域 | 典型 invariant |
|------|---------------|
| 古籍（华典）| V1: each person ≤ 1 primary name |
| 佛经 | each sutra ≤ 1 canonical translation |
| 法律 | each contract ≤ 1 primary party |
| 医疗 | each case ≤ 1 main diagnosis |
| 专利 | each patent ≤ 1 first inventor |
| 地方志 | each place ≤ 1 canonical pinyin slug |

### 1.2 Lower-bound（每 active entity ≥ N 个某属性）

| 领域 | 典型 invariant |
|------|---------------|
| 古籍（华典）| V9: every active person ≥ 1 primary name / V4: merged person ≥ 1 person_name |
| 佛经 | every active sutra ≥ 1 translation |
| 法律 | every active contract ≥ 1 party |
| 医疗 | every active case ≥ 1 diagnosis |
| 专利 | every active patent ≥ 1 inventor |
| 地方志 | every active place ≥ 1 alias |

### 1.3 Containment（A ⊆ B）

| 领域 | 典型 invariant |
|------|---------------|
| 古籍（华典）| V8: short single-char name ⊄ unexempted long-name prefixes / V10.c: active mapping ⊆ has-evidence / Slug-A: slug ∈ (Tier-S whitelist ∪ regex) / active-merged ⊆ deleted |
| 佛经 | every cited sutra ⊆ canon database |
| 法律 | every cited case ⊆ jurisdiction database / every statute reference ⊆ codified law |
| 医疗 | every prescribed drug ⊆ approved formulary / every diagnosis code ⊆ ICD-10 |
| 专利 | every prior-art reference ⊆ existing patents / every IPC class ⊆ IPC taxonomy |
| 地方志 | every modern alias ⊆ canonical region table |

### 1.4 Orphan Detection（引用必须指向存在行）

| 领域 | 典型 invariant |
|------|---------------|
| 古籍（华典）| V10.a: active mapping → live person / V10.b: mapping → existing entry |
| 佛经 | translator FK → existing person row |
| 法律 | citation → existing case row / party → existing organization |
| 医疗 | prescription → existing drug formulary entry / lab result → existing patient |
| 专利 | inventor FK → existing person / cited patent → existing patent row |
| 地方志 | parent_region → existing region |

### 1.5 Cardinality Bound（计数等于精确值或在范围内）

| 领域 | 典型 invariant |
|------|---------------|
| 古籍（华典）| V6: count(alias+is_primary) == 0 / V11: per-person active mapping ≤ 1 / Slug-B: per-slug count == 1 |
| 佛经 | per-sutra primary translator count ≤ 1 |
| 法律 | per-case primary cite count ≤ 1 / per-jurisdiction supreme court instance count == 1 |
| 医疗 | per-patient active prescription in [0, 50] / per-lab unique result count == 1 |
| 专利 | per-invention independent claim count ≥ 1 / per-patent reissue count ≤ 1 |
| 地方志 | per-modern-name canonical place count == 1 |

---

## 2. Severity 跨领域适配

| 领域 | 典型 critical | 典型 warning | 典型 info |
|------|------------|------------|-----------|
| 古籍 | V1/V4/V6/V8/V9/V10/V11/slug-collision | V7 (待 backfill) | row count sanity |
| 佛经 | translation 完整性 / 校对 cardinality | scholarly note coverage | 经文长度 sanity |
| 法律 | citation orphan / jurisdiction unique | precedent 待引用 | 判决书 word count |
| 医疗 | drug interaction / dose range / PHI protection | guideline 待引用 | patient row count |
| 专利 | claim 编号 unique / IPC 有效 | 自引检查 | 专利 page count |
| 地方志 | 行政区划 hierarchical orphan | 别名待整理 | 地名 row count |

---

## 3. DBPort 跨领域适配

DBPort Protocol 是无 backend-assumption 的 — 案例方实现自己的 driver。常见适配：

| 领域 / 技术栈 | DBPort 实现思路 |
|-------------|----------------|
| asyncpg + PostgreSQL | 直接用 examples/huadian_classics/db_port.py 模板 |
| aiopg + PostgreSQL | 类似，方法名映射差异 |
| async SQLAlchemy + 任意 SQL DB | 用 session.execute() + result.mappings() 转 dict |
| MongoDB (motor) | fetch/fetchval 实现 motor 查询；transaction() 用 client.start_session() |
| REST API（远程 KE 服务）| HTTP client 包装 |

---

## 4. Self-test 跨领域 instantiation

### 4.1 通用模板

```python
class MyInvariantSelfTest:
    name = "my_invariant_st"
    invariant_name = "MY_V1"

    async def setup_violation(self, port):
        # 注入符合违反条件的 row
        await port.execute("INSERT INTO ... VALUES (...)")

    def expected_violation_predicate(self, violation):
        # 验证 invariant 返回的 violation 包含注入数据的标识
        return violation.row_data.get("id", "").startswith("test-")
```

### 4.2 跨领域注入策略

| 领域 | 典型注入 |
|------|---------|
| 古籍 | 插入 person + name with 错误 is_primary |
| 佛经 | 插入 translator + 0 translations → Lower-bound 应 catch |
| 法律 | 插入 citation pointing to non-existent case → Orphan 应 catch |
| 医疗 | 插入 patient + 0 diagnosis → Lower-bound 应 catch |
| 专利 | 插入 patent + 2 first inventors → Upper-bound 应 catch |
| 地方志 | 插入 region + parent_region 不存在 → Orphan 应 catch |

---

## 5. 完整 instantiation example — 法律案例

假设你做一个判例 KE 项目。完整 invariant suite 步骤：

### 5.1 创建 examples/legal/

```
framework/invariant_scaffold/examples/legal/
  __init__.py
  db_port.py                       # asyncpg adapter for legal DB
  invariants_citation_orphan.py    # Orphan: citation → existing case
  invariants_party_existence.py    # Orphan: party FK → existing org/person
  invariants_active_contract.py    # Lower-bound: active contract ≥ 1 party
  invariants_unique_jurisdiction.py # Cardinality: per-case jurisdiction == 1
  invariants_one_primary_party.py  # Upper-bound: each contract ≤ 1 primary
  self_tests.py                    # 5 self-tests
  runner_setup.py                  # build_legal_runner factory
```

### 5.2 定义 invariant

```python
# invariants_active_contract.py
from framework.invariant_scaffold import LowerBoundInvariant

ACTIVE_CONTRACT_PARTY_SQL = """
    SELECT c.id::text, c.title
    FROM contracts c
    WHERE c.status = 'active'
      AND NOT EXISTS (
          SELECT 1 FROM contract_parties cp
          WHERE cp.contract_id = c.id
      )
"""

def make_active_contract_party() -> LowerBoundInvariant:
    return LowerBoundInvariant.from_template(
        name="active_contract_party",
        description="every active contract must have ≥ 1 party",
        sql=ACTIVE_CONTRACT_PARTY_SQL,
        min_count=1,
        violation_explanation_fmt="contract {id} ({title}) has 0 parties",
    )
```

### 5.3 跑

```python
from framework.invariant_scaffold.examples.legal.runner_setup import build_legal_runner
from framework.invariant_scaffold.examples.legal.db_port import LegalAsyncpgPort

runner = build_legal_runner(port=LegalAsyncpgPort(pool))
report = await runner.run_all()
runner.assert_all_pass(report)
```

→ 完整 instantiation < 200 行 plugin 代码 / framework 0 修改。

---

## 6. 添加新领域到本表（贡献指南）

如果你用 `framework/invariant_scaffold/` 启动了一个**本表未覆盖的领域**（如金融文档 / 学术论文 / 代码 corpus / etc），欢迎：

1. 在 `examples/` 下做完你的 instantiation（按 §5 模式）
2. 把你的新领域行加到 §1 5 pattern × 领域 表
3. 提 GitHub PR 标 `cross-domain-contribution`

期望随贡献增加，本表覆盖 ≥ 10 领域。

---

## 7. 修订历史

| Version | Date | Change |
|---------|------|--------|
| v0.1 | 2026-04-30 | 初版（Sprint O Stage 1）/ 6 领域 5 pattern mapping |

---

> 本文件继承 framework/role-templates/cross-domain-mapping.md + framework/identity_resolver/cross-domain-mapping.md 同款 6 领域结构，但聚焦 invariant pattern 适配。三文档配合使用：role-templates 是 who（谁来做）/ identity_resolver 是 how-to-resolve（怎么消歧）/ invariant_scaffold 是 how-to-verify（怎么验证）。
