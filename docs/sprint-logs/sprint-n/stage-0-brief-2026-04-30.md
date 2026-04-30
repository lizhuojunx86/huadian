# Sprint N Brief — Identity Resolver R1-R6 抽象（framework/identity-resolver/）

> 起草自 `framework/sprint-templates/brief-template.md` v0.1.1
> Dogfood: 这是 brief-template 的**第三次**外部使用（第一次 Sprint L 自审 / 第二次 Sprint M 起草自己 brief / 第三次 Sprint N 起草自己 brief）

## 0. 元信息

- **架构师**：首席架构师（Claude Opus 4.7）
- **Brief 日期**：2026-04-30
- **Sprint 形态**：**单 track / 多 stage**（与 Sprint L+M 不同：本 sprint 是代码层抽象 sprint，需要 PE 子 session 协助）
- **预估工时**：2-3 个 Cowork 会话 / 或 1-2 周（视用户节奏）— **明显高于 L+M 的 1 会话**
- **PE 模型**：`Sonnet 4.6`（per Sprint M retro §5.3 实证：代码 refactor 类工作切 Sonnet）
- **Architect 模型**：`Opus 4.7`（架构师 session 仍 Opus / 含 ADR-030 候选评估 / Stop Rule 仲裁）
- **触发事件**：Sprint M closeout §2.4 + retro §7.4 推荐 — Sprint N 候选 A "Identity Resolver R1-R6 抽象（推荐 / 切代码层）"，用户 ACK 启动
- **战略锚点**：[ADR-028](../../decisions/ADR-028-strategic-pivot-to-methodology.md) §2.3 Q3 + Sprint M closeout §2.4 推荐 + [docs/methodology/03-identity-resolver-pattern.md](../../methodology/03-identity-resolver-pattern.md) v0.1 草案

---

## 1. 背景

### 1.1 前置上下文

Sprint L+M 完成 D-route Layer 1 治理类双模块（sprint-templates v0.1.1 + role-templates v0.1.1 / 24 files / ~3700 lines）。下一刀按 Sprint M closeout §2.4 + retro §7.4 推荐切**代码层抽象**——Identity Resolver R1-R6。

Sprint N 在 D-route Layer 1 大局中的位置：

```
L1 第一刀 (Sprint L)   →   L1 第二刀 (Sprint M)      →   L1 第三刀 (Sprint N)
sprint-templates/         role-templates/                identity-resolver/
(治理工作流)              (角色协作)                      (核心 KE 代码模式 / 切代码层)
```

**抽象输入源（已就绪）**：

| 文件 | 行数 | 抽象类型 |
|------|------|---------|
| `services/pipeline/src/huadian_pipeline/resolve.py` | 1065 | 主流程 orchestration（UnionFind / resolve_identities / apply_merges / select_canonical / dry-run report）|
| `resolve_rules.py` | 614 | R1-R5 规则定义 + dictionary loading |
| `resolve_types.py` | 95 | 数据契约（MatchResult / MergeProposal / MergeGroup / BlockedMerge / ResolveResult）|
| `r6_seed_match.py` | 156 | R6 seed-match 算法（Wikidata QID 锚定）|
| `r6_temporal_guards.py` | 273 | temporal guard 算法（cross_dynasty）|
| `state_prefix_guard.py` | 191 | 春秋诸侯国 guard（**华典专属 reference impl**）|
| **总计** | **2394** | |

加上 docs/methodology/03-identity-resolver-pattern.md v0.1 草案（已起草） + Sprint H/I/J 实战经验（GUARD_CHAINS 演化 / state_prefix_guard 落地 / 楚怀王 entity-split 等）= 抽象输入完整就绪。

### 1.2 与 Sprint L+M 的差异

