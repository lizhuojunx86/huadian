# Sprint O Brief — V1-V11 Invariant Scaffold 抽象（framework/invariant_scaffold/）

> 起草自 `framework/sprint-templates/brief-template.md` v0.1.1
> Dogfood: brief-template **第四次**外部使用（L 自审 / M 自起草 / N 自起草 / O 自起草）

## 0. 元信息

- **架构师**：首席架构师（Claude Opus 4.7）
- **Brief 日期**：2026-04-30
- **Sprint 形态**：**单 track / single-actor**（与 Sprint L+M 同形态 / 比 Sprint N 简单 — 无 PE 子 session 需求，因为 invariant 本身是 SQL query + assertion，dogfood 也只是跑测试比对）
- **预估工时**：1-2 个 Cowork 会话（与 L+M 接近 / 比 N 短 ~30%）
- **PE 模型**：`N/A (single-actor sprint)`
- **Architect 模型**：`Opus 4.7`
- **触发事件**：Sprint N closeout §2.4 + retro §7.4 推荐 — Sprint O 候选 A "V1-V11 Invariant Scaffold 抽象（推荐）"，用户 ACK 启动
- **战略锚点**：[ADR-028](../../decisions/ADR-028-strategic-pivot-to-methodology.md) §2.3 Q3 + Sprint N closeout §2.4 推荐 + [docs/methodology/04-invariant-pattern.md](../../methodology/04-invariant-pattern.md) v0.1 草案（已起草 / 5 大 pattern 已定义）

---

## 1. 背景

### 1.1 前置上下文

Sprint L+M+N 完成 D-route Layer 1 三模块（sprint-templates + role-templates + identity_resolver / 52 files / ~7700 lines）。Sprint N 含 byte-identical 严格 dogfood 通过。

Sprint O 在 D-route Layer 1 大局中的位置：

```
L1 第一刀 (L)  →  第二刀 (M)  →  第三刀 (N)        →  第四刀 (O)
sprint-tmpl       role-tmpl      identity_resolver     invariant_scaffold
(治理工作流)       (角色协作)     (代码层 R1-R6)        (代码层 invariant)
```

完成后 framework/ 治理 + 代码层"质检治理"就完整：sprint workflow + role coordination + identity resolver + invariant scaffold。

### 1.2 与 Sprint N 的差异

| 维度 | Sprint N | Sprint O |
|------|----------|----------|
| 抽象类型 | 代码 algorithm（R1-R6 + Union-Find + GuardChain + canonical）| 代码 SQL + assertion 模板（V1-V11 invariants）|
| 抽象输入量 | 2394 行 Python | **1031 行** pytest 测试 + methodology/04 |
| 角色配置 | Architect + PE 子 session | **single-actor**（Architect 全程）|
| 工作量 | ~3 会话 | **1-2 会话**（明显简化）|
| dogfood gate | byte-identical（最严格）| 跑 framework + huadian_classics fixture，验证：(a) 所有 5 pattern 跑通 (b) 注入违反 → invariant 触发 (c) 与 production tests 同 schema 输出 |
| 风险等级 | medium | **low-medium**（vs N 的 medium / 比 L+M 的 low 略复杂）|
| 模型选型 | Architect Opus + PE Sonnet | **Architect Opus** 全程 |
| ADR 触发概率 | 低 | 低 |

### 1.3 不做的事（Negative Scope）

