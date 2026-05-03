# Sprint P Retro — v0.2 Patch + framework v0.2 Release

> 起草自 `framework/sprint-templates/retro-template.md` v0.1.1
> Dogfood: retro-template **第六次**外部使用（Sprint L/M/N/O + 本 sprint）

## 0. 元信息

- **Sprint ID**: P
- **完成日期**: 2026-04-30
- **主题**: v0.2 patch + framework v0.2 release（清债 + ceremonial release）
- **预估工时**: 1-2 个 Cowork 会话
- **实际工时**: **1 个 Cowork 会话**（含 brief 起草 + 5 批 patch + closeout + retro）
- **主导角色**: 首席架构师（Claude Opus 4.7）— single-actor sprint

---

## 1. Sprint 任务回顾

### 1.1 Stage 顺序与产出（精简模板 §3.B）

| Stage | 主导 | 状态 | 关键产出 |
|-------|------|------|----------|
| Stage 0 — Inventory（轻量内嵌 brief §2）| Architect | ✅ | brief §2.1 8 项待办清单 |
| Stage 1 — Patch + Release Prep | Architect | ✅ | 8 patches + 6 release prep 文件 |
| Stage 1.13 — Sanity 回归 | Architect | ✅ | 8/8 sanity 通过 + ruff clean |
| Stage 4 — Closeout | Architect | ✅ | closeout / retro / STATUS / CHANGELOG / debt 押后 |

注：本 sprint 用 §3.B 精简模板，无 Stage 2 / 3 / 5 编号——这是模板特性，不是 stage 缺失。

### 1.2 数据 / 工程基线 Δ

| 维度 | Sprint 前 | Sprint 后 | Δ |
|------|---------|---------|-----|
| 4 模块版本 | 各自 v0.1.x | **统一 v0.2.0** | 第一次同步 release |
| v0.2 累计待办 | 14 | **6** | -8（4 P3 模板 / 2 code patch / 1 P2 path / 1 doc-alt 段）|
| framework 文件总数 | ~86 | ~87 | +1（RELEASE_NOTES_v0.2.md）|
| brief-template 版本 | v0.1.1 | **v0.1.2** | +3 polish + §3 拆 alt 段 |
| Layer 4 触发 | 0 | **1**（v0.2.0 公开 release tag）| 第一刀 |
| L4 触发条件成熟 | "等待" | "已触发" | ⭐ |

---

## 2. 工作得好的部分（What Worked）

### 2.1 Sprint 设计的 5-batch 节律压缩到 1 会话内

brief §3 把 Stage 1 拆成 5 批（path / template / code / release / sanity），每批 5-30 分钟，每批结束都是天然 commit point。这种"内嵌节律"使得：
- Architect 任何时刻可中断（5 批之间无依赖）
- 用户审查易（每批小且明确）
- 避免长 stage 中段失控

**沉淀**：清债 sprint 的 5-batch 切法可写成 §3.B 精简模板的子模式；下次再有清债 sprint 直接复用。

### 2.2 v0.2 release prep 与 patch 同 sprint 完成

原本可拆"先 patch sprint → 再 release sprint"两 sprint，但 brief 设计为合并：因为 patch 改动小 + release prep 都是机械工作，合并后总工时不增反减（避免上下文切换）。**实证 1 会话内完成**。

### 2.3 cross-sprint 复发 bug 升级机制有效

DGF-N-02 (P3) → 跨 sprint 复发 → DGF-O-01 (P2) 升级 → Sprint P 优先处理。这套"P3 漏修 ≥ 2 sprint → 升 P2"的暗规则在本 sprint 第一次 explicit 兑现，证明 sprint 治理 patten 自我强化。

**沉淀**：可在下版 methodology/02-sprint-governance-pattern.md 显式收录"P3 复发升级 P2"作为 §X 子段。

### 2.4 ruff + sanity 双 gate 一次过

8 batch 全部 lint clean、format clean、sanity 8/8 一次过。无需 fix-cycle。说明：
- 改动小且明确（统一 pattern：env var > parents fallback / FIELD_ALIASES / isawaitable）
- 测试覆盖度足够（containment async 真有 case 走过）

---

## 3. 改进点（What Didn't Work）

### 3.1 brief §2.1 估时 "5 处" vs 实际 4 处

brief 写 "5 处 examples 路径硬编码"，实际只有 4 处。来源：sprint O debt §DGF-O-01 写 "~5 处"，是估算未核对。

**改进建议**：debt 文档登记时若涉及 file count，须 grep 实际数；不允许写 "~N" 模糊估算（落地时易 mismatch brief）。已沉淀为下次 debt 起草 mini check。

### 3.2 Sprint P brief 起草后未先 grep 验证

