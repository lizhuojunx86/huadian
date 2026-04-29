# Sprint L Brief — 框架抽象第一刀 + 产品化 Demo 双 Track

## 0. 元信息

- **架构师**：首席架构师
- **Brief 日期**：2026-04-29
- **Sprint 形态**：**双 track 并行**
  - Track 1：框架抽象第一刀（Layer 1 启动）
  - Track 2：产品化 demo（Layer 3 案例外可见证明）
- **预估工时**：2-3 周（Sprint L 比典型 ingest sprint 长，因含框架抽象工作）
- **PE 模型**：Sonnet 4.6（按 pattern 执行 + 案例验证）
- **Architect 模型**：Opus 4.7（战略 + 框架抽象设计 + 跨 track 协调）
- **触发条件**：D-route 战略转型完成（Stage A-D 文档体系全对齐 + 用户"假装新协作者"测试通过）
- **战略锚点**：[ADR-028](../../decisions/ADR-028-strategic-pivot-to-methodology.md) §2.3 Q3 ACK

---

## 1. 背景

### 1.1 战略上下文

Sprint K（T-P0-028 Triage UI V1）2026-04-29 完成同日，项目战略转型为 D-route：Agentic KE 工程框架 + 史记参考实现（详见 ADR-028 + docs/strategy/D-route-positioning.md）。

Sprint L 是 D-route 转型后**第一个**真正按新方向推进的 sprint。其使命是：

> 把 Sprint A-K 已建成的工程资产真正抽象为"开源框架"的 v0.1 形态，同时让案例层有"对外可看"的活体 demo。

### 1.2 为什么是双 track

单 track 不够：

- **只做框架抽象** → 没有"框架真的 work"的可见证明（外界看不到任何展示）
- **只做产品化 demo** → 框架未抽出，无法发布、无法被复用

→ 双 track 并行让 Layer 1 + Layer 3 同步推进，互相验证。

### 1.3 不做的事（Negative Scope）

依据 D-route §7 Negative Space + ADR-028 Q1 ACK：

- ❌ **不启动新 ingest sprint**（违反 C-22；Sprint M+ 才考虑延伸级 ingest）
- ❌ **不做新 NER prompt 主版本**（v1-r6 等推迟）
- ❌ **不做 T-P1-030 ADR-014 addendum**（textbook-fact 已 4 例触发，但不是 D-route 优先；P3 backlog）
- ❌ **不做 V12 invariant**（T-P2-008 已登记，但不是 D-route 优先；P3 backlog）
- ❌ **不做 frontend 组件库 / design system**（Negative Space 明确）
- ❌ **不做新 source adapter**（佛经 / 法律 / 等留给跨领域案例方）

---

## 2. 目标范围

### 2.1 Track 1 — 框架抽象第一刀

**目标**：从 Sprint A-K 代码中识别 P0 抽象优先级（参见 docs/methodology/00-framework-overview.md §2 + ADR-028 Appendix B）中**最成熟的 1-2 个**做第一次抽象 spike，写到 docs/methodology/ + framework/ 草目录。

**P0 候选**（按 Sprint K closeout §5.4 推荐顺序）：

1. **Sprint / Stage / Gate workflow 抽象** — 最成熟，影响面广
2. **Multi-role coordination 抽象**（角色 templates + tagged sessions 协议）

Track 1 选 **#1 Sprint workflow 抽象** 作为第一次 spike。

**具体动作**：
- 从 docs/methodology/02-sprint-governance-pattern.md 提取核心模板
- 在 `framework/sprint-templates/` 下创建：
  - `brief-template.md`（领域无关 sprint brief 模板）
  - `stage-templates/` — 5 个 stage 各自模板（含 Gate / Stop Rule 占位）
  - `retro-template.md`（领域无关 retro 模板）
  - `closeout-template.md`（领域无关 closeout 模板）
- 给每个模板加 `domain-specific parameters: [...]` 注释（C-23 应用）
- 给一个"如何套用到非古籍领域"的 README

**完成判据**：
- 一个完全外部的工程师能在 30 分钟内 clone + 复制模板 + 写出自己的 Sprint A brief
- 7 份 docs/methodology/ 中 §02 引用了 framework/sprint-templates/ 文件路径
- 模板被 dogfood：Sprint M brief（如启动）必须用这套模板写

