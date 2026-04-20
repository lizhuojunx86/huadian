# T-P1-008: Union-Find 簇验证（跨朝代污染防护）

## 元信息

- **优先级**: P1
- **主导角色**: pipeline-engineer
- **协作角色**: chief-architect（簇验证规则设计审查）
- **触发来源**: T-P0-006 α sprint Stage 3a Group 3（文王/武王跨族桥接实证）
- **预估工作量**: M
- **依赖**: none

## 背景

T-P0-006 α 的 identity resolver 将文王（姬昌）和武王（姬发）合入同一 Union-Find 组，根因是 NER 产出的"文武"合称 surface 同时挂在两个独立 person 上，R1 surface_form 匹配产生了一条跨族"污染边"，Union-Find 传递闭包将两族合并。

当前 resolver 在 Union-Find 之后无簇合法性验证——任何单条错误边都会无声扩大合并范围。

## 验收标准

- [ ] resolve.py 在 Union-Find 构建完成后增加簇验证步骤
- [ ] 簇内 dynasty 一致性检查：同簇成员 dynasty 严重不一致时降级为 hypothesis（不自动合并）
- [ ] 簇大小告警：簇成员数 ≥ 4 时 emit warning（人工审查提示）
- [ ] 不修改 R1-R5 匹配规则本身（只加后置过滤）
- [ ] 现有 resolve 测试不回归
- [ ] 新增 ≥ 3 条测试覆盖：跨朝代拆分、大簇告警、正常簇不受影响

## 非范围

- R1-R5 规则权重调整
- NER prompt 层面合称识别 → T-P1-009
- R2 dynasty 预过滤 → T-P1-010（与本 task 互补但独立）

## 相关文档

- ADR-010 (cross-chunk identity resolution)
- docs/sprint-logs/T-P0-006-alpha/stage-3a-resolve.md (Group 3 分析)
- docs/sprint-logs/T-P0-006-alpha/stage-5-sprint-summary.md
