# T-P0-026 · 词典 Seed Loader 可行性调研

- **调研日期**：2026-04-21
- **作者**：首席架构师（架构侧）+ x86（产品/项目经理侧，需求澄清）
- **触发**：T-P0-024 α 收官后，下一 Sprint B（T-P0-025 字典 seed loader）需要数据地基
- **结论预告**：**Wikidata 单源可行、CBDB 受 NC 条款限制只能参考不入库、ctext 字典受订阅限制延后**。Sprint B 建议 scope 收缩为"Wikidata 单源 seed + 自建补丁"。

---

## 1. 背景与目标

### 1.1 调研触发

T-P0-024 α 把证据链覆盖率（V7）从 52.48% 拉到 96.37%，但这是在 **已有三本书语料**（史记 五帝本纪 / 夏本纪 / 殷本纪 / 周本纪、尚书 尧典 / 舜典，《左传》相关段落）的基础上完成的。下一阶段要扩展到更多文本时，会遇到：

1. **NER 精度天花板**：v1-r4 prompt 在三本书内精度 94% / 召回 100%，但新文本会引入未见过的 surface 形式（异写、避讳、谥号、尊称等），LLM 单打独斗会跑飞
2. **消歧无外部锚点**：同名异人（例如"桓公"在不同诸侯国之间，"武王"在周 / 商之间）目前只能靠 prompt 里的上下文 heuristic，缺乏外部权威词典对照
3. **评价集稀缺**：没有外部 ground truth 可以和我们抽取结果对标

Seed 词典的核心价值：
- **NER hint**：已知 surface → known person 的精确匹配，绕过 LLM
- **消歧 anchor**：多个候选 person 用 seed 的属性（朝代、姓氏、地域、官职）打分
- **evidence 补强**：seed 条目本身作为 `provenance_tier = seed_dictionary` 的 source_evidence（ADR-015 已预留枚举值）

### 1.2 业务约束

- **当前只用公开数据**（x86 明确指示）
- **未来可能商业化**（CLAUDE.md §1 "未来可延展为移动 APP / API 开放平台 / 商业版"）
- **HuaDian 数据会以某种形式对外提供**（至少是 Web MVP 展示层，将来可能开放 API）

这两点合在一起决定了 **非商业（NC）条款的数据不能污染我们的主数据库**——任何 NC 数据一旦入库，整个下游产品就被传染，未来商业化要清退 NC 数据的成本会非常高。

### 1.3 调研范围

- **in scope**：Wikidata、CBDB、ctext.org（3 个公开可得的权威源）
- **out of scope**（留位给将来）：《辞源》《汉语大词典》《中国历代人名大辞典》等授权商业词典

---

## 2. 候选源详评

### 2.1 Wikidata — **TIER 1 主力推荐**

#### 2.1.1 概况

- **性质**：Wikimedia 基金会旗下协作式结构化知识库
- **规模**：~1.1 亿 items（截至 2026-01），结构化数据体量 ~1.6 TB 未压缩 / ~130 GB 压缩 JSON dump
- **历史人物覆盖**：世界范围，我们关心的中国古代（先秦—秦汉）历史人物条目数估计 ~数千到 ~万级（需 probe 确认）
- **更新频率**：实时（全球协作编辑）；dump 每周生成
- **结构**：基于 Q-item 的 RDF triple store，每个 item 有 label（多语言）+ claim（P-property → value）

#### 2.1.2 License

- **CC0**（结构化数据）—— 公共领域等价，**无任何附加条件**
- 允许商业使用、允许闭源产品集成、允许二次分发、无 viral clause
- **这是我们唯一真正"无后顾之忧"的源**

#### 2.1.3 技术接入

| 方式 | 适合场景 | 复杂度 |
|------|---------|-------|
| **SPARQL endpoint**（https://query.wikidata.org） | 按需查询、抽样、小规模 seed 加载 | 低 |
| **JSON dump**（weekly，~130 GB gz） | 全量本地索引、离线查询 | 中 |
| **Wikidata Toolkit** / pywikibot | 编程化访问特定 item | 低 |

