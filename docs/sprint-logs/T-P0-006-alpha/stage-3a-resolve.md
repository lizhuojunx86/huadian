# T-P0-006 α — Stage 3a Identity Resolver 扫描报告

- 日期：2026-04-20
- 执行者：pipeline-engineer (Claude Code)
- run_id: ccd3c71d-4e20-4b36-ace3-eccfa1001f85

## Step 0 侦察结论

- **resolve_identities 签名**：`async def resolve_identities(pool: asyncpg.Pool) -> ResolveResult` — 纯只读，不写 DB
- **CLI 子命令**：无。使用一次性 Python 脚本
- **规则集**：R1(0.95 surface_form) → R2(0.93 帝X) → R3(0.90 tongjia) → R5(0.90 miaohao) → R4(0.65 identity_notes)，全 5 条激活
- **候选 schema**：`ResolveResult` → `merge_groups: list[MergeGroup]`（canonical + merged_ids/names/slugs + proposals + reason）+ `hypotheses: list[HypothesisProposal]`
- **`generate_dry_run_report()`** 已内置，输出中文格式化报告

## Step 1 pre-scan

| 指标 | 值 |
|---|---|
| active_persons | 349 |
| deleted_persons | 21 |
| active_names | 579 |

## Step 2 扫描执行

- **运行时间**：0.29 秒（349² / 2 ≈ 61k 对比较）
- **候选总数**：24 merge groups / 33 proposals / 31 persons to merge
- **Hypotheses**：0（无 0.5-0.9 区间候选）
- **Errors**：0
- **合并后预计人数**：349 → 318（减少 31）
- **JSON 落盘**：`/tmp/t_p0_006_stage3a_candidates.json`（4.7 KB）

## Step 3 分类

### 3.1 置信度分布

| 区间 | 数量 | 说明 |
|------|------|------|
| ≥ 0.9 (高) | 33 | 全部 R1 |
| 0.7 ~ 0.9 (中) | 0 | — |
| < 0.7 (低) | 0 | — |

### 3.2 规则分布

| 规则 | 命中数 |
|------|--------|
| R1 (surface_form) | 33 |
| R2 (帝X prefix) | 0 |
| R3 (tongjia) | 0 |
| R5 (miaohao) | 0 |
| R4 (identity_notes) | 0 |

注：R3 通假字规则未产出新匹配（费仲↔费中 未被通假字典覆盖，按 Stage 0b 裁决留给 historian）

### 3.3 子类分布（A/B/C）

| 子类 | 数量 | 说明 |
|------|------|------|
| **A 新×旧** | 5 | 周本纪新 person × 既有 DB person |
| **B 新×新** | 19 | 周本纪内部重复（不同段落提取的同一人物） |
| **C 旧×旧** | 0 | 无既有 DB 内部新匹配 |

### 3.4 预测冲突验证

| 预测冲突 | 期望 | 实际 | 说明 |
|----------|------|------|------|
| 武王 ↔ 周武王 | A 类 | ⚠️ 在超大组 3 中 | 见下方警告 |
| 费仲 ↔ 费中 | 不出现 | ✅ 不出现 | R1 不命中，surface 不等 |
| 后稷 ↔ 弃 | 出现 | ✅ A 类组 1 | R1 overlap: 后稷, 弃 |
| 帝尧 ↔ 尧 | 出现 | ✅ 不出现（正确） | NER 更新了既有 yao，未创建新 person → 无 dup |
| 帝舜 ↔ 舜 | 出现 | ✅ 不出现（正确） | 同上 |

### 3.5 高置信度代表样本

