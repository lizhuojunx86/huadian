# 提取案例 OCR Schema 锁定文档 v0.4 — 完整 Lock

> Status: **v0.4（完整 lock）**（2026-06-01 / 完整 lock session / 接续 GO-M-ζ outline）
> Date: 2026-06-01（outline: 2026-05-15 GO-M-ζ）
> Owner: 首席架构师
> 触发：ADR-035 用户审稿通过（6.1 仅 8 项 / 6.2 B outline → 完整 lock / 6.4 A 复制 / 6.5 A cross_form）；沉淀期（5/15→5/31）结束后执行 v0.4.md §4 完整 lock 工作清单
> 关联 ADR：ADR-035-case-2-schema-v0.4-F004-finalization-and-F001-v0.4-lock.md
> 输入：batch-record.json records-only patch v0.3.1~v0.3.4 已落字段（A-016~A-021 + Q-029/035/036/037/038/039/040 + F-004 + F-001 v0.4）为权威源
> 输出：8 项 v0.4 增量完整字段定义（详细 jsonc 块 + 取值清单），从 outline 升级为完整 lock

---

## 0. 与 v0.1 / v0.2 / v0.3 的关系

**完全向前兼容**：
- v0.1 / v0.2 / v0.3 所有 sections / 字段定义不变
- v0.1 / v0.2 / v0.3 数据**无需重抽**
- v0.4 仅**新增**字段取值与 sections，不修改既有字段
- v0.4 完整 lock 阶段：字段名 + 类型 + 语义（outline 已 lock）+ 详细 jsonc 块 + 取值清单（本完整 lock 补全）

**outline → 完整 lock 的变化（本文档相对 GO-M-ζ outline）**：
- ✅ outline 已 lock：8 项字段名 + 类型 + 语义（保留不变）
- ✅ 完整 lock 补全：C-1 / C-2 / C-4 / C-10 的详细 jsonc 块（从 batch-record.json 复制 + 精炼，路径 6.4 A）
- ✅ 完整 lock 补全：§2.9 F-002 vs F-004 对比表正式 lock（v0.4.md §4 step 3）
- ⏳ 仍待执行：batch-record.json `_meta.schema_version` `0.3` → `0.4` + `_schema_upgrade_history` 追加 v0.4 条目（CLAUDE.md §5 红线 #2 / ADR-035 §6.3 / 需用户单独 ACK）
- 押后清单（C-5/C-6/C-9）：见 ADR-035 §2.1 押后表 / 留 v0.5

---

## 1. v0.1 / v0.2 / v0.3 内容（完整保留 / 不重述）

详见 `extraction-schema-v0.1.md` + `extraction-schema-v0.2.md` + `extraction-schema-v0.3.md`。本 v0.4 仅描述**增量**。v0.1/v0.2/v0.3 锁定快照保留（不删除 / 历史可追溯）。

---

## 2. v0.4 新增内容（8 项完整 lock）

### 2.1 [C-1] F-004 fundamental_finding lock

**字段路径**：`_meta.fundamental_findings.F-004`

**lock 路径**：直接复制 batch-record.json `_meta.fundamental_findings.F-004` 既有内容作为 schema 文档的 finding 定义（路径 6.4 A / batch-record.json 内容为权威）。

**完整字段定义**：

