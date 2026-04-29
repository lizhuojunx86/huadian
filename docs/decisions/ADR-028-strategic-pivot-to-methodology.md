# ADR-028 — Strategic Pivot: From Full-Stack Knowledge Product to Methodology Framework

- **Status**: accepted (pending architect ACK)
- **Date**: 2026-04-29
- **Authors**: 首席架构师
- **Related**:
  - 项目宪法 00（本 ADR 触发修宪：增加 D-route 不可变原则候选，由 Stage B 单独执行）
  - `华典智谱_架构设计文档_v1.0.md`（被本 ADR 标记为 v2.0 起点；v1.0 归档至 `archive/`）
  - ADR-014 / 021 / 025 / 026 / 027（这些 ADR 共同长出"identity governance + audit + workflow"工程模式 → 框架核心资产）
  - `docs/strategy/D-route-positioning.md`（同步起草，本 ADR 的产品化展开）

---

## 1. Context

### 1.1 触发事件 (timeline)

| 日期 | 事件 |
|------|------|
| 2026-04-29 | Sprint K (T-P0-028 Triage UI) 收档完成；项目首个完整跨角色 sprint 闭环 |
| 2026-04-29 | 第三方项目深度调研：shiji-kb（鲍捷 / baojie@gmail.com）、字节识典古籍、chinese-poetry、永乐大典数据库等 |
| 2026-04-29 | 首席架构师确认 D 路线 (方法论框架方向)；Q1-Q5 五个不可逆决策点全部 ACK |

### 1.2 第三方项目调研结论

**shiji-kb (鲍捷 / 2026-04 active)**：
- 130 篇全本史记结构化 / 14k 实体 / 3.2k 事件 / 7.6k 关系（vs 我们 3-4 篇 / 729 active persons）
- 26 SKILL 方法论文档 / 2 本 PDF（863 页）
- 数字人文社群 19 群约 9000+ 活跃订阅
- 数据 CC-BY-NC-SA 4.0 / 脚本 MIT
- 30+ 年知识工程经验单作者 + AI agent 模式

**字节识典古籍 (字节 × 北大)**：闭源 B 端服务 / 大模型 NER + 知识图谱 + 深度研究 AI 智能体 / 数万志愿者众包校对

**LangChain / LlamaIndex / AutoGen / CrewAI**：取知识 (RAG / agent 调用) 框架，**不解决造知识**

### 1.3 内省结论

在"古籍数据完整度"维度，我们落后头部玩家 1-2 年甚至更多。继续按"完成史记知识库 → C 端产品"路径走，6 个月后产物大概率不如 shiji-kb 当前状态。

但 Sprint A-K 已建成的工程资产真正稀缺的不是史记数据，而是 **"如何用多 agent + 多角色 + 严格治理构建可信知识库"** 的工程框架。当前可被抽象为领域无关框架的部分：

| 资产类别 | 具体内容 |
|---------|---------|
| Workflow | Sprint/Stage/Gate + Stop Rules + 4-stage dry-run/apply 模板 |
| Coordination | Multi-role tagged sessions（PE/BE/FE/Hist/Architect）+ 角色边界硬约束 |
| Decisions | ADR-driven 架构演化（27 个 ADR 实证）|
| Identity | R1-R6 resolver + GUARD_CHAINS（cross_dynasty / state_prefix / textbook-fact）|
| Quality | V1-V11 invariants（formal data correctness gates）|
| Audit | pending_merge_reviews + triage_decisions + entity_split_log + merge_log（人机协作可追溯）|
| Observability | TraceGuard prompt versioning + cost/latency tracking |
| Model Selection | Sonnet vs Opus per sprint phase（execution vs creation）|
| Pattern | textbook-fact threshold（2/3 → 4/N triggers ADR addendum）|
| Pattern | Backfill idempotency（unique key 设计 + cross-sprint dedup 容错）|
| Pattern | pre-sprint pg_dump rollback anchors |
| Pattern | Sub-merge tracking inside historian-approved batches |

目标用户匹配度：架构师角色长项 = 治理 + 决策 + 抽象，与"做方法论"完全匹配；与"做 C 端产品"错配。

---

## 2. Decision

### 2.1 战略定位转型

将项目主轴从 **"中国古籍 AI 知识平台 (C 端产品)"** 转向 **"Agentic Knowledge Engineering 工程框架 + 华典智谱史记参考实现"**。

