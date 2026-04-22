# 架构师复盘纪要 — Sprint B（T-P0-025 字典加载器 + T-P1-023 unique index 对齐）

- **日期**：2026-04-22
- **任务**：T-P0-025 Wikidata seed dictionary loader（主线）+ T-P1-023 unique index naming alignment（顺带收口）
- **结果**：完成。ADR-021 从 in-progress 翻成 accepted；320 人 bootstrap 落地 159 active + 44 pending_review；不变量集扩至 V1-V10；R6 resolver 规则上线
- **成本**：$0 LLM（SPARQL + 规则工程）+ 3 次架构深度介入（Stage 2 schema 冲突裁决 / Stage 4 review nit / Stage 5 收口 brief）
- **工时分布**：预估 4h → 实际 ~8h（Stage 1 dry-run fix + Stage 2 migration 0010 补救各占 1h）
- **产物**：11 commits 推上 origin/main、3 个 migration（0009/0010/0011）、2 个 ADR 更新（010 §R6 / 021 final）、1 条新 invariant（V10 三条子规则）、1 条新 debt 开（T-P0-025b）、1 条 debt 关（T-P1-023）

---

## 1. 原计划 vs 实际执行

原计划 5 阶段：Stage 0b schema → Stage 1 matcher → Stage 2 execute → Stage 3 R6 → Stage 4 V10 invariant → Stage 5 收口。

实际执行基本按图走，但三处出现"架构师在 review / brief 环节发现问题，导致 Stage 膨胀或补救"：

- **Stage 1 dry-run 先行**：原计划 Stage 1 完成 adapter/matcher/CLI 即进 Stage 2 execute。dry-run 跑出后发现 `cli.py` 的 R2 alias 过滤器太宽（`nickname/posthumous/temple` 都被塞进 alias_names），导致 R3 永远没候选。修 commit 9dcb6c0 后 R3 命中 6 人、multi-hit 也从共享 `r1_multi` 计数拆成 `r1/r2/r3_multi` 三桶。**dry-run/execute 分离**本次挽救了 Stage 2 的数据正确性。
- **Stage 2 schema 冲突**：架构师 Stage 2 brief 要求把 multi-hit 分流写 `mapping_status='pending_review'`，但 migration 0009 的 CHECK 约束只允许 `active/superseded/rejected` 三值。工程师按 stop rule #1 停手上报。**这是架构师在 0009 设计时的 miss**——multi-hit 分流决定是 Stage 1 复盘后才定的，0009 当时只想了 R6 bind 后的终态三值。裁决选方案 A：新起 migration 0010 ALTER CHECK 加 `pending_review`，语义第一等，不用 notes JSONB hack。这条裁决顺便把"`pending_review` 是一等状态"写进 ADR-021 final 的 lifecycle 段。
- **Stage 4 review nit**：V10.a/b/c bootstrap 全 0，但测试只有 V10.a 有注入式 self-test，b/c 只证了"生产数据干净"没证"注入异常能报警"。架构师 review 发现，要求在 Stage 5 开头补齐两条 self-test（e8ad98e）。**bootstrap=0 只证现状，self-test 证能力**——这条被提取成通用 invariant 验收规范。

每次偏差都不是"scope 自然膨胀"，而是**架构假设在 Gate 审计下被证伪或被补齐**。跟 Sprint A 的模式一致：用 Gate 把假设变成证据。

---

## 2. 关键判例

### J1: 架构师 0009 CHECK miss → Stage 2 stop rule 正确触发（判例）

Stage 2 brief 要求 INSERT `mapping_status='pending_review'`，但 CHECK 不包含该值。工程师没有"现场扩大脚本绕开"或"改成 active 塞进 notes"，而是按 stop rule #1 停手上报。

- 这是 stop rule 体系第一次在**schema 级别**触发（Sprint A 的停手都在数据级）。结果：发现架构师 0009 设计有盲点，补 migration 0010 干净恢复。
- 如果工程师自行降级到方案 B（active + notes 标记），后续 V10.c（active 必须有 evidence）就会误判或误触发，回归成本会远高于一次 ALTER。
- **记录**：stop rule 的价值在于"下游能挡住上游的 miss"，架构师设计 brief 时不应假设 schema 约束已被覆盖所有用法，brief 下达前应**反向扫一遍将要写入的值域 vs 现有 CHECK**。

### J2: dry-run/execute 分离挽救 Stage 1（判例）

Stage 1 brief 明确要求 CLI 实现 `--mode dry-run` 和 `--mode execute`，且 Stage 2 之前必须跑全量 dry-run。这条"强制 dry-run 先行"规范原本是针对"网络/限流出错早暴露"，结果抓到了一个 data-path bug（R2 alias 过滤器太宽）。

