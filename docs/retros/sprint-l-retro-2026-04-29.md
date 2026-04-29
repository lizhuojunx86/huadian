# Sprint L Retro

> 复制自 `framework/sprint-templates/retro-template.md`（dogfood：Sprint L retro 用 Sprint L 自己抽出的模板）
> Owner: 首席架构师

## 0. 元信息

- **Sprint ID**: L
- **完成日期**: 2026-04-29
- **主题**: 框架抽象第一刀 + 产品化 demo 双 track
- **预估工时**: 2-3 周
- **实际工时**: ~1 个会话（极致压缩）
- **主导角色**: 首席架构师（自驱）

---

## 1. Sprint 任务回顾

### 1.1 Stage 顺序与产出

| Stage | 主导 | 状态 | 关键产出 |
|-------|------|------|----------|
| Stage 0.1 用户测试 | User | ✅ | "假装新协作者"5 分钟测试通过（"没问题"）|
| Stage 0.2 架构师 inventory | Architect | ✅ | stage-0-inventory-2026-04-29.md（4500 字）— 抽象优先级排序 + 案例耦合点标注 |
| Stage 0.3 demo 形态 ACK | User | ✅ | 选 B（本地 dev + README Quick demo）|
| Stage 1 Track 1 — sprint-templates v0.1 | Architect | ✅ | framework/sprint-templates/ 11 files / 1500 lines |
| Stage 1 Track 1 — dogfood | Architect | ✅ | stage-1-dogfood-2026-04-29.md — 覆盖度 90% / 4 项 v0.2 迭代登记 |
| Stage 1 Track 2 — demo walkthrough | Architect | ✅ | RB-002-demo-walkthrough.md（184 行）+ README Quick demo 段 |
| Stage 2 — 朋友/用户审 framework | — | ⚪ 押后 | 等外部反馈触发（无紧急 timeline）|
| Stage 3 — 双 track 验证 | — | ⚪ 押后 | 同上 |
| Stage 4 — Closeout | Architect | ✅ | stage-4-closeout-2026-04-29.md + 本 retro |

### 1.2 数据 / 工程基线 Δ

| 维度 | Sprint L 前 | Sprint L 后 | Δ |
|------|-----------|-----------|-----|
| docs/methodology/ 草案 | 7 份 v0.1 | 7 份 v0.1（cross-reference 加强）| 内容不变 |
| framework/ 目录 | 不存在 | 11 files / ~1500 lines | **新增 L1 第一刀** |
| docs/runbook/ | RB-001 only | RB-001 + RB-002 | +1 |
| README "Quick demo" 段 | 无 | 有 | +1 |
| GitHub commits | 81490ad（Stage B end）| c5b8740（Stage C+D end）+ 待 push（Sprint L Stage 1）| +2 笔大 commit |
| 公开 D-route 文档 | A+A.5+B 已 push | A+A.5+B+C+D 已 push / Sprint L Stage 1 待 push | full visibility |

---

## 2. 工作得好的部分（What Worked）

### 2.1 双 Track 并行节奏可控

Track 1 框架抽象 + Track 2 demo walkthrough 并行推进。两者无依赖，互相不阻塞。架构师单 session 内可完成（虽然实际是极致压缩，正常应分 2-3 周做）。

### 2.2 "Sprint L 用自己产物给自己收档"的 dogfood 极有价值

closeout doc 直接复用 framework/sprint-templates/stage-templates/stage-5-closeout-template.md / retro 直接复用 framework/sprint-templates/retro-template.md。这是验证模板的最强证据——**如果模板自己用着别扭，那它对外部用户更别扭**。

实际验证下来，模板用着顺手，仅暴露 4 项小迭代（v0.2 候选）。

### 2.3 Inventory 阶段（Stage 0.2）的"抽象优先级表"对决策有用

