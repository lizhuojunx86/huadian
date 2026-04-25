# Sprint G Brief — 史记·项羽本纪 Ingest（T-P0-006-δ）

## 0. 元信息

- **架构师**: Chief Architect
- **Brief 日期**: 2026-04-25
- **Sprint 形态**: 单 track 内容产出（Phase 0 真书续推）
- **预估工时**: 1.5-2.5 天
- **触发条件**: Sprint F 收口（V1 根因封堵 + V9 上线 + NER v1-r5 + R6 cross-dynasty guard）= 内容产出四重护栏就绪

## 1. 背景

Sprint E/F 是"内容产出 + 根因修补"的串联：秦本纪 ingest → 暴露 V1 线性增长 → Sprint F 修封 → 现在可以安全续推内容。

Sprint G 目标：项羽本纪完整 ingest，沿用 T-P0-006-γ 秦本纪的 5-stage 模板，无新架构决策，纯执行类 sprint。

> **本 brief 复用 T-P0-006-γ stage-0-brief-2026-04-24.md 的 stages 模板**，差异点列在下面。

## 2. 与秦本纪 Sprint E 的差异

| 维度 | 秦本纪（T-P0-006-γ） | 项羽本纪（T-P0-006-δ） |
|------|----------------------|------------------------|
| 篇幅 | 72 段 / 10,431 字 | ~60-80 段（实测以 fixture 为准） |
| 字典覆盖率 | 25-30%（边界 override） | 50-60%（batch 1 字典 + Wikidata 覆盖好） |
| 跨朝代场景 | 春秋 → 战国 → 秦（多 dynasty 跨度） | 秦末 → 楚汉（少 dynasty 跨度，主要楚汉两方） |
| R6 cross-dynasty 风险 | 中（多次跨 500 年候选） | 低（同一时段为主） |
| NER prompt 版本 | v1-r4 | **v1-r5**（Sprint F 引入官衔+名规则） |
| Stop Rule 细化 | Mit 3 措辞模糊（"Stop BEFORE Stage 4"） | **已修订，措辞清晰** |

## 3. Stages（沿用秦本纪 5-stage 模板）

### Stage 0 — 前置准备
0.1 ctext fixture 下载：services/pipeline/fixtures/sources/shiji/xiang-yu-ben-ji.json
0.2 ctext adapter 注册：_CHAPTER_REGISTRY + _CHAPTER_META 增条
0.3 tier-s-slugs.yaml 楚汉扩充：≥15 行（建议覆盖：项羽/项梁/项伯/项庄/范增/英布/钟离昧/龙且/虞姬/楚怀王/宋义 等）
0.4 disambiguation_seeds 楚汉同名扩充：≥5 组（如多义"将军"称呼）
0.5 Pre-flight：跑 V1-V11 baseline，记 Sprint F 收口数字（V1=0 / V9=0 / active=555）作为 Stage 5 对照
0.6 commit C27: chore: T-P0-006-δ Stage 0 prep (xiang-yu-ben-ji fixture + adapter + tier-s + disambig)

### Stage 1 — Smoke（5 段）
1.1 跑 ingest+extract 5 段（项羽本纪开头，含项羽出场段）
1.2 验证：source_evidences 写路径 + NER 三态名 + R6 prepass + V1（必须保持 0，新数据上 V1 不能涨——Sprint F 修复的核心证据）
1.3 成本 ≤ $0.10
1.4 commit C28: feat: T-P0-006-δ Stage 1 smoke (5 paragraphs of xiang-yu-ben-ji)
1.5 **关键 Stop Rule**：smoke 跑后 V1 ≠ 0 → 立即 Stop，意味着 Sprint F 修复未覆盖某条 path（这是 Sprint F Stage 5 验证的延伸）

