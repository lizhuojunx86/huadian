# Sprint AA Retro — Layer 2 维护态首 sprint / v0.5 maintenance / 清 3 candidates / 1 会话紧凑

> Date: 2026-04-30
> 主导: Architect Opus 4.7 (single-actor)
> Sprint 形态: v0.5 maintenance sprint / cycle 完成后维护态首 sprint
> 工时: ~80 min ≈ 1 会话紧凑
> Stop Rule 触发: **0**（连续第 12 个 zero-trigger sprint / 240% over ADR-031 §3 #2 target）
> 17th external use of retro-template

---

## 1. What went well

### 1.1 维护态首 sprint 模板验证

per Sprint Z residual debts §6 维护态工作流预测 vs Sprint AA 实证：

| 维度 | 预测 | 实证 | 一致 |
|------|------|------|-----|
| 触发条件 | v0.5 押后 ≥ 3 候选累积 | 4 候选累积 / 实际清 3 | ✅ |
| 形态 | 1-1.5 会话 / 5-batch maintenance | 1 会话紧凑 / 3-batches | ✅ |
| 节律 | cycle 完成后偶发 | Sprint Z 完成后第一个 maintenance | ✅ |
| 期望频率 | ~每 2-3 个月一次 | (待后续 sprint 验证) | ⏳ |

→ Sprint Z residual debts §6 工作流预测**一次命中**。维护态模板 ready for Sprint AB / AC / 等。

### 1.2 方案 B 紧凑写法成功避 Stop Rule #4 触发 ⭐

/04 v0.2.1 fold §8.6: 555 → 597 行 / 99.5% Stop Rule #4 阈值 600。**紧凑写法**（V9 1 例代替 4 例详写 + 反模式 4 条不展开）让体量恰好内于阈值。

→ **方案 B 设计模式实证**：deferred 到 v0.x.1 后 fold 时**仍需紧凑**（不能假设 v0.x.1 阈值放宽）/ 紧凑路径稳定。

### 1.3 brief-template v0.1.5 polish 自我演化 dogfood

用 v0.1.4 estimate 自己升级到 v0.1.5（meta-dogfood）。结果：
- 估时 ~15-20 min / 实际 ~15 min / 偏差 0% (内于区间下界)
- v0.1.5 加 §2.5 重编号 checklist + §2.6 里程碑庆祝节制
- 满足 P3 复发升级 P2 触发条件（连续 3 sprint X+Y+Z 同 issue）+ Sprint Z retro §2.2 自我反思

### 1.4 12 sprint zero-trigger 持续 ⭐⭐⭐ (240% over target)

P→Q→R→S→T→U→V→W→X→Y→Z→**AA** 连续 12 sprint 0 Stop Rule 触发。强化 ADR-031 §3 #2（≥ 5 zero-trigger / 当前 12 / **240% over target**）。

vs Sprint Z 220% / +20pp / 持续递增。

### 1.5 Single source of truth cross-ref 网建立

/02 §14.4 + §15.4 cross-ref polish：让 trigger vs eval ADR 对比从 /02 inline 转为引 /06 §8 first-class 3 模板。

→ **避免重复定义 / 维护单源真相**：未来如 ADR 模板演化 / 仅在 /06 §8 修改 / /02 自然反映（vs 旧版需双 doc 同步改）。

### 1.6 cross-ref polish 子类基线偏保守 (新发现)

| 子类 | v0.1.4 估时表 | Sprint AA 实证 |
|------|-------------|--------------|
| Docs: cross-ref polish | ~95-105% 估算 | -33% (大幅低估) |

**新发现**：Docs: cross-ref polish 子类**实证比预期更快**。可能原因：
- cross-ref polish 通常 ≤ 15 min（实证 /02 ~10 min）
- v0.1.4 估时表把 cross-ref polish + 复杂双向 ref 混算（如 /04 v0.2 §8 cross-ref 重编号 vs Sprint AA /02 简单引用）
- 简单 cross-ref polish (≤ 5 行加) vs 复杂 cross-ref polish (≥ 15 行加 + 重编号) 应分子类

→ **触发 Sprint AB candidate**: brief-template v0.1.6 candidate / cross-ref polish 子类细化（简单 vs 复杂）。

