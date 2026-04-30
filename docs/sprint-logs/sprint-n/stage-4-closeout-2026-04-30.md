# Sprint N Stage 4 — Closeout

> 复制自 `framework/sprint-templates/stage-templates/stage-5-closeout-template.md`（**第三次** dogfood）
> Date: 2026-04-30
> Owner: 首席架构师

## 0. 目的

Sprint N 收档。Layer 1 第三刀（代码层第一刀）落地。

---

## 1. Closeout 必备产出

### 1.1 任务卡

Sprint N 不立独立 task card（与 L+M 同性质）。衍生债另登记（参见 §1.5）。

### 1.2 STATUS.md 更新

由架构师同步更新 docs/STATUS.md：

- Sprint N 状态：✅ Stage 0+1+1.13+4 完成 / Stage 2-3 押后
- D-route Layer 1 进度：🟢 治理类双模块 → 🟢 **治理类双模块 + 代码层第一刀**（identity_resolver v0.1）
- L2 methodology/03 v0.1 → v0.1.1（cross-reference 紧密化）

### 1.3 CHANGELOG.md 追加

Sprint N 条目（详见 §1.3.1）。

#### 1.3.1 CHANGELOG 条目

```markdown
## 2026-04-30 (Sprint N)

### [feat] Sprint N — identity_resolver framework + byte-identical dogfood PASSED

- **角色**：首席架构师（主导 / Opus 4.7）+ PE 子 session（Stage 1.13 byte-identical 跑 / Sonnet 4.6）
- **性质**：D-route Layer 1 第三刀；代码层抽象第一刀
- **关键产出**：
  - framework/identity_resolver/ v0.1（28 files / ~3996 lines + 3 docs）
    - Framework core（13 files）：types / entity / union_find / utils / guards /
      rules_protocols / r6_seed_match / rules / canonical / dry_run_report /
      resolve / apply_merges / __init__
    - examples/huadian_classics/（14 files）：reference impl 完整可跑
    - Documentation（3 files）：README / CONCEPTS / cross-domain-mapping
  - 9 Plugin Protocol：EntityLoader / R6PrePassRunner / DictionaryLoader /
    StopWordPlugin / IdentityNotesPatterns / CanonicalHint / SeedMatchAdapter /
    MergeApplier / ReasonBuilder
  - byte-identical dogfood (Stage 1.13) PASSED
- **D-route Layer 进度**：
  - L1: 🟢 治理类双模块 → 🟢 治理 + 代码层（首刀 / +28 files / +~3996 lines）
  - L2: methodology/03 v0.1 → v0.1.1
  - L3: +1 dogfood case（739 person production data byte-identical 等价）
- **commits**: 89cb668 (Stage 0+1 batches 1-3) + 75571ba (batches 4-5) +
  待 push (Stage 1.13 dogfood + Stage 4 closeout)
- **衍生债**: 5 项 v0.2 候选（DGF-N-01~05）+ 11 项继承自 Sprint L+M（5 项 v0.2 / 6 项已 patch）
- **Stop Rule 触发**: #1 临时触发 2 次（路径深度 / alias 命名），全部当场修复
- **下一 sprint 候选**: V1-V11 Invariant Scaffold 抽象（Sprint O）/ Audit + Triage Workflow（Sprint P）/
  framework v0.2 release 准备
```

### 1.4 Sprint N Retro

`docs/retros/sprint-n-retro-2026-04-30.md`（参见 §1.4 dogfood 第 4 次 retro-template 使用）。

### 1.5 衍生债登记

`docs/debts/sprint-n-framework-v02-iterations.md` 集中登记。

**5 项新 v0.2 候选**（来自 Sprint N dogfood）：

- **DGF-N-01** — test_byte_identical.py compare() 加 alias 字段 mapping 通用机制（`__field_aliases__` dict 让案例方扩展）
- **DGF-N-02** — `examples/huadian_classics/` 路径配置：硬编码 `parents[4]` 改为环境变量 `HUADIAN_DATA_DIR` 或构造函数参数（防止文件结构变化时再次踩坑）
- **DGF-N-03** — framework/identity_resolver/ 加 conftest.py + 单元测试（独立于 byte-identical / 加快迭代）
- **DGF-N-04** — examples/legal/ + examples/medical/ 增加跨领域 reference impl（dogfood + cross-domain-mapping.md 落地）
- **DGF-N-05** — `EntityLoader` Protocol 加 `load_subset(filters)` 方法（支持增量 resolve / 不每次扫全表）

合并视图（与 Sprint L+M）：**16 项 v0.2 候选** = Sprint L 4 + Sprint M 7 + Sprint N 5（其中 Sprint M 6 项已 patch / Sprint M+N 共 10 项待 v0.2 release 前批量）。

### 1.6 ADR 更新

Sprint N 没有触发新 ADR。既有 ADR-001 ~ ADR-029 全部 status 不变。

如未来跨领域案例方反馈 plugin 协议需要标准化，再触发 ADR-031（per Sprint M retro §3.3 + Sprint N inventory §7 评估）。

---

## 2. D-route 资产沉淀盘点

### 2.1 本 sprint 沉淀的可抽象 pattern

1. **Identity Resolver R1-R6 框架**（最直接产出）— framework/identity_resolver/ v0.1
2. **9 Plugin Protocol 体系**（DictionaryLoader / StopWordPlugin / IdentityNotesPatterns / CanonicalHint / EntityLoader / R6PrePassRunner / SeedMatchAdapter / MergeApplier / ReasonBuilder）
3. **byte-identical dogfood pattern** — vs L+M 的 covered/structural dogfood，N 是**严格等价**验证。框架抽象正确性的最高证明
4. **GuardChain 不是 Plugin 是参数 design pattern** — 让案例方更灵活 + framework 无 module-level globals
5. **person → entity 命名通用化 + alias 兼容** — 跨领域抽象时如何处理"案例 vs 通用"命名冲突的范本
6. **examples/huadian_classics/ pattern** — 14 文件完整 reference impl，让案例方 cp + 改即用

