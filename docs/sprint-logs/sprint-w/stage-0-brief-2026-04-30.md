# Sprint W Brief — methodology v0.2 cycle 持续 (/05 + /07 → v0.2)

> 起草自 `framework/sprint-templates/brief-template.md` **v0.1.4**（首次使用 7 子类估时表）
> Dogfood: brief-template **第 12 次**外部使用（v0.1.4 第 **1** 次 / 验证 7 子类是否解决 Sprint T Code 主导 + Sprint U new doc 起草偏差问题）

## 0. 元信息

- **架构师**：首席架构师（Claude Opus 4.7）
- **Brief 日期**：2026-04-30
- **Sprint 形态**：**单 track / single-actor**（与 Sprint L→V 同 / Architect Opus 全程）
- **预估工时**：**1.5 会话**（per Sprint V retro §8 推荐 / 双 doc v0.2 polish）
- **PE 模型**：N/A
- **Architect 模型**：Opus 4.7（methodology v0.2 起草需要长 context 综合多 sprint 实证 + 写作风格统一 / Sonnet 风险高）
- **触发事件**：Sprint V 完成 methodology/02 v0.2 起步（v0.x cycle 第 1 doc）→ Sprint W 候选议程 §8 推荐 候选 A：methodology v0.2 cycle 持续 / 推荐 /05 + /07 双 doc
- **战略锚点**：ADR-031 §3 #7 触发条件 (methodology 7 doc 全 ≥ v0.2) + Sprint V retro §8 + Sprint V residual debts §5 v0.2 cycle 进度追踪

---

## 1. 背景

### 1.1 前置上下文

Sprint V 完成 methodology v0.x cycle 起步：methodology/02 v0.1.1 → v0.2（+ §14 Eval Sprint Pattern + §15 Release Sprint Pattern + 重组 §9 总览 4→6 patterns）。当前 1/8 doc ≥ v0.2 / 距 ADR-031 触发条件 #7 达成还需 7 doc bump。

Sprint W 是 v0.2 cycle 第 2 sprint（推 1-2 doc / 推荐 /05 + /07 双 doc）。

Sprint W 在大局中位置：

```
Sprint V (methodology/02 v0.2 起步 / v0.x cycle 第 1 doc)
                     ↓
Sprint W (methodology/05 + /07 → v0.2 / cycle 第 2 sprint) ← 现在
                     ↓
Sprint X+N (剩余 5 doc 各 → v0.2 / 每 sprint 1-2 doc / 预计 ≥ 3-4 sprints)
                     ↓
Sprint Z+? (8/8 doc ≥ v0.2 → ADR-031 触发条件 #7 达成 / + 跨域 ref impl 触发 → v1.0 release)
```

### 1.2 与既有 sprint 的差异

| 维度 | Sprint V (v0.4 maint + meth/02 v0.2) | **Sprint W (双 doc v0.2 polish)** |
|------|---------------------------------|----------------------------------|
| 抽象类型 | maintenance fold + main doc bump | **2 doc methodology v0.2 polish** |
| 抽象输入 | 4 v0.4 候选 + Sprint S+U+P+T 实证 | **/05 v0.1.1 + /07 v0.1 现状 + Sprint K+Q+T 实证 + ADR-032 retroactive** |
| 涉及 doc 数 | 1 main doc bump (/02) | **2 doc bump** (/05 + /07) |
| 主导模型 | Opus | Opus |
| dogfood gate | 5 模块 sanity + 60 pytest | **5 模块 sanity + 60 pytest 不回归** |
| 风险等级 | low | **low**（无新代码 / 全 docs polish）|
| 工作量 | 1.5 会话 | **1.5 会话** |

### 1.3 不做的事（Negative Scope）

