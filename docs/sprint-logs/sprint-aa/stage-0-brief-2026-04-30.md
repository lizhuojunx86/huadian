# Sprint AA Stage 0 — Brief

> Status: draft → 待用户 ACK
> Date: 2026-04-30
> Brief-template version: **v0.1.4 第 5 次外部 dogfood**（之后 v0.1.5 patch 由本 sprint 落地）
> 主导：Architect Opus 4.7 (single-actor)
> Subject: **v0.5 maintenance sprint** / 清债 3 候选 / methodology v0.2 cycle 完成后首个维护 sprint

---

## 1. 背景

### 1.1 触发事件

methodology v0.2 cycle 完成（Sprint Z 关档）→ **Layer 2 进入维护态** → 押后清单累积 4 v0.5 候选触发 maintenance sprint（per /02 §10 触发条件 ≥ 3-5 候选）。

用户主动选 A 路径（per Sprint Z+1 候选议程 / 不走默认 D 等候触发）。

### 1.2 与 Sprint P (上次 maintenance sprint) 差异

| 维度 | Sprint P (v0.2 release prep + maintenance fold) | **Sprint AA (本 sprint)** |
|------|----------------------------------------------|--------------------------|
| 形态 | release prep + maintenance fold 复合 | **纯 v0.5 maintenance** |
| 主题 | v0.2 → v0.3 release timing 准备 | methodology v0.2.1 patch + brief-template v0.1.5 polish |
| 候选数 | 8 项 5-batch | **3 项 / 5-batch** |
| 触发 cycle | framework v0.2 → v0.3 release | methodology v0.2 cycle 完成后维护态首 sprint |
| 工时 | 1.5 会话 | **1 会话紧凑** |

### 1.3 不做的事（Negative Scope）

- ❌ 不动 framework code（v0.3.0 模块稳定 / 仅 doc patch + brief-template patch）
- ❌ 不起新 methodology v0.3 cycle（cycle 完成 / 进入维护态 / 不主动加速）
- ❌ 不主动起跨域 outreach (C 路径)
- ❌ 不 fold v0.2 押后清单 DGF-N-04/-05（等外部触发）

---

## 2. 目标范围

### 2.1 Track 1 — v0.5 maintenance / 3 候选清债

**目标**：清 4 v0.5 候选中的 3 项可执行 candidates / 把"deferred 内容补回"+"brief-template 演化触发"两类债务一并 fold。

**3 候选**：
1. **批 1 — T-V05-FW-002** (~15 min): methodology/02 v0.2 → v0.2.1（§14+§15 cross-ref polish）
2. **批 2 — T-X02-FW-001** (~25-35 min): methodology/04 v0.2 → v0.2.1（fold §8.6 实证 + 反模式 / 方案 B deferred 补齐）
3. **批 3 — T-X02-FW-002** (~15-20 min): brief-template v0.1.4 → v0.1.5（加 v0.x 大 bump 重编号 checklist + 里程碑庆祝节制段）

#### 工作量估算（v0.1.4 第 5 次 dogfood）

| 类别 / 子类 | 实证锚点 | 估时 |
|-----------|---------|------|
| **Docs: cross-ref polish** | 批 1 /02 + 批 3 brief-template | ~30-35 min |
| **Docs: new doc 起草** | 批 2 /04 fold §8.6 (deferred 补齐 = 起草 sub-section) | ~25-35 min |
| **Closeout / Retro** | stage-4-closeout / retro / debts | ~25-30 min |
| **小计** | — | **~80-100 min ≈ 1 会话紧凑** |

**v0.1.4 第 5 次 dogfood 关注点**：
- Docs: cross-ref polish 子类首独立验证（vs 之前都是 new doc 起草子类）
- v0.1.4 → v0.1.5 自我演化 dogfood（用 v0.1.4 estimate 自己升级到 v0.1.5）

