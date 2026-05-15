# ADR-033 — Case-2 Schema v0.2: incoming_qc 正式纳入 + 下限指标子通道

- **Status**: accepted
- **Date**: 2026-05-10
- **Authors**: 首席架构师（Claude）+ 用户（前本草堂制药负责人）批准
- **Related**:
  - ADR-028（D-route 战略转型）— Layer 3 跨领域案例机制
  - ADR-029（双许可证）— 案例数据治理基础
  - `docs/cases/tcm-extraction/schema/extraction-schema-v0.1.md`（已 lock 的 v0.1 / 不修订）
  - `docs/cases/tcm-extraction/schema/extraction-schema-v0.2.md`（v0.2 lock 文档 / 本 ADR 同步起草）
  - `docs/cases/tcm-extraction/data/incoming-qc/inventory-v0.2.md`（驱动了 v0.2 双通道设计 / 本 ADR 后将进一步升 v0.3）
  - `docs/cases/tcm-extraction/data/pilot-WK-B1/batch-record.json`（v0.2 schema 验证数据 / `_F-001_F-002_indicators_v0.3` 已落实例）
  - `docs/cases/tcm-extraction/data/incoming-qc/lot-L1-summary-v0.1.md`（A-003 实证基础）
- **Supersedes**: 无（v0.1 完整保留）

---

## 1. Context

### 1.1 案例时间锚

Stage 0（工艺规程提取 ✅）+ Stage 1（pilot OCR 16/100 页 ✅）+ Stage 2（schema v0.1 lock ✅）+ F-001 浮现 + F-002 浮现 + Stage 3 进行中（lot-L1 7 物料来料检验主页 OCR ✅ / 共 21 页）。

**当前位置**：lot-L1 单 lot 切面分析完成；6 批分布检验未启动；跨产品扩展未启动。

### 1.2 v0.1 schema 的盲点

v0.1 schema lock 时（2026-05-08 / pilot 通过即时）有两个未涵盖的领域：

1. **来料检验数据流未纳入** — 当时仅基于批生产记录 OCR 经验定 schema；之后用户提供的 81 份来料检验 PDF（1.3 GB）通过 inventory-v0.1 + batch-record.json `incoming_qc_来料检验[]` 临时定义结构，schema 主文档未同步
2. **下限指标的形态多样性未识别** — v0.1 只设单一 `_倍率_of_LOQ` 字段，未能区分主成分型（茯苓 β-葡聚糖 / 海螵蛸 CaCO3）vs 微量成分型（甘草苷 / 芍药苷 / 延胡索乙素）的反算难度差异

### 1.3 触发事件（A-002 + A-003）

lot-L1 7 物料来料检验主页横向比对（2026-05-10）涌现两个跨记录级别的发现：

- **A-002**：请验单"厂家批号"字段空白 3/7 = 43%（三七 / 海螵蛸 / 延胡索）。三个空白记录共同特征：物料代码无 "-Y" 后缀（"中药材"分类），由我厂自加工成中间体（Q-prefix lot）。这是制度性盲点，非数据丢失。
- **A-003**：12 个下限指标按"标准量级"分两类形态——
  - 主成分型（标准 ≥50% / ≥86%）：1.04-1.07 倍 LOQ（紧贴）
  - 微量成分型（标准 ≤6%）：1.33-2.83 倍 LOQ（远超）
  - F-002 upward 反算在两类形态上的"造假难度"截然不同；统一处理会洗掉信号

### 1.4 不升级的代价

如果保持 v0.1：
- A-002 的"厂家批号空白"在 v0.1 schema 下是 violation（必填字段为 null），后续每个空白都要单独处理，无法系统化记录
- A-003 在 v0.1 下下限指标只有平均 _倍率，主成分型反算嫌疑被微量型平均"稀释"
- 后续 6 批 + 跨产品 OCR 都要按 v0.1 处理，到 Stage 4 才发现 A-003，会要求**回填 ~100+ 条记录**的子通道字段——成本高于现在前瞻升级

### 1.5 升级的边界

