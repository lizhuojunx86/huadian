# T-P0-025 Gate 0a — Wikidata 匹配率 Probe

> **Sprint**: T-P0-025 (Seed Dictionary Loader, Wikidata TIER-1)
> **Stage**: 0a of N (probe 先行；后续 scope 依本 probe 产出决定)
> **Date**: 2026-04-21
> **Role**: Pipeline Engineer（实现 + 报告）+ Chief Architect（scope ruling）
> **Upstream**: ADR-021 §5.1（前置 probe 条款）
> **Related**: `docs/research/T-P0-026-dictionary-seed-feasibility.md` §2.1.5 / §5.1

---

## Summary

**目的**：在启动 T-P0-025 主体工程前，量化 Wikidata 对 HuaDian 现有 320 active persons 的覆盖率。产出用于 Sprint B scope 决策——ADR-021 §5.1 明文规定 probe 为 Sprint 前置门。

**非目的**：
- ❌ 不写任何 DB schema migration
- ❌ 不改 `services/pipeline/src/...` 生产代码
- ❌ 不写 seed_mappings / R6 规则
- ❌ 不触发任何 ingest / LLM 调用

**产出**：一份只读 probe 报告 + 附属 CSV/JSON 明细。约 0.5-1 工作日。

---

## 1. 度量目标

### 1.1 主要指标

| 指标 | 定义 | scope 决策用途 |
|------|------|---------------|
| **全局命中率** | 匹配到至少一个 Wikidata Q-number 的 persons 占 320 总数比例 | 主决策变量 |
| **高置信命中率** | 中文 label 精确匹配（`rdfs:label @zh`）命中 persons 占比 | 决定是否需要二轮模糊匹配 |
| **朝代分层命中率** | 按 `persons.dynasty` 分桶的命中率 | 评估 Wikidata 对先秦 vs 秦汉的差异 |
| **reality_status 分层** | 按 `realistic` / `legendary` / `divine` 分桶 | 上古神话人物（帝喾 / 颛顼）覆盖度 |

### 1.2 Sprint B scope 决策矩阵（ADR-021 §5.1）

| 全局命中率 | 决策 |
|-----------|------|
| ≥ 40% | Sprint B 按 ADR-021 §2.1 全量推进（Stage 0b-5） |
| 20% - 40% | Sprint B 推进但 scope 收缩；架构师评审是否并行启动 T-P0-025b |
| < 20% | Sprint B 暂停，优先启动 T-P0-025b（自建 TIER-4 seed） |

---

## 2. 输入

### 2.1 待匹配 persons 列表

从生产 DB 读取：

```sql
SELECT id, slug, canonical_name, dynasty, reality_status
FROM persons
WHERE deleted_at IS NULL
  AND merged_into_id IS NULL
ORDER BY slug;
```

预期 320 行（以 STATUS.md 2026-04-21 快照为准；跑时实际数为准）。

### 2.2 Wikidata endpoint

- **主路径**：`https://query.wikidata.org/sparql`
- **User-Agent**：必须设置（Wikidata policy），推荐 `HuaDian-Probe/0.1 (https://github.com/<org>; contact@example.com) T-P0-025-gate-0a`
- **速率限制**：≤ 1 req/sec（Wikidata 免费 endpoint 礼仪；320 persons 分批跑约 5-10 分钟）
- **本地 dump fallback**：若 endpoint 速率/连通有问题，可下载 weekly `latest-truthy.nt.bz2` 子集，但 **probe 阶段不必须**——先试 endpoint

---

## 3. 匹配策略（两轮）

### 3.1 Round 1 — 中文 label 精确匹配（主）

SPARQL 模板：

```sparql
SELECT ?item ?itemLabel ?description WHERE {
  ?item rdfs:label "${canonical_name}"@zh ;
        wdt:P31 wd:Q5 .          # instance of human
  OPTIONAL { ?item schema:description ?description . FILTER(LANG(?description) = "zh") }
  SERVICE wikibase:label { bd:serviceParam wikibase:language "zh,en" }
}
LIMIT 5
```

- `wdt:P31 wd:Q5`（人类）过滤避免同名歧义（地名 / 作品名）
- 允许多 Q 返回，记录 top-5，实际 matching 归为"候选"不下定论
- canonical_name 需在 query 里加 `"..."@zh` 语言标签

### 3.2 Round 2 — Alias 匹配（仅对 Round 1 未命中者）

对每个未命中的 person，取其 `person_names` 中所有 `name_type IN ('primary', 'alias')` 的条目（经 T-P0-024 α 回填后 V7=97.49%），逐个尝试：

```sparql
SELECT ?item ?itemLabel WHERE {
  ?item skos:altLabel "${alias}"@zh ;
        wdt:P31 wd:Q5 .
  SERVICE wikibase:label { bd:serviceParam wikibase:language "zh,en" }
}
LIMIT 5
```

匹配到视为"alias 命中"，单独计数（参考指标）。

### 3.3 Round 3（可选，不作为主指标）

将**同 canonical_name 但 `?item wdt:P31/wdt:P279* wd:Q215627`**（legendary figure）命中也计一桶——对上古神话人物有意义。

---

## 4. 冲突/歧义处理