| 维度 | Sprint L+M | Sprint N |
|------|-----------|----------|
| 抽象类型 | 文档抽象（治理 / 协作）| **代码抽象**（核心 KE 算法）|
| 抽象输入量 | ~3700 行 markdown | ~2400 行 Python + 1500+ 行 markdown 历史 |
| 工作量 | 1 会话 | **2-3 会话 / 1-2 周** |
| 角色活跃度 | Architect 单 actor 🟢 | Architect 🟢 + **PE 🟡 子 session**（如需要做 reference impl 重构验证）|
| 模型选型 | Architect Opus 全程 | Architect Opus + **PE Sonnet 4.6 子 session** |
| 风险等级 | low-risk（无数据 mutation）| **medium-risk**（涉及对生产代码的"摸"——但**只摸不改**，纯抽出新代码到 framework/ 不动 services/pipeline/）|
| dogfood 形态 | 用模板回审 Sprint K | 用 framework/identity-resolver/ 跑现有华典史记数据，比对结果一致性 |
| ADR 触发概率 | 0 | **中等**（可能触发 ADR-030 framework styleguide / ADR-031 plugin 注入协议 / etc）|

### 1.3 不做的事（Negative Scope）

- ❌ **不重构 services/pipeline/src/huadian_pipeline/resolve\*.py** — Sprint N 是**抽出**新代码到 framework/，**不改动**生产代码（这是 Sprint N 与 Sprint A-K 的根本区别——A-K 是改 huadian_pipeline；N 是建 framework/）
- ❌ **不改变 R1-R6 算法行为** — 抽出代码必须与生产代码行为完全一致（dogfood 验证 byte-identical 输出）
- ❌ **不抽 services/api/ / apps/web/** — 这些与 identity resolver 无关
- ❌ **不抽 V1-V11 invariant scaffold** — 留给 Sprint O 候选
- ❌ **不抽 Audit + Triage Workflow** — 留给 Sprint P 候选
- ❌ **不做 framework v0.2 release** — 等 Sprint N 完成 + 跨领域反馈后再考虑
- ❌ **不启动新 ingest sprint**（违反 C-22）
- ❌ **不做 Stage 2-3 外部审**（与 L+M 同样默认押后到外部反馈触发）
- ❌ **不做 framework 命名 ADR-030**（除非 Sprint N 中途明确触发，否则继续延后）

---

## 2. 目标范围

### 2.1 单 Track — Identity Resolver R1-R6 抽象

**目标**：抽出领域无关的 `framework/identity-resolver/` v0.1，让任何 KE 项目可以复制 + 注入自己的 domain dictionary + domain guard 来运行 R1-R6 identity resolution。

**抽象目标分层**（基于 Stage 0 inventory 初步评估）：

| 层级 | 内容 | 抽象比例 | 案例方需要做的 |
|------|------|---------|---------------|
| 🟢 完全领域无关 | UnionFind / 数据契约（MatchResult / MergeProposal / MergeGroup / BlockedMerge / ResolveResult）/ 主流程 orchestration / dry-run report | ~50% | 无（直接 import）|
| 🟡 接口领域无关 + 实现领域专属 | R1-R5 评分（算法无关 / 字典 plugin）/ canonical 选择（核心规则 + domain hint）/ GUARD_CHAINS 协议 | ~30% | 注入 domain dictionary loader + domain hint |
| 🔴 案例 reference impl | r6_temporal_guards (dynasty) / state_prefix_guard (春秋诸侯国) / tongjia + miaohao yaml 内容 / 帝X honorific hint | ~20% | 自己写领域 guard，参考华典 reference impl |

**具体动作**：

#### 2.1.1 `framework/identity-resolver/` 目录结构（候选）

```
framework/identity-resolver/
  README.md                       — 8 段，与 sprint-templates / role-templates README 同款
  CONCEPTS.md                     — R1-R6 / GuardChain / Decision 核心概念领域无关定义
  types.py                        — MatchResult / MergeProposal / MergeGroup / BlockedMerge / ResolveResult
  union_find.py                   — UnionFind 数据结构（领域无关）
  rules.py                        — R1-R5 规则接口 + 算法骨架（不含字典内容）
  rules_dictionary_protocol.py    — DictionaryLoader 协议（plugin 接口）
  guards.py                       — GuardChain 协议 + Guard 接口
  resolve.py                      — 主流程 orchestration（领域无关）
  canonical_selection.py          — canonical 选择主框架 + hook 注入点
  dry_run_report.py               — 报告生成（领域无关）
  examples/
    huadian_classics/             — 华典史记 reference impl
      tongjia_loader.py
      miaohao_loader.py
      dynasty_guard.py
      state_prefix_guard.py
      di_honorific_hint.py
  cross-domain-mapping.md         — 6 领域 R1-R6 instantiation 速查（继承 role-templates 同款表）
```

#### 2.1.2 docs/methodology/03-identity-resolver-pattern.md v0.1 → v0.1.1

参照 Sprint M methodology/01 的处理（Sprint M 加 §9 Framework Implementation cross-reference 段），methodology/03 加 §X Framework Implementation 引用 framework/identity-resolver/。

**完成判据**（5 项）：

- ✅ `framework/identity-resolver/` 下完整文件清单就位（types / union_find / rules / guards / resolve / canonical_selection / dry_run_report / examples / README / CONCEPTS / cross-domain-mapping）
- ✅ examples/huadian_classics/ 跑 framework code 与现有 services/pipeline/ resolve 结果**byte-identical**（dogfood 严格验证）
- ✅ docs/methodology/03 加 cross-reference §
- ✅ 跨领域 instantiation 实例（cross-domain-mapping.md 含医疗 / 法律 / 专利等 R1-R6 适配示例）
- ✅ 不影响 services/pipeline/src/huadian_pipeline/ 生产代码（V1-V11 全绿不回归）

### 2.2 Track 2

不适用（单 track sprint）。

---

## 3. Stages（5-stage 模板的 Sprint N 适配）

> 与 Sprint L+M 同——5-stage 默认假设 KE ingest 模式不适用，但 Sprint N 比 L+M 复杂（涉及代码 + dogfood byte-identical 验证），适配如下：

### Stage 0 — Inventory + 抽象优先级

**目标**：架构师深入扫 6 个 Python 文件，标"完全领域无关 / 接口无关 + 实现专属 / 案例专属"边界 + 抽象优先级排序。

**具体动作**：

- 0.1 deep read 6 个 .py 文件 + qc/ 相关 invariants
- 0.2 标注每个 function / class 的领域耦合等级
- 0.3 设计 plugin 注入点（DictionaryLoader / GuardChain / CanonicalHint / etc）
- 0.4 评估是否需要 ADR-030 framework styleguide / ADR-031 plugin 协议（如分歧明显则触发，否则延后）
- 0.5 起草顺序 + 工作量预估

**输出**：`docs/sprint-logs/sprint-n/stage-0-inventory-2026-04-30.md`（~5000 字）

**Gate 0**：

- 6 个 .py 文件都标了领域耦合等级
- plugin 注入点 ≥ 3 个明确（DictionaryLoader / GuardChain / CanonicalHint 至少）
- 抽象优先级表就位
- 工作量预估 ≤ 3 会话 / 否则触发 Stop Rule #5

### Stage 1 — 抽象起草（核心工作）

**目标**：起草 `framework/identity-resolver/` 全部内容（约 13-15 个文件 / ~1800-2500 行 Python + markdown）。

**子集大小**：1-2 会话内完成核心起草；examples/ + cross-domain-mapping 视情况延伸到第 3 会话。

**具体动作（按起草顺序）**：

- 1.1 起草 types.py（最简单，与 services/pipeline 几乎完全复制）
- 1.2 起草 union_find.py（标准算法，完全无关）
- 1.3 起草 guards.py 协议（GuardChain + Guard 接口）
- 1.4 起草 rules_dictionary_protocol.py（DictionaryLoader plugin 协议）
- 1.5 起草 rules.py（R1-R5 算法骨架 + plugin hook）
- 1.6 起草 canonical_selection.py（5 条规则核心 + hook 注入）
- 1.7 起草 dry_run_report.py（领域无关报告生成）
- 1.8 起草 resolve.py（主流程 orchestration）
- 1.9 起草 CONCEPTS.md（R1-R6 / GuardChain / Decision 概念定义）
- 1.10 起草 examples/huadian_classics/（华典 reference impl — 复制 + 改路径让其能跑）
- 1.11 起草 cross-domain-mapping.md（继承 role-templates 同款 6 领域）
- 1.12 起草 README.md（与其他模块同款 8 段）

**Gate 1**：

- 13-15 个文件全部就位
- types.py / union_find.py / 主流程领域无关验证（无 dynasty / 历史 / 古籍 字样）
- examples/huadian_classics/ 能 import + 不报错（不要求实际跑通，第 1.13 才验证）

### Stage 1.13 — Dogfood byte-identical 验证（关键 gate）

**目标**：用 examples/huadian_classics/ 跑现有华典 729 active persons 数据，输出与 services/pipeline/ 当前 dry-run 结果**byte-identical**。

**具体动作**：

- 1.13.1 PE 子 session（Sonnet 4.6）调用：跑两套 dry-run
  - A. `services/pipeline/src/huadian_pipeline/resolve.py` resolve_identities() 当前生产路径
  - B. `framework/identity-resolver/resolve.py` + examples/huadian_classics/ plugin 注入
- 1.13.2 比较两份 ResolveResult（merge_groups / hypotheses / blocked_merges / r6_distribution 全部）
- 1.13.3 输出 dogfood 报告 `stage-1-dogfood-2026-04-30.md`（与 L+M 同形态）

**Gate 1.13（critical）**：

- 两份 dry-run 结果**完全相同**（merge_groups 数量 + 内容 / hypotheses / blocked_merges / r6_distribution 全部一致）
- 如有任何差异 → 立即 Stop Rule #2 触发 → Architect 仲裁 → 修复 framework 代码或回到 Stage 1 改设计
- 这是 Sprint N 的最严格 gate（区别于 L+M 的 dogfood 是 cosmetic 覆盖度，N 的 dogfood 是 byte-identical 等价证明）

### Stage 2 — 外部反馈（默认押后）

与 L+M 同处理：默认押后到外部时机触发。本 sprint 不阻塞关档。

**触发条件**：1-2 个跨领域案例方主动接触 → 用 framework/identity-resolver/ 走通他们的"R1-R6 适配"。

### Stage 3 — Dry-Run + Review

不适用（无数据 mutation / 无 Domain Expert review）。

### Stage 4 — Apply

不适用（不改生产代码）。

### Stage 5 → 重命名 Stage 4 — Closeout

**目标**：Sprint N 关档。复用 framework/sprint-templates/stage-templates/stage-5-closeout-template.md（**第三次** dogfood）。

**具体动作**：

- 4.1 不立独立 task card（与 L+M 同性质）
- 4.2 STATUS.md 更新（D-route Layer 1 进度：治理类双模块 + identity-resolver = 三模块完整）
- 4.3 CHANGELOG.md 追加（Sprint N 条目）
- 4.4 retro 起草（复用 retro-template，**第三次** dogfood）
- 4.5 衍生债登记（dogfood 第三次发现的改进点 / 与 sprint-l/m 衍生债合并）
- 4.6 ADR 更新（如 Sprint N 中触发 ADR-030 / ADR-031 则落地）
- 4.7 docs/methodology/03 v0.1 → v0.1.1 cross-reference 段
- 4.8 Sprint O 候选议程（推荐 V1-V11 Invariant Scaffold）

**Gate 5 判据**：

- STATUS / CHANGELOG / retro 全部就位
- 衍生债登记完成
- methodology/03 cross-reference 加上
- 如触发新 ADR 则落地

---

## 4. Stop Rules

> 详见 `framework/sprint-templates/stop-rules-catalog.md` 5 类模板。
> Sprint N 是 medium-risk sprint（vs L+M low-risk），多了 byte-identical 验证 stop rule：

1. **byte-identical 验证失败**（最严格 / Gate 1.13）：framework code 与生产代码对同一份数据输出不同 → Stop，立即修复或回 Stage 1 改设计。**这是 Sprint N 的核心 stop rule**
2. **抽象边界判定混淆**：起草过程中发现某 function/class "领域无关 / 案例专属" 边界模糊 → Stop，触发 Architect 重审 + 必要时 ADR
3. **plugin 协议设计分歧明显**：DictionaryLoader / GuardChain / CanonicalHint 任一协议设计经反复推演仍有 ≥ 2 个明显候选方案分歧 → Stop，触发 ADR-031 plugin 协议
4. **意外触碰 services/pipeline 生产代码**：抽出过程中发现 framework 抽象需要改 services/pipeline/ 任何文件 → Stop，立即评估（违反 §1.3 Negative Scope）
5. **examples/ reference impl 无法跑**：华典 examples 在 framework code 上无法 import / 启动 → Stop，回 Stage 1 修协议
6. **Sprint N 工时 > 4 会话**：超出预估上限 → Stop，评估是否拆 Sprint N.1 / N.2
7. **触发新 ADR ≥ 2 个**：起草过程触发治理 / 协议类强制讨论超出预期 → Stop，先关 ADR 再继续
8. **dogfood byte-identical 完成但 framework 代码量 > 3000 行**：抽象过度（hint：services/pipeline 总共 2394 行；抽出来如超出原代码量说明设计不简洁）→ Stop，重审是否过度抽象

---

## 5. 角色边界

| 角色 | 活跃度 | 主要职责 |
|------|-------|---------|
| 首席架构师 | 🟢 主导 | Stage 0 inventory / Stage 1 起草全部 framework/identity-resolver/ 文件 / Stage 1.13 dogfood 设计 / Stage 4 closeout / 跨阶段 Stop Rule 仲裁 / 如触发 ADR 则起草 |
| 管线工程师 (PE) | 🟡 子 session（Stage 1.13）| 仅 Stage 1.13 启用：在 Sonnet 4.6 子 session 跑 byte-identical 验证（生产 dry-run vs framework dry-run 对比），输出 dogfood 报告。**PE 不写新代码 / 不改生产代码**；只跑两次 dry-run + 比对 |
| 后端工程师 (BE) | ⚪ 暂停 | 不参与 |
| 前端工程师 (FE) | ⚪ 暂停 | 不参与 |
| Domain Expert（古籍专家）| ⚪ 暂停 | 不参与（不抽具体领域内容）|
| QA 工程师 | 🟡 监控 | V1-V11 invariants 持续跟踪（不主动改）；如 Stage 1.13 byte-identical 失败可能与 invariant 关联 |
| DevOps | ⚪ 暂停 | 不参与 |
| 产品经理 / UI/UX 设计师 / 数据分析师 | ⚪ 暂停 | 不参与 |

🟢 高 / 🟡 维护 / ⚪ 暂停。

**与 Sprint L+M 的差异**：本 sprint 不再纯 single-actor — Stage 1.13 必须有 PE 子 session（Sonnet 4.6）跑 byte-identical 验证，因为：

1. Architect Opus 主 session 不便切换执行模式（一直起草新代码）
2. Sonnet 4.6 在跑 dry-run + 比对类执行任务上充分（per Sprint K closeout §6.3 实证）
3. 跨 session 协调用 framework/role-templates/tagged-sessions-protocol.md（**第一次** 实战使用 — 是 role-templates 的第一次"非 Sprint K" dogfood）

---

## 6. 收口判定（Definition of Done）

至少 5 条：

- ✅ `framework/identity-resolver/` 13-15 个文件全部就位
- ✅ ⚠️FILL 占位符规范与 Sprint L+M 一致
- ✅ Stage 1.13 byte-identical 验证通过（**critical gate**）
- ✅ docs/methodology/03 加 cross-reference 段（v0.1 → v0.1.1）
- ✅ STATUS.md / CHANGELOG.md 更新（D-route Layer 1 进度推进 / Sprint N 关档）
- ✅ Sprint N retro 完成（含 D-route 资产盘点 + Sprint O 候选议程）
- ✅ 衍生债登记
- ✅ V1-V11 全绿不回归（本 sprint 不改生产代码 / 不改数据，但 dogfood 验证间接确证 invariant 仍 valid）
- ✅ services/pipeline/src/huadian_pipeline/resolve\*.py 文件**完全未修改**（git diff 验证）
- ✅ Sprint O 候选议程拟定（推荐 V1-V11 Invariant Scaffold / 候选 Audit + Triage Workflow）

---

## 7. 节奏建议

**舒缓节奏（推荐）**：

- 会话 1：Stage 0 inventory（深 read 6 个 .py 文件）+ Stage 1 起草核心文件（types / union_find / guards / rules_dictionary_protocol / rules）
- 会话 2：Stage 1 起草剩余文件（canonical_selection / dry_run_report / resolve / CONCEPTS / examples/huadian_classics / cross-domain-mapping / README）
- 会话 3：Stage 1.13 dogfood byte-identical 验证（含 PE 子 session）+ Stage 4 closeout + retro

**极致压缩节奏**：

- 会话 1（强）：Stage 0 + Stage 1 全部起草 + Stage 1.13 dogfood 准备
- 会话 2：Stage 1.13 验证 + Stage 4 closeout

**判定标准**：

- 架构师状态良好 + Stage 0 inventory 完成后估时 ≤ 1 会话起草核心 → 极致压缩
- inventory 暴露设计分歧 / plugin 协议复杂 → 舒缓 3 会话
- 由用户决定（per L+M 同样原则 / D-route 不赶节奏）

不要赶节奏。Sprint N **本质上比 L+M 难**（代码抽象 + byte-identical 强约束），3 会话节奏更合理。

---

## 8. D-route 资产沉淀预期

本 sprint 预期沉淀：

- [x] **框架代码 spike**：`framework/identity-resolver/` v0.1 — 主要产出
- [x] **已有 methodology 草案的 v0.1 → v0.1.1 迭代**：methodology/03 加 cross-reference
- [x] **跨领域 mapping 表更新**：framework/identity-resolver/cross-domain-mapping.md
- [x] **案例素材积累**：retro 中标注可抽象 pattern（候选：dictionary plugin pattern / guard chain protocol / canonical selection hint pattern / byte-identical dogfood pattern）
- [ ] **新 ADR**（条件性）：如设计中触发 ADR-030 framework styleguide / ADR-031 plugin 注入协议

至少 4 项预期 → 远超 ADR-028 / C-22 的 ≥ 1 项要求。

**Layer 进度推进预期**：

- L1: 🟢 治理类双模块（sprint-templates + role-templates v0.1.1）→ 🟢 **治理类 + 代码层第一刀**（+ identity-resolver v0.1）/ +~1800-2500 行 / +1 抽象资产模块
- L2: methodology/03 加 cross-reference（与 methodology/01 + 02 同模式紧密化）/ 内容仍 v0.1
- L3: +1 dogfood 案例（华典 729 active persons byte-identical 验证）
- L4: 不变（机会主义；framework 三模块完整后 v0.2 release 候选门槛**升级**到第 4 模块完成时再考虑）

---

## 9. 模型选型

- **Architect 主 session**：Opus 4.7（继续 / 战略 + 架构 + 起草设计 + plugin 协议设计）
- **PE 子 session（仅 Stage 1.13）**：Sonnet 4.6（跑 byte-identical 验证 + 比对报告）
- **理由**：per Sprint K closeout §6.3 + Sprint M retro §5.3 实证—— "主 Opus + 子 Sonnet" 模式在 multi-role 协作 sprint 上充分。Sprint N 中 Architect 仍主导起草（Opus 强项），PE 子 session 仅做 deterministic 任务（dry-run + diff 比对，Sonnet 4.6 充分）。

---

## 10. Dogfood 设计

### 10.1 Sprint N 是 framework/sprint-templates/ 第三次外部使用 + framework/role-templates/ 第二次外部使用

- brief-template 第 3 次：起草本 brief（已发现起草中无新 v0.2 候选）
- closeout-template 第 3 次（Stage 4）
- retro-template 第 3 次（Stage 4）
- **role-templates tagged-sessions-protocol 第 1 次实战外部使用**：Stage 1.13 跨 Architect + PE session 协调（第一次"非 Sprint K"实战；非 self-audit）

### 10.2 Sprint N 是 framework/identity-resolver/ 第一次 self-audit dogfood

byte-identical 验证（Stage 1.13）是 framework/identity-resolver/ 的 self-audit dogfood — 如果 framework 抽象正确，则与 services/pipeline 输出完全相同；如不同则 framework 设计有缺陷。

**这是比 L+M 严格得多的 dogfood 标准**。L+M 是覆盖度（90% / 99.2%）；N 是 byte-identical（100% 相同 or 失败）。

### 10.3 起草本 brief 暴露的发现（即时登记）

无新 brief-template 改进候选发现。brief-template v0.1.1（after DGF-M-02 + 03 patch）对 Sprint N 适配良好 — §0 PE 模型字段、§3 stage 适配、§5 角色边界表都按需填了。

→ Sprint M v0.1.1 patch 验证有效。

---

## 11. 决策签字

- 首席架构师：__ACK 待签 (2026-04-30)__
- 用户：__ACK 待签 (2026-04-30)__
- 信号：本 brief 用户 ACK 后 → Sprint N Stage 0 启动

---

**本 brief 起草于 2026-04-30 / 沿用 framework/sprint-templates/brief-template.md v0.1.1（第三次外部使用 / 第二次"非自审" dogfood）**
