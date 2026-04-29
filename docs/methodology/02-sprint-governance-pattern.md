# Sprint Governance Pattern — Sprint / Stage / Gate / Stop Rule for Agentic KE

> Status: **Draft v0.1**
> Date: 2026-04-29
> Owner: 首席架构师
> Source: 华典智谱 Sprint A-K 真实工作流 + `docs/04_工作流与进度机制.md` + 11 个 sprint 完整 retro

---

## 0. TL;DR

KE 项目的工作节奏不是软件项目（每周 1-2 个 sprint），而是**深而慢**：每 1-2 周完成一个 Sprint，每个 Sprint 5 个 Stage（带 Gate + Stop Rules），失败可回滚。

AKE Sprint Governance = 4 个层级的治理：

1. **Sprint** — 1-2 周的工作单元，对应一个具体目标
2. **Stage** — Sprint 内的 5 个阶段（brief / smoke / full / review / closeout），各有交接物
3. **Gate** — Stage 之间的"质量闸门"（必须通过才能进下一 Stage）
4. **Stop Rule** — Sprint 内任何时点的"中止条件"（触发即暂停 + 升级）

本文件给出：(1) Sprint 治理理念；(2) 5-Stage 模板 + Gate 协议；(3) Stop Rule 设计；(4) 工作流（dry-run → review → apply → verify）抽象；(5) 跨领域使用指南。

---

## 1. 设计理念

### 1.1 KE 项目特征 vs 软件项目

| 维度 | 软件项目 | KE 项目 |
|------|---------|--------|
| 主要风险 | 功能 bug / UX 问题 | **数据正确性 / 实体一致性 / 不可逆数据污染** |
| 回滚成本 | 低（git revert + redeploy）| **高**（数据已合并 / 已 cascade）|
| 迭代速度 | 快（每周）| **慢**（每 1-2 周）|
| 单 Sprint 工作量 | 5-10 个 feature | 1-2 个数据问题 + 治理决策 |
| Sprint 节奏 | 紧凑（每周 release）| **审慎**（每 sprint 含 dry-run 阶段）|

→ AKE Sprint 必须比软件 Sprint 更**慎重**：dry-run 优先于 apply / 多 stage gate / 显式 stop rules / 完整 audit trail。

### 1.2 Stage 5-Pattern 的来源

5-Stage 不是凭空设计，是 Sprint A-K 真实演化的最小完备集：

| Stage | 解决的问题 | 不可省略的理由 |
|-------|----------|--------------|
| Stage 0 — Brief | 启动前对齐目标、范围、Stop Rules | 没有 brief = scope creep + 无 stop 条件 |
| Stage 1 — Smoke | 小规模验证（5 段 / 1 章节）| 没有 smoke = 大规模 ingest 后才发现 prompt 有 bug = 浪费 |
| Stage 2 — Full | 全量 ingest / extract | 主体工作 |
| Stage 3 — Review | dry-run + Domain Expert 审核 | 没有 review = 直接 apply = 不可逆数据问题 |
| Stage 4 — Apply | 真正落 DB | 与 Stage 3 严格分离防止误操作 |
| Stage 5 — Closeout | 任务卡 / STATUS / CHANGELOG / retro / 衍生债 | 没有 closeout = 项目混乱 |

### 1.3 "dry-run + apply" 双段式

KE 项目中**任何**会修改数据库的操作都必须分两步：

1. **Dry-run**：生成"如果 apply 会发生什么"的报告（不动数据）
2. **Review**：人工或 invariant test 审核 dry-run 报告
3. **Apply**：真改数据库

Sprint A-K 实证：dry-run + review 拦截了多次"差点 apply 错误"的情况。

---

## 2. Sprint 5-Stage 模板

### 2.1 Stage 0 — Brief

**输出**：`docs/sprint-logs/sprint-X/stage-0-brief-YYYY-MM-DD.md`

**必含字段**：

