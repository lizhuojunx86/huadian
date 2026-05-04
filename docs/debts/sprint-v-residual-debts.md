# Sprint V 衍生债 — 押后清单（v0.4 全清里程碑 / methodology v0.2 cycle 起步 1/8）

> Status: registered
> 来源 sprint: Sprint V Stage 4 closeout (2026-04-30)
> 总计 4 项押后（2 v0.2 + 0 v0.3 + 0 v0.4 ⭐ + 2 v0.5）

---

## 0. 总览

Sprint V 收口后（vs Sprint U 后）：

| 维度 | Sprint U 后 | Sprint V 后 |
|------|-----------|-----------|
| v0.2 押后 | 2 (DGF-N-04 / DGF-N-05) | 2（不变 / 等外部触发）|
| v0.3 押后 | 0 | 0（不变）|
| v0.4 候选 | 4 | **0** ⭐（Sprint V fold 4 项 land）|
| v0.5 候选 | 0 | **2**（新增 / Sprint V retro §6）|
| 累计 patch 落地率 | 24/26 = 92.3% | **28/30 = 93.3%** ⭐ |
| methodology /02 版本 | v0.1.1 | **v0.2** ⭐（v0.x cycle 起步 / 1/8 doc）|
| 7 sprint zero-trigger 连续 | 6 | **7** ⭐⭐ |

---

## 1. v0.2 押后清单（2 项 / 不变 / 等外部触发）

### 1.1 DGF-N-04 — 跨域 reference impl（合并 DGF-O-03 / 等案例方接触）
### 1.2 DGF-N-05 — EntityLoader.load_subset feature

详见 Sprint U residual debts §1.

---

## 2. v0.3 + v0.4 押后清单（**0 项** ⭐）

无押后。Sprint T fold T-V03-FW-005 + Sprint V fold 4 v0.4 候选 = 全清。

---

## 3. v0.5 候选清单（2 项 / 新增）

### 3.1 T-V05-FW-001 — methodology/06 v0.2 起草时 fold ADR-032 §5 retroactive lessons

**估算**：~10 min（fold 进 methodology/06 v0.2 加段 / 与 /06 v0.2 起草同 sprint）

**来源**：Sprint V retro §3.2 / ADR-032 §5 retroactive ADR 模板应该在 methodology/06 v0.2 first-class 收录（vs 仅 ADR §5 临时记录）。

**处理时机**：Sprint W+ 起草 methodology/06 v0.2 时同 sprint fold（不是独立 debt）。

### 3.2 T-V05-FW-002 — methodology/02 v0.2.1 polish §14+§15 cross-ref

**估算**：~15 min（小 polish）

**来源**：Sprint V retro §3.3 / §14 + §15 与其他 patterns 的 cross-ref 当前主要靠 §9 总览 + §14.3 对比表 / 可加 inline cross-ref 段更紧密。

**处理时机**：v0.5 maintenance sprint 触发时 fold（≥ 5 v0.5 候选累积时 / 当前 2 项 / 不急）。

---

## 4. 与 Sprint L→V 衍生债合并视图（最新）

| Sprint | v0.2 候选 | 已 patch | 押后 v0.2 | v0.3 候选 | 已 land | 押后 v0.3 | v0.4 候选 | 已 land | 押后 v0.4 | v0.5 候选 |
|--------|---------|---------|---------|----------|--------|----------|----------|--------|----------|----------|
| L+M+N+O | 20 | 18 ✓ | 2 | — | — | — | — | — | — | — |
| P-T | 0 | 0 | 0 | 6 | 6 ✓ | 0 | 2 | — | — | — |
| U | 0 | 0 | 0 | 0 | 0 | 0 | 2 | — | — | — |
| **V** | 0 | 0 | 0 | 0 | 0 | 0 | 0 | **4 ✓** | **0** ⭐ | **+2** |
| **合计** | **20** | **18** ✅ | **2** | **6** | **6** ✅ | **0** | **4** | **4** ✅ | **0** | **2** |

