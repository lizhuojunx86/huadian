# ADR-022 — NER 污染清理 vs Names-Stay 判定准则

- **Status**: Accepted
- **Date**: 2026-04-21
- **Authors**: 首席架构师（决策）+ 管线工程师（执行反馈 + Gate 0b/0c 数据）
- **Related**:
  - ADR-014（canonical merge — names-stay 原则）
  - ADR-013（persons.slug partial UNIQUE — soft-delete 机制对 persons 已存在）
  - T-P0-019 α Stage 2（先例应用 — F1 pronoun cleanup）
  - T-P1-014（F1 pronoun residuals debt — 本 ADR 落成后关闭）

---

## 1. Context

### 1.1 触发

T-P0-019 α Stage 2 执行 F1 pronoun residuals 清理时，遇到如下困境：

- 清理对象是 6 行 `person_names`（帝×2 / 王×2 / 朕 / 予一人），全部为 NER 错标（代词/自称/光秃爵位单字）
- `person_names` 表**没有** `deleted_at` 列，当前 Sprint 明示**不扩 schema**
- 可选路径：
  - 方案 A：硬 DELETE 6 行，pg_dump anchor 作审计回滚依据
  - 方案 B：新增 `deleted_at` + 改所有 SELECT + 改 ADR-013 语义 + 改 GraphQL 过滤

### 1.2 核心矛盾

ADR-014 names-stay 原则规定"合法名变体不物理删除"，但该原则是针对**合法历史称谓**（私名/字/号/谥/庙号等）设计的。NER 污染（代词、光秃爵位单字、分词错误产物）**不是**合法历史称谓，强行套用 names-stay 会：

1. 污染 read-side aggregation 逻辑（read path 被迫为"垃圾"多加一层过滤）
2. 让 V1-V6 invariant 语义变脏（"人名"集合里始终混杂代词）
3. 阻碍未来 extraction 改进（无法通过 QC rule 自动发现并清理新的 NER 污染）

另一侧，方案 B 扩 schema 的代价与 Phase 0-1 污染规模（< 20 行）严重不对称。

### 1.3 缺口

需要一条**明确的判定准则**，区分"合法名变体（走 ADR-014 names-stay）" vs "NER 污染（硬 DELETE）"，让未来类似清理任务（Stage 3 F2 前缀残留、Phase 1 扩大语料后新的污染发现等）有成文规则可依，不必每次临时裁决。

---

## 2. Decision

### 2.1 NER 污染三要素（AND，全部满足才成立）

一行 `person_names` 若同时满足以下三要素，归类为 "NER 污染"，适用硬 DELETE：

| # | 要素 | 验证方式 |
|---|------|---------|
| 1 | **Evidence 链零依赖** | `source_evidence_id IS NULL`；所有 evidence 相关表（source_evidences / extractions / chunks 等）对该行 0 反向引用 |
| 2 | **语义非合法人名** | 不是任何合法历史称谓形式；典型污染：代词（朕 / 予一人 / 吾）、独立排行字（伯 / 仲 / 叔 / 季）、独立光秃爵位（帝 / 王 / 公 / 侯）、分词错误产物（管 / 蔡 / 伯 等被错切的单字，其本应归入完整名如"管叔"/"蔡叔"） |
| 3 | **下游 FK 零依赖** | `information_schema.table_constraints` 查出所有 FK 到 `person_names.id` 的表，每表对该行 `COUNT(*) = 0` |

**任一要素不满足** → 不适用本 ADR。需走 ADR-014 names-stay（若是合法名）或升级为独立 ADR 评估是否需要引入 soft-delete 机制（若污染规模迫使 schema 扩展）。

### 2.2 执行协议（Gate 0 - Gate 4）

| Gate | 内容 | 输出物 |
|------|------|-------|
| **Gate 0** | pg_dump anchor：`pg_dump -Fc huadian_dev > /tmp/before-<task>-<stage>.dump` | SHA-256 记录到任务卡 |
| **Gate 0b** | 依赖审计：三要素的 Evidence + 语义 + is_primary/sibling names 状态 | 依赖矩阵贴架构师审 |
| **Gate 0c** | FK 扩围审计：`information_schema.table_constraints` 枚举 + 每表 COUNT | FK 矩阵贴架构师审 |
| **Gate 1** | pre-state snapshot：SELECT 要删除的行完整内容 | `evidence/<task>/stage-N-pre.json` |
| **Gate 2** | dry-run：`BEGIN; DELETE ...; SELECT <不变量校验>; ROLLBACK;` | dry-run 结果表贴架构师审 |
| **Gate 3** | 不可逆声明：标记 "hard DELETE per ADR-022, recovery via pg_dump only" | 架构师签字 |
| **Gate 4** | execute：`BEGIN; DELETE; SELECT <V1-V7>; COMMIT;` | post-state 快照 + commit SHA |

### 2.3 审计痕迹要求

commit message 必须**明确标注**：

- `per ADR-022` 短语
- 清理类型（pronoun residual / tokenization error / phantom title 等）
- pg_dump anchor SHA-256 前 12 位
- 机械性副作用（如 V7 分母缩减导致覆盖率变化）

任务卡（`docs/tasks/<task>/stage-N-*.md`）必须包含三要素判定依据的完整证据链。

---

## 3. Rationale

### 3.1 为什么不沿用 ADR-014 names-stay

ADR-014 的核心假设是"名有历史审计价值"——未来研究者可能需要知道某人物有过哪些异称。这对合法名（私名/字/号/谥/庙号）成立；但对 NER 污染不成立：

- "朕"是代词，不是任何具体人物的称谓
- 独立光秃的"帝 / 王"没有任何历史学术价值
- "管 / 蔡"分词错误残留，保留反而误导（让人以为有两个独立的"管"/"蔡"条目）

