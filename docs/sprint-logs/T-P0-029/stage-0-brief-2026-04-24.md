# T-P0-029 Stage 0 Brief — R6 Cross-Dynasty Guard

## 0. 元信息

- **架构师**: Chief Architect
- **Brief 日期**: 2026-04-24
- **针对任务卡**: `docs/tasks/T-P0-029-r6-cross-dynasty-guard.md`
- **预计 Sprint**: Sprint D 主线（独立 track）
- **预估工时**: 2-3 天（中型 sprint）
- **触发事件**: T-P0-027 Sprint C Stage 4 唯一 R6 false positive（启 ↔ 微子启 / Q186544）+ historian ruling 98de7bc

## 1. 上下文回顾

Sprint C 收口 commit 28fd0f8。R6 已接入 resolver 主调度并验证：
- 1 例 R1 真合并落地（鲁桓公 ↔ 桓公）
- 1 例 R6 false positive 被 historian 拦截（启 ↔ 微子启 跨 ~1000 年）

Historian 判定（98de7bc）锁定根因：纯 Wikidata QID 锚点对跨朝代同名人物防护不足。本卡目标 = 给 R6 加结构性 guard，把"明显跨时段同 QID"的 merge 候选拦截在 MergeProposal 生成阶段，避免再次依赖 historian 人工救火。

> 设计原则：guard 是"防御性降级"而非"判定权移交"——拦截后写入 pending_review 等待 historian triage（→ T-P0-028），不替 historian 做决策。

## 2. 目标范围

### 必做
1. 在 `_detect_r6_merges()` 内部新增 cross-dynasty / temporal guard
2. Guard 命中 → 不生成 MergeProposal，改为写入 pending_review 通道（具体存储位由 Stage 0 inventory 决定）
3. Guard 命中规则：必须覆盖 Sprint C 实例（启 ↔ 微子启），且不误伤合法 R6 merge
4. V11 invariant cardinality 保护机制保留
5. 给 T-P0-028 triage UI 留 hook：guard 命中条目可被人工 review

### 不做
- ❌ 不修改 `r6_seed_match()`（外部 lookup 路径无关）
- ❌ 不改 seed_mappings schema（除非 inventory 证明必须）
- ❌ 不做 Wikidata 全量反向 false-positive 扫描（→ Sprint D+）
- ❌ 不做 corrective seed-add（→ T-P0-030）
- ❌ 不修订 ADR-021（等本卡输出后由架构师决策）

## 3. Stages

### Stage 0 — Inventory + Design 选型

**PE 调研项（必填，6 项）**：
1. `persons.era` / `persons.dynasty` 字段是否存在？覆盖率多少？（持久化字段 vs 派生字段）
2. `events` 表中 era / time-range 字段成熟度？多少 person 通过 events JOIN 能拿到时间范围？覆盖率？
3. `dictionary_entries` / Sprint B seed loader 是否已抓 Wikidata 的 `dateOfBirth` / `period` / `floruit` 字段？
4. 当前 R6 MergeProposal 的 evidence 字段结构（看新增 guard signal 怎么挂）
5. T-P0-028 triage UI 数据源约定（pending_review 表 vs 新表？需协调）
6. 现有 R6 merge apply 历史 baseline（应只 0 条；Sprint C path A 没 apply R6）

**输出**：`docs/sprint-logs/T-P0-029/inventory-2026-04-XX.md`

### Stage 1 — Guard 实现 + 阈值标定

基于 Stage 0 inventory，从 4 候选选 1：

| 方案 | 时间源 | 阈值 trigger | 优 | 劣 |
|------|--------|--------------|---|----|
| α | `persons.era` 字段 | era 值不匹配 | 最简 | 依赖字段成熟度 |
| β | `events` JOIN time-range 距离 > N 年 | N 年 | 数据来源最广 | 需 events 数据足够 |
| γ | Wikidata `dateOfBirth`（如已抓） | 日期距离 > N 年 | 最精确 | 依赖 seed loader 是否抓了 |
| δ | α + β fallback（hybrid） | 复合规则 | 鲁棒 | 实现稍复杂 |

