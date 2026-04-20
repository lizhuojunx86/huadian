# T-P1-020: Extract name→person resolution into shared module

## 元信息

- **优先级**: P3
- **主导角色**: pipeline-engineer
- **触发来源**: T-P0-024 α code review — name resolution logic duplicated in 3 places
- **预估工作量**: M

## 背景

Person matching logic (slug generation → slug lookup → name fallback → ambiguity check) currently exists in:
1. `load.py` _upsert_person() — slug-only, creates if not found
2. `backfill_evidence.py` _resolve_person() — slug + name fallback + fail-loud
3. `resolve.py` identity resolution — surface_form matching

Extracting a shared `resolve_person(name_zh, *, create=False)` function would reduce duplication and ensure consistent matching behavior across all pipeline entry points.

## 验收标准

- [ ] Shared function in `huadian_pipeline/resolve_name.py` or similar
- [ ] load.py, backfill_evidence.py, resolve.py all use shared function
- [ ] Tests covering slug-first, name-fallback, ambiguity cases
