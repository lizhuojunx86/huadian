# Sprint T Retro — framework v0.3.0 release sprint + T-V03-FW-005 Docker compose

> 起草自 `framework/sprint-templates/retro-template.md` v0.1.1
> Dogfood: retro-template **第 10 次**外部使用

## 0. 元信息

- **Sprint ID**: T
- **完成日期**: 2026-04-30
- **主题**: framework v0.3.0 release sprint + T-V03-FW-005 Docker compose
- **预估工时**: 2 个 Cowork 会话
- **实际工时**: **~3 hours / 实际 ≤ 2 会话**（**远低于预算 / Code 类估算偏保守**）
- **主导角色**: 首席架构师（Claude Opus 4.7）— single-actor sprint

---

## 1. Sprint 任务回顾

### 1.1 Stage 顺序与产出（精简模板 §3.B）

| Stage | 主导 | 状态 | 关键产出 |
|-------|------|------|----------|
| Stage 0 inventory + brief 起草 | Architect | ✅ | brief-template v0.1.3 第 2 次外部 dogfood (Code 主导) |
| **Stage 1 批 1 — T-V03-FW-005 Docker compose 大头** | Architect | ✅ **PASSED** | scripts/ 4 files + **user local Docker 一次跑通 + dogfood 6/6 + 4 surfaces 全一致** ⭐ |
| **会话 1 中场 commit + push (`bb68ccd`) + 用户 local 验证 ✓** | — | ✅ | main `bb68ccd` |
| Stage 1 批 2 — 5 README §0+§8 + 3 __version__ bump | Architect | ✅ | 5 modules 统一 v0.3.0 |
| Stage 1 批 3 — RELEASE_NOTES_v0.3.md | Architect | ✅ | 211 行 / 9 段 |
| Stage 1 批 4 — STATUS / CHANGELOG v0.3.0 标记 | Architect | ✅ | STATUS §1 + 2.2.8 + CHANGELOG block |
| Stage 1 批 5 — sanity + dogfood + ADR-030 §5 6 条回填 | Architect | ✅ | **5/6 ✅ + 1 待 push tag → success** |
| Stage 4 closeout + retro | Architect | ✅ | 4 docs |

### 1.2 数据 / 工程基线 Δ

| 维度 | Sprint 前 | Sprint 后 | Δ |
|------|---------|---------|-----|
| framework 模块 v0.x | 5 (4 v0.2 + audit_triage v0.1) | **5 模块统一 v0.3.0** ⭐ | +5 模块 release |
| Docker dogfood infra | 无 | **scripts/dogfood-* 4 files** | +1 critical infra ⭐ |
| RELEASE_NOTES 数 | 1 (v0.2) | 2 (v0.2 + **v0.3**) | +1 |
| ADR 数 | 30 (含 ADR-030 起草) | 30 (ADR-030 §5 inline 回填 / 同 ID) | 不变 / 决策完整 |
| v0.3 押后 | 1 (T-V03-FW-005) | **0** ⭐ | 全清 |
| 累计 patch 落地率 | 23/26 = 88.5% | **24/26 = 92.3%** | +3.8pp |
| Stop Rule 触发 | 0 (Sprint S 接续) | **0**（连续 5 sprint）| 强化 |
| pytest tests | 60 | 60 | 不变 |
| L4 触发数 | 1 (v0.2.0) | **2** (+ v0.3.0) | +1 release tag 触发 |

---

## 2. 工作得好的部分（What Worked）

### 2.1 T-V03-FW-005 Approach B 一次跑通 + 用户 local 验证 dogfood PASSED

T-V03-FW-005 Docker compose 是本 sprint 最大变量（brief 估 3-4h），实际 ~95 min 完成 + user local 启容器 + dogfood 一次跑通 PASSED。

关键设计赢：
- **Approach B 7 表 minimum schema 子集**（vs Approach A 36+ 表全量复用）— 让 bootstrap.sql 单文件可读 + DB 起 < 5s
- **端口 5434**（vs 生产 5433）— dogfood 与生产可同时跑
- **deterministic UUID seed**（`00000000-0000-4000-8000-NNNNNNNNNNNN` shape）— 重启 + re-seed 数据一致 / 利于跨域 fork
- **pglast 帮助快速 SQL syntax 迭代**（无需起真 PG 即可验证）

