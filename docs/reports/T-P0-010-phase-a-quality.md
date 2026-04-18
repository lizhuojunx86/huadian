# T-P0-010 Phase A 质量抽检报告

- **抽检对象**: 史记 - 五帝本纪 (slug: `shiji-wu-di-ben-ji`)
- **抽检人**: historian@huadian
- **日期**: 2026-04-18
- **数据概况**: 29 段原文, 62 persons, 93 person_names

---

## 一、随机抽样 10 个 person 核对

从 DB 随机抽取 10 个 person 逐一核对。

### 1. 瞽叟 (slug: `gu-sou`)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 瞽叟 | correct |
| dynasty | 上古 | correct |
| reality_status | legendary | correct |
| surface_forms | 瞽叟 (primary) | correct |
| 原文出现 | 五帝本纪 19/20/21/22 段均出现"瞽叟" | correct |

**判定: correct**

### 2. 风后 (slug: `feng-hou`)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 风后 | correct |
| dynasty | 上古 | correct |
| reality_status | legendary | correct |
| surface_forms | 风后 (primary) | correct |
| 原文出现 | 3 段 "举风后、力牧、常先、大鸿以治民" | correct |

**判定: correct**

### 3. 羲仲 (slug: `xi-zhong`)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 羲仲 | correct |
| dynasty | 上古 | correct |
| reality_status | legendary | correct |
| surface_forms | 羲仲 (primary) | correct |
| 原文出现 | 12 段 "分命羲仲，居郁夷" | correct |

**判定: correct**

### 4. 倕 (slug: `chui`)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 倕 | correct |
| dynasty | 上古 | correct |
| reality_status | legendary | correct |
| surface_forms | 倕 (primary) | correct |
| 原文出现 | 25 段 "禹、皋陶、契、后稷、伯夷、夔、龙、倕、益、彭祖" | correct |

**说明**: 原文中"倕"出现在群臣列举中。26 段"垂主工师"中的"垂"是通假字（倕=垂），但 DB 中"垂"被单独抽为另一个 person（slug: `u5782`）。这属于**同人异名未合并**问题。

**判定: incorrect** -- "倕"(chui) 和"垂"(u5782) 应合并为同一人。

### 5. 羲氏 (slug: `u7fb2-u6c0f`)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 羲氏 | uncertain |
| dynasty | 上古 | correct |
| reality_status | legendary | correct |
| surface_forms | 羲氏 (primary), 羲 (alias) | uncertain |
| 原文出现 | 12 段 "乃命羲、和" | uncertain |

**说明**: 原文 12 段 "乃命羲、和" 中的"羲"和"和"是对"羲仲、羲叔"与"和仲、和叔"四人的合称。LLM 将"羲"作为"羲氏"的 surface_form，另将"和"作为"和氏"的 surface_form。

学界争议：
- 传统注解（如《史记集解》引孔安国曰）认为"羲"是羲仲、羲叔的姓氏合称
- 也有学者认为"羲、和"是一个人"羲和"的分称

当前处理方式将"羲氏"和"和氏"各作为独立 person 实体，同时又有羲仲、羲叔、和仲、和叔四个独立 person，形成了**重复/冗余实体**。在五帝本纪语境下，"羲"和"和"仅是羲仲/羲叔、和仲/和叔的省称，不应单独建立 person 实体。

**判定: incorrect** -- 应删除"羲氏"和"和氏"两个 person，或将其标记为对下属人物的合称。

### 6. 和仲 (slug: `he-zhong`)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 和仲 | correct |
| dynasty | 上古 | correct |
| reality_status | legendary | correct |
| surface_forms | 和仲 (primary) | correct |
| 原文出现 | 12 段 "申命和仲，居西土" | correct |

**判定: correct**

### 7. 宰予 (slug: `u5bb0-u4e88`)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 宰予 | correct |
| dynasty | 春秋 | correct |
| reality_status | historical | correct |
| surface_forms | 宰予 (primary) | correct |
| 原文出现 | 29 段 "孔子所传宰予问五帝德" | correct |

**说明**: slug 为 `u5bb0-u4e88`（Unicode fallback），应为 `zai-yu`。拼音映射缺失导致 slug 不友好，但不影响数据正确性。

