# ADR-026 — Entity Split Protocol：mention-level redirect 例外授权

- **Status**: accepted
- **Date**: 2026-04-26
- **Accepted-Date**: 2026-04-27
- **Authors**: 管线工程师（起草，Opus 4.7）+ 首席架构师（签字 2026-04-27）
- **Related**:
  - **ADR-014**（Canonical Merge Execution Model — names-stay 铁律）
    本 ADR 是 ADR-014 的 **supplement**（不 supersede），授权一类 ADR-014
    §2.1 明文禁止之外的 mention-level UPDATE，仅在 entity-split 场景生效
  - ADR-017（Migration Rollback Strategy — pg_dump anchor + 4 闸门）
  - ADR-025（R Rule Pair Guards — 与本 ADR 互补：guard 防未来 / split 修当下）
  - T-P0-031（楚怀王 entity-split — 本 ADR 首应用）
  - Sprint G T-P0-006-δ historian review §2.2 Group 13（CRITICAL 发现触发）

---

## 1. Context

### 1.1 触发

Sprint G T-P0-006-δ historian review (`fdfb7cb` §2.2 Group 13) 发现"楚怀王"
entity 在数据库中**跨人共享**：

- 秦本纪 §65 mention 指 **熊槐**（战国楚怀王，前 296 客死秦）
- 项羽本纪 §6 mentions 指 **熊心**（秦末楚怀王，前 208 被立 / 前 206 被杀）

二者相隔 ~90 年，是历史上完全不同的两个人。Sprint G T-P0-006-δ Stage 4
仅做安全子合并（怀王/义帝 → 熊心），entity-split 升格为独立 task
**T-P0-031**（P0）。

### 1.2 既有铁律阻塞

ADR-014 §2.1 明确规定：
> **不修改** `person_names.person_id` —— 每条 name 永远指向它被抽取时所属
> 的 person 实体，哪怕该实体已被 soft-delete。

ADR-014 §2.2:
> 任何场景下（包括 historian 手工裁决、crisis patch、bulk correction）都
> **不得绕过**此函数 [`apply_merges()`] 直接写 SQL。

`apply_merges()` 实现的是"merge 模型 A"：soft-delete entity + names-stay。
**没有**支持反向操作（把 mention 从 entity 迁出）。entity-split 在
ADR-014 框架下是**未支持场景**。

### 1.3 缺口

需要一个**明确的例外协议**：
1. 何时允许跨 person UPDATE `person_names.person_id`
2. 授权范围（哪些表 / 哪些列允许动）
3. 执行条件（双签 / 4 闸门 / pg_dump）
4. 审计要求（log 表 / commit 信息）
5. 何时**不**适用本协议（默认仍走 names-stay）

无 ADR 授权 → 任何 mention redirect 都属"ad-hoc cross-person SQL"，按
ADR-014 §2.2 应被 rollback。

---

## 2. Decision

### 2.1 授权范围（明确清单）

本 ADR 授权 **entity-split 场景** 下、且**仅在执行条件 §3 全部满足时**，
进行下列 SQL 操作：

| 表 | 字段 | 操作 | 边界 |
|----|------|------|------|
| `person_names` | `person_id` | UPDATE | 仅在 historian 明确裁决的 mention 列表上，FROM `<source person>` TO `<target person>` |
| `person_names` | (整行) | INSERT | 仅 historian `split_for_safety` 裁决场景；INSERT 行 `source_evidence_id` 必须等于 source entity 上同 surface + 同 `name_type` 对应行的 `source_evidence_id`（共享 SE）；INSERT 行 `person_id` = target entity；INSERT 必须在 `entity_split_log` 写对应 audit 行 |
| `source_evidences` | (无字段直接改) | mention 关联调整通过 `person_names` 上的 FK 间接完成 | 不直接 UPDATE source_evidences 列 |

### 2.2 不开放清单（明确边界）

本 ADR **不**授权下列操作（仍按 ADR-014 处理）：