### 2.2 Track 2 — 产品化 Demo

**目标**：把现有 729 active persons + 几篇本纪 + identity merge 案例 + triage UI workflow 接出一个对外可看的极简 demo，作为"框架真的 work"的活体证明。

**形态选项**（PE / FE 协商，架构师 ACK 一种）：

- **A. 极简静态站点**：Next.js export 到静态 HTML，部署 GitHub Pages
- **B. 内部可访问 dev 环境**：keep `pnpm dev` 模式，README 加访问指南
- **C. Cloudflare / Vercel 简部署**：免费层 + 数据库 read replica

**推荐 B**（最简单，符合 D-route "不卷部署"原则；C 端部署是 Layer 4 才考虑的事）。

**具体动作**（如选 B）：
- 现有 apps/web 的 / 首页 + /persons/[slug] + /triage 已可工作（Sprint K 验证）
- 写一份 `docs/runbook/RB-002-demo-walkthrough.md`：5 分钟带访客走通 demo
- 在 README.md 加 "Quick demo (5 min)" 段，引导访客本地起 demo
- demo 的"卖点"清单：
  - 8 类实体语法高亮（虽然只 1-2 篇本纪，但已能 demo）
  - 729 个人物 + 跨章身份合并
  - Triage UI 工作流（pending_merge_reviews + triage_decisions audit）
  - identity resolver R1-R6 + GUARD_CHAINS（cross_dynasty + state_prefix）
- 不做：实时部署 / SSL / DNS / 等（Layer 4 才做）

**完成判据**：
- README §Quick demo 段就位
- runbook 5 分钟可走通
- 至少一个外部读者（用户 + 一个朋友）能看懂 demo 在 demo 什么

---

## 3. Stages

### Stage 0 — 启动准备 + 双 track 协调

0.1 用户做"假装新协作者"5 分钟测试 — 验证 Stage A-D 文档体系真的可读
0.2 PE / Architect 联合 inventory：扫 Sprint A-K 代码识别"领域无关 vs 案例层"边界
0.3 用户 ACK Track 2 的 demo 形态选项（A/B/C）
0.4 架构师起草 stage-1-design

输出：docs/sprint-logs/sprint-l/stage-0-inventory.md + stage-1-design

### Stage 1 — Track 1 起步（Sprint workflow 抽象 spike）

1.1 创建 `framework/sprint-templates/` 目录骨架
1.2 起草 brief-template.md（从 Sprint K brief 提取领域无关部分）
1.3 起草 stage-templates/（5 个 stage 各自模板）
1.4 起草 retro-template.md + closeout-template.md
1.5 写 framework/README.md "如何套用到非古籍领域"
1.6 dogfood：用本套模板回过头审 Sprint K brief（看哪些是模板、哪些是案例）

### Stage 2 — Track 2 起步（产品化 demo 准备）

2.1 PE / FE 联合 demo walkthrough（本地起 demo，记录走通路径）
2.2 起草 runbook RB-002-demo-walkthrough.md
2.3 README.md 加 "Quick demo (5 min)" 段
2.4 修复 demo 走通路径上的任何 bug（小修，不大改）

### Stage 3 — 双 track 验证

3.1 一个朋友 / 用户审 framework/sprint-templates/（不必是工程师，看说明文档是否清晰）
3.2 一个朋友 / 用户走 demo 5 分钟（看能否理解项目在做什么）
3.3 反馈整理 → 衍生债 / Sprint M 候选

### Stage 4 — Closeout

4.1 task card 创建（T-P0-XXX-framework-spike）
4.2 STATUS / CHANGELOG 更新（Sprint L 完成 + Layer 1 / Layer 3 进度）
4.3 retro 起草，含 D-route 资产盘点段（per docs/04 §11.3 模板）
4.4 衍生债登记
4.5 Sprint M 候选议程（Track 1 第二次抽象 / Track 2 完善 / 等）

---

## 4. Stop Rules

