# Tagged Sessions Protocol — Multi-Session Coordination for AKE Teams

> Status: **v0.1 (Sprint M Stage 1 first abstraction)**
> Date: 2026-04-29
> License: Apache 2.0 (代码/模板) / CC BY 4.0 (文档)
> Source: 华典智谱 `docs/methodology/01-role-design-pattern.md` §3-§5 + Sprint K (T-P0-028 Triage UI V1) 5 角色 6-stage 实战 + `CLAUDE.md` §8.1

---

## 0. 这是什么

一份**领域无关**的多 session 协调协议，让任何 KE 项目的 Architect 可以并行调度多个 agent / 子 session（PE / BE / FE / Domain Expert / QA / DevOps）协同推进一个 sprint，避免上下文坍缩 + 决策模糊。

**核心信念**：

- LLM context window 是有限的；一个 session 装入"全栈知识工程师"上下文 → 上下文坍缩 + 决策模糊
- 角色拆分不是组织美学，是 LLM 物理约束推出的必然结论
- 跨 session 协作 = 决策权和执行权的明确传递 + 结构化交接信号

详见 `docs/methodology/01-role-design-pattern.md` §1 设计原则。

---

## 1. 协议元素 1 — Tag 命名约定

### 1.1 7 个标准 tag

每个子 session 的 prompt 用 `【{Role Tag}】Sprint X Stage Y` 开头：

| 角色 | 标签 |
|------|------|
| Architect | 主 session（不并行；通常不加 tag）|
| Pipeline Engineer | `【PE】` |
| Backend Engineer | `【BE】` |
| Frontend Engineer | `【FE】` |
| Domain Expert | `【⚠️FILL】`（华典：`【Hist】`；法律：`【Lawyer】`；医疗：`【Doctor】`；佛经：`【Buddhist】`；专利：`【Patent】`）|
| QA Engineer | `【QA】` |
| DevOps Engineer | `【DevOps】` |

### 1.2 Tag 使用规则

- Tag 必须放在 prompt 第一行
- 紧跟 sprint id + stage 编号
- 如：`【BE】Sprint K Stage 2 — migration 0014 起草`
- 一个 session 只承担一个角色（不能身兼多角）
- 一个角色可能在不同 stage 启动多个 session（不冲突）

### 1.3 Architect 的特殊地位

- Architect 是协调者，不并行
- Architect 在主 session 内调度其他 session
- Architect 不并行的原因：跨角色仲裁要求 Architect 必须保持"全局视角"

---

## 2. 协议元素 2 — 5 类跨 Session 关键信号（Handoff Protocol）

不同角色 session 之间通过结构化"信号"交互。Architect 作为协调者负责传递信号。

### 2.1 5 类信号定义

| # | 上游信号 | 下游 unblock | 典型时机 |
|---|---------|-----------|---------|
| 1 | 【BE】SDL ready | 【FE】codegen unblock | BE schema 落地后 FE 可启动 |
| 2 | 【BE】migration NNNN applied | 【PE】backfill apply unblock | DB migration 落地后 PE 可启动数据回填 |
| 3 | 【PE】Stage 2 apply done | 【Architect】给 Domain Expert 发 review prompt | 数据生成后请 Domain Expert review |
| 4 | 【DomainExpert】review report done | 【Architect】给 PE 发 Stage 4 apply 指令 | review 完成后 PE 启动最终 apply |
| 5 | 【Architect】Stop Rule 裁决 | 发回原触发 session | Stop Rule 触发后 Architect 给出结构化决策返回执行 session |

### 2.2 信号实战案例（Sprint K T-P0-028 实证）

| # | 信号 | Sprint K 实战时机 |
|---|------|------------------|
| 1 | 【BE】SDL ready | Stage 2 BE migration 0014 + GraphQL schema 完成 → Stage 3 FE 启动 |
| 2 | 【BE】migration 0014 applied | migration 0014 落地 → PE backfill 启动 |
| 3 | 【PE】Stage 2 apply done | PE 175 TD + 18 PMR backfill 完成 → Architect 给 Hist E2E |
| 4 | 【Hist】review report done | Hist 1 reject + 1 approve → Architect 启动 Stage 4 集成 smoke |
| 5 | 【Architect】Stop Rule 裁决 | PE 175 vs 179 / FE provenanceTier 文案 两次裁决发回原 session |

→ 5 类信号在 Sprint K 全部触发并运行，协议设计被实战验证。

### 2.3 信号格式约定

跨 session 信号通过结构化文本传递（不是口头）：

```markdown
## Handoff: [from-role] → [to-role]

- **Sprint**: ⚠️FILL (e.g., K)
- **Stage**: ⚠️FILL (e.g., Stage 2 done)
- **Signal**: ⚠️FILL (e.g., "BE migration 0014 applied")
- **Artifacts**:
  - ⚠️FILL (commit / file path / DB anchor)
- **Next action for receiver**:
  - ⚠️FILL (e.g., "PE 启动 backfill apply, target 18 PMR rows")
- **Architect ACK**: ⚠️FILL (yes/no/pending)
```