| 表 | 字段 | 原因 |
|----|------|------|
| `persons` | `id` / `slug` / `name` / `dynasty` / `deleted_at` / `merged_into_id` | persons 表本体不在本 ADR scope；如需变更走 `apply_merges()` 或专门 ADR |
| `person_merge_log` | 任何列 | merge_log 是审计表，不应回填修改；entity-split 用独立 audit 表（`entity_split_log`，§4） |
| `source_evidences` | 任何列 | mention 关联间接通过 person_names FK 调整，不直接改 SE 列 |
| `extractions_history` | 任何列 | 历史抽取审计不可变（C-11 宪法） |

### 2.3 适用场景定义

本 ADR 仅适用于满足以下**全部**条件的场景：

1. **同号异人** — 数据中已经把 ≥2 个不同历史人物错误聚合在一个 entity 上
   （典型：跨章 / 跨时段共享的 NER 标识符，如"楚怀王"= 熊槐+熊心）
2. **historian 已裁决每条 mention 的归属** — 输入是确定性 mention 清单 +
   target person 映射
3. **目标 entity 已存在** — 不允许在 entity-split 协议内**新建** persons
   行（如需新建，走 ingest 路径产出，再做 split）
4. **`split_for_safety` 子场景** — historian 裁决某 mention 跨人可能性**双端
   保留**时，原行在 source entity 保留不动，target entity 上 INSERT 同
   surface + 同 `name_type` + 同 `source_evidence_id` 副本。该子场景为
   **过渡态**：等未来 mention 段内位置切分（T-P2-007 候选）成熟后，由
   historian 复审决定将哪一端的副本 demote / delete

不满足条件 1-3 任一 → **不**适用本协议，回到 ADR-014 names-stay。
条件 4 仅在 `split_for_safety` 裁决出现时附加适用，不是必要条件。

### 2.4 与 ADR-025 的互补关系

| 维度 | ADR-025 | ADR-026 |
|------|---------|---------|
| 时机 | 防未来（持续性 guard） | 修当下（一次性数据校正） |
| 对象 | 阻止错误 merge proposal 形成 | 修正既有错误聚合 |
| 触发 | 每次 ingest / resolver 跑 | 仅在 historian 同号异人裁决后 |
| 数据形态 | 写 `pending_merge_reviews` | UPDATE `person_names.person_id` + 写 `entity_split_log` |

两个 ADR 共同覆盖"跨代同号"问题的两种形态。

---

## 3. 执行条件（强制）

任何 entity-split 操作 PR / commit 必须**同时**满足下列条件：

### 3.1 双签（架构师 + historian）

- **Architect sign-off**：在 task card 或 PR 描述中明示 ACK
- **Historian sign-off**：mention 分桶清单（含每条 mention 的 target
  person）由 historian 提交并签字（典型形式：sprint-logs 下的
  `<sprint>/<task>-mention-routing-<date>.md`）

任一签字缺失 → 操作被拒，转为 RFC 流程。

### 3.2 Dry-run 必备

- 实际 UPDATE SQL 必须先以 `BEGIN; UPDATE ... RETURNING *; ROLLBACK;`
  形式跑一次
- RETURNING 全量结果贴回 task card / PR 描述 / sprint-logs
- 架构师按"意图 vs 实际"逐行对读后才能进 §3.3

### 3.3 pg_dump anchor

- 操作前：`pg_dump -Fc huadian > ops/rollback/pre-<task-id>-<stage>-<timestamp>.dump`
- TOC 条数 + SHA-256 前 12 位记录到 task card
- 操作失败回滚优先 `pg_restore`，不依赖 SQL 反向脚本

### 3.4 4 闸门（pipeline-engineer.md §4）

| 闸门 | 内容 |
|------|------|
| 1 | pg_dump 快照（§3.3） |
| 2 | persons + person_names schema 确认（`\d+`） |
| 3 | NER cache / extractions_history 关联 replay 状态评估 |
| 4 | dry-run RETURNING 全量贴回 + 架构师对读 ACK |

