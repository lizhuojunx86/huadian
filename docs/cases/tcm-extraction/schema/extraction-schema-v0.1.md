# 提取案例 OCR Schema 锁定文档 v0.1

> Status: **v0.1 — Stage 2 产出 / Pilot 通过后第一次 schema lock**
> Date: 2026-05-08
> Owner: 首席架构师
> 输入：Pilot 16 页抽取经验（pp.1-13, 20-22 of P1 B1）
> 输出：后续所有 OCR 工作（剩余 84 页 + 5 批 + 7 批 Q + 跨产品扩展）的统一规范

---

## 0. 为什么要 lock schema

Pilot 阶段是"边读边发现 schema"，每页都可能新增字段或新页面类型。一旦进入全量 OCR：

- 没有 lock 的 schema → 跨页/跨批的字段名不一致 → 跨批比对失败 → 案例命题无法验证
- 有 lock 的 schema → 每页 OCR 输出可机械验证 → 不一致即报警 → 跨批比对自动化

本文档**冻结**所有字段命名、页面类型、抽取规则。任何新发现都走 v0.2 升级，不在 v0.1 内默默改变。

---

## 1. 页面类型 Taxonomy v0.1

8 类，覆盖 Pilot 16 页的全部形态。后续遇到不在清单的页型，新增 P09+。

| ID | 页面类型 | 已见样本 | 主要抽取目标 | 手写密度 |
|----|---------|---------|-------------|---------|
| **P01** | 封面 / 扉页 | p.1 | 产品名、批号、规格、批量、生产日期范围 | 低（5-10 字段） |
| **P02** | 领料单 | p.2, 22 | items[]：物料代码、名称、数量、批号、供应商、厂家批号 | 中（每行 1-2 手写字段） |
| **P03** | 批生产指令 | p.3 | 指令编号、items[]、签名（指令/审核/批准/接收）| 中-高 |
| **P04** | 岗位生产记录 — 表头 + 投料 | p.4, 7 | 操作间编号、设备勾选、4 等份/多份投料量 | 高 |
| **P05** | 岗位生产记录 — 工艺参数 | p.8, 9, 12, 13 | 罐次/批次的加溶液量+温度+提取时间+打药液时间+除渣时间；浓缩温度+真空度时序 | 极高 |
| **P06** | 岗位生产记录 — 收尾 + 收率 | p.10, 20 | 浸膏重量、收率、规范区间、判定 in_spec、设备、签名 | 高 |
| **P07** | 清场合格证 | p.6, 11, 21 | records[]：3 张卡片（前正/前副/后正）、清场者、检查者、操作间 | 中 |
| **P08** | 清场页（与岗位记录合页） | p.5 | 清场起止时间、QA 签名、合格判定 | 低-中 |

待发现页型（猜测）：
- **P09** 检验记录（入厂/中间体/成品）— 推测在 pp.23-70
- **P10** 偏差/退料/退库单 — 推测在 pp.40-90
- **P11** 签名汇总页 / 工艺员审核页 — 推测在尾部
- **P12** 跨工序衔接页（递交/接收）— 已在 p.20 嵌入，可能也作独立页存在

---

## 2. JSON Schema v0.1（顶层结构 + 字段命名规范）

### 2.1 命名约定

- **顶层 sections** 使用 `english_中文` 双语命名：可读性 + grep 友好性兼顾
  - `materials_領料`, `weighing_称量记录`, `extraction_提取操作记录`, `concentration_浓缩操作记录`, `operations_工序操作记录`, `cleanings_清场`, `deviations_偏差`, `qc_checks_检验`
- **section 内字段** 优先中文（与原始记录一致）：`物料批号`, `加溶液量_kg`, `提取时间_h`, `操作间编号`
- **数值字段** 统一加单位后缀 `_kg`, `_h`, `_C`, `_min`, `_pct`, `_MPa`
- **布尔字段** 形如 `_in_spec`, `_partial`, `_选用`
- **派生/计算字段** 加前缀 `_`（下划线）：`_critical_findings`, `_observations`, `_anomaly_candidate`
- **OCR 元数据** 加前缀 `_source_`：`_source_page`, `_source_form_id`

