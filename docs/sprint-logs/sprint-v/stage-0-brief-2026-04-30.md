# Sprint V Brief — v0.4 maintenance (4 candidates fold) + methodology/02 v0.2 (+ Eval + Release Sprint Patterns)

> 起草自 `framework/sprint-templates/brief-template.md` v0.1.3
> Dogfood: brief-template **第 11 次**外部使用（v0.1.3 第 **4** 次 / Docs 主导 / 累积趋势继续观察）

## 0. 元信息

- **架构师**：首席架构师（Claude Opus 4.7）
- **Brief 日期**：2026-04-30
- **Sprint 形态**：**单 track / single-actor**（与 Sprint L→U 同 / Architect Opus 全程）
- **预估工时**：**1.5-2 会话**（候选 A+B 合并 / per Sprint U retro §8 推荐）
- **PE 模型**：N/A（single-actor）
- **Architect 模型**：Opus 4.7
- **触发事件**：Sprint U retro §8 推荐 候选 A+B 合并；4 v0.4 候选累积成熟（接近 maintenance ≥ 5 阈值 / 一次性 fold 不必等更多累积）；methodology v0.2 cycle 起步条件成熟（per ADR-031 触发条件 #7）
- **战略锚点**：Sprint U retro §8 + Sprint U residual debts §3+§7 + ADR-031 §6.4 路径

---

## 1. 背景

### 1.1 前置上下文

Sprint Q→T cycle 完成 framework v0.3.0 release；Sprint U 完成 ADR-031 v1.0 候选议程评估 + methodology 8 doc 完整。

Sprint V 在大局中位置：

```
Sprint U (ADR-031 + meth/06+07+00 sync + 6 zero-trigger)
                     ↓
Sprint V (v0.4 maintenance + methodology/02 v0.2 起步) ← 现在
                     ↓
Sprint V+1~V+N (methodology v0.x → v0.2 cycle 持续 / per doc / ≥ 4 sprint)
                     ↓
Sprint Z+? (跨域案例方接触 / API 6 个月稳定 / 7/7 v1.0 触发条件达成 → v1.0 release sprint)
```

### 1.2 与既有 sprint 的差异

| 维度 | Sprint P+R (patch) | Sprint S+U (eval+meth) | Sprint T (release+feature) | **Sprint V (maintenance + meth v0.2 起步)** |
|------|------------------|---------------------|--------------------------|------------------------------------------|
| 抽象类型 | patch only | eval + meth iter | release + feature | **maintenance fold + meth v0.x → v0.2 起步** |
| 抽象输入 | v0.x 候选 | 触发条件 + 8 doc 完整化 | Docker compose | **4 v0.4 候选 + methodology/02 §14+§15 新加** |
| 涉及模块 | 4-5 模块 polish | 0 模块 + 1 ADR + 2 methodology | 5 模块统一 + 1 feature | **0 模块 + 1 ADR (历史回填) + 2 docs (template + role) + 1 methodology v0.2 (重大)** |
| 主导模型 | Opus | Opus | Opus | Opus |
| dogfood gate | sanity | sanity 不回归 | Docker dogfood + ADR §5 回填 | **5 模块 sanity + 60 pytest 不回归** |
| 风险等级 | low | low | medium | **low**（无新代码 / 全 docs + ADR）|
| 工作量 | 1 会话 | 1.5 会话 | 2 会话 | **1.5-2 会话** |

### 1.3 不做的事（Negative Scope）

- ❌ **不立即 release v0.4**（v0.4 候选累积仍 < 5 阈值 / 4 项 fold 后清空 / Sprint V 是 maintenance / 不 release）
- ❌ **不做新 framework 模块**（5 模块齐备已是阶段终点）
- ❌ **不动 framework v0.3 ABI**（保稳定到 v0.4 / v1.0 release）
- ❌ **不在本 sprint 完成 methodology v0.2 cycle 全部**（仅 /02 → v0.2 起步 / 7 doc 仍 v0.1.x）
- ❌ **不做 DGF-N-04 / DGF-N-05**（押后等外部触发）
- ❌ **不立即起 v1.0 release ADR**（per ADR-031 §2 决策 / 当前 2/7 触发条件）

---

