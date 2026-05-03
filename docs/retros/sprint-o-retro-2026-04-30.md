# Sprint O Retro

> 复制自 `framework/sprint-templates/retro-template.md`（**第四次** dogfood）
> Owner: 首席架构师

## 0. 元信息

- **Sprint ID**: O
- **完成日期**: 2026-04-30
- **主题**: V1-V11 Invariant Scaffold 抽象（framework/invariant_scaffold/）
- **预估工时**: 1-2 个会话
- **实际工时**: ~2 个会话（开工 + Stage 0 + Stage 1 第 1-3 批 framework core；第 4-5 批 examples + docs + 1.13 dogfood + Stage 4 closeout）
- **主导角色**: 首席架构师（Opus 4.7 全程 / single-actor）

---

## 1. Sprint 任务回顾

### 1.1 Stage 顺序与产出

| Stage | 状态 | 关键产出 |
|-------|------|---------|
| Stage 0.1 brief | ✅ | stage-0-brief / brief-template 第 4 次 |
| Stage 0.2 inventory | ✅ | stage-0-inventory — 7 测试文件 / 1031 行扫描 + 10 invariants → 5 pattern map |
| Stage 1 第 1-3 批 framework core | ✅ | 12 + 5 patterns + __init__ = 18 files / ~1335 lines / 10 sanity tests pass |
| Stage 1 第 4 批 examples | ✅ | 13 files / ~946 lines |
| Stage 1 第 5 批 docs | ✅ | 3 files / ~759 lines |
| **Stage 1.13 dogfood** | ✅ **PASSED** | 11/11 invariants + 4/4 self-tests / 修复 1 次 path bug |
| Stage 2-3 外部审 | ⚪ 押后 | 等外部反馈触发 |
| Stage 4 closeout + retro | ✅ | stage-4-closeout + 本 retro |

### 1.2 数据 / 工程基线 Δ

