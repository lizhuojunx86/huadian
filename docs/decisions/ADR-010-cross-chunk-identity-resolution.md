# ADR-010: Cross-Chunk Identity Resolution (跨 Chunk 身份消歧)

- **状态**：accepted
- **日期**：2026-04-18
- **提议人**：首席架构师 (chief-architect)
- **决策人**：用户 + 首席架构师
- **影响范围**：pipeline (resolve 模块) / DB schema (persons, person_names, identity_hypotheses) / Web API (person slug redirect)
- **Supersedes**：无
- **Superseded by**：无

---

## 背景

T-P0-010 真书 Pilot（史记本纪前 3 篇，99 段，169 persons）暴露了严重的跨 chunk 身份消歧缺陷：

**根因**：LLM 逐 chunk 独立抽取，每个段落的 NER 调用看不到其他段落的抽取结果。`merge_persons()` 仅按 `name_zh` 字面完全匹配合并，遇到同一人物在不同段落中使用不同称谓时无法识别。

**实际影响**（从 DB 全量 169 persons 扫描）：

### 确认的同人重复：11 组 24→11 人

| # | 实际人物 | 重复条目 (slug) | 根因类别 |
|---|---------|----------------|---------|
| 1 | **汤**（商开国君主） | `tang` (汤) / `cheng-tang` (成汤) / `u5546-u6c64` (商汤) | 同人异名 3→1 |
| 2 | **武乙**（商王） | `u6b66-u4e59` (武乙) / `u5e1d-u6b66-u4e59` (帝武乙) | 帝X vs X |
| 3 | **中丁**（商王） | `u4e2d-u4e01` (中丁) / `u5e1d-u4e2d-u4e01` (帝中丁) | 帝X vs X |
| 4 | **祖甲/帝甲**（商王） | `u7956-u7532` (祖甲) / `u5e1d-u7532` (帝甲) | 庙号 vs 帝号 |
| 5 | **太甲**（商王） | `tai-jia` (太甲) / `u592a-u5b97` (太宗) | 本名 vs 庙号 |
| 6 | **太戊**（商王） | `u592a-u620a` (太戊) / `u4e2d-u5b97` (中宗) | 本名 vs 庙号 |
| 7 | **微子启** | `wei-zi-qi` (微子启) / `u5fae-u5b50` (微子) | 全称 vs 省称 |
| 8 | **西伯昌/周文王** | `xi-bo-chang` (西伯昌) / `u5468-u6587-u738b` (周文王) | 跨段异名 |
| 9 | **弃/后稷** | `hou-ji` (后稷) / `u5f03` (弃) | 本名 vs 称号 |
| 10 | **倕/垂** | `chui` (倕) / `u5782` (垂) | 通假字 |
| 11 | **益/伯益** | `yi` (益) / `u4f2f-u76ca` (伯益) | 本名 vs 尊称 |

### 根因分类

| 根因类别 | 出现次数 | 可规则化 |
|---------|---------|---------|
| 帝X vs X（尊称前缀） | 3 | ✅ 完全规则化 |
| 庙号 vs 本名 | 3 | ⚠️ 需字典 |
| 通假字/异体字 | 1 | ⚠️ 需 variant_chars 字典 |
| 同人异名（本名/称号/省称） | 4 | ⚠️ 部分规则化 + surface_form 交叉匹配 |

---

## 选项

### 选项 A：纯规则引擎（Python 后处理）

在 `merge_persons()` 之后增加一层 `resolve_identities()` 后处理，按以下规则链逐步合并：

1. **R1 — surface_form 交叉匹配**：如果 person A 的某个 surface_form 与 person B 的 name_zh（或反之）完全匹配，则候选合并
2. **R2 — 帝X/X 前缀规则**：如果 `"帝" + personA.name_zh == personB.name_zh`（或反之），且同 dynasty，则合并
3. **R3 — variant_chars 字典**：维护通假字/异体字映射表，如果两个 person 的 name 存在通假关系，候选合并
4. **R4 — identity_notes 交叉引用**：解析 LLM 的 identity_notes 中"X与Y同人""X即Y"等模式
5. **R5 — 庙号字典**：维护一份 {庙号→本名} 映射表（如 太宗→太甲）

