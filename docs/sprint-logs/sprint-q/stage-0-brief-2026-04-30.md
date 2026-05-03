# Sprint Q Brief — Layer 1 第 5 刀 audit_triage 抽象 + 合并补 N+O pytest tests

> 起草自 `framework/sprint-templates/brief-template.md` v0.1.2
> Dogfood: brief-template **第 6 次**外部使用（第 1 次用 v0.1.2）

## 0. 元信息

- **架构师**：首席架构师（Claude Opus 4.7）
- **Brief 日期**：2026-04-30
- **Sprint 形态**：**单 track / single-actor**（与 Sprint L+M+N+O+P 同 / 全程 Architect 主导 / Opus 全程）
- **预估工时**：**2 个 Cowork 会话**（舒缓节律；vs Sprint P 1 会话——本 sprint 工作量约 1.5x）
- **PE 模型**：N/A（single-actor）
- **Architect 模型**：Opus 4.7
- **触发事件**：Sprint P retro §8 推荐 候选 A（audit_triage 抽象）+ 候选 B（合并补 pytest tests / DGF-N-03 + DGF-O-02）
- **战略锚点**：[ADR-028](../../decisions/ADR-028-strategic-pivot-to-methodology.md) §2.3 Q3 + Sprint P retro §8 + methodology/05-audit-trail-pattern.md v0.1（已有 339 行抽象设计文档）

---

## 1. 背景

### 1.1 前置上下文

Sprint L→P 完成 framework 4 模块统一 v0.2.0 release（治理类 sprint-templates / role-templates + 代码层 identity_resolver / invariant_scaffold）。L4 第一刀（v0.2.0 GitHub release）触发完成。

**framework 第 5 模块** = audit_triage：把 Sprint K 落地的 Triage UI workflow + 三表协作模式抽象成领域无关的 Python framework，以满足 ADR-028 §2.3 "framework 5 模块齐备"目标。

Sprint Q 在大局中位置：

```
Sprint L → M → N → O → P (4 模块抽象 + v0.2.0 release)
                          ↓
Sprint Q (audit_triage + 补 N+O pytest tests) ← 现在
                          ↓
Sprint Q+N (跨领域 reference impl 触发后) → audit_triage v0.2 / examples/legal+medical / etc
                          ↓
Sprint Q+M (条件成熟时) → framework v0.3 release
```

完成后：
- framework **5 模块齐备**（audit_triage v0.1）
- 押后 6 项 v0.2 候选 → 4 项（DGF-N-03 + DGF-O-02 合并落地）
- methodology/05-audit-trail-pattern.md v0.1 → v0.1.1（cross-reference framework 实现段）

### 1.2 与既有 sprint 的差异

| 维度 | Sprint L-O 抽象 | Sprint P patch | **Sprint Q** |
|------|--------------|---------------|------------|
| 抽象类型 | 新模块抽象 | incremental fix | **新模块抽象 + 合并 pytest 补测** |
| 抽象输入 | services/pipeline 代码 / docs | 20 v0.2 候选 | **services/api triage TS 代码 + ADR-027 + methodology/05** |
| 源 stack | Python (services/pipeline) | N/A | **TypeScript + Drizzle + Postgres-js（生产是 BE）** |
| 目标 stack | Python framework | N/A | **Python framework + asyncpg**（与 N/O 一致；不抽 GraphQL/REST 接口）|
| dogfood gate | byte-identical / soft-equivalent | 简单 sanity | **soft-equivalent**（跨 stack 不能 byte-identical）+ pytest 套件首发 |
| 风险等级 | low → medium | low | **medium**（跨 stack 抽象 + pytest 是 framework 第一次单测）|
| 模型选型 | Opus / Opus+Sonnet | Opus 全程 | **Opus 全程**（跨 stack 抽象需要长 context）|
| 工作量 | 1-3 会话 | 1 会话 | **2 会话**（推荐舒缓）|

### 1.3 不做的事（Negative Scope）

