# T-P0-006-ε Stage 3 — Historian Merge Review

> **角色**: 古籍专家 (historian@huadian)
> **日期**: 2026-04-28
> **输入**: `dry-run-resolve-2026-04-28.md` (Run ID `c9f9a1d8-37e9-452c-8124-e61e4fb2ba03`)
> **状态**: Stage 4 unblock — PE 可按本报告执行 apply_merges
> **章**: 《史记·高祖本纪》（卷八）
> **DB baseline**: 748 active persons / merge_log 92 / V1-V11 全绿

---

## 0. 审核原则

1. **split 优先**：不确定时 split（独立保留）；不硬猜，不"为了减负而合并"
2. **dynasty 校验**：跨国/跨代同名/同号必须核对 dynasty 字段一致性；NER dynasty 标记错的 case 单列 §4 衍生债
3. **source_type 标注**：每组证据标注来源类型
   - `in_chapter` — 《史记·高祖本纪》原文段落
   - `other_classical` — 其他史源（《史记·项羽本纪》/《陈涉世家》/《秦始皇本纪》/《吕太后本纪》/《汉书》/《左传》等）
   - `wikidata` — QID + label
   - `scholarly` — 学术研究 / 现代考据
   - `structural` — 基于 NER 结构特征（slug 重复、surface 共享）推断
4. **前序裁决引用**：本次 23 组中部分为 T-P0-006-γ 秦本纪 / T-P0-006-δ 项羽本纪 resolver 残留，标注前序 commit + 组号映射
5. **textbook-fact 路径**：公认本名/字/号/尊号关系按 `manual_textbook_fact` merge rule 标注。本 sprint 累计 2 例（G8 嬴政→始皇帝 + G11 陈胜→陈涉），叠加项目历史 2 例（T-P1-025 重耳→晋文公 + T-P0-006-δ G15 项籍→项羽）= **累计 4 例，触发 ADR-014 addendum 起草建议**（≥3 阈值，详见 §1 末尾说明 + §4.1）
6. **slug 重复 dedup**：5 对（G16/G18/G19/G20/G22/G23）走 `R1+structural-dedup`（与秦γ G14 同型，pinyin + unicode tier-s 共存清理），non-historical 判定
7. **cross-chapter 新实例标注**：项羽本纪 δ apply 已建立的 entity（如熊心、刘邦、项羽）被本章新 NER 实例 propose 与 entity 自身合并时，须明示"是 cross-chapter 新实例 vs 重复 propose"，避免 PE Stage 4 双 apply

---

## 1. §3.1 高置信度组（15 组）

### Group 3 — approve

| 字段 | 值 |
|------|-----|
| Merge | 秦王 → 子婴 |
| 裁决 | **approve** |
| merge_rule | R1+historian-confirm |
| source_type | in_chapter, other_classical |
| 证据 | 《史记·高祖本纪》："沛公至霸上……秦王子婴素车白马，系颈以组，封皇帝玺符节，降轵道旁。"《史记·秦始皇本纪》："立二世之兄子公子婴为秦王。"子婴（?–前206）为秦末降王，"秦王"在高祖本纪降秦段语境下唯一指子婴（非始皇帝/二世）。 |
| 理由 | 同一人，封号→本名关系；高祖本纪降秦语境无歧义 |

### Group 8 — approve (manual_textbook_fact ★ #3)

| 字段 | 值 |
|------|-----|
| Merge | 嬴政 → 始皇帝 |
| 裁决 | **approve** |
| merge_rule | **manual_textbook_fact** |
| source_type | in_chapter, other_classical |
| canonical 方向 | **始皇帝**（尊号 = 通行称呼，与 #1 重耳→晋文公"庙号方向"先例一致） |
| 证据 | 《史记·秦始皇本纪》："王初并天下，自以为德兼三皇、功过五帝……议帝号……朕为始皇帝。"嬴政（前259–前210）为秦庄襄王之子、秦国国君（前247–前221），统一六国后自尊号"始皇帝"。《史记·高祖本纪》追述秦事段（"始皇帝东游"等）的"始皇帝"即嬴政。中国史学常识级知识，无任何学术争议。 |
| 理由 | 名（嬴政）↔ 尊号（始皇帝/秦始皇）关系，textbook fact，跨史源全部一致 |
| 先例 | T-P1-025 重耳→晋文公（#1，名→庙号）+ T-P0-006-δ G15 项籍→项羽（#2，名→字）= 项目历史 2 例；本组为**第 3 例**，正式触发 ≥3 阈值 |
| precedent 累积 | **textbook-fact 案例数 → 3/3 阈值首次触达**（与 G11 同 sprint 触发，详见下条） |

### Group 9 — approve

| 字段 | 值 |
|------|-----|
| Merge | 二世 → 秦二世；胡亥 → 秦二世 |
| 裁决 | **approve** |
| merge_rule | R1+historian-confirm（**保守路径，非 manual_textbook_fact**） |
| source_type | in_chapter, other_classical |
| canonical 方向 | **秦二世**（state-prefix 全称，避免后续"二世"歧义污染） |
| 证据 | 《史记·秦始皇本纪》："二世皇帝元年……名曰胡亥。"胡亥（前230–前207）为秦始皇少子，前210 即位，称"二世皇帝"或"秦二世"。《史记·高祖本纪》："二世元年秋"等段落"二世"即胡亥。 |
| 理由 | 同一人，名（胡亥）↔ 即位代号（秦二世）；语境无歧义 |
| **不归 textbook-fact 的理由（重要）** | **"二世"作为通用即位代号在中国史中歧义严重**：周二世（虚指）、汉二世（汉惠帝刘盈）、唐二世（唐太宗李世民）、明二世（建文帝）等。"秦二世↔胡亥" 单独成立为 textbook-fact，但本组 propose 包含**裸"二世"**（不带国号前缀），违反 textbook-fact 准则隐含条件 #2 "surface 无歧义"。**本组归 R1+historian-confirm，并将"二世"加入 textbook-fact 准则的"反例"清单**（应在 ADR-014 addendum 草拟时明示：通用即位代号/排序词不构成 textbook-fact 充分条件，必须带 state/dynasty 前缀） |
| 衍生作用 | 这一保守路径裁定将影响未来"二世"/"三世"/"少帝"等通用排序词的 merge 准则 |

### Group 11 — approve (manual_textbook_fact ★ #4)

