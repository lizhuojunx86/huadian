# 提取案例 OCR Schema 锁定文档 v0.3

> Status: **v0.3 — 增量升级 / 完全向前兼容 v0.1 + v0.2**
> Date: 2026-05-10
> Owner: 首席架构师
> 触发：A-006~A-011 + GO-B-α 22 物料 6 类实证（饮片/中药材/中间体/动物源/辅料/包材）
> 关联 ADR：ADR-034-case-2-schema-v0.3-multi-class-subchannels-and-P11.md
> 输入：batch-record.json 22 incoming_qc records + lot-L1-summary-v0.1 + lot-L2-and-auxiliary-summary-v0.1
> 输出：(1) `_subchannel` 取值 3 → 6 类；(2) 页型 P11 物料接收初验记录；(3) A-002 v0.3 三维交互机制；(4) `_meta._SOP_跨lot_演进` 字段；(5) 包材代码前缀规范化；(6) F-002 v0.3 限定

---

## 0. 与 v0.1 / v0.2 的关系

**完全向前兼容**：
- v0.1 / v0.2 所有 sections / 字段定义不变
- v0.1 / v0.2 数据**无需重抽**
- v0.3 仅**新增**字段取值与 sections，不修改既有字段
- 已有的 `_subchannel` 字段在 v0.3 增加 3 个新取值（dual_limit_intermediate / dual_limit_excipient / dual_limit_packaging）

**新增内容**：
1. `_subchannel` 取值扩展为 6 类（main_component / extract / minor_component + 3 个 dual_limit 类）
2. 页面类型 P11 物料接收初验记录（SOP-T-J008-001 形态）
3. A-002 v0.3 三维交互机制（供应商 × 物料分类 × 时间）
4. `_meta._SOP_跨lot_演进` 字段（时间维度建模）
5. 包材代码前缀规范化（NB001 vs WB-NB017）
6. F-002 v0.3 限定（命题适用范围）
7. 跨记录级 anomaly 的 `scope` 扩展支持

---

## 1. v0.1 / v0.2 内容（完整保留 / 不重述）

详见 `extraction-schema-v0.1.md` + `extraction-schema-v0.2.md`。本 v0.3 仅描述**增量**。

---

## 2. v0.3 新增内容

### 2.1 `_subchannel` 取值扩展为 6 类

GO-B-α 跨 6 类物料 22 PDF 实证：除了 v0.2 的 3 子通道（main/extract/minor），还存在 3 类 dual_limit 子通道，标准既设下限又设上限。

**完整 6 类定义**：

| _subchannel | 适用 section | 适用物料类 | 标准量级 | 反算嫌疑特征形态 |
|-------------|-------------|-----------|---------|--------------|
| `main_component` | 含量测定 | 饮片/动物源 | ≥30% | 紧贴 LOQ 下限（1.04-1.07x）|
| `extract` | 浸出物 | 饮片/中药材 | 2-30% | 中间形态（1.25-1.68x）|
| `minor_component` | 含量测定 | 饮片/中药材 | <30% | 远超 LOQ（1.33-2.83x）|
| **`dual_limit_intermediate`** | 含量测定 | 中间体（浸膏等）| 区间制 | 紧贴中点（"安全居中反算"）|
| **`dual_limit_excipient`** | pH / 干燥失重等 | 辅料 | 区间制 | 紧贴中点 / 跨 lot 完全一致 |
| **`dual_limit_packaging`** | 尺寸/伸缩率/涂布差异 | 包材 | 目标值±公差 | 跨 lot 完全一致到小数点 |

**新增 dual_limit 子通道判定函数**：

