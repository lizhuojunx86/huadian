# 提取案例 OCR Schema 锁定文档 v0.4 — Outline

> Status: **v0.4-outline**（GO-M-ζ / 2026-05-15 / 用户 ACK 后起草）
> Date: 2026-05-15
> Owner: 首席架构师
> 触发：ADR-035 用户审稿通过（6.1 仅 8 项 / 6.2 B outline 路径 / 6.4 A 复制 / 6.5 A cross_form）
> 关联 ADR：ADR-035-case-2-schema-v0.4-F004-finalization-and-F001-v0.4-lock.md
> 输入：batch-record.json records-only patch v0.3.1~v0.3.4 已落字段（A-016~A-021 + Q-029/035/039/040 + F-004 + F-001 v0.4）
> 输出：8 项 v0.4 增量 outline（详细字段定义留 5/28 后续 session 完整起草）

---

## 0. 与 v0.1 / v0.2 / v0.3 的关系

**完全向前兼容**：
- v0.1 / v0.2 / v0.3 所有 sections / 字段定义不变
- v0.1 / v0.2 / v0.3 数据**无需重抽**
- v0.4 仅**新增**字段取值与 sections，不修改既有字段
- v0.4 outline 阶段：仅锁定字段名 + 字段类型 + 字段语义；详细 schema 体（jsonc 块 / 取值清单 / 判定函数）留 5/28 后续 session

**outline 状态边界**：
- ✅ 字段名 + 字段类型 + 字段语义 已 lock（本文档 §2）
- ⏳ 详细 jsonc 块 + 取值清单 + 判定函数 待 5/28 后续 session 完整起草
- ⏳ batch-record.json _meta.schema_version 0.3.4 → 0.4 推迟到完整 session 同步执行
- 押后清单（C-5/C-6/C-9）：见 ADR-035 §2.1 押后表 / 留 v0.5

---

## 1. v0.1 / v0.2 / v0.3 内容（完整保留 / 不重述）

详见 `extraction-schema-v0.1.md` + `extraction-schema-v0.2.md` + `extraction-schema-v0.3.md`。本 v0.4 仅描述**增量**。

---

## 2. v0.4 新增内容（8 项 outline）

### 2.1 [C-1] F-004 fundamental_finding lock

**字段路径**：`_meta.fundamental_findings.F-004`

**lock 路径**：直接复制 `batch-record.json` `_meta.fundamental_findings.F-004` 既有内容（~80 行）作为 schema 文档的 finding 定义（路径 6.4 A / batch-record.json 内容为权威）。

**核心子字段清单**（详细 jsonc 体留 5/28 完整起草）：
- `id` / `status` / `discovered` / `source` / `promotion_path` / `claim`
- `F-002_vs_F-004_对比表`（5 维度对比 / 已成 09 文章核心论点）
- `condition_X1_definition` / `condition_X2_definition`
- `_X1_finalize_verdict`（命题深化 / 紧贴位置二种形态 / σ 矩阵）
- `broader_methodological_value`
- `_X2_状态`（详 §2.8 [C-11]）

### 2.2 [C-2] F-001 v0.4 三层精细化 lock

**字段路径**：`_meta.fundamental_findings.F-001._v0_4_精细化`

**lock 路径**：复制 batch-record.json 既有 `F-001._v0_4_精细化` 字段段（line 870-913）。

**三层结构**（已实证）：
- 表层（合规叙事）→ 三类参数：`输入参数_反算填表` / `输出参数_真实记录` / `衍生指标_工艺控制压线`
- 中层（实际执行）→ `运筹层决策`（车间主任 + 排产）+ `_多形态`（详 §2.5 [C-8]）
- 深层（身体化经验）→ `身体化经验`（自我保护 + 真实噪声 + 班次配合）

### 2.3 [C-3] Anomaly.scope 增 `cross_form`

**字段路径**：`_meta.anomalies_found[].scope`

