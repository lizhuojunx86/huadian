# Sprint H Retrospective

> **Sprint 范围**：T-P0-031（楚怀王 entity-split, P0）+ T-P1-028（R1 dynasty 前置过滤）
> **持续时间**：2026-04-26 ~ 2026-04-27（4 PE 会话 + historian 1 会话 + architect brief / 仲裁多次）
> **PE 模型**：Opus 4.7（架构创设 sprint）
> **总产出**：13 commits / 1 migration / 1 new audit table / 1 new ADR (ADR-026) / 1 ADR addendum (ADR-014 §2.1 footnote) / 6 evaluate_pair_guards tests + 22 R6 既有测试 / 1 dynasty yaml 9 mappings 合流

---

## 1. 关键数字 (Sprint G → Sprint H)

| 指标 | Sprint G 收口 | Sprint H 收口 | 变化 |
|------|--------------:|--------------:|------|
| Active persons | 663 | 663 | 0（mention-level 操作） |
| Merge log | 92 | 92 | 0 |
| **person_names rows** | （未单独追踪） | +2（48061967 上 split_for_safety 副本） | +2 |
| **entity_split_log rows** | 0（表不存在） | 2 | +2 (new) |
| **pending_merge_reviews rows** | 0（bootstrap） | 0（dry-run 验证；ingest 触发后自动写入） | 0 |
| Migrations | 0012（pending_merge_reviews） | **0013**（entity_split_log） | +1 |
| ADRs accepted | 24（含 ADR-025） | **25**（+ADR-026） | +1 |
| ADR addenda | — | ADR-014 §2.1 footnote | +1 |
| dynasty-periods.yaml entries | 12 | 21 (12+9) | +9 mappings（Hist Track B 复核 + 合流） |
| V invariants 全绿 | V1-V11 | V1-V11（V12 评估为 backlog） | 不变 |
| LLM cost | $0.60（项羽本纪 ingest） | **$0**（Sprint H 全 schema/data-fix，无 ingest） | $0 |
| New tests | 0 | 6（evaluate_pair_guards） | +6 |

---

## 2. 主要交付

### 2.1 ADR-026 Entity Split Protocol（首次 entity-level 协议）

ADR-014 names-stay 铁律的第一个明文例外协议。10 决策点架构师签字（6 原 + 4 澄清）。授权 `person_names` 行的 UPDATE（redirect 场景）+ INSERT（split_for_safety 场景），仅在 4 闸门 + 双签 + dry-run + pg_dump anchor + 单事务严格条件下生效。

### 2.2 ADR-025 R Rule Pair Guards（Sprint H Stage 2 落地，本 sprint 跨 sprint 收尾）

`evaluate_pair_guards(a, b, *, rule)` rule-aware guard 接口。R1=200yr / R6=500yr 阈值。`pending_merge_reviews` 接收 R1 拦截 case，与 R6 共用基础设施。28 单元测试全绿（22 R6 既有 + 6 新）。

### 2.3 T-P0-031 楚怀王 entity-split（ADR-026 首应用）

- 历史问题：同一"楚怀王" entity 跨章节聚合熊槐（战国，-296）+ 熊心（秦末，-206）90 年同号异人
- Sprint H Stage 3 数据校正（apply commit `14eb2f5`）：保留 1 行（秦本纪楚怀王 primary）+ split_for_safety 2 行（项羽本纪怀王 posthumous + 楚王 nickname）→ target 熊心 entity 上 INSERT 副本
- 双签：architect commit `ed2e8c8` + `56a6743` / historian commit `a117fbf` §5
- pg_dump anchor `pre-t-p0-031-stage-3-20260427-204634.dump:52bd6f91da5c`
- post-apply V1-V11 全绿，无回归

### 2.4 dynasty-periods.yaml 9 mappings 合流（PE draft + Hist Track B 学术复核）

3 项学术修订采纳：
- 春秋战国 -500/-450/-475 → **-481/-403/-442**（学界标准断代：《春秋》绝笔 + 三家分晋）
- 秦末汉初 midpoint -205 → **-206**（floor convention 统一，away from zero）
- 战国·秦/韩/魏 alias 加 future-risk 注释（midpoint 差异 32-46yr 临近 50yr 上限）