**判定: correct**（数据正确，slug 质量问题另记）

### 8. 驩兜 (slug: `u9a69-u515c`)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 驩兜 | correct |
| dynasty | 上古 | correct |
| reality_status | legendary | correct |
| surface_forms | 驩兜 (primary, is_primary=true), 欢兜 (primary, is_primary=false) | correct |
| 原文出现 | 13 段 "欢兜曰"（简体），17 段 "欢兜进言" | correct |

**说明**: 原文用"欢兜"（简体），LLM 正确识别"驩兜"为通行字形。两个 surface_form 的 name_type 都标为 primary，严格来说"欢兜"应标为 alias（通假/异体写法），但可以接受。

**判定: correct**

### 9. 益 (slug: `yi`)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 益 | correct |
| dynasty | 上古 | correct |
| reality_status | legendary | correct |
| surface_forms | 益 (primary) | correct |
| 原文出现 | 25/26 段均出现"益" | correct |

**判定: correct**

### 10. 玄嚣 (slug: `xuan-xiao`)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 玄嚣 | correct |
| dynasty | 上古 | correct |
| reality_status | legendary | correct |
| surface_forms | 玄嚣 (primary, is_primary=true), 青阳 (alias) | correct |
| 原文出现 | 5 段 "其一曰玄嚣，是为青阳"，7 段 "玄嚣之孙高辛立"，8 段多次 | correct |

**判定: correct**

### 抽样汇总

| # | 人物 | 判定 | 问题类型 |
|---|------|------|---------|
| 1 | 瞽叟 | correct | -- |
| 2 | 风后 | correct | -- |
| 3 | 羲仲 | correct | -- |
| 4 | 倕 | **incorrect** | 倕/垂 同人未合并 |
| 5 | 羲氏 | **incorrect** | 合称被误建为独立 person |
| 6 | 和仲 | correct | -- |
| 7 | 宰予 | correct | slug 不友好 |
| 8 | 驩兜 | correct | -- |
| 9 | 益 | correct | -- |
| 10 | 玄嚣 | correct | -- |

**抽样正确率: 8/10 = 80%**

---

## 二、额外检查

### 2a. "姓/氏/族" 模式扫描

逐段扫描原文中的"姓X""X氏""X之族"模式：

| 段落 | 原文 | 模式 | surface_forms 中是否存在 | 判定 |
|------|------|------|------------------------|------|
| 1 | "姓公孙" | 姓X | "公孙" **不在** surface_forms 中 | **missed** |
| 2 | "神农氏" | X氏 | 存在 (alias, shen-nong-shi) | correct |
| 5 | "蜀山氏女" | X氏女 | 存在 (alias → chang-pu) | correct |
| 5 | "西陵之女" | X之女 | 存在 (alias → lei-zu) | correct |
| 8 | "高辛氏" | X氏 (帝喾) | 存在 (alias → di-ku) | correct |
| 12 | "羲氏" / "和氏" | X氏 | 存在但被误建为独立 person | **problematic** |
| 23 | "高阳氏" / "高辛氏" | X氏 | 存在 (alias → zhuan-xu / di-ku) | correct |
| 24 | "帝鸿氏" | X氏 | 存在 (alias → u5e1d-u9e3f-u6c0f) | correct |
| 24 | "少暤氏" | X氏 | 存在 (alias → u5c11-u66a4-u6c0f) | correct |
| 24 | "颛顼氏" | X氏 | 存在 (alias → zhuan-xu) | correct |
| 24 | "缙云氏" | X氏 | 存在 (alias → u7f19-u4e91-u6c0f) | correct |
| 28 | "姓姒氏" / "姓子氏" / "姓姬氏" | 姓X氏 | 姓氏名未作为 surface_form | **n/a** (属姓氏信息，非人名) |

**"公孙"问题确认**:

1 段 "姓公孙，名曰轩辕" 中的 "公孙" 是黄帝的姓，应作为 surface_form 记录在黄帝的 person_names 中（name_type=alias 或 name_type=primary），但 **当前 DB 中不存在**。

