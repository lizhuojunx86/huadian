# framework/identity_resolver — Identity Resolution Framework

> Status: **v0.2.0 (Sprint P release / 2026-04-30)**
> First abstraction: Sprint N Stage 1, 2026-04-30
> Date: 2026-04-30
> License: Apache 2.0 (代码) / CC BY 4.0 (文档)
> Source: 华典智谱 `services/pipeline/src/huadian_pipeline/resolve*.py` 抽象 (Sprint N)

---

## 0. 这是什么

一个**领域无关**的 entity identity resolution 框架，让任何 KE（Knowledge Engineering）项目可以复用华典智谱 Sprint A-K 实证的 R1-R6 规则系统 + GuardChain + Union-Find 主流程，跨章 / 跨文档识别"同一个实体" 并 soft-merge。

**核心信念**（与 framework/sprint-templates + framework/role-templates 一脉相承）：

- **算法领域无关**：Surface match / synonym normalization / alias dictionary / external anchor 等是通用 KE 模式，不是古籍专属
- **数据领域专属**：字典内容 / domain attribute（dynasty / jurisdiction / drug class / etc）/ DB schema 是案例方的事
- **plugin 注入而非继承**：用 PEP 544 `typing.Protocol` 把"领域无关算法"和"领域专属数据"清晰隔离

---

## 1. 何时用这套框架

✅ **适合**：

- 任何需要"跨章 / 跨文档 / 跨数据源识别同一实体"的 KE 项目
- 实体可以是：人 / 事件 / 地点 / 法律案件 / 药品 / 专利 / etc
- 已有结构化数据 + 至少一种"识别信号"（surface form / external anchor / etc）

❌ **不适合**：

- 单文档实体识别（用 LLM-based NER 即可，不需要框架）
- 完全无结构数据（先做 NER 抽出实体，再用本框架 resolve）
- 1-on-1 entity matching / record linkage（用专门的 record linkage 库）
- 实时 / 流式 entity resolution（本框架是 batch 设计）

---

## 2. 文件清单

```
framework/identity_resolver/
  __init__.py                        — 30+ exports，统一入口
  types.py                           — MatchResult / MergeProposal / etc 数据契约
  entity.py                          — EntitySnapshot (= PersonSnapshot alias)
  union_find.py                      — UnionFind 数据结构（标准算法）
  utils.py                           — swap_ab_payload 等
  guards.py                          — GuardChain 协议 + GuardResult + dispatcher
  rules_protocols.py                 — 4 个 plugin Protocol
  r6_seed_match.py                   — R6 算法 + SeedMatchAdapter Protocol
  rules.py                           — R1-R5 算法骨架 + ScorePairContext
  canonical.py                       — select_canonical + CanonicalHint
  dry_run_report.py                  — i18n-aware 报告 + ReasonBuilder
  resolve.py                         — 主流程（EntityLoader + R6PrePassRunner）
  apply_merges.py                    — apply 主流程 + MergeApplier
  examples/huadian_classics/         — 华典 reference impl（14 文件）
  README.md                          — 本文件
  CONCEPTS.md                        — R1-R6 / GuardChain / Decision 核心概念
  cross-domain-mapping.md            — 6 领域 R1-R6 instantiation 速查
```

---

## 3. 5 分钟快速上手

### Step 1: 复制框架到你的项目

```bash
# 选项 A: 整个仓库 fork / clone
git clone https://github.com/lizhuojunx86/huadian.git
# → 直接 import: from huadian.framework.identity_resolver import ...

# 选项 B: 复制框架核心到你自己的项目
cp -r huadian/framework/identity_resolver /path/to/your-project/your_pkg/
```

### Step 2: 实现 EntityLoader（必需）

```python
# your_project/adapters/loader.py
from framework.identity_resolver import EntitySnapshot

class MyLoader:  # implements EntityLoader Protocol
    async def load_all(self) -> list[EntitySnapshot]:
        # 从你的 DB / API / 文件源加载
        rows = await my_db.fetch("SELECT id, name, slug, attrs FROM entities")
        return [
            EntitySnapshot(
                id=r["id"], name=r["name"], slug=r["slug"],
                surface_forms={r["name"]} | set(r.get("aliases", [])),
                created_at=r["created_at"].isoformat(),
                domain_attrs={"jurisdiction": r["attrs"].get("jurisdiction", "")},
            )
            for r in rows
        ]
```

