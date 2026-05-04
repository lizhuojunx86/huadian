# Sprint V Retro — v0.4 maintenance fold + methodology/02 v0.2 起步

> 起草自 `framework/sprint-templates/retro-template.md` v0.1.1
> Dogfood: retro-template **第 12 次**外部使用

## 0. 元信息

- **Sprint ID**: V
- **完成日期**: 2026-04-30
- **主题**: v0.4 maintenance fold 4 候选 (T-V04-FW-001 ~ -004) + methodology/02 v0.1.1 → v0.2 (v0.x cycle 起步)
- **预估工时**: 1.5-2 个 Cowork 会话
- **实际工时**: **1.5 会话 ≈ 150 min**（紧凑路径达成 ✓）
- **主导角色**: 首席架构师（Claude Opus 4.7）— single-actor sprint

---

## 1. Sprint 任务回顾

### 1.1 Stage 顺序与产出（精简模板 §3.B）

| Stage | 主导 | 状态 | 关键产出 |
|-------|------|------|----------|
| Stage 0 inventory + brief 起草 | Architect | ✅ | brief-template v0.1.3 第 4 次外部 dogfood (Docs 主导) |
| Stage 1 批 1 — ADR-032 audit_triage retroactive | Architect | ✅ | 196 行 / status accepted (retroactive) / 6/6 ✅ Validation |
| Stage 1 批 2 — chief-architect §工程小细节 v0.3.1 | Architect | ✅ | + 第 4 条 commit message hygiene + role-templates v0.3.1 patch entry |
| Stage 1 批 3 — brief-template v0.1.4 | Architect | ✅ | §2.1 7 子类拆分 + sprint-templates v0.3.1 patch entry |
| **会话 1 中场 commit + push (`7c5ce84`)** | — | ✅ | main `7c5ce84`（3 commits）|
| **Stage 1 批 4 — methodology/02 v0.1.1 → v0.2** ⭐ | Architect | ✅ | + §14 Eval Sprint Pattern + §15 Release Sprint Pattern + 重组 §9 (4→6 patterns) + §16 修订历史 / 716 行 |
| Stage 1.13 sanity 回归 | Architect | ✅ | 60/60 in 0.26s + 5 模块 v0.3.0 + ruff/format clean |
| Stage 4 closeout + retro | Architect | ✅ | 4 docs |

### 1.2 数据 / 工程基线 Δ

| 维度 | Sprint 前 | Sprint 后 | Δ |
|------|---------|---------|-----|
| ADR 数 | 31 | **32** (+ ADR-032 retroactive) | +1 ⭐ |
| methodology /02 版本 | v0.1.1 (4 元 pattern) | **v0.2** (6 元 pattern + 重组总览) ⭐ | 大 bump |
| methodology v0.2 doc 数 | 0 | **1** (/02 ⭐) | +1 (cycle 起步) |
| brief-template 版本 | v0.1.3 (3 大类) | **v0.1.4** (7 子类) | +1 polish |
| role-templates 版本 | v0.3.0 | **v0.3.1** (chief-arch v0.3.1 +1 工程小细节) | +1 patch |
| sprint-templates 版本 | v0.3.0 | **v0.3.1** (brief-template v0.1.4 包装) | +1 patch |
| v0.4 押后 | 4 | **0** ⭐ | -4 (全 fold land) |
| 累计 patch 落地率 | 24/26 = 92.3% | **28/30 = 93.3%** ⭐ | +1pp |
| Stop Rule 触发 | 0 (Sprint U 接续) | **0**（连续 7 sprint）⭐⭐ | 持续强化 |
| pytest tests | 60 | 60 | 不变 |

---

## 2. 工作得好的部分（What Worked）

### 2.1 brief-template v0.1.3 §2.1 第 4 次 dogfood 持续验证（< 10% 偏差延续）

vs Sprint S+U Docs 主导 < 10%（实证 2 次），Sprint V 第 4 次 dogfood 同样 < 10% 偏差：
- 估算 ~120 min Docs / 实际 ~110 min（精度 ~92%）
- 估算 ~30 min Closeout / 实际 ~30 min ✓
- → **Docs 主导稳定性 3 sprint 累计实证**（vs Code 主导仅 1 次实证 / 偏差 47%）

