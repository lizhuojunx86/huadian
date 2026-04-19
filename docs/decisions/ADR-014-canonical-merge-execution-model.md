# ADR-014 — Canonical merge execution model (names-stay + read-side aggregation)

- **Status**: Accepted
- **Date**: 2026-04-19
- **Authors**: 首席架构师
- **Related**:
  - ADR-010（cross-chunk identity resolution with soft-merge）
  - ADR-013（persons.slug partial unique）
  - T-P0-006-β《尚书·尧典 + 舜典》ingest（discovery context）
  - T-P0-015（partial-merge leak precedent）

---

## 1. Context

T-P0-006-β 的 S-5 apply 阶段，管线工程师在没有咨询架构师、也没有经过 ADR 流程的情况下，用 ad-hoc SQL 事务执行了 4 组候选 merge。第一次事务因违反 V1 single-primary invariant 失败，工程师用一条额外的 `UPDATE SET is_primary=false` 绕过，COMMIT 后声称 "与 T-P1-002 一致"。

架构师审查澄清后确认三件事：

1. **S-5 全程未调用** 代码层 `services/pipeline/src/huadian_pipeline/resolve.py:apply_merges()`，全部是手写 ad-hoc SQL。
2. **Ad-hoc SQL 的数据操作形态** 为：`UPDATE person_names SET person_id = canonical`（把 source 的 name 行 FK 改指 canonical）+ `DELETE FROM person_names WHERE person_id = source`（清尾任何未迁移的 name）。
3. **这与 `apply_merges()` 不相容**：后者只对 `persons` 原子设置 `deleted_at + merged_into_id`，对 `person_names` 只做 in-place `SET name_type = 'alias'`（保留 `person_id` 指向 source），**完全不迁移 name 行**。

进一步审计暴露：

- **α 路线 T-P0-011/013 的 12 条 merge 全部是模型 A**（names 留在 source 上），与 `apply_merges()` 契约一致。
- **GraphQL `Person.names` resolver** 经由 `services/api/src/services/person.service.ts:findPersonNamesWithMerged()` 做运行时 merge-chain 聚合，**基于模型 A 假设实现**。
- **S-5 的 3 条 β merge 走了模型 B**（names 迁移 + 源端清理），其中 **弃** 的 3 行原 name 被 DELETE 物理销毁。
- 代码库**事实上同时存在两套不相容的 merge 执行模型**，但**没有任何 ADR 明确过哪一套是 canonical**。

这不是"漏了一列"级别的 bug，而是**项目级架构二义性**。

## 2. Decision

**项目合并执行的唯一合法模型 = 模型 A："names 留在 deleted person 上 + 读端通过 `merged_into_id` 聚合"。**

### 2.1 模型 A 正式约定

一次 merge 必须且只能做下列操作：

1. 在 `persons` 表上对 source 原子地设置 `deleted_at` + `merged_into_id`（单条 `UPDATE`，二列同时写）。
2. **不修改** `person_names.person_id`——每条 name 永远指向它被抽取时所属的 person 实体，哪怕该实体已被 soft-delete。
3. 在 source 上执行 `UPDATE person_names SET name_type = 'alias' WHERE person_id = source AND name_type = 'primary'`，把 source 原先的 primary name 降级为 alias。
4. 在 `person_merge_log` 写入一条审计行（含 `run_id / source_id / target_id / rule / confidence`）。
5. **不修改任何其他表**（不 INSERT、不 DELETE、不触碰 `raw_texts` / `person_aliases` / 未实现的 `raw_text_names`）。

### 2.2 唯一合法入口

`services/pipeline/src/huadian_pipeline/resolve.py::apply_merges()` 是**唯一合法** merge 执行路径。任何场景下（包括 historian 手工裁决、crisis patch、bulk correction）都**不得绕过**此函数直接写 SQL。

