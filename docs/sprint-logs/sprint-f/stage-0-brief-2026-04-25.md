# Sprint F Brief — V1 根因修复 + 衍生债批清理

## 0. 元信息

- **架构师**: Chief Architect
- **Brief 日期**: 2026-04-25
- **Sprint 形态**: 主线 + 4 衍生债打包
- **预估工时**: 2.5-3.5 天
- **触发事件**: Sprint E 收口发现 V1 30→94（+64）= 24% 新 NER persons 缺 is_primary，线性增长不可接受

## 1. 背景

Sprint E秦本纪 ingest 后 V1 invariant violations 从 30 增至 94。根因尚未确认但分布特征明确：
- 27 历史存量（T-P1-022 已记录，可能 T-P0-016 demotion 路径残留）
- ~64 新增（来自秦本纪 ingest 路径，NER/load.py 某条路径未保证 is_primary=true）

如果不在新内容 sprint 之前修这个根因，每 ingest 一章 V1 +50~80 行，存量越滚越大。Sprint F 必须把这个根因封掉再续推内容。

同时打包 Sprint E 产出的 4 张衍生债卡，避免单点积压。

## 2. 目标

### 主线（必做）
1. T-P1-022 Stage 0 诊断：定位 V1 +64 的产生路径（NER prompt? load.py? merge logic?）
2. T-P1-022 Stage 1 根因修复：在产生路径处补上 is_primary 保证逻辑
3. T-P1-022 Stage 2 回填：94 行存量数据修复（按方案 C 逻辑选 promote 候选）
4. T-P1-022 Stage 3 V9 invariant：按方案 B 引入 V9 lower-bound check + ADR
5. T-P1-022 Stage 4 验证：用秦本纪部分段落 re-ingest 测试（避免污染生产数据），确认 V1+V9 稳定

### 衍生债（趁热打铁）
6. T-P1-024 tongjia.yaml 扩充（缪/穆、傒/奚）
7. T-P1-026 disambig_seeds 跨国同名扩充（数据 add）
8. T-P1-025 重耳↔晋文公 merge 检查（investigation + 可能 merge）
9. T-P2-004 NER prompt v1-r5（官衔+名拆分修复，秦本纪暴露 6 例 CRITICAL auto-promotion）

### 不做
- ❌ 不做新内容 ingest（Sprint G 再续推真书）
- ❌ 不做 T-P0-028 triage UI（独立大 sprint）
- ❌ 不动 schema（除 V9 invariant 添加列/触发器外）

## 3. Stages

### Stage 0 — V1 根因诊断（必须先做，2-4 小时）

PE 调研项：
1. 跑 T-P1-022 stub §1.2 的 SQL，导出 94 个 violation 完整列表
2. 按 created_at 时间分布，对比与 Sprint E ingest 的时间窗口（应能区分 27 历史 vs 67 新增）
3. 对新增的 67 行，按 person 来源章节 / NER 模式分类：
   - 哪些是 surface_form 全部 is_primary=false（NER 完全没标）
   - 哪些是有 primary surface_form 但 person_names 表里没同步
   - 哪些是被 merge 过程降级未补
4. 判断根因落在 NER 抽出层 / load.py 写入层 / merge 后处理层 哪一处
5. 输出诊断报告 docs/sprint-logs/sprint-f/v1-root-cause-2026-04-XX.md

### Stage 1 — 根因修复（基于 Stage 0 输出）

如果根因在 NER 层 → 与 T-P2-004 NER v1-r5 合并实施
如果根因在 load.py → 修 _enforce_single_primary 或类似函数（覆盖所有 path）
如果根因在 merge 后处理 → 修 apply_merges 补 primary 提升逻辑

测试：单元测试覆盖修复点（至少 +3 tests）

### Stage 2 — 94 行回填

按 T-P1-022 stub §2 方案 C 的 SQL 模式：
- 优先选 name_type='primary' 的 alias promote
- 否则按 created_at 最早的 alias promote
- 单事务执行 + V1 跑后归 0
- pg_dump anchor 必备

### Stage 3 — V9 invariant 引入

按 T-P1-022 stub §2 方案 B：
- ADR-024 起草："V9 Invariant — at-least-one-primary 下界约束"
- V9 SQL + 3 self-tests（bootstrap=0 / 注入违反 / 边界 case）
- STATUS.md invariants 表新增 V9 行
- 与 V11 类似，bootstrap=0 是金标准（Stage 2 回填后跑 V9 应直接绿）

