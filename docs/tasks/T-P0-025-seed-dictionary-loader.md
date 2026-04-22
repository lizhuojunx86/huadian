# T-P0-025 — 字典 Seed Loader（Sprint B，Wikidata TIER-1）

- **状态**: done（Sprint B 完成 2026-04-22；ADR-021 final accepted）
- **优先级**: P0
- **主导角色**: 管线工程师 + 后端工程师（schema migration）+ 架构师（Stage ruling）
- **所属 Phase**: Phase 0 tail（数据治理 → 消歧基础设施）
- **预估工期**: 3-5 工作日（Gate 0a 已耗 0.5d；余下 Stage 0b-5 估 3-4d）
- **LLM 成本**: $0（SPARQL + 结构化 matching，不调 LLM）
- **ADR 依据**: ADR-021（Dictionary Seed Strategy）/ ADR-015 provenance_tier seed_dictionary / ADR-010 identity_resolver / ADR-014 canonical merge
- **创建日期**: 2026-04-21（重写自 pre-ADR-021 版本；原窄范围 JSON loader 已迁到 T-P0-025b）

---

## 1. Sprint 目标

把 Wikidata 里匹配到 HuaDian 现有 active persons 的条目，以 seed 形式入库，并激活 seed-first 消歧路径（R6 规则）。本 Sprint 定义**首条"外部权威锚点"进入项目**的规格与边界。

### 1.1 上线后的项目变化

- 主库 `dictionary_sources` / `dictionary_entries` / `seed_mappings` 三张新表（migration 0009）
- `source_evidences` 表首次写入 `provenance_tier = 'seed_dictionary'` 行（ADR-015 枚举从"预留"到"真实使用"）
- `resolve_rules.py` 新增 R6 规则，优先级高于 R1-R5
- `services/pipeline/src/huadian_pipeline/seeds/wikidata_adapter.py` 新模块
- 一次性 loader CLI：`uv run python -m huadian_pipeline.seeds.cli load --source wikidata`
- 新不变量候选 V9 / V10（见 Stage 4）
- Web Person 卡片外部链接区块（Wikidata Q-number，若有）→ 可并入本 Sprint 或延至 Sprint C

### 1.2 度量目标（Sprint 结束时）

| 指标 | 目标值 | 来源 |
|------|-------|------|
| 生产 seed_mappings 行数 | ≥ 170 行 | Gate 0a probe 命中 174 减去多候选手动 review 流失 |
| seed_mappings coverage（active persons 比例） | ≥ 50% | ≥ 170 / 320 |
| R6 规则激活测试覆盖 | 3 cases（exact match 成功 / alias 成功 / no match 回落 R1-R5） | 管线 unit tests |
| 所有现有不变量 V1-V8 无回归 | 全绿 | CI |
| Wikidata license 记录可审计 | `dictionary_sources.license='CC0' AND commercial_safe=true` | SQL |

---

## 2. 上游依据（硬依赖）

- **ADR-021 §2.1**：Wikidata 作为唯一 TIER-1 seed 源
- **ADR-021 §2.5**：三表 schema（DDL 见 `docs/research/T-P0-026-dictionary-seed-feasibility.md` §5.2）
- **ADR-021 §5.1**：前置 probe（= 本 Sprint Gate 0a）
- **ADR-015**：`provenance_tier = 'seed_dictionary'` 枚举已在 migration 0008 就位
- **T-P0-024 α**：V7 = 97.49%，evidence 覆盖保证 seed matching 的 person_names 数据质量

---

## 3. Stage 规划

### Gate 0a — Wikidata 覆盖率 Probe（✅ done）

详见 `docs/tasks/T-P0-025/gate-0a-wikidata-probe.md` 与报告 `docs/research/T-P0-025-gate-0a-wikidata-probe-report.md`。

**Gate 0a 结论**：
- 全局命中率 54.4% → 决策矩阵 "≥ 40% 全量推进" 桶
- Round 1 精确 49.1% / Round 2 alias +17 / 多候选仅 2.5%
- 朝代分层：商 70.5%（最高）/ 春秋 59.1% / 西周 46.3% / 夏 45.0%
- reality_status 分层：historical 54.9% ≈ legendary 55.7%（无差异）
- 0 HTTP 错误，endpoint 稳定
- 副发现登记 **T-P1-022**（V1 下界缺失）