- Historian 手工裁决 → 走 `apply_merges()` 的 `manual-historian` rule 分支，或 scripted wrapper。
- 紧急数据修复（如 T-P0-015 级 partial-merge leak）→ **允许** ad-hoc SQL，但必须附 ADR 记录（如 T-P0-015 被本轮以 `manual-fix` rule 合并补救）。
- 任何新场景觉得 `apply_merges()` 不够用 → 先写 RFC 推给架构师，通过后再扩展 `apply_merges()` 本体，**不得旁路**。

### 2.3 读端契约

`findPersonNamesWithMerged(db, canonicalId)` 是 GraphQL `Person.names` 字段的唯一来源：

1. 递归查 `persons WHERE merged_into_id = canonicalId` 得到所有 merged-in person id 列表
2. `person_names WHERE person_id IN (canonicalId + merged_ids)` 聚合全部 name 行
3. 按 4 级优先级 dedup（canonical-side → `merge_at DESC` → `source_evidence` → `created_at`）

**任何 API-层代码不得**直接写 `SELECT * FROM person_names WHERE person_id = X` 作为展示逻辑——必须走 `findPersonNamesWithMerged`。

## 3. Rationale

### 为什么是模型 A

1. **Per-book 归属可追溯性**：每条 name 永远留在其被抽取的 book 关联的 person 实体上。这是"中国古籍 AI 知识平台"底层语义的要求——项目宪法的"一次结构化、N 次衍生"无法建立在"name 行可被迁移"的前提上。虽然当前 `person_names.source_evidence_id` 全表 NULL（见 F8），但模型 A **保留了** 未来填补 evidence 链的可能；模型 B 会**永久丢失** "此 name 最初来自哪本书" 的信号。
2. **Soft-delete 的 soft 性**：ADR-010 的立项前提之一是"merge 必须可回退"。模型 A 下回退一条 merge 是单句 `UPDATE persons SET deleted_at = NULL, merged_into_id = NULL`——数据完整恢复。模型 B 需要重建已销毁的 name 行（本轮 β 已付学费）。
3. **已有代码契约一致性**：`apply_merges()` + `findPersonNamesWithMerged` 经 α 12 次 merge 验证，读端已在生产路径。改为模型 B 需要全盘迁移 12 条历史 merge + 重写 GraphQL resolver——技术债远大于 β 这一轮的小便利。
4. **审计友好**：V4 invariant（见 §5）钉死"所有 deleted person 必须保留至少一条 name 行"，forensic / historian 复核随时可追溯。

### 为什么 S-5 的 ad-hoc SQL 不可接受

**不仅是选错了模型**——更严重的是**绕过了已有代码层的唯一入口**。管线工程师不应为了单次 task 的便利替项目选架构。此类决策必须走架构师审阅 + ADR 流程。

## 4. Consequences

### 正面

- 确立单一 merge 执行路径，消除 model-A/B 不一致的再发空间。
- V4 invariant 在 CI 中防守任何 model-B 残留（无论 ad-hoc SQL 还是未来代码错误）。
- `findPersonNamesWithMerged` 的聚合假设得到 ADR 明确背书，API 层可安全依赖，无需防御性 double-check。
- Soft-delete 回退操作简化为单条 SQL，灾备语义清晰。

### 负面

- 所有 historian 手工裁决也必须走 `apply_merges()`（或其 scripted wrapper），不得直接写 SQL——**需要工具化**（未来工作项）。
- 读层查询跨 `merged_into_id` FK 做聚合 + dedup，随 merge chain 深度增长可能成为性能热点。**响应策略**：若真成热点，先做物化视图 / 读端缓存，不改模型。
- 模型 A 下 `is_primary` 列不被 `apply_merges()` 触碰，GraphQL 聚合可能出现 "alias + isPrimary=true" 的**语义矛盾组合**（见本轮 F11）。**响应**：由 T-P0-016 处理，即 `apply_merges()` 在 demote name_type 时同步 demote is_primary。这是**实施细节补丁**而非 ADR-014 的反例。

## 5. Compliance

### 5.1 Data-layer invariant V4