---

## 3. 关键 Lessons Learned

### 3.1 ADR audit 字段语义在多场景下需明示（架构师误读 dry-run 报告事件）

**事件**：S4.5 dry-run 报告 §3.2 `entity_split_log.person_name_id` 字段 在 split_for_safety 场景指向 **target 副本** UUID（事务内生成）；架构师对照 historian ruling commit `a117fbf` §5 的 source pn_id 短前缀时，误将 dry-run 输出的 target UUID 解读为 source pn_id，发现"不一致"暂缓 ACK。

**根因**：ADR-026 §4 schema 草案 `person_name_id` 字段描述为"被迁移的 person_names 行"，在 redirect 场景（UPDATE）下指被 UPDATE 的行（id 不变），在 split_for_safety 场景（INSERT）下指**新 INSERT 副本**（id 是新生成的）。同一字段在两场景下指向不同实体，存在两义性。

**解决**：选项 P 文档澄清（commit `56a6743`）：
- ADR-026 §4.1 person_name_id 列描述明确两场景下的指向语义
- ADR-026 §4.4 新增"verification-friendly 约定"：apply 脚本 dry-run 报告必须同时显示 source pn_id（脚本常量，稳定）+ target pn_id（RETURNING，事务内）两列
- dry-run 报告 §3.2 重排为双 pn_id 对账表

**Lesson**：**未来 ADR 起草涉及 audit 字段时，对每种操作场景明示该字段的指向语义**。即"语义" "在 op=X 时指 ..." 的列表必须在 schema 描述中显式列出，不能用一句"某行"模糊处理。

### 3.2 4 闸门协议的"对账"步骤需要协议级安全网

**架构师建议（Sprint H session 4 message）**：ADR-026 §3 闸门列表加第 5 闸门"架构师对照 historian ruling 短前缀逐行对账"作为 sign-off pre-condition。

本次事件证明：架构师对账是协议本身需要的"sanity check"，已通过 PE verification 兜底成功，但建议显式化进 ADR。**T-P2-009 候选**：ADR-026 §3 加第 5 闸门（详 §6 衍生债）。

### 3.3 ADR-017 forward-only 在 0-row 新表场景下的正确路径

**事件**：选项 Q 比较时 PE 一度建议"DROP + rebuild migration 0013"作为 schema 扩展路径，**违反 ADR-017 forward-only**。

**正确路径**：**ALTER TABLE via 新 migration**（如 migration 0014 `ALTER TABLE entity_split_log ADD COLUMN ...`），即使该表当前 0 行也不能 DROP + rebuild。

**Lesson**：ADR-017 forward-only 是绝对原则，与表的当前数据量无关。"表当前空所以可以 DROP" 是错误推论；表 schema 一旦 apply 就进入永久演进轨道。

### 3.4 选项 X vs 选项 Y（entity_split_log 语义边界）的设计哲学

选项 X（log 仅记数据变更行 / keep-case 不入 log）vs 选项 Y（log 全 mention 留痕）。架构师选 X，理由："entity_split_log 是动作审计表（记物理 DB 变更），不是决策审计表；决策审计已在 sprint-logs/historian-rulings/*.md（markdown 版本控制 + commit hash）作 source of truth"。

**Lesson**：审计表的边界以"动作物理变化"划定；"决策为何如此"留在文档/commit 中。这与 person_merge_log（仅记 entity-level soft-delete 动作，不记裁决理由）的既有惯例一致。

### 3.5 dry-run 报告作为协议契约，需要 verification 友好的格式

dry-run 报告不仅是"展示意图"，而是架构师对账的**实际工具**。当报告字段语义有歧义时，对账失败 → 暂缓 ACK 是协议正确动作，但浪费一次往返。

**已落地**（per option P 决策）：apply 脚本必须在 dry-run 报告显示双 pn_id 列；ADR-026 §4.4 立约束。

---

## 4. Sprint H 阶段 vs 节奏建议（brief §7）回顾