| 字段 | 值 |
|------|-----|
| Merge | 陈胜 → 陈涉 |
| 裁决 | **approve** |
| merge_rule | **manual_textbook_fact** |
| source_type | in_chapter, other_classical |
| canonical 方向 | **陈涉**（字方向，与 #2 项籍→项羽"字方向"先例一致；篇名《史记·陈涉世家》以字立篇与《史记·项羽本纪》以字立篇 isomorphic） |
| 证据 | 《史记·陈涉世家》开篇："**陈胜者，阳城人也，字涉。吴广者，阳夏人也，字叔。**"胜为名（míng），涉为字（zì）。中国史学常识级知识，无任何学术争议。《汉书·陈胜传》同载。《史记·高祖本纪》追述秦末段"陈涉首事"等指陈胜=陈涉。 |
| 理由 | 名/字关系，textbook fact；与 #2 项籍↔项羽 同型（名↔字），canonical 选字方向以维持 manual_textbook_fact rule 一致性 |
| 先例 | #1 重耳→晋文公（Sprint F T-P1-025） + #2 项籍→项羽（Sprint G T-P0-006-δ G15） + #3 嬴政→始皇帝（本 sprint G8） + **#4 本组** |
| precedent 累积 | **textbook-fact 案例数 → 4/3 阈值已超额**，ADR-014 addendum 起草由架构师后续动作（衍生债 §4.1，候选 T-P1-030） |

> **§1 末尾追加（textbook-fact 累计声明）**：本 sprint 单独贡献 #3、#4 两例 manual_textbook_fact，叠加项目历史先例 #1、#2 = **累计 4 例，已触发 ADR-014 addendum 起草建议**。本 historian session 不起草 addendum（架构师后续动作），仅在 §4.1 登记候选 task ID。同时 G9 胡亥↔二世/秦二世 走保守路径 R1+historian-confirm 的"二世通用排序词不构成 textbook-fact"裁决，将作为 addendum"反例清单"的实例化材料。

### Group 12 — approve

| 字段 | 值 |
|------|-----|
| Merge | 黥布 → 英布 |
| 裁决 | **approve** |
| merge_rule | R1+historian-confirm |
| source_type | in_chapter, other_classical |
| canonical 方向 | **英布**（本名优先；"黥布"为受秦黥刑后世人之称，类似绰号） |
| 证据 | 《史记·黥布列传》开篇："**黥布者，六人也，姓英氏。秦时为布衣。**少年，有客相之曰：'当刑而王。'及壮，坐法黥。布欣然笑曰：'人相我当刑而王，几是乎？'"英布（?–前196），秦末楚汉名将，先被项羽封九江王，后归汉封淮南王。"黥布"因其受黥刑得名，《史记·高祖本纪》"九江王布"/"淮南王布"皆指英布。 |
| 理由 | 同一人，本名↔ 绰号关系；史源一致 |

### Group 14 — approve

| 字段 | 值 |
|------|-----|
| Merge | 卿子冠军 → 宋义 |
| 裁决 | **approve** |
| merge_rule | R1+historian-confirm |
| source_type | in_chapter, other_classical |
| canonical 方向 | **宋义**（本名优先；"卿子冠军"为楚怀王熊心所封封号） |
| 证据 | 《史记·项羽本纪》："楚王召宋义与计事而大说之，因置以为上将军，项羽为次将……号为卿子冠军。"宋义（?–前207），秦末楚怀王所立上将军，后被项羽斩于安阳。"卿子冠军"为其封号，《史记·高祖本纪》追述楚汉段同载。 |
| 理由 | 同一人，本名↔ 封号关系；高祖本纪/项羽本纪一致 |

### Group 15 — approve

| 字段 | 值 |
|------|-----|
| Merge | 赵王歇 → 赵歇 |
| 裁决 | **approve** |
| merge_rule | R1+historian-confirm |
| source_type | in_chapter, other_classical |
| canonical 方向 | **赵歇**（本名优先；"赵王歇" = "赵王" + "歇" 为全称） |
| 证据 | 《史记·项羽本纪》："立赵歇为代王。"《史记·高祖本纪》："韩信、张耳已破赵，斩陈余、赵王歇。"赵歇（?–前204），秦末赵国宗室，先被陈余张耳立为赵王，后改为代王，再复立赵王，前 204 兵败死。"赵王歇" = "赵王（封号）+ 歇（名）"全称 异写。 |
| 理由 | 同一人，全称 ↔ 简称关系 |

### Group 16 — approve (structural-dedup)

| 字段 | 值 |
|------|-----|
| Merge | 纪信 (unicode slug) ↔ 纪信 (pinyin slug `ji-xin`) |
| 裁决 | **approve** |
| merge_rule | R1+structural-dedup |
| source_type | structural |
| 证据 | 同一人的两个 person entity，因 Stage 0 新增 tier-s-slugs.yaml `ji-xin` 与已有 unicode hex slug 共存。Sprint J Stage 0 tier-s 扩列副作用，与秦γ G14（秦孝公 unicode/pinyin 双 slug）同型。 |
| 理由 | slug dedup（pinyin + unicode 共存清理），无历史判断；canonical 由 ADR-010 select_canonical 决定（pinyin slug 优先以与 tier-s 命名规约一致） |
| 注 | 纪信（?–前204）：刘邦谋臣，荥阳被围时假扮汉王使刘邦突围，被项羽烹杀。本组无歧义 |

### Group 17 — approve

| 字段 | 值 |
|------|-----|
| Merge | 魏王豹 → 魏豹 |
| 裁决 | **approve** |
| merge_rule | R1+historian-confirm |
| source_type | in_chapter, other_classical |
| canonical 方向 | **魏豹**（本名优先；"魏王豹" = "魏王" + "豹"） |
| 证据 | 《史记·魏豹彭越列传》："魏豹者，故魏诸公子也。其兄魏咎，故魏时封为宁陵君。"魏豹（?–前204），战国魏国王族后裔，秦末复立魏国，被项羽封为西魏王，后被韩信俘斩。《史记·高祖本纪》"魏王豹"与"魏豹"同指。 |
| 理由 | 同一人，全称 ↔ 简称关系 |

### Group 18 — approve (structural-dedup)

| 字段 | 值 |
|------|-----|
| Merge | 郑昌 (unicode slug) ↔ 郑昌 (pinyin slug) |
| 裁决 | **approve** |
| merge_rule | R1+structural-dedup |
| source_type | structural |
| 证据 | slug dedup（pinyin + unicode 共存清理），与 G16 同型 |
| 理由 | 纯技术性去重；canonical 由 ADR-010 决定 |
| 注 | 郑昌：项羽所立韩王，前 205 被韩王信攻破，与 Group 19/20/22/23 同为 Stage 0 tier-s 副作用 |

### Group 19 — approve (structural-dedup)