- ❌ **不做 v0.5 maintenance**（v0.5 候选仅 2 项 / < 5 阈值 / 不急）
- ❌ **不开新 framework 模块** / **不动 framework v0.3 ABI**
- ❌ **不在本 sprint 完成 v0.2 cycle**（仅 /05 + /07 两 doc / 6 doc 仍 v0.1.x / 持续 Sprint X+N）
- ❌ **不立即 release v1.0**（per ADR-031 §2 / 当前距 #7 达成还需 5 doc bump）
- ❌ **不做 DGF-N-04 / DGF-N-05**（押后等外部触发）
- ❌ **不在 Sprint W 内同时 bump > 2 doc**（避免 scope creep / per Sprint V retro §8 反模式）

---

## 2. 目标范围

### 2.1 单 Track — methodology/05 + /07 v0.2

**目标**：

1. **批 1 — methodology/05 v0.1.1 → v0.2**：加 §8 Audit Immutability Pattern (multi-row audit per source_id + surface_snapshot 冻结 / first-class 抽出) + §7 Framework Implementation 加 ADR-032 retroactive 引用 + 重组（renumber 修订历史 §8 → §9）
2. **批 2 — methodology/07 v0.1 → v0.2**：加 §9 Tooling Pattern for Cross-Stack Abstraction (pglast SQL syntax check + Docker compose minimum schema subset + pre-commit hook services↔framework sync / 沉淀 Sprint R+T 实证) + 重组（renumber 修订历史 §9 → §10）
3. 5 模块 sanity + 60 pytest 不回归
4. methodology v0.2 cycle 进度追踪：1/8 → **3/8** ⭐

**Batch 详情**（v0.1.4 §2.1 7 子类估时表 / 首次使用）：

| 批 | 主题 | 估算（v0.1.4 子类）|
|----|------|-------------------|
| 1 | methodology/05 v0.1.1 → v0.2（+ §8 Audit Immutability Pattern / new first-class section / ~120 行 ↑）| **Docs: new doc 起草** ~50 min |
| 2 | methodology/07 v0.1 → v0.2（+ §9 Tooling Pattern / new first-class section / ~80 行 ↑）| **Docs: new doc 起草** ~40 min |
| 3 | sanity 回归 | (gate) ~10 min |
| 4 | closeout + retro + STATUS/CHANGELOG | **Closeout** ~30 min |

#### 工作量估算（v0.1.4 §2.1 / 7 子类首试）

| 类别 / 子类 | 包含 / typical 速率 | ⚠️估时 |
|-----------|-----------------|------|
| Code: 框架 spike / 已有 pattern fold | — | 0 |
| Code: 新模块抽象 / 全新 Plugin Protocol | — | 0 |
| Code: patch / version bump 等模板化改 | — | 0 |
| **Docs: cross-ref polish** | — (本 sprint 不做 cross-ref polish 类) | 0 |
| **Docs: new doc 起草** | methodology/05 + /07 v0.2 加新 first-class section（属新内容起草 / per Sprint U 实证 ~110-130%）| **~90 min**（50 min /05 + 40 min /07）|
| Docs: ADR / 决策记录 | — | 0 |
| **Closeout / Retro** | stage-4-closeout + sprint-w-retro + sprint-w-residual-debts + STATUS + CHANGELOG | **~30 min** |
| **小计** | — | **~120 min ≈ 1.5 会话** |

> **v0.1.4 估时表第 1 次外部 dogfood 备注**：
> - Sprint W 全部归为 "Docs: new doc 起草" 子类（因为 v0.2 加 first-class section 视为 new doc-段 起草 / 不是 cross-ref polish）
> - 预期偏差 ≤ 5%（vs v0.1.3 大类 ≤ 10% / 子类应更精确）
> - 如 Sprint W 实际偏差 > 10% → 触发 v0.1.5 polish 候选

#### 完成判据（5 项）

- ✅ methodology/05 v0.1.1 → v0.2（+ §8 Audit Immutability Pattern / + ADR-032 引用 in §7）
- ✅ methodology/07 v0.1 → v0.2（+ §9 Tooling Pattern for Cross-Stack Abstraction）
- ✅ 5 模块 sanity 不回归 + 60 pytest 全绿
- ✅ STATUS / CHANGELOG / retro / 衍生债 + Sprint X 候选议程
- ✅ methodology v0.2 cycle 进度更新：1/8 → **3/8** ⭐