**沉淀**：v0.1.4 (Sprint V fold) 应该解决 Code 主导 + new doc 起草子类问题。**Sprint W+ 第 5 次外部 dogfood** 应该用 v0.1.4 估时表（不再 v0.1.3）→ 验证 7 子类是否解决。

### 2.2 4 v0.4 候选一次性全 fold land（Sprint U 累积 + Sprint V 触发）

Sprint U 累积 4 v0.4 候选（T-V04-FW-001 ~ -004）/ 接近 maintenance ≥ 5 阈值。Sprint V 选择**不等更多累积**直接 fold：
- 优势：避免候选数膨胀 / scope 失控
- 实证：fold 4 项实际 ~60 min（含 ADR-032 30 min + chief-arch 5 min + brief-template 25 min）+ batch 4 不算 v0.4 fold
- 4 v0.4 全 land → push v0.4 押后 = 0

**沉淀**：v0.x maintenance sprint 触发条件可适度灵活（≥ 5 候选是上限阈值 / ≥ 3 候选 + 累积 ≥ 2 sprint 时也合理触发）。

### 2.3 ADR-032 是 first-class retroactive ADR（沉淀 retroactive 模板）

ADR-032 是 framework v0.x 演进首个 retroactive ADR。沉淀 §5 lessons learned：
- §5.1 何时 retroactive ADR 必要 / §5.2 何时不必要 / §5.3 编号策略

**沉淀**：retroactive ADR 模板可被未来类似情境复用（"应起 ADR 但未起 → 后续回填"）。methodology/06 v0.2 候选段（Sprint W+ 起草）可加 retroactive 子段。

### 2.4 methodology/02 v0.2 大 bump（v0.x cycle 第 1 doc）

Sprint V 批 4 加 §14 Eval Sprint Pattern + §15 Release Sprint Pattern 是**结构性变化**：
- 加 2 段 first-class pattern（vs 4 段 polish 是 v0.1.x）
- 重组 §9 总览（4 → 6 patterns / + 实证 sprint 列）
- 与 framework v0.x → v0.(x+1) 演化节奏对齐（version semantics 一致）

**沉淀**：methodology v0.x → v0.(x+1) bump 标准 = "≥ 1 段新 first-class pattern + 重组结构 + ≥ 1 sprint 实证锚点"（vs polish 仅加 cross-ref / 实证锚点段不算结构变化）。

---

## 3. 改进点（What Didn't Work）

### 3.1 Sprint U 预测的 v0.1.4 sub-class "可被同 sprint 内 self-validate" 未发生

Sprint U brief §10.4 / Sprint V brief §10.4 都暗示"Sprint V fold v0.1.4 后 + 同 sprint 用 v0.1.4 估时表 = 自我验证"。**实际 Sprint V brief 是用 v0.1.3 起草**（commit `7c5ce84` v0.1.4 落地于 batch 3 / brief 起草于 batch 0 之前）。

**改进建议**：
- 不严重（v0.1.4 待 Sprint W+ 第 5 次外部 dogfood）
- 但暴露了"同 sprint 内 polish + dogfood 同步"的逻辑陷阱（polish 落地 ≠ 立即可用 / 需要下一 sprint 起草时使用）
- 已沉淀为下次 sprint brief 起草风格 reminder（不算独立 debt）

### 3.2 ADR-032 §5 retroactive lessons 是否应 fold 到 methodology/06

ADR-032 §5 给出了 retroactive ADR 的 lessons learned，但这些 pattern 应该在 methodology/06 v0.2 或 /02 v0.2 中 first-class 收录（vs 仅 ADR §5）。

**改进建议**：
- 已记 v0.4 候选（待 methodology/06 v0.2 起草时 fold）→ T-V05-FW-001 候选
- 不严重（ADR §5 是合理临时记录 / methodology v0.2 cycle 时 fold 即可）

### 3.3 §14 Eval Sprint Pattern + §15 Release Sprint Pattern 与 §02 §10 Maintenance 的 cross-ref 完整度

§14 + §15 在 brief drafting 时聚焦"自身定义"，与 §10 + §13 等其他 patterns 的 cross-ref 不够紧密（vs §14.3 4 维对比表已是 cross-ref 的高水平）。

**改进建议**：
- 不严重（已有对比表 / vs §10 / §15）
- 可在 methodology/02 v0.2.1 polish 时再加 cross-ref 段
- 已沉淀 v0.5 候选（不算独立 debt）

---

## 4. Stop Rule 触发回顾

