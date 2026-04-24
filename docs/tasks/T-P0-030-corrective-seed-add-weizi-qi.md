# T-P0-030 — Corrective Seed-Add: wei-zi-qi → Q855012

- **状态**: planned（Sprint D 候选）
- **优先级**: P2 低（不阻塞 Phase 1；wei-zi-qi 已有 AI_INFERRED 数据，仅缺 seed anchor）
- **主导角色**: 管线工程师
- **所属 Phase**: Phase 0 tail
- **依赖**: T-P0-027 ✅（Stage 5 路径 A 降级 wei-zi-qi→Q186544）
- **创建日期**: 2026-04-24
- **触发事件**: historian 判定卡 ruling 98de7bc 确认微子启正确 QID = Q855012

## 1. 背景

Sprint C Stage 5（T-P0-027 路径 A）将 wei-zi-qi 的误判 seed_mapping（→Q186544 夏启）降级为 pending_review。Historian 确认微子启的正确 Wikidata QID 为 **Q855012**（label "微子"，description "商朝宗室，宋国始祖"）。

本卡为修正性操作：创建新 seed_mapping 将 wei-zi-qi 指向 Q855012，状态设为 active。

## 2. 执行步骤（占位）

1. 确认 dictionary_entries 中 Q855012 是否已存在（Sprint B matcher 可能已创建 entry）
2. 如不存在：INSERT dictionary_entry for Q855012
3. INSERT seed_mapping (wei-zi-qi → Q855012, confidence=1.0, mapping_method='historian_correction', status='active')
4. INSERT source_evidence (seed_dictionary tier)
5. V10 + V11 验证

## 3. 不在本卡范围

- 原误判 mapping（Q186544）的 rejected 状态迁移（留给 T-P0-028 triage UI）
- R6 cross-dynasty guard 实现（→ T-P0-029）