**Gate 0a 给 Stage 1 的输入**：
- `docs/research/T-P0-025-gate-0a-wikidata-probe-details.json`（320 条 matching 明细）
- 前 30 条未命中样本 → T-P0-025b 输入
- 8 条多候选样本 → Stage 2 disambiguation case base

---

### Stage 0b — Schema Migration（migration 0009）

**主导**：后端工程师
**预估**：0.5 工作日
**前置**：pg_dump anchor（ADR-017 §2）

#### 交付物

- `services/api/src/schema/dictionaries.ts`（Drizzle schema）
- `services/pipeline/migrations/0009_dictionary_seed_schema.sql`（Python 侧 raw SQL 镜像，per ADR-017）
- Drizzle migration 生成：`pnpm db:migrate:generate`
- 落 DB：`pnpm db:migrate`

#### Schema 约束（严格按 ADR-021 §2.5 / T-P0-026 §5.2）

三表不能改字段名 / 类型。**若工程师在落地时发现必须调整**（例如 Drizzle 类型映射问题），停下来走架构师 review，不自行改。

#### 不变量预留

- `dictionary_entries.UNIQUE (source_id, external_id)` — 防同源重复条目
- `seed_mappings.UNIQUE (dictionary_entry_id, target_entity_type, target_entity_id, mapping_status)` — 防重复 mapping
- `seed_mappings.confidence` `CHECK (confidence >= 0.00 AND confidence <= 1.00)` — 约束合法范围
- `dictionary_sources.commercial_safe` NOT NULL — 未来非商用源**必须显式**声明

#### pg_dump anchor

```bash
pg_dump -Fc -f ops/rollback/pre-t-p0-025-stage-0b-$(date +%Y%m%d-%H%M%S).dump huadian_pipeline
```

#### Gate 0b Done

- [ ] migration 0009 落 prod
- [ ] Drizzle schema 同步，API 可 introspect（即使没 resolver）
- [ ] Python 侧 migration hash 验证通过
- [ ] pg_dump anchor 保存
- [ ] V1-V8 无回归

---

### Stage 1 — Wikidata Adapter + Matching

**主导**：管线工程师
**预估**：1-1.5 工作日

#### 交付物

- `services/pipeline/src/huadian_pipeline/seeds/__init__.py`（新子包）
- `services/pipeline/src/huadian_pipeline/seeds/wikidata_adapter.py`
- `services/pipeline/src/huadian_pipeline/seeds/matcher.py`
- `services/pipeline/src/huadian_pipeline/seeds/cli.py`（`load` / `dry-run` 子命令）
- `services/pipeline/tests/test_seeds_wikidata_adapter.py`
- `services/pipeline/tests/test_seeds_matcher.py`

#### Matching Strategy（三轮，基于 Gate 0a 发现扩充）

| Round | 输入 | Query | 用途 |
|-------|------|-------|------|
| R1 | `persons.canonical_name` | `rdfs:label "..."@zh + wdt:P31 wd:Q5` | 高置信 exact match（Gate 0a 命中 157） |
| R2 | `person_names` WHERE `name_type IN ('primary','alias')` | `skos:altLabel + wdt:P31 wd:Q5` | Alias 补 match（Gate 0a 补 17） |
| **R3（新）** | `person_names` 全量（不限 name_type） | `rdfs:label OR skos:altLabel + wdt:P31 wd:Q5` | **Type B 错配补救**（高辛↔帝喾 类） |

**R3 是 Gate 0a 之后新增的 matching 轮次**，专治"Wikidata 有但 HuaDian 用了非标准 canonical_name"的 type B 问题。R3 预期再补 20-40 persons（架构师估算，Sprint 后实测）。

#### Confidence 算法（写入 `seed_mappings.confidence`）

