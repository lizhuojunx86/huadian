# ADR-037 — 框架包命名（Layer 1 distribution / import name）

- **Status**: **accepted**（2026-06-07 用户拍板 `kb-forge` / web 核实无占用）
- **Date**: 2026-06-07
- **Authors**: 首席架构师（Claude Opus 4.8）+ 用户确认（"同意 kb-forge"）
- **Related**:
  - [ADR-028](ADR-028-strategic-pivot-to-methodology.md)（D-route 战略转型）
  - [D-route §5 Layer 1](../strategy/D-route-positioning.md) — 完成判据"`kb-engine` 命名（或同等）确定（→ ADR-029）"
  - [ADR-029](ADR-029-licensing-policy.md)（许可证；**注**：D-route §5 误把命名指向 ADR-029，实际 ADR-029 是许可证策略，命名一直悬空 → 本 ADR 补位）
  - `framework/pyproject.toml`（provisional name = `huadian-ke-framework`）
  - `docs/reports/d-route-progress-review-2026-06-07.md` §5 #3（L1 命名判据未达标）
- **Supersedes**: 无

---

## 1. Context

2026-06-07 进度评估发现：D-route §5 Layer 1 的三条硬完成判据之一"框架命名确定"**从未真正落地**——D-route §5 把它指向 ADR-029，但 ADR-029 实为许可证策略，命名一直悬空。`framework/` 下三个 Python 包用 `framework.identity_resolver` 等描述性导入名，对外无 distribution 名，散称 "AKE framework"。

2027-01 框架 v0.1 release 锚点要求一个确定的、可对外引用的名字。命名属战略/品牌决策（影响 GitHub 可见度、未来 PyPI、方法论文章引用口径），由用户拍板。

### 1.1 命名需要区分两层

| 层 | 现状 | 改名成本 |
|---|---|---|
| **distribution name**（pip / 仓库展示名）| 无（pyproject 暂用 `huadian-ke-framework`）| 低（改 1 处 pyproject + README）|
| **import root**（`framework.*`）| `framework` | **高**（churn 每个测试/示例的 import）|

本 ADR 优先解决 distribution name；import root 是否改名作为次级问题（建议 v0.1 release 前再定，避免现在大规模 churn）。

---

## 2. Decision（accepted 2026-06-07）

**distribution name = `kb-forge`**（候选 A / 用户拍板）。**import root 暂保持 `framework` 不变到 v0.1 release 前**（避免现在 churn 所有 import）。

- **web 核实（2026-06-07）**：GitHub / PyPI 上无 `kb-forge` 项目（同类仅 `kb` / `kb-mcp-server` / `pykb` / `Knowledge-Base`，均非同名）→ 无强占用、可用。
- `framework/pyproject.toml` `[project].name` 已从 provisional 占位改为 `kb-forge`；README 标题与 provisional 注释相应更新。
- import root（`framework.*` → `kb_forge.*`）的实际 rename 仍延到 v0.1 release 前的专门 sprint（配 byte-identical dogfood）。

---

## 3. Alternatives Considered（命名候选）

| 候选 distribution name | 含义 / 联想 | 优点 | 缺点 |
|---|---|---|---|
| **A. `kb-forge`**（推荐）| Knowledge Base + forge（锻造）| 短、动词感、非领域绑定、易记、.com/GitHub 大概率可得 | 与若干小项目可能撞名（需 web 核） |
| **B. `huadian-ke`** | HuaDian + Knowledge Engineering | 与主项目绑定、叙事连续 | "huadian" 对英文读者无意义、绑定单案例感 |
| C. `kb-engine` | D-route §5 原始设想名 | 已在战略文写过 | "engine" 泛滥、与 LangChain 等同质化 |
| D. `agentke` / `ake-kit` | Agentic KE 缩写 | 直指定位 | 拗口、缩写无记忆点 |
| E. 暂不取对外名，只保留 `framework` import root | 零决策 | 不犯错 | 等于判据继续不达标，违背 v0.1 release 前提 |

**命名硬约束**（任一候选都要过）：①web 核实无强占用 / 无商标冲突；②与 [D-route §3](../strategy/D-route-positioning.md) 差异化叙事一致（造知识 ≠ 取知识，团队治理 ≠ agent 调用）；③领域中立（不绑史记 / 不绑中药）。

---

## 4. Consequences

### 正面
- L1 三条硬完成判据补上 1 条；2027-01 v0.1 release 有确定品牌
- 方法论文章、README、对外交流有统一称呼

### 负面 / 成本
- distribution 改名：改 `framework/pyproject.toml` name + `framework/README.md` 标题 + 各处散称 → ~0.5h
- 若将来连 import root 一起改（`framework` → `kb_forge`）：churn 所有 `from framework.X import`，需一个专门的 rename sprint（建议 v0.1 release 同批做，配 byte-identical dogfood 验证）

### 风险
- 选名后 web 核发现占用 → 缓解：§3 列了 5 个候选，可快速切换
- import root 改名拖到 v0.1 才做，期间对外名（dist）与内部名（import）不一致 → 缓解：README 已显式说明 provisional 状态

---

## 5. Out of Scope
- import root `framework.*` → 新名的实际 rename（留给 v0.1 release 前的专门 sprint）
- PyPI 实际发布 / 商标注册
- 分仓决策（framework 是否从 huadian 单仓拆出 — 见 sprint-roadmap §2 Sprint Q ADR-033 候选触发，与本 ADR 解耦）

---

## 6. 后续动作（accepted 后执行）
1. 用户在 §3 选定 / 另提 → 架构师 web 核实占用 → 本 ADR 转 accepted（记选定名 + 核实结果）
2. 改 `framework/pyproject.toml` `[project].name` + `framework/README.md` 标题与 provisional 注释
3. 修订 [D-route §5](../strategy/D-route-positioning.md) 把"命名（→ ADR-029）"更正为"→ ADR-037 + 选定名"
4. [ADR-000-index](ADR-000-index.md) 加索引行
5. （次级，v0.1 前）决定 import root 是否改名 → 如改，起 rename sprint

---

**本 ADR 终结线**：框架命名作为 L1 v0.1 release 的硬前提已被书面化。用户拍板前，`framework` / `huadian-ke-framework` 均为 provisional，不得在对外文章中当作最终名引用。
