# Sprint M 衍生债 — framework/sprint-templates/ + framework/role-templates/ v0.1 → v0.2 迭代清单

> Status: **partial-resolved** (DGF-M-02~07 已落地为 v0.1.1 patch / 2026-04-29)
> 来源 sprint: Sprint M brief 起草 + Stage 1 dogfood (2026-04-29)
> 优先级: 剩余 5 项 P3（不主动启动；遇到机会 batch 处理）
> 触发条件: Sprint N+ 启动时如顺手即处理；或外部反馈批量驱动；或 framework v0.2 release 前批量收尾
>
> **v0.1.1 patch 已处理项（2026-04-29 当日）**：
> - DGF-M-02 ✅ brief-template §0 PE 模型字段加 N/A 占位
> - DGF-M-03 ✅ brief-template §5 角色边界表加 single-actor 简化注脚
> - DGF-M-04 ✅ domain-expert §核心职责加 Triage Decision 单独条目
> - DGF-M-05 ✅ chief-architect §核心职责加 Stop Rule Arbitration 单独条目
> - DGF-M-06 ✅ tagged-sessions-protocol §2.3 加协调模式区分注脚
> - DGF-M-07 ✅ tagged-sessions-protocol §4.5 加 handoff_to: 模式区分注脚
>
> **v0.2 仍待项**（剩 5 项）：
> - DGF-M-01（brief-template §3 加纯文档 sprint 适配 alt 段 — 结构性改动，留 v0.2）
> - T-P3-FW-001 ~ T-P3-FW-004（Sprint L 4 项，全部留 v0.2）

---

## 0. 总览

Sprint M 是 framework/sprint-templates/ 的**第二次外部使用**（用 brief / closeout / retro template 给自己起草），同时是 framework/role-templates/ 的**第一次自审 dogfood**（用 role-templates + tagged-sessions-protocol 回审 Sprint K）。两次 dogfood 共发现 **7 项 v0.2 候选**，全部 P3。

与 Sprint L 4 项 v0.2 候选（T-P3-FW-001~004）合并后，framework/ v0.2 总共 **11 项**待迭代候选。建议达到 ≥ 15 项或 framework/ 第三个抽象模块完成时批量发版 v0.2。

---

## DGF-M-01 — brief-template.md §3 加 "纯文档抽象 sprint 适配" alt 段

### 描述

`framework/sprint-templates/brief-template.md` §3 默认 5-stage（Smoke / Full / Dry-Run / Apply / Closeout）适合 KE ingest sprint，但对纯文档抽象 sprint（Sprint L / Sprint M 形态）不适用——这两次都不得不在 brief §3 加 "stage 1-4 适配说明"。

### 影响

外部使用者若做"框架抽象类 sprint"会照抄 5-stage 框架，发现 Smoke / Apply 等概念不适用，需要自己摸索如何适配。Sprint L / M 已经 prove 这种 sprint 形态值得有专门的 stage 模板。

### 修改建议

v0.2 brief-template §3 加 alt 段：

```markdown
### §3-alt: 纯文档抽象 sprint 模式（适用于 framework abstraction / methodology drafting / etc）

如本 sprint 不涉及数据 mutation / NER / DB write，使用以下 3-stage 简化版替代默认 5-stage：

#### Stage 0 — Inventory
- 盘点抽象输入源（既有代码 / 文档 / 实战数据）
- 排出"领域无关 / 领域专属 / 混合"边界
- 输出 stage-0-inventory.md

#### Stage 1 — 起草 + dogfood
- 起草 framework 文件
- 用新文件回审 ≥ 1 个既有真实案例（dogfood 验证）
- 输出覆盖度报告

#### Stage 4 — Closeout
- 复用 stage-5-closeout-template
- retro / 衍生债登记 / STATUS / CHANGELOG 更新

Stage 2-3 默认押后到外部反馈触发，不阻塞关档。
```

### 处理时机

Sprint N 启动时如选 Identity Resolver 抽象（混合代码 + 文档 sprint），可参考 Sprint L+M 经验同时修订 brief-template §3-alt。

---

## DGF-M-02 — brief-template.md §0 PE 模型字段加 "N/A (single-actor)" 占位明示

### 描述

brief §0 元信息固定有 "PE 模型" 字段，对 single-actor sprint（Sprint L / M）不适用——只有 Architect 一个 session，PE 角色完全不参与。Sprint L 当时填了 "Sonnet 4.6"（防御性填写但实际不用），Sprint M 改为 "N/A"。

### 影响