```markdown
# Sprint X Brief — {主题}

## 0. 元信息
- 架构师：xx
- Brief 日期：YYYY-MM-DD
- Sprint 形态：单 track / 多 track
- 预估工时：N 天
- 主导角色 model：Sonnet 4.6 / Opus 4.7
- 触发事件：xxx

## 1. 背景
（为什么做这个 sprint，前置 sprint 的什么发现 / 衍生债驱动）

## 2. 与既有 sprint 的差异
（表格对比当前 vs 历史最近 sprint 的关键维度）

## 3. Stages（5-stage 模板）
- Stage 0 — 前置准备 / fixture / adapter 注册
- Stage 1 — Smoke 验证（5 段 / 1 子集）
- Stage 2 — Full 主体执行
- Stage 3 — Dry-run + Review（人工审核）
- Stage 4 — Apply（落数据）
- Stage 5 — 收档（task card / STATUS / CHANGELOG / retro / 衍生债）

## 4. Stop Rules
（≥ 5 条具体可触发的中止条件，含阈值）

## 5. 角色边界
（本 sprint 涉及的 1-5 个角色及其职责分工）

## 6. 收口判定
（≥ 5 条"sprint 算完成"的明确标准）

## 7. 节奏建议
（哪些 stage 可在同一 session，哪些必须分 session）

## 8. D-route 资产沉淀预期（D-route 项目特有）
（本 sprint 预期沉淀什么框架抽象资产）
```

### 2.2 Stage 1 — Smoke

**目的**：用最小子集（5 段 / 1 章节 / 10 行）跑通 pipeline，验证基础设施 + prompt + invariants 能工作。

**Gate 0**：
- LLM cost 不超过预算
- V1-V11 invariants 全绿
- 输出格式符合预期 schema

**输出**：smoke 报告 + 给 Stage 2 ACK 信号

### 2.3 Stage 2 — Full

**目的**：全量 ingest + extract + load。

**Gate 1**：
- 总成本不超过 brief 预算的 1.5x
- 新增实体数不超过 brief 预期的 1.2x
- 没有任何 V invariant 回归

**输出**：DB 数据 + 任务卡子勾选完成 + 给 Stage 3 ACK 信号

### 2.4 Stage 3 — Review (Dry-run + Human Review)

**目的**：

1. PE 跑 `scripts/dry_run_resolve.py` 等输出 merge 候选 / split 候选 / etc
2. Architect / Domain Expert 审核 dry-run 报告
3. 决策每个 candidate 的 approve / reject / defer

**Gate 2**：
- Domain Expert 完成审核报告
- Architect ACK 报告中所有 reject 决策
- 准备好给 Stage 4 的 apply input file

**输出**：`dry-run-resolve-YYYY-MM-DD.md` + Domain Expert review report + Architect ACK

### 2.5 Stage 4 — Apply

**目的**：根据 Stage 3 决策真改数据库。

**关键约束**：
- 必须用 idempotency unique key 防重写
- 必须留 pre-apply pg_dump anchor（备份）
- 必须支持 rollback

**Gate 3**：
- DB 写入数与决策数一致（误差 ≤ 5%，超出触发 stop rule）
- V1-V11 invariants 仍全绿
- audit log 完整

### 2.6 Stage 5 — Closeout

**输出**：

- 任务卡状态 → done
- STATUS.md 更新当前阶段 + 数据基线
- CHANGELOG.md 追加 sprint 完成记录
- `docs/retros/sprint-X-retro.md`（含 D-route 资产盘点段）
- 衍生债登记 → `docs/debts/`
- D-route 资产盘点（该 sprint 沉淀的可抽象 pattern + 暴露的案例耦合点 + 下一 sprint 抽象优先级建议）

---

## 3. Gate 协议（Stage 之间的质量闸门）

### 3.1 Gate 检查模板

```markdown
## Gate {N} Check (Stage {N-1} → Stage {N})

- [ ] 当前 Stage 所有交付物完成
- [ ] 所有 unit test / invariant test 全绿
- [ ] 当前 Stage 成本未超预算
- [ ] 没有 P0 / P1 严重 bug 待修
- [ ] 给下一 Stage 的输入文件就绪
- [ ] Architect ACK
```

### 3.2 Gate 不通过处理

任何 Gate 不通过 = Sprint **暂停**：
- 标识不通过原因
- 评估是修复（继续）还是 abort（rollback）
- 决策记入任务卡 + 升级 Architect 仲裁

不允许"差不多就过"的妥协。

---

## 4. Stop Rule 设计

