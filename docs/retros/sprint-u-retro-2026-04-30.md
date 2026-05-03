# Sprint U Retro — ADR-031 + methodology/06 v0.1.1 + /07 v0.1 + /00 §2 sync

> 起草自 `framework/sprint-templates/retro-template.md` v0.1.1
> Dogfood: retro-template **第 11 次**外部使用

## 0. 元信息

- **Sprint ID**: U
- **完成日期**: 2026-04-30
- **主题**: ADR-031 v1.0 候选议程评估 + methodology/06 v0.1.1 cross-ref + methodology/07 v0.1 新起草 (cross-stack abstraction) + /00 §2 sync (6→7)
- **预估工时**: 1.5-2 个 Cowork 会话
- **实际工时**: **1.5 会话 ≈ 155 min**（紧凑路径达成 ✓）
- **主导角色**: 首席架构师（Claude Opus 4.7）— single-actor sprint

---

## 1. Sprint 任务回顾

### 1.1 Stage 顺序与产出（精简模板 §3.B）

| Stage | 主导 | 状态 | 关键产出 |
|-------|------|------|----------|
| Stage 0 inventory + brief 起草 | Architect | ✅ | brief-template v0.1.3 第 3 次外部 dogfood (Docs 主导 / 累积趋势观察) |
| Stage 1 批 1 — ADR-031 v1.0 候选议程评估 | Architect | ✅ | 196 行 / 7 触发条件 / 不立即 release / 路径预测 |
| Stage 1 批 2 — methodology/06 v0.1.1 | Architect | ✅ | + §8 4 段 cross-ref + Sprint A-U 31 ADR 演化数据点 |
| **会话 1 中场 commit + push (`345658d` + `bb05463`)** | — | ✅ | main `bb05463` |
| Stage 1 批 3 — methodology/07 v0.1 新起草 | Architect | ✅ | 301 行 / 9 段 / cross-stack abstraction pattern first-class doc ⭐ |
| Stage 1 批 4 — methodology/00 §2 6→7 sync + bump v0.1.1 | Architect | ✅ | + 第 7 行 + 实证锚点列 + footer + §3.1 7→8 + 修订历史 |
| Stage 1.13 sanity 回归 | Architect | ✅ | 60/60 in 0.07s + ruff/format + 5 模块 + 8 doc 全部存在 |
| Stage 4 closeout + retro | Architect | ✅ | 4 docs |

### 1.2 数据 / 工程基线 Δ

| 维度 | Sprint 前 | Sprint 后 | Δ |
|------|---------|---------|-----|
| ADR 数 | 30 | **31** (+ ADR-031) | +1 ⭐ |
| methodology doc 数 | 7 | **8** ⭐ (+ /07 cross-stack abstraction) | +1 |
| methodology /00 §2 大核心抽象 | 6 大 | **7 大** ⭐ | +1 |
| methodology v0.1.x 完成 doc | 5 (/01 v0.1.2 / /02 v0.1.1 / /03 v0.1.2 / /04 v0.1.2 / /05 v0.1.1) | **8** (+ /00 v0.1.1 + /06 v0.1.1 + /07 v0.1) | +3 |
| v1.0 候选触发条件 | 未锁定 | **7 项锁定**（per ADR-031 §3）⭐ | 评估完成 |
| Stop Rule 触发 | 0 (Sprint T 接续) | **0**（连续 6 sprint）| 持续强化 |
| pytest tests | 60 | 60 | 不变 |
| L4 触发数 | 2 (v0.2.0 + v0.3.0) | 2 (+ ADR-031 release-eval ADR / 不算 release tag) | 1 release-eval |

---

## 2. 工作得好的部分（What Worked）

### 2.1 brief-template v0.1.3 第 3 次 dogfood 验证 Docs 主导稳定性

vs Sprint S 第 1 次（Code=0 / Docs 主导 / < 10% 偏差） + Sprint T 第 2 次（Code 主导 / Code 类 47% 偏差），Sprint U 第 3 次（Code=0 / Docs 主导 / **< 10% 偏差**）：

