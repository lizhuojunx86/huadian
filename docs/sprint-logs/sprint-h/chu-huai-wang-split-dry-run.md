# T-P0-031 Stage 3 — 楚怀王 Entity-Split Dry-Run Report

> **角色**：管线工程师 (Opus 4.7 / 1M)
> **日期**：2026-04-27
> **关联**：
> - ADR-026（Entity Split Protocol，accepted 2026-04-27 commit `ed2e8c8`）
> - Historian ruling commit `a117fbf` §5（mention bucketing 裁决）
> - PE Stage 0 inventory commit `8501ab9`（Sprint H S2.5 baseline 确认）
> - migration 0013 + Drizzle schema commit `c119b7c`
> - Split script commit `ba01dea`
> **状态**：dry-run PASS，等架构师 + historian 联合 ACK 后进 S4.6 真事务 apply

---

## 1. 4 闸门状态

| 闸门 | 内容 | 状态 |
|------|------|------|
| **闸门 1** | pg_dump 快照 | ✅ `ops/rollback/pre-t-p0-031-stage-3-20260427-204634.dump`<br>SHA-256 前 12: `52bd6f91da5c`<br>TOC 条数: 289<br>压缩: `-Fc` custom format<br>PG 版本: PostgreSQL 16 |
| **闸门 2** | persons + person_names + entity_split_log schema 确认 | ✅ migration 0013 已 apply，`\d+ entity_split_log` 输出确认（13 列 + 4 索引 + 2 CHECK + 4 FK ON DELETE RESTRICT）；persons + person_names schema 自 Sprint D/E 起未变 |
| **闸门 3** | NER cache / extractions_history replay 状态 | ✅ entity-split 不动 NER 输出，仅在 person_names 插入 2 行副本（共享 source SE）；extractions_history 不写；replay 无影响 |
| **闸门 4** | dry-run RETURNING 全量贴回 | ✅ 见 §3 |

---

## 2. 输入数据基线

### 2.1 source entity (777778a4 楚怀王 / 战国 / 熊槐)

```sql
SELECT id, name, name_type, is_primary, source_evidence_id
  FROM person_names
 WHERE person_id = '777778a4-bc13-4f91-b2c3-6f8efd1b0e72';
```

| pn_id | name | name_type | is_primary | source_evidence_id | 章节 | 裁决 |
|-------|------|-----------|------------|-------------------|------|------|
| `8fb2afc3` | 楚怀王 | primary | t | `d06422a2` | 史记·秦本纪 §65 | **keep**（不动）|
| `7a68ff90` | 怀王 | posthumous | f | `73e39311` | 史记·项羽本纪 §6 | **split_for_safety** |
| `2afc61fc` | 楚王 | nickname | f | `73e39311` | 史记·项羽本纪 §6 | **split_for_safety + NER QC flag** |

### 2.2 target entity (48061967 熊心 / 秦末)

```sql
SELECT id, name, name_type, is_primary, source_evidence_id
  FROM person_names
 WHERE person_id = '48061967-7058-47d2-9657-15c57a0b866b';
```

| pn_id | name | name_type | is_primary | source_evidence_id |
|-------|------|-----------|------------|-------------------|
| `6237c3cb` | 熊心 | primary | t | `f633a72c` |
| `b02bec8f` | 楚怀王孙心 | nickname | f | `f633a72c` |
| `eac1c671` | 楚怀王 | alias | f | `f633a72c` |

### 2.3 entity_split_log baseline

```
SELECT count(*) FROM entity_split_log;  -- 0 (post-migration-0013, pre-apply)
```

### 2.4 unique constraint pre-check

```sql
SELECT id FROM person_names
 WHERE person_id = '48061967-7058-47d2-9657-15c57a0b866b'
   AND name IN ('怀王', '楚王');
-- (0 rows) — target entity does not yet carry these surfaces, INSERT safe.
```

---

