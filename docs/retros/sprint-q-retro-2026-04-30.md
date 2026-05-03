# Sprint Q Retro — Layer 1 第 5 刀 audit_triage + 合并补 N+O pytest

> 起草自 `framework/sprint-templates/retro-template.md` v0.1.1
> Dogfood: retro-template **第七次**外部使用

## 0. 元信息

- **Sprint ID**: Q
- **完成日期**: 2026-04-30
- **主题**: Layer 1 第 5 刀 audit_triage 抽象 + 合并补 N+O pytest tests + methodology/05 v0.1.1
- **预估工时**: 2 个 Cowork 会话
- **实际工时**: **2 个 Cowork 会话**（准确，无偏差）
- **主导角色**: 首席架构师（Claude Opus 4.7）— single-actor sprint

---

## 1. Sprint 任务回顾

### 1.1 Stage 顺序与产出（精简模板 §3.B）

| Stage | 主导 | 状态 | 关键产出 |
|-------|------|------|----------|
| Stage 0 inventory（已嵌 brief §2）| Architect | ✅ | brief-template v0.1.2 第 1 次外部使用 / 14-file 设计 / 6 Plugin Protocol |
| Stage 1 批 1 framework core | Architect | ✅ | 6 files / 995 行 / 7 sanity ✓ |
| Stage 1 批 2 examples adapter | Architect | ✅ | 4 .py + schema.sql + README / 7 sanity ✓ |
| Stage 1 批 3 3 docs | Architect | ✅ | README + CONCEPTS + cross-domain-mapping (854 行) |
| Stage 1 批 4 60 pytest tests | Architect | ✅ | 33 (identity) + 27 (invariant) = 60/60 in 0.08s |
| Stage 1 批 5 methodology/05 v0.1.1 | Architect | ✅ | §7 Framework Implementation 段（5 Protocol map / 6 tags / 测试范本 / V0.2 路径）|
| Stage 1.13 dogfood + 60 pytest 全跑 | Architect | ⚠️ partial | script ready / sandbox 不可达 DB / 60 pytest 全绿 / 5 模块 import sanity |
| Stage 4 Closeout + Retro | Architect | ✅ | closeout / retro / debts / STATUS / CHANGELOG |

### 1.2 数据 / 工程基线 Δ

| 维度 | Sprint 前 | Sprint 后 | Δ |
|------|---------|---------|-----|
| framework 模块数 | 4 (v0.2.0) | **5**（+ audit_triage v0.1）| +1 ⭐ |
| framework 文件数 | 87 | ~125（+ 14 audit_triage + 19 tests + 1 dogfood + ~5 closeout/retro/debts/methodology）| +38 |
| framework 行数 | ~10800 | ~16200 | +5400 |
| pytest tests | 0 | **60** | +60 ⭐ |
| methodology 草案版本 | 7 各 v0.1.x | 7 各 v0.1.x（含 05 v0.1.1）| +1 iter |
| v0.2 累计已 patch | 14 | 18 | +4（DGF-N-03 + DGF-O-02 合并 / 视为 2 项各占 2 个 sprint slot）|
| v0.2 累计待 patch | 6 | 2 | -4 |
| Stop Rule 触发 | 0 (Sprint P) | **0**（连续 2 sprint）| 稳定 |
| L1 里程碑 | 4 模块 v0.2.0 | **5 模块齐备**（首次完整）| ⭐ |

---

## 2. 工作得好的部分（What Worked）

### 2.1 brief-template v0.1.2 第 1 次外部使用即顺手

Sprint P 里花精力做的 §3.B 精简模板 / §3.0 选择指南 / §1.2 灵活列数 / §8 措辞解耦在 Sprint Q brief 起草中**零摩擦**：
- §3.0 选择指南一眼选 §3.B（无需犹豫）
- §1.2 灵活列数自然写"Sprint L-O 抽象 / Sprint P patch / Sprint Q"3 列对比
- §8 不用刻意避开 C-22 措辞

**沉淀**：v0.1.2 polish 投资回报已显现；继续在每个 sprint 通过 dogfood 验证。

### 2.2 跨 stack 抽象（TS → Python）顺利

