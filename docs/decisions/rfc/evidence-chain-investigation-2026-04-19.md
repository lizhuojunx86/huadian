# Evidence 链技术现状调研 — ADR-015 起草前置

- **调研日期**：2026-04-19
- **调研人**：管线工程师（代理）
- **目的**：为 ADR-015（source_evidence_id 填充方案）提供事实基础
- **本文状态**：working doc（非 RFC，非 ADR）

---

## A. Schema 盘点

### A1: `person_names.source_evidence_id` FK

FK 名称：`person_names_source_evidence_id_source_evidences_id_fk`
指向：`source_evidences(id)`

```
person_names 表结构（`\d person_names`）：
       Column       |           Type           | Nullable |      Default
--------------------+--------------------------+----------+-------------------
 id                 | uuid                     | not null | gen_random_uuid()
 person_id          | uuid                     | not null |
 name               | text                     | not null |
 name_pinyin        | text                     |          |
 name_type          | name_type                | not null |
 start_year         | integer                  |          |
 end_year           | integer                  |          |
 is_primary         | boolean                  |          | false
 source_evidence_id | uuid                     |          |    ← NULLABLE
 created_at         | timestamp with time zone | not null | now()

FK constraints:
  person_names_person_id_persons_id_fk         → persons(id) ON DELETE CASCADE
  person_names_source_evidence_id_source_evidences_id_fk → source_evidences(id)
```

Drizzle 定义：`packages/db-schema/src/schema/persons.ts:73`
```typescript
sourceEvidenceId: uuid("source_evidence_id").references(() => sourceEvidences.id),
// No .notNull() — intentional per ADR-009
```

### A2: 目标表 `source_evidences` 完整结构

`\d+ source_evidences`：

```
     Column      |           Type           | Nullable |             Default
-----------------+--------------------------+----------+---------------------------------
 id              | uuid                     | not null | gen_random_uuid()
 raw_text_id     | uuid                     |          |         ← FK → raw_texts(id)
 position_start  | integer                  |          |         ← span 起始偏移
 position_end    | integer                  |          |         ← span 结束偏移
 quoted_text     | text                     |          |         ← 引文原文
 provenance_tier | provenance_tier          | not null | 'primary_text'
 text_version    | text                     |          |
 book_id         | uuid                     |          |         ← FK → books(id)
 prompt_version  | text                     |          |
 llm_call_id     | uuid                     |          |         ← FK → llm_calls(id)
 created_at      | timestamp with time zone | not null | now()
 updated_at      | timestamp with time zone | not null | now()

Referenced by:
  evidence_links.evidence_id
  feedback.evidence_id
  person_names.source_evidence_id
  place_names.source_evidence_id
  event_causality.source_evidence_id
```

Drizzle 定义：`packages/db-schema/src/schema/sources.ts:76-89`

### A3: Evidence 粒度

Schema **设计上** 支持三级粒度：

| 级别 | 使用字段 | 精度 |
|------|---------|------|
| **Book** | `book_id` only | 最粗 — "出自某书" |
| **Paragraph** | `raw_text_id`（→ `raw_texts.paragraph_no`） | 段落级 |
| **Span** | `raw_text_id` + `position_start` + `position_end` + `quoted_text` | 字符级偏移 |

**依据**：
- `position_start` / `position_end` 是 integer 类型，表示 raw_text.raw_text 中的字符偏移
- `quoted_text` 存储被引用的精确子串
- `raw_text_id` FK → `raw_texts`，后者的 `paragraph_no` + `chapter` 提供段落定位
- 三级粒度中，所有字段均为 **NULLABLE** — schema 允许从粗到细渐进填充

### A4: Evidence 相关表全库行数

```
         表名         | 行数
---------------------+------
 books               |    5
 raw_texts           |  126     ← 5 books × ~25 段
 source_evidences    |    0     ← ⚠️ 全空
 evidence_links      |    0     ← ⚠️ 全空
 person_names        |  282
 persons             |  174
 llm_calls           |   34     ← NER 调用有记录
 pipeline_runs       |    5
 extractions_history |    0     ← ⚠️ 全空
 person_merge_log    |   23
 textual_notes       |    0
 feedback            |    0
```

