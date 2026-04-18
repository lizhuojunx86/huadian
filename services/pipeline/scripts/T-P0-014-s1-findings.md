# T-P0-014 S-1 Findings — Non-Person Entity Candidates

> Generated: 2026-04-18
> Role: pipeline-engineer (with historian review protocol)
> Data snapshot: 157 active persons, 12 merged, 3 books (五帝本纪/夏本纪/殷本纪)

---

## Summary

| Category | Count | Action |
|----------|-------|--------|
| Confirmed delete | 3 | Proceed to S-4 soft-delete |
| Bumped to NEEDS_REVIEW | 4 | Deferred to user decision |
| B-class (historian ruled keep) | 9 | No action this task |
| Confirmed keep | 141 | No action |

---

## Confirmed Delete (3 entities)

### 1. 荤粥 (`u8364-u7ca5`)
- **dynasty**: 上古
- **surface_forms**: `荤粥` (single form)
- **classification**: 部族/族群 (匈奴古称)
- **核查**: surface_forms 无"去氏"人形，无歧义
- **verdict**: DELETE — `merge_rule='R3-non-person'`, reason='tribal_group'

### 2. 昆吾氏 (`u6606-u543e-u6c0f`)
- **dynasty**: 夏
- **surface_forms**: `昆吾氏` (single form)
- **classification**: 部族/封国 (夏代附庸诸侯)
- **核查**: surface_forms 仅含"昆吾氏"，无裸名"昆吾"
- **verdict**: DELETE — `merge_rule='R3-non-person'`, reason='tribal_group'

### 3. 姒氏 (`u59d2-u6c0f`)
- **dynasty**: 夏
- **surface_forms**: `姒氏` (single form)
- **classification**: 氏族/姓氏 (夏朝国姓)
- **核查**: surface_forms 仅含"姒氏"，无裸名"姒"
- **verdict**: DELETE — `merge_rule='R3-non-person'`, reason='clan_surname'

---

## Bumped to NEEDS_REVIEW (4 entities)

### 4. 羲氏 (`u7fb2-u6c0f`)
- **dynasty**: 上古
- **surface_forms**: `羲 | 羲氏`
- **原判**: A-class delete (官职世家)
- **核查结果**: surface_forms 含裸名"羲"（去氏人形）
- **核查规程触发**: "去掉氏后缀的人形" → 同一条可能同时指代族与人
- **verdict**: NEEDS_REVIEW — 个体成员（羲仲/羲叔）已有独立条目，但裸名"羲"可能指代特定人
- **用户决策点**: 是 delete 还是保留？如果"羲"在原文中仅作"羲氏"族称缩写（非指特定个人），可 delete

### 5. 和氏 (`u548c-u6c0f`)
- **dynasty**: 上古
- **surface_forms**: `和 | 和氏`
- **原判**: A-class delete (官职世家)
- **核查结果**: surface_forms 含裸名"和"（去氏人形）
- **核查规程触发**: "去掉氏后缀的人形" → 同一条可能同时指代族与人
- **verdict**: NEEDS_REVIEW — 个体成员（和仲/和叔）已有独立条目，但裸名"和"可能指代特定人
- **用户决策点**: 同上

### 6. 熊罴 (`u718a-u7f74`)
- **dynasty**: 上古
- **surface_forms**: `熊罴` (single form)
- **原判**: A-class delete (动物/图腾)
- **核查结果**: 出现在两段上下文中 —
  - **P2 (五帝本纪)**: "教熊罴貔貅貙虎，以与炎帝战于阪泉之野" → 兽兵/图腾
  - **P25 (五帝本纪)**: "益拜稽首，让于诸臣朱虎、熊罴…遂以朱虎、熊罴为佐" → **舜的臣子**
- **verdict**: NEEDS_REVIEW — 在 P25 语境中 熊罴 明确是舜朝官员（与朱虎并列），不能简单判为动物
- **用户决策点**: P2 和 P25 是否同一实体？P25 的"熊罴"是人名还是图腾名代人？

### 7. 龙 (`long`)
- **dynasty**: 上古
- **surface_forms**: `龙` (single form)
- **原判**: A-class delete (动物/神话)
- **核查结果**: 覆盖两书 —
  - **五帝本纪 P25**: "龙，朕畏忌谗说殄伪，振惊朕众，命汝为纳言" → **舜的纳言官**
  - **五帝本纪 P26**: "龙主宾客，远人至" → **舜朝官员**
  - **夏本纪 P14/P16**: "龙门" → 地名（非此人）
  - **夏本纪 P33**: "天降龙二…学扰龙于豢龙氏" → 动物（非此人）
- **verdict**: NEEDS_REVIEW — 按 historian 规程"两者都覆盖 → 报告给用户，暂不动"
- **用户决策点**: 该 person 实体明确代表舜臣（五帝本纪），夏本纪的"龙"是动物/地名非同一实体。建议保留，但需用户确认。

---

## B-class: Historian Ruled Keep (9 entities, no action)

| name | slug | reason |
|------|------|--------|
| 涂山氏 | u6d82-u5c71-u6c0f | 禹妻/启母族称代人，后续另开任务做"族称-个人聚合" |
| 帝鸿氏 | u5e1d-u9e3f-u6c0f | 另开 T-P0-015 处理"是否 merge 入黄帝" |
| 缙云氏 | u7f19-u4e91-u6c0f | 另开 T-P0-015 |
| 少暤氏 | u5c11-u66a4-u6c0f | 上古帝王，"氏"是尊称，后续与少昊走归并 |
| 浑沌 | u6d51-u6c8c | 四凶之一，绰号即身份，保留为匿名特定个体 |
| 梼杌 | u68bc-u674c | 四凶之一 |
| 穷奇 | u7a77-u5947 | 四凶之一 |
| 饕餮 | u9955-u992e | 四凶之一 |
| 神农氏 | shen-nong-shi | 上古三皇，明确"X氏"尊称白名单成员 |

---

## DB IDs for Confirmed Delete

```
荤粥: b40287a2-64ed-4bc3-83bf-3f51a8e1a48f
昆吾氏: be1927a1-1aef-4ae6-9a56-4640fd7c9ab0
姒氏: 16e09751-1795-4a4b-a0cf-4b5cb8409004
```

---

## 需用户回来决策

1. 羲氏/和氏：裸名"羲"/"和"在原文中是否指代特定个人？
2. 熊罴：P25 的"熊罴为佐"是人名还是图腾代人？
3. 龙：五帝本纪中明确是舜臣，建议保留，但需确认
