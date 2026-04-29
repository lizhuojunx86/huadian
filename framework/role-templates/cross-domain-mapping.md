# Cross-Domain Mapping — Domain Expert Instantiation Cheat Sheet

> Status: **v0.1 (Sprint M Stage 1 first abstraction)**
> Date: 2026-04-29
> License: CC BY 4.0
> Source: `framework/sprint-templates/README.md` §4.1 (4 列 mapping) + `docs/methodology/01-role-design-pattern.md` §2 + Sprint M Stage 0 inventory §6

---

## 0. 这是什么

跨领域 KE 项目的"Domain Expert 角色 instantiation 速查表"。

10 个 AKE 角色中只有 Domain Expert 需要 instantiate（重命名 + 大段重写），本文件给出 **6 个领域**的具体填写建议，让案例方"读完就能动手"。

其他 9 个角色（Architect / PE / BE / FE / PM / Designer / QA / DevOps / Analyst）跨领域不需要重命名，只需改少量路径名 / 技术栈名（参见 `framework/role-templates/README.md` §4）。

---

## 1. 6 领域速查表

### 1.1 综合表

| 维度 | 古籍（华典智谱）| 佛经 | 法律 | 医疗 | 专利 | 地方志 |
|------|-------------|-----|------|------|------|--------|
| **Domain Expert 角色名** | Historian / 古籍专家 | Buddhologist / 佛学专家 | Legal Expert / 律师 | Clinical Expert / 临床医师 | Patent Attorney / 专利律师 | Local History Scholar |
| **Tag** | 【Hist】 | 【Buddhist】 | 【Lawyer】 | 【Doctor】 | 【Patent】 | 【LocalHist】 |
| **核心专长** | 古籍版本学 / 史源可信度 / 典故鉴定 | 经论分类 / 传承谱系 / 宗派判教 | 法条解释 / 判例援引 / 法域归属 | 临床指南 / 药品禁忌 / 诊断分级 | 专利分类 / 引用关系 / 权利要求解读 | 地名沿革 / 地方人物 / 物产掌故 |
| **核心 entity 类型** | 人 / 地 / 事件 / 官职 / 朝代 / 典籍 / 等 18 类 | 经 / 论 / 师 / 寺院 / 译者 / 等 | 当事方 / 法条 / 案号 / 法域 / 主审法官 / 律所 | 患者 / 诊断 / 药品 / 手术 / 症状 / 检查 | 专利号 / 发明人 / 申请人 / IPC / 引用专利 / 权利要求 | 地名 / 人物 / 事件 / 物产 / 寺观 / 学校 |
| **主要 source 类型** | ctext / wikisource / 善本 OCR | CBETA / 大正藏 / 各宗派记录 | LexisNexis / Westlaw / 中国裁判文书网 | UpToDate / 临床指南 PDF / 病例库 | USPTO / 国家知识产权局 | 地方志数据库 / 县志志书 / 文史资料 |
| **典型 NER 范畴** | 古籍 18 类 | 5-7 类（经/论/师等）| 6 类（当事方/法条等）| 6 类（患者/诊断等）| 6 类（专利号/发明人等）| 6 类（地名/人物等）|
| **典型字典文件** | dynasty-periods.yaml / disambiguation_seeds.yaml / polities.yaml | sutras-classification.yaml / lineage-master.yaml | jurisdictions.yaml / case-citations.yaml | clinical-codes.yaml / drug-mappings.yaml | patent-classification.yaml / inventor-disambig.yaml | regions.yaml / local-events.yaml |

### 1.2 来源可信度评级（domain-specific 评级体系）

每个领域的"来源可信度评级"模式相同，但具体内容不同：

| 领域 | 评级体系 |
|------|---------|
| 古籍 | 5 tier（textbook / authoritative / standard / scholarly / unverified）+ credibility_tier 字段 |
| 佛经 | 类似 5 tier，但加"宗派判教"维度（如某经在某宗派为主依，在另宗派为旁参） |
| 法律 | 案件管辖层级（最高法 / 高级法院 / etc）+ 判例约束力（binding / persuasive / informative） |
| 医疗 | GRADE 证据级别（high / moderate / low / very low）+ guideline strength（strong / weak） |
| 专利 | 专利状态（granted / pending / lapsed）+ 引用强度（X / Y / A type） |
| 地方志 | 修志年代 + 编纂主体（官修 / 私修）+ 后世引用度 |

### 1.3 反馈分诊 routing 调整

在 `qa-engineer.md` §反馈分诊流程中，跨领域案例方需要把 `factual_error` 等类型 routing 到自己的 Domain Expert：

