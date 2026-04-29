# Contributing to HuaDian (华典智谱)

> 感谢你愿意贡献！这份文档帮你快速理解本项目的协作模式 + 治理方式。

---

## TL;DR

- **代码贡献** → fork + PR + 通过 review
- **方法论 / 文档贡献** → 同上，但需架构师额外 review 方法论一致性
- **跨领域案例** → 强烈欢迎！见 §6
- **Bug 报告** → GitHub Issues
- **inbound = outbound**：你提交的代码默认按 [Apache 2.0](LICENSE)，文档默认按 [CC BY 4.0](LICENSE-DATA)
- **行为准则**：技术讨论保持专业；尊重古籍研究的严肃性

---

## 0. 在贡献之前先读

按以下顺序读完，预计 30-45 分钟：

1. [README.md](README.md) — 项目是什么 / 状态 / 双许可证
2. [docs/00_项目宪法.md](docs/00_项目宪法.md) — **不可变原则**（任何贡献都不能违反）
3. [docs/strategy/D-route-positioning.md](docs/strategy/D-route-positioning.md) — 项目方向 / 不做的事
4. [ADR-028](docs/decisions/ADR-028-strategic-pivot-to-methodology.md) — 战略转型决策
5. [docs/STATUS.md](docs/STATUS.md) — 当前状态板
6. [CLAUDE.md](CLAUDE.md) — 项目入口（多 agent 协作模式）

如果只想做小 bug 修复，跳到 §3。

---

## 1. 许可证 (Inbound = Outbound)

提交 PR / 贡献内容到本项目，**即视为同意**：

- 你的**代码贡献**（apps/, services/, packages/, scripts/, build configs）按 [Apache License 2.0](LICENSE) 授予项目使用、修改、分发权
- 你的**文档 / 数据贡献**（docs/, data/, *.md, fixtures 衍生数据）按 [CC BY 4.0](LICENSE-DATA) 授予使用权
- 你确认你拥有提交内容的权利，未侵犯任何第三方权益
- 你不撤销已授予的许可（per Apache 2.0 §2 / CC BY 4.0 §2 irrevocable grant）

**重要**：本项目目前不要求签署单独的 CLA（Contributor License Agreement）。Apache 2.0 §5 已经为贡献提交建立了等效的法律框架。如果未来需要 CLA（例如形成法律实体或商业许可时），将以 ADR 形式公告，并不溯及既有贡献。

---

## 2. 多角色协作模型（重要）

本项目以"中型开发团队"模式运作。**Claude Code agent 与人类贡献者使用同一套角色边界**。

10 个角色定义在 [`.claude/agents/`](.claude/agents/)：

| 角色 | 职责 | 贡献者通常对应 |
|------|------|--------------|
| chief-architect | 架构决策、ADR、风险识别、仲裁 | 资深贡献者；不接受第一次贡献 |
| product-manager | PRD、功能取舍、商业化决策 | 产品经验者 |
| historian | 数据正确性、实体歧义仲裁、术语库 | 古籍研究者 / 数字人文学者 |
| ui-ux-designer | 视觉、交互原型、组件规范 | 设计师 |
| backend-engineer | API / Drizzle schema / 服务层 | 后端工程师 |
| pipeline-engineer | 数据摄入 / LLM 抽取 / TraceGuard | 数据 / AI 工程师 |
| frontend-engineer | React 组件实现 / GraphQL 调用 | 前端工程师 |
| qa-engineer | 测试、质检规则、黄金集 | QA / 测试工程师 |
| devops-engineer | CI/CD、Docker、监控基建 | SRE / DevOps |
| data-analyst | 埋点、A/B、反馈分析 | 数据分析师 |

**跨角色协作铁律**（项目宪法 C-15）：
- 每个任务卡指定主导角色；其他角色只能"提议 / 评审"
- 冲突 → 升级到架构师仲裁 → 记入 ADR
- 你 PR 涉及的领域，你需要扮演对应角色

---

## 3. 提交 Bug 报告

[New Issue](../../issues/new) 时请包含：

1. **预期行为** vs **实际行为**
2. **重现步骤**（最小可重现示例）
3. **环境**：操作系统、Node 版本、Python 版本、PostgreSQL 版本
4. **相关 sprint / ADR / 任务卡 ID**（如果你能定位）
5. **Stack trace / log 截取**（如果有）

如果 bug 触发了 V1-V11 invariant 回归 → 请标 `bug:invariant-regression` label，架构师会优先处理。

---

## 4. 提交代码 PR

### 4.1 准备