> ⚠️ **协调模式区别**（v0.1.1 注脚 / Sprint M dogfood 发现）：
> - **主 Architect 集中协调模式**（默认 / Sprint K 实证）：Architect 主 session 在场协调，本 §2.3 格式是 nice-to-have；任务卡评论 + commit message + STATUS 更新已足够
> - **多 Architect 并行模式**（罕见 / 多个 sub-team 各有自己的协调者）：本 §2.3 格式是必需，让跨 Architect handoff 可识别 + audit
>

---

## 3. 协议元素 3 — Session 启动模板（领域无关 6 步）

每个角色 session 启动时必执行：

```
1. Read CLAUDE.md（项目入口）
2. Read docs/STATUS.md（当前状态）
3. Read docs/CHANGELOG.md 最近 5 条
4. Read .claude/agents/{role}.md（角色边界 — 即本系列模板对应文件）
5. Read 任务卡 docs/tasks/T-NNN-*.md（如有）+ 关联 ADR
6. 输出 TodoList，等 Architect / 用户确认后再动手
```

**为什么强制 6 步**：

- 步骤 1-3：让 session 知道项目当前位置
- 步骤 4：让 session 知道自己的边界（决策权 / 禁区）
- 步骤 5：让 session 知道当前任务
- 步骤 6：让 Architect 有机会在 session 动手前修正方向

**反模式**：跳过任一步直接动手 → 上下文不足 / 越位 / 重复劳动。

---

## 4. 协议元素 4 — Session 收尾模板（领域无关 5 步）

每个角色 session 结束时必执行：

```
1. 生成本任务的交付物摘要
2. 更新 docs/STATUS.md
3. 追加 docs/CHANGELOG.md 一条
4. 若产生新决策（ADR / RFC / contract 级变更）→ 落盘 + 关联引用
5. 若影响其他角色 → 任务卡 handoff_to: [role] 标注 + 触发 §2 handoff 信号
```

> ⚠️ **协调模式区别**（v0.1.1 注脚 / Sprint M dogfood 发现）：
> - **主 Architect 集中协调模式**（默认）：第 5 步的 `handoff_to: [role]` 标注可由 commit message + Architect 协调 + STATUS 更新替代；任务卡 `handoff_to:` 字段是 nice-to-have
> - **多 Architect 并行模式**（罕见）：第 5 步的 `handoff_to: [role]` 标注必需，让跨 Architect handoff 可 grep + audit
>

**为什么强制 5 步**：

- 步骤 1-3：让下一个 session（任意角色）能从 STATUS / CHANGELOG 接续
- 步骤 4：让决策不丢失（口头决策 = 没决策）
- 步骤 5：让协作不静默（口头交接 = 没交接）

**反模式**：

- ❌ Session 结束不更新 STATUS → 下一 session 不知道项目进度
- ❌ 重大决策只在 commit message 提到 → 后续没法 grep / audit
- ❌ "我已经口头跟 BE 说过了" → 没有 audit trail

---

## 5. 协议元素 5 — 冲突升级 3 级机制

### 5.1 三级升级

```
Level 1: 任务卡评论区互相协商
    ↓ 仍冲突
Level 2: 升级到 Chief Architect 仲裁（记入任务卡）
    ↓ 仲裁涉及架构宪法
Level 3: 升级到用户决策 + 修宪流程（docs/00_constitution.md）
```

### 5.2 仲裁记录格式

任何 Level 2 仲裁必须记录：

```markdown
## 仲裁记录
- 日期：YYYY-MM-DD
- 冲突角色：{A} vs {B}
- 冲突点：{一句话描述}
- A 立场：...
- B 立场：...
- 仲裁人：Architect
- 仲裁结论：...
- 仲裁依据：（引用 ADR / 项目宪法 / 历史案例）
```

如仲裁触发新 ADR，记入 `docs/decisions/`。

### 5.3 仲裁案例（Sprint K T-P0-028 实证）

Sprint K 期间的 3 次仲裁：

| # | 仲裁主题 | 角色 | 仲裁结果 | 仲裁依据 |
|---|---------|------|---------|---------|
| 1 | PE 175 vs 179 backfill stop rule | PE → Architect | R1+R3 混合（接受 175 + 透明度文档）| ADR-014 idempotency 设计意图 |
| 2 | provenanceTier 文案 "未验证" vs "待补来源" | FE → Architect | Option A（统一"未验证"）| ADR-027 enum 一致性 |
| 3 | GraphQL TriageItem interface vs union | BE/FE → Architect | interface（Traceable + lazy person load）| 实现复杂度 + 性能 |

每次仲裁都记入对应任务卡 + 衍生债清单。

---

## 6. 协议元素 6 — 模型选型策略

### 6.1 推荐模式：主 Opus + 子 Sonnet

依据 Sprint K 实证（参见 `docs/sprint-logs/sprint-k/stage-6-closeout-2026-04-29.md` §6.3）：

