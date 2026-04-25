# Sprint H Stage 0 — 联合 Inventory

> **角色**: 管线工程师 (Opus 4.7 / 1M)
> **日期**: 2026-04-26
> **关联**: `docs/sprint-logs/sprint-h/stage-0-brief-2026-04-26.md` (架构师 brief)
> **范围**: T-P0-031 楚怀王 entity-split + T-P1-028 R1 dynasty 前置过滤
> **状态**: Stage 0 完成；Stop Rule #2 触发（楚怀王 mention 分桶 1 行不确定）→ T-P0-031 实施需第二会话切 historian

---

## 1. R1 当前实现 audit (Stage 0.1)

### 1.1 文件 / 函数定位

| 项 | 位置 |
|----|------|
| 主入口 | `services/pipeline/src/huadian_pipeline/resolve_rules.py:601` `score_pair()` |
| R1 实现 | `services/pipeline/src/huadian_pipeline/resolve_rules.py:226` `_rule_r1()` |
| R1-R5 主循环调用 | `services/pipeline/src/huadian_pipeline/resolve.py:462` `resolve_identities()` |
| R6 guard 集成（先例） | `services/pipeline/src/huadian_pipeline/resolve.py:346` `_detect_r6_merges()` |
| Guard module | `services/pipeline/src/huadian_pipeline/r6_temporal_guards.py` |

### 1.2 R1 现有 cross-dynasty guard 范围

`_rule_r1()` 已存在两层 dynasty 相关过滤（line 246-263）：

```python
# Step 2: Cross-dynasty guard — single-char only
cross_dynasty = a.dynasty and b.dynasty and a.dynasty != b.dynasty
if cross_dynasty:
    meaningful = {n for n in meaningful if len(n) >= 2}
    if not meaningful:
        return None
```

**关键限制**：现有 guard 仅在 **single-char overlap** 场景生效（如"启"/"益"）。对**多字短称**（"桓公"/"灵公"/"怀王"/"齐王"等）**完全不生效**——这是 Sprint G 暴露 13/21 = 62% FP 的直接根因。

### 1.3 文档 vs 实现一致性

ADR-010 §R1 描述 R1 为"surface_form 严格相等"，未规定 dynasty filter。实现的 single-char dynasty guard 是 ADR-010 之后增量加的（无独立 ADR 背书）。

**Stop Rule #1 不触发**（实现与 ADR-010 文档大方向一致；single-char guard 增量未冲突）。

### 1.4 R6 集成的先例

`_detect_r6_merges()` (resolve.py:299) 已经按 β 模式集成：
- 调用 `evaluate_guards(a, b)` (line 346)
- 命中 → 写入 `BlockedMerge`（line 354），最终入 `pending_merge_reviews`
- 未命中 → 进入 MergeProposal

但 R1-R5 的 pairwise loop（resolve.py:462-495）**没有任何 guard 调用**——这是 T-P1-028 设计的注入点。

---

## 2. Dynasty 字段成熟度 (Stage 0.2)

### 2.1 覆盖率（663 active persons）

```
total_active = 663
null_or_empty = 0           ✅ 100% 覆盖（与 Sprint D 报告一致）
distinct_dynasties = 21
```

### 2.2 取值分布

| 取值 | 人数 | YAML 映射? |
|------|-----:|:-----------|
| 春秋 | 118 | ✅ |
| 战国 | 111 | ✅ |
| 西周 | 88 | ✅ |
| 上古 | 84 | ✅ |
| 商 | 63 | ✅ |
| **秦末** | **61** | ❌ **缺** |
| 东周 | 36 | ✅ |
| **秦末汉初** | **21** | ❌ **缺** |
| 西汉 | 20 | ✅ |
| 夏 | 20 | ✅ |
| **战国·秦** | **11** | ❌ **缺**（"战国" alias 不命中） |
| 秦 | 11 | ✅ |
| 先周 | 6 | ✅ |
| **春秋战国** | **3** | ❌ **缺** |
| **战国·韩** | **2** | ❌ **缺** |
| 商末周初 | 2 | ✅ |
| **西周/春秋** | **2** | ❌ **缺** |
| **战国秦** | **1** | ❌ **缺** |
| **战国·魏** | **1** | ❌ **缺** |
| **战国末秦初** | **1** | ❌ **缺** |
| 周 | 1 | ✅ |

**缺映射 9 个取值，覆盖 ~103 active persons**（占 663 的 15.5%）。`cross_dynasty_guard` 对这些 persons **静默 fallback** 为 None（不拦）—— `r6_temporal_guards.py:172-181` 仅 `logger.warning`。