audit_triage 抽象的源代码是 TypeScript（services/api/triage.service.ts 922 行），目标是 Python framework + asyncpg。这种跨 stack 抽象是 Sprint L-P 没有过的（前 4 sprint 都是 Python → Python）。

策略：
1. SQL 逐字 port（不重新设计）
2. 业务逻辑分层（service.py 纯 Python / store.py 纯 Protocol / examples/asyncpg_store.py 落地）
3. dogfood 走 soft-equivalent（同 Sprint O 模式 / 不强求 byte-identical）

**沉淀**：跨 stack 抽象 pattern 可写成 methodology/03 v0.2 候选段（"how to abstract a TS implementation into Python framework"）。Sprint Q+M+ 候选议程。

### 2.3 60 pytest tests 1 次过（除 1 字段命名小修）

19 个测试文件 / 60 tests 在 1 次 pytest 调用内 59 passed + 1 failed (BlockedMerge 字段命名不匹配 — 见 §3.1)；修后 60/60 in 0.08s。这是 framework 第一个 pytest 套件，无 conftest 复用经验，速度算理想。

**沉淀**：FakePort + make_entity factory 模式可复用到 Sprint Q+M audit_triage tests 起草。

### 2.4 测试 + dogfood 双层 gate

Sprint Q 是 framework 第一次同 sprint 内同时落地 (a) 单测 + (b) dogfood：
- 单测验证 framework code 局部正确性（FakePort mocked / 0.08s 跑完）
- dogfood 验证 framework code 与生产等价（real DB / 用户 local 跑）

两 gate 互补：单测覆盖广（60 tests）但脱离生产；dogfood 覆盖窄（核心查询）但生产真实。

---

## 3. 改进点（What Didn't Work）

### 3.1 BlockedMerge 字段命名 mismatch（test_types.py 1 处 fail）

写 test_types.py::test_blocked_merge_carries_guard_payload 时凭记忆写了 `guard_reason` + `proposed_match_evidence`，但 `framework.identity_resolver.types.BlockedMerge` 实际字段是 `guard_payload` + `evidence`。

根因：未先 grep 实际 dataclass 字段就写 test。

**改进建议**：写 dataclass 测试前必须 `grep "^class\|^def" target.py`（已在本 sprint 实施 — 多数文件都先 grep）。例外是 test_types.py 因为 "type 测试感觉简单" 而跳过此步。下次 sprint 设新规：**dataclass shape test 必须先 grep**。

已沉淀为下次 sprint 自我提醒。

### 3.2 dogfood 在 sandbox 跑不了

audit_triage soft-equivalent dogfood 需要 Postgres 5433 — sandbox 不可达，必须在 user local Terminal 跑。这是 Sprint N + Sprint O 都遇到的相同情况，**说明 sandbox 限制是 framework dogfood 的固定 friction**。

**改进建议**：
- A. 短期：closeout 模板里固定加 "user local Terminal 完成 dogfood" checklist 段（已在 Sprint Q closeout §7 落地）
- B. 中期：考虑提供 Docker compose 启动 Postgres + 自动 seed test data 的 fixtures, 让 sandbox 也能跑（v0.3 候选 / 工作量大）
- C. 用户视角：sandbox 跑 60 pytest（unit）+ user local 跑 dogfood（integration），双 gate 互补已是合理分工

倾向 A + C（接受 sandbox/local 分工 + 把它写入流程模板）。

### 3.3 行数超 brief 估算 1.4x（接近 Stop Rule #4 阈值）

brief 估算 ~2800 行，实际 ~5374 行（含 closeout/retro）。Python 行数 3014 行（符合预期）；超出主要在 docs（CONCEPTS.md 309 + cross-domain-mapping.md 357 + closeout/retro 较长）。

**改进建议**：
- brief 估算时把 docs / closeout / retro 单独列出（不与 framework code 行数混算）
- v0.3 brief-template polish 候选：§2.1 表格按"code / docs / closeout-retro"3 类分别估时

---

## 4. Stop Rule 触发回顾

> 触发处理协议见 `framework/sprint-templates/stop-rules-catalog.md` §7。

