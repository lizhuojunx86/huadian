# T-P0-015 S-1 Evidence — 帝鸿氏/缙云氏 Canonical 归并调研

> Generated: 2026-04-19
> Role: historian (主导) + pipeline-engineer (DB 查询)
> Data snapshot: 152 active persons, 黄帝 canonical 无现有 merge

---

## DB 快照

### 黄帝 (canonical target)

| field | value |
|-------|-------|
| id | `3197e202-55e0-4eca-aa91-098d9de33bc9` |
| slug | `huang-di` |
| dynasty | 上古 |
| names | 轩辕 (primary), 黄帝 (nickname) |
| merged_into_id | NULL |
| deleted_at | NULL |
| mentions | 0 |
| identity_hypotheses | 0 |
| existing merges into | 0 |

### 帝鸿氏 (candidate #1)

| field | value |
|-------|-------|
| id | `19ef3926-eaf1-42e1-ba4b-f0fc4b9de9dd` |
| slug | `u5e1d-u9e3f-u6c0f` |
| dynasty | 上古 |
| names | 帝鸿氏 (alias) |
| merged_into_id | NULL |
| deleted_at | NULL |
| mentions | 0 |
| identity_hypotheses | 0 |

### 缙云氏 (candidate #2)

| field | value |
|-------|-------|
| id | `ae47eddd-804b-4715-974a-d1eb99a19509` |
| slug | `u7f19-u4e91-u6c0f` |
| dynasty | 上古 |
| names | 缙云氏 (alias) |
| merged_into_id | NULL |
| deleted_at | NULL |
| mentions | 0 |
| identity_hypotheses | 0 |

---

## 史源引文

### 出处 1：五帝本纪 P24（= 左传·文公十八年 引文）

> 昔**帝鸿氏**有不才子，掩义隐贼，好行凶慝，天下谓之浑沌。
> 少暤氏有不才子，毁信恶忠，崇饰恶言，天下谓之穷奇。
> 颛顼氏有不才子，不可教训，不知话言，天下谓之梼杌。
> 此三族世忧之。至于尧，尧未能去。
> **缙云氏**有不才子，贪于饮食，冒于货贿，天下谓之饕餮。
> 天下恶之，比之三凶。舜宾于四门，乃流四凶族，迁于四裔，以御螭魅。

**结构分析**：四个上古帝/族系并列（帝鸿氏 / 少暤氏 / 颛顼氏 / 缙云氏），各对应一"不才子"（浑沌 / 穷奇 / 梼杌 / 饕餮 = 四凶）。

### 出处 2：古注对"帝鸿氏"的训释

| 注家 | 出处 | 训释 |
|------|------|------|
| 贾逵 | 《左传》注（裴骃《史记集解》引） | "帝鸿，**黄帝**也" |
| 杜预 | 《春秋左传集解》 | "帝鸿，**黄帝**" |
| 张守节 | 《史记正义》 | "帝鸿，**黄帝号也**" |
| 服虔 | 《左传》注 | "帝鸿，**黄帝**也" |

**共识度**：帝鸿氏 = 黄帝 → **近乎全票**。贾逵、杜预、服虔、张守节四家一致。无已知古注反对此训。

### 出处 3：古注对"缙云氏"的训释

| 注家 | 出处 | 训释 |
|------|------|------|
| 杜预 | 《春秋左传集解》 | "缙云，**黄帝时官名**" |
| 贾逵 | 《左传》注（裴骃引） | "缙云氏，**黄帝时官也**" |
| 韦昭 | 《国语》注 | 缙云氏为黄帝所置夏官 |
| 部分晚期文献 | 散见 | 有将缙云氏等同于炎帝的说法（少数） |

**共识度**：缙云氏 = 黄帝时代的**官名/官族** → **主流**。与"帝鸿氏=黄帝**本人**"性质不同：缙云氏是黄帝朝的**臣属**，非黄帝的别称。

### 出处 4：叙事结构约束

P24 段落的四个族系（帝鸿氏 / 少暤氏 / 颛顼氏 / 缙云氏）以并列结构呈现，暗示它们是**四个不同的上古帝/族系**。如果帝鸿氏=黄帝（已确认），则缙云氏 ≠ 黄帝（否则同一列表中有两项指向同一实体，逻辑矛盾）。

---

## S-2 Historian 裁决

### 结论：**(c) 混合** — 帝鸿氏 MERGE，缙云氏 KEEP-independent

#### 帝鸿氏 → **MERGE into 黄帝**

- **核心理由**：帝鸿氏=黄帝是先秦两汉经学注疏的**一致共识**（贾逵、杜预、服虔、张守节四家无异议），"帝鸿"为黄帝的**帝号/尊称**（鸿=宏大），非独立实体。
- **merge_rule**: `R4-honorific-alias`（新规则：尊称/帝号类别名归并）
- **confidence**: 0.95
- **操作**：帝鸿氏.merged_into_id → 黄帝.id；黄帝 person_names 吸收"帝鸿氏"为 `alias` 类型

#### 缙云氏 → **KEEP-independent**

- **核心理由**：
  1. 杜预/贾逵明确训释缙云氏为"黄帝时**官名**"，非黄帝本人
  2. P24 四族系并列结构——帝鸿氏已等同黄帝，缙云氏若再等同黄帝则同表二指
  3. 缙云氏与黄帝是**从属关系**（官→帝），非**等同关系**（alias）
- **操作**：无 DB 变更。缙云氏保留为独立 person，dynasty=上古

---

## Impact Summary

| entity | action | persons affected | merge_log rows |
|--------|--------|-----------------|----------------|
| 帝鸿氏 | MERGE into 黄帝 | 1 (merged_into_id set) | 1 |
| 缙云氏 | KEEP-independent | 0 | 0 |
| **total** | | **1 person updated** | **1 log row** |
| active persons | 152 → **151** | | |
