# Identity Resolver Pattern — R1-R6 + GUARD_CHAINS for Cross-Domain Entity Resolution

> Status: **Draft v0.1**
> Date: 2026-04-29
> Owner: 首席架构师
> Source: 华典智谱 Sprint A-K 真实代码 + ADR-010 / ADR-025 / ADR-026 / Sprint H/I 实战

---

## 0. TL;DR

实体歧义解析（Entity Resolution / Identity Resolution）是知识工程的核心难题。AKE 框架提供 **R1-R6 + GUARD_CHAINS** 两层抽象：

- **R1-R6** = 六类规则（rules）的优先级队列，从严格到宽松匹配实体对
- **GUARD_CHAINS** = 每条规则可挂多个 guard 函数，链式过滤误判

实际效果（华典智谱史记 Sprint A-K）：从 R1 跨国 FP 62%（Sprint G 项羽本纪基线）→ Sprint J 高祖本纪 100% 治理（state_prefix_guard 7/7 拦截）。

本文件给出：(1) R1-R6 规则定义；(2) GUARD_CHAINS 机制；(3) 跨领域 mapping 表；(4) 设计契约（C-23 应用）；(5) 反模式。

---

## 1. 问题定义

### 1.1 知识库的"脏数据"主要来自哪里

| 来源 | 占比（实证）| 缓解方式 |
|------|-----------|---------|
| 同名异人未识别 | ~40% | R1-R6 + GUARD_CHAINS |
| 同人异名未合并 | ~30% | R6 seed-match + textbook-fact threshold |
| 实体类别错误 | ~15% | NER prompt 调整 + 字典批次 |
| 朝代 / 年代标错 | ~10% | dynasty-periods.yaml + cross_dynasty_guard |
| 其他 | ~5% | 一一处理 |

R1-R6 + GUARD_CHAINS 处理前两类（70% 的脏数据来源）。

### 1.2 "解析"的两个动作

KE 项目中，"解析"（resolution）≠ "找出最匹配的"，而是 **决定 merge / not-merge / pending-review**：

- **Merge** — 这两个 entity 是同一个，把它们合并为一行（保留所有名 / source 链 / etc）
- **Not-merge** — 这两个 entity 不是同一个，保持独立
- **Pending-review** — 不确定，挂入 historian review 队列等人工决策

R1-R6 提供"自动决策 + pending-review 选择"机制。

---

## 2. R1-R6 六类规则

### 2.1 规则定义（按严格度排序）

| Rule | 含义 | 严格度 | 误判风险 |
|------|------|-------|---------|
| **R6** seed-match | 双方都已 anchor 到同一 Wikidata QID | 极严（QID 唯一）| 极低 |
| **R5** exact-name + cross-validation | 双方主名完全一致 + 至少一项辅助证据（如朝代 / 出生年）| 严 | 低 |
| **R4** alias-match + temporal-consistency | 一方主名 = 另一方 alias + 朝代不冲突 | 中 | 中 |
| **R3** fuzzy-name + temporal | 主名 fuzzy match + 朝代一致 | 中宽 | 中高 |
| **R2** alias-overlap | 双方 alias 集合有交 | 宽 | 高 |
| **R1** name-prefix / cross-name | 名称前缀重合 / 短名长名关系 | 极宽 | **极高（FP 62% 实证）** |

### 2.2 R1-R6 优先级编排

```python
# 伪代码
def resolve(person_a, person_b):
    # 优先级最高的规则 wins
    for rule in [R6, R5, R4, R3, R2, R1]:
        result = rule.match(person_a, person_b)
        if result.matches:
            # 进入 GUARD_CHAINS 链路
            for guard in GUARD_CHAINS[rule.id]:
                if guard.blocks(person_a, person_b, result):
                    return Decision.PENDING_REVIEW(guard.reason)
            return Decision.MERGE(rule.id)
    return Decision.NOT_MERGE
```

### 2.3 规则之间的关系

- R1 是**最宽**的规则，意图覆盖"短名长名 / 前缀缩略"等常见现象（如"信"是"韩信"的简称）
- R6 是**最严**的规则，要求双方都有可信第三方 anchor（Wikidata QID）
- R3-R5 在中间，处理"主名一致或 alias 重合 + 时空一致"
- R2 是**最危险**的规则（alias 重合但无其他证据），生产中默认禁用或经特殊 guard

### 2.4 GUARD_CHAINS = 规则的"防御纵深"

每条规则可挂多个 guard 函数，guard 命中即把 candidate 推入 pending-review 而非自动 merge：

