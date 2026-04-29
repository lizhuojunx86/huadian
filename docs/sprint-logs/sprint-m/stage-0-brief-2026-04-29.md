# Sprint M Brief — Multi-Role Coordination 抽象（framework/role-templates/）

> 起草自 `framework/sprint-templates/brief-template.md`
> Dogfood: 这是该 brief 模板的**第二次**外部使用（第一次是 Sprint L 用它给自己起草 brief）

## 0. 元信息

- **架构师**：首席架构师（Claude Opus 4.7）
- **Brief 日期**：2026-04-29
- **Sprint 形态**：**单 track**（纯文档抽象工作；不需要 Claude Code sub-sessions）
- **预估工时**：1 个 Cowork 会话内可完成（极致压缩，与 Sprint L 同节奏），或分 2-3 个会话（更舒缓）
- **PE 模型**：N/A（单 track 文档抽象，PE 角色不参与）
- **Architect 模型**：Opus 4.7（架构师 session 全程承担 + 与 Sprint L 同模型选型）
- **触发事件**：Sprint L closeout §2.4 + retro §7.4 推荐 — Sprint L Sprint workflow 抽象完成后，"治理 / 协作"层下一刀自然落到 Multi-role coordination
- **战略锚点**：[ADR-028](../../decisions/ADR-028-strategic-pivot-to-methodology.md) §2.3 Q3（双 track）+ Sprint L Stage 1 Track 1 完成后的连续推进；C-22 案例服务于框架 / C-23 工程模式必须可抽象

---

## 1. 背景

### 1.1 前置上下文

Sprint L（2026-04-29 完成）落地 Layer 1 第一刀：`framework/sprint-templates/` v0.1（11 files / ~1500 lines），把 Sprint A-K 的 Sprint workflow 抽象为领域无关模板。

Sprint L closeout §2.4 + retro §7.4 推荐 Sprint M 主题为 **Multi-role coordination 抽象**，理由：

- **知识体系连续**：与 Sprint workflow 抽象相邻，同属"治理 / 协作"层（vs 跳到 identity resolver / invariants 这种代码层）
- **工作量可控**：与 Sprint L 接近（~1500 行模板 + dogfood），纯文档抽象不动代码
- **完成后构成 framework/ 下"治理类"双模块**（sprint-templates + role-templates），具备对外发版 v0.2 条件
- **抽象输入已就绪**：`docs/methodology/01-role-design-pattern.md` 草案 v0.1 + `.claude/agents/*.md` 10 份（含 D-route 框架抽象元描述段）+ Sprint K Tagged Sessions 实战经验三者齐备

Sprint M 在 D-route Layer 1 大局中的位置：

```
L1 第一刀 (Sprint L)   →   L1 第二刀 (Sprint M)      →   L1 第三刀候选 (Sprint N+)
sprint-templates/         role-templates/                identity-resolver/ 或
(治理工作流)              (角色协作)                      invariant-scaffold/
                                                         (代码层抽象，需 Sonnet PE)
```

### 1.2 与既有 sprint 的差异

