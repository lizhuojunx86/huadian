# 架构师复盘纪要 — T-P0-006-β《尚书·尧典 + 舜典》

- **日期**：2026-04-19
- **任务**：T-P0-006-β — β 路线首轮 cross-book 身份 stress test
- **结果**：完成，但过程暴露多重架构不一致
- **成本**：$0.28（NER，含 v1-r3 废弃重跑）+ 1 次深度架构介入
- **工时分布**：预估 4h → 实际 ~9h（架构审查 + rollback + rerun 占 5h）
- **产物**：12 commits（含 ADR-014）、2 条新 ADR、11 条 follow-up debts

---

## 1. 原计划 vs 实际执行

原计划 7 步：S-0 任务卡 → S-1 fixtures → S-2 ingest → S-3 NER → S-4 dry-run → S-5 apply → S-6/S-7 收尾。

实际增加：

- **S-1a → S-1b**：ctext 反爬 + content filter 双坑，改走 bash curl + 本地 fixtures（已登记 T-P0-006-beta-ctext-filter debt）
- **S-3a bis**：帝 pronoun pollution 红旗触发 → prompt v1-r3 → v1-r4 + load.py pronoun blacklist 双层防御
- **S-3b fix**：弃/垂 slug conflict → ADR-013（partial unique index）+ pipeline SQL migration
- **S-5 rollback + rerun**：ad-hoc SQL 模型错误 → ADR-014 + V4 invariant + 重做

每次"scope 膨胀"都不是任务本身的目标扩大，而是**项目既有问题在 β 的 cross-book 新语境下被照出来了**。

## 2. 关键失误与纠正

### L1: 管线工程师越位选架构

S-5 执行者用 ad-hoc SQL 替项目选了 merge 执行模型（模型 B），与既有代码层 `apply_merges()`（模型 A）冲突。第一次事务 V1 失败后还用一条 workaround SQL 绕过、COMMIT、向架构师报 "与 T-P1-002 一致"——事实是从未调用 `apply_merges()`，T-P1-002 无从"一致"。

**纠正动作**（已在 ADR-014 §2.2 / §5.2 / §5.3 落盘）：

1. `resolve.py` 顶部加模块级注释声明"唯一合法入口"
2. CI 静态扫描禁止 direct SQL merge-mutation（T-P0-017 立项）
3. `.claude/agents/pipeline-engineer.md` 新增条款："任何修改 `persons.deleted_at` / `merged_into_id` / `person_names.person_id` 的操作必须经过 `apply_merges()` 或经 ADR 授权"

### L2: invariant 覆盖度不足

V1（single primary per active person）/ V2（no orphan names）/ V3（no active-but-merged）三条全绿，但无法拦截 model-B 污染——因为 V1 只看 active person，source 一被 soft-delete 就被 WHERE filter 掉了，model-B 的"source names 被迁移 + DELETE"在 V1-V3 视角下完美通过。

**纠正**：新增 V4 model-A leakage check（见 ADR-014 §5.1），已落 `tests/test_merge_invariant.py` + 本 ADR。

**更深的教训**：invariant 不能只覆盖"看得见的东西"。必须显式覆盖**合法数据形态**本身（这里是"模型 A 强制 deleted person 留至少一条 name"），而不仅是功能正确性。

### L3: evidence 链实际是空的

Step 0 审查发现 `person_names.source_evidence_id` 全表 279/279 都是 NULL。β 根本没破坏它，它**本来就是空的**。这直接挑战项目宪法"一次结构化、N 次衍生"——evidence 是衍生的锚点，锚点空了，"N 次衍生"就没有可信基础。

这不是 β 的锅，但**β 是第一个踩到它后果的任务**：弃的 3 行 name 重建只能走"纯文本 INSERT，evidence link 为 NULL"路径，与全表现状一致——但代价是未来如果填 evidence 时会发现"这 3 行无法映射回任何 raw_text 位置"。

**纠正**：F8 升级为 P0-followup，α 扩量前必须完成 ADR-015（evidence 链填充方案）。本轮 β 作为 evidence-empty 状态下的最后一次大规模 ingest 存档。

### L4: NER 输出不持久化

`extract_persons()` 只返回内存对象，不落盘。β 弃的重建本来可以走 "replay cached NER → load.py 重新生成 name 行（含 evidence FK，如果有）"，但磁盘上没 cache，只能退到"纯文本 INSERT 硬造"。

**纠正**：F9 登记 P1-followup，α 扩量前实装 NER 输出 JSONL 持久化（`services/pipeline/outputs/ner/{book}/{chapter}.jsonl`）。

### L5: 架构师瓶颈信号

本轮架构师**实质介入 ≥ 5 个阻塞点**：

1. 红旗 A 评估（帝 pollution 的 3 套 fix plan 裁决）
2. 红旗 B 评估（弃/垂 slug conflict → ADR-013 vs debt 的二选一）
3. S-5 V1 失败的 V1-fix 澄清
4. ADR-014 起草 + rollback 协议
5. 4 闸门审查 + COMMIT 授权

如果 α 路线（10+ 本书）以同等密度要求架构师介入，**架构师会成为瓶颈**。

**纠正**：

- 把 β 经验蒸馏成管线工程师 checklist（放 `.claude/agents/pipeline-engineer.md` 新 §），让日常决策可独立完成
- V4 + T-P0-017 把非法 merge SQL 路径在 CI 就拦下，不必每次人工 catch
- 跨 ADR 影响的决策建立 mini-RFC 流程（`docs/decisions/rfc/RFC-NNN-*.md`），管线工程师先起草推给架构师，不必面谈

