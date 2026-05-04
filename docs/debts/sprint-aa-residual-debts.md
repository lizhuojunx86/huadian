# Sprint AA 衍生债 — 押后清单（**v0.5 押后清单 4 → 1 / 维护态首 sprint 清债**）

> Status: registered
> 来源 sprint: Sprint AA Stage 4 closeout (2026-04-30)
> 总计 3 项押后（2 v0.2 + 1 v0.5 候选未登记）/ Sprint AA 清 3 candidates

---

## 0. 总览（vs Sprint Z 后）

| 维度 | Sprint Z 后 | **Sprint AA 后** |
|------|-----------|-----------|
| v0.2 押后 | 2 (DGF-N-04 / DGF-N-05) | 2（不变 / 等外部触发）|
| v0.4 押后 | 0 | 0（不变）|
| **v0.5 候选** | **4** | **1（候选未登记 / Sprint AA 清 3 candidates）** |
| 累计 patch 落地率 | 28/30 = 93.3% | 28/30 = 93.3%（不变 / Sprint AA 不 land 新 patch / 仅 v0.x.1 polish）|
| methodology v0.2 doc | 8/8 = 100% ⭐⭐⭐ | 8/8（不变 / +2 v0.2.1 patch 不影响 cycle 完成判据）|
| zero-trigger sprint 连续 | 11 ⭐⭐⭐ (220% over) | **12 ⭐⭐⭐ (240% over target)** |

---

## 1. v0.2 押后清单（2 项 / 不变 / 等外部触发）

### 1.1 DGF-N-04 — 跨域 reference impl（合并 DGF-O-03）
### 1.2 DGF-N-05 — EntityLoader.load_subset feature

详见 Sprint U+V residual debts §1。

---

## 2. v0.5 押后清单（1 项 / Sprint AA 清 3 candidates）

### 2.1 (候选未登记) /02 v0.2.1 polish §X.X 元 pattern 增补

**触发**：cycle 完成后第三方 review 反馈（如有）/ 当前不主动起。

### 2.2 ✅ T-V05-FW-002 已清（Sprint AA 批 1）

methodology/02 v0.2 → v0.2.1 §14.4 + §15.4 cross-ref polish 落地。

### 2.3 ✅ T-X02-FW-001 已清（Sprint AA 批 2）

methodology/04 v0.2 → v0.2.1 fold §8.6 实证 + 反模式 落地（per Sprint X 方案 B / 紧凑写法）。

### 2.4 ✅ T-X02-FW-002 已清（Sprint AA 批 3）

brief-template v0.1.4 → v0.1.5 + sprint-templates v0.3.1 → v0.3.2 落地（+§2.5 重编号 checklist + §2.6 里程碑庆祝节制）。

---

## 3. Sprint AA 新发现 / 待评估候选

### 3.1 brief-template v0.1.6 candidate — cross-ref polish 子类基线调整

**触发**：Sprint AA §1.6 新发现 / Docs: cross-ref polish 子类首次独立验证 / -33% 大幅低估。

**估算**：~10-15 min（brief-template §2.1 估时表 cross-ref polish 子类基线从 ~95-105% 调到 ~70-80%）

**当前状态**：**未正式登记押后清单**（per Sprint AA retro §4.2 / 待 ≥ 2-3 次 cross-ref polish dogfood 后再决定 / 不一次性改）。

### 3.2 brief-template v0.1.6 / v0.1.7 candidate — 精简化 (template inflation 反思)

**触发**：Sprint AA §2.3 反思 / brief-template ~370 行 / 持续累积 polish 段有膨胀风险。

**估算**：~20-30 min（重构 §2.5 / §2.6 等 checklist 段 → catalog 引用 / brief 仅 link）

**当前状态**：**未正式登记押后清单**（v0.1.5 不动 / Sprint AB 候选评估）。

---

## 4. v1.0 触发条件评估状态（per ADR-031 §3 / Sprint AA 后）

| # | 条件 | Sprint Z 后 | **Sprint AA 后** |
|---|------|-----------|-----------|
| 1 | ≥ 5 模块 + ≥ 2 release cycle | ✅ | ✅ |
| 2 | ≥ 5 zero-trigger sprint | ✅ (11 / 220% over) | ✅ **12** ⭐⭐⭐ (240% over) |
| 3 | API 稳定 ≥ 6 个月 | ⏳ | ⏳ |
| 4 | ≥ 1 跨域 ref impl | ❌ | ❌ |
| 5 | 第三方 review ≥ 2 person | ❌ | ❌ |
| 6 | 累计 v0.x patch ≥ 95% | ⏳ 93.3% | ⏳ 93.3% |
| 7 | methodology 7 doc 全 ≥ v0.2 | ✅ 8/8 ⭐⭐⭐ | ✅ 8/8 (维持) |

→ **3/7 ✅ + 2/7 ⏳ + 2/7 ❌**（vs Sprint Z 后无变化 / Sprint AA 维护态不影响 v1.0 状态）

---

## 5. Sprint AB 候选议程

per Sprint AA retro §7：

### 5.1 默认推荐 — D 等候触发 ⭐

- 不启动新 sprint / 等外部信号
- v0.5 maintenance 触发条件未达成（候选 ≤ 2 / 阈值 ≥ 3）

### 5.2 用户主动启动选项

1. **A. v0.5 maintenance sprint**（仅 1 candidate + 2 待评估 / 累积 ≤ 2 / 不推荐）
2. **B. 跨域 outreach 主动启动**（战略层工作 / 等用户主动驱动）

### 5.3 推荐

**Sprint AB 默认 D 等候触发**。

---

## 6. cycle 完成后的"维护态"工作流（updated per Sprint AA 实证）

| 工作 | 触发条件 | 节律 | 实证 |
|------|---------|------|------|
| v0.2.x patch | 单 doc 实证 gap 暴露 | 不定时 / per maintenance sprint | ✅ Sprint AA /02 + /04 v0.2.1 |
| **v0.5 maintenance sprint** | ≥ 3 候选累积 | ~每 2-3 个月 | ✅ Sprint AA 首次 |
| 跨域 outreach (#4 + #5) | 用户主动驱动 | 不定时 | ⏳ 等触发 |
| v1.0 评估更新 | 任何 v1.0 触发条件状态变化 | per sprint retro | ✅ Sprint AA retro §1.4 |

---

**本债务清单 Sprint AA 起草于 2026-04-30 / Stage 4 closeout / Architect Opus / Layer 2 维护态首 sprint**