## 2. 目标范围

### 2.1 单 Track — v0.4 maintenance + methodology/02 v0.2 起步

**目标**：

1. **批 1 — T-V04-FW-004**: ADR-032 回填 audit_triage 抽象（Sprint Q 应起未起的 ADR）
2. **批 2 — T-V04-FW-001**: chief-architect §工程小细节 v0.3.1（加 commit message hygiene 规则）
3. **批 3 — T-V04-FW-002 + -003 合并**: brief-template §2.1 估时表 v0.1.4（Code 类拆分子类 + Docs 类拆分子类 + sprint-templates v0.3.1）
4. **批 4 — methodology/02 v0.1.1 → v0.2**（加 §14 Eval Sprint Pattern + §15 Release Sprint Pattern / 重组 §9 元 pattern 总览 4→6 patterns / 触发 v0.2 大 bump）⭐
5. 5 模块 sanity + 60 pytest 不回归

**Batch 详情**：

| 批 | ID | 改动 | 估时（v0.1.3 §2.1 三类）|
|----|---|------|----|
| 1 | T-V04-FW-004 | ADR-032 audit_triage abstraction (retroactive) | Docs ~30 min |
| 2 | T-V04-FW-001 | chief-architect §工程小细节 v0.3.1 (+1 行 + 来源说明) + role-templates v0.3.0 → v0.3.1 patch entry | Docs ~5 min |
| 3 | T-V04-FW-002 + -003 | brief-template §2.1 Code + Docs 类拆分子类 → v0.1.4 + sprint-templates v0.3.0 → v0.3.1 patch entry | Docs ~25 min |
| 4 | methodology/02 v0.2 | + §14 Eval Sprint Pattern + §15 Release Sprint Pattern + 重组 §9 (4→6 patterns) + footer / 修订历史 v0.1.1 → v0.2 | Docs ~60 min |
| 5 | sanity 回归 | (gate) | ~10 min |
| 4 (closeout) | closeout + retro + STATUS/CHANGELOG | Closeout ~30 min |

#### 工作量估算（v0.1.3 §2.1 / 第 4 次外部 dogfood / Docs 主导 / 累积趋势）

| 类别 | 包含 | 估时 |
|------|------|------|
| **Code** | 无（Sprint V 不动 framework code）| **0 hours** |
| **Docs** | ADR-032 (~200 行 / ~30 min) + chief-architect §工程小细节 (~5 min) + brief-template v0.1.4 (~25 min) + methodology/02 v0.2 (~60 min) | **~2 hours** |
| **Closeout / Retro** | stage-4-closeout + sprint-v-retro + sprint-v-residual-debts + STATUS + CHANGELOG | **~0.5 hours** |
| **小计** | — | **~2.5 hours = 1.5-2 会话** |

**v0.1.3 估时表第 4 次 dogfood 备注 / 累积趋势**：
- Sprint S 第 1 次（Docs 主导）：< 10% ✓
- Sprint T 第 2 次（Code 主导）：Code 类 47% 偏差 / 触发 v0.4 候选（本 sprint fold）
- Sprint U 第 3 次（Docs 主导）：< 10% ✓
- **Sprint V 第 4 次（Docs 主导）**：预期 < 10%（但 ADR-032 + methodology/02 v0.2 是 "new doc 起草" 类 / 触发 T-V04-FW-003 子类拆分需求 — **本 sprint 同时 fold 此 fix / 形成自我验证**）⭐

#### 完成判据（6 项）

- ✅ ADR-032 audit_triage abstraction (retroactive) 落地
- ✅ chief-architect §工程小细节 v0.3.1（+ commit message hygiene 规则）
- ✅ brief-template §2.1 v0.1.4（Code + Docs 类拆分子类）+ sprint-templates v0.3.1
- ✅ methodology/02 v0.1.1 → **v0.2**（+ §14 Eval Sprint Pattern + §15 Release Sprint Pattern + 重组 §9 总览 4→6 patterns）⭐
- ✅ 5 模块 sanity 不回归 + 60 pytest 全绿
- ✅ STATUS / CHANGELOG / retro / 衍生债 + Sprint W 候选议程

### 2.2 Track 2

不适用（单 track）。

---

