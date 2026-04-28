# Sprint J Brief — 史记·高祖本纪 Ingest（T-P0-006-ε）

## 0. 元信息

- **架构师**: Chief Architect
- **Brief 日期**: 2026-04-28
- **Sprint 形态**: 单 track 内容产出 + state_prefix_guard 首次实战验证
- **预估工时**: 2-3 天
- **PE 模型**: **Sonnet 4.6**（Sprint I 试用通过，真书 ingest 类工作 Sonnet 已证胜任）
- **触发条件**: Sprint I state_prefix_guard 上线 → 急需真实跨秦汉数据验证 R1 跨国 FP 治理 ≤10% 目标

## 1. 背景

Sprint G 项羽本纪暴露 R1 跨国 FP 62%（13/21 reject），Sprint H/I 累计落地两层 guard：
- Sprint H: dynasty distance guard (200yr) → 拦截跨朝代案例
- Sprint I: state_prefix guard → 拦截春秋同朝代不同国案例

Sprint J 高祖本纪是首次跨秦汉过渡章节 ingest，包含：
- 秦末汉初人物（项羽方与刘邦方人物大量交叉，可能与 Sprint G 项羽本纪 entity 双向映射）
- 楚汉两阵营内"齐王"/"楚王"/"汉王"等多义封号（Sprint G G18 韩信+田荣 类 case）
- 早期秦汉过渡人物（如周勃/萧何/张良等）

预期：state_prefix_guard 在 R1 dry-run 中拦截显著比例的跨国/跨朝代候选；historian review 数应显著低于 Sprint G/秦γ。

## 2. 与前两章 sprint 的差异

| 维度 | 秦本纪 γ | 项羽本纪 δ | 高祖本纪 ε |
|------|----------|-----------|-----------|
| 篇幅 | 72 段 / 10,431 字 | 45 段 / ~8,000 字 | 估 ~80-120 段 / ~12,000 字（实测以 fixture 为准） |
| 字典覆盖 | 25-30%（边界 override） | 50-60% | 60-70%（batch 1 含高祖/萧何/张良/陈平等） |
| 跨秦汉过渡 | 否 | 部分（秦末楚汉） | **核心**（秦末→西汉建立完整覆盖） |
| state_prefix_guard | 不可用 | 不可用 | ✅ Sprint I 上线后首次实测 |
| NER prompt | v1-r4 | v1-r5 | v1-r5（Sprint F 引入） |
| R1 跨国 FP 预期 | 40% | 62% | **<10%（Sprint G→I 目标验证）** |

## 3. Stages（沿用 T-P0-006-γ/δ 5-stage 模板）

### Stage 0 — 前置准备
0.1 ctext fixture 下载：services/pipeline/fixtures/sources/shiji/gao-zu-ben-ji.json
0.2 ctext adapter 注册：_CHAPTER_REGISTRY + _CHAPTER_META 增条
0.3 tier-s-slugs.yaml 楚汉/西汉初扩充 ≥15 行（覆盖：刘邦/萧何/张良/韩信/陈平/周勃/曹参/樊哙/吕雉/吕泽/卢绾/雍齿等）
0.4 disambiguation_seeds 西汉初同名扩充 ≥5 组（重点齐王/楚王/汉王封号歧义）
0.5 evaluate_guards deprecated wrapper 删除（Sprint I 末决议 deferred 到本 sprint 第一笔 commit；ADR-025 §2.4 commitment）
0.6 T-P2-006 dry_run_report label 泛化（Sprint I 衍生债，~10 行改动顺手做）
0.7 Pre-flight V1-V11 baseline，记 Sprint I 收口数（V1=0/V9=0/active=663）作为 Stage 5 对照
0.8 commit C1: chore: T-P0-006-ε Stage 0 prep (gao-zu-ben-ji fixture + adapter + tier-s + disambig + evaluate_guards 删除 + T-P2-006)

### Stage 1 — Smoke（5 段）
1.1 跑 ingest+extract 5 段（高祖本纪开头，含刘邦出身段）
1.2 验证 V1=0 / V9=0（Sprint F 修复继续生产验证）
1.3 验证 source_evidences 写路径 + NER v1-r5 三态名 + R6 prepass + GUARD_CHAINS（dynasty + state_prefix）调用
1.4 成本 ≤ $0.10
1.5 commit C2: feat: T-P0-006-ε Stage 1 smoke (5 paragraphs of gao-zu-ben-ji)

