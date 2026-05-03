# Sprint T Brief — framework v0.3.0 release sprint + T-V03-FW-005 Docker compose

> 起草自 `framework/sprint-templates/brief-template.md` v0.1.3
> Dogfood: brief-template **第 9 次**外部使用（v0.1.3 第 **2** 次 / 估时表第 2 次试 + 累积偏差观察）

## 0. 元信息

- **架构师**：首席架构师（Claude Opus 4.7）
- **Brief 日期**：2026-04-30
- **Sprint 形态**：**单 track / single-actor**（与 Sprint L+M+N+O+P+Q+R+S 同 / Architect Opus 全程）
- **预估工时**：**2 个 Cowork 会话**（含 T-V03-FW-005 fold 进批 1 / per 用户 ACK）
- **PE 模型**：N/A（single-actor）
- **Architect 模型**：Opus 4.7（per Sprint S retro §5.3 — Sonnet 候选但 T-V03-FW-005 是非平凡 feature 实现，保 Opus 稳定）
- **触发事件**：ADR-030 §2.2 锁定 Sprint T = v0.3 release sprint；用户 ACK "T-V03-FW-005 fold 进 Sprint T 批 1"；6/6 v0.3 release 触发条件全达成
- **战略锚点**：[ADR-030](../../decisions/ADR-030-v0.3-release-timing-decision.md) §2.2 + Sprint S retro §8 + Sprint S residual debts §5

---

## 1. 背景

### 1.1 前置上下文

Sprint L→S 完成 framework 抽象首次完整 + v0.2.0 release + audit_triage v0.1 + 60 pytest + methodology 网状 cross-ref + ADR-030 v0.3 release timing 决策（采用选项 B / 6/6 触发条件达成）。

**4 sprint zero-trigger 连续**（P + Q + R + S）= framework v0.2 + 5 模块齐备 + maintenance 节律稳定**强化信号**。

Sprint T 在大局中位置：

```
Sprint L → M → N → O (4 模块抽象)
                     ↓
Sprint P (v0.2 patch + v0.2.0 release)
                     ↓
Sprint Q (audit_triage + 60 pytest + 5 模块齐备 ⭐)
                     ↓
Sprint R (v0.3 patch + methodology/02 v0.1.1)
                     ↓
Sprint S (v0.3 release prep eval + ADR-030 + methodology/01+03+04 v0.1.2)
                     ↓
Sprint T (v0.3.0 release + T-V03-FW-005 Docker compose) ← 现在
                     ↓
Sprint T+N (v0.4 candidate accumulation + 跨域案例方接触触发)
```

完成后：
- **framework v0.3.0 公开 release**（GitHub tag `v0.3.0` + RELEASE_NOTES_v0.3.md）
- 押后 T-V03-FW-005 → 0 项（fold 进批 1）
- ADR-030 §5 Validation Criteria 6 条 checklist 回填
- 5 模块统一 v0.3.0 标记（per 统一版本号策略 / Sprint Q closeout §3.7 + Sprint P RELEASE_NOTES_v0.2.md §1）

### 1.2 与既有 sprint 的差异

| 维度 | Sprint L-O 抽象 | Sprint P (v0.2 release) | Sprint Q (新模块) | Sprint R (patch+meth) | Sprint S (eval) | **Sprint T (v0.3 release)** |
|------|--------------|---------------------|---------------|---------------------|----------------|----------------------------|
| 抽象类型 | 新模块 | release + patch | 新模块 + 补测 | patch + meth iter | eval + meth iter | **release + 1 大 feature (Docker)** |
| 抽象输入 | services/pipeline | 14 v0.2 候选 | TS triage | 6 v0.3 候选 | 5/6 触发条件 | **6/6 ✓ + T-V03-FW-005 押后项 fold** |
| 涉及模块 | 1 模块 | 4 模块统一 v0.2.0 | 1 新模块 | 5 模块 polish | 0 模块 (全 docs) | **5 模块统一 v0.3.0 + 1 新 scripts/ 子目录** |
| 主导模型 | Opus | Opus | Opus | Opus | Opus | **Opus** |
| dogfood gate | byte/soft-equiv | 简单 sanity | 60 pytest | 5 模块 sanity + hook | sanity 不回归 | **Docker compose 自跑 + 5 模块 sanity + 60 pytest + ADR-030 §5 6 条回填** |
| 风险等级 | low → medium | low | medium | low | low | **medium**（Docker compose 是新 infra）|
| 工作量 | 1-3 会话 | 1 会话 | 2 会话 | 1 会话 | 1.5 会话 | **2 会话**（T-V03-FW-005 是大头）|

### 1.3 不做的事（Negative Scope）