| Matching 路径 | confidence |
|--------------|-----------|
| R1 single hit | 1.00 |
| R1 multi hit（候选 ≥ 2）不自动选 | 不写 seed_mappings；进 identity_hypotheses 走 manual review |
| R2 alias hit | 0.85 |
| R3 全 person_names 扫 hit | 0.70 |

`seed_mappings.mapping_method` 记录路径来源：`'r1_exact' / 'r2_alias' / 'r3_name_scan'`。

#### Wikidata 礼仪（ADR-021 §2.1 约束）

- User-Agent: `HuaDian-Loader/<version> (https://github.com/<org>; contact@example.com) T-P0-025`
- Rate limit: ≤ 1 req/sec（复用 Gate 0a probe 实测参数）
- 失败重试 3 次（指数退避）
- 超时 30s

#### Dictionary Entries 入库策略

**每次 matching 成功时**，两步 INSERT（per ADR-015 pattern）：
1. INSERT `dictionary_entries`（若 `UNIQUE(source_id, external_id)` 已存在则 ON CONFLICT DO NOTHING，取既有）
2. INSERT `seed_mappings`（若 `UNIQUE(entry_id, target_entity_type, target_entity_id, 'active')` 已存在则 skip）

**幂等性**：重跑 Stage 1 不产生重复；配置变更重跑走 superseded 流程（`UPDATE seed_mappings SET mapping_status='superseded'` + 新行 INSERT）。

#### Gate 1 Done

- [ ] adapter 模块化（SPARQL 查询、结果 parsing、错误处理各成函数）
- [ ] matcher 三轮策略落盘
- [ ] CLI 有 `--dry-run`（读 DB 320 persons，跑 SPARQL，不 INSERT，打印 matching summary）
- [ ] tests ≥ 10 cases（每轮 matching 3 正 + 2 负 + R3 edge + multi-hit skip + rate limit respect）
- [ ] CI 全绿（V1-V8 无回归）

---

### Stage 2 — Matching 执行 + Manual Review Queue

**主导**：管线工程师 + 历史专家（multi-hit 仲裁）
**预估**：0.5-1 工作日

#### 交付物

- Stage 1 CLI `--mode=execute` 跑生产数据
- Manual review queue：multi-hit 的 8 条（Gate 0a 已知：白起 / 比干 / 伯夷 / 姚 / 惠王 / 朱虎 / 申侯 / 祖辛）进 `identity_hypotheses` 表，历史专家 review
- 每条 hypothesis 含 Wikidata 候选 Q-number + Wikidata 的 description + HuaDian person 的 alias / dynasty，供 historian 断

#### 执行流程

1. pg_dump anchor `pre-t-p0-025-stage-2-*.dump`
2. `uv run python -m huadian_pipeline.seeds.cli load --source wikidata --mode execute` → 写入 dictionary_sources + entries + mappings + source_evidences
3. `source_evidences` 写法：每条 seed_mapping 产出一行，`provenance_tier='seed_dictionary'`，`llm_call_id=NULL`，`raw_text_id` 指向新建 pseudo book "Wikidata dump <YYYYMMDD>"（T-P0-026 §6.1 约束）
4. Multi-hit 8 条跑 historian review；review 完成后把选中的 Q 写入 seed_mappings

#### Gate 2 Done

- [ ] seed_mappings 行数 ≥ 170（R1 149 + R2 17 + R3 新增 + 手动 review 确认的 multi-hit）
- [ ] source_evidences 新增 seed_dictionary 行数 = seed_mappings 行数
- [ ] identity_hypotheses 8+ 行 multi-hit 已处理（batch 或 individually）
- [ ] 所有 mapping 的 target_entity_id 指向 active person（V-candidate orphan check）
- [ ] STATUS 不变量表更新

---

### Stage 3 — R6 Seed-Match 规则集成 resolve_rules.py

**主导**：管线工程师
**预估**：0.5 工作日

#### 交付物

- `services/pipeline/src/huadian_pipeline/resolve_rules.py` 新增 `r6_seed_dictionary_match()`
- Rule chain 调整：R6 优先级高于 R1-R5
- `services/pipeline/tests/test_resolve_rules_r6.py`

