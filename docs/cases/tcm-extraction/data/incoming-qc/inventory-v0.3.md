# 来料检验记录数据盘点 v0.3

> Status: **盘点完成 / lot-L1 7 物料主页 OCR 完成 / F-003 候选浮现 / 子通道分析设计 lock**
> Date: 2026-05-10（v0.2 → v0.3 align）
> Owner: 首席架构师
> 数据源：`/Users/lizhuojun/Documents/工作和学习相关文件/批生产记录/药材检验记录/`
> 关联 ADR：ADR-033（schema v0.1 → v0.2 升级 + F-003 候选）
>
> **v0.3 alignment note**：v0.2 §4.2.2 的"下限通道单一三件套（集中度/lot 时间/下游相关）"已被 lot-L1 数据揭示的"主成分 vs 浸出物 vs 微量"子通道形态分裂取代。F-003 候选（A-003 升格）于 2026-05-10 浮现，要求下限通道分析按子通道独立进行，否则反算嫌疑信号被跨指标平均稀释。本 v0.3 §4.2 / §4.3 已按子通道重写。其余章节（数据规模、lot 闭环、PDF 结构、签名链等）内容沿用 v0.2，不重述。

---

## 0. TL;DR

lot-L1 7 物料主页 OCR 已完成（21 页 / 12 个下限指标 / 21+ 个上限指标）。**最关键单 lot 发现**：

| 子通道 | 样本数 | 倍率范围 | 极差 | F-003 含义 |
|--------|-------|---------|------|-----------|
| `main_component` | 2 | 1.043 - 1.07 | **0.027** | smoking gun 雏形（极差极小） |
| `extract` | 4 | 1.25 - 1.68 | 0.430 | 中间形态 |
| `minor_component` | 6 | 1.33 - 2.83 | **1.500** | 远超 LOQ |

极差比 = 1.500 / 0.027 ≈ **55 倍**。三个子通道在单 lot 即呈严格递减，是 F-003 候选的最强单 lot 实证。

但**单 lot 不足以下结论** — 6 批分布检验通过 σ_主成分组 < σ_微量成分组 后才能升 finalized；亦可被 retract。本文档锁定 6 批检验的具体设计。

---

## 1-3 数据规模 / lot 闭环 / PDF 结构

详见 inventory-v0.2.md 同节，内容**完全沿用**，本文档不重述。要点：

- 81 PDF / 1.3 GB，覆盖 3 产品全部主要药材+辅料+包材
- lot-L1 → 批生产记录 lot 闭环已精确建立
- 主页 1-3（每份 9-56 页 PDF 中的高密度数据段）OCR 已 7/22 完成

---

## 4. F-001 二阶检验 v0.3 设计（关键变更）

### 4.1 单批数据"舒适过线"检查 — 双通道 + 三子通道（lot-L1 实证）

#### 上限指标侧（F-002 downward 通道）

详见 lot-L1-summary-v0.1.md §2 跨物料 LOD% 矩阵。**关键判读**：

- 7 物料 6 个 → actual / 2 个 → actual_low_n
- 跨物料汞水平 100x 差异（A-004）= 强 actual 主柱
- 杂质/药屑全部 33.3% LOD 是可疑信号但不足以判 compliance

#### 下限指标侧（F-002 upward 通道 / 三子通道）

| 子通道 | 适用 section | 标准量级 | lot-L1 倍率范围 | 反算难度 | F-003 含义 |
|--------|-------------|---------|-------------------|---------|-----------|
| **main_component** | 含量测定 | ≥30% | 1.04-1.07x | **低** | smoking gun 雏形 |
| **extract** | 浸出物 | 2.5-22% | 1.25-1.68x | 中 | 中间形态 |
| **minor_component** | 含量测定 | <30% | 1.33-2.83x | **高** | ambiguous_lean_actual |

**单批整体下限通道判定**（lot-L1）：
```
下限通道 layer = mixed
  - main_component (n=2) → suspicious_main_component（紧贴 LOQ，反算嫌疑）
  - extract (n=4) → ambiguous（中间倍率，证据不足）
  - minor_component (n=6) → ambiguous_lean_actual（倍率分散，倾向真实）
```

### 4.2 6 批数据分布检验设计 — v0.3 三子通道独立方案（替代 v0.2 单通道三件套）