| 字段 | 值 |
|------|-----|
| Merge | 田横 (unicode slug) ↔ 田横 (pinyin slug) |
| 裁决 | **approve** |
| merge_rule | R1+structural-dedup |
| source_type | structural |
| 证据 | slug dedup |
| 理由 | 纯技术性去重 |
| 注 | 田横（?–前202），田齐宗室，秦末楚汉时期数次自立齐王后亡命海岛；高祖称帝后召降途中自杀。本组本身不歧义；但需注意"齐王"surface 与 G13 田氏齐王序列相关（见 G13） |

### Group 20 — approve (structural-dedup + R1)

| 字段 | 值 |
|------|-----|
| Merge | 刘太公 (unicode) ↔ 刘太公 (pinyin) ↔ 太公 |
| 裁决 | **approve** |
| merge_rule | R1+structural-dedup（前两者）+ R1+historian-confirm（"太公"→ 刘太公） |
| source_type | in_chapter, other_classical, structural |
| canonical 方向 | **刘太公**（pinyin slug，全称） |
| 证据 | 《史记·高祖本纪》："父曰太公"；《史记·项羽本纪》："汉王之父太公、吕后为楚所获"；高祖本纪/项羽本纪/吕太后本纪中"太公"在汉初语境唯一指刘邦之父刘煓（一说刘执嘉）。Sprint G T-P0-006-δ Group 20 已 approve "太公→刘太公"（commit `e83a7a3`）。 |
| 理由 | 3 person entity 实为同一人：2 个 slug-dedup（同一"刘太公"）+ 1 个语境短称合并（"太公"在汉初无歧义）。Sprint G 已对 entity-level "太公→刘太公" 做过合并；本组的"太公"为高祖本纪 NER 新实例（cross-chapter 新 person entity），与 Sprint G 已合并的"太公"alias 不冲突 |
| 注 | "太公"在先秦语境另有 姜太公（吕尚）/ 周太公（西伯昌之父）等指代；本判定仅适用于汉初语境，不构成对 disambig_seeds "太公" 条目的修订 |

### Group 21 — approve

| 字段 | 值 |
|------|-----|
| Merge | 吕后 → 吕雉 |
| 裁决 | **approve** |
| merge_rule | R1+historian-confirm |
| source_type | in_chapter, other_classical |
| canonical 方向 | **吕雉**（本名优先；与 Sprint G T-P0-006-δ Group 21 同型且同向，commit `fdfb7cb`） |
| 证据 | 《史记·高祖本纪》："吕公女乃吕后也，生孝惠帝、鲁元公主。"《史记·吕太后本纪》开篇："吕太后者，高祖微时妃也……生孝惠帝、女鲁元太后。"吕雉（前241–前180），字娥姁，刘邦正妻、汉惠帝/鲁元公主之母、吕氏外戚集团核心。"吕后"为后世固定称谓。 |
| 理由 | 同一人，称号 → 本名关系；与 Sprint G 决议一致（cross-chapter 重复但不冲突，见下注） |
| **cross-chapter 注** | Sprint G T-P0-006-δ G21 已对项羽本纪的"吕后→吕雉" entity 做过合并（apply commit `e83a7a3`，2 person 合并为 1）。本组的"吕后" = 高祖本纪 NER 新实例（**cross-chapter 新 person entity**），与现有"吕雉"entity 是新 propose 而非重复 propose（已合并的"吕后"alias 不应在本次 dry-run 出现为独立 person）。**PE Stage 4 应认知此为新实例 merge，非 Sprint G 已 apply 的回放** |
| **dynasty bug** | 本组中"吕后" entity 的 dynasty 字段被 NER 错误标记为"春秋"（详见 §4.3）。此 bug 与 cross_dynasty_guard 拦截 #11（吕后[春秋]↔秦穆公夫人[西汉]，526yr）相关，但**不影响本组的 historian 裁决**——guard 拦的是 FP 跨人对，本组是 TP cross-chapter 同人对 |

### Group 22 — approve (structural-dedup)

| 字段 | 值 |
|------|-----|
| Merge | 武涉 (unicode) ↔ 武涉 (pinyin) |
| 裁决 | **approve** |
| merge_rule | R1+structural-dedup |
| source_type | structural |
| 证据 | slug dedup |
| 理由 | 纯技术性去重 |
| 注 | 武涉（生卒不详），项羽属下，前 203 受命赴齐说韩信叛汉自立，未果。**注意**：武涉 ≠ 陈涉（陈胜字涉），二人无关；本组无 G11 陈胜↔陈涉相关歧义 |

### Group 23 — approve (structural-dedup)

| 字段 | 值 |
|------|-----|
| Merge | 陆贾 (unicode) ↔ 陆贾 (pinyin) |
| 裁决 | **approve** |
| merge_rule | R1+structural-dedup |
| source_type | structural |
| 证据 | slug dedup |
| 理由 | 纯技术性去重 |
| 注 | 陆贾（约前240–前170），汉初谋士，著《新语》，奉命出使南越说服赵佗归汉 |

---

## 2. §3.2 跨国/跨章/歧义组（8 组）

### 2.1 Reject 组（7 组）

> **前 5 组（G1/G2/G4/G5/G6）为秦γ + 项羽δ resolver 残留**：因"成"/"惠公"/"怀公"/"灵公"等裸谥号 entity 持续作为独立 person 存在，每次新章节扫描都会触发 R1 重 propose。秦γ historian review（commit `3280a35`）+ 项羽δ historian review（commit `fdfb7cb`）已逐组裁决，本次维持 reject 不变。**G10 + G13 为 PE 标记预期 reject**，独立审核。

#### Group 1 — reject

| 字段 | 值 |
|------|-----|
| Merge | 周成王 ↔ 成 |
| 裁决 | **reject** |
| 前序裁决 | `3280a35` §3.2 Group 2 + `fdfb7cb` §2.1 Group 1 — reject |
| source_type | in_chapter |
| 理由 | 周成王姬诵（西周，约前1042–前1021）≠ 单字"成"（典型 NER artifact，可能从"成王"/"项成"/"刘成"等任意上下文剥离）。"成"为歧义单字，独立保留 |

#### Group 2 — reject

| 字段 | 值 |
|------|-----|
| Merge | 秦惠公 ↔ 惠公 |
| 裁决 | **reject** |
| 前序裁决 | `3280a35` §3.2 Group 11 + `fdfb7cb` §2.1 Group 9 — reject |
| source_type | in_chapter |
| 理由 | "惠公"在多本纪中指涉两人：秦惠公（?–前387）与晋惠公（夷吾，?–前637）。NER 的"惠公"entity 可能混合两者 mentions，合并到秦惠公会错误归入晋惠公 mentions。独立保留 |