## 3. RETURNING 全量

`BEGIN; INSERT ... RETURNING *; ROLLBACK;` 完整输出：

### 3.1 person_names INSERTs（2 行）

```
- id=f6879018-a4fd-49cc-b808-ac496323d6c5 (TX-local UUID, 真 apply 时会重新生成)
  person_id=48061967-7058-47d2-9657-15c57a0b866b
  name='怀王' name_type=posthumous is_primary=False
  SE=73e39311-dfa7-4968-a608-b6a65e587d8f

- id=877a8954-c6df-4525-98d4-221bbe4d71d3 (TX-local UUID)
  person_id=48061967-7058-47d2-9657-15c57a0b866b
  name='楚王' name_type=nickname is_primary=False
  SE=73e39311-dfa7-4968-a608-b6a65e587d8f
```

**对架构师对读核对**：

| 项 | 期望（hist a117fbf §5） | 实际（dry-run RETURNING） | 一致? |
|----|------------------------|---------------------------|:------|
| 行数 | 2（怀王 + 楚王） | 2 | ✅ |
| target person_id | 48061967（熊心） | 48061967 ×2 | ✅ |
| name 1 | 怀王 / posthumous | 怀王 / posthumous | ✅ |
| name 2 | 楚王 / nickname | 楚王 / nickname | ✅ |
| SE 共享 | 73e39311（项羽本纪 §6） | 73e39311 ×2 | ✅ |
| is_primary | False（target 副本不为 primary） | False ×2 | ✅ |

### 3.2 entity_split_log INSERTs（2 行）

```
- id=b22fdd22-dac2-4533-9590-13f676124466
  operation=split_for_safety
  source_person_id=777778a4-bc13-4f91-b2c3-6f8efd1b0e72  (战国楚怀王)
  target_person_id=48061967-7058-47d2-9657-15c57a0b866b  (熊心)
  person_name_id=f6879018-a4fd-49cc-b808-ac496323d6c5    (新 INSERT 怀王 行)
  redirected_name='怀王' redirected_name_type=posthumous
  source_evidence_id=73e39311-dfa7-4968-a608-b6a65e587d8f

- id=5f406359-ea33-4116-9ec5-5d30bce0de90
  operation=split_for_safety
  source_person_id=777778a4 → target_person_id=48061967
  person_name_id=877a8954-c6df-4525-98d4-221bbe4d71d3    (新 INSERT 楚王 行)
  redirected_name='楚王' redirected_name_type=nickname
  source_evidence_id=73e39311-dfa7-4968-a608-b6a65e587d8f
```

每行 audit 还包括（脚本设置，dry-run 中未在简报中印出）：
- `historian_ruling_ref = 'a117fbf §5'`
- `architect_ack_ref = '<待 S4.6 commit hash>'`（dry-run 用占位 `dry-run-pending-ack`）
- `pg_dump_anchor = '<待 S4.6 真 anchor>'`（dry-run 用占位 `dry-run-no-anchor`）
- `applied_by = 'pipeline:t-p0-031-stage-3'`
- `run_id = 'a117fbf0-0031-4000-8000-000000000003'`（deterministic）
- `notes = ` historian §4.1 / §4.2 详细引用

---

## 4. Stop Rule (S4.5) 检查

| 检查项 | 期望 | 实际 | 状态 |
|-------|-----:|-----:|------|
| RETURNING person_names INSERT 行数 | 2 | 2 | ✅ |
| RETURNING entity_split_log INSERT 行数 | 2 | 2 | ✅ |
| 每行 person_name_id ↔ log person_name_id 配对 | 配对 | f6879018↔b22fdd22 / 877a8954↔5f406359 | ✅ |

**Stop Rule (S4.5)：PASS**（不触发，可推进 S4.6 真事务 apply）

---

## 5. ROLLBACK 验证

dry-run 完成后 DB 状态：

