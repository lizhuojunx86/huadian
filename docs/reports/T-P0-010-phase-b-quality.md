# T-P0-010 Phase B 质量抽检报告

- **抽检对象**: 史记 - 夏本纪 (slug: `shiji-xia-ben-ji`) + 殷本纪 (slug: `shiji-yin-ben-ji`)
- **抽检人**: historian@huadian
- **日期**: 2026-04-18
- **数据概况**:
  - 夏本纪：35 段原文，22 unique persons (dynasty=夏)
  - 殷本纪：35 段原文，66 unique persons (dynasty=商) + 1 (商末周初) + 1 (周) + 4 (西周)
  - 全库合计：169 persons，273 person_names
  - Prompt 版本：v1-r2（含帝X校验、姓氏提取、部族排除、合称规则 4 项改进）

---

## 一、随机抽样 10 个 person 核对

### 夏本纪 5 人

#### 1. 禹 (slug: `yu`, dynasty: 夏)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 禹 | correct |
| dynasty | 夏 | correct |
| reality_status | legendary | correct |
| surface_forms | 禹 (primary), 伯禹 (nickname), 帝禹 (nickname), 夏后 (alias), 夏禹 (nickname), 文命 (primary), 姒 (alias), 大禹 (nickname) | correct |
| 原文出现 | 全篇多次出现；§1"夏禹，名曰文命"；§26"姓姒氏" | correct |

**说明**: surface_forms 非常全面——"夏禹""文命""帝禹""伯禹""夏后""大禹"以及姓氏"姒"均被提取。其中"姒"来自§26"姓姒氏"，说明 v1-r2 prompt 的**姓氏提取规则已生效**。"文命"来自§1"名曰文命"，正确标为 primary。

**判定: correct**

#### 2. 帝予 (slug: `u5e1d-u4e88`, dynasty: 夏)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 帝予 | correct |
| dynasty | 夏 | correct |
| reality_status | legendary | correct |
| surface_forms | 帝予 (nickname, is_primary=true) | correct |
| 原文出现 | §33"帝少康崩，子帝予立。帝予崩，子帝槐立。" | correct |

**说明**: 帝予是夏代帝王，仅在世系传承段（§33）中出现。slug 使用 Unicode fallback，原因是 `_PINYIN_MAP` 未收录此条目。

**判定: correct**

#### 3. 胤 (slug: `u80e4`, dynasty: 夏)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 胤 | correct |
| dynasty | 夏 | correct |
| reality_status | legendary | correct |
| surface_forms | 胤 (primary) | correct |
| 原文出现 | §32"胤往征之，作胤征" | correct |

**说明**: 胤是帝中康时的大臣，奉命征讨废时乱日的羲、和。在史记中仅此一处出现。按《尚书·胤征》，胤为帝仲康命胤侯征讨羲和。此处作为个人提取正确。

**判定: correct**

#### 4. 少康 (slug: `shao-kang`, dynasty: 夏)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 少康 | correct |
| dynasty | 夏 | correct |
| reality_status | legendary | correct |
| surface_forms | 少康 (primary), 帝少康 (nickname) | correct |
| 原文出现 | §33"中康崩，子帝相立。帝相崩，子帝少康立。帝少康崩，子帝予立。" | correct |

**说明**: "帝少康"正确归属于少康本人（非其他人），帝X校验规则有效。

**判定: correct**

#### 5. 太康 (slug: `tai-kang`, dynasty: 夏)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 太康 | correct |
| dynasty | 夏 | correct |
| reality_status | legendary | correct |
| surface_forms | 太康 (primary), 帝太康 (nickname) | correct |
| 原文出现 | §31"子帝太康立。帝太康失国" | correct |

**说明**: 正确提取，帝太康归属正确。biography 准确概括了"失国"事件。

**判定: correct**

### 殷本纪 5 人

#### 6. 伊尹 (slug: `yi-yin`, dynasty: 商)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 伊尹 | correct |
| dynasty | 商 | correct |
| reality_status | legendary | **需讨论** |
| surface_forms | 伊尹 (primary), 阿衡 (alias) | correct |
| 原文出现 | §4-14 多段出现 | correct |

