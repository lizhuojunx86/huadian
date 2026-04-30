# Sprint N Stage 0 — Inventory: Identity Resolver 代码层抽象的领域耦合扫描

> Date: 2026-04-30
> Owner: 首席架构师
> Anchor: Sprint N Brief §3 Stage 0
> Purpose: 为 Stage 1 起草 `framework/identity-resolver/` 提供输入 — 6 个 .py 文件（2394 行）的领域耦合扫描 + plugin 注入点设计 + 起草顺序 + 工作量预估更新

---

## 0. 扫描方法

沿用 Sprint L+M Stage 0 inventory 同款分类（参见 `docs/sprint-logs/sprint-l/stage-0-inventory-2026-04-29.md` §0），但本 sprint 是**代码扫描**（vs L+M 的文档扫描），加细粒度：

- 🟢 **完全领域无关** — 算法 / 数据契约 / 标准模式，可零修改抽到 framework/identity-resolver/
- 🟡 **接口领域无关 + 实现领域专属** — 算法/接口无关，但具体实现（字典 / regex / SQL）需 plugin 化或注入
- 🔴 **案例 reference impl** — 完全华典专属（中文字符 / 朝代 / 春秋诸侯国 / 帝X 等），抽到 examples/huadian_classics/ 作为参考实现，跨领域案例方需自己写

每段代码额外标"plugin 化路径"（Protocol / Adapter / Hook / 直接抽出）。

---

## 1. 6 个 Python 文件总表

| # | 文件 | 行数 | 整体分类 | 抽象优先级 | 核心 plugin 注入点 |
|---|------|-----|---------|----------|------------------|
| 1 | `resolve.py` | 1065 | 🟢 主流程 / 🟡 DB 层 | **P0** 主流程 + **P1** DB 抽 Protocol | DB Adapter (`PersonLoader` / `R6PrePassAdapter` / `MergeApplier`)|
| 2 | `resolve_rules.py` | 614 | 🟡 R1-R5 接口 + 字典实现专属 | **P0** 接口 + **P1** plugin 化 | `DictionaryLoader` / `StopWordPlugin` / `IdentityNotesPatterns` Protocol |
| 3 | `resolve_types.py` | 95 | 🟢 完全领域无关 | **P0** 直接抽 | 无 |
| 4 | `r6_seed_match.py` | 156 | 🟡 接口无关 / SQL 专属 | **P0** 接口 + **P1** plugin 化 | `SeedMatchAdapter` Protocol（DB schema 注入）|
| 5 | `r6_temporal_guards.py` | 273 | 🟡 GuardChain 协议无关 / cross_dynasty 实现专属 | **P0** 协议 + **P3** 实现作 reference | `GuardFn` Protocol；cross_dynasty_guard → examples/ |
| 6 | `state_prefix_guard.py` | 191 | 🔴 完全华典（春秋诸侯国）| **P3** 整文件作 reference impl | 整文件 → examples/huadian_classics/state_prefix_guard.py |
| **合计** | — | **2394** | — | — | — |

**关键观察**：

- ~50% 完全领域无关（resolve_types + UnionFind + 主流程 + R1-R5 接口骨架 + GuardChain 协议）
- ~30% 接口无关 + 实现专属（DB 层 SQL / R3+R5 字典 / R1 stop words / canonical hint）
- ~20% 案例 reference impl（cross_dynasty / state_prefix / R2 帝X / 非人识别 / 中文 regex pattern）

→ 与 brief §2.1 抽象目标分层（50/30/20）实际匹配。

---

## 2. 各文件详细标注

### 2.1 `resolve_types.py` (95 行) — 🟢 完全领域无关 / 先抽

**领域无关段（直接复制）**：

- `MatchResult` 数据契约（rule / confidence / evidence）
- `MergeProposal` / `HypothesisProposal` / `MergeGroup` / `BlockedMerge` / `ResolveResult` 全部数据类
- `total_merged_persons` / `persons_after_merge` 计算属性

**⚠️ 微小注释要清理**：

- "T-P0-029" / "Sprint C" 等华典 task 标识 → 改为通用注释
- `proposed_rule: str  # "R6"` 注释中的 "R6" 字面量 → 留作 example，不强制
- `guard_type: str  # "cross_dynasty"` 注释 → 同上

**抽象路径**：

