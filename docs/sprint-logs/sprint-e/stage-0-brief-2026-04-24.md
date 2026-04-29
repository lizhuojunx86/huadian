# Sprint E Brief — T-P0-030 + Phase 1 推进

## 0. 元信息

- **架构师**: Chief Architect
- **Brief 日期**: 2026-04-24
- **Sprint 形态**: 双 track（小 + 大）
  - Track A：T-P0-030 corrective seed-add（半天，热身）
  - Track B：Phase 1 真书推进（主线，待 inventory 后定章节）
- **预估工时**: A ≈ 0.5 天 / B 待定（典型真书一章 1-2 天）

## 1. 背景

Sprint C/D 连续两个 Sprint 都在做 Phase 0 tail 修补（resolver orchestration + R6 cross-dynasty guard）。基础设施层稳健（V1-V11 全绿，pending_merge_reviews bootstrap，dynasty guard 22 tests），但内容产出节奏停滞。

Sprint E 目标：清掉单点债务（T-P0-030 wei-zi-qi → Q855012）热身，然后切回 Phase 1 真书内容推进，恢复"内容产出 → 数据消化 → 修补"的正向循环。

> 架构原则：Phase 0 tail 不能无限修补。每个新 sprint 必须问"是否真的阻塞 Phase 1"。T-P0-030 是有明确 historian ruling 的单点修复，可以做；T-P0-028 triage UI 工作量大且无 P0 阻塞，不进 Sprint E。

## 2. Track A — T-P0-030（短）

参考 `docs/tasks/T-P0-030-corrective-seed-add-weizi-qi.md` stub。

### 执行约束（架构师追加）

1. **dictionary_entries 检查优先**：先 SELECT 看 Q855012 是否已存在（Sprint B matcher 跑 zhou+yin 时可能命中过）。如已存在，复用，不重建。
2. **mapping_method 字段值**：用 `'historian_correction'`（新值，未来同类修复复用），不要复用 `'wikidata_match'` 等 Sprint B 通道值——审计可区分性
3. **source_evidence tier**：`'seed_dictionary'`，与 Sprint B 同
4. **不动原 Q186544 mapping**：保持 `pending_review` 状态（属 T-P0-028 范畴）
5. **写入需在事务内**：dictionary_entry（如新建）+ seed_mapping + source_evidence 三步同事务
6. **V10 + V11 跑后验证**：active seed_mappings 158 → 159，pending_merge_reviews 不变（应仍 0）

### Track A 收口产出
- Migration 不需要（纯数据 INSERT，无 schema 变更）
- 1 个 commit：`feat(pipeline): T-P0-030 corrective seed-add wei-zi-qi → Q855012`
- 跑前后做 audit log 截图（commit body 附 SQL SELECT 结果）

## 3. Track B — Phase 1 真书推进（待 inventory 后定）

### 3.1 PE inventory 任务

输出 `docs/sprint-logs/sprint-e/phase1-inventory-2026-04-XX.md`，覆盖 5 项：

1. **真书完成度盘点**：
   - 史记：哪些篇已 ingest（pilot + α 周本纪 + ?）
   - 尚书：哪些篇已 ingest（β 尧典+舜典 + ?）
   - 其他书目：状态
2. **下一章节候选**（至少 3 个，优先级排序）：
   - 候选 X：书 + 章 + 估计篇幅 + 估计成本（参考历史 LLM cost 数据）
   - 各候选的"为什么是它"（历史价值 / 验证特定管线能力 / 字典覆盖率 / 字典缺口）
3. **管线就绪度**：
   - 当前 prompt 版本 / NER 三态名 / evidence 链 Stage 1 / R6 prepass guard 全部已就绪？
   - 是否有未消化的 Phase 0 tail debt 会阻塞？
4. **Historian 字典准备**：
   - 候选章节涉及的人物 / 地点 / 政权字典覆盖率
   - 是否需要 historian 字典批次扩充作为前置（如需，开 follow-up 卡）
5. **PE 推荐 + 理由**

### 3.2 架构师签字（PE inventory 后）

- 选定章节 + 锁定 sprint scope
- 确认是否需要 historian 字典前置
- 给定具体 stage 划分（参考 T-P0-006-α 的 5 stage 模板）

### 3.3 Track B 执行（架构师签字后）

按选定章节走 standard pipeline pilot 流程：
- Stage 1: smoke（5 段验证）
- Stage 2: 全章 ingest
- Stage 3: identity resolver dry-run + historian 审核
- Stage 4: apply_merges
- Stage 5: 收档

> 不在本 brief 详细展开 stage——按 T-P0-006-α 经验复用即可。

## 4. Stop Rules

1. **Track A V10/V11 回归** → 立即 Stop。回滚事务，报架构师
2. **Track A 发现 Q855012 在 Wikidata 上 label/description 与 historian 描述不一致** → Stop。可能 Wikidata 数据已变（自 historian 查询 2026-04-22 至今 2 天），需 historian 二次确认
3. **Track B inventory 发现 Phase 1 推进有未消化 Phase 0 阻塞** → Stop。报架构师重新评估 Sprint E scope（可能要回到 Phase 0 tail）
4. **Track B 推荐章节 historian 字典覆盖率 < 50%** → Stop。先开字典扩充 follow-up 卡，本 sprint scope 调整或缩小

## 5. 角色边界

- **管线工程师**：Track A 全部 + Track B inventory + 执行
- **架构师**：本 brief + Track B 章节签字 + Stop Rule 触发时裁决
- **Historian**：Track A 不需介入；Track B 字典预审 + 章节 ingest 后审核 merge proposals
- **后端工程师**：不参与（无 schema 变更）

## 6. Sprint E 收口判定

- ✅ Track A：active seed_mappings 158 → 159，wei-zi-qi → Q855012 active
- ✅ Track B：选定章节完整 ingest + identity resolve apply
- ✅ V1-V11 全绿（V1 仍 30 是允许存量）
- ✅ Phase 1 内容产出节奏恢复（CHANGELOG 出现真书章节 entry）
- ✅ 衍生债务卡有序登记（不积压）

## 7. 节奏建议

第一会话：PE 完成 Track A + Track B inventory，挂起等架构师章节签字
第二会话：架构师签字 → PE 执行 Track B 全部 5 stages
第三会话（可选）：收口 + retro

不要把 Track A + Track B inventory + Track B 执行 全塞一个会话——历史经验 PE 大会话末尾质量下降。
