# ADR-034 — Case-2 Schema v0.3: dual_limit 子通道 6 类 + P11 + 三维交互 + 时间维度

- **Status**: accepted
- **Date**: 2026-05-10
- **Authors**: 首席架构师（Claude）+ 用户（前本草堂制药负责人）批准（GO-C-α）
- **Related**:
  - ADR-028（D-route 战略转型）
  - ADR-033（Case-2 schema v0.1 → v0.2 升级 / incoming_qc 正式纳入 + 3 子通道）
  - `docs/cases/tcm-extraction/schema/extraction-schema-v0.2.md`（v0.2 lock 文档 / 完整保留）
  - `docs/cases/tcm-extraction/schema/extraction-schema-v0.3.md`（v0.3 lock 文档 / 本 ADR 同步起草）
  - `docs/cases/tcm-extraction/data/pilot-WK-B1/batch-record.json`（22 records / 11 anomalies / 22 open questions / 145 KB）
  - `docs/cases/tcm-extraction/data/incoming-qc/lot-L1-summary-v0.1.md`
  - `docs/cases/tcm-extraction/data/incoming-qc/lot-L2-and-auxiliary-summary-v0.1.md`（A-006~A-011 实证）
- **Supersedes**: 无（v0.2 完整保留 / 仅增量扩展）

---

## 1. Context

### 1.1 案例时间锚（截至 2026-05-10）

- Stage 0 ~ Stage 2 完成 ✅
- Stage 3 Path C 进展：**B 段 22/22 = 100% P1 lot 闭环完成**；A 段 16/100
- F-001 / F-002 已锁；**F-003 候选已升级到 `candidate_lotL1_lotL2_strong_evidence`**（22 物料 × 6 子通道实证）
- ADR-033 完成 schema v0.1 → v0.2 / 3 子通道（main/extract/minor）

### 1.2 v0.2 schema 的盲点（GO-B-α 后浮现）

GO-B-α（lot-L2 7 物料 + 颠茄 2 lot + 辅料 3 + 包材 3 = 15 PDF）跨 lot 跨物料分析浮现 6 个 v0.2 盲点：

**(1) dual_limit 子通道未涵盖（A-010）**：v0.2 `_subchannel` 仅 3 类（main/extract/minor），但发现 4 类物料中存在 dual_limit 指标：
- 颠茄浸膏 天仙子胺 8.3-11.0 mg/g（中间体 dual_limit）
- 玉米淀粉 pH 4.5-7.0（辅料 dual_limit）
- 明胶胶囊 干燥失重 12.5-17.5%（辅料 dual_limit）
- PVC 加热伸缩率 ±6% / 尺寸公差（包材 dual_limit）
- 铝箔 粘合剂涂布差异 ±10% / 尺寸公差（包材 dual_limit）

**(2) P11 物料接收初验记录未涵盖（A-011）**：PVC L-mat-06 PDF 第 3 页是 `SOP-T-J008-001` 物料接收初验记录，含 7+ 项包装/外观/资质检查 + 3 个新签名角色（接收初验员/复核/QA确认）。v0.2 P09 / P10 只涵盖检验报告 + 放行单/请验单。

**(3) A-002 三维交互机制（A-007）**：v0.2 假设"中药材分类↔厂家批号空白"被 22 物料 6 供应商数据推翻。实际是 (供应商 × 物料分类 × 时间) 三维交互。

**(4) SOP 跨 lot 演进未建模（A-006）**：6-7 个月内 10 物料 100% SOP 升级。v0.2 schema 无时间维度建模。

**(5) 包材代码前缀不一致**：PVC `NB001`（无 WB-）vs 铝箔 `WB-NB017`（有 WB-）。v0.2 假设"前缀↔分类 1:1"破坏。

**(6) F-002 命题适用范围（A-010 衍生）**：F-002 v0.2 命题"含量标准只设下限 / upward 反算偏向"对中间体 / 辅料 / 包材（dual_limit 标准）**不适用** — "高即好"话语在这些物料类无文化语境。

### 1.3 不升级的代价

如果保持 v0.2：
- `_subchannel` 的 dual_limit 情况只能塞入字符串备注，无法做 6 类 σ_主 < σ_次 检验
- P11 物料接收初验记录数据无法系统化记录
- 跨 lot SOP 演进只能散落在 anomaly 备注，Stage 4 时间序列分析无据
- F-002 命题继续误用到中间体/辅料/包材，会产生错误结论