```python
# framework/identity-resolver/types.py
# 几乎完全复制，只清理 task ID / Sprint 标识等内部 reference
```

**预估**：~95 行 / 直接复制 + 5 处 cleanup / 5-10 分钟

---

### 2.2 `resolve.py` (1065 行) — 🟡 主流程无关 / DB 层 + 报告生成 需 plugin

**领域无关段（约 70%，直接抽出）**：

| 段 | 行 | 抽象路径 |
|---|---|---------|
| `UnionFind` class | 60-91 | → `framework/identity-resolver/union_find.py`（< 100 行）|
| `R6PrePassResult` class | 195-205 | → `framework/identity-resolver/r6_seed_match.py` 一部分 |
| `_swap_ab_payload` | 299-314 | → `framework/identity-resolver/utils.py`（标准 payload 处理）|
| `_detect_r6_merges` | 317-420 | → `framework/identity-resolver/resolve.py` 一部分（算法完全无关）|
| `resolve_identities()` 主流程 | 456-629 | → `framework/identity-resolver/resolve.py` 主入口 |
| `_filter_groups_by_skip_rules` | 673-698 | → `framework/identity-resolver/apply_merges.py` |
| `apply_merges()` 业务流程 | 701-900 | → `framework/identity-resolver/apply_merges.py`（主流程无关 + 注入 `MergeApplier` Protocol）|
| `generate_dry_run_report` | 908-1023 | → `framework/identity-resolver/dry_run_report.py`（i18n + 不硬编码中文）|

**接口无关 + 实现专属（约 20%，需 plugin）**：

| 段 | 行 | plugin 类型 |
|---|---|----------|
| `_load_persons` SQL | 99-182 | → `PersonLoader` Protocol（让案例方实现自己的 SQL / NoSQL / API source）|
| `_r6_prepass` SQL | 208-296 | → `R6PrePassAdapter` Protocol |
| `apply_merges` SQL writes | 757-891 | → `MergeApplier` Protocol（提供华典 reference adapter 在 examples/）|
| `select_canonical()` 5 条规则 | 428-448 | → `framework/identity-resolver/canonical.py`，前 4 条 hardcoded（has_pinyin_slug / created_at / id / surface_forms count），第 2 条 `has_di_prefix_peer` → `CanonicalHint` Protocol |

**案例专属（约 10%，作 reference impl）**：

| 段 | 行 | examples/ 目标 |
|---|---|---------------|
| `_build_reason` 中文 label | 632-665 | examples/huadian_classics/reason_builder.py（中文版本）|
| `_format_rule_evidence` 中文 label | 1033-1065 | 同上（i18n 框架接受 reason_builder plugin）|
| "T-P0-029" / "ADR-010" / 华典 ADR ID 注释 | 多处 | cleanup 时改为通用注释 |

**抽象路径总结**：

```
resolve.py 1065 行 → framework/identity-resolver/ 4 个文件:
  - union_find.py            (~80 行)
  - r6_seed_match.py 一部分   (~30 行：R6PrePassResult + _detect_r6_merges 一段)
  - resolve.py               (~400 行：主流程 + protocol 注入点)
  - apply_merges.py          (~250 行：主流程 + Protocol 接口)
  - dry_run_report.py        (~150 行：i18n-aware 框架；reason_builder plugin)
+ examples/huadian_classics/:
  - person_loader.py         (~80 行：华典 PostgreSQL 实现)
  - r6_prepass_adapter.py    (~80 行：seed_mappings / dictionary_entries SQL)
  - merge_applier.py         (~150 行：persons / person_merge_log / pending_merge_reviews / identity_hypotheses 写入)
  - reason_builder_zh.py     (~80 行：中文 reason / format_rule_evidence)
```

**预估**：~960 行抽出（vs 原 1065 行）/ 含 ~590 行 examples / 60-90 分钟

---

### 2.3 `resolve_rules.py` (614 行) — 🟡 接口无关 / 字典 + 中文模式 plugin

**领域无关段（直接抽出）**：

| 段 | 行 | 抽象路径 |
|---|---|---------|
| `PersonSnapshot` class | 149-202 | → `framework/identity-resolver/entity.py`（重命名 `EntitySnapshot` + alias `PersonSnapshot = EntitySnapshot` 向后兼容）|
| `score_pair()` dispatch | 601-614 | → `framework/identity-resolver/rules.py` 主入口 |
| `_RULE_ORDER` / `MERGE_CONFIDENCE_THRESHOLD` | 561-566 | 同上 |