`services/pipeline/src/huadian_pipeline/qc/invariants.py`（未来实现路径）与 `services/pipeline/tests/test_merge_invariant.py`（本轮已落盘）共同钉死：

```sql
-- V4: model-A leakage check
SELECT p.id, p.slug
FROM persons p
WHERE p.deleted_at IS NOT NULL
  AND p.merged_into_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM person_names WHERE person_id = p.id);
-- MUST RETURN 0 ROWS — ADR-014 compliance
```

### 5.2 Code-level constraint

`resolve.py` 顶部**必须**在下一轮维护中加入模块级注释声明：

```python
"""...

NOTE (ADR-014): apply_merges() is the SOLE legal entry point for merge
execution project-wide. Do not write ad-hoc SQL that mutates
persons.deleted_at / persons.merged_into_id / person_names.person_id
anywhere in the codebase, scripts, or migrations.
"""
```

### 5.3 CI-level static check（未来工作项 T-P0-017）

CI 增加静态扫描规则：禁止在 `services/pipeline/` 和 `services/api/` 出现以下 SQL 模式（除白名单 `resolve.py::apply_merges` 与 rollback 脚本）：

- `UPDATE\s+person_names\s+SET\s+person_id`
- `DELETE\s+FROM\s+person_names\b`
- `UPDATE\s+persons\s+SET\s+(deleted_at|merged_into_id)`（白名单：`apply_merges` 内部那行）

实现放 T-P0-017。未实施前，靠 code review + ADR-014 明示约束。

## 6. Implementation record（本轮已执行）

1. **Rollback** S-5 的 model-B 污染：`ops/rollback/T-P0-006-beta-s5-rollback.sql`
   - 垂 / 朱：`UPDATE person_names SET person_id = source_id` 回改
   - 弃：3 行已 DELETE 销毁 → 纯文本 INSERT 重建（无 FK evidence link，与全表 NULL 状态一致；登记 F8）
   - 清理 `person_merge_log(run_id=3d51dbfe)` 中 3 条 β 行，保留 `manual-fix` 行（帝鸿氏）
2. **Rerun** 3 条 merge via `apply_merges()` Python 路径
   - run_id = `2dc4bf73-1cac-4567-9109-96f38ac83198`
   - 弃 → hou-ji（R1）
   - 垂 → chui（R3-tongjia）
   - 朱 → dan-zhu（manual-historian）
3. **V4 invariant** 落盘测试：`services/pipeline/tests/test_merge_invariant.py`
4. **GraphQL spot-check** 验证三次合并的读端聚合正确

## 7. Non-goals

- 本 ADR **不定义** `is_primary` 与 `name_type` 之间的同步规则（由 F5/F11 + T-P0-016 处理）
- 本 ADR **不定义** `source_evidence_id` 的填充规范（由 F8 + 单独 ADR 处理）
- 本 ADR **不支持** merge chain 深度 > 1（即 A merged_into B merged_into C）——当前假设扁平合并；若业务需要，未来另开 ADR

## 8. Follow-ups

| ID | 描述 | 优先级 | 触发时机 |
|---|---|---|---|
| F5 / F11 | `apply_merges()` 在 demote `name_type` 时同步 demote `is_primary` | P0 | α 扩量前（T-P0-016） |
| F10 | α 旧行 `name_type='primary'` 未被 demote — 扫全表补丁 | P1 | α 扩量前 |
| F8 | `person_names.source_evidence_id` 全表 NULL — evidence 链补齐方案 | P0 | α 扩量前（另起 ADR-015） |
| F9 | NER 输出不落盘 — replay 机制设计 | P1 | α 扩量前 |
| T-P0-017 | CI 静态扫描禁止 ad-hoc merge-mutation SQL | P1 | β 收尾后 |
| T-P0-018 | Historian 手工裁决工具（wrapper over `apply_merges()`） | P1 | α 手工裁决场景出现时 |

详见 `docs/debts/T-P0-006-beta-followups.md`。
