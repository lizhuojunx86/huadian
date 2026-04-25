# T-P1-028 — R1 Dynasty 前置过滤（减少跨国 FP）

## 元信息

| 字段 | 值 |
|------|-----|
| ID | T-P1-028 |
| 优先级 | P1 |
| 状态 | registered |
| 主导角色 | 管线工程师 + 首席架构师 |
| 创建日期 | 2026-04-26 |
| 触发 | T-P0-006-δ historian review §4.4（commit fdfb7cb）|
| 数据 | 21 组 proposals → 13 reject（62%），其中 12 组为秦γ 已裁决残留 |

## 背景

在 T-P0-006-γ（秦本纪）和 T-P0-006-δ（项羽本纪）中，R1 surface form match 规则产生了大量跨国同谥号 false positive：
- 桓公/灵公/惠公/庄公/简公/悼公/平公 等谥号在多个诸侯国同时存在
- 这些 FP 在每次全量 resolver 扫描时重复出现（秦γ 已裁决的 reject 在 δ 中再次出现）

historian §4.4 建议评估在 R1 中引入 dynasty 前置过滤：类似 R6 的 cross-dynasty guard（ADR-010 + T-P0-029），通过 dynasty field 在 name surface match 之前过滤掉不同 dynasty 的 person 对。

## 影响分析

- **优先级高**：每次新章节 ingest 后的全量 resolver 扫描都会重复触发同类 FP，直接增加 historian 审核工作量
- **需 ADR**：R1 是核心 identity resolution 规则（ADR-010 §R1），任何修改须 ADR 审批
- **风险**：dynasty 字段数据质量（部分 persons.dynasty 为 NULL 或粒度较粗）需评估；dynasty 前置过滤可能误过滤合法的跨时段短称合并

## 实施方案候选

| 方案 | 说明 | 风险 |
|------|------|------|
| A | 同 dynasty 才能触发 R1 | 过于严格，同时段不同 dynasty 标注的人可能误过滤 |
| B | dynasty 距离阈值（类 R6 guard） | 保持 R6 成功模式，但 R1 场景比 R6 复杂 |
| C | 跨国谥号黑名单（桓/灵/惠/庄/简/悼/平/成/康/宣等） | 轻量，不影响非谥号合并，但需维护黑名单 |

**architect 推荐**：先评估方案 C（谥号黑名单），如效果不够再考虑方案 B。

## 依赖

- ADR-010 review + addendum（需首席架构师参与）
- dynasty-periods.yaml 已有（T-P0-029 建设，方案 B 可复用）

## 验收条件

- [ ] ADR-010 addendum 记录 R1 dynasty filter 决策
- [ ] 实施选定方案后，全量 resolver 扫描对已知 reject 组不再产生 proposals
- [ ] 现有所有合法 approve 案例回归通过