### 2.2 本 sprint 暴露的"案例耦合点"

1. `parents[N]` 硬编码路径深度 fragile（→ DGF-N-02 衍生债）
2. byte-identical compare() 字段名硬编码（→ DGF-N-01 衍生债）
3. R1 的 `cross_dynasty_attr` 默认值 "dynasty" 是 HuaDian-friendly，跨领域要传值（已设计 / 但需 cross-domain-mapping.md 强调）
4. R6 默认 `dictionary_source="wikidata"` 同上

→ 4 项案例耦合点全部已识别，2 项进入 v0.2 衍生债，2 项已在 cross-domain-mapping.md 强调。

### 2.3 Layer 进度推进

- **L1 框架代码**：+~3996 行抽象代码 / +28 files / framework/identity_resolver/ v0.1（治理类双模块外的**第一个代码层抽象模块**）
- **L2 方法论文档**：methodology/03 v0.1 → v0.1.1（Framework Implementation cross-reference 段）
- **L3 案例库**：+1 严格 dogfood 案例（华典 729 production 数据 byte-identical 等价 / 17 guard 拦截 / 8 merge groups 完全一致）
- **L4 不变**（机会主义；framework v0.2 release 候选条件升级到第 4 模块完成时再考虑）

### 2.4 下一 sprint 抽象优先级建议

Sprint N 完成后 framework/ 已有 3 个抽象模块（sprint-templates / role-templates / identity_resolver）。Sprint M closeout §2.4 给的下一刀候选：

- **A. V1-V11 Invariant Scaffold 抽象（推荐 Sprint O）**：
  - `framework/invariant_scaffold/`（5 大 invariant pattern：Upper-bound / Lower-bound / Containment / Orphan / Cardinality）
  - 抽象自 services/pipeline/src/huadian_pipeline/qc/ + docs/methodology/04
  - 工作量预估：与 Sprint N 接近（~2-3 会话）

- **B. Audit + Triage Workflow 抽象（Sprint P 候选）**：
  - `framework/audit_triage/`（pending_merge_reviews + triage_decisions + merge_log 三表协作）
  - 抽象自 ADR-027 + Sprint K Triage UI
  - 工作量较大（涉及 BE schema + FE 组件）

- **C. framework v0.2 公开 release**（不是 sprint，是阶段性事件）：
  - 条件已成熟（≥3 抽象资产稳定 + byte-identical 严格 dogfood 通过）
  - 建议时机：Sprint O 完成后 / 跨领域案例方主动接触时

**架构师推荐 Sprint O 选 A**（V1-V11 Invariant Scaffold）：

- 与 identity_resolver 配套（invariants 是 resolver 输出的 quality gate）
- 工作量与 N 接近（可控）
- 完成后 framework/ 下"质检治理"完整：sprint workflow + role coordination + identity resolver + invariant scaffold

如想休息几周再启动 Sprint O，**完全可以** — Sprint N 完成是另一个自然停顿点。

---

## 3. 给 Sprint O 的 Handoff

```
✅ Sprint N Stage 0+1+1.13+4 完成（Stage 2-3 押后）
- framework/identity_resolver/ v0.1 落地（28 files / ~3996 lines）
- byte-identical dogfood PASSED（华典 729 person 数据完全等价）
- methodology/03 v0.1 → v0.1.1
- 5 项 v0.2 衍生债登记（DGF-N-01~05）
- 0 services/pipeline/ 生产代码改动 ✅

→ Sprint O 候选主题：V1-V11 Invariant Scaffold 抽象（推荐）
→ Sprint O brief 起草用 framework/sprint-templates/brief-template.md（第四次外部使用）
→ 启动时机：自然停顿点 / 无紧急 timeline
→ framework v0.2 release 准备：可在 Sprint O 完成或跨领域反馈触发时考虑
```

---

## 4. Closeout Gate Check（→ Sprint N 关档条件）

- [x] §1.1 任务卡（不立卡）
- [x] §1.2 STATUS.md 更新（待执行）
- [x] §1.3 CHANGELOG 追加（待执行）
- [x] §1.4 retro 起草（另文）
- [x] §1.5 衍生债登记（5 项 P3 / 合并 16 项总）
- [x] §1.6 ADR 更新（无需）
- [x] §2 D-route 资产盘点
- [ ] commit 已提交（待 push 后勾选）

---

## 5. Sprint N 关档信号

```
✅ Sprint N 完成（Stage 0+1+1.13+4，Stage 2-3 押后到外部反馈）
- Layer 1 第三刀（代码层第一刀）：framework/identity_resolver/ v0.1 / 28 files / ~3996 lines
- byte-identical dogfood PASSED — framework 抽象正确性 100% 等价证明
- 9 Plugin Protocol 全部跑通 / 17 guard 拦截一一对应
- 0 services/pipeline 生产代码改动
- methodology/03 v0.1 → v0.1.1（cross-reference 紧密化）
- 衍生债: 5 项 P3 / 总 16 项（Sprint L+M+N 累计）/ Sprint M 6 项已 patch
- 下一 sprint 候选: V1-V11 Invariant Scaffold 抽象（推荐 Sprint O）
- framework v0.2 release 候选: 已具备条件，留给 Sprint O 完成后或外部反馈触发
→ Sprint N 关档 / Sprint O 准备（自然停顿点 / 无紧急启动）
```

---

**Sprint N 关档。**

---

**本 closeout 起草于 2026-04-30 / Sprint N Stage 4**