```jsonc
{
  "id": "F-004",
  "status": "finalized_X1_satisfied_with_mechanism_depth_extension_pending_X2",
  "_status_含义": "GO-E-α 用户访谈 Q-027 揭示'操作工压线合格机制' / 6 批跨批 σ ≈ 0 + 紧贴 40% 下限是直接实证 / finalize 待跨产品（X1）+ 跨企业（X2）验证",
  "discovered": "2026-05-10 (GO-E-α)",
  "source": "用户访谈 Q-027 用户原话 + GO-D-α 6 批P1跨批 σ 矩阵",
  "promotion_path": "GO-D-α 6 批 σ ≈ 0 数据 + GO-E-α Q-027 用户答（操作工压线合格） → F-004 候选浮现 → GO-G-γ-Phase 2 P2跨产品 X1 finalized",
  "claim": "中药批生产记录中的反算机制存在两种独立形态：(1) F-002 文化话语驱动 upward（'高即好' / 含量指标推高 / 无意识 / 来料检验侧）；(2) F-004 博弈论驱动 downward 压线（'自我保护 + 留安全垫' / 收率/衍生指标压在规程下限 / 有意识 / 批生产记录侧）。两种机制并存，方向相反、驱动不同、识别方法不同。",
  "evidence_lot_L1_to_260106": {
    "6批P1_收率": "[40.27, 40.26, 40.30, 40.28, 40.32, 40.30] / σ = 0.022 pp / 紧贴 40% 下限 (区间 40-45%)",
    "用户Q-027_机制说明": "操作工怕被高基线考核 + 怕 QA 调查异常 + 留未来失败空间 → 倾向每次都压线合格",
    "用户Q-027_真实噪声": "批间差异大 + 来料差异 + 操作不严谨 → 真实收率 σ 应 > 0.5%",
    "推论": "真实 σ > 0.5% 但记录 σ = 0.022 pp = 强反算确证"
  },
  "F-002_vs_F-004_对比表": "见 §2.9（6 维度正式 lock）",
  "适用范围": {
    "已实证": ["6 批P1收率 / 工艺参数 / 投料量", "6 批P2收率（跨产品 X1）"],
    "可能扩展": ["其他中成药企业的批生产记录衍生指标", "财报压线达标", "学术 p-hacking 避免过度显著", "临床试验主要终点压线"],
    "限定": "需要'有外部考核压力 + 一线人员有自填权限 + 紧贴规程边界的指标'三者并存"
  },
  "finalize_条件": {
    "X1_跨产品": "P2 6 批 σ=0.0275 紧贴标杆 38.3% → X1 satisfied (GO-G-γ-Phase 2)",
    "X2_跨企业": "其他中成药企业的操作工是否有同样行为 / 见 §2.8 _X2_状态（documented_unresolvable）",
    "_当前满足": "P1 + P2双产品 6+6 批 + 用户访谈确认（X1 satisfied + 单产品 C 满足）"
  },
  "_命题_深化_GO-G-γ": {
    "原命题": "操作工把可调整指标写入规程下限附近，留未来失败空间",
    "深化_命题": "操作工识别'最不引人注目的安全位置'：(a) 规程只给区间 → 选下限 (b) 规程给标杆 → 选标杆 (c) 任何'看起来合规且不需解释'的位置都是候选",
    "跨产品_实证": {
      "P1": { "规程": "区间 40-45%", "选择": "下限 40%", "σ": 0.0223 },
      "P2": { "规程": "区间 36-41% + 标杆 38.3%", "选择": "标杆 38.3%", "σ": 0.0275 }
    }
  },
  "broader_methodological_value": "F-004 是博弈论 + 行业心理学的新方法论命题。AI 知识工程在合规叙事审计中，识别'一线人员自我保护策略对数据偏向的影响' = 关键方法。命题形式化：'反算难度 + 操作者自我保护策略 + 外部考核机制 三者交互'。",
  "_X2_状态": "见 §2.8 [C-11]（documented_unresolvable_2026-05-14）"
}
```

**意义**：F-004 是 08 文章（双重反算识别）的核心新贡献，与 F-002 配对构成"双向反算"完整论点。

### 2.2 [C-2] F-001 v0.4 三层精细化 lock

**字段路径**：`_meta.fundamental_findings.F-001._v0_4_精细化`

**lock 路径**：复制 batch-record.json 既有 `F-001._v0_4_精细化` 字段段。

**完整字段定义**：