### Stage 4 — 衍生债批处理（可与 Stage 1-3 并行）

T-P1-024（最小，30 分钟）：
- services/pipeline/data/tongjia.yaml 增 2 行（缪→穆 / 傒→奚）
- 对应单元测试更新

T-P1-026（小，1 小时）：
- disambig_seeds.seed.json 按 historian 报告 §4 给定的跨国同名扩充
- 加载流程跑通

T-P1-025（中，2-4 小时）：
- 调研：当前库内重耳和晋文公 person_id 是否独立？
- 如独立：开 dry-run merge proposal，请 historian 看一下确认（如本 sprint historian 已审过类似可直接 apply，否则按现有 historian 通道走）
- 如已合并：标 done，记入 retro

T-P2-004（中，0.5-1 天）：
- 如 Stage 1 根因合并：作为 NER v1-r5 完整 prompt 修订
- 如 Stage 1 根因不在 NER：独立 v1-r5 修订处理 6 例官衔+名拆分
- 黄金集回归通过 + 秦本纪 auto-promotion 告警从 6 降到 ≤2

### Stage 5 — 验证 + 收档

S5.1 验证：
- 选秦本纪后 5 段（已 ingest 过）做 re-extract dry-run
- 或选下一章前 5 段做 smoke ingest（不持久化或单独 namespace）
- 确认 V1 不再线性增长（新数据 +0 violations）

S5.2 收档：
- STATUS.md 更新（V9 上线 / V1=0 / 衍生债 4 卡 closed）
- CHANGELOG.md 增条
- Sprint F retro
- ADR-024（V9）finalize

## 4. Stop Rules

1. **Stage 0 诊断结论模糊**：如 67 新增违反分布无明显规律（散落 NER/load/merge 三处都有）→ Stop，报架构师决策是按主因修还是分批修
2. **Stage 1 修复影响其他 invariant**：V1 修复导致 V6/V7/V11 任一回归 → Stop，回滚分析
3. **Stage 2 回填发现存量数据有意外结构**（如某 person 完全无 surface_form）→ Stop，单独评估
4. **Stage 3 V9 ADR 设计与 ADR-022/023 模式冲突** → Stop，架构师裁决
5. **Stage 5 验证 V1 仍线性增长**：意味着 Stage 1 修复未覆盖根因 → Stop，回 Stage 0 重诊
6. **任一 Stage LLM 成本异常**（本 Sprint 不应 > $0.50）→ Stop

## 5. 关联 & Follow-up

- 上游 Sprint：Sprint E 收口（commit b8ecf92）
- 4 衍生债卡：T-P1-024 / T-P1-025 / T-P1-026 / T-P2-004（本 Sprint 全部 close）
- T-P1-022 升级：原 P1，本 sprint 升 P0 处理（线性增长风险）
- ADR-024 候选：V9 invariant 引入
- 后续 Sprint G 候选：项羽本纪 / T-P0-028 triage UI（V1 修好后再选）

## 6. 角色边界

| 角色 | 职责 |
|------|------|
| 管线工程师 | Stages 0-5 全部执行 |
| 架构师 | 本 brief + Stage 0 诊断 ACK + Stage 1 选型签字 + ADR-024 finalize + Stop Rule 裁决 |
| Historian | T-P1-025 重耳 merge 复审（如有需要）+ tongjia.yaml 学术依据复核（PE 起草后请 historian 看一眼） |
| 后端工程师 | 不参与（除非 V9 涉及 Drizzle schema 同步，那时再 consult） |

## 7. Sprint F 收口判定

- ✅ V1 = 0（94 → 0）
- ✅ V9 上线 + bootstrap = 0
- ✅ V10/V11 全绿不回归
- ✅ 4 衍生债卡 close（T-P1-024/025/026/T-P2-004）
- ✅ ADR-024 落地
- ✅ Stage 5 验证证明 V1 不再线性增长
- ✅ 工作树干净，无 push/merge

## 8. 节奏建议

第一会话：Stage 0 诊断 + Stage 1 修复 + Stage 2 回填 + Stage 4 数据小卡（T-P1-024/T-P1-026）
第二会话：Stage 3 V9 + Stage 4 大卡（T-P1-025 + T-P2-004）+ Stage 5 验证 + 收档

不要把 8 项工作塞一个会话。Stage 0 诊断结果会影响 Stage 1 选型，自然断点在 Stage 0/1 之后。
