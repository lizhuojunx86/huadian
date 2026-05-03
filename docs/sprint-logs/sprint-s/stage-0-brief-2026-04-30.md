# Sprint S Brief — v0.3 Release Prep 评估 + methodology/01+03+04 cross-ref polish

> 起草自 `framework/sprint-templates/brief-template.md` v0.1.3
> Dogfood: brief-template **第 8 次**外部使用（v0.1.3 第 **1** 次 / 首次试新 3 类估时表）

## 0. 元信息

- **架构师**：首席架构师（Claude Opus 4.7）
- **Brief 日期**：2026-04-30
- **Sprint 形态**：**单 track / single-actor**（与 Sprint L+M+N+O+P+Q+R 同 / Architect Opus 全程）
- **预估工时**：**1.5-2 个 Cowork 会话**（A+B 合并 / 候选 3 / 不 fold T-V03-FW-005）
- **PE 模型**：N/A（single-actor）
- **Architect 模型**：Opus 4.7
- **触发事件**：Sprint R retro §8 推荐 候选 A + 候选 B 合并；用户 ACK "选 3"（A+B 合并 / 不 fold T-V03-FW-005）；连续 3 sprint zero-trigger 后 framework 稳定信号到达 / v0.3 release 候选条件成熟评估时机
- **战略锚点**：[ADR-028](../../decisions/ADR-028-strategic-pivot-to-methodology.md) §2.3 + Sprint R retro §8 + Sprint R residual debts §4 v0.3 release 触发条件评估

---

## 1. 背景

### 1.1 前置上下文

Sprint L→R 完成 framework 抽象首次完整（5 模块齐备）+ v0.2.0 release + audit_triage v0.1 + 60 pytest + methodology/02 v0.1.1 (4 段元 pattern) + brief-template v0.1.3 + role-templates v0.2.1。

**3 sprint zero-trigger 连续**（P + Q + R）= framework v0.2 + 5 模块齐备的稳定信号确认。Sprint R residual debts §4 评估 v0.3 release 触发条件**5/6 已达成**，仅缺"≥ 1 跨域 reference impl"。

Sprint S 在大局中位置：

```
Sprint L → M → N → O (4 模块抽象)
                     ↓
Sprint P (v0.2 patch + v0.2.0 release)
                     ↓
Sprint Q (audit_triage + 60 pytest + 5 模块齐备 ⭐)
                     ↓
Sprint R (v0.3 patch + methodology/02 v0.1.1 + 5 段元 pattern)
                     ↓
Sprint S (v0.3 release prep 评估 + methodology/01+03+04 cross-ref) ← 现在
                     ↓
Sprint S+N (条件路径决策后 → v0.3 release 或继续 maintenance)
```

完成后：
- **v0.3 release 路径决策**（ADR 起草 / 选 A 等跨域 / 选 B 调整触发条件 / 选 C 等 T-V03-FW-005）
- methodology/01 v0.1.1 → v0.1.2（加 cross-ref to /02 §10-§13 元 pattern）
- methodology/03 v0.1.1 → v0.1.2（加 cross-ref + 实证锚点段）
- methodology/04 v0.1.1 → v0.1.2（加 cross-ref + 实证锚点段）
- 5 模块 sanity 不回归 + 60 pytest 不回归

### 1.2 与既有 sprint 的差异

| 维度 | Sprint L-O 抽象 | Sprint P (patch) | Sprint Q (新模块) | Sprint R (patch+meth) | **Sprint S (eval+meth polish)** |
|------|--------------|--------------|---------------|---------------------|----------------------------|
| 抽象类型 | 新模块抽象 | incremental fix | 新模块 + pytest | incremental fix + meth iter | **eval + methodology iter** |
| 抽象输入 | services/pipeline 代码 | 20 v0.2 候选 | TS triage + ADR-027 | 6 v0.3 候选 | **3 sprint zero-trigger 实证 + meth/02 v0.1.1 cross-ref 需求** |
| 涉及模块 | 1 模块 / sprint | 4 模块 polish | 1 新模块 + 2 模块补测 | 5 模块 + 2 methodology | **3 methodology + 1 ADR** |
| 主导模型 | Opus 全程 | Opus 全程 | Opus 全程 | Opus 全程 | **Opus 全程**（评估 + cross-ref 写作）|
| dogfood gate | byte-identical / soft-equiv | 简单 sanity | 60 pytest + soft-equiv | 5 模块 sanity + hook 自跑 | **5 模块 sanity + 60 pytest 不回归** |
| 风险等级 | low → medium | low | medium | low | **low**（无新代码 / 全 docs + 评估）|
| 工作量 | 1-3 会话 | 1 会话 | 2 会话 | 1 会话 | **1.5-2 会话** |