```jsonc
{
  "_v0_4_精细化": {
    "_status_date": "2026-05-10 (GO-E-α)",
    "_triggered_by": "Q-026 + Q-027 + Q-028 用户访谈",
    "表层_合规叙事_三类参数": {
      "输入参数_反算填表": {
        "examples": ["投料数量 514.35 kg", "提取温度 100°C", "提取时间 3+2 h", "料液比 6.000"],
        "_机制": "无外部独立验证 → 操作工倒推合理数值填表"
      },
      "输出参数_真实记录": {
        "examples": ["相对密度（QC 复核）", "含量测定（QC 检测）", "外观（下游肉眼可见）"],
        "_机制": "QC 独立 + 下游约束 → 操作工不修改记录"
      },
      "衍生指标_工艺控制压线": {
        "examples": ["收率 40.26-40.32%（紧贴 40% 下限）"],
        "_机制": "操作工通过控制工艺过程让结果落到目标区间，不修改记录（F-004 命题）"
      }
    },
    "中层_实际执行_运筹层决策": {
      "_机制": "车间主任 + 排产决策 / 不是个人偏好 / 不是规程明文",
      "examples": ["A-013 浓缩设备 E1 → E2 切换 = B2 起排产变化"],
      "_多形态": "见 §2.6 [C-8]（跨批切换 / 同批并行）"
    },
    "深层_身体化经验": {
      "_机制": "操作工现场决策 + 自我保护策略 + 真实不严谨 + 班次配合",
      "examples": [
        "操作工压线合格策略（Q-027 → F-004）",
        "操作不严谨 = 真实生产噪声",
        "操作工 L/操作工 Z ABAB 班次轮值（A-015 / Q-006-延伸 / 字段押后 C-9 v0.5）"
      ]
    }
  }
}
```

**意义**：F-001 v0.4 三层结构是 09 文章（分层合规叙事识别）的核心论点（4 mermaid 之一），与 08 文章配对实现"结构 × 机制"互证。

### 2.3 [C-3] Anomaly.scope 增 `cross_form`

**字段路径**：`_meta.anomalies_found[].scope`

**v0.4 取值清单（v0.3 → v0.4）**：

```
single_record / cross_record / cross_batch / cross_product /
cross_supplier / cross_time_window /
cross_form  ← v0.4 新增（命名 ACK 6.5 A）
```

**语义**：form 之间不一致问题（与 record 间不一致 `cross_record` 区分）。
**实证**：A-019（黄芩饮片 70.94 kg / 领料单 lot L-mat-01 vs 批指令 lot L-mat-07 / 同一物料同一批次同一数量但 lot 字段不一致 / F-001 表层不同 form 之间内部数据不一致）。

### 2.4 [C-4] cross_product 顶层 section schema 化

**字段路径**：顶层 `cross_product_<产品名>_<场景>_<版本>`（如 `cross_product_yanreqing_lotL-mat-07_v0_1` / `cross_product_yanreqing_T_series_v0_1`）

**完整结构定义**：

```jsonc
{
  "cross_product_<产品名>_<场景>_<版本>": {
    "_source": "string — OCR 来源描述（GO 阶段 + 物料/批次范围）",
    "_extraction_date": "YYYY-MM-DD",
    "_purpose": "string — 跨产品扩展目的（F-003 condition B / F-004 X1 / F-001/F-002 跨产品稳健性等）",
    "_product": "string — 产品名 / 产品代码（如 'P2 / P2-CODE'）",
    "_supplier": "string — 供应商（如适用）",
    "incoming_qc_records": [
      // 各物料来料检验记录 / 结构同 v0.2 incoming_qc 主 schema（report_id / 物料名称 / 物料代码 /
      // _物料分类_v2 / 进厂批号 / 厂家批号 / 检查 / 含量测定[_subchannel] / 签名 /
      // _attached_documents[] / _layer_classification_v2 / _F-001_F-002_indicators_v0.3）
    ],
    "_records": [
      // 或：批生产记录横向对比记录（用于 T_series 跨批 σ 场景）
    ],
    "_findings_summary": "object — 跨产品发现汇总（F-002 minor 复现 / F-003 main 扩展 / 新极端样本等）",
    "_F004_X1_finalize_verdict": {
      // 如适用 / 跨产品 σ 矩阵 + 紧贴位置形态 / 见 §2.5 [C-7]
    }
  }
}
```

**实证**：batch-record.json 已落 2 个 cross_product 顶层 section（lot-260201 7 飲片 + T_series 6 批）。跨产品扩展（P3等 case-3）按本结构复用。

### 2.5 [C-7] 跨产品 σ 矩阵字段 schema 化

**字段路径**：`cross_product_*._F004_X1_finalize_verdict._跨产品_σ_矩阵`（嵌入 cross_product 顶层 section）