### 2.3 Schema 评估

| 表 | 是否需新字段? |
|----|-------------|
| `persons.dynasty` | 已有 ✅ |
| `dictionary_entries` | 不需要（T-P1-028 只用 persons.dynasty） |
| `pending_merge_reviews` | **完整支持** — `proposed_rule + guard_type + guard_payload` 都已就位（Sprint D 建） |

**T-P1-028 实施前置数据补充**（不在本会话 scope，但需在 Stage 2 前完成）：
- `data/dynasty-periods.yaml` 补 9 个缺失映射，覆盖 ~103 persons
- 否则 dynasty filter 对 15.5% persons 静默无效

---

## 3. Dynasty mapping 复用评估 (Stage 0.3)

### 3.1 既有接口

| 接口 | 位置 | 复用价值 |
|------|------|---------|
| `_load_dynasty_periods()` | r6_temporal_guards.py:59 | ✅ 直接复用 |
| `DynastyPeriod` dataclass | r6_temporal_guards.py:48 | ✅ 直接复用 |
| `cross_dynasty_guard(a, b)` | r6_temporal_guards.py:152 | ⚠️ **threshold 硬编码 500yr**（line 149），不能直接给 R1 用 |
| `evaluate_guards(a, b)` | r6_temporal_guards.py:216 | ⚠️ 不接受 rule context，所有规则共用同一 guard chain |
| `GuardResult` | r6_temporal_guards.py:131 | ✅ 直接复用 |
| `_GUARD_CHAIN = [cross_dynasty_guard]` | r6_temporal_guards.py:213 | ⚠️ 单一 guard，无法按规则切换 |

### 3.2 复用设计要点

为支持 R1 dynasty filter（200yr）+ R6 dynasty filter（500yr）共存，β 方案需扩展接口：

**方案 A**：threshold 参数化
```python
def cross_dynasty_guard(a, b, *, threshold_years: int = 500) -> GuardResult | None
```

**方案 B**：rule-aware guard chain
```python
GUARD_THRESHOLDS = {"R1": 200, "R6": 500}
def evaluate_pair_guards(a, b, rule: str) -> GuardResult | None
```

**方案 C**：每条 guard 独立配置
```python
R1_GUARD_CHAIN = [cross_dynasty_guard_200yr]
R6_GUARD_CHAIN = [cross_dynasty_guard_500yr]
```

**Stage 1 设计建议**：方案 B（与架构师默认 β 倾向一致）。理由：rule context 是天然的 dispatch key，未来若加 R2/R5 各自的 threshold 也可扩展同一接口。

### 3.3 单源真相评估

✅ dynasty mapping 单源（`data/dynasty-periods.yaml`）。R1 复用相同 YAML，不引入第二真相源。

---

## 4. 楚怀王 Entity Mention 分桶 (Stage 0.4)

### 4.1 楚怀王 entity 现状

```
person_id = 777778a4-bc13-4f91-b2c3-6f8efd1b0e72
slug      = u695a-u6000-u738b
name_zh   = 楚怀王
dynasty   = 战国        ← 标注为熊槐（战国楚怀王）
deleted_at= NULL        ← active
```

关联 `person_names` 仅 **3 行**：

| pn_id (前 8) | name | name_type | is_primary | source_evidence_id (前 8) | book / chapter |
|--------------|------|-----------|------------|---------------------------|----------------|
| `8fb2afc3` | 楚怀王 | primary | t | `d06422a2` | 史记·秦本纪 §65 |
| `7a68ff90` | 怀王 | posthumous | f | `73e39311` | 史记·项羽本纪 §6 |
| `2afc61fc` | 楚王 | nickname | f | `73e39311` | 史记·项羽本纪 §6 |

后两行**共享同一 `source_evidence_id` 73e39311** — 同一段引文产出。

### 4.2 SE 段落原文

**SE `d06422a2` (秦本纪 §65)**：
> ...九年，孟尝君薛文来相秦……奂攻楚，取八城，杀其将景快。**十年，楚怀王入朝秦，秦留之。**薛文以金受免……

→ 历史事件：前 296 年熊槐客死秦的"楚怀王入秦不返"事件。指代 **熊槐**（战国楚怀王，毫无歧义）。

**SE `73e39311` (项羽本纪 §6)**：
> 居鄛人范增，年七十……往说项梁曰："陈胜败固当。夫秦灭六国，楚最无罪。**自怀王入秦不反**，楚人怜之至今……今君起江东……以君世世楚将，为能复立楚之后也。"于是项梁然其言，**乃求楚怀王孙心民间，为人牧羊，立以为楚怀王**，从民所望也。陈婴为楚上柱国，封五县，**与怀王都盱台**。项梁自号为武信君。