### 1.3 不做的事（Negative Scope）

- ❌ **不做 v0.3 release 本身**（Sprint S 是 release prep 评估 / 不动版本号）
- ❌ **不开发新 framework 模块**（5 模块齐备已是阶段终点 / methodology/02 §12 显式约束）
- ❌ **不 fold T-V03-FW-005**（用户 ACK "默认不 fold" / 押后 Sprint S+1 单独 mini-sprint 或更晚）
- ❌ **不动 framework code**（Sprint S 主要 docs + ADR + 评估）
- ❌ **不做 DGF-N-04 / DGF-N-05**（押后等外部触发，per Sprint R debts §1）
- ❌ **不立即触发 ADR-031 plugin 协议**（per Sprint M-O-P-Q-R 同结论）
- ❌ **不动 services/pipeline 生产代码**

---

## 2. 目标范围

### 2.1 单 Track — v0.3 release 评估 + methodology cross-ref 合并

**目标**：

1. **A. v0.3 release timing 决策**（评估 5/6 已达成条件 + 决定走哪条路 / 起草 ADR-030）
2. **B. methodology/01+03+04 v0.1.1 → v0.1.2**（加 cross-ref to /02 §10-§13 元 pattern + 实证锚点段）
3. 5 模块 sanity 不回归 + 60 pytest 不回归

**Batch 详情**：

| 批 | ID | 改动 | 估时（预估）|
|----|---|------|-----|
| 1 | A — v0.3 release 评估 | 评估 5/6 触发条件 + 决定路径 + 起草 ADR-030 (v0.3 Release Timing Decision) | ~45 min |
| 2 | B-1 methodology/01 v0.1.2 | + cross-ref to /02 §10 (Maintenance Sprint) + §11 (P3 复发升级 P2) — role-templates v0.2.1 已落 chief-architect §工程小细节; meth/01 同 cross-ref | ~25 min |
| 3 | B-2 methodology/03 v0.1.2 | + cross-ref to /02 §13 (跨 stack 抽象) — identity_resolver byte-identical dogfood pattern 实证锚点 | ~25 min |
| 4 | B-3 methodology/04 v0.1.2 | + cross-ref to /02 §13 (跨 stack 抽象) — invariant_scaffold soft-equivalent dogfood pattern 实证锚点 | ~25 min |
| **小计** | — | **3 methodology v0.1.2 + 1 ADR-030** | **~120 min** |

#### 工作量估算（v0.1.3 §2.1 新 3 类估时表 / 首次外部使用）

| 类别 | 包含 | 估时 |
|------|------|------|
| **Code** | 无（Sprint S 不动 framework code）| **0 hours** |
| **Docs** | ADR-030 (~150 行 / ~30 min) + methodology/01 v0.1.2 (~60 行 / ~25 min) + methodology/03 v0.1.2 (~60 行 / ~25 min) + methodology/04 v0.1.2 (~60 行 / ~25 min) | **~2 hours** |
| **Closeout / Retro** | stage-4-closeout + sprint-s-retro + sprint-s-residual-debts + STATUS + CHANGELOG | **~0.75 hours** |
| **小计** | — | **~2.75 hours = 1.5-2 会话** |

**v0.1.3 估时表 dogfood 备注**：本 sprint 是 v0.1.3 §2.1 新表的**第 1 次外部使用**——
- 触发 Stop Rule #4（输出量类）的"哪类爆了"判断在 closeout §2 回填时即可生效
- 如果 docs 类爆了 → 调整 §10-§13 cross-ref 段长度
- 如果 closeout 类爆了 → 重新审 closeout 模板冗余段

#### 完成判据（5 项）

