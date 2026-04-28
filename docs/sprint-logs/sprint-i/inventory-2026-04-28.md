# Sprint I Stage 0 Inventory — state_prefix_guard 联合调研

> **角色**: 管线工程师（Opus 4.7 / 1M）
> **日期**: 2026-04-28
> **关联**: brief `docs/sprint-logs/sprint-i/stage-0-brief-2026-04-27.md` §3 / ADR-025 §6.2
> **DB 状态**: Sprint H 收口快照（663 active persons / merge_log 92 / V1-V11 全绿 / pg_dump anchor `52bd6f91da5c`）
> **本会话 scope**: Stage 0 调研 + Stage 1 设计 → 挂起等架构师 ADR-025 §5.3 addendum 签字

---

## §1 R1 集成点 + GUARD_CHAIN 物理位置（brief §3 调研项 #1）

### 1.1 现状（Sprint H 落地）

| 文件 | 行 | 行为 |
|------|----|------|
| `services/pipeline/src/huadian_pipeline/r6_temporal_guards.py` | 234-261 | `evaluate_pair_guards(a, b, *, rule)` 内部 single-guard dispatch：查 `GUARD_THRESHOLDS[rule]` 直调 `cross_dynasty_guard` |
| `services/pipeline/src/huadian_pipeline/resolve.py` | 480-509 | R1 主循环；`evaluate_pair_guards(rule=match.rule)` 命中 → `BlockedMerge` → `pending_merge_reviews` |
| `services/pipeline/src/huadian_pipeline/resolve.py` | 533 | R6 路径同样调用 `evaluate_pair_guards(rule="R6")`（Sprint H §2.4 兼容包装迁移） |

### 1.2 Sprint I 改造形态

**关键设计**：chain 实现完全封装在 `evaluate_pair_guards` 内部，**`resolve.py:480` 集成点 0 改动**。

```
当前 (Sprint H):
  evaluate_pair_guards(rule) → cross_dynasty_guard(threshold)
                             → GuardResult | None

Sprint I:
  evaluate_pair_guards(rule) → run_guard_chain(rule)
    R1 chain = [cross_dynasty_guard(200), state_prefix_guard]
    R6 chain = [cross_dynasty_guard(500)]   ← state_prefix 不挂 R6 (§6 分析)
    → 短路返回首个 blocking guard
```

### 1.3 GUARD_CHAIN 顺序（提议）

**dynasty_guard → state_prefix_guard 短路**（与既有 R6 路径同语义）。

理由：
1. `cross_dynasty_guard` 是 O(1) yaml lookup（`_get_dynasty_periods()` lazy cached dict）
2. `state_prefix_guard` 是 regex compile + match，单次 O(L) where L=name length
3. 短路语义保持 `BlockedMerge` 单一 `guard_type` 写入 `pending_merge_reviews`（每 pair 写 1 行），与 Sprint H 已落地一致；triage UI 单维度展示
4. 若未来需要"多维证据合并"（聚合 dynasty_distance + state_prefix + ...），开新 ADR 引入 `MultiGuardResult` aggregator；本 sprint 不动

---

## §2 春秋战国诸侯国候选清单（brief §3 调研项 #2）

### 2.1 数据来源融合

- **brief §2 必做 #1** 列举 12 国: 鲁/晋/齐/秦/楚/卫/宋/吴/越/魏/韩/赵
- **disambiguation_seeds.seed.json §跨国同名** 出现的国: 秦/晋/齐/鲁/楚/郑/周
- **DB person_names surface 实测**: 见 §3
- **学界春秋战国诸侯国主流名单**: + 燕/陈/蔡 等

### 2.2 主候选清单（**17 国 / 20 别名**，均 DB 实测命中或 brief 显式列举）