类似 §3.1 — brief §2.1 的 8 项清单是直接 transcribe Sprint O retro 推荐项，未做 sanity check。

**改进建议**：brief 起草完成后须执行 1 次 "candidate-vs-source-tree grep"，确认每项 patch 都能定位到具体文件。Sprint Q brief 起草时尝试。

### 3.3 sanity 测试中 GuardChain import 名错

Stage 1 批 5 sanity 第一次跑时尝试 `from framework.identity_resolver import GuardChain` — 实际公共 API 没有这个名称（只有 `GuardFn` / `evaluate_pair_guards`）。

**改进建议**：identity_resolver/README.md §2 "公共 API" 段应给出 explicit 的 `__all__` 等价清单（当前依赖 `__init__.py` import），便于下游 fork 时一眼看到接口边界。已记 v0.3 候选（暂不阻塞 v0.2）。

---

## 4. Stop Rule 触发回顾

> 触发处理协议见 `framework/sprint-templates/stop-rules-catalog.md` §7。

**无触发。**

| Rule | 类别 (catalog §2-§6) | 触发原因 | 架构师裁决 (A/B/C/D) | trigger 文件路径 |
|------|---------------------|---------|--------------------|----------------|
| — | — | 无触发 | — | — |

Sprint P 6 条 stop rule 全部未命中（详见 stage-4-closeout §5）。这是 Sprint L 以来**第一个 zero-trigger sprint**（vs Sprint M 触发 1 / Sprint N 触发 1 path bug / Sprint O 触发 1 同 path bug 复发）。

---

## 5. Lessons Learned

### 5.1 工程层面

#### "清债 sprint" 的 meta pattern

清债 sprint 与抽象 sprint 在节律上有本质差别：

| 维度 | 抽象 sprint (L/M/N/O) | 清债 sprint (P) |
|------|---------------------|----------------|
| 主要风险 | 抽象设计错误（高） | 改动 pattern 不一致（低）|
| Stop Rule 重点 | dogfood 失败 / 抽象漏洞 | 改动后 sanity 回归 |
| 节律 | 4-5 批 + dogfood gate | 5 批 + 简单 sanity |
| Stage 1.13 | 严格 dogfood | 简单 sanity 即可 |
| commit 粒度 | 大 commit（每模块）| 小 commit（每批）|

**沉淀**：清债 sprint 是 D-route 项目的"周期工作"（每隔 3-5 个抽象 sprint 该来一次）。这个 pattern 本身是可抽象的——methodology/02-sprint-governance-pattern.md v0.2 可加 §X "Maintenance Sprint Pattern" 段。（暂不本 sprint 落地，记 Sprint Q+ 候选。）

#### `__version__` 跨模块同步 vs 独立

Sprint P 选择"4 模块统一版本号 v0.2.0"，理由：
- 跨领域案例方 fork 时一个 baseline 引用即可
- 避免 version skew（A 用 v0.1 / B 用 v0.2.1 困惑）
- release notes 集中

代价：
- 任一模块 patch 都要联动 4 模块 README 改动
- 模块独立演进自由度降低

**沉淀**：v0.2 ~ v1.0 期内坚持统一版本号；v1.0+ 后若模块独立演进需求强烈再分。

### 5.2 协作层面

Sprint P 是 single-actor sprint，无跨角色协作。

**新发现**：在 Cowork 会话内，"task 列表 + 5-batch 节律" 这种自规划模式 vs 长指令一段到底，前者大幅减少架构师中段失焦风险。Task 列表本身就是"清债 sprint" 的天然 stop point catalog。

### 5.3 模型选型 retro

**Architect = Opus 4.7（全程）**：合适。

- patch 改动虽然机械，但每项都涉及多文件 cross-ref（README / __init__ / docs / etc），需要 long-context 一致性
- release notes 撰写涉及 8 项 patch 的统一叙事，Sonnet 容易 inconsistent
- closeout + retro 涉及自审 + retro pattern 提炼，Opus 在元认知方面更稳

**反例假设**：若用 Sonnet 跑 Sprint P，可能问题：
- README 4 模块版本同步偶尔遗漏一个
- release notes 叙事 inconsistency
- retro §5 lessons 流于现象记录，缺 pattern 提炼

→ Opus on patch sprint 不是 overkill，是符合 sprint 的"集成"性质。

---

## 6. 衍生债登记

本 sprint 收口后**新增 0 项 v0.2 候选**（patch sprint 本身不应触发新候选，符合 brief stop rule §5）。

**留 v0.3 候选 2 项**（不阻塞本 release）：

