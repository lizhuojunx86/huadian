# T-P0-006-δ Stage 3 — Historian Merge Review

> **角色**: 古籍专家 (historian@huadian)
> **日期**: 2026-04-25
> **输入**: `dry-run-resolve-2026-04-25.md` (Run ID `b2d0d357`)
> **状态**: Stage 4 unblock — PE 可按本报告执行 apply_merges
> **模型**: Claude Opus 4.6

---

## 0. 审核原则

1. **split 优先**：不确定时 split（两人独立保留），不硬猜
2. **dynasty 校验**：跨国同名必须核对 dynasty 字段一致性
3. **source_type 标注**：每组证据标注来源类型
   - `in_chapter` — 《史记·项羽本纪》原文段落
   - `other_classical` — 其他史源（《左传》《国语》《汉书》等）
   - `wikidata` — QID + label
   - `scholarly` — 学术研究 / 现代考据
   - `structural` — 基于 NER 结构特征推断
4. **前序裁决引用**：本次 21 组中 12 组为 T-P0-006-γ 秦本纪 resolver 残留（秦γ historian review commit `3280a35`），此类组标注前序裁决 commit + 组号映射，PE Stage 4 处理时可一眼识别
5. **textbook-fact 路径**：公认本名/字号关系按 `manual_textbook_fact` merge rule 标注（T-P1-025 重耳↔晋文公先例）

---

## 1. §3.1 高置信度组（7 组）

### Group 2 — approve

| 字段 | 值 |
|------|-----|
| Merge | 穆王 → 周穆王 |
| 裁决 | **approve** |
| source_type | in_chapter (周本纪) |
| 证据 | 《史记·周本纪》："穆王即位，春秋已五十矣。"周本纪国王纪事段"穆王"专指周穆王姬满（西周，约前976–前922在位）。R3 tongjia 缪→穆附带触发（tongjia.yaml 已有此对），但本组主要匹配机制为 R1 短称。先秦诸侯中无其他"穆王"谥号。 |
| 理由 | 同一人短称，谥号无跨国歧义 |

### Group 15 — approve (manual_textbook_fact) ★

| 字段 | 值 |
|------|-----|
| Merge | 项籍 → 项羽 |
| 裁决 | **approve** |
| merge_rule | **manual_textbook_fact** |
| source_type | in_chapter |
| 证据 | 《史记·项羽本纪》开篇第一句："**项籍者，下相人也，字羽。**"籍为名（míng），羽为字（zì）。此为中国史学常识级知识，无任何学术争议。《汉书·项籍传》同载。 |
| 理由 | 名/字关系，textbook fact；项羽（字）为通行称呼，项籍（名）为本名。同一人，合并为 项羽（canonical） |
| 先例 | T-P1-025 重耳→晋文公（Sprint F，commit `bdb8941`）为第 1 个 manual_textbook_fact 案例；本组为**第 2 个** |
| precedent 累积 | **textbook-fact 案例数 → 2/3 阈值**（再积 1 例即触发 ADR-014 addendum，按 Sprint F retro 准则） |

### Group 16 — approve

| 字段 | 值 |
|------|-----|
| Merge | 武信君 → 项梁 |
| 裁决 | **approve** |
| source_type | in_chapter |
| 证据 | 《史记·项羽本纪》："楚怀王因以项梁为上将军……号为武信君。"项梁（?–前208），项羽叔父，被楚怀王熊心封为武信君。"武信君"为封号，项梁为本名。 |
| 理由 | 同一人，封号→本名关系，项羽本纪语境无歧义 |

### Group 17 — approve

| 字段 | 值 |
|------|-----|
| Merge | 陈王 → 陈胜 |
| 裁决 | **approve** |
| source_type | in_chapter, other_classical |
| 证据 | 《史记·项羽本纪》："陈胜之起也……乃立为王，号曰张楚。"又："闻陈王定死。"《史记·陈涉世家》详载陈胜（字涉，?–前208）大泽乡起义后于陈县称王，号陈王。项羽本纪中"陈王"唯一指陈胜。 |
| 理由 | 同一人，称号→本名关系 |