- ❌ **不做新 framework 模块**（5 模块齐备 / methodology/02 §12）
- ❌ **不动 audit_triage v0.1 → v0.3 的 ABI**（仅 `__version__` bump 同步统一版本号 / 内容不变 / per Sprint P role-templates v0.1 → v0.2 同模式）
- ❌ **不重写所有 36 表生产 schema**（T-V03-FW-005 走 Approach B / 仅最小化 framework dogfood 所需子集 ~10 张表）
- ❌ **不做 DGF-N-04 / DGF-N-05**（押后等外部触发）
- ❌ **不立即触发 ADR-031 plugin 协议**（per Sprint M-O-P-Q-R-S 同结论）
- ❌ **不动 services/pipeline 生产代码 / services/api 生产 TS**

---

## 2. 目标范围

### 2.1 单 Track — v0.3.0 release + Docker compose

**目标**：

1. **批 1 — T-V03-FW-005 Docker compose + seed fixtures + sandbox dogfood enabling**（fold 进 Sprint T / 大头 ~3-4h）
2. 5 模块 README §0 + §8 加 v0.3.0 行 + 2 模块 `__version__` bump (identity / invariant 0.2.0 → 0.3.0 + audit_triage 0.1.0 → 0.3.0 / 统一版本号策略)
3. framework/RELEASE_NOTES_v0.3.md 起草
4. STATUS / CHANGELOG v0.3.0 release 标记
5. sanity + dogfood 双 gate 验证（含 ADR-030 §5 Validation Criteria 6 条回填）
6. Sprint T closeout + retro

**5 项 v0.3 release prep + 1 项 feature（即 T-V03-FW-005）清单**：

| ID / 主题 | 类型 | 改动 | 估时 |
|----|------|------|------|
| 批 1 — T-V03-FW-005 | feature | scripts/dogfood-postgres-compose.yml + scripts/dogfood-bootstrap.sql + scripts/dogfood-seed.sql + scripts/README-dogfood-postgres.md | ~3-4h |
| 批 2 — 5 模块 README §0+§8 + version bumps | release prep | 5 README files + 3 __init__.py | ~30 min |
| 批 3 — RELEASE_NOTES_v0.3.md | release prep | 1 new file ~200 行 | ~45 min |
| 批 4 — STATUS / CHANGELOG v0.3.0 标记 | release prep | 2 files edit | ~20 min |
| 批 5 — sanity + dogfood 回归 + ADR-030 §5 6 条回填 | gate | — + ADR-030 inline edit | ~30 min |
| **小计** | — | **~13 files** | **~5-6h ≈ 2 会话** |

#### 工作量估算（v0.1.3 §2.1 新 3 类估时表 / 第 2 次外部 dogfood）

| 类别 | 包含 | 估时 |
|------|------|------|
| **Code** | scripts/dogfood-postgres-compose.yml + scripts/dogfood-bootstrap.sql + scripts/dogfood-seed.sql + scripts/dogfood-helper.sh（如需要）+ 3 __init__.py version bumps | **~3-4h**（T-V03-FW-005 是新 feature / 大头）|
| **Docs** | scripts/README-dogfood-postgres.md (~150 行 / ~30 min) + 5 README §0+§8 (~10 行/file × 5 / ~30 min) + framework/RELEASE_NOTES_v0.3.md (~200 行 / ~45 min) + ADR-030 §5 inline 回填 (~10 min) | **~2 hours** |
| **Closeout / Retro** | stage-4-closeout + sprint-t-retro + sprint-t-residual-debts + STATUS + CHANGELOG | **~0.5 hours** |
| **小计** | — | **~5.5-6.5 hours = 2 会话** |

**v0.1.3 估时表第 2 次 dogfood 备注**：vs Sprint S 第 1 次（Code 0 / Docs 主导），本 sprint 是 Code 主导（T-V03-FW-005 是非平凡 feature）。可观察：
- Code 类估算精度 vs Sprint S Code=0 简单情形
- Docs 类是否仍能 ≤ 10% 偏差
- 累积 2 次 dogfood 的趋势：是否 v0.1.3 estimate 表稳定 work 还是触发 v0.1.4 polish 候选

#### 完成判据（7 项）

- ✅ T-V03-FW-005 Docker compose 启 Postgres + 加载 schema + 加载 seed → `test_soft_equivalent.py` 在 sandbox 内 PASSED
- ✅ 5 模块 README §0 + §8 v0.3.0 行更新
- ✅ 3 模块 `__version__` bump 到 0.3.0（identity / invariant / audit_triage）
- ✅ framework/RELEASE_NOTES_v0.3.md 落地
- ✅ STATUS / CHANGELOG / retro / 衍生债登记
- ✅ ADR-030 §5 Validation Criteria 6 条 checklist 回填
- ✅ git tag v0.3.0 命令准备就位

