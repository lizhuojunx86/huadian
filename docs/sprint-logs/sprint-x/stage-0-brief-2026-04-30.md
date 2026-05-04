# Sprint X Stage 0 — Brief

> Status: draft → 待用户 ACK
> Date: 2026-04-30
> Brief-template version: **v0.1.4 第 2 次外部 dogfood**（首次 v0.1.4 dogfood = Sprint W）
> 主导：Architect Opus 4.7 (single-actor)
> Subject: methodology v0.2 cycle 持续 / /06 + /04 → v0.2 / 1.5 会话

---

## 1. 目标

methodology v0.2 cycle 持续推进（per Sprint W retro §8 候选 A）：

1. **批 1**: methodology/06 v0.1.1 → v0.2
   - + §X ADR Template Comparison Pattern (release-trigger ADR-030 vs release-eval ADR-031 vs retroactive ADR-032 / 3 templates first-class 抽出)
   - fold T-V05-FW-001（ADR-032 §5 retroactive lessons → /06 first-class）
2. **批 2**: methodology/04 v0.1.2 → v0.2
   - + §X Self-Test Pattern first-class（per Sprint O 4/4 实证 / 散落 §3.3 + §7 + §8.3 → first-class section）

methodology v0.2 cycle 进度推进：**3/8 → 5/8** ⭐（过半线 / 距 ADR-031 #7 触发还需 3 doc）

---

## 2. 估时表（brief-template v0.1.4 7 子类 / 第 2 次外部 dogfood）

| 子类 | 本 sprint 任务 | 估时 | 实际（待回填）|
|------|--------------|------|--------------|
| Code: 框架 spike | — | — | — |
| Code: 新模块抽象 | — | — | — |
| Code: patch / version bump | — | — | — |
| Docs: cross-ref polish | — | — | — |
| **Docs: new doc 起草** | /06 v0.2 + /04 v0.2 | **~85-95 min** (~45 + ~40) | TBD |
| Docs: ADR / 决策记录 | — | — | — |
| **Closeout / Retro** | stage-4-closeout + retro + STATUS + CHANGELOG + debts | **~25-35 min** | TBD |

**总估时**: ~110-130 min ≈ 1.5 会话（vs Sprint W 1.5 会话 ≈ 120 min 同形态）

**v0.1.4 第 2 次 dogfood 关注点**：
- Sprint W Docs: new doc 起草偏差 5.5%（边缘 ≤ 5%）→ Sprint X 同子类偏差应 ≤ 10%（连续 2 次 dogfood 验证子类 stability）
- Closeout / Retro 子类首验证（Sprint W 含在 Docs 内 / Sprint X 单独拆出）

---

## 3. Stage 路径

```
Stage 0 — brief 起草（本文件）✅
Stage 1 批 1 — methodology/06 v0.1.1 → v0.2
Stage 1 批 2 — methodology/04 v0.1.2 → v0.2
Stage 1.13 — sanity 回归（60 pytest + 5 模块 + ruff/format）
Stage 4 — closeout + retro + STATUS/CHANGELOG + Sprint Y 候选
```

不需 Stage 2/3（无外部 review）。

---

## 4. 改动设计（细节）

### 4.1 批 1 — methodology/06 v0.1.1 → v0.2

**当前 (v0.1.1)**：477 行 / §0-§8 + §9 修订历史 / Sprint U §8 加 cross-ref to /02 + Sprint A-U 31 ADR 演化数据

**v0.2 加段**：

#### 4.1.1 §X ADR Template Comparison Pattern (新 first-class section)

3 类模板 + 各自结构 + 何时用 + 反模式：

| Template | ADR 锚点 | 触发条件 | 必含独有字段 | 何时用 |
|----------|---------|---------|------------|-------|
| **Release-trigger** | ADR-030 | v0.x → v0.(x+1) release 时机决策 | §3 6/6 触发条件 + §5 Validation Criteria（半填充 / 触发后回填）| release sprint 启动前 |
| **Release-eval** | ADR-031 | v(x).0 → v(x+1).0 候选议程评估 | §3 7+ 触发条件 + §5 路径预测（2 路径乐观/保守）| 候选议程评估时 |
| **Retroactive** | ADR-032 | 回填 sprint 应起未起的 ADR | §5 retroactive lessons + status: accepted (retroactive) | gap 识别后回填 |

每个模板列：
- 何时用 / 何时不用
- 必含字段（与基础模板的差异）
- 实证 sprint
- 反模式

#### 4.1.2 fold T-V05-FW-001（ADR-032 §5 retroactive lessons → first-class）

per Sprint W residual debts §2.1 / Sprint X 推荐 fold：
- ADR-032 §5 lessons learned（编号策略 / 何时必要 / 何时不必要）→ /06 §X.3 retroactive template + lessons

#### 4.1.3 § 修订历史 §9 → §10 重编号

**估算**: ~150-180 行加 / 627-657 总行（Stop Rule #3 阈值 600 → **可能触发 / 备 deferred section 方案**）