⚠️ **v0.3 关键改动**：v0.2 的"集中度 / lot 时间 / 下游相关"三件套适用于"假设下限通道是单一形态"的前提，但 lot-L1 实证显示下限通道形态分裂三类。每个子通道需独立检验，否则跨子通道平均会洗掉信号（如 main 组 σ 极小被 minor 组 σ 极大平均稀释）。

#### 4.2.1 上限指标 6 批检验（沿用 v0.2 §4.2.1 不变）

每个上限指标独立分析：分布形态 / 指标间相关性 / lot 内一致性。判定函数：

```
upper_channel_layer(indicator):
    if 极差 ≥ 30 and σ ≥ 10 and 与其他指标 |r| < 0.3:
        return "actual"
    elif 极差 < 10 and 集中在 5-20% LOD and 与其他指标 |r| > 0.7:
        return "compliance"
    else:
        return "tentative_actual"
```

#### 4.2.2 下限指标 6 批检验 — **v0.3 三子通道独立检验**

**(I) main_component 子通道 6 批检验**（lot-L1 候选指标：茯苓 β-葡聚糖 / 海螵蛸 CaCO3）

针对每个 main_component 指标：
- (a) **集中度（核心）**：6 批实测_pct 是否高度集中（σ < 0.5 个百分点 / 极差 < 1 个百分点）？
   - 高度集中 → **F-002 反算 strong evidence**（主成分型反算容易，6 批数据若集中说明被统一 upward 算到"舒适值"）
   - 自然分散（σ ≥ 1 个百分点） → tentative_actual
- (b) **倍率分布**：6 批 _倍率_of_LOQ 是否都在 1.00-1.10x 区间内？
   - 都紧贴 LOQ → 反算嫌疑加深
   - 有 ≥ 1 批 _倍率 > 1.20x → 至少该批是真实测量
- (c) **下游相关性（最强证据）**：6 批 main_component 实测含量 ↔ 提取得率 / 浸膏比重 / 成品含量
   - 高来料含量 lot → 下游各项指标同向变化 → 倾向 actual
   - 来料含量 6 批一致而下游有波动 → 反算嫌疑（来料数字被统一算到目标值）

**判定函数（main_component）**：
```
main_component_layer(indicator):
    σ = std(6 批 实测_pct)
    if σ < 0.5 个百分点 and 倍率全部 ≤ 1.10x and 与下游指标 |r| < 0.3:
        return "compliance_strong"  # F-003 finalized 条件之一
    elif σ < 1.0 个百分点 and 与下游指标 |r| < 0.5:
        return "compliance_lean"
    elif σ ≥ 1.0 个百分点 or 与下游指标 |r| ≥ 0.5:
        return "actual"
    else:
        return "tentative_actual"
```

**(II) extract 子通道 6 批检验**（lot-L1 候选指标：4 个浸出物）

中间形态。判定函数：

```
extract_layer(indicator):
    σ_normalized = std(6 批 _倍率_of_LOQ) / mean(6 批 _倍率_of_LOQ)
    if σ_normalized < 0.05 and 与 lot 时间无关联:
        return "compliance_lean"
    elif σ_normalized > 0.15 and 与 lot 时间有关联:
        return "actual"
    else:
        return "tentative_actual"
```

**(III) minor_component 子通道 6 批检验**（lot-L1 候选指标：6 个微量成分）

针对反算难度高的子通道。判定函数：

```
minor_component_layer(indicator):
    σ_relative = std(6 批 实测_pct) / mean(6 批 实测_pct)
    # 微量成分由于绝对差 0.04-2 个百分点，反算需要伪造小数点后 2-4 位
    if σ_relative < 0.10 and lot 时间无关联 and 与下游 |r| < 0.3:
        return "compliance_suspicious"  # 微量反算嫌疑
    elif σ_relative > 0.30 or lot 时间有合理关联:
        return "actual_strong"  # 微量分布大 = 强 actual 信号
    else:
        return "tentative_actual"
```

#### 4.2.3 F-003 smoking gun 终审判定函数

