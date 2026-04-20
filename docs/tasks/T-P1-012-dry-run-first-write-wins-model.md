# T-P1-012: Dry-run prediction model — first-write-wins simulation

## 元信息

- **优先级**: P3
- **主导角色**: pipeline-engineer
- **触发来源**: T-P0-024 α C1 (44→30, 68%) + C2 (340→200, 59%) dry-run over-prediction
- **预估工作量**: S

## 背景

backfill_evidence.py dry-run mode does not execute writes, so `find_uncovered_names()` returns the same uncovered names for every paragraph a person appears in. Real execution covers names on first-write, subsequent paragraphs see them as already covered → skip. This causes systematic positive bias in V7 projection (C1: +2.67pp, C2: dry-run showed >100%).

## 验收标准

- [ ] Dry-run maintains in-memory set of "already linked (person_id, name)" pairs
- [ ] Projection accuracy within ±3pp of actual execute result
- [ ] Disclaimer updated or removed once model is accurate
