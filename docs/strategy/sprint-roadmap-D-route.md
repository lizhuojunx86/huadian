# Sprint Roadmap — D-route 6-12 个月路线图

> 战略文档 — D-route 转型后 sprint 主题路线图
>
> Status: Draft v1
> Date: 2026-04-29
> Owner: 首席架构师
> Anchor: ADR-028 §7 + docs/strategy/D-route-positioning.md §6
>
> 本路线图是"方向盘"，不是"时间表"。每个 sprint 的实际启动需要架构师 ACK + brief 落地，不会因本路线图自动启动。

---

## 0. 路线图原则

1. **慢而深**：D-route sprint 节奏比 C-route 慢（每 1-3 周 1 个 sprint），单 sprint 工作深度更深
2. **双轴并行**：每个 sprint 都同时推进 Layer 1 框架抽象 + Layer 3 案例延伸（per ADR-028 §2.3 Q3）
3. **C-22 / C-23 守护**：每个 sprint 必须回答"对框架抽象的价值"，否则不启动
4. **机会主义触发**：跨领域案例邀约成功 / 近邻项目团队主动接触 / Anthropic 公布相关方向 等可触发计划外 sprint
5. **本路线图按需修订**：每两个月架构师审一次；战略锚点变化必须先改 ADR 再改本文件

---

## 1. 时间锚（与 ADR-028 §7 同步）

| 时间锚 | 里程碑 |
|--------|--------|
| **2026-05 (1mo)** | 文档体系全对齐（Stage A-D ✅）+ Sprint L 启动 |
| **2026-06 (2mo)** | docs/methodology/ 7 份草案 v0.2 + 第 1 个跨领域案例邀约启动 |
| **2026-08 (4mo)** | 华典智谱史记到 5-10 篇典型章节延伸级 + 产品化 demo 上线（内部可访问）|
| **2026-10 (6mo)** | 第 1-2 篇方法论文章发布 + 与近邻项目（如 shiji-kb）有过 1 次实质交流 |
| **2027-01 (9mo)** | 框架代码抽象 v0.1 release（单仓内 docs/methodology + framework/ 双成熟）|
| **2027-04 (12mo)** | 第 2 个跨领域案例（内部或外部）验证框架可移植性 |

---

## 2. Sprint 候选议程（L → R）

### Sprint L (2026-05 / 启动准备就绪)

**主题**：框架抽象第一刀 + 产品化 demo 双 track

详见 [docs/sprint-logs/sprint-l/stage-0-brief-2026-04-29.md](../sprint-logs/sprint-l/stage-0-brief-2026-04-29.md)。

**Track 1 启动重点**：Sprint workflow 抽象（最成熟的 P0 抽象目标）
**Track 2 启动重点**：现有数据 demo walkthrough + README "Quick demo (5 min)"

---

### Sprint M (2026-06 候选)

**主题**：Multi-role coordination 抽象 + methodology 草案 v0.2 迭代

**Track 1**：
- 抽象 multi-role coordination pattern（参见 docs/methodology/01-role-design-pattern.md §3 tagged sessions）
- 创建 `framework/role-templates/`（10 角色模板，领域无关版本）
- 起草"领域无关 + Domain Expert instantiate guide"

**Track 2**：
- 视 Sprint L 反馈完善 demo
- 候选：跨领域案例邀约启动（数字人文相关社群观察期满 4-6 周后）

**关键 ADR 候选**：
- ADR-030 框架命名（如时机成熟）

---

### Sprint N (2026-07 候选)

**主题**：Identity resolver + GUARD_CHAINS 抽象 + 史记延伸级 ingest 第一篇

**Track 1**：
- 抽象 R1-R6 + GUARD_CHAINS（参见 docs/methodology/03-identity-resolver-pattern.md）
- 创建 `framework/identity-resolver/`（接口领域无关，guard 可插拔）
- 史记案例 = 第一个使用本框架的"参考实现"

**Track 2**：
- 启动 1 篇延伸级 ingest（候选：吕后本纪 / 孝文本纪 / 项羽列传）
- 选择标准：覆盖不同体裁 + 不同人物密度 + 能验证不同框架抽象

**关键 ADR 候选**：
- 第一篇延伸级章节选择 ADR

---

### Sprint O (2026-08 候选)

**主题**：Invariant + Audit 抽象 + 史记延伸级第二篇

**Track 1**：
- 抽象 V1-V11 invariant pattern + Triage UI workflow（参见 docs/methodology/04-invariant-pattern.md + 05-audit-trail-pattern.md）
- 创建 `framework/invariant-scaffold/` + `framework/audit-tables/`（migration generator）

**Track 2**：
- 第 2 篇延伸级 ingest
- demo 完善（视外部反馈）

**关键 ADR 候选**：
- ADR-031 首篇方法论文章主题 + 发布平台（如 Layer 1 第 1 个抽象稳定后）

---

### Sprint P (2026-09 候选)

**主题**：ADR pattern 抽象 + 第 1-2 篇方法论文章发布

**Track 1**：
- ADR pattern 抽象（参见 docs/methodology/06-adr-pattern-for-ke.md）
- 创建 `framework/adr-templates/`
- 7 份 methodology 整体梳理为 v0.5 状态

**Track 2**：
- 史记延伸级第 3-4 篇（候选）
- **第 1-2 篇方法论文章发布**（per Q5 软节律 / 季度 1 篇）
- 候选话题：
  - "为什么 AI agent 时代需要团队级知识工程方法论"
  - "从 SKILL 到 Sprint：知识工程的工业化"
  - "Agentic Knowledge Engineering: 一份团队工作纪律"

