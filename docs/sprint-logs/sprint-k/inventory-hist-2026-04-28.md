# Sprint K Stage 0 — Historian Inventory（T-P0-028 Triage UI）

> **角色**：古籍专家 (historian@huadian)
> **日期**：2026-04-28
> **关联**：
> - 架构师 brief：`docs/sprint-logs/sprint-k/stage-0-brief-2026-04-28.md` §3 Stage 0 Historian 段
> - 历史 review 样本：γ (commit `3280a35`) / δ (commit `fdfb7cb`) / ε (commit `07db893`)
> - mention bucketing 先例：`docs/sprint-logs/sprint-h/historian-chu-huai-wang-mentions-2026-04-26.md`
> **状态**：Stage 0 Historian 段 inventory，4 项产出待架构师 Stage 1 设计输入
> **scope 边界**：本文档不写代码、不动 DB、不 push、不 merge；仅作为 UX 真实用户的需求陈述

---

## §1 当前手工 triage 痛点列表（≥5 条具体 case）

> **总体说明**：Sprint G→J 期间已积累 4 份手写 historian review markdown（γ/δ/H/ε），累计裁决约 100 组 merge proposals + ≈50 条 seed_mapping pending。从这 4 次实战中归纳出以下 8 条系统性痛点，按"出错风险高 → 时间消耗高 → 心智疲劳高"排序。

### 痛点 1（致命）：跨 sprint 重复审同一 surface 簇导致判断疲劳 + 结论不一致风险

**具体 case**：

| # | surface 组 | 出现 sprint | 每次结论 | 现状 |
|---|-----------|-----------|---------|------|
| 1.1 | 周成王 ↔ 成 ↔ 楚成王 | γ G2 / δ G1 / ε G1（3 次） | 三次都 reject | 三份独立 markdown，证据近乎重写 |
| 1.2 | 秦惠公 ↔ 惠公（含晋惠公混入） | γ G11 / δ G9 / ε G2（3 次） | 三次都 reject | 同上 |
| 1.3 | 秦怀公 ↔ 怀公（含晋怀公太子圉混入） | γ G26 / δ G14 / ε G5（3 次） | 三次都 reject | 同上 |
| 1.4 | 秦灵公 ↔ 灵公 ↔ 晋灵公 | γ G28 / δ G11 / ε G6（3 次） | 三次都 reject | 同上 |
| 1.5 | 鲁桓公 ↔ 桓公 ↔ 秦桓公 | γ G5（split→秦桓公）/ δ G4 残留（reject） | split 后 R1 仍因"桓公"alias 重叠重报 | δ 又写一遍证据 |
| 1.6 | 晋惠公 ↔ 秦襄公 ↔ 齐襄公 ↔ 晋襄公 ↔ 夷吾 | γ G16（split→夷吾→晋惠公）/ δ G10 残留（reject） | 4 国 4 人重复评估 | 同上 |

**时间消耗（单 case 实测）**：
- 第一次裁决（γ）：定位原文 + 写证据 + 标 source_type ≈ 8-12 分钟（含查《左传》/《史记集解》引文）
- 第二次裁决（δ）：理论上"标 reject + 引前序 commit"即可，但实际 markdown 表格全字段重抄（merge / 裁决 / 前序裁决 / source_type / 理由）≈ 4-6 分钟
- 第三次裁决（ε）：再次重抄 ≈ 4-6 分钟
- **6 个簇 × 3 次平均 ≈ 90-120 分钟纯重复劳动**

**出错风险**：
- 跨 sprint 结论不一致（如 γ 写 split、δ 又改写为 reject 但实际语义相同）→ 下游 PE apply 时混淆
- 证据深度逐次衰减（第 3 次写时容易省略《左传》卷次，仅写"前序裁决 X"）→ audit trail 弱化
- "同 surface 第 4/5 次 propose"出现时，hist 已无新增信息可补，但仍要走完全流程

**判断疲劳的具体表现**：γ review 中惠公 entity 论证含 4 段 in-chapter 引文，到 ε 时已退化为"独立保留"一行 — **质量下降不是 hist 偷懒，是流程没复用前序成果**。

---

### 痛点 2（严重）：决策记录散落 4+ 份 markdown，跨 sprint 查阅靠 grep

**具体 case**：审 ε G7 楚怀王 cluster 时，hist 必须**同时**打开：
- `T-P0-006-delta/historian-review-2026-04-25.md` §2.2 G13（项羽δ split 子合并 怀王/义帝→熊心）
- `sprint-h/historian-chu-huai-wang-mentions-2026-04-26.md`（mention bucketing 二次裁决）
- `sprint-h/T-P0-031-*-dry-run.md` + ddc6108/14eb2f5 commit log（entity-split 实际 INSERT 行）
- ε 本次 dry-run report 看 5 person entities 现状

**实际操作链**：grep `楚怀王` docs/sprint-logs/ → 拿到 6+ 个 hit → 逐个文件打开判断哪一份是 latest 状态 → mental 拼接出 cross-sprint 时间线 → 才能在 ε review 写出"协议链下游协同"裁决。

**时间消耗**：单 cluster ≈ 20-30 分钟（4-5 文件切换 + 时间线重建），且全部依赖 hist 个人记忆（"我应该读哪几份文件"无 index）。

**出错风险**：
- 漏读某份 markdown → 复制已废弃裁决（如未读 H mention bucketing → 把 split_for_safety 误写为 mention redirect）
- 时间线拼接出错 → cross-chapter 新实例 vs 重复 propose 区分错（ε G7/G20/G21 的 PE Stage 4 处理指令就因区分极复杂，写了三段才说清）
- 新 historian 接手时无入口文档（"楚怀王怎么处理过"完全靠口耳相传）