| 维度 | Sprint O 前 | Sprint O 后 | Δ |
|------|-----------|-----------|-----|
| framework/sprint-templates/ | v0.1.1 / 11 files | unchanged | 0 |
| framework/role-templates/ | v0.1.1 / 13 files | unchanged | 0 |
| framework/identity_resolver/ | v0.1 / 28 files | unchanged | 0 |
| **framework/invariant_scaffold/** | 不存在 | **34 files / ~3040 lines + 3 docs** | **新增 L1 第四刀** |
| docs/methodology/04 | v0.1 | v0.1.1（cross-reference）| +紧密化 |
| services/pipeline/tests/ | (Sprint A-K 状态) | 完全未改 | 0 ✅ |
| dogfood 实证 | 3 sprint 累计 | + 11 invariants + 4 self-tests catch | +1 sprint 实证 |

---

## 2. 工作得好的部分

### 2.1 5 pattern 设计经实证 valid

11 个 huadian invariants（V4 / V6 / V8 / V9 / V10.a/b/c / V11 / active_merged / slug_format / slug_no_collision）100% 映射到 5 pattern。无需新增第 6 pattern。

→ methodology/04 §2 五大 pattern 设计**经 sprint 实证**，可对外宣称 framework abstract 完整。

### 2.2 dogfood 节奏轻 + 显性化

vs Sprint N byte-identical 严格等价，本 sprint 用"production runs 0 violations + self-tests 注入 catch" 软等价模式 — 更轻、更快、更直观。Part A (production state validation) + Part B (self-test injection) 双层验证完整覆盖。

→ 软 dogfood 比硬 dogfood 更适合 invariant 抽象（因为 invariant 已是 0 状态 / hard equivalent 没有差异空间）。

### 2.3 Architect 全程 Opus + 单 actor 节奏舒适

vs Sprint N 需要 PE 子 session 跑 byte-identical，Sprint O 全程 Architect Opus 单 actor。1031 行 / 5 pattern / 11 invariants / 4 self-tests 的复杂度对单 actor 完全可控。

→ 与 Sprint L+M 同节奏（与 N 相比简单 ~50%），完全 fit single-actor sprint pattern。

### 2.4 framework abstract 简单 + 但功能完整

framework core ~1335 行（vs Sprint N 2280 / 简单 ~40%）/ 4 个 Plugin Protocol（vs Sprint N 9 / 简单 ~55%）/ 但功能完整覆盖 11 invariants 用例 + 4 self-tests。

→ "less is more"在框架抽象上得到验证。简单的 abstraction 更容易复用、易理解、易迁移。

### 2.5 Stage 1.13 dogfood path bug 当场修复 < 5 分钟

发现 → 诊断 → 修复 → re-run → PASSED 全过程在一次会话内完成。这种 fast-feedback loop 是 dogfood gate 设计的核心收益。

vs 单元测试不容易抓的 bug（path bug 在 sanity check 没暴露 / 因为 sandbox 没装 huadian_pipeline 用了 fallback / 但 fallback path 也错），只有 dogfood 真跑 production data 才暴露。

---

## 3. 改进点

### 3.1 path 深度 bug 复发（DGF-N-02 衍生债未及时处理）

**症状**：Sprint O slug_format dogfood 出 135 violations，根因是 `Path(__file__).parents[5]` 错算（应该 `[4]`）。

**根因**：Sprint N retro §3.1 已经登记 DGF-N-02 ("硬编码相对路径深度 fragile") 作为 P3 衍生债，但跨 sprint 未处理 → Sprint O 又踩同样坑。

**改进**：

- DGF-N-02 优先级升 **P3 → P2**（DGF-O-01 = 同 bug 第二实例）
- Sprint P 启动时**优先处理**（不能再等 v0.2 release 批量）
- 改用环境变量驱动（`HUADIAN_DATA_DIR`）+ 构造函数参数 + parents[4] fallback 三层

**Lesson**：跨 sprint 复发的 bug 不能保持 P3。

### 3.2 framework 文档已经在抽象内重复多次（README + CONCEPTS + cross-domain）

3 份 docs 共 ~759 行，跨两份 docs 有内容重叠（如 5 pattern 描述在 README + CONCEPTS 都讲）。

**改进**：未来 framework 模块文档结构应该 thinner：

- README — 5 分钟上手 + 不重复 CONCEPTS 内容
- CONCEPTS — 概念定义 + 不重复 README 内容
- cross-domain-mapping — 纯查询表

→ 留作 v0.2 release 前 docs polishing 候选（DGF-O-05 候选，未严格登记）。

### 3.3 examples/huadian_classics 路径仍硬编码

虽然修了 invariants_slug.py 的 `parents[N]`，但 examples 中其他文件可能也有类似问题（dynasty_guard.py 等已 fixed in Sprint N）。

→ DGF-O-01 处理时一并审查全 examples 的 path 用法。

---

## 4. Stop Rule 触发回顾

| Rule | 触发？ | 路径 |
|------|------|------|
| #1 invariant runner 跑非 0 violations | ⚠️ 临时触发 1 次 | slug path bug → 修 parents[5]→[4] → re-run pass |
| #2-#8 | ❌ 未触发 | — |

→ 与 Sprint N 1 次触发同形态，当场修复 < 5 分钟。Stop Rule #1 设计有效。

---

## 5. Lessons Learned

### 5.1 工程层面

- **path 深度硬编码是 fragile + 跨 sprint 复发的 bug pattern**：DGF-N-02 → DGF-O-01。改用环境变量是必要的（不是 nice-to-have）
- **5 pattern 是 invariant 的 universal set**：11 个真实 invariants 100% fit，跨 sprint+ 跨领域都不需要新 pattern
- **从 catch-all `except Exception` vs catch-specific `except ImportError` 的判断**：当 try block 调用第三方代码（如 huadian_pipeline.slug 内部加载 yaml），catch-all 更稳

### 5.2 抽象层面

- **simpler abstractions 可以更通用**：Sprint O 4 个 Plugin Protocol vs Sprint N 9 个 — 简单 ~55%但功能完整。证明 "9 个" 不是 minimum，是 over-engineered for identity_resolver
- **dogfood gate 应区分 hard / soft 等价**：byte-identical（hard / Sprint N）vs production state + self-test 注入（soft / Sprint O）— 后者更适合 invariant
- **`_RollbackSentinel` exception trick 优雅实现 transactional self-test**：避免每个 self-test 自己管理 transaction

### 5.3 协作层面

- **single-actor sprint 的舒适度**：vs Sprint N Architect+PE 双 session，Sprint O 单 actor 更连贯。invariant 抽象适合 single-actor（vs identity_resolver 需要 byte-identical 验证适合 PE 子 session）
- **dogfood 跑 user 本地 venv 而非 sandbox**：与 Sprint N 同 pattern，原因相同（sandbox 缺依赖 + 无 DB）

### 5.4 模型选型 retro

Sprint O 全程 Opus 4.7（与 L+M 同 / 与 N 主 session 同）。

效果：

- ✅ 5 pattern subclass 设计 + Plugin Protocol 设计质量高
- ✅ 11 invariants 抽出过程零卡顿
- ✅ 4 self-tests 设计精准 catch 注入违反
- ✅ dogfood path bug 诊断 < 5 分钟

下次 Sprint P 如选 v0.2 patch（轻量）→ 仍然 Opus
如选 audit_triage 抽象（涉及 BE schema + FE 组件 reference impl）→ 可能需要 PE / BE / FE 子 session（Sonnet 4.6）

---

## 6. 衍生债登记

### 6.1 Sprint O 新增 v0.2 候选（4 项）

| ID | 描述 | 优先级 | 来源 |
|----|------|--------|------|
| DGF-O-01 | framework examples 中所有 `parents[N]` 改环境变量驱动（**DGF-N-02 升级 P3→P2**）| **P2** | dogfood §3 + retro §3.1 |
| DGF-O-02 | framework/invariant_scaffold/ 加 conftest.py + pytest 单元测试 | P3 | retro inferred |
| DGF-O-03 | examples/legal/ + medical/ 跨领域 reference impl（Sprint N DGF-N-04 同 pattern）| P3 | retro §3.3 |
| DGF-O-04 | Containment in_python_predicate 用 `inspect.isawaitable()` 替代 `hasattr` | P3 | code review nit |

### 6.2 累计 v0.2 候选（Sprint L+M+N+O 合并）

| Sprint | 总数 | 已 patch | 仍待 v0.2 |
|--------|------|---------|----------|
| L | 4 | 0 | 4 |
| M | 7 | 6 | 1 |
| N | 5 | 0 | 5 |
| O | 4 | 0 | 4 |
| **合计** | **20** | **6** | **14** |

→ v0.2 release 触发条件**完全成熟**：≥ 15 v0.2 候选 ✅ / 4 抽象资产稳定 ✅ / 严格+软两种 dogfood 通过 ✅。

### 6.3 押后

| 押后项 | 触发条件 |
|--------|---------|
| framework/invariant_scaffold/ 外部工程师走通验证 | 1-2 个朋友 / 跨领域案例方主动接触 |
| 跨领域案例方真用 cross-domain-mapping.md 做 instantiation | 同上 / 与 DGF-O-03 联动 |

---

## 7. D-route 资产沉淀盘点

### 7.1 本 sprint 沉淀的可抽象 pattern

1. **Invariant scaffold 框架** — framework/invariant_scaffold/ v0.1
2. **5 pattern subclass + from_template 一行注册 pattern** — declarative invariant 注册
3. **Self-test 注入式 transactional verification pattern** — 守护元 bug
4. **DBPort 双模式（pool / with_connection）pattern**
5. **`_RollbackSentinel` 强制 rollback exception pattern** — transactional self-test 优雅实现

### 7.2 本 sprint 暴露的"案例耦合点"

1. `parents[N]` 硬编码（DGF-O-01 / 跨 sprint 复发）
2. Self-test SQL 重复（每 self-test 自己写 INSERT — 可 fixture 化）
3. README + CONCEPTS 内容重叠 — docs polishing 候选

### 7.3 Layer 进度推进

- **L1**: 3 模块（治理类双 + identity_resolver）→ **4 模块完整**（治理 + 代码层双 / +~3040 行 / +34 files）
- **L2**: methodology/04 v0.1 → v0.1.1（cross-reference）/ 草案内容仍 v0.1
- **L3**: +1 dogfood 案例（11 invariants + 4 self-tests / 软等价验证）
- **L4**: framework v0.2 release 候选条件**完全成熟**

### 7.4 下一 sprint 抽象优先级建议

按 closeout §2.4：

- **Sprint P 推荐：v0.2 patch 集中处理（清债 + release）**
  - 处理 14 项待 v0.2 候选
  - 处理 DGF-O-01 = DGF-N-02 P2 path bug
  - 完成后正式 v0.2 release
- **Sprint Q：audit_triage 抽象**（推迟到 v0.2 release 后）
- **不推荐立即做**：framework v0.2 release（先清债 / 推到 Sprint P 完成）

---

## 8. 下一步（Sprint P 候选议程）

依据本 retro：

- **主线**：v0.2 patch 集中处理（DGF-N-02 → DGF-O-01 升级 P2 + 14 项待办）
- **副线**：framework v0.2 release（patch 完成后正式 release）
- **押后**：Sprint Q audit_triage 抽象 / 跨领域 examples (DGF-O-03)

不要做的事：

- ❌ 不主动启动新 ingest sprint（违反 C-22）
- ❌ 不在 v0.2 patch 完成前做 framework v0.2 release（避免半成品）
- ❌ 不立即做 ADR-031 plugin 协议标准化（等跨领域案例方反馈触发）

---

## 9. 决策签字

- 首席架构师：__ACK 2026-04-30__

---

**Sprint O retro 完成 → Sprint O 关档。**