| Sprint | Code 类 | Docs 类 | Closeout 类 | 总偏差 |
|--------|--------|--------|----------|------|
| S (Docs 主导) | N/A (0) | ~120/120 min ✓ | 30/45 min（小估）| < 10% |
| T (Code 主导) | **47%**（95/3-4h）⚠️ | ~75/120 min ✓ | 30/30 min ✓ | Code 类爆表 |
| **U (Docs 主导)** | N/A (0) | **125/150 min ✓** | 30/45 min（小估）| **< 10% ✓** |

→ **v0.1.3 模板对 Docs 主导稳定**（2 次实证 / Sprint S + U）；**Code 主导偏保守**（Sprint T 单次实证 / 触发 v0.4 候选 T-V04-FW-002 子类拆分方向正确）。

**沉淀**：累积 3 次 dogfood 数据 → 第 4 次（Sprint V 起草时如有 Docs 主导）应再次验证 / 第 5 次（如有 Code 主导）应观察 v0.4 candidate fold 后的偏差变化。

### 2.2 methodology/07 first-class 详细抽象一次完成

vs methodology/02 §13 跨 stack 抽象 pattern 仅 4 段简介，Sprint U 批 3 起草 methodology/07 v0.1（301 行 / 9 段）实证：

- 详细抽象内容**几乎完全来自 Sprint Q + T 实证锚点**（per Sprint S retro §2.3 "元 pattern 必须有 ≥ 1 实证锚点"约定的延续）
- §3 3 种 dogfood 等价性等级表 + §4 3 种 stack 关系组合实证表 = 跨 doc 综合（合并 /02 §13 + /03 §9 + /04 §8 + /05 §7 数据点）
- §5 dogfood infra 选项（user local vs Docker compose）= Sprint T T-V03-FW-005 实证延伸
- §7 反模式 5 项 = Sprint Q + T 内未发生但跨域 fork 案例方易踩的坑

**沉淀**：methodology v0.x 起草时"先有简介在 /02 §X / 后有 first-class doc 在 /0Y"是合理演化路径（vs 一开始就独立 doc 起草 / risk 可能 over-design without 实证）。

### 2.3 ADR-031 vs ADR-030 对比模板沉淀

ADR-030 是 release-trigger ADR（6/6 条件 ✅ → 立即 release），ADR-031 是 release-eval ADR（2/7 条件 ✅ → 不立即 release）。两者形成对比模板：

| 维度 | release-trigger (ADR-030) | release-eval (ADR-031) |
|------|--------------------------|------------------------|
| 触发条件评估 | 列条件 + 评估 + ≥ 阈值 → release | 列条件 + 评估 + < 阈值 → 不 release / 锁定 |
| 决策动作 | 启动 release sprint | 锁定条件 + 路径预测 |
| Validation Criteria | release 完成后回填（5/6 + 1 待 push）| 下一个 release ADR 起草时回填 |
| 时机 | release prep 完成时 | sprint zero-trigger 触发评估时（per Sprint R retro §5.1）|

**沉淀**：未来 v0.4 / v0.5 / v1.0 release 决策可根据当前条件状态选 trigger 或 eval ADR 模板。

### 2.4 1.5 会话紧凑路径 + 0 Stop Rule + 6 sprint zero-trigger

延续 Sprint P+Q+R+S+T 节奏，Sprint U 第 6 个 zero-trigger sprint：
- 实际工时 1.5 会话（vs 预算 1.5-2 / 紧凑路径）
- 0 Stop Rule 触发
- 累积 6 sprint zero-trigger 进一步强化 framework 稳定信号

**沉淀**：v1.0 触发条件 #2 "Maintenance + Release sprint 累计 ≥ 5 zero-trigger"在 Sprint T 已达成，Sprint U 持续强化（6 zero-trigger）= **超额完成**该条件。但其他 5 项触发条件多数仍 ⏳ / ❌（per ADR-031 §4），不立即 release v1.0 是正确决策。

---

