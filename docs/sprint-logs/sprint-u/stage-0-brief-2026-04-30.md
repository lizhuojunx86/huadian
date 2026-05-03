# Sprint U Brief — v1.0 候选议程评估 (ADR-031) + methodology/06 v0.1.1 + methodology/07 新起草 (cross-stack abstraction)

> 起草自 `framework/sprint-templates/brief-template.md` v0.1.3
> Dogfood: brief-template **第 10 次**外部使用（v0.1.3 第 **3** 次 / 估时表第 3 次试 / 累积 3 次趋势观察）

## 0. 元信息

- **架构师**：首席架构师（Claude Opus 4.7）
- **Brief 日期**：2026-04-30
- **Sprint 形态**：**单 track / single-actor**（与 Sprint L→T 同 / Architect Opus 全程）
- **预估工时**：**1.5-2 会话**（候选 A+B 合并 / per Sprint T retro §8 推荐）
- **PE 模型**：N/A（single-actor）
- **Architect 模型**：Opus 4.7（评估 + 起草新 methodology + ADR / 长 context + 多文件 cross-ref / Sonnet 风险高）
- **触发事件**：Sprint T 完成 = framework v0.3.0 release land + 5 sprint zero-trigger 连续达成（per Sprint R retro §5.1 期待）→ Sprint U 候选议程 §8 推荐 候选 A + B 合并；用户 "ACK 请继续"
- **战略锚点**：Sprint T retro §7.4 + §8 + Sprint T residual debts §6 v1.0 候选议程评估清单 + Sprint Q residual debts §3.x（/07 cross-stack-abstraction-pattern 待起草）

---

## 1. 背景

### 1.1 前置上下文

Sprint Q→T cycle 完成 framework v0.3.0 release（5 模块齐备 + Docker dogfood + methodology 网状 cross-ref + 6/6 v0.3 patch land）。**5 sprint zero-trigger 连续触发 v1.0 候选议程评估**（per Sprint R retro §5.1 期待 / Sprint T 实证达成）。

Sprint S 最初 brief 把 methodology/06 + /07 都标 "Stage C 待起草" 是不精确的：
- **methodology/06** 实际已是 431 行完整 v0.1 draft（Sprint S+T 推迟 cross-ref polish 到 Sprint U）
- **methodology/07** 确实不存在 — 主题应为 "cross-stack abstraction pattern"，沉淀 Sprint Q audit_triage (TS prod → Python framework) + Sprint T Docker dogfood (sandbox/CI dogfood infra) 实证

methodology/00 §2 列 "**6 大核心抽象**"（/01-/06）— Sprint U 加 /07 后变 "**7 大核心抽象**"（与 framework 5 模块 / methodology 7 doc / 数字呼应）。

Sprint U 在大局中位置：

```
Sprint Q→R→S→T (v0.3 cycle / 5 模块齐备 + maintenance + eval + release)
                     ↓
Sprint U (v1.0 候选议程评估 + methodology/06+07 polish/start) ← 现在
                     ↓
Sprint U+N (v0.4 maintenance / 跨域案例方接触触发 / methodology v0.2 cycle)
                     ↓
Sprint Z+? (v1.0 触发条件全达成 → v1.0 release sprint)
```

### 1.2 与既有 sprint 的差异

| 维度 | Sprint L-O 抽象 | Sprint P+R (patch) | Sprint Q (新模块) | Sprint S (eval) | Sprint T (release+feature) | **Sprint U (eval + meth)** |
|------|--------------|------------------|---------------|----------------|--------------------------|----------------------------|
| 抽象类型 | 新模块 | patch | 新模块 + 补测 | eval + meth iter | release + feature | **eval (v1.0) + meth iter (06 cross-ref) + meth new (07)** |
| 抽象输入 | services/pipeline | v0.x 候选 | TS triage | 5/6 v0.3 触发条件 | Docker compose feature | **5 sprint zero-trigger 实证 + Sprint Q+T 跨 stack 实证 + methodology/06 v0.1 修订** |
| 涉及模块 | 1 模块 | 4-5 模块 | 1 新模块 | 0 模块 (全 docs) | 5 模块统一 | **0 模块 + 1 ADR + 2 methodology** |
| 主导模型 | Opus | Opus | Opus | Opus | Opus | **Opus** |
| dogfood gate | byte/soft-equiv | sanity | 60 pytest | sanity 不回归 | Docker dogfood + ADR §5 回填 | **5 模块 sanity + 60 pytest 不回归** |
| 风险等级 | low → medium | low | medium | low | medium | **low**（无新代码 / 全 docs + 评估）|
| 工作量 | 1-3 会话 | 1 会话 | 2 会话 | 1.5 会话 | 2 会话 | **1.5-2 会话** |