具体含义：
- **华典智谱史记** = 框架的"参考实现 / 案例样板"，**不是**终极产品目标
- **框架** = 项目的核心交付物（开源 / 公共方法论 / 个人技术品牌）
- **双轴**：framework 抽象 ↔ case 验证 互相驱动迭代

### 2.2 4-Layer 路线图 (D-route)

详见 `docs/strategy/D-route-positioning.md`。摘要：

| Layer | 时间窗 | 主要交付 |
|-------|--------|----------|
| L1 框架代码抽象 | 6-12mo | 单仓内子目录 `framework/` + `docs/methodology/`，可被外部 clone 跑通 |
| L2 方法论文档 | 12-18mo | 月度决策日记 + 季度方法论文章；累积可结集小书形式 |
| L3 案例库 | 持续 | 华典智谱 = 主案例；鼓励 1-2 个跨领域第三方案例 |
| L4 社区/培训/商业 | 机会主义 | 视 L1-L3 reach 决定是否打开 |

### 2.3 5 个不可逆决策点（Q1-Q5 已 ACK）

| # | 决策内容 | 已选项 | 理由 |
|---|---------|--------|------|
| Q1 | 华典智谱史记目标 | **延伸级**（5-10 篇典型章节后停） | 不追求和 shiji-kb 拼数据完整度；够支撑案例可信度 |
| Q2 | 框架抽象仓库策略 | **单仓内子目录**（6-9mo 后视成熟度再决定是否分仓） | 避免早期分仓双重维护负担 |
| Q3 | Sprint L 形态 | **框架抽象第一刀 + 产品化 demo 双 track** | 抽框架是 D 路线核心 ROI；demo 提供活体证明 |
| Q4 | 角色活跃度调整 | PE 主线 / BE+FE 维护模式 / Hist 暂停 / **Architect 增加战略+写作时间** | BE/FE V1 已交付；Architect 需腾时间做 D 路线核心工作 |
| Q5 | 写作输出节律 | **软节律（月/季）+ 代笔模式（用户出原料 AI 结构化）** | 用户写作能力短板的现实策略 |

### 2.4 组织变化

- **不新增角色**（保留 10 个既有 `.claude/agents/*.md`；Architect 工作内容增加战略+写作）
- **不变更技术栈**（Next.js / TypeScript / Python / Postgres / TraceGuard 全保留）
- **不变更 monorepo 结构**（pnpm workspace + uv 不动）
- **不变更角色边界**（C-15 角色解耦原则继续生效）

### 2.5 命名 / 仓库（Q2 子项延后）

框架命名（候选：`kb-engine` / `kb-forge` / `vault` / `agentic-ke` / `ke-ops` / 中文：典厂、典工、典仪、智典）**本 ADR 不决**，由后续 ADR-030 在 Sprint M 启动时决定。原因：现在命名等于 premature commitment；先做 1-2 个 sprint 让框架抽象的形状自己显出来。

> **2026-04-29 注**：原计划 ADR-029 = 框架命名；因项目转 public 触发紧急许可证决策（ADR-029 = Apache 2.0 + CC BY 4.0），框架命名顺移到 ADR-030。后续 ADR 编号以本文件 §6 表格为准。

---

## 3. Consequences

### 3.1 Positive

- 项目长期复利显著提升（方法论寿命 > 产品寿命）
- 与个人能力 / 性格匹配度提高
- 不卷热门赛道（"如何让 AI 团队严谨地构建可信知识"目前是空白象限）
- 已完成的 Sprint A-K 资产 100% 可迁移到框架抽象
- 与 shiji-kb / 字节识典古籍 互补不冲突（我们做"造的工具"，他们做"造好的数据"）
- 与 Anthropic Cowork / SubAgent / Constitutional AI 方向天然对接

### 3.2 Negative / Risk

| 风险 | 缓解 |
|------|------|
| 短期无快感（无 DAU / 无用户反馈循环 6-9mo）| 接受；这是修道院路线的代价 |
| 写作肌肉是短板 | Q5 软节律 + 代笔模式；优先"代码即文档"+"问答式输出" |
| 方法论容易被抄 | 先发优势 + 持续迭代 + 案例积累形成可信度护城河 |
| 没有商业化短期路径 | 接受；L4 是机会主义 |
| 鲍捷团队 / 字节 / Anthropic 抢占同类定位 | §5 阻塞条件触发时本 ADR 重评 |

