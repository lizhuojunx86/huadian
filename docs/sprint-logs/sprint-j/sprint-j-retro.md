# Sprint J Retrospective — 高祖本纪 (T-P0-006-ε)

- **日期**: 2026-04-28
- **Sprint 持续**: 单日（会话 1-3，跨 context compaction）
- **LLM 累计**: $0.79（NER ingest） + $0（架构/文档）
- **成本 YTD**: Sprint E $0.32 + Sprint G $0.60 + Sprint J $0.79 = **$1.71**

---

## Sprint G→J 管线 ROI 评估

| Sprint | 章节 | +NER persons | LLM 成本 | apply 合并 | 净 active |
|--------|------|-------------|---------|-----------|---------|
| Sprint E | 秦本纪 | +84 | $0.32 | 5 | 484 |
| Sprint G | 项羽本纪 | +117 | $0.60 | 9 | 663 |
| Sprint J | 高祖本纪 | +85 | $0.79 | 19 | 729 |

**每美元新增 active persons**：Sprint E=262/$ / Sprint G=180/$ / Sprint J=83/$

Sprint J 单价上升的主因：19 merges（高祖本纪 slug dedup 6 对 + G7 sub-merges 2 对）导致 net 降低；NER ingest 效率本身与 Sprint E/G 相当（+85 persons / $0.79）。

---

## Sonnet 4.6 累计评估（Sprint G/H/I/J）

| 维度 | 评估 |
|------|------|
| 代码生成质量 | 高。`_swap_ab_payload()` 实现正确，5 tests 全覆盖，ruff 一次过 |
| 架构感知 | 良好。能识别 pair-order normalization 副作用，主动匹配正确 fix 范围 |
| Stop Rule 响应 | 优秀。S4.3 SELECT 结果意外时立即 STOP 报架构师，未盲目继续 |
| 历史知识 | 可用。高祖本纪人物关系（陈胜/陈涉名字关系、刘太公/太公）识别正确 |
| 速度 vs Opus 4.7 | Sprint J 会话上下文量更大，compaction 触发 2 次；Sonnet 4.6 在 compaction 后能从 summary 正确续接，无遗漏 |

**建议**：Sonnet 4.6 适合管线日常 ingest sprint；Opus 4.7 保留用于高密度架构会话（ADR 设计 / 复杂仲裁）。

---

## §lessons — 本 Sprint 新增

### Stop Rule 价值：S4.3 SELECT verify 兜底救场

**现象**：S4.3 pre-flight SELECT 发现 吕后=西汉/刘盈=西汉，与 dry-run report 显示（春秋/战国）不符 → Stop Rule 触发。

**结果**：避免了将 DB 正确值强行 UPDATE 为错误值（动态页 dynasty-periods.yaml 中无"西汉初"，实际 UPDATE 会破坏 cross_dynasty_guard 查找）。

**教训**：S4.3 SELECT verify gate 不是形式主义，是实质性的兜底机制。每次 sprint 都必须执行，不得 skip。

---

### 架构师 Inline 裁决的局限性（T-P2-009 候选）

**现象**：S4.3 Stop Rule 触发时，架构师通过会话内消息（非正式 ADR 渠道）给出裁决 A+C+D。

**问题**：
1. 裁决 A（跳过 S4.3）的根因分析在会话中，未归入 decision log
2. 如果下一个 sprint 的工程师没有读 retro，可能不知道 T-P1-031 被显式否决

**改进方向**：Stop Rule 触发 → 架构师 inline 裁决 → 裁决摘要追加到 dry-run report §correction（本次已做）AND/OR 短 ADR note（T-P2-009 formal protocol 候选）。

---

### Guard Payload 键名对称性约束（新架构原则候选）

**根因**：`_swap_ab_payload()` bug 的根因是 guard 层（cross_dynasty_guard / state_prefix_guard）生成 payload 时，key 命名有 `*_a` / `*_b` 对称性假设，但 resolve 层 pair-order normalization swap 时未维护该对称性。

**建议**：将"guard_payload 中 `*_a`/`*_b` 键必须随 pair swap 同步互换"纳入 ADR-025 §guard-payload invariant（或独立 ADR）。

---

### V13 候选：alias 唯一性不变量（backlog）

**场景**：G7 entity-split 后，熊心有 alias "怀王"（Sprint G 已注册）和 "义帝"（Sprint G 已注册）。高祖本纪 NER 产出新的 怀王 / 义帝 persons，先 ingest 后再 apply sub-merge，在 apply 前短暂出现 alias 重复（2 active 怀王 alias）。

**现状**：V1-V11 不检查 alias 重复（names-stay model-A 明确允许 alias 跨 person 重名）。

**V13 候选定义**：单一 canonical entity 下同 name_type=alias 的同字 alias 数量上限（建议 ≤ 1，或 ≤ 1 per primary）。

**阈值**：需 ≥3 个 sprint 遇到此 pattern 方升正式 invariant。当前：1 例（熊心，Sprint J）。

---

### Textbook-fact 阈值触发：ADR-014 addendum 时机

累计 4 例（重耳→晋文公 / 项籍→项羽 / 嬴政→始皇帝 / 陈胜→陈涉），超过"≥3 例触发 addendum"阈值。

T-P1-030 注册（historian + 架构师 co-author）。

优先级建议：Sprint K 前完成 ADR-014 addendum 草案，避免第 5 例又无规范可依。

---

## 衍生债一览

| 任务 | 优先级 | 类型 | 状态 |
|------|--------|------|------|
| T-P1-030 | P1 | ADR-014 addendum（textbook-fact） | registered |
| T-P1-027 | P1 | disambig_seeds 扩充 | registered（增项） |
| T-P2-005 | P2 | NER v1-r6 西汉初格式 | registered（增项） |
| T-P2-009 | P2 | 架构师 inline 裁决 formal protocol | 候选（未注册） |
| V13 | — | alias 唯一性 invariant | backlog（1/3 例） |
