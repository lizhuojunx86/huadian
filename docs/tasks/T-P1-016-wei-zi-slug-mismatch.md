# T-P1-016: 微子 partial slug mismatch

## 元信息

- **优先级**: P2
- **主导角色**: pipeline-engineer
- **触发来源**: T-P0-024 α C2 yin §33,34 — 微子 no_match ×2
- **预估工作量**: S

## 背景

NER v1-r4 outputs name_zh="微子" for yin-ben-ji contexts. generate_slug("微子") = u5fae-u5b50. DB person is wei-zi-qi (微子启) with person_names: "启(primary)" and "微子启(alias)" — but no "微子" bare form. Name-fallback also fails since no person_name matches "微子".

## 验收标准

- [ ] Add "微子" as alias to wei-zi-qi person_names
- [ ] Re-run backfill → 2 names get evidence (or at minimum the person gets SE linkage)
- [ ] V7 improves by ~0.4pp (2/524)