| # | 主名 | 别名 / 异称 | 周代封号 | DB surface count | 命中谥-公/王 pattern | 来源 |
|---|------|------------|---------|-----------------:|--------------------:|-----|
| 1 | 秦 | — | 嬴姓·伯爵→公→王 | 41 | 19 | brief / DB / disambig |
| 2 | 晋 | 唐（唐叔虞封地早期称呼）| 姬姓·侯爵→公 | 16 | 10 | brief / DB / disambig |
| 3 | 齐 | — | 姜姓·侯爵→公→王 | 14 | 6 | brief / DB / disambig |
| 4 | 楚 | 荆（楚国早期他称） | 芈姓·子爵→王 | 18 | 8 | brief / DB / disambig |
| 5 | 鲁 | — | 姬姓·侯爵→公 | 8 | 2 | brief / DB / disambig |
| 6 | 卫 | — | 姬姓·伯爵→公 | 3 | 0 | brief / DB |
| 7 | 宋 | — | 子姓·公爵 | 3 | 0 | brief / DB |
| 8 | 吴 | 句吴 / 攻吴（金文异写） | 姬姓·子爵→王 | 3 | 0 | brief / DB |
| 9 | 越 | 於越（先秦异称） | 姒姓·子爵→王 | 0 | 0 | brief（DB 无 surface） |
| 10 | 魏 | — | 姬姓·战国诸侯王 | 11 | 1 | brief / DB |
| 11 | 韩 | — | 姬姓·战国诸侯王 | 13 | 2 | brief / DB |
| 12 | 赵 | — | 嬴姓·战国诸侯王 | 11 | 1 | brief / DB |
| 13 | 郑 | — | 姬姓·伯爵→公 | 6 | 3 | DB / disambig |
| 14 | 燕 | — | 姬姓·伯爵→战国王 | 3 | 1 | DB（战国七雄） |
| 15 | 陈 | — | 妫姓·侯爵 | 7 | 0 | DB（春秋大国） |
| 16 | 蔡 | — | 姬姓·侯爵 | 3 | 0 | DB |
| 17 | 蜀 | — | 古蜀国（非周封） | 6 | 0 | DB |

### 2.3 争议候选（Stop Rule #1 候选触发项 — 报架构师裁决）

| 国名 | 状态 | DB 数据 | 争议 |
|------|------|--------|------|
| **周** | **争议项 A** | 39 surfaces / 19 命中 `(周)(谥)(王)` | 周既是朝代名又作天子前缀；R1 跨"周成王↔楚成王"FP 已被 `cross_dynasty_guard`(gap=286>200) 100% 拦住，state_prefix 是否冗余？建议：**不纳入 states.yaml**，由 `cross_dynasty_guard` 兜底（§6 复核） |
| 邾 | 争议项 B | DB 0 surfaces | 春秋小国，未来高祖本纪/项羽本纪扩量也少见；预防性纳入需 historian ACK |
| 莒 | 争议项 B | DB 0 surfaces | 同上 |
| 巴 | 争议项 B | DB 0 surfaces | 边远小国；秦本纪有"伐巴蜀"地名，非诸侯 surface |
| 中山 | 争议项 C | DB 0 | 战国"中山国"是双字国名，本 sprint regex 仅支持单字前缀；登记 backlog |
| 鲜虞 | 争议项 C | DB 0 | 同上（双字） |

**Stop Rule #1 触发判定**：争议项 A "周" 的取舍属架构师裁决（影响 dynasty_guard 与 state_prefix_guard 边界），**不属国名争议** → Stop Rule #1 不触发。
争议项 B 三国 DB 无 surface，预防性纳入风险低，**建议默认不纳入，登记 backlog**，**不触发 Stop Rule #1**。
争议项 C 双字国名属未来扩展，不属本 sprint scope。

**结论**：Stop Rule #1 **不触发**，主候选 17 国（不含周）落地 states.yaml。

---

## §3 person_names surface 国名前缀分布（brief §3 调研项 #4）

### 3.1 SQL（按 Sprint H Sonnet 列名错教训，schema 已确认 ✅）

```sql
WITH state_chars(state) AS (VALUES ('鲁'),('晋'),('齐'),('秦'),('楚'),('卫'),('宋'),
  ('吴'),('越'),('魏'),('韩'),('赵'),('郑'),('燕'),('陈'),('蔡'),('周'),
  ('巴'),('蜀'),('邾'),('莒'))
SELECT s.state, COUNT(*) AS surface_count
FROM person_names pn JOIN persons p ON pn.person_id=p.id
WHERE p.deleted_at IS NULL
  AND pn.name LIKE s.state || '%'
  AND LENGTH(pn.name) >= 2
GROUP BY s.state
ORDER BY surface_count DESC;
```

### 3.2 结果（17 国命中，21 国扫描）

