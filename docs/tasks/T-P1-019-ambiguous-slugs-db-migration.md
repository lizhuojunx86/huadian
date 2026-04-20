# T-P1-019: AMBIGUOUS_SLUGS migration from Python constant to DB table

## 元信息

- **优先级**: P3
- **主导角色**: pipeline-engineer
- **协作角色**: qa-engineer (audit review)
- **触发来源**: T-P0-024 α — AMBIGUOUS_SLUGS hardcoded as frozenset in script
- **预估工作量**: S

## 背景

AMBIGUOUS_SLUGS is currently a Python frozenset constant in backfill_evidence.py: {qi, u5468-u6b66-u738b, wu-wang, tang, wu-ding}. As more books are ingested, new ambiguities may emerge. A DB table (or QC rule) would be more maintainable and auditable than a code constant.

## 验收标准

- [ ] Ambiguous slug registry in DB or YAML config (not Python code)
- [ ] QA engineer can review and update without code changes
- [ ] backfill_evidence.py reads from registry at runtime
