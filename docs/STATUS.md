# 华典智谱 · 项目状态板

> **本文件是项目的"现在时刻"快照，每次会话开始 / 结束都应阅读或更新。**

- **最近更新**：2026-04-30（Sprint O 完成 + 关档；Layer 1 第四刀 / 治理 + 代码层 4 模块完整 / dogfood PASSED 11/11 + 4/4）
- **更新人**：首席架构师（Claude Opus 4.7）
- **战略方向**：**D-route — Agentic Knowledge Engineering 框架 + 史记参考实现**（详见 [ADR-028](decisions/ADR-028-strategic-pivot-to-methodology.md) + [strategy/D-route-positioning.md](strategy/D-route-positioning.md)）
- **当前阶段**：Phase 0 已收尾 / D-route 文档体系全对齐 / **Sprint O 完成（Layer 1 第四刀 / framework 4 模块完整 / v0.2 release 候选条件成熟）** / Sprint P 候选准备（推荐 v0.2 patch sprint）

---

## 1. 战略快照（D-route，2026-04-29 落地）

| 维度 | 当前状态 |
|------|---------|
| 项目身份 | Agentic KE 工程框架 + 华典智谱史记参考实现（**不是** C 端古籍 App）|
| 仓库形态 | GitHub public（https://github.com/lizhuojunx86/huadian）|
| 许可证 | 代码 Apache 2.0 / 数据·文档·方法论 CC BY 4.0（详见 [ADR-029](decisions/ADR-029-licensing-policy.md)）|
| 4-Layer 路线 | L1 框架抽象（6-12mo）/ L2 方法论文档（12-18mo）/ L3 案例库（持续）/ L4 社区机会主义 |

### 1.1 D-route Layer 进度

| Layer | 状态 | 当前焦点 |
|-------|------|---------|
| L1 框架代码抽象 | **🟢 治理类双模块 + 代码层双刀 / 4 模块完整**（Sprint L+M+N+O 完成）| sprint-templates v0.1.1 + role-templates v0.1.1 + identity_resolver v0.1 + **invariant_scaffold v0.1**（共 86 files / ~10700 lines + docs）；下一步 Sprint P 推荐 v0.2 patch sprint（清债 + release）|
| L2 方法论文档 | 🟡 草案 v0.1 完整 + 4 份 cross-reference 紧密化 | docs/methodology/ 7 份草案（约 4 万字）；methodology/01 + 02 + 03 + **04** v0.1 → v0.1.1 cross-reference；下次迭代等 Sprint P 反馈 |
| L3 案例库 | 🟢 主案例 + demo + 4 sprint dogfood 实证 | 史记 3-4 篇本纪 + RB-002 demo + Sprint K 99.2% + Sprint N byte-identical + **Sprint O 11 invariants + 4 self-tests catch** |
| L4 社区 / 商业 | ⚪ 未启动 | framework v0.2 release 候选条件**完全成熟**（4 抽象资产稳定 + byte-identical + soft-equivalent 双 dogfood + 20 v0.2 候选）；建议 Sprint P 清债后正式 release |

---

## 2. 当前焦点（这周）

### 2.1 文档体系对齐 — Stage A → D（已全部完成）

| Stage | 状态 | 产出 |
|-------|------|------|
| Stage A — 战略锚点 | ✅ 完成 | ADR-028 + docs/strategy/D-route-positioning.md |
| Stage A.5 — 许可证 + public-facing | ✅ 完成 | LICENSE / LICENSE-DATA / NOTICE / README / CONTRIBUTING / ADR-029 + ADR-028 §6 + CLAUDE.md §1 |
| Stage B — 核心身份文档 | ✅ 完成 | CLAUDE.md / 项目宪法（C-22~C-25）/ STATUS.md / 架构 v2.0（v1.0 归档）|
| Stage C — 操作文档 + methodology 草案 | ✅ 完成 | 03/04/05 加框架视角 + docs/methodology/ 7 份草案（约 4 万字）+ 10 角色加框架抽象段 |
| Stage D — Sprint 规划重置 | ✅ 完成 | Sprint K closeout + Sprint L brief + 任务卡三分类 + sprint-roadmap-D-route + CHANGELOG |

### 2.2 Sprint L 进度（Layer 1 第一刀，已完成 Stage 1 + 4，关档）

| Stage | 状态 | 产出 |
|-------|------|------|
| Stage 0.1 用户测试 | ✅ | "假装新协作者"5 分钟测试通过 |
| Stage 0.2 架构师 inventory | ✅ | stage-0-inventory（抽象优先级排序 + 案例耦合点）|
| Stage 0.3 demo 形态 ACK | ✅ | 选 B（本地 dev + README Quick demo）|
| Stage 1 Track 1 sprint-templates v0.1 | ✅ | framework/sprint-templates/ 11 files / 1500 lines |
| Stage 1 Track 1 dogfood | ✅ | 模板覆盖度 90% / 4 项 v0.2 迭代登记 |
| Stage 1 Track 2 demo walkthrough | ✅ | RB-002 + README Quick demo 段 |
| Stage 2-3 外部审 | ⚪ 押后 | 等外部反馈触发（无紧急 timeline）|
| Stage 4 Closeout + Retro | ✅ | stage-4-closeout + sprint-l-retro + 衍生债登记 |

### 2.2.1 Sprint M 进度（Layer 1 第二刀，已完成 Stage 0 + 1 + 4，关档）

| Stage | 状态 | 产出 |
|-------|------|------|
| Stage 0.1 brief 起草 | ✅ | stage-0-brief（11 段 / dogfood brief-template 第二次外部使用 / DGF-M-01~03 已识别）|
| Stage 0.2 inventory | ✅ | stage-0-inventory（10 角色文件领域耦合扫描 / Sprint K 实战数据提取 / 起草顺序 / 工作量预估）|
| Stage 1 起草 framework/role-templates/ | ✅ | 13 files / ~2200 lines（10 角色模板 + tagged-sessions-protocol + cross-domain-mapping + README）|
| Stage 1 dogfood | ✅ | stage-1-dogfood — 总覆盖度 99.2% / DGF-M-04~07 登记 |
| Stage 1 cross-reference | ✅ | docs/methodology/01 v0.1 → v0.1.1（§9 Framework Implementation 段加）|
| Stage 2-3 外部审 | ⚪ 押后 | 等外部反馈触发（无紧急 timeline）|
| Stage 4 Closeout + Retro | ✅ | stage-4-closeout + sprint-m-retro + 衍生债登记（7 项 P3）|

### 2.2.2 Sprint N 进度（Layer 1 第三刀 / 代码层第一刀，已完成 Stage 0+1+1.13+4，关档）

| Stage | 状态 | 产出 |
|-------|------|------|
| Stage 0.1 brief | ✅ | stage-0-brief（11 段 / brief-template 第 3 次外部使用）|
| Stage 0.2 inventory | ✅ | stage-0-inventory — 6 .py / 2394 行扫描 + 9 plugin protocol 设计 |
| Stage 1 第 1-3 批 framework core | ✅ | 13 files / ~2280 lines / 10 sanity tests pass |
| Stage 1 第 4 批 examples | ✅ | 14 files / ~1440 lines |
| Stage 1 第 5 批 docs | ✅ | README + CONCEPTS + cross-domain-mapping |
| **Stage 1.13 byte-identical dogfood** | ✅ **PASSED** | 729 person production data 100% 等价（17 guard 拦截一一对应）；Stop Rule #1 临时触发 2 次都修复 |
| Stage 2-3 外部审 | ⚪ 押后 | 等外部反馈触发 |
| Stage 4 Closeout + Retro | ✅ | stage-4-closeout + sprint-n-retro + 衍生债登记（5 项 P3）|

### 2.2.3 Sprint O 进度（Layer 1 第四刀 / framework 4 模块完整，已完成 Stage 0+1+1.13+4，关档）

| Stage | 状态 | 产出 |
|-------|------|------|
| Stage 0.1 brief | ✅ | stage-0-brief / brief-template 第 4 次 |
| Stage 0.2 inventory | ✅ | stage-0-inventory — 7 测试文件 / 1031 行扫描 + 10 invariants → 5 pattern map |
| Stage 1 第 1-3 批 framework core | ✅ | 18 files / ~1335 lines / 10 sanity tests pass |
| Stage 1 第 4 批 examples | ✅ | 13 files / ~946 lines |
| Stage 1 第 5 批 docs | ✅ | 3 files / ~759 lines |
| **Stage 1.13 dogfood** | ✅ **PASSED** | 11/11 invariants + 4/4 self-tests / 修 1 path bug |
| Stage 2-3 外部审 | ⚪ 押后 | 等外部反馈触发 |
| Stage 4 Closeout + Retro | ✅ | stage-4-closeout + sprint-o-retro + 衍生债（4 项 / 1 P2 升级）|

### 2.3 阻塞 / 风险 / 等待项

- 无阻塞。Sprint O 关档。
- Sprint P 候选主题（推荐顺序）：
  - **A. v0.2 patch sprint**（推荐 / 清 14 项待办 + 优先 P2 DGF-O-01 path bug）
  - B. framework v0.2 公开 release（在 A 完成后做）
  - C. Sprint Q audit_triage 抽象（推迟到 v0.2 release 后）
- framework v0.2 release 候选条件**完全成熟**（4 模块 + 双 dogfood + 20 候选），建议 Sprint P 清债后 release。

---

## 3. 当前数据 / 工程基线（Sprint K 完成时刻）

### 3.1 DB 数据状态

| 维度 | 数值 | 备注 |
|------|------|------|
| Active persons | **729** | Sprint J 收口数 |
| merge_log entries | **111** | Sprint A-J 累计 9+9+...+19 merges |
| pending_merge_reviews | **18** rows | Sprint K Stage 2 PE backfill 写入；2 行已被 Hist Stage 5 决策（reject）|
| triage_decisions | **177** rows | 175 backfill + 2 Hist E2E 真决策（1 reject + 1 approve）|
| seed_mappings (pending_review) | **45** | Sprint G/H/I/J 累积，等 Hist 处理 |
| entity_split_log | **2 rows** | 楚怀王 entity-split (Sprint H) |
| V1-V11 invariants | **22 / 22 全绿** | 0 回归 |

---

## 4. Sunset / 降级 方向（D-route 不再做的事）

依据 D-route §7 Negative Space：

| 方向 | 状态 |
|------|------|
| C 端古籍阅读 App（核心产品形态）| ⚪ Sunset |
| 移动端（iOS / Android）| ⚪ Sunset |
| 与字节识典古籍同等数据完整度 | ⚪ Sunset |
| 古人模拟器 / 断案游戏 / 跨时空群聊 | ⚪ Sunset（永不主动启动）|
| 自建 frontend 组件库 / UI design system | ⚪ Sunset |
| 大规模数据 ingest（>20 篇章节）| ⚪ Sunset |
| DAU 增长 / 用户留存指标 | ⚪ Sunset |
| 抢首发"首个 X 框架"叙事 | ⚪ Sunset |
| 完成史记 130 篇 | ⚪ Sunset（5-10 篇典型即停）|

---

## 5. 下一步（Sprint L 候选议程）

Sprint L brief 待 Stage D 起草。预期主题（per ADR-028 §2.3 Q3 ACK）：

> **Sprint L = 框架抽象第一刀 + 产品化 demo 双 track**

候选议程项：