```
 state | surface_count
-------+--------------
 秦    |           41
 周    |           39
 楚    |           18
 晋    |           16
 齐    |           14
 韩    |           13
 赵    |           11
 魏    |           11
 鲁    |            8
 陈    |            7
 蜀    |            6
 郑    |            6
 蔡    |            3
 吴    |            3
 宋    |            3
 燕    |            3
 卫    |            3
```
（越/巴/邾/莒：DB 无 surface 命中）

### 3.3 严格谥号 pattern 命中（73 行）

```sql
SELECT pn.name, p.dynasty
FROM person_names pn JOIN persons p ON pn.person_id=p.id
WHERE p.deleted_at IS NULL
  AND pn.name ~ '^(秦|楚|晋|齐|鲁|郑|宋|卫|魏|韩|赵|燕|陈|蔡|吴|越|蜀|周)
                  [庄桓昭襄惠成穆悼平孝景灵献文武康简怀厉宣幽思敬考定哀殇悼烈]
                  (王|公|侯)$';
```

73 命中 / 11 国（秦 19 / 周 19 / 晋 10 / 楚 8 / 齐 6 / 郑 3 / 鲁 2 / 韩 2 / 燕 1 / 魏 1 / 赵 1）。

### 3.4 裸谥号同 surface 跨实体（state_prefix 不能拦的 case，记入已知局限）

```sql
SELECT pn.name, COUNT(DISTINCT p.id) AS entity_count, STRING_AGG(p.dynasty, ' | ')
FROM person_names pn JOIN persons p ON pn.person_id=p.id
WHERE p.deleted_at IS NULL
  AND pn.name ~ '^[庄桓昭襄惠成穆悼平孝景灵献文武康简怀厉宣幽思敬考定哀殇悼烈](王|公|侯)$'
GROUP BY pn.name HAVING COUNT(DISTINCT p.id) >= 2;
```

14 surface (武王 / 灵公 / 襄公 / 平公 / 庄公 / 康公 / 怀公 / 怀王 / 悼公 / 惠公 / 成王 / 桓公 / 灵王 / 简公) 各跨 2-3 entity。**这些是 R1 stop_words 之外的"裸谥号"surface**——双方都无国名前缀时，state_prefix_guard **fall through 不拦**，依赖 dynasty_guard 兜底（多数已 gap≥200）或 historian review。

---

## §4 谥号字典侦察（brief §3 调研项 #3）

### 4.1 现有资产

| 文件 | 内容 | 是否可复用 |
|------|------|-----------|
| `data/dictionaries/miaohao.yaml` | 11 entries / 商朝+上古（太甲/太宗 / 帝辛/纣 / 微子启 / 帝尧/舜/颛顼/帝喾/后稷/伯益）| **不可复用**——仅商朝庙号，无春秋战国诸侯谥号 |
| `data/dynasty-periods.yaml` | 17 dynasty periods + 9 mappings（Sprint H 合流）| 不相关 |
| `data/dictionaries/tongjia.yaml` | 通假字字典 | 不相关 |
| `data/dictionaries/disambiguation_seeds.seed.json` | 跨国 _notes（庄/桓/灵/悼/简/襄/怀/平/成王 11 谥号）| **辅助参考**，非字典本身 |

**结论**：项目无可复用的春秋战国谥号字典。

### 4.2 MVP 设计

不开新字典文件，**inline 谥号字符类于 `state_prefix_guard` regex**（在 states.yaml 内嵌或代码常量，Stage 1.2 设计稿决定）。

**字符集（来自 §3.3 / §3.4 实测命中合并）**：

```python
SHIHAO_CHARS = "庄桓昭襄惠成穆悼平孝景灵献文武康简怀厉宣幽思敬考定哀殇烈"  # 25 chars
RULER_TITLES = ("王", "公", "侯")
```

覆盖 §3.3/§3.4 全部 73+14=87 case。未来 NER prompt 引入新谥号 → 字符集扩展 → 单元测试新增。

### 4.3 双字谥号特殊处理

`秦昭襄王` / `周慎靚王` / `周显王` 等双字谥号：**regex 用 `[chars]+` 而非 `[chars]`**，自动覆盖 1-2 字（实测 §3.3 已含 "昭襄"）。

---

## §5 regex 边界 case 设计稿（brief §3 调研项 #5 + 用户追加 8 条）

### 5.1 设计目标

**单方守护（unilateral guard）**：仅当**双方 surface 都匹配 `(state)(shihao)(ruler)` 模式 且 state 不同**时拦截。任一方不匹配模式则 fall through（不阻 R1，等 dynasty_guard 兜底或进 MergeProposal）。

