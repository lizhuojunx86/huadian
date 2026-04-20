# T-P2-002: fail-loud incident standardization + alert routing

## 元信息

- **优先级**: P2
- **主导角色**: chief-architect
- **协作角色**: pipeline-engineer (implementation), devops-engineer (alert routing)
- **触发来源**: T-P0-024 α Sprint review — fail-loud 机制已实现但缺乏标准化响应预案
- **预估工作量**: M

## 背景

T-P0-024 α 引入了 AmbiguousNameError fail-loud 机制（三态名回退 ≥2 match 时触发）。本 Sprint 中 0 次触发，但随着更多书籍摄入，歧义概率上升。当前 fail-loud 仅 log + skip + 计入 no_match，没有：

1. 标准化 incident log 格式（谁 / 什么时间 / 影响范围 / 建议处理）
2. 告警路由（fail-loud 触发 → 通知架构师 / historian）
3. 响应 SOP（收到告警后的分诊流程 + 升级路径）

## 验收标准

- [ ] fail-loud 事件标准化 JSON schema（含 event_type, severity, candidates, suggested_action）
- [ ] 告警路由定义（fail-loud → Slack/email 或 pipeline dashboard 红灯）
- [ ] 响应 SOP 文档（分诊 → historian 裁决 → apply_merges 或 AMBIGUOUS_SLUGS 更新）
- [ ] backfill_evidence.py 适配新 schema