## 3. 改进点（What Didn't Work）

### 3.1 methodology/07 行数 301 vs 估算 250（~20% 偏差）

写 §3 3 种 dogfood 等价性等级表 + §4 3 种 stack 组合实证表时，加了 cross-doc 综合的内容（合并 /02 §13 + /03 §9 + /04 §8 + /05 §7 数据点），略超 brief 估算。

**改进建议**：
- 不严重（仍远低于 Stop Rule #4 阈值 400）
- 起草新 methodology doc 时应留 ~25% buffer（vs Sprint S /01 / /03 / /04 cross-ref polish 的精确估算）
- 起草新 doc vs cross-ref polish 是不同复杂度类型 / 应在 v0.1.4 brief-template polish 时反映（per Sprint T 触发的 v0.4 候选 T-V04-FW-002 Code 类拆分子类同思路 / 但本 case 是 Docs 类拆分子类）

→ 触发新 v0.4 候选 T-V04-FW-003（"brief-template §2.1 Docs 类估算分子类：'cross-ref polish' vs 'new doc 起草'"）。

### 3.2 audit_triage 抽象 (Sprint Q) 当时未起 ADR

methodology/06 v0.1.1 §8.2 实证锚点表显式标注 "Sprint Q audit_triage 抽象 / **应起 ADR 但未起**" → identified gap。

**改进建议**：
- 已记 v0.4 候选（待 fold 进 v0.4 maintenance sprint）
- 候选 ADR 编号：ADR-029.5 或 ADR-031.5（用 .5 表示"应回填的历史 ADR"）— 或重编号为 ADR-032（如不在意编号 sequential 严格性）
- 内容：跨 stack 抽象决策记录（TS prod → Python framework / Approach B / 6 Plugin Protocol design）
- 估算：~30 min（参考 ADR-027 + ADR-030 模板）

→ 触发新 v0.4 候选 T-V04-FW-004（"回填 audit_triage 抽象 ADR-032"）。

### 3.3 用户 brief preview 时 / 我倾向 brief-template polish 候选 / 提前预测

类似 Sprint S retro §3.3 同问题：本 brief §10.4 起草时已说"无新 brief-template 改进候选" — 但实际 Sprint U 内 §3.1 触发新 v0.4 候选 T-V04-FW-003。

**改进建议**：
- brief §10 dogfood 设计段不预言"无新候选" / 改写"待 retro 时验证"
- retro §6 衍生债登记是发现 brief 漏识别的 candidate 的正常机制 / 不算 brief 错误
- 已沉淀为下次 brief 起草风格 reminder

不严重。

---

## 4. Stop Rule 触发回顾

> 触发处理协议见 `framework/sprint-templates/stop-rules-catalog.md` §7。

**无触发**（连续第 **6** 个 zero-trigger sprint：P → Q → R → S → T → U）。

| Rule | 类别 (catalog §) | 触发原因 | 架构师裁决 (A/B/C/D) | trigger 文件 |
|------|----------------|---------|--------------------|-------------|
| — | — | 无触发 | — | — |

---

## 5. Lessons Learned

### 5.1 工程层面

#### "评估 sprint" 形态的成熟（Sprint S + U 累计 2 次实证）

Sprint S 是首次评估 sprint（v0.3 release timing），Sprint U 是第二次（v1.0 候选议程评估）。两次累积揭示评估 sprint 的标准结构：

```
评估 sprint typical structure:
  批 1 — 主 ADR 起草（trigger 或 eval / per Sprint S+U）— ~45 min
  批 2-N — methodology v0.x cross-ref polish + 实证锚点 — ~25 min × N
  Stage 4 closeout — ~30 min
  total: 1-2 会话
```

**沉淀**：methodology/02 v0.2 候选段（Sprint V+ 起草）可正式收录"Eval Sprint Pattern"（与 Maintenance Sprint Pattern / Release Sprint Pattern 并列 / 同模板）。

#### methodology 文档群完整化里程碑（7 → 8 doc）