- **主 Architect session**：Opus（战略 / ADR / 仲裁 / 跨角色协调）
- **子 PE / BE / FE / Domain Expert / QA / DevOps sessions**：Sonnet（执行 / 实现 / 报告 / E2E）

**理由**：

- ✅ Sonnet 已能处理 R1/R2/R3 Stop Rule 选项推荐 → Stop Rule 报告质量充分
- ✅ Sonnet 子 session 在 ingest / migration / E2E 类执行任务上充分
- ✅ Architect 主 session 战略 / ADR / 仲裁 复杂决策由 Opus 处理 → 全局视角清晰

### 6.2 例外情况

切换到 Opus 子 session 的触发条件：

- "创设"性质任务（框架抽象 / ADR 起草 / 跨领域 mapping 设计）→ 整 sprint 用 Opus（参见 Sprint L / Sprint M 全程 Opus 4.7 实证）
- 子 session 抽象深度不足（如只列字段不解释 trade-offs）→ 切 Opus

---

## 7. 协议反模式（Don'ts）

### 7.1 反模式 1：万能角色

❌ 让一个 session 同时扮演 Architect + Backend + Frontend + QA。理由：上下文坍缩 + 决策模糊。

✅ 拆成 4 个 tagged session 协作。

### 7.2 反模式 2：模糊决策权

❌ "PE 和 Domain Expert 一起决定实体归类" → 决策权不明，扯皮

✅ "实体归类由 Domain Expert 决定，PE 执行" 或反之，但不能混

### 7.3 反模式 3：跳级协作

❌ Frontend Engineer 直接改 schema（理由"我看到一个 typo"）

✅ Frontend Engineer issue 给 Backend Engineer + 等 BE 处理

### 7.4 反模式 4：口头交接

❌ "我已经口头跟 BE 说过了" → 没有 audit trail

✅ 一切交接通过任务卡评论 / commit message / PR description / ADR / Sprint brief / handoff signal

### 7.5 反模式 5：跳过升级机制

❌ 两个角色绕过 Architect 私下达成共识然后改代码

✅ 任何跨角色决策必须公开 + 记入任务卡 / ADR

---

## 8. 附录 — Sprint K 实证案例（完整数据）

### 8.1 Sprint K 概况

- **主题**：T-P0-028 Pending Triage UI V1
- **完成日期**：2026-04-29
- **协同角色数**：5（PE / BE / FE / Hist / Architect）
- **Stage 数**：6（Inventory / Design / BE schema + PE backfill / FE 实现 / 集成 smoke / Hist E2E + Closeout）
- **总耗时**：~1 工作日（多 session 并行 vs 单 session 估约 3-5 天）

### 8.2 协议要素首次完整使用

- ✅ §1 Tag 命名约定：5 个 tag（【Architect】【PE】【BE】【FE】【Hist】）首次完整使用
- ✅ §2 5 类跨 session 信号：全部 5 类触发并运行
- ✅ §3 启动模板：5 个角色 session 全部按 6 步启动
- ✅ §4 收尾模板：每个 stage 结束后 STATUS / CHANGELOG / handoff 全部触发
- ✅ §5 冲突升级：触发 3 次 Level 2 仲裁（见 §5.3）

### 8.3 模型选型实证

- 主 Architect session：Opus 4.7
- 子 PE / BE / FE / Hist sessions：Sonnet 4.6
- 结论：主 Opus + 子 Sonnet 模式有效

### 8.4 收益总结

- 总耗时缩短 3-5x（vs 单 session 估约 3-5 天）
- 每个 session 上下文窗口压力都在合理范围
- 关键决策（Stop Rule、ADR-027 sign-off、provenanceTier 文案裁决）都通过 Architect 集中仲裁
- 0 重复劳动 / 0 角色越位 / 0 口头交接

详见 `docs/sprint-logs/sprint-k/stage-6-closeout-2026-04-29.md`。

---

## 9. 反馈与贡献

本协议从华典智谱 Sprint K 实证抽出，是 v0.1 状态。预期会随更多案例（包括跨领域）反馈而迭代。

如果你用本协议做了你的项目，欢迎：

- **报告使用经验**（GitHub Issue 标 `tagged-sessions-feedback`）
- **指出遗漏 / 不清楚的地方**（GitHub Issue 标 `tagged-sessions-gap`）
- **贡献跨领域 instantiation 范例**（GitHub PR）

详见华典智谱主项目 [CONTRIBUTING.md](https://github.com/lizhuojunx86/huadian/blob/main/CONTRIBUTING.md)。

---

## 10. 版本信息

| Version | Date | Source | Change |
|---------|------|--------|--------|
| v0.1 | 2026-04-29 | Sprint M Stage 1 (first abstraction) | 初版抽出（含 Sprint K 实证案例段）|

---

> 本协议是 AKE 框架 Layer 1 的核心治理资产之一，与 `framework/role-templates/` 10 份角色模板配合使用。
> 当前完整 framework 目录见华典智谱主项目 https://github.com/lizhuojunx86/huadian/tree/main/framework
