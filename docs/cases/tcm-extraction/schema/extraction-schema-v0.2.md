# 提取案例 OCR Schema 锁定文档 v0.2

> Status: **v0.2 — 增量升级 / 完全向前兼容 v0.1**
> Date: 2026-05-10
> Owner: 首席架构师
> 触发：A-002（厂家批号制度性空白）+ A-003（主成分 vs 微量成分子通道形态不同 / 升 F-003 候选）
> 关联 ADR：ADR-033-schema-v0.2-incoming-qc-subchannels.md
> 输入：lot-L1 7 物料来料检验主页 OCR 横向比对（21 页，21 维上限指标 + 12 维下限指标）
> 输出：incoming_qc_来料检验 顶层 section 正式 schema + 双通道指标子通道字段 + 物料分类标记

---

## 0. 与 v0.1 的关系

**完全向前兼容**：
- v0.1 的所有 sections（`batch_header`, `materials_領料`, `extraction_提取操作记录`, ...）字段定义不变
- v0.1 数据**无需重抽**
- v0.2 仅**新增**字段与 sections，不修改既有字段
- 已有的 `_F-001_F-002_indicators_v0.3` 字段（在 batch-record.json 中事后追加）现正式纳入 schema

**新增内容**：
1. `incoming_qc_来料检验[]` 顶层 section 正式 schema（v0.1 时尚未有此 section / 后由 inventory-v0.1 + batch-record 临时定义）
2. 下限指标 `_subchannel` 字段（main_component / extract / minor_component）— A-003 触发
3. `_物料分类_v2` 字段 — 区分饮片 / 中药材 / 中间体 / 动物源 / 辅料 / 包材
4. `_layer_classification_v2` 取值清单标准化
5. 跨记录级 anomaly 的 `scope` 字段（single_record / cross_record）
6. v0.1 的 8 类页面 taxonomy 增加 P09（QC-入厂检验主页）+ P10（QC-物料放行单 / 请验单）

---

## 1. v0.1 内容（完整保留 / 不重述）

详见 `extraction-schema-v0.1.md`。本 v0.2 仅描述**增量**。

---

## 2. v0.2 新增 section：`incoming_qc_来料检验[]`

### 2.1 触发与定位

来料检验数据是 F-001 二阶检验的核心证据集（详见 inventory-v0.2.md）。v0.1 schema lock 时该数据流未纳入；本 v0.2 正式收纳。

每个 IncomingQCRecord 对应一份"来料检验报告"PDF 的主页 1-3（通常 9-56 页 PDF 中的高密度数据段）。

### 2.2 IncomingQCRecord 顶层结构

```jsonc
{
  "_source_pdf": "string (相对路径)",
  "_source_pages": "string (如 '1-3 of N')",
  "_extraction_status": "main_report_only_pp.1-3" | "complete" | "needs_review",

  "report_id": "string (检验报告编号 / QC-BG-WB-XXX-NNN-260101 形态)",
  "物料名称": "string",
  "物料代码": "string (MAT-018-Y / MAT-086 等)",
  "_物料分类_v2": "饮片" | "中药材" | "中间体" | "动物源材料" | "辅料" | "包材",
  "进厂批号": "string",
  "厂家批号": "string | null",  // ← v0.2 新：可空（A-002 触发）
  "_厂家批号_异常"?: "string",   // ← v0.2 新：当厂家批号为 null 时用文本说明
  "供货单位": "string",
  "规格": "string",
  "来货数量_kg": float,
  "检验依据": "string (TY-WB-STP-QA-WL-NNN-N-(NN) 形态)",
  "检验日期": "YYYY-MM-DD",
  "报告日期": "YYYY-MM-DD",

  "性状": IndicatorQualitative,
  "鉴别": IndicatorQualitative[],
  "检查": {
    [指标名]: IndicatorUpper | IndicatorQualitative,
    "重金属及有害元素"?: { [元素名]: IndicatorUpper }
  },
  "_检查项缺失"?: string[],   // ← v0.2 新：明确该药材不要求的指标项

  "浸出物_pct"?: IndicatorLower,    // ← 浸出物子通道（如有）
  "含量测定": IndicatorLowerWithSubchannel[],  // ← v0.2: 必含 _subchannel

  "总结论": "符合规定" | "不符合规定" | "待复检",
  "签名": SignatureBlock,
  "_attached_documents"?: AttachedDocument[],

  "_layer_classification_v2": LayerClassification,
  "_F-001_F-002_indicators_v0.3": F001F002Indicators,  // ← v0.2 正式纳入
  "_lot_闭环": LotClosure
}
```

