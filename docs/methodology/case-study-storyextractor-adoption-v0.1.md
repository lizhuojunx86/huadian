# 案例研究：storyextractor 对 huadian 框架的采纳（可移植性实证）
# Case Study — storyextractor's Adoption of the HuaDian Framework

> **Status**: v0.1（2026-06-07 / 架构师起草 / 经对抗式核验）
> **Owner**: 首席架构师
> **对象**: `~/Desktop/APP/storyextractor`（古籍故事抽取工具 / 独立项目 / 同一用户）
> **触发**: [ADR-038](../decisions/ADR-038-shiji-extension-milestone-superseded-by-case-2.md) §6 #5
> **配套**: [11-corpus-extraction-schema-pattern.md](./11-corpus-extraction-schema-pattern.md)（被采纳的骨架）
> **性质**: 第一份**真实下游**采纳证据 —— 不是 huadian 内部 dogfood，是一个独立项目自发"仿 huadian"

---

## 0. 一句话结论（双刃 / 诚实）

storyextractor 的"轻量重写"**同时**证明了两件方向相反的事：

> ✅ **框架的领域无关核心是真·可移植的**（四条骨架被自发保留）；
> ⚠️ **但当前 huadian 框架打包过重** —— 移植者做的第一件事是扔掉 60-70% 的 huadian schema。可移植的是那把瘦骨架，**不是 huadian 现在 ship 的那身肉**。

并且必须诚实：这是**同域移植（古籍→古籍）**，只证"核心稳"，**不证"跨域可移植"**。

---

## 1. 采纳关系（源码自承，非推测）

storyextractor 是独立项目，[ARCHITECTURE.md](../../../storyextractor/docs/ARCHITECTURE.md) 明示：

> "独立项目。**借用 huadian（华典智谱）的数据模型与管线设计**…但**不并入** huadian、不受其 D-route 框架宪法约束。原因：huadian 已转型为'工程框架'，与本项目的'产品/语料'目标取向不同。"

三处源码注释是采纳的铁证：
- `model.py:1` —「mirrors huadian's ingest contract, adapted & lightweight」
- `db.py:1` —「Schema mirrors huadian's design (books / raw_texts / stories / story_segments), trimmed to a single-file local DB」
- `extract/entities.py:5` —「借 huadian identity_resolver 思路, 轻量化」

**采纳形态 = 模式复用 + 轻量重写**：零第三方依赖（纯标准库 / SQLite），**不 import** huadian/kb-forge 代码，**不消费** huadian 史记数据（自建 916 文白对照语料）。即：借的是**设计**，不是 artifact。

---

## 2. 保留了什么 → 证明核心可移植

storyextractor 自发保留了 [11](./11-corpus-extraction-schema-pattern.md) 的**全部四条骨架**：

| 骨架 | storyextractor 实现 |
|---|---|
| Source→Unit→Span | `books` / `raw_texts(book_id, chapter_seq, paragraph_no)` |
| span 级溯源 | `event_sources(para_start, para_end, excerpt)` / `story_segments(raw_text_id)` / `entity_mentions(para_start/end)` |
| 抽取层永带回指 | `stories`←`story_segments`→`raw_texts`；`story_places.raw_text_id` |
| 多源聚合保留每源 | `events` + `event_sources(role: 主叙/详述/旁证)` + `canonical_summary` |

> 换了执行场景（Postgres→SQLite）、换了抽取物（person→story/event），这四条仍自发长出来 —— 这是"pattern 真实存在、领域无关"的强证据。

---

## 3. 砍掉了什么 → 反证框架打包过重

移植者主动扔掉的，**恰恰是 huadian 框架当前的大部分体量**：

