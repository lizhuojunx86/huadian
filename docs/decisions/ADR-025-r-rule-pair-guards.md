# ADR-025 — R Rule Pair Guards：通用 pair-level guard 接口

- **Status**: accepted
- **Date**: 2026-04-26
- **Accepted-Date**: 2026-04-26
- **Authors**: 管线工程师（起草，Opus 4.7）+ 首席架构师（签字 2026-04-26）
- **Related**:
  - ADR-010（Cross-Chunk Identity Resolution — R 规则引擎本体）
  - ADR-014（Canonical Merge Execution Model — names-stay）
  - ADR-022（NER 污染清理三要素 — 规则精化哲学先例）
  - ADR-023（V8 Prefix-Containment — α/β 豁免哲学先例）
  - T-P0-029（R6 cross-dynasty guard — `evaluate_guards` 首例）
  - T-P1-028（R1 dynasty 前置过滤 — 本 ADR 首个 R1 应用）
  - Sprint G T-P0-006-δ historian review（commit `fdfb7cb` — R1 跨国 FP 量化触发）

---

## 1. Context

### 1.1 触发

Sprint G T-P0-006-δ（项羽本纪）resolver dry-run 21 组 merge proposals 中 **13 组（62%）** 被 historian reject，其中 12 组属"R1 跨国同名 surface match" false positive（秦γ 已裁决残留）。Sprint H 联合 inventory（`docs/sprint-logs/sprint-h/inventory-2026-04-26.md`）量化数据：

- 项羽δ：13/21 = 62% R1 reject 涉跨 dynasty
- 秦γ：14/35 ≈ 40% R1 reject + split 涉跨 dynasty

R1 (`_rule_r1` resolve_rules.py:226) 现有 cross-dynasty guard 仅在 single-char overlap 场景生效（line 247-253），对多字短称（"桓公"/"灵公"/"怀王"等）完全不生效。每次新章节 ingest 后 historian 重复审核相同跨国 FP，工作量线性增长。

### 1.2 既有先例

T-P0-029（Sprint D）为 R6 引入 `evaluate_guards(a, b)` 接口（`r6_temporal_guards.py:216`），采用 β 模式：
- guard 命中 → 写 `pending_merge_reviews`（schema in migration 0012）
- guard 不命中 → 进 MergeProposal

resolve.py:346 `_detect_r6_merges` 已集成此模式。但 R1-R5 主循环（resolve.py:462）**没有任何 guard hook**。

### 1.3 缺口

需要一个**通用 pair-level guard 接口**：
- 支持按规则（R1/R6/未来 R2/R5）配置不同 threshold
- 支持未来扩展新 guard 维度（state-prefix / events-based / wikidata-attr-based 等）
- 与 R6 既有路径无缝兼容
- 单源真相（dynasty mapping 只能在 `dynasty-periods.yaml` 一处）

---

## 2. Decision

### 2.1 引入 `evaluate_pair_guards(a, b, *, rule)` 通用接口

替代当前 R6-only 的 `evaluate_guards(a, b)`：

```python
# r6_temporal_guards.py（候选重命名 → temporal_guards.py，但保留向后兼容包装）

GUARD_THRESHOLDS: dict[str, int] = {
    "R1": 200,   # T-P1-028（本 ADR 首应用）
    "R6": 500,   # T-P0-029 既有
}

def cross_dynasty_guard(
    a: PersonSnapshot,
    b: PersonSnapshot,
    *,
    threshold_years: int,
) -> GuardResult | None:
    """既有实现，threshold 参数化（默认 500 → 改为必传参数）"""
    ...

def evaluate_pair_guards(
    a: PersonSnapshot,
    b: PersonSnapshot,
    *,
    rule: str,
) -> GuardResult | None:
    """Rule-aware guard chain dispatch.

    threshold 按 rule 查 GUARD_THRESHOLDS；未注册的 rule 默认无 guard（fallback None）。
    """
    threshold = GUARD_THRESHOLDS.get(rule)
    if threshold is None:
        return None
    return cross_dynasty_guard(a, b, threshold_years=threshold)
```