### Group 19 — approve

| 字段 | 值 |
|------|-----|
| Merge | 韩王成 → 韩成 |
| 裁决 | **approve** |
| source_type | in_chapter |
| 证据 | 《史记·项羽本纪》："立韩公子成为韩王。"又："项王不肯遣韩王，乃以为侯，已又杀之。"韩成（?–前206），韩国贵族后裔，先被项梁立为韩王。"韩王成"= 韩王（封号）+ 成（名），为全称异写。 |
| 理由 | 同一人，全称与简称关系 |

### Group 20 — approve

| 字段 | 值 |
|------|-----|
| Merge | 太公 → 刘太公 |
| 裁决 | **approve** |
| source_type | in_chapter |
| 证据 | 《史记·项羽本纪》："汉王之父太公、吕后为楚所获。"又："项王乃置太公其上，告汉王曰：'今不急下，吾烹太公。'"项羽本纪中"太公"皆指刘邦之父刘太公（刘煓，一说刘执嘉），语境唯一确定。 |
| 理由 | 同一人短称，项羽本纪语境无歧义 |

### Group 21 — approve

| 字段 | 值 |
|------|-----|
| Merge | 吕后 → 吕雉 |
| 裁决 | **approve** |
| source_type | in_chapter, other_classical |
| 证据 | 《史记·项羽本纪》："汉王之父太公、吕后为楚所获。"《史记·吕太后本纪》："吕太后者，高祖微时妃也，生孝惠帝、女鲁元太后。"吕雉（前241–前180），字娥姁，刘邦正妻。"吕后"为后世固定称谓。 |
| 理由 | 同一人，称号→本名关系 |

---

## 2. §3.2 跨国/跨章歧义组（14 组）

### 2.1 Reject 组（13 组）

> 以下 12 组为 T-P0-006-γ 秦本纪 resolver 残留。秦γ historian review（commit `3280a35`）已裁决。本次 resolver 全量扫描导致重复出现，裁决结论不变。每组标注前序 commit + 组号映射。

#### Group 1 — reject

| 字段 | 值 |
|------|-----|
| Merge | 周成王 ↔ 成 ↔ 楚成王 |
| 裁决 | **reject** |
| 前序裁决 | `3280a35` §3.2 **Group 2** — reject |
| source_type | in_chapter |
| 理由 | 周成王姬诵（西周，约前1042–前1021）≠ 楚成王熊恽（春秋，?–前626），相隔约400年，跨代跨国。"成"为歧义单字。三者全部保留独立 |

#### Group 3 — reject

| 字段 | 值 |
|------|-----|
| Merge | 秦康公 ↔ 密康公 |
| 裁决 | **reject** |
| 前序裁决 | `3280a35` §3.2 **Group 3** — reject |
| source_type | in_chapter |
| 理由 | 秦康公嬴罃（春秋，?–前609）≠ 密康公（西周，密须国），不同国、不同朝、不同姓 |

#### Group 4 — reject

| 字段 | 值 |
|------|-----|
| Merge | 鲁桓公 ↔ 秦桓公 |
| 裁决 | **reject** |
| 前序裁决 | `3280a35` §3.2 **Group 5** — split（桓公→秦桓公已 apply；本组为残留二者） |
| source_type | in_chapter |
| 理由 | 鲁桓公姬允（春秋，?–前694）≠ 秦桓公嬴荣（春秋，?–前577），不同国。秦γ split 后 R1 仍因"桓公"alias 重叠触发 |

#### Group 5 — reject

| 字段 | 值 |
|------|-----|
| Merge | 晋悼公 ↔ 齐悼公 |
| 裁决 | **reject** |
| 前序裁决 | `3280a35` §3.2 **Group 7** — split（悼公→晋悼公已 apply；本组为残留二者） |
| source_type | in_chapter |
| 理由 | 晋悼公姬周（春秋，前586–前558）≠ 齐悼公姜阳生（春秋末，?–前485），不同国 |

#### Group 6 — reject