- **Track 1 — 框架抽象第一刀**：识别 Sprint A-K 代码里 P0 抽象优先级（Sprint workflow / multi-role / ADR / V1-V11 / identity resolver / triage UI）中**最成熟的 1-2 个**做第一次抽象 spike，写到 docs/methodology/ + framework/ 草目录
- **Track 2 — 产品化 demo**：把现有 729 active persons + 几篇本纪 + identity merge 案例 + triage UI workflow 接出一个对外可看的极简 demo，作为"框架真的 work"的活体证明
- 候选**不**走的方向：
  - ❌ 不再启动新 ingest sprint（违反 ADR-028 Q1 + C-22）
  - ❌ T-P1-030 ADR-014 addendum 不是 D-route 优先（虽然 textbook-fact 已 4 例触发；可降级到 P3 backlog）

---

## 6. 历史档案 — Phase 0 完整阶段标签（保留作为方法论案例库素材）

> 以下是 Sprint A-K 完成时的"phase 标签"，保留作为框架抽象验证素材（C-22 / C-23）。
> 详细 sprint 内容见 `docs/sprint-logs/sprint-{a..k}/`。

**Phase 0 (2026-04-15 ~ 2026-04-29) 完成清单**：DB Schema ✅ / 字典批次 1 ✅ / TraceGuard Adapter ✅ / GraphQL 骨架 ✅ / LLM Gateway ✅ / API Person Query ✅ / Web MVP Person Card ✅ / Web Person Search/List ✅ / Pipeline 基础设施 ✅ / 真书 Pilot ✅ / 跨 chunk 身份消歧 ✅ / Web 首页 + 全局导航 ✅ / 非人实体清理 ✅ / 帝鸿氏归并 ✅ / β 尚书摄入 ✅ / F10 残留 demote ✅ / persons CHECK 约束 ✅ / is_primary 同步 ✅ / 证据链 Stage 1 ✅ / α 周本纪扩量跑 ✅ / α 证据链主回填 ✅ / Sprint A 尾巴清零 ✅ / Sprint B Wikidata Seed Loader ✅ / Sprint C Resolver Orchestration ✅ / Sprint D R6 Cross-Dynasty Guard ✅ / Sprint E 秦本纪 ✅ / Sprint G 项羽本纪 ✅ / Sprint H R1 Pair Guards + 楚怀王 Entity-Split ✅ / Sprint I state_prefix_guard ✅ / Sprint J 高祖本纪 ✅ / Sprint K T-P0-028 Triage UI V1 ✅

---

## 7. 归档：Sprint K 之前的"当前在哪"快照（D-route 转型前视角）

> 以下为 D-route 战略转型（2026-04-29）之前的"当前在哪"内容，保留为历史快照。
> 真正的"当前焦点"以 §2 + §5 为准。
> §下一步候选 行已被 §5（Sprint L 候选议程）替代，请勿据此规划新工作。

**Sprint J 完成（2026-04-28）。T-P0-006-ε 高祖本纪 ingest + identity resolution：+85 NER persons（663→748→729 active）/ 19 soft-deletes（9 confirm + 2 textbook-fact + 6 slug-dedup + 2 G7 sub-merges）/ merge_log 92→111 / R1 FP 治理率 100%（state_prefix_guard 7/7）/ V1=0 V9=0 V10=0 V11=0 全绿。S4.3' 新增 _swap_ab_payload() bug fix（guard_payload dynasty/state 列位 transpose）+ 5 regression tests。textbook-fact 累计 4 例 → T-P1-030 ADR-014 addendum 触发。0.79 LLM / 0 migrations / 5 new tests。**

Sprint I 完成（2026-04-28）。state_prefix_guard 上线（ADR-025 §5.3）：data/states.yaml 17 国 / 4 alias，GUARD_CHAINS 替换单 guard dispatch，R1 chain=[cross_dynasty(200), state_prefix]。干跑 663 active persons：16 总拦截（9 cross_dynasty + 7 state_prefix）。新增 54 测试全绿（Sprint H 28 + Sprint I 17 state_prefix + 9 其他）。ADR-025 §5.3 addendum accepted（架构师签字 2026-04-28）。$0 LLM / 无 schema 变更 / 无 migration。**

Sprint H 完成（2026-04-27）。T-P1-028 R1 dynasty 前置过滤上线（ADR-025 evaluate_pair_guards rule-aware 接口；R1=200yr / R6=500yr）+ T-P0-031 楚怀王 entity-split 数据校正（ADR-026 Entity Split Protocol 首应用；2 split_for_safety person_names INSERTs）。ADR-014 §2.1 footnote 引入 ADR-026 例外。dynasty-periods.yaml 9 mappings 合流 Hist Track B 学术复核（春秋战国 -442 / 秦末汉初 -206 / 战国国别 future-risk）。Active persons 663 / V1-V11 全绿 / entity_split_log +2 行 / migration 0013。V12 评估为 backlog（T-P2-008，需 schema 变更）。

Sprint G 完成（2026-04-26）。T-P0-006-δ 项羽本纪完整 ingest（45 段 / +117 NER persons / $0.60）+ Stage 4 apply（9 merges）。textbook-fact precedent 2/3（G15 项籍→项羽）。

Sprint D（T-P0-029）完成：R6 merge 检测新增跨朝代 temporal guard。

Sprint B 全 Stage 完成：
- **Gate 0a（✅）**：Wikidata probe 54.4% 命中 → ≥40% 桶
- **Stage 0b（✅）**：migration 0009 三表 + Drizzle J layer
- **Stage 1（✅）**：wikidata_adapter + matcher（R1/R2/R3 三轮）+ CLI dry-run/execute
- **Stage 2（✅）**：execute 写入 159 active + 44 pending_review + 159 source_evidences(seed_dictionary) + migration 0010 pending_review CHECK
- **Stage 3（✅）**：R6 seed-match 规则（153 matched / 6 below_cutoff / 44 filtered）+ ADR-010 §R6 落地
- **Stage 4（✅）**：V10 invariant 三子规则（orphan target / orphan entry / active evidence）+ 6 self-tests
- **Stage 5（✅）**：migration 0011 unique index 对齐 + ADR-021 final + Sprint 收口

~~**下一步候选**：高后本纪 ingest（Sprint K 候选）/ T-P1-030（ADR-014 addendum textbook-fact 规范）/ T-P0-028（pending_review triage UI）/ T-P2-006（dry_run_report R6 标签泛化）/ T-P1-027 增项（塞王欣 surface + 齐王 5 候选）~~

**注（2026-04-29）**：此"下一步候选"列表已**作废**。其中 T-P0-028 已在 Sprint K 完成；其余项已被 D-route 战略转型重排：高后本纪 ingest 不再启动（违反 C-22 案例服务于框架），T-P1-030 / T-P2-006 / T-P1-027 降级到 P3 backlog。当前真正的"下一步"以 §5 为准。

---

## 已完成

### Sprint I — state_prefix_guard（2026-04-28）

- [x] **ADR-025 §5.3 addendum accepted**：架构师签字 2026-04-28；6 checkbox 全填 + 额外裁决 A（周不纳入）/B（邾/莒/巴不纳入）
- [x] **data/states.yaml**：17 国 + 4 alias（晋/唐、楚/荆、吴/句吴攻吴、越/於越）；周/邾/莒/巴 per 裁决排除
- [x] **state_prefix_guard.py**：blocks R1 merges when both names match (state)(shihao)(title) with different canonical states；alias 归一；裸谥号单方 fall-through；lazily imports GuardResult 避免循环依赖
- [x] **GUARD_CHAINS 重构**：evaluate_pair_guards 从 single-guard dispatch → chain iteration；R1=[cross_dynasty(200), state_prefix]；R6=[cross_dynasty(500)]；resolve.py:480 零改动
- [x] **测试**：17 state_prefix 测试（ADR §5.3.9 #1-7 全覆盖）+ Sprint H 28 回归 = **54 全绿**；test_evaluate_pair_guards §2.6 #2 更新为同国对
- [x] **Stage 3 dry-run**：663 persons → 16 总拦截（9 cross_dynasty + 7 state_prefix）；7 state_prefix 全为"春秋同朝代不同国"gap=0 case；预测 ~10，实际 7（70%，Stop Rule #3 不触发）
- 结果：Active persons 663（不变）/ merge_log 92（不变）/ guard 拦截 8→16 / V1-V11 全绿（干跑验证）
- 衍生债：T-P2-006（dry_run_report R6 label 泛化）/ evaluate_guards deprecated 包装 Sprint J 收口删除 / T-P2-010（NER prompt 国名前缀识别质量提升）
- 累计：4 commits（C1=ADR §5.3 sign-off / C2=Stage 2 impl / C3=S3 dry-run / C4=closeout）/ 0 migrations / 26 new tests / $0 LLM

### Sprint H — R1 Pair Guards + 楚怀王 Entity-Split（2026-04-26 ~ 2026-04-27）

- [x] **T-P1-028（R1 dynasty 前置过滤）**：ADR-025 evaluate_pair_guards rule-aware 接口（R1=200yr / R6=500yr）+ pending_merge_reviews 集成 + 6 单元测试（共 28 含 R6 既有）+ Stage 2 dry-run 663 active persons 8 拦截（1.14× 单章预测，Stop Rule #3 不触发）
- [x] **T-P0-031（楚怀王 entity-split）**：ADR-026 Entity Split Protocol 首应用；2 split_for_safety person_names INSERTs（target=熊心 entity）；source 楚怀王 entity 3 行不动；entity_split_log 2 audit 行；V1-V11 全绿；pg_dump anchor `52bd6f91da5c`
- [x] **ADR-026 落地**：accepted（10 决策点架构师签字 = 6 原 + 4 澄清）；ADR-014 §2.1 footnote 引入；migration 0013 entity_split_log 表 + Drizzle schema sync
- [x] **dynasty-periods.yaml 合流 Hist Track B**：9 mappings 学术复核合流（3 项采纳：春秋战国 -442 / 秦末汉初 -206 / 战国国别 future-risk）；yaml 头加 floor "rounding away from zero" convention
- [x] **V12 评估**：Stop Rule #5 触发（需 schema 变更）→ backlog T-P2-008（P2，触发条件 ≥2 例同号异人）
- [x] **lessons learned**：ADR audit 字段语义两义性（option P 文档澄清）；ADR-017 forward-only 在 0-row 新表场景的正确路径（ALTER TABLE via 新 migration，不 DROP+rebuild）
- 结果：Active persons 663（不变）/ person_names +2（target 熊心）/ entity_split_log 0→2 / merge_log 92（不变）/ V1-V11 全绿
- 衍生债：T-P2-006（dry_run_report R6 标签泛化）/ T-P2-007（mention 段内位置切分）/ T-P2-008（V12 invariant）/ T-P2-009（ADR-026 §3 第 5 闸门）/ T-P1-029 候选（惠公 entity 数据修复）
- 累计：13 commits / 1 migration（0013）/ 1 new audit table（entity_split_log）/ 1 new ADR（ADR-026）/ 1 ADR addendum（ADR-014 §2.1 footnote）/ 6 new tests / $0 LLM

### Sprint G — T-P0-006-δ 项羽本纪完整 ingest + identity resolution（2026-04-25 ~ 2026-04-26）
- [x] Stage 0：fixture + adapter + tier-s slug 楚汉扩充 + disambig prep
- [x] Stage 1-2：smoke + full ingest（45 段 / 117 NER persons / $0.60）+ Sprint F 修复验证（V1=0 / V9=0 on new data）
- [x] Stage 3：resolver dry-run（21 proposals）+ historian merge review（7 approve / 13 reject / 1 split）
- [x] Stage 4：apply_merges（9 soft-deletes：7 approve + 2 G13 sub-merges）+ V1-V11 全绿验证
- [x] Stage 5：task card + 3 debt stubs + STATUS + CHANGELOG + retro
- 结果：active persons 555→672→663 / merge_log 83→92 / V1-V11 全绿 / $0.60 LLM
- 核心发现：楚怀王 entity-level 同号异人（T-P0-031 P0 升格）/ Sprint F 修复真实验证通过
- textbook-fact precedent：G15 项籍→项羽（第 2 例，2/3 阈值）
- 衍生债：T-P1-027 / T-P1-028 / T-P2-005 + T-P0-031（P0 已存在 stub）
- 累计：3 commits (C31-C33) / 9 merges / $0.60 LLM / 0 new tests / 0 migrations

