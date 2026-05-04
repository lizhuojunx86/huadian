# Sprint W 衍生债 — 押后清单（methodology v0.2 cycle 进度 3/8）

> Status: registered
> 来源 sprint: Sprint W Stage 4 closeout (2026-04-30)
> 总计 4 项押后（2 v0.2 + 2 v0.5）/ 无新增

---

## 0. 总览（vs Sprint V 后）

| 维度 | Sprint V 后 | Sprint W 后 |
|------|-----------|-----------|
| v0.2 押后 | 2 (DGF-N-04 / DGF-N-05) | 2（不变）|
| v0.4 押后 | 0 | 0（不变）|
| v0.5 候选 | 2 | 2（不变）|
| 累计 patch 落地率 | 28/30 = 93.3% | 28/30 = 93.3%（不变 / Sprint W 不 land 新 patch）|
| methodology v0.2 doc | 1/8 | **3/8** ⭐ |
| zero-trigger sprint 连续 | 7 | **8** ⭐⭐ |

---

## 1. v0.2 押后清单（2 项 / 不变 / 等外部触发）

### 1.1 DGF-N-04 — 跨域 reference impl（合并 DGF-O-03）
### 1.2 DGF-N-05 — EntityLoader.load_subset feature

详见 Sprint U+V residual debts §1.

---

## 2. v0.5 候选清单（2 项 / 不变 / 不急触发 maintenance）

### 2.1 T-V05-FW-001 — methodology/06 v0.2 起草时 fold ADR-032 §5 retroactive lessons

**估算**：~10 min（fold 进 methodology/06 v0.2 加段）

**处理时机**：Sprint X 候选 A 推荐 /06 v0.2 起草同 sprint fold（per Sprint W retro §8）。

### 2.2 T-V05-FW-002 — methodology/02 v0.2.1 polish §14+§15 cross-ref

**估算**：~15 min

**处理时机**：v0.5 maintenance sprint 触发时（≥ 5 候选累积 / 当前仅 2 / 不急 / 可与 Sprint Y+ methodology v0.2 cycle 完成时一并 polish）。

---

## 3. methodology v0.2 cycle 剩余 5 doc 进度

per Sprint W retro §7.4：

| methodology doc | 当前版本 | 推荐 Sprint X+N |
|-----------------|--------|---------------|
| /00 framework-overview | v0.1.1 | Sprint Y+ (小工作 / §2 已是核心 / v0.2 加 cross-doc 网状图) |
| /01 role-design | v0.1.2 | Sprint Y+ (Sprint M+role-templates v0.2.1+0.3.1 实证支撑) |
| /03 identity-resolver | v0.1.2 | Sprint Y+ (加 byte-identical dogfood pattern first-class) |
| **/04 invariant** | **v0.1.2** | **Sprint X 推荐**（加 self-test pattern first-class）|
| **/06 adr-pattern** | **v0.1.1** | **Sprint X 推荐**（fold T-V05-FW-001 + release-trigger vs release-eval ADR 模板对比 first-class）|

**Sprint X 推荐 fold**：/06 + /04（双 doc / 与 Sprint W /05 + /07 同模式）。

---

## 4. v1.0 触发条件评估状态（per ADR-031 §3）

| # | 条件 | Sprint V 后 | Sprint W 后 |
|---|------|-----------|-----------|
| 1 | ≥ 5 模块 + ≥ 2 release cycle | ✅ | ✅ |
| 2 | ≥ 5 zero-trigger sprint | ✅ (7) | ✅ **8** ⭐⭐ |
| 3 | API 稳定 ≥ 6 个月 | ⏳ | ⏳ |
| 4 | ≥ 1 跨域 ref impl | ❌ | ❌ |
| 5 | 第三方 review ≥ 2 person | ❌ | ❌ |
| 6 | 累计 v0.x patch ≥ 95% | ⏳ 93.3% | ⏳ 93.3% |
| 7 | methodology 7 doc 全 ≥ v0.2 | ⏳ 1/8 | ⏳ **3/8** ⭐ |

→ 持续强化 #2 + #7 / 不变其他

---

## 5. Sprint X 候选议程

per Sprint W retro §8：

1. **A. methodology v0.2 cycle 持续**（推荐 / 1.5 会话 / 推 /06 + /04）：
   - /06 v0.1.1 → v0.2（fold T-V05-FW-001 + 加 release-trigger vs release-eval ADR 模板对比 first-class section）
   - /04 v0.1.2 → v0.2（加 self-test pattern first-class section）
2. B. v0.5 maintenance（v0.5 仅 2 候选 / 不急）
3. C. 跨域 outreach (legal) — 押后等触发

---

**本债务清单 Sprint W 起草于 2026-04-30 / Stage 4 closeout / Architect Opus**