### 3.3 What Changes（执行影响清单）

- `docs/00_项目宪法.md` 新增 D-route 不可变原则候选（C-22 / C-23 / C-24，由 Stage B 修宪）
- `华典智谱_架构设计文档_v1.0.md` 归档；`v2.0` 起草（双轴架构）
- `docs/STATUS.md` 完整重写
- `docs/strategy/sprint-roadmap-D-route.md` 新建
- `docs/methodology/` 新建（7 份草案：00-overview / 01-role / 02-sprint / 03-identity / 04-invariant / 05-audit / 06-adr-pattern）
- 所有任务卡（`docs/tasks/`）三分类（继续/降级/sunset）
- Sprint L brief 改为"框架抽象 + 产品化 demo"双 track
- `CHANGELOG.md` 加 D 转型条目

### 3.4 What Doesn't Change

- Sprint A-K 已交付资产（代码 / ADR / 测试 / 数据）完整保留
- 所有既有 ADR-001 到 ADR-027 status 不变
- 角色边界（10 个 `.claude/agents/*.md`）定义不变
- 技术栈 / 依赖 / monorepo 结构不动
- 红线规则（CLAUDE.md §5 危险操作清单）不变

---

## 4. 不可逆点

### 4.1 已不可逆（本 ADR 接受后即生效）

- 项目战略主轴 = D-route methodology framework（非 C 端产品）
- 案例服务于框架，不反过来（即华典智谱不再追求"做完整产品"目标）
- 已完成工作不"重做"或"推翻"，只做"重新定位 + 抽象"

### 4.2 可逆但需新 ADR

| 决策 | 重评条件 | 触发后 ADR |
|------|---------|-----------|
| Q1 降级程度 | 案例不够支撑框架抽象 | ADR-XXX 升级到持续级 |
| Q2 单仓策略 | 框架成熟到独立 release 节奏 | ADR-XXX 分仓 |
| Q3 双 track | 任一 track 卡死 6 周以上 | ADR-XXX 单 track 化 |
| Q5 写作节律 | 软节律 3 个月无产出 | ADR-XXX 调整为更轻或更重 |

### 4.3 必须等触发条件成熟才决定

- 框架命名（→ ADR-029，Sprint M 启动时）
- Layer 4 商业化形态（视 L1-L3 reach 决定）
- 是否分仓（6-9mo 后框架成熟度评估）
- 是否启动方法论书（当案例 ≥ 2 个 / 累计文章 ≥ 6 篇时评估）

---

## 5. 阻塞条件（本 ADR 应被重评的情况）

如下面任一条件出现，本 ADR 应暂停实施并重新评估：

1. shiji-kb 团队 6 个月内宣布做"团队级方法论框架" → 我们需重新差异化
2. 字节识典古籍开源其知识工程框架 → 同上
3. Anthropic 发布官方"Agentic KE 框架" → 同上（但也可能反而是机会，看节奏）
4. 华典智谱史记案例在 Sprint L-N 期间无法支撑框架抽象（即框架抽象出来但案例验证不通过）→ 重评 Q3
5. Architect 持续 3 个月无法投入战略 / 写作 → Q5 节律重订或本 ADR 整体重评

---

## 6. 后续 ADR 触发条件

| 事件 | 触发 ADR | 时机预估 |
|------|----------|---------|
| ~~开源许可证策略~~ | **ADR-029**（已落地 2026-04-29，因项目转 public 紧急插队）| ✅ |
| 决定框架命名 + repo 形态 | ADR-030 | Sprint M 启动时 |
| 决定首篇方法论文章主题 + 发布平台 | ADR-031 | Layer 1 第 1 个抽象稳定后 |
| 与 shiji-kb 鲍捷建立合作关系（如发生）| ADR-032 | 用户主动接触后 |
| 决定单仓分拆 | ADR-033 | 6-9mo 后框架成熟度评估 |
| 启动 Layer 4 商业化探索 | ADR-034 | 触发条件成熟后 |
| 接收第三方跨领域案例（佛经/法律/医疗等）| ADR-035 | 案例方主动接触或邀约成功后 |

---

## 7. 6-12 个月可见里程碑

