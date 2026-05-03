# Stop Rules Catalog — 5 类领域无关 Stop Rule 模板

> Status: v0.1
> Source: 华典智谱 Sprint A-K 11 个 sprint 的 Stop Rule 实证
> 配套：`framework/sprint-templates/brief-template.md` §4

---

## 0. 什么是 Stop Rule

> Stop Rule = Sprint 任何时点遇到的**不可妥协的中止条件**。触发 → 立即暂停 sprint → 升级架构师决策（继续 / rollback / scope 缩减 / 等）。

不是 review 反馈，是**硬中断**。

---

## 1. 设计原则（重申自 docs/methodology/02-sprint-governance-pattern.md §4.2）

1. **可量化**：每条 rule 必须有具体阈值（"成本 > $X" / "新实体 > Y 个"），不允许"差不多了"
2. **预先声明**：Sprint Brief §4 显式列出，不允许执行中"补"
3. **覆盖五类风险**（本文件 §2-§6）
4. **可触发的具体路径**：每条 rule 标注"触发时该做什么"

---

## 2. 类 1：成本类（Cost）

### 2.1 模板

```markdown
- **Stage X cost > $⚠️N → Stop**
  - 触发时：暂停 LLM 调用 / 评估根因（prompt / batching / 模型选型）
  - 决策路径：A. 调参数继续 / B. 切更便宜 model / C. abort sprint
```

### 2.2 实证示例（华典智谱）

- Sprint J: "Stage 2 cost > $1.80 → Stop"（实际 $0.79，未触发）
- Sprint G: "项羽本纪 cost > $0.80 → Stop"（实际 $0.60，未触发）

### 2.3 跨领域阈值参考

- 古籍：~$1-2 / sprint（NER prompt 不太长）
- 法律：可能 $10+ / sprint（contract clauses 长）
- 医疗：视监管要求决定（PHI 处理可能更严）

---

## 3. 类 2：数据正确性类（Data Correctness）

### 3.1 模板

```markdown
- **任一 V invariant 在新数据 ≠ 0 → 立即 Stop**
  - 触发时：不允许"先 apply 再修"
  - 决策路径：A. 修因后 retry / B. rollback + abort

- **黄金集任一已有章节回归 → Stop**
  - 触发时：不允许"已有数据回归换新数据上线"
  - 决策路径：A. 修因 / B. NER prompt 调整 / C. abort
```

### 3.2 实证示例（华典智谱）

- Sprint F: "V1 / V9 在新数据 ≠ 0 → 立即 Stop"（实际 V1=0 / V9=0，未触发）
- Sprint J: "NER v1-r5 黄金集任一已有章节回归 → Stop"（未触发）

### 3.3 跨领域调整

- 古籍：V1-V11 invariants（22 个测试）
- 法律：可能定义自己的 V1-V8（合同完整性 / 当事方一致性 / 等）
- 医疗：HIPAA / 临床指南合规相关 invariants

---

## 4. 类 3：输出量类（Output Volume）

### 4.1 模板

```markdown
- **Stage 2 NER new entities > ⚠️N → Stop pre-Stage 3 batch review**
  - 触发时：警告，不立即 abort；评估是 NER over-extract 还是数据本身丰富
  - 决策路径：A. 接受继续 / B. NER prompt 调整 / C. 数据 sub-batch 处理

- **R1 跨国 FP 治理率 < ⚠️N% → Stop**
  - 触发时：评估 GUARD_CHAINS 设计
  - 决策路径：A. 加新 guard / B. 调阈值 / C. 接受 + 记衍生债
```

### 4.2 实证示例（华典智谱）

- Sprint J: "Stage 2 NER new persons > 120 → Stop"（实际 +85，未触发）
- Sprint J: "R1 FP 治理率 < 70% → Stop"（实际 100%，反而是庆祝场景）

### 4.3 跨领域调整

- 数量阈值要 calibrate 到本领域的"正常 sprint 输出量"
- 治理率阈值通常 ≥70% 是接受底线

---

## 5. 类 4：治理类（Governance）

### 5.1 模板

```markdown
- **Stage 3 Domain Expert review reject 率 > ⚠️N% → Stop**
  - 触发时：意味着 R1-R6 自动 merge 准确率太低
  - 决策路径：A. GUARD_CHAINS 加强 / B. NER prompt 调整 / C. 接受 + 记 retro

- **Stage 3 review 工时 > ⚠️N 小时 → Stop pre-Stage 4 apply**
  - 触发时：意味着 review 负担过重，UX 需要改进
  - 决策路径：A. 押后部分 candidates 到下 sprint / B. 触发 V2 UX 改进
```

