# Sprint R Brief — v0.3 Patch + methodology v0.2 Polish 合并

> 起草自 `framework/sprint-templates/brief-template.md` v0.1.2
> Dogfood: brief-template **第 7 次**外部使用（v0.1.2 第 **2** 次）

## 0. 元信息

- **架构师**：首席架构师（Claude Opus 4.7）
- **Brief 日期**：2026-04-30
- **Sprint 形态**：**单 track / single-actor**（与 Sprint L+M+N+O+P+Q 同 / Architect Opus 全程）
- **预估工时**：**1-2 个 Cowork 会话**（推荐紧凑 1 会话 / 备选舒缓 2 会话）
- **PE 模型**：N/A（single-actor）
- **Architect 模型**：Opus 4.7
- **触发事件**：Sprint Q retro §8 推荐 候选 A（v0.3 patch sprint）+ 候选 B（methodology v0.2 polish 合并）；Sprint Q dogfood ✅ + 6 v0.3 候选累积成熟
- **战略锚点**：[ADR-028](../../decisions/ADR-028-strategic-pivot-to-methodology.md) §2.3 + Sprint Q retro §8 + 6 v0.3 候选清单

---

## 1. 背景

### 1.1 前置上下文

Sprint L→Q 完成 framework 抽象首次完整（5 模块齐备 + v0.2.0 release + audit_triage v0.1 + 60 pytest tests）。Sprint Q dogfood ✅ 实证跨 stack 抽象 pattern 完整闭环（TS prod ↔ Python framework 64 行 pending + 7 historical decisions 完全等价）。

Sprint Q 累积 4 项 v0.3 候选 + 继承 Sprint P 留 2 项 → 6 项 v0.3 候选累积成熟，触发 Sprint R **v0.3 patch sprint**（清债 + methodology v0.2 polish）。

Sprint R 在大局中位置：

```
Sprint L → M → N → O (4 模块抽象)
                     ↓
Sprint P (v0.2 patch + v0.2.0 release)
                     ↓
Sprint Q (audit_triage + 60 pytest + 5 模块齐备 ⭐)
                     ↓
Sprint R (v0.3 patch + methodology v0.2 polish) ← 现在
                     ↓
Sprint R+N (条件成熟 → v0.3 release)
```

完成后：
- 6 v0.3 候选清单 → 5 项 land + 1 项押后（T-V03-FW-005 大工作 / Docker compose Postgres）
- methodology/02 v0.1 → v0.1.1（加 Maintenance Sprint Pattern + P3 复发升级 P2 + 5 模块齐备阈值 + 跨 stack 抽象等元 pattern）
- methodology/05 v0.1.1 不动（Sprint Q 已 polish）
- brief-template v0.1.2 → v0.1.3（§2.1 估时按 code/docs/retro 3 类分别列）
- identity_resolver/README §2 加 `__all__` 等价"公共 API"段
- 1 个新 pre-commit hook (services↔framework/examples sync warning)
- chief-architect.md 加 dataclass-test-grep-target 流程规则

### 1.2 与既有 sprint 的差异

| 维度 | Sprint L-O 抽象 | Sprint P (v0.2 patch) | Sprint Q (新模块) | **Sprint R (v0.3 patch + meth polish)** |
|------|--------------|---------------------|---------------|----------------------------------|
| 抽象类型 | 新模块抽象 | incremental fix | 新模块抽象 + pytest | **incremental fix + methodology iter** |
| 抽象输入 | services/pipeline 代码 | 20 v0.2 候选 | TS triage + ADR-027 | **6 v0.3 候选 + Sprint P+Q retro 元 pattern** |
| 涉及模块 | 1 模块 / sprint | 4 模块 polish | 1 新模块 + 2 模块补测 | **5 模块 + 2 methodology + 1 hook** |
| 主导模型 | Opus 全程 | Opus 全程 | Opus 全程 | **Opus 全程** |
| dogfood gate | byte-identical / soft-equiv | 简单 sanity | 60 pytest + soft-equiv | **5 模块 sanity + pre-commit hook 自跑** |
| 风险等级 | low → medium | low | medium | **low**（无新代码 / 全 polish）|
| 工作量 | 1-3 会话 | 1 会话 | 2 会话 | **1-2 会话**（推荐 1 会话紧凑）|

