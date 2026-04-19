# T-P1-002: merge 后 person_names nameType 降级 + 重复名去重

- **状态**：done
- **主导角色**：管线工程师 + 后端工程师
- **所属 Phase**：Phase 1（技术债）
- **依赖任务**：T-P0-011 ✅（身份消歧 merge 基础设施）
- **创建日期**：2026-04-19
- **登记来源**：T-P0-013 sanity check（2026-04-18）+ T-P0-015 UNIQUE 衍生需求

## 目标

修复两个相关问题：

1. **primary 未降级**：person B merge 进 canonical A 后，B 的 person_names 仍保持
   `name_type='primary'`，导致 canonical A 的聚合 names 列表出现多个 primary。
   期望：merge 时把被并入方的 primary 降级为 alias。

2. **跨 person_id 重复名未去重**：同一 canonical group 内，canonical 和 merged person
   持有相同 name 文本，API 聚合后出现重复行。
   期望：每个 canonical group 内同名只保留一行（保留 canonical 的版本）。

3. **UNIQUE 约束**：person_names (person_id, name) 加 UNIQUE，防止未来同一 person_id
   下出现重复名。

## 范围（IN SCOPE）

1. 现状调研（DB 统计 + 代码路径分析）
2. 方向选择（A 写端 vs B 读端）
3. Drizzle migration：UNIQUE (person_id, name)
4. Backfill 脚本：降级 + 去重
5. resolve.py apply_merges() 修改（如选 A）或 API 层修改（如选 B）
6. 测试 + 验证

## 范围（OUT OF SCOPE）

- NER prompt 修改（减少产出多 primary 的根因 — 属于 prompt 优化范畴）
- person_names 的 name_type 枚举值调整

## 风险

| # | 描述 | 缓解 |
|---|------|------|
| R1 | backfill 误删有价值的 name 行 | 只删 cross-person-id 重复（保留 canonical 方的行）；回滚 SQL 可从 merge_log 反推 |
| R2 | UNIQUE 约束阻断后续 ingest | ON CONFLICT DO NOTHING 策略；ingest 代码幂等 |
| R3 | 降级 primary 后某些 person 变成 0 primary | backfill 逻辑保证每个 person_id 至少保留 1 个 primary |

## 交付物

- `docs/tasks/T-P1-002-s1-current-state.md` — S-1 调研报告
- `services/api/migrations/0003_*.sql` — UNIQUE 约束 migration
- `services/pipeline/scripts/T-P1-002-backfill.sql` — backfill 脚本
- `services/pipeline/scripts/T-P1-002-rollback.sql` — 回滚脚本
- resolve.py 或 person.service.ts 修改（取决于方向选择）
- 测试覆盖

## 验收标准

- [x] `SELECT person_id, name, count(*) FROM person_names GROUP BY 1,2 HAVING count(*)>1` → 0 rows ✅
- [x] 聚合视角：每个 canonical group 内无 >1 个 primary ✅（写端 backfill 17 行降级）
- [x] 聚合视角：每个 canonical group 内无重复 name 文本 ✅（读端 dedup 覆盖 11 对跨 person_id 重复）
- [x] UNIQUE (person_id, name) 约束存在 ✅（migration 0003）
- [x] T-P0-015 的 SQL 幂等测试通过 ✅（UNIQUE 约束不影响 — 帝鸿氏 alias 已在不同 person_id 下）
- [x] lint / typecheck / test 全绿 ✅（61 API tests + 195 pipeline tests）

## 执行结果

### 数字换算

- **19 个 canonical group** 在聚合视角有 >1 primary（调研维度）
- **17 个 person_id** 在行级有 >1 primary（backfill 维度）
- **差值 2**：倕 和 西伯昌 各自只有 1 primary per person_id，但 canonical group 聚合后出现 >1 primary（来自 merged person 的 primary）。这 2 个由**读端 dedup** 兜住，不需要 backfill
- **11 对跨 person_id 重复名**：全部由读端 dedup 处理（不删行，保留审计链）

### 方向 C（混合）实施

| 层 | 措施 | 影响行数 |
|----|------|---------|
| 写端 | backfill：17 行 person_names `primary → alias` | 17 UPDATE |
| 写端 | resolve.py `apply_merges()` 新增 primary→alias 降级 | 代码修改 |
| 写端 | UNIQUE (person_id, name) 约束 | migration 0003 |
| 读端 | `findPersonNamesWithMerged()` 按 name 文本去重 | 代码修改 |

### 已知 tradeoff

T-P0-015 帝鸿氏 alias 的 `source_evidence_id` 会被 canonical-side null 行遮挡（dedup 规则 a 击穿规则 c 的副作用）。已登记到 STATUS.md T-P0-015 衍生条目，非 bug。

### 衍生债

- T-P1-004：NER 阶段单人多 primary 约束（docs/debts/T-P1-004-ner-single-primary.md）