**关键 property**（用于我们 schema mapping）：

| P-number | 含义 | HuaDian target |
|----------|------|---------------|
| P31 | instance of（应为 Q5 人类） | Person type filter |
| P569 | birth date | persons.birth_date_historical |
| P570 | death date | persons.death_date_historical |
| P19 | place of birth | → places 表 |
| P20 | place of death | → places 表 |
| P22 | father | → identity_hypotheses / relations |
| P25 | mother | → identity_hypotheses / relations |
| P40 | child | → identity_hypotheses / relations |
| P106 | occupation | → person attributes（官职、身份） |
| P734 | family name | persons.surname hint |
| P735 | given name | persons.given_name hint |
| P1819 | described by source | → seed 溯源字段 |

#### 2.1.4 已知问题

- **pre-7 世纪中国人物条目密度低**：先秦人物在 Wikidata 上常常只有寥寥几条 property；黄帝、尧、舜这类传说人物尤其稀薄
- **中文 label 质量不均**：有些条目 zh label 为空，要回退到 zh-classical / zh-hans / zh-hant 多个 variant
- **多源合并可能制造错误条目**：Wikidata 是协作编辑，偶有 vandalism 或误合并 item，需要我们本地做 sanity check
- **dump 体积大**：130 GB 压缩 / 1.6 TB 未压缩，全量索引需要考虑增量策略

#### 2.1.5 Probe 建议

在 Sprint B Stage 0a 里先跑一组 SPARQL 探针，回答：
- 我们现有 320 active persons 里，**有多少能在 Wikidata 里匹配到一个权威 Q-item**？（预期 30%–60%，名人高、无名者低）
- 对于能匹配的部分，**Wikidata 的补充属性（生卒年、家族、官职）在多大比例条目上存在**？

这两个数字决定 Sprint B 的实际产出上限。

### 2.2 CBDB — **TIER 2 受限参考**

#### 2.2.1 概况

- **全称**：China Biographical Database Project（中国历代人物传记资料库）
- **主办**：哈佛大学 + 台湾中央研究院 + 北京大学
- **规模**：~649,533 人（截至 2025-05-20 发布版 CBDB_bi_20250520）
- **时期覆盖**：**主要 7 世纪—19 世纪（唐—清）**
- **形态**：SQLite / MS Access 单文件，可完整下载
- **更新频率**：版本化发布，最新快照 2026-02-08

#### 2.2.2 License — 关键限制

**Creative Commons Attribution-NonCommercial-ShareAlike 4.0（CC BY-NC-SA 4.0）**

- 🔴 **NC（NonCommercial）**：禁止商业使用
- 🔴 **SA（ShareAlike）**：**viral**——任何基于 CBDB 数据派生的新数据库必须也采用 CC BY-NC-SA 4.0
- 📌 **exclusive commercial license**：2018 年后 CBDB 把独家商用权授给了 ChineseAll.com（中华书局系下游）

**对 HuaDian 的含义**：

1. **CBDB 数据不能入 HuaDian 主库**——一旦入库，主库的下游分发（Web、API、商业版本）都被 NC + SA 传染
2. **"pipeline-time 查询"也有风险**——如果我们在抽取过程中用 CBDB 验证或增强，然后把增强结果写入 persons 表，这个写入动作的产出是否算"派生作品"，法律上是 gray area
3. **唯一绝对安全的用法**：CBDB 仅用于**人工核查**，架构师 / 历史学家在判断某个 merge 或 NER 结果时**肉眼参考**，不以任何自动化方式把 CBDB 数据写入我们代码库或数据库

#### 2.2.3 覆盖度错配

即使授权问题解决，CBDB 对 **HuaDian 当前 era 的帮助也很有限**：

