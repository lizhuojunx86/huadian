# Cross-Domain Mapping — R1-R6 Adaptation Cheat Sheet

> Status: v0.1 (Sprint N Stage 1)
> Source: `framework/role-templates/cross-domain-mapping.md` 同款 6 领域 + R1-R6 适配建议

---

## 0. 这是什么

跨领域 KE 项目的"R1-R6 instantiation 速查表"。给定 6 个常见领域（古籍 / 佛经 / 法律 / 医疗 / 专利 / 地方志），每个 R 规则在该领域怎么用、需要什么字典 / guards / adapter。

读完本文件你应该能回答："如果我做一个 X 领域 KE 项目，R1-R6 分别该怎么填？"

---

## 1. 6 领域 R1-R6 适配总表

### 1.1 R1 surface match（confidence 0.95）

通用机制：两实体 surface_forms 重叠 → 匹配。

| 领域 | EntitySnapshot.name | surface_forms 来源 | R1 stop words 例 |
|------|---------------------|-------------------|-----------------|
| 古籍（华典）| "刘邦" | person_names 表 | 王 / 帝 / 后 / 朕 / 武王 |
| 佛经 | "鸠摩罗什" | translator_aliases 表 | 法师 / 三藏 / 大师 |
| 法律 | "Brown v. Board of Education" | case_aliases 表 | the / case / matter |
| 医疗 | "acetaminophen" | drug_synonyms 表 | drug / medication |
| 专利 | "John Smith" | inventor_name_variants 表 | Inc. / Co. / Ltd. |
| 地方志 | "长安" | place_aliases 表 | 县 / 府 / 州 |

### 1.2 R2 prefix-honorific（HuaDian-specific / 案例方一般不用）

R2 是华典专属（"帝X" 前缀模式）。其他案例方一般**不启用** R2。

如果你的领域有类似的"前缀名→正名"模式（如医疗 "Dr. Smith" / "Sir John"），可参考 `examples/huadian_classics/r2_di_prefix_rule.py` 写自己的 custom rule，通过 `ScorePairContext.custom_rules` opt-in。

### 1.3 R3 synonym normalization（confidence 0.90）

通用机制：用 dict[variant, canonical] 做字符 / 词归一。

| 领域 | 字典文件 | 字典内容例 |
|------|---------|----------|
| 古籍（华典）| tongjia.yaml（异体字 / 通假字）| 倕→垂 / 啟→启 |
| 佛经 | sutra-translit-variants.yaml | 觀→观 / 譯→译 |
| 法律 | citation-style-variants.yaml | "U.S." → "United States" / "F.2d" → "Federal Reporter" |
| 医疗 | drug-name-variants.yaml | "Tylenol" → "acetaminophen" / "ASA" → "aspirin" |
| 专利 | patent-class-variants.yaml | "G06F" → "G06F (Computing)" / IPC sub-class normalization |
| 地方志 | place-name-variants.yaml | "京兆" → "长安" / "建康" → "南京" |

### 1.4 R4 identity_notes cross-reference（confidence 0.65）

通用机制：regex 提取 free-text 中对其他实体的引用。**仅生成 hypothesis（人工 review）**。

| 领域 | 典型 patterns（regex 概念）|
|------|-------------------------|
| 古籍（华典）| `与X同人` / `即X` / `X又名Y` / `或即X` / `一说为X` |
| 佛经 | `X即Y` / `X又称Y` / `本名X` |
| 法律 | `also known as X` / `formerly X` / `see also X` / `cited as X` |
| 医疗 | `aka X` / `brand name X` / `formerly X` |
| 专利 | `assigned from X` / `continuation of X` / `divisional of X` |
| 地方志 | `古名X` / `今X` / `又名X` |

### 1.5 R5 bidirectional alias dict（confidence 0.90）

通用机制：双向 dict[(name_a, name_b), entry] 查询。