### 1.3 不做的事（Negative Scope）

- ❌ **不立即 release v1.0**（Sprint U 是评估 sprint / 起草 ADR-031 触发条件 / 评估当前距离 v1.0 还差什么 / 不立即触发 release）
- ❌ **不做新 framework 模块**（5 模块齐备已是阶段终点 / methodology/02 §12）
- ❌ **不动 framework v0.3 ABI**（保稳定到 v0.4 / v1.0 release）
- ❌ **不做 v0.4 maintenance**（候选累积仅 2 项 / 不急）
- ❌ **不做 DGF-N-04 / DGF-N-05**（押后等外部触发）
- ❌ **不做新 ADR ≥ 2**（仅 ADR-031 / Sprint U 是评估 sprint）
- ❌ **不动 services/pipeline 生产代码 / services/api 生产 TS**

---

## 2. 目标范围

### 2.1 单 Track — v1.0 评估 + methodology/06+07

**目标**：

1. **批 1 — ADR-031 v1.0 候选议程评估**（评估 7 候选触发条件 + 决策不立即 release + 路径预测）
2. **批 2 — methodology/06 v0.1 → v0.1.1**（加 §X 与 /02 元 pattern 关系 + 实证锚点段 / 与 /01+/03+/04 v0.1.2 同模式）
3. **批 3 — methodology/07 v0.1 起草**（"Cross-Stack Abstraction Pattern" 新 doc / 沉淀 Sprint Q + T 实证）
4. **批 4 — methodology/00 §2 同步**（6 大 → 7 大核心抽象 / 加 /07 行）
5. 5 模块 sanity + 60 pytest 不回归

**Batch 详情**：

| 批 | 主题 | 估时（v0.1.3 §2.1 三类）|
|----|------|----|
| 1 | ADR-031 v1.0 候选议程评估 | Docs ~45 min |
| 2 | methodology/06 v0.1 → v0.1.1 cross-ref | Docs ~25 min |
| 3 | methodology/07 v0.1 起草 (cross-stack abstraction pattern / new doc / ~250 行) | Docs ~60 min |
| 4 | methodology/00 §2 同步 (6 → 7) | Docs ~10 min |
| 5 | sanity 回归 | (gate) ~10 min |
| 4 (closeout) | closeout + retro + STATUS/CHANGELOG | Closeout ~30 min |

#### 工作量估算（v0.1.3 §2.1 / 第 3 次外部 dogfood / 累积趋势观察）

| 类别 | 包含 | 估时 |
|------|------|------|
| **Code** | 无（Sprint U 不动 framework code）| **0 hours** |
| **Docs** | ADR-031 (~150 行) + methodology/06 v0.1.1 (+50 行) + methodology/07 v0.1 起草 (~250 行) + /00 §2 同步 (+10 行) | **~2.5 hours** |
| **Closeout / Retro** | stage-4-closeout + sprint-u-retro + sprint-u-residual-debts + STATUS + CHANGELOG | **~0.75 hours** |
| **小计** | — | **~3.25 hours = 1.5-2 会话** |

**v0.1.3 估时表第 3 次 dogfood 备注 / 趋势观察**：
- Sprint S 第 1 次（Code=0 / Docs 主导）：偏差 < 10% ✓
- Sprint T 第 2 次（Code 主导）：Code 类偏保守（实际 47% / 触发 v0.4 候选 T-V04-FW-002 子类拆分）
- **Sprint U 第 3 次**（Code=0 / Docs 主导 / 与 Sprint S 同类型）：预期偏差 < 10%（验证模板对"Docs 主导"形态的稳定性）

#### 完成判据（6 项）