---

### 痛点 3（严重）：决策时缺关键 context，被迫切多 SELECT 自查

**具体 case**：H sprint 楚怀王 mention bucketing 二次裁决（commit `a117fbf`）中，hist 必须：

```sql
-- 第 1 次 SELECT：取 192 字 raw_text 完整原文
SELECT id, content FROM raw_texts WHERE id = '84d1087b-...';

-- 第 2 次 SELECT：3 行 person_names 当前状态
SELECT id, name, name_type, is_primary, person_id
FROM person_names WHERE person_id = '777778a4-...' OR ...;

-- 第 3 次 SELECT：source_evidence id 链反查
SELECT id, raw_text_id, person_name_id, quoted_text
FROM source_evidences WHERE id = '73e39311-...';

-- 第 4 次 SELECT：候选 person 元信息
SELECT person_id, name_zh, dynasty, slug FROM persons WHERE ...;
```

4 次 SQL 才凑齐"原文 192 字 + 3 行 alias 状态 + 1 个 SE id + 2 个候选 person dynasty/slug"——而这才是裁决所需的最小信息集。

**时间消耗**：单 cluster ≈ 15-20 分钟（不含 SQL 写出时间，只算执行 + 阅读输出 + mental join）。

**出错风险**：
- SQL 写错（如 `is_primary=false` 漏 join 导致看到错误 alias 子集）→ 误判 NER 抽取来源
- 多次 SELECT 之间 DB 状态变化（理论上 dry-run 阶段不会，但管线实际可能并发跑）→ 看到的不是同一时刻快照
- 非 PostgreSQL 熟手 historian 完全无法接手（架构 brief §1 已明指此为可移交性问题）

---

### 痛点 4（中）：决策格式化输出冗长，markdown 表格手写易遗漏字段

**具体 case**：ε G8 嬴政→始皇帝 单组裁决的 markdown 表格含 **9 字段**：

```
| 字段 | 值 |
|------|-----|
| Merge | ... |
| 裁决 | approve |
| merge_rule | manual_textbook_fact |
| source_type | in_chapter, other_classical |
| canonical 方向 | 始皇帝 |
| 证据 | ... |
| 理由 | ... |
| 先例 | T-P1-025 + δG15 |
| precedent 累积 | 3/3 阈值首次触达 |
```

23 组 × 9 字段 = 207 单元格手写。ε review 实际撰写中曾因漏写 `canonical 方向` 字段被自查发现两次。

**时间消耗**：单 review 文档全程撰写约 3-5 小时（含查史源），其中纯格式化 ≈ 30-45 分钟。

**出错风险**：
- 字段漏写 → PE Stage 4 解析 review 时 ambiguous（"canonical 方向是什么？"反查 review 不写，二次问 hist）
- 跨组字段一致性（如 source_type 命名规范）靠记忆维护
- markdown 表格难以查询（无法自动统计"本 sprint 有几个 manual_textbook_fact"）

---

### 痛点 5（中）：textbook-fact 累计计数靠人工追踪

**具体 case**：ε G8 写 "**先例 #3**"、G11 写 "**先例 #4**" 时，hist 必须自己记得：

- #1 重耳→晋文公（Sprint F T-P1-025，commit `bdb8941`）
- #2 项籍→项羽（Sprint G T-P0-006-δ G15，commit `e83a7a3`）

**追踪方法**：grep `manual_textbook_fact` 全 review markdown + 手数。当前累计 4 例，下一例是第 5——但**无 systematic counter**，纯靠 hist 大脑记账。Sprint G retro 已立"≥3 阈值触发 ADR-014 addendum"规则，但触发依赖 hist 主动声明。

**时间消耗**：每次 review 撰写"precedent 累积"段 ≈ 5-10 分钟（grep + 验证）。

**出错风险**：
- 漏记某例 → addendum 触发延迟 → ADR 与代码状态不同步（Sprint J 的 G8/G11 实际是把 #3 + #4 同时触发，正常应该 #3 触发后立即起草 addendum）
- 同类计数其他 metadata 也靠人记（如 split_for_safety 累计、cross-chapter 新实例累计）

---

### 痛点 6（中）：disambig_seeds backlog 散落各 review §4，无字典覆盖率视图

**具体 case**：γ §4.4 列了 10 个待加 disambig 候选（桓公/灵公/悼公/...），δ §4.3 列了 4 个（齐王/楚王/汉王/怀王），ε §4.2 列了 8 个（齐王 P0 / 楚王 P0 / 代王 P0 / 三秦王组 P1 / 怀王 P1 / 汉王 P2 / 雍王 P1 / 塞王 P1 / 翟王 P1）。

**当前盲点**：
- "齐王" 在 δ + ε 两次出现，是同一条还是两条独立 backlog？hist 无法快速 dedup
- 哪些已落入 `data/dictionaries/disambiguation_seeds.yaml`？哪些仍 pending？
- T-P1-027 task card 跟踪进度，但 hist 看不到"T-P1-027 完成时这 N 条 backlog 全部清完了吗"

**时间消耗**：每次 review 收尾段写 §4 disambig 列表 ≈ 20-30 分钟，且大量重复（"齐王"列三次写 candidates 7 人）。

**出错风险**：跨 sprint 不一致（δ 写"齐王 4 候选"，ε 写"齐王 7 候选"——两次都对，但前者过时）。

---