```python
def classify_subchannel_v0_3(section_name: str, 标准: dict, _物料分类_v2: str) -> str:
    """
    section_name: 字段所在 section（浸出物_pct / 含量测定 / 检查.pH / 检查.干燥失重 / 检查.尺寸 / 检查.加热伸缩率 etc）
    标准: {标准_min: float?, 标准_max: float?}（dual_limit 时两者都有；单边时只有一个）
    _物料分类_v2: IncomingQCRecord 的物料分类字段
    """
    has_min = 标准.get('标准_min') is not None
    has_max = 标准.get('标准_max') is not None

    # 单边下限 (单纯下限)
    if has_min and not has_max:
        if section_name == "浸出物_pct":
            return "extract"
        elif section_name == "含量测定":
            return "main_component" if 标准['标准_min'] >= 30 else "minor_component"
        else:
            raise ValueError(f"Unknown single-min section: {section_name}")

    # 单边上限 (上限指标 - 不在 _subchannel 范围；该函数不处理)
    if not has_min and has_max:
        return None  # 上限指标无 _subchannel

    # dual_limit（同设上下限）
    if has_min and has_max:
        if _物料分类_v2 == "中间体":
            return "dual_limit_intermediate"
        elif _物料分类_v2 == "辅料":
            return "dual_limit_excipient"
        elif _物料分类_v2 == "包材":
            return "dual_limit_packaging"
        else:
            raise ValueError(f"Unknown dual_limit material class: {_物料分类_v2}")

    return None
```

**dual_limit 反算嫌疑特征形态**（v0.3 新发现）：

| 形态 | 实测位置 | 含义 |
|------|---------|------|
| `actual_high` | 紧贴上限 | 接近溢出，可能 actual 自然偏高 |
| `suspicious_LOQ` | 紧贴下限 | 反算"刚过下限"嫌疑（v0.2 单边下限同形态）|
| `centered_suspicious` | 紧贴中点 | **新形态**："安全居中反算"（避免触上下限）|
| `cross_lot_identical` | 跨 lot 完全一致 | **新形态**：跨 lot 0% 差异（明胶黏度 64=64 / PVC 不挥发物 10.1=10.1）|

**lot-L1 + lot-L2 已观察实例**：

```
dual_limit_intermediate (n=2):
  - 颠茄浸膏 天仙子胺 8.3-11.0 mg/g: 9.7 (L1) vs 10.1 (241201)
    L1 几乎完全居中 (中点 9.65 / 偏离 0.05) → centered_suspicious
    241201 偏向上限 (距上限 0.9) → actual_high

dual_limit_excipient (n=3):
  - 玉米淀粉 pH 4.5-7.0: 5.8 → 紧贴中点 5.75 / 偏离 0.05 → centered_suspicious
  - 明胶胶囊 干燥失重 12.5-17.5%: 14.1 / 14.1 (跨 lot 完全一致) → cross_lot_identical ⚠️

dual_limit_packaging (n=多):
  - PVC 加热伸缩率 ±6%: -2/2 (L1) vs -2/2 (L-mat-06) → cross_lot_identical ⚠️
  - PVC 不挥发物 (虽属上限但跨 lot 完全一致): [10.1,10.1,10.0] = [10.1,10.1,10.0] ⚠️
  - 铝箔 尺寸/粘合剂涂布差异 ±10%: 符合区间
```

### 2.2 页面类型 P11 — 物料接收初验记录

接续 v0.1 P01-P08 + v0.2 P09/P10 taxonomy：

| ID | 页面类型 | 已见样本 | 主要抽取目标 | 手写密度 |
|----|---------|---------|-------------|---------|
| **P11** | 物料接收初验记录 | PVC L-mat-06 第 3 页 (SOP-T-J008-001-3-(01)) | 来货数据 + 包装容器/资质/外包装/外观质量 7+ 项检查 + 接收初验员/复核/QA 三签名 | 高（多签名 + 多勾选）|

**P11 字段结构**：