### 5.2 实证示例（华典智谱）

- Sprint G: "review reject 率 > 80% → Stop"（实际 62%，未触发但记衍生债 → Sprint H state_prefix_guard）

### 5.3 跨领域调整

- reject 率高 = 框架 + domain knowledge 还需打磨；不要硬继续

---

## 6. 类 5：跨 Sprint 一致性类（Cross-Sprint Consistency）

### 6.1 模板

```markdown
- **黄金集任一已有章节回归 → Stop**（同 §3 数据正确性，但聚焦"跨 sprint 不退步"）

- **Stage X cost vs 历史最近 sprint 偏离 > 2x → Stop**
  - 触发时：评估是数据本身复杂度变化还是 pipeline regression
  - 决策路径：A. 接受 + 记衍生债 / B. 修 pipeline / C. 重新估算 brief

- **跨 sprint 同 surface 簇 review reject 率与历史不一致 (> ⚠️N%) → Stop**
  - 触发时：可能 NER prompt 漂移 / domain knowledge 演化
  - 决策路径：A. 接受新 baseline / B. 一致性修订 / C. 触发 ADR 决策
```

### 6.2 实证示例（华典智谱）

- Sprint K: PE 175 vs 179 backfill stop rule 实证（idempotency 跨 sprint 去重，已设计意图）
- Sprint J: 跨秦汉 R1 FP 治理率 ≥ 90% Sprint G→I 目标（达成 100%）

---

## 7. Stop Rule 触发处理协议（标准）

任何 Stop Rule 触发，统一按本协议处理：

```
1. 立即停止当前操作
   ├─ 不要 continue「再跑一个 stage 看看」
   └─ 不要 rollback（保留现场便于诊断）

2. 报告架构师
   ├─ Stop Rule 编号 + 触发数字
   ├─ 当前 stage 状态
   └─ 已完成 / 未完成的子任务

3. 等架构师裁决
   ├─ 选项 A：继续（接受 + 记衍生债）
   ├─ 选项 B：修因后 retry
   ├─ 选项 C：rollback（如已 apply）
   └─ 选项 D：abort sprint（重立 brief）

4. 架构师决策记录
   ├─ 写入 sprint-logs/{id}/stop-rule-trigger-X.md
   └─ retro §4 引用本决策（retro-template.md §4 表格的"路径"列填本协议第 3 步选项 A/B/C/D）
```

> **配套引用**：`framework/sprint-templates/retro-template.md` §4 的"Rule / 类别 / 触发原因 / 裁决 / trigger 文件路径"5 列表头与本协议一一对应。Retro 起草时一定要回填本协议第 3 步选定的 A/B/C/D 选项 + 触发文件链接，便于跨 sprint 检索同类触发模式。

---

## 8. 反模式

### 8.1 反模式：模糊阈值

❌ "Stage 2 cost 不要太高 → Stop"

✅ "Stage 2 cost > $1.80 → Stop"

### 8.2 反模式：执行中"补" Stop Rule

❌ Sprint 进行中发现"应该有这个 Stop Rule"，临时加进去

✅ 只能在下一 sprint brief 中正式纳入

### 8.3 反模式："软" Stop Rule

❌ "如果 cost 过高，请考虑停止"

✅ "如果 cost > $X → 必须立即停止"

### 8.4 反模式：违反但不报告

❌ "我看 cost $1.95 也不算太多，就继续了"

✅ Stop Rule 触发必须报告 + 等裁决

---

## 9. Stop Rule 数量建议

每个 Sprint Brief §4 通常列 5-8 条 Stop Rule。覆盖：

- ≥ 1 条成本类（§2）
- ≥ 1 条数据正确性类（§3）— 通常 V invariant
- ≥ 1 条输出量类（§4）
- ≥ 1 条治理类（§5）— 仅当 sprint 涉及 review 时
- ≥ 1 条跨 sprint 一致性类（§6）

不要太多（>10 条会 mental overload）；不要太少（<5 条覆盖不全）。

---

**本 catalog 是 framework v0.1 的一部分。后续案例反馈会补全 6th, 7th 类。**
