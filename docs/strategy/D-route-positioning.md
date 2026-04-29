# D-route Positioning — Agentic Knowledge Engineering Framework

> 项目战略定位文档 — Sprint K 收档后战略转型 (ADR-028) 的产品化展开
>
> Status: Draft v1
> Date: 2026-04-29
> Owner: 首席架构师
> Anchor ADR: ADR-028-strategic-pivot-to-methodology

---

## 0. TL;DR

**华典智谱 = Agentic Knowledge Engineering 工程框架 + 华典智谱史记参考实现案例。**

不再做 C 端古籍 App，不再追求和 shiji-kb 拼数据完整度。把 Sprint A-K 已建成的工程资产 (Sprint workflow / multi-role coordination / ADR governance / identity resolver / V1-V11 invariants / triage UI / audit pattern) 抽象为开源框架，让别人能用我们这套方法做任何领域的知识工程。

短期不变现，长期复利最大；写作能力短板用 AI 协作 + 软节律弥补；6-12 个月内里程碑明确。

---

## 1. 一句话定位

| 项目身份 | 一句话 |
|----------|--------|
| 核心产品 | **用 AI agent 团队严谨地构造可信知识** 的开源工程框架 |
| 参考实现 | 华典智谱史记知识库（5-10 篇典型章节，作为框架的"它真的 work"证明）|
| 目标用户 | 想用 AI 做严肃知识工程项目的工程团队 / 学者 / 机构 |
| 商业模式 | 开源（短期）+ 咨询/培训/付费支持（中长期机会主义）|

---

## 2. 解决什么问题（Problem We Solve）

### 2.1 这个时代的核心稀缺

> "AI 让做事变得几乎免费，但'做对的事'和'团队做对的事'反而成为最稀缺的能力。"

具体到知识工程：单人 + AI 已被证明可以高产（shiji-kb 55 小时做完史记）。但要扩展到：

- **大规模**（4600 万字级二十四史）
- **多机构合作**（北大 + 中华书局 + 字节 + 民间研究者）
- **多领域**（古籍 / 法律 / 医疗 / 专利 / 地方志）
- **长期维护**（10 年级数据持续修正、演化）

…… 单人 SKILL 范式撑不住。需要的是**团队级的工程纪律 + 可审计的协作流程 + 形式化的质量约束**。

### 2.2 当前市场上没有的东西

通用的、开源的、工业级的 **"用 AI 团队严谨地构建可信知识"** 框架。

类比：
- Linux Kernel = Linus Torvalds 一个人能写，但 Linux 之所以能扩展 30 年是 Git + LKML + Maintainer + patch review 那一整套**治理机制**
- DDD / TDD / Scrum = 软件工程的方法论标准，**几十年成熟**
- **知识工程没有等价物** — 这是空缺

---

## 3. 与已有玩家的差异化

### 3.1 二维定位图

|  | 取知识（已造好的）| 造知识（从零造）|
|---|---|---|
| **单人 / 小团队** | LangChain / LlamaIndex / RAG 类工具 | shiji-kb / SKILL playbook |
| **大团队 / 长期协作** | 字节识典古籍 / Notion AI | **空白象限 ← 我们** |

### 3.2 vs 具体玩家

#### vs shiji-kb

| 维度 | shiji-kb | 华典智谱 |
|------|----------|---------|
| 模式 | 单人英雄主义 + SKILL 个人 playbook | 团队工业化 + ADR 治理 |
| 优势 | 自由、高产、灵活（周级迭代）| 严谨、可复制、可审计、多人协作 |
| 弱点 | 难复制、难扩团队、SKILL 是个人经验 | 慢、过度工程化风险、需要团队配合 |
| 关系 | **互补不冲突**：他证明"AI 能把数十年压缩到几周"，我们解决"如何让多人 + 多 agent 持续协作做这件事 5-10 年" |

类比：他是车库手工匠，我们是流水线设计师。

#### vs 字节识典古籍

| 维度 | 字节识典古籍 | 华典智谱 |
|------|-------------|---------|
| 模式 | 中心化大厂闭源 + B 端服务 | 开源框架 + 工程师社区 + DIY 路径 |
| 类比 | "古籍 AWS"（你来用我的服务）| "古籍 Kubernetes"（你拿我的框架自建）|

#### vs LangChain / LlamaIndex / AutoGen / CrewAI