### 2.2 阈值配置（R1=200，R6=500）

| 规则 | threshold (年) | 理由 |
|------|---------------|------|
| R1 | **200** | 弱证据（surface match）+ historian review 数据观察"跨春秋/战国 (275yr)"和"跨西周/春秋 (286yr)"应拦；楚怀王 case (战国↔秦末 138yr) 走 T-P0-031 数据修复路径 |
| R6 | 500 | 强证据（QID anchor）+ T-P0-029 已确定 |

**已知局限**（明确登记）：
- 200yr 阈值**不能拦** "春秋同朝代不同国" (gap=0) case（鲁桓公↔秦桓公 等）—— 占项羽δ FP 的 ~38%。该 case 类需扩展为 **state_prefix_guard**（识别 鲁/晋/齐/秦/楚 等国别前缀），登记为 Future Work。
- 200yr 阈值**不能拦** dynasty 字段缺映射的 case（秦末/秦末汉初/春秋战国/战国·秦/...）—— 静默 fallback 为不拦。Stage 2 实施前必须先补 `data/dynasty-periods.yaml` 9 个缺失映射。

### 2.3 R1 集成位置

`resolve.py:462` `resolve_identities()` 主循环改造（伪代码）：

```python
for i in range(len(persons)):
    for j in range(i + 1, len(persons)):
        a, b = persons[i], persons[j]
        match = score_pair(a, b)
        if match is None:
            continue

        # NEW (本 ADR): rule-aware guard
        guard = evaluate_pair_guards(a, b, rule=match.rule)
        if guard is not None and guard.blocked:
            # 与 R6 _detect_r6_merges 同一路径：写 BlockedMerge → pending_merge_reviews
            blocked_merges.append(BlockedMerge(
                person_a_id=..., person_b_id=...,
                proposed_rule=match.rule,
                guard_type=guard.guard_type,
                guard_payload=guard.payload,
                evidence=match.evidence,
            ))
            continue

        # existing logic: append merge_proposals or hyp_proposals
        ...
```

### 2.4 向后兼容

R6 既有调用点（resolve.py:346 `_detect_r6_merges`）调整为：
```python
# Before: guard_result = evaluate_guards(a, b)
# After:
guard_result = evaluate_pair_guards(a, b, rule="R6")
```

**保留** `evaluate_guards(a, b)` 作为 deprecated 包装（默认 `rule="R6"`），使 ADR 实施 PR 不破坏既有测试：

```python
def evaluate_guards(a, b) -> GuardResult | None:
    """[DEPRECATED] Use evaluate_pair_guards(a, b, rule='R6') instead."""
    warnings.warn("evaluate_guards is deprecated, use evaluate_pair_guards", DeprecationWarning)
    return evaluate_pair_guards(a, b, rule="R6")
```

**保留期**：包装在 **Sprint I 收口**前保留（**不在 Stage 2 末删除**）。理由：
- 第三方代码（如未来的 historian 工具脚本）可能依赖既有 `evaluate_guards` 签名；Sprint I 完整 grep audit 后再删可避免遗漏
- DeprecationWarning 持续输出 1 个 sprint 给上游 caller 充分迁移时间
- Sprint I 末段移除时同步去掉 §6.1 中"R6 既有调用点 grep"工作项

### 2.5 Pending Merge Reviews schema 复用

`pending_merge_reviews` (Sprint D migration 0012) 已支持本 ADR 全部需求：

```sql
person_a_id        uuid NOT NULL
person_b_id        uuid NOT NULL  -- with CHECK (person_a_id < person_b_id)
proposed_rule      text NOT NULL  -- 'R1' / 'R6' / 未来扩展
guard_type         text NOT NULL  -- 'cross_dynasty' / 未来 'state_prefix' / ...
guard_payload      jsonb NOT NULL
evidence           jsonb NOT NULL
status             text NOT NULL DEFAULT 'pending'
```

