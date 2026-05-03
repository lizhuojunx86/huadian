# framework/audit_triage — Audit Trail + Triage Workflow Framework

> Status: **v0.1 (Sprint Q Stage 1 first abstraction)**
> Date: 2026-04-30
> License: Apache 2.0 (代码) / CC BY 4.0 (文档)
> Layer: AKE 框架 Layer 1 第 5 刀（与 sprint-templates / role-templates / identity_resolver / invariant_scaffold 同层）

## 0. 这个框架解决什么问题

Knowledge Engineering 项目里，AI agent 永远无法 100% 自动化——总有一类"歧义 / 跨源冲突 / 政策依赖"的 case 必须由 Domain Expert（古籍专家 / 法律顾问 / 主治医生 / etc）人工裁决。

**audit_triage** 抽象的是这套人机协作的工作流：

```
Pipeline 跑 → 输出待决策 candidates 到 pending_review 表
   ↓
Domain Expert 打开 Triage UI 看到队列
   ↓ 看到 hint banner "你之前在 Sprint G/J 拒绝过这个 surface"
   ↓ 决策 approve / reject / defer + reason_text
   ↓ 决策写入 triage_decisions（多值审计）
PE 后续异步 apply 决策到数据层（V0.2）
```

3 个跨 sprint / 跨案例的真实痛点（华典智谱 Sprint G/H/I 实证）：

1. **跨 sprint 重复审同 surface 簇**：周成王 ↔ 楚成王 在 3 个 sprint 各被 review 一次，每次 90+ 分钟
2. **决策记录散落 4+ markdown**：跨 sprint 查阅靠 grep
3. **没有 hint banner**：Domain Expert 不知道"我之前怎么决策过这个 surface"

→ ADR-027 提出 **三表协作**（pending_review + triage_decisions + audit_log）+ **Triage UI** 解决；Sprint K 落地，Sprint Q 抽象为框架。

## 1. 模块在框架中的位置

```
framework/
├── sprint-templates/     # 治理 / sprint workflow 模板
├── role-templates/       # 治理 / 多角色协作模板
├── identity_resolver/    # 代码 / R1-R6 实体消歧
├── invariant_scaffold/   # 代码 / V1-V11 不变量校验
└── audit_triage/         # 代码 / 人机协作 review workflow ← 本模块
```

5 模块齐备 → AKE 工程框架最小完整集合。

## 2. 公共 API（v0.1）

详见 `__init__.py` 的 `__all__`。三层 API：

### 2.1 数据类型

| 类型 | 用途 |
|------|------|
| `TriageDecisionType` | 决策枚举：`"approve"` / `"reject"` / `"defer"` |
| `ItemKind` | 领域可扩展的 review 类型字符串（"seed_mapping" / etc）|
| `PendingItem` | 待决策队列中的一行 |
| `DecisionRecord` | `triage_decisions` 表中的一行 |
| `RecordDecisionInput` | 写决策时的输入 payload |
| `RecordDecisionResult` | 写决策返回 (record + nextPendingId 或 error) |
| `DecisionError` / `DecisionErrorCode` | 结构化错误（6 个 code）|

### 2.2 Plugin Protocols（实现这些以接入你的领域）

| Protocol | 必要 | 职责 |
|----------|------|------|
| `TriageStore` | ✅ 必须 | DB I/O：list / find / insert / decisions queries |
| `HistorianAllowlist` | ✅ 必须 | 决策者 authz |
| `ReasonValidator` | ⚪ 可选 | reason_source_type 校验（默认提供 `DefaultReasonValidator`）|
| `ItemKindRegistry` | ⚪ 可选 | kind → source_table 映射（v0.1 store 自管，v0.2 启用）|
| `DecisionApplier` | ⚪ 可选 | V0.2 hook：决策 → 数据层 mutation（v0.1 不实现，仅 Protocol stub）|

### 2.3 Service 函数

| 函数 | 用途 |
|------|------|
| `record_decision(store, authz, input, *, reason_validator=None, ...)` | 写决策 + 返回 next pending |
| `list_pending_items(store, *, limit, offset, ...)` | 读队列 |
| `find_pending_item(store, item_id)` | 读单个 pending |
| `decisions_for_surface(store, surface, *, limit=10)` | hint banner 跨 sprint 回查 |
| `decisions_for_source(store, source_table, source_id, *, limit=100)` | 全 source audit trail |
| `encode_item_id` / `decode_item_id` | 复合 `"<kind>:<source_id>"` ID 编解码 |
| `is_valid_decision_type` / `coerce_decision_type` | 决策枚举 guards |

### 2.4 参考实现

| 名称 | 用途 |
|------|------|
| `StaticAllowlist(iterable)` | set-based `HistorianAllowlist` 实现 |
| `DefaultReasonValidator(allowed=None)` | set-based `ReasonValidator` 实现 |
| `DEFAULT_REASON_SOURCE_TYPES` | 6-tag 默认词汇（in_chapter / wikidata / etc）|