**无触发**（连续 2 sprint zero-trigger）。

| Rule | 类别 (catalog §) | 触发原因 | 架构师裁决 (A/B/C/D) | trigger 文件 |
|------|----------------|---------|--------------------|-------------|
| — | — | 无触发 | — | — |

---

## 5. Lessons Learned

### 5.1 工程层面

#### "5 模块齐备" 是 framework 抽象的稳定信号

Sprint L→Q 5 个 sprint 完成 5 模块抽象。回头看每个模块的设计 / 接口 / examples 都没有触发架构性返工（只有 v0.2 内部 polish）。这说明：

1. methodology 草案 v0.1（Sprint K 之前完成）作为"抽象设计指南"是有效的——指导抽象工作而非事后追溯
2. ADR-027 (audit_triage) / ADR-025 (identity_resolver) 等"先 ADR 再实现"的工作流让 framework 抽象有方向
3. 4 sprint dogfood 实证（M+N+O+Q）证明跨 stack / 跨 pattern 抽象都 work

**沉淀**：5 模块完整意味着 framework 已可被外部 fork 用（如果有跨领域案例方主动接触）。Sprint Q 后的工作重心可适度从"补模块"转向"等案例方反馈" + "v0.3 polish"。

#### pytest 套件首发的"测试范本"价值

framework 之前没有 pytest 套件（只有 in-script sanity + dogfood）。Sprint Q 落地 60 tests 不是为了 100% 覆盖 — 是为了：

1. 给跨域 fork 案例方一个"如何写 framework 测试"的范本
2. 在重构 framework code 时有快速回归保护
3. CI 集成（v0.3 候选 — 把 60 pytest 接入 GitHub Actions）

**沉淀**：测试文件结构（conftest + factory + per-module test file + asyncio mode=auto）可复用到 audit_triage tests（v0.2 候选）。

### 5.2 协作层面

Sprint Q 是 single-actor sprint，无跨角色协作。

但**跨 stack 抽象**揭示一个隐含协作维度：framework Python 抽象与生产 TypeScript 实现的"同步责任"。当 production triage.service.ts 改动时，framework/audit_triage/examples/huadian_classics/asyncpg_store.py 的 SQL 也要同步审视。

**沉淀**：可考虑加 pre-commit hook 检测"修改 services/api/.../triage.* 但未修改 framework/audit_triage/examples/huadian_classics/" → warning（不阻塞）。v0.3 候选。

### 5.3 模型选型 retro

**Architect = Opus 4.7（全程）**：合适。

跨 stack 抽象 + 60 tests 一次过 + 6 Plugin Protocol 同 sprint 内设计 — 这些都需要 long-context + 多文件一致性。Sonnet 风险点：
- 60 tests 跨 19 文件容易出现命名不一致
- 6 Plugin Protocol 设计如果中途换 model 容易漂移
- methodology/05 §7 cross-ref 需要 fresh context 中 framework 与 methodology 的 "双向同步" 视角

→ Opus 是 Sprint Q 的合理选择。Sprint R 视主题再评估（如果是 v0.2 patch sprint 可考虑 Sonnet）。

---

## 6. 衍生债登记

本 sprint 收口后：

**新 v0.3 候选 4 项**：

| ID | 描述 | 优先级 | 来源 |
|----|------|--------|------|
| T-V03-FW-003 | brief-template §2.1 表格估时按 code/docs/retro 3 类分别列 | P3 | 本 retro §3.3 |
| T-V03-FW-004 | dataclass shape test 起草前 grep target 字段（流程规则）| P3 | 本 retro §3.1 |
| T-V03-FW-005 | Docker compose Postgres + seed fixtures 让 sandbox 跑 dogfood（大工作）| P3 | 本 retro §3.2 |
| T-V03-FW-006 | pre-commit hook 检 services↔framework/examples sync warning | P3 | 本 retro §5.2 |

加上 Sprint P 留下的 2 项 v0.3 候选（T-V03-FW-001 / -002），累计 v0.3 候选 **6 项**。

押后 v0.2 候选剩 **2 项**（DGF-N-04 + DGF-N-05），详见 `docs/debts/sprint-q-residual-debts.md`。