每闸门必须有架构师显式 ACK 才能进下一闸门，COMMIT 前 4 闸门全绿。

### 3.5 单事务

- mention redirect 全部在**单一**事务内完成（`BEGIN; ... COMMIT;`）
- 跨事务的部分 redirect 视为违反本协议
- COMMIT 后立即跑 V1-V11 invariant，任一 violation → 立即触发 pg_restore

---

## 4. 审计：`entity_split_log` 表（migration 0013 草案）

新建表用于审计 entity-split 操作，**不复用** `person_merge_log`（语义不同：
merge_log 记 entity-level soft-delete，split_log 记 mention-level redirect）。

### 4.1 表 schema 草案（仅文字描述，**本 sprint 不写 .sql 文件**）

```
TABLE entity_split_log
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid()
  run_id                uuid NOT NULL              -- 一次 split 操作的批次 id
  source_person_id      uuid NOT NULL              -- mention 迁出 entity (FK persons.id)
  target_person_id      uuid NOT NULL              -- mention 迁入 entity (FK persons.id)
  person_name_id        uuid NOT NULL              -- 被迁移的 person_names 行 (FK person_names.id)
  redirected_name       text NOT NULL              -- 该 person_name 的 name (snapshot, 防 UPDATE 后丢)
  redirected_name_type  text NOT NULL              -- name_type (snapshot)
  source_evidence_id    uuid                       -- 关联 SE (FK source_evidences.id, NULL ok)
  historian_ruling_ref  text NOT NULL              -- 引用 historian 裁决 commit hash + section
  architect_ack_ref     text NOT NULL              -- 引用 architect ACK commit hash / PR comment
  pg_dump_anchor        text NOT NULL              -- pg_dump 文件名 + SHA-256 前 12 位
  applied_by            text NOT NULL              -- "pipeline:t-p0-031-stage-3" 之类
  applied_at            timestamptz NOT NULL DEFAULT now()
  notes                 text                       -- 自由文本备注

  CONSTRAINT entity_split_log_pair_distinct CHECK (source_person_id <> target_person_id)
  -- FK constraints to persons / person_names / source_evidences (ON DELETE RESTRICT)

INDEX idx_entity_split_log_run    btree (run_id)
INDEX idx_entity_split_log_source btree (source_person_id)
INDEX idx_entity_split_log_target btree (target_person_id)
```

### 4.2 设计要点

- **每条 mention 一行**（不是每次 split 一行）：精细审计粒度，便于事后
  查"哪些 mention 在何时从 X 迁到 Y"
- **snapshot 字段**（`redirected_name` / `redirected_name_type`）：防止
  person_names 后续 UPDATE 后丢失审计信号
- **double sign-off ref**（`historian_ruling_ref` / `architect_ack_ref`）：
  强制审计追溯到双签出处
- **pg_dump_anchor**：与 ADR-017 协议一致
- **ON DELETE RESTRICT**：确保审计表不被级联清理
- **不存 SQL 内容本身**：操作 SQL 在 ops/scripts 下，与 audit log 解耦

### 4.3 Migration 编号约定

下一 migration 编号是 **0013**（migration 0012 为 Sprint D
`pending_merge_reviews`）。本 ADR **不**起草 migration 0013 .sql 文件
（不在本 sprint scope）；T-P0-031 Stage 3 实施时由 PE 起草 + 后端工程师
review。

### 4.4 复杂度评估（Stop Rule #4 检查）

- 字段数：**13** 列（含 4 个外键 / 1 个 CHECK / 3 个索引）
- 与现有 `person_merge_log` 字段数相当（13 vs 9，多了 4 个 split 特有字段）
- 无触发器 / 无新枚举 / 无新跨表事务复杂度
- ⏱️ 预估实现工时：< 1 小时（单 migration + Drizzle schema sync）