- ❌ **不抽 GraphQL / REST / FE 层**（每个项目 BE stack 不同；framework 提供 store + service core，让案例方自己 binding）
- ❌ **不锁死 PostgreSQL**（DB-agnostic 通过 `TriageStore` Protocol；asyncpg 例子放 examples/）
- ❌ **不重写 services/api/.../triage.ts** 生产代码（跨 stack 抽象只针对"模式"，不替换生产实现）
- ❌ **不动 services/pipeline 生产代码**（Sprint Q 不做 V2 PE async job — 留 v0.3 候选）
- ❌ **不立即触发 ADR-031 plugin 协议**（per Sprint M-O-P 同结论）
- ❌ **不做跨领域 examples/legal+medical**（DGF-N-04 + DGF-O-03 等外部触发 / 押后）
- ❌ **不做 EntityLoader.load_subset**（DGF-N-05 等需求触发）

---

## 2. 目标范围

### 2.1 单 Track — audit_triage 抽象 + N+O pytest 补测

**目标**：

1. 抽出 `framework/audit_triage/` v0.1（Python core + asyncpg example + 3 docs）
2. 补 `framework/identity_resolver/tests/` + `framework/invariant_scaffold/tests/` pytest 套件（55 tests / ~1100 lines）
3. methodology/05-audit-trail-pattern.md v0.1 → v0.1.1（cross-reference framework 实现段）
4. dogfood：audit_triage soft-equivalent vs production（query/insert 行为一致）+ 新 pytest 套件全绿

**主要批次结构**（5 批 + 1.13 + 4）：

| 批 | 主题 | 文件数 | 估时 |
|----|------|------|------|
| 1 批 1 | audit_triage framework core | ~6 files / ~700 lines | ~1.5 hour |
| 1 批 2 | examples/huadian_classics/ asyncpg adapter | ~5 files / ~400 lines | ~1 hour |
| 1 批 3 | docs (README + CONCEPTS + cross-domain-mapping) | 3 files / ~600 lines | ~45 min |
| 1 批 4 | **DGF-N-03 + DGF-O-02 合并：补 N+O pytest tests** | ~13 files / ~1100 lines / 55 tests | ~2 hours |
| 1 批 5 | methodology/05 v0.1 → v0.1.1 cross-ref | 1 file edit | ~15 min |
| 1.13 | dogfood (audit_triage soft-equivalent + 55 tests pass) | — | ~45 min |
| 4 | closeout + retro + STATUS / CHANGELOG | — | ~45 min |
| **小计** | — | **~28 files / ~2800 lines** | **~7-8 hours / 2 会话** |

### 2.2 audit_triage framework 设计（批 1 详细）

**Plugin Protocol 数（vs Sprint N 9 个 / Sprint O 4 个）：6 个**（中等抽象量）

```
framework/audit_triage/
├── __init__.py              — 公共 API export + __version__
├── types.py                 — TriageDecisionType / Decision / PendingItem / DecisionRecord 等 frozen dataclass
├── store.py                 — TriageStore Protocol (PluginProtocol)
├── service.py               — record_decision / list_pending / decisions_for_surface / next_pending 业务逻辑
├── authz.py                 — HistorianAllowlist Protocol (PluginProtocol)
├── reasons.py               — REASON_SOURCE_TYPES const + ReasonValidator Protocol (Optional)
└── examples/
    └── huadian_classics/
        ├── __init__.py
        ├── asyncpg_store.py — TriageStore impl using asyncpg (production schema)
        ├── allowlist.py     — HistorianAllowlist impl reading historian-allowlist.yaml
        ├── schema.sql       — reference DDL (供案例方复制 / 改)
        ├── README.md        — 用法 + 与 services/api triage.ts 对应关系
        └── test_soft_equivalent.py — dogfood: 调用 framework + 调用 production query 比对
```

**6 Plugin Protocol**:

| Protocol | 职责 | 实现方 |
|----------|------|------|
| `TriageStore` | DB I/O：insert decision / list pending / fetch decisions for surface / find next pending | 案例方（asyncpg/sqlalchemy/etc）|
| `HistorianAllowlist` | 决策者 authz | 案例方（yaml/SSO/etc）|
| `ReasonValidator` (Optional) | 决策理由 source_type 验证（可选）| 案例方（默认提供 6 quick template 校验器）|
| `SurfaceClusterSorter` (Optional) | inbox 排序（surface cluster + FIFO 默认；可自定义）| 案例方 |
| `DecisionApplier` (Optional, V0.2 hook) | 决策 → 数据 mutation（V0.1 不实现，仅留 Protocol stub）| Sprint Q+ 留 |
| `ItemKindRegistry` | review_type 枚举注册（seed_mapping / guard_blocked_merge / ...）| 案例方 |