---

## 2. What could improve

### 2.1 cross-ref polish 子类首验证才发现基线偏差

Sprint W-Z 6 次 dogfood 都是 Docs: new doc 起草子类 / 没有 cross-ref polish 子类独立验证。Sprint AA 才首次出现 cross-ref polish 子类独立验证 / 发现 -33% 偏差。

**改进建议**：
- 不是 brief-template 设计有问题（v0.1.4 7 子类化方向正确）
- 而是 dogfood 覆盖度有 gap（同一子类反复 dogfood / 其他子类未验证）
- 后续 sprint 如出现 cross-ref polish / Code spike / Code 新模块 / Code patch / ADR 等子类，应记录 dogfood 数据 / 验证基线
- v0.1.6 candidate 待至少 2-3 次 cross-ref polish dogfood 后再调整基线（不一次性改）

### 2.2 维护态 sprint vs cycle 期间 sprint 节律差异

cycle 期间（V→Z）每个 sprint 都有"推进 cycle"的明确目标 / 紧迫感。Sprint AA 进入维护态后 / 节律变化：

- cycle 期间：每 sprint 1-2 doc bump / 紧凑节律
- 维护态：每 sprint 清 N candidates / 偶发触发

**反思**：维护态 sprint 的"价值密度"低于 cycle 期间（per Sprint AA 单次清 3 candidates vs Sprint W/X/Y/Z 各推 1-2 doc bump）。这是**正常的** / 不应追求 cycle 期间的紧凑节律。

→ pattern: 维护态 sprint **不应追求高频** / 累积 ≥ 3 候选时再触发 / 不积累 ≤ 2 候选不主动起。

### 2.3 brief-template v0.1.5 加 §2.5 + §2.6 后 brief 长度增加

brief-template 现在 ~370 行 (vs v0.1.4 ~340)。每次 brief 起草需"复制全文 + 改填" → 起草工时增加。

**反思**：brief-template 持续累积 polish 段（§2.5 / §2.6 / 等）有膨胀风险。

**改进建议**：v0.1.6+ 时考虑**精简化** / 把 § 2.5 / §2.6 等"checklist 段"重构为"附录 / 不必每 sprint 都 inline"（如 brief 仅引 link 到 catalog）。当前 v0.1.5 不动 / Sprint AB 候选评估。

---

## 3. Lessons learned

### 3.1 Layer 2 维护态首 sprint 验证 Sprint Z 工作流预测

Sprint Z residual debts §6 提出维护态工作流（v0.2.x patch / v0.5 maintenance / 跨域 outreach / v1.0 评估更新）。Sprint AA 实证：

- ✅ v0.2.x patch (本 sprint /02 + /04 v0.2.1)
- ✅ v0.5 maintenance (本 sprint 形态)
- ⏳ 跨域 outreach (未启动)
- ✅ v1.0 评估更新 (本 retro §1.4 / zero-trigger 计数更新)

→ 4 类工作流中 3 类已实证 / 维护态运行模式确立。

### 3.2 dogfood 覆盖度的盲区

Sprint W-Z 6 次 dogfood 都是 Docs: new doc 起草子类。**这是 dogfood 偏差（sample bias）**：
- 期间所有 sprint 都是 cycle 推进 sprint / 主要工作是新 doc 起草
- cross-ref polish / Code spike 等其他 5 子类**长期未独立验证**

→ 维护态 sprint 是验证其他子类的好机会。Sprint AA 验证 cross-ref polish / 后续 sprint 如有 Code 类工作 / 应专门 dogfood 记录。

### 3.3 "P3 复发升级 P2"暗规则的实操判断

per /02 §11: 跨 sprint 同 bug 复发 ≥ 2 次 → P3 升级 P2。

Sprint X+Y+Z §修订历史子节重编号 issue 连续 3 sprint → 满足 ≥ 2 触发条件。但本质是 **brief-template 改进而非代码 bug** / 不正式升级 P2 / 直接进 v0.5 maintenance。

→ pattern: §11 暗规则不是机械执行 / 应判断"是 process bug" vs "是 code bug" / process 类升 v0.5 maintenance / code 类升 P2 立即修。

---

## 4. Process tweaks