**架构师默认倾向**：δ（hybrid）。理由：单一数据源覆盖率不足是 Phase 0 常态，hybrid 可逐字段降级。
**最终选定**：由 Stage 0 数据观察决定，PE 给推荐 + 架构师签字。

**阈值起点**：500 年（historian 建议）。最终值由 Stage 1 数据观察决定（古代人物年代 ±100 年不确定性是常态）。

### Stage 2 — 单元测试 + dry-run 回归

- ✅ Guard **命中**场景：启 ↔ 微子启（Sprint C 案例）必须被拦截
- ✅ Guard **不命中**场景：构造同朝代同名人物（如有），确认不误伤
- ✅ V1-V11 全绿
- ✅ Dry-run 应当看到：R6 candidates 数 ≥ 实际 R6 MergeProposal 数（差额 = guard 拦截数）
- ✅ 拦截条目结构与 T-P0-028 triage UI 的 pending_review 数据源约定一致

### Stage 3 — Apply + 收口

- Guard 命中条目按 Stage 0 决定的存储位写入
- 已存在的 wei-zi-qi → Q186544 pending_review 记录是否需要补 guard 标记？由 Stage 0 决定（建议补 reason="cross-dynasty-guard-retroactive" 以便审计）
- CHANGELOG / STATUS / retro 收档
- 触发 ADR-021 修订决策（架构师本侧）

## 4. Stop Rules（强制）

1. **Stage 0 三源全失**：如果 `persons.era` 字段不存在 + `events.time-range` 覆盖率 < 30% + Wikidata `dateOfBirth` 未抓 → 报架构师。可能需要 fallback 到方案 B（historian QID blacklist 权宜方案）。
2. **Stage 2 dry-run 拦截 0 个 candidate**：本应至少看到启 ↔ 微子启被命中。0 拦截意味着实现失效或 R6 detection baseline 变化（如 Sprint C path A 的 seed downgrade 已让该 candidate 不再产出）→ Stop，分析根因。
3. **任意 invariant 回归** → 立即 Stop。
4. **T-P0-028 triage UI 数据源约定不清** → Stop，与架构师对齐 pending_review 通道结构后再实现（避免日后 schema 二次重构）。
5. **Stage 1 选型与本 brief δ 倾向不一致** → 报架构师签字（不阻塞，但需对齐）。

## 5. 关联卡 & Follow-up

- **上游**：T-P0-027（✅ Sprint C 收口）
- **平行**：T-P0-028（triage UI，本卡 guard 命中条目的人工通道——两卡在 pending_review 数据源约定上耦合）
- **下游**：T-P0-030（corrective seed-add wei-zi-qi → Q855012，独立 track）
- **后续可能**：ADR-021 修订（视本卡输出决定是否新增 "TIER-1 数据源限制" 小节）
- **风险清单**：docs/01_风险与决策清单_v2.md R-018（架构师待登记）

## 6. 角色边界

| 角色 | 职责 |
|------|------|
| 管线工程师 | Stage 0 inventory + Stage 1-3 实现 + 单元测试 |
| 架构师 | 本 brief + Stage 1 选型签字 + Stage 3 ADR-021 修订决策 |
| Historian | 仅在 Stage 1 阈值标定时被 consulted（不需常驻） |
| 后端工程师 | 仅在 Stage 0 发现需要 schema 变更时被 consulted（不预期） |
| QA | 不参与（管线工程师自验，遵循 4 闸门协议） |

## 7. 度量目标（Sprint D 收口判定）

- ✅ 启 ↔ 微子启 case 被 guard 自动拦截（不需人工）
- ✅ 测试 +N（N 由 Stage 2 决定，至少 +5 unit + 1 invariant 扩展）
- ✅ Active persons 数不变（guard 不应误删数据，仅拦截 merge）
- ✅ Pending_review 数 +M（guard 命中数）
- ✅ V1-V11 全绿