### 痛点 7（低-中）：审"楚王"/"齐王"等跨时代泛称时，看不到 corpus 全 mention 时间线

**具体 case**：γ G30 楚昭王↔楚王 split、δ G13 楚怀王 cluster、ε G7 楚怀王 cluster + ε G13 齐王 cluster。每次裁决"楚王"是不是泛称、跨几个真实人物时，hist 唯一依据是**史学知识**（"楚成王/楚庄王/楚灵王/楚昭王/楚怀王熊槐/楚怀王熊心 / 项羽自立西楚霸王"），而不是**数据**。

**理想 context**：UI 应显示"`楚王` surface 在当前 corpus 中累计出现 N 次 / 分布于 M 章 / 最早 raw_text X / 最晚 raw_text Y"——hist 可据此快速判断 entity 应不应该 split 还是合并到某一人。

**时间消耗**：现状无此 context，hist 只能凭经验判断 → 偶尔误判（如 H 楚怀王 mention bucketing 之前，δ G13 曾把"楚王"判为"独立保留"，没看到 alias surface 在 raw_text 中根本不字面出现，导致 H 二次裁决时才暴露 NER 半幻觉问题）。

---

### 痛点 8（低）：决策提交→git commit 链路对非工程 hist 不友好

**具体 case**：当前流程 = hist 写 markdown → git add → git commit -m "docs(sprint-X): historian merge review" → 由 PE 拿 commit hash 引用。如未来引入纯 hist 角色（古籍学者，无 git 经验），此链路完全断裂。

**时间消耗**：单次 commit ≈ 2-3 分钟（含写 commit message）。
**出错风险**：commit message 格式不规范 / 漏 sign-off / commit 到错误分支（架构 brief 已要求 conventional commits + 不 push 不 merge）。

---

## §2 理想 UI 设计描述（inbox 模式 + hint feature）

### 2.1 整体范式：邮箱 inbox 模式

**核心比喻**：类比 Gmail / Linear inbox。Hist 进入 `/triage` 看到一个待办队列，逐条裁决，决策提交后**自动跳到下一条**。三层结构：

```
[列表页 /triage]
   ├── filter / sort / group 控件（顶栏）
   ├── 队列卡片列（每条 = 一个 pending item，含核心字段速览）
   └── 底部分页 / "全部裁完"祝贺
        ↓ 点击单条卡片
[详情页 /triage/[itemId]]
   ├── 顶部 banner：跨 sprint 同 surface 历史裁决 hint（核心 feature）
   ├── 主体上半：原文 raw_text（surface 高亮）
   ├── 主体中部：候选 person 列表（含 historical mentions + dynasty + slug + wikidata）
   ├── 主体下半：决策表单（markdown rich text + 快捷模板 + 字段勾选）
   └── 底部按钮：[提交并跳下一条] / [提交并返回列表] / [defer 跳过]
```

### 2.2 列表页核心交互

**布局**：

```
┌────────────────────────────────────────────────────────────┐
│ /triage  [按 surface 聚合 ▼] [全部 guard_type ▼] [我的 ▼]   │  ← 顶栏控件
├────────────────────────────────────────────────────────────┤
│  📌 6 cluster 重复 surface（历史已审）                      │
│  ┌──────────────────────────────────────────────────┐      │
│  │ 周成王 ↔ 成 ↔ 楚成王         🔁 第 4 次 propose  │      │
│  │ Sprint K • cross_dynasty_guard 拦截              │      │
│  │ 候选 3 人：周成王(西周) / 成(歧义单字) / 楚成王(春秋) │      │
│  │ 💡 hint: γ G2 / δ G1 / ε G1 均 reject（一致）   │      │
│  │                                  [审核] [批量按 hint] │ │
│  └──────────────────────────────────────────────────┘      │
│  ⚙️  3 slug-dedup（structural，建议批量 approve）           │
│  ...                                                        │
│  🆕 12 全新 propose（首次出现）                            │
│  ...                                                        │
└────────────────────────────────────────────────────────────┘
```

**关键控件**：

| 控件 | 选项 | 默认 |
|------|------|------|
| **聚合维度** | 按 surface（同字面成簇） / 按 guard_type / 按创建时间 / 按 sprint | 按 surface（核心 UX 选择，直接对应痛点 1） |
| **filter** | 全部 / cross_dynasty / state_prefix / split_for_safety / TIER-4 seed_mapping / NER dynasty bug / 仅"重复 surface" | 全部 |
| **sort within group** | 时序倒序 / 相似度（同 surface 簇内）/ 推荐决策类型 | 时序倒序 |
| **状态显示** | 待办 / 已 defer / 已裁决（折叠） | 待办 |

**重复 surface 簇的"批量按 hint" 按钮**：当某 surface 历史 ≥2 次裁决结论一致时，hist 可一键应用相同决策到本簇所有未审 item（仍走二次确认弹窗，避免误操作）。**直接对应痛点 1**。

**视觉锚点（对应痛点疲劳）**：
- 🔁 = 重复 surface（历史已审）
- 🆕 = 全新 propose
- ⚙️ = structural-dedup（slug 重复，技术性合并）
- ⚠️ = NER dynasty 标记错（如吕后[春秋]/刘盈[战国] 高亮提醒）
- 📋 = 关联 split 协议下游（如 G7 cluster cross-chapter 系列）

### 2.3 详情页核心交互（inbox 模式心脏）

**顶部 banner — 跨 sprint 历史裁决 hint（V1 必做核心 feature）**：

布局：