```
def f003_finalize_or_retract(6_batch_data) -> str:
    σ_main = aggregate_std(main_component 6 批数据)
    σ_extract = aggregate_std(extract 6 批数据)
    σ_minor = aggregate_std(minor_component 6 批数据)

    # 严格递减形态 = F-003 finalized
    if σ_main < σ_extract < σ_minor:
        ratio_min_main = σ_minor / max(σ_main, 0.001)
        if ratio_min_main >= 10:
            return "F-003_finalized_strong"   # 极差比 ≥ 10x
        elif ratio_min_main >= 3:
            return "F-003_finalized_moderate"
        else:
            return "F-003_pending"            # 趋势一致但比例不显著

    # 反向或无序 = F-003 retracted
    elif σ_main >= σ_minor:
        return "F-003_retracted_inverse"     # main 极差比 minor 大 → 反 F-003

    elif σ_main ≈ σ_extract ≈ σ_minor:
        return "F-003_retracted_flat"        # 三组无差异 → 单 lot 巧合

    else:
        return "F-003_inconclusive"          # 部分趋势但有反例
```

**lot-L1 单 lot 极差比预演**：σ_minor / σ_main ≈ 1.500 / 0.027 ≈ **55x**。如果 6 批数据保持此比例 → F-003_finalized_strong。

⚠️ **重要**：单 lot 极差不等同于 6 批 σ。lot-L1 的极差是"7 物料同子通道横向极差"，6 批 σ 是"同物料同指标 6 批纵向 σ"。两个量级在反算行为下都应小，但具体数值可能不同。

### 4.3 v0.3 命题中的 layer 判定 — 三子通道版

来料检验数据**暂归 layer = "tentative_actual"**。最终归层取决于 §4.2 的双通道 + 三子通道分析结果：

| 上限通道判定 | main 子通道 | extract 子通道 | minor 子通道 | 整批 layer | 案例含义 |
|------------|-------------|---------------|--------------|-----------|---------|
| actual | actual | actual | actual_strong | **actual** | F-001/002/003 都获 actual 证据；来料检验是中层 ground truth |
| actual | compliance_strong | actual | actual_strong | **mixed_F003_finalized** | F-003 finalized：主成分被反算 / 微量真做。F-002 双通道命题获完整证据 |
| actual | actual | actual | actual_strong | actual_with_F003_retracted | F-003 retracted（不存在子通道反算难度差异） |
| compliance | compliance_strong | compliance | compliance_suspicious | **compliance** | 来料检验整体反算 — F-001 战场扩大到二阶 ground truth |

**最大概率预期**（基于 F-003 候选 + 单 lot 实证）：
- 上限 actual + main_compliance_strong + extract_actual + minor_actual_strong → **mixed_F003_finalized**
- 这是 F-003 命题价值最高的发现路径

### 4.4 与 v0.2 inventory.md 同节关系

| Section | v0.2 | v0.3 |
|---------|------|------|
| 4.1 单批 | 上限/下限分组 | + 下限按 main/extract/minor 三子通道分析 |
| 4.2.2 下限 6 批 | 单一三件套（集中度/lot 时间/下游） | 三子通道独立检验，每子通道独立判定函数 |
| 4.2.3 综合判定 | 4-cell 矩阵 | + F-003 smoking gun 终审函数 |
| 4.3 整批 layer | 4-cell | 4×3 = 12-cell 三子通道扩展 |

---

## 5. Schema 扩展（v0.2 已 lock，本节为 v0.3 候选）

v0.2 schema 已通过 ADR-033 lock。本 v0.3 inventory 文档**不动 schema**，仅在分析设计层面深化。

未来 v0.3 schema 候选触发：
1. 6 批分布检验完成后，子通道边界值是否需调整（30% / 2% → 其他）
2. 主成分子通道判定函数中 σ < 0.5 个百分点的阈值是否需调整
3. F-003 finalized 后的"主成分必抽 HPLC 谱图"机制（pp.4+ 原始记录）

---

## 6 工作纳入主任务流（v0.3 微调）

| 阶段 | 原范围 | v0.3 调整 |
|------|--------|----------|
| Stage 3 | P1 22 份来料检验 + 6 批批生产 | + lot-L1 7 份已完成 / L2 lot 7 份 + 颠茄 2 lot + 辅料 6 份待续 |
| Stage 4 | 跨批差异分析 + invariants 起草 | + **F-003 smoking gun 检验**：6 批同物料 σ 三子通道计算 + finalize/retract 判定 |
| Stage 5 | 跨产品扩展 | + 各产品下限指标按 v0.3 三子通道分类 / 验证 F-003 跨产品稳健性 |
| Stage 5.5 | 三层代差地图 | 来料检验 vs 批生产记录 + F-003 验证后的子通道差分图 |

