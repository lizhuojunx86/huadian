# Sprint Y 衍生债 — 押后清单（methodology v0.2 cycle 进度 7/8 / 距 100% 仅剩 /03）

> Status: registered
> 来源 sprint: Sprint Y Stage 4 closeout (2026-04-30)
> 总计 5 项押后（2 v0.2 + 3 v0.5）/ 0 项新增

---

## 0. 总览（vs Sprint X 后）

| 维度 | Sprint X 后 | Sprint Y 后 |
|------|-----------|-----------|
| v0.2 押后 | 2 (DGF-N-04 / DGF-N-05) | 2（不变）|
| v0.4 押后 | 0 | 0（不变）|
| v0.5 候选 | 3 | 3（不变 / 但 retro §2.1 提议 v0.1.5 brief-template 重编号 checklist 候选 / 待 Sprint Z 后评估）|
| 累计 patch 落地率 | 28/30 = 93.3% | 28/30 = 93.3%（不变 / Sprint Y 不 land 新 patch）|
| methodology v0.2 doc | 5/8 | **7/8** ⭐⭐ (距 100% 仅剩 /03) |
| zero-trigger sprint 连续 | 9 | **10** ⭐⭐⭐ **里程碑** |

---

## 1. v0.2 押后清单（2 项 / 不变 / 等外部触发）

### 1.1 DGF-N-04 — 跨域 reference impl（合并 DGF-O-03）
### 1.2 DGF-N-05 — EntityLoader.load_subset feature

详见 Sprint U+V residual debts §1。

---

## 2. v0.5 候选清单（3 项 / 不变）

### 2.1 T-V05-FW-002 — methodology/02 v0.2.1 polish §14+§15 cross-ref

**估算**：~15 min。处理时机：v0.5 maintenance sprint 触发时。

### 2.2 T-X02-FW-001 — methodology/04 v0.2.1 polish §8.6 实证 + 反模式

**估算**：~25-35 min。Sprint X 批 2 deferred per 方案 B。

### 2.3 (候选未登记) brief-template v0.1.5 加 "v0.x 大 bump 重编号 checklist" 段

**触发**：Sprint X retro §2.1 + Sprint Y retro §2.1 已识别（连续 2 sprint 同 issue）/ 待 v0.5 maintenance sprint 触发时正式登记。

**估算**：~10 min（brief-template §2 加 checklist 段）

**当前状态**：proposed / 不正式登记押后清单（待 Sprint Z 后 retro §"复发 ≥ 3 次"评估升级）。

---

## 3. methodology v0.2 cycle 剩余 1 doc 进度

per Sprint Y retro §6+§7：

| methodology doc | 当前版本 | 推荐 Sprint | 加段方向 | 估时 |
|-----------------|--------|------------|--------|------|
| /03 identity-resolver | v0.1.2 | **Sprint Z 推荐**（cycle 完成）| Byte-Identical Dogfood Pattern first-class（per Sprint N 实证 / 与 /04 §8 Self-Test Pattern 形成 L1 vs L4 对比）| ~60-90 min |

**Sprint Z 推荐**：/03 → v0.2 → cycle **8/8 = 100%** ⭐⭐⭐ → ADR-031 #7 触发 → **v1.0 评估议程激活**。

---

## 4. v1.0 触发条件评估状态（per ADR-031 §3）

| # | 条件 | Sprint X 后 | Sprint Y 后 | Sprint Z 后预期 |
|---|------|-----------|-----------|----------------|
| 1 | ≥ 5 模块 + ≥ 2 release cycle | ✅ | ✅ | ✅ |
| 2 | ≥ 5 zero-trigger sprint | ✅ (9) | ✅ **10** ⭐⭐⭐ | ✅ (11+) |
| 3 | API 稳定 ≥ 6 个月 | ⏳ | ⏳ | ⏳ |
| 4 | ≥ 1 跨域 ref impl | ❌ | ❌ | ❌ |
| 5 | 第三方 review ≥ 2 person | ❌ | ❌ | ❌ |
| 6 | 累计 v0.x patch ≥ 95% | ⏳ 93.3% | ⏳ 93.3% | ⏳ 93.3% |
| 7 | methodology 7 doc 全 ≥ v0.2 | ⏳ 5/8 | ⏳ **7/8** ⭐⭐ | **✅ 8/8** ⭐⭐⭐ |

→ **Sprint Z 后 v1.0 触发条件状态预期 3/7 ✅ + 2/7 ⏳ + 2/7 ❌**（剩 #4 跨域 ref impl + #5 第三方 review / 等触发）

---

## 5. Sprint Z 候选议程

per Sprint Y retro §7：

1. **A. methodology/03 → v0.2 + cycle 完成 8/8**（强烈推荐 / 1.5 会话 / 大工作 / Byte-Identical Dogfood Pattern first-class / 与 /04 §8 Self-Test Pattern 形成 L1 vs L4 对比）
2. B. v0.5 maintenance（仅 3 候选 / 不急 / **建议 Sprint Z 完成 cycle 后启动**：T-V05-FW-002 + T-X02-FW-001 + brief-template v0.1.5 重编号 checklist 候选）
3. C. 跨域 outreach (legal) — 押后等触发

---

**本债务清单 Sprint Y 起草于 2026-04-30 / Stage 4 closeout / Architect Opus**