**评分模型**：first-match-wins 决策树（每条规则有固定 confidence，第一条命中即终止，不加权求和）。详见"评分函数"一节。

**优点**：
- 零额外成本（不调 LLM）
- 确定性、可复现、可审计
- 规则可逐步添加，不怕回归
- 性能好：O(n²) 对 169 人 < 1ms，对 10k 人 < 1s

**缺点**：
- 无法处理"需要理解语义才能判断"的消歧（如"武王"在不同朝代指不同人）
- 规则维护成本随朝代/书籍增加而增加
- 规则覆盖面有限，只能解决已知模式

### 选项 B：二次 LLM 调用（将全书抽取结果喂给 LLM 做合并）

抽取完成后，将一本书的全部 persons 列表（name + surface_forms + identity_notes + chunk context）发给 LLM，要求输出合并决策。

**优点**：
- 能处理任意复杂的消歧场景
- 不需要维护规则和字典
- 对新书/新朝代天然适配

**缺点**：
- 额外 LLM 调用成本：每本书约 $0.05-0.15（169 人的 prompt 约 4000 tokens）
- 非确定性：相同输入可能产生不同合并决策
- 不可审计：LLM 的"推理过程"无法精确还原
- 可能产生 false positive（不该合并的被合并）且难以追踪根因
- 全量回放需要重新调 LLM，成本翻倍
- 10k/100k 人时 prompt 会超长，需要分组策略

### 选项 C：混合方案（规则优先，LLM 仲裁歧义）

先跑规则引擎（选项 A），将 confidence < 阈值的候选交给 LLM 仲裁。

**优点**：
- 结合两者优势：确定性规则处理大部分，LLM 兜底模糊场景
- 成本可控：只对少量歧义候选调 LLM

**缺点**：
- 架构复杂度显著增加
- LLM 仲裁部分仍有选项 B 的非确定性问题
- Phase 0 数据量（169 人）无需 LLM 仲裁，规则足够

---

## 决策

**我们选择选项 A（纯规则引擎）**，理由如下：

### 核心理由

1. **当前规模（169 人）的重复全部可规则化**：分析 11 组重复的根因，100% 可以被 R1-R5 规则覆盖——没有一组需要"语义理解"才能判断：
   - 汤/成汤/商汤 → R1（surface_form 交叉匹配 "成汤" 同时出现在 tang 和 cheng-tang）
   - 帝武乙/武乙、帝中丁/中丁 → R2（帝X 前缀）
   - 太甲/太宗、太戊/中宗 → R5（庙号字典）
   - 倕/垂 → R3（通假字字典）
   - 弃/后稷、益/伯益、微子/微子启 → R1（surface_form 交叉）
   - 西伯昌/周文王 → R1（"西伯" 同时出现在两者 surface_forms）

2. **确定性 > 准确性**：古籍知识平台的核心价值是数据可信。可审计的规则决策比 LLM 黑箱更符合项目宪法"溯源可审计"原则。

3. **成本最优**：零额外 LLM 调用成本。

4. **可扩展路径清晰**：如果未来（10k+ 人）出现规则无法覆盖的场景，可以在 R5 之后追加 R6-LLM-Arbitration，实质上升级到选项 C。当前不需要过度设计。

### 决策边界

- 规则引擎只处理**同书内**消歧（跨书消歧留待 Phase 1+）
- 评分模型：first-match-wins 决策树（不加权求和），阈值分两层：
  - `auto_merge`（confidence ≥ 0.90）：直接 soft merge + 写 merge_log（R1/R2/R3/R5）
  - `hypothesis`（0.50 ≤ confidence < 0.90）：不合并，写 identity_hypotheses（R4）
  - 低于 0.50 的匹配丢弃

---

## Schema 变更

### 新增：`person_merge_log` 表

用于记录每次合并操作，支持可逆性和审计。