- ✅ ADR-031 v1.0 候选议程评估落地（含 7 候选触发条件评估表 + 决策不立即 release + Sprint U+N 路径）
- ✅ methodology/06 v0.1 → v0.1.1（加 §X 与 /02 元 pattern 关系 + 实证锚点）
- ✅ methodology/07 v0.1 起草完成（"Cross-Stack Abstraction Pattern" / Sprint Q + T 实证沉淀）
- ✅ methodology/00 §2 6 大 → 7 大核心抽象（加 /07 行）
- ✅ 5 模块 sanity 不回归 + 60 pytest 全绿
- ✅ STATUS / CHANGELOG / retro / 衍生债登记 + Sprint V 候选议程

### 2.2 Track 2

不适用（单 track）。

---

## 3. Stages（用 brief-template v0.1.3 §3.B 精简模板）

### Stage 0 — Inventory（已完成 / 本 brief §1.1 + §2.1 即 inventory + 已 grep methodology/06 + /07 + /00 现状）

无独立 inventory 文档。

### Stage 1 — Eval + Polish + New Doc（4 批）

按以下顺序：

1. **批 1：ADR-031 v1.0 候选议程评估**（~45 min）
2. **批 2：methodology/06 v0.1 → v0.1.1 cross-ref**（~25 min）
3. **批 3：methodology/07 v0.1 起草**（~60 min / new doc）
4. **批 4：methodology/00 §2 同步 (6 → 7)**（~10 min）

**会话节点建议**：
- 会话 1：批 1+2 (~70 min) + 中场 commit + 用户 ACK
- 会话 2：批 3+4 (~70 min) + Stage 1.13 + Stage 4

### Stage 1.13 — Sanity 回归

- ruff check + format 全过
- 5 模块 import sanity（含 v0.3.0 versions）
- 60 pytest 全绿（不回归）
- methodology 7 doc 全部存在 + 版本验证

### Stage 4 — Closeout（精简版）

- 标记 v0.4 候选 + ADR-031 落地
- methodology 7 doc 完整（vs Sprint U 前 6 doc）
- STATUS / CHANGELOG / retro / 衍生债登记
- Sprint V 候选议程

---

## 4. Stop Rules

> 详见 `framework/sprint-templates/stop-rules-catalog.md` 5 类模板。

1. **§3 数据正确性类**：5 模块 sanity 任 1 回归 → Stop（不应该发生 / Sprint U 不动 code）
2. **§3 数据正确性类**：60 pytest 任 1 fail → Stop（不应该发生 / Sprint U 不动 code）
3. **§4 输出量类**：methodology/07 行数 > 400（vs 估算 ~250 行）→ Stop（评估 scope 是否 over / 拆 Sprint U+0.5）
4. **§4 输出量类**：ADR-031 行数 > 300（vs 估算 ~150 行）→ Stop（评估论证是否 over）
5. **§5 治理类**：触发新 ADR ≥ 2（除 ADR-031）→ Stop
6. **§6 跨 sprint 一致性类**：Sprint U 工时 > 2.5 会话 → Stop（评估 scope 是否过大）

---

## 5. 角色边界

| 角色 | 活跃度 | 主要职责 |
|------|-------|---------|
| 首席架构师 | 🟢 主导 | 全 stage / 单 actor / ADR 起草 + methodology cross-ref + 新 doc 起草 |
| 其余 9 角色 | ⚪ 暂停 | — |

> Single-actor sprint 简化（per brief-template v0.1.3 §5 注脚）。

---

## 6. 收口判定（同 §2.1，重复以便 closeout 直接对照）

- ✅ ADR-031 v1.0 评估 + 决策落地
- ✅ methodology/06 v0.1.1
- ✅ methodology/07 v0.1
- ✅ methodology/00 §2 6 → 7 同步
- ✅ 5 模块 sanity + 60 pytest 不回归
- ✅ STATUS / CHANGELOG / retro / 衍生债 + Sprint V 候选议程

---

## 7. 节奏建议

**舒缓 1.5 会话**（推荐 / 与 Sprint S 同 scale / 全 docs / 无 code feature）：

会话 1（~1.5 hours）：
- Stage 1 批 1 ADR-031 (~45 min)
- Stage 1 批 2 methodology/06 v0.1.1 (~25 min)
- 阶段性 commit + 用户中场 ACK

会话 2（~1.75 hours）：
- Stage 1 批 3 methodology/07 v0.1 起草 (~60 min)
- Stage 1 批 4 /00 §2 同步 (~10 min)
- Stage 1.13 sanity (~10 min)
- Stage 4 closeout + retro (~30 min)

**紧凑 1 会话**（备选 / 不推荐 / 3.25h ambitious / 触发 Stop Rule #6 风险）