| 时期 | CBDB 覆盖密度 | HuaDian 当前语料 |
|------|-------------|-----------------|
| 先秦（~前 221） | 稀薄 | 史记五帝本纪 / 夏本纪 / 殷本纪 / 周本纪 ✅、尚书 ✅、左传 ✅ |
| 秦—汉（前 221—220） | 中等 | 史记本纪 / 列传扩展（未来） |
| 三国—隋（220—618） | 中等 | （未覆盖） |
| **唐—清（618—1911）** | **密集** | （本项目 Phase 0-1 完全不涉及） |

**结论**：CBDB 的价值在 **Phase 2+ 项目扩展到唐宋元明清时才会兑现**，Phase 0-1 基本用不上。

#### 2.2.4 技术接入（若未来启用）

- **SQLite dump**：https://github.com/cbdb-project/cbdb_sqlite（最新 2026-02-08）
- **API**：https://projects.iq.harvard.edu/cbdb/cbdb-api（按 CBDB ID 或 name 查询）
- **Schema**：主表 BIOG_MAIN + 亲属 KIN_DATA + 职官 POSTED_TO_OFFICE_DATA + 著作 + 社团 + 地名 addr_codes（完整 schema 见 Journal of Open Humanities Data 论文 DOI:10.5334/johd.68）

### 2.3 ctext.org — **TIER 3 延后**

#### 2.3.1 概况

- **性质**：Donald Sturgeon 主导的古籍数字化平台
- **语料价值**：HuaDian 已在用它做古籍全文源（ctext adapter 已实现在 services/pipeline/sources/ctext.py）
- **字典能力**：有 classical Chinese usage dictionary，交叉链接到文本库

#### 2.3.2 License

- **站点条款模糊**：copyright "2006-2026"，"use of automatic download software is strictly prohibited"
- **重要**：我们当前的 ctext adapter 抓取 **文本 fulltext** 已经在 gray area（违反"禁止自动下载"但未被追究），不应扩展到抓取字典结构化数据
- **字典数据**的机读访问明确要求订阅

#### 2.3.3 订阅要求

- **Free tier**：只能通过站内浏览，无结构化数据
- **Institutional subscription**：需联系 Donald Sturgeon 获取 API key（定价不透明，网上无公开价码）
- **API 能力**：getstatus / gettext / getlink / readlink；**字典 endpoint 需订阅**
- **禁止条款**：未授权的自动化抓取被明确禁止

#### 2.3.4 结论

- Sprint B 阶段 **不启用 ctext 字典**
- 当前 ctext text ingest 路径 **保持现状不扩展**（已实现、够用）
- 若未来需要 ctext 字典数据：走订阅流程 → ADR 记录 → 独立 Sprint

---

## 3. 评估矩阵

| 源 | 规模 | 主要覆盖 | 结构化度 | 可得性 | License | 对 HuaDian 商业化兼容 | 对当前 era 的帮助 | **推荐优先级** |
|---|------|---------|---------|--------|---------|--------------------|-----------------|--------------|
| **Wikidata** | ~1.1 亿 Q-items | 全类、全球 | ⭐⭐⭐⭐⭐（RDF 三元组） | ✅ 公开 SPARQL + dump | **CC0** | ✅ 完全兼容 | ⭐⭐⭐（先秦稀薄，秦汉中等） | 🟢 **P0 主力** |
| **CBDB** | ~64.9 万人 | 7—19 世纪中国人物 | ⭐⭐⭐⭐（SQLite 关系表） | ✅ SQLite 下载 / API | 🔴 **CC BY-NC-SA 4.0** | ❌ 不兼容（NC+SA） | ⭐（唐前稀薄） | 🟡 **P2 仅供人工参考** |
| **ctext dict** | 未公开 | 古汉语字义 | ⭐⭐⭐（API JSON） | 🔒 订阅制 | 🔴 抓取禁、商用未定 | ❌ 不兼容 | ⭐⭐（字义有用） | 🔴 **P3 延后** |
| **自建 seed** | 取决于工作量 | 可定向覆盖 | 我们自己的 schema | ✅ 完全可控 | ✅ 我们自主选 license | ✅ 完全兼容 | ⭐⭐⭐（可定向填补） | 🟢 **P1 补丁** |