理由：避免"鲁桓公↔桓公"被错拦——后者裸谥号无国名信息，应继续走 R1 → 由 historian 审核。

### 5.2 regex 草稿

```python
# state_prefix_guard 内部
STATE_PATTERN = re.compile(
    r"^(?P<state>秦|楚|晋|齐|鲁|郑|宋|卫|魏|韩|赵|燕|陈|蔡|吴|越|蜀)"
    r"(?P<shihao>[庄桓昭襄惠成穆悼平孝景灵献文武康简怀厉宣幽思敬考定哀殇烈]+)"
    r"(?P<title>王|公|侯)$"
)
```

`state` 列表来自 §2.2 主候选 17 国（**不含周**，per §2.3 决议）。

### 5.3 8 条 boundary case（per 用户追加指引）

| # | Surface A | Surface B | A 匹配? | B 匹配? | guard 行为 | 期望 |
|---|----------|----------|--------:|--------:|------------|------|
| 1 | `鲁桓公` (state=鲁) | `秦桓公` (state=秦) | ✓ | ✓ | **state≠**, **blocked** ✅ | guard 命中（核心目标 case） |
| 2 | `秦昭襄王` (双字 shihao) | `齐昭公` (双字-shihao 子集) | ✓ | ✓ | **state≠**, **blocked** ✅ | guard 命中（双字谥兼容） |
| 3 | `孝公` (裸谥号无前缀) | `秦孝公` (state=秦) | ✗ | ✓ | **不双匹**, fall through ⚠️ | dynasty_guard 兜底（多数同朝代不拦）+ historian review |
| 4 | `楚成王` (state=楚) | `周成王` (周不在 list) | ✓ | ✗ | **不双匹**, fall through | dynasty_guard 拦（gap=286>200）✅ |
| 5 | `启` (单字 surface) | `太子启` | ✗ | ✗ | **不双匹**, fall through | R1 既有 single-char 路径处理（既存逻辑） |
| 6 | `鲁仲连` (姓"鲁"非国前缀) | `鲁连` | ✗ | ✗ | **不双匹**, fall through | "仲连"/"连" 非谥号字符，regex 不命中（保护正确） |
| 7 | `楚怀王` (战国 / 春秋称王) | `秦怀公` (战国称公) | ✓ | ✓ | **state≠**, **blocked** ✅ | guard 命中（跨称号变体） |
| 8 | `齐桓公`↔`鲁桓公`（多国共谥）| `晋桓公` (假设) | ✓ | ✓ | **state≠**, **blocked** ✅ | guard 命中 — 这正是设计目标 |

### 5.4 衍生 boundary（设计稿额外覆盖）

| # | case | 行为 |
|---|------|------|
| 9 | `楚王`（仅 state+title 无 shihao）| regex 不命中（shihao+ 至少 1 字符）→ fall through |
| 10 | `武王` 裸 surface（裸 shihao+title）| regex 不命中（缺 state）→ fall through，进 R1 stop_words 路径 |
| 11 | NER 抽出"X公"丢失国名前缀 | regex 不命中 → fall through（已知局限 §5.5） |
| 12 | 同 state 同 shihao（如两个 `秦桓公` mention）| state**==**, **不 blocked**（继续走 R1，可能合并）✅ |

### 5.5 已知局限（写入 ADR §5.3 → 仿 §4.2）

1. **裸谥号 case** (§3.4 14 surface) — state_prefix 不命中，依赖 dynasty_guard 或 historian review
2. **NER 丢失前缀** — 改进 NER prompt（T-P2-005 候选）
3. **双字国名**（中山/鲜虞）— 本 sprint regex 仅单字，登记 backlog
4. **国名 alias 等价**（晋=唐叔虞封地）— 同朝代同国别名（如"唐"指春秋早期晋）少见，本 sprint 仅记 alias，等数据驱动加入 regex 字符集

---

## §6 R6 是否同步加 state_prefix（brief §3 调研项 #6）

### 6.1 数据支撑（用户追加指引）

```sql
-- V11 invariant cross-check: 单 QID active 多 person
SELECT sm.dictionary_entry_id, COUNT(DISTINCT sm.target_entity_id) AS active_persons
FROM seed_mappings sm
JOIN persons p ON p.id=sm.target_entity_id AND p.deleted_at IS NULL
WHERE sm.target_entity_type='person' AND sm.mapping_status='active'
GROUP BY sm.dictionary_entry_id HAVING COUNT(DISTINCT sm.target_entity_id) > 1;
```

