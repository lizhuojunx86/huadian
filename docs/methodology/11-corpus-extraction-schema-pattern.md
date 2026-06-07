# 叙事语料抽取存储 Schema 骨架
# Narrative Corpus Extraction Storage Schema Skeleton

> **Status**: v0.1（2026-06-07 / 架构师起草 / 经对抗式核验收紧 scope）
> **Owner**: 首席架构师
> **Source（双实现字段级互证）**: huadian 史记语料 schema（`packages/db-schema/src/schema/sources.ts` + `events.ts` + `persons.ts`）↔ storyextractor（`~/Desktop/APP/storyextractor/src/storyextractor/db.py` + `model.py`，源码注释自承"mirrors huadian's design / ingest contract"）
> **触发**: [ADR-038](../decisions/ADR-038-shiji-extension-milestone-superseded-by-case-2.md) §6 #5 — storyextractor 下游引用评估暴露"被复用的是模式不是数据"，且该模式**不在**已抽象的 framework/ 三模块内
> **配套**: [case-study-storyextractor-adoption-v0.1.md](./case-study-storyextractor-adoption-v0.1.md)（同一抽象的可移植性实证）

---

## 0. 论点与定位（含**钉死的 scope 边界**）

00-07 抽象的是工程**方法**（角色 / sprint / 不变量 / 审计 / ADR / 跨栈）；03 抽象**消歧逻辑**、05 抽象**审计工作流**。但有一层 03/05 都没碰、却被每个语料知识库重复手写的东西：**原文与抽取物在数据库里长什么样、溯源指针怎么连。** 本文抽象这一层。

**核心论点**：

> 面向**叙事性 / 文本语料**的抽取知识库，存在一个可复用的**存储 schema 骨架**：
> **Source → Unit → Span 三层语料骨架 + span 级溯源 + 抽取层永带回指 + 多源聚合保留每源。**
> 这四条是领域无关的数据契约形状；其余（多语言 / GIS / 纪年 / 可信度分级）都是 case 层的领域丰富度，不进核心。

**两个钉死的限定词**（去掉任一，本 pattern 立刻变成硬凑）：

1. **"叙事 / 文本语料"** —— 本骨架在叙事性古籍上字段级验证。它**不覆盖**"对语料本身下审计结论"的 schema（如 case-2 中药的 F-001~F-004 / σ 矩阵 / 双重反算）——那是**另一个 pattern**（合规叙事审计），见 [08](./08-dual-reverse-calculation-pattern.md)/[09](./09-layered-compliance-narrative-pattern.md)/[10](./10-subchannel-stratified-detection-pattern.md)，与本骨架结构上**几乎零共享**。
2. **"存储 schema 形状"** —— 本文只管"表结构 + 外键 + 溯源指针怎么连"。**消歧逻辑 see [03](./03-identity-resolver-pattern.md)，审核 / 决策状态机 see [05](./05-audit-trail-pattern.md)**，本文不复述。

**验证强度的诚实声明**：本骨架已在**两个独立实现**上字段级验证（huadian-Postgres / storyextractor-SQLite，后者源码自承镜像）——**但两者都是史记域**（storyextractor 另含吕氏春秋，仍属古籍叙事）。因此本文只能 claim **"核心在同域双实现下稳健"**，**不能** claim "已验证跨域可移植"。真·跨域证据需一个**非叙事**第三域（法律判例 / 财报 / 病历），目前**不存在**（见 §4）。

---

## 1. 真核心：四条骨架（字段级证据）

判据：huadian 史记 ↔ storyextractor 字段级对应（强证据 = 源码注释自承镜像）。

### 骨架 1 — Source → Unit → Span 三层语料结构

源文本不是一团 blob，而是 **源容器（Book/Source）→ 章节单元（Chapter/篇）→ 可寻址跨度（Paragraph/段）** 三层。**段级的稳定复合键就是溯源锚点。**

| 层 | huadian 史记 | storyextractor |
|---|---|---|
| Source | `books(slug, title, author, dynasty, genre, license)` | `books(slug, title, author, dynasty, genre, license)` |
| Unit | `raw_texts(book_id, chapter)` | `raw_texts(book_id, chapter_seq, chapter)` |
| Span | `raw_texts(paragraph_no, ...)` | `raw_texts(paragraph_no, original, vernacular)` |