| 领域 | 字典文件 | 例 |
|------|---------|-----|
| 古籍（华典）| miaohao.yaml（庙号 / 谥号）| ("汉高祖", "刘邦") + ("刘邦", "汉高祖") → entry |
| 佛经 | dharma-name-pairs.yaml | ("弘忍", "五祖") + reverse |
| 法律 | case-name-pairs.yaml | ("Roe v. Wade", "Roe et al. v. Wade") + reverse |
| 医疗 | drug-equivalence-pairs.yaml | ("acetaminophen", "paracetamol") + reverse |
| 专利 | inventor-aliases.yaml | ("John Smith", "J. Smith") + reverse |
| 地方志 | place-equivalence-pairs.yaml | ("洛阳", "雒阳") + reverse |

### 1.6 R6 external authority anchor（confidence 1.00）

通用机制：用外部权威 ID 锚定实体。每个外部 ID 对应一个真实世界实体。

| 领域 | 权威源 | 字段值例 |
|------|------|---------|
| 古籍（华典）| Wikidata | Q9192（孔子）|
| 佛经 | CBETA / 大正藏 | T0235（金刚经）|
| 法律 | LexisNexis / Westlaw / 中国裁判文书网 | "410 U.S. 113"（Roe v. Wade）|
| 医疗 | RxNorm CUI / ATC code / SNOMED CT | "C0039237"（acetaminophen RxNorm）|
| 专利 | USPTO patent number / EPO publication number | "US4,567,890" |
| 地方志 | GeoNames / 中国行政区划代码 | "1810821"（长安区 GeoNames）|

---

## 2. Guard Chain 适配速查

每个领域典型的 guards：

### 2.1 古籍（华典）

```python
HUADIAN_GUARD_CHAINS = {
    "R1": [cross_dynasty_guard(200yr), state_prefix_guard],
    "R6": [cross_dynasty_guard(500yr)],
}
```

### 2.2 佛经案例

```python
BUDDHIST_GUARD_CHAINS = {
    "R1": [
        cross_era_guard(300yr),         # 跨朝代
        cross_school_guard,             # 不同宗派（禅宗 vs 净土）
    ],
    "R6": [cross_era_guard(800yr)],
}
```

### 2.3 法律案例

```python
LEGAL_GUARD_CHAINS = {
    "R1": [
        cross_jurisdiction_guard,       # 不同 jurisdiction
        cross_court_level_guard,        # 不同法院级别
    ],
    "R6": [cross_jurisdiction_guard],
}
```

### 2.4 医疗案例

```python
MEDICAL_GUARD_CHAINS = {
    "R1": [
        cross_atc_class_guard,          # 不同药物类别
        cross_dosage_form_guard,        # 不同剂型
    ],
    "R6": [],  # RxNorm CUI 已是权威，无需 guard
}
```

### 2.5 专利案例

```python
PATENT_GUARD_CHAINS = {
    "R1": [
        cross_classification_guard,     # 不同 IPC class
        cross_filing_year_guard(20yr),  # 跨年代过远
    ],
    "R6": [cross_classification_guard],
}
```

### 2.6 地方志案例

```python
LOCAL_HISTORY_GUARD_CHAINS = {
    "R1": [
        cross_dynasty_guard(300yr),     # 同名地点跨朝代
        cross_region_guard,             # 不同行政区
    ],
    "R6": [cross_dynasty_guard(500yr)],
}
```

---

## 3. EntitySnapshot.domain_attrs 适配速查

| 领域 | 关键 domain_attrs keys | `cross_dynasty_attr` 应填 |
|------|----------------------|---------------------------|
| 古籍（华典）| dynasty / state | `"dynasty"` |
| 佛经 | era / school / sect | `"era"` |
| 法律 | jurisdiction / court_level / filing_year | `"jurisdiction"` |
| 医疗 | atc_class / dosage_form / drug_class | `"atc_class"` |
| 专利 | ipc_class / filing_year / cpc_class | `"ipc_class"` |
| 地方志 | dynasty / region / administrative_level | `"region"` |

---

## 4. CanonicalHint 适配速查

每个领域的 canonical 选择 demotion 模式：