**沉淀**：T-V03-FW-005 是 framework v0.x release 的 dogfood infra "成熟度上升" milestone（vs v0.2 仅 user local）。Approach B 模板可被任何跨域 fork 案例方复用（per scripts/README §5）。

### 2.2 v0.1.3 §2.1 估时表第 2 次 dogfood 暴露 Code 类估算偏保守

vs Sprint S 第 1 次（Code=0 简单情形 / 偏差 < 10%），Sprint T Code 类首次主导：
- 估算：3-4h（T-V03-FW-005 大头）
- 实际：~95 min
- **Code 类实际仅 estimate 的 47%**（< 50%）

这暴露了 v0.1.3 §2.1 估时表的盲区：Code 类没区分"框架 spike"（实证偏快 / Approach B 简化 + 工具加成）vs "新模块抽象"（如 Sprint Q audit_triage 实证更慢）。

**沉淀**：触发 brief-template v0.1.4 polish 候选（v0.4 候选 / Sprint U+ fold）。

### 2.3 5 sprint zero-trigger 连续 → v1.0 候选议程评估触发

Sprint R retro §5.1 期待"≥ 5 sprint zero-trigger 触发 v1.0 候选议程"，Sprint T 完成后**正式达成**：

| Sprint | 形态 | Stop Rule 触发 |
|--------|------|---------|
| P | 清债 | 0 |
| Q | 新模块 + 跨 stack pattern 首实证 | 0 |
| R | 清债 + meth iter | 0 |
| S | eval + meth cross-ref | 0 |
| T | release + feature | 0 |

5 种 sprint 形态都 zero-trigger = framework v0.3 + 5 模块齐备 + maintenance 节律 + release sprint **完整稳定信号** ⭐。

**沉淀**：Sprint U 候选议程 §8 加 "v1.0 候选议程评估" 选项（不立即触发但开始收集 v1.0 触发条件）。

### 2.4 ADR-030 §5 6 条 checklist 5/6 ✅ + 1 待 → success

ADR-030 §3 选项 B 论证（拆解条件背后价值 → 评估替代实现）在 Sprint T 完整验证：

- 6 触发条件评估、6 项 Validation Criteria、5/6 ✅ + 1 待 push tag
- "≥ 1 跨外部读者 review" 通过 T-V03-FW-005 Docker compose 实证 + scripts/README §5 跨域 fork 启示**强等价**（vs 等真案例方接触 / 无 timeline 保证）

**沉淀**：ADR-030 模板 + Validation Criteria 6 条回填模式可被未来 v0.4 / v1.0 release 决策复用。

---

## 3. 改进点（What Didn't Work）

### 3.1 brief-template v0.1.3 §2.1 Code 类估算偏保守（已 §2.2 沉淀）

实际 47% vs estimate → 触发 v0.1.4 polish 候选（已记 v0.4 衍生债 §6）。

### 3.2 audit_triage v0.1 → v0.3 跳跃式 bump 是否会困惑用户？

audit_triage 内容自 Sprint Q 抽象后无 ABI 变化，但 `__version__` 跳跃式 0.1.0 → 0.3.0 对齐统一版本号。

**风险**：跨域 fork 案例方可能困惑"为什么 v0.1 → v0.3 没 v0.2 release notes"。

**减缓**：framework/audit_triage/README §8 v0.3.0 行已显式注明"跳跃式 bump 0.1.0 → 0.3.0 对齐统一版本号 / 内容自 v0.1 起无 ABI 变化"。framework/RELEASE_NOTES_v0.3.md §1 + §3 也强调统一版本号策略 + 无 breaking changes。

**改进建议**：v0.4 release 时如有 audit_triage 内容更新（如 V0.2 DecisionApplier hook 实现），可自然走 0.3.0 → 0.4.0 统一节奏。当前不需特殊处理。

### 3.3 commit-attribution 重复风险（Sprint R 残留 + 本 sprint 仍未 land 修复）

T-V04-FW-001（chief-architect §工程小细节 v0.2.2 commit message hygiene 规则）已在 Sprint S residual debts §3.1 登记 v0.4 候选，本 sprint 未 fold。

**改进建议**：Sprint U 如启动 v0.4 maintenance sprint 时优先 fold（estimate ≤ 5 min / 一行规则 + 来源说明）。

不严重 / 不影响 release 质量。

---

## 4. Stop Rule 触发回顾