**关键事实**：`source_evidences` 表 **0 行** — 不是"FK 值没填"，是**FK 目标表本身从未被写入过**。整个 evidence 链从根断开。

### A5: 约束检查

`person_names` 上只有 3 个约束：

| 约束名 | 类型 | 定义 |
|--------|------|------|
| `person_names_pkey` | PRIMARY KEY | `(id)` |
| `person_names_person_id_persons_id_fk` | FK | `→ persons(id) ON DELETE CASCADE` |
| `person_names_source_evidence_id_source_evidences_id_fk` | FK | `→ source_evidences(id)` |

- **无 NOT NULL 约束** on `source_evidence_id`
- **无 CHECK 约束**（无 `persons_soft_merge_paired` 等 — F3 followup 尚未实施）
- **无 partial index** on `source_evidence_id`

---

## B. 代码盘点

### B1: `load.py` INSERT 路径

文件：`services/pipeline/src/huadian_pipeline/load.py`

**两处 INSERT**（`_insert_person_names()` 函数内）：

**路径 1 — 插入 primary name（L367-376）**：
```python
await conn.execute(
    """
    INSERT INTO person_names (id, person_id, name, name_type, is_primary)
    VALUES ($1, $2, $3, $4::name_type, true)
    """,
    str(uuid.uuid4()),
    person_id,
    person.name_zh,
    primary_name_type,
)
```

**路径 2 — 插入 surface forms（L390-399）**：
```python
await conn.execute(
    """
    INSERT INTO person_names (id, person_id, name, name_type, is_primary)
    VALUES ($1, $2, $3, $4::name_type, false)
    """,
    str(uuid.uuid4()),
    person_id,
    sf.text,
    sf.name_type,
)
```

**结论**：`source_evidence_id` 列在 INSERT 中被**完全省略**，依赖 DB 默认 NULL。不是"传了 None"，而是"字段根本不在 INSERT 列表中"。

**关键上下文**：调用方传入的 `MergedPerson` 数据类**已携带** `chunk_ids: list[str]`（raw_texts.id）和 `paragraph_nos: list[int]`，但 `_insert_person_names()` 从未使用这些字段。位置信息存在于内存中，但在写 DB 时被丢弃。

### B2: `extract_persons()` 输出结构

文件：`services/pipeline/src/huadian_pipeline/extract.py:33-53`

```python
@dataclass(frozen=True, slots=True)
class SurfaceForm:
    text: str
    name_type: str
    # ← 无 position / offset 字段

@dataclass(frozen=True, slots=True)
class ExtractedPerson:
    name_zh: str
    surface_forms: list[SurfaceForm]
    dynasty: str
    reality_status: str
    brief: str
    confidence: float
    identity_notes: str | None
    chunk_paragraph_no: int   # ← 段落级位置 ✅
    chunk_id: str             # ← raw_texts.id ✅
    # ← 无 per-surface offset
```

**位置信息评估**：
- ✅ **段落级**：`chunk_paragraph_no` + `chunk_id` — 每个 person 知道来自哪段
- ❌ **Surface 级**：`SurfaceForm` 只有 `text` + `name_type`，无字符偏移
- ❌ **跨段聚合**：`MergedPerson.chunk_ids` 是 list — 一个 person 可能出现在多段，但 person_names 只有一行

### B3: NER Prompt v1-r4 输出 schema

文件：`services/pipeline/src/huadian_pipeline/prompts/ner_v1-r4.md:25-42`

```json
{
  "name_zh": "主要中文名（通行字形）",
  "surface_forms": [
    {"text": "段落原文中的称谓", "name_type": "primary"}
  ],
  "dynasty": "所属朝代或时期",
  "reality_status": "historical|legendary|mythical|fictional|composite|uncertain",
  "brief": "一句话描述此人在本段中的角色/事迹",
  "confidence": 0.0-1.0,
  "identity_notes": null
}
```

**位置信息**：**不要求 LLM 输出任何位置信息**。无 `position_start`、`position_end`、`char_offset`、`paragraph_index` 等字段。

Prompt 仅要求 `surface_forms[].text` 是"输入段落的精确子串"（L79），但不要求报告偏移量。

### B4: 其他写入 `person_names` 的路径

全仓搜索结果：