```sql
CREATE TABLE person_merge_log (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  run_id        UUID NOT NULL,                              -- 一次 resolve 运行的批次 ID（用于批量回滚）
  canonical_id  UUID NOT NULL REFERENCES persons(id),       -- 合并后保留的 person
  merged_id     UUID NOT NULL REFERENCES persons(id),       -- 被合并的 person（soft-deleted）
  merge_rule    TEXT NOT NULL,                               -- 触发的规则 (R1/R2/R3/R5)
  confidence    REAL NOT NULL,                               -- first-match confidence
  evidence      JSONB,                                       -- 匹配证据 {"overlap": ["成汤"], "rule": "R1"}
  merged_by     TEXT NOT NULL DEFAULT 'pipeline',            -- 操作者 (pipeline/human)
  merged_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  reverted_at   TIMESTAMPTZ,                                 -- 如果回滚，记录时间
  reverted_by   TEXT                                          -- 回滚操作者
);

CREATE INDEX idx_merge_log_canonical ON person_merge_log(canonical_id);
CREATE INDEX idx_merge_log_merged ON person_merge_log(merged_id);
CREATE INDEX idx_merge_log_run ON person_merge_log(run_id);
```

### 修改：`persons` 表

新增 `merged_into_id` 列，指向合并后的 canonical person：

```sql
ALTER TABLE persons ADD COLUMN merged_into_id UUID REFERENCES persons(id);
CREATE INDEX idx_persons_merged_into ON persons(merged_into_id) WHERE merged_into_id IS NOT NULL;
```

### 合并策略：纯 Soft Merge（数据不动，查询层解析）

**关键决策**：合并时 **不迁移** `person_names.person_id`。被合并 person 的所有子记录原地保留。

**被合并 person 的处理**：
- `deleted_at = NOW()`（soft-delete）
- `merged_into_id = canonical.id`（指向 canonical person）

**查询层负责 canonical 解析**：
- `findPersonBySlug(slug)` 如果命中的 person 有 `merged_into_id`，递归跟踪到 canonical person
- `searchPersons(name)` 匹配到被合并 person 的 person_name 时，返回 canonical person
- 实现方式：在 service layer 加一个 `resolveCanonical(person)` 辅助函数

**为什么选 soft merge 而非硬迁移**：
- 可逆性最强：回滚只需清除 `deleted_at` + `merged_into_id`，零数据迁移
- 审计完整：被合并 person 的原始数据结构完整保留，可随时回溯
- 简单：不需要处理 person_names / identity_hypotheses 等外键批量 UPDATE 的事务风险

**代价**：查询层需要多一次 `merged_into_id` 跟踪。169 人规模可忽略，10k+ 时通过索引 `idx_persons_merged_into` 保证性能。

### 不修改

- `person_names` 表结构和数据不变
- `identity_hypotheses` 表结构和数据不变
- `disambiguation_seeds` 表结构不变

---

## Canonical Person 选择策略

当两个 person 合并时，选择哪个作为 canonical（保留）person：

1. **优先有 pinyin slug 的**（如 `tang` 优先于 `u5546-u6c64`）
2. **优先 surface_forms 更多的**
3. **优先 name_zh 更常用的**（如"后稷"优先于"弃"，因为更广为人知）
4. **平手时取 created_at 更早的**

---

## Web API 影响

### Slug 重定向

合并后，被合并 person 的 slug 仍需可访问：

- `/persons/cheng-tang` → 301 redirect → `/persons/tang`
- `/persons/u5782` → 301 redirect → `/persons/chui`

实现方式：在 `findPersonBySlug` 中，如果查到的 person 有 `merged_into_id`，则返回 canonical person 并附带 redirect hint。

### GraphQL

`person(slug: "cheng-tang")` 返回 canonical person（即汤），response 中可选附带 `mergedFrom` 信息。

### 搜索

合并后，搜索"成汤"应能命中"汤"。由于 soft merge 不迁移 person_names，搜索 service 需在匹配 person_name 后检查其 person 是否有 `merged_into_id`，若有则返回 canonical person。

---

## 规则引擎详细设计

### 评分函数（决策树）

每对 (person_A, person_B) 依次过规则链。**第一条命中的规则决定 confidence**，不做加权求和。规则之间不冲突——命中即终止（first-match-wins）：

