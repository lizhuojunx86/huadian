# Sprint O Stage 4 — Closeout

> 复制自 `framework/sprint-templates/stage-templates/stage-5-closeout-template.md`（**第四次** dogfood）
> Date: 2026-04-30
> Owner: 首席架构师

## 0. 目的

Sprint O 收档。Layer 1 第四刀（代码层第二刀 / 治理 + 代码层 4 模块完整）落地。

---

## 1. Closeout 必备产出

### 1.1 任务卡

Sprint O 不立独立 task card（与 L+M+N 同性质）。

### 1.2 STATUS.md 更新

由架构师同步更新：

- Sprint O 状态：✅ Stage 0+1+1.13+4 完成 / Stage 2-3 押后
- D-route Layer 1 进度：3 模块 → **4 模块完整**（治理类双 + 代码层双：sprint-templates + role-templates + identity_resolver + invariant_scaffold）
- L2 methodology/04 v0.1 → v0.1.1（cross-reference）

### 1.3 CHANGELOG.md 追加

参见 §1.3.1 模板。

#### 1.3.1 CHANGELOG 条目

```markdown
## 2026-04-30 (Sprint O)

### [feat] Sprint O — invariant_scaffold framework + dogfood PASSED

- **角色**：首席架构师（single-actor / Opus 4.7 全程）
- **性质**：D-route Layer 1 第四刀；代码层抽象第二刀
- **关键产出**：
  - framework/invariant_scaffold/ v0.1（34 files / ~3040 lines + 3 docs）
    - Framework core（12 + 5 patterns + __init__ = 18 files）
    - examples/huadian_classics/（13 files / 11 invariants + 4 self-tests）
    - Documentation（3 files: README + CONCEPTS + cross-domain-mapping）
  - 5 pattern subclass + 4 Plugin Protocol（vs Sprint N 9 个 / 简单 ~50%）
  - dogfood: 11/11 invariants pass + 4/4 self-tests caught
  - methodology/04 v0.1 → v0.1.1
- **D-route Layer 进度**: 3 模块 → 4 模块完整（治理类 + 代码层双刀）
- **commits**: 19f879b (Stage 0+1 batches 1-3) + edf31ad (batches 4-5) +
  待 push (Stage 1.13 dogfood + Stage 4 closeout + slug path fix)
- **衍生债**: 4 项 v0.2 候选（DGF-O-01~04）/ 累计 20 项（L+M+N+O）
- **Stop Rule 触发**: #1 临时触发 1 次（slug path bug — DGF-N-02 复发），当场修复
- **下一 sprint 候选**: Sprint P Audit + Triage Workflow 抽象 / framework v0.2 release
```

### 1.4 Sprint O Retro

`docs/retros/sprint-o-retro-2026-04-30.md`（**第四次** retro-template dogfood）。

### 1.5 衍生债登记

`docs/debts/sprint-o-framework-v02-iterations.md`。

**4 项新 v0.2 候选**：

- **DGF-O-01**（**重提 + 升级 DGF-N-02**）：framework examples 中所有 `Path(__file__).parents[N]` 硬编码改环境变量驱动 — Sprint N+O 跨 sprint 踩同样的坑，**优先级升 P3 → P2**
- **DGF-O-02**：framework/invariant_scaffold/ 加 conftest.py + pytest 单元测试（vs 当前的 sanity check oneliner / 与 Sprint N DGF-N-03 同 pattern）
- **DGF-O-03**：cross-domain examples（legal / medical）—— Sprint N DGF-N-04 同 pattern，等跨领域案例方接触触发
- **DGF-O-04**：Containment 的 `in_python_predicate` 接受 `Awaitable[bool] | bool` 但通过 hasattr 判 await — 改为 `inspect.isawaitable()` 更标准

合并视图（与 Sprint L+M+N）：**20 项 v0.2 候选** = Sprint L 4 + Sprint M 7 + Sprint N 5 + Sprint O 4（其中 Sprint M 6 项已 patch / 14 项待 v0.2 release 前）。

### 1.6 ADR 更新

Sprint O 没有触发新 ADR。既有 ADR-001 ~ ADR-029 全部 status 不变。

---

## 2. D-route 资产沉淀盘点

### 2.1 本 sprint 沉淀的可抽象 pattern

1. **Invariant scaffold 框架**（最直接产出）— framework/invariant_scaffold/ v0.1
2. **5 pattern subclass + from_template helper** — 让案例方一行注册 invariant
3. **Self-test 注入式验证 pattern** — 守护"invariant SQL 写错也会假通过"的元 bug
4. **DBPort 双模式（pool / with_connection）pattern** — 让 invariant query 与 self-test transaction 共用一个 protocol
5. **`_RollbackSentinel` exception 强制 rollback pattern** — 优雅实现 transactional self-test

