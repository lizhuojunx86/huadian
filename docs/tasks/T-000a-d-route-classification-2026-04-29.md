# Task Backlog Classification — D-route 转型

> Date: 2026-04-29
> Trigger: ADR-028 战略转型 + Stage D-3 任务卡积压重整
> Owner: 首席架构师
>
> 本文件**不直接修改**每张任务卡，避免破坏既有引用。
> 而是给出**三分类总览**，由 Sprint L+ 推进时各 sprint brief 中按本表决定具体推进。

---

## 0. 分类原则

依据 ADR-028 §2.3 + 项目宪法 §六 C-22 / C-23：

- **🟢 继续** — 与 D-route 路线契合，Sprint L+ 主动推进
- **🟡 降级** — 部分契合，但不是 D-route 优先；降级到 P3 backlog（不主动启动，遇到时 batch 处理）
- **⚪ Sunset** — 纯 case-only 或纯 C 端产品，永不主动启动；未来如有跨领域案例方需要可重启
- **✅ 已完成** — 保留作为案例素材，不需要再处理

---

## 1. 已完成 task 概览（保留作为案例素材）

Sprint A-K 期间完成的所有 task 卡保留在 `docs/tasks/`，作为 D-route Layer 3 案例库素材。

完整列表：参见 `docs/tasks/T-000-index.md` + `docs/sprint-logs/sprint-{a..k}/`。

下面只列**还未明确归类**的活跃 task。

---

## 2. 🟢 继续推进（D-route 契合）

### 2.1 Sprint L 主动议程

下面这些不是新 task 卡，而是 Sprint L brief（`docs/sprint-logs/sprint-l/stage-0-brief-2026-04-29.md`）中规划的工作，等 Sprint L 启动后会落到具体 task 卡：

- **T-FRAMEWORK-001 Sprint workflow 抽象 spike**（待 Sprint L Stage 1 启动时立卡）
- **T-DEMO-001 产品化 demo walkthrough**（待 Sprint L Stage 2 启动时立卡）

### 2.2 Layer 1+2 持续推进

- **T-METHODOLOGY-001 ~ 006**（7 份 docs/methodology/ 草案的 v0.1 → v0.x 迭代）
  - 当前 status: Draft v0.1（Stage C 已起草）
  - 推进节奏：每个 Sprint 至少 +1 份草案 v0.x 迭代（dogfood + 引用 framework spike 后细化）

### 2.3 跨领域案例邀约（Layer 3）

- **T-CASE-001 跨领域案例邀约启动**（暂不立卡，视外部接触机会）

---

## 3. 🟡 降级到 P3 backlog（部分契合）

下面这些 task 卡曾被 P0 / P1 / P2 优先级标注，但 D-route 战略转型后**不再优先**。它们仍然是合理工程改进项，遇到机会时 batch 处理；但不主动启动新 sprint。

| Task ID | 原优先级 | 降级理由 | 何时再考虑 |
|---------|--------|---------|-----------|
| **T-P1-030** ADR-014 textbook-fact addendum | P1（4 例触发，Sprint J 后）| 是 Layer 3 案例细节，非框架抽象优先 | 框架抽象第 N 版稳定后（如 Sprint M+），与 ADR-014 一并整理 |
| **T-P2-002** fail-loud incident standardization | P2 | 是工程改进，非 D-route 优先 | 案例 ingest 出问题时再 batch 处理 |
| **T-P2-005** NER v1-r6 楚汉 titles | P2 | 不再做新 NER 主版本（D-route §7 Sunset）| 永不（或跨领域案例方需要时复用方法）|
| **T-P2-006** dry_run_report 通用 guard label | P2 | 案例改进，不属框架抽象 | 框架抽象 dry-run 部分时一并处理 |
| **T-P2-007** mention 段内位置切分 | P2 | 案例数据完整度改进 | sunset 候选 |
| **T-P2-008** V12 invariant（同号异人）| P2 | 已是 backlog；触发条件 ≥2 例同号异人 | 不主动启动 |
| **T-P1-005** unify migration entrypoint | P1 | 工程改进 | DevOps 维护模式时 batch 处理 |
| **T-P1-006** pipeline replay smoke framework | P1 | 与框架抽象部分重叠 | Sprint L Track 1 抽象中可能涵盖 |
| **T-P1-008** union-find cluster validation | P1 | 案例验证细节 | 与 V11/V12 一同处理 |
| **T-P1-010** resolver R2 pre-filter | P1 | 算法优化 | 框架抽象 identity resolver 时一并审 |
| **T-P1-017** source_evidence multi-source | P1 | 数据模型扩展 | sunset 候选 |
| **T-P1-018** backfill auto-trigger | P1 | 工程改进 | sunset 候选 |
| **T-P1-019** ambiguous slugs DB migration | P1 | schema 改进 | sunset 候选 |
| **T-P1-020** name resolution shared module | P1 | 与框架抽象部分重叠 | Sprint L Track 1 抽象中可能涵盖 |
| **T-P1-021** canonical merge missed pairs | P1 | 案例数据修订 | sunset 候选 |
| **T-P1-027** disambig seeds 楚汉扩充 | P1 | 案例字典扩充 | sunset 候选（D-route 不再做新 NER 字典批次）|
| **T-P0-028.V1.1 列表过滤 / Hint reason 摘要 / template 折叠**（来自 Hist Stage 5 反馈）| P1 | UX 优化 | 如 Sprint L Track 2 demo 真有用户使用反馈 |