```python
def score_pair(a: Person, b: Person) -> MatchResult | None:
    """Return the first matching rule's result, or None if no match."""

    # R1: surface_form 交叉匹配（最强信号）
    a_sf = {sf.text for sf in a.surface_forms}
    b_sf = {sf.text for sf in b.surface_forms}
    overlap = (a_sf & {b.name_zh}) | (b_sf & {a.name_zh}) | (a_sf & b_sf)
    if overlap:
        return MatchResult(rule="R1", confidence=0.95, evidence=overlap)

    # R2: 帝X / X 前缀（需要同书 + 同朝代 + 长度校验）
    if _is_di_prefix_match(a, b):
        return MatchResult(rule="R2", confidence=0.93, evidence={"prefix": "帝"})

    # R3: 通假字 / 异体字字典
    norm_a = _normalize_variant(a.name_zh)
    norm_b = _normalize_variant(b.name_zh)
    if norm_a == norm_b and norm_a is not None:
        return MatchResult(rule="R3", confidence=0.90,
                           evidence={"normalized": norm_a})

    # R5: 庙号 / 谥号字典（注意：R5 在 R4 之前，因为确定性更高）
    if _is_temple_name_match(a, b):
        return MatchResult(rule="R5", confidence=0.90,
                           evidence={"dict": "temple_names"})

    # R4: identity_notes 交叉引用（最弱信号，仅生成 hypothesis）
    note_match = _extract_identity_note_link(a, b)
    if note_match:
        return MatchResult(rule="R4", confidence=0.65,
                           evidence={"note": note_match})

    return None  # No match


def _is_di_prefix_match(a: Person, b: Person) -> bool:
    """帝X / X prefix match with false-positive guards."""
    short, long = sorted([a, b], key=lambda p: len(p.name_zh))
    # Guard 1: 长名必须是"帝" + 短名，且短名长度 ≥ 1
    if long.name_zh != "帝" + short.name_zh:
        return False
    # Guard 2: 必须同书（book_id 相同）或同朝代
    if a.dynasty != b.dynasty:
        return False
    # Guard 3: 短名不能是单字常见名（"辛""甲"等），除非有 surface_form 交叉
    if len(short.name_zh) == 1:
        a_sf = {sf.text for sf in a.surface_forms}
        b_sf = {sf.text for sf in b.surface_forms}
        if not (a_sf & b_sf):
            return False
    return True
```

### 阈值分层（基于 first-match confidence）

| confidence 区间 | 动作 | 触发规则 |
|----------------|------|---------|
| ≥ 0.90 | `auto_merge` — 直接合并，写 merge_log | R1, R2, R3, R5 |
| 0.50 – 0.89 | `hypothesis` — 不合并，写 identity_hypotheses | R4 |
| < 0.50 | 丢弃 | — |

### 传递性处理

如果 R1 说 A=B，R2 说 B=C，则 A=B=C 传递合并。实现方式：用 Union-Find 数据结构收集所有 pair，合并后每个连通分量选一个 canonical。

### 规则链（摘要）

| 规则 | 信号 | confidence | 假阳性防护 |
|------|------|-----------|-----------|
| R1 | surface_form 集合交叉 | 0.95 | 集合非空即匹配 |
| R2 | "帝" + X == Y | 0.93 | 同书/同朝代 + 单字需 sf 交叉 |
| R3 | variant_chars 归一化 | 0.90 | 字典条目需标出处 |
| R5 | 庙号字典 | 0.90 | 同朝代 |
| R4 | identity_notes 正则 | 0.65 | 仅生成 hypothesis |

### 字典文件

两个字典均为 YAML 格式，存放于 `data/dictionaries/`，每条记录带 `source` 出处字段，便于 historian review。

**`data/dictionaries/tongjia.yaml`** — 通假字 / 异体字映射

```yaml
# Variant character mappings for identity resolution (R3)
# source: historian attestation required
entries:
  - canonical: "倕"
    variants: ["垂"]
    source: "《史记·五帝本纪》'垂主工师'，通假字"
    note: "倕=垂，同一人"

  - canonical: "驩"
    variants: ["欢"]
    source: "《史记·五帝本纪》繁简异体"
    note: "驩兜=欢兜"
  # ... historian 继续补充
```

**`data/dictionaries/miaohao.yaml`** — 庙号 / 谥号映射