```
┌──── 历史裁决记录（同 surface "成王" / "楚成王"）────────────┐
│ ┌──────────────┬──────┬──────┬─────────────────────┐ │
│ │ Sprint G γ G2│ commit │ reject │ "周成王≠楚成王，跨代跨国" │ │
│ │              │ 3280a35│        │     by historian@huadian │ │
│ ├──────────────┼──────┼──────┼─────────────────────┤ │
│ │ Sprint G δ G1│ commit │ reject │ "维持 γ 结论"            │ │
│ │              │ fdfb7cb│        │                          │ │
│ ├──────────────┼──────┼──────┼─────────────────────┤ │
│ │ Sprint J ε G1│ commit │ reject │ "维持 γ/δ 结论"          │ │
│ │              │ 07db893│        │                          │ │
│ └──────────────┴──────┴──────┴─────────────────────┘ │
│  📊 一致性: 3/3 reject • 上次裁决距今 0 天                │
│  [复用最近一次裁决到本 item]                              │
└───────────────────────────────────────────────────────────┘
```

**banner 必显字段**（按用户问题逐条回答）：

| 字段 | 数据源 | 显示形式 |
|------|--------|----------|
| **Sprint + Group 编号** | review markdown 表头解析 / triage_decisions.sprint_id | "Sprint G γ G2" 紧凑标识 |
| **commit hash** | git log（PE 提交时记录到 triage_decisions.commit_hash）| 7 位短 hash + 点击跳 GitHub diff |
| **决策类型** | triage_decisions.decision | 彩色 chip（reject 红 / approve 绿 / split 黄 / defer 灰）|
| **一句理由** | triage_decisions.reason 首句截断（≤80 字符）| 单行省略号溢出，鼠标悬停显示完整 |
| **跨 sprint 链路** | 同 surface 历史 decisions 时序排列 | 表格逐行；首尾相隔时间 |
| **裁决人** | triage_decisions.historian_id | "historian@huadian" 短形式 |
| **一致性统计** | aggregate（reject/approve/split 各计数）| "3/3 reject" 醒目 badge |
| **复用按钮** | — | 一键应用最近裁决（带二次确认）|

**Banner 显示触发条件**：同 surface（精确字面匹配，如"楚成王"必须字符相同；"楚怀王"与"楚怀王孙心"不视为同 surface）历史 ≥1 次决策时显示。0 次则隐藏（首次 propose 无 hint 可参考）。

---

**主体原文区**：

```
┌──── 原文（高祖本纪 §6，192 字）───────────────────────────┐
│ 居鄛人范增，年七十，素居家，好奇计，往说项梁曰：           │
│ "陈胜败碧当。夫秦灭六国，楚最无罪。自[怀王]入秦不反，       │
│  楚人怜之至今，故[楚]南公曰'[楚]虽三户，亡[秦]必[楚]'也。   │
│  ...乃求[楚怀王]孙心民间，为人牧羊，立以为[楚怀王]，从       │
│  民所望也。陈婴为[楚]上柱国，封五县，与[怀王]都盱台。"       │
│  项梁自号为武信君。                                        │
│                                                            │
│  surface 高亮：[黄] = 当前 triage 涉及的 surface           │
│            [灰] = 同 person 簇相关 surface（参考）         │
└────────────────────────────────────────────────────────────┘
```

**关键能力（直接对应痛点 3）**：UI 把 SE id → raw_text → 全文 拉好，不用 hist 自己 SQL。同段双指代（楚怀王 §6 一段两王）必须支持**多点高亮 + 段内位置标记**（如"位置 1 = 熊槐，位置 4 = 熊心"颜色区分）。

---

**主体候选 person 区**：

```
┌──── 候选 person（5 人）───────────────────────────────┐
│ ✅ 熊心 (xiong-xin) • 秦末 • Sprint G 已建立 entity   │
│    历史 mentions：项羽本纪 ×8 / 高祖本纪 ×3（本次）   │
│    [查看全部 mentions ▼]                              │
│                                                        │
│ ⚠️ 楚怀王 (u695a-u6000-u738b) • 战国 • slug=unicode    │
│    historical 熊槐，与本 sprint 高祖本纪语境无关       │
│    📋 已被 T-P0-031 entity-split 协议保护（不参与本 merge）│
│                                                        │
│ ⚠️ 楚王 • 跨时代泛称 • NER 半幻觉（surface 在 §6 不字面出现）│
│    [查看 NER QC flag 详情]                            │
│                                                        │
│ 🆕 怀王 (NEW) • 高祖本纪本次 NER 新实例                │
│    🔗 wikidata Q??? • 未关联 seed                      │
│    建议方向：→ 熊心（cross-chapter 新实例）            │
│                                                        │
│ 🆕 义帝 (NEW) • 高祖本纪本次 NER 新实例                │
│    建议方向：→ 熊心（cross-chapter 新实例）            │
└────────────────────────────────────────────────────────┘
```

**关键能力**：候选 person 卡片携带 wikidata QID / dynasty / slug / 历史 mention 数 / 协议保护状态 — 直接对应**痛点 3**（不再切 SELECT）+ **痛点 7**（看到 surface 全 corpus mention 时间线）。

---

**决策表单（含快捷模板，对应用户提问）**：

