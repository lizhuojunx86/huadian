# T-P0-027 R1-R6 现状 Inventory（2026-04-22 by 管线工程师）

## R1-R5 主调度（resolve.py）

- **入口函数**：`resolve_identities(pool: asyncpg.Pool) -> ResolveResult`
- **位置**：`services/pipeline/src/huadian_pipeline/resolve.py:213`

### 主循环伪代码

```python
persons = _load_persons(conn)          # all non-deleted, with surface_forms + identity_notes
for i in range(len(persons)):          # O(n²) pairwise — acceptable for Phase 0 (≤ ~320)
    for j in range(i+1, len(persons)):
        match = score_pair(a, b)       # first-match-wins: R1→R2→R3→R5→R4
        if match is None: continue
        if match.confidence >= 0.90:   merge_proposals.append(...)
        else:                          hyp_proposals.append(...)
uf = UnionFind(all_person_ids)
for prop in merge_proposals:           uf.union(a_id, b_id)
for component in uf.groups():
    canonical = select_canonical(group_persons)
    result.merge_groups.append(MergeGroup(...))
```

### 规则调用顺序与聚合

- **调用链**：`score_pair(a, b)` → 依次尝试 `_RULE_ORDER = [R1, R2, R3, R5, R4]`
- **策略**：**first-match-wins**（第一个返回非 None 的规则即采纳，不做多规则分数合成）
- **阈值**：`MERGE_CONFIDENCE_THRESHOLD = 0.90`（≥0.90 auto-merge，<0.90 hypothesis）

### 关键设计决策

1. **同步纯函数**：`score_pair()` / 各 `_rule_rN()` 全部是同步的，不做 DB 查询
2. `_load_persons()` 一次性从 DB 加载所有 person 的 surface_forms，存入 `PersonSnapshot` 内存对象
3. 字典（tongjia / miaohao）在首次调用时模块级懒加载（`ensure_dicts_loaded()`）
4. `apply_merges()` 在单个事务内批量执行所有 soft-delete + merge log

---

## R6 现状（r6_seed_match.py）

- **位置**：`services/pipeline/src/huadian_pipeline/r6_seed_match.py:45`

### 函数签名

```python
async def r6_seed_match(
    conn: asyncpg.Connection,
    *,
    candidate_name: str,
    candidate_qid: str | None = None,
    dictionary_source: str = "wikidata",
    confidence_cutoff: float = 0.80,
) -> R6Result
```

### 四值状态机契约

```python
class R6Status(StrEnum):
    MATCHED = "matched"           # active mapping, confidence >= cutoff
    BELOW_CUTOFF = "below_cutoff" # active mapping, confidence < cutoff
    AMBIGUOUS = "ambiguous"       # name fallback 路径多命中
    NOT_FOUND = "not_found"       # 无 active mapping
```

`R6Result` 是 frozen dataclass：`status / person_id / confidence / entry_id / external_id / source_name / detail`

### 关键设计差异（vs R1-R5）

| 维度 | R1-R5 | R6 |
|------|-------|-----|
| 同步/异步 | 同步 | **async**（需要 DB conn） |
| 操作对象 | person **pair** 比较 | **single** person → 外部字典 lookup |
| 输入 | `PersonSnapshot × 2` | `candidate_name + optional QID` |
| 输出 | `MatchResult(rule, confidence, evidence)` | `R6Result(status, person_id, confidence, ...)` |
| 字典来源 | YAML 文件（tongjia/miaohao） | PostgreSQL 三表 JOIN |

### 当前调用方（grep 结果）

**仅 test file**：`services/pipeline/tests/test_identity_r6_seed_match.py` — 6 个测试用例。
**无任何 production 调用方。** R6 函数存在但未被任何管线/API 代码消费。

---

## seeds/matcher.py R1/R2/R3 vs resolver R1-R5 命名冲突

### 分析

| 标签 | seeds/matcher.py（Wikidata 匹配轮次） | resolve_rules.py（身份消歧规则） |
|------|--------------------------------------|-------------------------------|
| R1 | canonical_name → rdfs:label 精确匹配（SPARQL） | surface_form 交集（内存） |
| R2 | alias → skos:altLabel 匹配（SPARQL） | 帝X 前缀匹配（内存） |
| R3 | all_names → altLabel 扫描（SPARQL） | 通假字归一化（内存 + YAML） |