**不需 schema 改动**。

### 2.6 单元测试要求（最小集 ≥ 5）

per architect brief §3 §2.4：
1. R1 + cross_dynasty guard 命中（构造跨 dynasty 同 surface 案例 + R1 命中 → blocked）
2. R1 + cross_dynasty guard 不命中（同 dynasty 同 surface → 继续走 R1 → MergeProposal）
3. R6 + cross_dynasty guard 阈值差异验证（500yr R6 通过 vs 200yr R1 拦截）
4. dynasty 字段缺映射时 fallback（无 GuardResult，不阻 R1）
5. V11 invariant 回归（不变量不被新 guard 影响）
6. （加分）R6 既有路径回归（`evaluate_guards` → `evaluate_pair_guards(rule="R6")` 行为一致）

---

## 3. Rationale

### 3.1 为何不沿用 α (R1 内嵌 short-circuit)

α 短期改动小（~10 行），但：
1. 被拦 pair 不写 `pending_merge_reviews` → 审计断链
2. R6 已用 β 模式，α 引入双 path（R6 走 BlockedMerge / R1 走静默丢弃），破坏代码一致性
3. R2/R5 未来加 guard 时需重复粘贴 → 反 DRY

### 3.2 为何不沿用 γ (post-filter)

γ 在 R 规则输出后再过滤：
1. R6 已用 β 模式，γ 后置 filter 与 R6 路径分裂
2. MergeProposal 已构造再丢弃 → 调试时难追溯（vs β 在 score 之前 short-circuit + 写审计）
3. 信息流不自然（β：score → guard → propose；γ：score → propose → filter → propose'）

### 3.3 为何 rule-aware threshold 而非全局 threshold

不同规则证据强度差异显著：
- R6 (QID anchor) confidence=1.0 → 仅极端跨代（500yr+）才拦
- R1 (surface match) confidence=0.95 → 中等跨代（200yr+）即拦
- 未来 R2 (帝X prefix) confidence=0.93 → 可能介于 R1/R6 之间

全局 threshold 必然在某规则上过严或过松。

### 3.4 与 ADR-022/023 哲学的一致性

| 维度 | ADR-022 | ADR-023 | **ADR-025** |
|------|---------|---------|------|
| 对象 | 硬 DELETE 决策 | V8 invariant | R 规则 guard 接口 |
| 共同哲学 | 规则精化（三要素 AND） | 规则精化（α/β 豁免 OR） | 规则精化（rule-aware threshold dispatch） |
| 数据源 | evidence 链客观信号 | evidence 链客观信号 | dynasty 字段客观信号（YAML mapping） |
| 时机 | 一次性清理 | 持续防御 | 持续防御 |

ADR-025 与 ADR-022/023 共同延续"客观信号驱动 + 规则精化优先"路线 —— **不冲突，可共存**。

---

## 4. Consequences

### 4.1 正面

- ✅ R1 历史 dry-run 拦截能力 36-50%（基于 Stage 0.5 数据测算），减少 historian 重复审核工作量
- ✅ R6 与 R1 共享同一 guard 基础设施（`pending_merge_reviews` + `dynasty-periods.yaml`）
- ✅ 未来 R2/R5 加 guard 仅需注册 `GUARD_THRESHOLDS[rule]`，零结构性改动
- ✅ 与 ADR-022/023"规则精化优先"路线一致
- ✅ 不需 schema 改动（`pending_merge_reviews` 已支持）

### 4.2 负面 / 需要接受

- ⚠️ **春秋同朝代不同国 (gap=0) 不可拦** —— 占项羽δ FP 的 ~38%。本 ADR 仅解决跨 dynasty 维度，需补 state_prefix_guard（Future Work §6）。
- ⚠️ **dynasty 字段缺映射的 ~15% persons 静默不评估**（秦末/秦末汉初/...）—— 必须在 Stage 2 实施前补全 `dynasty-periods.yaml`。否则韩信↔田荣 等 case 仍走 historian。
- ⚠️ 单元测试面积扩大（≥5 新测试 + R6 回归测试）
- ⚠️ V11 invariant 不受影响，但 V12 候选（cross-time entity-collision）将依赖类似机制 —— 与本 ADR 设计一致

