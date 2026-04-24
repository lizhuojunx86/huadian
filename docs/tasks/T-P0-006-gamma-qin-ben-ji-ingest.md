# T-P0-006-γ — 史记·秦本纪 Ingest

- **状态**: in_progress（Sprint E Track B）
- **优先级**: P0
- **主导角色**: 管线工程师
- **所属 Phase**: Phase 0（内容产出回归）
- **依赖**: T-P0-006-α ✅（周本纪）/ T-P0-006-β ✅（尚书）
- **创建日期**: 2026-04-24
- **架构师签字**: Sprint E brief §签字 1/2

## 1. 背景

Sprint C/D 连续两个 Sprint 做 Phase 0 tail 修补，内容产出停滞。Sprint E Track B 恢复内容推进，选定秦本纪（卷五）为下一章节——自然序列续接、秦 dynasty 最大空白填补、大篇幅压力测试。

## 2. 章节信息

- **书**: 史记（Records of the Grand Historian）
- **章**: 秦本纪（Basic Annals of the Qin Dynasty）
- **卷**: 卷五
- **段落数**: 72
- **字数**: ~10,431
- **覆盖时段**: 秦先祖（颛顼后裔）→ 秦庄襄王（秦始皇之前）

## 3. 架构师 Mitigation（强制）

- **Mit 1**: Stage 0 字典扩充 — tier-s-slugs ≥20 行 + disambig ≥10 组
- **Mit 2**: 成本上限 — Stage 1 ≤$0.10 / Stage 2 ≤$2.50
- **Mit 3**: NER 输出量上限 — >100 new persons → Stop / >150 → 强制 split
- **Mit 4**: R6 guard 必须 active — guard 拦截 >5 → Stop

## 4. Stages

- [ ] Stage 0: 前置准备（fixture + adapter + tier-s + disambig + baseline）
- [ ] Stage 1: Smoke 5 段
- [ ] Stage 2: Full Ingest ~72 段
- [ ] Stage 3: Resolver Dry-Run + historian 审核
- [ ] Stage 4: Apply Merges
- [ ] Stage 5: 收档

## 5. Pre-flight Baseline（2026-04-24）

| Metric | Value |
|--------|-------|
| active persons | 319 |
| person_names | 517 |
| source_evidences | 572 |
| active seeds | 159 |
| V1 | 27 (存量) |
| V7 | 97.49% |
| V10 | 0/0/0 |
| V11 | 0 |
