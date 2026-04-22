# T-P0-027 — Resolver Orchestration（R1-R6 全集成主调度）

- **状态**: planned（Sprint C 主线）
- **优先级**: P0 高（Phase 1 产品层入口前置）
- **主导角色**: 管线工程师 + 首席架构师
- **所属 Phase**: Phase 0 tail / Phase 1 head 桥接
- **依赖**: T-P0-025（Sprint B Wikidata seed loader ✅）/ T-P0-011（identity_resolver R1-R5 ✅）/ ADR-010 §R6 ✅
- **创建日期**: 2026-04-22
- **ID 治理说明**: 本卡正式 ID 为 T-P0-027。retro §5.2 中 "T-P0-026 resolver orchestration" 为编写时 ID 复用错误，已通过本卡修正。

## 1. 背景

Sprint B（T-P0-025）落地 R6 seed-match 规则，但仅作为独立函数存在，**未接入 resolver 主调度**：
- R1-R5 由 identity_resolver/resolve.py 主循环统一调度
- R6 在 r6_seed_match.py 实现，目前只有 unit test 调用方，无 production 调用
- Phase 1 产品层（resolve API / NER pipeline）需要"R1-R6 全集成"的统一入口

## 2. 目标

把 R6 接入 resolver 主调度，让 Phase 1 产品层通过单一入口拿到完整 R1-R6 的 resolve 结果。具体范围由 Stage 0 brief 定义。

## 3. Stages（占位，由架构师 Stage 0 brief 细化）

- Stage 0：现状盘点（inventory 已由管线工程师产出）+ 接入设计（架构师 brief）
- Stage 1：resolver 主循环改造
- Stage 2：R6 四值状态机（matched/below_cutoff/ambiguous/not_found）如何并入 R1-R5 判定
- Stage 3：测试 + 不变量
- Stage 4：收口

## 4. 不在本卡范围

- pending_review triage（→ T-P0-028）
- 第二 TIER-1 数据源评估（→ ADR-024，未启动）
- 字典 source 扩展到 places / events（→ Phase 1+）
