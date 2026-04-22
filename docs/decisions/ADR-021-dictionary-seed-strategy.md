# ADR-021 — Dictionary Seed Strategy (open-data-first, Wikidata as sole TIER-1 source)

- **Status**: Accepted
- **Date**: 2026-04-21
- **Authors**: 首席架构师（决策）+ x86（需求澄清）
- **Related**:
  - `docs/research/T-P0-026-dictionary-seed-feasibility.md`（调研全文）
  - ADR-015（evidence chain fill plan — `seed_dictionary` provenance tier 已预留）
  - ADR-010（跨 chunk 身份消歧 — R1-R5 规则体系，待扩 R6 seed match）
  - ADR-014（canonical merge execution model — seed 条目不触发 merge）
  - T-P0-025（计划中的 Sprint B，本 ADR 决议后启动）

---

## 1. Context

### 1.1 触发

T-P0-024 α 完成后，V7 evidence 覆盖率达到 96.37%。下一阶段扩展到更多语料时将遇到：

- NER 精度天花板（当前三本书内 94%，新文本会引入未见 surface）
- 消歧缺少外部权威锚点（同名异人只靠 prompt heuristic）
- 评价集稀缺（无外部 ground truth 对标）

这些问题的共同解是：**引入外部词典 seed 数据**。

### 1.2 业务约束

- x86 指示：**Phase 0-1 只用公开数据**
- CLAUDE.md §1：**HuaDian 未来可能商业化**（Web 展示、API 开放、商业版本）
- 约束交集：**任何进入主数据库的 seed 数据必须兼容未来商业化**，即不能带 NonCommercial 条款、不能带 Share-Alike viral clause

### 1.3 调研结论

详见 `docs/research/T-P0-026-dictionary-seed-feasibility.md`。核心 3 个候选源的 license 与覆盖度评估：

| 源 | License | 商业化兼容 | 对当前 era 的覆盖 | 结论 |
|---|--------|----------|-----------------|------|
| **Wikidata** | CC0 | ✅ | ⭐⭐⭐（秦汉中等，先秦稀薄） | 唯一可直接入主库的源 |
| **CBDB** | CC BY-NC-SA 4.0 | ❌（NC + SA viral） | ⭐（7-19 世纪为主，唐前稀薄） | 不入库，Phase 2+ 再评 |
| **ctext dict** | 订阅 + 抓取禁 | ❌ | ⭐⭐（古汉语字义） | 延后，需订阅 + 独立 ADR |

---

## 2. Decision

### 2.1 TIER-1（本决议批准）

**Wikidata 作为 Sprint B（T-P0-025）的唯一 seed 数据源**：

- License：CC0（公共领域等价）
- 接入方式：SPARQL endpoint（小规模）+ 本地 weekly dump（全量索引）
- 覆盖策略：先匹配现有 320 active persons → 补充属性（生卒年 / 家族 / 官职 / 地点）→ 扩展到新语料摄入时的 seed-first 预标记

### 2.2 TIER-2（本决议明示禁用）

**CBDB 在 Phase 0-1 不启用**，理由：

- 🔴 CC BY-NC-SA 4.0 的 NC 条款与 HuaDian 商业化路径不兼容
- 🔴 SA（ShareAlike）viral clause 会传染主库下游
- 🔴 CBDB 密集覆盖 7-19 世纪，与 HuaDian 当前 Phase 0-1 的先秦—秦汉语料错配
- 📌 2018 年后 ChineseAll.com 持有独家商用许可，自行商用有明确法律风险

**未来启用条件**（Phase 2+）：
- 扩展到唐宋元明清语料时，**独立 ADR 重新裁决**
- 可选择方案：
  - 方案 A：放弃商用，改为非商业研究项目（需产品路线重新评估）
  - 方案 B：仅作"人工参考"（历史学家 / 架构师肉眼对照），不入代码和数据库
  - 方案 C：向 ChineseAll.com 洽谈商用授权

### 2.3 TIER-3（延后）

**ctext.org 字典 API 在本 ADR 范围内延后**：

- 需要订阅（向 Donald Sturgeon 洽谈）
- 现有 ctext text adapter（`services/pipeline/sources/ctext.py`）**保持现状不扩展**
- 启动条件：x86 或历史学家角色主导订阅洽谈 → 独立 ADR → 独立 Sprint

### 2.4 TIER-4（辅助）

**项目自建 seed 作为 Wikidata 的补丁**：

