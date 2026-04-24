# T-P0-030 — Corrective Seed-Add: wei-zi-qi → Q855012

- **状态**: **done**（Sprint E Track A, 2026-04-24）
- **优先级**: P2 低（不阻塞 Phase 1；wei-zi-qi 已有 AI_INFERRED 数据，仅缺 seed anchor）
- **主导角色**: 管线工程师
- **所属 Phase**: Phase 0 tail
- **依赖**: T-P0-027 ✅（Stage 5 路径 A 降级 wei-zi-qi→Q186544）
- **创建日期**: 2026-04-24
- **触发事件**: historian 判定卡 ruling 98de7bc 确认微子启正确 QID = Q855012

## 1. 背景

Sprint C Stage 5（T-P0-027 路径 A）将 wei-zi-qi 的误判 seed_mapping（→Q186544 夏启）降级为 pending_review。Historian 确认微子启的正确 Wikidata QID 为 **Q855012**（label "微子"，description "商朝宗室，宋国始祖"）。

本卡为修正性操作：创建新 seed_mapping 将 wei-zi-qi 指向 Q855012，状态设为 active。

## 2. 执行记录

1. ✅ A0: Wikidata SPARQL 实时复核 Q855012 — label=微子, description=商朝宗室宋国始祖 — 与 ruling 一致
2. ✅ A1-A3: 4 闸门（pg_dump / schema / artifact）
3. ✅ A4: Q855012 不在 dictionary_entries → 需新建
4. ✅ A5: dry-run（BEGIN + INSERT RETURNING + ROLLBACK）用户 ACK
5. ✅ A7: COMMIT — 三步同事务：
   - `dictionary_entries`: Q855012 (person, primary_name=微子, correction_source=historian_ruling_98de7bc)
   - `seed_mappings`: wei-zi-qi → Q855012, confidence=1.00, mapping_method='historian_correction', status='active'
   - `source_evidences`: provenance_tier='seed_dictionary', quoted_text='wikidata:Q855012→wei-zi-qi'
6. ✅ V10(0/0/0) + V11(0) 全绿
7. ✅ Active seed_mappings: 158 → 159

## 3. 不在本卡范围

- 原误判 mapping（Q186544）的 rejected 状态迁移（留给 T-P0-028 triage UI）
- R6 cross-dynasty guard 实现（→ T-P0-029）
