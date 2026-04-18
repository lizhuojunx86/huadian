# T-P0-014 S-1 Findings — Non-Person Entity Candidates

> Generated: 2026-04-18
> Updated: 2026-04-18 (historian override for 羲氏/和氏; historian KEEP for 熊罴/龙)
> Role: pipeline-engineer (with historian review protocol)
> Data snapshot: 157 active persons, 12 merged, 3 books (五帝本纪/夏本纪/殷本纪)

---

## Summary

| Category | Count | Action |
|----------|-------|--------|
| Confirmed delete | 5 | Proceed to S-4 soft-delete |
| Historian decided KEEP | 2 | No action (熊罴/龙) |
| B-class (historian ruled keep) | 9 | No action this task |
| Confirmed keep | 141 | No action |

---

## Confirmed Delete (5 entities)

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

### 4. 羲氏 (`u7fb2-u6c0f`) — historian override
- **dynasty**: 上古
- **surface_forms**: `羲 | 羲氏`
- **原判**: NEEDS_REVIEW (surface_forms 含裸名"羲"，触发 bare-name guard)
- **historian override**: 裸名"羲"为羲氏族称缩写（非独立人名），个体成员（羲仲/羲叔）已有独立条目
- **verdict**: DELETE — `merge_rule='R3-non-person'`, reason='official_clan', rule='shi_suffix_pattern + historian_override'

### 5. 和氏 (`u548c-u6c0f`) — historian override
- **dynasty**: 上古
- **surface_forms**: `和 | 和氏`
- **原判**: NEEDS_REVIEW (surface_forms 含裸名"和"，触发 bare-name guard)
- **historian override**: 裸名"和"为和氏族称缩写（非独立人名），个体成员（和仲/和叔）已有独立条目
- **verdict**: DELETE — `merge_rule='R3-non-person'`, reason='official_clan', rule='shi_suffix_pattern + historian_override'

---

## Historian Decided KEEP (2 entities)

### 6. 熊罴 (`u718a-u7f74`)
- **dynasty**: 上古
- **surface_forms**: `熊罴` (single form)
- **原判**: NEEDS_REVIEW (dual context in 五帝本纪)
- **historian verdict**: **KEEP** — P25"遂以朱虎、熊罴为佐"证据明确，熊罴是舜朝臣子（与朱虎并列），保留为人
- **原文上下文**:
  - **P2**: "教熊罴貔貅貙虎，以与炎帝战" → 兽兵/图腾（不同语境，不影响 P25 的人物身份）
  - **P25**: "益拜稽首，让于诸臣朱虎、熊罴…遂以朱虎、熊罴为佐" → 舜臣

### 7. 龙 (`long`)
- **dynasty**: 上古
- **surface_forms**: `龙` (single form)
- **原判**: NEEDS_REVIEW (两书覆盖)
- **historian verdict**: **KEEP** — 五帝本纪 P25/P26 中"龙"是舜的纳言官，保留为人
- **原文上下文**:
  - **五帝本纪 P25**: "龙，朕畏忌谗说殄伪…命汝为纳言" → 舜臣
  - **五帝本纪 P26**: "龙主宾客，远人至" → 舜朝官员
  - **夏本纪 P33**: "天降龙二…学扰龙于豢龙氏" → 动物（不同实体）
- **后续**: slug 一致性问题另登 T-P2-002

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
荤粥:   b40287a2-64ed-4bc3-83bf-3f51a8e1a48f
昆吾氏: be1927a1-1aef-4ae6-9a56-4640fd7c9ab0
姒氏:   16e09751-1795-4a4b-a0cf-4b5cb8409004
羲氏:   411ee7c8-a7fe-4f0b-8018-d1e63b0440bf
和氏:   c67494ce-eac5-4524-a8d2-0a8c03d24373
```