| 字段 | 值 |
|------|-----|
| Merge | 灵王 ↔ 楚灵王 |
| 裁决 | **reject** |
| 前序裁决 | `3280a35` §3.2 **Group 8** — split（楚公子围→楚灵王已 apply；灵王显式保留独立） |
| source_type | in_chapter |
| 理由 | "灵王"为歧义短称——周灵王姬泄心（前571–前545在位）与楚灵王熊虔（?–前529）均可匹配。秦γ 已裁决"灵王"独立保留，本次维持 |

#### Group 7 — reject

| 字段 | 值 |
|------|-----|
| Merge | 秦庄公 ↔ 齐庄公 |
| 裁决 | **reject** |
| 前序裁决 | `3280a35` §3.2 **Group 9** — split（庄公→秦庄公已 apply；本组为残留二者） |
| source_type | in_chapter |
| 理由 | 秦庄公嬴其（西周末/春秋初，?–前778）≠ 齐庄公姜光（春秋，?–前548），不同国不同朝 |

#### Group 8 — reject

| 字段 | 值 |
|------|-----|
| Merge | 秦简公 ↔ 齐简公 |
| 裁决 | **reject** |
| 前序裁决 | `3280a35` §3.2 **Group 10** — split（简公→秦简公已 apply；本组为残留二者） |
| source_type | in_chapter |
| 理由 | 秦简公嬴悼子（战国，?–前400）≠ 齐简公姜壬（春秋末/战国初，?–前481），不同国 |

#### Group 9 — reject

| 字段 | 值 |
|------|-----|
| Merge | 秦惠公 ↔ 惠公 |
| 裁决 | **reject** |
| 前序裁决 | `3280a35` §3.2 **Group 11** — reject |
| source_type | in_chapter |
| 理由 | "惠公"在秦本纪中指涉两人：秦缪公段为**晋惠公**夷吾（?–前637），秦惠公纪事段为**秦惠公**（?–前387）。NER 的"惠公"entity 可能混合两者 mentions，合并到秦惠公会错误归入晋惠公 mentions。独立保留 |

#### Group 10 — reject

| 字段 | 值 |
|------|-----|
| Merge | 晋惠公 ↔ 秦襄公 ↔ 齐襄公 ↔ 晋襄公 |
| 裁决 | **reject** |
| 前序裁决 | `3280a35` §3.2 **Group 16** — split（夷吾→晋惠公已 apply；本组为残留四者） |
| source_type | in_chapter |
| 理由 | 四国四人：晋惠公姬夷吾（?–前637）、秦襄公嬴开（?–前766）、齐襄公姜诸儿（?–前686）、晋襄公姬欢（?–前621）。R1 因"公"/"襄"字面重叠产生 massive false positive。全部保留独立 |

#### Group 11 — reject

| 字段 | 值 |
|------|-----|
| Merge | 晋灵公 ↔ 灵公 ↔ 秦灵公 |
| 裁决 | **reject** |
| 前序裁决 | `3280a35` §3.2 **Group 28** — split（全部独立保留，0 子合并） |
| source_type | in_chapter |
| 理由 | 晋灵公姬夷皋（?–前607）≠ 秦灵公嬴肃（?–前415），相隔约200年。"灵公"entity 可能混合晋/秦两国 mentions。三者全部保留独立 |

#### Group 12 — reject

| 字段 | 值 |
|------|-----|
| Merge | 晋平公 ↔ 齐平公 |
| 裁决 | **reject** |
| 前序裁决 | `3280a35` §3.2 **Group 29** — reject |
| source_type | in_chapter |
| 理由 | 晋平公姬彪（?–前532）≠ 齐平公姜骜（?–前456），不同国不同朝 |

#### Group 14 — reject

| 字段 | 值 |
|------|-----|
| Merge | 秦怀公 ↔ 怀公 |
| 裁决 | **reject** |
| 前序裁决 | `3280a35` §3.2 **Group 26** — split（太子圉+子圉已 apply；怀公、秦怀公显式保留独立） |
| source_type | in_chapter |
| 理由 | "怀公"在秦本纪中双指涉：秦缪公段为**晋怀公**（太子圉即位后），秦怀公纪事段为**秦怀公**（?–前425）。两人相隔约200年。NER 的"怀公"entity 混合两者，不安全合并。独立保留 |