### 4.1 Stop Rule = 不可妥协的中止条件

Sprint 任何时点遇到 Stop Rule 触发 → 立即暂停 → 升级 Architect 决策（继续 / rollback / scope 缩减 / 等）。

不是 review 反馈，是**硬中断**。

### 4.2 Stop Rule 设计原则

1. **可量化**：每条 rule 必须有具体阈值（"成本 > $X" / "新实体 > Y 个"），不允许"差不多了"
2. **预先声明**：Sprint Brief 中 §4 显式列出，不允许执行中"补"
3. **覆盖五类风险**：
   - 成本（LLM cost / 时长 / etc）
   - 数据正确性（invariant 回归）
   - 输出量（实体数 / merge 数 异常）
   - 治理（review 拒绝率超阈值）
   - 跨 sprint 一致性（与历史数据的差距）
4. **可触发的具体路径**：每条 rule 标注"触发时该做什么"（rollback / 升级 / 调参数 / etc）

### 4.3 实例（Sprint J 高祖本纪 ingest）

```markdown
## 4. Stop Rules

1. **V1 / V9 在新数据 ≠ 0** → 立即 Stop（Sprint F 修复持续验证）
2. **Stage 2 cost > $1.80** → Stop
3. **Stage 2 NER new persons > 120** → Stop pre-Stage 3 historian batch review
4. **R1 跨国 FP 治理率 < 70%** → Stop，分析根因（state_prefix_guard 设计可能需要补强）
5. **R1 跨国 FP 治理率 70-90%** → 继续 apply，但 retro 中分析剩余 case 是否需 NER prompt 改进 / 字典扩充
6. **R1 跨国 FP 治理率 ≥ 90%** → ✅ Sprint G→I 治理目标达成，retro 庆祝
7. **NER v1-r5 黄金集任一已有章节回归** → Stop
8. **任一 V invariant 回归** → Stop
```

### 4.4 Sprint K 实战（多次 stop rule 触发）

Sprint K 期间触发了多次 stop rule，全部以"明确决策 + 文档化 + 接受"方式处理：

- **PE 175 vs 179 backfill stop rule**（idempotency 跨 sprint 去重）
  - 触发：实际写入 175，dry-run 预期 179
  - 决策：架构师 R1+R3 混合（接受 175 + 透明度文档）
  - 路径：dry-run 报告补 idempotency 章节 + retro 加方法学缺陷
- **provenanceTier 文案不一致**（FE 4b smoke 发现）
  - 触发：UI 显示原始 enum vs PersonCard 显示"未验证"
  - 决策：架构师 Option A（统一"未验证"）
  - 路径：FE 加 commit + 测试

→ Stop Rule 不是阻碍 sprint 完成，是**保证 sprint 完成质量**的机制。

---

## 5. 4-Stage 通用工作流（dry-run / review / apply / verify）

### 5.1 概念抽象

任何 KE 数据修改操作都遵循 4 步：

```
dry-run (生成报告，不动数据)
  ↓
review (人 + invariant test 审核报告)
  ↓
apply (真改数据 + audit log + idempotency)
  ↓
verify (post-apply 检查 invariants + 数据 sanity)
```

### 5.2 实例（Sprint K Stage 2 PE backfill）

```python
# Stage 2 prep: dry-run
python scripts/backfill_pending_merge_reviews.py --dry-run > dry-run-report.md

# Stage 2 review: 人工 + invariant test
# Architect 审 dry-run 报告
# pytest tests/test_invariants_*.py → 22/22 全绿

# Stage 2 apply: 真改 DB
pg_dump > pre-apply-anchor.dump
python scripts/backfill_pending_merge_reviews.py --apply
python scripts/backfill_triage_decisions.py --apply

# Stage 2 verify: post-apply
psql -c "SELECT count(*) FROM pending_merge_reviews;"  # 期望 18
psql -c "SELECT count(*) FROM triage_decisions;"        # 期望 175
pytest tests/test_invariants_*.py                       # 仍 22/22 全绿
```

### 5.3 失败模式 + 处理