### 2.3 N+O pytest tests 设计（批 4 详细）

**identity_resolver/tests/**（~30 tests）:

```
framework/identity_resolver/tests/
├── conftest.py              — shared fixtures (sample EntitySnapshot / GuardChain)
├── test_types.py            — 5 tests: EntitySnapshot equality / RuleResult shape / etc
├── test_entity.py           — 3 tests: PersonSnapshot backwards-compat
├── test_union_find.py       — 4 tests: union / find / connected_components
├── test_guards.py           — 5 tests: evaluate_pair_guards / GuardChain order / payload swap
├── test_rules.py            — 8 tests: R1-R6 each (smoke)
├── test_canonical.py        — 2 tests: select_canonical with hint
├── test_resolve.py          — 2 tests: resolve_identities orchestration smoke
└── test_apply_merges.py     — 1 test: filter_groups_by_skip_rules
```

**invariant_scaffold/tests/**（~25 tests）:

```
framework/invariant_scaffold/tests/
├── conftest.py              — FakePort fixture
├── test_types.py            — 3 tests: Severity / Violation
├── test_invariant.py        — 3 tests: Invariant ABC / __init_subclass__
├── test_patterns_upper_bound.py   — 3 tests
├── test_patterns_lower_bound.py   — 3 tests
├── test_patterns_containment.py   — 4 tests (sync + async predicate)
├── test_patterns_orphan_detection.py — 3 tests
├── test_patterns_cardinality_bound.py — 3 tests
├── test_runner.py           — 2 tests: run_all / strict mode
└── test_self_test.py        — 1 test: SelfTestRunner._RollbackSentinel
```

### 2.4 完成判据（Definition of Done — 8 项）

- ✅ `framework/audit_triage/` v0.1 落地（~14 files / ~1700 lines incl. examples + docs）
- ✅ `framework/identity_resolver/tests/` + `framework/invariant_scaffold/tests/` 共 55 tests 全绿
- ✅ methodology/05 v0.1 → v0.1.1 加 §Framework Implementation 段
- ✅ dogfood: audit_triage soft-equivalent 通过（list_pending / record_decision / decisions_for_surface 与 services/api triage.ts 行为一致）
- ✅ ruff check + format 全过 / pytest 全绿
- ✅ 4 模块原 sanity 不回归（Sprint P 8 项 sanity 仍通过）
- ✅ STATUS / CHANGELOG 更新（Sprint Q 关档 + framework 5 模块齐备里程碑）
- ✅ Sprint Q closeout + retro + 衍生债登记 + Sprint R 候选议程

---

## 3. Stages（用 brief-template v0.1.2 §3.B 精简模板）

### Stage 0 — Inventory（已完成，本 brief §2.2 + §2.3 即 inventory）

无独立 inventory 文档；本 brief §2.2 audit_triage 设计 + §2.3 pytest tests 设计已列清。

### Stage 1 — 抽象 + 补测（5 批 + 1.13）

按以下顺序：

1. **批 1**：audit_triage framework core (types / store / service / authz / reasons / __init__) — ~1.5 hour
2. **批 2**：examples/huadian_classics/ asyncpg adapter + reference schema.sql + README — ~1 hour
3. **批 3**：3 docs (README + CONCEPTS + cross-domain-mapping) — ~45 min
4. **批 4**：N+O pytest tests 55 个 + conftest（DGF-N-03 + DGF-O-02 合并）— ~2 hour
5. **批 5**：methodology/05 v0.1 → v0.1.1 cross-reference 段 — ~15 min

会话 1 完成批 1+2+3，会话 2 完成批 4+5+1.13+Stage 4。

### Stage 1.13 — Dogfood（soft-equivalent + pytest 套件首发）

两条路径并行验证：

1. **soft-equivalent**：dogfood 脚本 `examples/huadian_classics/test_soft_equivalent.py`：
   - 起 asyncpg 连 production DB
   - framework path: `framework.audit_triage.service.list_pending(store)` + `record_decision(...)` + `decisions_for_surface(...)`
   - production path: 调用 services/api triage.service.ts 等价 query（用 asyncpg 直接跑 SQL）
   - 比对：list 数量一致 / decision INSERT 后立即 SELECT 字段值一致 / decisions_for_surface 与同 SQL 跑出一致

2. **pytest 套件首发**：
   - `pytest framework/identity_resolver/tests/ framework/invariant_scaffold/tests/ -v`
   - 期望 55 tests 全绿
   - 任 1 fail → 立即修复（不允许 skip）

### Stage 4 — Closeout

- stage-4-closeout (judging vs §2.4 8 项判据)
- retro (含 D-route 资产盘点段 + 跨 stack 抽象 lessons)
- STATUS / CHANGELOG (framework 5 模块齐备里程碑 + 押后 4 项)
- debt 登记 (剩余 4 项 v0.2)
- Sprint R 候选议程

---

## 4. Stop Rules

> 本 brief 6 条 stop rule，覆盖 5 类（catalog §2-§6）。详见 `framework/sprint-templates/stop-rules-catalog.md` §2-§6。

1. **§3 数据正确性类**：audit_triage soft-equivalent dogfood 任 1 字段不一致 → Stop，立即根因定位（要么改 framework 要么记差异为衍生债）
2. **§3 数据正确性类**：N+O pytest 任 1 fail → Stop，立即修因（不允许 skip / xfail）
3. **§3 数据正确性类**：Sprint P 4 模块 sanity 任 1 回归 → Stop，立即 revert + 重审 audit_triage 抽象是否引入跨模块耦合
4. **§4 输出量类**：audit_triage framework 行数超 brief §2.2 估算 1.5x（>2550 行）→ Stop，评估抽象是否过度（reduce scope）
5. **§5 治理类**：触发新 ADR ≥ 1 → Stop（per Sprint M-O 同结论 / 暂不动 ADR-031 plugin 协议）
6. **§2 成本类（mock）+ §6 跨 sprint 一致性类**：Sprint Q 工时 > 3 会话 → Stop，评估是否拆 Q.1 (audit_triage) / Q.2 (pytest tests)

---

## 5. 角色边界

| 角色 | 活跃度 | 主要职责 |
|------|-------|---------|
| 首席架构师 | 🟢 主导 | 全 stage / 单 actor |
| 其余 9 角色 | ⚪ 暂停 | — |

> Single-actor sprint 简化（per brief-template v0.1.2 §5 注脚）：本 sprint 仅 Architect 主导，其余 9 角色全 ⚪ 暂停。

---

## 6. 收口判定（同 §2.4，重复以便 closeout 直接对照）

- ✅ `framework/audit_triage/` v0.1 落地（~14 files）
- ✅ `framework/{identity_resolver,invariant_scaffold}/tests/` 共 55 tests 全绿
- ✅ methodology/05 v0.1 → v0.1.1
- ✅ dogfood: audit_triage soft-equivalent 通过
- ✅ ruff check + format 全过 / pytest 全绿
- ✅ Sprint P 4 模块 sanity 不回归
- ✅ STATUS / CHANGELOG 更新（5 模块齐备）
- ✅ Sprint Q closeout + retro + 衍生债登记 + Sprint R 候选议程

---

## 7. 节奏建议

**舒缓 2 会话**（推荐 / vs Sprint P 1 会话——本 sprint 1.5x 工作量）：

会话 1（~3-4 hours）：
- Stage 0 inventory（已嵌 brief §2）
- Stage 1 批 1 audit_triage framework core (~1.5h)
- Stage 1 批 2 huadian_classics asyncpg adapter (~1h)
- Stage 1 批 3 docs (~45min)
- 阶段性 commit + 用户中场 ACK

会话 2（~3-4 hours）：
- Stage 1 批 4 pytest tests 55 个（最大单批 / ~2h）
- Stage 1 批 5 methodology/05 cross-ref (~15min)
- Stage 1.13 dogfood + pytest 套件首发 (~45min)
- Stage 4 closeout + retro + STATUS/CHANGELOG (~45min)

**单会话压缩**（备选 / 风险高 / 不推荐）：
- 跨 stack 抽象 + 55 tests 一次过的概率较低；如压缩易触发 Stop Rule #6 工时超 3 会话

---

## 8. D-route 资产沉淀预期

本 sprint 预期沉淀以下框架抽象资产（**至少勾 ≥ 1 项**；本 sprint 实际勾 4 项）：

- [x] **新增 framework 代码模块**：`framework/audit_triage/` v0.1（第 5 刀 / 与 identity_resolver / invariant_scaffold 同代码层）
- [x] **methodology v0.x → v0.(x+1) 迭代**：methodology/05-audit-trail-pattern.md v0.1 → v0.1.1（加 §Framework Implementation 段）
- [x] **框架代码 spike**：N+O pytest 套件首发（55 tests / framework testing 范本）
- [x] **跨领域 mapping 表更新**：framework/audit_triage/cross-domain-mapping.md v0.1（首发 / 6 领域适配指南）
- [ ] 案例素材积累（不勾 — Sprint Q 是抽象 sprint / 不动数据）

> 至少 4 项预期 → 远超 ADR-028 / C-22 的 ≥ 1 项要求。

**Layer 进度推进预期**：

- L1: 4 模块 v0.2.0 → **5 模块**（audit_triage v0.1 加入；framework 抽象**首次完整**）
- L2: methodology/05 v0.1 → v0.1.1（cross-reference / 与 N/O 同 pattern）
- L3: 不变（dogfood Sprint L-O 已完成；Sprint Q 的 dogfood 是 audit_triage soft-equivalent + pytest 套件首发）
- L4: 不变（v0.2.0 已 release）；下一刀触发等 Sprint Q+N v0.3 release

---

## 9. 模型选型

- **Architect 主 session**：Opus 4.7（与 L+M+N+O+P 同）
- **理由**：跨 stack 抽象（TS 生产 → Python framework）+ 6 Plugin Protocol 设计 + 55 pytest tests 撰写需要长 context + 多文件一致性；Sonnet 在 multi-file orchestration + cross-stack pattern translation 上偶尔失焦

---

## 10. Dogfood 设计

### 10.1 brief-template v0.1.2 第 1 次外部使用

本 brief 是 brief-template v0.1.2（Sprint P release）的**第 1 次外部使用**（vs v0.1.1 用了 4 次）。

预期发现：
- §3.B 精简模板的 batch 编号惯例（"批 N"）是否清晰
- §3.0 选择指南是否帮助本 sprint 一眼选 §3.B（应该是 ✓）
- §1.2 灵活列数说明（与 L-O 抽象 + Sprint P 三方对比 4 列）是否好用

发现的 issue（如有）登记为 v0.3 候选。

### 10.2 audit_triage soft-equivalent 是 framework 抽象的"出厂检验"

audit_triage 与 identity_resolver / invariant_scaffold 不同的是：production 是 TypeScript（services/api/triage.service.ts），framework 是 Python。byte-identical 不可能（两个 stack DTO shape 不同），所以走 **soft-equivalent**：

- 调 framework Python `list_pending(store)` → 得 list of PendingItem
- 调 production TS 等价 SQL（asyncpg 直接跑）→ 得 raw rows
- 比对：rows 数量 / 每行 source_id 一致 / surface 一致 / pending_since 一致

类似 Sprint O 的 soft-equivalent 模式。

### 10.3 pytest 套件首发是 framework 的"测试范本"

55 tests 不是为了 100% 覆盖，而是给跨领域 fork 案例方一个"如何写测试"的范本：
- conftest.py 怎么搭
- async test 怎么跑（pytest-asyncio）
- mock DBPort 怎么设计

### 10.4 起草本 brief 暴露的发现（即时登记）

无新 brief-template 改进候选（v0.1.2 第 1 次用就用得顺手；超出 v0.1.1 痛点已解决）。

---

## 11. 决策签字

- 首席架构师：__ACK 待签 (2026-04-30)__
- 用户：__ACK 待签 (2026-04-30)__
- 信号：本 brief 用户 ACK 后 → Sprint Q Stage 1 启动（会话 1）

---

**本 brief 起草于 2026-04-30 / brief-template v0.1.2 第 1 次外部使用 / Architect Opus**