### 2.3 关键 type 定义

#### `IndicatorUpper` — 上限指标（F-002 downward 通道）

```jsonc
{
  "标准_max": float,
  "实测": float | "未检出",
  "_pct_of_LOD": float,    // = 实测 / 标准_max × 100
  "结论": "符合规定" | "不符合规定",
  "_note"?: string
}
```

#### `IndicatorLower` — 下限指标基础（浸出物等）

```jsonc
{
  "标准_min": float,
  "实测": float,
  "_倍率_of_LOQ": float,   // = 实测 / 标准_min
  "结论": "符合规定" | "不符合规定",
  "_note"?: string
}
```

#### `IndicatorLowerWithSubchannel` — 含量测定（F-002 upward 通道 / v0.2 新增子通道）

```jsonc
{
  "成分": "string",
  "化学式": "string",
  "标准_min_pct": float,
  "实测_pct": float,
  "_倍率_of_LOQ": float,
  "_subchannel": "main_component" | "extract" | "minor_component",  // ← v0.2 KEY
  "结论": "符合规定" | "不符合规定",
  "_note"?: string
}
```

#### `_subchannel` 取值定义（A-003 / F-003 候选触发）

`_subchannel` 由**指标的 section 类型**与**标准量级**联合决定（语义优先，非纯阈值）：

| 子通道 | 适用 section | 标准 _min 范围 | 反算难度 | 单批 layer 倾向 | 已观察实例（lot-L1）|
|--------|-------------|---------------|---------|----------------|----------------------|
| `main_component` | `含量测定[]` | ≥30% | 低（绝对差 3-4 个百分点即"刚过线"看似合理）| **suspicious_main_component** | 茯苓 β-葡聚糖 (50%) / 海螵蛸 CaCO3 (86%) — 2 个 |
| `extract` | `浸出物_pct`（独立字段，section 即子通道）| 2.5-22%（无固定上下限，由各药材药典规定）| 中（浸出物指标本身有一定波动空间）| ambiguous | 白芍 (22) / 茯苓 (2.5) / 三七 (21) / 延胡索 (13) — 4 个 |
| `minor_component` | `含量测定[]` | <30% | 高（绝对差 0.04-2 个百分点反而显眼）| ambiguous_lean_actual | 甘草苷 (0.45) / 甘草酸 (1.8) / 芍药苷 (1.2) / 苹果酸酯 (1.5) / 皂苷总量 (6.0) / 延胡索乙素 (0.04) — 6 个 |

**判定函数**（lot-L1 实证 / 语义优先）：

```python
def classify_subchannel(section_name: str, 标准_min: float) -> str:
    if section_name == "浸出物_pct":
        return "extract"
    elif section_name == "含量测定":
        if 标准_min >= 30:
            return "main_component"
        else:
            return "minor_component"
    else:
        raise ValueError(f"Unknown section: {section_name}")
```

**关键设计决策**：
- 浸出物 (`浸出物_pct`) 与含量测定 (`含量测定[]`) 是不同 section（语义区别：浸出物 = 醇/水溶性混合物总量；含量测定 = 特定有效成分定量）
- 浸出物本身就是子通道 `extract`，无需在字段中再标 `_subchannel`（`IndicatorLower` type 不含此字段）
- 含量测定项必须有 `_subchannel` 字段（`IndicatorLowerWithSubchannel` type 强制）
- 边界值 30% 是 lot-L1 7 物料经验值；皂苷总量 6.0% 虽 ≥2 但因属"含量测定"且 <30 → minor_component（与甘草酸 1.8% 同组）

**待 6 批 + 跨产品数据验证后可能调整**（v0.2 → v0.3 触发候选）。

#### `_物料分类_v2`

```
"饮片"          — 已加工的中药饮片（代码后缀 -Y / 如 MAT-018-Y 甘草饮片）
"中药材"        — 未加工成饮片的原药材（代码无后缀 / 如 MAT-086 三七, MAT-083 延胡索）
"中间体"        — 我厂内部加工产物（lot 前缀 Q / 如 Q20260101 三七细粉）
"动物源材料"    — 海螵蛸等动物来源（指标体系简化 / 重金属限值放宽）
"辅料"          — 玉米淀粉 / 明胶空心胶囊 / 薄荷脑等
"包材"          — 铝箔 / PVC 硬片等
```