#### Group 18 — reject (NEW — 项羽本纪首见)

| 字段 | 值 |
|------|-----|
| Merge | 韩信 ↔ 田荣 |
| 裁决 | **reject** |
| source_type | in_chapter, other_classical |
| 证据 | R1 因"齐王"surface form 重叠触发。韩信（?–前196），淮阴人，先为汉大将军，后被刘邦封为齐王（前203）、改封楚王。田荣（?–前205），齐国田氏贵族，秦末自立为齐王（前206），后被项羽击败身死。《史记·项羽本纪》分别记载二人事迹。 |
| 理由 | **严重 false positive**——韩信与田荣完全不同的人，先后据有"齐王"号但时段不同、身份不同。"齐王"为楚汉时期典型多义封号，应加入 disambig_seeds |

### 2.2 Split 组（1 组）— CRITICAL

#### Group 13 — split (楚怀王 cluster)

| 字段 | 值 |
|------|-----|
| Merge | 楚怀王 ↔ 楚昭王 ↔ 楚王 ↔ 熊心 ↔ 怀王 ↔ 义帝 |
| 裁决 | **split** |
| source_type | in_chapter, other_classical, scholarly |

**核心问题——同号异人（CRITICAL）**：

中国历史上有**两个"楚怀王"**：

| 人物 | 本名 | 朝代 | 生卒 | 出处 |
|------|------|------|------|------|
| 楚怀王（战国） | 熊槐 | 战国楚 | ?–前296 | 《史记·秦本纪》《楚世家》 |
| 楚怀王（秦末） | 熊心 | 秦末 | ?–前206 | 《史记·项羽本纪》 |

《史记·项羽本纪》："项梁乃求楚怀王孙心民间，为人牧羊，立以为楚怀王，从民所望也。"项梁找到战国楚怀王·熊槐的孙辈熊心，立为新楚怀王以号召反秦。后项羽尊熊心为**义帝**，遣杀于江南。

**数据层发现**：dry-run cross-chapter 表显示现有"楚怀王"entity（slug `u695a-u6000-u738b`，dynasty=**战国**）同时出现在秦本纪和项羽本纪。这意味着项羽本纪的"楚怀王"mentions 被错误归入**战国楚怀王·熊槐** entity——实际上项羽本纪的"楚怀王"指的是**秦末楚怀王·熊心**，是不同的人。**此为数据正确性 critical issue**，已升格为独立 task card **T-P0-031**。

**保留独立**（4 persons）：
- **楚怀王**（现有 entity，dynasty=战国）— 保留为熊槐。项羽本纪 mentions 的归属修正由 T-P0-031 处理
- **楚昭王**（熊珍，春秋末，?–前489）— 完全不同的楚国君主，比熊槐早约200年
- **楚王** — 跨时代泛称，秦本纪/项羽本纪涉及多位楚王（楚成王/楚庄王/楚灵王/楚昭王/楚怀王等），合并到任何单人都不安全

**安全子合并**（2 merges → 熊心 as canonical）：

| 方向 | canonical_id | merged_id | 关系 |
|------|-------------|-----------|------|
| 怀王 → 熊心 | 熊心 | 怀王 | 项羽本纪语境中"怀王"特指秦末楚怀王·熊心（非战国楚怀王·熊槐，后者在秦本纪以"楚怀王"全称出现） |
| 义帝 → 熊心 | 熊心 | 义帝 | 《项羽本纪》："项王使人徙义帝……乃阴令衡山王、临江王击杀之江中。"义帝=熊心的后期称号 |

**Stage 4 apply 指令**：仅 apply 上述 2 条安全子合并。楚怀王 entity 的 mention redirect 属 T-P0-031 范畴，本 sprint 不做。