### 1.3 不做的事（Negative Scope）

- ❌ **不做 v0.3 release**（押后条件未满足：DGF-N-04 + DGF-N-05 + 跨域 reference impl 仍未 land）
- ❌ **不开发新 framework 模块**（5 模块齐备已是抽象阶段终点 / v0.x 期内）
- ❌ **不动 audit_triage v0.1 ABI**（保稳定到 v0.2 release）
- ❌ **不做 T-V03-FW-005**（Docker compose Postgres + seed fixtures 是大工作 / 押后 Sprint R+1 或更晚）
- ❌ **不做 DGF-N-04 / DGF-N-05**（押后等外部触发，per Sprint Q residual debts）
- ❌ **不立即触发 ADR-031 plugin 协议**（per Sprint M-O-P-Q 同结论）
- ❌ **不动 services/pipeline 生产代码**

---

## 2. 目标范围

### 2.1 单 Track — v0.3 patch + methodology v0.2 polish

**目标**：

1. 清 5 项 v0.3 候选（押后 T-V03-FW-005 1 项）
2. methodology/02 v0.1 → v0.1.1（加 4 段元 pattern：Maintenance Sprint / P3 复发升级 P2 / 5 模块齐备阈值 / 跨 stack 抽象）
3. brief-template v0.1.2 → v0.1.3（§2.1 估时按 code/docs/retro 3 类分别列）
4. 5 模块 sanity 不回归 + 60 pytest 不回归 + 新 pre-commit hook 跑通

**5 项 v0.3 候选清单**：

| ID | 类型 | 改动 | 估时 |
|----|------|------|------|
| **T-V03-FW-001** | doc polish | identity_resolver/README §2 加 `__all__` 等价"公共 API"段 | ~10 min |
| **T-V03-FW-002** | methodology v0.2 | methodology/02 v0.1.1 加 §10 "Maintenance Sprint Pattern" + §11 "P3 复发升级 P2 暗规则" | ~30 min |
| **T-V03-FW-003** | template polish | brief-template §2.1 估时表按 code/docs/retro 3 类分别列；bump v0.1.2 → v0.1.3 | ~10 min |
| **T-V03-FW-004** | 流程规则 | chief-architect.md 加 §"dataclass shape test 起草前必须 grep target 字段" | ~5 min |
| **T-V03-FW-006** | pre-commit hook | 加 hook 检测 services/api/triage.* 修改但 framework/audit_triage/examples/huadian_classics/ 未修改 → warning（不阻塞）| ~30 min |
| ~~T-V03-FW-005~~ | (押后) | Docker compose Postgres + seed fixtures（大工作 ≥ 4 hours）| 押后 Sprint R+1 或更晚 |
| **小计** | — | **5 项 + 2 methodology 段** | **~85 min（含 methodology v0.2 polish）** |

**methodology v0.2 polish 详情**（与 T-V03-FW-002 合并，~30 min）：

`docs/methodology/02-sprint-governance-pattern.md` v0.1 → v0.1.1 加 4 段：

| 段 | 主题 | 来源 |
|----|------|------|
| §10 | Maintenance Sprint Pattern（清债 sprint 形态）| Sprint P retro §5.1 + Sprint Q 实证 |
| §11 | P3 复发升级 P2 暗规则 | Sprint P retro §5.1（DGF-N-02 → DGF-O-01 跨 sprint 复发）|
| §12 | 5 模块齐备阈值 | Sprint Q retro §5.1（"完成度 vs 完美" 取舍）|
| §13 | 跨 stack 抽象 pattern（TS prod → Python framework）| Sprint Q retro §5.1 + audit_triage 实证 |