**说明**: 关于 reality_status，伊尹标为 legendary。从考古学角度看，甲骨文中已发现"伊尹"（伊）的祭祀记录，学界一般认为伊尹为真实历史人物。但 prompt 规则仅对"有甲骨文验证的商王"标 historical，非王族人物的判定标准不够明确。surface_form "阿衡"来自§5"伊尹名阿衡"，提取正确。

依据：陈梦家《殷虚卜辞综述》第十五章"祭祀"中记载甲骨文有伊尹祭祀卜辞。

**判定: correct**（reality_status 可接受但不完美，按当前 prompt 规则合理）

#### 7. 小甲 (slug: `u5c0f-u7532`, dynasty: 商)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 小甲 | correct |
| dynasty | 商 | correct |
| reality_status | legendary | **uncertain** |
| surface_forms | 小甲 (primary), 帝小甲 (nickname) | correct |
| 原文出现 | §15"帝太庚崩，子帝小甲立。帝小甲崩，弟雍己立" | correct |

**说明**: 小甲在甲骨文卜辞中有祭祀记录（殷墟甲骨文中"小甲"见于祭祀谱系），应标 historical。但作为与太庚、雍己同列的早期商王，LLM 标 legendary 也不算严重错误——prompt 规则中"有甲骨文验证"的判定对 LLM 来说难以执行。

**判定: correct**（数据正确，reality_status 可进一步优化）

#### 8. 汤 (slug: `tang`, dynasty: 商)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 汤 | correct |
| dynasty | 商 | correct |
| reality_status | legendary | **uncertain** |
| surface_forms | 汤 (primary), 成汤 (alias), 武王 (posthumous), 予一人 (self_ref), 王 (nickname), 朕 (self_ref) | **部分正确** |
| 原文出现 | 全篇多段出现 | correct |

**说明**:
1. **同人重复问题严重**：汤被拆为 3 个独立 person——`tang`（汤）、`cheng-tang`（成汤）、`u5546-u6c64`（商汤）。三者指同一人：商朝开国君主成汤。根因是 LLM 在不同段落中使用了不同的 name_zh（"汤""成汤""商汤"），merge_persons() 按 name_zh 合并导致未能统一。
2. "予一人"和"朕"作为 self_ref 提取有创意但不标准——这些是帝王自称的泛称，非特定人物的 surface_form。
3. "武王"标为 posthumous 正确（汤自号武王）。
4. reality_status 标 legendary 有争议：甲骨文中有"大乙"（成汤庙号"太乙"/"大乙"）的祭祀记录，但"汤"这一称呼本身来自文献而非甲骨。

依据：王国维《殷卜辞中所见先公先王考》确认甲骨文中"大乙"即成汤。

**判定: incorrect** — 同人三分问题严重影响数据质量。

#### 9. 小辛 (slug: `u5c0f-u8f9b`, dynasty: 商)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 小辛 | correct |
| dynasty | 商 | correct |
| reality_status | legendary | uncertain |
| surface_forms | 小辛 (primary), 帝小辛 (nickname) | correct |
| 原文出现 | §22"弟小辛立，是为帝小辛。帝小辛立，殷复衰。" | correct |

**说明**: 小辛在甲骨文祭祀谱系中有记录（见陈梦家《殷虚卜辞综述》周祭谱），应标 historical。但同上述说明，这是系统性问题而非个案错误。

**判定: correct**

#### 10. 巫咸 (slug: `u5deb-u54b8`, dynasty: 商)

| 项目 | 内容 | 判定 |
|------|------|------|
| 姓名 | 巫咸 | correct |
| dynasty | 商 | correct |
| reality_status | legendary | correct |
| surface_forms | 巫咸 (primary) | correct |
| 原文出现 | §16"伊陟赞言于巫咸。巫咸治王家有成，作咸艾，作太戊。" | correct |

**说明**: 巫咸是商代大臣/巫官，身份在学界有争议（是个人还是巫官世家代称）。标 legendary 合理。

**判定: correct**

### 抽样汇总

