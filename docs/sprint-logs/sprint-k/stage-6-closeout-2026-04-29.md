# Sprint K Stage 6 — Closeout + 战略转型衔接

> Sprint K = T-P0-028 Pending Triage UI V1
> 完成日期：2026-04-29
> 主导：首席架构师（统筹）+ PE / BE / FE / Hist 协同
> 收档形态：常规 closeout + **D-route 战略转型衔接节点**

---

## 0. Summary

Sprint K 是华典智谱项目的**两个里程碑同时达成**：

1. **首个完整跨角色 5-stage Sprint** — PE / BE / FE / Hist / Architect 5 角色协同 + 4-stage workflow（dry-run / review / apply / verify）+ 真实 Hist E2E + ADR-027 落地
2. **D-route 战略转型节点** — Sprint K 完成同日（2026-04-29）触发 ADR-028 战略转型，项目方向从 C 端古籍知识平台 → Agentic KE 工程框架 + 史记参考实现

本 closeout 同时记录两件事的产出 + 衔接关系。

---

## 1. Sprint K 任务回顾

### 1.1 Stage 顺序与产出

| Stage | 主导 | 状态 | 关键产出 |
|-------|------|------|----------|
| Stage 0 — Inventory + Brief | Architect | ✅ | stage-0-brief / 4 角色 inventory 报告 |
| Stage 1 — ADR-027 + Design Doc | Architect | ✅ | ADR-027（11 sections / 8 sign-off points）+ stage-1-design |
| Stage 2 — BE schema + PE backfill | BE / PE | ✅ | migration 0014 + 175 TD backfill + 18 PMR backfill |
| Stage 3 — FE Triage UI 实现 | FE | ✅ | apps/web/app/triage/* + middleware + 7 e2e tests + label fix |
| Stage 4 — 集成 smoke | BE / FE | ✅ | DATABASE_URL fix（commit b3dd15f）+ 7/7 e2e green |
| Stage 5 — Hist E2E | Hist | ✅ | 真实历史学家 1 reject + 1 approve 决策提交，DB audit 完整 |
| Stage 6 — Closeout（本文件）| Architect | ✅ | 本文件 |

### 1.2 数据 / 工程基线

| 维度 | Sprint K 前 | Sprint K 后 | Δ |
|------|-----------|-----------|-----|
| Active persons | 729 | 729 | 不变（Triage UI V1 zero-downstream）|
| pending_merge_reviews | 0 | 18 | +18 backfill |
| triage_decisions | 0 | 177 | +175 backfill + 2 真实 E2E |
| ADR 总数 | 27 (ADR-001~027) | 29 (+ADR-028 + ADR-029) | +2 |
| migration | 13 | 14 | +1 (0014 triage_decisions) |
| V1-V11 invariants | 22/22 全绿 | 22/22 全绿 | 0 回归 |

### 1.3 Commits 总数（Sprint K 期间）

约 20+ commits，涵盖：
- BE schema + service + GraphQL（Stage 2，7 commits）
- FE pages + components + e2e（Stage 3，4 commits）
- PE backfill scripts + dry-run + apply（Stage 2 prep + Stage 2，5 commits）
- BE DATABASE_URL fix（Stage 4a，1 commit）
- FE provenanceTier label fix（Stage 4b 收尾，1 commit）
- ADR-027 文档落地 + design doc + Hist inventory（Stage 0/1，多 commits）

---

## 2. Sprint K 实证亮点

### 2.1 5-Stage Workflow 首次完整实战

Sprint K 是华典智谱第一个**所有 stage 都跨角色协同**的 sprint：

- 此前 sprint（A-J）多为单角色主导（PE 或 BE 或 Architect），Sprint K 首次 5 角色全部并行 + 顺序协同
- Tagged Sessions 协议（`【BE】` `【FE】` `【PE】` `【Hist】`）首次完整使用
- 跨 session 关键信号成功传递（BE SDL ready → FE codegen / BE migration → PE backfill / PE apply done → Hist review / etc）

### 2.2 Stop Rule 实战处理

Sprint K 期间触发 2 次 Stop Rule，全部以"明确决策 + 文档化 + 接受"方式处理：

| Stop Rule | 触发原因 | 架构师裁决 | 路径 |
|-----------|---------|-----------|------|
| PE TD 175 vs 179 backfill | Idempotency 跨 sprint 去重命中 4 行 | R1+R3 混合（接受 175 + 透明度文档）| backfill 报告补 idempotency 章节 + retro 加方法学缺陷 |
| FE provenanceTier 文案不一致 | UI 显示 raw enum vs PersonCard "未验证" | Option A（统一"未验证"）| FE commit 0579c28 + 8 测试 |

→ Stop Rule 不是阻碍 sprint 完成，是**保证 sprint 完成质量**的机制。

### 2.3 ADR-027 设计正确性验证

ADR-027 §3 schema unique key `(source_id, surface_snapshot, historian_id)` 经 Sprint K Stage 2 实战验证 = 设计意图正确：

- 跨 sprint 同 historian 对同 (source, surface) 重复决策时 idempotency 正确去重
- 175 行 = "unique 决策行数"语义，不是 bug
- ADR-027 §11 应添 footnote 注明此 cross-sprint 行为（衍生债登记）

### 2.4 Hist Stage 5 E2E 验证

Domain Expert 真实身份走完整工作流：

- 提交 1 reject（周成王↔楚成王 cross_dynasty）+ 1 approve（伯夷 → Q61314449）
- DB audit 完整：triage_decisions 写入 + V1-V11 不回归 + Hint Banner 显示历史决策 + nextPendingItemId 协议工作
- 可用性反馈（Step 5）：6 quick template / Hint Banner / 列表过滤行为 / 批量决策需求 / V2 priority

---

## 3. 衍生债登记

### 3.1 V2 候选（来自 Sprint K Hist Stage 5 反馈）

| ID | 描述 | 优先级 | 来源 |
|----|------|--------|------|
| T-P0-028.V1.1 | 列表页过滤已决策 item（V1 zero-downstream UX gap）| P0（V1.1 即时 follow-up）| Hist Step 5 反馈 #1 工作流流畅度 |
| T-P0-028.V1.1.b | Hint Banner 加历史 reason_text 摘要预览 | P1 | Hist Step 5 反馈 #2 信息密度 |
| T-P0-028.V1.1.c | 6 quick template 折叠"不常用"3 个 | P2 | Hist Step 5 反馈 #3 |
| T-P0-028.V2.a | 批量决策（select N rows → bulk reject with shared reason）| P0 V2 | Hist Step 5 反馈 #6 V2 最想要 |
| T-P0-028.V2.b | DONE / AUDIT 队列页 + `recentTriageDecisions` query | P1 V2 | BE Stage 4a 语义差异讨论 |

### 3.2 ADR-027 §11 footnote

- 内容：跨 sprint 同 pair 同 surface 同 historian 同 decision 视为单一决策（idempotency 设计意图）
- 状态：候选 P2 — 等 ADR-014 addendum 一并起草

### 3.3 BE 提出的 4 个衍生债 candidates

来自 BE Stage 4a 报告：

- **T-P1-032 provenance_tier sync**（PMR backfill evidence 缺 source_evidence_id 字段，fallback 'unverified'）
- historian-allowlist shared package（FE + BE 各自拷贝同一份 yaml/ts）
- person-search test isolation（与 Sprint K 不直接相关，但 Sprint K test isolation 也是参考）
- T-P0-028.V2 backlog（如 §3.1 所列）

### 3.4 PE 提出的方法学衍生债

- **T-P3-XXX 跨 sprint 历史学家裁决估算方法学修订**（来自 Stage 2 backfill 175 vs 179 教训）
- 内容：未来跨 sprint backfill 估算应：
  1. 先估 PMR unique pair 数
  2. 再估每个 pair 在多 sprint 中的重复裁决数
  3. TD 预期 = sum over PMR rows × historian 实际写入次数（idempotency 去重后）

---

## 4. D-route 战略转型衔接（2026-04-29）

### 4.1 触发

Sprint K 收档同日（2026-04-29），项目经过深度战略反思（详见 ADR-028 §1）触发**战略转型**：

- 第三方调研：shiji-kb / 字节识典古籍 / chinese-poetry / 永乐大典 等
- 关键发现：在"古籍数据完整度"维度，我们落后头部玩家 1-2 年；但 Sprint A-K 沉淀的工程资产（多角色 / Sprint 治理 / identity resolver / V1-V11 / triage UI）是更稀缺的"团队级 KE 框架"
- 战略选择：**D-route — Agentic KE 工程框架 + 史记参考实现**

### 4.2 Sprint K 工作 → D-route 衔接

Sprint K 的工程产出**非常匹配** D-route 战略，无需任何 sunset：

| Sprint K 产出 | D-route 价值 |
|-------------|-------------|
| ADR-027 三表 schema（pending_merge_reviews / triage_decisions / merge_log）| → AKE 框架 Layer 1 P1 抽象资产（参见 docs/methodology/05-audit-trail-pattern.md）|
| Triage UI V1 工作流 + 6 quick templates | → AKE 框架 Layer 1 P1 抽象资产 |
| 4-stage workflow（dry-run / review / apply / verify）| → AKE 框架 Layer 1 P0 抽象资产（参见 docs/methodology/02-sprint-governance-pattern.md §5）|
| Multi-role tagged sessions 协议 | → AKE 框架 Layer 1 P0 抽象资产（参见 docs/methodology/01-role-design-pattern.md §3）|
| Stop Rule 实战处理（175 vs 179 / provenanceTier 文案）| → AKE 框架 ADR pattern 案例（参见 docs/methodology/06-adr-pattern-for-ke.md §3.6）|
| Hist E2E 验证 | → AKE 框架"参考实现"可信度证明 |

### 4.3 Stage A-D 文档体系对齐（伴随 Sprint K closeout）

D-route 文档体系对齐分 4 个 stage 完成（详见 docs/STATUS.md §2.1）：

- **Stage A** — 战略锚点（ADR-028 + D-route-positioning）✅
- **Stage A.5** — 许可证 + public-facing（LICENSE / CONTRIBUTING / README / ADR-029 / NOTICE / LICENSE-DATA）✅
- **Stage B** — 核心身份（CLAUDE.md 重写 + 项目宪法 §六 D-route 原则 C-22~C-25 + STATUS 重写 + 架构 v2.0）✅
- **Stage C** — 操作文档加框架视角 + docs/methodology/ 7 份草案 + 10 角色加框架抽象段 ✅
- **Stage D** — Sprint K 收档（本文件）+ Sprint L brief + 任务卡分类 + sprint roadmap + CHANGELOG ✅

---

## 5. D-route 资产沉淀盘点

### 5.1 本 sprint 沉淀的可抽象 pattern（C-22 / C-23 应用）

按 ADR-028 §Appendix B 的 pattern 优先级表：

| # | Pattern | Sprint K 实证 | 抽象成熟度 |
|---|---------|--------------|-----------|
| 1 | Sprint / Stage / Gate workflow | 5 stage 跨角色协同首次完整使用 | ⭐⭐⭐⭐⭐（已极成熟）|
| 6 | Audit + triage workflow | ADR-027 + Triage UI V1 完整落地 | ⭐⭐⭐⭐（首次完整实证）|
| 7 | Backfill idempotency | Stage 2 175 vs 179 实战 | ⭐⭐⭐⭐（设计意图被实战验证）|
| 8 | dry-run → historian review → apply | Stage 2-5 完整走完 | ⭐⭐⭐⭐（4-stage workflow 抽象 ready）|

### 5.2 本 sprint 暴露的"案例耦合点"

需要在框架抽象时注意：

- **Triage UI 的 6 quick templates** 当前是史记 domain-specific（in_chapter / other_classical 等），抽象时需变为可配置
- **historian-allowlist.yaml** 当前硬编码 chief-historian / backfill-script / e2e-test，抽象时需变为 plugin-style 注入
- **provenanceTier enum 文案**（"未验证" / "二手古籍" / 等）是中文古籍 domain，抽象时需 i18n

### 5.3 Layer 进度推进

| Layer | Sprint K 推进 |
|-------|-------------|
| L1 框架代码 | +0 行抽象代码（本 sprint 工作集中在 案例层 + 战略转型）|
| L2 方法论文档 | **+7 份草案 v0.1** (`docs/methodology/00-06`)，含 Sprint K 实证素材 |
| L3 案例库 | Triage UI V1 = "框架真的 work"的活体证明 |
| L4 社区 / 商业 | 项目转 public + 许可证就绪（Apache 2.0 + CC BY 4.0）= 社区参与门槛降低 |

### 5.4 下一 sprint 的抽象优先级建议

依据 Sprint K 实战，建议 Sprint L 抽象优先级排序：

1. **P0**：Sprint / Stage / Gate workflow 抽象（最成熟，影响面广）
2. **P0**：Multi-role coordination 抽象（角色 templates + tagged sessions 协议）
3. **P1**：Audit + triage workflow 抽象（schema 部分领域无关，UI 部分需 i18n）
4. **P1**：Identity resolver R1-R6 + GUARD_CHAINS 抽象（接口领域无关，guard 实现领域专属）
5. **P2**：V1-V11 invariant pattern 抽象（5 大类 pattern 模板）

详见 docs/strategy/sprint-roadmap-D-route.md 即将起草。

---

## 6. Lessons Learned

### 6.1 工作得好的部分

1. **Tagged Sessions 协议在多 session 并行时显著减少混淆** — Sprint K 是首次实战，效果显著
2. **Stop Rule 提前预声明在 brief 中** — 触发时不需要"现编"决策路径
3. **ADR-027 §3 unique key 设计经实战验证** — 跨 sprint 数据完整性保护正确
4. **架构师 Inline 裁决能力** — Stop Rule 触发后能快速给出 R1+R3 等结构化决策选项（Sonnet 4.6 或 Opus 4.7 均可处理）

### 6.2 改进点

1. **Stage 0 inventory 阶段的"真实数据基线"应早期 verify** — Sprint K Stage 0 PE 调查发现 PMR=0（不是 brief 假设的 16），导致需要补 backfill 工作
2. **Sprint K Stage 2 backfill 估算方法学缺陷** — dry-run 估算 179 vs 实际 175，跨 sprint 重复决策没考虑 idempotency 去重（→ T-P3 衍生债）
3. **provenanceTier 文案应在 ADR-027 中提前列出枚举映射表** — 避免 BE/FE 各自实现时不一致（→ T-P1-032）

### 6.3 模型选型 retro（per ADR-028 §2.3 Q5）

Sprint K 期间使用：
- 主 session（Architect）：Opus 4.7
- 子 session（PE / BE / FE / Hist）：Sonnet 4.6

效果：
- ✅ 跨角色协调流畅
- ✅ 子 session Stop Rule 报告质量高（Sonnet 已能处理 R1/R2/R3 选项推荐）
- ✅ Architect 主 session 战略 / ADR / 仲裁 复杂决策由 Opus 处理
- ⚠️ 1 次 PE Stop Rule（175 vs 179）的根因诊断 Sonnet 完全胜任，不需要切 Opus
- ⚠️ Hist Stage 5 在 Sonnet 下 E2E 报告质量充分（不需要 Opus）

→ 经验：multi-role 协作 sprint 推荐 **主 Opus + 子 Sonnet** 模式。

---

## 7. 下一步（Sprint K → Sprint L 衔接）

### 7.1 不再做的事

依据 ADR-028 + D-route §7 Negative Space：

- ❌ 不再启动新 ingest sprint（违反 C-22 案例服务于框架）
- ❌ T-P1-030 ADR-014 addendum 不立即做（虽然 textbook-fact 已 4 例触发；可降级到 P3 backlog）
- ❌ 不在 Sprint L 启动前修复 ADR-027 §11 footnote（T-P3 batch 处理）

### 7.2 接下来做的事

依据 ADR-028 §2.3 Q3 + 本文件 §5.4：

- ✅ **Sprint L** = 框架抽象第一刀 + 产品化 demo 双 track（详见 docs/sprint-logs/sprint-l/stage-0-brief-2026-04-29.md，已起草）
- ✅ Sprint L 启动前用户做"假装新协作者"5 分钟测试（按"开工三步"读 CLAUDE.md → STATUS → CHANGELOG，验证能理解新方向）

---

## 8. 决策签字

- 首席架构师：__ACK 2026-04-29__
- 信号：本 closeout 接受 → Sprint K 关档 → Sprint L 准备启动（待 Stage D 全部完成 + 用户测试通过）

---

**本 closeout 起草于 2026-04-29 / Stage D-1 of D-route doc realignment**
