# T-P0-028 — Manual Triage UI for pending_review Mappings

- **状态**: planned（Sprint C 候选，可与 T-P0-027 并行独立 track）
- **优先级**: P1 中
- **主导角色**: 管线 + 历史专家 + 前端
- **所属 Phase**: Phase 0 tail
- **依赖**: T-P0-025（44 条 pending_review ✅）
- **创建日期**: 2026-04-22
- **ID 治理说明**: 本卡正式 ID 为 T-P0-028。retro §4 中以 "T-P0-025b" 描述的 manual triage UI 已通过本卡修正。原 T-P0-025b（self-curated seed patch）含义独立保留。

## 1. 背景

Sprint B 收口时 44 条 seed_mappings 处于 pending_review 状态，分布在 16 persons：
- R1 multi（8 人）：同名不同人
- R2 multi（7 人）：别名触发多命中
- R3 multi（1 人）：扫描式多命中

不处置则 R6 状态统计永远有 filtered=44，不收敛。

## 2. 目标

提供历史专家可用的 triage UI，对每个候选一键标记 active 或 rejected；后端只改 UPDATE seed_mappings + INSERT source_evidence 两条 SQL，不改 schema。

## 3. 占位范围（待独立 brief 细化）

- UI：候选列表（QID / label_zh / description_zh）+ 一键操作 + 审计 trail
- 后端：mapping_status 状态机迁移 + active 时补 source_evidence
- 不变量保护：V10.c（active 必须有 evidence）

## 4. 不在本卡范围

- resolver 主调度集成（→ T-P0-027）
- seed schema 扩展