| brief 建议节奏 | 实际 |
|----------------|------|
| 第一会话：Stage 0 inventory + Stage 1 设计 → 挂起等架构师 ADR-025 签字 | ✅ 完成（PE 会话 1） |
| 第二会话：Stage 2 T-P1-028 实施 + Stage 3 T-P0-031 dry-run → 挂起等联合 ACK | ✅ 完成（PE 会话 2-3） |
| 第三会话：Stage 3 apply + Stage 4 验证收档 | ⚠️ **拆为会话 3 + 会话 4 两段**（中间 historian Track B 9 yaml 复核 + ADR-026 起草分担） |

**实际节奏**：4 PE 会话（Opus 4.7）+ 1 historian 会话 + 多次 architect 仲裁。比 brief 预估多 1 会话，原因：
- ADR-026 起草时 6 决策点 + Sprint H S2.5 Stage 2 dry-run 验证占用了一个独立产出节点
- 选项 P/Q 澄清往返（架构师误读 dry-run 报告）多 1 个文档迭代

**评估**：节奏可接受。架构创设 sprint 多 1 个会话用于澄清比"赶节奏导致协议含糊"更值。

---

## 5. Stop Rule 触发记录

| Stop Rule | 是否触发 | 处理 |
|-----------|:--------:|------|
| #1 Stage 0 R1 实现与文档严重不符 | ❌ | — |
| #2 楚怀王 mention 分桶需 historian 二次裁决 | ✅（PE Stage 0） | 切 historian 会话产出 commit `a117fbf` |
| #3 Stage 1 设计选型与 β 倾向不一致 | ❌ | β 路径采纳 |
| #4 Stage 2 dry-run guard 拦截数 >2× 预测 | ❌（1.14×） | 通过 |
| #5 任一 V invariant 回归 | ❌ | post-apply V1-V11 全绿 |
| #6 V12 评估发现需要 schema 变更 | ✅ | 不本 sprint 实施，登记 T-P2-008 backlog |
| **额外（架构师对账）** | ✅（pn_id 一致性） | 选项 P 文档澄清 commit `56a6743` |

总：3 触发 / 5 处理顺利。

---

## 6. 衍生债登记

| ID 候选 | 描述 | 优先级 | 触发上调条件 |
|---------|------|:-------:|---------------|
| **T-P2-006** | `generate_dry_run_report` 标签写死 "R6 guard 拦截"，应改为通用 "Guard 拦截"（含 R1）；显示 bug，逻辑无误 | P2 | 用户报错出现混淆时 |
| **T-P2-007** | mention 段内位置切分（per historian a117fbf §6.1）；当前 split_for_safety 是过渡态，需要 mention timestamp + position offset 字段 | P2 | 累积 ≥3 例同类 split_for_safety |
| **T-P2-008** | V12 invariant — entity-level cross-time mention detection（per S4.7 评估）；推荐方案 D（mention dynasty 字段，500yr 阈值） | P2 | 发现 ≥2 例同号异人 entity-collision |
| **T-P2-009** | ADR-026 §3 加第 5 闸门"架构师对账 historian ruling 短前缀"作为 sign-off pre-condition（per Lesson 3.2） | P2 | 下次 entity-split case 出现时实施 |
| **T-P1-029（候选）** | 惠公 entity 内含晋惠公/秦惠公 dynasty 混合（dynasty 字段 `战国` 但 mention 跨春秋/战国），entity-level 数据修复（Sprint H Stage 2.5 dry-run §3.1 异常调查发现）| P1 | Sprint I 候选 |

---

## 7. 关联 retros

- Sprint G retro: G15 项籍→项羽 textbook-fact precedent（与本 sprint 无直接重叠）
- Sprint F retro: V1 根因修复 + V9 invariant（本 sprint apply 过程依赖 V1=0/V9=0 约束）

---

## 8. 致谢

- **Historian (Opus 4.7)**: a117fbf §5 楚怀王 mention bucketing 裁决（2 行 split_for_safety 决策权威依据） + d7f79b7 dynasty mapping 9 项学术复核（春秋战国 / 秦末汉初 / 战国国别）
- **Architect**: ADR-025（10 决策点） + ADR-026（10 决策点 = 6 原 + 4 澄清） + 选项 P/X 裁决 + Stop Rule 仲裁
- **PE Opus 4.7**: 4 会话推进 + 13 commits + ADR/migration/script/dry-run 报告产出