- 如果 Stage 1 直接 execute，159 条 active 会写入，但 R3 命中的 6 人永远没机会被 match（filter 包含太多 name_type，R2 就把所有非 primary 名字都试完了，R3 `remaining = []`）。修 filter 后要再跑一次全量 → 两次写入会产生 entry 重复或 seed_mapping 冲突，清理成本高。
- dry-run 时 R3 一条不命中的分布 + 全 `none` 兜底是个**明显异常**（ADR-021 预期 R3 应有 5-10 的边际增益），架构师据此回查 `cli.py` 的 name filter。
- **记录**：外部数据源集成的第一印象性能数字（hit rate、round 分布）就是质量信号。brief 应该明确"如果某轮命中率为 0 且 reality_status/alias 分布不匹配先验，必须停手查 data path"。

### J3: V10 验收规范 — bootstrap ≠ 能力（判例）

Stage 4 三条 V10 子规则 bootstrap 全 0，但 V10.b/c 没有 self-test。架构师 review 要求补，因为"规则写错了恰好返回 0"和"规则写对了数据也干净返回 0"无法从 bootstrap 本身区分。

- 补的测试（e8ad98e）用了两种注入方式：V10.b 在事务里 DROP FK → INSERT 孤儿 mapping → 断言 V10.b=1 → ROLLBACK；V10.c 直接 INSERT active mapping 不写 source_evidence → 断言 V10.c=1。两条都在 txn 内，对生产数据零污染。
- **沉淀为规范**：新 invariant 引入的验收清单必须含 `bootstrap = 0` + `每条子规则各一条注入 self-test`。写进 `docs/05_质检与监控体系.md` 的 invariant 引入检查项（Stage 5 已同步更新 STATUS + CHANGELOG，规范正文更新留到下次触及该文档时顺手做）。

### J4: R3 0.70 留在 DB 但不自动 bind — 分层决策的范本

R3 scan 命中 6 人，confidence 0.70。如果 R6 cutoff 设 0.70，这 6 条会自动 bind，但 R3 本身是"扫描式"命中（把 person 所有 alias_names 挨个 altLabel 查询，首个 single-hit 即采纳），对"思王 → 吳麟瑞 (Q45567107 明朝)"这种高熵误匹配的防御力弱。实际样本中也确实出现了这条误匹配。

设计 R6 cutoff 0.80 让这 6 条留在 `seed_mappings.active` 但对 resolver 不可见（`below_cutoff`），等待上层 R1-R5 用原始 NER 上下文决策。数据保留但不消费，**既不丢线索也不误绑**。

- 这是"confidence 分层 + 消费层 cutoff"的具体实例。记入 ADR-010 §R6 的 lookup contract。
- **推广**：未来外部数据源集成的 match 结果若有明显置信度分层（R1 1.00 / R2 0.85 / R3 0.70），消费侧 cutoff 应**设在分层边界之上**，而不是底线之上。

---

## 3. 治理里程碑

Sprint B 把"外部数据源集成"从 zero 推到 production-shaped，沉淀出可复用的集成模板：

**外部数据源集成三段式**（T-P0-025 为首个完整实例）：

1. **Schema 层**：`dictionary_sources`（一条数据源一行）/ `dictionary_entries`（外部实体）/ `seed_mappings`（外部 → 内部的桥）。polymorphic target（`target_entity_type + target_entity_id`，不上 FK）允许未来对接 places / books / events。
2. **Adapter 层**：rate limit 1.1s（>1req/s Wikidata policy）+ 指数退避 + 429 special + async context manager。query 构造与 HTTP 传输分离，响应解析走独立 `parse_bindings` 纯函数便于单测。
3. **Loader 层**：三轮匹配 R1 exact → R2 alias → R3 scan，每轮命中后跳过后续。dry-run JSON 先出供 review，execute 时走事务写入 + pseudo-book evidence chain（ADR-015 §6.1）。

这三段未来可以直接用于 CBDB / Baike / 地名词典（ADR-024 评估若通过）。

**不变量 V10**：三条子规则首次把"外部 → 内部绑定"的数据一致性形式化为 invariant：

- V10.a（target FK 一致性）：active/pending 的 seed 不能指向已删除 / 已合并 person
- V10.b（entry FK 一致性）：每条 seed_mapping 必须有对应 dictionary_entry
- V10.c（evidence 合规）：active seed 必须有 `provenance_tier='seed_dictionary'` 的 source_evidence；pending 不要求