```yaml
# Temple name / posthumous name mappings for identity resolution (R5)
# source: historian attestation required
entries:
  - canonical: "太甲"
    aliases: ["太宗"]
    dynasty: "商"
    source: "《史记·殷本纪》'帝太甲崩...是为太宗'"

  - canonical: "太戊"
    aliases: ["中宗"]
    dynasty: "商"
    source: "《史记·殷本纪》'帝太戊...殷复兴...是为中宗'"

  - canonical: "祖甲"
    aliases: ["帝甲"]
    dynasty: "商"
    source: "《史记·殷本纪》祖甲又称帝甲"
  # ... historian 继续补充
```

**来源说明**：
- `tongjia.yaml`：初始条目从 T-P0-010 pilot 中发现的通假关系手工整理。未来可从古汉语通假字典库（如《通假字汇释》）批量导入，但每条仍需 historian review 后打 `reviewed: true` 标记。
- `miaohao.yaml`：初始条目从殷本纪世系中手工整理。覆盖面有限（仅商代），后续朝代需逐步补充。

**强制约定**：字典数据禁止硬编码在 .py 文件中，必须从 YAML 加载。

### 模块位置

```
services/pipeline/src/huadian_pipeline/
  resolve.py          # IdentityResolver 主模块（对外接口 + orchestration）
  resolve_rules.py    # R1-R5 规则实现 + score_pair()
  resolve_types.py    # MergeProposal / MergeResult / MatchResult 类型
```

---

## R4 产出与 identity_hypotheses 表的关系

### 语义区分

现有 `identity_hypotheses` 表（T-P0-002 建表）的设计语义是：**"单个 person 的身份不确定性"**（如"少典可能是部族名而非人名"）。其 `relation_type` 枚举包含 `same_person / possibly_same / conflated / distinct_despite_similar_name`。

R4 产出的是 **"A 和 B 可能是同一人"** — 恰好对应 `relation_type = 'possibly_same'`。

### 决策：复用现有表，不新建

`identity_hypotheses` 的现有字段已足够表达 R4 产出：

| 字段 | R4 用法 |
|------|--------|
| `canonical_person_id` | person A（规则认为应保留的一方） |
| `hypothesis_person_id` | person B（规则认为可能是同一人的另一方） |
| `relation_type` | `'possibly_same'` |
| `scholarly_support` | `NULL`（无学术依据，纯规则匹配） |
| `evidence_ids` | `[]` |
| `accepted_by_default` | `false`（需人工确认） |
| `notes` | 规则来源和匹配证据，如 `"R4: identity_notes '弃即后稷'"` |

不新增字段，不新建表。如果未来 ADR-015（Identity Hypotheses 表达机制）需要扩展，在那个 ADR 中处理。

---

## 可逆性 / 审计设计

### 合并操作（单次 merge 的 SQL 序列）

```sql
-- Step 1: 写 merge_log
INSERT INTO person_merge_log
  (id, run_id, canonical_id, merged_id, merge_rule, confidence, evidence, merged_by)
VALUES
  ($log_id, $run_id, $canonical_id, $merged_id, $rule, $conf, $evidence::jsonb, 'pipeline');

-- Step 2: soft-delete 被合并 person + 设置 merged_into_id
UPDATE persons
SET deleted_at = NOW(), merged_into_id = $canonical_id, updated_at = NOW()
WHERE id = $merged_id;

-- 注意：person_names / identity_hypotheses 数据不动（soft merge）
```

### 撤销单次合并

```sql
-- Step 1: 恢复被合并 person
UPDATE persons
SET deleted_at = NULL, merged_into_id = NULL, updated_at = NOW()
WHERE id = $merged_id;

-- Step 2: 标记 merge_log 已撤销
UPDATE person_merge_log
SET reverted_at = NOW(), reverted_by = $actor
WHERE id = $log_id;
```

### 批量回滚一次 run 的全部合并

`person_merge_log.run_id` 字段标识一次 resolve 运行。回滚一次 run：