#### Group 4 — reject

| 字段 | 值 |
|------|-----|
| Merge | 晋惠公 ↔ 晋襄公 |
| 裁决 | **reject** |
| 前序裁决 | 无（本 sprint 首见，但与秦γ G16 同源） |
| source_type | in_chapter, other_classical |
| 证据 | 晋惠公姬夷吾（?–前637）≠ 晋襄公姬欢（?–前621）。**叔侄关系**：晋惠公夷吾 → 子晋怀公子圉（短命） → 重耳（晋文公） → 子晋襄公欢。两人虽同国（晋）同朝（春秋），但是不同的人，相隔约 16 年。R1 因"晋"+"公"字面重叠 + 共享"晋君"surface 触发 false positive。 |
| 理由 | 同国不同人；晋君世系不可合并 |
| 注 | 此组未被 state_prefix_guard 拦截，因二者 state 都是"晋"（同国）；guard 设计本意即"跨国拦截"，同国同号不同人不在 guard 范畴。这属于"同国同时代不同人"类，需 historian 介入。Sprint H 已 backlog T-P1-029（惠公 entity 内含晋惠公/秦惠公 dynasty 混合）相关 |

#### Group 5 — reject

| 字段 | 值 |
|------|-----|
| Merge | 秦怀公 ↔ 怀公 |
| 裁决 | **reject** |
| 前序裁决 | `3280a35` §3.2 Group 26 + `fdfb7cb` §2.1 Group 14 — reject |
| source_type | in_chapter |
| 理由 | "怀公"在秦本纪中双指涉：秦怀公（嬴封，战国，?–前425）与晋怀公（太子圉即位后）。两人相隔约 200 年。NER 的"怀公"entity 混合两者，不安全合并。独立保留 |
| 注 | **本 sprint 还需注意"楚怀王/怀王"系**（见 G7），"怀公" ≠ "怀王" 是两个不同 entity，不要混淆 |

#### Group 6 — reject

| 字段 | 值 |
|------|-----|
| Merge | 秦灵公 ↔ 灵公 |
| 裁决 | **reject** |
| 前序裁决 | `3280a35` §3.2 Group 28 + `fdfb7cb` §2.1 Group 11 — reject |
| source_type | in_chapter |
| 理由 | 秦灵公（嬴肃，战国初，?–前415）≠ 晋灵公（姬夷皋，春秋，?–前607）。"灵公"entity 混合两者 mentions。独立保留 |

#### Group 10 — reject (PE 预期 FP，historian 独立确认 ✓)

| 字段 | 值 |
|------|-----|
| Merge | 司马欣 ↔ 董翳 |
| 裁决 | **reject** |
| source_type | in_chapter, other_classical |
| 证据 | **三秦王典故**：项羽分关中故秦地为三国，封章邯为雍王（关中西部）、司马欣为塞王（关中东部）、董翳为翟王（关中北部，上郡），合称"三秦"。《史记·项羽本纪》："项王、范增疑沛公之有天下……乃阴谋曰：'巴、蜀道险，秦之迁人皆居蜀。'乃曰：'巴、蜀亦关中地也。'故立沛公为汉王，王巴、蜀、汉中……而三分关中，王秦降将以距塞汉王。项王乃立章邯为雍王，王咸阳以西，都废丘。长史欣者，故为栎阳狱掾，尝有德於项梁；都尉董翳者，本劝章邯降楚。故立司马欣为塞王，王咸阳以东至河，都栎阳；立董翳为翟王，王上郡，都高奴。"《史记·高祖本纪》同载"立章邯为雍王，司马欣为塞王，董翳为翟王"。R1 因二者皆有"塞王"/"翟王"/"三秦王" 类 surface 共享触发 false positive，**实际是不同人**。 |
| 理由 | **严重 FP**：司马欣（塞王）≠ 董翳（翟王），均为楚汉初期项羽所封"三秦王"之一。共享 surface "塞王" 实为 NER 半幻觉/泛化（董翳 entity 混入"塞王"alias 是抽取错误），non-historical merge。三秦王（章邯/司马欣/董翳）为楚汉典故核心组合，三人独立保留 |
| 衍生债 | disambig_seeds 楚汉封号扩充必须包含"塞王"/"翟王"/"雍王"（三秦王组合）— 加入 §4.2 |

#### Group 13 — reject (PE 预期 FP，historian 独立确认 ✓)

| 字段 | 值 |
|------|-----|
| Merge | 田广 ↔ 田荣 ↔ 田广 ↔ 韩信 ↔ 齐王 |
| 裁决 | **reject** |
| source_type | in_chapter, other_classical |
| 证据 | **楚汉时期"齐王"序列跨人 + 同号异身**——"齐王"在秦末楚汉数年间频繁易主：<br>① 田儋（田荣兄，前 209 自立齐王）→ 死于秦将章邯；<br>② 田假（齐王田建之弟，前 208 立）→ 田荣击逐，奔楚；<br>③ 田市（田儋子，田荣立，前 208）→ 项羽改封胶东王，前 205 被田荣杀；<br>④ **田荣**（田儋弟，前 205 自立齐王）→ 项羽击败死于平原；<br>⑤ **田广**（田荣子，田横立，前 205）→ 韩信破齐时被烹，前 204 死；<br>⑥ 田横（田荣弟，前 204 自立齐王）→ 韩信破齐后亡命，汉初自杀；<br>⑦ **韩信**（淮阴侯，前 203 刘邦封齐王取代田氏齐王）→ 改封楚王 → 谋反贬淮阴侯 → 死。<br>《史记·田儋列传》详载田氏齐王世系。《史记·淮阴侯列传》："乃遣张良往立信为齐王，征其兵击楚。"《史记·高祖本纪》同载。 |
| 理由 | **严重 FP**：5 person entities（田广 ×2 实为同一人 slug 重复 + 田荣 + 韩信 + 齐王）涵盖 3 个不同人物（田广/田荣/韩信），均称"齐王"于不同时期。R1 因"齐王"surface 共享触发 massive false positive。**全部独立保留**（如田广 ×2 slug 重复需走 R1+structural-dedup 单独处理，不在本组范畴；本组的"齐王"entity 跨多个真实齐王 mentions 应保持独立等待 mention-level 消歧） |
| 衍生债 | (a) disambig_seeds 楚汉封号扩充必须包含"齐王"（田儋/田假/田市/田荣/田广/田横/韩信 7 人不同时期持号）— 加入 §4.2；(b) 田广 ×2 slug 重复需 PE Stage 4 作为 R1+structural-dedup 单独处理（与 G16/18/19/22/23 同型，本次 dry-run 未单独成组的疏漏，PE 在 Stage 4 实施时拆出处理） |