### 2.2 顶层结构

```jsonc
{
  "_meta": {
    "schema_version": "0.1",            // ← 必须
    "extraction_date": "ISO8601",
    "extraction_method": "Claude Vision (Anthropic) end-to-end structured extraction",
    "source_file": "string",
    "source_pages_total": int,
    "extraction_status": "in_progress" | "complete" | "needs_review",
    "pages_extracted": int[],
    "pages_pending": "string (range)",
    "anomalies_found": Anomaly[],
    "open_questions": string[]
  },

  "batch_header": BatchHeader,            // ← P01 抽取

  "materials_領料": LingliaoForm[],       // ← P02 抽取（多张）
  "production_instructions_提取批指令": Instruction[],  // ← P03 抽取
  "weighing_称量记录": WeighingForm[],    // ← P04 + P08 抽取
  "extraction_提取操作记录": ExtractionForm[],   // ← P04 + P05 抽取
  "concentration_浓缩操作记录": ConcentrationForm[],  // ← P05 抽取
  "operations_工序操作记录": GeneralOperationForm[],  // ← P06 抽取（收膏等）
  "cleanings_清场": CleaningRecord[],     // ← P07 抽取（多张）
  "cleanings_清场_附加": CleaningRecord[],  // ← P07 抽取（更多张）
  "deviations_偏差": Deviation[],         // ← P10 抽取
  "qc_checks_检验": QCRecord[],           // ← P09 抽取
  "signatures_log_签名日志": SignatureEntry[]  // ← 跨页汇总
}
```

### 2.3 关键 type 定义

#### `BatchHeader` (来自 P01)

```jsonc
{
  "product_name": string,            // 必须 — 手写：是
  "product_code": string,            // 必须 — 印刷：是
  "batch_id": string,                // 必须 — 手写：是 (如 "B1")
  "stage": "前处理提取" | "固体制剂",   // 必须
  "specification": string,           // 必须 — 手写
  "package_specification": string | null,  // 可选
  "batch_size": string,              // 必须 — 手写 (如 "162万粒")
  "production_date_start": "YYYY-MM-DD",
  "production_date_end": "YYYY-MM-DD",
  "company": string,                 // 印刷
  "_source_page": int,
  "_handwritten_fields": string[]
}
```

#### `LingliaoForm` (来自 P02)

```jsonc
{
  "_source_page": int,
  "form_id": string,                 // "TY-SMP-SC-J016-003-3-(01)"
  "form_name": string,               // "领料单"
  "領料日期": "YYYY-MM-DD",
  "包装规格": string,
  "items": [
    {
      "代码": string,
      "名称": string,
      "数量_kg": float,
      "物料批号": string,
      "_lot_age": "current" | "previous" | null  // 跨 lot 领料模式标记
    }
  ],
  "签名": {
    "车间核算员": string,
    "车间主任": string,
    "仓库保管员": string
  },
  "_pattern_observed": string | null,   // 跨 lot 领料等行为观察
  "_anomaly_candidate": Anomaly | null
}
```

#### `Anomaly`

```jsonc
{
  "id": "A-NNN",
  "page": int,
  "type": string,
  "expected_kg"?: float,
  "actual_kg"?: float,
  "ratio"?: float,
  "user_explanation_general": string,
  "user_explanation_for_this_case": string | "未确认",
  "follow_up": string,
  "extra_clue": string | null,
  "status": "open" | "investigating" | "resolved" | "false_positive"
}
```

#### `ExtractionForm` (来自 P04 + P05 — 提取工序最复杂)

```jsonc
{
  "_source_page": int | "range",
  "form_id": string,
  "form_name": string,
  "操作间编号": string,
  "生产日期_范围": "ISO8601 - ISO8601",
  "生产时长_h": float,
  "生产用设备_可选": [
    {"设备": string, "编号": string, "选用": boolean, "_note"?: string}
  ],
  "岗位操作法_批记录_补全SOP": object,    // ← KEY: 抓取批记录里印刷的 SOP 文字
                                          //         规程未明文但 SOP 限定的参数都在这
  "水提_4等份投料"?: BatchPortion[],      // 白芍/延胡索/茯苓 4 等份
  "甘草投料_2份"?: BatchPortion[],         // 甘草分组
  "罐次数据"?: ExtractionRunData[],        // 每罐次详细参数
  "甘草投料_组N_设备编号"?: GanBatchData,  // 甘草特殊处理
  "甘草料液比验证"?: object,
  "_other_observations"?: object,
  "_critical_findings"?: string[]
}
```