### 4.3 回滚路径

- 删除 `evaluate_pair_guards` + 还原 `evaluate_guards` + 移除 R1 集成点 → 行为退回 T-P0-029 状态
- `pending_merge_reviews` 中由 R1 guard 写入的行通过 `proposed_rule='R1'` filter 软清理
- 无 schema 变更需回滚

---

## 5. Applied Examples

### 5.1 T-P1-028（本 ADR 首应用）

- **对象**：R1 surface match 之前增加 dynasty 前置过滤（threshold=200yr）
- **覆盖 case 示例**：
  - 周成王(西周 -909) ↔ 楚成王(春秋 -623) gap=286 → blocked ✅
  - 鲁桓公(春秋 -623) ↔ 秦桓公(春秋 -623) gap=0 → **not blocked**（已知局限） ⚠️
  - 韩信(西汉 -97) ↔ 田荣(秦末 缺映射) → guard 返回 None（已知局限） ⚠️
- **预期**：项羽δ 21 → ~14-16 组进 historian review；秦γ 35 → ~28-30 组

### 5.2 T-P0-029（先例引用）

- **对象**：R6 same-QID merge + cross_dynasty guard (threshold=500yr)
- **首应用结果**：bootstrap=0（截止 Sprint D 收口无 R6 跨代 case）
- **本 ADR 兼容**：通过 `evaluate_pair_guards(a, b, rule="R6")` 调用，行为不变

### 5.3 Sprint I 扩展：state_prefix_guard for R1（addendum status: **accepted** 2026-04-28）

> 本 §5.3 是 ADR-025 §6.2 显式承诺的中期 follow-up 落地，**不开新 ADR**。
> 整 ADR-025 status 保持 **accepted**；本 §5.3 单节状态 **proposed**，等架构师签字后转 accepted。
> 与 §5.1 / §5.2 平级，不改 §5.1 原文（ADR 不可变 convention）。
> 关联：Sprint I brief `docs/sprint-logs/sprint-i/stage-0-brief-2026-04-27.md` / Stage 0 inventory `docs/sprint-logs/sprint-i/inventory-2026-04-28.md`

#### 5.3.1 触发原因

Sprint H Stage 2 dry-run（commit `8501ab9`）验证 R1 dynasty_guard 拦截 8 对，落在原预测内（1.14× 单章上限）。但 §3 列举剩余未拦 R1 proposals 中 ~38% 是"春秋同朝代不同国"（gap=0）：

| 类型 | 示例 | gap | dynasty_guard | state_prefix_guard 设计目标 |
|------|------|----:|---------------|---------------------------|
| 跨朝代 | 周成王↔楚成王 | 286 | ✅ 拦 | ✅ 也拦（state≠） |
| 同朝代不同国 | 鲁桓公↔秦桓公 | 0 | ❌ 不拦 | **✅ 拦（state≠，核心目标）** |
| 同朝代不同国 | 晋悼公↔齐悼公 | 0 | ❌ 不拦 | **✅ 拦** |
| 同朝代不同国 | 晋平公↔齐平公 | 0 | ❌ 不拦 | **✅ 拦** |
| 同朝代同国 | 秦桓公↔秦桓公 | 0 | ❌ 不拦 | ❌ 不拦（state==，进 R1）✅ |

R1 跨国 FP 经 Sprint G→H→I 累计降至 ≤10%（架构师 Sprint J 跑后验证）— 是本 sprint 收口判定（brief §7）。

#### 5.3.2 guard 设计

**对象**：双方 surface 都匹配 `(state)(shihao)(ruler_title)` 模式且 state 不同时，blocked。