1. Fork 本仓库
2. 在你的 fork 上 checkout 一个新分支（命名：`feat/xxx`、`fix/xxx`、`docs/xxx`、`chore/xxx`、`refactor/xxx`）
3. 本地起服务（参考 [README §Quick start](README.md#quick-start-5-minutes)）
4. 改代码 + 加测试

### 4.2 commit 规范

使用 [Conventional Commits](https://www.conventionalcommits.org/zh-hans/v1.0.0/)：

```
feat(scope): summary
fix(scope): summary
docs(scope): summary
chore(scope): summary
refactor(scope): summary
test(scope): summary
```

- scope 例：`pipeline`, `api`, `web`, `db`, `framework`, `methodology`, `adr-028`
- summary 用英文（与项目代码注释一致）
- body 可用中文（README / docs 双语）
- 不自动 push、不自动 merge

每完成一个独立功能点建议 commit。**禁止** force push 到 main。

### 4.3 测试要求

- **代码 PR 必须**通过 typecheck + lint + 既有测试
- 修改 V1-V11 invariant 路径必须通过对应 invariant test
- 新增功能建议加单元测试（`tests/test_*.py` for pipeline / `__tests__/*.test.ts` for web）
- 触及 identity resolver / merge / split 必须通过 `services/pipeline/tests/test_invariants_*.py`

### 4.4 Review 流程

- PR 提交后等待 review（通常 1-7 天，活跃 sprint 期间更快）
- review 由对应角色主导（如修 services/api/ → backend-engineer review）
- 跨角色变更触发架构师仲裁
- 重大架构改动需要先开 ADR，PR 与 ADR 同步合入

---

## 5. 提交方法论 / 文档 PR

我们正在 Layer 2（方法论文档）阶段（参见 [ADR-028 §2.2](docs/decisions/ADR-028-strategic-pivot-to-methodology.md)）。

### 5.1 docs/methodology/ 贡献

7 份草案陆续起草（00-overview / 01-role / 02-sprint / 03-identity / 04-invariant / 05-audit / 06-adr-pattern）。如果你想：

- **完善草案** → fork + 加你的 review comment / 改写部分 / 新增案例 → PR
- **新增草案** → 先开 issue 讨论是否符合 D-route 范围，避免与既有草案重复
- **翻译** → 当前优先中文（用户群匹配），英文版后续启动；想做英文翻译请先 issue

### 5.2 ADR 贡献

新增 ADR 编号取最新 + 1（当前最大 = ADR-029）：

```bash
cp docs/decisions/ADR-028-strategic-pivot-to-methodology.md \
   docs/decisions/ADR-NNN-your-decision-topic.md
```

ADR 必须包含：Status / Date / Authors / Context / Decision / Consequences / 不可逆点 / 阻塞条件。

修订既有 ADR：不要直接改原文，**新增 addendum** 或新 ADR superseding。

### 5.3 Sprint logs / Retro 贡献

仅 sprint 主导角色 + 架构师贡献。外部贡献者通常不动 sprint logs。

---

## 6. 跨领域案例贡献（最欢迎！）

D-route 战略的核心赌注之一是**框架的领域可移植性**。如果你正在做：

- **佛经数字化**
- **中医典籍结构化**
- **法律案例分析**
- **现代专利知识图谱**
- **地方志 / 族谱 / 碑刻**
- **任何"严肃 + 团队 + AI" 的知识工程项目**

…… 哪怕只是想试一下，强烈欢迎与我们交流。可走的合作模式：

1. **轻度 — 借鉴**：你拿走我们的方法论 / ADR / 框架抽象自己用，社区报告反馈
2. **中度 — 案例**：你的项目作为本仓库的"第三方案例"被引用（保留你的项目独立性 + license）
3. **深度 — 共建**：你的项目代码 / 数据合并入本仓库（需要双方 license 兼容）

请先开 [Issue](../../issues/new) 标 `cross-domain-case` label，描述你的项目 + 想要哪种合作模式。

---

## 7. 行为准则

- 技术讨论保持专业 + 善意
- 尊重古籍研究的严肃性（即便我们用 AI，也不轻佻对待源材料）
- 不容忍人身攻击 / 骚扰 / 歧视
- 鼓励"我不知道，让我去查"（古籍研究本来就需要谦逊）
- 鼓励质疑既有 ADR / invariant，但请通过 issue / PR 走流程，不通过私下渠道

---

## 8. 沟通渠道

- **GitHub Issues** — 主要渠道：bug 报告 / feature 请求 / 设计讨论 / 跨领域案例
- **GitHub Discussions** — （未启用，视社区规模决定）
- **微信群** — （未启用，视项目阶段决定）

不要通过个人邮件 / 私信讨论项目设计 — 公开化让所有贡献者都能看到决策过程。

---

## 9. 致开源生态的回礼

如果本项目的方法论 / 框架对你有帮助，最有价值的回礼**不是 star**，而是：

1. **告诉我们你怎么用** — 一个 issue 即可，我们会作为案例记入 retros
2. **贡献你领域的 invariant / pattern** — 让框架更通用
3. **公开发表你的方法论使用经验** — 博客 / 论文 / 会议分享，不必引用我们但帮助 KE 社区

---

**最后一句话**：知识工程是慢工出细活的领域。本项目不追求高频 release / fancy demo，追求**长期、可信、可复制**。如果你的贡献节奏与此匹配，欢迎加入。

— The HuaDian Project Maintainers
  2026-04-29
