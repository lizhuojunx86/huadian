# V1 Root Cause Diagnosis Report — Sprint F Stage 0

> **角色**: 管线工程师
> **日期**: 2026-04-25
> **状态**: 等待架构师 ACK

---

## 0. 摘要

V1 violations 的根因 **100% 落在 `load.py _insert_person_names`**，不在 NER 层，不在 merge 层。两个 bug 导致 124 个 active person 违规（94 为 name_type 维度，33 为 is_primary 维度，1 人双重违规）。修复范围约 15 行代码变更，不需要改 NER prompt 或 merge 逻辑。

---

## 1. 94 行 name_type 维度违规明细

### 1.1 分类汇总

| 违规类型 | 行数 | 描述 |
|----------|------|------|
| MULTI_NAMETYPE | 92 | 一个 active person 有 >1 个 name_type='primary' 的 person_names 行 |
| ZERO_NAMETYPE | 2 | 一个 active person 无 name_type='primary' 行 |
| **合计** | **94** | |

### 1.2 时间分布

| 日期 | MULTI_NAMETYPE | ZERO_NAMETYPE | 合计 | 来源 |
|------|---------------|---------------|------|------|
| 2026-04-18 | 2 | 2 | 4 | Phase A/B（五帝/夏/殷 ingest） |
| 2026-04-19 | 31 | 0 | 31 | α 周本纪 ingest |
| 2026-04-24 | 59 | 0 | 59 | γ 秦本纪 ingest |
| **合计** | **92** | **2** | **94** | |

**结论**：Brief 预测 "27 历史 + ~64 新增"，实际 "35 pre-秦 + 59 秦本纪"。27→35 的差值来自 T-P1-022 登记后周本纪 ingest 新增的 8 行。

### 1.3 ZERO_NAMETYPE 明细（2 行）

| slug | name_zh | dynasty | 说明 |
|------|---------|---------|------|
| u5c11-u66a4-u6c0f | 少暤氏 | 上古 | 仅 1 条 name，name_type 不详（Phase A 早期 ingest，pre-T-P1-004） |
| u7f19-u4e91-u6c0f | 缙云氏 | 上古 | 仅 1 条 name，name_type 不详（同上） |

---

## 2. 33 行 is_primary 维度违规明细

### 2.1 分类汇总

| 违规类型 | 行数 | 描述 |
|----------|------|------|
| TYPE_A | 31 | 有 name_type='primary' 的 name，但所有 name 的 is_primary=false |
| TYPE_B | 2 | 既无 name_type='primary' 也无 is_primary=true（= ZERO_NAMETYPE 子集） |
| **合计** | **33** | |

### 2.2 时间分布

| 日期 | TYPE_A | TYPE_B | 合计 |
|------|--------|--------|------|
| 2026-04-18 | 3 | 2 | 5 |
| 2026-04-19 | 21 | 0 | 21 |
| 2026-04-24 | 7 | 0 | 7 |
| **合计** | **31** | **2** | **33** |

---

## 3. 根因分析

### 3.1 根因落点：**100% load.py `_insert_person_names`**

不在 NER 层（NER 正确输出 surface_forms 和 name_type）。
不在 merge 层（`apply_merges` 不触碰 name_type / is_primary 写入）。

**两个独立 bug**，均在同一函数 `_insert_person_names`（load.py:334-462）：

### 3.2 Bug 1 — name_zh 默认 name_type='primary' 导致重复（→ 92 MULTI_NAMETYPE）

**位置**: load.py:404

```python
primary_name_type = "primary"  # ← 默认值
for sf in validated_forms:
    if sf.text == person.name_zh:
        primary_name_type = sf.name_type
        break
```

**机制**：当 `name_zh`（如 "秦庄公"）不在 `validated_forms`（NER 只返回 "庄公"）时，`primary_name_type` 保持默认 `"primary"`。然后：
1. name_zh "秦庄公" 被插入为 `name_type='primary'`（line 424）
2. surface_form "庄公" 也被插入为 `name_type='primary'`（line 454，使用 sf.name_type）
3. 结果：2 个 name_type='primary' → MULTI_NAMETYPE

**触发条件**：name_zh ≠ 任何 surface_form.text。在古籍语境中极其常见——NER 抽出短称（"庄公"）但 name_zh 用全称（"秦庄公"），或 NER 用姓（"发"）但 name_zh 用谥号（"武王"）。

**验证**：92 个 MULTI_NAMETYPE 中，90 个的 name_zh 行有 `is_primary=true`（= 代码第一段插入，带默认 "primary"），另一个 primary 行来自 surface_forms 循环。

### 3.3 Bug 2 — surface_forms 循环硬编码 `is_primary=false`（→ 31 TYPE_A + 2 TYPE_B）

**位置**: load.py:452