| 维度 | 它们 | 华典智谱 |
|------|------|---------|
| 解决的问题 | "用 LLM 做事"（取知识 / agent 调用）| "严谨地构造可信知识"（造知识 / 团队治理）|
| 核心抽象 | Chain / Tool / Agent / Memory | Sprint / Role / ADR / Invariant / Audit |
| 关系 | **下游互补**：用我们的方法构造的知识库 → 用 LangChain 接到应用 |

#### vs Anthropic Cowork / SubAgent

| 维度 | Anthropic 工具 | 华典智谱 |
|------|---------------|---------|
| 性质 | agent 协作工具（substrate）| agent 协作方法论（discipline）|
| 关系 | **天然对接**：我们的方法论可以直接把 Anthropic 工具当 substrate 跑 |

#### vs Scrum / Agile / SRE

| 维度 | 软件工程方法论 | 华典智谱 |
|------|---------------|---------|
| 领域 | 软件项目管理（几十年成熟）| 知识工程项目管理（**空白**）|
| 类比 | Scrum / Agile / SRE 是软件项目的纪律 → 我们做"知识工程的 Scrum" |

### 3.3 差异化护城河

护城河**不在代码**（MIT 开源），**不在数据**（CC 数据谁都能下），护城河在：

> **累积的真实案例 + 案例总结出来的模式 + 第一个把它讲清楚的人在历史上留名**

类比 Kent Beck 的 TDD、Eric Evans 的 DDD、Martin Fowler 的 Refactoring：不是想法多复杂，是用真实代码案例把 pattern 讲透了，所以成为经典。

我们的护城河构建路径：
1. 华典智谱史记案例做扎实（5-10 篇延伸级 demo）
2. 鼓励 1-2 个跨领域第三方案例（佛经 / 法律 / 医疗 / 地方志任一）
3. **"这套东西真的 work"** 这件事的可信度立住了，没人能轻易复制这个可信度

---

## 4. 核心资产（来自 Sprint A-K 真实积累）

### 4.1 工程模式资产（Layer 1 优先抽象目标）

| 模式 | 来源 | 抽象优先级 |
|------|------|-----------|
| Sprint / Stage / Gate workflow + Stop Rules | Sprint A-K 全部 | P0 |
| Multi-role coordination + tagged sessions | CLAUDE.md §4 + 10 agent 文档 | P0 |
| ADR-driven 架构决策记录 | 27 ADRs | P0 |
| V1-V11 invariants（formal correctness gates）| Sprint F/H/I | P0 |
| Identity resolver R1-R6 + GUARD_CHAINS 框架 | ADR-010 / 025 / 026 | P1 |
| Audit 表 + triage workflow | ADR-027 + Sprint K | P1 |
| Backfill idempotency 模式 | Sprint K Stage 2 | P1 |
| dry-run → historian review → apply 4-stage | Sprint G/H/I/J | P1 |
| TraceGuard prompt versioning + observability | ADR-006 | P2 |
| pre-sprint pg_dump rollback anchors | Sprint H/K ops | P2 |
| Sonnet vs Opus model selection patterns | Sprint I/J/K retro | P2 |

### 4.2 案例资产

- 华典智谱史记：3-4 篇本纪深度结构化（项羽/秦/高祖）+ 729 active persons + identity merge case 库 + triage workflow 实证
- Sprint K 完成：第一个完整跨角色 sprint（PE/BE/FE/Hist/Architect 5 角色协同 + 4-stage gate + ADR-027 落地 + 真实 historian E2E 验证）

### 4.3 经验资产

- Sprint A-K retro 沉淀的 lesson learned（散落于各 sprint-logs/sprint-X/retro.md）
- 衍生债（T-P0/P1/P2/P3 候选）累积的真实 pattern
- 跨 sprint 治理经验（idempotency edge cases / model selection trade-offs / ADR addendum 触发条件）

---

## 5. 4-Layer 路线（timing-based commitment）

### Layer 1: 框架代码抽象（6-12mo）

**目标**：把 `services/pipeline` 和 `services/api` 里"领域无关"部分识别 + 抽象，让别人能 clone 跑通。

**形式**：
- 单仓内 `framework/`（待命名）+ `docs/methodology/` 子目录
- CLI / config schema / agent role 模板 / sprint template / invariant test scaffolding / audit migration generator
- 不强求产品级稳定，强求"概念清晰 + 可被跑通 + 有 starter template"

**不做的事**：
- 不做 100k stars 项目（小而精比大而水好）
- 不做单独 release / npm publish（在华典智谱单仓内即可）

**完成判据**：
- 一个完全外部的工程师能在 1 小时内 clone + 跑通 starter template
- 7 份 `docs/methodology/*.md` 草案（每份 2000-4000 字）+ 真实代码引用
- `kb-engine` 命名（或同等）确定（→ ADR-029）