这是已知的 missed extraction。原因分析：NER prompt 示例中对 1 段 的标注输出未包含 "公孙" 这个 surface_form，导致 LLM 学习了"不提取姓氏单称"的模式。

> 依据：《史记·五帝本纪》"姓公孙"。公孙既是黄帝的本姓，后世"公孙"姓即源于此。作为姓氏单称的 "公孙" 应当被记录为黄帝的 surface_form（name_type: alias），以便下游消歧和搜索。

### 2b. "X曰 / X名 / 名曰X" 模式

| 段落 | 原文 | 被标注人物 | primary 识别 | 判定 |
|------|------|-----------|-------------|------|
| 1 | "名曰轩辕" | 轩辕 → 黄帝 | "轩辕" name_type=primary | correct |
| 7 | "生子曰穷蝉" | 穷蝉 | primary | correct |
| 8 | "高辛父曰蟜极" | 蟜极 | primary | correct |
| 9 | "自言其名" | (帝喾自述) | n/a | correct |
| 14 | "曰虞舜" | 虞舜 → 舜 | "虞舜" alias, "舜" primary | correct |
| 19 | "名曰重华" | 重华 → 舜 | "重华" primary (non-is_primary), "舜" primary (is_primary) | correct |
| 19 | "重华父曰瞽叟" | 瞽叟 | primary | correct |
| 19 | "瞽叟父曰桥牛" | 桥牛 | primary | correct |
| 19 | "桥牛父曰句望" | 句望 | primary | correct |
| 19 | "句望父曰敬康" | 敬康 | primary | correct |
| 19 | "敬康父曰穷蝉" | 穷蝉 | primary | correct |

**"名曰X"模式识别整体良好**, 所有通过此模式引入的人名都被正确提取。

### 2c. "帝X" / "X帝" 模式

| surface_form | 所属 person | name_type | 判定 |
|-------------|-------------|-----------|------|
| 帝颛顼 | 颛顼 (zhuan-xu) | nickname | correct |
| 帝颛顼高阳 | 颛顼 (zhuan-xu) | nickname | correct -- 但整体合称作为 surface_form 价值不大 |
| 帝喾 | 帝喾 (di-ku) | nickname | **需讨论** |
| 帝喾高辛者 | 帝喾 (di-ku) | primary | **incorrect** |
| 帝尧 | 尧 (yao) | nickname | correct |
| 帝舜 | 尧 (yao) | nickname | **CRITICAL BUG** |
| 帝舜 | 舜 (shun) | nickname | correct |
| 帝禹 | 禹 (yu) | nickname | correct |
| 帝挚 | 帝挚 (u5e1d-u631a) | nickname | correct |
| 帝 | 尧 (yao) | nickname | **uncertain** |

**关键错误发现**:

1. **"帝舜"被同时挂在尧和舜两个 person 下**: 这是**严重错误**。"帝舜"只能指帝舜（即舜），绝不可能指尧。推测原因：某段落中"帝舜"出现在尧的上下文中（如 18 段"尧辟位...帝舜"），LLM 错误地将其归入了尧的 surface_forms。

2. **"帝喾高辛者" name_type=primary**: 这是 6 段开头"帝喾高辛者，黄帝之曾孙也"的全文提取。作为 surface_form 可以保留，但 name_type 不应是 primary，应该是 nickname 或 alias。"高辛"才是 primary name（本名）。

3. **"帝"作为尧的 nickname**: 泛称"帝"在五帝本纪中视上下文可指不同帝王，作为固定 surface_form 挂在尧名下不够准确。但 prompt 中已有规则"仅当能明确判断指代谁时才提取"，此处在某段落上下文中"帝"确实指尧，可以接受。

4. **帝喾的 primary name 问题**: DB 中帝喾的 name 为 `{"zh-Hans": "帝喾"}`，is_primary=true 的 person_name 是"帝喾"(nickname)。但"帝喾"是尊号/谥号，本名是"高辛"或"喾"。按照 NER prompt 的规则，"帝X"应为 nickname，本名（primary）应为"喾"或"高辛"。当前标注将 nickname 标为 is_primary，存在语义矛盾。