```jsonc
{
  "_source_page": int,
  "form_id": "SOP-T-J008-001-3-(01)",
  "form_name": "物料接收初验记录",
  "来货名称": string,
  "来货日期": "YYYY-MM-DD",
  "来货单号": string,
  "物料编码": string,
  "进厂批号": string,
  "来货总量_kg_或_件": float,
  "包装规格": string,
  "包装件数": int,
  "包装容器类型": "金属桶" | "编织袋" | "纸板桶" | "纸箱" | "其他",
  "供应商资质_经QA批准": boolean,
  "生产商标签信息": {
    "生产商名称": string,
    "生产商批号": string,
    "生产日期": "YYYY-MM-DD?",
    "有效期_复验期": "YYYY-MM-DD?"
  },
  "供应商标签信息": {
    "供应商名称": "string | null",
    "供应商批号": "string | null"
  },
  "物料信息与实际来货不一致": string | null,
  "随货文件": {
    "检验报告书": boolean,
    "送货单": boolean,
    "装箱单": boolean,
    "其他": string | null
  },
  "外包装_检查": {
    "包装完好": boolean,
    "外包装有破损渗漏": boolean,
    "包装封签破损": boolean,
    "外包装有污水灰尘": boolean,
    "是否需要清洁工具": "否" | "扫帚" | "抹布"
  },
  "外观质量情况": {
    "包装是否有受潮水渍霉变虫蛀鼠咬": boolean,
    "是否有肉眼可见霉变虫蛀": boolean,
    "其他": string | null
  },
  "备注": string | null,
  "接收初验人_签名": string,
  "接收初验_日期": "YYYY-MM-DD",
  "复核人_签名": string,
  "复核_日期": "YYYY-MM-DD",
  "QA确认签字": string,
  "QA确认_日期": "YYYY-MM-DD",
  "_数学一致性_检查": string | null  // ← v0.3 新：用于记录如"3000kg ≠ 100×25kg/件"的内部不一致
}
```

**关键观察**：P11 替代或并存于 P10（请验单）。在 PVC L-mat-06 PDF 中，第 3 页是 P11；在其他 21 份 PDF 中，第 3 页是 P10 请验单。schema 设计两者并存（同 record 可同时含 P10 和 P11）。

### 2.3 A-002 v0.3 三维交互机制（厂家批号填写）

**v0.2 假设**（"中药材分类↔厂家批号空白"）已被 GO-B-α 数据推翻。

**v0.3 实际机制 — (供应商 × 物料分类 × 时间) 三维交互**：

| 供应商 | lot-L2 (2025-06) | lot-L1+ (2026-01+) |
|--------|---------------------|----------------------|
| 供应商S1 + 饮片(-Y) | 全部空白 | 部分有值 / 部分空白 |
| 供应商S1 + 中药材(无 -Y) | (无样本) | 全部空白 |
| 恒达（浸膏）| 有值 | 有值 |
| 大成（淀粉）| n/a | 有值 |
| 供应商S4（胶囊）| 有值 | (OCR 缺) |
| 供应商S5（PVC）| n/a | 有值 |
| 格瑞（铝箔）| n/a | 有值 |

**v0.3 字段扩展**：

```jsonc
// IncomingQCRecord 新增
"_供应商_批号填写历史": {
  "供应商名称": string,
  "_本案例观察_批号填写": "always" | "sometimes" | "never",
  "_时间演进": string | null,  // 如 "2025-06 不填 → 2026-01 开始填"
  "_物料分类相关性": "yes" | "no" | "partial"
}
```

### 2.4 `_meta._SOP_跨lot_演进` 字段

GO-B-α 发现 SOP 在 6-7 个月内 10 物料 100% 升级，触发 _meta 顶层增加时间维度字段：

```jsonc
"_meta": {
  ...
  "_SOP_跨lot_演进": {
    "_observation_date": "YYYY-MM-DD",
    "_时间窗口": "string (如 '2025-06 → 2026-01')",
    "_升级覆盖率": "string (如 '10/10 = 100% 物料')",
    "_主要变更类别": [
      "agricultural_residue_expansion",     // 农残检测项扩展（33→47 种）
      "heavy_metal_introduction",          // 重金属检测引入更多药材
      "main_component_introduction",       // 主成分含量测定新增
      "standard_tightening",               // 标准限值收紧
      "wording_normalization"              // 鉴别/检验描述规范化
    ],
    "_案例含义": "F-001 三层结构在时间维度上是动态的，合规叙事的外层在持续扩展"
  }
}
```

