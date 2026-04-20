# T-P1-011: Merged-alias evidence backfill (弃→后稷, 垂→倕)

## 元信息

- **优先级**: P2
- **主导角色**: pipeline-engineer
- **触发来源**: T-P0-024 α C1 no_match (弃×2, 垂×1) + C2 no_match (垂×2)
- **预估工作量**: S

## 背景

When a person was merged (e.g., 弃 merged into 后稷 via identity resolver), the merged person's slug becomes inactive. NER re-extraction outputs name_zh="弃" → slug lookup finds only the deleted person → no_match. The name-fallback successfully resolves 弃→后稷, but 垂→倕 fails because 垂 was soft-deleted and its slug points to no active person_names.

## 验收标准

- [ ] 垂/倕 的 person_names 中"垂" alias 能被 backfill 脚本匹配到
- [ ] 全部 merged-alias 的 evidence 链补齐
- [ ] no_match 中 merged-alias 类降为 0