| 时间锚 | 里程碑 |
|--------|--------|
| 2026-05 (1mo) | 文档体系全对齐（Stage A-D 完成）+ Sprint L 启动 |
| 2026-06 (2mo) | `docs/methodology/` 7 份草案完整版 + 第 1 个跨领域案例邀约启动 |
| 2026-08 (4mo) | 华典智谱史记到 5-10 篇典型章节延伸级 + 产品化 demo 上线（内部可访问）|
| 2026-10 (6mo) | 第 1-2 篇方法论文章发布 + 与鲍捷有过 1 次实质交流 |
| 2027-01 (9mo) | 框架代码抽象 v0.1 release（单仓内 `docs/methodology` + `framework/` 双成熟）|
| 2027-04 (12mo) | 第 2 个跨领域案例（内部或外部）验证框架可移植性 |

---

## 8. 决策签字

- 首席架构师：__ACK 待签 (2026-04-29)__
- 信号：本 ADR 接受后，所有 Stage B-D 文档以本 ADR 为锚点起草

---

## Appendix A. 不选 A/B/C 的理由（decision negative space）

| Path | 拒绝理由 |
|------|----------|
| A 全 fork shiji-kb 数据 + 应用层 | CC-BY-NC-SA ShareAlike 锁死任何商业可能；丢失 4-6 周已建立的工程资产；若 C 端定位则与 shiji-kb 用户群直接竞争 |
| B 混合数据策略（fork + 自建）| 法律边界模糊；长期需要 maintain 两套数据真相源；商业化路径不清；merge 后回不去 clean-room |
| C 完全独立做古籍数据 | 6-12mo 才能追上 shiji-kb 当前状态；需要团队 + 资金；不符合"短期可见进展"心理需求；不发挥架构师角色长项 |
| **D 方法论框架** | ✅ **选定** — 与已建工程资产对齐、与个人能力对齐、与市场空白对齐、与 AI agent 时代趋势对齐 |

---

## Appendix B. 已抽象出可框架化的工程模式（Sprint A-K 真实积累）

按可抽象成熟度排序（高→低）：

| # | 模式 | 来源 | 抽象成熟度 |
|---|------|------|-----------|
| 1 | Sprint/Stage/Gate + Stop Rules workflow | Sprint A-K 全部 | ⭐⭐⭐⭐⭐ |
| 2 | ADR-driven 架构决策记录 | 27 ADRs | ⭐⭐⭐⭐⭐ |
| 3 | Multi-role tagged sessions + 角色边界 | CLAUDE.md §4 + 10 agent 文档 | ⭐⭐⭐⭐⭐ |
| 4 | V1-V11 invariants（formal correctness gates）| Sprint F/H/I | ⭐⭐⭐⭐ |
| 5 | Identity resolver R1-R6 + GUARD_CHAINS 框架 | ADR-010 / 025 / 026 | ⭐⭐⭐⭐ |
| 6 | pending_merge_reviews + triage_decisions audit | ADR-027 + Sprint K | ⭐⭐⭐⭐ |
| 7 | Backfill idempotency 模式 | Sprint K Stage 2 | ⭐⭐⭐⭐ |
| 8 | dry-run report → historian review → apply 4-stage | Sprint G/H/I/J | ⭐⭐⭐⭐ |
| 9 | Cross-dynasty / state-prefix domain guards | ADR-025 §5.3 / Sprint H/I | ⭐⭐⭐ (含 domain 特定) |
| 10 | TraceGuard prompt versioning + cost/latency | ADR-006 | ⭐⭐⭐ |
| 11 | Sonnet vs Opus selection patterns | Sprint I/J/K retro | ⭐⭐⭐ |
| 12 | Textbook-fact precedent threshold (N/M)| Sprint G/J/T-P1-030 | ⭐⭐ (尚未抽象完成)|
| 13 | Entity-split protocol（split_for_safety）| ADR-026 | ⭐⭐⭐ |
| 14 | Sub-merge tracking 内嵌 historian batch | Sprint E/G | ⭐⭐ |
| 15 | pre-sprint pg_dump rollback anchors | Sprint H/K ops | ⭐⭐⭐⭐ |

⭐⭐⭐⭐ 以上为 Layer 1 优先抽象目标。

---

**本 ADR 起草于 2026-04-29 / Stage A-1 of D-route doc realignment**