```sql
-- 恢复该 run 中所有被合并的 person
UPDATE persons
SET deleted_at = NULL, merged_into_id = NULL, updated_at = NOW()
WHERE id IN (
  SELECT merged_id FROM person_merge_log
  WHERE run_id = $run_id AND reverted_at IS NULL
);

-- 标记所有 merge_log 为已撤销
UPDATE person_merge_log
SET reverted_at = NOW(), reverted_by = $actor
WHERE run_id = $run_id AND reverted_at IS NULL;
```

### R4 hypothesis 的回滚

合并回滚时，如果该 run 还写入了 `identity_hypotheses` 记录：

```sql
-- 删除该 run 产生的 hypothesis 记录（通过 notes 中的 run_id 标记）
DELETE FROM identity_hypotheses
WHERE notes LIKE 'run:' || $run_id || '%';
```

### 审计查询

```sql
-- 查看所有合并记录
SELECT ml.*,
  c.name->>'zh-Hans' as canonical_name,
  m.name->>'zh-Hans' as merged_name
FROM person_merge_log ml
JOIN persons c ON c.id = ml.canonical_id
JOIN persons m ON m.id = ml.merged_id
ORDER BY ml.merged_at DESC;

-- 查看某个 person 的合并历史
SELECT * FROM person_merge_log
WHERE canonical_id = $1 OR merged_id = $1;

-- 查看某次 run 的全部操作
SELECT * FROM person_merge_log
WHERE run_id = $1 ORDER BY merged_at;
```

---

## 性能与扩展性

### 当前实现（Phase 0）

169 persons → C(169,2) = 14,196 对全遍历。每对 5 条规则，纯 Python dict 操作。预估 < 50ms，无需优化。

### 扩展路线图（不在本次实现范围内，但须提及以避免后续重写）

| 数据规模 | persons | 朴素 O(n²) | 优化策略 |
|---------|---------|-----------|---------|
| 当前 (3 篇) | 169 | 14k pairs, < 50ms | 全遍历 |
| 史记全量 | ~5,000 | 12.5M pairs, < 2s | **Blocking key**：按 (dynasty, name_zh 首字) 分桶，桶内全遍历。将 12.5M 降至 ~100k。 |
| 二十四史 | ~100,000 | 5B pairs | **Blocking key** + **倒排索引**：建 surface_form → person_id 的 hash map，R1 从 O(n²) 降至 O(n)。R2/R3/R5 仍需桶内遍历。 |
| 全量古籍 | ~1,000,000 | 不可行 | **Embedding 预召回**：用 name embedding 做 ANN 检索 top-k 候选，再对候选对跑规则链。需 pgvector 已就绪（ADR-005）。 |

**当前代码只实现全遍历**。Blocking key 和倒排索引在 person 数突破 5k 时再加。Embedding 预召回是 Phase 2+ 议题。

---

## 回滚方案

1. **数据回滚（批量）**：按 run_id 执行批量回滚 SQL（见"可逆性 / 审计设计"一节）。由于 soft merge 不动 person_names，回滚仅需 UPDATE persons 表。
2. **Schema 回滚**：`ALTER TABLE persons DROP COLUMN merged_into_id; DROP TABLE person_merge_log;`
3. **代码回滚**：移除 resolve.py 及相关模块，`load.py` 回到 name_zh 字面匹配

---

## Related Fixes（不在本 ADR 决策范围内）

以下问题在 T-P0-010 中同时发现，但性质不同于"跨 chunk 同人合并"，应作为 **follow-up PR** 单独处理：

1. **虚假实体清理**（5 个冗余 person：姒氏 / 昆吾氏 / 羲氏 / 和氏 / 荤粥）
   - 性质：LLM 抽取误判（部族名 / 合称省称 / 姓氏描述被误建为 person）
   - 处理：soft-delete + deletion_reason 标记，不走 merge_log
   - 时机：合并 apply 后作为独立 data-fix commit

2. **错误关联修正**（尧 `yao` 的 surface_forms 包含"帝舜"）
   - 性质：LLM 将段落中出现的"帝舜"错误归入尧的 person_names
   - 处理：DELETE / UPDATE person_names 记录，不涉及 person 合并
   - 时机：同上

---

## Implementation Notes（Phase 4 实施后追加）

### API resolveCanonical 实现方式

