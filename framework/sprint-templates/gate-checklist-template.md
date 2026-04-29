# Gate Checklist Template

> 复制本文件作为每个 sprint stage 之间的 gate 检查记录。
> Source: `docs/methodology/02-sprint-governance-pattern.md` §3 Gate 协议

---

## 0. 用法

每个 stage 完成时，对应的 gate 必须显式 check。所有项目通过 → 解锁下一 stage。任何项目不通过 → sprint 暂停 + 升级架构师裁决。

---

## 1. Stage 0 → Stage 1 (Gate 0a — 启动 Gate)

> 适用：从 Stage 0 Prep 到 Stage 1 Smoke

- [ ] §0 Prep checklist 全部完成（fixture / adapter / pre-flight baseline / 等）
- [ ] Pre-flight invariants 全绿（基线对照）
- [ ] commit C1 已提交
- [ ] 给 Stage 1 的输入文件 / 配置就绪
- [ ] 架构师 ACK
- [ ] 多角色 sprint：所有角色 inventory 已就位

---

## 2. Stage 1 → Stage 2 (Gate 0 — Smoke Gate)

> 适用：从 Stage 1 Smoke 到 Stage 2 Full

- [ ] LLM cost ≤ smoke 预算（通常 ≤ $0.10 / sprint）
- [ ] V1-V11 invariants 全绿
- [ ] 输出格式符合 schema（zod / pydantic 校验通过）
- [ ] 没有 silent failure（log 中无 ERROR）
- [ ] DB 数据可见（SQL 直查吻合预期）
- [ ] 架构师 / 主导角色 ACK

---

## 3. Stage 2 → Stage 3 (Gate 1 — Full Output Gate)

> 适用：从 Stage 2 Full 到 Stage 3 Review

- [ ] 总成本 ≤ brief 预算的 1.5x（超 1.2x 提请架构师审）
- [ ] 新增实体数 ≤ brief 预期的 1.2x（超提请审）
- [ ] V1-V11 invariants 全绿（不允许任何回归）
- [ ] 黄金集回归全绿（如适用）
- [ ] 没有 silent failure
- [ ] commits 已提交（含 apply 脚本输出 log）
- [ ] dry-run input file 就绪（候选清单完整）

---

## 4. Stage 3 → Stage 4 (Gate 2 — Review Gate)

> 适用：从 Stage 3 Dry-Run + Review 到 Stage 4 Apply

- [ ] dry-run 报告完整（所有 candidates 列出）
- [ ] Domain Expert review 完成（每个 candidate 有 decision + reason）
- [ ] Architect ACK 所有 reject 决策（reason 充分）
- [ ] Stage 4 apply input file 就绪：
  - approve list（→ 真 mutation）
  - reject list（→ 写 audit row 但不 mutation）
  - defer list（→ 留 pending_review）
- [ ] pre-apply pg_dump 备份就位

---

## 5. Stage 4 → Stage 5 (Gate 3 — Apply Gate)

> 适用：从 Stage 4 Apply 到 Stage 5 Closeout

- [ ] DB 写入数 vs 决策数误差 ≤ 5%（超出触发 Stop Rule）
- [ ] V1-V11 invariants 全绿（任一回归 → rollback）
- [ ] 黄金集回归全绿
- [ ] audit log 完整（merge_log / triage_decisions / etc）
- [ ] errors = 0
- [ ] commit 已提交
- [ ] 实际写入数字 + skipped + errors 已记录

---

## 6. Stage 5 → Sprint 关档 (Gate 4 — Closeout Gate)

> 适用：从 Stage 5 Closeout 到 Sprint 关档

- [ ] 任务卡 → done
- [ ] STATUS.md 更新（数据基线 / 当前阶段）
- [ ] CHANGELOG.md 追加
- [ ] retro 起草（含 D-route 资产盘点段，如 D-route 项目）
- [ ] 衍生债登记（如有）
- [ ] ADR 更新（如有架构决策变更）
- [ ] commit 已提交

---

## 7. Gate 不通过的处理

### 7.1 标准协议

任何 gate 项不通过 = Sprint **暂停**：

1. 标识不通过的具体原因（哪一项 / 数字 / log）
2. 评估是修复（继续）还是 abort（rollback）
3. 决策记入 sprint-logs/{id}/gate-{N}-failure-YYYY-MM-DD.md
4. 升级架构师仲裁

### 7.2 架构师裁决路径

| 裁决 | 含义 |
|------|------|
| **Continue** | 修小问题后继续，记衍生债 |
| **Retry** | 当前 stage 重做（如 Stage 2 cost 超预算 → 调 prompt 重跑）|
| **Rollback** | 回到上一 stage 起点（如 Stage 4 apply 失败 → pg_restore）|
| **Abort** | sprint 终止，重立 brief（极少触发）|

### 7.3 不允许的处理

❌ "差不多就过" — gate 是硬约束
❌ "下一 sprint 再修" — 当前 sprint 不能跳过 gate
❌ "我看着应该没问题" — 必须有 invariant test / SQL 数字依据

---

## 8. Gate 检查频率

- 每个 stage 结束时：必查
- 每天工作启动时：扫一眼当前 stage 处于哪个 gate（恢复上下文）
- 跨多 session 协作时：每个角色完成自己的部分都要 push gate check

---

**本 checklist 是 framework v0.1 的一部分。**
