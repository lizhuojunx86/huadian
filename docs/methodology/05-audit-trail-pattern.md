# Audit Trail Pattern — Pending Review + Triage Workflow for Human-in-the-Loop KE

> Status: **Draft v0.1**
> Date: 2026-04-29
> Owner: 首席架构师
> Source: 华典智谱 Sprint K (T-P0-028 Triage UI V1) + ADR-027 + Hist Stage 5 真实 E2E

---

## 0. TL;DR

KE 项目无法靠 AI 完全自动化——总有 ambiguous case 需要 Domain Expert 判断。AKE 框架提供 **三表协作 + Triage Workflow** 模式：

1. **`pending_review` 表** — 等 Domain Expert 决策的 candidate 队列
2. **`audit_log` 表**（如 `merge_log`）— 已执行决策的不可变记录
3. **`triage_decisions` 表** — Domain Expert 决策行为的审计 + 跨 sprint 决策回查

辅以 **Triage UI** 让 Domain Expert 通过 Web 界面而非 SQL 工作。

实证（Sprint K）：5 角色（PE/BE/FE/Hist/Architect）协同，1 个工作日完成 V1 落地，Domain Expert 真实 E2E 验证（提交 1 reject + 1 approve 决策，DB 完整 audit）。

本文件给出：(1) 三表协作模式；(2) Triage UI workflow；(3) 跨 sprint 决策回查机制；(4) 跨领域指南；(5) 反模式。

---

## 1. 为什么需要这个模式

### 1.1 KE 项目的"ambiguous case"

R1-R6 + GUARD_CHAINS（参见 [03-identity-resolver-pattern.md](03-identity-resolver-pattern.md)）拦截下来的 candidate **不能直接 merge**——guard 触发 = 系统不确定。这些 candidate 需要 Domain Expert 决策。

但**怎么管理这个决策流程**是一个独立的工程问题。

### 1.2 不用 audit trail 的痛点（Sprint G/H/I 实证）

Sprint G/H/I 的 Domain Expert review 都是用 **markdown 文件 + git commit** 方式做的。痛点积累：

1. **跨 sprint 重复审同 surface 簇**：周成王↔楚成王 在 Sprint G/J/项羽δ 三连 reject — 每次重新看 90-120 分钟
2. **决策记录散落 4+ markdown**：跨 sprint 查阅靠 grep
3. **context 不足时切多 SELECT**：楚怀王 mention bucketing 需 4 次 SQL
4. **没有 hint banner**：Domain Expert 不知道"这个 surface 我之前怎么决策过"

→ ADR-027 提出 Triage UI + 三表协作模式解决这些痛点。

### 1.3 解决方案的核心抽象

```
PE 跑 dry-run resolve
  ↓ 候选写入 pending_merge_reviews
Domain Expert 打开 Triage UI
  ↓ 看到 candidate + 历史 hint banner
  ↓ 决策 approve / reject / defer + reason_text
  ↓ 决策写入 triage_decisions（多值审计）
PE 读 triage_decisions（V2 计划）→ apply 到 merge_log + 数据 mutation
```

---

## 2. 三表协作模式

### 2.1 表的角色

| 表 | 角色 | 谁写 | 谁读 |
|----|------|------|------|
| `pending_review`（如 `pending_merge_reviews`）| 等决策的 candidate 队列 | Pipeline | Domain Expert (via Triage UI) |
| `triage_decisions` | Domain Expert 决策 audit | Domain Expert (via UI) | Architect / Pipeline / 跨 sprint 回查 |
| `audit_log`（如 `merge_log`）| 已执行决策的不可变记录 | Pipeline (apply phase) | All（用于 invariant test / 数据回溯）|

### 2.2 Schema 抽象（领域无关）

```sql
-- pending_review 表（每个领域可以有多种 review 类型）
CREATE TABLE pending_reviews (
    id UUID PRIMARY KEY,
    review_type TEXT NOT NULL,              -- 'merge_candidate' / 'split_candidate' / etc
    surface_snapshot TEXT NOT NULL,         -- 触发的"surface"快照（如人名）
    candidate_data JSONB NOT NULL,          -- 候选详情
    pending_since TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending'  -- 'pending' / 'decided'
);

-- triage_decisions 表（多值审计：同一 source 可有多条决策记录）
CREATE TABLE triage_decisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_table TEXT NOT NULL,
    source_id UUID NOT NULL,
    surface_snapshot TEXT NOT NULL,
    decision TEXT NOT NULL CHECK (IN ('approve', 'reject', 'defer')),
    reason_text TEXT,
    reason_source_type TEXT,
    historian_id TEXT NOT NULL,
    historian_commit_ref TEXT,
    architect_ack_ref TEXT,
    decided_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    downstream_applied BOOLEAN NOT NULL DEFAULT false,
    downstream_applied_at TIMESTAMPTZ,
    downstream_applied_by TEXT,
    notes TEXT,
    UNIQUE (source_id, surface_snapshot, historian_id)  -- idempotency
);

-- audit_log 表（已执行的不可变决策，参见 ADR-014）
CREATE TABLE merge_log (
    id UUID PRIMARY KEY,
    target_id UUID NOT NULL,                -- merge 后保留的 entity
    source_id UUID NOT NULL,                -- merge 前被合并的 entity
    merge_type TEXT NOT NULL,               -- 'historian_approved' / 'sub_merge' / 'textbook_fact' / etc
    triage_decision_id UUID,                -- FK to triage_decisions（V2）
    merged_at TIMESTAMPTZ NOT NULL,
    merged_by TEXT NOT NULL,
    metadata JSONB
);
```