不在 v0.2 范围内的：
- HPLC 谱图、TLC 板照片等"二阶 ground truth"原始记录的 schema（pp.4+ 待 Stage 5 评估）
- Stage 5.5 三层代差地图的显式字段（仍待 6 批 + 跨产品后才有实证基础）
- 案例命题（F-001 / F-002）— 不动 fundamental_findings 数组的既有内容；F-003 仅作为 candidate 状态加入（不锁定）

---

## 2. Decision

### 2.1 升级 schema v0.1 → v0.2（完全向前兼容）

新建独立文档 `extraction-schema-v0.2.md`，v0.1 文档保留为历史 lock 快照不修订。

**v0.2 增量内容**（详见 schema-v0.2.md §9 变更清单）：

1. `incoming_qc_来料检验[]` 顶层 section 正式 schema（之前在 inventory-v0.1 + batch-record 临时定义）
2. 下限指标 `_subchannel` 字段（main_component / extract / minor_component）+ 边界值定义（≥30% / ≥2% / <2%）
3. `_物料分类_v2` 字段（饮片 / 中药材 / 中间体 / 动物源 / 辅料 / 包材）
4. `厂家批号` 类型放宽为可空 + `_厂家批号_异常` 文本字段
5. `_检查项缺失` 字段（茯苓白及无重金属 / 海螵蛸无水分灰分等）
6. `_layer_classification_v2` 取值清单标准化（8 态）
7. `_F-001_F-002_indicators_v0.3` 正式纳入 schema（之前事后追加）
8. `_subchannel_breakdown` in 下限指标侧_证据（按子通道分组）
9. `Anomaly.scope` 字段（single_record / cross_record / cross_batch / cross_product）
10. P09（来料检验报告主页）/ P10（物料放行单+请验单）页面类型扩展
11. `_meta.schema_version` `0.1-pilot` → `0.2`

### 2.2 把 A-003 升格为 F-003 候选 fundamental finding

在 batch-record.json `_meta.fundamental_findings` 数组追加 F-003，状态标 `candidate_pending_6_batch_validation`（**不是已锁定**，需 6 批分布检验通过 σ_主 < σ_微 smoking-gun 后才能升 finalized）。

claim：**"F-002 upward 反算的实施难度随下限指标量级变化。主成分型（≥30%）反算容易，微量成分型（<6%）反算困难。F-001 二阶检验下限通道必须按子通道再分组分析，否则反算嫌疑信号被跨指标平均稀释。"**

broader methodological value（方法论价值）：跨案例可迁移——任何"上限存在反算嫌疑"领域，反算难度都是指标量级的函数。huadian D-route Layer 2 方法论文章潜在选题。

### 2.3 不动的部分

- v0.1 schema 文档：保留为 lock 快照，**不修订**
- 既有 batch-record.json 数据：v0.1 字段不变；v0.2 新字段以补充方式追加
- F-001 / F-002 fundamental_findings：内容不修订
- A-005 签名链 4→9 人扩展：**不在本 ADR 范围**（已在 GO-A 之外，等用户单独批准后处理）
- inventory-v0.2.md：本次同步升级到 v0.3（独立任务 / 与本 ADR 配套）

---

## 3. Consequences

### 3.1 即时影响（本 session）

- batch-record.json：7 个 incoming_qc 记录补全 `_subchannel` 字段（12 个下限指标分别归类）；schema_version 升级
- inventory-v0.2.md → v0.3.md（独立新建）：§4.2.2 下限通道 6 批检验由"3 检验"分为"3 子通道独立检验"
- case-2-tcm-manufacturing-evaluation.md §10：Stage 3 lot-L1 节追加（含 v0.2 schema 升级 + F-003 候选事件）

### 3.2 短期影响（Path C 下批 OCR）

- L2 lot 7 份饮片 + 颠茄 2 lot + 辅料 6 份 OCR 时按 v0.2 schema 输出（含 `_subchannel`）
- 6 批 T + 7 批 Q OCR 数据可直接做 σ_主 < σ_微 smoking-gun 检验
- A-002 / A-005 类异常按 cross_record scope 字段持续累积