**probe 阶段不做消歧**。每个 person 的 matching 产出格式：

```json
{
  "person_slug": "zhou-wen-wang",
  "canonical_name": "周文王",
  "dynasty": "西周",
  "reality_status": "realistic",
  "round1_hits": [
    {"qid": "Q9134", "label_zh": "周文王", "description_zh": "..."}
  ],
  "round2_alias_hits": [],
  "match_tier": "round1_single"      // round1_single / round1_multi / round2 / no_match
}
```

Multi-hit（>1 Q 候选）保留候选列表；**不自动选一个**。架构师后续根据 probe 报告决定 disambiguation 策略。

---

## 5. 产出

### 5.1 主报告

路径：`docs/research/T-P0-025-gate-0a-wikidata-probe-report.md`

必含章节：
1. **执行摘要**：全局命中率 + 决策矩阵落桶
2. **分层命中率**：
   - 按 dynasty（先秦列国 / 西周 / 春秋 / 战国 / 秦 / 汉 / 上古）
   - 按 reality_status（realistic / legendary / divine / uncertain）
3. **未命中样本**：前 30 条（全名 + slug + dynasty），用于架构师快速判断缺口形态
4. **多候选样本**：前 10 条 Round 1 multi-hit（用于评估消歧负担）
5. **Alias 贡献**：Round 2 独立贡献 persons 数（= alias 命中 - round1 命中）
6. **执行元数据**：endpoint / timestamp / 用时 / HTTP 异常计数

### 5.2 明细 JSON

路径：`docs/research/T-P0-025-gate-0a-wikidata-probe-details.json`

320 条 matching record（按上述 JSON 格式）。

### 5.3 可重跑 probe 脚本

路径：`scripts/probe_wikidata_coverage.py`（一次性 probe，**不进** `services/pipeline/src/`）

**规格约束**：
- 纯 Python（`httpx` 或 `requests`），读 DB 经 `.env` DSN
- 显式 User-Agent + ≤ 1 req/sec rate limit
- 失败重试 3 次（指数退避），超过视为 no_match
- 输出 JSON + Markdown 两份
- 带 `--dry-run` 选项（跑前 10 条看格式）

### 5.4 commit

一次 commit，建议 message：

```
docs(research): T-P0-025 gate 0a — Wikidata coverage probe

- scripts/probe_wikidata_coverage.py (one-shot probe)
- docs/research/T-P0-025-gate-0a-wikidata-probe-report.md
- docs/research/T-P0-025-gate-0a-wikidata-probe-details.json

Hit rate: XX.X% (round1 exact) / YY.Y% (incl round2 alias)
Decision matrix bucket: [≥40% / 20-40% / <20%]
```

---

## 6. Gate 退出条件

Probe 完成即 exit；不要继续 Stage 0b 或 Stage 1。交付物齐后挂架构师 review：

- [ ] 主报告 §执行摘要 明确给出决策矩阵落桶
- [ ] 分层命中率覆盖 dynasty + reality_status 两个维度
- [ ] 未命中样本 ≥ 30 条
- [ ] JSON 明细 320 条齐全（若 DB 人数变化则以当时实际为准）
- [ ] 脚本可重跑（dry-run 输出示例贴在 PR 描述或 commit body）
- [ ] 无新增 DB 写入、无 pipeline/src/ 代码变更
- [ ] 不改动 STATUS.md / CHANGELOG.md（probe 不是 Sprint 收尾，这些由架构师本次 review 后统一登记）

---

## 7. 架构师 review 重点

Probe 交付后，架构师将评估：

1. **命中率 vs 决策矩阵**：按 §1.2 落桶，决定 Sprint B 形态
2. **朝代偏置**：若先秦命中率 << 秦汉，T-P0-025b 必须前置
3. **多候选密度**：若 multi-hit 比例 > 15%，Sprint B Stage 2 需专门预算 disambiguation 成本
4. **未命中形态**：是系统性（Wikidata 根本没收录）还是表面性（label 写法差异），决定是否加 Round 3+ 或人工 mapping queue
5. **探测边界**：若发现 Q-number 覆盖但 zh label 缺失严重（只有英文 label），需新增 en→zh 回流策略讨论

---

## 8. 不做什么（再次明确）

- ❌ 不建 `dictionary_sources` / `dictionary_entries` / `seed_mappings` 表
- ❌ 不写 migration 0009
- ❌ 不改 `resolve_rules.py` / `load.py`
- ❌ 不动 Web 展示
- ❌ 不做自建 TIER-4 seed 工作（T-P0-025b 独立）
- ❌ 不跑 apply_merges / 任何 DB 写入
- ❌ 不改 STATUS.md 的 Sprint A 已结记录

若跑 probe 中发现"顺手能修"的不相关小问题，登记到 debt 不就地改。

---

## 9. 预算

- **工期**：0.5–1 工作日
- **LLM 成本**：$0
- **网络成本**：~320 SPARQL queries Round 1 + ~100 queries Round 2（估）= ~10 分钟
- **回滚**：无 DB 变更，commit revert 即可

---

> **Done 定义**：probe 报告写好 + 架构师 review 通过 → 本 Gate 关闭，架构师基于决策矩阵出 Stage 0b 或 T-P0-025b 前置方案。
