# T-P0-027 Sprint C Stage 0 Brief — Resolver Orchestration（R6 集成）

> 架构师下达 2026-04-22。管线工程师执行。

## 0. 元信息

- **任务**：T-P0-027 Resolver Orchestration（R6 接入 resolver 主调度）
- **依据**：T-P0-027 task card stub + inventory 报告（docs/sprint-logs/T-P0-027/inventory-2026-04-22.md）+ ADR-010 §R6 + Sprint B retro §7 hand-off
- **架构师**：本 brief 同步落盘 docs/sprint-logs/T-P0-027/stage-0-brief-2026-04-22.md（管线工程师在 Stage 1 开工前先 mkdir + 写入）
- **预估工时**：8-11h（Stage 1-5）
- **LLM 成本**：$0（只读 DB + SPARQL 已在 Sprint B 落地）

---

## 1. 架构裁决（5 条，不可改）

### 裁决 1 — Sprint C scope 收口
本 Sprint 只做 **resolver pipeline batch 路径** 的 R6 集成。API 在线 resolveCanonical 和 NER pipeline 自动触发**不在本 Sprint 范围**——后续 T-P0-029 / T-P0-030 单独立。

理由：retro §1 教训（避免 scope 自然膨胀）+ API 在线 resolve 涉及性能/缓存策略（独立 ADR）。

### 裁决 2 — 切入点 B（R6 pre-pass）
采纳 inventory 推荐：R6 在 `resolve_identities()` 中作为 pre-pass，**不入 `_RULE_ORDER`**。

理由：R6 是 async + single-entity-lookup，与 R1-R5 的 sync + pair-comparison 概念不同构；强行塞入 `score_pair()` 会污染纯函数契约。

### 裁决 3 — PersonSnapshot 扩展是允许的
扩展 `PersonSnapshot.r6_result: R6Result | None = None` 字段**不破坏纯函数契约**——纯函数原则保护 `score_pair()` 不做 I/O，不约束 PersonSnapshot 的字段集合。

### 裁决 4 — R6 触发 merge 的规则
- **触发**：两个 active person 映射到同一 active QID（both R6 status=MATCHED, same external_id）→ `MergeProposal(rule="R6", confidence=1.0)`
- **不触发**：single MATCHED + other NOT_FOUND；BELOW_CUTOFF；AMBIGUOUS（仅作为 PersonSnapshot 装饰，留作未来规则的输入）
- **R6 价值**主要在"作为 Phase 1 入口接入" + V11 一致性验证；merge 增量是次要（预期 0-5）

### 裁决 5 — 引入 V11 R6 Self-Consistency Invariant
- **定义**：每个 active `seed_mappings`（status='active'），其 `target_entity_id` 必须与 `r6_seed_match(candidate_name=person.canonical_name)` 实时 lookup 结果的 person_id 一致
- **为什么是不变量而不是 QC 规则**：V10 守的是数据库静态一致性；V11 守的是 lookup 函数行为与表数据的一致性，是 V10 的运行时孪生
- **Sprint B 落地的 159 active mappings 应当全部满足 V11**（如不满足，揭示 Sprint B 的 lookup 实现 bug，要单独 escalate）

---

## 2. 反向 CHECK 扫描（已由架构师完成，结果如下）

| 检查项 | 现状 | Sprint C 行动 |
|--------|------|--------------|
| `person_merge_log.merge_rule` | TEXT NOT NULL（无 CHECK/ENUM） | **不需要 migration**，可直接 INSERT 'R6' |
| `_RULE_ORDER` | `[r1, r2, r3, r5, r4]` 5 条 | **不动**，R6 走 pre-pass 独立路径 |
| `resolve.py:347` audit log if-elif | R1/R2/R3/R5/R4 五分支 | Stage 2 加 `elif rule == "R6"` |
| `resolve.py:616` 同上 | 同上 | Stage 2 加 `elif rule == "R6"` |
| `seed_mappings.mapping_status` | active/pending_review/superseded/rejected | Sprint C 不新增值 |
| `PersonSnapshot` 字段 | `resolve_rules.py:146` | Stage 1 加 `r6_result: R6Result | None = None` |
| `MatchResult.rule` 字段类型 | 自由 str（grep 结果显示 R1-R5 全是字符串字面量） | Stage 2 直接用 `rule="R6"` 字符串 |

---

## 3. Stage 划分（5 Stages + 5 Gates）

### Stage 1 — R6 Pre-Pass Infrastructure（2-3h）

**执行**：
1. `resolve_rules.py`: PersonSnapshot 加 `r6_result: R6Result | None = None` 字段（dataclass 默认值，向后兼容）
2. `resolve.py`: 新增 `async def _r6_prepass(conn, snapshots) -> None`，对每个 snapshot 调 `r6_seed_match(conn, candidate_name=snap.canonical_name)`，把结果挂在 `snap.r6_result`
3. `resolve_identities()` 在 `_load_persons()` 之后、pairwise 扫描之前调 `_r6_prepass()`
4. **不引入 merge 逻辑**（裁决 4 移到 Stage 2）

**Gate 1（架构师 ack）**：dry-run 一次（不 apply），输出 R6 status 分布数字。**先验**：

| status | 预期 | 容差 |
|--------|------|------|
| MATCHED | 159 | ± 5 |
| NOT_FOUND | 161 | ± 5 |
| BELOW_CUTOFF | 6 | ± 2 |
| AMBIGUOUS | 0 | 严格 |
| 总计 | 326（含 6 BELOW_CUTOFF 计入 lookup） | — |

