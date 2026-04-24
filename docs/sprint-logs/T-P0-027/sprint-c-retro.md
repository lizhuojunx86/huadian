# 管线工程师复盘纪要 — Sprint C（T-P0-027 Resolver Orchestration）

- **日期**：2026-04-22 ~ 2026-04-24
- **任务**：T-P0-027 Resolver Orchestration（R6 接入 resolver 主调度）
- **结果**：完成（路径 A）。R6 pre-pass 接入 resolver 主调度；R1 merge ×1 apply；R6 false positive ×1 historian 否决
- **成本**：$0 LLM（纯规则工程 + DB 查询）
- **工时分布**：预估 8-12h → 实际 ~6h（Stage 1-3 紧凑；Stage 4-5 被 historian 等待阻断约 2 天）
- **产物**：9 commits on main / 0 migrations / 1 new invariant (V11) / 13 new tests / 2 debt opened (T-P0-029, T-P0-030) / 1 debt closed (T-P0-027)

---

## 1. 原计划 vs 实际执行

原计划 5 阶段 + 5 Gates。实际按图走，两处出现偏差：

- **Stage 1 Stop Rule #1 触发**：R6 pre-pass 原设计复用 `r6_seed_match()` name fallback 路径，Gate 1 dry-run 数字偏离先验（matched 143 vs 159 expected）。4 因子根因分析后架构师裁决采用方案 A（FK 直查替代 name fallback）。修复后数字精确吻合。
- **Stage 4-5 historian 阻断**：R6 发现 1 例 false positive（启↔微子启 Q186544），需 historian 裁决。跨约 2 天等待后 historian 完成判定（ruling 98de7bc），选定路径 A。

每次偏差都被 Gate 机制拦截，无数据损坏。

---

## 2. 关键判例

### J1: Stop Rule #1 — r6_seed_match 语义不匹配（判例）

Stage 1 直接调用 `r6_seed_match(conn, candidate_name=snap.name)` 做 pre-pass，但该函数的 name fallback 路径是为**外部 lookup**设计的（by Wikidata label），不是为**内部 pre-pass**设计的（by person_id FK）。

管线工程师的 4 因子拆解定位了全部偏差来源：
1. persons.name JSONB vs COALESCE(primary name, ...) 字段不一致（-6~-10）
2. R2/R3 alias/scan 匹配路径 Wikidata label ≠ 华典 canonical name（-10）
3. below_cutoff 路径仅在 QID 主路径触发，name fallback 直接过滤为 NOT_FOUND（-6）
4. ambiguous=1 因 name 碰撞

架构师裁决：R6 有两种消费模式（external lookup vs internal pre-pass），不应合并。方案 A（FK 直查）采纳。

**沉淀**：函数复用前须验证语义匹配——"能调通"≠"语义正确"。

### J2: 启 vs 微子启 — Wikidata 跨实体编辑混淆（判例）

Sprint B matcher R2 alias 路径把"启"作为微子启的别名，命中 Wikidata Q186544（夏启）。两人跨夏→商约 1000 年。Historian 通过 SPARQL 四查确认 Q186544 = 夏启，微子启正确 QID = Q855012。

**沉淀**：
- 外部数据源的 QID 一致不等于实体一致（Wikidata 非权威来源）
- 需要 R6 cross-dynasty guard 防御类似 false positive → T-P0-029
- R2 alias 匹配器对"启"类通用短名缺乏 dynasty guard

---

## 3. Stop Rules 记录

| # | 触发 Stage | 类型 | 描述 | 解决 |
|---|-----------|------|------|------|
| 1 | Stage 1 Gate 1 | R6 分布偏离先验 | matched 143 vs 159 | 方案 A（FK 直查）替代 name fallback |

1 次触发 / 1 次解决 / 0 次数据损坏。Sprint B+C 累计 3 次 Stop Rule 全部有效。

---

## 4. Best Practices 沉淀

### BP1: Stop Rule 根因分析样板（Stage 1）

管线工程师的 4 因子拆解被架构师评价为"质量很高"：
1. 精确定量每个因子的偏差贡献
2. 提出 2 个修复方案 + 优劣对比
3. 推算修复后的期望数字
4. 不猜测，用数据说话

推荐作为未来 Stop Rule 根因分析的模板格式。

### BP2: 函数复用前的语义验证

r6_seed_match 的 name fallback 路径"能调通"但语义不匹配 pre-pass 场景。教训：复用函数前须验证其设计语义（谁调、为什么调、输入从哪来）是否与当前使用场景一致。

### BP3: --skip-rule 可复用基础设施

apply_merges 的 `skip_rules` 参数 + `_filter_groups_by_skip_rules()` 是通用基础设施，未来任何规则 false positive 都可以用 `--skip-rule RN` 临时绕过，无需改代码。

---

## 5. 成本与产出对账

| 维度 | 数值 | 备注 |
|------|------|------|
| Commits | 9 | ca37039 → 本 commit（含 historian ruling 98de7bc） |
| Migrations | 0 | Sprint C 不新增 schema |
| pg_dump anchors | 1 | pre-T-P0-027-stage-5 |
| LLM 成本 | $0 | 纯规则工程 + DB 查询 |
| 新 invariant | 1 | V11（anti-ambiguity cardinality） |
| Pipeline tests | 314 → 327 | +13（R6 prepass 10 + V11 3） |
| Active persons | 320 → 319 | R1 merge ×1（鲁桓公↔桓公） |
| Active seed_mappings | 159 → 158 | wei-zi-qi downgrade |
| Pending_review | 44 → 45 | +1（wei-zi-qi Q186544） |
| Debt opened | 2 | T-P0-029（R6 guard）+ T-P0-030（corrective seed-add） |
| Debt closed | 1 | T-P0-027 |
| Stop Rules | 1 triggered / 1 resolved | Stage 1 Plan A |

---

## 6. 给后续会话的 hand-off 提示

- **R6 pre-pass 是 FK 直查，不复用 r6_seed_match()**：两种消费模式语义不同，不要合并。r6_seed_match() 保留给 Phase 1 NER pipeline / API external lookup。
- **apply_merges --skip-rule 是通用基础设施**：任何规则产生 false positive 时可用 `--skip-rule RN` 临时绕过。
- **V11 守的是 cardinality 不是 FK**：V10 守 FK 一致性，V11 守"每人最多 1 个 active mapping"。两者互补。
- **wei-zi-qi 正确 QID = Q855012**：T-P0-030 负责修正性 seed-add，本 Sprint 不执行。
- **T-P0-029 的 500 年阈值是参考起点**：historian 建议跨朝代 >500 年自动降级，但具体阈值由 T-P0-029 设计阶段细化。