### 1.4 升级的边界

不在 v0.3 范围内的：
- HPLC 谱图 / TLC 板照片等"二阶 ground truth"原始记录的 schema（pp.4+ 待 Stage 5）
- Stage 5.5 三层代差地图字段
- F-003 升 finalized（仍是 candidate / 待 6 批数据）
- 跨产品扩展引发的新物料分类（参乌鲜蛋 / 95% 乙醇 / 维生素 E 等待 Stage 5）

---

## 2. Decision

### 2.1 升级 schema v0.2 → v0.3（完全向前兼容）

新建独立文档 `extraction-schema-v0.3.md`，v0.2 文档保留为历史 lock 快照不修订。

**v0.3 增量内容**（详见 schema-v0.3.md §6 变更清单）：

1. `_subchannel` 取值 3 → **6 类**：新增 `dual_limit_intermediate` / `dual_limit_excipient` / `dual_limit_packaging`
2. 页型 P09/P10 → 增加 **P11 物料接收初验记录**（含 7+ 项检查字段 + 3 签名角色）
3. `_供应商_批号填写历史` 字段（A-002 v0.3 三维交互机制）
4. `_meta._SOP_跨lot_演进` 字段（时间维度建模）
5. `_代码前缀_v2_映射` 字段（包材前缀不一致建模）
6. F-002 `_v0_3_适用范围` 子字段（命题适用范围限定）
7. `Anomaly.scope` 取值扩展：增加 `cross_supplier` / `cross_time_window`
8. `_subchannel_breakdown` 字段支持 6 类
9. `_数学一致性_检查` 字段（用于 PVC L-mat-06 类内部数学不一致）
10. `_meta.schema_version` `0.2` → `0.3`

### 2.2 不动的部分

- v0.1 / v0.2 schema 文档：完整保留为 lock 快照
- 既有 batch-record.json 数据：v0.1 / v0.2 字段不变；v0.3 新字段以补充方式追加
- F-001 / F-002 / F-003 fundamental_findings：内容保留；F-002 增加 `_v0_3_适用范围` 子字段
- inventory v0.3：内容沿用（覆盖三子通道核心设计，v0.3 schema 的 dual_limit 扩展不影响 inventory 主分析逻辑）
- F-003 status：保持 `candidate_lotL1_lotL2_strong_evidence`（不升 finalized / 待 6 批数据）

### 2.3 v0.3 升级对 GO-B-α 已落字段的回溯整合

GO-B-α 在 batch-record.json 中已经用了 dual_limit_intermediate / dual_limit_excipient / dual_limit_packaging 等字符串作为 `_subchannel` 字段值。这些是"v0.3 schema 候选"的实证基础。本 ADR 把这些字段值正式锁定为 v0.3 schema 的合法取值，**无需重抽数据**。

---

## 3. Consequences

### 3.1 即时影响（本 session）

- batch-record.json: `_meta.schema_version` 0.2 → 0.3 + `_schema_upgrade_history` 追加 v0.3 条目
- case-2 §10 追加 §10.7 节（GO-B-α + GO-C-α 综合记录）
- inventory v0.3：不动（已覆盖核心设计）

### 3.2 短期影响（Stage 3 剩余 + Stage 4）

- A 段 B1 剩余 84 页 OCR 时使用 v0.3 schema
- P1其余 5 批 T + 7 批 Q OCR 时按 v0.3 输出
- Stage 4 跨批分析按 6 子通道独立 σ 检验（main / extract / minor 沿用 v0.2 设计 + 3 个 dual_limit 子通道新设计）

### 3.3 长期影响（Stage 5 + Layer 2 方法论）

- Stage 5 跨产品扩展（参乌 / P2）按 v0.3 schema 输出；可能触发 v0.4（新 `_物料分类_v2` 取值）
- F-003 6 批验证：6 子通道独立 σ 计算 + smoking gun 终审函数（lot-L1 极差比 55x / 跨 lot 极差比 ~370x / 6 批σ 待验证）
- D-route Layer 2 方法论文章潜在选题：
  - "F-001 三层代差 + 时间维度演进" — A-006 案例
  - "F-002 反算难度与指标量级关系" — F-003 命题
  - "AI 知识工程跨文化跨学科应用的话语偏向识别" — F-002 v0.3 限定 + dual_limit 物料类发现
  - "合规叙事的子通道反算检测方法论" — F-003 候选

### 3.4 风险与回滚

