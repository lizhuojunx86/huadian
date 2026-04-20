# T-P1-013: V6 historical alias+is_primary=true cleanup (28 violations)

## 元信息

- **优先级**: P2
- **主导角色**: pipeline-engineer
- **协作角色**: backend-engineer (schema review)
- **触发来源**: T-P0-024 α Gate 4 V6 check discovered 28 pre-existing violations
- **预估工作量**: M

## 背景

28 person_names rows have name_type ∈ {nickname(22), posthumous(5), temple(1)} but is_primary=true. All have source_evidence_id=NULL (Phase A/B era, pre-T-P0-016 fix). The T-P0-016 migration fixed 18 rows of the inverse (primary+is_primary=false) but did not address this pattern.

## 验收标准

- [ ] Migration to SET is_primary=false WHERE name_type != 'primary' AND is_primary=true
- [ ] V6 violation count: 28 → 0
- [ ] No regression on V1-V5