### 4.1 dogfood 数据点扩大子类覆盖

后续 sprint 如出现 Code 类 / cross-ref polish / ADR 等子类 / 应在 stage-4-closeout §3 扩展 dogfood 记录。当前仅 Docs: new doc 起草子类有充分数据。

### 4.2 cross-ref polish 子类基线观察

Sprint AA -33% 偏差 / 不立即调 v0.1.5 / 等 ≥ 2-3 次 cross-ref polish dogfood 后再决定 v0.1.6 调整。

### 4.3 维护态 sprint 触发条件确认

Sprint AA 实证维护态 sprint 触发条件 ≥ 3 候选累积。后续 sprint 如累积 < 3 候选 / 不主动起 maintenance sprint / 等下批累积。

---

## 5. Effort breakdown

| 阶段 | 估时 | 实际 |
|------|------|------|
| Stage 0 (inventory + brief) | ~10 min | ~10 min ✓ |
| Stage 1 批 1 (/02 v0.2.1) | ~15 min | ~10 min ✓ (-33%) |
| Stage 1 批 2 (/04 v0.2.1 fold §8.6) | ~25-35 min | ~25 min ✓ (区间下界) |
| Stage 1 批 3 (brief-template v0.1.5) | ~15-20 min | ~15 min ✓ (区间下界) |
| Stage 1.13 (sanity) | ~5 min | ~5 min ✓ |
| Stage 4 (closeout + retro) | ~25-30 min | ~15 min (TBD 回填 / 简洁路径) |
| **总计** | **~95-115 min** | **~80 min ✓ (-16% / 内于下界)** |

紧凑路径达成 / brief 估算 v0.1.4 第 5 次 dogfood 整体偏差 -16%（vs Sprint Z -7% / 趋势：维护态 sprint 偏差比 cycle 期间略大）。

---

## 6. v0.5 maintenance sprint 节律观察（首次实证）

| Sprint | 形态 | 工时 | 候选数 |
|--------|------|------|-------|
| Sprint P (v0.2 release prep + maintenance fold) | 复合 | 1.5 会话 | 8 |
| **Sprint AA (v0.5 maintenance)** | **纯 maintenance** | **1 会话紧凑** | **3** |

**模板验证**：维护态 sprint = 1 会话紧凑 / 3-batches / pure docs + template patch / 1 file per batch。

→ 后续 v0.5 maintenance sprint (Sprint AC / AD / etc) 应基于此模板。

---

## 7. Sprint AB 候选议程

cycle 完成后默认路径仍为 **D 等候触发**（per Sprint Z retro §7.4 + Sprint AA §1.1 维护态模板验证）。

如用户主动启动新 sprint：

### 7.1 候选 A — v0.5 maintenance sprint（小 / 仅 1 candidate + 1 候选未登记）

- 候选 1: brief-template v0.1.6 cross-ref polish 子类基线调整（per Sprint AA §1.6 新发现 / 待 ≥ 2-3 次 cross-ref polish dogfood 后触发 / 当前不主动起）
- 候选 2: /02 v0.2.1 polish §X.X 元 pattern 增补（候选未登记 / 等第三方 review 反馈触发）

→ 当前**累计 ≤ 2 候选 / 不主动起 maintenance**（per §4.3 维护态触发条件 ≥ 3）。

### 7.2 候选 B — 跨域 outreach 主动启动

- 探索 v1.0 触发条件 #4 + #5
- 战略层工作 / 非 sprint level
- 推荐时机：用户希望主动驱动 v1.0 路径时

### 7.3 候选 D（推荐）— 等候触发

- 不启动新 sprint / 等外部信号
- 维护态默认状态
- per D-route §7 Negative Space 哲学

### 7.4 推荐

**Sprint AB 默认路径 = D 等候触发** ⭐

原因：
- v0.5 maintenance 触发条件未达成（候选 ≤ 2 / 阈值 ≥ 3）
- 跨域 outreach 是战略层 / 非 sprint level / 等用户主动驱动
- Layer 2 维护态首 sprint 模板已验证 / 后续维护态运行 ready

---

**Sprint AA retro 完成于 2026-04-30 / Architect Opus / 17th external retro-template use / Layer 2 维护态首 sprint**