---

## 4. License 矩阵（决策依据）

| 条款维度 | Wikidata | CBDB | ctext | 我们需要的最低条件 |
|---------|---------|------|-------|-----------------|
| 免费获取 | ✅ | ✅ | 订阅 | ✅ |
| 公开可下载 | ✅ | ✅ | ❌ | ✅ |
| 允许商业使用 | ✅ | ❌ | 不清 | ✅ |
| 允许闭源产品集成 | ✅ | ❌ | ❌ | ✅ |
| 允许二次分发 | ✅ | ✅（但需同 NC-SA） | ❌ | ✅ |
| 无 viral 传染 | ✅ | ❌（SA） | 不清 | ✅ |
| 要求 attribution | ❌（建议但非必需） | ✅ | ✅ | —— |
| **可直接入主库** | ✅ | ❌ | ❌ | ✅ |

**法律层面的唯一"直接入库"源：Wikidata**。这是铁律。

---

## 5. Seed Schema v0.1 草案

### 5.1 设计原则

1. **溯源优先**：每条 seed 条目都能回溯到哪个源、哪次 dump、哪个外部 ID
2. **不污染 persons**：seed 表**独立**于 persons 表，seed 条目通过 `seed_mappings` 关联到 persons 而非直接成为 persons（可撤回）
3. **版本化**：支持多个 dump 并存，切换 source snapshot 不破坏历史
4. **与 ADR-015 evidence chain 对齐**：seed 条目可以作为 source_evidence 的一种（provenance_tier = 'seed_dictionary'）

### 5.2 表结构草案

```sql
-- 词典源注册
CREATE TABLE dictionary_sources (
  id                  UUID PRIMARY KEY,
  source_name         TEXT NOT NULL,         -- 'wikidata', 'cbdb', 'self-curated'
  source_version      TEXT NOT NULL,         -- '20260421' / 'v0.1.0'
  license             TEXT NOT NULL,         -- 'CC0', 'CC-BY-NC-SA-4.0', 'project-owned'
  commercial_safe     BOOLEAN NOT NULL,      -- 真正敢入主库的门槛
  access_url          TEXT,                  -- SPARQL endpoint / SQLite path / internal path
  ingested_at         TIMESTAMPTZ NOT NULL,
  notes               JSONB,
  UNIQUE (source_name, source_version)
);

-- 词典条目（一条原始外部数据）
CREATE TABLE dictionary_entries (
  id                  UUID PRIMARY KEY,
  source_id           UUID NOT NULL REFERENCES dictionary_sources(id),
  external_id         TEXT NOT NULL,         -- Q-number / CBDB ID / self-ref
  entry_type          TEXT NOT NULL,         -- 'person', 'place', 'polity', 'reign_era', 'office'
  primary_name        TEXT,                  -- 推荐中文主名
  aliases             JSONB,                 -- [{name, language, source_note}]
  attributes          JSONB NOT NULL,        -- 源字段原样保留（不强制归一）
  ingested_at         TIMESTAMPTZ NOT NULL,
  UNIQUE (source_id, external_id)
);

-- 条目 → HuaDian 实体的映射（关键：这是 seed 可撤回的前提）
CREATE TABLE seed_mappings (
  id                      UUID PRIMARY KEY,
  dictionary_entry_id     UUID NOT NULL REFERENCES dictionary_entries(id),
  target_entity_type      TEXT NOT NULL,     -- 'person', 'place', ...
  target_entity_id        UUID NOT NULL,     -- persons.id / places.id / ...
  confidence              NUMERIC(3,2),      -- 0.00 - 1.00
  mapping_method          TEXT NOT NULL,     -- 'exact_name' / 'manual_review' / 'llm_hinted'
  mapping_created_at      TIMESTAMPTZ NOT NULL,
  mapping_status          TEXT NOT NULL DEFAULT 'active',  -- 'active' / 'superseded' / 'rejected'
  notes                   JSONB,
  UNIQUE (dictionary_entry_id, target_entity_type, target_entity_id, mapping_status)
);
```