### 2d. False Negative 分析

#### 2d-1. 2 段 (人物密集段)

**原文**: 轩辕之时，神农氏世衰。诸侯相侵伐，暴虐百姓，而神农氏弗能征。于是轩辕乃习用干戈，以征不享，诸侯咸来宾从。而蚩尤最为暴，莫能伐。炎帝欲侵陵诸侯，诸侯咸归轩辕。轩辕乃修德振兵，治五气，艺五种，抚万民，度四方，教熊罴貔貅貙虎，以与炎帝战于阪泉之野。三战然后得其志。蚩尤作乱，不用帝命。于是黄帝乃徵师诸侯，与蚩尤战于涿鹿之野，遂禽杀蚩尤。而诸侯咸尊轩辕为天子，代神农氏，是为黄帝。天下有不顺者，黄帝从而征之，平者去之，披山通道，未尝宁居。

**手工标注的人物**:
1. 轩辕/黄帝 (同一人)
2. 神农氏
3. 蚩尤
4. 炎帝

**DB 中对应 person_names 出现情况**:
- 轩辕 -> huang-di: 存在
- 黄帝 -> huang-di: 存在
- 神农氏 -> shen-nong-shi: 存在
- 蚩尤 -> chi-you: 存在
- 炎帝 -> yan-di: 存在

**讨论**: "教熊罴貔貅貙虎"中的"熊罴"在此处是**动物名**（指驱使猛兽作战），不应作为人物提取。但 DB 中存在"熊罴"(u718a-u7f74) 作为独立 person，其 biography 为"益让位于他，被任为虞之佐"——这是 25 段的"遂以朱虎、熊罴为佐"。在 25 段语境中，"熊罴"确实是人名（益的佐官），但在 2 段中是动物名。LLM 没有在 2 段错误提取"熊罴"，这是正确的。

**2 段 false negative: 0** (完美提取)

#### 2d-2. 19 段 (世系密集段)

**原文**: 虞舜者，名曰重华。重华父曰瞽叟，瞽叟父曰桥牛，桥牛父曰句望，句望父曰敬康，敬康父曰穷蝉，穷蝉父曰帝颛顼，颛顼父曰昌意：以至舜七世矣。自从穷蝉以至帝舜，皆微为庶人。

**手工标注的人物**:
1. 虞舜/舜/重华/帝舜 (同一人)
2. 瞽叟
3. 桥牛
4. 句望
5. 敬康
6. 穷蝉
7. 帝颛顼/颛顼 (同一人)
8. 昌意

**DB 中检查**:
- 虞舜 -> shun: 存在
- 重华 -> shun: 存在
- 帝舜 -> shun: 存在
- 瞽叟 -> gu-sou: 存在
- 桥牛 -> qiao-niu: 存在
- 句望 -> gou-wang: 存在
- 敬康 -> jing-kang: 存在
- 穷蝉 -> qiong-chan: 存在
- 帝颛顼 -> zhuan-xu: 存在
- 颛顼 -> zhuan-xu: 存在
- 昌意 -> chang-yi: 存在

**19 段 false negative: 0** (完美提取，世系链全部捕获)

#### 2d-3. 25 段 (官职分封密集段)

**原文**: 舜入于大麓...而禹、皋陶、契、后稷、伯夷、夔、龙、倕、益、彭祖自尧时而皆举用...舜谓四岳曰..."皆曰：'伯禹为司空...'"禹拜稽首，让于稷、契与皋陶...舜曰："弃，黎民始饥，汝后稷播时百谷。"...舜曰："契..."...舜曰："皋陶..."...皆曰垂可。于是以垂为共工...皆曰益可...益拜稽首，让于诸臣朱虎、熊罴...皆曰伯夷可...伯夷让夔、龙...舜曰："龙..."...

**手工标注的人物**:
1. 舜 (多次)
2. 尧 (多次)
3. 丹朱
4. 禹/伯禹 (同一人)
5. 皋陶
6. 契
7. 后稷/稷 (同一人)
8. 伯夷
9. 夔
10. 龙
11. 倕
12. 益
13. 彭祖
14. 垂
15. 朱虎
16. 熊罴
17. 弃 (= 后稷)

