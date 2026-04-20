# T-P1-018: Backfill auto-trigger in production pipeline

## 元信息

- **优先级**: P3
- **主导角色**: pipeline-engineer
- **协作角色**: devops-engineer (automation)
- **触发来源**: T-P0-024 α Sprint summary — manual backfill is labor-intensive
- **预估工作量**: M

## 背景

Current workflow: after each NER extract + load run, evidence backfill must be triggered manually via `backfill_evidence.py`. In production, incremental ingestion of new chapters should automatically backfill evidence for any new llm_calls.

## 验收标准

- [ ] Post-ingest hook or Prefect task that runs backfill for newly ingested book
- [ ] Idempotent (safe to re-run)
- [ ] Logs to pipeline audit trail