→ 同段同时指代两人：
> - "**怀王**入秦不反" / "**楚怀王**孙心" → **熊槐**（战国，被作为血统来源）
> - "立以为**楚怀王**" / "与**怀王**都盱台" → **熊心**（秦末，被立的新楚怀王）

### 4.3 Mention 分桶决策表

| pn_id (前 8) | 章节 | 段落片段（10-30 字） | 上下文判定 | 迁移决策 |
|--------------|------|--------------------|-----------|---------|
| `8fb2afc3` | 秦本纪 §65 | "十年，楚怀王入朝秦，秦留之" | **战国熊槐**（昭襄王段，前 296 客死秦事件） | **保留**现 entity（楚怀王 / 战国 / slug u695a-u6000-u738b） |
| `7a68ff90` | 项羽本纪 §6 | "自怀王入秦不反"（句 1）+"立以为楚怀王"+"与怀王都盱台"（句 2、3） | **不确定** — 同段引文同时指代熊槐（句 1，血统溯源）与熊心（句 2/3，被立的新王）；alias "怀王" 在 NER 阶段被聚合到一个 entity，但底层 evidence 链跨人 | **Stop Rule #2 触发** — 切 historian 二次裁决 |
| `2afc61fc` | 项羽本纪 §6 | 同 SE 73e39311 段落整段 | **不确定** — alias "楚王" 在原文中**不独立出现**（仅"楚怀王/楚国/楚后/楚上柱国/楚之后"等组合），NER 取了"楚……王"组合或泛称归属错误；归楚怀王 entity 属数据错误，但迁移目标不明 | **Stop Rule #2 触发** — 切 historian 二次裁决 |

### 4.4 Stop Rule #2 触发记录

✅ **触发**：3 行 mention 中 **2 行不确定**（≥ 1 即触发）。

**触发原因**：
1. SE `73e39311` 段落本身指代两个不同人（熊槐 + 熊心），alias 归属在 SE 粒度不可机械分桶
2. "楚王" alias 在原文中不独立出现（NER 归属源头存疑），需 historian 复核 LLM call cc380423 的具体提取依据

**影响范围**：
- ✅ T-P1-028（R1 dynasty filter 设计 + ADR-025）**不受影响**（结构性改进，不依赖楚怀王分桶决议）
- ❌ T-P0-031（楚怀王 entity-split 实施）**受阻**，需第二会话切 historian 会话

**Brief §7 节奏建议已规划**：
> - 第二会话：Stage 2 T-P1-028 实施 + Stage 3 T-P0-031 dry-run → 挂起等联合 ACK

→ T-P0-031 dry-run 前必须先有 historian 对 SE `73e39311` 的 alias 归属裁决。

### 4.5 涉及的相关 entities (上下文)

```
熊心      48061967  u718a-u5fc3       秦末       active     ← T-P0-031 mention 迁移目标
义帝      2b953715  u4e49-u5e1d       秦末汉初   merged→熊心 (Sprint G G13 子合并)
怀王      d40d6efe  u6000-u738b       秦末       merged→熊心 (Sprint G G13 子合并)
楚怀王    777778a4  u695a-u6000-u738b 战国       active     ← T-P0-031 待 split
楚王      52014459  u695a-u738b       战国       active     ← 独立保留（historian §2.2 Group 13）
```

---

## 5. R1 跨国 FP 历史扫描量化 (Stage 0.5)

### 5.1 数据源

| 来源 | dry-run | historian review |
|------|---------|------------------|
| 秦γ (T-P0-006-γ) | `docs/sprint-logs/T-P0-006-gamma/dry-run-resolve-2026-04-25.md` | `historian-review-2026-04-25.md` (commit `3280a35`) |
| 项羽δ (T-P0-006-δ) | `docs/sprint-logs/T-P0-006-delta/dry-run-resolve-2026-04-25.md` | `historian-review-2026-04-25.md` (commit `fdfb7cb`) |

### 5.2 项羽δ：21 组 → 13 reject + 1 split + 7 approve

按 dynasty 字段值检查每个 reject 组的实际 gap：