| 失败 | 处理 |
|------|------|
| dry-run 报告说要改 X 行，实际只改了 X-N 行 | idempotency 拦截了 N 行 → 是预期还是 bug？stop rule 决定 |
| dry-run 全绿，apply 后 invariant 红 | 立即 rollback（pg_dump restore）+ 调查 |
| apply 中途崩溃 | 恢复到 pg_dump anchor + 修因 + 再 apply |

---

## 6. 模型选型模式（Sonnet vs Opus）

### 6.1 经验规则

| Sprint 形态 | 推荐模型 |
|------------|---------|
| 框架创设（新 ADR / 新设计 / 新模式）| Opus 4.7 |
| 框架扩展（已有 pattern 内的新功能 / 案例验证）| Sonnet 4.6 |
| 真实数据 ingest（按 pattern 执行）| Sonnet 4.6 |
| 跨章节复杂决策（merge / split / 跨 dynasty 分析）| Opus 4.7 |
| 简单任务（fixture register / commit / closeout）| Sonnet 4.6 |

### 6.2 实证（Sprint I/J/K）

- Sprint I（state_prefix_guard 框架扩展）：Sonnet 4.6 ✅ 通过
- Sprint J（高祖本纪 ingest，按 pattern 执行）：Sonnet 4.6 ✅ 通过
- Sprint K（T-P0-028 跨角色 + 新协议设计）：Opus 4.7 主 + Sonnet 4.6 子 ✅ 通过

### 6.3 抽象到框架

模型选型是 **per-sprint** 决策，不是 per-project。每个 Sprint Brief §0 显式声明本 sprint 主导角色的 model：

```markdown
- **PE 模型**：Sonnet 4.6（Sprint I 试用通过；本 sprint 真书 ingest 类工作）
```

---

## 7. 跨领域使用指南

### 7.1 复用度极高（领域无关）

- Sprint 5-Stage 模板（§2）
- Gate 协议（§3）
- Stop Rule 设计（§4）
- 4-Stage 通用工作流（§5）
- 模型选型经验（§6）

直接复制 + 调整少量领域参数即可用。

### 7.2 需要领域调整

- Stop Rule 阈值（古籍领域 NER cost vs 法律领域 contract clause cost 的预算不同）
- Smoke 子集大小（章节 vs 案例 vs 病例 的"5 段"含义不同）
- Domain Expert review 强度（古籍 1 review session vs 法律可能 N review session）

### 7.3 启动模板

```bash
# 1. 复制 sprint 框架
mkdir -p docs/sprint-logs/sprint-a/

# 2. 复制 brief 模板（基于本文件 §2.1）
cp /path/to/huadian/docs/sprint-logs/sprint-k/stage-0-brief-2026-04-28.md \
   docs/sprint-logs/sprint-a/stage-0-brief-YYYY-MM-DD.md

# 3. 改 brief：领域 / Stop Rule 阈值 / 角色 / 节奏 / D-route 资产预期

# 4. Architect 审 brief → ACK → 启动
```

---

## 8. 反模式

### 8.1 反模式：跳 Stage

❌ 直接从 Stage 1 smoke 跳 Stage 4 apply（"smoke 通过了，应该没问题"）

✅ 严格走 5 个 stage；smoke 通过不等于 full 通过

### 8.2 反模式：模糊 Stop Rule

❌ "如果 cost 太高 stop"（多高？）

✅ "Stage 2 cost > $1.80 → Stop"（具体阈值）

### 8.3 反模式：跨 Sprint 隐式依赖

❌ Sprint K 启动前没 verify Sprint J 已收档

✅ 每个 Sprint Brief 列出对前置 sprint 的依赖 + 验证依赖完成

### 8.4 反模式：只前进不回滚

❌ 数据 apply 出错就忍着不回滚（"数据已经在 DB 了，重做太麻烦"）

✅ 每个 apply 步骤都备好 pg_dump anchor，出错立即 rollback

---

## 9. 修订历史

| Version | Date | Author | Change |
|---------|------|--------|--------|
| Draft v0.1 | 2026-04-29 | 首席架构师 | 初稿（Stage C-6 of D-route doc realignment）|

---

> 本文档描述的 Sprint Governance 是 AKE 框架的 Layer 1 核心资产之一。
> Sprint A-K 是其真实演化历史，详见 `docs/sprint-logs/sprint-{a..k}/`.
