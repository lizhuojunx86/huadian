# Historian 判定卡 — 启(qi) vs 微子启(wei-zi-qi) / Wikidata Q186544

> **状态**: ✅ 已裁决
> **请求方**: 管线工程师（T-P0-027 Stage 4）
> **裁决依据**: CLAUDE.md §4 古籍专家"实体歧义仲裁"
> **裁决人**: historian (Claude Opus)
> **裁决日期**: 2026-04-24

---

## 1. 背景

Sprint C R6 merge detection 发现：
- **启**（slug: qi，华典 person）和 **微子启**（slug: wei-zi-qi，华典 person）
- 两者均 active seed_mapping → Wikidata **Q186544**
- R6 规则产生 MergeProposal(confidence=1.0)

管线工程师初步判断为 false positive（夏朝 vs 商朝，跨 ~1000 年）。

## 2. Historian 复核

### 2.1 Wikidata Q186544 当前状态

> SPARQL 端点: https://query.wikidata.org/sparql
> 查询时间: 2026-04-24T10:45:30Z（UTC）
> 查询模板: 附录 A（A1-A4 四条全部执行）

| 字段 | 值 |
|------|-----|
| rdfs:label @zh | 启 |
| schema:description @zh | 夏朝君主 |
| wdt:P569 (dateOfBirth) | （无数据） |
| wdt:P570 (dateOfDeath) | （无数据） |
| wdt:P31 (instance of) | Q5（人類） |
| wdt:P27 (country of citizenship) | （无数据） |

#### A2 别名全集（Q186544）

| 语言 | 类型 | 值 |
|------|------|-----|
| en | label | Qi of Xia |
| en | altLabel | Si Qi |
| en | altLabel | King Qi of Xia |
| en | altLabel | Qi Wang Xia |
| zh | label | 启 |
| zh-hans | label | 启 |
| zh-hant | label | 啓 |
| zh-hant | altLabel | 啓王夏 |
| zh-hant | altLabel | 夏王啟 |
| zh-hant | altLabel | 姒啟 |

**关键观察**：Q186544 的全部 label 和 altLabel（10 条）均指向夏启，无任何"微子"相关别名。

#### A3 "启"与"微子启" QID 检索

| QID | label | description |
|-----|-------|-------------|
| Q186544 | 启 | 夏朝君主 |
| Q855012 | 微子 | 商朝宗室，宋国始祖 |

**关键观察**：Wikidata 上两人拥有**独立的 QID**。微子启的正确 QID 为 **Q855012**（primary label "微子"），非 Q186544。

#### A4 合并/重定向历史

Q186544 无 owl:sameAs、P460（said to be the same as）、P1889（different from）任何三元组。不存在 Wikidata 层面的合并或混淆痕迹。

---

### 2.2 证据分析

#### 证据 A：Wikidata 结构化数据（来自 SPARQL 查询）

1. **Q186544 = 夏启**：label "启"、description "夏朝君主"、英文 "Qi of Xia"、繁体别名 "夏王啟""姒啟" 均明确指向夏朝开国二代君主。
2. **Q855012 = 微子（启）**：label "微子"、description "商朝宗室，宋国始祖"。"微子启"为其 altLabel 命中路径（A3 查询以 `skos:altLabel "微子启"@zh` 命中此 QID）。
3. **两者在 Wikidata 上从未合并**：A4 查询返回空集，无 sameAs / P460 / P1889 记录。

#### 证据 B：古籍史源（historian 学识判断）

1. **夏启**（姒启）：
   - 《史记·夏本纪》："禹子启贤，天下属意焉……禹崩……天下朝启。"
   - 大禹之子，夏朝第二位君主
   - 传统纪年约前 2070 年
   - 姒姓，名启

2. **微子启**（宋微子）：
   - 《史记·宋微子世家》："微子开者，殷帝乙之首子而帝纣之庶兄也。"
   - 商纣王庶兄，名启（一作"开"，汉代避景帝刘启讳改称"开"）
   - 周武王灭商后封于宋，为宋国始祖
   - 传统纪年约前 1100 年
   - 子姓，微为封地

3. **关键区分**：
   - 两人相隔约 **1000 年**（夏朝 vs 商末周初）
   - 不同姓氏（姒 vs 子）
   - 不同世系（大禹之子 vs 帝乙之子）
   - 古籍从无混淆记录

---

### 2.3 选定判定

| 选项 | 描述 | historian 选择 |
|------|------|---------------|
| (a) | Q186544 实指夏启，微子启被误挂 → reject R6 merge | ✅ **选定** |
| (b) | Q186544 实指微子启，启被误挂 → reject R6 merge | |
| (c) | Wikidata 把两人合并为一条 → 上游 bug → reject R6 merge | |
| (d) | 其他 | |