```
[组1-A] 后稷 (hou-ji) ← 弃 (u5f03) | R1 overlap: 后稷, 弃 | ✅ 正确
[组2-A] 纣 (zhou-xin) ← 帝辛 (di-xin) | R1 overlap: 帝辛 | ✅ 正确
[组4-A] 武庚 (u6b66-u5e9a) ← 禄父 (u7984-u7236) | R1 overlap: 禄父 | ✅ 正确
[组5-A] 周成王 (u5468-u6210-u738b) ← 成王 (u6210-u738b) | R1 overlap: 成王 | ✅ 正确
[组6-B] 季历 (ji-li) ← 公季 (u516c-u5b63) | R1 overlap: 公季 | ✅ 正确
[组11-B] 幽王 (you-wang) ← 周幽王 (u5468-u5e7d-u738b) | R1 overlap: 幽王 | ✅ 正确
[组12-B] 周平王 ← 宜臼, 平王 | R1 overlap: 宜臼, 平王 | ✅ 正确
[组24-B] 赧王 ← 周君, 王赧, 周赧王 | R1 overlap: 王赧, 周君 | ✅ 正确
```

## ⚠️ 警告：组 3 超大合并组 — 文王/武王混淆

**组 3**：武王(wu-wang) ← 西伯昌(xi-bo-chang) + 周文王 + 姬昌 + 姬发 + 文王 = **6 人合 1**

**问题**：Union-Find 传递闭包将**两个不同历史人物**合进一组：
- **武王系**：武王(wu-wang) = 姬发 = 太子发（周武王）
- **文王系**：西伯昌(xi-bo-chang) = 姬昌 = 文王 = 周文王（周文王，武王之父）

**根因**：R1 在以下 surface 上命中，产生跨系传递：
- "西伯" 同时出现在 wu-wang 和 xi-bo-chang 的 name 集 → 错误关联
- "文王" / "文武" 可能出现在武王的 surface 集 → 错误关联
- 正确关联（"太子发"连接 wu-wang ↔ 姬发）与错误关联混在同一 Union-Find 组

**Historian 裁决需求**：此组必须**拆分**为两个独立合并组：
1. 文王组：西伯昌 + 周文王 + 姬昌 + 文王 → canonical = 西伯昌(xi-bo-chang)
2. 武王组：武王 + 姬发 → canonical = 武王(wu-wang)

## ⚠️ 可疑：组 14 鲁桓公 ← 桓公

"桓公" 在周本纪中可能指**齐桓公**（§46-§48）或**鲁桓公**（§44）。NER 提取了单独的 "桓公" person，resolver 将其匹配到 "鲁桓公"。
- 若 "桓公" 实际指齐桓公 → **false positive**（需 historian 核实原文段落）
- 若 "桓公" 实际指鲁桓公 → 正确合并

## 异常与观察

1. **全部 R1，无 R2/R3/R5 命中**——说明周本纪新增人物中无 "帝X" 前缀对、无通假字新发现、无庙号新匹配。通假字典（tongjia.yaml）的费仲←→费中按 Stage 0b 裁决留给 historian 手工添加。
2. **0 hypotheses**——所有 pair 要么 ≥ 0.9 auto-merge 要么完全不匹配。R4 identity_notes 规则未触发（NER v1-r4 的 identity_notes 字段可能为空或不含 "X即Y" 模式）。
3. **C 类 = 0**——旧 DB 中没有新的跨 person 匹配浮现。说明前几轮 sprint 的 merge 覆盖良好。

## Stage 3b 建议（给 historian 的优先审核清单）

**批次 1 — A 类 5 组（高优先）**：
- 组 1: 后稷←弃 ✅ 预期正确
- 组 2: 纣←帝辛 ✅ 预期正确
- 组 3: 武王←文王系 **⚠️ 需拆分**
- 组 4: 武庚←禄父 ✅ 预期正确
- 组 5: 周成王←成王 ✅ 预期正确

**批次 2 — B 类 19 组（中优先，大部分应为正确的内部去重）**：
- 重点审：组 14 鲁桓公←桓公（可疑）
- 组 23 嵬←考王（需确认：嵬=考王的个人名？）
- 其余 16 组多为 "X王←周X王" 格式，预期正确

**总工作量**：24 组审核，其中 2 组需特别注意（组 3 拆分 + 组 14 核实）。在 historian 合理审核量内。