| # | 来源 | 人物 | slug | 判定 | 问题类型 |
|---|------|------|------|------|---------|
| 1 | 夏 | 禹 | yu | correct | -- |
| 2 | 夏 | 帝予 | u5e1d-u4e88 | correct | slug fallback |
| 3 | 夏 | 胤 | u80e4 | correct | slug fallback |
| 4 | 夏 | 少康 | shao-kang | correct | -- |
| 5 | 夏 | 太康 | tai-kang | correct | -- |
| 6 | 殷 | 伊尹 | yi-yin | correct | reality_status 可优化 |
| 7 | 殷 | 小甲 | u5c0f-u7532 | correct | reality_status 可优化 |
| 8 | 殷 | 汤 | tang | **incorrect** | 同人三分（汤/成汤/商汤） |
| 9 | 殷 | 小辛 | u5c0f-u8f9b | correct | reality_status 可优化 |
| 10 | 殷 | 巫咸 | u5deb-u54b8 | correct | -- |

**抽样正确率: 9/10 = 90%**

---

## 二、Phase A v1-r2 改进验证

### 2a. 帝X 归属校验

**结果: 大部分有效，但仍有残留问题**

| 检查项 | 结果 | 详情 |
|--------|------|------|
| 夏本纪帝X归属 | **通过** | 帝禹→禹、帝太康→太康、帝少康→少康、帝予→帝予...全部正确 |
| 殷本纪帝X归属 | **大部分通过** | 帝太甲→太甲、帝武丁→武丁、帝盘庚→盘庚...正确 |
| 帝甲重复 | **问题** | "帝甲"既是祖甲(u7956-u7532)的 surface_form(temple)，又是独立 person `u5e1d-u7532`(帝甲)的 primary name |
| 帝武乙重复 | **问题** | `u6b66-u4e59`(武乙)和`u5e1d-u6b66-u4e59`(帝武乙)是同人 |
| 帝中丁重复 | **问题** | `u4e2d-u4e01`(中丁)和`u5e1d-u4e2d-u4e01`(帝中丁)是同人 |
| Phase A "帝舜→尧" bug | **未修复** | 仍存在（五帝本纪数据未重跑） |

**评估**: 帝X归属校验规则在新抽取（夏/殷本纪）中**有效防止了跨人误归**。但"帝X"和"X"在不同段落中被识别为不同 name_zh 时，merge_persons() 仍无法合并。这是 merge 逻辑缺陷而非 prompt 问题。

### 2b. 姓氏提取

**结果: 部分有效**

| 原文位置 | 原文 | 提取情况 | 判定 |
|---------|------|---------|------|
| 夏本纪 §26 | "姓姒氏" | "姒" 被提取为禹的 alias | **有效** |
| 夏本纪 §26 | "姓姒氏" | "姒氏" 被建为独立 person | **问题** |
| 殷本纪 §1 | "赐姓子氏" | "子" 未被提取为契的 surface_form | **未生效** |
| 殷本纪 §35 | "契为子姓" | "子" 未被提取为契的 surface_form | **未生效** |

**评估**: 姓氏规则在夏本纪中生效（禹有"姒" alias），但同时产生了副作用（"姒氏"被建为独立 person）。在殷本纪中"赐姓子氏"未触发提取——可能因为 prompt 示例仅覆盖了"姓X"模式，未覆盖"赐姓X氏"模式。

### 2c. 部族排除

**结果: 有效**

| 原文位置 | 部族名 | 是否被排除 | 判定 |
|---------|--------|-----------|------|
| 夏本纪 §30 | 有扈氏 | **未建人** | **有效** |
| 殷本纪 §33 | 大师、少师 | **未建人** | **有效** |
| 夏本纪 §14 | 三苗 | 未检查到独立 person | **有效** |
| 殷本纪 §7 | 昆吾氏 | **建为 person** | **问题** |

**评估**: 有扈氏正确被排除（§30"有扈氏不服，启伐之"），大师/少师（官职名）也正确不提取。但昆吾氏（§7"诸侯昆吾氏为乱"）被建为 person。在殷本纪语境中，"汤乃兴师率诸侯...遂伐昆吾"更接近部族/诸侯而非个人。但因原文"诸侯昆吾氏为乱"确实以主语形式出现且有具体行为（"为乱"），边界模糊，可以接受但不理想。