- ✅ ADR-030 v0.3 release timing 决策落地（含 5/6 条件评估表 + 选项 A/B/C 论证 + 决策 + 触发条件）
- ✅ methodology/01 + 03 + 04 各 v0.1.1 → v0.1.2（加 §修订历史行 + cross-ref to /02 §10-§13）
- ✅ 5 模块 sanity 不回归 + 60 pytest 全绿
- ✅ ruff check + format 全过
- ✅ Sprint S closeout + retro + STATUS/CHANGELOG 更新 + Sprint T 候选议程

### 2.2 Track 2

不适用（单 track）。

---

## 3. Stages（用 brief-template v0.1.3 §3.B 精简模板）

### Stage 0 — Inventory（已完成 / 本 brief §2.1 即 inventory + 已 grep methodology/01+03+04 现状）

无独立 inventory 文档。

### Stage 1 — Eval + Polish（4 批）

按以下顺序：

1. **批 1：v0.3 release 评估 + ADR-030 起草**（~45 min）
2. **批 2：methodology/01 v0.1.2 cross-ref**（~25 min）
3. **批 3：methodology/03 v0.1.2 cross-ref**（~25 min）
4. **批 4：methodology/04 v0.1.2 cross-ref**（~25 min）

**会话节点建议**（如选 1.5 会话）：
- 会话 1：批 1 + 批 2 + 中场 commit + 用户 ACK
- 会话 2：批 3 + 批 4 + Stage 1.13 + Stage 4

### Stage 1.13 — Sanity 回归

- ruff check + format 全过
- 5 模块 import sanity（identity / invariant / audit_triage / sprint-templates / role-templates）
- 60 pytest 全绿（不回归）

### Stage 4 — Closeout（精简版）

- 标记 5/6 v0.3 候选 → 5/6（不变 / Sprint S 不 land 新候选）
- ADR-030 落地 + 路径决策记录
- methodology/01 + 03 + 04 v0.1.2 落地
- STATUS / CHANGELOG / retro / 衍生债（剩 1 项 v0.3 + 2 项 v0.2 押后 / 不变）
- Sprint T 候选议程

---

## 4. Stop Rules

> 详见 `framework/sprint-templates/stop-rules-catalog.md` 5 类模板。

1. **§3 数据正确性类**：5 模块 sanity 任 1 回归 → Stop（不应该发生 / Sprint S 不动 code）
2. **§3 数据正确性类**：60 pytest 任 1 fail → Stop（不应该发生 / Sprint S 不动 code）
3. **§4 输出量类**：Sprint S 总 docs 行数变化 > +500 → Stop（评估是否 4 段 cross-ref 写过头）
4. **§4 输出量类**：ADR-030 长度 > 300 行 → Stop（评估是否决策论证过度 / ADR 应简洁）
5. **§5 治理类**：触发新 ADR ≥ 2（除 ADR-030）→ Stop（Sprint S 应该只 1 个 ADR）
6. **§6 跨 sprint 一致性类**：Sprint S 工时 > 2.5 会话 → Stop，评估 scope 是否过大

---

## 5. 角色边界

| 角色 | 活跃度 | 主要职责 |
|------|-------|---------|
| 首席架构师 | 🟢 主导 | 全 stage / 单 actor / ADR 起草 + methodology cross-ref 写作 |
| 其余 9 角色 | ⚪ 暂停 | — |

> Single-actor sprint 简化（per brief-template v0.1.3 §5 注脚）。

---

## 6. 收口判定（同 §2.1，重复以便 closeout 直接对照）

- ✅ ADR-030 落地（含 v0.3 release timing 决策 + 5/6 条件评估）
- ✅ methodology/01 + 03 + 04 各 v0.1.2（加 cross-ref to /02 §10-§13）
- ✅ 5 模块 sanity 不回归 + 60 pytest 全绿
- ✅ ruff check + format 全过
- ✅ STATUS / CHANGELOG / retro / 衍生债登记
- ✅ Sprint T 候选议程

---

## 7. 节奏建议

**舒缓 1.5 会话**（推荐 / 按 §2.1 估时 ~2.75h）：

会话 1（~1.5 hours）：
- Stage 1 批 1 v0.3 release 评估 + ADR-030（~45 min）
- Stage 1 批 2 methodology/01 v0.1.2（~25 min）
- 阶段性 commit + 用户中场 ACK