### Layer 2: 方法论文档（12-18mo）

**目标**：用低频高质量文章 + 决策日记沉淀方法论。

**形式**：
- 月度决策日记（架构师自记，约 500-1000 字 / 月，舒适形式）
- 季度方法论文章（AI 协作起草，架构师 review，约 3000-5000 字 / 季）
- 累积达 6-10 篇可结集小书形式

**不做的事**：
- 不写长篇专著（太重，前 18mo 不做）
- 不接传统出版社（太慢，走 Gitbook / 个人博客 / 知乎专栏即可）
- 不强求高频更新（季度节律即可）

**完成判据**：
- 12mo 累计 ≥ 4 篇文章发布
- 至少 1 篇文章被外部 (社区 / 学术 / 业界) 真实引用或讨论
- 一个 "方法论书雏形" 目录大纲存在 (不必 commit 任何章节)

### Layer 3: 案例库（持续）

**目标**：华典智谱 = 主案例（5-10 篇延伸级即停）；鼓励 1-2 个跨领域第三方案例。

**主案例**：
- 华典智谱史记：再做 5-7 篇典型章节（候选：吕后本纪 / 孝文本纪 / 项羽列传 / 刺客列传 / 货殖列传 / 太史公自序）
- 选择标准：覆盖不同体裁（本纪 / 列传 / 自序）+ 不同人物密度 + 能验证不同框架抽象

**跨领域案例（邀约模式，不强求）**：
- 候选领域：佛经数字化 / 中医典籍 / 法律案例 / 地方志 / 现代专利
- 邀约对象：高校数字人文中心 / 民间研究者 / 行业知识工程师
- 哪怕失败也有价值——失败本身就是方法论需要修订的信号

### Layer 4: 社区 / 培训 / 商业（机会主义）

**目标**：视 L1-L3 反响逐步打开。

**潜在形式**：
- 中文 AI agent 社区分享 / 讲座（B 站、知乎、即刻）
- 学术圈合作：北大数字人文中心、清华 AIR、字节研究院
- 海外发声：英文版方法论、HackerNews / Lobsters 投稿
- B2B 咨询：帮特定机构做知识工程项目（古籍 / 法律 / 医疗）
- 培训课程 / 付费支持
- 极端情况：拿 VC 钱做"Notion for Knowledge Engineering"（不强求）

**不做的事**：
- 不主动推（视前 3 layer 反响决定）
- 不做"快速变现"产品（D 路线本质是 long game）

---

## 6. 6-12 个月里程碑

| 时间锚 | 里程碑 | 风险/前置依赖 |
|--------|--------|--------------|
| 2026-05 (1mo) | 文档体系全对齐（Stage A-D 完成）+ Sprint L 启动 | 无 |
| 2026-06 (2mo) | `docs/methodology/` 7 份草案完整版 + 第 1 个跨领域案例邀约启动 | Sprint L 完成 |
| 2026-08 (4mo) | 华典智谱史记到 5-10 篇典型章节延伸级 + 产品化 demo 上线（内部可访问）| PE 主线持续；BE/FE 维护模式不卡 |
| 2026-10 (6mo) | 第 1-2 篇方法论文章发布 + 与近邻项目（如 shiji-kb）有过 1 次实质交流 | 写作节律 (Q5) 不掉链 |
| 2027-01 (9mo) | 框架代码抽象 v0.1 release（单仓内 `docs/methodology` + `framework/` 双成熟）| L1 工作不被中断 |
| 2027-04 (12mo) | 第 2 个跨领域案例（内部或外部）验证框架可移植性 | L3 邀约成功率 |

---

## 7. 不做的事（Negative Space — 防止方向漂移）

| 不做 | 理由 |
|------|------|
| C 端古籍阅读 App | 与 shiji-kb 直接竞争且我们没有产品/UI/marketing 长项 |
| 移动端 (iOS / Android) | 同上 + 维护负担 |
| 与字节识典古籍同等数据完整度 | 1-2 年追不上；不必追 |
| 古人模拟器 / 断案游戏 / 跨时空群聊等创新应用 | C 端产品都属于 distraction；放进 backlog 永不主动启动 |
| 自建 frontend 组件库 / UI design system | 借用 shadcn / Tailwind 即可；不深做 |
| 大规模数据 ingest（>20 篇章节）| 超过案例需求即浪费 |
| DAU 增长 / 用户留存指标 | 不是 D 路线的衡量维度 |
| 快速变现路径 | 接受 L4 是机会主义 |
| 抢首发"首个 X 框架"叙事 | 让作品说话，不做 marketing 噱头 |

