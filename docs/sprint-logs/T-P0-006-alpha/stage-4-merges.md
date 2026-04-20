# T-P0-006 α — Stage 4 apply_merges 报告

- 日期：2026-04-20
- 执行者：pipeline-engineer (Claude Code)
- merge run_id：4c05b872-da8d-46be-b5b7-c4ed62de91f4

## Gate 0-3 摘要（回顾）

| 项目 | 值 |
|------|-----|
| verdict sha256 | `3ed0d969e74c67ffc8d5462e5e4ed7e8677bc0da86b9fd8a788381bb52a811f0` |
| pg_dump anchor | `ops/rollback/pre-stage-4-merges-20260420-123958.dump` (sha256 c5f4ce4b) |
| dry-run 对账 | 29 = 29 ✅ |
| V5 pre-scan | ✅ PASSED |

## Gate 3.5 FK 检查

person_names 无下游 FK 引用（0 行），DELETE 安全。

## Gate 4a apply_merges 执行

| 项目 | 值 |
|------|-----|
| run_id | `4c05b872-da8d-46be-b5b7-c4ed62de91f4` |
| groups | 24 |
| persons_soft_deleted | **29** ✅ |
| log_rows_inserted | 29 |
| errors | **0** |
| merged_by | `historian:stage4` |

29 个 merged person 的 primary names 全部 demoted to alias + is_primary=false。

## Gate 4b V5/V6 即时断言

| 不变量 | 结果 |
|--------|------|
| V5 (no active-but-merged) | ✅ PASSED |
| V6 (no alias+is_primary) | ✅ PASSED |

## Gate 4c 文武 surface DELETE

| 步骤 | 结果 |
|------|------|
| 预 SELECT | 2 行确认 (is_primary=false) |
| DELETE RETURNING | **2 行** ✅ |

删除记录：
- `19167f92` (person wu-wang, surface "文武", posthumous)
- `39505e44` (person u6587-u738b→已 soft-deleted into xi-bo-chang, surface "文武", posthumous)

## Gate 4d V1-V7 全矩阵

| 不变量 | 结果 | 备注 |
|--------|------|------|
| V4 model-B leakage | ✅ PASSED | |
| V5 active-but-merged | ✅ PASSED | |
| V6 alias+is_primary | ✅ PASSED | |
| V7 evidence coverage | ✅ **PASSED (52.5%)** | 无 warning（>30% 阈值）|

## Gate 4e Δ 快照

| 指标 | Stage 0d 基线 | Stage 2 post | Stage 4 post | 硬期望 | 状态 |
|------|-------------|-------------|-------------|--------|------|
| active_persons | 153 | 349 | **320** | 320 | ✅ |
| deleted_persons | 21 | 21 | **50** | 50 (21+29) | ✅ |
| active_names | 249 | 579 | **524** | ~572-577 | ⚠️ 见下 |
| source_evidences | 0 | 242 | **242** | 242 | ✅ |
| V7 coverage | 0.00% | 57.0% | **52.48%** | ≥57% | ⚠️ 见下 |
| merge_log_total | 23 | 23 | **52** | 52 (23+29) | ✅ |

### active_names 524 vs 预估 572-577

Δ = 579 - 524 = -55（减少 55 条）。预估"减 2（文武）+ 若干去重" = -7 左右。实际减少 55 远多于预估。

**根因**：apply_merges demote primary→alias 不删除 names，但 active_names 的 JOIN 条件是 `p.deleted_at IS NULL`。29 个被 soft-deleted 的 persons 的全部 person_names（55 条）不再计入 active_names。这是**正确行为**——names 仍保留在 DB 中（ADR-014 model-A），只是 JOIN 时被排除。

### V7 coverage 52.48% vs 预估 ≥57%

同理：分子（active names with evidence）也因 soft-delete 减少。原来 330 条有 evidence 的 names 中，部分属于现在被 soft-deleted 的 persons → 从分子排除。分母从 579→524，分子从 330→275 左右。275/524 ≈ 52.5%。

**这不是回归**——evidence 数据完好（source_evidences=242 不变），只是统计口径随 active person 定义收缩。

## 最终状态

| 指标 | 值 |
|------|-----|
| active_persons | **320** |
| active_names | 524 |
| source_evidences | 242 |
| V7 coverage | **52.48%** |
| merge_log | 52 (23 旧 + 29 新) |
| V4/V5/V6/V7 | **全绿** |
| 累计 LLM 成本 | $0.77 |

## 衍生观察

1. **active_names Δ 解读**：-55 条是正确的 ADR-014 model-A 行为——soft-deleted persons 的 names 仍在 DB，只是不参与 active 统计。`findPersonNamesWithMerged()` 读端聚合会自动拉回这些 names。
2. **V7 覆盖率下降**：从 57.0% → 52.5% 是统计口径效应，非数据损失。新增的 source_evidences 仍完好。
3. **merge_log +29 条**：全部带 `merged_by='historian:stage4'`，可追溯。