### 2.5 包材代码前缀规范化

**v0.2 假设**：物料代码前缀 ↔ `_物料分类_v2` 一一对应。

**GO-B-α 实证**：
- PVC = `NB001`（无 WB- 前缀）
- 铝箔 = `WB-NB017`（有 WB- 前缀）
- 两者都是"包材"分类

**v0.3 修正**：

```jsonc
// IncomingQCRecord 字段增强
"_代码前缀_v2_映射": {
  "前缀": "WB-ZY-Y | WB-ZY | WB-FG | NB | WB-NB",
  "_物料分类_v2": "饮片 | 中药材 | 中间体 | 动物源材料 | 辅料 | 包材",
  "_一对多": true,  // ← v0.3 承认前缀↔分类不是 1:1
  "_包材子映射": {
    "NB[NNN]": "包材-PVC类",
    "WB-NB[NNN]": "包材-铝箔类",
    "_note": "可能反映编号体系演进 / 不同时期引入 / 不构成案例本质"
  }
}
```

### 2.6 F-002 命题 v0.3 限定

**v0.2 命题**：中成药质量标准只设含量下限（来自"含量高=质量好"话语）→ upward 反算偏向。

**v0.3 限定**：F-002 命题适用于**中药材成品/饮片的"含量测定"section（单边下限）**。**不适用于**：
- 工艺中间体（浸膏 dual_limit_intermediate）：双向控制，"高即好"话语不适用
- 辅料（玉米淀粉 pH / 明胶干燥失重 dual_limit_excipient）：物理化学指标，无文化话语驱动
- 包材（PVC 加热伸缩率 / 尺寸公差 dual_limit_packaging）：工业制造公差，无"高即好"话语

**F-002 v0.3 适用范围字段**：

```jsonc
// 在 fundamental_findings.F-002 中
"_v0_3_适用范围": {
  "适用_section": ["含量测定（单边下限）"],
  "适用_物料分类_v2": ["饮片", "中药材", "动物源材料"],
  "不适用_section": ["浸出物_pct（中间形态）", "含量测定（dual_limit）"],
  "不适用_物料分类_v2": ["中间体", "辅料", "包材"]
}
```

### 2.7 跨记录级 anomaly 的 `scope` 扩展

v0.2 已支持 single_record / cross_record / cross_batch / cross_product。v0.3 增加：

```jsonc
"scope": "single_record" |
         "cross_record" |
         "cross_batch" |
         "cross_product" |
         "cross_supplier" |       // ← v0.3 新（A-007 触发）
         "cross_time_window"      // ← v0.3 新（A-006 触发）
```

---

## 3. v0.3 _subchannel_breakdown 字段更新

v0.2 在 `_F-001_F-002_indicators_v0.3.下限指标侧_证据._subchannel_breakdown` 中支持 3 类。v0.3 扩展为 6 类：

```jsonc
{
  "_subchannel_breakdown": {
    "main_component": float[] | null,
    "extract": float[] | null,
    "minor_component": float[] | null,
    "dual_limit_intermediate": [{"实测": float, "中点": float, "偏离中点": float}] | null,
    "dual_limit_excipient": [{"实测": float, "中点": float, "偏离中点": float}] | null,
    "dual_limit_packaging": [{"实测_横向": float, "实测_纵向": float, "标准_min": float, "标准_max": float}] | null
  }
}
```

**注意**：dual_limit 类的字段结构与单边类不同 — 需要记录中点 + 偏离中点（centered_suspicious 检测）或者横向/纵向（dual_limit_packaging 加热伸缩率）。

---

## 4. v0.3 升级触发条件（前瞻 / v0.4 候选）

下列情况之一触发 schema v0.4：