```python
GUARD_CHAINS = {
    "R1": [
        cross_dynasty_guard(threshold_years=200),  # 跨朝代拦截
        state_prefix_guard(states_yaml),           # 跨国拦截
        textbook_fact_guard(threshold_count=3),    # 教科书事实拦截
    ],
    "R6": [
        cross_dynasty_guard(threshold_years=500),  # R6 已有 QID 但年代差太大也拦
    ],
}
```

---

## 3. GUARD_CHAINS 机制详解

### 3.1 Guard 接口（领域无关）

```python
# Pseudocode
class Guard:
    def applies_to(self, rule_id: str) -> bool: ...
    def blocks(self, a: Entity, b: Entity, match_result) -> Optional[BlockReason]: ...
```

每个 Guard 实现：
1. `applies_to` - 决定该 guard 用于哪些 rule
2. `blocks` - 给定 entity pair + match result，返回阻塞原因（None = 不阻塞）

### 3.2 实证 guards（华典智谱）

| Guard | 触发条件 | domain-specific 参数 |
|-------|---------|-------------------|
| `cross_dynasty_guard` | 双方 dynasty 间距 > N 年 | N（古籍 200yr / 法律可能 50yr 政府届期）|
| `state_prefix_guard` | 双方名称都含 state 前缀（鲁X / 秦X）但 state 不同 | states.yaml（古代诸侯国列表，领域专属）|
| `textbook_fact_guard` | candidate 已被 N 例独立 textbook fact 反驳 | N（实证 4 例触发 ADR-014 addendum）|

### 3.3 GUARD_CHAINS 的执行顺序

按 Sprint H/I 实证经验：

1. **先 cheap，后 expensive**：cross_dynasty_guard（O(1) yaml lookup）先于 textbook_fact_guard（O(N) DB query）
2. **先 high-FP rule 多 guard**：R1 链有 3 个 guard / R6 链只有 1 个
3. **早期 fail-fast**：第一个 block 即 return，不跑后续 guard

### 3.4 GUARD_CHAINS 不是 invariant

注意区分：
- **GUARD** = 软约束，触发时把 candidate 推 pending-review（不阻断 sprint）
- **INVARIANT** = 硬约束，违反时阻断 commit / sprint（参见 `docs/methodology/04-invariant-pattern.md`）

GUARD 是"我不确定，请 historian 看一眼"；INVARIANT 是"这个状态不允许存在，必须修"。

---

## 4. 设计契约（C-23 案例服务于框架）

### 4.1 R1-R6 接口必须领域无关

```python
# 框架层签名（领域无关）
def resolve(
    a: Entity,
    b: Entity,
    rules: List[Rule] = [R6, R5, R4, R3, R2, R1],
    chains: Dict[str, List[Guard]] = GUARD_CHAINS,
) -> Decision:
    ...

# 案例层 instantiate（注入 domain-specific guard）
chain_for_my_case = {
    "R1": [
        my_temporal_guard(threshold_years=200),     # 案例参数
        my_state_guard(my_state_list_yaml),         # 案例参数
    ],
}
```

### 4.2 Guard 函数必须明确标注 domain-specific 参数

```python
def cross_dynasty_guard(threshold_years: int):
    """
    domain-specific parameters:
        threshold_years: 跨"dynasty"概念的年数阈值
                         古籍领域 200yr / 法律领域可能 50yr / 医疗几乎不适用
        dynasty_periods: 通过 yaml 文件注入，不硬编码
    """
    ...
```

### 4.3 案例层（domain）输入清单

新案例使用 R1-R6 + GUARD_CHAINS 框架时需要提供：

1. `Entity` 类型定义（name / aliases / dynasty / temporal / etc）
2. 每条 rule 对应的 match 实现（领域可能省略某些 rule）
3. domain-specific guard（如朝代 / 时间 / 地理 / 等领域约束）
4. domain-specific 字典（dynasty-periods.yaml / states.yaml 等价物）
5. domain-specific match 阈值（fuzzy match 相似度 / temporal 容差 / etc）

---

## 5. 跨领域 Mapping

### 5.1 Concept Mapping 表

| 古籍（华典智谱）| 佛经案例 | 法律案例 | 医疗案例 | 专利案例 |
|---------------|--------|--------|--------|--------|
| Person（人物）| 高僧 / 经师 | 当事方 / 法人 | 患者 / 主诊医师 | 发明人 / 申请人 |
| Dynasty | 朝代 | 朝代 / 法系（普通法 / 大陆法）| 政府届期 | 时代（专利时代："胶片时代"）|
| State（诸侯国）| 教派 / 宗派 | 法域 / 司法管辖区 | 不适用 | 不适用 |
| QID（Wikidata anchor）| 同 | 案号 / 法人统一信用代码 | 病历号 / 医师执照号 | 专利号 |
| 跨章合并 | 跨经典合并 | 跨判例合并 | 跨病历合并 | 跨专利合并 |