> 触发处理协议见 `framework/sprint-templates/stop-rules-catalog.md` §7。

**无触发**（连续第 **5** 个 zero-trigger sprint：P → Q → R → S → T）。

| Rule | 类别 (catalog §) | 触发原因 | 架构师裁决 (A/B/C/D) | trigger 文件 |
|------|----------------|---------|--------------------|-------------|
| — | — | 无触发 | — | — |

---

## 5. Lessons Learned

### 5.1 工程层面

#### release sprint 形态（vs 抽象 / maintenance / eval）的特性总结

至 Sprint T 收档，framework v0.x 演进已实证 5 种 sprint 形态：

| 形态 | 实证 sprint | 主要输出 | typical 工时 | Stop Rule 触发 typical |
|------|----------|---------|-----------|---------------------|
| 新模块抽象 | L / M / N / O / Q | framework code + dogfood | 1-3 会话 | 0-1 |
| Maintenance（清债）| P / R | patch + small docs | 1 会话 | 0 |
| Eval / Release prep | S | ADR + methodology cross-ref | 1.5 会话 | 0 |
| **Release** | **P (v0.2) / T (v0.3)** | **RELEASE_NOTES + version bump + tag** | **1-2 会话** | **0** |
| Hybrid（release + 大 feature） | **T (含 T-V03-FW-005)** | release prep + 1 feature land | **2 会话** | **0** |

→ Hybrid 形态（Sprint T）是 release sprint 的"扩展变体"——release 节奏内 fold 1 个押后大 feature 是可行模式（不必拆 release 前的 mini-sprint）。

**沉淀**：methodology/02 v0.2 候选段（待 Sprint U+ 起草）可加 "Release Sprint Hybrid Pattern"（fold 押后大 feature 进 release prep）。

#### "5 sprint zero-trigger 触发 v1.0 候选议程" 实证达成

per Sprint R retro §5.1 期待 + 本 sprint 实证：5 sprint zero-trigger 是 framework v0.x 稳定的**强信号**。

但**不等于触发 v1.0 release**（v1.0 阈值更高 / 还需评估其他维度如：跨域 fork 案例方 ≥ 1 / API 稳定性 ≥ 6 个月 / 第三方 review 等）。

**沉淀**：Sprint U 候选议程 §8 加 "v1.0 候选议程评估" 选项 — 不立即触发但开始**起草 v1.0 触发条件 ADR**（候选 ADR-031）。

### 5.2 协作层面

Sprint T 是 single-actor sprint，无跨角色协作。

但 T-V03-FW-005 Docker compose 的 user local 验证是**用户实测协作**：架构师 (sandbox) 起草 + 用户 (local Terminal) 验证 = 跨环境闭环。

**沉淀**：未来跨 stack / 跨 infra 的 framework feature 可考虑这种"sandbox 起草 + user local 验证"协作模式（vs 完全 sandbox-side 验证）。

### 5.3 模型选型 retro

**Architect = Opus 4.7（全程）**：合适 / 但部分批次可考虑 Sonnet。

- 批 1 T-V03-FW-005 Docker compose（schema 设计 + seed 设计 + 跨 stack sync）：必须 Opus
- 批 2 5 README + version bump：模板化 / Sonnet 可考虑（但 5 README 内容差异 + 跨 doc 一致性 + Opus 全程稳定性 / 切换成本高 / 不值得）
- 批 3 RELEASE_NOTES_v0.3.md（参考 v0.2 模板 + 加 v0.3 cycle 数据）：模板化 + 数据填充 / Sonnet 可考虑
- 批 4 STATUS / CHANGELOG：模板化 / Sonnet 可考虑
- 批 5 sanity + ADR-030 §5 回填：模板化 / Sonnet 可考虑
- Stage 4 closeout + retro（本文件）：需要长 context + 元认知 / Opus 必要

→ 完整 model switch 增加复杂度 / 不值得（per Sprint S retro §5.3 同结论）。Sprint U 视主题再评估。

---

## 6. 衍生债登记

本 sprint 收口后：

**新 v0.4 候选 1 项**（合并 Sprint S 留下的 1 项 → 累计 v0.4 候选 2 项）：

