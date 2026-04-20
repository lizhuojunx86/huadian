# T-P1-010: Resolver R2 dynasty + reality_status 预过滤

## 元信息

- **优先级**: P2
- **主导角色**: pipeline-engineer
- **协作角色**: chief-architect（规则设计审查）
- **触发来源**: T-P0-006 α sprint Stage 3a 观察（全 R1，无低置信度候选）
- **预估工作量**: M
- **依赖**: none（与 T-P1-008 互补但独立）

## 背景

T-P0-006 α 的 identity resolver 33/33 proposals 全为 R1 surface_form 匹配，R2-R5 零命中。R1 是最宽泛的规则（只看 surface 文字相等），缺乏 dynasty/era 上下文过滤。

ADR-010 的 R2 规则（帝X/X prefix match）要求"同书或同朝代"，但当前 R1 无此约束。引入 R2 级别的预过滤可以在 R1 命中后加一层 dynasty 一致性检查，把跨朝代误匹配（如 Group 3 的文王/武王）从自动合并降级为候选。

## 验收标准

- [ ] Pair 在 R1 命中后增加 dynasty/reality_status 一致性检查
- [ ] dynasty 严重不一致（如"商" vs "东周"）时降级为 hypothesis（confidence < 0.9）
- [ ] dynasty 轻微差异（如"西周" vs "先周"）允许通过（相邻朝代容忍）
- [ ] 不修改 R2-R5 规则本身
- [ ] 现有 resolve 测试不回归
- [ ] 新增 ≥ 3 条测试覆盖跨朝代降级

## 非范围

- Union-Find 簇验证 → T-P1-008
- NER 合称识别 → T-P1-009
- R2/R3/R5 规则权重调整

## 相关文档

- ADR-010 (cross-chunk identity resolution, §评分函数)
- docs/sprint-logs/T-P0-006-alpha/stage-3a-resolve.md
- docs/sprint-logs/T-P0-006-alpha/stage-5-sprint-summary.md