**接口无关 + 实现专属（plugin 化）**：

| R 规则 | 行 | 算法 vs 实现 | plugin 化 |
|--------|---|-----------|----------|
| `_rule_r1` | 226-273 | 算法无关（surface overlap + 单字 guard）；`_R1_STOP_WORDS`（"王"/"帝"/"武王" 等中文）实现专属 | `StopWordPlugin` Protocol（案例方注入领域 stop words）|
| `_rule_r2` | 276-318 | 算法 = 帝X 前缀模式 — **完全华典专属**（"帝" 字符）| **整规则 → optional plugin**（`PrefixHonorificRule`），案例方决定是否启用 |
| `_rule_r3` | 321-373 | 算法无关（dictionary lookup + char substitution）；tongjia 字典内容专属 | `DictionaryLoader` Protocol（案例方注入字典）|
| `_rule_r4` | 442-469 | 算法无关 + `_IDENTITY_NOTES_PATTERNS`（"与X同人"等中文 regex）实现专属 | `IdentityNotesPatterns` Protocol |
| `_rule_r5` | 376-416 | 算法无关（双向 alias dictionary）；miaohao 字典专属 | `DictionaryLoader` Protocol（同 R3）|

**案例专属（reference impl）**：

| 段 | 行 | examples/ 目标 |
|---|---|---------------|
| `_R1_STOP_WORDS` | 211-223 | examples/huadian_classics/r1_stop_words.py |
| `_build_tongjia_index` / `_build_miaohao_index` / `ensure_dicts_loaded` | 75-141 | examples/huadian_classics/dictionary_loaders.py |
| `_TONGJIA_PATH` / `_MIAOHAO_PATH` | 46-47 | 同上（路径硬编码 `data/dictionaries/`）|
| `HONORIFIC_SHI_WHITELIST` | 478-494 | examples/huadian_classics/non_person_classifier.py |
| `_KNOWN_NON_PERSON_NAMES` | 497-508 | 同上 |
| `is_likely_non_person` | 511-554 | 同上（算法无关但内容华典专属）|
| `_IDENTITY_NOTES_PATTERNS` | 420-426 | examples/huadian_classics/identity_notes_patterns.py |
| `is_di_honorific` / `has_di_prefix_peer` | 569-598 | examples/huadian_classics/di_honorific_hint.py |

**plugin 协议设计**（关键 — Sprint N 设计核心）：

```python
# framework/identity-resolver/rules_protocols.py

from typing import Protocol

class DictionaryLoader(Protocol):
    """Plugin for R3 (variant char) + R5 (alias) dictionaries."""
    def load_synonym_dict(self) -> dict[str, str]:
        """Variant → canonical char mapping (R3)."""
        ...
    def load_alias_dict(self) -> dict[tuple[str, str], dict]:
        """Bidirectional alias pair → entry mapping (R5)."""
        ...

class StopWordPlugin(Protocol):
    """Plugin for R1 stop words (ambiguous generic terms)."""
    def get_stop_words(self) -> frozenset[str]: ...

class IdentityNotesPatterns(Protocol):
    """Plugin for R4 identity_notes regex patterns."""
    def get_patterns(self) -> list[re.Pattern]: ...

class CanonicalHint(Protocol):
    """Plugin for select_canonical() to add domain-specific demotion logic."""
    def should_demote(self, p: EntitySnapshot, group: list[EntitySnapshot]) -> bool: ...
```

**预估**：~614 行 → ~250 行 framework + ~250 行 examples / 60-90 分钟

---

### 2.4 `r6_seed_match.py` (156 行) — 🟡 接口无关 / SQL 专属

**领域无关段**：

| 段 | 行 | 抽象路径 |
|---|---|---------|
| `R6Status` enum | 23-29 | → `framework/identity-resolver/r6_seed_match.py`（直接抽）|
| `R6Result` dataclass | 32-42 | 同上 |
| `r6_seed_match()` function 算法 | 45-156 | 接口抽出 + SQL 由 Adapter 注入 |

**接口无关 + 实现专属**：

整个 `r6_seed_match` 函数体的 SQL 是华典专属（`seed_mappings` / `dictionary_entries` / `dictionary_sources` 三表 JOIN）。

**plugin 化设计**：