- ❌ **不重构 services/pipeline/tests/test_invariants_v*.py** — 抽出新代码到 framework/，不改测试本身
- ❌ **不改变 V1-V11 SQL 行为** — framework 抽出的 invariant runner 跑出来必须与原 pytest 测试等价
- ❌ **不引入 ORM 抽象 over SQL** — invariants 是直接 SQL，简单为美（vs identity_resolver 的复杂 plugin 体系）
- ❌ **不抽 services/pipeline/src/huadian_pipeline/qc/** — 那是 TraceGuard 集成（运行时质检），不是 invariants（数据正确性）；qc/ 抽象留 Sprint P+ 候选
- ❌ **不抽 Audit + Triage Workflow** — Sprint P 候选
- ❌ **不做 framework v0.2 release** — 等 Sprint O 完成后再考虑（条件已成熟 + 4 模块完整后 release 信号更强）
- ❌ **不启动新 ingest sprint**（违反 C-22）
- ❌ **不做 Stage 2-3 外部审**（默认押后到外部反馈触发）

---

## 2. 目标范围

### 2.1 单 Track — V1-V11 Invariant Scaffold 抽象

**目标**：抽出领域无关的 `framework/invariant_scaffold/` v0.1，让任何 KE 项目可以：

1. 用 5 大 invariant pattern（Upper-bound / Lower-bound / Containment / Orphan / Cardinality）注入自己的 domain SQL
2. 框架统一跑所有 invariants + 输出 violations
3. 框架支持 self-test pattern（注入违反 → 验证 invariant 真能 catch）
4. bootstrap：每次 sprint 收口必跑全部 invariants

**抽象目标分层**：

| 层级 | 内容 | 抽象比例 |
|------|------|---------|
| 🟢 完全领域无关 | 5 pattern SQL template（参数化 entity / attr 名）/ Violation 数据契约 / InvariantRunner 主流程 / SelfTestRunner protocol | ~60% |
| 🟡 接口无关 + 实现专属 | DBPort（query 接口 — 让案例方 plugin SQL backend）/ FixtureManager（self-test 注入 / 清理 — 案例方实现 schema-specific 注入）| ~25% |
| 🔴 案例 reference impl | 华典 V1/V8/V9/V10/V11 具体 SQL 内容（persons / person_names / seed_mappings 等表名）/ slug invariant / merge invariant | ~15% |

**具体动作**：

#### 2.1.1 `framework/invariant_scaffold/` 目录结构（候选）

```
framework/invariant_scaffold/
  README.md                          ~150 行
  CONCEPTS.md                        ~200 行  | 5 pattern 概念 + bootstrap pattern
  cross-domain-mapping.md            ~120 行  | 6 领域 invariants 适配
  __init__.py                        ~100 行  | 30+ exports

  types.py                           ~80 行   | Violation / InvariantResult / etc
  invariant.py                       ~120 行  | Invariant 抽象基类 + 5 pattern subclass
  runner.py                          ~180 行  | InvariantRunner 主流程（跑所有 invariants）
  port.py                            ~80 行   | DBPort Protocol（query 接口）
  patterns/
    __init__.py
    upper_bound.py                   ~80 行
    lower_bound.py                   ~80 行
    containment.py                   ~80 行
    orphan_detection.py              ~80 行
    cardinality_bound.py             ~80 行
  self_test.py                       ~150 行  | SelfTestRunner + FixtureManager Protocol

  examples/huadian_classics/
    __init__.py                      ~30 行
    db_port.py                       ~80 行   | asyncpg adapter
    fixtures.py                      ~120 行  | 注入违反 + 清理（V1/V8/V9/V10/V11 各自）
    invariants_v1.py                 ~50 行   | upper-bound 实例
    invariants_v8.py                 ~80 行   | containment 实例
    invariants_v9.py                 ~50 行   | lower-bound 实例
    invariants_v10.py                ~120 行  | orphan detection (3 sub-rules)
    invariants_v11.py                ~50 行   | cardinality 实例
    invariants_slug.py               ~50 行
    invariants_merge.py              ~80 行
    test_byte_identical.py           ~150 行  | dogfood: 跑 framework runner vs 原 pytest 输出比对
```

约 **20-22 文件 / ~1900-2200 行**（比 Sprint N 28 files / 3996 lines 小 ~50%）。

#### 2.1.2 docs/methodology/04 v0.1 → v0.1.1

加 §X Framework Implementation cross-reference 段（与 methodology/01 + 02 + 03 同模式）。

**完成判据**（5 项）：

- ✅ `framework/invariant_scaffold/` 全部文件就位
- ✅ 5 pattern subclass 正确实现（每个有 `query()` + `from_template()` + 1+ 单元测试）
- ✅ examples/huadian_classics/ 7 个 invariant 跑出与原 pytest 测试一致结果（byte-identical 软版 — vs Sprint N 严格 byte-identical / 这次 invariant 已经是 0 violations，等价更容易）
- ✅ docs/methodology/04 v0.1 → v0.1.1 cross-reference
- ✅ services/pipeline/tests/test_invariants_v*.py 完全未改（git diff 验证）

### 2.2 Track 2

不适用（单 track sprint）。

---

## 3. Stages

### Stage 0 — Inventory + 5 pattern 详细映射

**目标**：

- 读完 6 个 test_invariants_*.py + slug/merge 测试 → 标每个 invariant 属于哪个 pattern
- 设计 Invariant 基类 API + 5 pattern subclass API
- 设计 DBPort + FixtureManager Protocol
- 起草顺序

**输出**：`stage-0-inventory-2026-04-30.md`（~3000-4000 字）

**Gate 0**：

- 7 个 invariants（V1/V8/V9/V10a-c/V11/slug/merge）每个分配到一个 pattern
- Invariant 基类 + 5 pattern subclass 接口设计完成
- DBPort + FixtureManager Protocol 设计完成
- 起草顺序就位

### Stage 1 — 起草 framework/invariant_scaffold/

**子集大小**：20-22 文件 / 1-2 会话内完成核心起草。

**5 批起草顺序**：

1. **数据契约层**（types / invariant / port，~3 文件 / ~280 行）— 30 分钟
2. **5 pattern subclass**（patterns/upper_bound / lower_bound / containment / orphan_detection / cardinality_bound，5 文件 / ~400 行）— 60 分钟
3. **主流程**（runner / self_test，~2 文件 / ~330 行）— 30 分钟
4. **examples/huadian_classics/**（10 文件 / ~860 行）— 60 分钟
5. **文档**（README / CONCEPTS / cross-domain-mapping，3 文件 / ~470 行）— 30 分钟

**Gate 1**：

- 所有文件 syntax OK + ruff check + format 通过
- sanity tests（10+ 个 pytest tests）通过

### Stage 1.13 — Dogfood 软 byte-identical 验证

**目标**：用 examples/huadian_classics/ 跑全部 7 个华典 invariants，输出与原 pytest 测试一致（每个 invariant 都报 0 violations）。

**软版**（vs Sprint N 严格版）：

- 因为 invariants 在 production 都是 0 violations 状态，等价验证 = "framework runner 跑出来都是 0"
- 加 self-test 验证：注入违反 → invariant 触发 fail → 清理 → 复位

**Gate 1.13**：

- 7 个 invariants 框架 runner 跑出与原 pytest 一致（都 0 violations）
- self-test 注入违反 → 检测到 → 清理后复位（验证框架 catch 能力）

### Stage 4 — Closeout（无 Stage 2-3 / 押后）

- STATUS / CHANGELOG / retro / 衍生债 / methodology/04 cross-reference

---

## 4. Stop Rules

1. **invariant runner 跑 huadian_classics 出现非 0 violations**（最严格）→ Stop，立即修复 framework 或回 Stage 1
2. **抽象边界判定混淆**（某 invariant 不能映射到 5 pattern 中任一）→ Stop，触发 Architect 重审 + 必要时新增第 6 pattern
3. **意外触碰 services/pipeline/tests/ 生产测试**（git diff 必须 0 changes）→ Stop
4. **Sprint O 工时 > 3 会话**（超出 1-2 会话预估上限 50%+）→ Stop，评估是否拆 Sprint O.1 / O.2
5. **触发新 ADR ≥ 1 个**（vs Sprint N 阈值 2 — 本 sprint 更不应该触发 ADR）→ Stop
6. **framework 代码量 > 2500 行**（vs Sprint N 阈值 3000 — 本 sprint 输入小 / 不应该比 N 大）→ Stop，重审是否过度抽象
7. **self-test 注入违反不能被 invariant catch**→ Stop，invariant SQL 设计错

---

## 5. 角色边界

| 角色 | 活跃度 | 主要职责 |
|------|-------|---------|
| 首席架构师 | 🟢 主导 | 全 stage 自驱执行 |
| 其余 9 角色 | ⚪ 暂停 | 不参与（single-actor sprint）|

---

## 6. 收口判定

- ✅ `framework/invariant_scaffold/` 20-22 文件全部就位
- ✅ 5 pattern subclass 实现 + 7 huadian invariants 抽到 examples/
- ✅ Stage 1.13 dogfood 通过（7 invariants 跑 0 violations + self-test catch 注入违反）
- ✅ docs/methodology/04 加 cross-reference 段（v0.1 → v0.1.1）
- ✅ STATUS / CHANGELOG 更新
- ✅ Sprint O retro 完成
- ✅ 衍生债登记
- ✅ services/pipeline/tests/ 完全未改（git diff 验证）
- ✅ Sprint P 候选议程拟定（Audit + Triage Workflow / framework v0.2 release）

---

## 7. 节奏建议

**舒缓节奏（推荐）**：

- 会话 1：Stage 0 inventory + Stage 1 第 1-3 批（数据契约 + 5 pattern + 主流程，~10 文件）
- 会话 2：Stage 1 第 4-5 批（examples + 文档，~13 文件）+ Stage 1.13 dogfood + Stage 4 closeout

**极致压缩**：

- 单会话内完成全部（Sprint L+M 同节奏）

**判定**：抽象输入比 Sprint N 简单 ~50%（1031 vs 2394 行 / 无 dispatch / 无 Union-Find），单会话可行性更高。

---

## 8. D-route 资产沉淀预期

- [x] 框架代码 spike：`framework/invariant_scaffold/` v0.1
- [x] methodology/04 cross-reference 段（v0.1 → v0.1.1）
- [x] 跨领域 mapping 表（cross-domain-mapping.md / 6 领域 invariants 适配）
- [x] 案例素材：5 pattern 的 6 领域填写示例
- [ ] 新 ADR：不预期

**Layer 进度推进**：

- L1: 🟢 治理 + 代码层第一刀（identity_resolver）→ 🟢 **治理 + 代码层双刀**（+invariant_scaffold / +~2000 行 / +20-22 files / +1 抽象资产）
- L2: methodology/04 v0.1 → v0.1.1
- L3: +1 dogfood case（华典 7 invariants 0 violations + self-test catch 验证）
- L4: framework v0.2 release 候选条件**继续加强**（4 模块完整 / 立即 release 信号最强）

---

## 9. 模型选型

- **Architect 主 session**：Opus 4.7（全程 / 与 Sprint N 同）
- **PE 子 session**：N/A（不需要；单 actor / 比 Sprint N 简单）
- **理由**：invariants 是 SQL + assertion + 5 pattern subclass 设计 — Opus 强项；不需要 PE 跑大型 dry-run 比对（dogfood 是简单的"7 个 invariants 都 0 violations" + self-test）

---

## 10. Dogfood 设计

### 10.1 brief-template / closeout / retro / role-templates 第 4 次外部使用

- brief-template 第 4 次（本 brief）
- closeout-template 第 4 次（Stage 4）
- retro-template 第 4 次（Stage 4）

### 10.2 framework/invariant_scaffold 自审 dogfood

- huadian_classics 7 个 invariants 跑通 = 5 pattern subclass 全部正确
- self-test 注入违反 → catch → 清理 = SelfTestRunner 验证有效

vs Sprint N byte-identical 严格等价，本次"软版"等价更容易（invariants 都是 0 状态）。

### 10.3 起草本 brief 暴露的发现

无新 brief-template 改进候选。brief-template v0.1.1（after Sprint M DGF-M-02+03 patch）对 Sprint O 适配良好。

→ Sprint M v0.1.1 patch 第 3 sprint 验证有效（M / N / O 都用得顺手）。

---

## 11. 决策签字

- 首席架构师：__ACK 待签 (2026-04-30)__
- 用户：__ACK 待签 (2026-04-30)__
- 信号：本 brief 用户 ACK 后 → Sprint O Stage 0 启动

---

**本 brief 起草于 2026-04-30 / brief-template v0.1.1 第四次外部使用**