| 被砍掉的 huadian 部件 | storyextractor 的处理 |
|---|---|
| Postgres + pgvector + Drizzle 全套 | → 9 张 SQLite 表 + 零第三方依赖 |
| identity_resolver R1-R6 完整链 | → "轻量化"：Gate1 廉价确定性守卫 + Gate2 LLM judge（`entities.py:5`）|
| `source_evidences` 字符偏移精度 | → 段范围 `para_start/end`（粗粒度够用）|
| `MultiLangText{zh-Hans,zh-Hant,en}` JSONB | → 单字段 `vernacular` 白话译文 |
| PostGIS `geometry` + 政区层级 + 纪年 | → `places(modern_name, admin_level, keywords)`，`db.py:90` 明示"永不生成沿革文本"（主动放弃 GIS）|
| `credibility_tier` / `provenance_tier` 多级枚举 | → 砍成 `reality_status` 一个字段 |
| `events` 双层 account + `account_conflicts` | → `events` + `event_sources`，冲突建模省略 |

**冷读结论**：要把框架搬到"第二份语料"，第一步是扔掉 60-70% 的 huadian schema。这强烈暗示——**huadian 框架的"重"，主要是史记这个 case 的领域丰富度，不是框架的领域无关核心。** 与 [STATUS §1.2](../STATUS.md) 自测"领域无关 LOC ~56-62% < 70% 目标 / examples/huadian_classics 偏重"**完全吻合、互为印证**。

> 别把"轻量重写成功"读成"框架已经够轻"——它恰恰是**反证**。

---

## 4. 新增了什么 → 框架未覆盖的真实需求

storyextractor 为产品目标加了 huadian 没有的层（提示框架可往哪长 / 或哪些该留 case 层）：

| 新增 | 说明 | 对框架的启示 |
|---|---|---|
| 文白对齐（`ingest/align.py` difflib + Needleman-Wunsch）| 文言原文 ↔ 白话译文段级对齐 | 译文/对照语料是叙事古籍子类需求，留 plugin |
| 多 LLM 共识 panel（`alias_reviews: provider/verdict/abstain`）| 4 家机审投票替代单一人审 | **本质是 05 audit-trail 的"approved_by=consensus"变体**，不是新核心 |
| 地点发现层（`places`/`place_aliases`/`story_places`）| 今地名反查 + 古今映射人审 | "确定性事实层 vs 人审门控层"切分 = 11 骨架 + 05 门控的组合实例 |

---

## 5. 对 kb-forge v0.1 的启示（可执行）

1. **v0.1 该 ship 的是瘦骨架，不是史记那身肉**：把 [11](./11-corpus-extraction-schema-pattern.md) 的四条骨架做成干净 core；MultiLangText / PostGIS / tier 体系明确留 `examples/huadian_classics/`，**不进 core**。这直接推进"领域无关比例 56-62% → 70%"目标。
2. **storyextractor 的"轻量化"是 kb-forge 的天然 reference fork**：它已示范"core 该多瘦"。可把它的 9 表 SQLite schema 作为 kb-forge `examples/` 的第二个 reference（与 huadian_classics 并列），证明 core 不绑 Postgres。
3. **identity_resolver 偏重已被实证**：移植者主动"轻量化"了它 → kb-forge 应提供一个"Gate1 确定性 + Gate2 LLM judge"的**轻量档**，而非只有完整 R1-R6 链。
4. **诚实记入北极星**：storyextractor 是"≥1 个真实下游引用"的达成证据（D-route §10 L1/L3），但要标注"同域 / 模式复用 / 非 import"，**不可**当作"跨域可移植已验证"。

---

## 6. 边界与未决（诚实声明）

- **本案例证明**：核心骨架在同域双实现下稳健 + 当前框架打包过重。
- **本案例不证明**：跨域可移植性（两实现都是古籍叙事）。
- **未决**：是否把 storyextractor 正式登记为 D-route Layer 3 第 2 案例？它是用户自有的独立产品项目（非 huadian 案例、非外部第三方）—— 介于"内部 dogfood"与"外部第三方案例"之间。建议登记为**"准外部采纳实证"**，区别于 case-2（huadian 内部跨域案例）与未来真·第三方案例。
- **future work**：真·跨域探针（非叙事域）= 检验 [11](./11-corpus-extraction-schema-pattern.md) "叙事"限定词能否松绑的唯一途径，当前不存在。

---

> v0.1（2026-06-07）。第一份真实下游采纳证据。核心论点：**可移植的是骨架，不是当前框架的全部体量；同域已证，跨域未证。** 任何把本案例当"跨域可移植已验证"或"框架已够轻"的引用都是过度解读。