加 4 段约 +200 行；methodology/02 由 402 → ~600 行（仍在合理范围）。

**完成判据**（5 项）：

- ✅ 5 项 v0.3 候选 land + ruff clean + 5 模块 sanity 跑通
- ✅ methodology/02 v0.1 → v0.1.1（+ 4 段 / §修订历史更新）
- ✅ brief-template v0.1.2 → v0.1.3
- ✅ 60 pytest 全绿不回归 + 5 模块 import sanity 不回归
- ✅ Sprint R closeout + retro + STATUS/CHANGELOG 更新

### 2.2 Track 2

不适用（单 track）。

---

## 3. Stages（用 brief-template v0.1.2 §3.B 精简模板）

### Stage 0 — Inventory（已完成 / 本 brief §2.1 即 inventory + 已 grep 实际位置）

无独立 inventory 文档。

### Stage 1 — Patch + Polish（5 批）

按以下顺序：

1. **批 1：T-V03-FW-001 + T-V03-FW-003** — identity_resolver/README §2 加公共 API 段 + brief-template §2.1 改估时表格 + bump v0.1.3（~20 min）
2. **批 2：T-V03-FW-004** — chief-architect.md 加 dataclass-test-grep 流程规则（~5 min）
3. **批 3：T-V03-FW-002 = methodology/02 v0.1.1**（4 段：Maintenance Sprint / P3 复发升级 / 5 模块齐备 / 跨 stack 抽象）（~30 min）
4. **批 4：T-V03-FW-006** — pre-commit hook services↔framework/examples sync warning（~30 min）
5. **批 5：5 模块 sanity 回归 + 60 pytest 全跑**（~15 min）

### Stage 1.13 — Sanity 回归

- ruff check + format 全过
- 5 模块 import sanity（identity / invariant / audit_triage / sprint-templates / role-templates）
- 60 pytest 全绿
- 新 pre-commit hook 自跑（修改测试 file 触发 warning）

### Stage 4 — Closeout（精简版）

- 标记 6 → 1 v0.3 候选（押后 T-V03-FW-005）
- methodology/02 v0.1.1 落地
- STATUS / CHANGELOG / retro / 衍生债（剩 1 项 v0.3 + 2 项 v0.2 押后）
- Sprint S 候选议程

---

## 4. Stop Rules

> 详见 `framework/sprint-templates/stop-rules-catalog.md` 5 类模板。

1. **§3 数据正确性类**：5 模块 sanity 任 1 回归 → Stop，立即 revert + 重审改动
2. **§3 数据正确性类**：60 pytest 任 1 fail → Stop，立即修因（不允许 skip）
3. **§3 数据正确性类**：新 pre-commit hook 误报率高（误判 ≥ 30%）→ Stop，调整规则或 revert
4. **§4 输出量类**：Sprint R 总 Python 行数变化 > +500 → Stop（v0.3 patch 应主要是 docs / hook，不该写大量代码）
5. **§5 治理类**：触发新 ADR ≥ 1 → Stop（patch sprint 不应触发 ADR）
6. **§6 跨 sprint 一致性类**：Sprint R 工时 > 2 会话 → Stop，评估 scope 是否过大

---

## 5. 角色边界

| 角色 | 活跃度 | 主要职责 |
|------|-------|---------|
| 首席架构师 | 🟢 主导 | 全 stage / 单 actor |
| 其余 9 角色 | ⚪ 暂停 | — |

> Single-actor sprint 简化（per brief-template v0.1.2 §5 注脚）。

---

## 6. 收口判定（同 §2.1，重复以便 closeout 直接对照）

- ✅ 5 项 v0.3 候选 land + ruff clean
- ✅ methodology/02 v0.1 → v0.1.1
- ✅ brief-template v0.1.2 → v0.1.3
- ✅ 5 模块 sanity 不回归 + 60 pytest 全绿
- ✅ 新 pre-commit hook 跑通
- ✅ STATUS / CHANGELOG / retro / 衍生债登记
- ✅ Sprint S 候选议程