注：320 active persons + 6 BELOW_CUTOFF 是 lookup 命中但 confidence < 0.80 的情况，按 Sprint B Stage 3 已计入 active mappings 但 R6 标 below_cutoff。如总数偏离 → stop rule #1 触发。

---

### Stage 2 — R6 Merge Logic + Audit Log（2-3h）

**执行**：
1. 新增 `def _detect_r6_merges(snapshots) -> list[MergeProposal]`：group by `r6_result.external_id`（仅 status=MATCHED），size > 1 → 每对生成 `MergeProposal(rule="R6", confidence=1.0, evidence={"external_id": ..., "source": "wikidata"})`
2. `resolve_identities()` 在 pairwise 扫描完成、生成 merge_proposals 之后，调 `_detect_r6_merges()` 把结果**追加**到 merge_proposals（不去重，UnionFind 会兜住）
3. `resolve.py:347` 和 `:616` if-elif 链加 `elif rule == "R6": ...`（描述文本由管线工程师按上下文写）
4. **裁决 4 边界严格遵守**：only both-MATCHED-same-QID 触发；其它情况零 MergeProposal

**Gate 2（架构师 ack）**：dry-run 一次，输出 R6 MergeProposal 数。**先验**：0-5。如 > 5 → stop rule #3 触发停手汇报。

---

### Stage 3 — V11 Invariant + Unit Tests（2h）

**执行**：
1. V11 SQL invariant + 3 self-tests（注入式，事务 ROLLBACK 保护）
2. R6 pre-pass / pair detection 单元测试（≥ 6 cases）

**Gate 3（架构师 ack）**：4 闸门全绿（lint / typecheck / test / V1-V11）。V11 bootstrap = 0。

---

### Stage 4 — 全量 Dry-Run + Historian Sample（1-2h，含 ack 等待）

**执行**：
1. `python scripts/dry_run_resolve.py` 全量
2. ResolveResult 输出 `rule_distribution`
3. 如有 R6 MergeProposal > 0：导出 candidates JSON → historian 抽样

**Gate 4（架构师 ack）**：数字 vs 先验；historian 反馈（如适用）。

---

### Stage 5 — Conditional Apply + 收口（1-2h）

**路径 A**（merges > 0 且 ack）：pg_dump → apply → V1-V11 验证
**路径 B**（merges = 0）：跳过 apply

**收口**：STATUS + CHANGELOG + T-P0-029/030 stubs + task card done

**Gate 5（架构师 ack）**：commit message 由架构师 review 后下达。

---

## 4. Stop Rules（5 条，触发即停手汇报）

1. **Stage 1**：R6 status 分布偏离先验容差
2. **Stage 1**：R6 pre-pass 让 R1-R5 命中数下降
3. **Stage 2**：R6 MergeProposal > 5
4. **任意 Stage**：V1-V11 任何 violation
5. **Stage 4**：historian 反对 R6 merge

---

## 5. 验收清单

- [ ] 4 闸门全绿（lint / typecheck / test / V1-V11）
- [ ] V11 bootstrap = 0 + 3 self-tests 全绿
- [ ] pipeline tests 数 +N（具体由 Stage 3 完成数定）
- [ ] R6 pre-pass 命中数符合先验（159 ± 5）
- [ ] R6 MergeProposal 数 ≤ 5
- [ ] dry-run + apply（如适用）零 V1-V11 violation
- [ ] resolve.py audit log if-elif 链含 R6 分支
- [ ] ResolveResult.rule_distribution 输出含 R6 子项
- [ ] CHANGELOG 含 R6 数字对账 + 衍生债务登记

---

## 6. 风险与回滚

| 风险 | 严重度 | 回滚 |
|------|--------|------|
| R6 pre-pass 引入 async DB 查询 O(n) 159 次性能不可控 | 低 | Sprint C 不动数据；测出慢 → 加 batch query 优化（独立 PR），不阻塞主线 |
| R6 触发的 false-positive merge（historian 反对） | 中 | dry-run 必走 historian sample；apply 前可中止 |
| V11 bootstrap ≠ 0（Sprint B lookup bug） | 高 | 立即停手；不上线 V11；单独 escalate Sprint B 复盘 |
| PersonSnapshot 扩展破坏 R1-R5 行为 | 中 | Stop rule #2 防御；R1-R5 测试基线对比；如发现 → 拆 r6_result 出 PersonSnapshot 走旁路 dict |

---

## 7. Sprint C 不做什么（明确边界）

- ❌ API resolveCanonical 集成 R6（→ T-P0-029，未立卡）
- ❌ NER pipeline 自动触发 resolve（→ T-P0-030，未立卡）
- ❌ pending_review triage UI（→ T-P0-028，独立 track）
- ❌ TIER-4 self-curated seed 加载（→ T-P0-025b，backlog）
- ❌ 第二 TIER-1 数据源接入（→ ADR-024，未启动）
- ❌ R6 cutoff 调整（保持 0.80）
- ❌ R6 状态机扩展（保持四值契约）

---

## 8. 工时估算

| Stage | 估时 | 含 ack 等待？ |
|-------|------|---------------|
| 1 | 2-3h | 含 |
| 2 | 2-3h | 含 |
| 3 | 2h | 含 |
| 4 | 1-2h | 含 historian |
| 5 | 1-2h | 含 |
| **总计** | **8-12h** | — |