> 触发处理协议见 `framework/sprint-templates/stop-rules-catalog.md` §7。

**无触发**（连续第 **7** 个 zero-trigger sprint：P → Q → R → S → T → U → V）。

| Rule | 类别 (catalog §) | 触发原因 | 架构师裁决 (A/B/C/D) | trigger 文件 |
|------|----------------|---------|--------------------|-------------|
| — | — | 无触发 | — | — |

---

## 5. Lessons Learned

### 5.1 工程层面

#### "v0.x cycle 起步 sprint" 形态实证

Sprint V 是 framework v0.x 演化中**首次 methodology v0.x → v0.(x+1) cycle 起步 sprint**。沉淀模板：

```
v0.x cycle 起步 sprint typical structure:
  批 1-3: maintenance fold（v0.x 候选清空 / 与 maintenance sprint 同 batch 模式）
  批 4: 主 doc v0.x → v0.(x+1) 大 bump（≥ 1 段新 first-class pattern）
  Stage 4 closeout + retro（注明 v0.x cycle 进度 / 1/8 doc 类）
```

vs 同 sprint 仅 maintenance（no methodology bump）/ vs 仅 methodology bump（no maintenance fold）：
- 合并 sprint = 1.5-2 sessions / vs 拆 2 sprint = 2-3 sessions
- 合并不增加复杂度（v0.4 fold + methodology bump 工作正交 / 互不阻塞）

**沉淀**：methodology/02 v0.3 候选段（待 Sprint W+ 起草）可加 "v0.x cycle 起步 sprint pattern"（与 Maintenance / Eval / Release 并列 / 7 patterns）。

#### "first-class retroactive ADR" 模板沉淀

ADR-032 §5 lessons 是 framework v0.x 演化中关键 missing piece：

- 何时 retroactive ADR 必要（决策 cross-cutting + 已实证 + 跨外部 reviewer 需透明）
- 何时不必要（patch / methodology 可覆盖 / 后续 ADR superseded）
- 编号策略（顺序 ADR-X vs 小数 ADR-X.5）

**沉淀**：methodology/06 v0.2 候选段（待 Sprint W+ 起草）可加 retroactive ADR 子段。

### 5.2 协作层面

Sprint V 是 single-actor sprint，无跨角色协作。

但 ADR-032 retroactive 让 Sprint Q 决策有 first-class 记录 = **跨外部 reviewer 透明化**（per chief-architect role 输出格式）。这是 framework v0.x → v1.0 转型期 Architect 角色的"向后修补"职责。

**沉淀**：未来类似情况（如 Sprint W+ 发现 Sprint X 应起 ADR）应**主动起 retroactive ADR**（vs 在 retro 中提及但不形式化）。

### 5.3 模型选型 retro

**Architect = Opus 4.7（全程）**：合适。

methodology/02 v0.2 大 bump（§14 + §15 + 重组 §9）需要长 context 综合 Sprint S+T+U+P+Q 多 sprint 实证 + 写作风格统一 + 表格设计精确 → Opus 必要。

但批 2+3 是 polish-only / 模板化 / **Sonnet 完全可胜任**（per Sprint S+T+U+V retro §5.3 同结论）。未来 maintenance + polish 混合 sprint 可考虑混合 model（Opus 大批 + Sonnet 小批）/ 但当前 Opus 全程稳定性 > model switch 复杂度。

---

## 6. 衍生债登记

本 sprint 收口后：

**新 v0.5 候选 2 项**（已 fold 4 v0.4 候选 / 累计 v0.5 候选 2 项 / 远低于 ≥ 5 触发阈值）：

| ID | 描述 | 优先级 | 来源 |
|----|------|--------|------|
| T-V05-FW-001 | methodology/06 v0.2 起草时 fold ADR-032 §5 retroactive lessons | P3 | 本 retro §3.2 |
| T-V05-FW-002 | methodology/02 v0.2.1 polish §14+§15 与其他 patterns 的 cross-ref（vs 当前主要靠 §9 总览 + §14.3 对比表）| P3 | 本 retro §3.3 |

押后清单（不变 / v0.4 已全清）：
- v0.2: 2 项（DGF-N-04 + DGF-N-05 / 等外部触发）

详见 `docs/debts/sprint-v-residual-debts.md`。

---

## 7. D-route 资产沉淀盘点

### 7.1 本 sprint 沉淀的可抽象 pattern