```
SELECT person_id, name, name_type FROM person_names
 WHERE person_id IN ('777778a4-bc13-4f91-b2c3-6f8efd1b0e72', '48061967-7058-47d2-9657-15c57a0b866b')
ORDER BY person_id, name_type;
                                  ↓
 (6 rows — pre-dry-run baseline 一致)

SELECT count(*) FROM entity_split_log;
                                  ↓
 0 (pre-apply baseline 一致)
```

ROLLBACK 完整，DB 零变化 ✅

---

## 6. Snapshot 校验栈

dry-run 期间脚本对每条 mention 在 INSERT 前做了下列前置校验（任一不通过即整个事务 ROLLBACK）：

1. source pn_id 行存在
2. source row.person_id == 777778a4（不是别的 entity）
3. source row.name == 期望 surface
4. source row.name_type == 期望 type
5. source row.source_evidence_id == 期望 SE
6. target person_id (48061967) 不已存在该 surface（uq_person_names_person_name 不冲突）

dry-run 通过全部校验 → 真 apply 时校验栈相同，安全等价。

---

## 7. 双签 ACK 检查清单（架构师 + historian 联合 ACK）

### 7.1 数据形态校验

- [ ] **行数**：person_names INSERT 2 行 + entity_split_log INSERT 2 行 = 总 4 INSERT，无 UPDATE / 无 DELETE
- [ ] **target entity**：仅 48061967（熊心）；source entity 777778a4（楚怀王/战国）零写入
- [ ] **SE 共享**：所有 INSERT 行 source_evidence_id 均为 73e39311（与 historian §4.1 "两份共享同一 SE" 描述一致）
- [ ] **source 保留**：8fb2afc3（秦本纪楚怀王 primary）/ 7a68ff90（项羽本纪怀王 posthumous）/ 2afc61fc（项羽本纪楚王 nickname）三行原地不动

### 7.2 protocol 校验

- [ ] **historian 双签**：commit `a117fbf` §5 已签字（裁决人 historian Opus 4.7）
- [ ] **architect 双签**：commit `ed2e8c8` 中 ADR-026 §8 6 + 4 决策点已签
- [ ] **4 闸门**：1 (pg_dump) ✅ / 2 (schema) ✅ / 3 (cache) ✅ / 4 (RETURNING) ✅

### 7.3 V1-V11 影响预判

dry-run 期间未跑 V1-V11（事务内 ROLLBACK）。预判：
- **V1（single-primary）**：source 行不动；target INSERT is_primary=False → V1 不变
- **V4（deleted person 须保留 ≥1 name）**：本操作不动 deleted_at → V4 不变
- **V8（prefix-containment）**：怀王/楚王 surface 已存在于其他 entity（楚怀王/楚王 entity）；target 增加同 surface 不影响 V8 既有判定
- **V9（at-least-one-primary）**：source 仍有 primary（8fb2afc3 不动）；target 仍有 primary（6237c3cb 熊心）→ V9 不变
- **V11（anti-ambiguity cardinality）**：本操作不写 seed_mappings → V11 不变

**任一 V invariant 在真 apply 后回归 → 立即 pg_restore（按 ADR-026 §3.5）**。

### 7.4 联合 ACK 流程

1. PE 提交本报告
2. 用户/architect 读 §3 RETURNING 输出 + §7.1/7.2 检查清单核对
3. 用户/architect 引用 historian commit a117fbf §5 自验（per 用户 message："historian 联合 ACK 我会替你协调"）
4. ACK 后 PE 进 S4.6：真 apply（COMMIT）+ V1-V11 全跑

---

## 8. 衍生发现 / 风险提示

无新发现。

待 S4.6 真 apply 后产生的"楚王 alias 副本在熊心 entity 上"形态 = **过渡态**，未来由 T-P2-005（NER v1-r6 楚汉封号 few-shot）+ T-P2-007 候选（mention 段内位置切分）成熟后清理。