**风险 1：dual_limit 子通道边界值待调整**：lot-L1+L2 是 2 批 4 lot 数据点，n 仍小。例如颠茄浸膏 dual_limit_intermediate 仅 2 个数据点（L1 居中 9.7 / 241201 偏上 10.1），不能下结论。
- 缓解：等 6 批 / 跨产品后再调；v0.4 可调整 dual_limit 子通道判定函数

**风险 2：P11 字段过度建模**：仅 1 个样本（PVC L-mat-06），其他 21 份 PDF 未见。可能是 PVC L-mat-06 偶发，不是普遍存在的页型。
- 缓解：schema 字段以 optional 方式定义；不强制要求所有 record 有 P11；扩展后看普遍性

**风险 3：F-002 v0.3 限定过窄**：限定到"中药材成品/饮片含量测定"可能漏掉中间体某些 upward 反算情形（如颠茄浸膏 6.22 mg/g 东莨菪内酯 11.31x 是 minor_component / 中间体上 F-002 仍可能适用，只是 dual_limit 不适用）
- 缓解：F-002 `_v0_3_适用范围` 字段明确分 section 而非分物料类；保留可调整空间

**回滚机制**：极端情况下，v0.3 升级可被"忽略"（不删除 v0.3 文档，但 v0.4 不引用），所有 OCR 回到 v0.2 兼容字段；但向前累积的 11 anomalies + 22 records 字段仍保留为有效信息。

### 3.5 与 D-route 战略的对接

本 ADR 是 Case-2 的第二个正式 ADR（继 ADR-033）。D-route §3.4 跨领域案例机制要求每个案例对框架抽象有产出。本 ADR 的框架抽象产出：

- **多类 invariants 模式**：6 子通道 `_subchannel` × 6 类 `_物料分类_v2` × N 类 `_layer_classification_v2` 三维标记 = 案例 invariants 命名空间的工程化实现
- **audit_triage 时间维度**：`Anomaly.scope.cross_time_window` 把 audit_trail 从静态扩展到时间序列
- **跨实体（cross_supplier）关系建模**：`_供应商_批号填写历史` 是 identity_resolver 在跨外部实体的扩展
- **methodology Layer 2 实证素材**：F-001 + F-002 + F-003 三个 finding 共同构成"AI 知识工程在合规叙事领域的多维度反向计算识别框架"的丰满实证基础

---

## 4. Implementation

| 步骤 | 文件 | 状态 |
|------|------|------|
| 起草 schema-v0.3.md | `huadian/docs/cases/tcm-extraction/schema/extraction-schema-v0.3.md` | ✅ 完成 |
| 起草本 ADR (ADR-034) | `huadian/docs/decisions/ADR-034-...md` | ✅ 完成（本文件） |
| schema_version 0.2 → 0.3 | `batch-record.json` `_meta.schema_version` + `_schema_upgrade_history` | ⏳ 进行中 |
| F-002 加 `_v0_3_适用范围` 字段 | `batch-record.json` `_meta.fundamental_findings.F-002` | ⏳ 进行中 |
| case-2 §10 追加 §10.7 | `case-2-tcm-manufacturing-evaluation.md` | ⏳ 进行中 |

---

## 5. 参考与延伸

- 实证基础（lot-L1 单 lot）：`docs/cases/tcm-extraction/data/incoming-qc/lot-L1-summary-v0.1.md`
- 实证基础（跨 lot 跨物料）：`docs/cases/tcm-extraction/data/incoming-qc/lot-L2-and-auxiliary-summary-v0.1.md`
- ADR-033：v0.1 → v0.2 升级（incoming_qc + 3 子通道）
- schema-v0.2.md：v0.2 lock 快照
- schema-v0.3.md：本 ADR 同步起草的 v0.3 lock 文档
- batch-record.json：22 records / 11 anomalies / 22 open questions / 145 KB / 5328 行 — 实证数据集

### 5.1 v0.3 后下一步触发链

```
v0.3 (本 ADR) → 等待 Stage 4 (6 批P1 σ 检验 / Q-016)
              → F-003 finalize 或 retract
              → 触发 v0.4 候选（边界值调整 / 新案例命题 / 二阶检验机制）
              → 或触发 D-route Layer 2 方法论文章 v0.1 起草
```

---

> 本 ADR 是 Case-2 第二个正式 ADR。后续 Case-2 ADR（ADR-035 = 6 批分布检验 F-003 升级 / 或跨产品扩展 v0.4 升级）按编号链延续。