**完成判据**：
- 3 batches 全 complete
- 60 pytest 不回归 + 5 模块 sanity OK
- methodology/02 → v0.2.1 / methodology/04 → v0.2.1 / brief-template → v0.1.5
- v0.5 押后清单 4 → 1（只剩 DGF-N-04/-05 v0.2 押后 + 1 候选未登记）

---

## 3. Stages

走 §3.B 精简模板（pure docs sprint / 不涉 LLM / 不涉 schema）。

```
Stage 0 — brief 起草（本文件）✅
Stage 1 批 1 — T-V05-FW-002 /02 v0.2.1 polish
Stage 1 批 2 — T-X02-FW-001 /04 v0.2.1 fold §8.6
Stage 1 批 3 — T-X02-FW-002 brief-template v0.1.5
Stage 1.13 — sanity 回归
Stage 4 — closeout + retro + STATUS/CHANGELOG + Sprint AB 候选
```

不需 Stage 2/3。1 会话紧凑路径（per Sprint Y 节律 / 不中场 commit）。

---

## 4. 改动设计（细节）

### 4.1 批 1 — T-V05-FW-002 /02 v0.2 → v0.2.1（~15 min / Docs cross-ref polish）

**当前 (v0.2)**：716 行 / Sprint V 批 4 加 §14+§15 / 6 元 pattern 总览

**v0.2.1 加段**：
- §14 / §15 cross-ref 自身 polish（Sprint V 批 4 起草时 §14 + §15 互引未充分建立 / per Sprint V residual debts §2.2）
- 加 ~5-10 行 cross-ref（§14.X 引 §15.Y / §15.X 引 §14.Y / §9 元 pattern 总览表更新双向引用）
- §修订历史加 v0.2.1 entry

**估算**: ~10-15 行加 / 726-731 总行（vs 当前 716 / 增量小）

### 4.2 批 2 — T-X02-FW-001 /04 v0.2 → v0.2.1（~25-35 min / Docs new doc 起草）

**当前 (v0.2)**：555 行 / Sprint X 批 2 / §8 Self-Test Pattern first-class / §8.6 deferred to v0.2.1

**v0.2.1 加段**：fold §8.6 deferred 内容（per Sprint X 方案 B）：
- §8.6.1 Sprint O 4/4 catch 详细实证（具体 SelfTest impl 例 + transaction rollback verify）
- §8.6.2 self-test 反模式（无 transaction rollback / query 与 invariant 共享模板 / 仅断言 row count 等）

**估算**: ~50-70 行加 / 605-625 总行（vs 阈值 600 / **接近上限**）

**Stop Rule #4 风险**：v0.2.1 fold §8.6 后体量预测 605-625 行 / 略超阈值 600。应对：
- 方案 A: 接受体量 605-625（仅 1-4% 超阈值 / 内于合理 wiggle room）
- 方案 B: §8.6 内容紧凑写（≤ 50 行加 / 体量 ≤ 605）/ 推荐
- 方案 C: 继续 deferred §8.6.2 反模式到 v0.2.2 / 不推荐（碎片化）

**推荐方案 B**：紧凑写法 / 实证用 1 例代替 4 例详写 / 反模式仅列 4 条不展开。

### 4.3 批 3 — T-X02-FW-002 brief-template v0.1.4 → v0.1.5（~15-20 min / Docs cross-ref polish）

**当前 (v0.1.4)**：sprint-templates/brief-template.md / §2.1 7 子类估时表

**v0.1.5 加段**（per Sprint Z residual §2.3）：
- §X.1 v0.x 大 bump 重编号 checklist（per Sprint X retro §2.1 + Sprint Y §2.1 + Sprint Z §2.1 连续 3 sprint 同 issue）
  - [ ] 父节号重编
  - [ ] 子节号重编（容易遗漏）
  - [ ] cross-ref 内章节引用更新
- §X.2 里程碑庆祝节制段（per Sprint Z retro §2.2）
  - ⭐ 数量与里程碑实际 weight 对齐
  - "等触发"vs"实际触发"区分

**placement**：在 §2 后 / §3 Stages 前（新 §2.5 或 §3 之前）