| 路径 | 操作 | evidence 状态 |
|------|------|-------------|
| `load.py:367,392` | INSERT（主路径） | 省略 source_evidence_id |
| `ops/rollback/T-P0-006-beta-s5-rollback.sql:44-51` | INSERT 重建弃的 3 行 | 省略 source_evidence_id |
| `services/pipeline/scripts/T-P0-015-merge.sql:61-63` | INSERT 帝鸿氏 alias | 省略 source_evidence_id |
| `services/pipeline/migrations/0003_fix_dishun_misattribution.sql` | DELETE 错误行 | N/A |
| `services/pipeline/seeds/pilot-shiji-benji/*.sql` | seed INSERT | 省略 source_evidence_id |
| `services/pipeline/src/huadian_pipeline/seed_dump.py` | 导出 SQL（只读） | 导出时也不含该列 |

**结论**：全仓**所有写入路径**均省略 `source_evidence_id`。无一例外。

---

## C. 数据盘点

### C1: person_names evidence 状态

```
 total_rows | evidence_null | evidence_filled
------------+---------------+-----------------
        282 |           282 |               0
```

**282/282 行 source_evidence_id = NULL**。比 retro 报告的 279 多 3 行（β 后续操作新增）。

### C2: raw_texts 分布

```
        book        | paragraphs | total_chars
--------------------+------------+-------------
 shangshu-shun-dian |         20 |        1081
 shangshu-yao-dian  |          7 |         619
 shiji-wu-di-ben-ji |         29 |        4555
 shiji-xia-ben-ji   |         35 |        4065
 shiji-yin-ben-ji   |         35 |        3558
```

合计：5 books / 126 paragraphs / ~13,878 chars。β 占 27 段。

### C3: β 数据 surface 频次 + 全库跨人重复

**β-specific surfaces**：所有 β 新 surface 均为 cnt=1（每个 surface 在 person_names 中只出现一次）。β 数据量小，无高频 surface。

**全库跨人重复 top 15**：

| surface | 出现次数 | 跨 person 数 | 涉及 slugs |
|---------|---------|-------------|-----------|
| 弃 | 3 | 3 | hou-ji, u5f03 |
| 成汤 | 3 | 3 | cheng-tang, tang, u5546-u6c64 |
| 后稷 | 2 | 2 | hou-ji, u5f03 |
| 启 | 2 | 2 | qi, wei-zi-qi |
| 垂 | 2 | 2 | u5782 |
| 帝 | 2 | 2 | shun, yao |
| 帝鸿氏 | 2 | 2 | huang-di, u5e1d-u9e3f-u6c0f |
| ... | ... | ... | ... |

多数跨人重复为 active↔soft-deleted 的合并残留（模型 A 保留 source person names）。

### C4: β 弃/垂/朱 merge 相关行

**Persons 合并状态**：

| slug | person_id (前8) | merged_into | deleted |
|------|----------------|-------------|---------|
| hou-ji | 709a5ab7 | — | active |
| chui | 2595b9c9 | — | active |
| dan-zhu | 46add4d2 | — | active |
| u5f03 | 3e4f389a | hou-ji | deleted |
| u5f03 | b33d8c16 | hou-ji | deleted |
| u5782 | ca247afa | chui | deleted |
| u5782 | 34b49774 | chui | deleted |
| u6731 | 66fccef4 | dan-zhu | deleted |

**对应 person_names 行（13 行）**：

| person_id (前8) | slug | name | name_type | is_primary | source_evidence_id |
|----------------|------|------|-----------|------------|-------------------|
| 2595b9c9 | chui | 倕 | primary | true | NULL |
| 46add4d2 | dan-zhu | 丹朱 | primary | true | NULL |
| 709a5ab7 | hou-ji | 后稷 | nickname | true | NULL |
| 709a5ab7 | hou-ji | 弃 | primary | false | NULL |
| 709a5ab7 | hou-ji | 稷 | alias | false | NULL |
| ca247afa | u5782 | 垂 | primary | true | NULL |
| 34b49774 | u5782 | 垂 | alias | true | NULL |
| 3e4f389a | u5f03 | 弃 | alias | true | NULL |
| 3e4f389a | u5f03 | 后稷 | alias | false | NULL |
| 3e4f389a | u5f03 | 稷 | alias | false | NULL |
| b33d8c16 | u5f03 | 弃 | primary | true | NULL |
| 66fccef4 | u6731 | 朱 | alias | true | NULL |
| 66fccef4 | u6731 | 胤子朱 | nickname | false | NULL |

