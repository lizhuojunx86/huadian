# T-P0-006 α Sprint — Stage 1b Narrow Smoke Report

- 日期：2026-04-20
- 执行者：pipeline-engineer (Claude Code)
- 段落数 N：5（§1-§5）

## Step 0: 前置侦察

### 0.1 幂等性

`_insert_raw_texts` (ingest.py:122-132): 应用层 SELECT-before-INSERT 去重，key = `(source_id, paragraph_no)`。
无 DB UNIQUE 约束。`_upsert_book` 有 `ON CONFLICT (slug) DO UPDATE` 真 upsert。

**结论**：**续跑路径安全** — Stage 2 pilot 全 82 段会 skip 已入库的 5 段。

### 0.2 extract 去重

`extract_persons` (extract.py:116-124): 扫全部 `raw_texts WHERE book_id=$1 AND deleted_at IS NULL`。
**无去重** — Stage 2 会重复调 5 次 LLM（~$0.05 额外，可忍）。

### 0.3 段落选择

| 段 | 字数 | 关键人物 | 类型 |
|---|---|---|---|
| §1 | 175 | 姜原(新), 帝喾(旧), 弃(旧) | 后稷出生传说 |
| §2 | 155 | 帝尧(旧), 帝舜(旧), 后稷(旧) | 后稷封邰 |
| §3 | 175 | 不窋(新), 鞠(新), 公刘(新), 庆节(新) | 周先祖世系 |
| §4 | 320 | 皇仆~公叔祖类(新×7), 古公亶父(新,tier-S) | 古公迁岐 |
| §5 | 92 | 太伯(新,tier-S), 虞仲(新), 太姜(新), 季历(新,tier-S), 太任(新), 昌(旧=文王) | 让位传位 |

N=5 确认：新旧混合、tier-S 白名单验证、无超 500 字段落。

## Step 1: Pre-run 快照

| 指标 | 值 |
|---|---|
| zhou raw_texts | 0 |
| source_evidences | 0 |
| active persons | 153 |
| active person_names | 249 |
| llm_calls | 34 |

## Step 2: 脚本执行

```
INGEST: book_id=07ec7d8a inserted=5 skipped=0
EXTRACT: persons=29 prompt=ner/v1-r4 cost=$0.0549 tokens_in=1078 tokens_out=3443
  §1: 3 persons $0.0062 (180+380)
  §2: 3 persons $0.0064 (187+386)
  §3: 5 persons $0.0095 (199+595)
  §4: 11 persons $0.0199 (383+1252)
  §5: 7 persons $0.0128 (129+830)
MERGE: 29 → 24 unique persons
LOAD: new=20 updated=4 names=24 errors=0
```

**Warnings** (T-P1-004 auto-promotion, non-blocking):
- 帝喾: 0 primaries → promoted name_zh match
- 尧: 0 primaries, no name_zh match → promoted shortest "帝尧"
- 舜: same pattern → promoted "帝舜"
- 后稷: 0 primaries → promoted name_zh match

## Step 3: Δ 分析

### 3.1 表计数

| 指标 | pre | post | Δ | 说明 |
|---|---|---|---|---|
| zhou raw_texts | 0 | 5 | +5 | ✅ 符合 N |
| source_evidences | 0 | **24** | **+24** | ✅ 每 person 1 条 |
| active persons | 153 | 173 | +20 | 20 new + 4 updated |
| active person_names | 249 | 273 | +24 | 每 person 至少 1 name |
| llm_calls | 34 | 39 | +5 | ✅ 每段 1 次 LLM call |

### 3.2 V7 覆盖率

| 指标 | 值 |
|---|---|
| total active names | 273 |
| with evidence | 24 |
| **coverage** | **8.79%** |
| **Δ from baseline** | **+8.79pp (0.00% → 8.79%)** |

**新写入的 24 条 person_names 全部 source_evidence_id 非空** ✅

### 3.3 V1-V7 矩阵

| 不变量 | 结果 | 备注 |
|---|---|---|
| V4 model-B leakage | ✅ PASSED | |
| V5 active-but-merged | ✅ PASSED | |
| V6 alias+is_primary | ✅ PASSED | |
| V7 evidence coverage | ⚠️ 8.8% < 30% | warning 级，预期内 |

**V1/V2/V3 状态**：`test_merge_invariant.py` 仅含 V4/V5/V6/V7 四项 DB 级测试。
- V1 (single-primary)：有 `test_load_validation.py` 单元测试覆盖（_enforce_single_primary），无 DB 级不变量
- V2 (name completeness)：完全缺失
- V3 (FK completeness)：完全缺失
- **衍生债务**：sprint 尾统一决定是否新建 V1/V2/V3 DB 级不变量测试

## Step 4: Evidence 行抽样

24 条 source_evidences 全部检查通过：

| 字段 | 预期 | 实际 | 状态 |
|---|---|---|---|
| raw_text_id | NOT NULL → 本次 raw_texts | 全部 NOT NULL | ✅ |
| book_id | NOT NULL → shiji-zhou-ben-ji | 全部 NOT NULL | ✅ |
| provenance_tier | ai_inferred | 全部 ai_inferred | ✅ |
| prompt_version | ner/v1-r4 | 全部 ner/v1-r4 | ✅ |
| llm_call_id | NOT NULL → llm_calls.id | 全部 NOT NULL | ✅ |

FK 完整性抽查：5 条 source_evidences → llm_calls JOIN 成功，model=claude-sonnet-4-6 ✅

## 成本

| 项目 | 值 |
|---|---|
| 实际成本 | $0.0549 |
| 预估 | ~$0.025 |
| Δ | +$0.03（§4 长段落 383 tokens 拉高均价） |
| 单段均价 | $0.011/段 |
| 82 段外推 | ~$0.90（Low $0.50 ~ High $1.30） |
| 预算余量 | $2.00 - $0.055 = $1.95 |

## Verdict

**✅ WRITE PATH PASS**

- source_evidences 子系统从 0 行到 24 行，首次实弹激活成功
- 全部 5 列字段填写正确，FK 完整
- V7 覆盖率从 0.00% 升至 8.79%，证明新 ingest 自动产出 evidence
- V4/V5/V6 无回归
- 0 load errors
- 成本在预算范围内

**已知预期行为**（非 bug）：
- 弃 (u5f03) 作为新 person 重建（旧的已 soft-deleted/merged into hou-ji）→ Stage 3 identity resolver 会重新归并
- 周文王 (u5468-u6587-u738b) 同理重建 → resolver 会归并到 xi-bo-chang
- T-P1-004 auto-promotion warnings 是 NER v1-r4 对尊称前缀的已知行为