```python
# framework/identity-resolver/r6_seed_match.py

class SeedMatchAdapter(Protocol):
    """Plugin for R6 seed-match DB queries (DB-agnostic)."""
    async def lookup_by_id(
        self,
        external_id: str,
        source_name: str,
        confidence_cutoff: float,
    ) -> R6Result: ...

    async def lookup_by_name(
        self,
        candidate_name: str,
        confidence_cutoff: float,
    ) -> R6Result: ...

async def r6_seed_match(
    adapter: SeedMatchAdapter,
    *,
    candidate_name: str,
    candidate_qid: str | None = None,
    dictionary_source: str = "wikidata",  # 默认；案例方可改
    confidence_cutoff: float = 0.80,
) -> R6Result:
    """领域无关入口；SQL 由 adapter 实现。"""
    if candidate_qid:
        return await adapter.lookup_by_id(candidate_qid, dictionary_source, confidence_cutoff)
    return await adapter.lookup_by_name(candidate_name, confidence_cutoff)
```

**examples/huadian_classics/r6_seed_match_adapter.py** 实现 PostgreSQL 版本（复制现有 SQL）。

**预估**：~156 行 → ~80 行 framework + ~80 行 examples / 30-40 分钟

---

### 2.5 `r6_temporal_guards.py` (273 行) — 🟡 GuardChain 协议无关 / cross_dynasty 实现专属

**领域无关段（GuardChain 核心协议）**：

| 段 | 行 | 抽象路径 |
|---|---|---------|
| `GuardResult` dataclass | 139-150 | → `framework/identity-resolver/guards.py`（核心数据契约）|
| `evaluate_pair_guards` dispatch | 249-273 | 同上（GuardChain 协议核心）|
| `GUARD_CHAINS` 全局变量结构 | 173-181 | 同上（dict[rule_name, list[GuardFn]] 协议）|

**案例 reference impl（整文件抽到 examples/）**：

| 段 | 行 | examples/ 目标 |
|---|---|---------------|
| `DynastyPeriod` class | 56-64 | examples/huadian_classics/dynasty_guard.py |
| `_load_dynasty_periods` / `_DYNASTY_PERIODS_PATH` | 52-114 | 同上 |
| `cross_dynasty_guard` function | 184-241 | 同上（华典专属 — dynasty midpoint 算法）|
| `GUARD_THRESHOLDS` 具体值 R1=200 / R6=500 | 164-167 | examples/huadian_classics/guard_chains.py（华典 reference）|

**plugin 化设计**：

```python
# framework/identity-resolver/guards.py

from typing import Callable, Protocol
from .entity import EntitySnapshot

GuardFn = Callable[[EntitySnapshot, EntitySnapshot], "GuardResult | None"]

@dataclass(frozen=True, slots=True)
class GuardResult:
    """Outcome of a single guard evaluation."""
    guard_type: str
    blocked: bool
    reason: str
    payload: dict[str, Any]

def evaluate_pair_guards(
    person_a: EntitySnapshot,
    person_b: EntitySnapshot,
    *,
    rule: str,
    guard_chains: dict[str, list[GuardFn]],  # 注入参数 / 不再 module-level globals
) -> GuardResult | None:
    """Rule-aware guard chain dispatch.

    case-domain side passes their own guard_chains dict.
    """
    for guard_fn in guard_chains.get(rule, []):
        result = guard_fn(person_a, person_b)
        if result is not None and result.blocked:
            return result
    return None
```

**examples/huadian_classics/guard_chains.py**:

```python
HUADIAN_GUARD_CHAINS: dict[str, list[GuardFn]] = {
    "R1": [
        lambda a, b: cross_dynasty_guard(a, b, threshold_years=200),
        state_prefix_guard,
    ],
    "R6": [
        lambda a, b: cross_dynasty_guard(a, b, threshold_years=500),
    ],
}
```

**预估**：~273 行 → ~80 行 framework + ~200 行 examples / 30-40 分钟

---

### 2.6 `state_prefix_guard.py` (191 行) — 🔴 完全华典专属

整文件直接抽到 `examples/huadian_classics/state_prefix_guard.py`，零修改。这是 framework/ 的"非目标"——案例方应自己写自己的领域 guard（参见 cross-domain-mapping.md）。

但**作为 reference impl 极有价值**：展示了"如何写一个领域专属 guard"——