**Stop Rule #4 不触发**（schema 复杂度在常规范围内）。

---

## 5. ADR-014 关系

### 5.1 supersede vs supplement

本 ADR 是 ADR-014 的 **supplement**（不 supersede）。理由：

- ADR-014 §2.1 names-stay 仍是默认规则
- ADR-014 §2.2 "唯一合法入口 = `apply_merges()`" 仍在大多数场景下成立
- 本 ADR 仅为 entity-split 这一特定场景开 ADR-授权口径，符合 ADR-014 §2.2
  括号文字"或经 ADR 授权"

ADR-014 §2.2 原文：
> 任何修改 `persons.deleted_at` / `merged_into_id` / `person_names.person_id`
> 的操作必须经过 `apply_merges()` 或经 ADR 授权；ad-hoc SQL 一律拒绝。

**"或经 ADR 授权"即指本 ADR 这类例外协议**。

### 5.2 ADR-014 §2.1 修订

本 ADR accepted 后，ADR-014 §2.1 第 2 项加补注（**不动原条款**，加 footnote）：

> 2. **不修改** `person_names.person_id`...
>
>    *^[ADR-026 例外] entity-split 协议下的 mention redirect 是 ADR-014 §2.2 末尾"或经 ADR 授权"的具体实现，且仅在 ADR-026 §3 全部条件满足时生效。*

### 5.3 模型 A 不变

ADR-014 模型 A 的核心约束依然成立：
- ✅ 一次 merge → soft-delete + merged_into_id + names 留 source
- ✅ 读端 `findPersonNamesWithMerged` 不变（split 后 source entity 仍由
  自己的 mentions 聚合）
- ✅ V4 invariant（"deleted person 必须保留至少一条 name 行"）需 split
  后 source entity 至少剩 1 条 name；如清空 → 须随后 soft-delete source

---

## 6. Rationale

### 6.1 为什么不扩展 `apply_merges()`

`apply_merges()` 的语义是 "n→1 entity 收敛"；entity-split 是 "1→n entity
发散"，方向相反。强行塞入同函数会破坏单一职责，且函数签名变臃肿。新建
独立操作（未来可工具化为 `apply_entity_split()`）更清晰。

### 6.2 为什么不直接复用 `person_merge_log`

merge_log 字段约定（`canonical_id` / `merged_id` / `merge_rule`）与 split
操作语义（`source` / `target` / `historian_ruling`）不匹配。复用会让
merge_log 字段语义双义化，增加 query 复杂度。

### 6.3 为什么 mention-level 而非 entity-level

split 的本质是"把错误聚合的 mentions 分散到正确的 entities"。如果在
entity 级操作（如新建 entity 再 merge），会引入额外 entity（slug 命名问题
+ 多走一遍 merge），不必要复杂。直接 `UPDATE person_names.person_id` 是
最直白的形态。

### 6.4 为什么严格双签

- entity-split 是不可逆操作（除非 pg_restore），与 merge soft-delete 不同
- 错误的 mention redirect 难以察觉（不会触发 V1-V11 violation），需要
  historian 内容审 + 架构师协议审两道防线
- 双签 + 4 闸门是 pipeline-engineer.md §"数据形态契约级决策"的最高
  级防护

---

## 7. Consequences

### 7.1 正面

- ✅ T-P0-031 楚怀王 entity-split 有了明确的执行协议
- ✅ 未来同类问题（如发现"晋文公"也跨章污染等）有现成路径
- ✅ entity_split_log 提供完整审计轨迹，事后可追溯每条 mention 的迁移
  历史
- ✅ ADR-014 names-stay 默认规则不动；只在 §3 严格条件下开口

### 7.2 负面 / 需要接受

- ⚠️ 增加一种"合法 ad-hoc SQL"类型，对 CI 静态扫描（ADR-014 §5.3 候选 T-P0-017）
  规则需要白名单——具体白名单形态由 T-P0-017 实施时定