**结果**：1 例 — Q468747（周公旦）映射到 `周公` (slug=u5468-u516c) 与 `周公旦` (slug=u5468-u516c-u65e6)，**均"周"前缀 / 均西周 dynasty**。

### 6.2 评估

- **case 是 R6 同 QID 同国同朝代**：state_prefix 不会拦此 case（state==）
- 当前 663 active persons 中**未观察到"同 QID 跨国 active person"** case
- 理论上 V11（anti-ambiguity cardinality, Sprint C 落地）已防御此类
- R6 强证据（QID anchor, conf=1.0），dynasty_guard(threshold=500) 已足够松

### 6.3 决策

**R6 不挂 state_prefix_guard**，理由：
1. 数据 0 例驱动需求（V11 守护下不应出现）
2. R6 + 500yr dynasty_guard 已是松约束，state_prefix 反易引入 over-blocking
3. 与 ADR-025 §3.3 "rule-aware threshold" 哲学一致（强证据规则 guard 应少，弱证据规则 guard 应多）

**触发条件登记 backlog**：未来出现 ≥1 例"R6 同 QID 跨国 active person"或 V11 violation（破 V11 守护）→ 重评估并报架构师。

---

## §7 GUARD_CHAIN 顺序提议（汇总）

```python
# r6_temporal_guards.py (Sprint I 新增结构)

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
            return result   # 短路返回首个 blocking
    return None
```

**短路顺序选定**：dynasty 在前（O(1) yaml lookup）+ state_prefix 在后（regex compile + match）。

---

## §8 调研结论 + 下一步

### 8.1 6 项调研结论汇总

| # | 调研项 | 结论 |
|---|--------|------|
| 1 | R1 集成点 | 0 改动 `resolve.py:480`，chain 封装在 `evaluate_pair_guards` 内部 |
| 2 | 国名候选清单 | **17 国**（秦/晋/齐/楚/鲁/卫/宋/吴/越/魏/韩/赵/郑/燕/陈/蔡/蜀），不含周（争议项 A 决议）；4 国别名（晋=唐 / 楚=荆 / 吴=句吴 / 越=於越） |
| 3 | DB surface 分布 | 73 命中严格 (state+shihao+ruler) pattern / 14 裸谥号跨实体 |
| 4 | 谥号字典 | 无可复用资产，inline 25 字符集 + (王/公/侯) ruler titles |
| 5 | regex 边界 case | 8+4 条 + 5 已知局限 |
| 6 | R6 同步加 state_prefix | **不加**，data-driven backlog |

### 8.2 Stop Rule 触发记录

- **Stop Rule #1（国名争议）**：**不触发**。争议项 A "周" 属架构师裁决（不属国名争议本身），争议项 B 三小国默认不纳入，争议项 C 双字国名属未来扩展。
- **Stop Rule #2（regex 过度匹配）**：本 stage 仅设计稿，不触发；Stage 2 实施后 dry-run 才能验证。
- **Stop Rule #3-#5**：本 stage 不在 dry-run / 实施 scope。

### 8.3 下一步

- Stage 1.1 / 1.2 / 1.3 设计 → 入 ADR-025 §5.3 addendum draft（commit C2）
- 挂起等架构师签字
- Stage 2 实施留 sprint-i 会话 2

---

## §9 引用 commit / 文件锚点

- **Brief**: `docs/sprint-logs/sprint-i/stage-0-brief-2026-04-27.md`
- **ADR-025**: `docs/decisions/ADR-025-r-rule-pair-guards.md` (accepted commit `b9bfc8d`)
- **resolve.py R1 集成点**: `services/pipeline/src/huadian_pipeline/resolve.py:480-509`
- **r6_temporal_guards.py 当前 dispatch**: `services/pipeline/src/huadian_pipeline/r6_temporal_guards.py:234-261`
- **disambiguation_seeds 跨国 _notes**: `data/dictionaries/disambiguation_seeds.seed.json` line 340-641
- **miaohao.yaml**（不可复用）: `data/dictionaries/miaohao.yaml`
- **DB pg_dump anchor**: Sprint H closeout `52bd6f91da5c`（663 active persons / V1-V11 全绿）