外部使用者做 single-actor sprint 时不知道是否必须填 PE 模型字段，可能出现"防御性填写但实际无意义"或者"留空但不知是否合规"的不确定。

### 修改建议

v0.2 brief-template §0 加注解：

```markdown
- **PE 模型**：⚠️FILL `Sonnet 4.X` / `Opus 4.X` / `N/A (single-actor sprint)`
  - 理由：执行类用 Sonnet / 创设类用 Opus / 单 actor sprint 填 N/A
```

### 处理时机

同 DGF-M-01。

---

## DGF-M-03 — brief-template.md §5 角色边界表加 "single-actor sprint 简化" 注脚

### 描述

brief §5 默认 10 角色活跃度表格（Architect / Domain Expert / PE / BE / FE / QA / DevOps / PM / Designer / Analyst）对 single-actor sprint 显得形式主义——Sprint L / M 都是 1 行 🟢 + 9 行 ⚪ 暂停。

### 影响

外部使用者做 single-actor sprint 时填表显得繁琐，可能跳过此段（破坏 brief 完整性）。

### 修改建议

v0.2 brief-template §5 加注脚：

```markdown
> ⚠️ Single-actor sprint 简化：如本 sprint 仅 Architect 主导，可仅列 1 行（Architect 🟢）并加注脚
> "其余 9 角色全 ⚪ 暂停（不参与本 sprint）"，无需逐行填全。
```

### 处理时机

同 DGF-M-01。

---

## DGF-M-04 — domain-expert.md §核心职责加 "Triage / Audit Decision Submission" 单独条目

### 描述

`framework/role-templates/domain-expert.md` §核心职责当前列了"实体歧义仲裁 / 典故鉴定 / 来源可信度评级 / 字典维护 / 黄金集标注 / 抽样审核 / 默认叙述判定"7 项，但**没明示** "Triage UI 决策 / Audit Decision Submission" 作为单独条目。

Sprint K Hist Stage 5 的 1 reject + 1 approve 提交是 Triage UI workflow 实操——这是 Domain Expert 的实际工作，但模板隐含在"实体歧义仲裁"内，外部使用者可能不会立即想到。

### 影响

外部跨领域案例方读 domain-expert.md 时可能漏掉 Triage UI decision 这一关键工作流。

### 修改建议

v0.2 domain-expert.md §核心职责加：

```markdown
- ⚠️FILL **Triage / Audit Decision Submission**（华典实例：Sprint K Triage UI workflow — pending_merge_reviews 上的 approve / reject 决策）
  - 跨 sprint idempotency 行为：相同 (source_id, surface_snapshot, historian_id, decision) 视为单一决策
  - 决策必须含 reason_text + reason_source_type
```

参见 `docs/methodology/05-audit-trail-pattern.md` §3 Triage UI Workflow。

### 处理时机

domain-expert.md v0.2 起草时一并修订；或 Sprint N 启动如顺手即修订。

---

## DGF-M-05 — chief-architect.md §核心职责加 "Stop Rule Arbitration" 单独条目

### 描述

`framework/role-templates/chief-architect.md` §核心职责当前列了 8 项，但**没明示** "Stop Rule Arbitration" 作为单独条目。

Sprint K 期间 Architect 仲裁了 2 次 Stop Rule（PE 175 vs 179 / FE provenanceTier 文案）— 这是 Architect 的实际重要工作之一，但模板隐含在"跨角色冲突仲裁"内。

### 影响

外部使用者读 chief-architect.md 时可能不会立即想到 "Stop Rule 触发时 Architect 必须 inline 仲裁" 这一职责（参见 framework/sprint-templates/stop-rules-catalog.md）。

### 修改建议

v0.2 chief-architect.md §核心职责加：

```markdown
- **Stop Rule Arbitration**（参见 `framework/sprint-templates/stop-rules-catalog.md`）
  - sprint 期间任一 Stop Rule 触发时 Architect 必须 inline 给出结构化决策（R1 接受 / R2 修订 / R3 妥协 / R1+R3 混合 / etc）
  - 决策必须记入仲裁记录（参见 `framework/role-templates/tagged-sessions-protocol.md` §5.2）
```

### 处理时机

同 DGF-M-04。

---

## DGF-M-06 — tagged-sessions-protocol.md §2.3 加注脚区分协调模式

### 描述

`framework/role-templates/tagged-sessions-protocol.md` §2.3 给出"Handoff: [from-role] → [to-role]"标准格式（含 Sprint / Stage / Signal / Artifacts / Next action / Architect ACK 6 字段）。