### 2.2 Track 2

不适用（单 track）。

---

## 3. Stages（用 brief-template v0.1.4 §3.B 精简模板）

### Stage 0 — Inventory（已完成 / 本 brief §1.1 + §2.1 即 inventory + 已 grep /05 + /07 现状 / 已设计 §8 + §9 大纲）

无独立 inventory 文档。

### Stage 1 — Methodology v0.2 Polish（2 批）

按以下顺序：

1. **批 1：methodology/05 v0.1.1 → v0.2**（~50 min）
2. **批 2：methodology/07 v0.1 → v0.2**（~40 min）

**会话节点建议**（1.5 会话 / 与 Sprint S+U+V 同模式）：
- 会话 1：批 1 (~50 min) + 中场 commit + 用户 ACK
- 会话 2：批 2 (~40 min) + Stage 1.13 + Stage 4

### Stage 1.13 — Sanity 回归

- ruff check + format 全过
- 5 模块 import sanity
- 60 pytest 全绿
- methodology 8 doc 全部存在 + 版本验证（/05 应 ≥ v0.2 / /07 应 ≥ v0.2）

### Stage 4 — Closeout

- 标记 v0.2 cycle 进度 1/8 → 3/8 ⭐
- STATUS / CHANGELOG / retro / 衍生债登记
- Sprint X 候选议程（剩余 5 doc：/00 + /01 + /03 + /04 + /06 / 推荐每 sprint 1-2 doc）

---

## 4. Stop Rules

> 详见 `framework/sprint-templates/stop-rules-catalog.md` 5 类模板。

1. **§3 数据正确性类**：5 模块 sanity 任 1 回归 → Stop（不应该发生 / Sprint W 不动 code）
2. **§3 数据正确性类**：60 pytest 任 1 fail → Stop（不应该发生 / Sprint W 不动 code）
3. **§4 输出量类**：methodology/05 v0.2 总长度 > 600 行（vs 当前 v0.1.1 401 行 + §8 加段 ~120 行 = ~520 估算）→ Stop
4. **§4 输出量类**：methodology/07 v0.2 总长度 > 450 行（vs 当前 v0.1 301 行 + §9 加段 ~80 行 = ~380 估算）→ Stop
5. **§5 治理类**：触发新 ADR ≥ 1 → Stop（Sprint W 是 methodology iter / 不应起 ADR）
6. **§6 跨 sprint 一致性类**：Sprint W 工时 > 2.5 会话 → Stop（评估 scope 是否过大）

---

## 5. 角色边界

| 角色 | 活跃度 | 主要职责 |
|------|-------|---------|
| 首席架构师 | 🟢 主导 | 全 stage / 单 actor / methodology v0.2 起草 |
| 其余 9 角色 | ⚪ 暂停 | — |

> Single-actor sprint 简化（per brief-template v0.1.4 §5 注脚）。

---

## 6. 收口判定（同 §2.1）

- ✅ methodology/05 v0.1.1 → v0.2
- ✅ methodology/07 v0.1 → v0.2
- ✅ 5 模块 sanity + 60 pytest 不回归
- ✅ STATUS / CHANGELOG / retro / 衍生债 + Sprint X 候选议程
- ✅ v0.2 cycle 进度 1/8 → 3/8

---

## 7. 节奏建议

**舒缓 1.5 会话**（推荐 / 与 Sprint S+U+V 同 scale）：

会话 1（~1 hour）：
- Stage 1 批 1 methodology/05 v0.2 (~50 min)
- 阶段性 commit + 用户中场 ACK

会话 2（~1.25 hours）：
- Stage 1 批 2 methodology/07 v0.2 (~40 min)
- Stage 1.13 sanity (~10 min)
- Stage 4 closeout + retro (~30 min)

---