```
┌──── 你的裁决 ──────────────────────────────────────────┐
│ 决策类型 (radio)                                        │
│   ○ approve（合并执行）                                 │
│   ● reject（保持独立）                                  │
│   ○ split（拆分含子合并）                               │
│   ○ defer（暂缓，标记下次再审）                         │
│                                                          │
│ canonical 方向（如 approve/split）                      │
│   [____________________] (autocomplete from 候选列表)   │
│                                                          │
│ merge_rule (multi-select)                               │
│   ☐ R1+historian-confirm                                │
│   ☐ R1+structural-dedup                                 │
│   ☐ R1+historian-split-sub                              │
│   ☐ manual_textbook_fact ← textbook-fact 计数 4/3 已超 │
│   ☐ historian_correction                                │
│                                                          │
│ source_type (multi-select)                              │
│   ☑ in_chapter ☐ other_classical ☐ wikidata ☐ scholarly │
│   ☐ structural                                          │
│                                                          │
│ 理由 (markdown rich text, 必填)                          │
│  ┌───────────────────────────────────────────────────┐ │
│  │ 快捷模板 ▼:                                       │ │
│  │  [📌 引用最近 sprint 裁决] [📜 引用 in_chapter]    │ │
│  │  [📚 引用 other_classical]   [⚙️ slug-dedup 模板]  │ │
│  │  [🔗 引用 commit hash]      [🗂️ 引用 ADR-XXX]      │ │
│  │ ─────────────────────────────────                   │ │
│  │  > 引用 Sprint G γ G2 (commit 3280a35):            │ │
│  │  > "周成王姬诵（西周）≠ 楚成王熊恽（春秋），跨代跨国" │ │
│  │  > 维持 reject。                                  │ │
│  │                                                    │ │
│  │ [输入框，支持 markdown 表格 / 引用块 / 链接]       │ │
│  └───────────────────────────────────────────────────┘ │
│                                                          │
│ 衍生债登记 (optional)                                    │
│   ☐ 标记为 disambig_seeds 候选                           │
│   ☐ 触发 NER QC flag (surface 不在 raw_text 中)          │
│   ☐ 触发 dynasty bug 数据修复（具体 person id：____）   │
│                                                          │
│ 🔗 关联 commit hash (optional, 如引用历史裁决)           │
│   [____________] (autocomplete from git log)            │
│                                                          │
│ ┌────────────────────┐ ┌──────────────┐ ┌─────────┐   │
│ │ 提交 → 跳下一条     │ │ 提交 → 列表  │ │  defer  │   │
│ └────────────────────┘ └──────────────┘ └─────────┘   │
└──────────────────────────────────────────────────────────┘
```

**快捷模板（直接对应用户问题 #3）**：UI 必须提供以下 6 个一键模板：

| 模板按钮 | 自动插入内容 | 触发场景 |
|---------|------------|---------|
| 📌 引用最近 sprint 裁决 | 自动从 banner 抓 latest decision，插入"引用 Sprint X 裁决（commit Y）：'reason' 维持/修正 当前裁决" | 重复 surface（痛点 1）|
| 📜 引用 in_chapter | 弹窗选段落 → 自动插入"《史记·X 本纪》：'引文'" | 高置信度 approve |
| 📚 引用 other_classical | 弹窗选史源 → 插入"《左传·X 公 N 年》'引文'" | 跨史源验证 |
| ⚙️ slug-dedup 模板 | 整段插入 R1+structural-dedup 标准模板（含"纯技术性去重，无历史判断" + canonical 方向说明）| structural 类（痛点 4）|
| 🔗 引用 commit hash | 输入 hash → 自动 fetch commit message 插入 | audit trail |
| 🗂️ 引用 ADR-XXX | dropdown 选 ADR → 插入"per ADR-XXX §Y" | 协议性裁决（如 G7 楚怀王 split 协议）|

### 2.4 "决策后跳下一条" 的 next item 选择逻辑（用户问题 #2）

**默认排序（V1）**：

1. **同 surface 簇优先**：如果当前 item 属于某 surface 簇（如"楚成王"3 次重复），跳到**同簇下一未审 item**，让 hist 一气呵成裁决整簇 — 直接对应痛点 1 的"判断疲劳"
2. **如同簇已全部审完**：跳到**下一个有 hint 的簇**（历史已审过的优先，可以快速复用）
3. **如全部 hint 簇审完**：跳到**全新 propose 簇**（按 created_at 时序倒序）
4. **如该 sprint 全审完**：返回列表页 + 显示祝贺（"✅ Sprint K 全部 N 条 triage 完成"）

**高级排序（V1.1 / V2 候选）**：
- 按 hist 个人偏好（如"我擅长楚汉，先跳楚汉相关"，由用户配置）
- 按推荐决策类型聚合（连续审 reject → 连续审 approve → 连续审 split）
- 按 dynasty 聚合（同代际人物上下文连续）
- 按 guard_type 聚合（如先审完所有 cross_dynasty，再审 state_prefix）

**关键 UX 决策**：默认排序"同簇优先"是 V1 必做（痛点 1 直接驱动），其他排序模式可作为下拉切换选项延后。

---

## §3 重要 metadata 需求分级

### 3.1 必须字段（缺则无法决策）

| 字段 | 数据源 | 当前可获 | 说明 |
|------|--------|---------|------|
| surface form | seed_mappings.surface / pending_merge_reviews.surface_a / surface_b | ✅ | 必须精确字符匹配 |
| 候选 person 列表（id + name_zh + dynasty + slug） | persons join | ✅ | 至少 2 个候选 |
| 推测决策类型 | guard_type / mapping_method | ✅ | cross_dynasty / state_prefix / TIER-4 等 |
| 所属 sprint / 创建时间 | seed_mappings.created_at + run_id | ✅ | 时序定位 |
| **原文 raw_text 完整内容** | source_evidences.raw_text_id → raw_texts.content | ✅ DB 中有，UI 必须 join 出来 | 痛点 3 直接对应 |
| guard 拦截理由（如 dynasty gap=200yr） | pending_merge_reviews.guard_payload | ✅ | JSON 解析展示 |
| **跨 sprint 同 surface 历史裁决** | triage_decisions（V1 新增表）+ 历史 review markdown 解析 | ❌ 需 BE 实现 | 痛点 1 直接对应 — V1 核心 |