#### `ExtractionRunData` (单罐次的提取参数)

```jsonc
{
  "罐": string,                      // 设备编号
  "批次": int,
  "一次": {
    "加溶液量_kg": float,
    "温度_C": int,
    "提取时间_h": float,
    "起止": "DD日 HH:MM - HH:MM",
    "打药液时间_h": float,
    "打药液起止": "DD日 HH:MM - HH:MM"
  },
  "二次": SimilarStructure,
  "除渣时间_h": float,
  "除渣起止": "DD日 HH:MM - HH:MM",
  "_partial"?: boolean
}
```

#### `ConcentrationForm` (来自 P05 — 浓缩工序)

```jsonc
{
  "_source_page": "range",
  "form_id": string,
  "form_name": string,
  "操作间编号": string,
  "生产日期_范围": "ISO8601 - ISO8601",
  "生产时长_h": float,
  "生产用设备": [{设备, 编号, 选用}],
  "岗位操作法_批记录": {
    "操作描述": string,
    "E1_参数": {"真空度_MPa": "区间", "温度_C": "区间"},
    "E3_一效"?: object,
    "E3_二效"?: object,
    "终点": string
  },
  "E1_浓缩观察记录_概要"?: TimeSeriesSummary,  // ← 32 小时压缩成 summary
  "E1_浓缩观察记录_完整"?: TimeSeriesEntry[],   // ← 可选：完整逐小时（仅在 cross-batch 比对需要时填充）
  "E3_一效记录_部分"?: TimeSeriesSummary
}
```

#### `TimeSeriesSummary` (高频时序数据的标准压缩格式)

```jsonc
{
  "记录密度": "每小时 1 次" | "每 10 分钟 1 次" | etc,
  "记录条数": int,
  "时间范围": "DD日 HH:MM 至 DD日 HH:MM",
  "温度区间_C": "min-max",
  "真空度区间_MPa"?: "min-max",
  "_in_spec": boolean,
  "_pattern": string,                // "起始 78℃ → 渐升至 80℃ → 渐降至 78℃"
  "_observation": string             // 自由文本
}
```

`TimeSeriesSummary` 是 v0.1 的关键设计决策：**默认只记 summary，逐点数据按需展开**。32 小时浓缩 = 32 行数据，6 批 = 192 行；如果每行都展开，JSON 会迅速膨胀且失去对比价值。Summary 形式保留可比性同时控制规模。

跨批比对若需要逐点数据（比如对比 6 批的温度曲线形态），再按需要从原 PDF 重新抽 `TimeSeriesEntry[]`。

---

## 3. 抽取 Prompt 模板

下面这段是在 Pilot 期间内化为我做 OCR 时遵循的规则集。后续 session、其他批次、跨产品扩展时复用同样规则即可。

```
你是中药制造批生产记录解析专家。任务：从扫描 PDF 页面中抽取结构化数据。

输入：单页或多页扫描图（400 DPI / 中文 / 印刷模板 + 手写填值）
输出：符合 Schema v0.1 的 JSON 片段（仅本页/本组涉及的 sections）

抽取规则：
1. 印刷文字：直接抄录，含字段标签和印刷数据值（如规格、批量、料液比公式）
2. 手写数值：精确读取，标 _handwritten 标记；模糊处用 null + _note
3. 手写签名：识别"哪些岗位签了字"+"是否相同笔迹"；姓名清晰则记录，不清晰记 "(签名)"
4. 表格：按行抽取，保持原始顺序与列对应
5. 勾选框（☑/☐）：作为 boolean 处理；注意"未勾选≠未使用"，需结合后续页交叉验证
6. 时间戳：统一 ISO8601 风格（"DD日 HH:MM" 在跨日工序中可保留原格式）
7. 数值单位：统一加 _kg / _h / _C / _MPa / _pct 后缀
8. 异常自由文本（备注/偏差/补充）：完整保留，作为 _observations[] 或 anomaly_candidate
9. 可疑跨页关联（如 part 1 of 4）：标 _partial: true，明确指向继续页

判定规则：
- 关键字段（数量/温度/时长/批号/物料代码）必须 ≥ 95% 准确率
- 出现规程参数 vs 实际数据偏差 > 5% 即记为 anomaly_candidate
- 出现规程未明文但 SOP 限定的参数即记为"暗参数补全"（_pattern_observed）

禁止：
- 推断未出现的字段值
- 修正手写错别字（保留原始）
- 跳过看似无关页面（清场卡也含工序时间链）
```