## 3. Quick Start

```python
import asyncpg
from framework.audit_triage import (
    StaticAllowlist, DefaultReasonValidator,
    RecordDecisionInput, record_decision,
)
from framework.audit_triage.examples.huadian_classics import (
    AsyncpgTriageStore,
)

async def main():
    pool = await asyncpg.create_pool(DATABASE_URL)
    store = AsyncpgTriageStore(pool)
    authz = StaticAllowlist(["chief-historian", "alice"])

    items, total = await list_pending_items(store, limit=10)
    print(f"{total} pending items")

    if items:
        result = await record_decision(
            store, authz,
            RecordDecisionInput(
                item_id=items[0].item_id,
                decision="approve",
                historian_id="chief-historian",
                reason_text="同章节明确互称",
                reason_source_type="in_chapter",
            ),
        )
        if result.error:
            print(f"FAIL: {result.error.code} — {result.error.message}")
        else:
            print(f"OK: {result.decision_record.id}")
            print(f"next: {result.next_pending_item_id}")

    await pool.close()
```

## 4. V0.1 设计原则

1. **零下游 (zero-downstream)** — `record_decision` 只写 `triage_decisions`，不动数据层（per ADR-027 §2.5 / §5 merge-iron-rule）。决策 → 数据 mutation 是 V0.2 `DecisionApplier` 的职责。
2. **Surface-cluster + FIFO 排序** — inbox 按 surface cluster 聚合（同一 surface 的 candidates 一起处理）+ cluster 内 FIFO（per ADR-027 §2.3 V1）。
3. **多值审计** — 同一 source_id 允许多条决策记录（defer → revisit → approve）。
4. **Surface 冻结** — 决策时 `surface_snapshot` 立即冻结到 `triage_decisions.surface_snapshot`，源行后续修改不影响 hint banner。
5. **接口层不抽** — REST / GraphQL / FE 各项目栈不同；framework 只抽 store + service core，让案例方自己 binding（fastify / graphql / flask / etc）。
6. **DB 不锁死** — `TriageStore` Protocol；asyncpg 是 examples/，不是 framework。

## 5. 5 类反模式（来自 Sprint G/H/I 痛点）

| 反模式 | 后果 | 替代 |
|--------|------|------|
| 把 review 做成 markdown + git commit | 跨 sprint 重复审 / 无 hint | Triage UI + `triage_decisions` |
| 单值决策表（UNIQUE on source_id）| defer 后无法 revisit | 多值审计（多行允许）|
| 决策时不存 surface | 源行重命名后 hint banner 失效 | `surface_snapshot` 冻结 |
| 决策 + 数据 mutation 同事务 | rollback 灾难 / 测试困难 | 零下游 + 异步 applier |
| Authz 写在 service 里 | 跨域不可换 | `HistorianAllowlist` Protocol |

## 6. 跨域适配指南

详见 [cross-domain-mapping.md](cross-domain-mapping.md)。简表：

| 领域 | ItemKind 候选 | source_table 候选 |
|------|-------------|----------------|
| 古籍 | seed_mapping / guard_blocked_merge | seed_mappings / pending_merge_reviews |
| 法律 | contract_party_match / clause_revision | pending_party_matches / pending_clause_reviews |
| 医疗 | drug_substitution / dosage_review | pending_substitutions / pending_dosage_reviews |
| 专利 | claim_overlap / prior_art_match | pending_overlaps / pending_prior_art |
| 学术 | author_disambig / citation_match | pending_authors / pending_citations |

## 7. 反馈与贡献

本框架从华典智谱 Sprint K 实战 + ADR-027 + methodology/05-audit-trail-pattern.md 抽出，是 v0.1 状态。

- **报告使用经验**（GitHub Issue 标 `audit-triage-feedback`）
- **指出遗漏**（标 `audit-triage-gap`）
- **贡献跨领域 reference impl**（PR 加 `examples/your_domain/`）

详见华典智谱主项目 [CONTRIBUTING.md](https://github.com/lizhuojunx86/huadian/blob/main/CONTRIBUTING.md)。

---

## 8. 版本信息

| Version | Date | Source | Change |
|---------|------|--------|--------|
| v0.1 | 2026-04-30 | Sprint Q Stage 1 (first abstraction) | 初版抽出（6 framework core + 4 huadian_classics examples + 3 docs）|

---

> 本框架是 AKE 框架 Layer 1 的**第五刀**（5 模块齐备 / 框架抽象首次完整）。
> 第一刀 (L)：framework/sprint-templates/
> 第二刀 (M)：framework/role-templates/
> 第三刀 (N)：framework/identity_resolver/
> 第四刀 (O)：framework/invariant_scaffold/
> 第五刀 (Q)：framework/audit_triage/ ← 本框架
> 当前完整 framework 目录：https://github.com/lizhuojunx86/huadian/tree/main/framework