| 证据 | 《史记·项羽本纪》："项梁乃求楚怀王孙心民间，为人牧羊，立以为楚怀王"——熊心被立为楚怀王。"项王使人徙义帝长沙郴县"——后期被尊为义帝。《史记·高祖本纪》同载。"怀王"在项羽本纪叙事语境中特指熊心（"怀王约入关者王之""怀王不肯"等皆指秦末楚怀王），与秦本纪中指熊槐的"楚怀王"非同一人。 |
| 理由 | 六者中仅 熊心=怀王=义帝 为同一人；楚怀王 entity 因跨章同号异人需 entity-level split（T-P0-031）；楚昭王、楚王各自独立 |

---

## 3. 汇总

| 裁决 | 数量 | 组号 |
|------|------|------|
| **approve** | **7** | §1: 2, 15★, 16, 17, 19, 20, 21 |
| **reject** | **13** | §2.1: 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 18 |
| **split** | **1** | §2.2: 13 |
| **总计** | **21** | — |

### Self-check: 7 + 13 + 1 = 21 ✓（等于 PE 报告的 merge proposals 总数）

### Split 组内安全子合并汇总（PE Stage 4 可直接 apply）

| 组 | 子合并 | 方向 |
|----|--------|------|
| 13 | 怀王 → 熊心 | 短称 → 本名 |
| 13 | 义帝 → 熊心 | 后期称号 → 本名 |

Split 组内不合并（全部独立）：楚怀王（待 T-P0-031）、楚昭王、楚王

### Approve 组合并方向汇总（PE Stage 4 可直接 apply）

| 组 | 子合并 | 方向 | merge_rule |
|----|--------|------|------------|
| 2 | 穆王 → 周穆王 | 短称 → 全称 | R1+historian-confirm |
| 15 | 项籍 → 项羽 | 名 → 字（通行称呼） | **manual_textbook_fact** |
| 16 | 武信君 → 项梁 | 封号 → 本名 | R1+historian-confirm |
| 17 | 陈王 → 陈胜 | 称号 → 本名 | R1+historian-confirm |
| 19 | 韩王成 → 韩成 | 全称 → 简称 | R1+historian-confirm |
| 20 | 太公 → 刘太公 | 短称 → 全称 | R1+historian-confirm |
| 21 | 吕后 → 吕雉 | 称号 → 本名 | R1+historian-confirm |

**Stage 4 apply 总计**：7 (approve) + 2 (split sub-merges) = **9 soft-deletes**

**textbook-fact 案例数 → 2/3 阈值**（架构师未来抽查数据点：#1 重耳→晋文公 T-P1-025 / #2 项籍→项羽 本组）

---

## 4. 衍生债（Derivative Debt）

### 4.1 楚怀王 Entity Split → T-P0-031 (task card stub 已创建)

**升格为独立 task card**，非普通衍生债。详见 `docs/tasks/T-P0-031-chu-huai-wang-entity-split.md`。

- **性质**：数据正确性 critical issue
- **优先级**：P0
- **范围**：楚怀王 entity（dynasty=战国，slug `u695a-u6000-u738b`）需拆分为熊槐（战国）和熊心（秦末）两个独立 entity，并将项羽本纪 mentions redirect 到熊心
- **Sprint G Stage 4 只做安全子合并**（熊心+怀王+义帝），entity-split 由 T-P0-031 单独 sprint 处理

### 4.2 项籍↔项羽 textbook-fact merge

- **处理方式**：Stage 4 apply 时直接执行，merge_rule = `manual_textbook_fact`
- **不开新卡**，本 sprint 内消化
- **PE 注意**：merge_log 的 merge_rule 字段必须写 `manual_textbook_fact`（非 `R1+historian-confirm`），与 T-P1-025 重耳→晋文公保持一致

### 4.3 disambig_seeds 楚汉扩充 → T-P1-027

本次审核暴露楚汉时期多义封号 false positive（Group 18 韩信↔田荣 via"齐王"）。建议扩充：

