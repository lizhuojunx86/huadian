# data/

**Owner**: Historian (历史专家 / `@historian` role)

This directory holds curated reference data that feeds the pipeline and QC system.

## Structure

```
data/
├── golden/          # Gold-standard JSONL for QC regression testing
├── dictionaries/    # polities, reign_eras, disambiguation_seeds (YAML/JSONL)
└── README.md
```

## Rules

- All files in this directory are **version-controlled** (committed to git).
- **Single file > 10 MB** triggers a Git LFS evaluation — file a new ADR before merging.
- **Git LFS is NOT enabled** in Phase 0. If you hit the 10 MB threshold, talk to DevOps first.
- Only the **historian role** may add or modify files here. Other roles may read.
- Raw/unprocessed data goes to `data/raw/` (gitignored) — NOT here.