### Stage 2 — Full Ingest（~80-120 段）
2.1 跑全章 ingest+extract+load
2.2 实时监控：每 30 段中间报 LLM 累计成本 + new persons 数
2.3 跑后 V1-V11 全套，记数字
2.4 成本上限：≤ $1.80（比项羽本纪稍长，给 25% buffer）
2.5 NER 产出 new persons 上限：≤ 120（比项羽本纪 117 略宽）
2.6 commit C3: feat: T-P0-006-ε Stage 2 full ingest (gao-zu-ben-ji)

### Stage 3 — Identity Resolver Dry-Run + Historian 审核
3.1 跑 scripts/dry_run_resolve.py
3.2 重点关注（Sprint I 验证核心）：
    - merge proposals 总数
    - **GUARD_CHAINS R1 拦截分布**：dynasty_guard / state_prefix_guard 各拦多少（核心数据）
    - **R1 dry-run 余量**：拦截后剩余 R1 proposals 数 → 这是 historian 实际工作量
    - R6 prepass 分布（应稳定）
    - cross-chapter merge（与项羽本纪 δ entity 重叠）
3.3 计算 R1 跨国 FP 治理率：
    - Pre-Sprint G→I baseline：项羽δ 62% / 秦γ 40%
    - 当前预期：guard 拦截率 + historian reject 比例总和应 ≥ 90%（即"跨国 FP 真实进 historian review 后被 reject"占总 R1 的比例 ≤ 10%）
    - 实测数字将决定 Sprint G→I 治理目标是否达成
3.4 输出 docs/sprint-logs/T-P0-006-epsilon/dry-run-resolve-2026-04-XX.md
3.5 挂起，等 historian 审核（独立会话切 historian）

### Stage 4 — Apply Merges（historian 裁决后）
按 T-P0-006-γ/δ 同流程

### Stage 5 — 收档
- T-P0-006-ε task card 创建
- STATUS / CHANGELOG / Sprint J retro
- 衍生债登记
- **Sprint G→I 治理目标验证报告**（架构师本侧关注的关键交付）

## 4. Stop Rules

1. **V1 / V9 在新数据 ≠ 0** → 立即 Stop（Sprint F 修复持续验证）
2. **Stage 2 cost > $1.80** → Stop
3. **Stage 2 NER new persons > 120** → Stop pre-Stage 3 historian batch review（Sprint E Mit 3 修订版："Stop BEFORE Stage 4 apply"）
4. **R1 跨国 FP 治理率 < 70%** → Stop，分析根因（state_prefix_guard 设计可能需要补强）
5. **R1 跨国 FP 治理率 70-90%** → 继续 apply，但 retro 中分析剩余 case 是否需 NER prompt 改进 / 字典扩充
6. **R1 跨国 FP 治理率 ≥ 90%** → ✅ Sprint G→I 治理目标达成，retro 庆祝
7. **NER v1-r5 黄金集任一已有章节回归** → Stop
8. **任一 V invariant 回归** → Stop

## 5. 角色边界

| 角色 | 职责 |
|------|------|
| 管线工程师（Sonnet 4.6） | Stages 0-5 全部 |
| 架构师 | 本 brief + 各 stage 闸门 ACK + Stop Rule 裁决 + Sprint G→I 治理目标验证 |
| Historian | Stage 3/4 merge proposals 审核（独立会话） |
| 后端 / DevOps | 不参与 |

## 6. 收口判定

- ✅ 高祖本纪完整 ingest（~80-120 段，cost ≤ $1.80）
- ✅ V1 / V9 / V10 / V11 在新数据上保持 0
- ✅ NER v1-r5 在已有章节无回归
- ✅ Sprint I state_prefix_guard 真实数据验证（拦截数 + 治理率）
- ✅ **R1 跨国 FP 治理率 ≥ 90%（Sprint G→I 目标）**
- ✅ T-P0-006-ε task card + retro + 衍生债

## 7. 节奏建议

- 第一会话：Stage 0 + Stage 1 smoke + Stage 2 full ingest + Stage 3 dry-run，挂起等 historian
- 第二会话：historian 审核报告
- 第三会话：PE Stage 4 apply + Stage 5 收档

## 8. PE Sonnet 4.6 试用持续观察

Sprint I 已证 Sonnet 胜任真书 ingest 类工作。本 sprint 继续观察：
- 跨秦汉过渡场景的 NER 处理（v1-r5 prompt 在新章节的稳定性）
- state_prefix_guard 实测数字与 Sprint I 预测的对照精度
- historian review 报告生成质量
- Sprint G→I 治理目标分析报告的洞察深度（这是 Sonnet 与 Opus 区分的关键场景）

如治理目标分析报告深度不足（如只列数字不解读 trend），下次架构创设/分析类 sprint 切回 Opus。