---

## 4. ⚪ Sunset（永不主动启动）

下面这些 task 卡的方向已被 ADR-028 / D-route §7 明确 sunset。它们仍然在 git history 中，作为"项目演化的真实记录"保留，但不再推进。

| Task ID | Sunset 理由 | 何时可重启 |
|---------|-----------|-----------|
| **T-P1-007** 桓公 person split | 案例数据修订（同名异人具体案例），不属框架优先 | 跨领域案例方需要类似 split 时复用方法 |
| **T-P1-009** NER compound name guard | 与 NER 主版本相关 | 永不（D-route §7 Negative Space）|
| **T-P1-016** wei-zi slug mismatch | 案例数据修订 | 永不 |
| **T-P1-022** V1 at-least-one-primary debt | 已有 V9 invariant 覆盖 | 已隐含完成 |
| **T-P1-023** unique index naming alignment | 工程改进 | 永不（D-route 不卷数据库底层细节）|
| **T-P1-024** tongjia 扩充 | 案例字典扩充 | 永不 |
| **T-P1-025** 重耳↔晋文公 merge | 案例数据修订 | 永不（textbook-fact 案例已积累，不需要再单独 merge）|
| **T-P1-026** disambig seeds 跨朝代 | 案例字典扩充 | 永不 |
| **T-P1-013** V6 alias is_primary cleanup | 已隐含完成 | 永不需要重启 |
| **T-P1-014** 武王 persons merge audit | 已隐含完成 | 永不 |
| **T-P0-028.V2 batch decisions / DONE queue / etc** | 是 V2 候选，但 D-route 不做 V2 → 等 Layer 4 商业化才考虑 | 永不在 D-route 主线推进；可作 V2 模板供跨领域案例方参考 |

---

## 5. 衍生债重整

### 5.1 既有 debts/（5 个文件）

| File | 状态 | D-route 处置 |
|------|------|------------|
| T-P0-006-beta-ctext-filter.md | 历史 debt（β 尚书）| 保留为案例素材 |
| T-P0-006-beta-followups.md | 历史 debt | 保留为案例素材 |
| T-P1-001-test-isolation.md | 工程改进 debt | 降级 P3（QA 维护模式 batch）|
| T-P1-004-ner-single-primary.md | 已隐含完成（ADR-024）| 保留为已完成 |
| T-P1-005-migration-entrypoint.md | 工程改进 debt | 降级 P3（DevOps 维护模式 batch）|

### 5.2 Sprint K 新增衍生债

来自 `docs/sprint-logs/sprint-k/stage-6-closeout-2026-04-29.md` §3：

- **T-P0-028.V1.1**（列表过滤已决策 item）— P0 候选，但 D-route 不直接做（Triage UI V1 zero-downstream 是设计意图）→ 降级 P3
- **T-P0-028.V1.1.b**（Hint Banner reason 摘要）— P1 候选 → P3
- **T-P0-028.V1.1.c**（6 quick template 折叠）— P2 → P3
- **T-P0-028.V2.a**（批量决策）— V2 候选 → 永不在 D-route 主线推（参见 §4 Sunset）
- **T-P0-028.V2.b**（DONE 队列页 + recentTriageDecisions query）— V2 候选 → 同上
- **T-P1-032**（provenance_tier sync）— BE 提出，与框架抽象部分重叠 → 框架抽象 audit pattern 时一并审
- **T-P3 跨 sprint 历史学家裁决估算方法学修订** — D-route 框架抽象时纳入 docs/methodology/05-audit-trail-pattern.md v0.2 迭代

### 5.3 D-route 衍生债处理原则

- **不主动开新 sprint** 处理衍生债
- **每个 Sprint Brief §X "对框架抽象的产出预期"段** 可包含"借机处理 1-2 个相关衍生债"
- **每季度** 架构师做一次 backlog scan，把"持续 6+ 个月没动" 的 P3 衍生债转为 sunset

---

## 6. Sprint L 启动前 checklist

Sprint L brief 已起草（`docs/sprint-logs/sprint-l/stage-0-brief-2026-04-29.md`），其中：

- ✅ Track 1 / Track 2 主线对应 §2 D-route 契合 task
- ✅ Negative scope（不做的事）对应 §3 降级 + §4 Sunset 清单
- ✅ Stop Rules 显式列出"违反 D-route 原则"的中止条件

→ Sprint L 启动 = 本分类生效。

---

## 7. 修订机制

本分类每**两个月**审一次（架构师），更新内容：

- 新完成的 task 加入 §1 已完成
- 新触发的衍生债加入 §5.2
- 持续 6+ 月 P3 中没动的 task 转入 §4 Sunset
- 跨领域案例方接触 → 重启某些 §4 Sunset task

---

**本文件起草于 2026-04-29 / Stage D-3 of D-route doc realignment**
