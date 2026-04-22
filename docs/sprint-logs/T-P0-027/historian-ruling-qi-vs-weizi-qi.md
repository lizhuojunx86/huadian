# Historian 判定卡 — 启(qi) vs 微子启(wei-zi-qi) / Wikidata Q186544

> **状态**: 待 historian 填写
> **请求方**: 管线工程师（T-P0-027 Stage 4）
> **裁决依据**: CLAUDE.md §4 古籍专家"实体歧义仲裁"

---

## 1. 背景

Sprint C R6 merge detection 发现：
- **启**（slug: qi，华典 person）和 **微子启**（slug: wei-zi-qi，华典 person）
- 两者均 active seed_mapping → Wikidata **Q186544**
- R6 规则产生 MergeProposal(confidence=1.0)

管线工程师初步判断为 false positive（夏朝 vs 商朝，跨 ~1000 年）。

## 2. 请求 historian 复核

### 2.1 Wikidata Q186544 当前状态

> （请 historian 用 SPARQL 直查以下字段，填入结果）

| 字段 | 值 |
|------|-----|
| rdfs:label @zh | |
| schema:description @zh | |
| wdt:P569 (dateOfBirth) | |
| wdt:P570 (dateOfDeath) | |
| wdt:P31 (instance of) | |
| wdt:P27 (country of citizenship) | |

### 2.2 判定选项

| 选项 | 描述 | historian 选择 |
|------|------|---------------|
| (a) | Q186544 实指夏启，微子启被误挂 → reject R6 merge | |
| (b) | Q186544 实指微子启，启被误挂 → reject R6 merge | |
| (c) | Wikidata 把两人合并为一条 → 上游 bug → reject R6 merge | |
| (d) | 其他 | |

### 2.3 选定判定

> （historian 填写）

**选定**: __(a)/(b)/(c)/(d)__

**证据来源**:

**简要理由（≤3 句）**:

---

## 3. 后续动作（管线工程师根据判定执行）

- (a)/(b)/(c) → 路径 A：R6 merge 不 apply，seed_mappings 降级 pending_review
- (d) → 视具体情况决定

---

> historian 签名：__________ 日期：__________

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