### 3.3 长期影响（Stage 4 / Stage 5）

- Stage 4 跨批分析自动化：从 v0.2 数据按 `_subchannel` × `_物料分类_v2` × `_layer_classification_v2` 三维交叉，直接产出"子通道 × 物料类型"的反算嫌疑矩阵
- Stage 5 跨产品扩展：参乌 31 份 + P2 28 份 OCR 时已有 v0.2 schema，无需 v0.3 升级（除非新 `_物料分类_v2` 取值出现，如鲜蛋）
- F-003 候选验证：6 批同物料数据足够后，按 σ_主 < σ_微 + 子通道独立 σ 检验判定升 finalized 还是 retract

### 3.4 风险与回滚

- **风险**：边界值 30% / 2% 是 lot-L1 7 物料经验值，可能需调整。若调整超过 1 个百分点（如改为 40% / 5%）→ 触发 v0.3 schema 升级，但已分类的记录不需重抽（_subchannel 字段值会跨边界发生变化但语义连续）
- **风险**：F-003 在 6 批数据中被 retract 的概率非零（如果实际 σ_主 ≈ σ_微 / 主成分型与微量型反算难度无显著差异）。状态字段 `candidate_pending_6_batch_validation` 即为此预留——不锁定，可回退
- **回滚**：极端情况下，v0.2 升级可被"忽略"（不删除 v0.2 文档，但 v0.3 不引用），所有 OCR 回到 v0.1 兼容字段；但向前累积的 cross_record anomalies + `_subchannel` 字段仍保留为有效信息

### 3.5 与 D-route 战略的对接

本 ADR 是 Case-2 的第一个正式 ADR。D-route §3.4 跨领域案例机制要求每个案例对框架抽象有产出。本 ADR 的框架抽象产出：

- **invariants pattern**：`_subchannel` × `_物料分类_v2` × `_layer_classification_v2` 三维标记是 invariants 命名空间的一种工程化实现
- **audit_triage pattern**：`Anomaly.scope` 字段把 audit_triage 从单记录扩展到跨记录维度，是 v0.4 audit_trail 模式的演进锚点
- **methodology Layer 2**：F-003 候选 + F-002 + F-001 共同构成 huadian D-route Layer 2 方法论文章"AI 知识工程在合规叙事领域的反向计算识别框架"的实证基础

---

## 4. Implementation

| 步骤 | 文件 | 状态 |
|------|------|------|
| 起草 schema-v0.2.md | `huadian/docs/cases/tcm-extraction/schema/extraction-schema-v0.2.md` | ✅ 完成 |
| 起草本 ADR | `huadian/docs/decisions/ADR-033-...md` | ✅ 完成（本文件）|
| F-003 候选写入 batch-record `_meta.fundamental_findings` | `batch-record.json` | ⏳ 进行中 |
| 7 物料下限指标 `_subchannel` 字段补全 | `batch-record.json` | ⏳ 进行中 |
| schema_version `0.1-pilot` → `0.2` | `batch-record.json` | ⏳ 进行中 |
| inventory v0.2 → v0.3 | `inventory-v0.3.md` | ⏳ 进行中 |
| case-2 §10 进度日志追加 | `case-2-tcm-manufacturing-evaluation.md` | ⏳ 进行中 |

---

## 5. 参考与延伸

- 实证基础：`docs/cases/tcm-extraction/data/incoming-qc/lot-L1-summary-v0.1.md` §3.1 / §3.2 / §6
- 双通道初步设计：`docs/cases/tcm-extraction/data/incoming-qc/inventory-v0.2.md` §4.2
- F-001 fundamental finding：`batch-record.json` _meta.fundamental_findings[0]
- F-002 fundamental finding：`batch-record.json` _meta.fundamental_findings[1]
- F-003 候选（待写入）：`batch-record.json` _meta.fundamental_findings[2]

---

> 本 ADR 是 Case-2 案例首个正式 ADR。后续 Case-2 ADR（如 ADR-034 = 6 批分布检验 F-003 升级判定）将延续本编号链。
