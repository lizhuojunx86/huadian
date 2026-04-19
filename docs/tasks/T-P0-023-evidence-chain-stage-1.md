# T-P0-023: Evidence 链 Stage 1 实装（新行必填 + 段落粒度）

- **状态**：planned
- **主导角色**：管线工程师
- **协作角色**：后端工程师（`seed_dictionary` 枚举 + Drizzle schema）、QA（V5 invariant）
- **所属 Phase**：Phase 0
- **关联 ADR**：ADR-015 §2.2 / §2.5 / §2.6
- **创建日期**：2026-04-19

## 背景

ADR-015 Stage 1 —— 新行必填段落级 evidence，激活 source_evidences 子系统。详见 ADR-015 §2.2。

前置事实（调研 memo）：
- `source_evidences` 表 0 行（首次激活）
- `MergedPerson.chunk_ids` / `paragraph_nos` 已携带段落定位（只需写入）
- `llm_call_id` 当前未在 extract→load 链透传，需改
- 枚举当前已有 5 值（primary_text / scholarly_consensus / ai_inferred / crowdsourced / unverified），本任务新增第 6 值 `seed_dictionary`

## 验收标准

- `load.py._insert_person_names()` 先 INSERT source_evidences 行，再用返回 UUID 填 person_names.source_evidence_id
- `source_evidences` 行必含：raw_text_id / book_id / provenance_tier='primary_text' / prompt_version / llm_call_id
- `ExtractionResult` 新增 `llm_call_id` 字段；extract→load 链透传
- `provenance_tier` 枚举扩展 `seed_dictionary` 值（Drizzle schema + migration）
- 字典合成 person_names 的 persons.provenance_tier='seed_dictionary'；source_evidence_id 保持 NULL
- 新增 V5 invariant 测试（`tests/test_merge_invariant.py`），初始警告级（不 fail build）
- 改动走 4 闸门协议（pg_dump / schema / cache / dry-run RETURNING）
- 不回填存量（Stage 2 范畴）

## 关联

- 前置：无
- 阻塞：α 第一本书 ingest（T-P0-006 α route）
- 后续：T-P0-024（Stage 2 回填）
