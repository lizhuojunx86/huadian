# T-P1-007: u6853-u516c 桓公 person 拆分

## 元信息

- **优先级**: P1
- **主导角色**: pipeline-engineer
- **协作角色**: historian（裁决§43/§64 归属）
- **触发来源**: T-P0-006 α sprint Stage 3b Group 14
- **预估工作量**: M
- **依赖**: none

## 背景

T-P0-006 α 周本纪 ingest 中，NER 将两段不同语境的"桓公"合为同一 person 实体 u6853-u516c：
- §43「鲁杀隐公，立桓公」= 鲁桓公（鲁国第十五代君，前711-前694在位）
- §64「考王封其弟于河南，是为桓公」= 西周桓公（考王弟，河南封君，前440-?在位）

二者相隔约三百年，绝非同一人。Stage 3b historian 裁决 REJECTED 合并，但 person 本身的"两人合体"状态保留未修。

## 验收标准

- [ ] u6853-u516c 拆分为两个独立 person：鲁桓公 + 西周桓公
- [ ] §43 的 source_evidences / person_names FK 重挂到鲁桓公 person
- [ ] §64 的 source_evidences / person_names FK 重挂到西周桓公 person
- [ ] 两个新 person 各有正确的 dynasty / slug / name
- [ ] V1-V7 全绿（特别是 V1 单主名、V4 model-B leakage）
- [ ] person_merge_log 无残留指向 u6853-u516c 的 merge 记录

## 非范围

- NER prompt 层面的同名异人识别改进 → T-P1-009
- Resolver R2 dynasty 预过滤 → T-P1-010

## 相关文档

- docs/sprint-logs/T-P0-006-alpha/stage-3b-historian-package.md (Group 14)
- docs/sprint-logs/T-P0-006-alpha/stage-5-sprint-summary.md
