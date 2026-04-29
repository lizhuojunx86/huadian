# Sprint ⚠️FILL-ID Brief — ⚠️FILL-TOPIC

> 复制本文件到 `docs/sprint-logs/sprint-{id}/stage-0-brief-YYYY-MM-DD.md` 后填写。
> 删除本注释块。占位符用 `⚠️FILL-XXX` 标识。

## 0. 元信息

- **架构师**：⚠️FILL-NAME / 角色
- **Brief 日期**：YYYY-MM-DD
- **Sprint 形态**：⚠️FILL `单 track` / `多 track 并行` （多 track 需说明各 track 主题）
- **预估工时**：⚠️FILL `N 天 / 周`
- **PE 模型**：⚠️FILL `Sonnet 4.X` / `Opus 4.X` / `N/A (single-actor sprint)`（理由：执行类用 Sonnet / 创设类用 Opus / 单 actor sprint 填 N/A）
- **Architect 模型**：⚠️FILL `Opus 4.X`（架构师 session 通常用 Opus）
- **触发事件**：⚠️FILL `前置 sprint 的什么发现 / 衍生债驱动 / 战略转型 / etc`

---

## 1. 背景

### 1.1 前置上下文
⚠️FILL：前 N 个 sprint 已完成什么；本 sprint 在大局中的位置；战略锚点引用（如 ADR-NNN）

### 1.2 与既有 sprint 的差异
⚠️FILL（表格）：当前 sprint vs 历史最近 sprint 的关键维度对比

| 维度 | 上一 sprint | 本 sprint |
|------|----------|---------|
| ⚠️FILL | ... | ... |
| ⚠️FILL | ... | ... |

### 1.3 不做的事（Negative Scope）
⚠️FILL：本 sprint 显式不做的事（防止 scope creep）

- ❌ ⚠️FILL
- ❌ ⚠️FILL

---

## 2. 目标范围

### 2.1 Track 1 — ⚠️FILL Track 主题（如单 track 此节即唯一目标）

**目标**：⚠️FILL 一句话目标

**具体动作**：
- ⚠️FILL
- ⚠️FILL

**完成判据**：
- ⚠️FILL（可量化的完成标准）

### 2.2 Track 2 — ⚠️FILL Track 主题（仅多 track 情况）

（同上结构）

---

## 3. Stages（5-stage 模板）

### Stage 0 — 前置准备 / Inventory

⚠️FILL：本 sprint 启动前需要的准备工作（fixture / adapter / inventory / etc）

输出：⚠️FILL `docs/sprint-logs/sprint-{id}/stage-0-{topic}.md`

### Stage 1 — Smoke

**子集大小**：⚠️FILL `5 段 / 1 章节 / 10 行 / etc`

**Gate 0**：
- ⚠️FILL LLM cost 不超过 $⚠️N
- ⚠️FILL invariants 全绿
- ⚠️FILL 输出格式符合 schema

### Stage 2 — Full

**Gate 1**：
- ⚠️FILL 总成本 ≤ $⚠️N（brief 预算的 1.5x 内）
- ⚠️FILL 新增实体数 ≤ ⚠️N（brief 预期的 1.2x 内）
- ⚠️FILL 没有任何 invariant 回归

### Stage 3 — Dry-Run + Review

⚠️FILL：本 sprint 的 review 类型（merge candidates / split candidates / mapping verification / etc）

**Gate 2**：
- ⚠️FILL Domain Expert 完成 review
- ⚠️FILL Architect ACK 决策
- ⚠️FILL apply input file 就绪

### Stage 4 — Apply

**关键约束**：
- ⚠️FILL idempotency unique key
- pre-apply pg_dump anchor（必备）
- rollback 策略：⚠️FILL

**Gate 3**：
- ⚠️FILL DB 写入数与决策数一致（误差 ≤ 5%）
- ⚠️FILL invariants 仍全绿
- ⚠️FILL audit log 完整

### Stage 5 — Closeout

输出：
- 任务卡 → done
- STATUS / CHANGELOG 更新
- retro 文档（含 D-route 资产盘点段）
- 衍生债登记

---

## 4. Stop Rules

> 详见 `framework/sprint-templates/stop-rules-catalog.md` 5 类模板。
> 至少列 5 条具体可触发的中止条件，每条含具体阈值。

1. ⚠️FILL `成本类`：例如 "Stage 2 cost > $X → Stop"
2. ⚠️FILL `数据正确性类`：例如 "任一 V invariant 回归 → Stop"
3. ⚠️FILL `输出量类`：例如 "新实体 > X → Stop"
4. ⚠️FILL `治理类`：例如 "review reject 率 > X% → Stop"
5. ⚠️FILL `跨 sprint 一致性类`：例如 "黄金集回归任一回归 → Stop"

---

## 5. 角色边界

| 角色 | 活跃度 | 主要职责 |
|------|-------|---------|
| 首席架构师 | 🟢/🟡/⚪ | ⚠️FILL |
| Domain Expert（⚠️FILL 角色名）| 🟢/🟡/⚪ | ⚠️FILL |
| 管线工程师 | 🟢/🟡/⚪ | ⚠️FILL |
| 后端 / 前端 / QA / DevOps / PM / Designer / Analyst | 🟢/🟡/⚪ | ⚠️FILL |

🟢 高 / 🟡 维护 / ⚪ 暂停。

> ⚠️ **Single-actor sprint 简化**（适用于纯文档抽象 / framework abstraction 类 sprint）：
> 如本 sprint 仅 Architect 主导，可仅列 1 行（Architect 🟢）并加注脚 "其余 9 角色全 ⚪ 暂停（不参与本 sprint）"，无需逐行填全。
> 实证：Sprint L / Sprint M 都是 single-actor sprint，整表 1 行 + 注脚足以。

---

## 6. 收口判定（Definition of Done）

至少列 5 条"sprint 算完成"的明确标准：

- ✅ ⚠️FILL
- ✅ ⚠️FILL
- ✅ ⚠️FILL
- ✅ ⚠️FILL
- ✅ ⚠️FILL

---

## 7. 节奏建议

⚠️FILL：哪些 stage 可在同一 session，哪些必须分 session；预估每 stage 工时。

---

## 8. D-route 资产沉淀预期（Layer 1+2 项目专用，非 D-route 项目可删本节）

本 sprint 预期沉淀以下框架抽象资产（任选 ≥ 1 项，违反 C-22 不得启动）：

- [ ] 新增 docs/methodology/*.md 草案
- [ ] 已有 methodology 草案的 v0.x → v0.(x+1) 迭代
- [ ] 框架代码 spike（具体路径）
- [ ] 案例素材积累（retro 中标注 ≥1 个可抽象 pattern）
- [ ] 跨领域 mapping 表更新

---

## 9. 决策签字

- 首席架构师：__ACK __日期 (待签)__
- 信号：本 brief 接受 + 用户 ACK 后 → Sprint Stage 0 启动

---

**本 brief 模板版本**：framework/sprint-templates v0.1