### Sprint F — V1 根因修复 + V9 invariant + 衍生债批清理（2026-04-25）
- [x] Stage 0：V1 +64 根因诊断（100% load.py，Bug 1 name_type 默认值 + Bug 2 is_primary 硬编码）
- [x] Stage 1：load.py _insert_person_names 修复（~15 行改动 + S1.3 函数级 guard + 3 tests）
- [x] Stage 2：94→0 回填（125 行 UPDATE 单事务 + pg_dump anchor）
- [x] Stage 3：V9 invariant 上线（ADR-024 + 3 self-tests + bootstrap=0）
- [x] Stage 4 小卡：T-P1-024（tongjia 缪/穆+傒/奚）+ T-P1-026（disambig_seeds 10 组）
- [x] Stage 4 大卡：T-P1-025（重耳↔晋文公 textbook merge → 555 active）+ T-P2-004（NER v1-r5 官衔+名）
- [x] Stage 5：验证（V1=0/V9=0/V10=0/V11=0）+ 收档
- 结果：V1 94→0 / V9 bootstrap=0 / active persons 556→555 / merge_log 82→83 / ADR-024 落地
- 核心修复：load.py Bug 1（name_zh 默认 primary → 92 duplicate）+ Bug 2（is_primary 硬编码 false → 33 desync）
- 衍生债：T-P1-022/024/025/026 + T-P2-004 全部 close
- 累计：8 commits / $0.163 LLM / 3 V9 tests + 3 Stage 1 tests / ADR-024 / NER v1-r5

### Sprint E Track B — T-P0-006-γ 秦本纪摄入 + identity resolution（2026-04-24 ~ 2026-04-25）
- [x] Stage 0：fixture + adapter + tier-s slug 扩列 + disambig prep
- [x] Stage 1-2：smoke + full ingest（72 段 / 266 NER persons / $0.83）
- [x] Stage 3：resolver dry-run（35 proposals）+ historian merge review（21 approve / 5 reject / 9 split）
- [x] Stage 4：apply_merges（29 soft-deletes：22 from 21 approve groups + 7 sub-merges）+ V10a seed_mapping redirect
- [x] Stage 5：task card + 4 debt stubs + STATUS + CHANGELOG + retro
- 结果：active persons 319→585→556 / merge_log 53→82 / V1-V11 全绿
- 核心发现：R1 跨国同名 false positive 严重（16/35 组），historian split 内 sub-merge 格式化效果好
- 衍生债：T-P1-024（tongjia 扩充）/ T-P1-025（重耳↔晋文公）/ T-P1-026（disambig_seeds 扩充）/ T-P2-004（NER v1-r5）
- 累计：5+2 commits / 29 merges / $0.83 LLM / 0 new tests / 0 migrations

### Sprint E Track A — T-P0-030 Corrective Seed-Add wei-zi-qi → Q855012（2026-04-24）
- [x] A0：Wikidata SPARQL 实时复核 Q855012（label=微子, description=商朝宗室宋国始祖, P31=Q5 — 与 historian ruling 98de7bc 一致）
- [x] A1-A3：4 闸门（pg_dump + schema + artifact）
- [x] A4：基线 SELECT（Q855012 不在 dictionary_entries / active seeds=158 / wei-zi-qi 已有 Q186544 pending_review）
- [x] A5-A6：dry-run RETURNING + 用户 ACK
- [x] A7：COMMIT（dictionary_entry + seed_mapping + source_evidence 三步同事务）
- [x] A8：V10(0/0/0) + V11(0) 全绿；active seed_mappings 158→159
- 结果：wei-zi-qi → Q855012 active / Q186544 保持 pending_review / 319 active persons 不变
- 累计：1 commit / 0 migrations / 0 new tests / $0 LLM / mapping_method='historian_correction'（新枚举值）

### Sprint D — T-P0-029 R6 Cross-Dynasty Guard（2026-04-24）
- [x] Stage 0：Phase 0 数据 inventory（persons.dynasty 100% / events 空 / dictionary_entries dateOfBirth 空 → 方案 α 选定）
- [x] Stage 1：migration 0012 pending_merge_reviews + dynasty-periods.yaml 12 条 + r6_temporal_guards.py + resolve.py 改造 + 22 unit tests
- [x] Stage 2/3：apply pass（no-op）+ 收档
- 结果：319 active persons（不变）/ 0 pending_merge_reviews（bootstrap）/ V11 全绿
- 架构选型：方案 α（persons.dynasty 单源 midpoint distance）> brief δ 倾向被 Stage 0 数据 override
- Stop Rules：#2 触发（0 live 拦截），接受为"clean baseline change"（Sprint C 已修复唯一案例）
- 累计：4 commits / 22 new tests / 1 migration / 1 new table / 1 new YAML / $0 LLM

### Sprint C — T-P0-027 Resolver Orchestration（2026-04-22 ~ 2026-04-24）
- [x] Stage 0：R1-R6 现状 inventory + 架构师 brief（5 裁决 + 5 stop rules）
- [x] Stage 1：R6 pre-pass infrastructure（R6PrePassResult + batch FK query + PersonSnapshot.r6_result）
  - Stop Rule #1 触发：r6_seed_match name fallback 偏离先验 → 架构师裁决方案 A（FK 直查）修复
- [x] Stage 2：R6 merge logic + audit log（_detect_r6_merges same-QID + apply_merges --skip-rule）
- [x] Stage 3：V11 invariant（anti-ambiguity cardinality）+ 13 tests（10 R6 prepass + 3 V11）
- [x] Stage 4：Full dry-run → 1 R6 MergeProposal（启 ↔ 微子启 Q186544）→ historian 裁决 false positive
- [x] Stage 5（路径 A）：R1 merge ×1 apply（鲁桓公↔桓公）/ R6 ×0 apply / wei-zi-qi seed_mapping 降级 pending_review
- 结果：319 active persons（-1 from R1 merge）/ 158 active seed_mappings（-1 from wei-zi-qi downgrade）/ 45 pending_review / V1-V11 全绿
- 累计：7 commits / 13 new tests / 1 pg_dump anchor / 0 migrations / $0 LLM
- 衍生债：T-P0-029（R6 cross-dynasty guard）/ T-P0-030（corrective seed-add wei-zi-qi→Q855012）

### Sprint A — T-P0-019 α β 尾巴清理 + V8 invariant 引入（2026-04-21）
- [x] Stage 1（V6 零化）：28 行 alias+is_primary=true → `name_type='primary'`（TYPE-B 降格为合法 primary；T-P1-013 closed）
- [x] Stage 2（F1 硬 DELETE）：6 行代词/光秃爵位残留 per ADR-022 三要素 → 硬 DELETE + pg_dump anchor；V7 96.37%→97.49%；T-P1-014 closed
- [x] Stage 3（F2 V8 精化）：3 行单字 α/β 双豁免（合法古汉语 anaphoric short-form），不删数据；ADR-023 V8 invariant 上线；T-P1-015 closed（名义）
- [x] ADR-022 accepted — NER 污染清理 vs Names-Stay 判定准则（三要素 AND 硬 DELETE + Gate 0-4 协议）
- [x] ADR-023 accepted — V8 Prefix-Containment Invariant（与 V1-V7 同级 + α evidence OR β alias 豁免 + self-test 强制）
- [x] V8 SQL + self-test（3 tests）落盘 services/pipeline/tests/test_v8_prefix_containment.py；282 tests 全绿
- 结果：V6 28→0（转绿）/ V7 96.37%→97.49%（+1.12pp 机械性）/ V8 引入（0 violations）/ ADR +3（ADR-021 Dictionary Seed Strategy 并行登记 + ADR-022 + ADR-023）
- 衍生债：T-P1-021（canonical merge missed pairs — 管叔/管叔鲜、蔡叔/蔡叔度；V8 probe 副产品）
- 累计：6 commits / 3 new tests（V8 self-test）/ 2 pg_dump anchors / 3 new ADRs

### T-P0-024 α — 历史章节证据链回填（2026-04-21）
- [x] Stage 0a：侦察（β 现状 + Phase A/B 盘点 + 路径 C 混合方案选定）
- [x] Stage 1a-1d：C1 β Path A（hash 复用 27 段，V7 52.48%→58.21%，$0 LLM）
- [x] Stage 2a：Phase A/B prompt diff + 静态三分类 + 3 段 LLM 探针（$0.03）
- [x] Stage 2b：脚本扩展（--mode reextract / 三态名回退 / AMBIGUOUS_SLUGS 审计网）+ wu-di dry-run（$0.28）+ xia+yin dry-run（$0.47）
- [x] Stage 2cd：C2 Phase A/B 三本合并 backfill execute（fast lane, $0 新增 LLM）
- [x] Stage 2e：Sprint 收尾（代码合入 + STATUS + CHANGELOG + 10 条 P1 debt 登记）
- 结果：V7 52.48%→96.37%（+230 names / +170 SE / $0.78 total LLM）
- 机制：slug-first + AMBIGUOUS_SLUGS 白名单 + 三态名回退 + fail-loud + fast lane
- 审计：21/21 AMBIGUOUS 命中精确匹配，0 fail-loud，0 errors
- 衍生债：T-P1-011~T-P1-020（10 条）
- 累计：5 commits + 1 merge / 920 行脚本 / 2 pg_dump anchors

### T-P0-006-α — 周本纪 α 扩量跑 + evidence 写路径验证（2026-04-20）
- [x] Stage 0: 任务卡 + tier-S slug 14 条扩列 + ctext.py zhou-ben-ji 注册 + 4 闸门基线
- [x] Stage 1: Narrow smoke（5 段）— source_evidences 写路径首弹验证（V7: 0→8.79%）
- [x] Stage 2: 全章 ingest 82 段（V7: 57.0%，成本 $0.77）
- [x] Stage 3: Identity resolver 全扫（24 组/31 persons）+ historian 审核（22 approved / 1 rejected / 1 split）
- [x] Stage 4: apply_merges 29 persons + 文武 surface 2 条硬清理（V7: 52.48%）
- [x] Stage 5: 收官 + STATUS/CHANGELOG + 衍生债务 T-P1-007~010
- 结果：persons 153→320（+167 净增）/ source_evidences 0→242 / V7 0%→52.48% / merge_log 23→52
- 核心验证：ADR-015 Stage 1 生产写路径 + ADR-014 apply_merges historian 闭环首次端到端通过
- 发现：Union-Find 跨族桥接（Group 3 文武污染）/ NER 同名异人合体（Group 14 桓公）
- 累计：8 commits / $0.77 LLM 成本 / 4 新 debt tasks (T-P1-007~010)