---

## 8. 风险与对策

| 风险 | 概率 | 严重度 | 对策 |
|------|------|-------|------|
| shiji-kb 团队抢做团队级框架 | 低 | 高 | 持续观察社区动向；与近邻项目保持友好关系；保持差异化（团队 vs 单人） |
| 字节识典古籍开源框架 | 低 | 中 | 我们走 DIY / 工程师社区路线，B 端市场不冲突 |
| Anthropic 发布官方框架 | 中 | 中 | 我们的方法论可对接 Anthropic 工具，反而获益；保持框架领域中立 |
| 写作短板导致 L2 卡死 | 中 | 中 | Q5 软节律 + 代笔模式；文档驱动 > 文章驱动 |
| Architect 单点风险 | 中 | 高 | 文档体系优先（人离开后下一个人能接续）；不做"全在我脑子里"项目 |
| 框架抽象做出来但案例验证不通过 | 低 | 高 | Sprint L 双 track 即时反馈；4-stage gate 每个 sprint 验证 |
| 6-9mo 没有任何外部认可导致心理崩溃 | 中 | 高 | 接受这是修道院路线；找 1-2 个真心同道者保持小信号 |

---

## 9. 1 个月内可执行 checkpoint

| Date | Checkpoint | Owner |
|------|-----------|-------|
| 2026-04-29 | ADR-028 + D-route-positioning.md draft (本文件) 完成 | Architect |
| 2026-04-30 | 用户审 ADR-028 → ACK / 修订 | User |
| 2026-05-01 | Stage B 启动 (CLAUDE.md / 项目宪法 / STATUS / 架构 v2.0)| Architect |
| 2026-05-04 | Stage B 完成 → 用户审 | Architect → User |
| 2026-05-05 | Stage C 启动 (操作文档 + methodology 7 份草案 + agent 元描述) | Architect |
| 2026-05-09 | Stage C 完成 → 用户审 | Architect → User |
| 2026-05-10 | Stage D 启动 (Sprint K 收档 + Sprint L brief + 任务卡分类 + roadmap) | Architect |
| 2026-05-12 | Stage D 完成 → 用户审 | Architect → User |
| 2026-05-13 | "假装新协作者" 测试：按开工三步读 CLAUDE.md → STATUS → CHANGELOG，验证 5 分钟内能理解新方向 | User |
| 2026-05-14 | Sprint L Stage 0 brief ACK → Sprint L 正式启动 | Architect → User |
| 2026-05-30 | （可选）观察数字人文 19 群 4 周后 → 决定何时主动接触近邻项目团队 | User |

---

## 10. 衡量成功的指标（North Star Metrics）

D 路线**不**用 DAU / 用户增长曲线衡量。我们用：

### Layer 1 (框架抽象):
- 7 份 `docs/methodology/*.md` 草案完成（草案 → v1.0 → v1.1 迭代次数）
- 一个外部工程师 clone + 跑通 starter template 的耗时（目标 ≤ 1 小时）
- 框架抽象出的代码相对华典智谱代码的"领域无关比例"（目标 ≥ 70%）

### Layer 2 (方法论文档):
- 月度决策日记累计字数（目标 6mo 累计 ≥ 6000 字）
- 季度方法论文章发布数（目标 12mo 累计 ≥ 4 篇）
- 文章被外部引用 / 讨论次数（目标 12mo 内 ≥ 3 次实质引用）

### Layer 3 (案例库):
- 华典智谱史记延伸到的章节数（目标 8mo 内 5-10 篇）
- 跨领域第三方案例邀约成功数（目标 12mo 内 ≥ 1 个，哪怕失败也算成功）

### Layer 4 (机会主义):
- 不设硬指标
- 但每季度评估一次反响信号（社区互动 / 同行认可 / 邀约请求 / 商业询问）

### 元指标:
- 项目方向稳定性：D-route 战略不被 sunset / 不被 pivot 的月数（越长越好；short-term 改变是大问题）
- Architect 持续投入度：每月战略 + 写作时间投入小时数（不强求高，但要稳定）

---

## 11. 修订历史

| Version | Date | Author | Change |
|---------|------|--------|--------|
| Draft v1 | 2026-04-29 | Architect | 初稿（与 ADR-028 同步起草，Stage A 一部分）|

---

**本文件为 ADR-028 的产品化展开。任何与本文档冲突的后续设计 / 决策 / 任务卡，应优先回归 ADR-028 + 本文件复核，再考虑修订。**