1. **"v0.x cycle 起步 sprint" 形态**（Sprint V 首次实证 / 1.5-2 会话 / maintenance fold + main doc bump 合并 / 待 methodology/02 v0.3 候选段收录）
2. **"first-class retroactive ADR" 模板**（ADR-032 §5 / 何时必要 / 编号策略 / 待 methodology/06 v0.2 收录）
3. **methodology v0.x → v0.(x+1) bump 标准**（≥ 1 段新 first-class pattern + 重组结构 + ≥ 1 sprint 实证锚点 / 实证 Sprint V /02 v0.1.1 → v0.2）
4. **brief-template v0.1.4 7 子类估时**（待 Sprint W+ 第 5 次 dogfood 验证）
5. **commit message hygiene 规则**（chief-architect §工程小细节 v0.3.1 / Sprint R commit `35f371d` 教训沉淀）

### 7.2 本 sprint 暴露的"案例耦合点"

无新案例耦合（maintenance + methodology iter / 不动 case 数据）。

### 7.3 Layer 进度推进

- L1: 5 模块 v0.3.0 不变 / sprint-templates + role-templates v0.3.1 patch
- L2: methodology/02 v0.1.1 → **v0.2**（v0.x cycle 起步 / 1/8 doc）⭐
- L3: 不变
- L4: + ADR-032 retroactive（首个 retroactive ADR / 跨外部 reviewer 历史完整性）

### 7.4 下一 sprint 抽象优先级建议

按 ADR-031 §6.4 + Sprint V retro §6 + methodology v0.2 cycle 状态：

1. **Sprint W 候选 A**：methodology v0.2 cycle 持续（推荐 / 1-2 doc per sprint / 1.5 会话）
   - 候选 doc 优先级（per /00 §2 7 大核心抽象）：
     - /05 audit-trail-pattern.md v0.1.1 → v0.2（Sprint Q audit_triage 实证支撑 + ADR-032 retroactive 加段）
     - /07 cross-stack-abstraction-pattern.md v0.1 → v0.2（Sprint Q+T 双实证支撑 + Hybrid Release Sprint Pattern 加段）
     - /06 adr-pattern-for-ke.md v0.1.1 → v0.2（fold T-V05-FW-001 retroactive ADR 子段）
2. **Sprint W 候选 B**：methodology v0.2 cycle 起步合并 v0.5 maintenance（如有 ≥ 3 v0.5 候选累积 / 当前仅 2 项 / 不急）
3. **Sprint W 候选 C**：跨域 outreach / reference impl (legal) — 押后等触发
4. **Sprint W 候选 D**：v1.0 触发条件持续追踪（自动 / 不算独立 sprint）

---

## 8. 下一步（Sprint W 候选议程）

依据本 retro 发现：

- **优先选 候选 A**（methodology v0.2 cycle 持续 / 1-2 doc / 1.5 会话）
  - 推荐 1: /05 audit-trail-pattern.md v0.1.1 → v0.2（与 ADR-032 retroactive 紧密关联 / 沉淀 audit_triage 抽象后的更新）
  - 推荐 2: /07 cross-stack-abstraction-pattern.md v0.1 → v0.2（加 Sprint T Hybrid Release Sprint Pattern 实证 + methodology/02 v0.2 §15.3 Hybrid 段引用）
  - 单 sprint 1-2 doc 取决于工时预算
- 候选 C+D 不主动启动
- 候选 B 等 v0.5 累积更多再触发

不要做的事：

- ❌ 不立即 release v1.0（per ADR-031 §2 决策 / 当前 2/7 触发条件）
- ❌ 不动 framework v0.3 ABI
- ❌ 不在 Sprint W 内同时 bump > 2 doc 到 v0.2（避免 scope creep / methodology v0.2 cycle 应该持续 ≥ 4 sprint）
- ❌ 不立即 release v0.4（v0.4 候选 0 / 也无 v0.5 累积 / 不急）

---

## 9. 决策签字

- 首席架构师：__ACK 2026-04-30 (Architect)__
- 用户：__ACK 待签__
- 信号：本 retro 用户 ACK + commit + push → **Sprint V 关档 / Sprint W 候选议程激活（methodology v0.2 cycle 持续 / 推荐 /05 + /07 之一）**

---

**Sprint V retro 起草于 2026-04-30 / retro-template v0.1.1 第 12 次外部使用 / Architect Opus**