### Step 3: 实现 MergeApplier（apply 必需）

```python
# your_project/adapters/applier.py
from framework.identity_resolver import BlockedMerge, HypothesisProposal

class MyApplier:  # implements MergeApplier Protocol
    async def soft_delete_and_link(self, merged_id: str, canonical_id: str): ...
    async def demote_primary_names(self, merged_id: str) -> int: ...
    async def write_merge_log(self, *, run_id, canonical_id, merged_id, ...): ...
    async def write_hypothesis(self, hyp: HypothesisProposal): ...
    async def write_blocked_review(self, item: BlockedMerge): ...
```

### Step 4: 跑 dry-run

```python
from framework.identity_resolver import (
    build_score_pair_context,
    resolve_identities,
    generate_dry_run_report,
)

# 可选：注入 R3+R5 字典 / R1 stop words / R4 patterns
ctx = build_score_pair_context(
    dictionary_loader=MyDictLoader(),
    stop_word_plugin=MyStopWords(),
    cross_dynasty_attr="jurisdiction",  # or "dynasty" for HuaDian classics
)

# 可选：注入 GuardChain
my_guards = {
    "R1": [my_jurisdiction_guard],
    "R6": [my_temporal_guard],
}

result = await resolve_identities(
    loader=MyLoader(pool),
    score_context=ctx,
    guard_chains=my_guards,
)

print(generate_dry_run_report(result))
```

### Step 5: Apply（dry_run 通过后）

```python
from framework.identity_resolver import apply_merges

async with pool.acquire() as conn, conn.transaction():
    applier = MyApplier.with_connection(conn)
    summary = await apply_merges(applier=applier, result=result, dry_run=False)
    print(summary)
```

完整 reference impl 见 `examples/huadian_classics/`。

---

## 4. 跨领域使用指南

### 4.1 必须 instantiate 的字段

每个 plugin Protocol 是 Python `typing.Protocol`（鸭子类型）— 不需要继承基类，只需实现 method。

最小可用配置（仅 R1 surface match）：

```python
ctx = build_score_pair_context()  # 全部默认值
result = await resolve_identities(loader=MyLoader(), score_context=ctx)
```

完整配置（所有规则 + 所有 guards）：

```python
ctx = build_score_pair_context(
    dictionary_loader=MyDictLoader(),
    stop_word_plugin=MyStopWords(),
    notes_patterns_plugin=MyPatterns(),
    cross_dynasty_attr="jurisdiction",
    custom_rules=[my_r2_equivalent],
)
result = await resolve_identities(
    loader=MyLoader(),
    score_context=ctx,
    guard_chains=MY_GUARD_CHAINS,
    r6_prepass=MyR6Runner(),
    canonical_hint=MyHint(),
    reason_builder=MyChineseReasonBuilder(),
)
```

### 4.2 跨领域字段 mapping 速查

| 字段 | 古籍（华典）| 法律 | 医疗 | 专利 |
|------|-----------|------|------|------|
| `EntitySnapshot.name` | "刘邦" | "Brown v. Board" | "acetaminophen" | "US Patent 4,xxx,xxx" |
| `domain_attrs["dynasty"]` | "西汉" | `["jurisdiction"]` = "SCOTUS" | `["drug_class"]` = "analgesic" | `["filing_year"]` = "1995" |
| R3 字典 | tongjia.yaml（异体字）| citation-variants.yaml | drug-aliases.yaml | patent-class-variants.yaml |
| R5 字典 | miaohao.yaml（庙号谥号）| case-aliases.yaml | drug-synonyms.yaml | inventor-aliases.yaml |
| R6 external_id | Wikidata Q-ID | LexisNexis case ID | RxNorm CUI | USPTO patent number |
| R1 stop words | "王" / "帝" | "court" / "plaintiff" | "patient" / "ICU" | "method" / "device" |
| Guard chain | dynasty + state_prefix | jurisdiction + court_level | drug_class + dose | classification + filing_year |

详见 `cross-domain-mapping.md`。

### 4.3 Plugin 注入门槛