**DB 中检查**:
- 舜 -> shun: 存在
- 尧 -> yao: 存在
- 丹朱 -> dan-zhu: 存在
- 禹/伯禹 -> yu: 存在
- 皋陶 -> gao-yao: 存在
- 契 -> xie: 存在
- 后稷/稷 -> hou-ji: 存在
- 伯夷 -> bo-yi: 存在
- 夔 -> kui: 存在
- 龙 -> long: 存在
- 倕 -> chui: 存在
- 益 -> yi: 存在
- 彭祖 -> peng-zu: 存在
- 垂 -> u5782: 存在
- 朱虎 -> u6731-u864e: 存在
- 熊罴 -> u718a-u7f74: 存在
- 弃 -> u5f03 / hou-ji: **存在但被拆为两个 person**

**问题**:
1. "弃"被建为两个 person: `hou-ji`（后稷，弃为其 surface_form）和 `u5f03`（弃，独立 person）。实际上"弃"就是后稷（周始祖），原文"舜曰：'弃，黎民始饥，汝后稷播时百谷。'"明确说明弃=后稷。**这是同人重复问题**。
2. "垂"与"倕"同人未合并（已在抽样检查中发现）。

**25 段 false negative: 0**（所有人物均被提取）
**但存在 2 处同人重复（弃/后稷、倕/垂）**

---

## 三、已知问题确认与扩展

### 3.1 "公孙" missed extraction（已确认）

- **问题**: 1 段 "姓公孙，名曰轩辕" 中的 "公孙" 未被提取为黄帝的 surface_form
- **根因**: NER prompt v1 示例中，1 段 的标注输出仅列出 "黄帝" 和 "轩辕"，未包含 "公孙"
- **影响**: 姓氏信息丢失，下游无法通过 "公孙" 搜索到黄帝
- **建议**: prompt v2 应在示例中增加 "公孙" 为 surface_form (name_type: alias)，并明确规则"姓X"中的 X 应作为 surface_form 记录

### 3.2 扩展: 姓氏类 missed extraction 普查

全文扫描所有"姓X"模式：

| 段落 | 原文 | X | 是否提取 |
|------|------|---|---------|
| 1 | "姓公孙" | 公孙 | **未提取** |
| 28 | "姓姒氏" | 姒氏/姒 | 未提取（但此处是对禹的描述，"姒"可作为禹的 alias） |
| 28 | "姓子氏" | 子氏/子 | 未提取（对契的描述） |
| 28 | "姓姬氏" | 姬氏/姬 | 未提取（对弃的描述） |

**结论**: 所有姓氏类信息均未被提取为 surface_form。这是一个**系统性遗漏**，需要在 prompt v2 中统一修复。

---

## 四、全库扫描发现的其他问题

### 4.1 同人重复（Duplicate Person）

| 实际人物 | DB 中的 person 1 | DB 中的 person 2 | 说明 |
|---------|-----------------|-----------------|------|
| 弃/后稷 | hou-ji (后稷) | u5f03 (弃) | 弃=后稷，周始祖 |
| 倕/垂 | chui (倕) | u5782 (垂) | 通假字：倕=垂 |

**根因**: merge_persons() 按 name_zh 合并，但 LLM 在不同段落中用了不同的 name_zh（25 段列举用"倕"，26 段叙功用"垂"），导致未合并。

### 4.2 错误关联（Wrong Association）

| surface_form | 当前归属 | 正确归属 | 说明 |
|-------------|---------|---------|------|
| 帝舜 | yao (尧) | shun (舜) | "帝舜"只能指舜 |

**根因**: 某段落中"帝舜"出现在以尧为主语的段落上下文中（如 18/27 段），LLM 可能将其归入了尧的 surface_forms。

### 4.3 冗余实体（Spurious Person）

| person | slug | 说明 |
|--------|------|------|
| 羲氏 | u7fb2-u6c0f | "羲"是羲仲/羲叔的合称省称，不应独立建人 |
| 和氏 | u548c-u6c0f | "和"是和仲/和叔的合称省称，不应独立建人 |
| 荤粥 | u8364-u7ca5 | 北方游牧部族名，非个人，不应建为 person |