| 领域 | demotion 模式 | 例 |
|------|------------|-----|
| 古籍（华典）| 帝X 有 bare-name peer 时 demote | "帝尧" demoted vs "尧" |
| 佛经 | "X法师" 有 "X" peer 时 demote | "鸠摩罗什法师" demoted vs "鸠摩罗什" |
| 法律 | "X et al." 有 lead party peer 时 demote | "Brown et al." demoted vs "Brown" |
| 医疗 | brand name 有 generic name peer 时 demote | "Tylenol" demoted vs "acetaminophen" |
| 专利 | reissued patent 有原 patent peer 时 demote | "RE34,xxx" demoted vs original |
| 地方志 | 古名 有 today's name peer 时 demote | "京兆" demoted vs "长安" |

---

## 5. 完整 instantiation example — 法律案例

假设你做一个判例 KE 项目。完整步骤：

### 5.1 创建 `examples/legal/` 目录

```
framework/identity_resolver/examples/legal/
  __init__.py
  case_loader.py              # EntityLoader for case_law table
  citation_variants_loader.py # DictionaryLoader (R3 + R5)
  legal_stop_words.py         # StopWordPlugin
  legal_notes_patterns.py     # IdentityNotesPatterns (also known as / cited as / etc)
  jurisdiction_guard.py       # cross_jurisdiction_guard
  court_level_guard.py        # cross_court_level_guard
  guard_chains.py             # LEGAL_GUARD_CHAINS
  lexis_seed_adapter.py       # SeedMatchAdapter for LexisNexis IDs
  case_merge_applier.py       # MergeApplier for legal DB
  reason_builder_en.py        # English ReasonBuilder
```

### 5.2 EntitySnapshot 映射

```python
EntitySnapshot(
    id="case-uuid-or-citation",
    name="Brown v. Board of Education",
    slug="brown-v-board",
    surface_forms={"Brown v. Board", "Brown v. Board of Ed.", "347 U.S. 483"},
    created_at="1954-05-17T00:00:00Z",
    domain_attrs={
        "jurisdiction": "SCOTUS",
        "court_level": "supreme",
        "filing_year": "1954",
        "topic_area": "civil_rights",
    },
    identity_notes=["overruled Plessy v. Ferguson"],
)
```

### 5.3 跑

```python
from framework.identity_resolver import build_score_pair_context, resolve_identities
from .examples.legal import (
    CaseLoader, CitationVariantsLoader, LegalStopWords, LegalNotesPatterns,
    LEGAL_GUARD_CHAINS, LexisSeedAdapter, ReasonBuilderEn,
)

ctx = build_score_pair_context(
    dictionary_loader=CitationVariantsLoader(),
    stop_word_plugin=LegalStopWords(),
    notes_patterns_plugin=LegalNotesPatterns(),
    cross_dynasty_attr="jurisdiction",
)

result = await resolve_identities(
    loader=CaseLoader(pool),
    score_context=ctx,
    guard_chains=LEGAL_GUARD_CHAINS,
    r6_prepass=LexisR6PrePassRunner(pool),
    reason_builder=ReasonBuilderEn(),
)
```

→ 完整 instantiation < 200 行 plugin 代码 / framework 0 修改。

---

## 6. 添加新领域到本表（贡献指南）

如果你用 `framework/identity_resolver/` 启动了一个**本表未覆盖的领域**（如金融文档 / 学术论文 / 代码 corpus / etc），欢迎：

1. 在 `examples/` 下做完你的 instantiation
2. 把你的新领域行加到 §1-§4 表
3. 在 §5 加完整 instantiation example
4. 提 GitHub PR 标 `cross-domain-contribution`

期望随贡献增加，本表覆盖 ≥ 10 领域。

---

## 7. 修订历史

| Version | Date | Change |
|---------|------|--------|
| v0.1 | 2026-04-30 | 初版（Sprint N Stage 1）/ 6 领域 R1-R6 mapping |

---

> 本文件继承 `framework/role-templates/cross-domain-mapping.md` 同款 6 领域结构，但聚焦 R1-R6 适配（vs role-templates 聚焦 Domain Expert 角色定义）。两文档配合使用。