| Group | Members | Dynasties | gap (200yr 阈值) | 200yr 拦? |
|-------|---------|-----------|------------------|-----------|
| 1 | 周成王 ↔ 楚成王 | 西周 / 春秋 | 286 | ✅ |
| 3 | 秦康公 ↔ 密康公 | 春秋 / 西周 | 286 | ✅ |
| 4 | 鲁桓公 ↔ 秦桓公 | 春秋 / 春秋 | **0** | ❌ |
| 5 | 晋悼公 ↔ 齐悼公 | 春秋 / 春秋 | **0** | ❌ |
| 6 | 灵王 ↔ 楚灵王 | 西周 / 春秋 | 286 | ✅ |
| 7 | 秦庄公 ↔ 齐庄公 | 西周 / 春秋 | 286 | ✅ |
| 8 | 秦简公 ↔ 齐简公 | 战国 / 春秋 | 275 | ✅ |
| 9 | 秦惠公 ↔ 惠公 | (entity 内含晋惠公污染) | 数据混合，guard 拦不住 | ❌ |
| 10 | 晋惠公 ↔ 秦襄公 ↔ 齐襄公 ↔ 晋襄公 | 春秋 / 西周/春秋(missing) / 春秋 / 春秋 | 大部分 **0** | ❌（部分） |
| 11 | 晋灵公 ↔ 灵公 ↔ 秦灵公 | 春秋 / 战国 / 春秋战国(missing) | 部分 275 | ✅（部分） |
| 12 | 晋平公 ↔ 齐平公 | 春秋 / 春秋 | **0** | ❌ |
| 14 | 秦怀公 ↔ 怀公 | 春秋战国(missing) / 战国 | unknown / 137 | ❌（未补 yaml）|
| 18 | 韩信 ↔ 田荣 | 西汉 / 秦末(missing) | unknown | ❌（未补 yaml） |

**项羽δ 200yr 拦截能力（dynasty mapping 完整后）**：5-7/13 ≈ 38-54%（明确能拦 5 组：1/3/6/7/8）

### 5.3 秦γ：35 组 → 21 approve + 5 reject + 9 split

| 类别 | 组号 | 跨国 dynasty? | gap 200yr 拦? |
|------|------|--------------|--------------|
| reject | 2 (周成王↔楚成王) | 西周/春秋 | ✅ |
| reject | 3 (秦康公↔密康公) | 春秋/西周 | ✅ |
| reject | 11 (秦惠公↔惠公) | entity 混合 | ❌ |
| reject | 17 (重耳↔秦文公) | 春秋/春秋 | ❌ (gap=0) |
| reject | 29 (晋平公↔齐平公) | 春秋/春秋 | ❌ |
| split | 5 (鲁桓公↔秦桓公) | 春秋/春秋 | ❌ |
| split | 7 (晋悼公↔齐悼公) | 春秋/春秋 | ❌ |
| split | 8 (灵王↔楚灵王) | 西周/春秋 | ✅ |
| split | 9 (秦庄公↔齐庄公) | 西周/春秋 | ✅ |
| split | 10 (秦简公↔齐简公) | 战国/春秋 | ✅ |
| split | 16 (晋惠公↔秦襄公↔...) | 春秋/西周/春秋 | 部分 |
| split | 26 (秦怀公↔怀公) | 春秋战国/战国 | ❌ (未补 yaml) |
| split | 28 (晋灵公↔秦灵公) | 春秋/春秋战国 | ❌ |
| split | 30 (楚昭王↔楚王) | 春秋/战国 | ✅ |

**秦γ 200yr 拦截能力**：5-7/14 ≈ 36-50%

### 5.4 关键洞察

1. **春秋同朝代不同国** (gap=0) 是 R1 FP 主体，**任何 dynasty distance 阈值都拦不住**。
   - 秦γ 14 跨国组中 ~6 组属此类（鲁桓公↔秦桓公 / 晋悼公↔齐悼公 / 重耳↔秦文公 / 晋平公↔齐平公 / 鲁桓公等）
   - 项羽δ 13 reject 中 ~5 组属此类
2. **dynasty mapping 缺映射** 让 ~15% persons 静默不被 guard 评估（韩信↔田荣等）。
3. **数据混合** （Group 11 秦惠公 entity 内含晋惠公 mentions）属 entity-level 污染，dynasty filter 无能为力，需 mention-level 消歧。
4. 200yr 阈值（dynasty 完整后）能拦的明确 case 约 36-50% R1 跨国 FP — **比 architect brief 默认估计更悲观**。

### 5.5 Historian 工作量减少估算

启用 R1 dynasty filter (200yr) 后：
- 项羽δ：21 组 → 减约 5-7 组 → ~15 组进 historian review (节省 25-33%)
- 秦γ：35 组 → 减约 5-7 组 → ~28 组进 historian review (节省 14-20%)