会话 2（~1.25 hours）：
- Stage 1 批 3 methodology/03 v0.1.2（~25 min）
- Stage 1 批 4 methodology/04 v0.1.2（~25 min）
- Stage 1.13 sanity 回归（~10 min）
- Stage 4 closeout + retro + STATUS/CHANGELOG（~30 min）

**紧凑 1 会话**（备选 / ~2.75h 一次完成 / 略 ambitious）：
- 4 批 + sanity + closeout 一次过 / 可能触发 Stop Rule #6（如果某批超估算）

---

## 8. D-route 资产沉淀预期

本 sprint 预期沉淀以下框架抽象资产（**至少勾 ≥ 1 项**；本 sprint 实际勾 3 项）：

- [x] **methodology v0.x → v0.(x+1) 迭代**：methodology/01 + 03 + 04 v0.1.1 → v0.1.2（3 doc cross-ref polish）
- [x] **新 ADR**：ADR-030 (v0.3 Release Timing Decision)
- [ ] 框架代码 spike（不勾 — Sprint S 不动 code）
- [ ] 案例素材积累（不勾 — Sprint S 不动 case）
- [x] **跨领域 mapping 表更新**：methodology/03 + 04 v0.1.2 cross-ref 强化跨 stack 抽象 pattern 对跨域 fork 案例方的指导意义

> 至少 3 项预期 → 远超 ADR-028 / C-22 的 ≥ 1 项要求。

**Layer 进度推进预期**：

- L1: 5 模块 不变（patch sprint 不动 code）
- L2: **methodology/01 + 03 + 04 v0.1.1 → v0.1.2**（3 doc cross-ref polish + ≥ 1 实证锚点）⭐
- L3: 不变
- L4: + ADR-030 v0.3 release timing 决策（明确 release 路径，对外可见性提升）

---

## 9. 模型选型

- **Architect 主 session**：Opus 4.7（与 L+M+N+O+P+Q+R 同）
- **理由**：ADR 起草需要长 context（评估 5/6 条件 + 论证 3 路径） + methodology cross-ref 写作需要风格统一（与原 §1-§N 不漂移）；Sonnet 风险点：ADR 论证常 inconsistent / cross-ref 段写作偶尔 hallucinate 实证锚点

---

## 10. Dogfood 设计

### 10.1 brief-template v0.1.3 第 1 次外部使用 / 首次试新 3 类估时表

本 brief 是 brief-template v0.1.3（Sprint R polish）的**第 1 次外部使用** + 首次试新 §2.1 3 类估时表。

预期发现：
- 3 类估时（Code / Docs / Closeout）vs 单一时长估算的实战价值
- closeout §2 回填 vs estimate 偏离对比
- 是否触发 v0.1.4 polish 候选（如果 3 类估时表暴露问题）

### 10.2 ADR-030 是 v0.3 release path 的 first-class 决策记录

不要把 v0.3 release 决策埋在 retro 或 STATUS 里 — 用 ADR 给跨 sprint / 跨外部 fork 案例方一个明确锚点。

ADR-030 应包含：
- 5/6 已达成条件清单
- 缺 "≥ 1 跨域 reference impl" 的影响评估
- 选项 A/B/C 论证（A 等跨域 / B 调整触发条件 / C 等 T-V03-FW-005）
- 决策 + 触发条件 + 推迟到 Sprint X 的路径

### 10.3 methodology/01 + 03 + 04 v0.1.2 cross-ref 是 maintenance 节奏的延续

Sprint R 让 methodology/02 v0.1.1 沉淀了 4 段元 pattern；Sprint S 把这些 pattern 的 cross-ref 落到 /01 + /03 + /04，让方法论文档群形成"星形 → 网状"结构（每个 doc 都有反向引用 to /02 元 pattern + 各自实证锚点）。

### 10.4 起草本 brief 暴露的发现

无新 brief-template 改进候选（v0.1.3 第 1 次外部使用即顺手；3 类估时表 dogfood 待 closeout §2 回填验证）。

---

## 11. 决策签字

- 首席架构师：__ACK 待签 (2026-04-30)__
- 用户：__ACK 待签 (2026-04-30)__
- 信号：本 brief 用户 ACK 后 → Sprint S Stage 1 启动

---

**本 brief 起草于 2026-04-30 / brief-template v0.1.3 第 1 次外部使用 / Architect Opus**