**guard 类型**：`state_prefix`（写入 `pending_merge_reviews.guard_type`，schema 已支持）。

**无年代阈值**：不同于 cross_dynasty_guard 的 200/500yr 数值阈值，state_prefix 是布尔识别（state==state 通过 / state≠state 拦截），**不引入新 threshold 配置项**。

**单方守护语义**：仅当**双方都匹配**时拦截；任一方不匹配模式（裸谥号 / 单字 surface / 无前缀）→ fall through 不阻 R1。理由：避免"鲁桓公↔桓公"被错拦，后者裸谥号无国名信息应进 historian review。

#### 5.3.3 GUARD_CHAIN 顺序

| Rule | Chain |
|------|-------|
| R1 | `cross_dynasty_guard(threshold=200)` → `state_prefix_guard` |
| R6 | `cross_dynasty_guard(threshold=500)`（**state_prefix 不挂**，详 §5.3.7） |

伪代码：

```python
GUARD_CHAINS: dict[str, list[Callable]] = {
    "R1": [
        lambda a, b: cross_dynasty_guard(a, b, threshold_years=200),
        lambda a, b: state_prefix_guard(a, b),
    ],
    "R6": [
        lambda a, b: cross_dynasty_guard(a, b, threshold_years=500),
    ],
}

def evaluate_pair_guards(a, b, *, rule):
    for guard in GUARD_CHAINS.get(rule, []):
        result = guard(a, b)
        if result is not None and result.blocked:
            return result    # 短路返回首个 blocking
    return None
```

**短路语义**：与既有 R6 路径一致，每 pair 只产生 1 行 `pending_merge_reviews`（首个 blocking guard）。triage UI 维护单一 `guard_type` 维度。**`resolve.py:480` R1 集成点零改动**——chain 实现完全封装在 `evaluate_pair_guards` 内部。

**顺序选定**：dynasty 在前（O(1) yaml dict lookup）+ state_prefix 在后（regex compile + match）。性能与 audit 都更友好。

#### 5.3.4 states.yaml schema 设计稿

新文件 `data/states.yaml`（仿 `dynasty-periods.yaml` 格式）：

```yaml
# Spring-Autumn / Warring-States 诸侯国名单 + 别名 / 异称。
# Used by: services/pipeline/src/huadian_pipeline/state_prefix_guard.py
# Task: T-P1-028 follow-up (Sprint I, ADR-025 §5.3)
#
# Convention:
#   - name: 主名（人名前缀使用的字符）
#   - aliases: 同国异称 / 古称（前缀 regex 字符集中视为等价）
#   - era: 春秋 / 战国 / 春秋战国（覆盖期，仅文档用，不参与 guard 判定）
#   - notes: 学术注解 / 来源
#
# Maintenance:
#   - 新国添加需要 historian ACK
#   - 双字国名（中山/鲜虞）暂不支持，待 backlog
#
# 17 国（per Sprint I Stage 0 inventory §2.2）：

states:
  - name: "秦"
    era: "春秋战国"
    aliases: []
    notes: "嬴姓·伯爵→公→王（战国）"

  - name: "晋"
    era: "春秋"
    aliases: ["唐"]   # 唐叔虞封地早期称呼
    notes: "姬姓·侯爵→公；战国后被韩/魏/赵三家分晋"

  - name: "齐"
    era: "春秋战国"
    aliases: []
    notes: "姜姓→田姓·侯爵→公→王"

  - name: "楚"
    era: "春秋战国"
    aliases: ["荆"]   # 楚国早期他称
    notes: "芈姓·子爵→王（春秋僭越称王）"

  # ... (其余 13 国 / 4 国带 alias 详 inventory §2.2)
```

**字符集 inline at code（不进 yaml）**：

```python
SHIHAO_CHARS = "庄桓昭襄惠成穆悼平孝景灵献文武康简怀厉宣幽思敬考定哀殇烈"  # 25 chars
RULER_TITLES = ("王", "公", "侯")
```

