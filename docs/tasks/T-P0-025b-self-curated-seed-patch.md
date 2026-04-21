# T-P0-025b — 自建 Seed 补丁（TIER-4 Self-Curated Patch）

- **状态**: backlog
- **优先级**: P1（Sprint B 后的 follow-up，不阻塞）
- **主导角色**: 管线工程师 + 历史专家
- **所属 Phase**: Phase 0 tail / Phase 1 head
- **依赖**: T-P0-025（Sprint B 主体完成；seed schema 已落地，可直接复用）
- **ADR 依据**: ADR-021 §2.4（TIER-4 自建 seed 作为 Wikidata 补丁的定位）
- **创建日期**: 2026-04-21（从原 T-P0-025 pre-ADR-021 卡片演化而来）

---

## 1. 背景

### 1.1 T-P0-025 Gate 0a 发现

Wikidata 对现有 320 active persons 的命中率为 54.4%（174/320），146 人未命中。未命中的形态按 probe 分析分三类：

| 类型 | 描述 | 数量级 | 处置建议 |
|------|------|-------|---------|
| A. Wikidata 未收录 | 上古传说人物 / 先秦冷门人物（昌仆、倕、风后、简狄、嫘祖、蟜极、穷蝉、桥牛、伯臩、伯阳甫等） | 估 70-100 | **T-P0-025b 主体目标** |
| B. Label 错配 | Wikidata 有但 label 与 HuaDian `canonical_name` 不同（高辛↔帝喾、轩辕↔黄帝、古公亶父↔周太王、太伯↔吴太伯等） | 估 20-40 | 补 HuaDian `person_names` 的 alias 即可，不需自建 seed；由 **T-P0-025 Stage 1 Round 3** matching 覆盖 |
| C. 歧义/超出范围 | 未来新语料会带入的人物 | 不定 | 未来 Sprint 处理 |

### 1.2 承接现有资产

项目仓库已存在 `data/dictionaries/persons.seed.json`（40 条，2026-04-16 产出，T-P0-004 批次 1）。这 40 条是历史专家手工精校的先秦高频人物，license 属项目自有。本任务主要工作之一是：

1. **验证** 40 条与 Sprint B 落地的 seed schema 对齐
2. **扩充** 到覆盖 Gate 0a Type A 未命中名单（目标总规模 ~100-120 条）
3. **加载** 到 `dictionary_sources` / `dictionary_entries` / `seed_mappings` 三表（复用 T-P0-025 Stage 1 loader 基础设施）

---

## 2. 目标

### 2.1 产出

- 扩充版自建 seed 文件（建议路径 `data/dictionaries/persons.seed.v2.json` 或保留 `persons.seed.json` 做 append-only 增补）
- 一个 `dictionary_sources` 源注册，`source_name='self-curated'` / `license='project-owned'`（或 `CC BY 4.0`）/ `commercial_safe=true`
- 该源的 `dictionary_entries` 条目 + 对应 `seed_mappings`（自动精确名匹配优先，confidence=1.0；余者进 manual review queue）

### 2.2 覆盖目标

- Gate 0a Type A 未命中名单完全覆盖（从 probe report 前 30 + 其余 ~120 人中人工挑选值得 seed 的）
- Type B 名单作为**姓名补全队列**交给历史专家（不在 T-P0-025b 本体范围）

### 2.3 非目标

- ❌ 不抽取自商业词源（《辞源》/《汉语大词典》）
- ❌ 不走 LLM 生成 seed（历史专家主导，手工精校，AI 可辅助但不主导）
- ❌ 不触发 canonical merge（ADR-014 §2：seed 不触发 merge）

---

## 3. License 约束

按 ADR-021 §2.4，自建 seed 的 license 由项目自主选择，建议 **CC BY 4.0** 或 **CC0**，避免未来 license 升级困难。

来源可引用：
- 公共领域古籍注疏（《史记》三家注、《尚书》孔传、《左传》杜注）
- 中华书局标点本（**仅引用事实性信息，不复制注文**，避免侵犯编辑选择权）
- 历史专家自有研究

每条 seed 条目在 `attributes` JSONB 里记录 `source_citation`（古籍卷次 + 现代标点本版本），便于未来审计。

---

## 4. 阶段计划（粗粒度）

| Stage | 内容 | 预估 |
|-------|------|------|
| 0 | 盘点：基于 Gate 0a probe 的 146 未命中列表，按类型 A/B/C 筛选 + 历史专家 review | 0.5d |
| 1 | Schema 验证：40 条既有 seed 与 Sprint B 三表 schema 对齐；找不匹配字段的桥接规则 | 0.5d |
| 2 | 扩充：目标 +60-80 条新条目，含 name / 字 / 号 / 谥 / 生卒 / 朝代 / 史源引用 | 1-2d（历史专家主导） |
| 3 | Loader：复用 T-P0-025 基础设施 + 自建 source 分支 | 0.5d |
| 4 | 载入 + 验证：V1-V9 全绿 + 抽样审计 | 0.5d |
| 5 | 收尾：STATUS/CHANGELOG/retro | — |

**总预估**：3-4 工作日（其中 2 天历史专家）

---

## 5. 集成点

### 5.1 与 T-P0-025 Sprint B 的关系

- T-P0-025b **严格依赖** T-P0-025 完成（schema 落地、loader 基础设施、R6 规则）
- T-P0-025b 启动前 T-P0-025 Sprint 必须收尾（docs + STATUS 更新 + retro）

### 5.2 与现有 `persons.seed.json` 的关系

- 原文件保留，作为 v1 seed
- v2 新增条目append-only，不覆盖 v1
- loader 需支持从多个 JSON 文件合并加载（若 schema 一致）

### 5.3 与 Wikidata seed 的冲突解决

当某条人物**同时** Wikidata 和 self-curated 都有条目时：
- 两条都记入 `dictionary_entries`（不同 source_id）
- `seed_mappings` 各建一条 mapping（各自 confidence）
- R6 seed-match 规则选高置信的那条；若两条都 high-confidence，走 identity_hypothesis

此规则在 T-P0-025 主 Sprint 已需定义（见 T-P0-025 Stage 3 §R6 设计），T-P0-025b 不新引入。

---

## 6. 风险与开放问题

| # | 风险 | 严重度 | 预案 |
|---|------|-------|------|
| R1 | 历史专家产能紧张，Stage 2 被压缩 | 中 | 先出 40+20=60 条 MVP，剩余条目作为长尾 T-P1-02X 持续增补 |
| R2 | 自建 seed 的 `attributes` JSONB 字段无规范 → 未来查询困难 | 低 | Stage 1 结束时出 v2 schema JSONL 规范文档 |
| R3 | 与 Wikidata 冲突的人物处理成本 | 低 | Phase 0 估极少，观察到再立 ADR |

---

## 7. 备注

- 本任务**不在 Sprint B 主路径**。Sprint B 可在没有 T-P0-025b 的情况下独立收尾。
- 若 Sprint B 完成后 HuaDian 不继续扩语料（停在现 3 书），T-P0-025b 的优先级会下降到 P2。
- 原 pre-ADR-021 T-P0-025 卡片内容（纯 40 条 JSON loader）演化到本任务；原卡片已重写为 Sprint B 完整规格。