### 2.2 Split 组（1 组）— G7 楚怀王 cluster

#### Group 7 — split (cross-chapter, 与 T-P0-031 entity-split 协同)

| 字段 | 值 |
|------|-----|
| Merge | 熊心 ↔ 楚王 ↔ 楚怀王 ↔ 怀王 ↔ 义帝 |
| 裁决 | **split** |
| source_type | in_chapter, other_classical, scholarly |

**核心问题——Sprint G→H 已识别"楚怀王同号异人 + entity-split"协议**（CRITICAL 复习）：

中国历史上有**两个"楚怀王"**：

| 人物 | 本名 | 朝代 | 生卒 | 出处 |
|------|------|------|------|------|
| 楚怀王（战国） | 熊槐 | 战国楚 | ?–前296 | 《史记·楚世家》《秦本纪》 |
| 楚怀王（秦末） | 熊心 | 秦末楚 | ?–前206 | 《史记·项羽本纪》《高祖本纪》 |

**项目历史背景**（PE Stage 4 必读）：
- Sprint G T-P0-006-δ G13 已 apply 子合并：怀王 → 熊心 + 义帝 → 熊心（commit `e83a7a3`，**项羽本纪 NER 实例**）
- Sprint H T-P0-031 已 apply entity-split 协议（commit `ddc6108`/`14eb2f5`）：在 **target=熊心 entity** 上 INSERT 2 行 split_for_safety alias（`怀王`/`楚王`），**source=楚怀王 entity（dynasty=战国，slug `u695a-u6000-u738b`）3 行 person_names 不动**（per ADR-026 split_for_safety 设计）
- Sprint H historian ruling commit `a117fbf`：原文复核确认项羽本纪 §6 段内"怀王"/"楚王" surface 实际跨指熊槐 + 熊心（同段双人交叉指代），故 split_for_safety 而非 mention redirect

**本 sprint G7 cluster 的 5 个 person entities 现状判定**（PE Stage 4 必须按此处理，避免双 apply）：

| Person | 来源 | 状态 | 处理 |
|--------|------|------|------|
| **熊心** | Sprint G T-P0-006-δ apply 后建立的 entity（包含 Sprint H T-P0-031 INSERT 的 `怀王`/`楚王` split_for_safety alias） | 现存活，作为本组 canonical | 不动（merge target） |
| **怀王**（高祖本纪 NER 新实例） | 高祖本纪本次 NER 抽出的**新 person entity**（cross-chapter 新实例） | 新 person | **merge → 熊心**（cross-chapter 新实例 merge，**非重复 propose**）<br>注：Sprint G 已 apply 的"怀王"alias 是项羽本纪 entity-level 合并，与本次"怀王"new person entity 不冲突——本次合并新增 1 行 person_names alias 到熊心 entity（如 ADR-014 model-A apply_merges 不去重则可能与 T-P0-031 已 INSERT 的"怀王" split_for_safety 行 surface 重复，PE 须 V1 自检；如 V1 报警则 PE 需将本次 cross-chapter 新 person 的"怀王" surface 跳过 INSERT 仅做 person 级 soft-delete） |
| **义帝**（高祖本纪 NER 新实例） | 高祖本纪本次 NER 抽出的**新 person entity**（cross-chapter 新实例） | 新 person | **merge → 熊心**（cross-chapter 新实例 merge，**非重复 propose**）<br>注：Sprint G 已 apply 项羽本纪的"义帝→熊心" entity-level 合并；本次为高祖本纪 NER 新 person entity，PE Stage 4 须以 cross-chapter 新实例对待，预期触发新增 person_names alias "义帝" 到熊心 entity（如已存在则 V1 自检） |
| **楚怀王**（战国楚怀王熊槐 entity，slug `u695a-u6000-u738b`） | Sprint H T-P0-031 已确认为熊槐 entity（split_for_safety 协议下保留 3 行 person_names 不动） | 现存活，**保留独立** | **不合并**——熊槐为战国楚怀王，与秦末熊心是不同人；高祖本纪虽未直接叙述熊槐，但 NER 可能因"楚怀王"surface 共享将本章 mention 误归入此 entity，PE Stage 4 不要 trigger 此 entity 的任何写操作（保守处理；如本章 mention 确实有错归到熊槐 entity，应通过未来 entity-split 第二例 task card 处理，本次不处理） |
| **楚王**（NER 新实例 / 跨时代泛称） | 跨时代泛称 entity（NER 半幻觉风险高） | 现存活，**保留独立** | **不合并**——"楚王"在秦本纪/项羽本纪/高祖本纪涉及多位楚国君主（楚成王/楚庄王/楚灵王/楚昭王/楚怀王熊槐/楚怀王熊心/项羽自立西楚霸王 等），合并到任何单人都不安全；与 Sprint H T-P0-031 在熊心 entity 上加 split_for_safety "楚王" alias 不冲突（那是受 ADR-026 协议约束的特殊 INSERT，非 entity-level merge） |

**Stage 4 apply 指令总览（split 组内安全子合并）**：

| 方向 | canonical_id | merged_id | merge_rule | 性质 | 注意 |
|------|-------------|-----------|------------|------|------|
| 怀王 → 熊心 | 熊心 | 怀王（高祖本纪 NER 新 person） | R1+historian-confirm | cross-chapter 新实例 merge | V1 自检 person_names alias "怀王" 是否与 T-P0-031 INSERT 的 split_for_safety 行重复 |
| 义帝 → 熊心 | 熊心 | 义帝（高祖本纪 NER 新 person） | R1+historian-confirm | cross-chapter 新实例 merge | V1 自检 person_names alias "义帝" 是否与 Sprint G 已合并的项羽本纪"义帝"alias 重复 |

**Split 组内不合并（保留独立）**：
- **楚怀王**（熊槐 entity，slug `u695a-u6000-u738b`，dynasty=战国）— per Sprint H T-P0-031 split_for_safety 协议
- **楚王**（跨时代泛称 entity）— 不安全合并到任何单人

| 证据 | 《史记·高祖本纪》："项羽兵罢归徐……封项羽为长安侯……与项羽俱攻秦……怀王曰：'先入定关中者王之。'"《史记·项羽本纪》："项梁乃求楚怀王孙心民间，为人牧羊，立以为楚怀王。"《史记·秦本纪》"楚怀王" 指熊槐（战国）。三本纪交叉证实"楚怀王"在不同语境下指代两个不同的人，必须保持 entity 隔离 |
| 理由 | 5 entities 中仅 熊心 / 怀王 / 义帝 为同一人（熊心）；楚怀王（熊槐）与楚王（泛称）保留独立。本组与 Sprint G T-P0-006-δ G13 + Sprint H T-P0-031 协议链下游协同，不破坏既有 entity-split 状态 |

