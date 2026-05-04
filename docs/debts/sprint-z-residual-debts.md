# Sprint Z 衍生债 — 押后清单（**methodology v0.2 cycle 完成 ⭐⭐⭐ / ADR-031 §3 #7 触发**）

> Status: registered
> 来源 sprint: Sprint Z Stage 4 closeout (2026-04-30)
> 总计 6 项押后（2 v0.2 + 4 v0.5）/ 1 项新增（T-X02-FW-002 / brief-template v0.1.5）

---

## 0. 总览（vs Sprint Y 后）

| 维度 | Sprint Y 后 | Sprint Z 后 |
|------|-----------|-----------|
| v0.2 押后 | 2 (DGF-N-04 / DGF-N-05) | 2（不变）|
| v0.4 押后 | 0 | 0（不变）|
| v0.5 候选 | 3 | **4（+1 T-X02-FW-002 / brief-template v0.1.5 重编号 + 里程碑庆祝节制 checklist）**|
| 累计 patch 落地率 | 28/30 = 93.3% | 28/30 = 93.3%（不变）|
| methodology v0.2 doc | 7/8 | **8/8 = 100% ⭐⭐⭐ NEW** |
| zero-trigger sprint 连续 | 10 ⭐⭐⭐ | **11 ⭐⭐⭐ (220% over target)** |
| **ADR-031 §3 #7 触发** | ⏳ | **✅ NEW** |
| **v1.0 评估议程** | ⏳ | **✅ 激活 NEW** |

---

## 1. v0.2 押后清单（2 项 / 不变 / 等外部触发）

### 1.1 DGF-N-04 — 跨域 reference impl（合并 DGF-O-03）
### 1.2 DGF-N-05 — EntityLoader.load_subset feature

详见 Sprint U+V residual debts §1。

---

## 2. v0.5 候选清单（4 项 / +1 NEW）

### 2.1 T-V05-FW-002 — methodology/02 v0.2.1 polish §14+§15 cross-ref

**估算**：~15 min。处理时机：v0.5 maintenance sprint 触发时。

### 2.2 T-X02-FW-001 — methodology/04 v0.2.1 polish §8.6 实证 + 反模式

**估算**：~25-35 min。Sprint X 批 2 deferred per 方案 B。

### 2.3 **T-X02-FW-002 — brief-template v0.1.4 → v0.1.5 polish**（NEW / Sprint Z 正式登记）

**估算**：~15-20 min（brief-template §2 加 2 个 checklist 段）

**触发条件已达成**：
- 连续 3 sprint 同 issue（X+Y+Z §修订历史子节重编号需手动修复）
- per /02 §11 P3 复发升级 P2 暗规则达成（但本质是 brief-template 改进 / 不正式升级 P2 / 直接进 v0.5）

**内容**：
- §X.1 v0.x 大 bump 重编号 checklist（per Sprint X retro §2.1 + Sprint Y §2.1 + Sprint Z §2.1）
  - [ ] 父节号重编
  - [ ] 子节号重编（容易遗漏）
  - [ ] cross-ref 内章节引用更新
- §X.2 里程碑庆祝节制段（per Sprint Z retro §2.2）
  - ⭐ 数量与里程碑实际 weight 对齐
  - "等触发"vs"实际触发"区分

**处理时机**：v0.5 maintenance sprint 触发时（per Sprint Z+1 候选 A / 累积 4 候选已达触发条件）。

### 2.4 (候选未登记) /02 v0.2.1 polish §X.X 元 pattern 增补

**触发**：cycle 完成后第三方 review 反馈（如有）/ 当前不主动起。

---

## 3. methodology v0.2 cycle **完成** ⭐⭐⭐ — 终态全表

| methodology doc | Sprint Y 后 | **Sprint Z 后** |
|-----------------|------------|-----------------|
| /00 framework-overview | v0.2 | **v0.2** ✓ |
| /01 role-design | v0.2 | **v0.2** ✓ |
| /02 sprint-governance | v0.2 | **v0.2** ✓ |
| /03 identity-resolver | v0.1.2 | **v0.2 ⭐⭐⭐ NEW** |
| /04 invariant | v0.2 | **v0.2** ✓ |
| /05 audit-trail | v0.2 | **v0.2** ✓ |
| /06 adr-pattern | v0.2 | **v0.2** ✓ |
| /07 cross-stack | v0.2 | **v0.2** ✓ |

**进度**: **8/8 = 100% ⭐⭐⭐**

→ ADR-031 §3 #7 触发条件达成 → v1.0 评估议程激活

---

## 4. v1.0 触发条件评估状态（per ADR-031 §3 / Sprint Z 后）

| # | 条件 | Sprint Y 后 | **Sprint Z 后** |
|---|------|-----------|-----------|
| 1 | ≥ 5 模块 + ≥ 2 release cycle | ✅ | ✅ |
| 2 | ≥ 5 zero-trigger sprint | ✅ (10 / 100% over) | ✅ **11** ⭐⭐⭐ (220% over) |
| 3 | API 稳定 ≥ 6 个月 | ⏳ | ⏳ |
| 4 | ≥ 1 跨域 ref impl | ❌ | ❌ |
| 5 | 第三方 review ≥ 2 person | ❌ | ❌ |
| 6 | 累计 v0.x patch ≥ 95% | ⏳ 93.3% | ⏳ 93.3% |
| 7 | methodology 7 doc 全 ≥ v0.2 | ⏳ 7/8 | ✅ **8/8** ⭐⭐⭐ NEW |

→ **3/7 ✅ + 2/7 ⏳ + 2/7 ❌**

→ **v1.0 评估议程激活**（per ADR-031 §5）/ Layer 2 第一阶段完整化 / 进入维护态

---

## 5. Sprint Z+1 候选议程

per Sprint Z retro §7：

### 5.1 默认推荐 — D 等候触发 ⭐

- 不启动新 sprint / 等外部信号
- 跨域 fork 团队接触 / 第三方 review 邀请 / 等
- D-route §7 Negative Space 哲学一致

### 5.2 用户主动启动选项（按优先级排序）

1. **A. v0.5 maintenance sprint**（5 候选累积已达触发条件 / 含 T-X02-FW-002 brief-template v0.1.5 polish）
2. **B. v0.2.1 polish 单 doc patch**（如 /04 v0.2.1 fold §8.6 deferred）
3. **C. 跨域 outreach 主动启动**（v1.0 #4 + #5 触发探索 / 战略层工作）

---

## 6. cycle 完成后的"维护态"工作流

cycle 完成后 → Layer 2 进入维护态。新工作流：

| 工作 | 触发条件 | 节律 |
|------|---------|------|
| v0.2.x patch | 单 doc 实证 gap 暴露 | 不定时 / per maintenance sprint |
| v0.5 maintenance sprint | ≥ 5 押后候选累积 | ~每 2-3 个月 |
| 跨域 outreach (#4 + #5) | 用户主动驱动 | 不定时 |
| v1.0 评估更新 | 任何 v1.0 触发条件状态变化 | per sprint retro |

---

**本债务清单 Sprint Z 起草于 2026-04-30 / Stage 4 closeout / methodology v0.2 cycle 完成 sprint / Architect Opus** ⭐⭐⭐