**v0.4 取值清单**（v0.3 → v0.4）：
```
single_record / cross_record / cross_batch / cross_product /
cross_supplier / cross_time_window /
cross_form  ← v0.4 新增（命名 ACK 6.5 A）
```

**语义**：form 之间不一致问题（与 record 间不一致 cross_record 区分）。
**实证**：A-019（黄芩饮片 70.94 kg 领料单 L-mat-01 vs 批指令 L-mat-07 / 同一物料同一批次同一数量但 lot 字段不一致）。

### 2.4 [C-4] cross_product 顶层 section schema 化

**字段路径**：顶层 `cross_product_<产品名>_<场景>_<版本>`（如 `cross_product_yanreqing_lotL-mat-07_v0_1`）

**结构**（详细 jsonc 留 5/28 完整起草）：
- `_purpose`（跨产品扩展目的 / F-003 / F-004 验证条件等）
- `_records[]`（各产品物料 / 批次的横向对比记录）
- `_findings_summary`（跨产品发现汇总）
- `_F004_X1_finalize_verdict`（如适用 / 跨产品 σ 矩阵 + 紧贴位置形态）

**实证**：batch-record.json 已落 2 个 cross_product 顶层 section（lot-260201 + T_series）。

### 2.5 [C-7] 跨产品 σ 矩阵字段 schema 化

**字段路径**：`cross_product_*._F004_X1_finalize_verdict._跨产品_σ_矩阵`（嵌入 cross_product 顶层 section）

**字段结构**（详 09 §6.4 + ADR-035 §1.2）：
```jsonc
{
  "_跨产品_σ_矩阵": [
    {
      "产品": string,
      "规程": "区间 / 标杆 / 单边",
      "实际紧贴": string,
      "σ_pp": float,
      "n_批": int,
      "偏离量级_pp": "min~max"
    }
  ]
}
```

**实证**：P1 σ=0.0223 / P2 σ=0.0275。

### 2.6 [C-8] F-001 中层运筹层多形态字段

**字段路径**：`_meta.fundamental_findings.F-001._v0_4_精细化.中层_实际执行_运筹层决策._多形态`

**取值清单**（已实证 2 形态）：
- `跨批切换`（P1 / B1 E1 32h → B2+ E2 10h）
- `同批并行`（P2 / B7 同批 双效 E3 + 单效 E1 + 收膏 E2 = 3 设备并行 / 工艺规程 §4.10.5 明示）

**未来扩展**：case-3 跨车间扩展可能浮现 `第三种形态`（待实证）。

### 2.7 [C-10] 页型 P12 中药材检验原始记录

**取值扩展**：v0.3 P11 → v0.4 P12（接续 v0.1 P01-P08 + v0.2 P09/P10 + v0.3 P11 taxonomy）。

**P12 字段结构**（详细 jsonc 留 5/28 完整起草）：
- `_source_page` / `form_id`（如 `中药材检验原始记录`）
- `性状描述` / `鉴别` / `检查` / `含量测定` 等检验项原始记录字段
- `_性状描述_照抄标准` 标记字段（A-022 候选 / 栀子 16 页实证 / F-001 表层延伸到原始记录层）

**实证**：GO-G-γ Phase 1 / 栀子 16 页 / 性状描述几乎完全照抄标准。

### 2.8 [C-11] F-004._X2_状态 显式 unresolvable 字段

**字段路径**：`_meta.fundamental_findings.F-004._X2_状态`

**字段结构**：
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

---

## 3. v0.3 → v0.4 变更清单（核对用 / 8 项）