Sprint U 完成后 methodology 文档群完整：
- 1 framework overview (/00)
- 7 core patterns (/01-/07)

7 patterns 与 framework 5 模块的对应关系（per /00 §2 v0.1.1 footer）：
- 5 patterns 单射 framework 5 模块（role / sprint / identity / invariant / audit）
- 2 patterns 跨 framework（ADR / cross-stack）

**沉淀**：methodology 文档群"完整化"是 framework v1.0 的必要条件之一（per ADR-031 §3 #7）。但当前仍 v0.1.x / 距 v0.2 cycle 还需 ≥ 4 sprint。

#### v1.0 候选议程评估的"非触发"决策价值

ADR-031 决定不立即 release v1.0 看似"消极"，但实际上：
- 锁定 7 触发条件 → 防止"漂移"（之后 Sprint V+N 工作不可任意调低条件）
- 预测路径时间线（2026-10 ~ 2027-04）→ 给跨域案例方接触提供 outreach 锚点
- 评估 sprint 本身是 release prep 的 first-class 形态（per Sprint S retro §5.1）

**沉淀**："不立即 release" 决策的 ADR 模板可被任何 v0.x → 高 milestone 评估复用（如未来 v2.0 / v3.0 候选议程评估）。

### 5.2 协作层面

Sprint U 是 single-actor sprint，无跨角色协作。

但 ADR-031 §5 路径预测中提到 "跨域案例方 outreach"（DGF-N-04 触发 #4 + #5）— 这是 framework v0.x → v1.0 转型期 Architect 角色的**新职责维度**：从纯框架抽象转向"主动跨外部 outreach"。

**沉淀**：role-templates/chief-architect.md v0.2.1 §工作风格 可考虑加 v0.2.2 段："framework v0.x → v1.0 转型期 Architect 应主动 outreach 跨域案例方"（v0.4 候选 T-V04-FW-005 候选）。

但 outreach 是非 sprint 单元的工作（属于"持续后台任务"）/ 不应 fold 进单 sprint。

### 5.3 模型选型 retro

**Architect = Opus 4.7（全程）**：合适。

写 ADR-031 综合 7 触发条件评估 + 写 methodology/07 综合 Sprint Q+T+多 doc cross-ref + 写 closeout 长 context 综合 → Opus 是必要的。

但 batch 4 (methodology/00 §2 sync) 实际只是 +12 行 markdown / 模板化 / **Sonnet 完全可胜任**。未来纯 sync sprint（如 v0.4 release sprint 中"5 模块 README §0+§8 + version bump"批次）可考虑 Sonnet 作为成本优化候选（不阻塞当前 Opus 全程的稳定性）。

---

## 6. 衍生债登记

本 sprint 收口后：

**新 v0.4 候选 2 项**（合并 Sprint S+T 留存 → 累计 v0.4 候选 4 项）：

| ID | 描述 | 优先级 | 来源 |
|----|------|--------|------|
| (Sprint S) T-V04-FW-001 | chief-architect §工程小细节 v0.2.2 加 commit message hygiene 规则 | P3 | Sprint S retro §3.2 |
| (Sprint T) T-V04-FW-002 | brief-template §2.1 Code 类估算分子类 | P3 | Sprint T retro §3.1 |
| **T-V04-FW-003** | brief-template §2.1 Docs 类估算分子类（"cross-ref polish" vs "new doc 起草"）| P3 | 本 retro §3.1 |
| **T-V04-FW-004** | 回填 audit_triage 抽象 ADR-032（Sprint Q 应起未起的 ADR）| P3 | 本 retro §3.2 |

押后清单（不变）：
- v0.2: 2 项（DGF-N-04 + DGF-N-05 / 等外部触发）
- v0.3: 0 项

详见 `docs/debts/sprint-u-residual-debts.md`。

---

## 7. D-route 资产沉淀盘点

### 7.1 本 sprint 沉淀的可抽象 pattern