**理由**：
- states.yaml 是"国名字典"语义（数据 + 学术 metadata），更新走 historian
- 谥号字符集是"regex 字符类"语义（代码常量），更新走 PE + 单元测试 — 两者职责分离

#### 5.3.5 国名 alias 等价性

regex 编译时合并主名 + 全部 aliases：

```python
all_states = []
for state in load_states_yaml():
    all_states.append(state.name)
    all_states.extend(state.aliases)
# all_states = ["秦", "晋", "唐", "齐", "楚", "荆", ...]

STATE_PATTERN = re.compile(
    r"^(?P<state>" + "|".join(map(re.escape, all_states)) + r")"
    r"(?P<shihao>[" + SHIHAO_CHARS + r"]+)"
    r"(?P<title>王|公|侯)$"
)
```

**alias 解析**：捕获后归一到主名比较（`唐叔X公` 与 `晋X公` 视为同 state="晋"，**不 blocked**）。

**冲突预防**：alias 必须不与其他 state 主名冲突。inventory §2.2 4 个 alias（唐/荆/句吴/於越）已检查无冲突，未来添加 alias 需 historian ACK + grep 检查。

#### 5.3.6 与 dynasty_guard 的关系

| 场景 | dynasty_guard | state_prefix_guard | 联合行为 |
|------|--------------|-------------------|---------|
| 跨朝代 + 跨国 | ✅ blocked | ✅ blocked | dynasty 先短路（首个 blocked） |
| 跨朝代 + 同国 | ✅ blocked | ❌ 不拦 | dynasty 短路 |
| 同朝代 + 跨国 | ❌ 不拦 | ✅ **blocked** | state_prefix 命中（**核心目标**） |
| 同朝代 + 同国 | ❌ 不拦 | ❌ 不拦 | 正常进 R1 / merge |
| 任一方 dynasty 缺映射 | None | regex 仍可独立判定 | state_prefix 兜底（**新增防御**） |
| 任一方 surface 不匹配 regex | dynasty 判定 | 不拦（fall through）| 仅靠 dynasty |

**关键互补点**：dynasty 缺映射的 ~15% persons（韩信↔田荣等楚汉时期 case，§4.2 已知局限）现可被 state_prefix 部分覆盖（如双方都是"X王"模式）。

#### 5.3.7 R6 不挂 state_prefix（数据驱动结论）

per Stage 0 inventory §6 + Sprint I brief §3 调研项 #6：

- 当前 663 active persons 中**仅 1 例 V11-bordering case**（Q468747 周公旦 → 周公 / 周公旦，同国同 dynasty，state==）
- R6 强证据（QID anchor, conf=1.0），dynasty_guard(500yr) 已是松约束
- state_prefix 加 R6 反易引入 over-blocking（同 QID 标注国不同 → 应回归数据修复，非 guard 拦截）
- **触发条件登记 backlog**：未来 ≥1 例"R6 同 QID 跨国 active person" → 重评估并报架构师

#### 5.3.8 已知局限（仿 §4.2 写法）

- ⚠️ **裸谥号 case**（无国名前缀的 surface，如`桓公`/`武王`/`灵公`/`怀王` 等 14 surface 跨实体，详 inventory §3.4）—— state_prefix 不命中，依赖 dynasty_guard 兜底或 historian review
- ⚠️ **NER 抽出"X公"丢失国名前缀** —— 改进 NER prompt 是更根本路径（候选 T-P2-005 / T-P2-010）
- ⚠️ **双字国名**（中山 / 鲜虞）—— 本 sprint regex 仅单字 state；登记 backlog（**Future Work**）
- ⚠️ **同 state 但写作不同字面**（如"晋"vs"唐"alias）—— states.yaml alias 处理；未列入 alias 的同国异称（如未列"姬周"=周王朝）会被误判为 state≠
- ⚠️ **NER 极端长度 surface**（如"周王孙满"、"周公黑肩"等含国名前缀但非"X公/王"模式）—— regex 不命中，fall through，不影响