**选定**: **(a)** — Q186544 实指夏启，微子启的 seed_mapping 指向了错误的 QID

**证据来源**:
- Wikidata SPARQL 查询 A1-A4（端点 https://query.wikidata.org/sparql，查询时间 2026-04-24T10:45:30Z UTC）
- 《史记·夏本纪》（司马迁，西汉）
- 《史记·宋微子世家》（司马迁，西汉）

**简要理由（≤3 句）**:
Q186544 的 label（"启"）、description（"夏朝君主"）和全部 10 条别名均明确指向夏启，无任何"微子"相关标记。微子启在 Wikidata 上拥有独立的 QID **Q855012**（label "微子"，description "商朝宗室，宋国始祖"）。华典 seed_mapping 将 wei-zi-qi 错挂到 Q186544 属于匹配器误判，两者在历史上相隔约 1000 年，从无混淆。

---

## 3. 后续动作（管线工程师根据判定执行）

**路径 A（已选定）**：R6 merge 不 apply，wei-zi-qi 的 seed_mapping 降级 pending_review。

具体步骤（由 pipeline-engineer 执行）：
1. **Stage 5 路径 A**：跳过 R6 MergeProposal（启 ↔ 微子启），不执行 apply_merges
2. **seed_mapping 降级**：将 wei-zi-qi → Q186544 的 seed_mapping 从 `active` 改为 `pending_review`（该映射为误判）
3. **可选修复**（建议但不阻塞 Stage 5）：创建新 seed_mapping 将 wei-zi-qi 指向正确的 **Q855012**，状态设为 `active`
4. **T-P0-029**（R6 cross-dynasty guard）建议纳入防御：同一 QID 但跨朝代 > 500 年的 merge 候选应自动降级为 pending_review，避免类似 false positive 再次发生

---

> historian 签名：historian (Claude Opus)　日期：2026-04-24

---

## 附录 A：SPARQL 查询模板

> 以下查询在 https://query.wikidata.org/ 执行。结果分析由 historian 完成。

### A1. Q186544 基本信息

```sparql
SELECT ?label ?description ?instanceOf ?instanceOfLabel
       ?dateOfBirth ?dateOfDeath ?period ?periodLabel
WHERE {
  BIND(wd:Q186544 AS ?item)
  OPTIONAL { ?item rdfs:label ?label FILTER(LANG(?label) = "zh") }
  OPTIONAL { ?item schema:description ?description FILTER(LANG(?description) = "zh") }
  OPTIONAL { ?item wdt:P31 ?instanceOf }
  OPTIONAL { ?item wdt:P569 ?dateOfBirth }
  OPTIONAL { ?item wdt:P570 ?dateOfDeath }
  OPTIONAL { ?item wdt:P2348 ?period }
  SERVICE wikibase:label { bd:serviceParam wikibase:language "zh,en" }
}
```

### A2. Q186544 所有别名（zh-Hans / zh-Hant / en）

```sparql
SELECT ?label ?altLabel ?lang
WHERE {
  BIND(wd:Q186544 AS ?item)
  {
    ?item rdfs:label ?label .
    BIND(LANG(?label) AS ?lang)
    FILTER(?lang IN ("zh", "zh-hans", "zh-hant", "en"))
  }
  UNION
  {
    ?item skos:altLabel ?altLabel .
    BIND(LANG(?altLabel) AS ?lang)
    FILTER(?lang IN ("zh", "zh-hans", "zh-hant", "en"))
  }
}
ORDER BY ?lang
```

### A3. "启"和"微子启"在 Wikidata 对应的 QID 列表

```sparql
SELECT DISTINCT ?item ?itemLabel ?itemDescription
WHERE {
  {
    ?item rdfs:label "启"@zh .
  }
  UNION
  {
    ?item skos:altLabel "启"@zh .
  }
  UNION
  {
    ?item rdfs:label "微子启"@zh .
  }
  UNION
  {
    ?item skos:altLabel "微子启"@zh .
  }
  ?item wdt:P31 wd:Q5 .  # instance of human
  SERVICE wikibase:label { bd:serviceParam wikibase:language "zh,en" }
}
ORDER BY ?item
```

### A4. Q186544 合并/重定向历史

```sparql
SELECT ?prop ?propLabel ?value ?valueLabel
WHERE {
  BIND(wd:Q186544 AS ?item)
  {
    ?item owl:sameAs ?value .
    BIND(owl:sameAs AS ?prop)
  }
  UNION
  {
    ?item wdt:P460 ?value .  # said to be the same as
    BIND(wdt:P460 AS ?prop)
  }
  UNION
  {
    ?item wdt:P1889 ?value .  # different from
    BIND(wdt:P1889 AS ?prop)
  }
  SERVICE wikibase:label { bd:serviceParam wikibase:language "zh,en" }
}
```