**估算**: ~20-30 行加（template 改动）

---

## 5. 关键文件清单

修改：
- `docs/methodology/02-sprint-governance-pattern.md` (v0.2 → v0.2.1)
- `docs/methodology/04-invariant-pattern.md` (v0.2 → v0.2.1)
- `framework/sprint-templates/brief-template.md` (v0.1.4 → v0.1.5)
- `framework/sprint-templates/__init__.py`（如有 version constant，bump v0.3.1 → v0.3.2）
- `docs/STATUS.md` (Layer 1+2+4 + §2.2.15 Sprint AA + §2.3 Sprint AB 候选)
- `docs/CHANGELOG.md` (Sprint AA 块前置)

新建：
- `docs/sprint-logs/sprint-aa/stage-0-brief-2026-04-30.md` (本文件)
- `docs/sprint-logs/sprint-aa/stage-4-closeout-2026-04-30.md`
- `docs/retros/sprint-aa-retro-2026-04-30.md`
- `docs/debts/sprint-aa-residual-debts.md`

无 framework code 改动（pure docs + template patch sprint）/ 无 ADR 起草。

---

## 6. 收口判据（5 项）

1. methodology/02 v0.2 → v0.2.1（§14+§15 cross-ref polish）
2. methodology/04 v0.2 → v0.2.1（fold §8.6 实证 + 反模式 / 方案 B 紧凑写法 / 体量 ≤ 605 行）
3. brief-template v0.1.4 → v0.1.5（+ 重编号 checklist + 里程碑庆祝节制 / sprint-templates v0.3.1 → v0.3.2）
4. 5 模块 sanity 不回归 + 60 pytest 全绿
5. v0.5 押后清单 4 → 1（清 3 candidates / 仅剩 1 候选未登记）+ STATUS / CHANGELOG / retro 全 land

---

## 7. Stop Rule 风险评估

| Rule | 风险 | 应对 |
|------|------|------|
| #1 单 batch 工时超 1.5x | 低 | 3 batches 都体量小 / 实证锚点清晰 |
| #2 单 batch 改动 file > 5 | 低 | 各批 1-2 file |
| #3 doc 总行 > 600 (/02) | 低 | 716 → 726-731 / 已超 600 但是 v0.x cycle 起步 doc / 阈值不严格 (per /02 自身体量证明阈值因 doc 而异) |
| **#4 doc 总行 > 600 (/04)** | **中** | 555 → 605-625 / 略超 / **方案 B 紧凑写法** + Sprint X 方案 B deferred 节律延续 |
| #5 跨 sprint 决策残留 | 低 | 本 sprint 即清 3 候选 / 不残留 |

**当前预测**：连续第 12 个 zero-trigger sprint 概率高（3 batches 都体量内 / 1 会话紧凑）。

---

## 8. cycle 完成后第一个维护 sprint 的意义

Sprint AA 是 **Layer 2 维护态首个 sprint**。其设计模式可作为后续 v0.5 maintenance sprint 模板：

- 触发条件：v0.5 押后 ≥ 3 候选累积
- 形态：1 会话紧凑 / 3-batches / pure docs + template patch
- 节律：cycle 完成后偶发触发（vs cycle 期间持续推进）
- 期望频率：~每 2-3 个月一次（per Sprint Z residual debts §6 维护态工作流）

→ Sprint AA closeout retro 应明确记录此模板，为 Sprint AB / AC / 等未来 v0.5 maintenance sprint 提供参考。

---

## 9. 下一步

待用户 ACK 本 brief → Architect 启动 Stage 1 批 1（/02 v0.2.1）→ 直接 批 2（/04 v0.2.1 fold §8.6）→ 批 3（brief-template v0.1.5）→ Stage 1.13 + Stage 4 → 一次 commit + push (2 commits 整体)。

---

**brief 起草完成 / brief-template v0.1.4 第 5 次外部 dogfood / Layer 2 维护态首 sprint / 待用户 ACK**
