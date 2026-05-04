# Sprint X 衍生债 — 押后清单（methodology v0.2 cycle 进度 5/8）

> Status: registered
> 来源 sprint: Sprint X Stage 4 closeout (2026-04-30)
> 总计 5 项押后（2 v0.2 + 3 v0.5）/ 1 项新增（T-X02-FW-001）

---

## 0. 总览（vs Sprint W 后）

| 维度 | Sprint W 后 | Sprint X 后 |
|------|-----------|-----------|
| v0.2 押后 | 2 (DGF-N-04 / DGF-N-05) | 2（不变）|
| v0.4 押后 | 0 | 0（不变）|
| v0.5 候选 | 2 | **3（+1 T-X02-FW-001 / 方案 B deferred）**|
| 累计 patch 落地率 | 28/30 = 93.3% | 28/30 = 93.3%（不变 / Sprint X 不 land 新 patch）|
| methodology v0.2 doc | 3/8 | **5/8** ⭐ (过半线) |
| zero-trigger sprint 连续 | 8 | **9** ⭐⭐ |

---

## 1. v0.2 押后清单（2 项 / 不变 / 等外部触发）

### 1.1 DGF-N-04 — 跨域 reference impl（合并 DGF-O-03）
### 1.2 DGF-N-05 — EntityLoader.load_subset feature

详见 Sprint U+V residual debts §1。

---

## 2. v0.5 候选清单（3 项 / +1 / 不急触发 maintenance）

### 2.1 T-V05-FW-001 — methodology/06 v0.2 起草时 fold ADR-032 §5 retroactive lessons

**状态**：✅ **已 fold per Sprint X 批 1**（/06 §8.4.1 Retroactive ADR Lessons Learned）/ 转为 closed 押后清单。

### 2.2 T-V05-FW-002 — methodology/02 v0.2.1 polish §14+§15 cross-ref

**估算**：~15 min

**处理时机**：v0.5 maintenance sprint 触发时（≥ 5 候选累积 / 当前 3 / 不急）。

### 2.3 **T-X02-FW-001 — methodology/04 v0.2.1 polish §8.6 实证 + 反模式**（NEW / Sprint X 批 2 deferred per 方案 B）

**估算**：~25-35 min（fold 进 /04 §8.6 / 加段 + 反模式 sub-section）

**处理时机**：v0.5 maintenance sprint 触发时 / OR Sprint Z+ methodology v0.2 cycle 完成同 sprint fold（per Sprint X retro §3.1 方案 B 标准节律）。

**deferred 内容**：
- §8.6.1 Sprint O 4/4 catch 详细实证（具体 SelfTest impl 例 + transaction rollback verify）
- §8.6.2 self-test 反模式（无 transaction rollback / query 与 invariant 共享模板 / 仅断言 row count 等）

**触发条件**：
- v0.5 maintenance sprint 启动（≥ 5 candidates）
- OR /04 doc 体量阈值上调（如 600 → 700）的 stop-rules patch ADR
- OR Sprint Z+ methodology v0.2 cycle 完成（8/8）后专门 polish sprint

---

## 3. methodology v0.2 cycle 剩余 3 doc 进度

per Sprint X retro §7：

| methodology doc | 当前版本 | 推荐 Sprint Y+N | 估时 |
|-----------------|--------|---------------|------|
| /00 framework-overview | v0.1.1 | **Sprint Y 推荐**（cross-doc 网状图）| ~30-40 min |
| /01 role-design | v0.1.2 | **Sprint Y 推荐**（Sprint M+role-templates 实证支撑）| ~50-70 min |
| /03 identity-resolver | v0.1.2 | **Sprint Z 推荐**（byte-identical dogfood pattern first-class）| ~60-90 min |

**Sprint Y 推荐 fold**：/00 + /01（小+中 / 1 会话紧凑）→ cycle 5/8 → 7/8。

**Sprint Z 推荐 fold**：/03（大 / 1.5 会话）→ cycle 7/8 → **8/8** ⭐ → ADR-031 #7 触发。

---

## 4. v1.0 触发条件评估状态（per ADR-031 §3）

| # | 条件 | Sprint W 后 | Sprint X 后 |
|---|------|-----------|-----------|
| 1 | ≥ 5 模块 + ≥ 2 release cycle | ✅ | ✅ |
| 2 | ≥ 5 zero-trigger sprint | ✅ (8) | ✅ **9** ⭐⭐ |
| 3 | API 稳定 ≥ 6 个月 | ⏳ | ⏳ |
| 4 | ≥ 1 跨域 ref impl | ❌ | ❌ |
| 5 | 第三方 review ≥ 2 person | ❌ | ❌ |
| 6 | 累计 v0.x patch ≥ 95% | ⏳ 93.3% | ⏳ 93.3% |
| 7 | methodology 7 doc 全 ≥ v0.2 | ⏳ 3/8 | ⏳ **5/8** ⭐ (过半) |

→ 持续强化 #2 + #7 / 不变其他 / Sprint Z 后 #7 预期触发

---

## 5. Sprint Y 候选议程

per Sprint X retro §8：

1. **A. methodology v0.2 cycle 持续**（推荐 / 1 会话紧凑 / 推 /00 + /01）：
   - /00 v0.1.1 → v0.2（加 cross-doc 网状图 / 8 doc 互引图）
   - /01 v0.1.2 → v0.2（Sprint M+role-templates v0.2.1+0.3.1 实证支撑 + ADR-032 retroactive 对架构师角色的影响）
2. B. v0.5 maintenance（v0.5 仅 3 候选 / 不急 / 可与 Sprint Z+ cycle 完成时一并 polish）
3. C. 跨域 outreach (legal) — 押后等触发

---

**本债务清单 Sprint X 起草于 2026-04-30 / Stage 4 closeout / Architect Opus**