### 3.2 优先字段（有更好但缺也可决策）

| 字段 | 数据源 | 当前可获 | 说明 |
|------|--------|---------|------|
| 候选 person 历史 mentions 数量 / 章节分布 | person_names + source_evidences aggregate | ✅ DB 中有，需 GraphQL 暴露 | 痛点 7 |
| 是否已有 disambig_seeds 条目 | data/dictionaries/disambiguation_seeds.yaml grep | ⚠️ YAML 静态文件，需 BE 加载 | 痛点 6 |
| wikidata QID + label | dictionary_entries.dictionary_data | ✅ | 跨源验证 |
| canonical merge 方向预测 | resolver heuristic | ⚠️ 现有 dry-run report 有 | 减少 hist 输入负担 |
| 同 surface 在 corpus 全 mention 时间线（按 raw_text 时序） | 全表 join | ⚠️ 需新 GraphQL query | 痛点 7 高级 |
| NER 是否半幻觉（surface 在 raw_text 字面是否出现） | 后端字符串匹配 | ❌ 需 PE 实现 | H 楚怀王 mention bucketing 教训 |
| textbook-fact 累计计数 | aggregate triage_decisions WHERE merge_rule='manual_textbook_fact' | ❌ 需 V1 实现 | 痛点 5 |

### 3.3 可选字段（V2 再加）

| 字段 | 说明 |
|------|------|
| 候选 person 关系图谱（亲族 / 同时代人） | 知识图谱可视化，依赖 events / relationships 表 |
| 学界引文（disambig_seeds.references 字段标准化）| 当前 review 中靠 hist 手写，未结构化 |
| 决策预览（approve 后将 soft-delete 哪些行 + V1 invariant 影响预测）| 类似 SQL EXPLAIN，hist 无需自查 |
| bulk decision（同类型多条一次 approve/reject）| V1 已部分对应"批量按 hint"按钮，但全 bulk operations 留 V2 |
| 历史裁决一致性预警（如本次决策与历史 hint 不一致时弹窗）| 防止 hist 误操作 |
| 自动 commit + commit message 生成 | 痛点 8 |

---

## §4 E2E 验证愿景 + 候选 sample pending data

### 4.1 验证场景

V1 上线后 hist 在本地起服务（PE 协助）→ 浏览 `/triage` → 用 UI 完成下列 8 条历史 pending data 的裁决（不实际触发下游 apply，仅写 triage_decisions 表 + 验证持久化）。每条决策与"如果我用 SQL + markdown 单独审"应得到**完全一致**结论（数据 + 理由）。

### 4.2 sample 选定（按用户优先级排序）

#### 必做（3 条 — 验证 V1 核心 feature）

**Sample #1 — 周成王 ↔ 成 ↔ 楚成王（hint feature 验证 ★）**
- 来源：γ G2 / δ G1 / ε G1（3 次历史 reject）
- 数据：pending_merge_reviews 中已存在的 cross_dynasty 拦截行
- 验证点：
  - banner 必须正确显示 3 次历史裁决（commit 3280a35 / fdfb7cb / 07db893 + "reject"+ 一句理由）
  - "复用最近裁决"按钮一键应用
  - **一致性 badge 显示"3/3 reject"**
- 期望结论：reject（与历史一致）
- **核心验证**：痛点 1 + 痛点 2 同时缓解

**Sample #5 — 楚怀王 cluster cross-chapter（split 协议复杂 case ★）**
- 来源：ε G7（5 entities cluster + Sprint G/H 协议下游协同）
- 数据：pending_merge_reviews 含 5 entities propose
- 验证点：
  - 详情页正确显示 T-P0-031 entity-split 协议保护标记（楚怀王 entity 不参与）
  - cross-chapter 新实例 vs 重复 propose 区分清晰（怀王/义帝 NEW 标记）
  - 候选 person 卡片携带 Sprint G/H 已 apply 状态
  - 决策表单允许"split + 子合并 2 条 + 保留 2 entity 独立"
- 期望结论：split（怀王→熊心 + 义帝→熊心，楚怀王/楚王独立）
- **核心验证**：痛点 2（多文件查阅）缓解 + 协议下游可视化

**Sample #8 — TIER-4 异源 seed_mapping（异源 case ★）**
- 来源：seed_mappings WHERE mapping_status='pending_review' 中随机一条（Sprint B 起累积约 50 条）
- 数据：含 wikidata QID + dictionary_entries 元信息
- 验证点：
  - 列表页能正确显示 TIER-4 类型（与 cross_dynasty / state_prefix 区分 group）
  - 详情页展示 wikidata 候选信息（label / description / P31）
  - 决策表单支持 mapping_method='historian_correction' 选项
- 期望结论：approve / reject / defer 任一（视实际数据）
- **核心验证**：双源 union 抽象不破坏既有 query 路径

#### 优先（3 条 — 验证 metadata 完备性）

**Sample #2 — 嬴政 → 始皇帝（textbook-fact approve）**
- 来源：ε G8（已 apply，但可在测试环境复现一条同型）
- 验证点：
  - merge_rule 多选含 manual_textbook_fact 选项
  - **textbook-fact 累计计数显示"4/3 已超阈"**（痛点 5）
  - 触发 ADR-014 addendum 起草建议提示