### 2.2 本 sprint 暴露的"案例耦合点"

1. `parents[N]` 硬编码（DGF-O-01）— Sprint N+O 跨 sprint 同 bug
2. Pattern 数量稳定在 5（无新增需求）— 但 Sprint O 11 个 invariants 全 fit 进 5 pattern → 5 pattern 可能就是 universal set
3. Self-test 编写需要写大量 INSERT SQL — 可考虑 fixture 工具简化

### 2.3 Layer 进度推进

- **L1 框架代码**：+~3040 行抽象代码 / +34 files / framework/invariant_scaffold/ v0.1（**第 4 个抽象模块完整**）
- **L2 方法论文档**：methodology/04 v0.1 → v0.1.1（cross-reference 段）
- **L3 案例库**：+1 dogfood 案例（华典 11 invariants 跑通 + 4 self-tests catch）
- **L4 不变**（framework v0.2 release 候选条件**完全成熟** — 4 模块完整 / byte-identical + soft dogfood 都 pass / 20 v0.2 候选）

### 2.4 下一 sprint 抽象优先级建议

framework/ 4 模块完整后，下一刀候选：

- **A. Sprint P — Audit + Triage Workflow 抽象**（推荐）：
  - `framework/audit_triage/`（pending_merge_reviews + triage_decisions + merge_log 三表协作）
  - 抽象自 ADR-027 + Sprint K Triage UI
  - 工作量较大（涉及 BE schema + FE 组件 reference impl）

- **B. framework v0.2 公开 release**（不是 sprint，是阶段性事件）：
  - 条件**完全成熟**
  - 建议时机：Sprint P 完成后 / 或外部反馈触发

- **C. v0.2 patch 集中处理 14 项待办**（轻量 sprint）：
  - 把 Sprint L+M+N+O 的 v0.2 衍生债批量 fix
  - 完成后正式 v0.2 release

**架构师推荐 Sprint P 选 C → 然后 v0.2 release → 然后 Sprint Q audit_triage**：
- C 是最有价值的中间步骤（清债 + release）
- v0.2 release 后框架对外可见性显著升级
- audit_triage 留给 Sprint Q（跨度更大 / 有时间准备）

---

## 3. 给 Sprint P 的 Handoff

```
✅ Sprint O Stage 0+1+1.13+4 完成（Stage 2-3 押后）
- framework/invariant_scaffold/ v0.1 落地（34 files / ~3040 lines）
- 11 invariants + 4 self-tests dogfood PASSED
- methodology/04 v0.1 → v0.1.1
- 4 项 v0.2 衍生债登记（DGF-O-01~04）
- 0 services/pipeline 生产代码改动 ✅

→ Sprint P 候选：v0.2 patch 集中处理（推荐 / 14 项待办）or audit_triage 抽象 or framework v0.2 release
→ 架构师推荐顺序：v0.2 patch → v0.2 release → audit_triage（Sprint Q）
→ 启动时机：自然停顿点 / 无紧急 timeline
```

---

## 4. Closeout Gate Check

- [x] §1.1 任务卡（不立卡）
- [x] §1.2 STATUS.md 更新（待执行）
- [x] §1.3 CHANGELOG 追加（待执行）
- [x] §1.4 retro 起草（另文）
- [x] §1.5 衍生债登记（4 项 P3 / 1 项 P2 升级）
- [x] §1.6 ADR 更新（无需）
- [x] §2 D-route 资产盘点
- [ ] commit 已提交（待 push 后勾选）

---

## 5. Sprint O 关档信号

```
✅ Sprint O 完成（Stage 0+1+1.13+4，Stage 2-3 押后）
- Layer 1 第四刀（代码层第二刀）：framework/invariant_scaffold/ v0.1 / 34 files / ~3040 lines
- 5 pattern + 4 Plugin Protocol + InvariantRunner + SelfTestRunner
- dogfood PASSED — 11/11 invariants + 4/4 self-tests
- methodology/04 v0.1 → v0.1.1
- 衍生债: 4 项（含 1 项 P2 升级 DGF-O-01 = DGF-N-02 复发）
- framework v0.2 release 候选条件: 完全成熟（4 模块完整 + dogfood 全过 + 20 v0.2 候选）
- 下一 sprint 候选: v0.2 patch（推荐）/ Sprint P audit_triage / v0.2 release
→ Sprint O 关档 / Sprint P 准备（自然停顿点 / framework 4 模块完整里程碑）
```

---

**Sprint O 关档。**

---

**本 closeout 起草于 2026-04-30 / Sprint O Stage 4**