- 加载 yaml 字典（states.yaml）
- 用 regex 模式匹配（state-shihao-title pattern）
- 跨别名归一（"唐"→"晋"）
- 返回 GuardResult

跨领域案例方可以模仿这个 pattern 写自己的 domain guard。

**预估**：~191 行 → 整体抽到 examples/ / 5-10 分钟（基本是 cp）

---

## 3. Plugin 注入点总表（关键设计 — Sprint N 核心抽象产出）

设计 7 个 Plugin Protocol，覆盖 R1-R6 + canonical 选择 + DB 层 + reason 生成：

| # | Plugin Protocol | 用途 | R 规则 | 是否必需 |
|---|----------------|-----|-------|---------|
| 1 | `DictionaryLoader` | R3 + R5 字典加载 | R3, R5 | optional（不注入则 R3/R5 不触发）|
| 2 | `StopWordPlugin` | R1 stop words | R1 | optional（不注入则无 stop words 过滤）|
| 3 | `IdentityNotesPatterns` | R4 regex patterns | R4 | optional（不注入则 R4 不触发）|
| 4 | `CanonicalHint` | select_canonical 领域 demotion | canonical 选择 | optional |
| 5 | `PersonLoader` | DB 加载 entities | 整流程 | **required**（无替代）|
| 6 | `SeedMatchAdapter` | R6 SQL queries | R6 | optional（不注入则 R6 不触发）|
| 7 | `MergeApplier` | apply_merges DB writes | apply 阶段 | **required**（如要 apply）|

**关键设计原则**：

- **GuardChain 不是 Plugin，是参数**：`guard_chains: dict[str, list[GuardFn]]` 由案例方在 resolve_identities() 调用时传入（最灵活）
- **R 规则不是 Plugin**：R1-R5 是 framework 内置算法，案例方通过 plugin 注入数据让规则触发或不触发；R2 是个例外（华典帝X 模式）—— 作为 optional rule，案例方决定是否启用
- **PersonLoader / MergeApplier 是 required**：DB 层完全领域专属，case 方必须实现

---

## 4. framework/identity-resolver/ 目录结构（最终版）

基于 §1-§3 设计，目录结构 + 每文件预估：

```
framework/identity-resolver/
  README.md                          ~150 行  | 8 段，与 sprint-templates/role-templates 同款
  CONCEPTS.md                        ~250 行  | R1-R6 / GuardChain / Decision / Plugin 概念
  cross-domain-mapping.md            ~150 行  | 6 领域 R1-R6 适配（继承 role-templates 同款）

  types.py                           ~95 行   | MatchResult / MergeProposal / etc 数据契约
  entity.py                          ~70 行   | EntitySnapshot (= PersonSnapshot alias)
  union_find.py                      ~80 行   | 标准算法
  utils.py                           ~30 行   | _swap_ab_payload 等

  rules.py                           ~250 行  | R1-R5 算法骨架 + dispatch
  rules_protocols.py                 ~80 行   | DictionaryLoader / StopWordPlugin / etc Protocol

  guards.py                          ~80 行   | GuardFn / GuardResult / evaluate_pair_guards

  canonical.py                       ~80 行   | select_canonical + CanonicalHint Protocol

  r6_seed_match.py                   ~80 行   | R6 算法 + SeedMatchAdapter Protocol

  resolve.py                         ~400 行  | 主流程 orchestration（DB-agnostic）
  apply_merges.py                    ~250 行  | apply 主流程 + MergeApplier Protocol

  dry_run_report.py                  ~150 行  | i18n-aware 报告 + reason_builder plugin

  examples/
    huadian_classics/
      __init__.py                    ~30 行
      dictionary_loaders.py          ~120 行  | tongjia + miaohao yaml
      r1_stop_words.py               ~30 行   | 华典 stop words
      identity_notes_patterns.py     ~30 行   | 中文 regex
      di_honorific_hint.py           ~50 行   | 帝X demotion (CanonicalHint impl)
      non_person_classifier.py       ~80 行   | HONORIFIC_SHI / 神农氏 / etc
      dynasty_guard.py               ~150 行  | cross_dynasty_guard + DynastyPeriod
      state_prefix_guard.py          ~190 行  | 整文件直接复制
      guard_chains.py                ~30 行   | HUADIAN_GUARD_CHAINS dict
      person_loader.py               ~100 行  | huadian PostgreSQL adapter
      seed_match_adapter.py          ~80 行   | huadian seed_mappings adapter
      merge_applier.py               ~180 行  | huadian persons/person_merge_log/etc writes
      reason_builder_zh.py           ~80 行   | 中文 reason 生成
      r2_di_prefix_rule.py           ~60 行   | R2 帝X 规则（华典 optional rule）
```