**A-002 关联**：lot-L1 经验，"中药材"分类 100% 厂家批号空白；"饮片"分类 100% 厂家批号有值。这一关联在 v0.2 schema 通过 `_物料分类_v2` × `厂家批号 == null` 二维交叉显式建模。

#### `_layer_classification_v2` 取值

```
"tentative_actual"          — 默认初值；证据不足时
"actual"                    — 上限通道分散度高 + 跨物料物理差异保留 = 真实测量证据
"actual_low_n"              — 上限通道判 actual 但维度数 < 5（如茯苓/白及无重金属组）
"compliance"                — 上限通道集中低位 + 高度共变 = 反算嫌疑
"mixed"                     — 上限 actual / 下限 compliance（A-003 形态）
"suspicious_main_component" — 下限主成分子通道紧贴 LOQ
"ambiguous"                 — 下限其他子通道证据不足以判定
"ambiguous_lean_actual"     — 下限微量成分子通道 _倍率 较高
```

#### `F001F002Indicators` 字段（v0.2 正式锁定结构）

```jsonc
{
  "上限指标侧_证据": {
    "指标数": int,
    "_pct_of_LOD_分布": "string ([值数组])",
    "分散度": "高" | "中" | "低",
    "_judgment_单批": "string",
    "F-002 偏向": "downward",
    "_layer_倾向": LayerClassification
  },
  "下限指标侧_证据": {
    "指标数": int,
    "_倍率_of_LOQ": float[],
    "_subchannel_breakdown"?: {  // ← v0.2 新：按子通道分组
      "main_component"?: float[],
      "extract"?: float[],
      "minor_component"?: float[]
    },
    "_judgment_单批": "string",
    "F-002 偏向": "upward",
    "_layer_倾向": LayerClassification
  },
  "_combined_judgment_单批": "string",
  "_judgment_v0.3_strategy_分通道"?: object,
  "_special_notes"?: string[]
}
```

#### `LotClosure` (来料检验侧)

```jsonc
{
  "厂家批号_来料检验_请验单": "string | null",
  "厂家批号_批生产记录_提取批指令"?: "string",
  "进厂批号_来料检验": "string",
  "进厂批号_批生产记录领料单": "string",
  "_lot_链"?: "string",   // ← 链路二段（饮片→中间体→投料）形态
  "实际投料_B1_kg": float,
  "来货数量_kg": float,
  "本批使用率_pct": float,
  "_note"?: string
}
```

---

## 3. v0.2 新增页面类型 P09 / P10

接续 v0.1 的 P01-P08 taxonomy：

| ID | 页面类型 | 已见样本 | 主要抽取目标 | 手写密度 |
|----|---------|---------|-------------|---------|
| **P09** | 来料检验报告主页 | 7 份 lot-L1 PDF 第 1 页 | report_id / 物料 / 批号 / 检验项目矩阵 / 总结论 / 签名 | 中（指标值 + 报告/复核/批准签名）|
| **P10** | 物料放行单 + 请验单（合页或独立页）| 7 份 lot-L1 PDF 第 2-3 页 | 三级签批 + 请验数据 + 批号映射 | 高（多签名）|

P09/P10 通常 PDF 内为 pp.1-3 / pp.1-4，紧随其后是原始记录（待 Stage 5 单独评估）。

---

## 4. 跨记录级 anomaly 的 `scope` 字段（v0.2 新增）

v0.1 的 `Anomaly` type 仅设计单条记录内异常（如 A-001 颠茄浸膏数量异常）。lot-L1 横向分析涌现的"跨物料异常"（A-002 / A-003 / A-004 / A-005）需要新字段标识：

```jsonc
{
  "id": "A-NNN",
  "scope": "single_record" | "cross_record" | "cross_batch" | "cross_product",  // ← v0.2 新
  "discovered": "YYYY-MM-DD",
  "source": "string",
  "type": "string",
  // ... 既有字段保留
  "instances"?: object[],     // ← cross_* scope 时记录涉及的多条数据
  "frequency"?: "string",     // ← 如 "3/7 = 43%"
  "pattern"?: "string",
  "hypothesis"?: "string",
  "case_value"?: "string",
  "status": "open" | "investigating" | "resolved" | "false_positive" | "downgraded_v0.X" | "documented_systemic" | "tentative_finding_promote_candidate" | "actual_evidence_strong"
}
```

`scope` 取值含义：

```
"single_record"   — 单条记录内异常（如 A-001 单批超额领料）
"cross_record"    — 跨同类记录（如 A-002 跨 7 份来料检验 PDF）
"cross_batch"     — 跨同产品多批（待 Stage 4 涌现）
"cross_product"   — 跨产品（待 Stage 5 涌现）
```