| 维度 | Sprint L | Sprint M |
|------|----------|----------|
| Track 数 | 双 track（框架 + demo）| **单 track**（仅框架抽象）|
| 抽象对象 | Sprint / Stage / Gate / Stop Rule 治理 | 角色边界 + tagged sessions 多 session 协调 |
| 抽象输入 | docs/methodology/02 + Sprint A-K 11 个 sprint 实证 | docs/methodology/01 + .claude/agents/*（10 份）+ Sprint K Tagged Sessions 实战 |
| 代码改动 | 0（纯文档抽象）| **0**（纯文档抽象，与 L 一致）|
| 子 session | 0 | **0**（Cowork 单 session）|
| 涉及角色 | Architect 🟢 + 名义上 PE/BE/FE/QA 🟡 | Architect 🟢 单角色，其余全 ⚪ |
| dogfood 形态 | 用模板回审 Sprint K brief（覆盖度 90%）| 用新模板回审 Sprint K 5 角色协同实战 + 验证本 brief 即第二次 dogfood |
| 外部反馈 stage | 押后到 Sprint M 启动后接触友人时 | 同样默认押后（无紧急 timeline）|
| 衍生 framework v0.x | v0.1（首次落地）| v0.2 候选（双模块完整）|

### 1.3 不做的事（Negative Scope）

依据 D-route §7 Negative Space + ADR-028 Q1 ACK + Sprint L retro §8 不要做的事：

- ❌ **不做 framework/identity-resolver/ 抽象**（推迟到 Sprint N 候选；需要从代码层动手）
- ❌ **不做 framework/invariant-scaffold/ 抽象**（推迟到 Sprint O 候选）
- ❌ **不做 framework v0.1 公开 release**（per Sprint L retro §8；等 ≥ 2 个抽象资产稳定后才考虑——本 sprint 完成 后才开始评估）
- ❌ **不做框架命名 ADR-030**（per Sprint L retro §8；暂时无明确需求）
- ❌ **不启动新 ingest sprint**（违反 C-22）
- ❌ **不做 .claude/agents/* 的代码层重构**（10 份角色定义文件本身不动；只**抽出**领域无关版本到 framework/role-templates/）
- ❌ **不做新 ADR**（除非启动过程中触发治理 / 命名 / 策略类强制讨论）
- ❌ **不做 Stage 2-3 外部审**（与 Sprint L 同样默认押后到外部反馈触发）

---

## 2. 目标范围

### 2.1 单 Track — Multi-Role Coordination 抽象

**目标**：把 Sprint A-K 实证可行的 10 角色协作模式 + tagged sessions 多 session 协调协议抽象成领域无关的 `framework/role-templates/` v0.1，让任何 KE 项目能复制一份就能运行同样形态的多 agent 团队。

**具体动作**：

#### 2.1.1 `framework/role-templates/` 10 份角色模板

参照 docs/methodology/01-role-design-pattern.md §2.1 角色定义模板（8 段：Mission / Authority / Responsibility / No-fly Zone / Handoff Contract / Escalation / Bootstrap / Closeout）抽出：

| # | 模板文件 | 抽象自 | 领域无关程度 |
|---|---------|-------|------------|
| 1 | `chief-architect.md` | `.claude/agents/chief-architect.md` | 完全无关 |
| 2 | **`domain-expert.md`** | `.claude/agents/historian.md` | 含 ⚠️FILL 占位（角色名称 / 专业领域 / dictionary 类型）|
| 3 | `pipeline-engineer.md` | `.claude/agents/pipeline-engineer.md` | 完全无关（NER prompt 等案例细节用 ⚠️FILL）|
| 4 | `backend-engineer.md` | `.claude/agents/backend-engineer.md` | 完全无关 |
| 5 | `frontend-engineer.md` | `.claude/agents/frontend-engineer.md` | 完全无关 |
| 6 | `product-manager.md` | `.claude/agents/product-manager.md` | 完全无关 |
| 7 | `ui-ux-designer.md` | `.claude/agents/ui-ux-designer.md` | 完全无关 |
| 8 | `qa-engineer.md` | `.claude/agents/qa-engineer.md` | 完全无关 |
| 9 | `devops-engineer.md` | `.claude/agents/devops-engineer.md` | 完全无关 |
| 10 | `data-analyst.md` | `.claude/agents/data-analyst.md` | 完全无关 |

每份模板继续沿用 Sprint L 的 **⚠️FILL 占位符模式**，凡领域专属的字段（如 `historian` 的"古籍专家"、"史记 / 春秋 / etc"、"dynasty-periods.yaml" 等）用 `⚠️FILL-XXX` 占位 + `⚠️ DOMAIN-SPECIFIC: <说明>` 注释标识。

#### 2.1.2 `framework/role-templates/tagged-sessions-protocol.md`

抽出 docs/methodology/01-role-design-pattern.md §3 Tagged Sessions 协议 + CLAUDE.md §8.1 多 session 并行规约 + Sprint K 5 角色协同实战 → 一份完整的领域无关 multi-session 协调协议文档，覆盖：

- **tag 命名约定**：`【BE】`/`【FE】`/`【PE】`/`【DomainExpert】`/`【QA】`/`【DevOps】`/`【Architect】`（注意 Domain Expert tag 留 ⚠️FILL 让案例方填）
- **跨 session 关键信号 handoff 协议**：来自 docs/methodology/01 §3.3 + CLAUDE.md §8.1 关键信号清单（5 类信号）
- **session 启动模板**：6 步必读文件（CLAUDE.md / STATUS / CHANGELOG / role.md / 任务卡 / TodoList）
- **session 收尾模板**：5 步必更新（交付物摘要 / STATUS / CHANGELOG / ADR / handoff_to）
- **冲突升级 3 级机制**：来自 docs/methodology/01 §4
- **协议反模式**：万能角色 / 跨角色越位 / 隐式 handoff（来自 docs/methodology/01 §7）
- **Sprint K 实证案例段**：作为案例附录证明协议真的 work（含 4 角色 + Architect 协同 5-stage 1 工作日完成的具体数据）

#### 2.1.3 `framework/role-templates/README.md`

参照 `framework/sprint-templates/README.md` 同款结构（8 段：是什么 / 何时用 / 文件清单 / 5 分钟上手 / 跨领域使用指南 / 设计哲学 / 反模式 / 反馈与贡献）。

特别强调"10 个角色中只有 1 个需要领域 instantiate（Domain Expert），其余 9 个完全领域无关"这个核心观察（来自 methodology/01 §2 关键观察），让外部使用者第一眼就明白迁移成本极低。

#### 2.1.4 `framework/role-templates/cross-domain-mapping.md`

跨领域 instantiation 速查表（佛经 / 法律 / 医疗 / 专利 / 学术研究 等领域 → Domain Expert 应填什么），来自 docs/methodology/01 §2 表格 + framework/sprint-templates/README.md §4.1 已有 mapping 的扩充。本文件是案例方"读完就能动手"的关键素材。

**完成判据**（5 项）：

- ✅ `framework/role-templates/` 下 10 份角色模板全部就位（领域无关 + ⚠️FILL 占位规范）
- ✅ `tagged-sessions-protocol.md` 含 Sprint K 实证案例段
- ✅ `README.md` + `cross-domain-mapping.md` 就位
- ✅ dogfood：用 `framework/role-templates/` + `tagged-sessions-protocol.md` 回审 Sprint K 5 角色 5-stage 协作过程，覆盖度 ≥ 80%（与 Sprint L Sprint K brief 回审 90% 同口径）
- ✅ docs/methodology/01-role-design-pattern.md 加 cross-reference 段引用 framework/role-templates/（与 Sprint L methodology/02 ↔ framework/sprint-templates/ 同模式）

### 2.2 Track 2

不适用（单 track sprint）。

---

## 3. Stages（5-stage 模板的 Sprint M 适配）

> ⚠️ Sprint M 与典型 KE ingest sprint 不同（无 NER / 无 LLM cost / 无 DB mutation / 无 Domain Expert review），故 Stage 1-4 中"Smoke / Full / Dry-Run / Apply"概念**不适用**。
> 沿用 Sprint L 的适配方式：复用 stage 编号 + 重命名子主题（这是 framework/sprint-templates/brief-template.md §3 的合理灵活解释）。
> 这一发现也登记为 dogfood 候选（参见 §10.2）。

### Stage 0 — 前置准备 / Inventory

**目标**：架构师 inventory 阶段，盘点 docs/methodology/01 + .claude/agents/* + Sprint K Tagged Sessions 实战的领域耦合点 + 抽象优先级排序。

**具体动作**：

- 0.1 扫 `.claude/agents/` 10 份文件，标记每段内容的"领域无关 / 领域专属 / 混合"
- 0.2 扫 docs/methodology/01-role-design-pattern.md，识别"已抽象 vs 待落地到 framework/" gap
- 0.3 扫 Sprint K stage-* 文件 + sprint-k-retro，提取 tagged sessions 实战数据（角色数 / stage 数 / 工时 / handoff 信号实例）
- 0.4 输出 `stage-0-inventory-2026-04-29.md`（与 Sprint L 同款，~3000 字）

**输出**：`docs/sprint-logs/sprint-m/stage-0-inventory-2026-04-29.md`

**Gate 0 判据**：

- 10 份 .claude/agents/ 都标了"哪段领域无关、哪段需 ⚠️FILL"
- 抽象优先级表就位（哪个角色模板先动 / 哪个后动）
- methodology/01 ↔ framework/role-templates/ 的 cross-reference 计划就位

### Stage 1 — 框架抽象起草（Sprint L 的 Stage 1 同位）

**目标**：起草 `framework/role-templates/` 全部内容（10 份角色模板 + tagged-sessions-protocol.md + README.md + cross-domain-mapping.md）。

**子集大小**：与 Sprint L 同量级 — 13 个文件 / ~1500-2000 lines / Cowork 单 session 内完成。

**具体动作**：

- 1.1 创建 `framework/role-templates/` 目录骨架
- 1.2 起草 README.md（参照 `framework/sprint-templates/README.md` 8 段结构）
- 1.3 起草 10 份角色模板（按 docs/methodology/01 §2.1 的 8 段模板抽出）
- 1.4 起草 tagged-sessions-protocol.md（含 Sprint K 实证案例段）
- 1.5 起草 cross-domain-mapping.md
- 1.6 dogfood Stage 1：用新模板回审 Sprint K 5 角色协同实战，输出 `stage-1-dogfood-2026-04-29.md`（覆盖度报告 + v0.2 衍生债登记）
- 1.7 docs/methodology/01-role-design-pattern.md 加 cross-reference 段引用 framework/role-templates/

**Gate 1 判据**：

- 13 个文件全部就位
- ⚠️FILL 占位符规范一致（与 Sprint L 同 style）
- dogfood 报告显示覆盖度 ≥ 80%
- methodology/01 cross-reference 已加

### Stage 2 — 外部反馈（默认押后）

与 Sprint L 同处理：默认押后到外部反馈时机触发。本 sprint 不阻塞关档。

**触发条件**：1-2 个朋友 / 跨领域案例方主动接触 → 用 `framework/role-templates/` 走通他们的"角色定义初稿"5 分钟测试。

**输出**：（押后）`stage-2-external-review-YYYY-MM-DD.md`

### Stage 3 — Dry-Run + Review

不适用（无 DB mutation / 无 Hist review）。

### Stage 4 — Apply

不适用（无 DB mutation）。

### Stage 5 → 重命名 Stage 4 — Closeout

**目标**：Sprint M 关档。复用 framework/sprint-templates/stage-templates/stage-5-closeout-template.md（这是该模板的**第二次** dogfood — 第一次是 Sprint L）。

**具体动作**：

- 4.1 不立独立 task card（与 Sprint L 同性质，文档抽象工作不在 docs/tasks/ 体系）
- 4.2 STATUS.md 更新（D-route Layer 1 进度：sprint-templates + role-templates 双模块；Sprint M 关档）
- 4.3 CHANGELOG.md 追加（Sprint M 条目）
- 4.4 retro 起草（复用 framework/sprint-templates/retro-template.md，第二次 dogfood）
- 4.5 衍生债登记（dogfood 第二次发现的 brief-template / role-template 改进点）
- 4.6 ADR 不更新（除非过程中触发新决策）

**Gate 5 判据**：

- STATUS / CHANGELOG / retro 全部就位
- 衍生债登记完成（与 Sprint L 4 项 P3 v0.2 候选合并或新增）
- Sprint N 候选议程拟定（推荐 identity-resolver 或 invariant-scaffold）

---

## 4. Stop Rules

> 详见 `framework/sprint-templates/stop-rules-catalog.md` 5 类模板。
> Sprint M 是 low-risk sprint（同 Sprint L），多数典型 stop rule 不适用；以下是本 sprint 实际可触发的 8 条具体条件：

1. **抽象层级判定混淆**：起草过程中发现某角色定义"领域无关 / 案例专属"边界模糊（如 historian 的"古籍版本学"是否是 Domain Expert 通用职责）→ Stop，触发架构师重审 + 必要时升级到 ADR
2. **dogfood 覆盖度 < 60%**：用新模板回审 Sprint K 5 角色协同发现 ≥ 4 个 critical 缺失 → Stop，重设计模板（同 Sprint L Stop Rule #2 模式）
3. **抽象与 Sprint L 模板风格冲突**：role-templates 与 sprint-templates 在占位符 / 命名 / 结构上分歧明显 → Stop，先起草统一约定（可能升级为 ADR-030 framework styleguide）
4. **跨领域 mapping 不可信**：cross-domain-mapping.md 起草过程中发现某领域（如医疗）实际无法用统一 10 角色模型 → Stop，重新评估"10 个角色完全领域无关"假设是否成立
5. **Sprint M 工时 > 3 个会话**：超出舒缓节奏 2-3 个会话上限 → Stop，评估是否拆 Sprint M.1 / M.2
6. **触发新 ADR ≥ 2 个**：起草过程触发治理 / 命名 / 策略类强制讨论超出预期 → Stop，先关 ADR 再继续
7. **brief-template / retro-template / closeout-template dogfood 发现 critical 缺陷（≥ 2 项）**：第二次 dogfood 暴露 Sprint L 抽出的模板真有大问题 → Stop，先迭代 sprint-templates 到 v0.2 再继续 Sprint M
8. **写作能力短板触发**：架构师无法在合理时间内完成某文件起草（如 cross-domain-mapping.md 跨 5 领域的 instantiation 表）→ Stop，AI 协作 + 软节律调整（同 Sprint L Stop Rule #8）

---

## 5. 角色边界

| 角色 | 活跃度 | 主要职责 |
|------|-------|---------|
| 首席架构师 | 🟢 主导 | 全 stage 自驱执行：inventory / 起草 13 个文件 / dogfood / closeout / retro |
| 管线工程师 (PE) | ⚪ 暂停 | 不参与（无代码层 / 无 NER）|
| 后端工程师 (BE) | ⚪ 暂停 | 不参与 |
| 前端工程师 (FE) | ⚪ 暂停 | 不参与 |
| Domain Expert（古籍专家）| ⚪ 暂停 | 不参与（不抽具体领域内容）|
| QA 工程师 | ⚪ 暂停 | 不参与（V1-V11 invariants 不动）|
| DevOps | ⚪ 暂停 | 不参与 |
| 产品经理 / UI/UX 设计师 / 数据分析师 | ⚪ 暂停 | 不参与 |

🟢 高 / 🟡 维护 / ⚪ 暂停。

**角色活跃度对比 Sprint L**：Sprint L 名义上 BE/FE/QA/DevOps 🟡（防 demo bug fix），实际全 sprint 仅架构师 🟢；Sprint M 直接全部 ⚪，更纯净 single-actor sprint。

---

## 6. 收口判定（Definition of Done）

至少 5 条：

- ✅ `framework/role-templates/` 13 个文件全部就位（10 角色模板 + tagged-sessions-protocol + README + cross-domain-mapping）
- ✅ ⚠️FILL 占位符规范与 Sprint L sprint-templates 一致（外部使用者一眼能分辨"哪些必填"）
- ✅ dogfood 通过：用新模板回审 Sprint K 5 角色协同实战，覆盖度 ≥ 80%
- ✅ docs/methodology/01-role-design-pattern.md 加 cross-reference 段引用 framework/role-templates/
- ✅ STATUS.md / CHANGELOG.md 更新（D-route Layer 1 进度推进 / Sprint M 关档）
- ✅ Sprint M retro 完成（含 D-route 资产盘点段 + Sprint N 候选议程）
- ✅ 衍生债登记（含 Sprint L T-P3-FW-001~004 状态更新 + Sprint M 第二次 dogfood 发现的新 v0.2 候选）
- ✅ V1-V11 全绿不回归（本 sprint 不改代码 / 不改数据，invariant 不存在回归风险，但仍需正式确认一次）
- ✅ Sprint N 候选议程拟定（推荐 identity-resolver / invariant-scaffold；不强求启动）

---

## 7. 节奏建议

**极致压缩节奏**（与 Sprint L 同形态）：

- 单 Cowork 会话内完成 Stage 0 + Stage 1 + Stage 4
- Stage 2-3 默认押后

**舒缓节奏**（推荐选项）：

- 会话 1：Stage 0 inventory + Stage 1 起草 README + 10 角色模板（约一半工作量）
- 会话 2：Stage 1 起草 tagged-sessions-protocol + cross-domain-mapping + dogfood
- 会话 3（可选）：Stage 4 closeout + retro + STATUS/CHANGELOG 更新

**判定标准**：

- 架构师状态良好 + 无紧急其它任务 → 极致压缩
- 写作疲劳 / 需要休息节奏 → 舒缓 2-3 会话
- 由用户决定（per Sprint L retro §8 D-route 不赶节奏原则）

不要赶节奏。D-route 的核心是**深而慢**，不是快。

---

## 8. D-route 资产沉淀预期（Layer 1+2 项目专用）

本 sprint 预期沉淀以下框架抽象资产（≥ 1 项即不违反 C-22）：

- [x] **框架代码 spike**（具体路径：`framework/role-templates/`）— 主要产出
- [x] **已有 methodology 草案的 v0.1 → v0.2 迭代**：docs/methodology/01-role-design-pattern.md 加 cross-reference 段
- [x] **跨领域 mapping 表更新**：framework/role-templates/cross-domain-mapping.md（基于 framework/sprint-templates/README.md §4.1 + methodology/01 §2 扩充）
- [x] **案例素材积累**：retro 中标注 ≥ 1 个可抽象 pattern（候选：dogfood-on-template 元 pattern / single-actor abstraction sprint pattern）
- [ ] 新增 docs/methodology/*.md 草案（不预期；本 sprint 不新增 methodology）

至少 4 项预期 → 远超 ADR-028 / C-22 的"≥ 1 项"要求。

**Layer 进度推进预期**：

- L1: 🟢 第一刀（Sprint L sprint-templates）→ 🟢 第一+二刀（Sprint M role-templates）/ +~1500-2000 行 / +1 抽象资产模块
- L2: docs/methodology/01 加 cross-reference（与 Sprint L methodology/02 同模式紧密化）/ 内容仍 v0.1
- L3: 不变（无新案例素材；可能 Sprint K 协作过程被"固化"为 case study 进 retro）
- L4: 不变（机会主义）

---

## 9. 模型选型（Sprint L Opus 4.7 复用判定）

Sprint L 全程使用 Opus 4.7，效果良好（retro §5.3 验证）。Sprint M 主题继续是抽象类工作（与 Sprint L 同性质），故继续 Opus 4.7。

判定理由：

- ✅ Sprint M 是"创设"性质（抽象 multi-role 协议、设计 cross-domain mapping）— Opus 强项
- ✅ 单 session 深度推进（与 Sprint L 同模式）— Opus 长上下文 + 决策连续性优势
- ✅ 不涉及代码 refactor（vs 未来 Sprint N identity-resolver 可能切 Sonnet 4.6）

如本 sprint 中途发现某些纯结构化抽取工作（如把 .claude/agents/* 8 段拆解为 ⚠️FILL 占位）可由 Sonnet 处理，不切，因切模型成本 > 单段抽取工作量。

---

## 10. Dogfood 设计（本 sprint 是 framework/sprint-templates/ 第二次外部使用）

### 10.1 第二次 dogfood 的目的

Sprint L 是 framework/sprint-templates/ 的"自审 dogfood"（用模板给抽出模板的 sprint 自身收档）。Sprint M 是**真正的"第二次"使用** — Sprint L 的产出第一次被另一个独立主题 sprint 使用。

观察重点：

1. brief-template.md 第一次给非 Sprint L 用 → 哪些字段不顺手？
2. stage-templates/* 6 份模板是否仍适用 Sprint M（无 KE 典型 NER / DB / Hist 流程的 sprint）？
3. retro-template.md 第二次使用是否仍合理？
4. stop-rules-catalog.md 5 类是否覆盖 Sprint M 的 8 条 stop rule？

### 10.2 起草本 brief 过程已暴露的发现（即时登记）

起草本 brief 过程中已发现的 brief-template.md / stage-templates 改进候选（待 Stage 4 retro 时正式登记）：

- **DGF-M-01**：brief-template.md §3 默认 5-stage 假设了"Smoke / Full / Dry-Run / Apply / Closeout"KE ingest 模式，对纯文档抽象 sprint 不适用 → 候选 v0.2 加 §3-alt "纯文档 sprint 适配" 段
- **DGF-M-02**：brief-template.md §0 PE 模型字段对单 actor sprint 不适用（Sprint M 无 PE）→ 候选 v0.2 加 "N/A" 占位明示
- **DGF-M-03**：brief-template.md §5 角色边界表对全 ⚪ 暂停 sprint 显得冗余 → 候选 v0.2 加"single-actor sprint"简化表

这 3 项候选与 Sprint L 已登记的 T-P3-FW-001~004 不重复，是新发现，待 Stage 4 retro 合并到 docs/debts/sprint-l-framework-v02.md 或新文件。

### 10.3 第二次 dogfood 的"用模板回审 Sprint K"任务（Stage 1.6）

**任务**：用新抽出的 `framework/role-templates/` + `tagged-sessions-protocol.md` 回审 Sprint K（T-P0-028 Triage UI V1）的 5 角色 5-stage 协同实战，看：

- 5 个角色（PE/BE/FE/Hist/Architect）的 mission / authority / handoff contract 在新模板里是否都有对应位置
- Sprint K 实际发生的 5 类 handoff 信号（BE→PE migration / PE→Architect dry-run done / Architect→Hist review prompt / Hist→Architect review report / Architect→PE Stage 4 apply）是否都能套到 tagged-sessions-protocol.md 的"跨 session 关键信号"清单
- Sprint K 仲裁案例（PE 175 vs 179 / provenanceTier / TriageItem interface vs union 三例）是否都能套到协议的"冲突升级 3 级机制"

期望覆盖度：≥ 80%（与 Sprint L 90% 略低，因为 Sprint K 协作复杂度更高）。

---

## 11. 决策签字

- 首席架构师：__ACK 待签 (2026-04-29)__
- 用户：__ACK 待签 (2026-04-29)__
- 信号：本 brief 用户 ACK 后 → Sprint M Stage 0 启动

---

**本 brief 起草于 2026-04-29 / 沿用 framework/sprint-templates/brief-template.md v0.1（第二次外部使用 / 第一次 Sprint L 自审 dogfood）**