- 针对 Wikidata 覆盖不到的先秦 / 上古人物
- 源：公共领域古籍注疏（《史记》三家注、《尚书》孔传、《左传》杜注等）
- License：项目自主选择（建议 CC BY 4.0 或 CC0）
- 形态：YAML / JSON 文件，checked into git
- 规模预估：~50–100 条高频名人物
- 交付方式：Sprint B（T-P0-025）的 follow-up，或独立 Sprint T-P0-025b

### 2.5 Seed Schema（v0.1）

三表设计，与主 schema 解耦：

- `dictionary_sources` — 源注册（含 license 字段 + commercial_safe 门槛标志）
- `dictionary_entries` — 原始条目（attributes JSONB 保留源字段，不强制归一）
- `seed_mappings` — 条目 ↔ HuaDian 实体映射（confidence + mapping_status 支持撤回）

完整 DDL 见 `docs/research/T-P0-026-dictionary-seed-feasibility.md` §5.2。

### 2.6 与现有架构集成

| 现有组件 | 集成方式 |
|---------|---------|
| **ADR-015 evidence chain** | seed 写 source_evidences 时 `provenance_tier = 'seed_dictionary'`（枚举值已存在 migration 0008） |
| **ADR-010 identity_resolver** | 新增 R6-seed-dictionary-match 规则，优先级高于 R1-R5 |
| **ADR-014 apply_merges** | **seed 不触发 merge**；seed_mappings.confidence < 0.8 进 identity_hypotheses 待审 |
| **load.py 写路径** | 新增 seed_preprocessor，NER 前预标记命中条目，命中直接 bind to target_entity_id |
| **Web Person card** | 外部链接区块显示 Wikidata Q-number（若有 seed_mapping）；不显示 CBDB 链接（NC 风险） |

---

## 3. Rationale

### 3.1 为什么不让 CBDB 进入"pipeline-time 查询参考"

表面上，"查询而不入库"似乎规避 NC/SA 条款。但实际存在两个风险：

1. **Gray area**：如果管线在抽取过程中查 CBDB 验证并据此改写 persons 表的字段，这个写入的结果是否算 CBDB 派生数据，法律上尚未清晰。稳妥做法是**管线任何环节都不接触 CBDB 数据**
2. **操作复杂度**：管理"什么时候可以查 / 什么时候不能用"的边界，比"完全不启用"的运营成本高得多

Phase 0-1 的 HuaDian 数据体量足够小（< 1000 persons），Wikidata 单源 + 自建 seed 已经够用。CBDB 在 Phase 2 扩展到后期朝代时再系统性评估，不强行在 Phase 0-1 挤进来。

### 3.2 为什么 seed 表独立于 persons 表

核心原因：**可撤回性**。

- 若未来发现某条 seed mapping 错误，直接 `UPDATE seed_mappings SET mapping_status='rejected'`，主库 persons 表不受影响
- 若未来更换 seed 源（例如从 Wikidata 2026-04-21 dump 升级到 2026-10 dump），旧的 mappings 可整批 supersede，新的并行写入
- 与 identity_hypotheses 和谐共存——seed_mappings confidence 低的条目直接转成 identity_hypothesis 走人工 review 流程

### 3.3 为什么 R6 优先级最高

R1-R5 都是基于 NER 输出的 surface 和 context 的 heuristic，本质是概率推断。seed 命中是**外部权威锚点**，一旦命中就没有更高优先级的信息来源。R6 排在最前等于"如果 seed 说是这个人，就是这个人"。

但 R6 只处理**精确 name match**，不做模糊匹配——模糊匹配保留给 R1-R5，这样避免 seed 数据质量问题污染其他规则。

---

## 4. Consequences

### 4.1 正面

- Phase 0-1 的 NER + 消歧有外部锚点可参照，精度和一致性双升
- 主库数据 license 纯净，未来商业化无后顾之忧
- Schema 预留多源扩展能力，Phase 2+ 加入 CBDB 或商业词典时不需要重构
- Evidence chain（ADR-015）的 `seed_dictionary` 枚举值从"预留"变成"真实写入"，闭环

### 4.2 负面 / 需要接受

- Wikidata 对先秦人物覆盖稀薄，Sprint B 对上古人物的 seed 增益有限（需要 T-P0-025b 自建 seed 补足）
- CBDB 的高价值数据（唐宋元明清）在 Phase 0-1 完全放弃
- 需要新增三张表（dictionary_sources / dictionary_entries / seed_mappings）和一次 migration
- Pipeline 入口增加一层 seed_preprocessor，复杂度和维护成本上升

### 4.3 回滚路径

若本 ADR 决定后续证明有误（例如 Wikidata 覆盖率太低、自建 seed 工作量爆炸）：