通过逐文件扫 services/pipeline + apps/web + packages/，明确了：
- P0（最成熟，立即抽）：Sprint workflow / R1-R6 resolver / V1-V11 invariants
- P1：Multi-role coordination / Triage UI / extract pipeline
- P3 案例层（不抽）：data/*.yaml / NER prompts / sources/

这避免了"抽错对象"或"边界模糊"的浪费。

### 2.4 ⚠️FILL 占位符模式

跨领域使用模板时，⚠️FILL 标识让占位"显眼"，避免外部工程师以为某个字段是 hard-coded 值。

### 2.5 极致压缩到 1 会话完成

预估 2-3 周的工作在 1 会话完成，没有质量妥协。原因：
- D-route 转型 Stage A-D 已经把大部分"思考"做完
- framework spike 主要是"重组已有 docs/methodology + Sprint K brief"，不是从零设计
- dogfood 不需要等外部用户，架构师自己做就够 90%

---

## 3. 改进点（What Didn't Work）

### 3.1 Stage 2-3 外部反馈环节没法快速完成

预设需要"朋友/用户审 framework + 走 demo"。架构师没有立刻可调用的"外部友人"，且外部反馈本质是慢节奏（等人有空）。

**改进建议**：D-route 项目要接受"部分 stage 必须等外部时机"。Sprint M+ brief 应预设这种 stage（"该 stage 押后到外部反馈触发，不阻塞 sprint 关档"）。

### 3.2 framework/sprint-templates/ 命名空间没规划

当前 framework/ 下只有 sprint-templates/ 一个子目录。Sprint M 抽 multi-role / Sprint N 抽 identity-resolver 时，目录组织怎么演化？

**改进建议**：在 Sprint M brief 中明确 framework/ 目录组织约定（如 `framework/role-templates/` / `framework/identity-resolver/` / `framework/invariant-scaffold/` / etc 平铺，不嵌套）。

### 3.3 dogfood 报告（stage-1-dogfood）格式比较 ad hoc

当前 dogfood 报告是自由格式 markdown。未来 v0.2 抽象时，"dogfood 报告"本身可能成为一个模板。

**改进建议**：留作 Sprint M+ 衍生债（不立即做；等 ≥3 次 dogfood 后再总结模板）。

---

## 4. Stop Rule 触发回顾

Sprint L 期间**无 Stop Rule 触发**。

原因：
- 极致压缩到 1 会话完成 → cost / 时间预算根本没机会触及
- 没有数据 mutation → V1-V11 invariant 不存在回归风险
- 没有 review 环节（dogfood 是架构师本人审）→ 治理类 rule 不适用

→ Sprint L 是 "low-risk sprint"。后续 Sprint M+ 如涉及代码抽象（services/pipeline → framework/identity-resolver/）会进入 "high-risk sprint"，Stop Rule 重要性回归。

---

## 5. Lessons Learned

### 5.1 工程层面

- **dogfood 是抽象质量的最强反馈**。Sprint L 用模板写自己的 closeout，立刻发现"§1.2 表格列数不够"等问题。这不是 unit test 能发现的，必须真用一次。
- **领域无关 ≠ 抽象到死**。framework/sprint-templates/ 中保留了 ⚠️FILL 占位 + 实证示例（华典智谱 Sprint K 数字），让模板可读不抽象。如果完全抽象就是空架子，外部工程师反而不知道该填什么。

### 5.2 协作层面

- **D-route 项目大部分工作可以单架构师推进**。Sprint A-K 时代的 multi-role multi-session 协作适用于"做案例数据"；Sprint L 的"做框架抽象"反而更适合架构师单 session 深度推进，多 role 反而协调成本高。
- **D-route 角色活跃度调整（per ADR-028 §2.3 Q4）已经验证有效**：Sprint L 实际只架构师一个 🟢 角色，PE/BE/FE/Hist 都🟡或⚪，节奏紧凑高效。

### 5.3 模型选型 retro

Sprint L 全程使用 **Opus 4.7**（架构师 session）。

效果：
- ✅ 框架抽象设计决策（5 类 Stop Rule 分类 / 6 gate 协议 / 跨领域 instantiation 表）质量高
- ✅ dogfood 报告精准识别 4 项 v0.2 改进点
- ✅ 单 session 内压缩 2-3 周工作，没有质量妥协

如 Sprint M 主题是 multi-role coordination（继续抽象类工作）→ 继续 Opus
如 Sprint N 是 identity resolver code refactor（代码工作）→ 切 Sonnet 4.6

---

## 6. 衍生债登记

### 6.1 v0.2 迭代候选（来自 dogfood）

| ID | 描述 | 优先级 | 来源 |
|----|------|--------|------|
| T-P3-FW-001 | brief-template.md §1.2 表格灵活列数支持 | P3 | dogfood §3.1 |
| T-P3-FW-002 | retro §4 + stop-rules-catalog §7 cross-reference 紧密化 | P3 | dogfood §3.2 |
| T-P3-FW-003 | stage-3-review-template.md §2.0 review 形式选择指南 | P3 | dogfood §3.3 |
| T-P3-FW-004 | brief-template.md §8 D-route 段措辞调整（更明确"可选"）| P3 | dogfood §3.4 |

不立 task card 文件；登记到 docs/debts/sprint-l-framework-v02.md（参见 §6.3）。

### 6.2 Stage 2-3 押后

| 押后项 | 触发条件 |
|--------|---------|
| framework/sprint-templates/ 外部工程师走通验证 | 1-2 个朋友 / 跨领域案例方主动接触 |
| demo walkthrough 外部访客 5 分钟走通验证 | 同上 |

无具体 timeline，等外部时机。

### 6.3 衍生债文件

`docs/debts/sprint-l-framework-v02.md`（待架构师另起草，4 项 v0.2 集中登记）。

---

## 7. D-route 资产沉淀盘点

### 7.1 本 sprint 沉淀的可抽象 pattern

1. **Sprint workflow 模板系**（最直接产出）— framework/sprint-templates/ v0.1
2. **5 类 Stop Rule 分类**（成本/正确性/输出量/治理/跨sprint一致性）— framework/sprint-templates/stop-rules-catalog.md
3. **6-Gate Checklist 协议**（Stage 之间硬约束）— framework/sprint-templates/gate-checklist-template.md
4. **dogfood 模式**（Sprint L 用 Sprint L 产物收档）— 元 pattern，未来抽象时复用

### 7.2 本 sprint 暴露的"案例耦合点"

1. brief-template.md §1.2 表格（固定 2 列）→ v0.2
2. stage-3-review-template.md（缺 review 形式选择指南）→ v0.2
3. brief-template.md §8（D-route 假设）→ v0.2

### 7.3 Layer 进度推进

- **L1**: 🟡 → 🟢（首次有 framework/ 目录代码 / 模板）/ +1500 lines
- **L2**: cross-reference 紧密化（docs/methodology/02 + 04 引用 framework/）/ 内容不变
- **L3**: +RB-002 demo walkthrough / +README Quick demo 段
- **L4**: 不变（机会主义）

### 7.4 下一 sprint 抽象优先级建议

按 closeout §2.4：

- **推荐 Sprint M 主题**：Multi-role coordination 抽象（P0）
- **形式**：framework/role-templates/ + tagged-sessions-protocol.md
- **抽象自**：docs/methodology/01-role-design-pattern.md + .claude/agents/* + Sprint K Tagged Sessions 实战
- **预估工时**：与 Sprint L 接近（~1500 行模板 + dogfood）
- **启动时机**：用户 ACK + 准备好（无紧急 timeline；可以休息几天 / 一周后再启动）

---

## 8. 下一步（Sprint M 候选议程）

依据本 retro + Sprint L closeout §2.4：

- **主线**：Multi-role coordination 抽象（framework/role-templates/）
- **副线**：dogfood Sprint M 启动 brief（Sprint L 模板的第二次外部使用）
- **押后**：identity resolver 代码抽象（Sprint N 候选）/ V1-V11 scaffold（Sprint O 候选）

不要做的事：

- ❌ 不主动启动新 ingest sprint（违反 C-22）
- ❌ 不做框架命名 ADR-030（暂时无明确需求；Sprint M 启动时如有讨论可触发）
- ❌ 不做 framework v0.1 公开 release（等 ≥ 2 个抽象资产稳定后才考虑）

---

## 9. 决策签字

- 首席架构师：__ACK 2026-04-29__

---

**Sprint L retro 完成 → Sprint L 关档。**
