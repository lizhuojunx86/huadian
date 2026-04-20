# T-P0-006 α Sprint 总览

## 元信息

- **Sprint 标题**：周本纪 α 扩量跑 + source_evidences 写路径真实验证
- **起止**：2026-04-20（Stage 0-5 单日）
- **主导角色**：pipeline-engineer（执行）+ chief-architect（指令/仲裁）+ historian（Stage 3c 裁决）
- **前置依赖**：T-P0-023（ADR-015 Stage 1 evidence chain 激活 ✅）

## Sprint 目标

1. 周本纪（shiji/zhou-ben-ji）全 82 段 ingest 入库
2. T-P0-023 Stage 1 source_evidences 写路径在非 β 章节首次生产级验证
3. R1 identity resolver + ADR-014 apply_merges 首次端到端走通（historian 审核闭环）
4. V7 evidence coverage 从 0% 突破 30% 阈值

## 时间线

| Stage | 内容 | 关键产物 | Commit |
|-------|------|---------|--------|
| 0a-0c | 任务卡 + tier-S slug 14 条 + ctext.py 注册 + fixture | `T-P0-006-alpha.md` + `zhou_ben_ji.txt` | 47550f5 |
| 0d | 4 闸门基线固定 | `stage-0d-baseline.md` + pg_dump anchor | a40c993 |
| 1b | Narrow smoke（5 段）— evidence 写路径首弹 | `stage-1b-smoke.md`（V7: 0→8.79%）| 1ba144f |
| 2 | 全章 ingest（82 段）| `stage-2-full.md`（V7: 57.0%）| b7c63e5 |
| 3a | Identity resolver 全扫（349 persons O(n²)）| `stage-3a-resolve.md`（24 groups, 31 merges）| 2f07b79 |
| 3b | Historian 审核材料包 | `stage-3b-historian-package.md` + verdict JSON | 998de4c |
| 4 | apply_merges 执行（29 soft-delete + 文武 cleanup）| `stage-4-merges.md` | eb1156c |
| 5 | 收官（本文件 + STATUS + CHANGELOG + debt tasks）| — | 本 commit |

## 核心指标 Δ

| 指标 | Stage 0d 基线 | Stage 1b post | Stage 2 post | Stage 4 post | 净变化 |
|------|-------------|-------------|-------------|-------------|--------|
| active_persons | 153 | 173 | 349 | **320** | +167 |
| deleted_persons | 21 | 21 | 21 | **50** | +29 |
| active_names | 249 | 273 | 579 | **524** | +275 |
| source_evidences | 0 | 24 | 242 | **242** | **+242** |
| V7 coverage | 0.00% | 8.79% | 57.0% | **52.48%** | **+52.48pp** |
| merge_log | 23 | 23 | 23 | **52** | +29 |
| llm_calls | 34 | 39 | 121 | 121 | +87 |
| LLM 成本 | — | $0.055 | $0.769 | $0.769 | **$0.77** |

## 主要成就

1. **source_evidences 子系统从 0 行到 242 行** — ADR-015 Stage 1 写路径首次在生产数据上验证通过
2. **V7 覆盖率从 0% 到 52.48%** — 首次突破 30% 阈值，V7 测试从 warning 升为 PASS
3. **周本纪 82 段全部入库** — 史记本纪从 3 章扩展到 4 章（+10318 字）
4. **Identity resolver 端到端走通** — 349 persons O(n²) 扫描 → 24 组候选 → historian 审核 → apply_merges 执行 → 29 合并
5. **Historian 审核流程首次闭环** — verdict JSON 驱动 → 4 闸门协议 → 执行 → 即时 V5/V6 断言
6. **Group 3 文王/武王污染诊断** — Union-Find 跨族桥接的首例实证，"文武"合称根因定位
7. **V4/V5/V6/V7 全绿** — sprint 全程无不变量回归
8. **成本 $0.77 / 预算 $2.00** — 61% 余量

## 代价 / 观察 / 意外

1. **active_names 579→524 (-55)**：29 个 merged persons 的 names 退出 active 统计。ADR-014 Model-A 正确行为——names 仍在 DB，`findPersonNamesWithMerged()` 读端聚合自动拉回。
2. **V7 57.0%→52.48% (-4.5pp)**：分母收缩（active names 减少）导致。source_evidences=242 完好，非数据损失。Sprint 成就记"V7 0→52.48%"。
3. **llm_calls +87（预期 +82）**：extract 按 book_id 全扫不去重，Stage 2 重处理了 Stage 1b 已 extract 的 §1-§5（+5 额外调用，~$0.03 成本）。Step 0.2 侦察已预知。
4. **"文武" NER 污染**：NER 将合称"文武"作为 posthumous name 挂到两个独立人物 → R1 错误连接 → Union-Find 跨族桥接。Stage 4c 硬 DELETE 清理 2 条。根因修复→T-P1-009。
5. **Group 14 桓公两人合体**：NER 将 §43 鲁桓公 + §64 西周桓公合为一个 person。REJECTED 不合并，person 拆分→T-P1-007。

## 衍生债务登记

| ID | 类型 | 优先级 | 标题 | 触发来源 |
|---|---|---|---|---|
| T-P1-007 | 数据清理 | P1 | u6853-u516c 桓公 person 拆分 | Stage 3b Group 14 |
| T-P1-008 | Resolver 架构 | P1 | Union-Find 簇验证（跨朝代污染防护）| Stage 3a Group 3 |
| T-P1-009 | NER prompt | P1 | 合成词护栏（文武/尧舜 类识别）| Stage 4c 文武 cleanup |
| T-P1-010 | Resolver 规则 | P2 | R2 dynasty + reality_status 预过滤 | Stage 3a 全 R1 观察 |

## 遗留风险

- **Group 14 / u6853-u516c 未拆分** — 下次涉"桓公" surface 的章节 ingest 时会放大
- **V7 52.48% 分母含 249 条 pre-sprint names 全 NULL** — T-P0-024 Stage 2 backfill 会把这部分一次性填补

## 后续 sprint 建议排序

1. T-P0-019（β 尾 F1/F2）— 继续验证 evidence 链
2. T-P0-025（词典 seed loader）
3. T-P0-024（evidence Stage 2 backfill）— 把 249 历史 names 补全 evidence，V7→~100%
4. T-P1-007/008/009/010 按事件触发优先级插入

## 产物清单

- Commits: 8（47550f5 → 本 commit）
- Sprint logs: 7 份（stage-0d / 1b / 2 / 3a / 3b / 4 / 5）
- Task cards: 5 份（T-P0-006-alpha + T-P1-007/008/009/010）
- pg_dump anchors: 2（pre-t-p0-006-alpha-20260420 / pre-stage-4-merges-20260420-123958）
- Historian verdict: 归档 `artifacts/historian-verdict.json`（sha256 3ed0d969）