选择**透明返回 canonical**（非 HTTP redirect）：
- `person(slug:"u5782")` 直接返回 canonical 倕 的完整数据（slug:"chui"），不返回 301/302
- 前端可通过比较请求 slug 与返回 slug 是否一致来决定是否做客户端 redirect
- 理由：GraphQL 无 redirect 语义，且透明返回对搜索引擎更友好（单一 canonical URL 积累权重）

### Pipeline raw SQL 与 API Drizzle 的 schema 同步约定

凡涉及 API 侧表结构变更的 pipeline migration，**必须同步更新 API Drizzle schema 文件**：
1. 在 `packages/db-schema/src/schema/*.ts` 中声明新列/表
2. 跑 `pnpm db:generate`，验证输出 "No schema changes"
3. 如果 Drizzle 生成了 migration，对比 SQL 一致性后删除 Drizzle 生成的（避免双重 apply）
4. Pipeline-only 的表（如 `person_merge_log`）不进 Drizzle schema，但须在 pipeline migration 注释中说明

违反此约定会导致下次 `db:generate` 反向生成删除 migration（定时炸弹）。

### Known Follow-ups

1. **Canonical 选择对"帝X"前缀有系统性偏差**：surface_forms 数量 tiebreaker 导致"帝中丁"优先于"中丁"。建议增加"去尊称前缀优先"规则（`select_canonical` 中，如果候选 A.name == "帝" + 候选 B.name，优先选 B）。小任务，<1 天。
2. **益/伯益 canonical 选择的学术争议**：选了"益"（本名），传统索引惯用"伯益"。学术上均可，记录在案，historian 在 Phase 1 扩量时可选择覆盖。

---

## 相关链接

- 任务卡：T-P0-011
- 合并报告：`docs/reports/T-P0-011-apply-report.md`
- 质量报告：`docs/reports/T-P0-010-findings.md` / `T-P0-010-phase-a-quality.md` / `T-P0-010-phase-b-quality.md`
- 相关 ADR：ADR-009（Person sourceEvidenceId traceability）
- 已规划 ADR：ADR-015（Identity Hypotheses 表达机制）— 本 ADR 的合并结果会产生 identity_hypothesis 记录，两者互补

---

## Supplement 2026-04-19（来源：T-P0-020 Stage 0 发现）

### persons 表 soft-delete 的两种合法语义

T-P0-020 实施 F3 CHECK 约束过程中，Stage 0 扫描发现 persons 表存在两种合法的 soft-delete 形态：

| 语义 | deleted_at | merged_into_id | 来源 |
|------|-----------|----------------|------|
| active | NULL | NULL | 正常活跃 |
| merge soft-delete | NOT NULL | NOT NULL | `apply_merges()` 正常路径 |
| pure soft-delete | NOT NULL | NULL | T-P0-014 R3-non-person 规则 |

三态并存，不违反 merge 铁律。违规态仅有一种：
- `deleted_at IS NULL AND merged_into_id IS NOT NULL`（merged 但未 deleted）

### CHECK 约束选型：单向蕴涵

T-P0-020 原拟议双向等价 `(merged_into_id IS NULL) = (deleted_at IS NULL)` 会误伤 pure soft-delete 的 5 行。架构师裁决改为单向蕴涵：

```sql
ALTER TABLE persons ADD CONSTRAINT persons_merge_requires_delete
  CHECK (merged_into_id IS NULL OR deleted_at IS NOT NULL);
```

即 `merged_into_id IS NOT NULL → deleted_at IS NOT NULL`，逆否命题 `deleted_at IS NULL → merged_into_id IS NULL`，保证 `active = deleted_at IS NULL` 与 `active = deleted_at IS NULL AND merged_into_id IS NULL` 严格等价（F4 修复）。

### 影响

- 所有查询中的 "active person" 定义统一为 `deleted_at IS NULL`
- 未来若需要更细粒度的 deletion 语义（例如区分 non-person / duplicate / obsolete），应独立开 ADR 引入 `deletion_reason` 枚举列，当前的单向 CHECK 与此演进路径兼容
- 本 supplement 不改变 ADR-010 §5 apply_merges 的合约
