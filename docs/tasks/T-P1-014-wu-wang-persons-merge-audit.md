# T-P1-014: wu-wang / zhou-wu-wang / tang persons merge audit

## 元信息

- **优先级**: P2
- **主导角色**: historian
- **协作角色**: pipeline-engineer (execution)
- **触发来源**: T-P0-024 α Stage 2b Step 1 ambiguity pre-check
- **预估工作量**: M

## 背景

Ambiguity pre-check found "武王" shared by 3 active persons: tang (商汤, posthumous name), u5468-u6b66-u738b (周武王), wu-wang (武王). Also "发" shared by u5468-u6b66-u738b and wu-wang. This suggests wu-wang may be a redundant person that should be merged into u5468-u6b66-u738b (周武王).

Historian must determine:
1. Is wu-wang = 周武王? If yes → merge
2. Is tang's "武王" posthumous name correctly assigned? (商汤's posthumous is historically debated)
3. Is the current 3-way ambiguity safe or needs resolution?

## 验收标准

- [ ] Historian ruling on wu-wang identity
- [ ] If merge needed: apply via ADR-014 apply_merges()
- [ ] AMBIGUOUS_SLUGS constant updated to reflect resolved state