V10.c 是 ADR-015 evidence chain 规则的**首次在 invariant 层显式化**（之前只是规约，没被守住）。

**R6 resolver 规则**：首条依赖外部词典的 resolver 规则。纯 lookup，不做决策，状态机四值契约（`matched / below_cutoff / ambiguous / not_found`）。这是 ADR-010 R1-R5 之后第一次扩展，也是 identity resolver 从"纯文本规则"走向"文本 + 外部词典混合"的入口。

---

## 4. 副产品 / 新增 debt

> [ID-corrected 2026-04-22]：本节"T-P0-025b — Manual triage UI for pending_review mappings"为 retro 编写时的 ID 复用错误。正式 ID 为 T-P0-028（已建 task card stub）。原 T-P0-025b（self-curated seed patch）含义保留不变。

### T-P0-025b — Manual triage UI for pending_review mappings（Sprint C 候选）

44 条 pending_review 分布在 16 个 persons 上，需要人工裁决：

- R1 multi（8 人）：同名不同人，典型如白起（战国将领 Q 号 vs 另一个 Q 号），需要历史专家一眼就能判
- R2 multi（7 人）：别名触发多命中，需要看候选 QID 的 description_zh 辅助
- R3 multi（1 人）：扫描式多命中，置信度本来就低

UI 需求：对每个 person 展示候选列表（QID / label_zh / description_zh），一键点选后 `pending_review → active`（附带生成 source_evidence）或 `pending_review → rejected`。后端只改 UPDATE + INSERT source_evidence 两条 SQL，不改 schema。

**登记为 T-P0-025b**，Sprint C 候选。

### T-P1-022 独立赛道存续

27 persons 缺 primary name_type，`cli.py` 用 `COALESCE(pn_primary.name, p.name->>'zh-Hans')` 兜底处理了，没因此阻塞 Sprint B。独立赛道，不变。

### 49.7% hit rate 未达 60% — ADR-024 未启动

Wikidata 对中国古代人物覆盖率先天不足（特别是周代以前），320 人命中 159 个 = 49.7%，低于 ADR-021 §6 初始预期的 60%。这意味着：

- Sprint B 证明了集成管线可用，但**单靠 Wikidata 顶不住 Phase 1 的 knowledge graph 密度需求**
- 下一步需要 ADR-024：TIER-1 第二数据源评估（CBDB / 百度百科 / 学术知识库），评估维度是覆盖率 + 授权 + 维护活跃度

ADR-024 未启动，留给 Sprint C 或 Phase 0 末尾。**不阻塞 Phase 1 启动**：Phase 1 产品可先用 159 active seeds 作为种子，未达 60% 不是红线。

---

## 5. 遗留 / 建议

### 5.1 遗留不处理（非 Sprint B 范畴）

- **T-P1-021** canonical merge missed pairs（管叔 vs 管叔鲜 / 蔡叔 vs 蔡叔度）：Sprint A 留的，ADR-014 execution model 覆盖，独立赛道。
- **T-P1-022** 27 persons 缺 primary name_type：同上，独立赛道。

### 5.2 建议下一步（Sprint C 候选）

候选顺序（推荐度↓）：

1. **T-P0-026 resolver orchestration**（R1-R6 全集成）：R6 已落地但还没接进 resolver 主调度。Phase 1 产品层要调用完整 R1-R6 才能 resolve entity，这条不做 Phase 1 走不动。**架构师强推**。

> [ID-corrected 2026-04-22]："T-P0-026" 为 retro 编写时的 ID 复用错误（原 T-P0-026 是 docs/research/ 下 feasibility 研究文档 ID，不复用为 task card）。正式 ID 为 T-P0-027（已建 task card）。

2. **T-P0-025b manual triage UI**：44 pending_review 需要处置，否则 R6 状态统计永远有 "filtered=44"，人工不降这个数字就不会收敛。工时估 1-2 天。（→ 已重编号为 T-P0-028）
3. **ADR-024 TIER-1 second source 评估**：不动工程，只做决策文档。工时估 0.5-1 天，可以并行 T-P0-026。
4. **T-P1-021 canonical merge missed pairs**：Sprint A 留的，规模小（2 组），ADR-014 execution model 即可。

架构师推荐 **T-P0-026 resolver orchestration**：R6 已落地，resolver 骨架已在 T-P0-026 task card 里设计好，路径短、把 Sprint B 的 R6 投入变成可消费能力。T-P0-025b 可以并行立一个独立 track 给历史专家参与，不必等架构师。

### 5.3 流程改进

