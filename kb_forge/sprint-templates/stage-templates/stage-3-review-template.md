# Sprint ⚠️FILL-ID Stage 3 — Dry-Run + Review

> 复制到 `docs/sprint-logs/sprint-{id}/stage-3-review-YYYY-MM-DD.md`

## 0. 目的

把 Stage 2 产生的"需要决策的候选"（merge candidate / split candidate / mapping verification / etc）通过 **dry-run 报告 + Domain Expert 审核** 处理，准备 Stage 4 apply 输入。

⚠️ **关键约束**：dry-run **不动数据库**。Stage 4 apply 才动。两 stage 必须严格分离。

---

## 1. Dry-Run

### 1.1 跑 dry-run 脚本

```bash
⚠️FILL: 例如
cd services/pipeline
uv run python scripts/dry_run_resolve.py > docs/sprint-logs/sprint-{id}/dry-run-resolve-YYYY-MM-DD.md
```

### 1.2 dry-run 报告内容

```markdown
# Dry-Run Report — Sprint X

## Run ID: ⚠️UUID
## Active persons (or entities): ⚠️N

## Candidates summary
- Total candidates: ⚠️N
- By rule: R1=⚠️N / R2=⚠️N / ... / R6=⚠️N
- Guard blocked: ⚠️N (cross_dynasty=⚠️N / state_prefix=⚠️N / etc)

## Per-candidate details
| # | rule | a_id | b_id | a_name | b_name | guard | suggest |
|---|------|------|------|--------|--------|-------|---------|
| 1 | R1 | ... | ... | ... | ... | none | merge   |
| 2 | R1 | ... | ... | ... | ... | cross_dynasty | pending_review |
...
```

---

## 2. Domain Expert Review

### 2.0 Review 形式选择指南（Sprint P T-P3-FW-003 新增）

按以下顺序判断，选第一个 ✅ 的方案：

| 条件 | 推荐形式 | 理由 |
|------|---------|------|
| candidates ≥ 30 **或** 跨 sprint 一致性必查 | **Triage UI（§2.1）** | 历史 hint banner / audit table 不可替代 |
| 30 > candidates ≥ 10 **且** triage UI 已就绪 | Triage UI（§2.1） | 用就用，避免 markdown 流量回退 |
| candidates < 10 **且** 三天内只 1 次 review | **Markdown Review（§2.2）** | 起 UI 服务 ROI 不划算 |
| candidates < 10 **但** 涉及历史 reject 复检 | Triage UI（§2.1） | hint banner 必查 |
| triage UI 临时不可用（CI / 离线 / 等） | Markdown Review（§2.2） | V1 fallback，retro §3 记衍生债 |

> 选 Markdown Review 时必须在 retro §3 标注"用 V1 fallback 是 ⚪ 临时 / 🟡 持续，下 sprint 是否切回 Triage UI"。

### 2.1 Triage UI（推荐主路径，参见 `docs/methodology/05-audit-trail-pattern.md`）

- Hist 用 Web UI 决策（approve / reject / defer）
- Hint Banner 显示历史决策（跨 sprint 一致性）
- 决策写入 `triage_decisions` audit table

### 2.2 Markdown Review（V1 fallback）

- Hist 直接编辑 dry-run 报告，加 decision column
- 决策记录在 sprint-logs/{id}/historian-review-YYYY-MM-DD.md

### 2.2 Review 输出

每个 candidate 必须有：
- decision: `approve` / `reject` / `defer`
- reason_text: 1-3 句历史依据 / 业务依据
- reason_source_type: `in_chapter` / `other_classical` / `slug-dedup` / etc（参见 framework Triage UI 6 quick templates）

---

## 3. Architect ACK

Architect 审 review 报告：

- 检查所有 reject 决策的 reason_text 充分性（≥ 1 句具体理由）
- 检查 approve 决策的 reason 不与历史 reject 冲突（高一致性 → 高警觉）
- 仲裁任何 Hist 标 defer 的 case（架构师裁决继续 / 押后）

---

## 4. Gate 2 Check（→ Stage 4 解锁条件）

- [ ] dry-run 报告完整（所有 candidates 列出）
- [ ] Domain Expert review 完成（每个 candidate 有 decision + reason）
- [ ] Architect ACK 所有 reject 决策（reason 充分）
- [ ] Stage 4 apply input file 就绪：
  - approve list（→ Stage 4 真 merge / split）
  - reject list（→ Stage 4 写 audit row 但不 mutation）
  - defer list（→ 留 pending_review）

---

## 5. 决策统计

记录关键比例：

```
- 总 candidates: ⚠️N
- approve: ⚠️N (⚠️X%)
- reject: ⚠️N (⚠️X%)
- defer: ⚠️N (⚠️X%)
- guard blocked (auto-pending_review): ⚠️N

Domain Expert review 工时: ⚠️N 小时
Architect ACK 工时: ⚠️N 分钟
```

---

## 6. 给 Stage 4 的 Handoff 信号

```
✅ Sprint X Stage 3 Dry-Run + Review 完成
- Run ID: ⚠️UUID
- Total candidates: ⚠️N (approve ⚠️A / reject ⚠️R / defer ⚠️D)
- Architect ACK: 完成
- Stage 4 input file: ⚠️FILL 路径
→ Stage 4 Apply 可启动
```

---

**Stage 3 完成 → Stage 4 启动。**
