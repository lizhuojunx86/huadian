# 任务卡索引

> 本目录记录华典智谱所有任务卡。
> 命名规则：`T-NNN-kebab-title.md`
> 状态枚举：`pending / in_progress / review / done / blocked / cancelled`
> 模板见 `docs/04_工作流与进度机制.md §三`

---

## 当前活跃任务

| 任务 ID | 标题 | 状态 | 主导角色 | 所属 Phase |
|---------|------|------|---------|-----------|
| T-P0-002 | DB Schema 落地 | **ready** | 后端工程师 | Phase 0 |
| T-P0-005a | SigNoz 版本对齐与接入 | **planned** | DevOps + 管线 | Phase 0 |

## 已完成
| 任务 ID | 标题 | 完成日期 | 主导角色 |
|---------|------|---------|---------|
| T-000 | 用户审阅 docs/00~06 架构文档并签收 | 2026-04-15 | 用户 |
| T-001 | 补齐 10 个 agent 角色定义 | 2026-04-15 | 架构师 |
| T-002 | 首批 ADR-001~ADR-006 落地 | 2026-04-15 | 架构师 |
| T-003 | U-01~U-07 未决项封版 | 2026-04-15 | 架构师代决 |
| T-TG-001 | TraceGuard 7 问封版（ADR-004） | 2026-04-15 | 架构师 |
| T-P0-001 | Monorepo 骨架落地 | 2026-04-15 | DevOps | Phase 0 |

## 已规划（待签收后创建任务卡）

### Phase 0 — 地基
- ~~T-P0-001 Monorepo 骨架（DevOps + 后端）~~ ✅ done
- T-P0-002 DB Schema 落地（后端）
- T-P0-003 GraphQL schema 骨架（后端）
- T-P0-004 历史专家字典初稿（历史专家）
- T-P0-005 LLM Gateway + TraceGuard 集成（管线）
- T-P0-005a SigNoz 版本对齐与接入（DevOps + 管线）← 从 T-P0-001 拆出
- T-P0-006 Pipeline MVP：鸿门宴 NER（管线）
- T-P0-007 API MVP：person query（后端）
- T-P0-008 Web MVP：人物卡片页（前端 + 设计师）
- T-P0-009 Docker Compose 一键启动验证（DevOps）
- T-P0-010 端到端验收（QA）

### 质检 / 监控（横向，穿插各 Phase）
- T-QC-001 PG 约束与触发器
- T-QC-002 质检规则引擎脚手架
- T-QC-003 黄金集初始化
- T-AN-001 事件字典 + useAnalytics hook
- T-AN-002 analytics_events 表 + receiver
- T-AN-003 feedback 表 + QA 看板骨架
- T-OB-001 OpenTelemetry 接入
- T-OB-002 Sentry 接入

---

## 已阻塞 / 取消

（暂无）