---

## 3. 汇总

| 裁决 | 数量 | 组号 |
|------|------|------|
| **approve** | **15** | §1: 3, 8★, 9, 11★, 12, 14, 15, 16⚙, 17, 18⚙, 19⚙, 20⚙+, 21, 22⚙, 23⚙ |
| **reject** | **7** | §2.1: 1, 2, 4, 5, 6, 10, 13 |
| **split** | **1** | §2.2: 7 |
| **总计** | **23** | — |

★ = manual_textbook_fact
⚙ = R1+structural-dedup（slug 重复清理，pinyin/unicode 共存）
+ = G20 含 R1+structural-dedup × 1 + R1+historian-confirm × 1 双类型

### Self-check: 15 + 7 + 1 = 23 ✓（等于 PE 报告的 merge proposals 总数；与计划预案 14/8/1 偏离 +1/-1/0，原因：G14 卿子冠军→宋义 由 PE 标"裸谥号需仲裁"被本审核归为高置信度 approve，而非 reject。详见 G14 段落证据）

### Approve 组合并方向汇总（PE Stage 4 可直接 apply）

| 组 | 子合并 | 方向 | merge_rule | canonical |
|----|--------|------|------------|-----------|
| 3 | 秦王 → 子婴 | 封号 → 本名 | R1+historian-confirm | 子婴 |
| **8** | **嬴政 → 始皇帝** | **本名 → 尊号（通行称呼）** | **manual_textbook_fact** | **始皇帝** |
| 9 | 二世 + 胡亥 → 秦二世 | 排序代号 + 名 → 全称（含 state） | R1+historian-confirm | 秦二世 |
| **11** | **陈胜 → 陈涉** | **名 → 字（与 #2 项籍→项羽同型）** | **manual_textbook_fact** | **陈涉** |
| 12 | 黥布 → 英布 | 绰号 → 本名 | R1+historian-confirm | 英布 |
| 14 | 卿子冠军 → 宋义 | 封号 → 本名 | R1+historian-confirm | 宋义 |
| 15 | 赵王歇 → 赵歇 | 全称 → 简称 | R1+historian-confirm | 赵歇 |
| 16 | 纪信 (unicode) → 纪信 (pinyin) | slug dedup | R1+structural-dedup | pinyin slug |
| 17 | 魏王豹 → 魏豹 | 全称 → 简称 | R1+historian-confirm | 魏豹 |
| 18 | 郑昌 (unicode) → 郑昌 (pinyin) | slug dedup | R1+structural-dedup | pinyin slug |
| 19 | 田横 (unicode) → 田横 (pinyin) | slug dedup | R1+structural-dedup | pinyin slug |
| 20 | 刘太公 (unicode) + 太公 → 刘太公 (pinyin) | slug dedup + 短称 → 全称 | R1+structural-dedup × 1 + R1+historian-confirm × 1 | pinyin slug |
| 21 | 吕后 → 吕雉 | 称号 → 本名 (cross-chapter 新实例) | R1+historian-confirm | 吕雉 |
| 22 | 武涉 (unicode) → 武涉 (pinyin) | slug dedup | R1+structural-dedup | pinyin slug |
| 23 | 陆贾 (unicode) → 陆贾 (pinyin) | slug dedup | R1+structural-dedup | pinyin slug |

### Split 组内安全子合并汇总（PE Stage 4 可直接 apply）

| 组 | 子合并 | 方向 | merge_rule | canonical | 性质 |
|----|--------|------|------------|-----------|------|
| 7 | 怀王 → 熊心 | NER 新 person → 现存 entity | R1+historian-confirm | 熊心 | cross-chapter 新实例 |
| 7 | 义帝 → 熊心 | NER 新 person → 现存 entity | R1+historian-confirm | 熊心 | cross-chapter 新实例 |

Split 组内不合并（全部独立保留）：**楚怀王（熊槐 entity）+ 楚王（跨时代泛称）**

### Stage 4 apply 总计

- **approve 组 soft-deletes**：G3(1) + G8(1) + G9(2) + G11(1) + G12(1) + G14(1) + G15(1) + G16(1) + G17(1) + G18(1) + G19(1) + G20(2) + G21(1) + G22(1) + G23(1) = **17 soft-deletes**
- **split 组子合并 soft-deletes**：G7(怀王→熊心) + G7(义帝→熊心) = **2 soft-deletes**
- **总计**：**19 soft-deletes**
- 预计 active persons：748 → ~729（19 SD；扣除 slug-dedup 6 行不影响真实人物计数，实际历史人物维度合并约 13 人）

### textbook-fact 累计统计

| # | merge | sprint / commit | merge_rule | canonical 方向 |
|---|-------|----------------|------------|---------------|
| 1 | 重耳 → 晋文公 | Sprint F T-P1-025 / `bdb8941` | manual_textbook_fact | 晋文公（庙号） |
| 2 | 项籍 → 项羽 | Sprint G T-P0-006-δ G15 / `e83a7a3` | manual_textbook_fact | 项羽（字） |
| **3** | **嬴政 → 始皇帝** | **Sprint J T-P0-006-ε G8 / 待 Stage 4** | **manual_textbook_fact** | **始皇帝（尊号）** |
| **4** | **陈胜 → 陈涉** | **Sprint J T-P0-006-ε G11 / 待 Stage 4** | **manual_textbook_fact** | **陈涉（字）** |

> **累计 4 例，已超 ≥3 阈值**（Sprint G retro 第 76-85 行明文规则："第 3 个 manual_textbook_fact 案例出现时，必须起草 ADR-014 addendum"）。
>
> 本次 Sprint J 单独贡献 #3、#4 两例。**架构师后续动作：起草 ADR-014 addendum，正式登记 textbook-fact rule 准则**（候选 task ID = T-P1-030，详见 §4.1）。
> Historian 本 session 不起草 addendum，仅在 §4 留候选与建议条款。

---

## 4. 衍生债（Derivative Debt）

### 4.1 ADR-014 Addendum 起草触发 → T-P1-030（候选）

**触发条件**：textbook-fact 累计案例数 4 例（≥3 阈值）。

**建议条款（架构师后续起草时参考）**：