| Plugin | 必需？ | 不实现的后果 |
|--------|------|-------------|
| `EntityLoader` | **必需** | resolve 无法启动 |
| `MergeApplier` | apply 必需 | dry-run 仍可用，apply 报错 |
| `DictionaryLoader` | optional | R3 + R5 silently skip |
| `StopWordPlugin` | optional | R1 不过滤 stop words |
| `IdentityNotesPatterns` | optional | R4 silently skip |
| `CanonicalHint` | optional | canonical 用默认 4-rule 顺序 |
| `SeedMatchAdapter` | R6 必需 | R6 不启用 |
| `R6PrePassRunner` | R6 必需 | R6 不启用 |
| `ReasonBuilder` | optional | 用 `DefaultReasonBuilder`（英文）|

---

## 5. 设计哲学

### 5.1 算法 vs 数据的分离

R1-R5 的**算法核心**（surface overlap / dictionary lookup / regex match / etc）领域无关；**数据**（具体的字典 / regex / stop words / etc）领域专属。

抽象边界 = 算法 / 数据界线。框架提供算法骨架 + Protocol 接口，案例方提供数据。

### 5.2 GuardChain 不是 Plugin 是参数

`guard_chains: dict[rule_name, list[GuardFn]]` 是 `resolve_identities()` 的参数，不是 module-level singleton。这让案例方：

- 一个项目里跑多种 guard 配置（experimentation）
- 跨领域不会污染 framework 状态
- 测试时容易 mock

### 5.3 R 规则不是 Plugin 是内置 + custom_rules 扩展

R1-R5 是 framework 内置 — 案例方通过 plugin 注入数据让规则触发或跳过。HuaDian-specific 的 R2（帝X 前缀）不在内置序列里，作为 `custom_rules` opt-in。

### 5.4 person → entity 命名通用化

原 huadian_pipeline 用 "person" 命名（PersonSnapshot / persons / person_merge_log）。框架统一用 "entity"（EntitySnapshot / merge_proposals / merge_log）。`PersonSnapshot = EntitySnapshot` alias 保留向后兼容。

### 5.5 byte-identical dogfood 验证

framework abstraction 的正确性证明 = 与原 services/pipeline 输出 byte-identical（除 run_id UUID）。Sprint N Stage 1.13 的 dogfood gate 就是这个 — 任何差异 → Stop。

---

## 6. 反模式（不要这么做）

- ❌ **不要直接修改 framework/identity_resolver/ 用于自己案例** — fork / cp 到自己项目，改 `examples/your_domain/`
- ❌ **不要把领域专属逻辑塞进 framework core** — 走 plugin 注入
- ❌ **不要让 GuardChain 成为 module-level globals** — 用参数传递
- ❌ **不要直接 import services/pipeline/src/huadian_pipeline/** — framework 才是抽象层 / huadian_pipeline 是具体实现
- ❌ **不要跳过 byte-identical dogfood** — 抽象正确性必须验证

---

## 7. 反馈与贡献

本框架从华典智谱 Sprint A-K 实证 + Sprint N abstraction 抽出，是 v0.1 状态。预期会随更多案例（包括跨领域）反馈而迭代。

如果你用本框架做了你的项目，欢迎：

- **报告使用经验**（GitHub Issue 标 `identity-resolver-feedback`）
- **指出遗漏 / 不清楚的地方**（GitHub Issue 标 `identity-resolver-gap`）
- **贡献跨领域 instantiation 范例**（GitHub PR 加 `examples/your_domain/`）

详见华典智谱主项目 [CONTRIBUTING.md](https://github.com/lizhuojunx86/huadian/blob/main/CONTRIBUTING.md)。

---

## 8. 版本信息

| Version | Date | Source | Change |
|---------|------|--------|--------|
| v0.1 | 2026-04-30 | Sprint N Stage 1 (first abstraction) | 初版抽出（13 framework core + 14 huadian_classics examples）|
| **v0.2.0** | **2026-04-30** | **Sprint P v0.2 release** | DGF-O-01 (P2): examples 4 处路径硬编码改 `HUADIAN_DATA_DIR` 环境变量优先 + `parents[4]` fallback；DGF-N-01: `test_byte_identical.compare()` 引入 `FIELD_ALIASES` 通用机制（替换 inline `dict.get` 链，便于跨 domain fork 扩展）；与 framework v0.2 release 同步发布 |

---

> 本框架是 AKE 框架 Layer 1 的**第三刀**（代码层第一刀）。
> 第一刀：framework/sprint-templates/（Sprint L）
> 第二刀：framework/role-templates/（Sprint M）
> 第三刀：framework/identity_resolver/（Sprint N）
> 当前完整 framework 目录：https://github.com/lizhuojunx86/huadian/tree/main/framework
