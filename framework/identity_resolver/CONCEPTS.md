# Concepts — R1-R6 / GuardChain / Decision

> Status: v0.1 (Sprint N Stage 1)
> 框架核心概念定义。读完本文件后再读 `README.md` §3 快速上手会更顺。

---

## 1. 核心问题

> **问题**：给定一组实体记录（`persons` / `cases` / `drugs` / `patents` / etc），跨记录识别出哪些"代表同一个真实世界的事物"，并 soft-merge 它们。

**典型场景**：

- 古籍：同一历史人物在不同章节用不同名（"刘邦" / "汉高祖" / "高祖"）
- 法律：同一判例在不同 jurisdiction 有不同 citation
- 医疗：同一药品有商品名 / 通用名 / ATC code 多种引用
- 专利：同一发明人在不同专利写不同名字（"John Smith" / "J. Smith" / "Smith, John"）

---

## 2. 核心抽象

### 2.1 EntitySnapshot

每个待 resolve 的实体在 framework 中表示为一个 `EntitySnapshot`：

```python
EntitySnapshot(
    id="uuid-or-string",          # 主键
    name="canonical name",         # 标准名
    slug="url-safe-id",            # 短标识
    surface_forms={"name1", "name2", "..."},  # 所有已知名字
    created_at="2026-01-01T00:00:00Z",         # ISO 时间戳
    domain_attrs={"dynasty": "西汉"},          # 领域属性
    identity_notes=["与X同人"],                # 自由文本注解
    seed_match=None,                           # 由 R6 pre-pass 注入
)
```

`domain_attrs` 是 freeform dict — 案例方放入领域专属属性（dynasty / jurisdiction / drug_class / filing_year / etc）。框架核心算法不直接读 `domain_attrs`，而是通过 plugin（如 `cross_dynasty_attr` 参数）告诉 R 规则该看哪个 key。

### 2.2 R 规则（R1-R6）

每条规则是一个 **rule function** `(entity_a, entity_b, ctx) -> MatchResult | None`：

| 规则 | 信号 | confidence | 默认启用 |
|------|------|-----------|---------|
| R1 | surface_form 重叠 | 0.95 | ✅ 内置 |
| R2 | 帝X 前缀（华典专属） | 0.93 | ❌ HuaDian opt-in |
| R3 | synonym dict 归一 | 0.90 | ✅ 内置（需字典）|
| R4 | identity_notes 交叉引用 | 0.65 | ✅ 内置（需 patterns）|
| R5 | bidirectional alias dict | 0.90 | ✅ 内置（需字典）|
| R6 | external authority anchor | 1.00 | ✅ 内置（需 adapter）|

**评估顺序（first-match-wins）**：R1 → R3 → R5 → R4 → custom_rules

R6 是**单独路径**（pre-pass 阶段独立运行），不在 score_pair() dispatch 里。

### 2.3 MatchResult / MergeProposal / HypothesisProposal

每条规则返回一个 `MatchResult`（或 None）：

- `confidence >= 0.90`（默认阈值）→ 升级为 `MergeProposal` → 进 Union-Find
- `confidence < 0.90` → 降级为 `HypothesisProposal` → 写 hypotheses 表 / 人工 review

阈值由 `ScorePairContext.merge_threshold` 控制。

### 2.4 Union-Find / MergeGroup

多条规则在多对 entity 上 fire 后，可能形成 transitive closure：

- A↔B fired (R1)
- B↔C fired (R3)
- → A、B、C 同组

UnionFind 数据结构（path compression + union by rank）做这件事。每个 connected component → 一个 `MergeGroup`。

### 2.5 select_canonical

从一个 MergeGroup 选一个 canonical 代表，5 条优先级（first wins）：

1. has_pinyin_slug（避免 u-fallback slug）
2. NOT demoted by `CanonicalHint`（领域专属 demotion）
3. more surface_forms（descending）
4. earlier created_at（ascending）
5. smaller id（ascending tiebreaker）

第 1 条可由案例方覆盖（重写 `EntitySnapshot.has_pinyin_slug`）。第 2 条由 `CanonicalHint` plugin 注入。第 3-5 条领域无关。

### 2.6 GuardChain

**Guard** = 阻止特定 merge proposal 的领域专属逻辑。例如：

- `cross_dynasty_guard` — 朝代差距 > 200/500 年 → block（华典 R1/R6）
- `state_prefix_guard` — 春秋诸侯国不同 → block（华典 R1）

**GuardChain** = `dict[rule_name, list[GuardFn]]` — 案例方按规则配置 guards。

```python
HUADIAN_GUARD_CHAINS = {
    "R1": [cross_dynasty_guard_200yr, state_prefix_guard],
    "R6": [cross_dynasty_guard_500yr],
}
```

每对 candidate 在生成 MergeProposal 之前，按 chain 顺序跑 guards。**任一 guard `blocked=True` → 该 candidate 改为 BlockedMerge**（写 pending_merge_reviews 表 / Domain Expert review）。

### 2.7 BlockedMerge / pending_merge_reviews

被 guard 拦截的 merge → `BlockedMerge` 数据结构 → 案例方 `MergeApplier.write_blocked_review()` 写入自己的 triage 表（华典：pending_merge_reviews）。Domain Expert 走 Triage UI workflow 决策（参见 `framework/role-templates/` 文档）。

### 2.8 R6 Pre-pass

R6 的特殊性：它是**批量预查询** + **同 QID 检测合并**（不是 pairwise 评分）。所以 R6 走独立路径：