#### 5.3.9 单元测试要求（最小集 ≥ 6，仿 §2.6 写法）

per Sprint I brief §2 必做 #5：

1. **state_prefix 命中（核心目标）**：`鲁桓公(春秋) ↔ 秦桓公(春秋)` — gap=0，state≠ → blocked
2. **state_prefix 不命中（同 state）**：`秦穆公 ↔ 秦桓公` — state==，**guard 不拦**，进 R1 → MergeProposal
3. **裸谥号 fall through**：`桓公 ↔ 鲁桓公` — 单方匹配 regex，**不 blocked**（避免错拦）
4. **dynasty + state 双 guard 协同（dynasty 短路）**：`周成王(西周) ↔ 楚成王(春秋)` — dynasty(286>200) 先短路，state_prefix 不被调用
5. **dynasty 缺映射 + state 拦截**：构造一对 dynasty 缺映射的诸侯（如 dynasty=None 但都有 state 前缀）— state_prefix 独立兜底
6. **alias 等价**：`唐叔X公 ↔ 晋X公` — alias 归一后 state==晋 → 不拦（如果数据有 surface 含"唐"前缀）
7. **R6 路径回归（Sprint H 既有测试 28 全部不破）**：R6 chain 不挂 state_prefix，行为与 Sprint H 一致

#### 5.3.10 实施 Stages（per brief §3）

- **Stage 0**：inventory（commit `05cf818`）— 本 §5.3 起草前置
- **Stage 1**：本 §5.3 + states.yaml schema（不写 yaml 文件）— 等架构师签字
- **Stage 2**：states.yaml 落盘 + state_prefix_guard 函数 + GUARD_CHAINS 重构 + ≥6 单元测试 + R6 路径回归
- **Stage 3**：当前 DB 663 active persons re-run dry-run + 拦截数对比 §5.3.1 预测 ~38%（项羽δ+秦γ ~10 对）
- **Stage 4**：closeout

#### 5.3.11 收口判定（per brief §7）

- ✅ states.yaml ≥12 国（本设计 17 国）
- ✅ state_prefix_guard 函数 + ≥6 单元测试 + R6 路径无回归
- ✅ ADR-025 §5.3 addendum 落地（**本节签字**）
- ✅ 当前 DB dry-run state_prefix 单独拦截数 ≈ 项羽δ+秦γ 残余 38%（~10 对）
- ✅ V1-V11 全绿不回归
- ✅ Sprint G 暴露的 R1 跨国 FP Sprint G→H→I 累计降至 ≤10%（架构师 Sprint J 跑后验证）

---

## 5.4 Architect Sign-off for §5.3（2026-04-28）

- [x] **§5.3.4 states.yaml schema** 设计采纳（格式与 dynasty-periods.yaml 一致；17 国 + 4 alias 覆盖足够；SHIHAO_CHARS / RULER_TITLES inline at code 职责分离正确）
- [x] **§5.3.3 GUARD_CHAIN 顺序**：dynasty (O(1)) → state_prefix (regex) 短路顺序正确；resolve.py:480 零改动展示 evaluate_pair_guards 抽象价值；与 R6 既有 single-guard 路径同语义
- [x] **§5.3.7 R6 不挂 state_prefix** 数据驱动结论采纳（1 例 V11-bordering case 周公↔周公旦同 state 足够支撑决策；backlog trigger 条件登记为动态阈值治理）
- [x] **§5.3.8 已知局限** 列举完整（5 项覆盖裸谥号 / NER prompt 改进路径 / 双字国名 / alias 缺失 / 极端长 surface；与 §4.2 写法对齐）
- [x] **§5.3.9 单元测试** 最小集 ≥6 涵盖（实际 7 项；第 6 项 alias 等价测试唐叔X公↔晋X公 是亮点；第 7 项 R6 回归守 Sprint H 既有 28 测试）
- [x] **§5.3 整体落地**：Stage 2 进入条件 met

**额外裁决（inventory §2.3）**