1. **manual_textbook_fact 准则**：
   - 条件 #1：cross-source 一致 — 至少 2 个独立史源（一手史源 + 后世注释/学术权威）确认 person 关系
   - 条件 #2：surface **无歧义** — surface 在中国史范围内唯一指向同一 person（不存在其他朝代/国家同名人物）
   - 条件 #3：关系类型 — 本名 ↔ 字/号/谥号/庙号/尊号/通行称呼 之一，**不包括纯封号/官衔**（封号有可能跨人传承）
   - 条件 #4：merge 方向 — canonical = 通行称呼（不一定是本名；项羽 / 晋文公 / 始皇帝 / 陈涉 等通行称呼方向已成 4 例先例）

2. **反例清单**（不构成 textbook-fact 充分条件）：
   - 通用即位代号 / 排序词（"二世" / "三世" / "少帝" / "幼主" 等）— 必须带 state/dynasty 前缀（"秦二世" / "汉惠帝"）才合格 — 实例化材料：本 sprint G9 胡亥↔二世↔秦二世 走 R1+historian-confirm 而非 textbook-fact
   - 跨朝代共享封号（"齐王" / "楚王" / "汉王" / "塞王" / "翟王" / "雍王" 等）— per G10/G13 的"封号跨人"实例
   - 跨国共享谥号（"惠公" / "灵公" / "怀公" / "桓公" / "襄公" 等）— 已被 state_prefix_guard / R1 reject 大量覆盖

3. **rule taxonomy 升级**：
   - 现有 merge_rule 枚举：R1 / R2 / R3 / R4 / R5 / R6 / R6-seed / historian_correction / manual_textbook_fact
   - addendum 应明示 manual_textbook_fact 与其他规则的优先级关系（建议：高于 R1，低于 historian_correction；与 R6 同级）

4. **canonical 方向规则**：
   - 默认 canonical = 通行称呼（per #1-#4 历史先例）
   - 如本名与通行称呼难分高下，由 historian 在 review 时明示 canonical 方向（本 sprint 已为 #3/#4 明示）

**优先级**：P1 — addendum 是协议正式化文档，不阻塞已 apply 的 4 例 textbook-fact merges；但**必须在 textbook-fact 第 5 例出现前完成**

### 4.2 disambig_seeds 楚汉多义封号扩充 → T-P1-027（已存在 stub，本次增项）

本次审核暴露 G10/G13 严重 R1 跨人 false positive，根因是楚汉时期"封号"频繁易主（一封号跨多人持有）。Sprint G T-P0-006-δ retro 已开 T-P1-027 stub；本次新增以下急需的 disambig 候选：

| surface | 候选 person 列表 | 说明 | 优先级 |
|---------|----------------|------|--------|
| **齐王** | 田儋 / 田假 / 田市 / 田荣 / 田广 / 田横 / 韩信 (前203) / 刘肥 (前201) / 后续诸吕齐王 等 | 楚汉-西汉初最严重多义封号，**至少 9 人** 不同时期持号 | P0 — 直接修复 G13 类 FP |
| **塞王** | 司马欣 (项羽前206封) / 后续无 | 楚汉特殊封号（三秦王之一） | P1 |
| **翟王** | 董翳 (项羽前206封) / 后续无 | 三秦王之一 | P1 |
| **雍王** | 章邯 (项羽前206封) / 后续刘氏雍王 | 三秦王之一 + 西汉宗室封 | P1 |
| **楚王** | 楚怀王(熊槐) / 楚怀王(熊心) / 项羽 (西楚霸王) / 韩信 (前203改封) / 刘交 (汉初封) / 刘戊 等 | 战国-西汉初跨多代多人 | P0 |
| **汉王** | 刘邦（楚汉时期专指）+ 后续无 | 楚汉时期单一指向，**风险点**：未来扩章遇汉宣帝/汉昭帝同号需注意 | P2 |
| **怀王** | 楚怀王(熊槐) / 楚怀王(熊心) / 晋怀公(太子圉) / 秦怀公 | 跨代跨国，G7 split 已示 | P1 — 部分已被 entity-level split 覆盖 |
| **代王** | 赵歇 (项羽前206改封) / 刘喜 / **刘恒（汉文帝即位前）** / 后续 | 跨人继承，未来高祖本纪+吕后本纪+文帝本纪 ingest 必触发 | P0 |

**优先级**：P0 — 影响 Sprint K（候选下章）的 R1 FP 治理水平；建议在下一 ingest batch 之前完成

### 4.3 NER dynasty 字段标记错误 → T-P1-031（候选）

本 sprint dry-run 发现 2 个高祖本纪 person entity 的 dynasty 字段被 NER 错误标记（详见 dry-run-resolve §"cross_dynasty 拦截"⚠️ 注释）：

| person | 现 dynasty | 正确 dynasty | 影响 cross_dynasty_guard 拦截 # | 推测原因 | 优先级 |
|--------|-----------|-------------|-------------------------------|---------|--------|
| **吕后**（本 sprint G21 的"吕后" entity，cross-chapter 新实例） | **春秋** | **西汉** | #11（吕后[春秋]↔秦穆公夫人[西汉]，526yr 反向 gap，guard 拦得对但 dynasty 标记错） | NER 半幻觉：LLM 可能因"吕"姓在春秋齐国（吕氏出齐太公）联想或 prompt v1-r5 dynasty inference 失败 | **P0** — 西汉皇后核心人物 dynasty 错误严重影响 cross-chapter merge 与 R1 dynasty 前置过滤 (T-P1-028) 准确性 |
| **刘盈**（本 sprint NER 新出，对应汉惠帝） | **战国** | **西汉** | #18（刘盈[战国]↔秦惠文王[西汉]，251yr 反向 gap，guard 拦得对但 dynasty 标记错） | NER 半幻觉：LLM 可能因"盈"字在战国/先秦语境（如越王勾践相关）联想，或 prompt v1-r5 对汉初宗室 dynasty inference 不稳 | **P0** — 西汉第二位皇帝同理 |

**修复路径建议**（架构师后续裁决）：

- 选项 A（轻量数据修复）：开 T-P1-031 ad-hoc data fix，UPDATE persons SET dynasty='西汉' WHERE person_id IN (吕后, 刘盈)；走 ADR-014 single UPDATE pre-flight gate
- 选项 B（系统性改进）：合入 T-P2-005 NER v1-r6 prompt 改进 scope（dynasty inference few-shot 加强 + 西汉初宗室/外戚 dynasty mapping 显式化）
- 选项 C（双轨）：A + B 同 sprint 实施

**注**：guard 行为正确（拦住了 FP cross-人 pair），dynasty bug 仅是数据正确性问题，不影响 Sprint J Stage 4 apply 流程；但**应在 Sprint K 启动前完成数据修复**，避免持续污染下游分析