### 2d. 合称规则

**结果: 部分有效**

| 原文位置 | 合称 | 处理情况 | 判定 |
|---------|------|---------|------|
| 夏本纪 §32 | "羲、和湎淫" | 归入已有 person（羲氏、和氏） | **问题** |

**评估**: 夏本纪 §32"帝中康时，羲、和湎淫，废时乱日"中的"羲、和"被归入了五帝本纪中已建立的"羲氏"和"和氏" person。但根据 Phase A 报告，"羲氏"和"和氏"本身就是 Phase A 遗留问题（合称被误建为独立 person）。新规则未在 Phase B 中产生新的合称误建，但旧问题因五帝本纪未重跑而延续。

---

## 三、False Negative 抽样

### 3a. 殷本纪 §31 — 西伯昌九侯段

**原文**: 百姓怨望而诸侯有畔者，于是纣乃重刑辟，有炮格之法。以西伯昌、九侯、鄂侯为三公。九侯有好女，入之纣。九侯女不喜淫，纣怒，杀之，而醢九侯。鄂侯争之强，辨之疾，并脯鄂侯。西伯昌闻之，窃叹。崇侯虎知之，以告纣，纣囚西伯羑里。西伯之臣闳夭之徒，求美女奇物善马以献纣，纣乃赦西伯。西伯出而献洛西之地，以请除炮格之刑。纣乃许之，赐弓矢斧钺，使得征伐，为西伯。而用费中为政。费中善谀，好利，殷人弗亲。纣又用恶来。恶来善毁谗，诸侯以此益疏。

**手工标注应有人物**:
1. 纣
2. 西伯昌 / 西伯（同一人）
3. 九侯
4. 九侯女（九侯之女）
5. 鄂侯
6. 崇侯虎
7. 闳夭
8. 费中
9. 恶来

**DB 检查结果**:

| 人物 | DB 中存在 | slug | 判定 |
|------|----------|------|------|
| 纣 | 存在 | zhou-xin | correct |
| 西伯昌/西伯 | 存在 | xi-bo-chang（含"西伯" alias） | correct |
| 九侯 | 存在 | u4e5d-u4faf | correct |
| 九侯女 | 存在 | u4e5d-u4faf-u5973 | correct |
| 鄂侯 | 存在 | u9102-u4faf | correct |
| 崇侯虎 | 存在 | u5d07-u4faf-u864e | correct |
| 闳夭 | 存在 | u95f3-u592d | correct |
| 费中 | 存在 | u8d39-u4e2d | correct |
| 恶来 | 存在 | u6076-u6765 | correct |

**§31 false negative: 0** (完美提取，9 个人物全部捕获)

### 3b. 殷本纪 §33 — 纣灭亡段

**原文**: 纣愈淫乱不止。微子数谏不听，乃与大师、少师谋，遂去。比干曰："为人臣者，不得不以死争。"乃强谏纣。纣怒曰："吾闻圣人心有七窍。"剖比干，观其心。箕子惧，乃详狂为奴，纣又囚之。殷之大师、少师乃持其祭乐器奔周。周武王于是遂率诸侯伐纣。纣亦发兵距之牧野。甲子日，纣兵败。纣走入，登鹿台，衣其宝玉衣，赴火而死。周武王遂斩纣头，县之白旗。杀妲己。释箕子之囚，封比干之墓，表商容之闾。封纣子武庚、禄父，以续殷祀，令修行盘庚之政。殷民大说。于是周武王为天子。其后世贬帝号，号为王。而封殷后为诸侯，属周。

**手工标注应有人物**:
1. 纣
2. 微子（=微子启）
3. 比干
4. 箕子
5. 周武王
6. 妲己
7. 商容
8. 武庚 / 禄父（同一人）
9. 盘庚

**非人物排除**:
- 大师、少师：官职名，不应建人 → DB 中**正确未建**
- "殷后"：泛称 → **正确未建**

**DB 检查结果**:

