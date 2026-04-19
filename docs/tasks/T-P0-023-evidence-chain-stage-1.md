# T-P0-023: Evidence 链 Stage 1 实装（新行必填 + 段落粒度）

- **状态**：✅ done 2026-04-19
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

- [x] `load.py._insert_person_names()` 先 INSERT source_evidences 行，再用返回 UUID 填 person_names.source_evidence_id
- [x] `source_evidences` 行必含：raw_text_id / book_id / provenance_tier='ai_inferred' / prompt_version / llm_call_id
- [x] `ExtractedPerson` 新增 `llm_call_id` 字段；extract→load 链透传（LLMResponse.call_id → ExtractedPerson → MergedPerson.llm_call_ids）
- [x] `provenance_tier` 枚举扩展 `seed_dictionary` 值（migration 0008 + Drizzle + Python StrEnum 三路同步）
- [x] 字典加载器推迟至 T-P0-025（本 sprint 仅扩 enum 值）
- [x] 新增 V7 invariant 测试（`tests/test_merge_invariant.py`），初始警告级（不 fail build）
- [x] 改动走 4 闸门协议（pg_dump 锚点 md5=d2258466 / 7e911b37 + schema 确认 + 缓存/进程检查 + 代码读确认）
- [x] 不回填存量（Stage 2 范畴）

## 关联

- 前置：无
- 阻塞：α 第一本书 ingest（T-P0-006 α route）
- 后续：T-P0-024（Stage 2 回填）/ T-P0-025（字典加载器）

## 实施摘要（2026-04-19）

- Sprint 拆分：Stage 1a/1b/1c/1d/1e/2/3，7 个 commit
- Commits:
  - af1e858 feat(pipeline): add LLMResponse.call_id for evidence chain traceability
  - 61a23e4 feat(pipeline): propagate llm_call_id to ExtractedPerson
  - ed2d04f refactor(pipeline): introduce ProvenanceTier enum to replace literal strings
  - 14c1d68 feat(schema): extend provenance_tier enum with seed_dictionary
  - 2271bb0 feat(pipeline): activate source_evidences write path (ADR-015 Stage 1)
  - ecf1068 test(pipeline): add V7 warning-level invariant for evidence chain coverage
  - (Stage 3 本 docs commit)
- 新增测试 10 个：4 merge_persons 单测 / 2 enum 守卫 / 3 DB evidence 集成 / 1 V7 warning 级
- 全 suite：pipeline 279 passed（Stage 0 基线 269 + 10）
- Migration：0008_t-p0-023-seed-dictionary-enum.sql（forward-only）
- 4 闸门协议全程遵守（pg_dump 锚点 md5=d2258466... + 7e911b37...）
- 关键决策记入 ADR-015 §9 Implementation Notes
- 已登记验证盲点：smoke ingest 未跑（见 STATUS "已知验证盲点" + T-P1-006 backlog）