## 3. Stages（用 brief-template v0.1.3 §3.B 精简模板）

### Stage 0 — Inventory（已完成 / 本 brief §1.1 + §2.1 即 inventory + 已 grep 4 候选实际位置）

无独立 inventory 文档。

### Stage 1 — Maintenance Fold + Methodology v0.2（4 批）

按以下顺序：

1. **批 1：T-V04-FW-004 ADR-032 回填**（~30 min）
2. **批 2：T-V04-FW-001 chief-architect §工程小细节 v0.3.1**（~5 min）
3. **批 3：T-V04-FW-002 + -003 brief-template v0.1.4**（~25 min）
4. **批 4：methodology/02 v0.1.1 → v0.2**（+ Eval + Release Sprint Patterns / ~60 min）

**会话节点建议**：
- 会话 1：批 1+2+3（~60 min）+ 中场 commit + 用户 ACK
- 会话 2：批 4（~60 min）+ Stage 1.13 + Stage 4

### Stage 1.13 — Sanity 回归

- ruff check + format 全过
- 5 模块 import sanity（v0.3.0 不变）
- 60 pytest 全绿（不回归）
- methodology 8 doc 全部存在 + 版本验证（/02 应 ≥ v0.2）

### Stage 4 — Closeout（精简版）

- 标记 4 v0.4 候选全 land + 1 ADR (ADR-032)
- methodology/02 v0.2 落地（v0.x cycle 第 1 doc）
- STATUS / CHANGELOG / retro / 衍生债登记
- Sprint W 候选议程（剩余 7 doc methodology v0.2 cycle / 跨域案例方接触 / etc）

---

## 4. Stop Rules

> 详见 `framework/sprint-templates/stop-rules-catalog.md` 5 类模板。

1. **§3 数据正确性类**：5 模块 sanity 任 1 回归 → Stop（不应该发生 / Sprint V 不动 code）
2. **§3 数据正确性类**：60 pytest 任 1 fail → Stop（不应该发生 / Sprint V 不动 code）
3. **§4 输出量类**：methodology/02 v0.2 总长度 > 800 行（vs 当前 v0.1.1 593 行 + 加段估算 ~700）→ Stop（评估是否 over）
4. **§4 输出量类**：ADR-032 长度 > 300 行 → Stop（评估是否 over）
5. **§5 治理类**：触发新 ADR ≥ 2（除 ADR-032）→ Stop
6. **§6 跨 sprint 一致性类**：Sprint V 工时 > 2.5 会话 → Stop（评估 scope）

---

## 5. 角色边界

| 角色 | 活跃度 | 主要职责 |
|------|-------|---------|
| 首席架构师 | 🟢 主导 | 全 stage / 单 actor / ADR 回填 + methodology v0.2 起草 + template polish |
| 其余 9 角色 | ⚪ 暂停 | — |

> Single-actor sprint 简化（per brief-template v0.1.3 §5 注脚）。

---

## 6. 收口判定（同 §2.1，重复以便 closeout 直接对照）

- ✅ ADR-032 audit_triage retroactive
- ✅ chief-architect §工程小细节 v0.3.1
- ✅ brief-template v0.1.4 + sprint-templates v0.3.1
- ✅ methodology/02 v0.1.1 → v0.2 (+ §14 + §15 + 重组 §9)
- ✅ 5 模块 sanity + 60 pytest 不回归
- ✅ STATUS / CHANGELOG / retro / 衍生债 + Sprint W 候选议程

---

## 7. 节奏建议

**舒缓 1.5 会话**（推荐 / 与 Sprint S+U 同 scale）：

会话 1（~1.25 hours）：
- Stage 1 批 1 ADR-032 (~30 min)
- Stage 1 批 2 chief-architect v0.3.1 (~5 min)
- Stage 1 批 3 brief-template v0.1.4 (~25 min)
- 阶段性 commit + 用户中场 ACK

会话 2（~1.25 hours）：
- Stage 1 批 4 methodology/02 v0.2 (~60 min)
- Stage 1.13 sanity (~10 min)
- Stage 4 closeout + retro (~30 min)

---

## 8. D-route 资产沉淀预期

本 sprint 预期沉淀以下框架抽象资产（**至少勾 ≥ 1 项**；本 sprint 实际勾 4 项）：