### 结论

**不需重命名**。两组 R1/R2/R3 在完全不同的模块（`seeds.matcher` vs `resolve_rules`）中定义，且语义完全不同：
- seeds R1/R2/R3 = 从华典 person → Wikidata entity 的**外部匹配**轮次
- resolver R1-R5 = 华典 person 之间的**内部消歧**规则

代码层无冲突（不同命名空间）。文档/对话中引用时需注明上下文（"seeds R1" vs "resolver R1"）即可。

---

## API resolveCanonical 现状

- **位置**：`services/api/src/services/person.service.ts:146-165`
- **当前实现**：**纯 DB 链追踪**，跟 `merged_into_id` 最多 5 跳
- **不调用 Python identity_resolver**，不调用 R6
- 被 `findPersonBySlug()` 使用：当 slug 命中一个 merged person 时，透明跳转到 canonical

```typescript
async function resolveCanonical(db, row): Promise<PersonRow | null> {
  let current = row; let hops = 0;
  while (current.mergedIntoId && hops < 5) {
    current = await db.select().from(persons).where(eq(id, current.mergedIntoId));
    hops++;
  }
  return current.deletedAt == null ? current : null;
}
```

**关键点**：API 层 resolve 是读端行为（查询时透明跳转），与 pipeline 端 resolve（写端行为，产生 merge proposals 并执行 soft-delete）是两个独立系统，目前不共享逻辑。

---

## NER pipeline 中 identity_resolver 调用位置

### 调用点

`resolve_identities()` **不在 NER pipeline 主流程中调用**。

`cli.py` 的 `pilot` 命令流程：
```
ingest → extract → load → seed_dump   (cli.py:120-213)
```

四步均不调用 `resolve_identities()` 或 `apply_merges()`。

### 独立脚本调用

identity resolver 通过两个独立脚本手动触发：
- `scripts/dry_run_resolve.py` — `resolve_identities(pool)` + `apply_merges(pool, result, dry_run=True)`
- `scripts/apply_resolve.py` — `resolve_identities(pool)` + `apply_merges(pool, result, dry_run=False)`

### 时机

**post-load 独立 batch**：在完成一次或多次 `pilot` / `ingest+extract+load` 后，手动运行 resolve 脚本对全量 persons 做 O(n²) pairwise 扫描。这不是自动触发的——每次运行都是架构师 brief 指示后才执行。

---

## 接入 R6 的潜在切入点（管线工程师初步建议）

### 切入点 A：把 R6 塞入 score_pair() 规则链

在 `_RULE_ORDER` 列表首位插入一个 R6 wrapper。

- **劣**：R6 是 async + 需要 DB conn，而 score_pair 是 sync 纯函数；R6 操作对象是 single person → external dict，不是 person-pair 比较，概念不匹配；强行适配会破坏 score_pair 的纯函数契约
- **优**：改动面最小（一行代码）

### 切入点 B：在 resolve_identities() 中加 R6 pre-pass

在 O(n²) pairwise 扫描之前，对每个 person 调用 `r6_seed_match()`，构建 `person_id → R6Result` 映射。两个 person 映射到同一 Wikidata QID（both MATCHED）→ 产生高置信度 MergeProposal(rule="R6")。同时将 R6 结果挂在 PersonSnapshot 上供 R1-R5 参考。

- **优**：尊重 R6 的语义（single person lookup，不是 pair comparison）；async 自然；不破坏 score_pair 纯函数契约；可发现"R1-R5 漏掉但外部锚点一致"的新 merge
- **劣**：需要在 `resolve_identities()` 中新增 ~30 行；PersonSnapshot 可能需要扩展字段

### 切入点 C：R6 作为 post-pass 装饰器

在 ResolveResult 生成后，用 R6 注释已有 merge groups（enrichment only）。

- **优**：零侵入现有流程
- **劣**：不能用 R6 发现新 merge，只是 metadata 丰富；Phase 1 产品层仍然无法利用 R6 做决策

### 推荐

**切入点 B**（R6 pre-pass）。原因：R6 的本质是"用外部锚点识别相同实体"，与 R1-R5 的"用文本/字典规则识别相同实体"互补但操作方式不同；pre-pass 让 R6 结果在 R1-R5 之前就位，且能独立发现 R1-R5 漏掉的 merge。