**说明**: "荤粥"（匈奴前身），3 段 "北逐荤粥" 明确是族群/国名而非人名。按 prompt 规则"氏族/部落名...如果是作为政治实体而非个人提及，不提取"，此处不应提取。

### 4.4 四凶建模问题

| person | slug | 说明 |
|--------|------|------|
| 浑沌 | u6d51-u6c8c | 帝鸿氏之不才子的绰号 |
| 穷奇 | u7a77-u5947 | 少暤氏之不才子的绰号 |
| 梼杌 | u68bc-u674c | 颛顼氏之不才子的绰号 |
| 饕餮 | u9955-u992e | 缙云氏之不才子的绰号 |
| 帝鸿氏 | u5e1d-u9e3f-u6c0f | 浑沌之来源 |
| 少暤氏 | u5c11-u66a4-u6c0f | 穷奇之来源 |
| 缙云氏 | u7f19-u4e91-u6c0f | 饕餮之来源 |

四凶（浑沌、穷奇、梼杌、饕餮）在 24 段中是四位"不才子"的绰号，其真名不详。LLM 将绰号作为 person 的 primary name 建入 DB，这一做法可以接受（因为这些人确实无本名传世）。但 name_type 标为 nickname 更准确（当前标注：浑沌 nickname, 穷奇 nickname, 梼杌 nickname, 饕餮 nickname —— 已经正确）。

帝鸿氏、少暤氏、缙云氏是氏族名/氏族首领代称。严格来说它们是氏族名而非人名，但在此语境中代指具体的氏族首领，保留为 person 可以接受。

### 4.5 name_type 标注不一致

| person | surface_form | 当前 name_type | 建议 name_type | 说明 |
|--------|-------------|---------------|---------------|------|
| 黄帝 | 黄帝 | nickname (is_primary=true) | nickname | "黄帝"确实是号/尊称，标 nickname 正确；但 is_primary=true 意味着这是"主要使用名"，合理 |
| 黄帝 | 轩辕 | primary (is_primary=false) | primary | 轩辕是本名，标 primary 正确；但 is_primary=false 因为通常称"黄帝" |
| 帝喾 | 帝喾 | nickname (is_primary=true) | nickname | 同上，合理 |
| 帝喾 | 帝喾高辛者 | primary | **应改为 alias** | 这是叙述性称呼而非名字 |
| 帝挚 | 帝挚 | nickname (is_primary=true) | nickname | 合理 |
| 帝挚 | 挚 | primary (is_primary=false) | primary | 正确 |

### 4.6 Slug 质量问题

19 个 person 的 slug 使用 Unicode fallback（`u{hex}` 格式），原因是 `_PINYIN_MAP` 缺少对应条目。这些人物包括：

| slug | 人物 | 建议 slug |
|------|------|----------|
| u53f8-u9a6c-u8fc1 | 司马迁 | sima-qian |
| u548c-u6c0f | 和氏 | he-shi |
| u5782 | 垂 | chui-2 |
| u5b54-u5b50 | 孔子 | kong-zi |
| u5bb0-u4e88 | 宰予 | zai-yu |
| u5c11-u66a4-u6c0f | 少暤氏 | shao-hao-shi |
| u5e1d-u631a | 帝挚 | di-zhi |
| u5e1d-u9e3f-u6c0f | 帝鸿氏 | di-hong-shi |
| u5f03 | 弃 | qi |
| u6731-u864e | 朱虎 | zhu-hu |
| u68bc-u674c | 梼杌 | tao-wu |
| u6d51-u6c8c | 浑沌 | hun-dun |
| u718a-u7f74 | 熊罴 | xiong-pi |
| u7a77-u5947 | 穷奇 | qiong-qi |
| u7f19-u4e91-u6c0f | 缙云氏 | jin-yun-shi |
| u7fb2-u6c0f | 羲氏 | xi-shi |
| u8364-u7ca5 | 荤粥 | xun-yu |
| u9955-u992e | 饕餮 | tao-tie |
| u9a69-u515c | 驩兜 | huan-dou |