1. **"评估 sprint" 形态的标准结构**（per §5.1）— 可写入 methodology/02 v0.2 候选段 "Eval Sprint Pattern"
2. **release-trigger ADR vs release-eval ADR 对比模板**（per §2.3）— 可被未来 release 决策复用
3. **methodology 文档群完整化里程碑**（5 patterns 单射 framework 模块 + 2 patterns 跨 framework）— v0.x → v1.0 必要条件之一
4. **brief 内 Docs 类估算分子类需求**（cross-ref polish vs new doc 起草 / 累积 3 次 dogfood 暴露）— 触发 v0.4 候选 T-V04-FW-003
5. **ADR 历史回填规则**（Sprint Q 应起 ADR 未起 → 触发 ADR-032 回填 / 触发 v0.4 候选 T-V04-FW-004）

### 7.2 本 sprint 暴露的"案例耦合点"

无新案例耦合（评估 + methodology sprint）。

methodology/07 §6 跨域 fork 启示中明确指出"应该做 / 不应该做"5+5 = 10 条规则 / 让跨域 fork 案例方有清晰 anti-pattern 防御（vs Sprint Q methodology/05 的 5+5 反模式表 / 模式延续）。

### 7.3 Layer 进度推进

- L1: 5 模块 v0.3.0 不变
- L2: 7 doc → **8 doc**（+ /07 cross-stack abstraction pattern / 第 7 大核心抽象）⭐ + /00 v0.1.1 + /06 v0.1.1
- L3: 不变
- L4: + ADR-031（release-eval ADR / 与 ADR-030 release-trigger 形成对比模板）

### 7.4 下一 sprint 抽象优先级建议

按 ADR-031 §6.4 + Sprint T retro §7.4 综合：

1. **Sprint V 候选 A**：methodology v0.2 cycle 起步 sprint（推荐 / 1.5-2 会话 / 选 1-2 doc 从 v0.1.x → v0.2 / per ADR-031 触发条件 #7）
2. **Sprint V 候选 B**：v0.4 maintenance sprint（fold T-V04-FW-001 ~ -004 / 当前 4 候选累积成熟 / 可触发 / 1-1.5 会话）
3. **Sprint V 候选 C**：跨域 reference impl (legal) 跨域 outreach 启动 sprint（per ADR-031 触发条件 #4 + #5 / 但需外部接触 / 非主动驱动）
4. **A + B 合并**（推荐 / 1.5-2 会话 / 与 Sprint S+T+U 同模式 / methodology v0.2 第 1 doc + v0.4 maintenance fold）

---

## 8. 下一步（Sprint V 候选议程）

依据本 retro 发现 + ADR-031 §6.4 路径：

- **优先选 候选 A + B 合并**（methodology v0.2 cycle 起步 + v0.4 maintenance / 1.5-2 会话）
  - 推荐 methodology/02 → v0.2 作为第 1 doc（per Sprint U §5.1 触发 "Eval Sprint Pattern" / "Release Sprint Pattern" 加段需求 / methodology/02 是元 pattern 中心节点）
  - v0.4 maintenance fold 4 候选（T-V04-FW-001 ~ -004 / 各 ~5-30 min / 累计 ~70 min）
- 候选 C 不主动启动（等案例方触发）

不要做的事：

- ❌ 不开新 framework 模块（5 模块齐备已是阶段终点 / methodology/02 §12）
- ❌ 不动 framework v0.3 ABI（保稳定到 v0.4 / v1.0 release）
- ❌ 不立即 release v1.0（per ADR-031 §2 决策 / 距触发条件还差 5/7）
- ❌ 不在 Sprint V 内**立即起 v1.0 release ADR**（候选议程评估 sprint 已在 Sprint U 完成 / Sprint V 是后续 maintenance + iter）

---

## 9. 决策签字

- 首席架构师：__ACK 2026-04-30 (Architect)__
- 用户：__ACK 待签__
- 信号：本 retro 用户 ACK + commit + push → **Sprint U 关档 / Sprint V 候选议程激活**

---

**Sprint U retro 起草于 2026-04-30 / retro-template v0.1.1 第 11 次外部使用 / Architect Opus**