- [x] **新 ADR (历史回填)**：ADR-032 audit_triage cross-stack abstraction (retroactive)
- [x] **methodology v0.x → v0.(x+1) 大 bump**：methodology/02 v0.1.1 → **v0.2**（+ §14 Eval + §15 Release Sprint Patterns / 重大 / v0.x cycle 第 1 doc）⭐
- [x] **sprint-templates v0.x.y polish**：brief-template v0.1.3 → v0.1.4（Code + Docs 类拆分子类）+ sprint-templates v0.3.0 → v0.3.1
- [x] **role-templates v0.x.y polish**：chief-architect §工程小细节 v0.3.1（+ commit message hygiene）+ role-templates v0.3.0 → v0.3.1
- [ ] 框架代码 spike（不勾 — Sprint V 不动 code）
- [ ] 案例素材积累（不勾 — Sprint V 不动 case）

> 至少 4 项预期 → 远超 ADR-028 / C-22 的 ≥ 1 项要求。

**Layer 进度推进预期**：

- L1: 5 模块 v0.3.0 不变 / sprint-templates + role-templates patch v0.3.1
- L2: methodology/02 v0.1.1 → **v0.2** ⭐（v0.x cycle 第 1 doc / 全部 7 doc 待 v0.x cycle 完成 / per ADR-031 触发条件 #7）
- L3: 不变
- L4: + ADR-032 audit_triage 历史回填（让 Sprint Q 决策有 first-class 记录 / 跨外部 reviewer 可追溯）

---

## 9. 模型选型

- **Architect 主 session**：Opus 4.7（与 L→U 同）
- **理由**：methodology/02 v0.2 起草 + ADR-032 历史回填需要长 context 综合 Sprint S+T+U 实证 + 写作风格统一；批 2+3 是 polish 但 Opus 全程稳定性 > model switch 复杂度（per Sprint S+T+U retro §5.3 同结论）

---

## 10. Dogfood 设计

### 10.1 brief-template v0.1.3 第 4 次外部使用 / 累积趋势

本 brief 是 v0.1.3 第 4 次外部 dogfood：
- 第 1 次（S）：Docs / < 10% ✓
- 第 2 次（T）：Code 主导 / 47% 偏差
- 第 3 次（U）：Docs / < 10% ✓
- **第 4 次（V）**：Docs 主导 / 预期 < 10%
- **本 sprint 同时 fold v0.1.4** → 验证 v0.1.4 估时表是否解决 Code/Docs 子类需求 → **第 5 次（Sprint W+ 起草时）应用 v0.1.4**

### 10.2 methodology/02 v0.2 是 v0.x cycle 起步 doc

per ADR-031 §3 #7 触发条件："methodology 7 doc 全 ≥ v0.2"。Sprint V 完成后状态：1/8 doc ≥ v0.2（/02）。

**v0.2 cycle 完成预估**：
- Sprint V (本 sprint)：/02 → v0.2
- Sprint V+1 ~ Sprint V+5：剩余 7 doc 各自 → v0.2（每 sprint 1-2 doc）
- Sprint V+6 后：8 doc 全 ≥ v0.2 → 触发条件 #7 达成

### 10.3 ADR-032 是 framework v0.x 演进的"历史完整性"补强

framework Q→T cycle 实证后才发现 Sprint Q audit_triage 抽象当时未起 ADR / 触发本 sprint 回填。这是 framework 演化中"先实证后追认"的正常情况。

ADR-032 模板可被未来类似情境复用（"应起 ADR 但未起 → 后续回填" pattern）。

### 10.4 起草本 brief 暴露的发现

无新 brief-template 改进候选（v0.1.3 第 4 次 + v0.1.4 同 sprint fold / 等 v0.1.4 第 5 次外部 dogfood 时再观察）。

---

## 11. 决策签字

- 首席架构师：__ACK 待签 (2026-04-30)__
- 用户：__ACK 待签 (2026-04-30)__
- 信号：本 brief 用户 ACK 后 → Sprint V Stage 1 启动

---

**本 brief 起草于 2026-04-30 / brief-template v0.1.3 第 4 次外部使用 / Architect Opus**