```
原（华典智谱）：factual_error → 历史专家
法律案例：     factual_error → Lawyer
医疗案例：     factual_error → Physician
                                + 加 clinical_concern → Physician + DevOps（合规风险）
                                + 加 prescription_safety → Physician + PM（高优先 SLA）
专利案例：     factual_error → Patent Attorney
                                + 加 prior_art_dispute → Patent Attorney + Architect
```

---

## 2. 各领域 Domain Expert 文件填写示例

### 2.1 古籍（华典智谱 — 已实现，作为 reference）

参见 `.claude/agents/historian.md`（华典智谱原始版本）+ `framework/role-templates/domain-expert.md`（领域无关模板）。

**字典 example**：

```yaml
# data/dictionaries/disambiguation_seeds.yaml
- name: 韩信
  candidates:
    - person_id: han-xin-huaiyin-hou
      dynasty: 西汉
      context_hint: ["史记·淮阴侯列传", "高祖", "项羽"]
      priority: 100
```

**黄金集 example**：

```json
{
  "task": "ner",
  "raw_text": "项王军壁垓下，兵少食尽...",
  "expected_entities": [
    {"surface": "项王", "type": "person", "entity_id": "xiang-yu"}
  ]
}
```

### 2.2 佛经案例

**核心职责调整**：

- 经论分类（律 / 经 / 论 三藏 + 宗派判教）
- 译者考证（鸠摩罗什 / 玄奘 / 等）
- 异译本比对（同经多译本，哪个为标准底本）
- 传承谱系（祖师 / 弟子 / 法脉）

**字典 example**：

```yaml
# data/dictionaries/lineage-master.yaml
- master: 慧能
  candidates:
    - person_id: huineng-chan-6
      sect: 禅宗
      lineage: 6th patriarch
      context_hint: ["坛经", "弘忍", "曹溪"]
      priority: 100
```

**黄金集 example**：

```json
{
  "task": "ner",
  "raw_text": "时大师告众曰：善知识，菩提自性，本来清净...",
  "expected_entities": [
    {"surface": "大师", "type": "person", "entity_id": "huineng-chan-6"},
    {"surface": "菩提自性", "type": "concept", "entity_id": "bodhi-nature"}
  ]
}
```

### 2.3 法律案例

**核心职责调整**：

- 当事方歧义仲裁（同名公司 / 异名同方）
- 法条引用核对（旧法 vs 新法 / 已废止条款）
- 法域归属判定（联邦 / 州 / 跨境 / 普通法 vs 大陆法）
- 判例援引强度评估（binding precedent / persuasive / informative）

**字典 example**：

```yaml
# data/dictionaries/case-citations.yaml
- citation: "Marbury v. Madison"
  candidates:
    - case_id: marbury-v-madison-1803
      jurisdiction: SCOTUS
      year: 1803
      legal_issue: judicial_review
      precedent_strength: binding
```

**黄金集 example**：

```json
{
  "task": "ner",
  "raw_text": "原告主张依《合同法》第52条，本案合同因违反公序良俗应属无效...",
  "expected_entities": [
    {"surface": "原告", "type": "party", "role": "plaintiff"},
    {"surface": "《合同法》第52条", "type": "statute", "entity_id": "contract-law-52"},
    {"surface": "公序良俗", "type": "legal_concept", "entity_id": "public-policy-cn"}
  ]
}
```

**特别说明**：法律领域 LLM cost 通常是古籍的 5-10x（context 长 / token 多），sprint cost 阈值要相应调高。

### 2.4 医疗案例

**核心职责调整**：

- 患者去标识化（PHI 必须脱敏）
- 诊断 ICD-10 / SNOMED 映射
- 药品 ATC / RxNorm 映射 + 禁忌检查
- 临床指南证据级别（GRADE）评级
- 处方安全（drug-drug interaction / dose）

**字典 example**：

```yaml
# data/dictionaries/drug-mappings.yaml
- name: 阿司匹林
  candidates:
    - drug_id: aspirin-acetylsalicylic
      atc_code: B01AC06
      rxnorm_id: 1191
      contraindications: ["pregnancy_3rd_trimester", "active_bleeding"]
      common_dose_range: "75-100mg/day for cardio prophylaxis"
```

**黄金集 example**：

```json
{
  "task": "ner",
  "raw_text": "患者，男，65 岁，主因阵发性胸痛 3 天入院。既往高血压病史 10 年...",
  "expected_entities": [
    {"surface": "胸痛", "type": "symptom", "entity_id": "chest-pain"},
    {"surface": "高血压", "type": "diagnosis", "entity_id": "hypertension-icd10-i10"}
  ]
}
```