### 4.4 NER prompt v1-r6 楚汉"封号+名"模式 → T-P2-005（已存在 stub，本次增项）

本 sprint 多组 approve（G15 赵王歇/赵歇、G17 魏王豹/魏豹）显示 NER 对"封号+名"格式（X王Y）的拆分仍依赖 R1 alias merge 兜底。Sprint G 已开 T-P2-005 stub；本次确认 v1-r6 prompt 应：
- 加强"X王Y" few-shot（楚汉多个案例：赵王歇、魏王豹、塞王欣、翟王翳、雍王邯）
- 加 dynasty inference 西汉初宗室/外戚专项 few-shot（与 §4.3 选项 B 协同）
- 加"二世/三世/少帝"通用排序词带 state 前缀的强制要求

**优先级**：P2 — NER 质量改进，不阻塞当前 sprint

### 4.5 田广 ×2 slug 重复 PE Stage 4 单独处理 → 落 G13 reject 后

G13 reject 后，田广（pinyin slug `tian-guang`）与田广（unicode hex slug）的 slug 重复仍需作为 R1+structural-dedup 单独 apply（与 G16/18/19/22/23 同型）。本 dry-run 未将其拆出独立成组（因 G13 群组化拉入"齐王"歧义内），PE Stage 4 实施时单独处理。

**优先级**：P1 — Stage 4 内消化，非独立 task card

### 衍生债 ID 占位（PE Stage 5 创建 stub）

| ID | 标题 | 优先级 |
|----|------|--------|
| **T-P1-030**（**候选 — 新**） | **ADR-014 addendum textbook-fact merge 协议正式化** | P1 — addendum 实际起草由架构师 |
| T-P1-027（增项） | disambig_seeds 楚汉多义封号扩充（齐王 P0 / 楚王 P0 / 代王 P0 / 三秦王组 P1 / 怀王 P1 / 汉王 P2） | P0/P1 — 影响 Sprint K |
| **T-P1-031**（**候选 — 新**） | **NER dynasty 字段标记错误数据修复（吕后 / 刘盈 → 西汉）** | P0 — Sprint K 启动前修复 |
| T-P2-005（增项） | NER v1-r6 楚汉封号+名 + dynasty inference 西汉初宗室 few-shot + 通用排序词强制 state 前缀 | P2 |

---

## 5. 审核方法论说明

1. **证据层级**：in_chapter > other_classical > scholarly > wikidata > structural。本次 23 组中 18 组有 in_chapter 级证据（《史记·高祖本纪》原文可定位），G7/G8/G11/G14/G21 辅以 other_classical（《项羽本纪》/《秦始皇本纪》/《陈涉世家》/《吕太后本纪》/《楚世家》），G16/G18/G19/G20/G22/G23 仅 structural（slug dedup）。

2. **textbook-fact 三例触发标准的实例化**：本 sprint 同时触发 #3（嬴政→始皇帝，本名→尊号）+ #4（陈胜→陈涉，名→字与 #2 同型），与 G9（胡亥↔二世/秦二世，保守归 R1+historian-confirm）的"反例"裁决一并构成 ADR-014 addendum 起草的实例化素材。建议架构师起草 addendum 时直接引用本报告 §1 G8/G9/G11 段落作为附录。

3. **cross-chapter 新实例 vs 重复 propose 的区分**：本次 G7（楚怀王 cluster）+ G20（太公）+ G21（吕后）三组涉及 Sprint G T-P0-006-δ 已 apply 的 entity（熊心、刘太公、吕雉）与高祖本纪 NER 新实例的 cross-chapter merge。审核区分原则：
   - **如 propose 中包含已 apply 后 soft-deleted 的 person entity** → 异常，PE 须排查（应不会出现，因为 dry-run 应过滤 deletedAt is not null）
   - **如 propose 中是已合并 entity 的"alias surface 共享"导致的新 person 与 canonical 合并** → 正常 cross-chapter 新实例 merge，apply 即可
   - **G7 特殊**：因 Sprint H T-P0-031 已 split_for_safety 在 target 熊心 entity 加 INSERT 行，本次 cross-chapter merge 时 V1 须自检 alias surface 是否重复（详见 G7 段落 PE Stage 4 处理指令）

4. **state_prefix_guard 同国不同人不在 guard 范畴**：G4 晋惠公↔晋襄公 reject 是同国（晋）同朝（春秋）但不同人（叔侄）。state_prefix_guard 设计本意为"跨国拦截"，同国同号不同人需 historian 介入。这是 ADR-025 §5.3 设计上已知局限，未触发新 guard 设计需求（已 backlog 在 T-P1-029 候选）。

5. **NER dynasty bug 与 guard 行为正交**：本次 cross_dynasty_guard 拦截 #11/#18 所示，guard 设计在"dynasty 标记部分错"前提下仍能正确拦截 FP 跨人对（拦的是"任意 dynasty gap > 阈值"组合），但 dynasty 标记错本身污染下游分析。本类型 bug 修复（§4.3）独立于 guard 评估。

6. **R1+structural-dedup 与 R1+historian-confirm 的区分价值**：本次首次将 5 对 slug-dedup 标注为 `R1+structural-dedup` 子规则（与秦γ G14 同型，但秦γ 仅 1 例未单独命名）。建议 future merge_rule 枚举或 audit log 标签 reserves 此区分，便于回顾"哪些 merge 是 NER/技术性 + 哪些是 historian 历史判断"。**优先级 P3** — 不开独立卡。

---

> **Historian sign-off**: 本报告基于《史记·高祖本纪》原文及相关史源（《项羽本纪》/《秦始皇本纪》/《陈涉世家》/《吕太后本纪》/《楚世家》/《田儋列传》/《淮阴侯列传》/《魏豹彭越列传》/《黥布列传》）完成审核。23 组 merge proposals 逐组裁决完毕，PE 可据此执行 Stage 4 apply_merges（**19 soft-deletes**：17 from approve groups + 2 from G7 split sub-merges）。
>
> **核心事件**：
> - **textbook-fact 累计 4 例触发 ADR-014 addendum 起草建议**（候选 T-P1-030，架构师后续动作）
> - **G10/G13 PE 预期 reject 独立确认**（三秦王 / 楚汉齐王序列两类楚汉典型 R1 FP）
> - **G7 楚怀王 cluster cross-chapter 协议链下游协同**（与 Sprint G T-P0-006-δ + Sprint H T-P0-031 协议链一致，无破坏既有 entity-split 状态）
> - **NER dynasty bug 2 项（吕后/刘盈）登记为 P0 衍生债**（候选 T-P1-031）
>
> **审核人**: historian@huadian
> **日期**: 2026-04-28