**累计 patch 落地率**：(18 + 6 + 4) / (20 + 6 + 4) = **28/30 = 93.3%** ⭐（vs Sprint U 后 92.3%）

---

## 5. methodology v0.2 cycle 进度追踪（per ADR-031 触发条件 #7）

per ADR-031 §3 #7: methodology 7 doc 全 ≥ v0.2（注：当前实际 8 doc / per Sprint U /00 §2 6→7 sync 后）

**Sprint V 后状态**：1/8 doc ≥ v0.2

| methodology doc | 当前版本 | 距 v0.2 |
|-----------------|--------|--------|
| **/02 sprint-governance** | **v0.2** ⭐ | **达成**（Sprint V）|
| /00 framework-overview | v0.1.1 | 待 bump（小工作）|
| /01 role-design | v0.1.2 | 待 bump |
| /03 identity-resolver | v0.1.2 | 待 bump |
| /04 invariant | v0.1.2 | 待 bump |
| /05 audit-trail | v0.1.1 | 待 bump（推荐 Sprint W 优先 / 与 ADR-032 紧密关联）|
| /06 adr-pattern | v0.1.1 | 待 bump（含 fold T-V05-FW-001 retroactive lessons）|
| /07 cross-stack | v0.1 | 待 bump（推荐 Sprint W 优先 / 与 §15 Hybrid 紧密关联）|

**v0.2 cycle 完成预估**（per Sprint V retro §7.4）：
- Sprint W (本计划): /05 + /07 → v0.2（双 doc 推荐）
- Sprint X: /06 → v0.2（fold T-V05-FW-001）
- Sprint Y: /00 + /01 → v0.2
- Sprint Z: /03 + /04 → v0.2
- Sprint AA 后：8/8 doc ≥ v0.2 → ADR-031 触发条件 #7 达成

预估时长：4-5 sprints / 约 6-10 hours total.

---

## 6. v1.0 触发条件评估状态（per ADR-031 §3）

Sprint V 完成后状态：

| # | 候选条件 | Sprint U 后 | Sprint V 后 |
|---|---------|-----------|-----------|
| 1 | ≥ 5 模块稳定 + ≥ 2 release cycle | ✅ | ✅ 不变 |
| 2 | Maintenance + Release sprint 累计 ≥ 5 zero-trigger | ✅ (6) | ✅ **7** ⭐⭐ |
| 3 | API 稳定 ≥ 6 个月 | ⏳ 0 day | ⏳ 0 day |
| 4 | ≥ 1 跨域 reference impl | ❌ | ❌ |
| 5 | 第三方 review ≥ 2 person | ❌ | ❌ |
| 6 | 累计 v0.x patch ≥ 95% | ⏳ 92.3% | ⏳ **93.3%** ⭐ +1pp |
| 7 | methodology 7 doc 全 ≥ v0.2 | ❌ 0/8 | ⏳ **1/8** ⭐ |

→ 持续强化条件 #2 + 推进条件 #6 + #7 / 不变条件 #1 + #3 + #4 + #5

---

## 7. Sprint W 候选议程（per Sprint V retro §8）

按推荐顺序：

1. **A. methodology v0.2 cycle 持续**（推荐 / 1.5 会话 / 1-2 doc）：
   - 推荐 1: /05 audit-trail-pattern.md v0.1.1 → v0.2（与 ADR-032 retroactive 紧密关联）
   - 推荐 2: /07 cross-stack-abstraction-pattern.md v0.1 → v0.2（加 Hybrid Release Sprint Pattern 实证）
   - 单 sprint 1-2 doc 取决于工时
2. B. v0.5 maintenance sprint（待累积 ≥ 3-5 v0.5 候选）/ 当前仅 2 项 / 不急
3. C. 跨域 outreach / reference impl (legal) — 押后等触发
4. D. v1.0 触发条件持续追踪（自动）

---

**本债务清单 Sprint V 起草于 2026-04-30 / Stage 4 closeout / Architect Opus**