**Stop Rule 备案**:
- 阈值预警: 600 行 → 当前预算超约 4-9%
- 应对: 如超 600 行，考虑把"反模式扩充"或"实证 sprint table 全表"deferred 到 v0.2.1

### 4.2 批 2 — methodology/04 v0.1.2 → v0.2

**当前 (v0.1.2)**：481 行 / §0-§8 + §9 修订历史 / Sprint S §8 加 cross-ref to /02 跨 stack pattern

**v0.2 加段**：

#### 4.2.1 §X Self-Test Pattern (新 first-class section)

抽离散落在 §3.3 + §7 + §8.3 的 self-test 内容，沉淀为 first-class pattern：

- §X.1 定义 — 在 transaction 中主动注入违反 / verify catch / auto-rollback
- §X.2 vs byte-identical / soft-equivalent dogfood — 第 4 个 dogfood 等级（"主动 dogfood"）
- §X.3 SelfTest Protocol 设计契约（per Sprint O / 4 plugin protocol map）
- §X.4 何时必须配 self-test — critical invariant / 涉及 SQL 阈值的 invariant
- §X.5 跨 invariant 类 framework 启示 — invariant_scaffold 独有 / identity_resolver / audit_triage 没有
- §X.6 实证（Sprint O 4/4 catch + transaction rollback verify）
- §X.7 反模式（self-test 仅断言行 count / 无 transaction rollback / 测试与 invariant 共享 query 模板）

#### 4.2.2 § 修订历史 §9 → §10 重编号

**估算**: ~130-160 行加 / 611-641 总行（Stop Rule #4 阈值 450 → **明确触发 / 必须 deferred** OR **改 Stop Rule 阈值**）

**Stop Rule 备案**:
- 当前 481 行 → +130-160 = 611-641 行 → 远超 450 阈值
- **方案 A**：阈值上调到 700（Sprint W 已实证 /05 532 + /07 426 都接近上限 / 阈值偏紧）→ 需新 ADR or stop-rules patch
- **方案 B**：deferred 部分内容 → §X.6 实证 + §X.7 反模式 押后 v0.2.1
- **推荐方案 B**（保守 / 符合 Sprint V/W zero-trigger 节律）

---

## 5. 关键文件清单

修改：
- `docs/methodology/06-adr-pattern-for-ke.md` (v0.1.1 → v0.2)
- `docs/methodology/04-invariant-pattern.md` (v0.1.2 → v0.2)
- `docs/STATUS.md` (Layer 1+2+4 + §2.2.12 Sprint X + §2.3 Sprint Y)
- `docs/CHANGELOG.md` (Sprint X 块前置)

新建：
- `docs/sprint-logs/sprint-x/stage-0-brief-2026-04-30.md` (本文件)
- `docs/sprint-logs/sprint-x/stage-4-closeout-2026-04-30.md`
- `docs/retros/sprint-x-retro-2026-04-30.md`
- `docs/debts/sprint-x-residual-debts.md`

无 framework code 改动（pure docs sprint）/ 无 ADR 起草（所有改动在 methodology level）。

---

## 6. 收口判据（5 项）

1. methodology/06 v0.1.1 → v0.2（+§X ADR Template Comparison + fold T-V05-FW-001 / Stop Rule #3 阈值 600 内 OR deferred 方案落地）
2. methodology/04 v0.1.2 → v0.2（+§X Self-Test Pattern first-class / Stop Rule #4 阈值 450 内 OR deferred 方案落地）
3. 5 模块 sanity 不回归 + 60 pytest 全绿
4. STATUS / CHANGELOG / retro / 衍生债 + Sprint Y 候选 全 land
5. methodology v0.2 cycle 进度更新：3/8 → **5/8** ⭐（过半线）

---

## 7. Stop Rule 风险评估

| Rule | 风险 | 应对 |
|------|------|------|
| #1 单 batch 工时超 1.5x | 低 | Docs new doc 子类已实证（Sprint W 偏差 5.5%）|
| #2 单 batch 改动 file > 5 | 低 | 各批仅 1 file |
| #3 doc 总行 > 600（/06）| **中** | deferred §X.6/§X.7 反模式到 v0.2.1 OR 单 ADR 例 only |
| #4 doc 总行 > 450（/04）| **高** | **deferred §X.6/§X.7 实证+反模式到 v0.2.1 / 仅留 §X.1-§X.5 first-class 定义 + Protocol + 跨 framework 启示** |
| #5 跨 sprint 决策残留 | 低 | T-V05-FW-001 fold per Sprint W retro §8 已规划 |

**当前预测**：连续第 9 个 zero-trigger sprint 概率高（双 doc 都 deferred 部分内容 / 阈值内合规）。

---

## 8. 下一步

待用户 ACK 本 brief → Architect 启动 Stage 1 批 1（methodology/06 v0.2）→ 中场 commit + push → Stage 1 批 2 → Stage 1.13 + Stage 4。

---

**brief 起草完成 / brief-template v0.1.4 第 2 次外部 dogfood / 待用户 ACK**