---

## 8. D-route 资产沉淀预期

本 sprint 预期沉淀以下框架抽象资产（**至少勾 ≥ 1 项**；本 sprint 实际勾 4 项）：

- [x] **新 ADR**：ADR-031 (v1.0 Release Candidate Agenda Evaluation)
- [x] **methodology v0.x → v0.(x+1) 迭代**：methodology/06 v0.1 → v0.1.1（cross-ref to /02 元 pattern）
- [x] **新 methodology doc**：methodology/07 v0.1（Cross-Stack Abstraction Pattern / 第 7 大核心抽象 / 沉淀 Sprint Q+T 实证）⭐
- [x] **methodology/00 同步**：6 大 → 7 大核心抽象（架构文档群完整化）
- [ ] 框架代码 spike（不勾 — Sprint U 不动 code）
- [ ] 案例素材积累（不勾 — Sprint U 不动 case）

> 至少 4 项预期 → 远超 ADR-028 / C-22 的 ≥ 1 项要求。

**Layer 进度推进预期**：

- L1: 5 模块 v0.3.0 不变
- L2: methodology/06 v0.1 → v0.1.1 + **methodology/07 v0.1 新增 ⭐**（7 doc 完整 / 6 大 → 7 大核心抽象）
- L3: 不变
- L4: + ADR-031 v1.0 候选议程评估（明确 v1.0 触发条件 / 公开 release 路径预测）

---

## 9. 模型选型

- **Architect 主 session**：Opus 4.7（与 L→T 同）
- **理由**：methodology/07 是新 doc 起草（vs cross-ref polish）/ 需要长 context 综合 Sprint Q+T 跨 stack 实证 + 写作风格统一（与 /01-/06 平行结构）；ADR-031 v1.0 评估需要长 context 综合 7 sprint 实证；Sonnet 风险点：新 doc 起草偶尔 hallucinate 实证锚点 / cross-ref 段写作易 inconsistent。

---

## 10. Dogfood 设计

### 10.1 brief-template v0.1.3 第 3 次外部使用 / 累积趋势观察

本 brief 是 v0.1.3 第 3 次外部 dogfood：
- 第 1 次（Sprint S）：Code=0 / Docs 主导 / 偏差 < 10% ✓
- 第 2 次（Sprint T）：Code 主导 / Code 类偏保守 → 触发 v0.4 候选 T-V04-FW-002
- **第 3 次（Sprint U）**：Code=0 / Docs 主导 / **预期偏差 < 10%**（验证 v0.1.3 表对"Docs 主导"形态的稳定性 = 验证 v0.4 候选 T-V04-FW-002 是否仅适用 Code 主导）

### 10.2 methodology/07 是 framework 文档群完整化的最后一刀

vs methodology/00 §2 当前 "6 大核心抽象"，加 /07 后 framework 文档群完整化：
- 1 (overview) + 6 (patterns)（当前）→ 1 (overview) + **7 (patterns)** ⭐
- 与 framework 5 模块对应：/01 → role-templates / /02 → sprint-templates / /03 → identity_resolver / /04 → invariant_scaffold / /05 → audit_triage / /06 → ADR pattern (跨 framework) / /07 → cross-stack abstraction pattern (跨 framework)
- 7 doc 完整覆盖 framework 抽象的方法论维度

### 10.3 ADR-031 是 framework 第 2 个 release-related ADR

vs ADR-030 (v0.3 release timing)，ADR-031 是 v1.0 release **议程评估**（不是触发）。两个 ADR 形成对比：
- ADR-030：6 触发条件 5/6 ✅ → 立即 release v0.3
- ADR-031：7+ 候选触发条件 + 评估当前差距 → 不立即 release v1.0 / 路径预测

模板可被未来 v0.4 / v0.5 / v1.0+ release timing decisions 复用。

### 10.4 起草本 brief 暴露的发现

无新 brief-template 改进候选（v0.1.3 第 3 次使用顺手）。

---

## 11. 决策签字

- 首席架构师：__ACK 待签 (2026-04-30)__
- 用户：__ACK 待签 (2026-04-30)__
- 信号：本 brief 用户 ACK 后 → Sprint U Stage 1 启动

---

**本 brief 起草于 2026-04-30 / brief-template v0.1.3 第 3 次外部使用 / Architect Opus**