#### R6 语义（ADR-021 §3.3）

**只处理精确 name match**：若 NER 输出的 surface 与某条 active seed_mapping 的 target person 的 `person_names` 精确匹配（case-sensitive），直接 bind 到该 target_entity_id，skip R1-R5。

**不做模糊匹配**：模糊留给 R1-R5，避免 seed 数据质量问题污染其他规则。

**confidence 下限**：`seed_mappings.confidence >= 0.80` 的 mapping 才生效 R6；低于 0.80 的 mapping 仅作为 identity_hypothesis 参考，不自动 bind。

#### Gate 3 Done

- [ ] R6 实现 + rule chain 接入
- [ ] tests ≥ 3（R6 命中 / R6 confidence 低回退 R1-R5 / R6 无 mapping 回退 R1-R5）
- [ ] 回归测试：现有 identity_resolver 输出（3 本书 282 tests）无改变
- [ ] ADR-010 supplement：R6 条目新增到 R1-R5 规则表（by 架构师，可作为 Stage 5 小补丁）

---

### Stage 4 — V Invariant 候选 + Self-Test

**主导**：管线工程师 + 架构师（invariant 规格）
**预估**：0.5 工作日

#### 候选不变量

**V9 候选 — seed_mapping orphan check**（ADR-021 §5.2 预留）：

```sql
SELECT sm.id, sm.target_entity_id
FROM seed_mappings sm
WHERE sm.mapping_status = 'active'
  AND sm.target_entity_type = 'person'
  AND NOT EXISTS (
    SELECT 1 FROM persons p
    WHERE p.id = sm.target_entity_id
      AND p.deleted_at IS NULL
      AND p.merged_into_id IS NULL
  );
```

期望：0 违反（active seed_mapping 必须指向 active person）

**V9 vs T-P1-022 V9 命名冲突**：
T-P1-022 提议的 V9 是 "at-least-one-primary"；本 Stage 4 的 V 候选是 "seed_mapping_target_active"。两者择一 V9 命名，架构师在 Stage 4 review 时定夺（倾向 T-P1-022 的 V9 命名早期提出，本 Stage 4 用 V10）。

#### Self-Test 强制（参考 ADR-023 §2.3 的 V8 模式）

1. 生产数据 V10 = 0
2. 注入 orphan mapping → V10 抓到
3. mapping status = superseded → V10 不报（过滤 active）

#### Gate 4 Done

- [ ] V10（或 V9 别命名）SQL + 实现
- [ ] Self-test 3 cases
- [ ] CI 集成
- [ ] STATUS 不变量表新增

---

### Stage 5 — Sprint 收尾

**主导**：架构师（主） + 管线工程师
**预估**：0.5 工作日

#### 交付物

- STATUS.md：Sprint B 收尾数据 + 不变量表扩 V10 + 健康度指标更新
- CHANGELOG.md：2026-04-XX 节 Sprint B 三视图
- 架构师复盘：`docs/retros/sprint-b-YYYY-MM-DD-retro.md`（参考 Sprint A 格式）
- ADR-021 supplement（若 R3 matching 需补决议 / multi-hit 处理形成 precedent）
- Web 外链集成**可选**并入（若工期允许）；否则延 Sprint C

---

## 4. 集成点（详细）

### 4.1 Evidence 链（ADR-015）

- `source_evidences.provenance_tier = 'seed_dictionary'`（migration 0008 已就位）
- `source_evidences.raw_text_id` 指向特殊 pseudo book "Wikidata dump YYYYMMDD"
- 需 Stage 2 前预建该 book 条目（一次性，一行 INSERT）

### 4.2 identity_resolver（ADR-010）

见 Stage 3。R6 优先级最高，confidence ≥ 0.80 才生效。

### 4.3 canonical merge（ADR-014）

**seed 不触发 merge**（ADR-021 §2.6）。即使 Wikidata 显示某两条 HuaDian persons 应合并（例如高辛 + 帝喾 + 喾），本 Sprint 不自动 merge。该信息作为 identity_hypothesis 让 historian review，走 ADR-014 流程。

### 4.4 load.py