**统计**：

| 类型 | 文件数 | 行数 |
|------|-------|------|
| Framework core (Python) | 12 | ~1645 |
| Framework docs | 3 | ~550 |
| Examples (huadian_classics) | 14 | ~1210 |
| **合计** | **29** | **~3405** |

→ 比 brief §2.1.1 的预估（13-15 文件 / 1800-2500 行）增加 ~50%——主要是 examples/huadian_classics 比预想更大（14 文件 vs 预估 5-6 文件）。

**与 brief §4 Stop Rule #8 比对**：framework core ~1645 行 < 3000 行阈值 ✅；如果计入 examples 为 ~3400 行 > 3000 但因为 examples 是 reference impl 不计入"抽象代码量"，仍合规。

---

## 5. 起草顺序（基于依赖关系 + 抽象优先级）

### 5.1 第一批（先抽，无依赖 / 数据契约 / 1-1.5 小时）

按拓扑顺序：

1. `types.py`（无依赖）
2. `entity.py`（依赖 types）
3. `union_find.py`（无依赖）
4. `utils.py`（无依赖）
5. `guards.py`（依赖 entity）
6. `rules_protocols.py`（依赖 entity）

**Gate**：上述 6 个文件可独立 `python -c "import ..."` 不报错。

### 5.2 第二批（核心算法 / 1.5-2 小时）

7. `r6_seed_match.py`（依赖 entity / 1 个 Protocol 注入）
8. `rules.py`（依赖 entity / rules_protocols / utils）
9. `canonical.py`（依赖 entity / 1 个 Protocol）
10. `dry_run_report.py`（依赖 types / 1 个 reason_builder plugin）

**Gate**：每个文件可独立 import + 通过 type checker（mypy --strict）。

### 5.3 第三批（主流程 / 1-1.5 小时）

11. `resolve.py`（依赖几乎所有上述模块 + DB Adapter Protocol）
12. `apply_merges.py`（依赖 types / MergeApplier Protocol）

**Gate**：framework core 完整闭包；可 import + 类型检查 + 简单 dry-run（用 mock adapter）。

### 5.4 第四批（华典 reference impl / 1.5-2 小时）

13-26. examples/huadian_classics/ 14 文件（按依赖关系）

**Gate**：huadian_classics 可与 framework core 协作 import 不报错。

### 5.5 第五批（文档 / 30-40 分钟）

27. `CONCEPTS.md`
28. `cross-domain-mapping.md`
29. `README.md`

### 5.6 Stage 1.13 dogfood byte-identical 验证（关键 / 30-60 分钟 / 含 PE 子 session）

**任务**：

1. 写 `examples/huadian_classics/test_byte_identical.py` 脚本：
   - 跑 services/pipeline/src/huadian_pipeline/resolve.py 的 resolve_identities()
   - 跑 framework/identity-resolver/resolve.py + huadian_classics adapters
   - 比对 ResolveResult 各字段（**除 run_id**：UUID 随机；其余 merge_groups / hypotheses / blocked_merges / r6_distribution / total_persons 完全一致）
2. PE 子 session（Sonnet 4.6）跑两次 dry-run + 输出 diff 报告
3. 输出 `stage-1-dogfood-2026-04-30.md`

**Gate 1.13（critical）**：

- 两份 dry-run 结果 **byte-identical**（除 run_id）
- 如有任何差异 → Stop Rule #1 触发

---

## 6. 工作量预估更新（vs brief §8）

| 任务 | brief 预估 | inventory 后预估 |
|------|----------|-----------------|
| Stage 0 inventory | 30-40 分钟 | ✅ 已完成（约 25 分钟实际）|
| Stage 1 第一批（数据契约 / 6 文件）| — | ~1-1.5 小时 |
| Stage 1 第二批（核心算法 / 4 文件）| — | ~1.5-2 小时 |
| Stage 1 第三批（主流程 / 2 文件）| — | ~1-1.5 小时 |
| Stage 1 第四批（examples / 14 文件）| — | ~1.5-2 小时 |
| Stage 1 第五批（文档 / 3 文件）| — | ~30-40 分钟 |
| Stage 1.13 dogfood byte-identical | — | ~30-60 分钟（含 PE 子 session）|
| Stage 4 closeout + retro | — | ~30-40 分钟 |
| **合计** | 2-3 会话 | **~6-8.5 小时纯起草工作** |