**完整字段结构**（详 09 §6.4 + ADR-035 §1.2）：

```jsonc
{
  "_跨产品_σ_矩阵": [
    {
      "产品": "string",
      "规程": "string — '区间 / 标杆 / 单边'描述",
      "实际紧贴": "string — 实际紧贴位置 + 偏离量级",
      "σ_pp": "float — 跨批收率标准差（百分点）",
      "n_批": "int",
      "偏离量级_pp": "string — 'min~max'"
    }
  ]
}
```

**实证（已 lock 数据点）**：

| 产品 | 规程 | 实际紧贴 | σ (pp) | n 批 | 偏离量级 (pp) |
|------|------|---------|--------|------|--------------|
| P1 | 区间 40-45% / 无标杆 | 下限 40% | 0.0223 | 6 | +0.26~0.32 |
| P2 | 区间 36-41% / 标杆 38.3% | 标杆 38.3% | 0.0275 | 6 | +0.264~0.341 |

### 2.6 [C-8] F-001 中层运筹层多形态字段

**字段路径**：`_meta.fundamental_findings.F-001._v0_4_精细化.中层_实际执行_运筹层决策._多形态`

**取值清单（已实证 2 形态）**：

```jsonc
{
  "_多形态": [
    {
      "形态": "跨批切换",
      "实证": "P1 / B1 E1 32h → B2+ E2 10h"
    },
    {
      "形态": "同批并行",
      "实证": "P2 / B7 同批 双效 E3 + 单效 E1 + 收膏 E2 = 3 套设备并行 / 工艺规程 §4.10.5 明示并行"
    }
  ]
}
```

**未来扩展**：case-3 跨车间扩展可能浮现`第三种形态`（如紧贴上限 / 中点 / 待实证，Q-040）。

### 2.7 [C-10] 页型 P12 中药材检验原始记录

**取值扩展**：v0.3 P11 → v0.4 P12（接续 v0.1 P01-P08 + v0.2 P09/P10 + v0.3 P11 taxonomy）。

**P12 完整字段结构**（栀子 16 页实证 / 嵌入 incoming_qc record 的 `_attached_documents[]`）：

```jsonc
{
  "_source_page": "int",
  "form_id": "string — 如 TY-WB-SOP-QC-WL-J031-001-3-(02)",
  "form_name": "string — 如 '栀子中药材检验原始记录'",
  "_新页型_P12": "string — schema v0.3 P09/P10/P11 之外的第 4 类 / 中药材检验过程原始记录",
  "_F-001_表层延伸": "string — 手写检验结果几乎完全照抄标准描述 / 性状描述未个性化 → F-001 表层反算延伸到'原始记录'层",
  "_性状描述_照抄标准": "bool — 标记字段（A-022 候选 / 栀子实证）",
  "检验人": "string",
  "复核人": "string"
}
```

**实证**：GO-G-γ Phase 1 / 栀子 16 页 / 性状描述几乎完全照抄标准（Q-036 / Q-037 待其他物料 P12 验证）。

### 2.8 [C-11] F-004._X2_状态 显式 unresolvable 字段

**字段路径**：`_meta.fundamental_findings.F-004._X2_状态`

**完整字段结构**：

```jsonc
{
  "_X2_状态": "documented_unresolvable_2026-05-14",
  "_X2_决定时间": "2026-05-14 (GO-I-ε)",
  "_X2_决定理由": "用户答 '人脉不确定' / 选承认局限性而非强行推进",
  "_X2_remediation_path": "v0.3 文献综述 / 中药 GMP 行业研究 / 制造业 lean 文献 / 社会学组织研究文献检索 F-004 类似命题的间接证据（不依赖一手访谈）",
  "_对学界外审的影响": "09 §11.4 局限性章节明示 / 透明承认局限 / generalizability 由文献综述部分补强"
}
```

**意义**：透明承认局限 = 比硬撑伪 generalizability 更稳健 / 学界外审时 schema 文档可作为命题严谨性证据。

### 2.9 F-002 vs F-004 对比表（正式 lock / 双重反算识别核心）