### 2.3 Idempotency 设计（关键）

**关键**：`triage_decisions.UNIQUE (source_id, surface_snapshot, historian_id)`

理由：跨 sprint 同 historian 对同一 (source, surface) 重复决策时，应**保留 1 条**（先到先得），而非创建多条。

实证（Sprint K Stage 2 backfill）：
- Backfill 175 行 vs dry-run 预期 179 行
- 4 行差异 = 跨 sprint 重复决策（γ G3 + δ G3 同 pair 同 reject）
- Idempotency unique key 正确去重，符合设计意图

→ **Idempotency 不是"安全网"，是"语义意图"**。

### 2.4 Multi-valued Audit（多值审计）

为什么 `triage_decisions` 不是 `(source_id) UNIQUE` 而是 `(source_id, surface_snapshot, historian_id) UNIQUE`？

理由：支持"defer → 重审 → approve"的状态演进。同一 source 可能有：

- T0: Domain Expert A `defer`
- T1: Domain Expert A `approve`（取代 defer）
- T2: Domain Expert B `reject`（不同 historian，可能由 architect 仲裁）

每条决策都是不可变 audit row，最新的有效。

---

## 3. Triage UI Workflow

### 3.1 UI 三段结构（ADR-027）

```
┌─────────────────────────────────────────────┐
│ 1. Hint Banner (跨 sprint 历史决策回查)       │
│    "本 surface 已有 N 条历史决策"             │
│    + 决策列表 + 一致性 badge                 │
├─────────────────────────────────────────────┤
│ 2. Item Detail                              │
│    - candidate 完整字段                      │
│    - guard payload                          │
│    - source / evidence                      │
│    - lazy load (如 Person)                  │
├─────────────────────────────────────────────┤
│ 3. Decision Form                            │
│    - radio: approve / reject / defer       │
│    - select: reason_source_type            │
│    - textarea: reason_text                 │
│    - 6 quick template buttons              │
│    - submit                                │
└─────────────────────────────────────────────┘
```

### 3.2 Inbox Mode（ADR-027 §2.3）

Triage UI V1 的核心 UX：

- 列表页 = 队列视图（按 surface 簇 + FIFO）
- 提交决策后 → 自动跳转到下一个 pending item（`nextPendingItemId`）
- Domain Expert 进入"审一审一审"心流

### 3.3 6 Quick Templates（实证最常用的 reason 类型）

```
1. 参考最近裁决：(在 hint banner 中展示)
2. in_chapter: 同章节内即可判断（如 "周成王西周 vs 楚成王春秋"）
3. other_classical: 引用其他古籍（如《左传》）
4. slug-dedup: 命名规范导致的去重（slug 相同）
5. commit hash 引用: 历史 commit 已处理类似 case
6. ADR 引用: 已有 ADR 覆盖此规则
```

→ 这些 template 是从 Sprint G/H/I review 实战中提炼的最常用 reason 类型。

### 3.4 V1 vs V2 的范围划分

| 维度 | V1（Sprint K 已交付）| V2（Sprint M+ 候选）|
|------|-------------------|-------------------|
| 写决策 | ✅ Triage UI + GraphQL mutation | 同 |
| 读历史决策 | ✅ Hint banner + per-surface 回查 | 同 |
| 列表过滤已决策 | ❌（V1 zero-downstream）| ✅ |
| `recentTriageDecisions` query | ❌ | ✅ |
| DONE 队列页 | ❌ | ✅ |
| 批量决策 | ❌ | ✅（Hist Stage 5 反馈最想要的）|
| Pipeline 自动 apply | ❌（V1 zero-downstream）| ✅ |

### 3.5 V1 Zero-Downstream 设计

ADR-027 §2.5 显式声明 V1 = **zero-downstream**：决策只写 audit，不修改 `pending_merge_reviews.status` 或 `seed_mappings.mapping_status`。

理由：
- V1 优先 ship 工作流闭环
- 不冒险触发下游 pipeline 自动 apply
- 让 Architect 仍然手动控制 apply 时机

代价：
- 列表页不过滤已决策的 item（UX gap）
- Hist 提交后看到 item 仍在队列里（有 Hint Banner 提示历史已决策）

抽象洞察：**V1 优先 ship 闭环，V2 优化 UX**。

---

## 4. 跨 Sprint 决策回查（Hint Banner 机制）

### 4.1 痛点回顾