### T-P0-023 — 证据链 Stage 1 激活（ADR-015）（2026-04-19）
- [x] Stage 1a：LLMResponse.call_id 契约字段（audit → gateway 4-hop 传递链）（af1e858）
- [x] Stage 1b：ExtractedPerson.llm_call_id 传递（61a23e4）
- [x] Stage 1c：ProvenanceTier StrEnum 类 + load.py 字面量替换 + 守卫测试（ed2d04f）
- [x] Stage 1d：migration 0008 seed_dictionary 枚举扩展 + Python/Drizzle 三路同步（14c1d68）
- [x] Stage 1e：source_evidences 两步 INSERT + MergedPerson.llm_call_ids + per-person 事务化 + 7 测试（2271bb0）
- [x] Stage 2：V7 warning 级 evidence 覆盖率不变量（ecf1068）
- [x] Stage 3：book-keeping（本 commit）
- 结果：source_evidences 子系统首次激活；新 ingest 自动产出 evidence 行（per-person 粒度，AI_INFERRED tier）；V7 覆盖率 0.0%（存量 249 行 NULL 待 T-P0-024 回填）
- 附带修复：load_persons per-person 事务化（pre-existing gap）
- 累计：7 commits / 10 new tests / 1 migration / 1 新 Python enum 模块

### T-P0-016 apply_merges + load.py W1 双路径 is_primary 同步（2026-04-19）
- [x] Stage 0：4 闸门 + 写路径审计发现第二活跃路径（W1）
- [x] Stage 1a：resolve.py apply_merges SET 子句加 is_primary=false（4 测试）
- [x] Stage 1b：load.py W1 is_primary_value = primary_name_type == "primary"（2 测试）
- [x] Stage 2：Migration 0007 backfill 18 行 → 0（V6 TDD red→green）
- [x] Stage 3：book-keeping + F12 debt 登记
- 结果：18 行违规清零；V1-V6 首次全绿；269 pipeline + 61 api + 55 web = 385 tests
- 附带发现：W2 路径对称违规（F12），11 行 active 基线
- 累计：4 commits / 7 new tests / 1 migration / 1 new debt (F12)

### T-P0-022 + T-P0-020 合并 Sprint — F10 残留清理 + persons CHECK 约束（2026-04-19）
- [x] Stage 0：共用 4 闸门 + 双预扫描（T-P0-020 发现 5 行 partial-delete 违反原 CHECK）
- [x] Stage 1（T-P0-022）：Migration 0005 demote 8 行 merge source primary→alias
- [x] Stage 2（T-P0-020）：Migration 0006 ALTER TABLE persons_merge_requires_delete CHECK（架构师裁决双向→单向）
- [x] Stage 3：ADR-010 supplement + book-keeping + F3/F4/F10 resolved
- 结果：F10 清零；persons 三态语义确立（active/merge/pure）；V1-V5 全 PASS
- Drizzle schema 同步 persons.ts
- 累计：3 commits / 2 migrations / 0 new tests / ADR-010 supplement

### T-P0-006-β《尚书·尧典 + 舜典》摄入 — β 路线跨书归并压力测试（2026-04-19）
- [x] S-0：任务卡 + 6 问架构师预裁
- [x] S-1：fixtures 准备 + ctext adapter 扩展 + DB 现状对照表
- [x] S-2：Ingest（2 books / 27 raw_texts / 1700 字）
- [x] S-3a：smoke v1-r3 → 发现"帝" surface 污染 → 停机
- [x] S-3a-bis：v1-r4 prompt + _filter_pronoun_surfaces + prompt caching（双保险方案 C）
- [x] S-3b：全量 NER v1-r4（$0.12 含 cache）+ load 入库（5 new persons）
- [x] S-3b-fix：ADR-013 partial unique index（修 slug 冲突）+ 弃/垂 retry
- [x] S-4：Dry-run identity resolver（2 auto + 1 manual + 1 α-fix）
- [x] S-5：Merge apply → model-B 误用 → rollback + apply_merges() rerun per ADR-014
- [x] S-6：CI 全绿 + V1-V4 invariant 全 PASS
- 结果：153 active persons（151α + 5β - 3 merged）；2 new（殳斨/伯与）
- 核心验证：R3 tongjia 跨书触发（垂→倕）端到端通过 ✅
- 过程产出：ADR-013（partial unique）+ ADR-014（model-A merge）+ NER v1-r4 + 7 pronoun filter tests + V4 invariant
- 衍生债：11 条 followups（见 docs/debts/T-P0-006-beta-followups.md）
- 累计成本：~$0.28（NER API）
- 累计：8 commits / 7 new tests / 4 DB merges / 2 ADRs / 1 migration

### T-P1-004 NER 阶段单人多 primary 约束 — 三层防御（2026-04-19）
- [x] S-0：任务卡创建
- [x] S-1：现状分析（14 NER-source 多 primary，4 类冲突模式）
- [x] S-2：规则设计 + ADR-012 初稿
- [x] S-3：实施
  - NER prompt v1-r3：`## name_type 唯一性约束（严格）` + 反�� few-shot
  - `load.py _enforce_single_primary()`：auto-demotion 4 case（>1 primary / 0+match / 0+no-match / pass）
  - QC 规则 `ner.single_primary_per_person`（severity=major）
  - 共享 `is_di_honorific()` 从 resolve_rules.py 抽取
  - 32 new tests（load 18 + QC 8 + is_di_honorific 6）
- [x] S-4：跳过（不加 DB partial unique index，NER + ingest 两层足够）
- [x] S-5：验证全绿（ruff 0 / basedpyright 0/0/0 / 250 pipeline + 61 api + 55 web tests）
- 结果：single-primary 成为管线不变量；ADR-012 accepted；零 DB 变更
- 累计：4 commits / 32 new tests / 0 DB changes / 1 QC rule / 1 shared utility

### T-P2-002 persons.slug 命名一致性清理 — 分层白名单（2026-04-19）
- [x] S-0：任务卡创建
- [x] S-1：现状调研（151 active persons: 88 unicode + 63 pinyin, 0 collisions）
- [x] S-2：方向裁决 → 方向 3（分层白名单：Tier-S pinyin + unicode fallback）
- [x] S-3：实施
  - `data/tier-s-slugs.yaml`（74 条 Tier-S 白名单，含治理规则注释）
  - `services/pipeline/src/huadian_pipeline/slug.py`（generate_slug / unicode_slug / classify_slug）
  - `load.py` 重构（删除 `_PINYIN_MAP` + `_generate_slug`，改用 slug 模块）
  - ADR-011 accepted（分层白名单决策 + 扩列治理 + 不变量保证）
  - 23 unit tests（test_slug.py）+ 3 invariant tests（test_slug_invariant.py）
- [x] S-4：跳过（方向 3 无 DB 变更）
- [x] S-5：验证全绿（ruff 0 / basedpyright 0/0/0 / 218 pipeline + 61 api + 55 web tests）
- 结果：slug 规则明文化为 YAML 白名单；不变量测试 CI 保证；零 DB 变更；零 URL 变更
- 累计：3 commits / 26 new tests / 0 DB changes / 1 new dependency (pyyaml) / ADR-011

### T-P1-002 person_names 降级 + 去重 + UNIQUE 约束（2026-04-19）
- [x] S-0：任务卡创建
- [x] S-1：现状调研（17 person_id 多 primary + 11 对跨 person_id 重复 + 0 per-person_id 重复）
- [x] S-2：方向裁决 → C（混合）：写端 primary 降级 + 读端 name 文本 dedup
- [x] S-3：实施（Drizzle schema UNIQUE + backfill SQL + resolve.py demote + API dedup + 9 integration tests）
- [x] S-4：DB 执行（17 行 primary→alias + UNIQUE INDEX uq_person_names_person_name）
- [x] S-5：V1-V3 验证通过 + STATUS/CHANGELOG 更新
- 结果：17 行降级；19 canonical 多 primary → 0；11 对跨 person_id 重复由读端兜住
- 衍生债：T-P1-004（NER 单人多 primary 约束）
- 累计：2 commits / 9 new tests / 17 DB UPDATE / 1 schema migration

### T-P0-015 帝鸿氏/缙云氏 Canonical 归并裁决（2026-04-19）
- [x] S-0：任务卡创建
- [x] S-1：证据调研（DB 快照 + 五帝本纪 P24 原文 + 古注四家训释）
- [x] S-2：Historian 裁决 → (c) 混合：帝鸿氏 MERGE，缙云氏 KEEP-independent
  - 帝鸿氏=黄帝：贾逵/杜预/服虔/张守节四家一致（"帝鸿，黄帝也"）
  - 缙云氏≠黄帝：杜预/贾逵训为"黄帝时官名"（从属关系非等同）+ P24 并列结构约束
- [x] S-3：dry-run JSON + merge SQL（R4-honorific-alias 新规则）
- [x] S-4：DB 执行（1 person merged, 1 merge_log, 1 person_name added）
- [x] S-5：V-1~V-5 验证全通过 + STATUS/CHANGELOG 更新
- 结果：152 → 151 active persons；黄帝 names 新增"帝鸿氏(alias)"
- 累计：1 commit / 0 new tests / 1 DB merge / 1 新 merge_rule (R4-honorific-alias)

### T-P1-003 搜索召回精度调优 — F1 95.6%→100%（2026-04-19）
- [x] S-1：searchPersons 实现调研（pg_trgm threshold=0.3 + ILIKE，GIN 索引确认）
- [x] S-2：黄金测试集 30 条（精确/短词FP/异写/前缀/不存在 6 维度）
- [x] S-3：基线 benchmark（P=93.9% R=100% F1=95.6%，3 disallowed violations）
- [x] S-4：4 策略实验（A 阈值提高 / B 前缀优先 / C 长度加权 / D 三段式）→ C 以 F1=100% 胜出
- [x] S-5：实施 Strategy C — `similarityThreshold()` 长度加权 + `aliasSubstringSearch()` fallback
- [x] S-6：最终 benchmark（P=100% R=100% F1=100%，0 violations）+ 7 条回归单测
- [x] S-7：5 commits / push / CI
- 修复 FP：帝中→中壬/中康、帝中丁→中壬/中康、帝武乙→武丁 全部消除
- 累计：5 commits / 7 new tests / 30 条黄金集 / 0 schema 变更

### T-P0-014 非人实体清理 — soft-delete 5 条（2026-04-19）
- [x] S-1：候选审计（157 persons 扫描 → 7 候选 A 类 + 9 B 类）
- [x] S-1 核查规程：surface_forms 裸名检查 + 原文上下文验证
  - 羲氏/和氏 触发裸名 guard → historian override → delete
  - 熊罴/龙 确认为舜臣 → KEEP
- [x] S-2：`is_likely_non_person()` 规则函数（HONORIFIC_SHI_WHITELIST 13 条 + _KNOWN_NON_PERSON_NAMES 词典 + X氏 suffix pattern + bare-name guard）
- [x] S-3：22 新 test cases（7 TP + 9 TN + 4 boundary + 1 whitelist sanity + 1 extra），67 total resolve
- [x] S-4：SQL soft-delete 5 条（荤粥/昆吾氏/姒氏/羲氏/和氏），person_merge_log 5 行（merge_rule='R3-non-person'）
- [x] S-5：V-1 lint/typecheck/test 全绿；V-2/V-3 DB 验证通过
- 结果：157 → 152 active persons
- 累计：5 commits / 22 new tests / 5 DB soft-deletes / 1 新规则函数
- 衍生债：T-P2-002（slug 命名不一致）