Stage 1 不改 load.py；R6 在 resolve_rules.py 入口即生效。load.py 层面的 seed_preprocessor（ADR-021 §2.6 提到的"NER 前预标记"）**不在 Sprint B 范围**，延至 Sprint C 或更后。

### 4.5 Web

- `GET /persons/:slug` 返回 seed_mappings 若有 → 前端显示 Wikidata Q-number + 链接
- 前端组件：`<ExternalLinks />` 新增，默认只展示 Wikidata（不展示 CBDB 等 NC license 源）
- **可选并入 Sprint B**：若 Stage 0b-4 顺利，Stage 5 前并入。否则 Sprint C 独立处理

---

## 5. 风险 / 开放问题

| # | 风险 | 严重度 | 处理 |
|---|------|-------|------|
| R1 | R3 matching 命中率远低于架构师估（20-40） | 中 | 实测若仅补 5 内，登记 Sprint B Type B 补救不力，T-P0-025b 前置优先级上调 |
| R2 | Wikidata 某些人物条目有 vandalism / 错合并 | 低 | seed_mappings.confidence 默认写 0.85 以下 mapping_method=r2/r3 + manual spot check 抽样 20 条 |
| R3 | dictionary_sources 三表未来扩字段（如 last_checked_at）导致 migration 滚动 | 低 | Stage 0b schema 留 notes JSONB 口袋字段，未来扩展从 JSONB 抽出 |
| R4 | R6 与未来 soft-delete 机制交互 | 低 | 当前 seed_mappings UNIQUE 包含 mapping_status，soft-delete 时 update status='superseded'，新 mapping INSERT，与 ADR-014 / ADR-013 pattern 一致 |
| R5 | Wikidata rate limit 被触发导致 Stage 1 分段跑 | 低 | Gate 0a 实测 320 persons 耗 245s 无 HTTP 错误，实战跑 batch=15 应稳 |

---

## 6. 验收标准（Sprint 级）

- [ ] migration 0009 落 prod，三表就位
- [ ] `dictionary_sources` 含 1 行 `source_name='wikidata', license='CC0', commercial_safe=true`
- [ ] `dictionary_entries` 行数 ≥ 170
- [ ] `seed_mappings` 行数 ≥ 170，`mapping_status='active'` 占比 ≥ 95%（余下为 superseded 测试行）
- [ ] `source_evidences` 新增 seed_dictionary 行数 = seed_mappings 行数
- [ ] R6 规则上线，3 cases tests 通过
- [ ] V1-V9（或 V10）全绿
- [ ] pipeline tests 从 282 扩至 ≥ 295（+10-15 new tests across stages）
- [ ] STATUS + CHANGELOG + retro 齐
- [ ] T-P1-022（V1 下界）仍在 backlog 不被本 Sprint 阻塞

---

## 7. 预算与回滚

### 7.1 预算

- **工期**: 3-4 工作日（Gate 0a 已耗 0.5d，余 2.5-3.5d）
- **LLM 成本**: $0
- **网络成本**: Stage 1 ~400 SPARQL queries (batched)
- **commits 预估**: 5-7 on main

### 7.2 回滚

| Stage | 回滚方式 |
|-------|---------|
| Stage 0b migration | Drizzle migration 回滚 + pg_restore 从 pg_dump anchor |
| Stage 1 adapter | git revert；DB 无改动 |
| Stage 2 matching 入库 | `UPDATE seed_mappings SET mapping_status='rejected'` 整批；pg_restore 兜底 |
| Stage 3 R6 | git revert；resolve_rules.py 恢复 R1-R5 原链 |
| Stage 4 V invariant | 从 invariants 套件移除对应 check |

---

## 8. 备注

- 原 pre-ADR-021 卡片内容（"加载 40 条 persons.seed.json"）已迁到 T-P0-025b
- Gate 0a 已完成，副发现 T-P1-022 已登记
- 本 Sprint 不处理 CBDB / ctext.org 词典 API（按 ADR-021 §2.2 / §2.3 延后）
- Sprint B 结束后首选下一条路径候选：T-P0-025b / T-P1-021 / T-P1-022