建议：在 `_PINYIN_MAP` 中补充这些条目，或引入 `pypinyin` 库自动生成。

---

## 五、总体质量评估

### 5.1 准确率估算

| 指标 | 数值 | 说明 |
|------|------|------|
| 人物识别准确率 | ~94% (58/62) | 62 人中约 4 个有问题（2 重复 + 2 冗余实体） |
| surface_form 准确率 | ~96% (89/93) | 93 条中约 4 条有问题（1 帝舜错误关联 + 1 帝喾高辛者 type 错误 + 2 姓氏缺失不计入分母） |
| 抽样正确率 | 80% (8/10) | 随机抽取 10 个 person |
| false negative | ~0% (3段全覆盖) | 3 个测试段落中人物无遗漏 |
| 同人合并率 | ~97% (60/62) | 2 对同人未合并（弃/后稷、倕/垂） |

### 5.2 主要错误类型

按严重性排序：

1. **CRITICAL - 错误关联**: "帝舜" 被挂在尧名下（影响搜索和关系展示）
2. **HIGH - 同人未合并**: 弃/后稷、倕/垂 各被拆为两个 person
3. **MEDIUM - 冗余实体**: 羲氏、和氏、荤粥 不应作为 person
4. **MEDIUM - 姓氏系统性遗漏**: "公孙""姒""子""姬"等姓氏未作为 surface_form
5. **LOW - name_type 不精确**: "帝喾高辛者"标 primary 等
6. **LOW - Slug 质量**: 19/62 (30.6%) 使用 Unicode fallback

### 5.3 总体评价

Phase A 抽取质量**总体可用**（人物识别召回率极高，false negative 接近零），但存在以下需要在 Phase B 前修复的问题：

1. 通假字/异体字合并逻辑需要增强（倕/垂）
2. 同人不同称谓的合并依赖 name_zh 字面匹配，需要更智能的消歧
3. 姓氏信息的提取规则需要在 prompt 中明确
4. 部族/国族名与人名的区分规则需要强化

---

## 六、Prompt v2 改进建议

### 6.1 必改项（Phase B 前）

1. **姓氏提取规则**: 在 prompt 中明确："姓X"中的 X 应作为该人物的 surface_form，name_type 标为 alias。在示例中补上"公孙"。

2. **通假字/异体字合并指引**: 增加规则："如果同一段或相近段落中出现通假/异体写法（如'倕'与'垂'），应在 identity_notes 中标注，以便下游合并。"

3. **合称/省称不建独立 person**: 增加规则："'羲、和'等合称/省称，如果段落中已有明确的分称（羲仲、羲叔、和仲、和叔），则合称不单独建立 person。"

4. **部族/国族排除强化**: 将"荤粥"等明确的部族名加入负面示例。

5. **"帝X"归属校验**: 增加规则："'帝舜''帝尧'等称谓只能归属于舜、尧本人，不可作为其他人物的 surface_form。"

### 6.2 建议改项（可延后）

1. **Slug 生成改进**: 引入 `pypinyin` 或扩展 `_PINYIN_MAP`
2. **name_type 细化规则**: 对"帝喾高辛者"类叙述性称呼明确标注规则
3. **四凶建模**: 考虑将四凶绰号与来源氏族通过 identity_hypotheses 关联

---

## 七、审核日志

| 时间 | 动作 | 结果 |
|------|------|------|
| 2026-04-18 | 随机抽样 10 person | 8 correct, 2 incorrect |
| 2026-04-18 | 姓/氏/族 模式扫描 | 1 missed (公孙), 1 problematic (羲氏/和氏) |
| 2026-04-18 | 名曰X 模式验证 | 全部正确 |
| 2026-04-18 | 帝X 模式验证 | 1 critical bug (帝舜→尧) |
| 2026-04-18 | False negative: 2段 | 0 遗漏 |
| 2026-04-18 | False negative: 19段 | 0 遗漏 |
| 2026-04-18 | False negative: 25段 | 0 遗漏, 2 同人重复 |
| 2026-04-18 | 全库扫描 | 2 重复, 3 冗余, 1 错误关联, 4 姓氏遗漏 |