### 5.3 与现有架构集成

- **ADR-015 provenance_tier**：已有 `seed_dictionary` 枚举值（migration 0008 已落），直接复用。seed_mappings 触发 source_evidences 写入时 provenance_tier = 'seed_dictionary'
- **ADR-014 apply_merges**：seed 不触发 merge，seed_mappings.confidence < 0.8 的条目不自动入 source_evidences，需进入 identity_hypotheses 待人工审
- **identity_resolver**：seed 作为消歧 rule 的外部锚点——在 R1-R5 规则之外新增 R6-seed-match（优先级最高，绕过所有 heuristic）
- **Pipeline 运行时**：NER 之前先跑 seed_preprocessor，把文本中直接命中 seed primary_name / aliases 的 span 预标记，LLM 只负责未命中部分

### 5.4 冲突解决规则

当 Wikidata 和 CBDB（假设我们也决定加入）对同一人物给出冲突属性时：

| 情形 | 处理 |
|------|------|
| 两源都有 attribute X，值相同 | OK，单独记 |
| 两源都有，值不同 | 保留两条 dictionary_entries，在 seed_mappings 里各建一条 mapping，触发 identity_hypothesis |
| 一源有一源无 | 直接采纳有的那源 |
| 日期冲突 | 走 HistoricalDate 双记（已有 schema），写明 source |

因为 HuaDian 当前只采纳 Wikidata，实际 Phase 0-1 不会触发多源冲突。但 schema 提前预留能力。

---

## 6. 与 HuaDian 现有架构的集成点

### 6.1 Evidence 链（ADR-015）

- `provenance_tier = 'seed_dictionary'` 已存在（migration 0008）
- seed 写 source_evidences 的逻辑跟 AI_INFERRED 走相同两步 INSERT 路径
- 区别：`raw_text_id` 必须指向一个特殊的 "pseudo book" — "Wikidata dump 20260421"，需要新建 book 条目

### 6.2 identity_resolver（ADR-010）

在 `services/pipeline/src/huadian_pipeline/resolve_rules.py` 里增加 R6：

```python
def r6_seed_dictionary_match(candidates, seed_entries):
    """最高优先级：若 canonical name 与 seed primary_name 精确匹配，锁定。"""
    ...
```

R6 优先级高于 R1-R5（当前所有 heuristic）。

### 6.3 load.py

NER 输出进 load 之前，先跑一遍 seed_preprocessor：
- 命中 → 直接 bind to seed's target_entity_id，跳过 persons 新建
- 未命中 → 走正常 NER → resolve → load 路径

### 6.4 Web 展示

Person card 增加 "外部链接" 区块：
- Wikidata Q-number（若有 seed_mapping）
- 不显示 CBDB 链接（NC 条款风险）

---

## 7. 推荐的 Sprint B 范围

### 7.1 T-P0-025 — 词典 Seed Loader（Wikidata 单源）

**Sprint 目标**：把 Wikidata 里匹配到 HuaDian 现有 320 persons 的条目，以 seed 形式入库，并激活 seed-first 消歧路径。

**Stage 规划**：

| Stage | 内容 | 关键产出 |
|-------|------|---------|
| 0a | Probe：320 persons × Wikidata 匹配率评估 | 报告 |
| 0b | Schema migration（dictionary_sources / dictionary_entries / seed_mappings） | migration 0009 |
| 1 | Wikidata SPARQL adapter | src/huadian_pipeline/seeds/wikidata_adapter.py |
| 2 | Name-based 初步 matching + 人工 review 入口 | seed_mappings confidence + manual queue |
| 3 | R6 seed-dictionary-match rule 集成 resolve | resolve_rules.py 扩展 |
| 4 | V8 invariant（seed mapping coverage） | 测试 + STATUS |
| 5 | Sprint 收尾 | 常规 |