---

## 7. Open Questions（v0.3 整理）

| ID | 问题 | 状态 | F-003 关联 |
|----|------|------|-----------|
| Q-001-014 | (历史 / 见 batch-record.json) | resolved 大部分 | — |
| Q-015 | 6 批同物料含量分布形态 | open | 核心 |
| Q-016 | 主 vs 微 σ 是否显著不同 | open（**升级为 F-003 验证核心**）| 核心 |
| Q-017 | 跨产品同物料汞水平是否保持 100x 差距 | open | 上限通道侧 |
| Q-018 | 厂家批号空白与中药材分类是否完全对应 | open | 制度性盲点 |
| **Q-019**（v0.3 新增）| F-003 子通道边界 30% / 2% 在 6 批 + 跨产品后是否需调整？ | open | F-003 边界鲁棒性 |
| **Q-020**（v0.3 新增）| extract 子通道 6 批 σ 是否介于 main 和 minor 之间（中间形态稳定性）？ | open | F-003 三态完整性 |

---

## 8. 下次 session 启动调整

new-session prompt v0.4（建议替换 cowork-project-instructions.md）：

```
（v0.4 增补，基于 v0.3）

Read docs/cases/tcm-extraction/data/incoming-qc/inventory-v0.3.md（已对齐 ADR-033 schema v0.2 + F-003 候选）

OCR 任务可在以下选项中按用户选择：
A. 续完 B1 剩余 84 页（pp.14-19, 23-100）— 接续主线
B. P1剩余 15 份来料检验 PDF 主页（L2 lot 7 份 + 颠茄 2 lot + 辅料 6 份 = 45 页）
C. 混合：先完成P1 22 份来料检验全 lot 闭环，再回 A

OCR 时遵守 schema v0.2 + v0.3 解读规则：
- 上限指标抓 _pct_of_LOD
- 下限指标抓 _倍率_of_LOQ + _subchannel（main_component / extract / minor_component）
- 下限指标 _subchannel 由 section + 标准量级联合决定（详见 schema-v0.2 §2.3）
- 每个 incoming_qc 记录的 _F-001_F-002_indicators_v0.3 必含 _subchannel_breakdown
- F-003 候选验证：每条主成分型记录是 F-003 关键样本，OCR 必抓 _倍率 + 实测_pct 精度
- 记 anomaly 时使用 scope 字段（single_record / cross_record / cross_batch / cross_product）
- 不在没有用户授权的情况下改 schema 或案例命题
```

---

## 9. v0.2 → v0.3 变更清单

| Section | v0.2 | v0.3 | 触发 |
|---------|------|------|------|
| 0 (TL;DR) | 双通道 lot-L1 概要 | + 三子通道极差比 55x smoking gun 雏形 | F-003 候选 |
| 4.1 | 上限/下限分组 | + 下限三子通道（main/extract/minor）单批表 | F-003 候选 |
| 4.2.2 | 单通道三件套 | 三子通道独立判定函数 | F-003 候选 |
| 4.2.3（新增）| - | F-003 smoking gun 终审函数（finalized/retracted/inconclusive 5 态）| F-003 候选 |
| 4.3 | 4-cell 矩阵 | 4×3 = 12-cell 三子通道矩阵 | F-003 候选 |
| 5 | schema v0.2 候选 | schema v0.2 已 lock；v0.3 候选条件改写 | ADR-033 |
| 6.2 | T7-T9 | 不动 / Stage 4 任务待 6 批后细化 | 进度 |
| 7 | Q-015-018 | + Q-019 / Q-020（边界 + 中间形态）| F-003 候选 |
| 8 | new-session prompt v0.3 | new-session prompt v0.4（含 _subchannel 抽取要求）| 子通道字段强制 |

---

> 本盘点文档 v0.3 与 batch-record.json 三子通道字段、ADR-033、schema-v0.2 三向对齐。
> 6 批分布检验完成后，本文档 §4.2 应升级到 v0.4 含 F-003 finalized/retracted 结论。
> v0.1 / v0.2 文件保留作为历史快照，不删除。