**字段路径**：`_meta.fundamental_findings.F-004.F-002_vs_F-004_对比表`

08 文章（双重反算识别框架）的核心论点。6 维度正式 lock：

| 维度 | F-002 | F-004 |
|------|-------|-------|
| 反算方向 | upward（推高） | downward（压低 / 压线） |
| 适用 section | 含量测定下限指标（来料检验） | 收率 / 工艺参数 / 衍生指标（批生产记录） |
| 驱动 | 文化话语（"高即好"） | 博弈论自我保护（怕考核 + 怕调查） |
| 触发模式 | 心智偏向（无意识） | 理性策略（有意识） |
| 数据形态 | 倍率 1.04-2.83x（main_component 紧贴 LOQ） | σ ≈ 0 + 紧贴下限 |
| 识别方法 | 子通道分布检验（lot-L1） | 跨批 σ ≈ 0 + 紧贴边界 + 用户访谈验证 |

**关键论断**：单一识别框架会漏掉至少一半反算嫌疑（F-002 与 F-004 方向相反、机制不同、识别方法不同）。

---

## 3. v0.3 → v0.4 变更清单（核对用 / 8 项）

| 变更项 | 类型 | 触发 | 影响 | 状态 |
|--------|------|------|------|------|
| F-004 fundamental_finding lock (C-1) | 新增 finding | A-020 / Q-027 / GO-J-ε | `_meta.fundamental_findings.F-004` | ✅ 完整 lock（§2.1 + §2.9） |
| F-001 v0.4 三层精细化 lock (C-2) | 新增字段段 | A-016 + A-017 + Q-029 | `F-001._v0_4_精细化` | ✅ 完整 lock（§2.2） |
| Anomaly.scope 增 cross_form (C-3) | 取值扩展 | A-019 | `Anomaly.scope` | ✅ 完整 lock（§2.3） |
| cross_product 顶层 section schema (C-4) | 新增 section 类型 | GO-G-γ Phase 1+2 | 顶层 `cross_product_*` | ✅ 完整 lock（§2.4） |
| 跨产品 σ 矩阵字段 (C-7) | 新增字段段 | GO-D-α + GO-G-γ Phase 2 | `_跨产品_σ_矩阵` | ✅ 完整 lock（§2.5） |
| F-001 中层运筹层多形态 (C-8) | 新增字段段 | A-021 | `F-001._v0_4_精细化.中层._多形态` | ✅ 完整 lock（§2.6） |
| 页型 P12 (C-10) | taxonomy 扩展 | GO-G-γ Phase 1 栀子 | 页型 11 → 12 类 | ✅ 完整 lock（§2.7） |
| F-004._X2_状态 显式 (C-11) | 新增字段 | GO-I-ε 用户决定 | `F-004._X2_状态` | ✅ 完整 lock（§2.8） |
| schema_version `0.3` → `0.4` | 版本升级 | 本文档 | `_meta.schema_version` | ⏳ 待用户 ACK（红线 / ADR-035 §6.3） |

**押后到 v0.5（3 项 / 详 ADR-035 §2.1 押后表）**：C-5 边界子通道（high_minor / high_extract）/ C-6 qualitative_LOD / C-9 ABAB 班次。

---

## 4. 完整 lock 达成记录 + batch-record.json 同步路径

**完整 lock session 工作清单（v0.4.md §4 / 已达成）**：

1. ✅ C-1 / C-2 / C-4 / C-10：详细 jsonc 块完整起草（从 batch-record.json 复制 + 精炼）→ §2.1/§2.2/§2.4/§2.7
2. ⏳ batch-record.json `_meta.schema_version` `0.3` → `0.4` + `_schema_upgrade_history` 追加 v0.4 条目 → **待用户 ACK（CLAUDE.md §5 红线 #2）**
3. ✅ F-002 vs F-004 跨产品对比表正式 lock 入 schema 文档 → §2.9
4. ✅ F-001 v0.4 三类参数 / 中层多形态 / 深层身体化经验 详细字段定义 → §2.2 + §2.6
5. ✅ P12 中药材检验原始记录字段结构完整定义 → §2.7
6. ✅ 与 inventory v0.3 + lot-summary 文档的 cross-ref → §6 参考