**特殊回填限制**：
- **3e4f389a 的 3 行**（弃/alias, 后稷/alias, 稷/alias）是 β S-5 rollback 后用纯文本 INSERT 重建的 — 无 NER cache 可追溯，只能通过 raw_text 文本搜索匹配段落
- **u5f03(b33d8c16) 的 1 行** 和 **u5782 的 2 行** 来自 α NER，虽然 llm_calls.response 有存档，但 `extractions_history` 为 0 行（NER output 未落 extractions_history）
- **所有 13 行** source_evidence_id = NULL

---

## D. ADR 约束

### D1: ADR-009 "nullable 放宽"精确措辞

**来源**：`docs/decisions/ADR-009-person-source-evidence-traceability.md`

> **触发**（§触发）：T-P0-007 Q-5 — `Person implements Traceable` 承诺 `sourceEvidenceId: ID!`（non-null），但 `persons` 表无 `source_evidence_id` 列；字典种子 40 人为合成身份，无单一 source evidence

> **决策**（§决策）：将 `Traceable.sourceEvidenceId` 从 `ID!` 放宽为 `ID`（nullable）。

> **R-1 修订**：Traceable 最小字段集为 3 个字段：sourceEvidenceId（nullable）/ provenanceTier（non-null）/ updatedAt（non-null）。traceability 由 provenanceTier（必填）+ sourceEvidenceId（选填直接链接）+ evidence_links（多对多关联）三者共同保证。

> **不允许的后续行为**：
> - 不得为满足 non-null 而创建语义空壳 SourceEvidence 记录
> - 不得在 resolver 中返回 magic string 代替 null
> - 如果未来 Phase 需要恢复 non-null 约束，必须通过新 ADR + 确认所有实体表已有列 + 所有行已有值

**背景**：ADR-009 的 nullable 放宽原本是 Phase 0 权宜——预期 pipeline 抽取后会渐进填充。但目前 Phase 0 全部管线跑完，282 行 person_names 仍然全 NULL。"渐进式增强"路径从未被走过。

### D2: 项目宪法"一次结构化 N 次衍生"

**来源**：`docs/00_项目宪法.md` §一、数据第一性

> **C-1 一次结构化，N 次衍生。**
> 所有产品功能均为对底层统一知识图谱的查询视图。禁止为单个产品建立独立数据表或绕过知识层。

> **C-2 所有实体必须可溯源。**
> 任何向用户展示的事实、关系、推断都必须能回溯到至少一条 `SourceEvidence`，**或**清晰标注为 AI 推断 / 学界共识 / 众包贡献（provenance tier）。没有溯源的数据不得入库。

**分析**：
- C-1 的"一次结构化"隐含要求：结构化的产物必须足够丰富，使"N 次衍生"有意义。如果 evidence 链为空，衍生产品（搜索高亮、原文定位、知识图谱可视化中的溯源跳转）无法实现。
- C-2 当前勉强合规：282 行 person_names 的 `provenanceTier` 默认为 `'primary_text'`（写在 persons 表上），走"或"条件通过。但这是最低限度合规——实质上用一个枚举值代替了真正的溯源链。
- ADR-014 §3 明确论述了 evidence 链对模型 A 的价值锚地位："模型 A 保留了未来填补 evidence 链的可能；模型 B 会永久丢失'此 name 最初来自哪本书'的信号"。

---

## E. NER 输出持久化现状

### E1: 输出目录

`services/pipeline/outputs/` **目录不存在**。pipeline 子包目录结构中无任何输出持久化路径。

### E2: extract.py 磁盘写入

**extract.py 无任何文件 I/O**。搜索 `.jsonl`、`json.dump`、`writelines`、`write(`、`open(` — 全部零命中。

`extract_persons()` 的数据流：
1. 从 DB 读 raw_texts
2. 调 LLM Gateway
3. 在内存解析 JSON
4. 返回 `ExtractionResult` 对象（纯内存）
5. 调用方 `load.py` 写 DB — **此时 NER 原始输出已丢失**