1. **用户"假装新协作者"测试不通过** → Stop，回 Stage A-D 修订文档
2. **Track 1 抽象出来但模板不能 dogfood**（即重审 Sprint K brief 时发现模板有 critical 缺失）→ Stop，重设计模板
3. **Track 2 demo 走通失败** → Stop（这是产品化 demo 的最低要求）
4. **任一 V1-V11 invariant 回归** → Stop（与 Sprint K 同样规则）
5. **Sprint 工时 > 4 周** → Stop，评估是否拆 Sprint M
6. **Track 间互相阻塞 6 周以上** → Stop，可能需要单 track 化（→ ADR-028 §4.2 触发条件）
7. **新启动框架命名讨论且分歧明显** → Stop，启动 ADR-030（per ADR-028 §6 触发条件）
8. **写作能力短板触发**（架构师无法在合理时间内完成 framework/README.md 起草）→ Stop，AI 协作 + 软节律调整

---

## 5. 角色边界

| 角色 | 活跃度 | 主要职责 |
|------|--------|---------|
| 首席架构师 | 🟢 主导 | 双 track 协调 / framework spike 设计 / dogfood 验证 / 衍生债判定 |
| 管线工程师 | 🟢 Track 1 + Track 2 共参与 | Track 1：识别 services/pipeline 中领域无关部分；Track 2：协助 demo 跑通 |
| 后端工程师 | 🟡 维护模式 | 仅响应 Track 2 demo bug fix |
| 前端工程师 | 🟡 维护模式 | 仅响应 Track 2 demo bug fix（如 UI 不通顺）|
| 古籍专家 | ⚪ 暂停 | 不参与本 sprint |
| QA 工程师 | 🟡 维护模式 | V1-V11 invariants 跟踪（不主动新增）|
| DevOps | 🟡 维护模式 | 仅 demo 部署相关问题 |
| 产品经理 / UI/UX / 数据分析师 | ⚪ 暂停 | 不参与本 sprint |

---

## 6. 收口判定

- ✅ 用户"假装新协作者"5 分钟测试通过
- ✅ Track 1：framework/sprint-templates/ 目录就位 + dogfood 通过
- ✅ Track 2：README.md "Quick demo (5 min)" 段就位 + runbook 走通
- ✅ V1-V11 全绿不回归
- ✅ Sprint L retro 含 D-route 资产盘点段（per docs/04 §11.3 模板）
- ✅ Sprint M 候选议程拟定（不强求启动）

---

## 7. 节奏建议

- **第一周**：Stage 0 + Stage 1 起步（Track 1 spike）
- **第二周**：Stage 2（Track 2 demo）+ Track 1 dogfood
- **第三周**（如需）：Stage 3 验证 + Stage 4 收档

不要赶节奏。D-route 的核心是**深而慢**，不是快。如本 sprint 实际需要 4 周，调整不需要架构师审批（per Stop Rule #5 触发才停）。

---

## 8. D-route 资产沉淀预期（per docs/04 §11.2）

本 sprint 预期沉淀以下框架抽象资产：

- [x] 框架代码 spike — `framework/sprint-templates/` 目录第一版
- [x] 已有 methodology 草案的 v0.1 → v0.2 迭代（02-sprint-governance-pattern.md 引用 framework/）
- [x] 案例素材积累 — Sprint K closeout 已做 D-route 资产盘点
- [ ] 跨领域 mapping 表更新（视 Track 1 dogfood 发现）
- [x] 一个对外可访问的 demo 路径

至少 4 项预期 → 远超 ADR-028 / C-22 的"≥ 1 项"要求。

---

## 9. PE Sonnet 4.6 持续观察

Sprint I/J/K 已证 Sonnet 4.6 胜任真书 ingest + 框架扩展类工作。Sprint L 继续观察：

- Track 1 框架抽象任务是否需 Opus（"创设"性质）
- 如 Sonnet 在 framework/sprint-templates/ 起草时表现良好（结构清晰 / 抽象到位 / 不过度泛化）→ 继续 Sonnet
- 如 Sonnet 抽象深度不足（如只列字段不解释 trade-offs）→ 切 Opus

详见 ADR-028 §2.3 Q5 ACK 模型选型策略。

---

## 10. 决策签字

- 首席架构师：__ACK 待签 (2026-04-29)__
- 信号：本 brief 接受 + 用户 ACK 后 → Sprint L 正式启动 Stage 0

---

**本 brief 起草于 2026-04-29 / Stage D-2 of D-route doc realignment**
