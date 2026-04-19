# T-P0-024: Evidence 链 Stage 2 存量回填（text-search + provenance 降级）

- **状态**：planned
- **主导角色**：管线工程师
- **协作角色**：historian（单字 surface 抽查）、QA（V5 强制化）
- **所属 Phase**：Phase 0
- **关联 ADR**：ADR-015 §2.3 / §2.5
- **创建日期**：2026-04-19

## 背景

ADR-015 Stage 2 —— 存量 282 行（+ Stage 1 前新增）text-search 回填。详见 ADR-015 §2.3。

关键事实：
- 243/245 active surfaces 可 LIKE 反查回填
- 2 个字典合成（司马迁 / 周成王）保持 NULL
- 回填 provenance_tier='ai_inferred'（不得用 primary_text）
- β 3 行重建（3e4f389a）走 text-search，精度有限

## 验收标准

- 脚本 `scripts/backfill_evidence_stage2.py` 按 `(name, book_id)` 双键 text-search
- 每命中行写入 source_evidences（provenance_tier='ai_inferred'）并填 person_names.source_evidence_id
- 单字 surface（如"弃"）的匹配结果由 historian 抽查签收（至少 sample 10 条）
- Soft-deleted persons 的 33 行同样回填
- 字典合成身份保持 NULL，输出审计报告列明哪些 surface 未能回填及原因
- V5 invariant 从警告级升级为强制级（fail build if NULL found on non-seed_dictionary active persons）
- 改动走 4 闸门协议
- 不启用 evidence_links（Stage 3 范畴）

## 关联

- 前置：T-P0-023 完成
- 阻塞：无（不阻塞 α 第一本书 ingest，但建议 α 第一本书结束前完成）
- 后续：ADR-020+（Stage 3 span 粒度 + replay 提纯）