| ID | 描述 | 优先级 | 来源 |
|----|------|--------|------|
| T-V03-FW-001 | identity_resolver/README §2 加 `__all__` 等价"公共 API"段 | P3 | 本 retro §3.3 |
| T-V03-FW-002 | methodology/02-sprint-governance-pattern.md v0.2 加 "Maintenance Sprint Pattern" 段 | P3 | 本 retro §5.1 |

押后到 Sprint Q+ 的 6 项 v0.2 候选见 `docs/debts/sprint-p-residual-v02-debts.md`。

---

## 7. D-route 资产沉淀盘点

### 7.1 本 sprint 沉淀的可抽象 pattern

1. **"5-batch 清债 sprint" pattern** — 每批 5-30 分钟 / 每批天然 commit point / 5 批之间零依赖；可压缩到 1 会话；适合 P3 累积清理 sprint
2. **"P3 复发升级 P2" 暗规则首次 explicit 兑现** — 跨 sprint 同 bug 复发 → 自动升级；可写入 methodology/02 v0.2
3. **"统一版本号" pattern (vs 独立)** — 4 模块 v0.2.0 同步释放，跨 module 引用 baseline 单一；适用 v0.x 早期 / 模块强 coupling 场景

### 7.2 本 sprint 暴露的"案例耦合点"

1. `examples/huadian_classics/` 中的 path 解析仍然假设"项目布局是 framework/X/examples/huadian_classics/"——若用户把 framework/ rename 或挪位置（如装到 `~/.local/share/`），`parents[4]` walk-up 会失效。`HUADIAN_DATA_DIR` 环境变量 cover 了这个 case，但默认体验仍依赖项目布局。
   - 抽象时需：在 cross-domain-mapping.md 加 §X "data dir 解析的 3 种 strategy"（env var / explicit ctor arg / walk-up 推断）

### 7.3 Layer 进度推进

- L1: 4 模块 v0.1 → **v0.2.0 公开 release**（**第一次正式 release tag**）
- L2: 不变（patch sprint 不产 methodology；2 项候选记 Sprint Q+）
- L3: 不变（dogfood Sprint L-O 已完成）
- L4: **第一刀触发**（v0.2.0 GitHub release tag → 项目对外可见性升级）

### 7.4 下一 sprint 抽象优先级建议

按价值 / 风险综合判断推荐顺序：

1. **Sprint Q 候选 A**：audit_triage 抽象（第 5 模块）— per Sprint O retro 推荐
   - 来源：services/pipeline/src/huadian_pipeline/triage_*.py + services/api/triage/
   - 抽出：triage_decisions audit table + Hint Banner 跨 sprint 一致性 + 6 quick template reasons
   - 形态：multi-actor 可能（涉及 BE 接口 / DB schema），但仍以 Architect 主导 + PE 协助
   - 工时：2-3 会话（vs Sprint N 的 1 会话 / Sprint O 的 1 会话）

2. **Sprint Q 候选 B**（备选）：methodology v0.2 起草 sprint
   - methodology/02 加 "Maintenance Sprint Pattern" + "P3 复发升级 P2" 暗规则
   - methodology/04 加 v0.2（invariant 5 pattern + isawaitable lesson）
   - 形态：纯文档 / Architect 主导 / 1 会话

3. **Sprint Q 候选 C**（远期）：跨领域 reference impl（legal）
   - 触发条件：跨领域案例方主动接触
   - 当前未触发 → 不建议主动启动

---

## 8. 下一步（Sprint Q 候选议程）

依据本 retro 发现，建议 Sprint Q 推进：

- **优先选 候选 A**（audit_triage 抽象）— 完成 Layer 1 第 5 刀，使 framework 5 模块齐备
- 候选 B 可与候选 A **合并**（Stage 0 inventory 时同时加 methodology/02 polish 段，工时 +0.5 会话）
- 候选 C 不主动启动，等触发

不要做的事：

- ❌ 不开新 framework 模块（候选 A 是已规划 5 模块的最后 1 刀，不算新）
- ❌ 不动 Sprint P 已 release 的 4 模块（保 v0.2.0 ABI 稳定到 Sprint Q+ 期内）
- ❌ 不立即触发 ADR-031 plugin 协议（per Sprint M-O 同结论）
- ❌ 不在 Sprint Q 内做"小 patch sprint"（间隔 1-2 sprint 后再清债）

---

## 9. 决策签字

- 首席架构师：__ACK 2026-04-30 (Architect)__
- 用户：__ACK 待签__
- 信号：本 retro 用户 ACK + commit + tag v0.2.0 push 后 → **Sprint P 关档 / Sprint Q 候选议程激活**

---

**Sprint P retro 起草于 2026-04-30 / retro-template v0.1.1 第六次外部使用 / Architect Opus**