---

## 4. 跨批比对数据模型

Pilot 已经识别出多个跨批可比指标。Stage 4（跨批分析）将基于此构建对比矩阵：

### 4.1 一级对比指标（每批 1 条记录）

```jsonc
{
  "batch_id": "B1",
  "product": "P1",
  "batch_size_万粒": 162,
  "投料合计_饮片_kg": 1671.51,
  "甘草料液比": 5.0001,
  "白芍延胡索茯苓料液比": 6.000,
  "提取温度_C": 100,
  "提取主设备": ["E-asset-101-01", "E-asset-101-02"],
  "甘草提取设备": ["E-asset-134", "E-asset-133"],
  "板框过滤_h": 14,
  "滤布_目": 80,
  "浓缩主设备": "E-asset-102 (E1)",
  "浓缩_h": 32,
  "浓缩温度_区间_C": "78-80",
  "浓缩真空度_区间_MPa": "-0.03 至 -0.04",
  "收率_pct": 40.27,
  "收率_in_spec": true,
  "操作主力": "操作工 L",
  "工艺员": "工艺员 G",
  "QA": "QA C",
  "异常数": 1,
  "偏差数": 0
}
```

6 批数据汇总后即可生成跨批对比表，看每个指标的：
- 极差（max - min）
- 标准差
- 是否触及规程区间边界
- 与收率/含量的相关性

### 4.2 二级对比（按工序展开 — 可选）

每工序展开为时间序列，计算工序时长、相邻工序衔接间隔、操作工切换次数等。

---

## 5. 与 huadian 框架元素的对应

| huadian 元素 | 本案例对应 | Schema 中表现 |
|------------|----------|--------------|
| identity_resolver R1-R6 | 物料识别（同饮片不同批） | `LingliaoForm.items[].代码 + 物料批号` 联合 key |
| invariants V1-V11 | 提取工序量化参数约束 | `ExtractionForm.甘草料液比验证` 等 _validation 字段 |
| audit_triage | anomaly 处理流程 | `Anomaly.status` 状态机 + follow_up 字段 |
| sprint-templates | 案例分阶段推进 | 每 stage 一个 markdown + JSON 增量 |
| role-templates | 制药领域专家 / OCR 工程师 / 后端 / QA | 暂为 Claude + 用户合作；将来可拆角色 |

---

## 6. v0.2 升级触发条件

下列情况之一触发 schema v0.2：

1. 出现 P09+ 新页型（检验记录、偏差报告、退料单等）
2. 跨批扩展时发现 v0.1 字段缺失或语义混淆
3. 跨产品扩展（参乌、P2）时发现工艺差异大于 v0.1 可表达范围（如：参乌的醇提/醇沉/超临界 CO2 萃取需要新 sections）
4. 用户在 invariants 访谈中提出 v0.1 未覆盖的"暗参数"维度

每次 v0.2 升级必须：保持向前兼容（v0.1 数据不需重抽）、写 migration note、登记 ADR。

---

## 7. 锁定声明

**本 v0.1 schema 自 2026-05-08 起 lock**。所有后续 OCR 工作（P1 B1 剩余 84 页 + 5 批 T + 7 批 Q + 跨产品扩展）按本 schema 输出。

任何对 schema 的偏离视为 bug 或 v0.2 候选。

---

> 本文档由 Claude（首席架构师）在 Pilot 通过后立即起草，作为案例的"工程地基"。
> 文件位置：`huadian/docs/cases/tcm-extraction/schema/extraction-schema-v0.1.md`