| surface | 候选 | 说明 |
|---------|------|------|
| 齐王 | 田荣 / 韩信 / 田建 / 田横 | 秦末-楚汉多人先后称齐王 |
| 楚王 | 楚怀王(熊槐) / 楚怀王(熊心) / 项羽 | 跨时代泛称 |
| 汉王 | 刘邦 | 楚汉时期专指，但未来扩章可能遇同号 |
| 怀王 | 楚怀王(熊槐) / 楚怀王(熊心) / 晋怀公(太子圉) / 秦怀公 | 跨代跨国 |

**优先级**：P1 — 建议在下一 ingest batch 前完成

### 4.4 R1 跨国 FP 源头改进 → T-P1-028

本次 21 组中 13 组（62%）为 reject，其中 12 组是秦γ 已裁决的跨国同名残留。根因：R1 仅基于名称字面匹配，不考虑 dynasty。

建议评估 R1 引入 dynasty 前置过滤（类似 R6 的 cross-dynasty guard），从源头减少 false positive。此改进可能需要 ADR。

**优先级**：P1 — 影响后续每个 ingest sprint 的 historian 审核工作量

### 4.5 NER 楚汉封号识别 → T-P2-005

auto-promotion 告警中的楚汉时期模式（韩王成→韩成、齐王建→田建 等"封号+名"组合）值得在 NER prompt v1-r6 中处理。当前 v1-r5 的官衔+名规则主要覆盖先秦模式，楚汉时期的"X王Y"格式可作为新的 few-shot 案例。

**优先级**：P2 — NER 质量改进类

### 衍生债 ID 占位（PE Stage 5 创建 stub）

| ID | 标题 | 优先级 |
|----|------|--------|
| T-P0-031 | 楚怀王 Entity Split (熊槐/熊心) | P0 — **stub 已创建** |
| T-P1-027 | disambig_seeds 楚汉多义封号扩充 | P1 |
| T-P1-028 | R1 dynasty 前置过滤（减少跨国 FP） | P1 |
| T-P2-005 | NER v1-r6 楚汉封号+名 few-shot | P2 |

---

## 5. 审核方法论说明

1. **证据层级**：in_chapter > other_classical > scholarly > wikidata > structural。本次 21 组中 19 组有 in_chapter 级证据，2 组辅以 other_classical（《汉书》《左传》）。
2. **前序裁决引用**：12/21 组为秦γ resolver 残留，标注前序 commit `3280a35` + 组号映射。此类组的裁决结论与秦γ 一致，PE 处理时无需重新核验——仅需确认 entity ID 未因中间 merges 变化。
3. **textbook-fact 标准**：本次 Group 15 项籍↔项羽 满足 manual_textbook_fact 全部条件：(a) 名/字/号关系，(b) 一手史源明确记载，(c) 学术界零争议。与 T-P1-025 重耳↔晋文公同级。累计 2/3 阈值。
4. **楚汉同号异人问题**：Group 13 暴露了 entity-level 消歧的新类型——不是"跨国同谥号"（秦γ 已大量处理），而是"同国同号跨时代"（战国楚怀王 vs 秦末楚怀王）。此类问题在 R1 surface match 框架下无法自动检测，需要 historian 历史知识介入。建议 Sprint G retro 记为"Sprint G 最大架构发现"——这是 V12 invariant 候选（"同号异人跨时段 entity 完整性检查"）。
5. **Split 原则一致性**：Group 13 的 split 策略与秦γ 一致——"短称/泛称 entity 可能混合多人 mentions 时，不做 entity-level merge，保留独立等待 mention-level 消歧"。但本组额外发现了 entity-level 的跨章污染（楚怀王 entity），这超出了 split 原则的范畴，需要 entity split 操作（T-P0-031）。

---

> **Historian sign-off**: 本报告基于《史记·项羽本纪》原文、《史记·秦本纪》交叉校验及相关史源完成审核。21 组 merge proposals 逐组裁决完毕，PE 可据此执行 Stage 4 apply_merges（9 soft-deletes：7 approve + 2 split sub-merges）。
>
> **CRITICAL 发现**：楚怀王 entity 跨章同号异人污染（T-P0-031），Sprint G 最大架构发现。
>
> **审核人**: historian@huadian
> **日期**: 2026-04-25