### Stage 2 — Full Ingest（~60-80 段）
2.1 跑全章 ingest+extract+load
2.2 实时监控：每 30 段中间报 LLM 累计成本和 new persons 数（命中 Mit 上限立即 Stop）
2.3 跑后 V1-V11，记 V1（必须仍 0）+ V9（必须仍 0）+ active persons + new evidences
2.4 成本上限：≤ $1.50（项羽本纪比秦本纪略小）
2.5 commit C29: feat: T-P0-006-δ Stage 2 full ingest (xiang-yu-ben-ji)

### Stage 3 — Identity Resolver Dry-Run + Historian 审核
3.1 跑 scripts/dry_run_resolve.py，输出报告 docs/sprint-logs/T-P0-006-delta/dry-run-resolve-2026-04-XX.md
3.2 重点关注：
    - merge proposals 总数
    - R6 prepass 分布
    - R6 cross-dynasty guard 拦截数（应低，楚汉 dynasty 跨度小）
    - 与秦本纪人物的 cross-chapter merge（如秦末人物已在秦本纪出现）
3.3 挂起，等 historian 审核（独立会话切 historian）

### Stage 4 — Apply Merges（historian 裁决后）
按秦本纪同流程

### Stage 5 — 收档
- T-P0-006-δ task card 创建（与 α/β/γ family 一致）
- STATUS / CHANGELOG / retro
- 衍生债登记
- Sprint G retro

## 4. Stop Rules（强化版，吸取 Sprint E 教训）

1. **V1 / V9 在新数据上变化**：Stage 1 smoke 或 Stage 2 ingest 后 V1 ≠ 0 或 V9 ≠ 0 → 立即 Stop（这是 Sprint F 修复的真实生产验证）
2. **Stage 2 cost > $1.50** → Stop
3. **Stage 2 NER 产出 new persons > 80** → Stop pre-Stage 3 historian batch review（**注意：Stop BEFORE Stage 4 apply，dry-run 输出可作 historian 预审材料**——Sprint E Mit 3 措辞修订后的版本）
4. **R6 cross-dynasty guard 拦截 > 3** → Stop（楚汉同时段不应有这么多跨朝代候选）
5. **NER v1-r5 在已有章节回归**：Stage 1 smoke 后跑黄金集，任一已有章节 NER 输出降级 → Stop（v1-r5 应只增不减）
6. **任一 V invariant 回归** → 立即 Stop

## 5. 角色边界

| 角色 | 职责 |
|------|------|
| 管线工程师 | Stages 0-5 全部 |
| 架构师 | 本 brief + 各 stage 闸门 ACK + Stop Rule 裁决 |
| Historian | Stage 3/4 merge proposals 审核（独立会话） |
| 后端 / DevOps | 不参与 |

## 6. 收口判定

- ✅ 项羽本纪完整 ingest（~60-80 段，cost ≤ $1.50）
- ✅ V1 / V9 / V10 / V11 在新数据上保持 0（Sprint F 修复真实验证）
- ✅ NER v1-r5 在已有章节无回归
- ✅ Active persons 净增（合并后实际数字以 historian 裁决为准）
- ✅ T-P0-006-δ task card + retro + 衍生债（如有）

## 7. 节奏建议

第一会话：Stage 0 + Stage 1（smoke）+ Stage 2（full ingest）+ Stage 3（dry-run resolve），挂起等 historian
第二会话：historian 审核报告
第三会话：PE 切回 → Stage 4 apply + Stage 5 收档

不要把 Stage 0-5 全塞一个会话——Stage 3/4 涉及 historian 跨会话协作，自然断点。

## 8. PE 模型选择（架构师注）

本 sprint 是检测 PE 角色用 Sonnet 4.6 是否胜任的好场景：
- Pattern 已成熟（沿用 T-P0-006-γ 模板）
- 无新架构决策
- Stop Rule 已细化到位

如 PE 切 Sonnet，重点观察：Stop Rule 触发判断 / 数字精度 / 边界 case 捕捉 / TodoList 对齐度 / dry-run vs apply 区分。任一 yellow flag → 切回 Opus。