- 期望结论：approve + canonical=始皇帝

**Sample #3 — 三秦王 司马欣 ↔ 董翳（楚汉典故 reject）**
- 来源：ε G10
- 验证点：
  - 候选 person 卡片显示 dynasty=秦末 + 共享 surface 警示（"塞王"/"翟王" alias 跨 entity）
  - 决策表单"标记为 disambig_seeds 候选"勾选后自动弹窗输入候选列表
- 期望结论：reject + disambig flag（塞王/翟王）

**Sample #6 — 吕后 ↔ 秦穆公夫人 526yr（dynasty bug 暴露）**
- 来源：ε G21 关联 cross_dynasty 拦截 #11
- 验证点：
  - **NER dynasty 错误用 ⚠️ 高亮提醒**（吕后 entity 当前 dynasty=春秋，应为西汉）
  - 决策表单"触发 dynasty bug 数据修复"勾选后能输入 person id
  - 即使 dynasty 错，guard 拦截行为仍正确（hist 能区分"guard 拦得对" vs "数据本身错"）
- 期望结论：reject（拦截正确）+ dynasty bug flag（吕后 person id）

#### 可选（2 条 — 时间紧可后挪）

**Sample #4 — 齐王 cluster 7 人**
- 来源：ε G13（5 entities propose）
- 验证点：cluster 中 5 entities 均独立保留 + disambig_seeds 候选记录"齐王"7 候选
- 期望结论：reject（全部独立）

**Sample #7 — 胡亥 ↔ 二世 ↔ 秦二世（textbook-fact 反例）**
- 来源：ε G9
- 验证点：merge_rule 选 R1+historian-confirm 而非 manual_textbook_fact，验证"反例清单" UX 提示（"二世为通用排序词，不构成 textbook-fact 充分条件"）
- 期望结论：approve + R1+historian-confirm + canonical=秦二世

### 4.3 验证标准

| 维度 | 通过标准 |
|------|---------|
| **持久化** | 每条裁决正确写入 triage_decisions（含 decision / reason / merge_rule / source_type / commit_hash 等字段）|
| **决策一致性** | 每条 UI 决策结论与"hist 单独 SQL+markdown 审核"完全一致（reason 文字可不同，但 decision + merge_rule + canonical 必须一致）|
| **audit trail** | UI 决策携带 historian_id + 时间 + commit hash（V1 简化 token 模式）|
| **回滚能力** | defer 状态可重审；已 approve 状态在 V1 不允许回滚（V2 加）|
| **下游不破坏** | 决策 mutation 后 V1-V11 invariant 全绿 + resolver / R6 prepass 行为不变（PE Stage 4 验证）|

### 4.4 反馈机制（V1.1 / V2 backlog）

E2E 测试中如发现以下 UX 痛点，立即登记：

| 类别 | 反馈样例（提前预判）| 紧急度 |
|------|-------------------|-------|
| 列表页 | 同 surface 簇折叠/展开交互不直观 | V1.1 |
| 列表页 | filter / sort 状态不持久（刷新页面丢失）| V1.1 |
| 详情页 | 原文高亮多点定位不准（楚怀王 §6 段内位置切分需精细化）| V1.1 |
| 详情页 | 候选 person 历史 mentions 加载慢（>3s）| V2 性能 |
| 表单 | markdown 预览模式缺失 | V1.1 |
| 表单 | 快捷模板自定义（hist 自创模板）| V2 |
| 表单 | 决策提交失败时 reason 文字丢失 | V1 必修 |
| Auth | URL token 模式不安全（误点链接他人可代审）| V2 SSO |
| 整体 | "全部裁完"祝贺界面缺失 / 进度条不直观 | V1.1 |

---

## §5 跨角色依赖（向 BE / FE / PE 提的需求清单）

### 5.1 向 Backend Engineer (BE)

| 需求 | 优先级 | 对应痛点 | 说明 |
|------|--------|---------|------|
| GraphQL `pendingTriageItems(groupBy, filter, sort)` 必须支持 `groupBy: surface`（同字面聚合） | P0 | 痛点 1 | 列表页核心查询 |
| 必须 join `raw_texts.content` 完整原文（不仅 chapter §）| P0 | 痛点 3 | 详情页核心 |
| 必须返回该 surface 的"跨 sprint 历史 triage_decisions"（含 commit_hash / decision / reason / historian_id / created_at）| P0 | 痛点 1 + 痛点 2 | hint banner 数据源 |
| Mutation `recordTriageDecision` 必须支持以下字段：decision / reason (markdown) / merge_rule (multi) / source_type (multi) / canonical_id / disambig_flag / dynasty_bug_flag / commit_hash_ref | P0 | 痛点 4 | 决策表单 |
| 候选 person 卡片携带：person_id / name_zh / dynasty / slug / wikidata_qid / historical_mentions_count / cross_chapter_apply_status | P1 | 痛点 3 + 痛点 7 | 详情页中部 |
| Aggregate query：textbook-fact 累计计数 / disambig_seeds 字典覆盖率 | P1 | 痛点 5 + 痛点 6 | 全局 dashboard 数据 |
| 历史 review markdown 解析（γ/δ/H/ε 4 份）→ 写入 triage_decisions backfill | P1 | 痛点 1 hint 启动数据 | 否则 hint banner V1 上线时空 |

### 5.2 向 Frontend Engineer (FE)