**batch-record.json 待同步条目（红线 / 需 ACK）**：

```jsonc
// _meta.schema_version: "0.3" → "0.4"
// _meta._schema_upgrade_history 追加：
{
  "from": "0.3.4",
  "to": "0.4",
  "date": "2026-06-01",
  "adr": "ADR-035",
  "trigger": "v0.4 完整 lock：F-004 + F-001 v0.4 + cross_form + cross_product + σ 矩阵 + 中层多形态 + P12 + X2 unresolvable（8 项）",
  "changes": [
    "F-004 fundamental_finding lock 入 schema (C-1)",
    "F-001 v0.4 三层精细化 lock 入 schema (C-2)",
    "Anomaly.scope 增 cross_form (C-3)",
    "cross_product 顶层 section schema 化 (C-4)",
    "跨产品 σ 矩阵字段 schema 化 (C-7)",
    "F-001 中层运筹层多形态字段 (C-8)",
    "页型 P12 中药材检验原始记录 (C-10)",
    "F-004._X2_状态 显式 unresolvable (C-11)"
  ],
  "defer_to_v0_5": ["C-5 边界子通道 high_minor/high_extract", "C-6 qualitative_LOD", "C-9 ABAB 班次轮值"],
  "compat": "fully_forward_compatible / 无需重抽数据 / records-only patch v0.3.1~v0.3.4 已落字段值在 v0.4 中正式合法化"
}
```

---

## 5. 锁定声明

**v0.4 schema 自 2026-06-01 起完整 lock**。本文档 §2 字段名 + 类型 + 语义 + 详细 jsonc 块为权威。

任何对 v0.4 的偏离视为 bug 或 v0.5 升级候选。

batch-record.json 既有 records 维持 records-only patch v0.3.4 状态 / `_meta.schema_version` 待用户 ACK 后升 `0.4`（红线 #2 / ADR-035 §6.3）。

---

## 6. 参考与延伸

- 实证基础（lot-L1 单 lot）：`docs/cases/tcm-extraction/data/incoming-qc/lot-L1-summary-v0.1.md`
- 实证基础（跨 lot 跨物料）：`docs/cases/tcm-extraction/data/incoming-qc/lot-L2-and-auxiliary-summary-v0.1.md`
- 实证基础（6 批跨批 σ）：`docs/cases/tcm-extraction/data/pilot-WK-B1/cross-batch-T-summary-v0.1.md`
- 实证基础（用户访谈 5 题）：`docs/cases/tcm-extraction/data/user-interview-v0.1-go-e-alpha.md`
- 实证基础（跨产品 7 飲片 + 6 批）：`batch-record.json` `cross_product_yanreqing_*` sections
- ADR-035 §2.1：8 项 lock + 3 项押后清单 / §6：5 个用户决策点（已 ACK / GO-M-ζ）
- ADR-033：v0.1 → v0.2 升级（incoming_qc + 3 子通道）
- ADR-034：v0.2 → v0.3 升级（dual_limit 6 类 + P11 + 三维交互 + 时间维度）
- schema-v0.3.md：v0.3 lock 快照（完整保留）
- 09 文章：`docs/methodology/09-layered-compliance-narrative-pattern.md` v0.2 全本（F-001 v0.4 三层结构 / 4 mermaid / 950 行）
- 08 文章：`docs/methodology/08-dual-reverse-calculation-pattern.md` v0.3 partial（F-002 vs F-004 对比表 / §7.3 学术理论 / 717 行）
- 2026-05 月度日记：`docs/methodology/decision-journals/2026-05.md` v1.0 定版

---

> 本 v0.4 是 v0.1 / v0.2 / v0.3 的增量演进，不修订既有字段。所有 v0.1 / v0.2 / v0.3 数据继续有效。
> 文件位置：`huadian/docs/cases/tcm-extraction/schema/extraction-schema-v0.4.md`
> v0.1 / v0.2 / v0.3 锁定快照保留（不删除 / 历史可追溯）
> 本文档完整 lock 状态 / outline 阶段（GO-M-ζ / 2026-05-15）→ 完整 lock（2026-06-01）