- **Brief 下达前反向扫 CHECK 约束**：Sprint B Stage 2 的 migration 0009 CHECK miss 是本 Sprint 最大的架构失误。未来架构师下 brief 要求写入某字段时，应反向列出该字段的 CHECK / ENUM / FK 约束，确认 brief 要求的值都在允许集内。**写进架构师 agent 指令**（`.claude/agents/chief-architect.md` 的 brief 下发 checklist）。
- **Invariant 验收清单**：bootstrap=0 + 每条子规则一条注入 self-test。已体现为 J3 判例，正文更新留到下次触及 `docs/05_质检与监控体系.md` 时顺手补。
- **外部数据源 dry-run 预期数字先给**：Sprint B Stage 1 dry-run 的异常是架构师**事后**发现的（R3 命中为 0 不合先验）。未来外部数据源集成，brief 应在 Stage 1 完成预期给出"R1/R2/R3 命中率先验范围"，让 dry-run 完成自查而不是等架构师 review。

---

## 6. 成本与产出对账

| 维度 | 数值 | 备注 |
|------|------|------|
| Commits pushed to main | 11 | 199e8ba → 4b771b8，推送范围 a36f203..4b771b8 |
| Migrations landed | 3 | 0009 schema / 0010 pending_review CHECK / 0011 unique index align |
| pg_dump anchors | 3 | pre-stage-0b / pre-stage-2 / pre-stage-5 |
| LLM 成本 | $0 | 纯 SPARQL + 规则工程，不跑 LLM extractor |
| 新 ADR / ADR 更新 | 2 | ADR-010 §R6 implemented（e5735a3）/ ADR-021 accepted（2966524） |
| 新 invariant | 1 | V10（三条子规则 a/b/c） |
| Pipeline tests | 282 → 314 | +32（adapter 12 + matcher 8 + CLI execute 6 + R6 6 + V10 6 - 其中若干重合） |
| Debt opened | 1 | T-P0-025b manual triage UI |
| Debt closed | 1 | T-P1-023 unique index naming（0011 解决） |
| Bootstrap: active | 159 | R1 single 149 + R2 alias 4 + R3 scan 6 |
| Bootstrap: pending_review | 44 | 16 persons × 平均 2.75 候选 |
| Bootstrap: no_match | 145 | 45.3%，Wikidata 覆盖率瓶颈 |
| R6 状态分布 | 153 / 6 / 0 / 44 | matched / below_cutoff / ambiguous / invisible |
| V7 机械性 | 97.49% (unchanged) | Sprint B 不改 persons 表 |
| V10 violations | — → 0 × 3 | 三条子规则生产数据全 0 |
| Hit rate | 49.7% | 低于 ADR-021 §6 预期 60% → 触发 ADR-024 评估 |

---

## 7. 给后续会话的 hand-off 提示

- **R6 是纯 lookup，不做决策**：状态机四值（matched / below_cutoff / ambiguous / not_found）是契约，上层 resolver 根据状态决定怎么用。新 rule 若要依赖外部数据源，照 R6 格式写——纯函数 + 状态机 + 独立测试 + 不写数据库。
- **pending_review 是一等状态**：不是"带标记的 active"。任何看到 `seed_mappings.mapping_status` 的 SQL / 代码都必须显式处理四值，不能假设非 active 就是 rejected。V10.c 只校验 active，V10.a 校验 active + pending，两者不对称是故意的。
- **Wikidata adapter 是外部数据源集成模板**：下次接 CBDB / Baike / 其它词典，照 `services/pipeline/src/huadian_pipeline/seeds/` 的三层结构（adapter / matcher / CLI）复制。rate limit + retry + pseudo-book evidence + dry-run/execute 分离都要保留。
- **Invariant 引入验收规范**：`bootstrap = 0` 是必要不充分条件，必须配每条子规则一条注入 self-test 才算上线。V10 三条是正例。
- **ADR-021 §6 的 60% 覆盖率不是红线**：49.7% 不阻塞 Phase 1，但触发 ADR-024 评估。Phase 1 产品可基于 159 active seeds 启动，第二 TIER-1 源在下一个字典扩充窗口补齐。
- **Architect brief 下达前反向扫 CHECK / ENUM / FK**：Sprint B Stage 2 的 migration 0009 CHECK miss 教训。写进架构师指令 checklist。

---

> Sprint B 标志 Phase 0 数据层从"内部治理"进入"内外桥接"。V10 三条子规则把外部 seed 的一致性守在 invariant 层；R6 让 identity resolver 第一次消费外部词典；ADR-021 从规划文档变成落地 ADR。下一步 T-P0-026 resolver orchestration 会把 R6 投入转为 Phase 1 产品可调用的 resolve API——Sprint B 是那条路径的前置。