强行 names-stay 这些行等于在审计档案里保留"我们曾经犯过的 NER 错误"——没人会想复原这种数据。

### 3.2 为什么不扩 schema 加 soft-delete

加 `deleted_at` 列的代价在 Phase 0-1 规模下严重不成比例：

| 项目 | 成本 |
|------|------|
| Migration（ADD COLUMN + 索引） | 1 人时 |
| 所有 SELECT 加 `WHERE deleted_at IS NULL` | 2 人时（全栈扫描 + 测试回归） |
| ADR-013 partial UNIQUE 语义更新 | 3 人时（设计 + ADR 起草 + 迁移） |
| GraphQL schema 层过滤 | 2 人时 |
| QC rule 对已删除行的处理逻辑 | 1 人时 |
| **合计** | **≈ 9 人时** |

对比 6 行清理的价值，ROI 远不及"一行命令 + pg_dump anchor"方案。**当污染规模 > 100 行**或 Phase 2+ 扩语料后污染成常态时，再重启此评估。

### 3.3 为什么三要素而非单一要素

任何单一要素都不足够安全：

- **只看 Evidence 零依赖**：合法古籍人物因 evidence backfill 未覆盖可能也显示为 NULL，会误删
- **只看语义**：无法被程序化判定（需要架构师/史学家人工审），但又不能每次都人工审
- **只看 FK 零依赖**：扩展中的新表可能引入未知 FK，单看此项有遗漏风险

三要素 AND 是最保守的设计——除非三者同时确凿，否则走更保守路径。

---

## 4. Consequences

### 4.1 正面

- 清理 NER 污染不用扩 schema，保持 Phase 0-1 约束
- 与 ADR-014 边界清晰——合法名走 UPDATE，污染走 DELETE，判定可自动化（前两项是 SQL + 语义规则）
- pg_dump anchor + pre-state snapshot 提供完整审计痕迹
- 未来 QC rule 可以自动发现满足前两项要素的污染候选，进入人工审核队列

### 4.2 负面 / 需要接受

- 硬 DELETE 不可 SQL 回滚，只能通过 pg_dump anchor 物理复原
- 执行协议 Gate 数量多（Gate 0 / 0b / 0c / 1 / 2 / 3 / 4 = 7 闸门），单次操作成本略高
- 语义要素的判定依赖人工（难以完全程序化），每次清理任务需要架构师或历史学家介入确认
- 若未来需要"审计已删除污染"的场景出现（例如分析管线改进效果），需通过 pg_dump 反推，成本较高

### 4.3 回滚路径（本 ADR 自身）

若本 ADR 决定后续证明有误（例如某次清理被史学家发现误删合法名）：

- 新 ADR supersede 本 ADR，引入 `deleted_at` soft-delete 机制
- 已硬 DELETE 的行通过最近一次 pg_dump anchor 复原
- 三要素判定规则纳入 QC rule 做自动化检查，防止重蹈

---

## 5. Applied Examples

### 5.1 T-P0-019 α Stage 2（本 ADR 首个应用）

- **对象**：F1 pronoun residuals — 帝×2 / 王×2 / 朕 / 予一人（6 行）
- **三要素判定**：
  - Evidence 链：6 行 `source_evidence_id` 全 NULL ✅
  - 语义：代词（朕、予一人）+ 光秃爵位（帝、王）——明确非合法人名 ✅
  - FK 下游：`information_schema.table_constraints` 查询 0 表引用 ✅
- **处理**：硬 DELETE
- **副作用**：V7 从 96.37% 机械性上升到 97.49%（分母 524→518，分子 505 不变）——非 extraction 改善
- **Commit**：`b986891`
- **pg_dump anchor**：`f32964f4...`

### 5.2 T-P0-019 α Stage 3（计划应用，待 Gate 0b/0c 数据确认）

- **对象**：F2 前缀残留 — 独立单字 伯 / 管 / 蔡（3 行）
- **历史学家预判**：
  - 伯：排行字（伯仲叔季）或爵位（公侯伯子男）；独立出现无具体人物指向
  - 管：分词错误残留——本应归入"管叔鲜"（Stage 1 已修正 `name_type` 为 primary）
  - 蔡：同 管——本应归入"蔡叔度"
- **三要素预判**：语义要素明显满足；Evidence 链与 FK 待工程师 Gate 0b/0c 数据确认
- **若三要素全满足** → 硬 DELETE
- **若任一不满足** → 停下评估，可能需：调整 Stage 1 scope 回补、或升级为 ADR-022 修订

---

## 6. Known Follow-ups

### 6.1 短期（Sprint A 收尾内）

- **T-P0-019 α Stage 3**：首个 Stage 2 后启动的清理任务，完整走 Gate 0-4 + 三要素审
- **T-P1-014 关闭**：F1 pronoun residuals debt 随 Stage 2 commit `b986891` 关闭

### 6.2 中期（Phase 0-1 末段）

- **自动化 QC rule**：开发 `F1-ner-pollution-detector` 规则，扫描 `person_names` 表找到三要素全满足的候选行，进入人工审核队列
- **污染规模累计监控**：若 Phase 0-1 结束前累计清理次数 > 3 次或总规模 > 100 行，重启 soft-delete 机制评估

### 6.3 长期（Phase 2+）

- **audit log 表的必要性**：若 Phase 2+ 污染成常态，考虑新增 `data_cleanup_log` 表（与 `person_names` 解耦，不扩 `person_names` 本身的 schema），记录 DELETE 历史 + 三要素判定证据
- **本 ADR 修订**：污染规模突破阈值时，本 ADR 可能需要升级为 soft-delete + audit log 组合方案