---

## 5. 顶层 schema_version 字段更新

batch-record.json `_meta.schema_version` 从 `"0.1-pilot"` 升级为 `"0.2"`。

**migration note**：v0.1-pilot 数据（甘草饮片 L1 主页 1-3 嵌入）无需重写——v0.1 数据是 v0.2 的有效子集；v0.2 新增字段（`_subchannel` / `_物料分类_v2` 等）以补充方式追加，不变更既有值。

---

## 6. 与 huadian 框架元素的对应（v0.2 新增映射）

| huadian 元素 | v0.2 新增对应 |
|--------------|--------------|
| invariants V1-V11 | `_subchannel` 三态 + `_layer_classification_v2` 八态 = 案例的 invariants 命名空间扩展 |
| audit_triage | `Anomaly.scope` cross_record 是 audit_triage 跨记录扩展点（vs v0.1 仅单记录）|
| identity_resolver | `_物料分类_v2` × 物料代码后缀 (-Y/无后缀) 双键归一 |

---

## 7. v0.3 升级触发条件（前瞻）

下列情况之一触发 schema v0.3：

1. **6 批P1分布检验完成后**：A-003 → F-003 是否成立？子通道边界 30% / 2% 是否需调整？
2. **跨产品扩展（参乌 / P2）**：是否出现新的 `_物料分类_v2` 取值（如鲜蛋的"动物制品原料"）？
3. **原始记录页（pp.4+）OCR 启动**：HPLC 谱图、TLC 板照片等"二阶 ground truth"是否需要新 type 定义？
4. **Stage 5.5 三层代差地图**：表层/中层/深层间显式 mapping 字段需求？

每次 v0.3 升级必须保持 v0.1/v0.2 数据向前兼容、写 migration note、起独立 ADR。

---

## 8. 锁定声明

**v0.2 schema 自 2026-05-10 起 lock**。所有后续 OCR 工作（lot-L1 已 patch / L2 lot 7 份饮片 + 颠茄 2 lot + 辅料 6 份 + 6 批批生产记录 + 跨产品扩展）按本 v0.2 schema 输出。

任何对 v0.2 的偏离视为 bug 或 v0.3 候选。

---

## 9. v0.1 → v0.2 变更清单（核对用）

| 变更项 | 类型 | 触发 | 影响 |
|--------|------|------|------|
| `incoming_qc_来料检验[]` 顶层 section 正式 schema | 新增 section | inventory-v0.2 + lot-L1 OCR 完成 | 新建结构定义 |
| `_subchannel` 字段（main_component/extract/minor_component） | 新增字段 | A-003 / F-003 候选 | 含量测定数组 |
| `_物料分类_v2` 字段 | 新增字段 | A-002 物料代码后缀关联 | IncomingQCRecord 顶层 |
| `厂家批号` 改为可空 | 类型放宽 | A-002 制度性盲点 | IncomingQCRecord 顶层 |
| `_厂家批号_异常` 字段 | 新增字段 | A-002 | IncomingQCRecord 顶层 |
| `_检查项缺失` 字段 | 新增字段 | 茯苓/白及无重金属 / 海螵蛸无水分灰分 | IncomingQCRecord 检查 |
| `_layer_classification_v2` 取值清单标准化 | 类型清单 | lot-L1 8 种取值涌现 | IncomingQCRecord 顶层 |
| `_F-001_F-002_indicators_v0.3` 正式纳入 | 字段提升 | 已在 batch-record 事后追加 / v0.2 锁定为正式字段 | IncomingQCRecord 顶层 |
| `_subchannel_breakdown` in 下限指标侧_证据 | 新增字段 | A-003 | F001F002Indicators |
| `Anomaly.scope` 字段 | 新增字段 | A-002~A-005 跨记录涌现 | _meta.anomalies_found[] |
| 页面类型 P09 / P10 | taxonomy 扩展 | lot-L1 来料检验主页 | 8 类 → 10 类 |
| schema_version `0.1-pilot` → `0.2` | 版本升级 | 本文档 | _meta 顶层 |

---

> 本 v0.2 是 v0.1 的增量演进，不修订 v0.1 已定字段。所有 v0.1 数据继续有效。
> 文件位置：`huadian/docs/cases/tcm-extraction/schema/extraction-schema-v0.2.md`
> v0.1 锁定快照保留：`extraction-schema-v0.1.md`（不删除 / 历史可追溯）
