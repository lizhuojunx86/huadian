# T-P1-017: ADR-015 Stage 1 SE multi-source extension

## 元信息

- **优先级**: P3
- **主导角色**: chief-architect
- **协作角色**: backend-engineer (schema), pipeline-engineer (implementation)
- **触发来源**: T-P0-024 α design observation — person_names.source_evidence_id is single FK
- **预估工作量**: L

## 背景

Current schema: person_names.source_evidence_id is a single UUID FK → one name can reference only one source_evidence. When the same name appears in multiple paragraphs/books, only the first-write-wins SE is recorded. This is a known simplification from ADR-015 Stage 1.

A more complete model would support N:M (a name can have multiple evidence sources from different paragraphs/books). This requires either a junction table or array column.

## 验收标准

- [ ] Architecture decision: keep 1:1 or move to N:M
- [ ] If N:M: schema migration + backfill script update
- [ ] V7 metric definition updated if model changes