### 5.2 Guard Mapping 表

| 华典智谱 guard | 佛经类比 | 法律类比 | 医疗类比 | 专利类比 |
|--------------|--------|--------|--------|--------|
| cross_dynasty_guard | cross_era_guard | cross_jurisdiction_guard | 不适用 | cross_tech_era_guard |
| state_prefix_guard | sect_prefix_guard | jurisdiction_prefix_guard | 不适用 | classification_guard |
| textbook_fact_guard | scripture_fact_guard | precedent_fact_guard | guideline_fact_guard | prior_art_guard |

### 5.3 跨领域使用步骤

```
1. 把上面 Concept Mapping 套到你的领域
2. 实现 6 个 rules 对应的 match 函数（可能只用其中 3-4 个）
3. 实现 domain-specific guards（cross_X_guard / X_prefix_guard / etc）
4. 准备 domain dictionary（dynasty-periods.yaml 等价物）
5. 跑 Sprint A smoke 验证 pipeline
6. Sprint B 起做 cross-entity dry-run + review + apply
```

---

## 6. 实证：Sprint G→I 治理目标达成

### 6.1 baseline（Sprint G 项羽本纪）

- 21 组 R1 候选 → Domain Expert review
- 13 组 reject（FP 62%）
- 主要 FP 类别：跨朝代 / 跨国名同号

### 6.2 Sprint H 介入（cross_dynasty_guard）

- ADR-025 evaluate_pair_guards 接口落地
- cross_dynasty_guard(200yr) 接入 R1
- 实测拦截：约 50% 跨朝代 FP 案例
- 残余：~38% 春秋同朝代不同国（gap=0，dynasty 无法触发）

### 6.3 Sprint I 介入（state_prefix_guard）

- ADR-025 §5.3 addendum
- states.yaml 17 国 + state_prefix_guard
- GUARD_CHAINS 替换单 guard dispatch（R1 chain = [cross_dynasty(200), state_prefix]）
- 实测拦截：剩余 38% 跨国 FP

### 6.4 Sprint J 验证（高祖本纪）

- 跨秦汉过渡章节，预期高 R1 FP 风险
- 实测：state_prefix_guard 拦截 7/7（100% 治理率）
- Sprint G→I 治理目标 ≥ 90% **达成**

### 6.5 抽象洞察

R1-R6 + GUARD_CHAINS 不是一次设计完美，而是**通过 sprint 迭代逐步纵深**：

- Sprint G：暴露 R1 跨国 FP
- Sprint H：第一层 guard（cross_dynasty）
- Sprint I：第二层 guard（state_prefix）
- Sprint J：第三层（textbook_fact_guard 4 例触发，待 ADR-014 addendum）
- ...

→ Guard chain 是**生长**出来的，不是设计出来的。这本身是 AKE 框架的一个核心信念：**先看数据，再加 guard**。

---

## 7. 反模式

### 7.1 反模式：直接 R1 自动 merge

❌ R1（最宽规则）一命中就 auto-merge

✅ R1 必须经过 GUARD_CHAINS 链；任何不经 guard 的 R1 merge 都视为高风险

### 7.2 反模式：硬编码 domain rules

❌ guard 内写 `if dynasty_a == "汉" and dynasty_b == "周"`

✅ 通过 yaml / json 配置注入 domain knowledge

### 7.3 反模式：guard chain 顺序乱

❌ textbook_fact_guard（DB query）在 cross_dynasty_guard（O(1)）之前

✅ cheap-first；early fail

### 7.4 反模式：guard 与 invariant 混淆

❌ 在 invariant 里实现"跨朝代检查"（应该是 guard，触发 pending-review，不阻断）

✅ guard 推 pending-review；invariant 阻断 commit

### 7.5 反模式：复用规则跨领域

❌ 把华典智谱的 cross_dynasty_guard 直接拿到法律案例（"跨朝代"在法律里没意义）

✅ 案例方实现自己的 guard，复用框架接口（Guard 抽象类），不复用具体实现

---

## 8. 修订历史

| Version | Date | Author | Change |
|---------|------|--------|--------|
| Draft v0.1 | 2026-04-29 | 首席架构师 | 初稿（Stage C-7 of D-route doc realignment）|

---

> 本文档描述的 R1-R6 + GUARD_CHAINS 是 AKE 框架的 Layer 1 核心资产之一。
> Sprint H/I 是其真实演化历史，详见 ADR-025 + sprint logs。