### E2 补充：llm_calls 表的意外发现

**⚡ 关键发现**：`llm_calls` 表有 34 行，`response` JSONB 列保存了完整的 LLM 响应（含 NER JSON 数组）。

```
 prompt_version | calls | total_input | total_output | total_cost
----------------+-------+-------------+--------------+------------
 ner/v1         |     7 |       30924 |         2623 |   0.132117
 ner/v1-r4      |    27 |        2464 |         6151 |   0.099657
```

样例 response：
```json
{
  "content": "```json\n[\n  {\"name_zh\": \"舜\", \"surface_forms\": [{\"text\": \"舜\", \"name_type\": \"primary\"}], ...}\n]\n```",
  "response_id": "msg_01UDb7nCGNvufcwYGj9o84TD",
  "stop_reason": "end_turn"
}
```

**这意味着**：NER 输出虽然不在磁盘上（F9 未实装），但**部分可从 `llm_calls.response` 中恢复**。不过：
- 27 条 ner/v1-r4 是有效的 β 调用（尚书），但不含 paragraph_id 映射（需要 cross-reference pipeline_runs 或根据 input 推断）
- 7 条 ner/v1 是 α 早期调用（可能被 v1-r2 后的重跑覆盖），reliability 存疑
- response 是 LLM 原始文本（含 markdown code fence），需要 parse
- **⚠️ `extractions_history` 表 0 行** — LLM Gateway audit writer 写 `llm_calls`，但不写 `extractions_history`（此表由 TraceGuard adapter 写，NER 流程未经 checkpoint 直写）

### E3: NER 输出落盘设想（参考，不做决策）

**建议路径**：`services/pipeline/outputs/ner/{book_slug}/{chapter}.jsonl`

**建议 JSONL schema 初稿**：

```jsonc
// 每行一个 paragraph 的 NER 结果
{
  "raw_text_id": "uuid",            // raw_texts.id
  "book_id": "uuid",                // books.id
  "book_slug": "shiji-wu-di-ben-ji",
  "chapter": "五帝本纪",
  "paragraph_no": 1,
  "prompt_version": "ner/v1-r4",
  "prompt_hash": "sha256:...",
  "llm_call_id": "uuid",            // llm_calls.id（可追溯 LLM 审计）
  "model": "claude-sonnet-4-6",
  "extracted_at": "2026-04-19T...",
  "persons": [
    {
      "name_zh": "黄帝",
      "surface_forms": [
        {
          "text": "黄帝",
          "name_type": "primary",
          "offset_start": 0,         // ← 可选：span 级定位
          "offset_end": 2
        }
      ],
      "dynasty": "上古",
      "reality_status": "legendary",
      "brief": "...",
      "confidence": 0.95,
      "identity_notes": null
    }
  ],
  "raw_llm_response": "..."         // 原始 LLM 输出（含 code fence）
}
```

**设计考量**：
- JSONL 格式（非 JSON 数组）便于 append-only、增量回放
- 含 `raw_text_id` + `llm_call_id` 双锚可追溯
- `offset_start` / `offset_end` 为可选字段——不要求当前 prompt 输出，但预留 span 级粒度的扩展位
- 不依赖 DB 存在即可离线使用（historian 黄金集对比、A/B prompt 迭代）

---

## F. 决策关键数据点

### F1: "新行必须带 evidence FK"改动预估

**场景**：从下一次 ingest 起，`load.py` 写 person_names 时必须同时创建 `source_evidences` 行并填充 FK。

**当前代码有什么 / 缺什么**：

| 信息 | 有无 | 来源 |
|------|------|------|
| `raw_text_id`（段落 UUID） | ✅ 有 | `MergedPerson.chunk_ids` |
| `paragraph_no` | ✅ 有 | `MergedPerson.paragraph_nos` |
| `book_id` | ✅ 有 | 从调用链传入 |
| `prompt_version` | ✅ 有 | `ExtractionResult.prompt_version` |
| `llm_call_id` | ❓ 需改 | Gateway 返回 `LLMResponse.call_id`，但 extract→load 链未透传 |
| **Per-surface 段落归属** | ❌ 无 | `SurfaceForm` 无 `chunk_id` — MergedPerson 聚合了多段 |
| **Per-surface 字符偏移** | ❌ 无 | NER prompt 不要求 LLM 输出 offset |

**LOC 估算（段落粒度，不要求 per-surface offset）**：

| 变更位置 | 内容 | 预估 LOC |
|---------|------|---------|
| `extract.py` — `SurfaceForm` | 添加 `chunk_id: str` 字段 | ~3 |
| `extract.py` — parse 逻辑 | 在 per-paragraph 解析时为每个 sf 附加 chunk_id | ~5 |
| `load.py` — `MergedPerson` | 在 merge 时保留 per-surface chunk_id | ~10 |
| `load.py` — `_insert_person_names()` | 创建 source_evidence 行 + 填充 FK | ~20 |
| `load.py` — 函数签名 | 透传 book_id / prompt_version | ~5 |
| tests | 新增 / 修改 load 测试 | ~30 |
| **合计** | | **~73 LOC** |

**LOC 估算（span 粒度，需要 LLM 输出 offset）**：

| 额外变更 | 内容 | 预估 LOC |
|---------|------|---------|
| NER prompt v1-r5 | 输出 schema 增加 `offset_start` / `offset_end` | ~15（prompt markdown） |
| `extract.py` | parse offset、校验在原文范围内 | ~15 |
| `load.py` | evidence 行写 position_start/end + quoted_text | ~10 |
| tests | offset 校验测试 | ~20 |
| **额外合计** | | **~60 LOC** |
| **段落 + span 总计** | | **~133 LOC** |

**前置依赖**：
- 段落粒度：**无硬前置**，可直接改
- Span 粒度：需要 prompt 改版（v1-r5），且 LLM offset 输出可能有精度问题（需黄金集校验）

### F2: 存量回填

**可回填范围**：

| 类别 | 行数 | 可否回填 | 方法 |
|------|------|---------|------|
| Active persons、surface 在 raw_texts 中可找到 | 243/245 surfaces | ✅ 可回填 | `raw_text LIKE '%surface%'` 反查 |
| Active persons、surface 不在 raw_texts 中 | 2 surfaces（司马迁、周成王） | ❌ 不可 | 字典合成身份，不在已摄入古籍中 |
| Soft-deleted persons (merged sources) | 33 name rows | ⚠️ 部分可 | 文本搜索可定位，但价值有限（已合并） |
| β rollback 重建行（3e4f389a） | 3 rows | ⚠️ 可但精度差 | 只能靠文本搜索，无 NER cache |

**回填数据规模**：
- 245 distinct active surfaces → 739 total (surface, paragraph) matches
- 一个 surface 平均出现在 ~3 个段落 — **一对多** 问题
- 回填策略选择：
  - 取**第一次出现**段落 → 282 个 source_evidence 行，1:1 映射
  - 取**所有出现**段落 → 需要走 `evidence_links` 多对多表，person_names.source_evidence_id 指向第一条

**不能回填的行估计**：
- 字典种子行：~2 surfaces（司马迁、周成王），但实际影响更广——40 人字典种子的大量 name 行来自手工 INSERT，非 NER 抽取，回填意义有限
- β 3 行重建（3e4f389a）：可通过文本搜索定位到尚书段落，技术上可回填

### F3: Paragraph vs Span 粒度对比

| 维度 | Paragraph 粒度 | Span 粒度（含 offset） |
|------|---------------|---------------------|
| **改动成本** | S（~73 LOC，无 prompt 改动） | M（~133 LOC，含 prompt v1-r5） |
| **LLM 风险** | 无（不改 prompt） | 中（LLM offset 可能不准，需校验） |
| **GraphQL 高亮定位** | ❌ 只能定位到段落 | ✅ 可精确高亮 surface 在原文中的位置 |
| **搜索结果上下文** | 返回整段 raw_text | 返回精确片段 + 上下文窗口 |
| **知识图谱可视化** | "出自五帝本纪 P24" | "出自五帝本纪 P24 第5-7字" |
| **"N 次衍生"能力** | 基础衍生 ✅ | 丰富衍生 ✅✅ |
| **回填复杂度** | 简单（文本搜索 → 段落 ID） | 复杂（需 `str.find()` 计算 offset） |
| **存量一致性** | 新旧行均为段落级，一致 | 旧行需补 offset 或接受混合粒度 |
| **宪法 C-1 满足度** | 满足最低要求 | 充分满足 |

**建议路径**：先段落粒度打通链路（S cost），α 扩量时再升级 span（M cost），避免一次性大改动 + prompt 风险。

---

## 调研人初步观察（给架构师的输入）

基于上述事实提出 3 个方向的初步感觉（不做定论）：

### 方向 A："新行必填 + 段落粒度"

- **一句话**：从下一次 ingest 起，load.py 创建 source_evidence 行（段落粒度），填入 person_names.source_evidence_id；存量不回填
- **适用范围**：所有未来 NER ingest
- **成本**：S（~73 LOC）
- **风险**：低 — 不改 prompt、不影响存量
- **代价**：282 行存量永远 NULL，新旧混合状态持续存在

### 方向 B："新行必填 + 存量 paragraph-level 回填"

- **一句话**：方向 A + 对存量 282 行通过 `raw_text LIKE '%surface%'` 反查回填段落级 evidence
- **适用范围**：全量
- **成本**：M（方向 A + 回填脚本 ~50 LOC + 一对多策略决策）
- **风险**：中 — 一个 surface 可能出现在多个段落，需要决策"取哪个"；2 个字典种子 surface 无法回填
- **代价**：回填行的 evidence 是"计算推断"而非"NER 原始输出"——provenanceTier 语义应标为 `ai_inferred` 而非 `primary_text`

### 方向 C："新行必填 + 存量暂缓 + span 粒度路线图"

- **一句话**：Phase 0 尾声用方向 A（段落粒度）打通链路；α 扩量时升级 prompt v1-r5 输出 offset 实现 span 粒度；存量在 span 方案成熟后再统一回填
- **适用范围**：渐进式
- **成本**：S 起步 → M 长期
- **风险**：低起步，span 阶段有 LLM 精度风险（需黄金集校验 offset 准确率）
- **代价**：存量混合粒度过渡期；需要两次改动而非一次

**决策交架构师 ADR-015。**

---

## 附录：意外发现与警报

### ⚠️ Alert 1: `extractions_history` 表 0 行

`extractions_history` 是 schema 设计用来保存"每段的 NER 结果 by prompt version"的审计表（C-11 requirement），但**从未被写入**。NER 流程中 `extract_persons()` 调用 LLM Gateway → Gateway 写 `llm_calls` 审计 → 但**不写 `extractions_history`**（后者由 TraceGuard adapter 管辖，NER 未走 checkpoint 直写流程）。

这意味着：
- C-11（"LLM 抽取结果按 prompt 版本保留历史，不覆盖"）**实质未被满足**
- `llm_calls.response` 是唯一的 NER 输出存档，但缺乏结构化索引（无 paragraph_id 作为 key）
- 与 F9（NER 输出不落盘）是同一问题的两个面

### ⚠️ Alert 2: `source_evidences` 表 0 行

不仅是 person_names 的 FK 没填——**FK 目标表 source_evidences 本身从未被写入**。整个 evidence 子系统（source_evidences + evidence_links + feedback 的 evidence_id FK）是一个**从未激活的空壳**。

这比"某列 NULL"严重得多——它意味着填充 evidence 链不是"给已有 INSERT 加一列"，而是需要**首次启用一个从未跑过的子系统**。

### ⚠️ Alert 3: `person_names` 实际 282 行（非 retro 报告的 279）

retro 和 followups 文档引用 279 行，但实际为 282 行。差异 +3 行来自 β 收尾操作后的新增（可能是 T-P0-015 帝鸿氏 alias INSERT 等）。文档数字需在下次更新时校正。

### ℹ️ Info: `llm_calls.response` 是救命稻草

34 行 NER 调用的完整 LLM 响应已保存在 `llm_calls.response` JSONB 中。虽然不如 F9 设想的 JSONL 持久化方便，但**理论上可以从中恢复所有 NER 输出**，用于回填 evidence 链。不过需要解决：
1. response 文本中的 markdown code fence 需要 parse
2. 无直接 paragraph_id 映射（需 cross-reference 或从 input 推断）
3. 7 条 ner/v1 调用可能与后续重跑（v1-r2/r4）的行不匹配
