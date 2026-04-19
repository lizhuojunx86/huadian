# T-P0-006 α Sprint — Stage 0d 基线快照

- 任务：T-P0-006 α 扩量跑（周本纪）
- 阶段：Stage 0d — 基线固定
- 日期：2026-04-20
- 执行者：pipeline-engineer (Claude Code)

## Gate 1: pg_dump Anchor

- 路径：`ops/rollback/pre-t-p0-006-alpha-20260420.dump`
- Size：157K
- SHA256：`a4c2950c54df488e782471dd965ffdcd3f90cea48d553be70bc9263037c9d017`
- 完成时刻：2026-04-20 00:24 CST

## Gate 2: Schema 快照

### 2.1 provenance_tier 枚举

```
{primary_text,scholarly_consensus,ai_inferred,crowdsourced,unverified,seed_dictionary}
```

6 值 ✅（含 T-P0-023 Stage 1d 新增的 `seed_dictionary`）

### 2.2 source_evidences 结构

```
 id              | uuid         | NOT NULL | gen_random_uuid()
 raw_text_id     | uuid         |          |
 position_start  | integer      |          |
 position_end    | integer      |          |
 quoted_text     | text         |          |
 provenance_tier | provenance_tier | NOT NULL | 'primary_text'
 text_version    | text         |          |
 book_id         | uuid         |          |
 prompt_version  | text         |          |
 llm_call_id     | uuid         |          |
 created_at      | timestamptz  | NOT NULL | now()
 updated_at      | timestamptz  | NOT NULL | now()
```

FK: raw_text_id → raw_texts(id), book_id → books(id)
Referenced by: person_names.source_evidence_id, evidence_links, feedback, event_causality, place_names

### 2.3 person_names

```
 person_id          | uuid      | NOT NULL
 name               | text      | NOT NULL
 name_type          | name_type | NOT NULL
 is_primary         | boolean   |          | false
 source_evidence_id | uuid      |          |          ← nullable FK to source_evidences
```

Indexes: uq_person_names_person_name (person_id, name) UNIQUE
FK: person_id → persons(id) ON DELETE CASCADE, source_evidence_id → source_evidences(id)

### 2.4 persons

```
 slug            | text      | NOT NULL
 name            | jsonb     | NOT NULL
 merged_into_id  | uuid      |          | FK → persons(id)
 deleted_at      | timestamptz |        |
```

CHECK: `persons_merge_requires_delete (merged_into_id IS NULL OR deleted_at IS NOT NULL)`
Partial unique: `persons_slug_unique WHERE deleted_at IS NULL`

### 2.5 迁移文件清单

- 总数：8 文件
- 最新：`0008_t-p0-023-seed-dictionary-enum.sql` ✅

## Gate 3: 运行时 / 计数状态

### 3.1 表计数

| 指标 | 值 |
|------|-----|
| source_evidences 总数 | **0** |
| active persons | 153 |
| active person_names | 249 |
| active names with evidence | 0 |
| **V7 覆盖率 %** | **0.00%** |
| raw_texts (zhou-ben-ji) | 0 |

### 3.2 LLM 缓存

- `.cache` 目录不存在
- 仅有 `__pycache__` + `.pytest_cache`（标准 Python 缓存）
- 周本纪相关文件仅 fixture `zhou_ben_ji.txt`（Stage 0c 产出）
- 无 LLM response 缓存

### 3.3 Prefect / 进程

- Prefect 未激活
- 无 pipeline 相关进程运行

## Gate 4: V1-V7 不变量

| 不变量 | 结果 | 备注 |
|--------|------|------|
| V4 model-B leakage | ✅ PASSED | 全部 merged person 保留 name 行 |
| V6 alias+is_primary | ✅ PASSED | 无 alias + is_primary=true 违规 |
| V5 active-but-merged | ✅ PASSED | CHECK 约束保护 |
| V7 evidence coverage | ⚠️ WARNING | 0.0% (0/249)，低于 30% 阈值 → UserWarning |

注：V1-V3 不在 test_merge_invariant.py 中（由其他测试覆盖），Gate 3.1 的 SQL 计数已间接验证。

**`-W error::UserWarning` 模式**：V7 失败（预期），其余 3 项 PASSED
**正常模式**：4 项全 PASSED，V7 emit warning

## Gate 4 附加：basedpyright

- 错误数：0
- 警告数：0
- 注释数：0

## 异常与升级

无异常。所有指标符合预期。

## Sprint Δ 对比点（sprint 尾用）

| 指标 | 起始值 | 目标 |
|------|--------|------|
| V7 覆盖率 | 0.00% | > 5%（保守：新增行有 evidence，老 249 行仍 NULL） |
| source_evidences 总数 | 0 | +20～50（每个新 person 1 条） |
| active persons | 153 | +30～60（周本纪独有新人物） |
| active person_names | 249 | +40～100 |
| raw_texts (zhou) | 0 | 82（全章） |
| merge_log rows | 23 | +5～15（跨书归并） |