---

## 7. 节奏建议

**紧凑 1 会话**（推荐 / 与 Sprint P 同 scale）：

会话 1（~2 hours）：
- Stage 1 批 1+2（~25 min）
- Stage 1 批 3 methodology/02 v0.1.1（~30 min）
- Stage 1 批 4 pre-commit hook（~30 min）
- Stage 1.13 sanity 回归（~15 min）
- Stage 4 closeout + retro（~30 min）

**舒缓 2 会话**（备选 / 如批 3 methodology 段超时）：
- 会话 1：Stage 1 批 1-3
- 会话 2：Stage 1 批 4-5 + Stage 4

---

## 8. D-route 资产沉淀预期

本 sprint 预期沉淀以下框架抽象资产（**至少勾 ≥ 1 项**；本 sprint 实际勾 3 项）：

- [x] **methodology v0.x → v0.(x+1) 迭代**：methodology/02 v0.1 → v0.1.1（+ 4 段元 pattern）
- [x] **框架代码 spike**：5 模块 polish + 1 pre-commit hook + chief-architect role 流程规则
- [ ] 案例素材积累（不勾 — Sprint R 是 patch sprint）
- [x] **跨领域 mapping 表更新**：不直接更新 mapping 表，但 methodology/02 §13 跨 stack 抽象段对跨领域 fork 有指导意义
- [ ] 新 framework 模块（按 §1.3 不做）

> 至少 3 项预期 → 远超 ADR-028 / C-22 的 ≥ 1 项要求。

**Layer 进度推进预期**：

- L1: 5 模块 v0.x（不变）+ 微 polish（不算新刀）
- L2: **methodology/02 v0.1 → v0.1.1**（4 段元 pattern 沉淀）⭐
- L3: 不变
- L4: 不变（v0.3 release 等条件成熟）

---

## 9. 模型选型

- **Architect 主 session**：Opus 4.7（与 L+M+N+O+P+Q 同）
- **理由**：methodology v0.1.1 4 段写作 + cross-ref 涉及 multi-file consistency；Sonnet 风险点：methodology 段写作偶尔风格漂移（与原 §1-§9 不一致）；Opus 在元认知 / pattern 提炼方面更稳

---

## 10. Dogfood 设计

### 10.1 brief-template v0.1.2 第 2 次外部使用

本 brief 是 brief-template v0.1.2（Sprint P release）的**第 2 次外部使用**（vs 第 1 次 Sprint Q）。

预期发现：
- §2.1 估时表按"~XX min" 单一时长 vs 按 code/docs/retro 3 类分别列的对比体验
- §3.B 精简模板的"批 N"惯例在 patch sprint 中是否同 Q 一样顺手
- §1.2 灵活列数（本次 4 列对比）

发现的 issue 即时登记为 v0.4 候选（如有）。

### 10.2 Sprint R 自身做 dogfood

T-V03-FW-003 改 brief-template §2.1 估时表 → 下次 sprint brief 起草时即下游 dogfood。
T-V03-FW-006 加 pre-commit hook → 在 Sprint R 内自跑（修改 framework/audit_triage/examples 触发 warning）。
T-V03-FW-002 methodology/02 v0.1.1 → 写本 brief 时已使用 4 段沉淀的元 pattern（"清债 sprint" / "P3 复发升级 P2"）作为 §1 + §1.3 的设计依据。

### 10.3 起草本 brief 暴露的发现

无新 brief-template v0.4 候选（v0.1.2 第 2 次用就用得顺手；§3.B 精简模板 + §3.0 选择指南 + §1.2 灵活列数都覆盖到位）。

---

## 11. 决策签字

- 首席架构师：__ACK 待签 (2026-04-30)__
- 用户：__ACK 待签 (2026-04-30)__
- 信号：本 brief 用户 ACK 后 → Sprint R Stage 1 启动

---

**本 brief 起草于 2026-04-30 / brief-template v0.1.2 第 2 次外部使用 / Architect Opus**
