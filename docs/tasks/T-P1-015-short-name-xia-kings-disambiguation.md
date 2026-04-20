# T-P1-015: Short-name 夏 kings disambiguation (7 uncovered)

## 元信息

- **优先级**: P2
- **主导角色**: pipeline-engineer
- **协作角色**: historian (naming convention ruling)
- **触发来源**: T-P0-024 α C2 xia §33 — 7 no_match (予/槐/芒/泄/不降/扃/廑)
- **预估工作量**: S

## 背景

xia-ben-ji §33 is a dense succession paragraph: "帝相崩，子帝少康立。帝少康崩，子帝予立。帝予崩，子帝槐立..." NER v1-r4 extracts these kings with bare names (予, 槐, 芒...) but DB stores them with 帝X prefix (帝予, 帝槐, 帝芒...) as name_zh. Slug lookup fails because generate_slug("予") ≠ generate_slug("帝予"). Name-fallback also fails because person_names only has the 帝X form, not bare X.

## 验收标准

- [ ] Add bare-name aliases (予, 槐, 芒, 泄, 不降, 扃, 廑) to person_names for these 7 kings
- [ ] Re-run backfill → 7 names get evidence
- [ ] V7 improves by ~1.3pp (7/524)
- [ ] 附属：形成《短名 disambiguation 规则》文档（slug-first + 显式 disambiguation 规则文档化），沉淀本 Sprint 方法论，避免散佚