| 需求 | 优先级 | 对应痛点 | 说明 |
|------|--------|---------|------|
| 列表页支持 group_by surface（同字面聚合卡片簇）+ 顶栏 filter/sort 控件 | P0 | 痛点 1 | UX 核心 |
| 详情页顶部 hint banner（4 字段表格 + 一致性 badge + 复用按钮）| P0 | 痛点 1 | UX 核心 |
| 原文展示 surface 多点高亮（支持同段双指代如楚怀王 §6 不同位置不同颜色）| P0 | 痛点 3 + 痛点 7 | 视觉 UX |
| 决策表单支持 markdown rich text（预览 + 表格 + 引用块 + 链接）| P0 | 痛点 4 | 表单核心 |
| 表单 6 个快捷模板按钮（引用最近 sprint / in_chapter / other_classical / slug-dedup / commit hash / ADR）| P0 | 痛点 1 + 痛点 4 | 核心 UX |
| "提交后跳下一条" 默认排序逻辑（同簇优先 → 有 hint 优先 → 时序）| P0 | 痛点 1 | inbox 模式心脏 |
| "批量按 hint" 按钮（同簇历史一致时一键应用）+ 二次确认弹窗 | P1 | 痛点 1 | 进阶 UX |
| 视觉锚点 emoji 系统（🔁 重复 / 🆕 新 / ⚙️ structural / ⚠️ dynasty bug / 📋 协议保护）| P1 | 痛点 1 + 痛点 4 | 速读支持 |
| 进度条 / "全部裁完"祝贺界面 | P2 | UX 完整性 | V1.1 候选 |

### 5.3 向 Pipeline Engineer (PE)

| 需求 | 优先级 | 对应痛点 | 说明 |
|------|--------|---------|------|
| Stage 5 E2E 验证时提供 8 条历史 pending data sample（按 §4.2 选定，含 6 个 case 类型） | P0 | E2E 验证 | hist 实测 input |
| 评估"approve seed_mapping → V1 不自动 active"是否影响 R6 prepass 路径（V1 仅 mark status）| P0 | 下游兼容 | 架构师 brief §2 已定 |
| 评估 NER QC flag（surface 不在 raw_text 字面出现）是否能在 V1 实现（依赖 H 楚怀王 mention bucketing 经验）| P1 | 痛点 7 | V1 优先 / V1.1 兜底 |
| 配合 BE 把 4 份历史 review markdown（γ/δ/H/ε commit hash 已知）解析后批量回填 triage_decisions | P1 | 痛点 1 hint 启动数据 | 一次性脚本 |
| 评估 dynasty bug 数据修复（吕后 / 刘盈）是否在 Sprint K 内消化还是开 T-P1-031 | P2 | 痛点 7 衍生 | 架构师 brief §4 已部分 cover |

### 5.4 向架构师（Stage 1 设计输入）

| 议题 | 决策类型 | 说明 |
|------|---------|------|
| `triage_decisions` 表 schema 是否包含 commit_hash 字段 | schema 决策 | hist 强烈建议含此字段（audit trail 必要）|
| GraphQL union type vs 分两 query | 接口设计 | hist 不强偏好，BE 主导 |
| Auth V1 简化方案 | URL token / X-User header / 配置项 | hist 建议**配置项**模式（hist 本机 .env 设 `HISTORIAN_ID=historian@huadian` 即可，不需 URL 操作）|
| 历史 review markdown 4 份是否纳入 V1 backfill | scope 决策 | hist 强烈建议**必须** backfill — 否则 hint banner V1 启动时空，痛点 1 缓解效果归零 |
| ADR-027 起草必要性 | ADR 决策 | hist 建议起草（historian 工作流是项目长期模式）|

---

## §6 元信息

- **裁决人**：Historian (Opus 4.7 / 1M)
- **完成时长**：约 2.5 小时（含 8 份输入文档阅读 + 文档撰写）
- **输入文档清单**：
  - CLAUDE.md / docs/STATUS.md（offset 1-200）/ docs/CHANGELOG.md（行 1-100）
  - .claude/agents/historian.md
  - docs/sprint-logs/sprint-k/stage-0-brief-2026-04-28.md
  - docs/sprint-logs/T-P0-006-gamma/historian-review-2026-04-25.md（35 组裁决样本）
  - docs/sprint-logs/T-P0-006-delta/historian-review-2026-04-25.md（21 组裁决样本）
  - docs/sprint-logs/sprint-j/historian-review-2026-04-28.md（23 组裁决样本，原 brief 路径 T-P0-006-epsilon 不存在，实际位于 sprint-j）
  - docs/sprint-logs/sprint-h/historian-chu-huai-wang-mentions-2026-04-26.md（mention bucketing 二次裁决先例）
- **稳定性**：本 inventory 在当前 4 sprints（G/H/I/J）已完成 + Sprint K 尚未启动的前提下成立。如 Sprint K 期间架构师 Stage 1 设计推翻"hint 启动 backfill"假设，§5.4 需重审。

---

> **Historian 签字**：以上 4 项产出（§1 痛点 / §2 UI 流程 / §3 metadata / §4 E2E + sample / §5 跨角色需求）反映本人作为 V1 真实用户的需求陈述。痛点 1（重复审同 surface 判断疲劳）是 V1 必须解决的核心，hint feature + inbox 模式是建议设计的两根支柱。架构师 Stage 1 设计如有 trade-off 抉择，建议优先保 hint feature 的完整性（即使牺牲其他 metadata 完备性）。
>
> **审核人**: historian@huadian
> **日期**: 2026-04-28