---

### Sprint Q (2026-10 ~ 12 候选)

**主题**：跨领域案例验证 + 框架 v0.1 release 准备

**Track 1**：
- framework/ 整体梳理为 v0.1 release 候选
- 起草 framework/README.md + 5-min Quick start
- starter template repo（如分仓决策做出，参见 ADR-033 候选触发）

**Track 2**：
- 史记延伸级第 5-7 篇（视 5-10 篇目标进度）
- **跨领域案例邀约成功** = Sprint Q 关键里程碑
  - 候选领域：佛经 / 法律 / 医疗 / 地方志 / 专利
  - 邀约对象：高校数字人文中心 / 民间研究者 / 行业知识工程师
- 第 3-4 篇方法论文章发布

**关键 ADR 候选**：
- ADR-032 与 shiji-kb 团队合作关系（如发生）
- ADR-033 单仓分拆决策（6-9mo 节点重评）

---

### Sprint R+ (2027-01 起候选)

**主题**：框架 v0.1 release + 第 2 个跨领域案例验证 + Layer 4 探索

**视前期反响调整议程**。候选议程：

- framework v0.1 公开 release（GitHub release / 技术博客 announcement）
- 第 2 个跨领域案例（内部尝试或外部接收）
- Layer 4 商业化探索启动（如有外部需求触发，per ADR-028 §6 ADR-034 触发条件）
- 方法论书雏形目录起草（如累计 ≥ 6 篇文章）

---

## 3. 跨 sprint 持续维护工作（不算独立 sprint）

下面这些工作是**架构师持续推进**，不需要单独 sprint：

### 3.1 月度（per C-24）

- 月度决策日记（≥ 1 段，500-1000 字）
- 方法论草案 v0.x 迭代（视 sprint 实战发现）
- backlog 自检（参见 docs/04 §十）

### 3.2 季度（per C-24）

- 季度方法论文章（AI 协作起草，架构师 review，3000-5000 字）
- D-route Layer 进度评估（per docs/strategy/D-route-positioning.md §10）
- 任务卡 backlog 重审（更新 `T-000a-d-route-classification.md`）

### 3.3 半年度

- ADR 正确率回顾
- 项目宪法适用性评审
- D-route 战略锚点重评（如有第三方项目重大变化）

---

## 4. 触发条件 & 计划外 sprint

下面这些事件触发计划**外** sprint，不在主线路线图：

| 触发事件 | Sprint 类型 |
|---------|-----------|
| 近邻项目团队（如 shiji-kb）主动接触 → 合作意向 | Sprint X：合作探索（→ ADR-032）|
| 字节识典古籍开源框架 | Sprint X：差异化重评 |
| Anthropic 发布官方 KE 框架 | Sprint X：差异化重评 |
| 跨领域案例方主动接触 | Sprint X：案例 onboarding |
| 媒体 / 学术圈反响（≥ 一个实质讨论）| Sprint X：方法论文章加速 + Layer 4 启动评估 |
| Architect 持续 3 个月无 Layer 2 产出 | Sprint X：D-route 整体重评（per ADR-028 §5）|

每个触发事件**记入新 ADR + Sprint Brief**，不绕过流程。

---

## 5. 不做的事（Negative Space — sprint 形态层面）

依据 D-route §7 Negative Space + ADR-028 + 项目宪法 C-22：

- ❌ 不启动新 ingest sprint（D-route 主轴；Sprint M+ 案例延伸级 ingest 不算"新 ingest"）
- ❌ 不启动 C 端产品功能 sprint（古人模拟器 / 断案游戏 / 等）
- ❌ 不启动 mobile 端 sprint
- ❌ 不启动新前端组件库 sprint
- ❌ 不启动"做完史记 130 篇"主题 sprint
- ❌ 不启动 DAU 增长 / A/B 测试 sprint

如未来某个跨领域案例方对上述某些方向有需求，可由案例方主导 + 我们提供框架支持，但不是我们主线 sprint。

---

## 6. 衡量成功（North Star — Sprint 视角）

每个 sprint 是否成功的衡量（不是单看里程碑数）：

### 必须满足（不达即 sprint 失败）：

- ✅ V1-V11 invariants 全绿（per 项目宪法）
- ✅ 沉淀 ≥ 1 个可抽象 pattern（per C-22）
- ✅ ADR 治理流程完整（每个非琐碎决策有对应 ADR）
- ✅ 有完整 retro 含 D-route 资产盘点（per docs/04 §11.3）

### 加分项：

- 💎 一份 methodology 草案 v0.x → v0.(x+1) 迭代
- 💎 一段公开文章 / 决策日记
- 💎 跨领域 mapping 表更新
- 💎 一个 framework 模板被 dogfood 验证

### 警告信号：

- ⚠️ 连续 2 个 sprint 没有 Layer 2 产出（写作）
- ⚠️ 连续 2 个 sprint 没有 Layer 1 抽象推进
- ⚠️ Sprint 反复触发 Stop Rule（系统性问题）
- ⚠️ Sprint 工时超预估 ≥ 100%（节奏失控）

警告信号触发即架构师重评本路线图。

---

## 7. 修订历史

| Version | Date | Author | Change |
|---------|------|--------|--------|
| Draft v1 | 2026-04-29 | 首席架构师 | 初稿（Stage D-4 of D-route doc realignment）|

---

> 本路线图是 D-route 战略的具象化。任何与本路线图冲突的 sprint brief 应优先回归 ADR-028 + D-route-positioning 复核，再考虑修订本路线图。