- ⚠️ entity_split_log 表是新表（schema migration 0013 草案）；本 sprint 不实施，
  T-P0-031 Stage 3 实施前需后端 review
- ⚠️ V4 invariant 在 split 后可能瞬时违反（如 source entity 所有 name 都迁走
  但 source 没 soft-delete）—— §3.5 单事务 + V1-V11 跑 已覆盖此风险

### 7.3 回滚路径

- 操作失败：pg_restore 自最近 pg_dump anchor（§3.3）
- ADR 本身废弃：新 ADR supersede 本 ADR；已发生的 split 操作通过
  entity_split_log 反查 + 反向 UPDATE 恢复

---

## 8. Architect Sign-off (2026-04-27)

架构师签字（2026-04-27 PE Sprint H 会话 4）：

- [x] **§2.1 授权范围**：`person_names.person_id` UPDATE **+ INSERT**（解读 A
      采纳，与 historian §5 "保 1 份 + 复 1 份" 裁决一致；`source_evidences` 不直接改）
- [x] **§2.2 不开放清单**：同意 `persons` 表本体在 split 协议外继续走
      `apply_merges()` / 不开口
- [x] **§3.1 双签机制**：sprint-logs file + commit hash 作签字载体（不允许仅 PR 评论）
- [x] **§4 entity_split_log schema**：13 字段接受；CHECK (source ≠ target) 保留
      （keep-case 不入 log，由 historian ruling commit 作 source of truth — 选项 X）
- [x] **§5.2 ADR-014 修订**：footnote 形式（不动 ADR-014 §2.1 原条款）
- [x] **§7.2 CI 白名单**：T-P0-017 未来联动设计（当前不动作）

**额外 sign-off（2026-04-27 PE 会话 4 澄清）**：

- [x] **解读 A 采纳**：`split_for_safety` = source 保留 + target INSERT（共享 SE）；
      解读 B（UPDATE）违反 historian §5 "保 1 份"明文裁决；解读 C（仅 audit flag）
      违反 T-P0-031 "修当下" 目标。决定性证据：historian §4.1 "两份 person_names
      行将共享同一 source_evidence_id（73e39311）" — INSERT 才能产生此形态
- [x] **entity_split_log 选项 X**：log 仅记数据变更行；keep-case 不入 log；
      CHECK (source ≠ target) 不弱化
- [x] **§2.1 INSERT 行授权措辞**：INSERT 行 `source_evidence_id` 必须等于 source
      entity 上同 surface + 同 `name_type` 对应行的 `source_evidence_id`（共享 SE）；
      INSERT 行 `person_id` = target entity；INSERT 必须在 `entity_split_log` 写对应 audit 行
- [x] **§2.3 适用场景第 4 项**：`split_for_safety` 子场景定义（过渡态，未来 T-P2-007
      段内位置切分成熟后清理）

状态：**accepted**（2026-04-27）。后续：T-P0-031 Stage 3 实施基于本 ADR
执行 4 闸门 + 双签 + dry-run + pg_dump anchor + 单事务 commit。

---

## 9. Known Follow-ups

| ID 候选 | 描述 | 优先级 |
|---------|------|--------|
| T-P0-031 Stage 3 | 楚怀王 entity-split 实施（本 ADR 首应用） | P0 |
| migration 0013 | `entity_split_log` 表 DDL（PE 起草 + 后端 review） | P0（Stage 3 前置）|
| Drizzle schema sync | `services/api/src/db/schema/entity-split-log.ts` | P0 |
| 操作脚本工具化 | `services/pipeline/scripts/apply_entity_split.py` Python wrapper | P1（≥2 例后） |
| T-P0-017 联动 | CI 静态扫描白名单 ADR-026 路径 | P1 |
| V12 invariant 候选 | "无 entity 包含跨 ≥500yr mentions"（与本 ADR 互补防御） | P1 — Sprint I |
