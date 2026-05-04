# Sprint Z Stage 0 — Brief

> Status: draft → 待用户 ACK
> Date: 2026-04-30
> Brief-template version: **v0.1.4 第 4 次外部 dogfood**
> 主导：Architect Opus 4.7 (single-actor)
> Subject: methodology v0.2 cycle **完成 sprint** ⭐⭐⭐ / /03 → v0.2 / 1.5 会话大工作

---

## 1. 目标

methodology v0.2 cycle **完成** sprint（per Sprint Y retro §7 候选 A）：

1. **批 1 (单批 / 大工作)**: methodology/03 v0.1.2 → v0.2
   - + §10 Byte-Identical Dogfood Pattern first-class（per Sprint N 729 person 实证）
   - 与 /04 §8 Self-Test Pattern 形成 **L1 vs L4 对比**
   - **完成 4 等级 dogfood 框架** first-class（L1 byte-identical / L2 soft-equivalent 同 stack / L3 soft-equivalent 跨 stack / L4 self-test 主动）

methodology v0.2 cycle 进度推进：**7/8 → 8/8 = 100%** ⭐⭐⭐ → **ADR-031 §3 #7 触发** → **v1.0 评估议程激活**

---

## 2. 估时表（brief-template v0.1.4 7 子类 / 第 4 次外部 dogfood）

| 子类 | 本 sprint 任务 | 估时 | 实际（待回填）|
|------|--------------|------|--------------|
| Code: 框架 spike | — | — | — |
| Code: 新模块抽象 | — | — | — |
| Code: patch / version bump | — | — | — |
| Docs: cross-ref polish | — | — | — |
| **Docs: new doc 起草** | /03 v0.2（大工作 / 单 doc）| **~70-90 min** | TBD |
| Docs: ADR / 决策记录 | — | — | — |
| **Closeout / Retro** | stage-4-closeout + retro + STATUS + CHANGELOG + debts + cycle 完成宣布 | **~30-40 min** | TBD |

**总估时**: ~100-130 min ≈ **1.5 会话**（大工作 / 单 doc 但需 fold 4 等级 dogfood 完整框架）

**v0.1.4 第 4 次 dogfood 关注点**：
- 单 doc 大 bump 子类首验证（vs Sprint W/X/Y 都是双 doc bump）
- Closeout / Retro 子类含 cycle 完成宣布 + ADR-031 #7 触发记录 / 工作量略高于平时 (~30-40 vs Sprint Y ~25-30)

---

## 3. Stage 路径

```
Stage 0 — brief 起草（本文件）✅
Stage 1 (单批) — methodology/03 v0.1.2 → v0.2（大工作 / +120-160 行 / Byte-Identical Dogfood Pattern first-class + 4 等级 dogfood 框架完整化）
Stage 1.13 — sanity 回归（60 pytest + 5 模块 + ruff/format）
Stage 4 — closeout + retro + STATUS/CHANGELOG + cycle 完成宣布 + ADR-031 #7 触发宣布 + Sprint Z+1 候选议程
```

不需 Stage 2/3。**1 会话紧凑路径**（per Sprint Y 节律 / 不中场 commit / 一次性 push 2 commits 整体）。

---

## 4. 改动设计（细节）

### 4.1 批 1 — methodology/03 v0.1.2 → v0.2

**当前 (v0.1.2)**：391 行 / §0-§9 + §10 修订历史 / Sprint S 批 3 加 §9 元 pattern cross-ref

**v0.2 加段**：

#### 4.1.1 §10 Byte-Identical Dogfood Pattern first-class (新)

placement：在 §9 (元 pattern cross-ref) 后 / §10 修订历史前（新 §10 / 修订历史 §10 → §11 重编号）。

内容 sub-sections（8 sub-sections）：
- §10.1 定义（同 stack 抽象后跑双路径 / 字段逐字一致）
- §10.2 4 等级 Dogfood 框架（L1-L4 / 与 /04 §8.2 协调 / 把 L1 抽出 first-class）
- §10.3 Byte-Identical 适用条件（同 stack / 输出确定性 / 抽象边界清晰 + 例外 alias 列表）
- §10.4 Byte-Identical 设计契约（pseudocode + Plugin Protocol 边界设计要求）
- §10.5 实证 Sprint N 729 persons / 17 guards / 0 字段差异（含 Stop Rule #1 临时触发的处理）
- §10.6 跨域 fork 启示（同 stack 走 L1 / 跨 stack 走 L3 / 首次抽象 Stop Rule #1 风险）
- §10.7 Byte-Identical vs Self-Test 对比（与 /04 §8 / 4 等级 framework 完整化）
- §10.8 反模式（强制 byte-identical 跨 stack / alias whitelist 失控 / Stop Rule #1 反复 / dogfood 推到 Stage 4）

#### 4.1.2 § 修订历史 §10 → §11 重编号

**估算**: ~140-170 行加 / 531-561 总行（vs 阈值 600 / 88-94% 容量 / Stop Rule N/A 但接近 /04 v0.2 体量）

---

## 5. 关键文件清单

