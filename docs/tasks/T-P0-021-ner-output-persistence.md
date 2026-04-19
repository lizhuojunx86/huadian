# T-P0-021: NER 输出持久化（JSONL 落盘 + replay 支持）

- **状态**：planned
- **主导角色**：管线工程师
- **协作角色**：QA（replay 回归验证）
- **所属 Phase**：Phase 0
- **关联 debt**：F9（`docs/debts/T-P0-006-beta-followups.md`）
- **创建日期**：2026-04-19

## 背景

T-P0-006-β followup F9：`extract_persons()` 只返回内存对象，不落盘。导致以下问题：

1. 无法 replay `load.py`（β 弃的重建只能退到"纯文本 INSERT 硬造"，丢失 evidence 链关联可能）
2. 无法离线 A/B prompt 迭代（每次 prompt 变更必须重跑 LLM）
3. 无法为 historian 提供黄金集对比样本

建议：extract 完成后 dump JSONL 到 `services/pipeline/outputs/ner/{run_id}.jsonl`。

参见 `docs/debts/T-P0-006-beta-followups.md` F9 条目。

## 验收标准

- `extract_persons()` 完成后自动 dump JSONL 到 `services/pipeline/outputs/ner/{run_id}.jsonl`
- JSONL 格式包含：段落 ID、原文片段、抽取的 person 列表（含 surface_forms / name_type / identity_notes）
- `load.py` 新增 `--from-cache` 模式，可从 JSONL 重放而不调 LLM
- `.gitignore` 排除 `services/pipeline/outputs/`（不入库）
- 至少 3 条测试覆盖 dump + replay 路径
- 文档更新：pipeline-engineer.md 标准任务流程中体现 JSONL 持久化步骤

## 关联

- 前置：无
- 阻塞：无（P1，不阻塞 alpha，但建议 alpha 首本 ingest 前实装）
- 相关：ADR-015（evidence 链填充方案，依赖 NER 输出可重放）