> 字段几乎一一对应（storyextractor `db.py:1` 自承"Schema mirrors huadian's design (books / raw_texts ...)"）。稳定键 = `(book, chapter, paragraph_no)`。

### 骨架 2 — span 级溯源（provenance 到跨度，不到"文档"）

每条抽取结论都能回溯到**原文的某个字符 / 段范围**，而非泛泛"出自某篇"。

- huadian：`source_evidences(raw_text_id, position_start, position_end, quoted_text)` —— **字符偏移**级。
- storyextractor：`event_sources(chapter_seq, para_start, para_end, excerpt)` + `story_segments(story_id, raw_text_id)` + `entity_mentions(para_start, para_end, excerpt)` —— **段范围**级（粗粒度，但同构）。

> 粒度可调（字符偏移 ↔ 段范围）是 plugin 点；"抽取结论必须挂一条回原文的 span 指针"是核心契约。

### 骨架 3 — 抽取层 ≠ 原文层，且**永带回指**

实体 / 事件 / 故事等抽取产物，**永远不脱离它来自哪段**：所有抽取表强制外键回 `raw_texts` / `source_evidences`。"抽取物可以错、可以重抽，但它与原文的链接不可断"是数据完整性底线。

- huadian：`persons` / `events` / `mentions` 经 `source_evidences` 锚定。
- storyextractor：`stories` ← `story_segments` → `raw_texts`；`events` ← `event_sources`；`story_places.raw_text_id`。

### 骨架 4 — 多源聚合：融合但逐源保留溯源

纪传体同一事件天然分散（本纪记纲、列传记详）；同一实体跨篇出现。聚合层把多源融合成完整叙述，**但每个来源单独留一条带 span 溯源的记录 + 角色标签**。

| | huadian 史记 | storyextractor |
|---|---|---|
| 聚合实体 | `events` + `event_accounts`（ADR-002 双层：抽象事件锚点 + 多 account + `account_conflicts`）| `events` + `event_sources(role: 主叙/详述/简述/评论/旁证)` |
| 融合产物 | account 合并 | `canonical_summary`（LLM 融合 / 要点标来源）|

> 两侧都**有意**建模"融合 ≠ 抹掉来源"，结构同构。这是骨架里最有抽象价值的一条（朴素做法会把多源 flatten 成一段文本，丢失逐源可审计性）。

**真核心总结**：骨架 1+2+3+4 是字段级真实、源码自承的领域无关核心。**pattern 的硬核就是这四条。**

---

## 2. 与 03 / 05 的边界（不复述，只指针）

本骨架与已有两篇有**实质重叠**，必须划清，否则三篇打架：

| 关注点 | 归属 doc | 本文怎么处理 |
|---|---|---|
| 两个抽取物要不要 merge（消歧逻辑 R1-R6 / GUARD_CHAINS / 身份卡）| **[03](./03-identity-resolver-pattern.md)** | 本文只定义"抽取物表 + 别名 + 共现锚点字段长什么样"，**消歧逻辑 see 03** |
| 人审门控 / draft→approved 状态机 / 决策审计回查 | **[05](./05-audit-trail-pattern.md)** | 本文只定义"事实层 vs 人审门控层的表切分"，**状态机与审计 see 05** |
| **原文与抽取物在表里长什么样、溯源指针怎么连** | **本文（11）** | ← 这是 03/05 都没碰、本文唯一的合法领地 |

一个具体例子（"事实层 vs 门控层"切分，三方一致但归属 05）：storyextractor `db.py:82` 明示"人审只门控 `place_aliases.review_status`；`story_places` 是语料确定性函数，无人审"——这与 huadian "`mentions` 确定性抽取 / `triage_decisions` 门控 merge" 同构。**本文只记"要把确定性事实层与人审门控层分成两类表"这个 schema 切分决定；门控状态机本身 see 05。**

---

## 3. 领域无关核心 vs plugin 点（约 1/3 : 2/3）