- [x] **裁决 A："周" 不纳入 states.yaml**（PE 推荐成立）— dynasty_guard gap≥286 已 100% 兜底周天子 / 春秋诸侯跨代 case；"周"进 yaml 反易触发"周王 vs 楚王"等 over-block；未来如 dynasty_guard 漏拦周相关 case → 重评估
- [x] **裁决 B：邾/莒/巴 不纳入**（PE 推荐成立）— DB 0 surface 数据驱动决策正确；backlog 登记到位

签字日期：2026-04-28
签字人：架构师
单节 status: **accepted**（2026-04-28 签字）

---

## 6. Known Follow-ups

### 6.1 短期（Sprint H Stage 2-4）

- **`data/dynasty-periods.yaml` 9 缺失映射补全**（管线工程师起草 draft + historian 后续年代复核）：秦末 / 秦末汉初 / 春秋战国 / 战国·秦 / 战国·韩 / 战国·魏 / 战国秦 / 战国末秦初 / 西周/春秋。每条标 `pending-historian-review`，draft 直接生效供 stage 2-5 使用
- **R6 既有调用点迁移到 `evaluate_pair_guards(rule="R6")`**（Stage 2 内完成）；deprecated 包装**保留至 Sprint I 收口**（不在 Stage 2 末删除）
- **dry-run 验证**：当前 DB（663 active persons）回跑，对比 Stage 0.5 拦截预测

### 6.2 中期（Sprint I/J 候选）

- **state_prefix_guard**：识别 鲁/晋/齐/秦/楚/卫/宋/吴/越/魏/韩/赵 等国别前缀差异（覆盖 gap=0 case）。设计要点：
  - 字典：`data/state-prefixes.yaml`（春秋战国诸侯国名单 + 谥号正则）
  - 触发条件：双方 surface form 都含国别前缀且前缀不同
  - 复用同一 `pending_merge_reviews` 接口（guard_type='state_prefix'）
- **wikidata_attr_guard**（仅 R6 强化）：基于 dictionary_entries 的 birth/death year 做更精细距离判定（不依赖 dynasty 字段）

### 6.3 长期（Phase 2+）

- **dynasty 字段细粒度化评估**：当前 663 persons 中已有 "战国·秦" / "战国·韩" 等更细粒度标注，但仅 14 行；如未来扩展到春秋（春秋·鲁 / 春秋·秦 等），可弃用 state_prefix_guard 改用 dynasty 距离即可
- **V12 invariant 候选**："无 entity 包含跨 ≥500yr mentions"——本 ADR 提供的 guard 基础设施可被 V12 检测路径复用

---

## 7. Relationship to Existing ADRs

| ADR | 关系 |
|-----|------|
| ADR-010 §R1 | 不修改 R1 评分逻辑本体，仅在 R1 输出后增加 guard 层 |
| ADR-014 | 不影响 names-stay；guard 拦截不产生任何 person_names UPDATE |
| ADR-022 | 哲学一致（规则精化优先）；不重叠（不同对象） |
| ADR-023 | 哲学一致（α/β 豁免 ↔ rule-aware threshold dispatch） |

本 ADR **不 supersede** 任何现有 ADR，是 supplement。

---

## 8. Architect Sign-off (2026-04-26)

- [x] **阈值最终选定**：**R1=200yr / R6=500yr**（PE 推荐采纳）
- [x] **接口命名最终选定**：`evaluate_pair_guards`（PE 推荐采纳）
- [x] **向后兼容包装保留期**：**Sprint I 收口**前保留（不在 Stage 2 末删除）；§2.4 / §6.1 已同步修订
- [x] **dynasty-periods.yaml 9 缺失映射**：**PE 起草 draft + historian 后续年代复核**（不阻塞 Stage 2，draft 直接生效）；§6.1 已同步修订
- [x] **state_prefix_guard 实施时机**：**延后 Sprint I**（本 sprint 仅 R1 dynasty filter）

状态：**accepted**（2026-04-26）。