| 变更项 | 类型 | 触发 | 影响 | 状态 |
|--------|------|------|------|------|
| F-004 fundamental_finding lock (C-1) | 新增 finding | A-020 / Q-027 / GO-J-ε | `_meta.fundamental_findings.F-004` | ⏳ outline lock / 详细 5/28 |
| F-001 v0.4 三层精细化 lock (C-2) | 新增字段段 | A-016 + A-017 + Q-029 | `F-001._v0_4_精细化` | ⏳ outline lock / 详细 5/28 |
| Anomaly.scope 增 cross_form (C-3) | 取值扩展 | A-019 | `Anomaly.scope` | ✅ outline lock 完整 |
| cross_product 顶层 section schema (C-4) | 新增 section 类型 | GO-G-γ Phase 1+2 | 顶层 `cross_product_*` | ⏳ outline lock / 详细 5/28 |
| 跨产品 σ 矩阵字段 (C-7) | 新增字段段 | GO-D-α + GO-G-γ Phase 2 | `_跨产品_σ_矩阵` | ✅ outline lock 完整 |
| F-001 中层运筹层多形态 (C-8) | 新增字段段 | A-021 | `F-001._v0_4_精细化.中层._多形态` | ✅ outline lock 完整 |
| 页型 P12 (C-10) | taxonomy 扩展 | GO-G-γ Phase 1 栀子 | 页型 11 → 12 类 | ⏳ outline lock / 详细 5/28 |
| F-004._X2_状态 显式 (C-11) | 新增字段 | GO-I-ε 用户决定 | `F-004._X2_状态` | ✅ outline lock 完整 |
| schema_version `0.3.4` → `0.4-outline` | 版本升级 | 本文档 | `_meta.schema_version` | ⏳ 推迟 5/28 |

**押后到 v0.5（3 项 / 详 ADR-035 §2.1 押后表）**：C-5 边界子通道 / C-6 qualitative_LOD / C-9 ABAB 班次。

---

## 4. v0.4 outline → v0.4 完整 lock 路径（5/28 后续 session）

完整 lock session 工作清单：
1. C-1 / C-2 / C-4 / C-10：详细 jsonc 块完整起草（从 batch-record.json 复制 + 精炼）
2. batch-record.json `_meta.schema_version` 0.3.4 → 0.4 + `_schema_upgrade_history` 追加 v0.4 条目
3. F-002 vs F-004 跨产品对比表正式 lock 入 schema 文档
4. F-001 v0.4 三类参数 / 中层多形态 / 深层身体化经验 详细字段定义
5. P12 中药材检验原始记录字段结构完整定义
6. 与 inventory v0.3 + lot-summary 文档的 cross-ref polish

完整 lock session ETA：5/28 后（与 2026-06 月度日记起草节奏对齐 / 不冲突沉淀期）或 6/1 起 08 v0.3 完整初稿启动前。

---

## 5. 锁定声明

**v0.4-outline schema 自 2026-05-15 起 outline lock**。本文档 §2 字段名 + 类型 + 语义为权威。

任何对 v0.4 outline 的偏离视为 bug 或 v0.4 完整 lock session 调整候选。

batch-record.json 既有 records 维持 records-only patch v0.3.4 状态 / 不动 / 待完整 lock session 同步升级。

---

## 6. 参考与延伸

- 实证基础：详 ADR-035 §5 参考与延伸
- ADR-035 §2.1：8 项 lock + 3 项押后清单
- ADR-035 §6：5 个用户决策点（已 ACK / GO-M-ζ）
- 09 文章 v0.2 全本：F-001 v0.4 三层结构 + σ 矩阵核心实证（详 09 §6.4）
- 08 文章 v0.3 partial：F-002 vs F-004 对比表 + §7.3 学术理论锚点

---

> 本 v0.4 是 v0.1 / v0.2 / v0.3 的增量演进，不修订既有字段。所有 v0.1 / v0.2 / v0.3 数据继续有效。
> 文件位置：`huadian/docs/cases/tcm-extraction/schema/extraction-schema-v0.4.md`
> v0.1 / v0.2 / v0.3 锁定快照保留（不删除 / 历史可追溯）
> 本文档 outline 状态 / 详细字段定义留 5/28 后续 session（路径 6.2 B / 用户 ACK）