修改：
- `docs/methodology/03-identity-resolver-pattern.md` (v0.1.2 → v0.2)
- `docs/STATUS.md` (Layer 1+2+4 + §2.2.14 Sprint Z + §2.3 cycle 完成 + ADR-031 #7 触发宣布 + v1.0 评估议程激活)
- `docs/CHANGELOG.md` (Sprint Z 块前置)

新建：
- `docs/sprint-logs/sprint-z/stage-0-brief-2026-04-30.md` (本文件)
- `docs/sprint-logs/sprint-z/stage-4-closeout-2026-04-30.md`
- `docs/retros/sprint-z-retro-2026-04-30.md`
- `docs/debts/sprint-z-residual-debts.md`

无 framework code 改动（pure docs sprint）/ 无 ADR 起草（/06 §8.4 retroactive ADR 模板已涵盖此次 cycle 完成 / 不需 release 触发 ADR）。

**注**：cycle 完成 sprint 不需 release-trigger ADR（per /06 §8.2 / methodology v0.2 cycle 不是 framework release / 是 doc cycle）。但 retro §7 应记录"#7 触发条件达成"作为 ADR-031 §3 #7 状态更新（不起新 ADR）。

---

## 6. 收口判据（5 项）

1. methodology/03 v0.1.2 → v0.2（+§10 Byte-Identical Dogfood Pattern first-class / 8 sub-sections）
2. 5 模块 sanity 不回归 + 60 pytest 全绿
3. STATUS / CHANGELOG / retro / 衍生债 全 land
4. methodology v0.2 cycle 进度更新：7/8 → **8/8 = 100%** ⭐⭐⭐
5. **ADR-031 §3 #7 触发条件达成** + STATUS §1.1 + retro 明确记录 + v1.0 评估议程激活

---

## 7. Stop Rule 风险评估

| Rule | 风险 | 应对 |
|------|------|------|
| #1 单 batch 工时超 1.5x | 中 | /03 大工作 / 8 sub-sections / Stop Rule #1 触发限度需 ≥ 90 min × 1.5 = 135 min / 内于预算 |
| #2 单 batch 改动 file > 5 | 低 | 单批 1 file |
| #3 doc 总行 > 600 (/03) | **中** | 391 → 531-561 / 88-94% 容量 / 接近 /04 v0.2 体量 / 备 deferred 方案 B（但优先在 §10 内压缩） |
| #5 跨 sprint 决策残留 | 低 | 无 fold target |

**当前预测**：连续第 11 个 zero-trigger sprint 概率高（单 doc 大 bump 但体量内 / 1.5 会话紧凑）。**Sprint Z 完成 = methodology v0.2 cycle 完成 = ADR-031 #7 触发**。

**风险节制**：如果 §10 体量超预算（≥ 170 行）→ 应用方案 B（per Sprint X /04 实证 / deferred §10.7 vs Self-Test 对比 + §10.8 反模式 → v0.2.1）。

---

## 8. cycle 完成里程碑（关键）

Sprint Z 完成 = methodology v0.2 cycle **8/8 = 100%** ⭐⭐⭐：

```
Sprint V (起步) → 1/8
Sprint W → 3/8
Sprint X → 5/8 (过半)
Sprint Y → 7/8
Sprint Z → 8/8 = 100% ⭐⭐⭐
```

**触发条件达成**：
- ADR-031 §3 #2: ≥ 5 zero-trigger sprint → ✅ 11 (220% over target)
- ADR-031 §3 #7: methodology 7 doc 全 ≥ v0.2 → ✅ **8/8 (含 /00 入口 / 全 v0.2)**

**v1.0 触发条件状态预期**（Sprint Z 后）：

| # | 条件 | 状态 |
|---|------|------|
| 1 | ≥ 5 模块 + ≥ 2 release cycle | ✅ |
| 2 | ≥ 5 zero-trigger sprint | ✅ (11 / 220% over target) |
| 3 | API 稳定 ≥ 6 个月 | ⏳ |
| 4 | ≥ 1 跨域 ref impl | ❌ |
| 5 | 第三方 review ≥ 2 person | ❌ |
| 6 | 累计 v0.x patch ≥ 95% | ⏳ 93.3% |
| 7 | methodology 7 doc 全 ≥ v0.2 | ✅ **8/8** ⭐⭐⭐ NEW |

→ **3/7 ✅ + 2/7 ⏳ + 2/7 ❌**（剩 #4 跨域 ref impl + #5 第三方 review / 等触发 / 不强求）

→ **v1.0 评估议程激活**（per ADR-031 §5 / v0.x cycle 收官 / 进入"等触发"阶段）

---

## 9. 下一步

待用户 ACK 本 brief → Architect 启动 Stage 1（methodology/03 v0.2 / 单批大工作）→ Stage 1.13 + Stage 4 → 一次 commit + push (2 commits 整体 / 不中场 commit)。

Sprint Z+1 候选议程将在 Stage 4 retro §7 提议（基于 cycle 完成后的新阶段）：
- A. v0.5 maintenance sprint（5 候选累积已达触发条件 / 含 brief-template v0.1.5 重编号 checklist 候选）
- B. v0.2.1 polish 单 doc patch（如 /03 v0.2 deferred §X.x → v0.2.1）
- C. 跨域 outreach 主动启动（v1.0 #4 + #5 触发探索）
- D. 等候触发（被动 / 不主动启动新 sprint）

---

**brief 起草完成 / brief-template v0.1.4 第 4 次外部 dogfood / cycle 完成 sprint / 待用户 ACK**