### 2.2 Track 2

不适用（单 track）。

---

## 3. Stages（用 brief-template v0.1.3 §3.B 精简模板）

### Stage 0 — Inventory（已完成 / 本 brief §2.1 即 inventory + 已 grep 5 模块版本现状）

无独立 inventory 文档。

### Stage 1 — Release Prep + Docker Feature（5 批）

按以下顺序：

1. **批 1：T-V03-FW-005 Docker compose + seed fixtures**（~3-4h / 大头）
2. **批 2：5 README §0+§8 + 3 `__version__` bump**（~30 min）
3. **批 3：RELEASE_NOTES_v0.3.md 起草**（~45 min）
4. **批 4：STATUS / CHANGELOG v0.3.0 标记**（~20 min）
5. **批 5：sanity + dogfood 双 gate + ADR-030 §5 回填**（~30 min）

**会话节点建议**（2 会话）：
- 会话 1：批 1（T-V03-FW-005 / 大头）+ 中场 commit + 用户 ACK
- 会话 2：批 2+3+4+5 + Stage 4 closeout

### Stage 1.13 — Sanity + Dogfood 双 gate

- ruff check + format 全过
- 5 模块 import sanity（含新版本 0.3.0）
- 60 pytest 全绿（不回归）
- **新增**：Docker compose 启 + `test_soft_equivalent.py` PASSED on sandbox container
- ADR-030 §5 Validation Criteria 6 条 checklist 回填

### Stage 4 — Closeout（精简版）

- T-V03-FW-005 → land（押后清单 v0.3 减到 0 项）
- ADR-030 §5 回填 + 决策正确性 partial-success / success / failure 标记
- methodology/02 v0.1.1 §10.4 Maintenance sprint 节律实证更新（添加 Sprint T = release sprint 数据点）
- STATUS / CHANGELOG / retro / 衍生债登记
- Sprint U 候选议程

---

## 4. Stop Rules

> 详见 `framework/sprint-templates/stop-rules-catalog.md` 5 类模板。

1. **§3 数据正确性类**：Docker compose 启动失败 / `test_soft_equivalent.py` 在 sandbox 内 fail → Stop（评估 schema 子集 + seed data 是否需要扩展）
2. **§3 数据正确性类**：5 模块 sanity 任 1 回归 → Stop（不应该发生 / 仅 version bump）
3. **§3 数据正确性类**：60 pytest 任 1 fail → Stop（不应该发生 / 不动 framework code）
4. **§4 输出量类**：T-V03-FW-005 工时 > 5h（vs 估算 3-4h）→ Stop（评估 scope 是否过度 / 拆 Sprint T+0.5）
5. **§5 治理类**：触发新 ADR ≥ 1（除 ADR-030 §5 inline 回填）→ Stop
6. **§6 跨 sprint 一致性类**：Sprint T 工时 > 2.5 会话 → Stop（评估 scope creep）

---

## 5. 角色边界

| 角色 | 活跃度 | 主要职责 |
|------|-------|---------|
| 首席架构师 | 🟢 主导 | 全 stage / 单 actor / Docker compose + RELEASE_NOTES + ADR 回填 |
| 其余 9 角色 | ⚪ 暂停 | — |

> Single-actor sprint 简化（per brief-template v0.1.3 §5 注脚）。

---

## 6. 收口判定（同 §2.1，重复以便 closeout 直接对照）

- ✅ T-V03-FW-005 Docker compose + sandbox dogfood PASSED
- ✅ 5 模块 README §0+§8 v0.3.0
- ✅ 3 模块 `__version__` bump 到 0.3.0
- ✅ framework/RELEASE_NOTES_v0.3.md
- ✅ STATUS / CHANGELOG / retro / 衍生债
- ✅ ADR-030 §5 6 条回填
- ✅ git tag v0.3.0 命令就位
- ✅ Sprint U 候选议程

---

## 7. 节奏建议

**舒缓 2 会话**（推荐 / 与 Sprint Q 同 scale）：

会话 1（~3-4 hours）：
- Stage 1 批 1 T-V03-FW-005 Docker compose（~3-4h）
- 阶段性 commit + 用户中场 ACK + 验证 Docker compose 在 user local 跑通

会话 2（~2 hours）：
- Stage 1 批 2 5 README §0+§8 + version bumps（~30 min）
- Stage 1 批 3 RELEASE_NOTES_v0.3.md（~45 min）
- Stage 1 批 4 STATUS / CHANGELOG（~20 min）
- Stage 1 批 5 sanity + dogfood 双 gate + ADR-030 §5 回填（~30 min）
- Stage 4 closeout + retro（~30 min）

