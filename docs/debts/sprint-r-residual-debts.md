# Sprint R 衍生债 — v0.2 + v0.3 押后清单（最新）

> Status: registered（押后状态）
> 来源 sprint: Sprint R Stage 4 closeout (2026-04-30)
> 总计 3 项押后（2 v0.2 + 1 v0.3）
> 触发条件: 见每项 §"处理时机"

---

## 0. 总览

Sprint R 收口后（vs Sprint Q 后）：

| 维度 | Sprint Q 后 | Sprint R 后 |
|------|-----------|-----------|
| v0.2 押后 | 2 (DGF-N-04 / DGF-N-05) | 2（不变）|
| v0.3 押后 | 6（候选未 land）| **1**（仅 T-V03-FW-005 大工作）|
| 累计 patch 落地率 | 18/26 = 69.2% | **23/26 = 88.5%** |
| Sprint R 新增 v0.4 候选 | — | **0**（patch sprint / zero-trigger）|

---

## 1. v0.2 押后清单（2 项 / 不变 / 等外部触发）

### 1.1 DGF-N-04 — 跨域 reference impl（合并 DGF-O-03）

**描述**：framework/identity_resolver/ + framework/invariant_scaffold/ + framework/audit_triage/ 都只有 huadian_classics reference impl；其他领域（法律 / 医疗 / 等）只有 cross-domain-mapping.md 设计 intent。

**处理时机**：
- A. 跨域案例方主动接触 → 优先做对方领域 reference impl
- B. 主动起 1 个 legal example sprint（不建议在无外部触发时主动起）

→ 默认押后；不阻塞 v0.3 release（如果 release 触发是"5 模块齐备 + maintenance 稳定 ≥ 3 sprint"而非"≥ 1 跨域 reference impl"）。

### 1.2 DGF-N-05 — EntityLoader.load_subset feature

**描述**：EntityLoader 只支持 `load_all()`；跨域案例方可能需子集加载。

**处理时机**：等用户提需求。当前 huadian ~700 person 全量加载性能不是瓶颈。

→ 默认押后；不阻塞 v0.3 release（feature 不是阻塞性 bug）。

---

## 2. v0.3 押后清单（1 项 / 大工作 / 押后 Sprint R+1 或更晚）

### 2.1 T-V03-FW-005 — Docker compose Postgres + seed fixtures

**描述**：让 sandbox 也能跑 framework dogfood（vs 当前必须在 user local Terminal 跑）。

**估算工作量**：≥ 4 hours（涉及 docker-compose.yml + seed.sql + fixtures + CI 集成验证）。

**为什么 Sprint R 押后**：
- Sprint R 总工时 1-2 会话；T-V03-FW-005 单项 ≥ 4h 独立占 1 会话
- 加进来会触发 Stop Rule #6（工时 > 2 会话）
- 不是 v0.3 release 的阻塞条件（dogfood 在 user local 跑也是稳定方案）

**处理时机**：
- A. Sprint S 单独 1 个 batch（如 Sprint S 是 v0.3 release prep 评估 / 工时空余）
- B. Sprint S+1 单独 mini-sprint（"sandbox infra sprint" / 1 会话内）
- C. 长期押后（如果 user local Terminal 跑 dogfood 持续稳定）

→ 推荐 **A** 或 **B**；不推荐 C（系统性投入 sandbox infra 长期收益高）。

---

## 3. 与 Sprint L+M+N+O+P+Q+R 衍生债合并视图（最新）

| Sprint | v0.2 候选 | 已 patch | 押后 v0.2 | v0.3 候选 | 已 land | 押后 v0.3 |
|--------|---------|---------|---------|----------|--------|----------|
| L | 4 | 4 ✓ | 0 | — | — | — |
| M | 7 | 7 ✓ | 0 | — | — | — |
| N | 5 | 3 ✓ | 2 (DGF-N-04 / -05) | — | — | — |
| O | 4 | 4 ✓ | 0 | — | — | — |
| P | 0 | 0 | 0 | 2 (T-V03-FW-001 / -002) | — | — |
| Q | 0 | 0 | 0 | 4 (T-V03-FW-003~006) | — | — |
| **R** | 0 | 0 | 0 | 0 | **5 ✓** | **1 (T-V03-FW-005)** |
| **合计** | **20** | **18** ✅ | **2** ⏳ | **6** | **5** ✅ | **1** ⏳ |

---

## 4. v0.3 release 触发条件评估（Sprint R 后状态）

参考 v0.2 release 触发条件（Sprint O closeout §2.4 / Sprint P 落地）：

| 条件 | 评估 |
|------|------|
| ≥ 4 个抽象资产稳定 | ✅ 5 模块齐备（per methodology/02 §12）|
| Maintenance sprint 稳定 ≥ 1 sprint | ✅ Sprint P + R 两次 maintenance / 全 zero-trigger |
| 押后 v0.2 候选 ≥ 80% land | ✅ 18/20 = 90% |
| 押后 v0.3 候选 ≥ 80% land | ✅ 5/6 = 83.3% |
| ≥ 1 跨域 reference impl | ❌ 未达成（DGF-N-04 等触发）|
| 连续 zero-trigger sprint ≥ 3 | ✅ Sprint P + Q + R 全 zero-trigger |

→ **5/6 条件达成**，仅缺"跨域 reference impl"。

**v0.3 release 候选议程**：
- 选项 A：等跨域 reference impl 触发后 release（保守 / 等案例方）
- 选项 B：调整触发条件（去掉"≥ 1 跨域"硬要求，改为"≥ 1 跨域已规划 + cross-domain-mapping.md v0.2"）→ 可在 Sprint S+1 release
- 选项 C：等 T-V03-FW-005 land 后 release（ + 1 sprint）

→ Sprint S 候选 A（v0.3 release prep 评估）的核心 deliverable 是判断走哪个选项。

---

## 5. Sprint S 候选议程建议（来自 Sprint R retro §8）

按价值 / 风险综合：

1. **A. v0.3 release prep 评估 sprint**（1 会话）
   - 评估 5/6 条件 + 决定 release timing
   - 形态：纯评估 / 不开 patch / 输出 ADR-031 或新 ADR 决策"是否在 Sprint S+N release"
2. **B. methodology v0.2 持续 polish**（1-2 会话）
   - methodology/01 / 03 / 04 v0.1.1（加 cross-ref to /02 §10-§13）
   - 视情况 methodology/06 + 07 起草
3. **A + B 合并**（推荐 / 1.5-2 会话）
   - Stage 1 批 1：v0.3 触发条件评估 + ADR
   - Stage 1 批 2-3：methodology cross-ref polish
   - Stage 1 批 4：T-V03-FW-005 Docker compose（如 A 决定 v0.3 release 等其完成）
4. **C. 跨域 reference impl (legal)** — 押后等触发
5. **D. T-V03-FW-005 单独 mini-sprint** — 仅当 A 决定 v0.3 release 等其完成

---

**本债务清单 Sprint R 起草于 2026-04-30 / Stage 4 closeout / Architect Opus**