- seed 三表 DROP 不影响主库数据（seed 仅 reference 主库，不被主库 reference）
- R6 规则从 resolve_rules.py 移除即可恢复旧行为
- ADR-021 supplement 记录回滚理由

---

## 5. Known Follow-ups

### 5.1 Sprint B（T-P0-025）

- **前置 probe**：Wikidata 对现有 320 persons 的匹配率
  - 若 < 20% → Sprint B scope 收缩，强 T-P0-025b 前置
  - 若 ≥ 40% → Sprint B 按计划推进
- **法律兜底**：Wikidata CC0 license 条款在 ingest 时记录到 `dictionary_sources.license` 字段，license 变更时有痕可查

### 5.2 V8 invariant 候选

Sprint B 收尾时考虑新增 V8 invariant：**seed_mappings 的 target_entity_id 必须在 persons/places/polities 等主表中存在且 active**（防孤儿 mapping）。警告级起步，Sprint C 后强制。

### 5.3 CBDB Phase 2 评估

扩展到唐宋语料时，重开 CBDB 评估（独立 ADR），评估内容：
- 当时 HuaDian 是否已明确商业化路线（若放弃商用，CBDB 限制消失）
- ChineseAll.com 授权成本
- CBDB 作为"pipeline-time 查询参考"的法律边界

### 5.4 ctext.org 订阅决策

若启动 ctext dict API 订阅：
- x86 或历史学家角色主导洽谈 Donald Sturgeon
- 订阅条款落入 dictionary_sources.license 字段
- 独立 ADR 裁决接入方式与使用范围

---

## 6. Notes on ADR Numbering

本 ADR 起草时原拟编号 018，落笔前发现 `ADR-000-index.md` 已把 016 / 018 / 019 / 020 四个编号预占给其他 planned 主题（搜索召回回溯 / extractions_history C-11 / 多语言 JSONB / Prompt 版本化）。为不侵占预占主题，本 ADR 跳到下一空位 **021**。预占主题待各自独立起草时沿用其原分配编号。

---

## Implementation Summary (Sprint B, 2026-04-22)

### Artifacts

| Layer | File | Purpose |
|-------|------|---------|
| Migration | `0009_dictionary_seed_schema.sql` | 3 tables: dictionary_sources / dictionary_entries / seed_mappings |
| Migration | `0010_seed_mappings_add_pending_review_status.sql` | Extend status CHECK for multi-hit triage |
| Migration | `0011_seed_unique_index_naming_alignment.sql` | Align UNIQUE constraint names with Drizzle |
| Drizzle | `packages/db-schema/src/schema/seeds.ts` | J layer schema (dictionarySources / dictionaryEntries / seedMappings) |
| Adapter | `services/pipeline/src/huadian_pipeline/seeds/wikidata_adapter.py` | SPARQL client with rate limiting + retry |
| Matcher | `services/pipeline/src/huadian_pipeline/seeds/matcher.py` | R1/R2/R3 three-round matching engine |
| CLI | `services/pipeline/src/huadian_pipeline/seeds/cli.py` | `load --mode dry-run/execute` |
| Pseudo-book | `services/pipeline/src/huadian_pipeline/seeds/pseudo_book.py` | source_evidence anchor for seed_dictionary tier |
| R6 Rule | `services/pipeline/src/huadian_pipeline/r6_seed_match.py` | Seed-first identity resolver lookup (ADR-010 §R6) |
| Invariant | `services/pipeline/tests/test_invariants_v10.py` | V10.a/b/c seed_mapping consistency (6 tests incl. self-tests) |

### Bootstrap Results (320 active persons, Wikidata source_version=20260422)

| Round | Count | Confidence | DB status |
|-------|-------|------------|-----------|
| R1 single | 149 | 1.00 | active |
| R2 alias | 4 | 0.85 | active |
| R3 scan | 6 | 0.70 | active (below R6 cutoff, not auto-bound) |
| R1 multi | 8 persons / ~17 candidates | n/a | pending_review |
| R2 multi | 7 persons / ~21 candidates | n/a | pending_review |
| R3 multi | 1 person / ~3 candidates | n/a | pending_review |
| No match | 145 | n/a | not written |

**R6 visibility**: 153 matched, 6 below_cutoff, 44 pending invisible.

**DB totals**: dictionary_sources=1, dictionary_entries=201, seed_mappings=203 (159 active + 44 pending_review), source_evidences(seed_dictionary)=159.

### Open Follow-ups

- **T-P0-025b**: manual triage UI for 16 pending_review persons (Sprint C)
- **T-P1-022**: 27 persons missing is_primary=true name (V1 lower-bound gap)
- Hit rate 49.7% — second TIER-1 source (CBDB / Baike) deferred to future ADR evaluation