### T-P0-013 Canonical 选择策略优化 — 帝X 前缀去偏差（2026-04-18）
- [x] S-1：`has_di_prefix_peer()` 辅助函数 + `select_canonical()` sort_key 插入帝X惩罚项（priority #2）
- [x] S-2：11 新 test cases（TestSelectCanonical 6 + TestHasDiPrefixPeer 5），45 total pass
- [x] S-3：`verify_canonical.py` 验证全部 12 条 merge — 仅 1 组需改（帝中丁→中丁），武乙组旧规则已正确
- [x] S-4：SQL 反转帝中丁/中丁 canonical 方向（事务执行，V1/V2/V3 验证通过）
- [x] S-5：STATUS / CHANGELOG 更新
- ADR-010 Known Follow-up #1 闭环
- 累计：4 commits / 11 new tests / 1 DB data fix（canonical reversal）

### [W-8] CI 基建修复 — DB schema apply + turbo env passthrough（2026-04-18）
- [x] S-1：调查 Drizzle vs pipeline raw SQL 覆盖范围 + extension 依赖验证
- [x] S-2：ci.yml 改用自定义 PG 镜像（`docker/postgres/Dockerfile`）+ Step 4b `db:migrate`
- [x] S-4.5：skip T-P1-001 已知隔离 2 case + 登记 `docs/debts/T-P1-001-test-isolation.md`
- [x] S-2b：turbo.json `passThroughEnv: ["DATABASE_URL", "REDIS_URL"]`（strict env mode 修复）
- CI Run [24600242038](https://github.com/lizhuojunx86/huadian/actions/runs/24600242038) 全绿（3 jobs success）
- 累计：3 commits / 0 新测试 / 2 case skip（T-P1-001 债）
- 衍生技术债：[T-P1-001](../docs/debts/T-P1-001-test-isolation.md)（API integration test isolation）

### T-P0-012 Web 首页 + 全局导航（2026-04-18）
- [x] S-1：布局骨架（Header + Footer → layout.tsx，子页面 `<main>` → `<div>` 修正）
- [x] S-2：首页 Hero（站名 + 定位语 + HeroSearch 搜索框）
- [x] S-3：知名人物区（6 slug 硬编码 + FeaturedPersonCard + Promise.all 并发 fetch）
- [x] S-4：数据概览（SDL `stats: Stats!` + API resolver 3× COUNT + StatsBlock 组件）
- [x] S-5：探索全部 CTA（→ /persons）
- [x] S-6：/about 页（项目简介 + 技术栈 + 状态 + 联系方式）
- [x] S-7：SEO metadata（首页 + /about OG 标签）
- [x] S-8：vitest 17 cases（Header 4 + Footer 3 + FeaturedPersonCard 5 + StatsBlock 2 + HeroSearch 3）
- [x] S-9：Playwright E2E 3 cases（推荐卡片 + 搜索跳转 + 导航关于）
- [x] S-10：STATUS / CHANGELOG / index 更新
- 累计：7 commits / 17 new unit tests / 3 E2E tests / 1 SDL 扩展（Stats type）
- 原 T-P0-012（冗余实体 soft-delete）重编号为 T-P0-014

### T-P0-011 跨 Chunk 身份消歧（2026-04-18）
- [x] Phase 1：ADR-010 起草 + v2 修订（评分函数/字典/soft merge/可逆性）
- [x] Phase 3：Schema migration（persons.merged_into_id + person_merge_log）
- [x] Phase 3：字典文件（tongjia.yaml + miaohao.yaml，带 source 字段）
- [x] Phase 3：identity_resolver 模块（resolve.py / resolve_rules.py / resolve_types.py）
- [x] Phase 3：R1 stop words + cross-dynasty guard（修复 3 个 false positive）
- [x] Phase 3：单元测试 34 cases 全绿
- [x] Phase 3：帝舜 data fix（Related Fix #2）
- [x] Phase 3：Dry-run 11 组全绿（169→157）
- [x] Phase 4：Apply merges（run_id=39b495d0，12 persons soft-merged）
- [x] Phase 4：API resolveCanonical（搜索穿透 + slug 透明返回 + 别名聚合）
- [x] Phase 4：Historian 抽样 5/5 正确
- [x] Phase 4：Web API 端到端验证 5/5 通过
- 累计：ADR-010 accepted / 3 schema migrations / 5 new Python modules / 2 YAML dicts / 34 pipeline tests / 6 commits

### T-P0-010 Pipeline 基础设施 + 真书 Pilot（2026-04-18）
- [x] S-prep 1~8：管线基础设施从零建设（8 模块，8 commits）
  - Python 模块导入修复 / ctext adapter + fixtures / ingest / NER prompt v1 / extract / load / CLI / seed dump
- [x] Phase A：五帝本纪 smoke（29 段，62 persons，$0.54）
  - 精确率 ~94%，召回率 ~100%
  - Historian 抽检 8/10 正确
- [x] Prompt v1-r2：A-class fixes（帝X校验 / 姓氏规则 / 部族排除 / 合称规则）
- [x] Phase B：夏本纪 + 殷本纪 扩容（70 段，107 new persons，$1.23）
  - 精确率 ~93%，召回率 ~100%，抽样正确率 90%（改善）
  - 帝X 误归 Phase A→1 处 → Phase B→0 处（修复验证）
- [x] 发现问题清单 + T-P0-011 建立
- 累计产出：3 books / 169 persons / 273 names / $1.77 总成本

### T-P0-009 Web 人物搜索/列表页（2026-04-18）
- [x] S-0：任务卡起草
- [x] S-1：SDL 扩展 — persons(search, limit, offset): PersonSearchResult
- [x] S-2：service + resolver — pg_trgm similarity + ILIKE fallback
- [x] S-3：集成测试 13 cases（精确/模糊/空结果/分页/soft-delete）
- [x] S-4：Web codegen + PersonsSearchQuery typed document
- [x] S-5：/persons 路由 + Server Component（searchParams → SSR fetch）
- [x] S-6：SearchBar 客户端组件（300ms debounce + router.replace）
- [x] S-7：PersonListItem + PersonList 组件
- [x] S-8：Pagination 组件（上一页/下一页 + total 显示）
- [x] S-9：loading 骨架屏 / error 重试 / 空结果提示
- [x] S-10：vitest 15 cases + Playwright E2E 2 cases
- [x] Q-1~Q-7 预裁决策全部落地
- [x] lint / typecheck / build / codegen 全绿

### T-P0-008 Web MVP — 人物卡片页（2026-04-18）
- [x] S-0：Tailwind CSS v3 + shadcn/ui 初始化 + 全依赖安装
- [x] S-1：GraphQL codegen 前端管线（client-preset typed documents）
- [x] S-2：路由 `/persons/[slug]` + async Server Component + generateMetadata
- [x] S-3：PersonCard + HistoricalDateDisplay 组件
- [x] S-4：PersonNames + PersonHypotheses 分区（含空状态占位）
- [x] S-5：Loading 骨架屏 / Error 重试 / notFound 404
- [x] S-6：vitest 单元测试 23 cases 全绿
- [x] S-7：Playwright E2E 冒烟 2 cases（需 API + DB）
- [x] Q-1 架构师豁免：Phase 0 暂免 UI/UX 角色参与
- [x] lint 0 errors / typecheck / build / codegen 全绿

### T-P0-007 API MVP — person query（2026-04-18）
- [x] S-0.5：SDL nullable 变更（ADR-009 实施）— 6 文件 `sourceEvidenceId: ID!` → `ID` + codegen
- [x] S-1：slug 验证工具函数 `src/utils/slug.ts` + 9 单元测试
- [x] S-2：Service layer + DTO 映射 `src/services/person.service.ts`（findPersonBySlug eager / findPersons pagination）
- [x] S-3：Resolver 实现（person/persons 真实查询 + Person field resolvers for names/identityHypotheses）
- [x] S-4：Integration 测试（真 PG + 4 fixture persons + 8 test cases）
- [x] S-5：lint + typecheck + build + codegen 全绿
- [x] vitest 测试框架引入（31 tests 全绿：9 slug + 7 DTO mapper + 7 resolver + 8 integration）
- [x] tsconfig.test.json + eslint 配置支持 tests 目录

### T-P0-005 LLM Gateway + TraceGuard 基础集成（2026-04-17）
- [x] `services/pipeline/src/huadian_pipeline/ai/` 子包：6 个源文件
- [x] `types.py`：LLMResponse / LLMGatewayError / PromptSpec
- [x] `gateway.py`：LLMGateway Protocol
- [x] `hashing.py`：prompt_hash / input_hash（SHA-256 确定性）
- [x] `anthropic_provider.py`：AnthropicGateway 实现
  - AsyncAnthropic SDK + HTTP 层指数退避 retry（429/529/5xx）
  - TraceGuard checkpoint 内置（Q-1 裁定 A）：action 路由 pass/retry/degrade/fail
  - Token 定价 hardcode 成本计算（Q-3）
  - Best-effort audit writer hook
- [x] `audit.py`：LLMCallAuditWriter（asyncpg → llm_calls 表，Q-2）
- [x] 新增依赖 `anthropic>=0.40.0`（架构师批准）
- [x] 46 条 ai/ 测试全绿 + basedpyright 0/0/0
- [x] 全量 128 测试通过（ai/ 46 + qc/ 82）

### T-P0-003 GraphQL schema 骨架（2026-04-17）
- [x] SDL 骨架：8 个 .graphql 文件（scalars / enums / common / a-sources / b-persons / c-events / d-places / queries + _bootstrap）
- [x] 12 entity types（Book / SourceEvidence / Person / PersonName / IdentityHypothesis / Event / EventAccount / AccountConflict / Place / PlaceName / Polity / ReignEra）+ 3 JSONB ref types + Traceable interface
- [x] 5 implements Traceable（Book / SourceEvidence / Person / Event / Place）— R-1 三字段（sourceEvidenceId / provenanceTier / updatedAt）
- [x] 5 Query 入口（person / persons / event / place / sourceEvidence）全抛 NOT_IMPLEMENTED（Q-10）
- [x] graphql-codegen（SDL → 1020 行 TS types）+ 确定性 schema:merge 快照
- [x] HuadianGraphQLError + 6 codes + GraphQLContext（db / requestId / tracer）
- [x] CI graphql-breaking.yml（drift check + graphql-inspector diff warn-only）
- [x] pnpm -r build / lint / typecheck / codegen 全绿；GraphiQL 本地验证通过

### T-TG-002 TraceGuard Adapter 实现（2026-04-17）
- [x] Port/Adapter 六边形架构（`src/huadian_pipeline/qc/`）
- [x] `_imports.py` 唯一 TG ingress（4 冻结符号）+ 3 条契约测试
- [x] `action_map.py` Mismatch #1 翻译 + `ActionEscalator` Protocol
- [x] `types.py` ADR-004 协议（CheckpointInput / CheckpointResult / Violation）
- [x] `adapter.py` 完整决策链：TG eval → rules → policy → audit → result
- [x] `rule_registry.py` + 5 条首批规则（common ×2 / ner ×2 / relation ×1）
- [x] `policy.py` + `traceguard_policy.yml`（defaults / by_severity / by_step 三段）
- [x] `audit.py` 双写 llm_calls + extractions_history（ON CONFLICT DO UPDATE 幂等）
- [x] `replay.py` 回放回归检测（ReplayReport / ReplayDiff / drift detection）
- [x] 82 条测试全绿 + basedpyright 0/0/0
- [x] follow-up F-6：Drizzle schema 同步 deferred to 后端

### T-P0-004 历史专家字典初稿 · 批次 1（2026-04-16）
- [x] `data/dictionaries/_NOTES.md` — 架构师 5 点裁决 + 5 条工作约束（C-01~C-05）+ TODO-001（T-P0-006 stub 前置要求）
- [x] `data/dictionaries/polities.seed.json` — 5 条（秦 / 西汉 / 新 / 更始 / 东汉）
- [x] `data/dictionaries/reign_eras.seed.json` — 89 条 + `_datingGapNote` 7 节（秦无年号 / 西汉前五朝无命名 / 武帝以降全覆盖 / 边界年歧义 / 公元零年 / 共治并存 / 献帝 189 年五改元）
- [x] `data/dictionaries/disambiguation_seeds.seed.json` — 10 组 surface / 26 行（韩信 / 刘秀 / 淮南王 / 楚王 / 赵王 / 公孙 / 霍将军 / 窦将军 / 王大将军 / 韩王）
- [x] `data/dictionaries/persons.seed.json` — 40 人（秦 3 / 秦末楚汉 11 / 西汉初—武帝 14 / 西汉末—新—更始 5 / 东汉 7；鸿门宴 NER 必要角色齐全）
- [x] `data/dictionaries/places.seed.json` — 25 处（都城 5 / 封国郡国核心 10 / 战役典故 7 / 人物籍贯 3）
- [x] 裁决落地：BC -202 西汉起始年 / 更始独立 polity / "后元"三撞靠 (emperor, name) 二元组 / "甘露"跨代入 T-P0-002 F-5 / slug 两阶段加载 + DEFERRABLE FK

### T-P0-002 DB Schema 落地（2026-04-16）
- [x] shared-types：HistoricalDate / MultiLangText / EventRefs / 22 枚举 zod schema
- [x] db-schema：10 个 schema 文件（common / enums / sources / persons / events / places / relations / artifacts / embeddings / pipeline / feedback）
- [x] 33 张表 Drizzle 定义 + pgEnum
- [x] PostGIS GEOMETRY customType + pgvector vector(1024) customType
- [x] gen-types.sh 全链路：6 JSON Schema + 6 Pydantic 模型
- [x] drizzle-kit generate + migrate 成功
- [x] pnpm -r build / lint / typecheck 全绿
- [x] ADR-005 errata（entity_id UUID）

### T-P0-001 Monorepo 骨架落地（2026-04-15）
- [x] 根级工具链（package.json / pnpm-workspace / turbo.json / tsconfig / pyproject.toml / Makefile）
- [x] 共享配置包（config-typescript / config-eslint）
- [x] 10 个子包骨架（apps/web / services/api / services/pipeline / packages/*）
- [x] Docker Compose（PG + Redis + OTel Collector）
- [x] 环境变量（.env.example）+ pre-commit（gitleaks + lint-staged）
- [x] CI（ci.yml 八步 + pre-commit.yml + CODEOWNERS + dependabot）
- [x] 脚本（dev.sh / db-reset.sh / smoke.sh / gen-types.sh）
- [x] 文档（RB-001 本地开发 / README 扩写）

### 架构设计文档落地（2026-04-15）
- [x] 架构设计文档 v1.0
- [x] 项目宪法 `docs/00_项目宪法.md`
- [x] 七份核心文档 `docs/01~06`
- [x] 10 个 Agent 角色定义
- [x] ADR-001 ~ ADR-007（7 条 accepted）

---

## 进行中

（无当前进行中任务 — Sprint G 已完成）

---

## 下一步候选（按建议优先级）

| 优先级 | 任务 ID | 描述 | 主导角色 | 依赖 | 状态 |
|--------|---------|------|---------|------|------|
| 🔴 高 | T-P0-031 | 楚怀王 Entity Split (熊槐/熊心 同号异人)——数据正确性 critical | historian + 管线 | T-P0-006-δ ✅ | pending |
| ~~🟡 中~~ | ~~T-P0-030~~ | ~~Corrective seed-add wei-zi-qi → Q855012~~ | ~~管线~~ | ~~T-P0-027 ✅~~ | **done** |
| 🟡 中 | T-P0-025b | TIER-4 自建 seed 补丁（继承原 persons.seed.json 40 条 + 扩充 ~60-80 先秦冷门人物；≠ pending_review triage，后者见 T-P0-028） | 管线 + 历史专家 | T-P0-025 | backlog |
| 🟡 中 | T-P0-028 | Manual triage UI for pending_review（44 条待审 → active/rejected） | 管线 + 历史专家 + 前端 | T-P0-025 ✅ | planned |
| ~~🟡 中~~ | ~~T-P1-022~~ | ~~V1 下界缺失~~ | ~~管线 + 架构师~~ | — | **done (Sprint F)** |
| 🟡 中 | T-P0-005a | SigNoz 版本对齐与接入 | DevOps + 管线 | T-P0-005 ✅ | planned |
| 🟡 中 | T-P0-004 批次 2 | 字典扩展（秦汉二线人物 + 封国/战役地 + slug 补齐） | 历史专家 | T-P0-004 批次 1 ✅ | planned |
| 🟡 中 | T-P1-005 | 统一 migration 入口（Drizzle + pipeline SQL 双轨合一） | DevOps + 后端 | — | registered |
| 🟡 中 | T-P1-007 | u6853-u516c 桓公 person 拆分（§43 鲁桓公 vs §64 西周桓公） | 管线 + historian | — | registered |
| 🟡 中 | T-P1-008 | Union-Find 簇验证（跨朝代污染防护） | 管线 + 架构师 | — | registered |
| 🟡 中 | T-P1-009 | NER 合成词护栏（文武/尧舜 类识别） | 管线 + historian | — | registered |
| 🟡 中 | T-P1-021 | canonical merge missed pairs（管叔/管叔鲜、蔡叔/蔡叔度，V8 probe 副产品） | 管线 + historian | ADR-014 ✅ | registered |
| ⚪ 微 | T-P1-023 | Drizzle uniqueIndex 命名与 raw SQL UNIQUE 约束不一致（Stage 0b review 副产物，方案 B migration 0010 DROP 自动名） | 后端 | — | registered |
| 🟢 低 | T-P1-010 | Resolver R2 dynasty + reality_status 预过滤 | 管线 + 架构师 | — | registered |
| 🟢 低 | T-P1-011 | Merged-alias evidence backfill（垂→倕） | 管线 | — | registered |
| 🟢 低 | T-P1-012 | Dry-run first-write-wins 预测模型 | 管线 | — | registered |
| 🟢 低 | T-P1-016 | 微子 slug mismatch 修正 | 管线 | — | registered |
| ⚪ 微 | T-P1-017 | SE 多源扩展（ADR-015 Stage 1 → N:M） | 架构师 + 后端 | — | registered |
| ⚪ 微 | T-P1-018 | Backfill 自动触发器 | 管线 + DevOps | — | registered |
| ⚪ 微 | T-P1-019 | AMBIGUOUS_SLUGS DB 迁移 | 管线 + QA | — | registered |
| ⚪ 微 | T-P1-020 | Name resolution 共享模块抽取 | 管线 | — | registered |
| ~~🟡 中~~ | ~~T-P1-024~~ | ~~tongjia.yaml 扩充（缪/穆、傒/奚）~~ | ~~管线 + historian~~ | T-P0-006-γ ✅ | **done (Sprint F)** |
| ~~🟡 中~~ | ~~T-P1-025~~ | ~~重耳↔晋文公 merge~~ | ~~管线~~ | T-P0-006-γ ✅ | **done (Sprint F)** |
| ~~🟡 中~~ | ~~T-P1-026~~ | ~~disambig_seeds 跨国同名扩充~~ | ~~管线 + historian~~ | T-P0-006-γ ✅ | **done (Sprint F)** |
| 🟡 中 | T-P1-027 | disambig_seeds 楚汉多义封号扩充（齐王/楚王/汉王/怀王；historian §4.3 引用 fdfb7cb） | 管线 + historian | T-P0-006-δ ✅ | registered |
| 🟡 中 | T-P1-028 | R1 dynasty 前置过滤（减少跨国 FP；historian §4.4；可能需 ADR） | 管线 + 架构师 | T-P0-006-δ ✅ | registered |
| ⚪ 微 | T-P2-001 | codegen trailing newline 不一致 | DevOps | — | registered |
| ~~⚪ 微~~ | ~~T-P2-004~~ | ~~NER prompt v1-r5~~ | ~~管线~~ | T-P0-006-γ ✅ | **done (Sprint F)** |
| ⚪ 微 | T-P2-005 | NER v1-r6 楚汉封号+名 few-shot（historian §4.5 引用 fdfb7cb） | 管线 | T-P0-006-δ ✅ | registered |

---

## 阻塞项

| # | 描述 | 等待 | 建议处理 |
|---|------|------|---------|
| （无当前阻塞） | — | — | — |

---

## 最近决策（ADR · 已接受）

- `ADR-001` — 单 PostgreSQL 16 + pgvector + PostGIS + pg_trgm
- `ADR-002` — 事件双层建模（Event + EventAccount）
- `ADR-003` — 多角色协作框架启用（10 角色）
- `ADR-004` — TraceGuard 集成合同（Port/Adapter 契约）
- `ADR-005` — Embedding 多槽位与模型切换策略（errata：entity_id UUID）
- `ADR-006` — 未决项 U-01~U-07 封版决策
- `ADR-007` — Monorepo 布局与包管理（pnpm + uv + Turborepo）
- `ADR-008` — License 策略（GraphQL Book.license `CC_BY` 规范化 + workspace 包 `UNLICENSED`）
- `ADR-009` — Person sourceEvidenceId Traceability（Traceable 接口 `sourceEvidenceId` nullable 放宽；R-1 修订）
- `ADR-010` — 跨 chunk 身份消歧（5 规则评分函数 + 字典 + soft merge + 可逆性）
- `ADR-011` — Person Slug Naming Scheme — Tiered Whitelist（方向 3：Tier-S pinyin + unicode fallback；扩列治理；不变量测试）
- `ADR-012` — NER 单人多 primary 约束三层防御（prompt + ingest auto-demotion + QC rule）
- `ADR-013` — persons.slug partial unique index（排除 soft-deleted persons）
- `ADR-014` — Canonical Merge Execution Model（names-stay + read-side aggregation + apply_merges() 唯一入口）
- `ADR-015` — Evidence 链填充方案（staged activation + paragraph-level Stage 1）
- `ADR-017` — Migration Rollback Strategy（forward-only + pg_dump anchor + 4 闸门协议）
- `ADR-021` — Dictionary Seed Strategy（open-data-first；Wikidata 作为唯一 TIER-1 源；CBDB 因 CC BY-NC-SA 延后）
- `ADR-022` — NER 污染清理 vs Names-Stay 判定准则（三要素 AND：evidence 零依赖 + 非合法名语义 + FK 零引用 → 硬 DELETE + pg_dump anchor）
- `ADR-023` — V8 Invariant 引入：Prefix-Containment（length=1 名 + 跨 person 前缀包含 → 违反；α evidence-backed 或 β alias-typed → 豁免）
- `ADR-010 Supplement` — persons 表三态 soft-delete 语义 + 单向 CHECK 选型
- `ADR-024` — V9 Invariant: At-Least-One-Primary Lower-Bound Check（V1 上界 + V9 下界 = exactly-one-primary）

---

## 健康度指标

- 📘 文档覆盖度：核心 7/7 ✅
- 🧭 ADR 数量：20 accepted（含 ADR-010 supplement；新增 ADR-024 V9 @ 2026-04-25）
- 📋 任务卡数量：T-P0-001~T-P0-016 + T-P0-019~T-P0-030 + T-P0-006-γ + T-P1-007~T-P1-026 + T-P2-001~T-P2-004 done/in_progress/planned/registered/backlog（40+）
- 👥 Agent 角色定义：10/10 ✅
- 🏗️ 子包 build：10/10 全绿
- 🐳 Docker：PG + Redis 健康；34 张表 migrate 成功（+pending_merge_reviews）；SigNoz deferred；端口约定 5433/6380
- 📚 字典种子：185 条（polities 5 / reign_eras 89 / disamb 26 / persons 40 / places 25）@ 0.1.0-draft 静躺待 T-P0-025 加载；Sprint B Gate 0a Wikidata 覆盖 54.4%（174/320）；persons.seed.json 40 条 TIER-4 演化为 T-P0-025b
- 🧪 测试覆盖：471 passed（pipeline 349 + api 61 + web 55）+ 34 skipped（DB-dependent invariant）；E2E 7 specs
- 🔗 合并状态：663 active persons / 85 merge-soft-deleted / 5 pure-soft-deleted = 753 total
- 📊 Evidence 覆盖：V7 覆盖率（项羽本纪 +117 persons，覆盖率待 Sprint H 更新）
- 🌐 Seed 覆盖：dictionary_entries 202 / seed_mappings 204（159 active + 45 pending_review）/ 覆盖率 28.6%（159/556）
- 🗄️ Pipeline migrations：0001–0012（latest: 0012_add_pending_merge_reviews.sql @ Sprint D Stage 1）
- 🚦 阻塞项数量：0 ✅

### 数据层不变量矩阵

| # | Invariant | 描述 | 当前状态 | 转绿日期 |
|---|-----------|------|---------|---------|
| V1 | single-primary | 每 active person 恰 1 个 name_type='primary' | ✅ | 历史绿 |
| V2 | name completeness | 每 active person 至少 1 个 name | ✅ | 历史绿 |
| V3 | FK completeness | merged_into_id 指向存在的 person | ✅ | 历史绿 |
| V4 | model-B leakage | merged source 无 primary name | ✅ | 2026-04-19（T-P0-022） |
| V5 | active definition | 无 merged 但未 deleted（CHECK 约束保护） | ✅ | 2026-04-19（T-P0-020） |
| V6 | alias ≠ is_primary | 全表无 alias+is_primary=true | ✅ | 2026-04-21（Sprint A Stage 1，28→0；机制历史绿自 2026-04-19 T-P0-016） |
| V7 | evidence coverage | active person_names 的 source_evidence_id 覆盖率 | ✅ 98.54% (PASS) | 2026-04-25（Sprint E γ 秦本纪 evidence 新增） |
| V8 | prefix-containment | length=1 name + 跨 person 前缀包含（α evidence OR β alias 豁免） | ✅ 0 violations | 2026-04-21（Sprint A Stage 3；ADR-023） |
| V9 | at-least-one-primary | 每 active person 至少 1 个 is_primary=true name（V1 下界） | ✅ 0 (bootstrap) | 2026-04-25（Sprint F Stage 3；ADR-024） |
| V10 | seed_mapping consistency | V10.a orphan target + V10.b orphan entry + V10.c active evidence | ✅ 0/0/0 | 2026-04-22（Sprint B Stage 4） |
| V11 | R6 pre-pass cardinality | no active person has >1 active seed_mapping（anti-ambiguity） | ✅ 0 | 2026-04-22（Sprint C Stage 3） |

**V1-V9 + V10-V11 全绿；V1=0（Sprint F 修复 + Sprint G 新数据验证）；V9=0（Sprint G 新数据验证）；V10=0/0/0；V11=0；seed coverage ~24%（159/663 active persons matched，分母因 Sprint G +117 增大）**。

### 已知未处理违规（debt baseline）

| Debt | 描述 | 行数 | 优先级 |
|------|------|------|--------|
| F12 | primary + is_primary=false（W2 路径） | 11 行 active | P2 |

### 已知验证盲点

- ~~**源证据链生产路径未经 smoke-ingest 验证**~~ — **已验证 2026-04-20**（T-P0-006 α Stage 1b narrow smoke + Stage 2 全章 ingest）。242 条 source_evidences 真实写入，5 列全部正确，FK 完整。追踪任务：T-P1-006（replay smoke framework, backlog，优先级降低）。

---

## 更新日志（STATUS 文件本身的）

- 2026-04-15：初始化
- 2026-04-15：T-001 / T-002 / T-003 / T-TG-001 完成
- 2026-04-15：ADR-007 accepted；T-P0-001 ready
- 2026-04-15：T-P0-001 done — Monorepo 骨架落地；SigNoz deferred to T-P0-005a；T-P0-002 进入 ready
- 2026-04-16：T-P0-002 done — DB Schema 落地（33 表 + Drizzle 迁移 + shared-types + ADR-005 errata）
- 2026-04-16：T-P0-004 批次 1 done — 字典种子 185 条（polities/reign_eras/disamb/persons/places）+ _NOTES.md（5 裁决 + 5 约束 + TODO-001）
- 2026-04-17：T-P0-007 / T-P0-005 任务卡就绪（ready）；ADR-008 accepted（License 策略）
- 2026-04-17：T-TG-002 done — TraceGuard Adapter 实现（Port/Adapter + 5 rules + policy + audit + replay；82 tests；6 commits）
- 2026-04-17：ADR-009 accepted — Traceable.sourceEvidenceId nullable 放宽（T-P0-007 Q-5 裁决）；T-P0-007 任务卡 v2 更新（新增 S-0.5 SDL 变更子任务）
- 2026-04-17：T-P0-003 done — GraphQL schema 骨架（12 entity types + Traceable + 5 Query + codegen + CI graphql:breaking；6 commits）
- 2026-04-18：T-P0-007 done — API Person Query（SDL nullable ADR-009 + slug 验证 + service layer + resolver + 31 tests；5 commits）
- 2026-04-18：T-P0-008 done — Web MVP 人物卡片页（Tailwind + shadcn + codegen + /persons/[slug] + 4 组件 + 23 tests + 2 E2E；8 commits）
- 2026-04-17：T-P0-005 done — LLM Gateway + TraceGuard 基础集成（ai/ 子包 6 文件 + anthropic SDK + 46 tests；4 commits）
- 2026-04-18：T-P0-009 done — Web 人物搜索/列表页（SDL PersonSearchResult + pg_trgm search + /persons 路由 + SearchBar + Pagination + 28 新增 tests + 2 E2E；7 commits）
- 2026-04-18：T-P0-011 done — 跨 chunk 身份消歧（ADR-010 + identity_resolver 5 规则 + 2 YAML 字典 + schema migration + API resolveCanonical；11 组合并 169→157 persons；34 pipeline tests + 5 web 验证；6 commits）
- 2026-04-18：T-P0-012 done — Web 首页 + 全局导航（Header/Footer layout + Hero + FeaturedPersonCard×6 + Stats SDL 扩展 + StatsBlock + /about + SEO；17 unit tests + 3 E2E；7 commits）；原 T-P0-012 冗余实体 soft-delete 重编号为 T-P0-014
- 2026-04-18：W-8 done — CI 基建修复（自定义 PG 镜像 + db:migrate + turbo passThroughEnv；Run 24600242038 全绿；3 commits）；衍生债 T-P1-001 registered
- 2026-04-18：T-P0-013 done — Canonical 帝X 前缀去偏差（has_di_prefix_peer + select_canonical 优先级链；1 组 canonical 反转 帝中丁→中丁；11 new tests → 45 resolve tests；4 commits）；ADR-010 Follow-up #1 闭环
- 2026-04-19：T-P0-014 done — 非人实体清理（is_likely_non_person 规则 + HONORIFIC_SHI_WHITELIST 13 条 + X氏 pattern；5 entities soft-deleted 157→152 persons；22 new tests → 67 resolve tests；5 commits）；衍生债 T-P2-002 registered
- 2026-04-19：T-P1-001 closed — API 集成测试隔离修复（2 skip → 0 skip；hasMore 断言改用 probe+offset、ordering 断言 scope 到 test-* fixtures；1 commit）
- 2026-04-19：T-P1-003 closed — 搜索召回精度调优（length-weighted threshold + alias fallback；F1 95.6%→100%；3 FP 消除；30 条黄金集 + 7 new tests → 52 api tests；5 commits）
- 2026-04-19：T-P2-003 closed — 清理 datamodel-codegen dash-case 死文件（5 untracked files 删除 + gen-types.sh 防御性 find-delete 兜底；1 commit）
- 2026-04-19：T-P0-015 done — 帝鸿氏归并入黄帝（historian 裁决 (c) 混合：帝鸿氏 MERGE R4-honorific-alias + 缙云氏 KEEP-independent；152→151 persons；1 commit）
- 2026-04-19：T-P1-002 closed — person_names 降级+去重+UNIQUE（方向 C 混合：写端 backfill 17 行 primary→alias + resolve.py demote；读端 name 文本 dedup 4 级排序；UNIQUE (person_id,name)；9 new tests → 61 api tests；2 commits）；衍生债 T-P1-004 registered
- 2026-04-19：T-P2-002 closed — slug 命名一致性清理（方向 3 分层白名单：data/tier-s-slugs.yaml 74 条 + slug.py 模块 + load.py 重构；ADR-011 accepted；26 new tests → 218 pipeline tests + 3 DB invariant；零 DB 变更；零 URL 变更；3 commits）
- 2026-04-19：T-P1-004 closed — NER 单人多 primary 约束（ADR-012 三层防御：NER prompt v1-r3 + load.py _enforce_single_primary auto-demotion + QC ner.single_primary_per_person；共享 is_di_honorific；32 new tests → 250 pipeline tests；零 DB 变更；4 commits；tip a50c2f9）
- 2026-04-19：CI 基建修复 — 堵上 pipeline SQL 迁移在 CI 未应用的漏洞（person_merge_log 不存在触发 #76/#77 红灯），ci.yml 新增 Step 4c 按文件名顺序 psql -f 跑 `services/pipeline/migrations/*.sql`；`test_slug_count_sanity` 加 `pytest.skip()` 兜底空 DB 环境（#78 红灯修复）；2 commits（b55beb8 + 0a4aa78）；#79 全绿；T-P1-004 rebase 上推 #80 全绿；衍生债 T-P1-005 registered
- 2026-04-19：T-P0-022 + T-P0-020 合并 sprint（F10 demote 8 行 + persons CHECK 约束 + ADR-010 supplement；tip 9a19140）
- 2026-04-19：T-P0-016 sprint（双路径 is_primary 同步 + backfill 18→0 + V6 invariant + F12 debt；tip 7566916）
- 2026-04-19：V1-V6 全套 invariant 首次集体绿；CI run #24629863280 全绿
- 2026-04-19：T-P0-023 sprint 完成（证据链 Stage 1 激活；6 commits；+10 tests；migration 0008；V7 warning 级不变量；smoke 验证盲点登记 T-P1-006）
- 2026-04-20：T-P0-006 α sprint 完成（周本纪 82 段 ingest + evidence 写路径验证 + 29 persons merge；8 commits；persons 153→320；source_evidences 0→242；V7 0%→52.48%；LLM $0.77；衍生 T-P1-007~010）
- 2026-04-21：T-P0-024 α sprint 完成（证据链主回填 Path C 混合：C1 β hash 复用 + C2 Phase A/B 重抽取 fast lane；source_evidences 242→412；V7 52.48%→96.37%（+43.89pp）；LLM $0.78；5 commits + 2 merges；衍生 T-P1-011~020）
- 2026-04-21：T-P0-026 字典种子研究完成 — ADR-021 Dictionary Seed Strategy accepted（open-data-first；Wikidata 作为唯一 TIER-1 源；CBDB 因 CC BY-NC-SA 延后；17570d6）
- 2026-04-21：Sprint A 收官（T-P0-019 α β 尾巴清理）— Stage 1 V6 28→0（name_type 修正）/ Stage 2 F1 6 行硬 DELETE per ADR-022（V7 96.37%→97.49%）/ Stage 3 F2 3 行 V8 规则精化（合法古汉语 anaphoric short-form 双豁免，不删）；ADR-022 accepted + ADR-023 accepted（V8 Prefix-Containment Invariant 与 V1-V7 同级）；6 commits；T-P1-013/014/015 closed；衍生 T-P1-021（canonical merge missed pairs）
- 2026-04-21：Sprint B 启动 — T-P0-025 Gate 0a Wikidata 覆盖率 probe 完成（commit 4cf34b5）；320 active persons / 54.4% 命中率（174/320；Round 1 精确 49.1% + Round 2 alias +17）；8 条多候选（2.5%）；朝代分层商 70.5% / 春秋 59.1% / 西周 46.3% / 夏 45%；decision matrix 落 "≥40% 全量推进" 桶；245s elapsed / 0 HTTP 错误；副发现 27 person 缺 primary name（V1 下界盲点 → T-P1-022 registered）
- 2026-04-21：T-P0-025 任务卡按 ADR-021 对齐重写（pre-ADR-021 40-JSON 窄范围 → Sprint B 完整规格 6 Stage + Round 3 新增 person_names 全表扫描以覆盖 Type B label mismatch 如 高辛↔帝喾）；原需求演化为 T-P0-025b（TIER-4 self-curated seed patch，backlog）
- 2026-04-21：Sprint B Stage 0b done（commit 199e8ba）— migration 0009 三表落地（dictionary_sources / dictionary_entries / seed_mappings）；Drizzle J layer seeds.ts + index.ts 导出 + pg_dump anchor pre-t-p0-025-stage-0b-20260421-234943.dump；CHECK 约束（entry_type 5 枚举 / confidence 0-1 / mapping_status 3 枚举）+ 三索引（idx_seed_mappings_target partial + idx_dictionary_entries_primary_name + idx_dictionary_entries_source）全部就位；pipeline 282 + api 61 tests 全绿；V1-V8 无回归；衍生债 T-P1-023（uniqueIndex 命名不一致，P2）
- 2026-04-22：ID 治理修订 — T-P0-026 撞号澄清（仅研究文档 ID，不复用为 task card）+ T-P0-025b 含义边界明确（≠ retro §4 误用的 manual triage UI）+ 新立 T-P0-027 / T-P0-028 stub；流程改进：未来 research 文档使用独立命名空间（建议 R-NNN）
- 2026-04-22：Sprint C Stage 1-4 完成（R6 pre-pass + merge detection + V11 invariant + 13 tests）；Stage 1 Stop Rule #1 触发→方案 A 修复；Stage 4 发现 R6 FP（启↔微子启 Q186544）→挂起等 historian
- 2026-04-24：Sprint C Stage 5 路径 A 收口 — historian ruling 98de7bc 确认 Q186544=夏启，R6 merge rejected；R1 merge ×1 apply（鲁桓公↔桓公 → run_id 2b4a28f0）；wei-zi-qi seed_mapping 降级 pending_review；开 T-P0-029/030；319 active persons / 158 active seeds / V1-V11 全绿
- 2026-04-24：Sprint D 完成（T-P0-029 R6 Cross-Dynasty Guard）— 方案 α（persons.dynasty midpoint > 500yr）；migration 0012 pending_merge_reviews；r6_temporal_guards.py evaluate_guards() chain；dynasty-periods.yaml 12 条；22 new tests；4 commits；Stop Rule #2 接受为 baseline change；V11 全绿；active persons 319 不变
- 2026-04-24：Sprint E Track A 完成（T-P0-030 corrective seed-add）— wei-zi-qi → Q855012（historian_correction）；dictionary_entry + seed_mapping(active) + source_evidence(seed_dictionary) 三步同事务；active seeds 158→159；V10+V11 全绿；1 commit；$0 LLM
- 2026-04-25：Sprint E Track B 完成（T-P0-006-γ 秦本纪）— 72 段 ingest / 266 NER persons / $0.83 LLM；35 merge proposals → historian ruling 3280a35（21/5/9）→ 29 soft-deletes apply（+V10a seed redirect）；active persons 319→585→556；merge_log 53→82；V1-V11 全绿（V1=94 存量）；衍生 T-P1-024/025/026 + T-P2-004
- 2026-04-25：Sprint E 收口 — task card T-P0-006-γ + 4 debt stubs + retro + STATUS + CHANGELOG；Sprint E 完成标记
- 2026-04-25：Sprint F 完成 — V1 根因修复（load.py Bug 1+2 → 94→0）+ V9 invariant 上线（ADR-024 bootstrap=0）+ 4 衍生债 close（T-P1-024/025/026 + T-P2-004）+ 重耳↔晋文公 textbook merge；active persons 555 / merge_log 83 / V1-V9+V10-V11 全绿；8 commits + $0.163 LLM
- 2026-04-26：Sprint G 完成 — T-P0-006-δ 项羽本纪 ingest（45 段 / +117 persons / $0.60）+ Stage 4 apply（9 merges）；active persons 663 / merge_log 92 / V1-V11 全绿；Sprint F 修复真实验证（新数据 V1+V9 +0）；textbook-fact 2/3 阈值（G15 项籍→项羽）；T-P0-031 P0 升格（楚怀王 entity-split）；衍生债 T-P1-027/028 + T-P2-005；3 commits (C31-C33)

---

## 技术债索引

### ~~T-P1-002: merge 后 person_names 的 nameType 未降级 + 重复名未去重~~ — **closed 2026-04-19**

- **修复**：方向 C（混合）— 写端 backfill 17 行 primary→alias + resolve.py apply_merges() 自动降级；读端 findPersonNamesWithMerged() 按 name 文本去重（4 级排序：canonical-side → merge_at DESC → source_evidence_id → created_at）
- **结果**：19 canonical 多 primary → 0；11 对跨 person_id 重复由读端兜住；UNIQUE (person_id, name) 约束已添加
- **已知 tradeoff**：T-P0-015 帝鸿氏 alias 的 source_evidence_id 被 canonical-side null 行遮挡（dedup 规则 a 击穿规则 c 的副作用），非 bug

### ~~T-P1-004: NER 阶段单人多 primary 约束~~ — **closed 2026-04-19**

- **修复**：ADR-012 三层防御 — NER prompt v1-r3 单 primary 约束 + load.py `_enforce_single_primary()` auto-demotion + QC 规则 `ner.single_primary_per_person`
- **结果**：single-primary 成为管线不变量；共享 `is_di_honorific()` 帝X 检测；32 new tests；零 DB 变更
- **衍生**：无（DB partial unique index 评估后决定不加，ingest 两层防御足够）

### ~~T-P1-003: pg_trgm 搜索对"帝X"类查询召回过宽~~ — **closed 2026-04-19**

- **修复**：length-weighted similarity threshold（≤2 chars: 0.5, 3 chars: 0.4, 4+ chars: 0.3）+ aliasSubstringSearch fallback
- **结果**：F1 95.6%→100%，3 disallowed violations→0，30 条黄金集全部通过

### ~~T-P2-002: persons.slug 命名不一致~~ — **closed 2026-04-19**

- **修复**：方向 3（分层白名单）— Tier-S 人物用 pinyin slug（74 条白名单 `data/tier-s-slugs.yaml`），其余用 unicode hex fallback
- **结果**：slug 规则明文化；`slug.py` 模块化生成；不变量测试 CI 保证；零 DB 变更；零 URL 变更
- **治理**：新增白名单条目必须附带 ADR/CHANGELOG 记录（ADR-011）

### ~~T-P1-013: alias+is_primary=true（Phase A/B 遗产 28 行）~~ — **closed 2026-04-21**

- **修复**：Sprint A Stage 1 — 28 行 `name_type='alias' AND is_primary=true` → `UPDATE SET name_type='primary'`（采用"降格为合法 primary"路径，保留 is_primary=true；架构师原提议 is_primary 翻转由工程师 SQL 精化为 `name_type` 修正，两者对 V6 皆等价）
- **结果**：V6 转绿（28 → 0）；零 DELETE、零 merge；V1-V5 无回归
- **commit**：5639868

### ~~T-P1-014: F1 代词 / 光秃爵位残留清理~~ — **closed 2026-04-21**

- **修复**：Sprint A Stage 2 — 6 行（帝×2 / 王×2 / 朕 / 予一人）per ADR-022 三要素全满足 → 硬 DELETE + pg_dump anchor
- **三要素判定**：Evidence 链零依赖（`source_evidence_id IS NULL` 6/6）+ 语义非合法名（代词 / 光秃爵位）+ FK 零引用（0 表引用）
- **机械性副作用**：V7 覆盖率 96.37% → 97.49%（分母 524→518，分子 505 不变）——非 extraction 改善
- **commit**：b986891 + pg_dump anchor `f32964f4...`

### ~~T-P1-015: 短名夏王 disambiguation（F2 prefix residuals）~~ — **closed（名义，规则化处理）2026-04-21**

- **原意图**：对单字"伯 / 管 / 蔡"等短名做 disambiguation 或清理
- **实际处置**：Sprint A Stage 3 Gate 0b 审计发现 3 行全部 `source_evidence_id IS NOT NULL` + `name_type='alias'`——属合法古汉语 anaphoric short-form（《尚书·舜典》§15 立名短形回指伯夷；《史记·周本纪》"管蔡畔周"并列缩略），不适用 ADR-022 硬 DELETE
- **结论**：不删数据；改立 **ADR-023 V8 Prefix-Containment Invariant**（与 V1-V7 同级）防御未来回归。V8 SQL 对 α evidence-backed OR β alias-typed 豁免，生产数据 0 violations
- **衍生债**：T-P1-021（V8 probe 副产品：canonical merge missed pairs 管叔/管叔鲜、蔡叔/蔡叔度）
- **commit**：7629726（V8 实现 + self-test）+ 2dd53c9（ADR-023）+ af7581d（ADR-022）

### T-P1-005: 统一 migration 入口（Drizzle + pipeline SQL 双轨合一）— **registered 2026-04-19**

- **现状**：`pnpm db:migrate` 只跑 Drizzle 迁移（`services/api/src/db-migrate.ts`）；pipeline 独占表（`person_merge_log`、`idx_persons_merged_into` 等）存活在 `services/pipeline/migrations/*.sql`，需手工 `psql -f` 应用
- **触发事件**：CI #76/#77 因 `person_merge_log does not exist` 红灯 — pipeline SQL 迁移在 CI 从未被应用，本地依赖手工执行掩盖了漏洞；临时通过 ci.yml Step 4c for-loop 应用修复（b55beb8）
- **问题**：两个入口 + 两种执行习惯 → 环境漂移（local dev / CI / prod 可能各异）；db:reset 无法保证全量 schema
- **修复候选**：
  1. `pnpm db:migrate` 脚本末尾追加 pipeline SQL 应用步骤（简单、显式）
  2. 迁移 pipeline SQL → Drizzle 管理（需把 `person_merge_log` 等搬入 Drizzle schema，但破坏"pipeline 独占"边界）
  3. 引入统一 migration runner（如 sqitch/flyway）同时管理两侧（重）
- **建议**：方向 1（追加步骤）+ 保留 pipeline SQL 作为幂等补丁源
- **影响**：本地 `pnpm db:reset` / `db:migrate` 全量正确；CI Step 4c 可退化为 `pnpm db:migrate` 一句；新人 onboarding 不再踩手工 psql 坑
- **优先级**：P1 — 不阻塞 β 路线，但 T-P0-006（扩量跑）开始前建议闭环