**特别说明**：医疗领域必须遵守 HIPAA / GDPR 等隐私监管。所有黄金集 / 字典中的患者信息必须是合成或经患者授权的真实数据。审计 trail 保留期通常 7 年（HIPAA）。

### 2.5 专利案例

**核心职责调整**：

- 专利分类（IPC / CPC 多级映射）
- 引用关系类型（X / Y / A 引用强度）
- 权利要求解读（独立权利要求 vs 从属权利要求）
- 现有技术（prior art）评估

**字典 example**：

```yaml
# data/dictionaries/inventor-disambig.yaml
- name: "Smith, John"
  candidates:
    - inventor_id: john-smith-ibm-1990s
      company: IBM
      patent_count: 12
      tech_field: computer_architecture
      patent_years: [1992, 1995, 1998]
      priority: 100
```

**黄金集 example**：

```json
{
  "task": "ner",
  "raw_text": "本发明涉及一种基于神经网络的图像识别方法，特别是涉及卷积神经网络...",
  "expected_entities": [
    {"surface": "神经网络", "type": "tech_concept", "entity_id": "neural-network"},
    {"surface": "图像识别", "type": "application_field", "entity_id": "image-recognition"}
  ]
}
```

### 2.6 地方志案例

**核心职责调整**：

- 地名沿革考证（古今地名变迁 / 行政区划调整）
- 地方人物考辨（同名异人 / 异名同人 — 类似古籍）
- 物产掌故核证（特产真伪 / 物产分布）
- 修志年代 + 编纂主体可信度评估

**字典 example**：

```yaml
# data/dictionaries/regions.yaml
- name: 长安
  candidates:
    - region_id: chang-an-tang
      modern_equivalent: 西安市
      dynasty: 唐
      coordinates: [108.97, 34.27]
      context_hint: ["京师", "西京"]
      priority: 100
    - region_id: chang-an-han
      modern_equivalent: 西安市汉长安城遗址
      dynasty: 西汉
      coordinates: [108.84, 34.32]
      priority: 90
```

---

## 3. 跨领域 instantiation 通用注意事项

### 3.1 监管与合规

| 领域 | 监管要求 |
|------|---------|
| 古籍 | 版权（古籍 PD 居多 / 当代标点本可能有版权）|
| 佛经 | 版权（部分宗派对译本有保留）|
| 法律 | 判决书隐私脱敏（PIPL / GDPR / 各司法辖区不同）|
| 医疗 | HIPAA（美）/ GDPR（欧）/ PIPL（中）/ PHI 严格脱敏 / 审计 7 年留存 |
| 专利 | 公开后无隐私问题；但商业秘密敏感案件需特殊处理 |
| 地方志 | 当代条目可能涉及在世人物 → 隐私脱敏 |

### 3.2 LLM cost 量级

| 领域 | 单 sprint 典型 cost 量级 |
|------|----------------------|
| 古籍 | $0.5-2 / sprint（章节级 ingest）|
| 佛经 | $1-3 / sprint（经论较长）|
| 法律 | $5-20 / sprint（判决书冗长）|
| 医疗 | $3-15 / sprint（病例 + 指南交叉）|
| 专利 | $5-25 / sprint（权利要求 + 说明书 + 引用）|
| 地方志 | $1-3 / sprint（章节级）|

→ Stop Rule 阈值（参见 `framework/sprint-templates/stop-rules-catalog.md` §1 cost 类）必须按领域调整。

### 3.3 黄金集规模

| 领域 | 黄金集典型规模 |
|------|-------------|
| 古籍 | 50-200 段 / 任务 |
| 佛经 | 同古籍 |
| 法律 | 100-500 案例 / 任务（cost 高）|
| 医疗 | 200-1000 病例 / 任务（合成数据为主）|
| 专利 | 100-300 专利 / 任务 |
| 地方志 | 同古籍 |

---

## 4. 添加新领域到本表（贡献指南）

如果你用 `framework/role-templates/` 启动了一个**本表未覆盖的领域**（如金融文档 / 学术论文 / 代码 corpus / 政策文件 / etc），欢迎：

1. 在 `.claude/agents/` 下做完你的 Domain Expert instantiation
2. 把你的新领域行加到 §1 综合表 + 写一段 §2 填写示例
3. 提 GitHub PR 标 `cross-domain-contribution`

期望随贡献增加，本表覆盖 ≥ 10 领域。

---

## 5. 版本信息

| Version | Date | Source | Change |
|---------|------|--------|--------|
| v0.1 | 2026-04-29 | Sprint M Stage 1 (first abstraction) | 初版抽出（6 领域 mapping）|

---

> 本文件是 AKE 框架 Layer 1 跨领域迁移工具的核心。
> 与 `framework/role-templates/domain-expert.md` 配合使用。