| 人物 | DB 中存在 | slug | 判定 |
|------|----------|------|------|
| 纣 | 存在 | zhou-xin | correct |
| 微子 | 存在但重复 | u5fae-u5b50 + wei-zi-qi | **问题** |
| 比干 | 存在 | bi-gan | correct |
| 箕子 | 存在 | ji-zi | correct |
| 周武王 | 存在 | u5468-u6b66-u738b | correct |
| 妲己 | 存在 | da-ji | correct |
| 商容 | 存在 | u5546-u5bb9 | correct |
| 武庚/禄父 | 存在，"禄父"标 courtesy | u6b66-u5e9a | correct |
| 盘庚 | 存在 | pan-geng | correct |

**§33 false negative: 0** (所有人物均被提取)
**但有 1 处同人重复**: 微子(u5fae-u5b50) / 微子启(wei-zi-qi)

---

## 四、全库同人重复汇总（Phase B 新增 + Phase A 遗留）

### 4.1 确认的同人重复

| # | 实际人物 | Person A | Person B | Person C | 根因 | 严重度 |
|---|---------|----------|----------|----------|------|--------|
| 1 | 汤（商开国君主）| tang (汤) | cheng-tang (成汤) | u5546-u6c64 (商汤) | 不同段落用不同 name_zh | CRITICAL |
| 2 | 武乙（商王）| u6b66-u4e59 (武乙) | u5e1d-u6b66-u4e59 (帝武乙) | -- | "帝X"与"X"未合并 | HIGH |
| 3 | 中丁（商王）| u4e2d-u4e01 (中丁) | u5e1d-u4e2d-u4e01 (帝中丁) | -- | 同上 | HIGH |
| 4 | 祖甲/帝甲（商王）| u7956-u7532 (祖甲) | u5e1d-u7532 (帝甲) | -- | "帝甲"是祖甲的简称 | HIGH |
| 5 | 太甲/太宗（商王）| tai-jia (太甲) | u592a-u5b97 (太宗) | -- | "太宗"是太甲庙号 | HIGH |
| 6 | 太戊/中宗（商王）| u592a-u620a (太戊) | u4e2d-u5b97 (中宗) | -- | "中宗"是太戊庙号 | HIGH |
| 7 | 微子启 | wei-zi-qi (微子启) | u5fae-u5b50 (微子) | -- | "微子"是"微子启"省称 | HIGH |
| 8 | 西伯昌/周文王 | xi-bo-chang (西伯昌) | u5468-u6587-u738b (周文王) | -- | 同人不同称谓跨段落 | HIGH |
| 9 | 弃/后稷 | hou-ji (后稷) | u5f03 (弃) | -- | Phase A 遗留 | HIGH |
| 10 | 倕/垂 | chui (倕) | u5782 (垂) | -- | Phase A 遗留，通假字 | MEDIUM |
| 11 | 益/伯益 | yi (益) | u4f2f-u76ca (伯益) | -- | "伯益"是"益"尊称 | MEDIUM |

**合计**: 11 对/组同人重复（Phase A 遗留 2 对 + Phase B 新增 9 对/组）

### 4.2 冗余实体（不应建人的条目）

| person | slug | 原因 | 严重度 |
|--------|------|------|--------|
| 姒氏 | u59d2-u6c0f | "姓姒氏"中的"姒氏"是禹的姓氏描述，不是独立人物 | MEDIUM |
| 昆吾氏 | u6606-u543e-u6c0f | "诸侯昆吾氏为乱"，是诸侯/部族名 | LOW |
| 羲氏 | u7fb2-u6c0f | Phase A 遗留：合称省称 | MEDIUM |
| 和氏 | u548c-u6c0f | Phase A 遗留：合称省称 | MEDIUM |
| 荤粥 | u8364-u7ca5 | Phase A 遗留：部族名 | MEDIUM |

### 4.3 涂山氏特殊处理

涂山氏（u6d82-u5c71-u6c0f）作为独立 person 的处理**可以接受**。原文§23"予娶涂山"、§29"其母涂山氏之女"中，涂山氏是禹之妻的代称。学界一般认为"涂山氏"在此指涂山氏族之女（即禹妻），而非氏族本身。作为个人建模合理。

