# Sprint U 衍生债 — 押后清单（Sprint L→U 累计 / methodology 8 doc 完整里程碑）

> Status: registered（押后状态）
> 来源 sprint: Sprint U Stage 4 closeout (2026-04-30)
> 总计 6 项押后（2 v0.2 + 0 v0.3 + 4 v0.4）
> 触发条件: 见每项 §"处理时机"

---

## 0. 总览

Sprint U 收口后（vs Sprint T 后）：

| 维度 | Sprint T 后 | Sprint U 后 |
|------|-----------|-----------|
| v0.2 押后 | 2 (DGF-N-04 / DGF-N-05) | 2（不变 / 等外部触发）|
| v0.3 押后 | 0 ⭐ (Sprint T fold land) | 0（不变）|
| v0.4 候选 | 2 | **4**（+ T-V04-FW-003 + -004）|
| 累计 patch 落地率 | 24/26 = 92.3% | 24/26 = 92.3%（不变 / 评估 + methodology sprint）|
| methodology doc 数 | 7 | **8** ⭐（+ /07 cross-stack abstraction） |
| **v1.0 候选议程评估** | 待评估 | **完成（ADR-031 / 不立即 release / 7 触发条件锁定 / 路径预测 2026-10~2027-04）** ⭐ |
| 5 sprint zero-trigger | 5 (P→Q→R→S→T) | **6 (+ U)** ⭐ |

---

## 1. v0.2 押后清单（2 项 / 不变 / 等外部触发）

### 1.1 DGF-N-04 — 跨域 reference impl（合并 DGF-O-03）

按 ADR-030 §4.3 / ADR-031 §3 #4，跨域 reference impl 是 v0.4+ release 候选条件 + v1.0 触发条件之一。

**处理时机**：等真案例方接触触发。优先 legal（per Sprint Q debt §1.1）。

### 1.2 DGF-N-05 — EntityLoader.load_subset feature

**处理时机**：等用户提需求。

---

## 2. v0.3 押后清单（**0 项** / Sprint T fold land 完成）

无押后。

---

## 3. v0.4 候选清单（4 项 / 累积成熟 / 可触发 v0.4 maintenance sprint）

### 3.1 T-V04-FW-001（Sprint S 留存）— chief-architect §工程小细节 v0.2.2 commit message hygiene 规则

**估算**：~5 min

**来源**：Sprint R commit `35f371d` 实际包含 6 files (hooks + 4 framework polish) 但 message 仅说 hooks → 触发"commit message 应反映实际改动 file 集合"规则建议。

### 3.2 T-V04-FW-002（Sprint T 留存）— brief-template v0.1.3 §2.1 Code 类估算分子类

**估算**：~15 min

**来源**：Sprint T retro §3.1 实证 Code 主导 47% 偏差。建议子类：
- "框架 spike / 已有 pattern fold"（如 T-V03-FW-005 / 实证偏快）
- "新模块抽象 / 全新 Plugin Protocol"（如 Sprint Q audit_triage / 实证较慢）
- "patch / version bump 等模板化改"（如 Sprint P 类型 / 实证模板化）

### 3.3 T-V04-FW-003（Sprint U 新增）— brief-template v0.1.3 §2.1 Docs 类估算分子类

**估算**：~15 min

**来源**：Sprint U retro §3.1 实证 / methodology/07 起草 301 行 vs 估算 250 行 ~20% 偏差。建议子类：
- "cross-ref polish"（如 Sprint S /01 + /03 + /04 + Sprint U /06 / 实证精确）
- "new doc 起草"（如 Sprint U /07 / 实证略偏 ~20%）
- "ADR / 决策记录"（如 Sprint S ADR-030 + Sprint U ADR-031 / 实证精确）

### 3.4 T-V04-FW-004（Sprint U 新增）— 回填 audit_triage 抽象 ADR-032

**估算**：~30 min

**来源**：Sprint U methodology/06 v0.1.1 §8.2 实证锚点表标注 "Sprint Q audit_triage 抽象 / 应起 ADR 但未起"。

**内容预测**（参考 ADR-027 + ADR-030 模板）：
- Title: ADR-032 — audit_triage Cross-Stack Abstraction Decision Record (Retroactive)
- Context: Sprint Q 选择 cross-stack 抽象路径（TS prod → Python framework / Approach B / 6 Plugin Protocol）
- Decision: 已实施（per Sprint Q closeout）
- Consequences: per Sprint Q + T 实证（dogfood ✅ user local + Docker PASSED）
- Status: accepted (retroactive)

### 3.5 T-V04-FW-005（候选 / 暂不登记）— Architect 角色 v0.4 转型期 outreach 责任

**来源**：Sprint U retro §5.2 启示。但 outreach 是非 sprint 单元的工作（持续后台任务）/ 不应 fold 进 sprint maintenance。

**处理时机**：仅在 chief-architect.md 加段（per role-templates v0.2.2 / fold T-V04-FW-001 时同 sprint 完成）/ 不算独立 debt。