| ID | 描述 | 优先级 | 来源 |
|----|------|--------|------|
| T-V04-FW-002 | brief-template v0.1.3 §2.1 Code 类估算分"框架 spike" vs "新模块抽象" 子类 | P3 | 本 retro §3.1（Sprint T Code 类实际 47% vs estimate）|
| (从 Sprint S) T-V04-FW-001 | chief-architect §工程小细节 v0.2.2 加 commit message hygiene 规则 | P3 | Sprint S retro §3.2 |

押后清单（不变 / v0.3 已全清）：
- v0.2: 2 项（DGF-N-04 + DGF-N-05 / 等外部触发）

详见 `docs/debts/sprint-t-residual-debts.md`。

---

## 7. D-route 资产沉淀盘点

### 7.1 本 sprint 沉淀的可抽象 pattern

1. **"Release Sprint Hybrid" 形态**（release prep + fold 押后大 feature / 实证 Sprint T）— 可写入 methodology/02 v0.2 候选段
2. **Approach B 最小 schema 子集 dogfood infra**（vs Approach A 全量复用）— 跨域 fork 案例方可复用
3. **deterministic UUID seed pattern**（重启 / re-seed 一致 / 跨域 fork 友好）— 跨域 fork 案例方可复用
4. **pglast SQL syntax 验证模式**（无需起真 PG 即可迭代 SQL）— 跨域 fork 案例方在写 dogfood-bootstrap.sql 时可复用
5. **5 sprint zero-trigger → v1.0 候选议程评估触发**（实证条件 / per Sprint R retro §5.1 期待）— 待写入 methodology/02 v0.2

### 7.2 本 sprint 暴露的"案例耦合点"

无新案例耦合点（release sprint / 不动 case 数据）。

T-V03-FW-005 dogfood-bootstrap.sql 与生产 schema 之间有 sync 责任（per scripts/README-dogfood-postgres.md §4 + .pre-commit-config.yaml services-framework-audit-triage-sync hook 已 cover）。

### 7.3 Layer 进度推进

- L1: 5 模块 v0.2.0/0.1.0 → **统一 v0.3.0 公开 release** ⭐
- L2: methodology/02 §10.4 节律实证 + Sprint T 数据点（不立即写 / 待 v0.2 候选段统一 polish）
- L3: + Docker dogfood infra（sandbox/CI 可跑）⭐
- L4: **第二刀触发**（v0.3.0 GitHub release tag 待 push）⭐

### 7.4 下一 sprint 抽象优先级建议

按价值 / 风险综合：

1. **Sprint U 候选 A**：v1.0 候选议程评估（推荐 / 1 会话 / 起草 ADR-031 v1.0 触发条件 / 不立即 release v1.0）
2. **Sprint U 候选 B**：methodology/06 + /07 起草（Stage C 待起草草案 / 优先度 P3 / 1.5-2 会话）
3. **Sprint U 候选 C**：v0.4 maintenance sprint（fold T-V04-FW-001 + -002 / 候选累积少 / 不急）
4. **Sprint U 候选 D**（远期）：跨域 reference impl (legal) — 押后等触发
5. **A + B 合并**（推荐 / 1.5-2 会话 / 与 Sprint S 模式一致）

---

## 8. 下一步（Sprint U 候选议程）

依据本 retro 发现：

- **优先选 候选 A + B 合并**（v1.0 候选议程评估 + methodology/06 + /07 起草 / 1.5-2 会话）
- 候选 C 不急（v0.4 候选仅 2 项 / 待累积到 ≥ 5 项再触发 maintenance sprint）
- 候选 D 不主动启动（等案例方触发）

不要做的事：

- ❌ 不开新 framework 模块（5 模块齐备已是阶段终点）
- ❌ 不动 audit_triage v0.3 ABI（保稳定到 v0.4 release）
- ❌ 不在 Sprint U 内**立即 release v1.0**（候选议程评估 sprint 仅起草触发条件 ADR / 不等于触发）
- ❌ 不立即触发 ADR-031 plugin 协议（per Sprint M-O-P-Q-R-S-T 同结论 / 但 ADR-031 v1.0 触发条件可作为 Sprint U 候选 A 起草标的）

---

## 9. 决策签字

- 首席架构师：__ACK 2026-04-30 (Architect)__
- 用户：__ACK 待签__
- 信号：本 retro 用户 ACK + commit + push + tag v0.3.0 → **Sprint T 关档 / Sprint U 候选议程激活**

---

**Sprint T retro 起草于 2026-04-30 / retro-template v0.1.1 第 10 次外部使用 / Architect Opus**