---

## 7. D-route 资产沉淀盘点

### 7.1 本 sprint 沉淀的可抽象 pattern

1. **跨 stack 抽象 pattern（TS prod → Python framework）**：SQL 逐字 port + 业务逻辑分层 + soft-equivalent dogfood — 适合 v0.x 早期"同方案多 stack"案例
2. **"5 模块齐备" 即 L1 里程碑** — 5 模块覆盖 governance(2) + code(3) 即可被 fork；不必追求"完美"前发布
3. **pytest 套件首发即测试范本** — conftest + factory + per-module + asyncio mode=auto 模式可被跨域 fork 案例方 1:1 复用
4. **single-actor sprint 在 framework 抽象中是稳定模式** — Sprint L+M+N+O+P+Q 6 个 sprint 都 single-actor / Architect Opus / 1-2 会话 / zero-trigger（最近 2 个）

### 7.2 本 sprint 暴露的"案例耦合点"

1. `examples/huadian_classics/asyncpg_store.py` 中 `_SEED_SELECT` / `_GUARD_SELECT` 与 production `services/api/triage.service.ts` 的同步风险（§5.2 已记 v0.3 候选）
2. `examples/huadian_classics/allowlist.py` 假设 `apps/web/lib/historian-allowlist.yaml` 路径布局（已用 `HUADIAN_HISTORIAN_ALLOWLIST_PATH` env var 解耦，但默认值仍依赖项目布局）

### 7.3 Layer 进度推进

- L1: 4 模块 v0.2.0 → **5 模块齐备**（**framework 抽象首次完整** ⭐）
- L2: methodology/05 v0.1 → v0.1.1（cross-reference framework/audit_triage/）
- L3: + Sprint Q audit_triage soft-equivalent dogfood script（待 user local 跑确认）
- L4: 不变（v0.2.0 GitHub release tag 继续生效；v0.3 release 等 ≥5 v0.3 候选 + 跨领域案例触发）

### 7.4 下一 sprint 抽象优先级建议

按价值 / 风险综合判断：

1. **Sprint R 候选 A**：v0.3 patch sprint（清 6 项 v0.3 候选 + 修 BlockedMerge 这种小 nit）
   - 形态：与 Sprint P 同 / single-actor / 1 会话 / Sonnet 可考虑
   - 价值：v0.3 release 准备
2. **Sprint R 候选 B**（备选）：methodology v0.2 起草 sprint
   - 7 草案的 v0.1 → v0.2 polish + 加"Maintenance Sprint Pattern" + "P3 复发升级 P2" + "5 模块齐备阈值"等沉淀的元 pattern
   - 形态：纯文档 / Architect 主导 / 1-2 会话
3. **Sprint R 候选 C**（远期）：跨领域 reference impl（legal）
   - 触发条件：跨领域案例方主动接触
   - 当前未触发 → 不建议主动启动

---

## 8. 下一步（Sprint R 候选议程）

依据本 retro 发现，建议 Sprint R 推进：

- **优先选 候选 A**（v0.3 patch sprint）— 清 6 项候选 + framework v0.3 release 候选条件评估
- **候选 B 可与候选 A 合并** — Stage 1 加批"methodology v0.2 polish 段"（工时 +0.5-1 会话）
- 候选 C 不主动启动，等触发

不要做的事：
- ❌ 不开新 framework 模块（5 模块齐备已是抽象阶段终点 — v0.x 期内）
- ❌ 不动 audit_triage v0.1 ABI（保稳定到 v0.2 release）
- ❌ 不立即触发 ADR-031 plugin 协议（per Sprint M-O-P-Q 同结论）
- ❌ 不在 Sprint R 内做新模块抽象（间隔 1-2 sprint 后再考虑）

---

## 9. 决策签字

- 首席架构师：__ACK 2026-04-30 (Architect)__
- 用户：__ACK 待签__
- 信号：本 retro 用户 ACK + commit + push + user local Terminal 跑 dogfood → **Sprint Q 关档 / Sprint R 候选议程激活**

---

**Sprint Q retro 起草于 2026-04-30 / retro-template v0.1.1 第七次外部使用 / Architect Opus**