1. **6 批P1分布检验完成**：F-003 finalized / retracted；子通道边界 30% / 2% 是否需调整
2. **跨产品扩展（参乌 / P2）**：是否出现新的 `_物料分类_v2` 取值（鲜蛋的"动物制品原料"？95% 乙醇的"溶剂"？维生素 E 的"营养辅料"？）
3. **原始记录页（pp.4+）OCR 启动**：HPLC 谱图 / TLC 板照片 / 显微图等"二阶 ground truth"是否需要新 type 定义
4. **Stage 5.5 三层代差地图**：表层/中层/深层间显式 mapping 字段需求
5. **F-002 / F-003 升 finalized 后**：可能触发"命题文档"独立 ADR 与 schema 分离

每次 v0.4 升级必须保持 v0.1/v0.2/v0.3 数据向前兼容、写 migration note、起独立 ADR。

---

## 5. 锁定声明

**v0.3 schema 自 2026-05-10 起 lock**。所有后续 OCR 工作按本 v0.3 schema 输出。

任何对 v0.3 的偏离视为 bug 或 v0.4 候选。

---

## 6. v0.2 → v0.3 变更清单（核对用）

| 变更项 | 类型 | 触发 | 影响 |
|--------|------|------|------|
| `_subchannel` 取值 3 → 6 类（增加 3 个 dual_limit） | 字段值扩展 | A-010 dual_limit 形态发现 | 含量测定 + 检查中 dual_limit 字段 |
| 页面类型 P11 物料接收初验记录 | taxonomy 扩展 | A-011 PVC L-mat-06 新页型 | 10 类 → 11 类 |
| `_供应商_批号填写历史` 字段 | 新增字段 | A-007 三维交互机制 | IncomingQCRecord 顶层 |
| `_meta._SOP_跨lot_演进` 字段 | 新增 meta 字段 | A-006 时间维度演进 | _meta 顶层 |
| `_代码前缀_v2_映射` 字段 | 新增字段 | 包材 NB001 vs WB-NB017 | IncomingQCRecord 顶层 |
| F-002 `_v0_3_适用范围` 子字段 | 新增字段 | A-010 dual_limit 限定 | fundamental_findings.F-002 |
| `Anomaly.scope` 增加 cross_supplier / cross_time_window | 取值扩展 | A-006 / A-007 | _meta.anomalies_found |
| `_subchannel_breakdown` 支持 6 类 | 字段值扩展 | 同上 | F-001_F-002_indicators_v0.3 |
| schema_version `0.2` → `0.3` | 版本升级 | 本文档 | _meta 顶层 |

---

## 7. 本 v0.3 + GO-B-α 22 records 整合验证

22 records 数据中，v0.3 字段补全要求：

| 记录类 | 数量 | 需补 dual_limit_subchannel 字段 |
|-------|------|------------------------------|
| 饮片/中药材/动物源（lot-L1+L2）| 14 | 主成分 2 / 浸出物 8 / 微量 12 — 已落字段 ✅ |
| 中间体（颠茄浸膏 2 lot）| 2 | dual_limit_intermediate（天仙子胺）/ minor_component（东莨菪内酯）— **新增字段值 v0.3** |
| 辅料（玉米淀粉 + 明胶 2 lot）| 3 | dual_limit_excipient（pH / 干燥失重）/ main_component（黏度）— **新增字段值 v0.3** |
| 包材（PVC 2 lot + 铝箔）| 3 | dual_limit_packaging（加热伸缩率 / 尺寸 / 粘合剂涂布）— **新增字段值 v0.3** |

batch-record.json 数据已在 GO-B-α 时填了 `dual_limit_intermediate` 等字符串到 `_subchannel` 字段，v0.3 schema 正式 lock 这些取值。**无需重抽数据**。

---

> 本 v0.3 是 v0.1 / v0.2 的增量演进，不修订既有字段。所有 v0.1 / v0.2 数据继续有效。
> 文件位置：`huadian/docs/cases/tcm-extraction/schema/extraction-schema-v0.3.md`
> v0.1 / v0.2 锁定快照保留（不删除 / 历史可追溯）