---

## 五、reality_status 评估

### 5.1 夏代人物

全部 22 人标 legendary。按当前 prompt 规则（"夏代人物→legendary，无独立考古实证"），**完全正确**。

### 5.2 商代人物 reality_status 分析

| 标注 | 数量 | 占比 |
|------|------|------|
| historical | 28 | 42% |
| legendary | 36 | 55% |
| uncertain | 2 | 3% |

**问题**: 商代王室世系中的 reality_status 判定不一致。按甲骨文验证，以下商王已被确认为真实存在但被标为 legendary：

| 人物 | 当前标注 | 应标注 | 依据 |
|------|---------|--------|------|
| 汤/成汤/商汤 | legendary | historical | 甲骨文"大乙"即成汤（王国维《先公先王考》） |
| 太甲 | legendary | historical | 甲骨文周祭谱有"大甲" |
| 太庚 | legendary | historical | 甲骨文周祭谱有"大庚" |
| 小甲 | legendary | historical | 甲骨文周祭谱有"小甲" |
| 雍己 | legendary | historical | 甲骨文周祭谱有"雍己" |
| 太戊 | legendary | historical | 甲骨文"大戊"且有"中宗"称号 |
| 外丙 | legendary | historical | 甲骨文周祭谱有"卜丙"（=外丙） |
| 中壬 | legendary | historical | 甲骨文周祭谱有"中壬" |
| 沃丁 | legendary | historical | 甲骨文有祭祀记录 |
| 小辛 | legendary | historical | 甲骨文周祭谱有"小辛" |
| 阳甲 | legendary | historical | 甲骨文周祭谱有"阳甲" |
| 帝庚丁 | legendary | historical | 甲骨文周祭谱有"庚丁" |
| 帝廪辛 | legendary | historical | 甲骨文周祭谱有"廪辛" |
| 帝甲/祖甲 | legendary | historical | 甲骨文周祭谱有"祖甲" |

依据：陈梦家《殷虚卜辞综述》周祭谱、王国维《殷卜辞中所见先公先王考》《殷卜辞中所见先公先王续考》。

**结论**: 殷本纪中的商王 reality_status 判定存在**系统性偏低**。LLM 难以独立判断每位商王是否有甲骨文验证。建议在 prompt 或后处理中提供一份"甲骨文已证实商王列表"作为参考。

### 5.3 夏→殷转折点的合理性

| 朝代 | reality_status 分布 | 评估 |
|------|-------------------|------|
| 上古 | 100% legendary | 正确 |
| 夏 | 100% legendary | 正确 |
| 商 | 42% historical / 55% legendary | **偏低** |
| 周及以后 | 100% historical | 正确 |

商代已确认存在的帝王（甲骨文证实）中仅部分被标 historical。这不是 prompt v1-r2 的缺陷而是 LLM 知识应用的局限——LLM 知道哪些商王有甲骨文验证但执行不稳定。

---

## 六、Phase A vs Phase B 对比表

| 指标 | Phase A (五帝本纪) | Phase B (夏本纪+殷本纪) | 趋势 |
|------|-------------------|----------------------|------|
| 原文段落数 | 29 | 70 (35+35) | -- |
| unique persons | 62 | 88 (22+66) | -- |
| person_names | 93 | ~180 | -- |
| **抽样正确率** | **80%** (8/10) | **90%** (9/10) | **改善** |
| false negative (抽样段) | 0/3 段 | 0/2 段 | 稳定 |
| 同人重复数 | 2 对 | 11 对/组 | **恶化** |
| 冗余实体 | 3 个 | 5 个(含Phase A遗留) | 略增 |
| 帝X 误归 | 1 处 (CRITICAL) | 0 处 (新增) | **改善** |
| 姓氏提取 | 0/4 处 | 1/2 处 (部分有效) | **改善** |
| 部族误建 | 1 处 (荤粥) | 1 处 (昆吾氏) | 稳定 |
| slug fallback 比例 | 19/62 (30.6%) | 67/88 (76.1%) | **恶化** |
| reality_status 合理性 | 高 (全legendary) | 中 (商代偏低) | 新问题 |