Sprint G→J 期间多次出现"我之前是不是审过这个 surface 簇"的疑问。手动 grep 4 个 markdown 找答案。

### 4.2 解决方案

`triageDecisionsForSurface(surface: String): [TriageDecision!]!`

GraphQL query 接受 surface（人名 / 关键 token），返回历史所有决策。

UI 在 Item Detail 页顶部展示 Hint Banner：

```
┌─────────────────────────────────────────────┐
│ ⓘ 同 surface "周成王" 已有 3 条历史决策      │
│   高一致性（3/3 reject）                    │
│   2026-04-26 chief-historian reject (周成王↔楚成王)│
│   2026-04-27 chief-historian reject (周成王↔成王) │
│   2026-04-28 chief-historian reject (...)    │
└─────────────────────────────────────────────┘
```

### 4.3 一致性 Badge

如果同 surface 历史决策**全部一致**（全 reject / 全 approve），显示"高一致性"badge。Domain Expert 可快速 pattern-match 历史决策做新决策。

### 4.4 实证（Sprint K Hist Stage 5 E2E）

Domain Expert 提交"周成王↔楚成王 reject"后，再次访问该 surface 的 detail 页：

- Hint Banner 包含 4 条历史决策（3 backfill + 1 新提交）
- "高一致性"badge 显示（4/4 reject）
- Domain Expert 反馈："Hint Banner 信息密度极有价值；缺历史 reason_text 摘要"（→ V2 candidate）

---

## 5. 跨领域使用指南

### 5.1 三表协作的领域无关性

`pending_review` / `triage_decisions` / `audit_log` 三表的 schema 是**完全领域无关**的。任何 KE 项目可直接套用。

差异只在：
- **review_type** enum 值（古籍 = 'merge_candidate' / 'split_candidate' / 法律 = 'precedent_match' / 'overrule_candidate' / etc）
- **surface_snapshot** 含义（古籍 = 人名；法律 = 案号 / 法条；医疗 = 诊断关键词）
- **6 quick templates** 内容（每个领域提炼自己的最常用 reason 类型）

### 5.2 启动新案例的步骤

```
1. 复制 ADR-027 schema 到你的项目
2. 调整 review_type enum
3. 实现 GraphQL TriageItem interface（参见 services/api/src/schema/triage.graphql）
4. 实现 RecordTriageDecision mutation
5. 复用 apps/web/app/triage/* React 组件（领域无关）
6. 调整 6 quick templates 文案
7. 调整 Hint Banner 配色 / 文案
```

### 5.3 跨领域 reason_source_type 例

| 领域 | reason_source_type 候选 |
|------|----------------------|
| 古籍 | in_chapter / other_classical / slug-dedup / commit_hash / adr |
| 佛经 | in_sutra / other_sutra / commentarial / sectarian |
| 法律 | in_case / cited_precedent / statute / legal_review |
| 医疗 | clinical_judgment / guideline / literature / consult |
| 专利 | claim_examination / prior_art / legal_review |

---

## 6. 反模式

### 6.1 反模式：用 git commit 替代 audit table

❌ Domain Expert 通过 git commit 记录决策（"我在 SHA xxx 中 reject 了周成王 case"）

✅ git commit 不可结构化查询；audit table 才是真审计

### 6.2 反模式：单值 audit

❌ `triage_decisions UNIQUE (source_id)` — 一个 source 只能有 1 条决策

✅ 多值审计支持 defer → approve 状态演进

### 6.3 反模式：UI 强写 schema 字段

❌ Triage UI 直接 INSERT INTO `merge_log`（绕过 ADR-014 names-stay 铁律）

✅ Triage UI 只写 `triage_decisions`；Pipeline 才能写 `merge_log`

### 6.4 反模式：列表页过滤已决策（V1 不要做）

❌ V1 加 NOT EXISTS subquery 过滤"已决策"item

✅ V1 zero-downstream，列表页就是 raw pending；过滤等 V2

### 6.5 反模式：Hint Banner 把决策细节全显示

❌ Hint Banner 显示完整 reason_text + 全部 metadata

✅ Hint Banner 只显示 count + 一致性 badge + 链接到完整决策

### 6.6 反模式：Idempotency 包括过多字段

❌ `UNIQUE (source_id, surface, historian_id, reason_text)` — reason_text 不同就允许重复

✅ `UNIQUE (source_id, surface, historian_id)` — 同 historian 同 source 同 surface 只能 1 条决策

---

## 7. 修订历史

| Version | Date | Author | Change |
|---------|------|--------|--------|
| Draft v0.1 | 2026-04-29 | 首席架构师 | 初稿（Stage C-9 of D-route doc realignment）|

---

> 本文档描述的 Audit Trail Pattern 是 AKE 框架的 Layer 1 核心资产之一。
> Sprint K (T-P0-028) 是其首次完整实现，详见 `docs/decisions/ADR-027-pending-triage-ui-workflow-protocol.md` + `docs/sprint-logs/sprint-k/`.