**结论**：dynasty filter 是必要但不充分。Stage 1 设计需说明纯 dynasty distance 阈值不能解决"春秋同朝代不同国"的核心问题——可能需要复合 guard（state-prefix guard 等扩展）。

---

## 6. Mention Redirect 机制现状 (Stage 0.6)

### 6.1 Mention 存储模型

| 表 | 存什么 | 关联 person 字段 |
|----|--------|------------------|
| `person_names` | name + name_type + source_evidence_id | `person_id` (FK to persons, ON DELETE CASCADE) |
| `source_evidences` | book/raw_text/quoted_text/llm_call_id | 经 person_names.source_evidence_id 间接关联 |
| `mentions` | (设计中，未激活) | 不在本 sprint scope |

楚怀王 entity 的"mention 迁移"= **修改 person_names.person_id 指向新 entity**。

### 6.2 是否有现成 redirect 接口？

**否**。`apply_merges()` (resolve.py:641) 是 entity-level merge（soft-delete + names-stay），**不支持 mention-level redirect**（不修改 person_names.person_id）。

### 6.3 自建脚本约束

T-P0-031 实施需要：

```sql
-- Pseudo-code（实际需 4 闸门）
BEGIN;
UPDATE person_names
SET person_id = '<熊心 entity id>'
WHERE id IN ('7a68ff90-...', '2afc61fc-...');  -- historian 裁决后确定
COMMIT;
```

**ADR-014 merge 铁律 §** （pipeline-engineer.md §数据形态契约级决策）：
> 任何修改 `persons.deleted_at` / `merged_into_id` / `person_names.person_id` 的操作必须经过 `apply_merges()` 或经 ADR 授权；ad-hoc SQL 一律拒绝。

→ T-P0-031 mention redirect 属"ad-hoc cross-person UPDATE"，**必须有 ADR 授权**。

### 6.4 ADR 授权路径

T-P0-031 task card §候选方案 已选方案 A（entity-split + mention redirect）。该 task card 本身可作为 ADR 替代品，但需架构师明确签字。或：

- 走 ADR-014 addendum（在 ADR-014 里加"entity-split 例外条款"）
- 或新建 ADR-026（"entity-split mention redirect — ad-hoc UPDATE 例外协议"）

**Stage 1 设计文档建议**：T-P0-031 实施前需架构师确定 ADR 授权路径（不在本会话 scope，但需在第二会话 historian ACK 后立即决定）。

### 6.5 4 闸门要求

T-P0-031 mention redirect 命中"§4 闸门敏感操作协议"全部要素（`pipeline-engineer.md`）：
- 闸门 1：pg_dump anchor
- 闸门 2：persons + person_names schema 确认
- 闸门 3：cache 状态（NER JSONL replay 可能性）
- 闸门 4：dry-run RETURNING 全量

---

## 7. Stage 1 设计输入

| 关键发现 | 对 Stage 1 设计的影响 |
|---------|----------------------|
| R6 已用 `evaluate_guards` β 模式 (resolve.py:346) | β 路径有先例，与架构师默认倾向一致 |
| R1-R5 主循环无 guard hook (resolve.py:462) | β 实施需在 score_pair 调用前后插入 guard 调用 |
| `cross_dynasty_guard` threshold 硬编码 500yr | β 接口必须扩展为 rule-aware：`evaluate_pair_guards(a, b, rule)` |
| dynasty mapping 9 取值缺映射 | T-P1-028 实施前置：`data/dynasty-periods.yaml` 必须先补全 |
| 春秋同朝代不同国 (gap=0) 是 FP 主体 | 单一 dynasty distance 不足；ADR-025 需说明扩展性，未来 state_prefix_guard 候选 |
| pending_merge_reviews schema 完整 (Sprint D) | T-P1-028 不需 schema 改动，仅 INSERT 新 guard_type='r1_cross_dynasty' |
| T-P0-031 受 Stop Rule #2 阻 | T-P1-028 设计独立可推进；T-P0-031 第二会话切 historian |

---

## 8. Stop Rule 触发记录

| Stop Rule | 触发? | 影响 |
|-----------|------|------|
| #1 R1 实现与文档严重不符 | 否 | — |
| **#2 楚怀王 mention 分桶需 historian 二次裁决** | **是** | T-P0-031 第二会话切 historian；T-P1-028 不受阻 |
| #3 Stage 1 选型与 β 不一致 | 否（推荐 β） | — |
| #4 ADR-025 草稿与 ADR-022/023 冲突 | 否（结构兼容） | — |

---

> Stage 0 inventory 完成。下一步：Stage 1 三方案 trade-off + 阈值灵敏度表 + ADR-025 草稿（status=proposed）。