**紧凑 1 会话**（备选 / 不推荐 / 5-6h 一次性 ambitious）：
- 触发 Stop Rule #6 风险高

---

## 8. D-route 资产沉淀预期

本 sprint 预期沉淀以下框架抽象资产（**至少勾 ≥ 1 项**；本 sprint 实际勾 4 项）：

- [x] **框架代码 spike**：scripts/dogfood-postgres-compose.yml + dogfood-bootstrap.sql + dogfood-seed.sql + helper（让任何 fork 案例方可用 Docker 验证 framework）
- [x] **release 资产**：framework v0.3.0 公开 release（GitHub tag + RELEASE_NOTES）
- [x] **methodology v0.x 数据点**：methodology/02 §10.4 Maintenance sprint 节律实证更新
- [x] **跨领域 mapping 间接更新**：Docker compose 模板对跨域 fork 案例方有指导意义（"如何为你的领域 schema 配置 dogfood Postgres"）
- [ ] 案例素材积累（不勾 — Sprint T 不动 case 数据）
- [ ] methodology v0.x → v0.(x+1) 迭代（不勾 — Sprint T 是 release sprint）

> 至少 4 项预期 → 远超 ADR-028 / C-22 的 ≥ 1 项要求。

**Layer 进度推进预期**：

- L1: 5 模块 v0.2.0 → **统一 v0.3.0 公开 release** ⭐
- L2: methodology/02 §10.4 节律实证小补充
- L3: + Docker compose dogfood infra（sandbox 可跑 / vs 之前只能 user local）
- L4: **第二刀触发**（v0.3.0 GitHub release tag → 项目 release cadence 实证 / 跨外部 reviewer 可观察）

---

## 9. 模型选型

- **Architect 主 session**：Opus 4.7（与 L+M+N+O+P+Q+R+S 同）
- **理由**：T-V03-FW-005 Docker compose 是非平凡新 feature（schema 子集设计 + seed 数据合理性 + Docker compose 配置），不是简单 patch / docs；保 Opus 稳定。Sprint S retro §5.3 提到的 "Sonnet 可考虑" 适用于纯 RELEASE_NOTES + version bump 模板批次（批 2-4），但合并 sprint 内 model switch 增加复杂度，不值得。

---

## 10. Dogfood 设计

### 10.1 brief-template v0.1.3 第 2 次外部使用

本 brief 是 v0.1.3（Sprint R polish）的**第 2 次外部使用**。Sprint S 第 1 次以 "Code 0 / Docs 主导" 验证 < 10% 偏差。本 sprint 是 "Code 主导"（T-V03-FW-005 是非平凡新 feature），可观察：
- Code 类估算 3-4h vs 实际偏差
- 累积 2 次 dogfood 趋势 → 是否触发 v0.1.4 polish 候选

### 10.2 T-V03-FW-005 自身就是 framework dogfood infra 升级

Docker compose + seed → sandbox 可跑 framework dogfood = 让框架可独立于 production DB 验证。这是 framework v0.x 演进的"测试基础设施" milestone：

- v0.1：dogfood 必须 user local DB
- v0.3（本 sprint）：dogfood 可 Docker compose / 任何 fork 案例方在 CI 可跑

**沉淀**：scripts/dogfood-* 模板对跨域 fork 案例方有指导意义（"复制此目录 + 改 schema + 改 seed = 你的 framework dogfood 也可 sandbox 跑"）。

### 10.3 v0.3.0 release 是 framework 第 2 次公开 release

vs v0.2.0（Sprint P / 4 模块统一）：
- v0.3.0 是 5 模块统一（+ audit_triage）
- 落地 6 v0.3 候选（vs v0.2 落地 8 v0.2 候选）
- 落地 ADR-030（vs v0.2 无独立 ADR）
- 落地 T-V03-FW-005 Docker dogfood infra（vs v0.2 仅 patch）

→ v0.3.0 是 v0.2.0 之后的"成熟度上升"release（量化指标在 RELEASE_NOTES_v0.3.md §X 给出）。

### 10.4 起草本 brief 暴露的发现

无新 brief-template 改进候选（v0.1.3 第 2 次使用顺手 / 3 类估时表与 Code 主导场景适配 OK）。

---

## 11. 决策签字

- 首席架构师：__ACK 待签 (2026-04-30)__
- 用户：__ACK 待签 (2026-04-30)__
- 信号：本 brief 用户 ACK 后 → Sprint T Stage 1 启动

---

**本 brief 起草于 2026-04-30 / brief-template v0.1.3 第 2 次外部使用 / Architect Opus**