---

## 4. 与 Sprint L→U 衍生债合并视图（最新）

| Sprint | v0.2 候选 | 已 patch | 押后 v0.2 | v0.3 候选 | 已 land | 押后 v0.3 | v0.4 候选 | 押后 v0.4 |
|--------|---------|---------|---------|----------|--------|----------|----------|----------|
| L+M+N+O | 20 | 18 ✓ | 2 | — | — | — | — | — |
| P-T | 0 | 0 | 0 | 6 | 6 ✓ | 0 ⭐ | 2 | 2 |
| **U** | 0 | 0 | 0 | 0 | 0 | 0 | **+2** | **+2** |
| **合计** | **20** | **18** ✅ | **2** | **6** | **6** ✅ | **0** | **4** | **4** |

→ **累计 patch 落地率 24/26 = 92.3%**（不变 / Sprint U 不 land 新 patch）；**v0.4 候选累积 4 项**（接近 ≥ 5 触发 v0.4 maintenance sprint 条件 / 需 1 项再触发）。

---

## 5. v0.4 maintenance sprint 触发条件评估

参考 ADR-030 / ADR-031 触发条件模板：

| # | 候选条件 | 评估 |
|---|---------|------|
| 1 | v0.4 候选 ≥ 5 累积 | ⏳ **当前 4 / 接近触发**（差 1 项）|
| 2 | 5 sprint zero-trigger（since v0.3 release）| ⏳ Sprint U 是第 1 个 / 还需 4 sprint |
| 3 | 距 v0.3 release 时间 ≥ 2 sprint | ⏳ Sprint U 是第 2 sprint after v0.3.0（Sprint T+ Sprint U）/ ✅ 接近 |
| 4 | 累计 v0.x patch ≥ 95% | ⏳ 当前 92.3% |

**评估**：v0.4 maintenance sprint **可在 Sprint V 候选 B 触发**（per ADR-031 §6.4 + Sprint U retro §7.4 合并 candidate）：
- 4 候选累积已成熟（差 1 项触发 ≥ 5）
- Sprint V 候选 B fold 这 4 候选 land + 同时新增可能的 5th 候选 → 触发完整
- vs 等更多 v0.4 候选累积（risk: 候选数膨胀 / scope 失控 / 不建议）

---

## 6. v1.0 候选议程评估状态（per ADR-031 §3 锁定 7 触发条件）

Sprint U 完成后状态（vs ADR-031 §4 起草时）：

| # | 候选条件 | Sprint U 前 | Sprint U 后 |
|---|---------|-----------|-----------|
| 1 | ≥ 5 模块稳定 + ≥ 2 release cycle | ✅ | ✅ 不变 |
| 2 | Maintenance + Release sprint 累计 ≥ 5 zero-trigger | ✅ (5) | ✅ **6** ⭐ 持续强化 |
| 3 | API 稳定 ≥ 6 个月 | ⏳ 0 day | ⏳ 0 day（Sprint U 当日 / 时钟从 v0.3.0 release 起算）|
| 4 | ≥ 1 跨域 reference impl 完整 working code | ❌ | ❌ 不变（外部触发 / 等接触）|
| 5 | 第三方 review ≥ 2 person | ❌ | ❌ 不变（外部触发）|
| 6 | 累计 v0.x patch ≥ 95% | ⏳ 92.3% | ⏳ 92.3%（不变 / Sprint U 不 land 新 patch）|
| 7 | methodology 7 doc 全 ≥ v0.2 | ❌ 0/7 ≥ v0.2 | ❌ 0/8 ≥ v0.2（**8 doc 完整 / 但仍 v0.1.x**）|

→ **2/7 ✅ + 1/7 ⏳（API 6 个月 / 始终 +6 个月）+ 2/7 ❌（外部触发）+ 2/7 ⏳（内部工作）**

**v1.0 触发条件 Sprint U 后状态**：与 Sprint T 后**实质不变**（只 #2 持续强化）。需要等 #3 的 6 个月时钟 + #6 #7 的内部工作 + #4 #5 的外部触发。

---

## 7. Sprint V 候选议程（per Sprint U retro §8）

按推荐顺序：

1. **A + B 合并（推荐 / 1.5-2 会话 / 与 Sprint S+T+U 同模式）**：
   - **A. methodology v0.2 cycle 起步**（推荐 methodology/02 → v0.2 / 加 "Eval Sprint Pattern" + "Release Sprint Pattern" / per Sprint U §5.1 触发 / per ADR-031 触发条件 #7）
   - **B. v0.4 maintenance sprint**（fold T-V04-FW-001 ~ -004 / 累计 4 候选成熟 / ~70 min）
2. **C. methodology v0.2 cycle 单独 sprint**（如 A+B 合并工时超）
3. **D. 跨域 outreach + reference impl (legal) — 押后等触发**

---

**本债务清单 Sprint U 起草于 2026-04-30 / Stage 4 closeout / Architect Opus**