```python
await conn.execute(
    """
    INSERT INTO person_names (id, person_id, name, name_type, is_primary, source_evidence_id)
    VALUES ($1, $2, $3, $4::name_type, false, $5::uuid)
    """,                             # ↑ 硬编码 false
    ...
)
```

**机制**：当 `_enforce_single_primary` 将一个非 name_zh 的 surface_form 标为 primary（如 "发" 是 primary，name_zh="武王" 是 posthumous），该 surface_form 在循环中被写入时 `is_primary=false`。而 name_zh 也因其 name_type 不是 'primary' 而得到 `is_primary=false`。没有任何行获得 `is_primary=true`。

**实例**（武王 wu-wang）：

| name | name_type | is_primary | 说明 |
|------|-----------|------------|------|
| 武王 | posthumous | false | name_zh，name_type 正确但 is_primary 跟随 |
| 太子发 | alias | false | surface_form |
| 发 | primary | **false** | ← _enforce_single_primary 指定的 primary，但循环硬编码 false |

**结果**：0 行 is_primary=true → TYPE_A 违规

---

## 4. 修复成本估计

| 分类 | 行数 | 根因 | 修复位置 | 修复成本 |
|------|------|------|---------|---------|
| MULTI_NAMETYPE | 92 | Bug 1: name_zh 默认 'primary' | load.py:404 | ~5 行改动 |
| TYPE_A (is_primary desync) | 31 | Bug 2: 循环硬编码 false | load.py:452 | ~5 行改动 |
| TYPE_B (无 primary) | 2 | Pre-T-P1-004 遗留 | 同 Bug 2 修复 + backfill | 0（backfill 覆盖） |
| **合计** | **124 unique** | **load.py 独占** | **_insert_person_names** | **~10 行改动** |

### 修复方案

两个 bug 在同一函数内，一次修复：

1. **找到 designated primary**：从 `validated_forms` 中找到 `name_type='primary'` 的那个 form
2. **Fix Bug 1**（line 404）：如果 name_zh 不在 validated_forms 中，`primary_name_type = "alias"`（不再默认 "primary"）
3. **Fix Bug 2**（line 452）：surface_forms 循环中，对 designated primary form 设置 `is_primary=true`（而非硬编码 false）
4. **新增 3+ 单元测试**：
   - name_zh ≠ surface_form → name_zh 写为 alias，surface_form primary 写为 is_primary=true
   - name_zh = designated primary → name_zh is_primary=true，其余 false
   - name_zh 在 forms 中但非 primary → name_zh is_primary=false，designated primary is_primary=true

### 不需要改的

- ❌ **NER prompt**：NER 输出正确（surface_forms 和 name_type 标注无误），问题在写入层
- ❌ **merge 逻辑**：`apply_merges` 不影响 name_type / is_primary 写入
- ❌ **_enforce_single_primary**：函数逻辑正确，问题在调用者使用其输出的方式

---

## 5. 推荐修复路径

**路径 A（推荐）：load.py 独立修复**

- 修改 `_insert_person_names` 约 10 行
- 独立于 T-P2-004（NER v1-r5），不需要合并
- 修复后新 ingest 不再产生 V1 violations
- Stage 2 回填清 124 行存量

**路径 B（不推荐）：NER + load.py 合并**

- 改 NER prompt 让 name_zh 总是在 surface_forms 中 → 只能修 Bug 1，不能修 Bug 2
- 且改 NER prompt 需要 T-P2-004 黄金集回归，工时大
- Bug 2 仍需独立修

**结论**：路径 A 成本最低、风险最小。两个 bug 根因明确、修复代码 ≤15 行、测试可完整覆盖。

---

## 6. Stage 2 回填范围修订

Brief 预估 94 行回填。实际需覆盖 124 行（94 name_type + 33 is_primary - 1 重叠 - 2 TYPE_B 需特殊处理）。

回填分两步：
1. **MULTI_NAMETYPE 修复**（92 行）：对每个 person，保留 name_zh 的 name_type='primary'，将其余降为 'alias'。如果 name_zh 本身不应是 primary（如 2 个例外），保留 is_primary=true 的那个作 primary，name_zh 降为 alias。
2. **TYPE_A 修复**（31 行）：对每个 person，将 name_type='primary' 的 name 同步 `is_primary=true`。
3. **TYPE_B 修复**（2 行 少暤氏 / 缙云氏）：promote 唯一的 name 为 primary + is_primary=true。

单事务执行 + pg_dump anchor。

---

## 7. Stop Rule 评估

- ✅ **诊断结论清晰**：根因 100% 落在 load.py，不存在"散落三处"的模糊情况 → 不触发 Stop Rule #1
- ✅ **LLM 成本**: $0（纯 SQL + 代码分析，无 LLM 调用）

---

> **管线工程师请求**：架构师 ACK 后进入 Stage 1 修复。推荐路径 A（load.py 独立修复）。