1. `R6PrePassRunner.attach_seed_matches()` — 一次性查询所有实体的 seed_mappings → 设 `entity.seed_match`
2. `_detect_r6_merges()` — 找出所有 `MATCHED` 状态且 same QID 的实体对 → 生成 R6 MergeProposal
3. R6 proposals 加入 Union-Find 与 R1-R5 proposals 一起做 transitive closure

---

## 3. Plugin 协议总览（9 个）

| Plugin | 必需？ | 作用 |
|--------|------|------|
| `EntityLoader` | **required** | 从 DB / API / 文件加载所有 entity → list[EntitySnapshot] |
| `MergeApplier` | apply 必需 | DB write 实现（soft-delete / log / hypothesis / triage row）|
| `R6PrePassRunner` | R6 必需 | 批量预查 seed_mappings 设 `entity.seed_match` |
| `SeedMatchAdapter` | R6 on-demand 必需 | 单次 R6 查询（QID 或 name）|
| `DictionaryLoader` | optional | R3 + R5 字典加载 |
| `StopWordPlugin` | optional | R1 stop words |
| `IdentityNotesPatterns` | optional | R4 regex patterns |
| `CanonicalHint` | optional | canonical 选择 demotion |
| `ReasonBuilder` | optional | 报告 evidence 格式化（i18n / 领域术语）|

详细 Protocol 定义见对应 .py 文件 docstring。

---

## 4. 完整流程图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       resolve_identities() 主流程                          │
└─────────────────────────────────────────────────────────────────────────┘

    EntityLoader.load_all() → list[EntitySnapshot]
                |
                ↓
    R6PrePassRunner.attach_seed_matches() (optional)
                | → 每 entity 设 .seed_match
                ↓
    ┌──────────────────────────────────────────┐
    │  for each (a, b) pair (O(n²)):           │
    │    score_pair(a, b, ctx) → MatchResult?  │
    │    if confidence ≥ 0.90:                 │
    │      evaluate_pair_guards(a, b, rule)    │
    │      ├─ blocked → BlockedMerge           │
    │      └─ pass    → MergeProposal          │
    │    else:                                 │
    │      → HypothesisProposal                │
    └──────────────────────────────────────────┘
                |
                ↓
    _detect_r6_merges() — same-QID 合并
                | → 加入 merge_proposals
                ↓
    ┌──────────────────────────────────────────┐
    │  UnionFind for transitive closure        │
    │    uf.union(a, b) for each MergeProposal │
    │    uf.groups() → connected components    │
    └──────────────────────────────────────────┘
                |
                ↓
    ┌──────────────────────────────────────────┐
    │  for each connected component:           │
    │    select_canonical(group, hint)         │
    │    build_reason_summary(builder)         │
    │    → MergeGroup                          │
    └──────────────────────────────────────────┘
                |
                ↓
    ResolveResult {
      run_id, total_entities,
      merge_groups: [MergeGroup, ...],
      hypotheses: [HypothesisProposal, ...],
      blocked_merges: [BlockedMerge, ...],
      r6_distribution: {matched, not_found, ...},
    }


┌─────────────────────────────────────────────────────────────────────────┐
│                         apply_merges() 主流程                             │
└─────────────────────────────────────────────────────────────────────────┘

    if dry_run:
      count + return summary, no DB write

    else:
      filter_groups_by_skip_rules() — 排除指定 rule 的 group
      for each MergeGroup:
        for each merged_id in group.merged_ids:
          MergeApplier.soft_delete_and_link(merged_id, canonical_id)
          MergeApplier.demote_primary_names(merged_id)
          MergeApplier.write_merge_log(...)

      for each HypothesisProposal:
        MergeApplier.write_hypothesis(...)

      for each BlockedMerge:
        MergeApplier.write_blocked_review(...)

      → return summary
```

---

## 5. 与 huadian_pipeline 原代码的对应

| Framework | huadian_pipeline 原 |
|-----------|--------------------|
| `EntitySnapshot` | `PersonSnapshot` |
| `EntityLoader` | `_load_persons()` |
| `R6PrePassRunner` | `_r6_prepass()` |
| `SeedMatchAdapter` | `r6_seed_match.py` SQL |
| `MergeApplier` | `apply_merges()` 内的 SQL |
| `cross_dynasty_attr="dynasty"` | hardcoded `a.dynasty` |
| `guard_chains` 参数 | `GUARD_CHAINS` module-level |
| `ctx.synonym_dict` | `_TONGJIA` module-level |
| `ctx.alias_dict` | `_MIAOHAO` module-level |

抽象**不改算法行为**，只把 module-level globals / hardcoded SQL / hardcoded dict 改为 plugin 注入。byte-identical dogfood（Stage 1.13）证明这点。

---

## 6. 跨规则 confidence 设计原则

每条规则的 confidence 反映**该信号的可信度**：

- R6 (1.00) — 外部权威锚点（Wikidata 等已经过人类整理）
- R1 (0.95) — surface 完全重叠（强但偶有误）
- R2 (0.93) — 帝X 前缀（华典专属语义模式）
- R3 (0.90) — 字典归一（依赖字典质量）
- R5 (0.90) — alias dict（同上）
- R4 (0.65) — identity_notes（弱信号 / 仅 hypothesis）

跨领域案例方应根据自己领域的"信号可信度"重新校准。

---

## 7. 修订历史

| Version | Date | Change |
|---------|------|--------|
| v0.1 | 2026-04-30 | 初版（Sprint N Stage 1）|

---

> 本文件描述的概念是 framework/identity_resolver/ 的**理论基础**。具体使用方法见 README.md / 跨领域 mapping 见 cross-domain-mapping.md。