**预估工期**：3-5 工作日
**LLM 成本预估**：$0（SPARQL + 结构化 matching 不需要 LLM）
**预期收益**：为 P0-3+ 新语料摄入提供外部锚点，NER 精度上限从 ~94% 拉到 ~97%+

### 7.2 T-P0-025b — 自建 seed 补丁（可选，独立 Sprint）

针对 Wikidata 覆盖不到的先秦 / 上古人物，自建一份 seed 文件：
- 源：公共领域注疏（《史记》三家注、《尚书》孔传、《左传》杜注等）
- 形式：YAML / JSON，项目自有 license
- 规模：~50–100 条高频名 person

这是 Sprint B 后的 follow-up，不并入 T-P0-025。

### 7.3 暂缓项

- **CBDB**：Phase 0-1 不启用。Phase 2（扩展到隋唐以后）时重评。
- **ctext dict**：需要联系 Donald Sturgeon 洽谈订阅，x86 或历史学家角色推进，非架构师范围。
- **商业词典**（辞源 / 汉语大词典）：待有明确商业化规划 + 法务支持后再评。

---

## 8. 风险与开放问题

| # | 风险 | 严重度 | 建议处理 |
|---|------|-------|---------|
| R1 | Wikidata 对先秦人物覆盖度可能极低，导致 Sprint B 产出低于预期 | 中 | Stage 0a probe 先量化，若 < 20% 则调整 Sprint scope 或启动 T-P0-025b 自建 |
| R2 | Wikidata 条目 zh label 缺失 / 不准 | 低 | 多语言 label fallback + 人工 review queue |
| R3 | SPARQL endpoint 速率限制 | 低 | 支持切换到本地 dump（加载一次 weekly dump + 本地索引） |
| R4 | Wikidata 有 vandalism / 错误合并 | 低 | seed_mappings.confidence 设默认中等 + 人工 review 前不自动走 R6 |
| R5 | 未来若启用 CBDB，license 边界含糊 | 高 | **Phase 0-1 明确不启用 CBDB**，进 Phase 2 时单独 ADR 裁决 |

---

## 9. 建议的决策

**批准以下决议（写入 ADR-021）：**

1. **Sprint B（T-P0-025）只采用 Wikidata 作为唯一 seed 源**
2. **CBDB 延后到 Phase 2+，且未来启用前必须 ADR 单独裁决**
3. **ctext 字典 API 延后，需要 x86 / 历史学家主导订阅洽谈**
4. **Seed schema v0.1 按本文第 5 节落地，provenance_tier 复用 'seed_dictionary' 枚举**
5. **Sprint B 启动前跑 probe（Wikidata 对现有 320 persons 的匹配率），根据 probe 决定是否需要并开 T-P0-025b 自建 seed**

---

## 10. 参考来源

- [China Biographical Database Project (CBDB)](https://cbdb.hsites.harvard.edu/)
- [CBDB Download 页面](https://projects.iq.harvard.edu/cbdb/download-cbdb-standalone-database)
- [CBDB API](https://projects.iq.harvard.edu/cbdb/cbdb-api)
- [CBDB SQLite repo](https://github.com/cbdb-project/cbdb_sqlite)
- [CBDB Exclusive Commercial License](https://projects.iq.harvard.edu/cbdb/exclusive-commercial-license)
- [CBDB (Journal of Open Humanities Data DOI:10.5334/johd.68)](https://openhumanitiesdata.metajnl.com/articles/10.5334/johd.68)
- [Wikidata:Licensing](https://www.wikidata.org/wiki/Wikidata:Licensing)
- [Wikidata:SPARQL query service](https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service)
- [Wikidata:Database download](https://www.wikidata.org/wiki/Wikidata:Database_download)
- [Wikimedia Data dumps legal](https://dumps.wikimedia.org/legal.html)
- [Chinese Text Project API](https://ctext.org/tools/api)
- [Chinese Text Project Subscribe](https://ctext.org/tools/subscribe)
