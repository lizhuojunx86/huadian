# Sprint L 衍生债 — framework/sprint-templates/ v0.1 → v0.2 迭代清单

> Status: registered
> 来源 sprint: Sprint L Stage 1 dogfood (2026-04-29)
> 优先级: 全部 P3（不主动启动；遇到机会 batch 处理）
> 触发条件: Sprint M+ 启动时如顺手即处理；或外部反馈批量驱动

---

## T-P3-FW-001 — brief-template.md §1.2 表格灵活列数支持

### 描述

`framework/sprint-templates/brief-template.md` §1.2 "与既有 sprint 的差异" 表格当前固定 2 列（"上一 sprint" / "本 sprint"）。dogfood 发现 Sprint K brief 实际写了 3-4 列对比（`秦γ` / `项羽δ` / `高祖ε` / `本 sprint`）。

### 影响

跨多 sprint 对比时模板限制了表格列数，外部工程师可能照抄 2 列限制，错过有价值的多对比维度。

### 修改建议

```markdown
### 1.2 与既有 sprint 的差异

⚠️FILL（表格 — 列数视需要灵活，建议 ≥2 列）：当前 sprint vs 历史最近 N 个 sprint 的关键维度对比

| 维度 | ⚠️N-2 sprint | ⚠️上一 sprint | 本 sprint |
|------|---------|----------|---------|
| ⚠️FILL | ... | ... | ... |
```

### 处理时机

Sprint M brief 起草时如发现需要 3+ 列对比 → 顺手修订模板。

---

## T-P3-FW-002 — retro §4 + stop-rules-catalog §7 cross-reference 紧密化

### 描述

`framework/sprint-templates/retro-template.md` §4 "Stop Rule 触发回顾" 与 `framework/sprint-templates/stop-rules-catalog.md` §7 "触发处理协议" 描述了同一概念的两个面，但当前没有显式 cross-reference。dogfood 发现 Sprint K retro 实际有 §4 段，但 catalog §7 没指向 retro template。

### 影响

外部工程师阅读 catalog 时不知道"触发后该写到哪里"。

### 修改建议

- catalog §7 末尾加："详见 `retro-template.md` §4 模板"
- retro §4 顶部加："本节模板对应 Stop Rule 触发处理协议（参见 `stop-rules-catalog.md` §7）"

### 处理时机

Sprint M / N 任一次 framework 修订时顺手做。

---

## T-P3-FW-003 — stage-3-review-template.md §2.0 review 形式选择指南

### 描述

`framework/sprint-templates/stage-templates/stage-3-review-template.md` §2.1 提到了 2 种 review 形式（Triage UI / Markdown Review），但**没说何时该用哪种**。新项目可能不知道选哪个。

### 影响

外部工程师陷入选择困难 / 默认按"看起来更高级的"选 Triage UI，但其实早期项目用 Markdown 更合适（low setup cost）。

### 修改建议

在 §2 顶部加 §2.0：

```markdown
### 2.0 选择 review 形式

依据项目阶段：

| 项目阶段 | 推荐 review 形式 |
|---------|----------------|
| 早期 / V1 | Markdown review（low setup cost）|
| 成熟 / V2 / 跨 sprint 决策回查需求 | Triage UI（参见 docs/methodology/05-audit-trail-pattern.md）|
| 单人项目 | Markdown review（不需要 audit trail UI）|
| 多人 / 多 historian | Triage UI（必须有 audit + 一致性 hint）|

选定后写入 brief §3 Stage 3 段。
```

### 处理时机

任一外部工程师反馈时优先处理；否则 Sprint N+ 顺手。

---

## T-P3-FW-004 — brief-template.md §8 D-route 段措辞调整

### 描述

`framework/sprint-templates/brief-template.md` §8 "D-route 资产沉淀预期" 当前注明"非 D-route 项目可删本节"，但措辞默认假设走 D-route。跨领域案例方可能不走 D-route（仅借鉴框架），不应该被强制要求"必须沉淀框架抽象资产"。

### 影响

跨领域工程师可能误以为本节是必填，徒增负担。

### 修改建议

§8 改成：

```markdown
## 8. （可选）D-route 资产沉淀预期

> 本节仅适用于走 D-route 路线的项目（即同时建框架 + 案例的项目，如华典智谱）。
> 跨领域案例方仅借鉴本套 sprint 治理模板时，**可直接删除本节**，不必填写。

---

如本项目走 D-route 路线，本 sprint 预期沉淀以下框架抽象资产（任选 ≥ 1 项，违反 C-22 不得启动）：

- [ ] ...
```

### 处理时机

任一非 D-route 案例方启动时优先处理。

---

## 后续 v0.2 集中迭代触发条件

任一条件满足 → 集中处理 4 项 v0.2 迭代（约 1-2 小时工作量）：

1. 外部工程师反馈 ≥ 2 项以上述清单
2. Sprint M / N / O 任一启动时发现至少 2 项需要修
3. framework v0.1 → v0.2 公开 release 准备时（如有此计划）

---

## 不主动处理的理由

v0.1 状态对当前 dogfood + 内部使用充分。修订是"锦上添花"，不是"必要修复"。提早修可能：

- 引入新 bug（多次小修不如一次大修）
- 浪费精力在还没真正被测试出问题的方向
- 违反 D-route "慢而深" 节奏（应等真实使用反馈，而非凭空优化）

→ **耐心等真实反馈再批量修订**。

---

**本文件起草于 2026-04-29 / Sprint L Stage 4 衍生债登记**