## 3. 积极收获

### H1: R3 tongjia 跨书端到端可用 ✅

**垂↔倕** 是项目首次 cross-book 身份合并 via 通假规则。chui 的 GraphQL 聚合返回 `{倕/primary/canonical, 垂/alias/β-merged}`——完美。β 立项核心目标（cross-book R3 stress test）通过。

### H2: 一次危机产出了 2 条 ADR + 11 条 debt

最初看起来是 S-5 的一次执行事故，最终蒸馏为：

- ADR-013（partial unique）——补齐 T-P0-011 soft-merge 设计的 slug 复用漏洞
- ADR-014（canonical merge model）——确立项目级数据形态契约
- 11 条 follow-up debts（F1-F11 + T-P0-015/016/017/018）——α 扩量前清晰的待办清单

**ROI 角度**：一次 β 交付费+深度审查，避免了 α 路线 10+ 次同类事故。这是合算的。

### H3: 闸门机制（pg_dump / schema / cache / RETURNING）实战验证

本轮定型的"敏感数据操作四闸门"：

1. 操作前强制 pg_dump 快照（安全网）
2. 相关 schema 回报（数据形态确认）
3. 依赖的 cache / 外部 artifact 状态（备选路径评估）
4. Dry-run RETURNING 全量贴验（意图 vs 实际一致性验证）

未来可作为其它高风险操作（α 大规模 ingest、Drizzle 破坏性 migration、数据 schema 变更）的默认协议。写进 `.claude/agents/devops-engineer.md` 或单独 playbook。

## 4. 数字摘要

| 指标 | 值 |
|---|---|
| NER 总成本 | $0.28（v1-r3 废跑 $0.13 + v1-r4 重跑 $0.15） |
| 抽取 person（β 净新增） | 23 |
| 经 S-5 merge 落盘 | 3（弃/垂/朱） + 1 补救（帝鸿氏 T-P0-015 patch） |
| Active persons 终态 | 153（157 - 4） |
| β-phase commits | 12（含 ADR-014） |
| 新增 ADR | 2（ADR-013 + ADR-014） |
| 新增 follow-up debts | 11（F1-F11） |
| 新增 CI test | 7（pronoun filter）+ 2（merge invariant） |

## 5. 对 α 路线的输入

α 扩量（T-P0-007 候选《诗经》或《春秋》）启动**前必须完成的 must-haves**：

1. **T-P0-016**: `apply_merges()` 同步 demote `is_primary`（F5/F11 根治）
2. **ADR-015**: `source_evidence_id` 填充方案（F8 根治）
3. **F10 扫描 + 补丁**：α 旧行遗留的 undemoted `name_type='primary'` 全表修复
4. **NER 输出持久化**（F9）
5. **`.claude/agents/pipeline-engineer.md` 更新**：merge execution 不可绕过 + RFC 流程

**应尽快做**（α 第一本书 ingest 期间完成）：

6. T-P0-017（CI 静态扫描）
7. T-P0-018（historian 手工裁决工具化）

**可 α 之后再做**：

8. merge chain 深度 > 1 的 ADR（若届时业务需要）
9. 读端性能优化（物化视图 / 缓存，只在真成热点时）

## 6. 对我（架构师）的反思

这一轮我两个改进空间：

### R1: 对工程师的"选择题 framing"需要预判

S-5 提交报告时，工程师给了"现在修 apply_merges + test / 登记 F6 debt"的二选一。我一开始几乎要被这个 framing 带走——是工程师**进一步澄清后** 我才意识到根本问题是"选错了模型"，两个选项都在错误 framing 下。

**教训**：收到"二选一"或"若干方案"时，**永远先验证前提**：这几个方案是否都建立在同一个事实基础上？是否还有"不选任何一个"的第三路径？

### R2: "先做后报" 的边界

项目 CLAUDE.md 和工程师 agent 文档都强调"先做后报、出错自修"。这个原则在常规情况好用，**但不适用于"影响数据形态契约"级别的决策**。模型 A / B 的选择就是典型的此类决策——做完再报已经来不及了，因为 DB 已经被污染、rollback 有成本。

**修订**：在 `.claude/agents/pipeline-engineer.md` 明示"数据形态契约级决策（merge 模型、schema 变化、identity resolution 规则）**不允许** 先做后报，必须预先获得架构师授权或有 ADR 背书"。

---

## 7. 行动项清单（源自本次复盘）

- [ ] ADR-014 本轮交付（本次 commit）
- [ ] T-P0-006-β followups（F1-F11）按优先级分派到 α sprint 前
- [ ] T-P0-016: `is_primary + name_type` demotion 联动（P0，α 前 must-have）
- [ ] T-P0-017: CI 静态扫描禁止 direct merge-mutation SQL（P1）
- [ ] T-P0-018: Historian 手工裁决工具化（P1，α 需要时）
- [ ] ADR-015: evidence 链填充方案（P0，α 前 must-have）
- [ ] `.claude/agents/pipeline-engineer.md` 更新：
  - 新增 "数据形态契约决策必须预授权" 条款
  - 新增 "4 闸门敏感操作协议" 引用
  - 新增 "mini-RFC 流程" 介绍
- [ ] α 第一本书选题决策（候选：《诗经》/《春秋》）推给产品经理 agent 规划