对抗式核验的关键量化发现：**本骨架（领域无关核心）约占 huadian 史记 schema 的 1/3；其余 2/3 是史记的领域丰富度。**（与 [STATUS §1.2](../STATUS.md) 自测"领域无关 LOC ~56-62% < 70% 目标 / examples/huadian_classics 偏重"互证。）

| | 进核心（domain-invariant）| 留 plugin（domain-specific / case 层）|
|---|---|---|
| 语料结构 | Source→Unit→Span 三层 + 稳定键 | 体裁枚举（本纪/列传 vs 寓言/论说）|
| 溯源 | span 指针契约 | 粒度（字符偏移 vs 段范围）|
| 抽取物 | 永带回指 + 别名 + 锚点字段 | 抽取物类型（person / story / event）|
| 多源 | 融合保留每源 + 角色标签 | 角色词表 / 冲突建模深度 |
| **不进核心（史记丰富度 / 已被 storyextractor 砍掉）** | — | `MultiLangText{zh-Hans,zh-Hant,en}` / PostGIS `geometry` + 政区层级 + 纪年 / `credibility_tier`·`provenance_tier` 多级枚举 |

> **剔除清单（对抗式核验明确判出的"伪共享"）**：中药 F-001~F-004/σ矩阵（属 08/09/10 审计 pattern）、MultiLangText、PostGIS/纪年、多 LLM 共识 panel（storyextractor 单方实验，本质是 05 变体）、credibility/provenance tier。**命名相同（events/entities）≠ 抽象相同**（粒度/层次不同），不可当共享证据。

---

## 4. 跨域边界与 future work（诚实声明）

- **已验证**：核心骨架在**同域双实现**（huadian-Postgres 史记 / storyextractor-SQLite 史记+吕氏）字段级稳健。这证明"核心稳"——换执行者、换存储引擎，这四条会自发长出来。
- **未验证**：**跨域可移植性**。两个实现都是古籍叙事，是同域双实现，不是跨域。
- **future work（不在本文范围 / 需用户启动）**：用一个**非叙事**第三域（法律判例 / 财报 / 病历）做真·跨域探针——届时检验"叙事"限定词能否进一步松绑为"文本语料"，还是骨架在非叙事域就破。**当前仓库中无任何此类实例，不得伪造跨域结论。**

---

## 5. Fork 指南（新叙事语料项目如何实例化骨架）

最小可用骨架（storyextractor 用 9 张 SQLite 表 + 零第三方依赖跑通同域）：

1. `sources`（slug + 元数据 + license）
2. `units`（source_id + 章节序 + 章节名）
3. `spans`（unit_id + 段序 + 原文 [+ 译文]）+ 稳定键 `(source, unit_seq, span_no)`
4. `extractions`（抽取物，FK → spans / provenance）
5. `provenance`（extraction_id + span 指针 position/para range + quoted/excerpt）
6. `aggregations` + `aggregation_sources`（多源融合 + 逐源溯源 + role）
7. 消歧字段（别名 / 锚点）→ **see 03**；审核门控（status / review）→ **see 05**

> 粒度、抽取物类型、体裁枚举按域替换；四条骨架契约保持。**先实现 1-3（语料层）即可摄入；4-6 随抽取增量长出。**

---

## 6. 参考

- 双实现源码：huadian `packages/db-schema/src/schema/{sources,events,persons}.ts`；storyextractor `src/storyextractor/{db.py,model.py}` + `extract/entities.py`
- 相邻 pattern：[03 identity-resolver](./03-identity-resolver-pattern.md)（消歧）/ [05 audit-trail](./05-audit-trail-pattern.md)（审核）/ [02 event-account-split / ADR-002](../decisions/ADR-002-event-account-split.md)（多源双层）
- 可移植性实证：[case-study-storyextractor-adoption-v0.1.md](./case-study-storyextractor-adoption-v0.1.md)
- 剔除出本 pattern 的审计 schema：[08](./08-dual-reverse-calculation-pattern.md)/[09](./09-layered-compliance-narrative-pattern.md)/[10](./10-subchannel-stratified-detection-pattern.md)

---

> v0.1（2026-06-07）。scope 钉死两个限定词："叙事" + "存储 schema"。去掉任一，pattern 即从"真实、瘦、诚实"退化为"把中药审计 / 跨域宣称 / 史记丰富度硬塞进来的发明"。