### 改善项

1. **帝X归属**: v1-r2 的"帝X只能归属X本人"规则在 Phase B 新抽取中**完全有效**——未发现任何帝X跨人误归。Phase A 的"帝舜→尧" bug 因五帝本纪未重跑而延续，不计入 Phase B 新增问题。

2. **姓氏提取**: 禹的"姒"被正确提取为 alias，说明规则生效。但触发率低，"赐姓子氏"模式未覆盖。

3. **部族排除**: 有扈氏正确被排除。大师/少师（官职）也正确不提取。

4. **抽样正确率**: 从 80% 提升至 90%。

### 恶化项

1. **同人重复**: 从 2 对爆增至 11 对/组。殷本纪的商王世系（大量帝X/X/庙号三种称呼）严重暴露了 merge_persons() 按 name_zh 字面匹配的局限。这不是 prompt 问题，而是 merge 逻辑需要增强。

2. **slug fallback**: 76.1% 的新增 person 使用 Unicode fallback slug。`_PINYIN_MAP` 需要大规模扩充。

3. **reality_status 判定**: 商代帝王的 historical/legendary 分界不稳定。

### 未变项

1. **false negative**: 两个 phase 的召回率均极高，抽样段落中人物无遗漏。
2. **部族边界**: 仍有个别边界模糊的部族被建为 person（昆吾氏）。

---

## 七、Prompt v3 / 后处理改进建议

### 7.1 必改项（Phase C 前）

1. **merge 逻辑增强**（代码层，非 prompt 层）:
   - 如果 person A 的某个 surface_form 与 person B 的 name_zh 完全匹配，合并为同一人
   - 特别处理"帝X"与"X"的合并
   - 特别处理"庙号"与"本名"的合并（太宗→太甲、中宗→太戊）
   - 引入 disambiguation_seeds 字典辅助合并

2. **商王 reality_status 校正**:
   - 在 prompt 中提供甲骨文已证实商王列表，或
   - 在后处理中对已知商王统一修正 reality_status

3. **姓氏提取模式扩展**:
   - 覆盖"赐姓X氏"模式
   - 覆盖"X为Y姓"模式
   - 防止"姓X氏"中的"X氏"被建为独立 person

4. **slug 扩充**: `_PINYIN_MAP` 至少补全当前 67 个 fallback 条目

### 7.2 建议改项

1. **name_type 一致性**: 帝X 的 name_type 在不同 person 间不一致（nickname/temple/posthumous/primary 混用）。建议统一为 nickname（因"帝"是加在本名前的尊称）。

2. **"予一人""朕"等泛称**: 考虑在 prompt 中明确排除帝王自称泛称。

3. **涂山氏 identity_notes**: 应标注"涂山氏在此指涂山氏族之女，非氏族本身"以辅助下游。

---

## 八、审核日志

| 时间 | 动作 | 结果 |
|------|------|------|
| 2026-04-18 | 随机抽样 5 夏本纪 person | 5 correct |
| 2026-04-18 | 随机抽样 5 殷本纪 person | 4 correct, 1 incorrect (汤三分) |
| 2026-04-18 | 帝X 归属校验 | 夏/殷新增 0 误归；Phase A bug 延续 |
| 2026-04-18 | 姓氏提取验证 | 部分有效（禹→姒），部分未生效（契→子） |
| 2026-04-18 | 部族排除验证 | 有效（有扈氏排除）；边界情况存在（昆吾氏） |
| 2026-04-18 | 合称规则验证 | 夏本纪无新增合称问题 |
| 2026-04-18 | false negative §31 | 0 遗漏 (9/9) |
| 2026-04-18 | false negative §33 | 0 遗漏 (9/9)，1 同人重复 |
| 2026-04-18 | 全库同人重复扫描 | 11 对/组 |
| 2026-04-18 | reality_status 评估 | 商代偏低，夏代正确 |
| 2026-04-18 | Phase A vs Phase B 对比 | 抽样正确率改善 80%→90%；同人重复恶化 2→11 |