Sprint K 实际信号传递时**未严格按此格式**——Sprint K 当时是用任务卡评论 + commit message 混合传递。但传递依然成功，因为 Architect 主 session 集中协调。

### 影响

外部使用者可能误以为不严格按 §2.3 格式 = 违反协议；实际"主 Architect 集中协调"模式下 §2.3 格式是 nice-to-have；只有"多 Architect 并行"模式（罕见）才是必需。

### 修改建议

v0.2 tagged-sessions-protocol.md §2.3 加注脚：

```markdown
> ⚠️ 协调模式区别：
> - **主 Architect 集中协调模式**（默认；Sprint K 实证）：Architect 主 session 在场协调，§2.3 格式是 nice-to-have；任务卡评论 + commit message + STATUS 更新已足够
> - **多 Architect 并行模式**（罕见；如多个 sub-team 各有自己的协调者）：§2.3 格式是必需，让跨 Architect handoff 可识别
```

### 处理时机

同 DGF-M-04。

---

## DGF-M-07 — tagged-sessions-protocol.md §4.5 加 handoff_to: 标注模式区分

### 描述

`framework/role-templates/tagged-sessions-protocol.md` §4 收尾模板第 5 步要求"任务卡 handoff_to: [role] 标注 + 触发 §2 handoff 信号"。

Sprint K 期间 BE Stage 2 后的 handoff 用 commit message 替代了任务卡 handoff_to: 字段——并未严格执行 §4.5。但 Sprint K 协作依然成功，因为 Architect 协调在场。

### 影响

同 DGF-M-06：外部使用者可能误以为不严格按 §4.5 = 违反协议。

### 修改建议

v0.2 tagged-sessions-protocol.md §4.5 加注脚：

```markdown
> ⚠️ 协调模式区别：
> - **主 Architect 集中协调模式**：handoff_to: 标注可由 commit message + Architect 协调 + STATUS 更新替代；任务卡 handoff_to: 字段是 nice-to-have
> - **多 Architect 并行模式**：handoff_to: 标注必需，让跨 Architect handoff 可 grep + audit
```

### 处理时机

同 DGF-M-04（与 DGF-M-06 一并修订）。

---

## 押后项（Stage 2-3）

| 押后项 | 触发条件 | 备注 |
|--------|---------|------|
| framework/role-templates/ 外部工程师走通验证 | 1-2 个朋友 / 跨领域案例方主动接触 | 与 Sprint L 押后项类似处理 |
| 跨领域案例方真用 cross-domain-mapping.md 做 instantiation | 跨领域案例方接触（佛经 / 法律 / 医疗 / etc）| 这是 cross-domain-mapping 的真正"出厂测试"，必须等外部时机 |

---

## 与 Sprint L T-P3-FW-001~004 合并视图

Sprint L + Sprint M 累计 **11 项 v0.2 候选**：

| ID | 描述 | Sprint 来源 |
|----|------|-----------|
| T-P3-FW-001 | brief-template §1.2 表格灵活列数 | Sprint L |
| T-P3-FW-002 | retro §4 + stop-rules-catalog §7 cross-reference | Sprint L |
| T-P3-FW-003 | stage-3-review-template §2.0 review 形式选择指南 | Sprint L |
| T-P3-FW-004 | brief-template §8 D-route 段措辞调整 | Sprint L |
| DGF-M-01 | brief-template §3 加纯文档 sprint 模式 alt 段 | Sprint M |
| DGF-M-02 | brief-template §0 PE 模型字段加 N/A 占位 | Sprint M |
| DGF-M-03 | brief-template §5 角色边界表加 single-actor 简化 | Sprint M |
| DGF-M-04 | domain-expert §核心职责加 Triage Decision 条目 | Sprint M |
| DGF-M-05 | chief-architect §核心职责加 Stop Rule Arbitration 条目 | Sprint M |
| DGF-M-06 | tagged-sessions-protocol §2.3 加协调模式区分注脚 | Sprint M |
| DGF-M-07 | tagged-sessions-protocol §4.5 加 handoff_to: 模式区分注脚 | Sprint M |

**v0.2 release 触发条件建议**：

- 累计 ≥ 15 项 → batch release
- 或 framework/ 第三个抽象模块完成（Sprint N identity-resolver 或 Sprint O invariant-scaffold）→ batch release
- 或跨领域案例方主动接触并提供反馈 → 优先处理对应 case 的衍生债 → release v0.2

---

**本债务清单 sprint M 起草于 2026-04-29 / Sprint M Stage 4 closeout**