## 8. D-route 资产沉淀预期

本 sprint 预期沉淀以下框架抽象资产（**至少勾 ≥ 1 项**；本 sprint 实际勾 3 项）：

- [x] **methodology v0.x → v0.(x+1) 大 bump**：methodology/05 v0.1.1 → v0.2 + methodology/07 v0.1 → v0.2（v0.2 cycle 第 2 sprint / 双 doc）
- [x] **新 first-class methodology section**：/05 §8 Audit Immutability Pattern + /07 §9 Tooling Pattern for Cross-Stack Abstraction（2 段 first-class pattern）⭐
- [x] **sprint pattern 演化数据点**：Sprint W = 第 2 个 v0.x cycle 持续 sprint（vs Sprint V 起步）/ 加入 methodology/02 v0.3 候选段 "v0.x cycle 持续 sprint pattern"
- [ ] 框架代码 spike（不勾 — Sprint W 不动 code）
- [ ] 案例素材积累（不勾）

> 至少 3 项预期 → 远超 ADR-028 / C-22 的 ≥ 1 项要求。

**Layer 进度推进预期**：

- L1: 5 模块 v0.3.0 不变
- L2: methodology v0.2 cycle 进度 1/8 → **3/8**（/02 + /05 + /07）⭐
- L3: 不变
- L4: 不变（v0.2 cycle 持续 / 距 v1.0 触发条件 #7 达成 5 doc bump）

---

## 9. 模型选型

- **Architect 主 session**：Opus 4.7（与 L→V 同）
- **理由**：methodology v0.2 起草需要长 context 综合多 sprint 实证（/05 ← Sprint K+Q+ADR-032 / /07 ← Sprint Q+R+T）+ 写作风格统一（与原 §1-§7 一致）+ 跨 doc cross-ref（/05 + /07 + /02 v0.2 §15.3 引用）

---

## 10. Dogfood 设计

### 10.1 brief-template v0.1.4 第 1 次外部使用 / 7 子类估时首验证

本 brief 是 v0.1.4（Sprint V 批 3 polish）的**第 1 次外部使用**。
- 全部归 "Docs: new doc 起草" 子类（per /05 + /07 v0.2 加新 first-class section 性质）
- 预期偏差 ≤ 5%（vs v0.1.3 大类 ≤ 10%）
- closeout §2 回填验证

如 Sprint W 实际偏差 > 10% → 触发 v0.1.5 polish 候选（待 Sprint X+ retro 时评估）。

### 10.2 methodology v0.2 cycle 第 2 sprint = "持续 sprint" 形态实证

vs Sprint V 起步 sprint（v0.4 maintenance + v0.2 cycle 起步合并），Sprint W 是纯 v0.2 cycle 持续 sprint（无 maintenance fold）。形态对比：

| 形态 | 实证 sprint | typical 工时 | 触发条件 |
|------|-----------|-----------|---------|
| v0.x cycle 起步 sprint | Sprint V | 1.5-2 会话 | maintenance + main doc bump 合并 |
| **v0.x cycle 持续 sprint** | **Sprint W** | **1.5 会话** | **每 sprint 1-2 doc bump / 持续 ≥ 4 sprint** |

**沉淀**：methodology/02 v0.3 候选段（待 Sprint X+ 起草）可加 "v0.x cycle 持续 sprint pattern"（与起步 sprint 并列 / 7 patterns）。

### 10.3 起草本 brief 暴露的发现

无新 brief-template 改进候选。但 v0.1.4 全部归一类（"Docs: new doc 起草"）的 dogfood 仅 1 子类，**未充分验证其他 6 子类**。Sprint X+ 应该用 mix 子类的 sprint dogfood 验证。

---

## 11. 决策签字

- 首席架构师：__ACK 待签 (2026-04-30)__
- 用户：__ACK 待签 (2026-04-30)__

---

**本 brief 起草于 2026-04-30 / brief-template v0.1.4 第 1 次外部使用 / Architect Opus**
