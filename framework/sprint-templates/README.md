# framework/sprint-templates — Sprint Governance Templates

> Status: **v0.1 (Sprint L Stage 1 first abstraction)**
> Date: 2026-04-29
> License: Apache 2.0 (代码/模板) / CC BY 4.0 (文档)
> Source: 华典智谱 Sprint A-K 11 个真实 sprint 实证 + `docs/methodology/02-sprint-governance-pattern.md`

---

## 0. 这是什么

一套**领域无关**的 Sprint 治理模板，让任何 Knowledge Engineering 项目可以直接复用 AKE 框架的 Sprint / Stage / Gate / Stop Rule 工作流。

不需要写代码，**只需要复制本目录到你的项目，改填占位字段，即可启动你的 Sprint A**。

---

## 1. 何时用这套模板

✅ **适合**：
- 新启动一个 KE（Knowledge Engineering）项目
- 已有项目想改用工程化 sprint 节奏
- 多人 / 多 agent 协作的"造知识"项目（数据完整性敏感、回滚成本高）

❌ **不适合**：
- 普通软件项目（Scrum / Kanban 已成熟，不需要 KE-specific 治理）
- 单人短期项目（1-2 周内完成）
- 纯 RAG / chatbot 应用（用 LangChain 等工具足够，不需要 sprint 治理）

---

## 2. 文件清单

| 文件 | 用途 | 复制频率 |
|------|------|---------|
| `README.md` | 本文件 | 复制一次（每项目）|
| `brief-template.md` | Sprint Brief 模板 | 每个 sprint 复制 + 改填 |
| `stage-templates/stage-0-prep-template.md` | Stage 0 准备模板 | 每个 sprint 复制 |
| `stage-templates/stage-1-smoke-template.md` | Stage 1 smoke 模板 | 每个 sprint 复制 |
| `stage-templates/stage-2-full-template.md` | Stage 2 full 模板 | 每个 sprint 复制 |
| `stage-templates/stage-3-review-template.md` | Stage 3 review 模板 | 每个 sprint 复制 |
| `stage-templates/stage-4-apply-template.md` | Stage 4 apply 模板 | 每个 sprint 复制 |
| `stage-templates/stage-5-closeout-template.md` | Stage 5 closeout 模板 | 每个 sprint 复制 |
| `retro-template.md` | Sprint Retro 模板 | 每个 sprint 复制 |
| `stop-rules-catalog.md` | 5 类 Stop Rule 模板 | 复制一次（每项目）+ 每 sprint brief 引用 |
| `gate-checklist-template.md` | Gate 检查清单模板 | 复制一次（每项目）+ 每 stage 引用 |

---

## 3. 5 分钟快速上手

```bash
# 1. 复制本目录到你的项目
cp -r /path/to/huadian/framework/sprint-templates /path/to/your-project/sprint-templates

# 2. 创建你的项目第一个 sprint 目录
mkdir -p /path/to/your-project/docs/sprint-logs/sprint-a

# 3. 复制 brief 模板填写
cp sprint-templates/brief-template.md \
   docs/sprint-logs/sprint-a/stage-0-brief-$(date +%Y-%m-%d).md

# 4. 编辑 brief（按文件内 ⚠️ 占位符提示填写）

# 5. 架构师 ACK brief → Sprint A Stage 0 启动
```

---

## 4. 跨领域使用指南

### 4.1 必须 instantiate 的占位字段

每个模板用 `⚠️ DOMAIN-SPECIFIC: <说明>` 标注**领域专属**字段。这些字段必须按你的领域填写，不能照抄华典智谱史记案例。

常见领域字段示例：

| 占位 | 古籍领域填法 | 法律领域填法 | 医疗领域填法 |
|------|-----------|-----------|-----------|
| `主题` | 高祖本纪 ingest | 知识产权判例 batch | 心血管疾病病例库 |
| `entity 类别` | 18 类古籍实体 | 当事方/法条/案号/法域 | 患者/诊断/药品/手术 |
| `LLM cost 预算` | $1.80 / sprint | 视模型选型 | 视模型选型 |
| `domain dictionary` | dynasty-periods.yaml | jurisdictions.yaml | clinical-codes.yaml |

### 4.2 角色 instantiation

10 个 AKE 角色（参见 `docs/methodology/01-role-design-pattern.md`）中只有 1 个需要 instantiate：

- 古籍领域：**Historian**
- 佛经领域：**Buddhologist**
- 法律领域：**Legal Expert / 律师**
- 医疗领域：**Clinical Expert / 医师**
- 专利领域：**Patent Attorney**

其他 9 个角色（Architect / PE / BE / FE / QA / DevOps / PM / Designer / Analyst）名字和职责完全不变。

### 4.3 Stop Rule 阈值调整

`stop-rules-catalog.md` 给出 5 类 Stop Rule 模板。具体阈值（cost / 实体数 / 回归率 / etc）必须按你的领域调整：

- 古籍 cost 预算：~$1-2 / sprint
- 法律 cost 预算：可能 5-10x（context 长 / token 多）
- 医疗 cost 预算：视监管/合规要求决定

---

## 5. 设计哲学

本套模板基于以下信念（参见 `docs/methodology/02-sprint-governance-pattern.md`）：

1. **KE 项目 ≠ 软件项目** — 数据正确性 > 功能完整度
2. **dry-run + apply 双段式** — 任何 DB mutation 必须分两步
3. **Stop Rule 显式化** — 不允许"差不多就过"的妥协
4. **慢而深** — Sprint 节奏比软件 Scrum 慢（每 1-3 周 1 个），单 sprint 工作量大但质量高
5. **跨角色协作铁律** — 决策权 + 执行权明确分离

---

## 6. 反模式（不要这么做）

读过 `docs/methodology/02-sprint-governance-pattern.md` §8 反模式，简短重申：

- ❌ 跳 Stage（"smoke 通过了应该没问题"）
- ❌ 模糊 Stop Rule（"如果 cost 太高 stop"——多高？）
- ❌ 跨 Sprint 隐式依赖（不验证前置 sprint 收档就启动）
- ❌ 只前进不回滚（数据 apply 出错忍着不 rollback）

---

## 7. 反馈与贡献

本套模板从华典智谱 Sprint A-K 实证抽出，是 v0.1 状态。预期会随更多案例（包括跨领域）反馈而迭代。

如果你用本套模板做了你的项目，欢迎：

- **报告使用经验**（GitHub Issue 标 `framework-feedback`）
- **指出遗漏 / 不清楚的地方**（GitHub Issue 标 `framework-gap`）
- **贡献跨领域 instantiation 范例**（GitHub PR 加你的领域 mapping 表）

详见华典智谱主项目 [CONTRIBUTING.md](https://github.com/lizhuojunx86/huadian/blob/main/CONTRIBUTING.md)。

---

## 8. 版本信息

| Version | Date | Source | Change |
|---------|------|--------|--------|
| v0.1 | 2026-04-29 | Sprint L Stage 1 (first abstraction) | 初版抽出 |

---

> 本套模板是 AKE 框架 Layer 1 的第一刀。后续 Layer 1 抽象（multi-role coordination / identity resolver / invariants / audit / etc）将陆续在 `framework/` 下出现。
> 当前完整 framework 目录见华典智谱主项目 https://github.com/lizhuojunx86/huadian/tree/main/framework