→ 单会话极致压缩可完成，但容易疲劳；舒缓 2-3 会话更合适。

**对比 Sprint L+M 实际**：L+M 都是 1 会话内压缩完成（~5-6 小时）。Sprint N 工作量比 L+M 大约 30-40%（~6.5 vs ~5），但质量风险更高（byte-identical 验证）。建议 **2 会话节奏**：

- 会话 1：Stage 0 inventory（已完成）+ Stage 1 第一+二+三批（framework core 12 文件 / ~3.5-5 小时）
- 会话 2：Stage 1 第四+五批（examples + 文档 / ~2-2.5 小时）+ Stage 1.13 dogfood + Stage 4 closeout / retro（~1.5-2 小时）

---

## 7. ADR 触发评估

依据 brief Stop Rule #7（"触发新 ADR ≥ 2 个 → Stop"）：

**当前评估**：Sprint N 设计中**最多触发 1 个 ADR**：

- **ADR-031 候选**：framework Plugin 注入协议（DictionaryLoader / GuardFn / etc 7 个 Protocol 的统一约定 — 是否需要正式 ADR 化？）

**评估结论**：**目前不必触发 ADR-031**。理由：

- 7 个 Plugin Protocol 都遵循 PEP 544 Python `typing.Protocol` 标准模式，无 framework 特定约定
- 如未来跨领域案例方反馈"Plugin 协议设计有问题"，再触发 ADR-031（per Sprint M retro §3.3）
- ADR-030 framework styleguide 也继续延后（与 Sprint M 同结论）

**Stop Rule #7 不触发**。

---

## 8. plugin Protocol 7 项统一设计原则

为保证 plugin 设计一致 + 案例方易于 instantiate，所有 7 个 Protocol 遵循：

1. **Python typing.Protocol**（PEP 544）— 鸭子类型，无强制继承
2. **method 名简洁**（load_xxx / get_xxx / lookup_xxx / should_xxx / build_xxx / etc）
3. **Protocol 不带状态**（`load_synonym_dict` 是 method，不是 property）
4. **Optional plugin 不注入时降级**（如 R3 字典 plugin 不注入 → R3 规则跳过 + log warning，不报错）
5. **Required plugin 不注入则报错**（PersonLoader / MergeApplier）
6. **Protocol 文档 example**：每个 Protocol 在 docstring 给一个 example impl 类参考
7. **examples/huadian_classics 给 8 个完整 reference impl** 作为 instantiation 范本

---

## 9. Gate 0 自检

- [x] 6 个 .py 文件全部深 read 完成
- [x] 各文件领域耦合等级标注完成（§2 详细标注）
- [x] Plugin 注入点 ≥ 3 个明确（实际设计 **7 个 Protocol**）
- [x] 抽象优先级表就位（§5 起草顺序）
- [x] 工作量预估更新（§6）
- [x] ADR 触发评估完成（§7 — 不触发）
- [x] framework/identity-resolver/ 完整目录结构 + 每文件预估行数（§4）

→ Stage 0 完成 / Stage 1 unblock。

---

## 10. 已就绪信号

```
✅ Sprint N Stage 0 inventory 完成
- 6 个 .py 文件 / 2394 行全部扫描完成
- 50% 完全无关 / 30% 接口无关+实现专属 / 20% 案例 reference
- 设计 7 个 Plugin Protocol（DictionaryLoader / StopWordPlugin / IdentityNotesPatterns / CanonicalHint / PersonLoader / SeedMatchAdapter / MergeApplier）
- framework/identity-resolver/ 候选目录：29 文件 / ~3400 行（含 examples）/ framework core ~1645 行
- 起草顺序 5 批（数据契约 → 核心算法 → 主流程 → examples → 文档）+ Stage 1.13 dogfood
- ADR 触发评估：不触发（Stop Rule #7 安全）
- 工作量预估：~6-8.5 小时 / 推荐 2 会话节奏
→ Stage 1 起草 unblock
```

---

**本 inventory 起草于 2026-04-30 / Sprint N Stage 0**
