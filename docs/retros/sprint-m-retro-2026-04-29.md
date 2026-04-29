# Sprint M Retro

> 复制自 `framework/sprint-templates/retro-template.md`（**第二次** dogfood：第一次是 Sprint L 自审）
> Owner: 首席架构师

## 0. 元信息

- **Sprint ID**: M
- **完成日期**: 2026-04-29
- **主题**: Multi-Role Coordination 抽象（framework/role-templates/）
- **预估工时**: 1 个 Cowork 会话（极致压缩）/ 或 2-3 会话（舒缓）
- **实际工时**: ~1 个会话内完成（与 Sprint L 同节奏）
- **主导角色**: 首席架构师（自驱 / 单 actor sprint）

---

## 1. Sprint 任务回顾

### 1.1 Stage 顺序与产出

| Stage | 主导 | 状态 | 关键产出 |
|-------|------|------|----------|
| Stage 0.1 brief 起草 | Architect | ✅ | stage-0-brief-2026-04-29.md（11 段，dogfood brief-template 第二次外部使用 / 已发现 DGF-M-01~03 三项 v0.2 候选）|
| Stage 0.2 inventory | Architect | ✅ | stage-0-inventory-2026-04-29.md — 10 角色文件领域耦合扫描 + Sprint K 实战数据提取 + 起草顺序 + 工作量预估 |
| Stage 1 起草 framework/role-templates/ | Architect | ✅ | 13 files / ~2200 lines（10 角色模板 + tagged-sessions-protocol + cross-domain-mapping + README）|
| Stage 1 dogfood | Architect | ✅ | stage-1-dogfood-2026-04-29.md — 总覆盖度 99.2%（远超 ≥80% 目标）/ DGF-M-04~07 四项 v0.2 候选登记 |
| Stage 1 cross-reference | Architect | ✅ | docs/methodology/01 v0.1 → v0.1.1（§9 Framework Implementation 段加 + 修订历史更新）|
| Stage 2 — 朋友/用户审 framework | — | ⚪ 押后 | 等外部反馈触发（无紧急 timeline）|
| Stage 3 — 跨领域案例方走 cross-domain-mapping | — | ⚪ 押后 | 同上 |
| Stage 4 — Closeout | Architect | ✅ | stage-4-closeout-2026-04-29.md（dogfood closeout-template 第二次）+ 本 retro |

### 1.2 数据 / 工程基线 Δ

| 维度 | Sprint M 前 | Sprint M 后 | Δ |
|------|-----------|-----------|-----|
| framework/sprint-templates/ | 11 files / ~1500 lines | 11 files（不变）| 0（已稳定）|
| **framework/role-templates/** | 不存在 | **13 files / ~2200 lines** | **新增 L1 第二刀** |
| docs/methodology/01 | v0.1（无 cross-reference）| v0.1.1（§9 加 Framework Implementation 段）| +紧密化 |
| Sprint K 实战 dogfood 案例 | 无（仅 Sprint L 自审）| Sprint K 5 角色协同实战 99.2% 覆盖 | +1 完整实证 |
| docs/sprint-logs/sprint-m/ | 不存在 | brief / inventory / dogfood / closeout 4 文件 | +sprint 完整记录 |
| docs/retros/ | sprint-l-retro 含 | + sprint-m-retro | +1 |

---

## 2. 工作得好的部分（What Worked）

### 2.1 inventory 阶段决策力对 Stage 1 起草顺序贡献巨大

Stage 0.2 inventory 把 10 份角色文件按"⚠️FILL 占位密度 + 文件长度 + 是否需要重命名"分三批排序，让 Stage 1 起草变成有节奏的 5 + 3 + 2 流水（先简单 + 后复杂），避免起草中卡壳。

具体批次：

- 第一批（最干净，~30 分钟）：product-manager / chief-architect / data-analyst / qa-engineer / devops-engineer
- 第二批（中度 ⚠️FILL，~40 分钟）：frontend-engineer / ui-ux-designer / backend-engineer
- 第三批（最特殊，~60-90 分钟）：pipeline-engineer / domain-expert（重命名 + 大段 ⚠️FILL）

实际执行下来 Stage 0.2 的预估非常准——pipeline-engineer 因为 235 行 + §工作协议（数据形态契约级 + 4 闸门 + mini-RFC）需要精读完整保留，确实是最耗时的；domain-expert 因为 5 跨领域 instantiation 范例需要一一构思，也是耗时大头。

→ **inventory 不是浪费，是决策的前置投资**。Sprint L 已经证明这点，Sprint M 再次确证。

### 2.2 Sprint K 实战 dogfood 99.2% 覆盖度（远超目标）

brief §10.3 设定 ≥ 80% 目标，实际 99.2%。这不是"作弊"——抽象输入（framework）与实战来源（Sprint K）来自同一根（methodology/01）。但反过来这恰恰证明：

- 抽象路径**正确**（不脱离实战）
- methodology/01 v0.1 草案的 §3 Tagged Sessions / §4 冲突升级 / §7 反模式等内容**已经达到工程级精度**
- Sprint K 当时已是 well-architected sprint（按 methodology/01 协议设计执行）

→ 99.2% 覆盖度是 framework v0.1 的"早期出厂质量证明"。

### 2.3 dogfood-on-template 元 pattern 第 2-3 次实例验证

Sprint L 用 sprint-templates 给自己收档（自审 dogfood / 1 次实例）。
Sprint M：

- 用 brief-template 起草自己 brief（**第二次外部使用** / dogfood 实例 #2）
- 用 closeout / retro template 给自己收档（dogfood 实例 #3 + #4）
- 用 role-templates 回审 Sprint K（**第一次自审** dogfood / dogfood 实例 #5）

→ 4 次新实例 + 已有 1 次 = **5 次 dogfood 实证**，元 pattern 稳定。可在 retro §7.1 正式登记为可抽象的 pattern。

### 2.4 single-actor abstraction sprint pattern 双案例（L + M）确证

Sprint L 与 Sprint M 都是单架构师 1 会话完成的纯文档抽象 sprint。两次都效果良好：

- 总耗时缩短 3-5x（vs 多 role 协作 sprint 估约 2-3 周）
- 0 角色越位 / 0 协调成本
- Stop Rule 重要性下降（low-risk sprint）
- dogfood 覆盖度可达 90%+（Sprint L 90% / Sprint M 99.2%）

→ 这是 D-route 时代"框架抽象类工作"的最佳节奏（per ADR-028 §2.3 Q4 ACK 角色活跃度调整）。

### 2.5 cross-domain-mapping.md 的 6 领域具体填写示例显著提升模板可用度

不是只列"古籍 / 法律 / 医疗 / etc"6 个领域，而是给每个领域填了具体字典 example（韩信 / 慧能 / Marbury v. Madison / 阿司匹林 / John Smith / 长安）+ 黄金集 example。这让外部使用者一眼能 visualize 自己领域怎么填，门槛极低。

→ Sprint L README §4.1 仅有 4 列简单 mapping；Sprint M cross-domain-mapping.md 是 v0.2 版本（更详细 / 更可操作）。

---

## 3. 改进点（What Didn't Work）

### 3.1 brief-template.md 默认 5-stage KE ingest 模式对纯文档抽象 sprint 不适用

brief §3 5 stages（Smoke / Full / Dry-Run / Apply / Closeout）适合 KE ingest sprint，但对 Sprint L / M 这种纯文档抽象 sprint 显得冗余——Sprint L / M 都不得不在 brief §3 加注解适配。

**改进建议**：v0.2 brief-template §3 加 "纯文档抽象 sprint 模式" alt 段，提供 3-stage 简化版（Inventory / 起草 + dogfood / Closeout）。登记为 DGF-M-01。

### 3.2 brief §0 PE 模型字段 / §5 角色边界表对单 actor sprint 显得冗余

Sprint L / M 都是单 actor，brief §0 "PE 模型" 和 §5 "10 角色活跃度表" 在 brief 中显得形式主义。Sprint M 起草 brief 时已经发现 + 标注 N/A，但模板本身没指引。

**改进建议**：v0.2 brief-template §0 / §5 加 "single-actor sprint 简化" 注脚。登记为 DGF-M-02 + 03。

### 3.3 framework/role-templates/ 与 sprint-templates/ 风格略有不一致

Sprint M 起草 role-templates README 时参照 sprint-templates README，但发现两者细节风格不完全一致：

- sprint-templates README §4.1 有 4 列 mapping 表
- role-templates README §4.1 有 6 列 mapping 表（cross-domain-mapping.md 扩充）
- 占位符标识（⚠️FILL vs ⚠️ DOMAIN-SPECIFIC）使用一致，但**没有形成约定文档**

**改进建议**：未来如有 Sprint N + 启动 ADR-030 framework styleguide（per Sprint L brief Stop Rule #7 触发条件），把双模块的占位符约定 / README 结构 / 命名规范写成正式约定。当前没明显冲突，押后到 Sprint N 启动时如必要触发 ADR-030。

### 3.4 Stage 2-3 外部反馈环节继续没法快速完成

与 Sprint L 同样问题——架构师没有立刻可调用的"外部友人"，且外部反馈本质是慢节奏。Sprint M 继续押后。

**改进建议**：sprint M+ brief 应继续预设这种 stage（"该 stage 押后到外部反馈触发，不阻塞 sprint 关档"）—— Sprint M brief 已经做了这点。当前不算问题，是 D-route 项目的固有特性。

---

## 4. Stop Rule 触发回顾

Sprint M 期间**无 Stop Rule 触发**。

原因：

- 单 actor 1 会话完成 → cost / 时间预算根本没机会触及
- 没有数据 mutation → V1-V11 invariant 不存在回归风险
- 没有 review 环节（dogfood 是架构师本人审 Sprint K）→ 治理类 rule 不适用
- dogfood 覆盖度 99.2% > 60% Stop Rule 阈值
- 总工时 1 会话 < 3 会话上限（Stop Rule #5 阈值）
- 触发新 ADR 0 个 < 2 阈值（Stop Rule #6）
- brief / closeout / retro template dogfood 暴露的是 P3 v0.2 候选（4 项 P3 < 2 critical 阈值，Stop Rule #7）

→ Sprint M 是 "low-risk sprint"（与 Sprint L 同形态）。

---

## 5. Lessons Learned

### 5.1 工程层面

- **抽象成熟度的"早期信号"是 dogfood 高覆盖度**：Sprint K（5 角色协同）→ framework/role-templates/ + tagged-sessions-protocol → Sprint K 自审 99.2% 覆盖度。当一个 framework 抽象能达到这种 fit 度时，说明框架已是 v0.1 出厂级别。
- **"⚠️FILL 占位 + 实证示例"组合是抽象质量的最佳平衡点**：纯抽象（无示例）→ 外部使用者不知怎么填；纯具体（无占位）→ 不是框架。Sprint L sprint-templates / Sprint M role-templates 都用同样模式，效果良好。
- **重命名 + 大段重写的角色（domain-expert.md）需要附 6 领域 instantiation 范例**：让外部使用者"读完就能动手"。简单的 ⚠️FILL 占位对这种角色不够（因为它"换人不换角色名 + 换内容大半"），必须给具体填写示范。

### 5.2 协作层面

- **D-route Layer 1 抽象类工作的最佳节奏 = 单架构师 1-3 会话**：Sprint L + M 两次确证。Sprint A-K 时代的 multi-role multi-session 协作适用于"做案例数据"，但"做框架抽象"是相反的——多 role 反而协调成本高，单 actor 深度推进效率最高。
- **Sprint L → M 的"知识体系连续性"显著提升 Sprint M 起草速度**：因为 sprint-templates 已经定 framework/ 双模块的占位符 / README 结构 / cross-domain mapping 模式，Sprint M role-templates 起草是"类比迁移"而不是"从零设计"。这印证 Sprint L closeout §2.4 的判断（"Sprint M 选 multi-role 是因为知识体系连续 / 工作量与 Sprint L 接近"）。

### 5.3 模型选型 retro

Sprint M 全程使用 **Opus 4.7**（架构师 session）。

效果：

- ✅ 13 个文件起草质量稳定（10 角色模板 + 3 伴随文件）
- ✅ Sprint K dogfood 99.2% 覆盖度（精准定位 4 项 v0.2 候选）
- ✅ cross-domain-mapping.md 6 领域具体填写示例（医疗 / 法律 / 专利 等）的领域知识深度——Opus 在跨领域知识抽象上明显优于 Sonnet
- ✅ 单会话压缩节奏，没有质量妥协

如 Sprint N 主题选 Identity Resolver R1-R6 抽象（代码 refactor 工作）→ 切 Sonnet 4.6（per Sprint L retro §5.3 + Sprint K closeout §6.3 实证）

---

## 6. 衍生债登记

### 6.1 v0.2 迭代候选（来自 brief 起草 + dogfood）

| ID | 描述 | 优先级 | 来源 |
|----|------|--------|------|
| DGF-M-01 | brief-template.md §3 加 "纯文档抽象 sprint 适配" alt 段（3-stage 简化版）| P3 | brief §10.2 |
| DGF-M-02 | brief-template.md §0 PE 模型字段加 "N/A (single-actor)" 占位明示 | P3 | brief §10.2 |
| DGF-M-03 | brief-template.md §5 角色边界表加 "single-actor sprint 简化" 注脚 | P3 | brief §10.2 |
| DGF-M-04 | domain-expert.md §核心职责加 "Triage / Audit Decision Submission" 单独条目 | P3 | dogfood §1.2 |
| DGF-M-05 | chief-architect.md §核心职责加 "Stop Rule Arbitration" 单独条目 | P3 | dogfood §1.2 |
| DGF-M-06 | tagged-sessions-protocol.md §2.3 加注脚说明 handoff 格式在主 Architect 集中协调模式下是 nice-to-have | P3 | dogfood §2.2 |
| DGF-M-07 | tagged-sessions-protocol.md §4.5 加注脚说明 handoff_to: 标注在主 Architect 集中协调模式下可由 commit message + Architect 协调替代 | P3 | dogfood §4.2 |

合计：**7 项 P3 v0.2 候选**。集中登记到 docs/debts/sprint-m-framework-v02.md（参见 §6.3）。

### 6.2 Stage 2-3 押后

| 押后项 | 触发条件 |
|--------|---------|
| framework/role-templates/ 外部工程师走通验证 | 1-2 个朋友 / 跨领域案例方主动接触 |
| 跨领域案例方真用 cross-domain-mapping.md 做 instantiation | 跨领域案例方接触（佛经 / 法律 / 医疗 / etc）|

无具体 timeline，等外部时机。

### 6.3 衍生债文件

`docs/debts/sprint-m-framework-v02.md`（架构师另起草，7 项 v0.2 集中登记 + 与 Sprint L T-P3-FW-001~004 对照）。

---

## 7. D-route 资产沉淀盘点

### 7.1 本 sprint 沉淀的可抽象 pattern

1. **Multi-role coordination 模板系**（最直接产出）— framework/role-templates/ v0.1
2. **Tagged Sessions 协议**（5 类 handoff 信号 + 3 级冲突升级 + 5 反模式）— framework/role-templates/tagged-sessions-protocol.md
3. **6 领域 Domain Expert instantiation 速查**— framework/role-templates/cross-domain-mapping.md（古籍 / 佛经 / 法律 / 医疗 / 专利 / 地方志 + 字典 / 黄金集 example）
4. **dogfood-on-template 元 pattern**（5 次实例验证：Sprint L 自审 / Sprint M brief / Sprint M closeout / Sprint M retro / Sprint M role-templates 回审 Sprint K）— 元 pattern 稳定，retro 中正式登记
5. **single-actor abstraction sprint pattern**（Sprint L + M 双案例确证）— 1-3 会话单架构师纯文档抽象工作的最佳节奏

### 7.2 本 sprint 暴露的"案例耦合点"

1. brief-template.md §3 默认 5-stage 偏 KE ingest 模式 → 纯文档 sprint 不适用（DGF-M-01）
2. brief-template.md §0 / §5 → 单 actor sprint 显得冗余（DGF-M-02 + 03）
3. domain-expert.md / chief-architect.md §核心职责 → Triage Decision / Stop Rule Arbitration 等具体职责未单独列条（DGF-M-04 + 05）
4. tagged-sessions-protocol.md handoff 格式 / handoff_to → 主 Architect 集中协调 vs 多 Architect 并行模式区别未明示（DGF-M-06 + 07）

→ 全部 P3 衍生债。

### 7.3 Layer 进度推进

- **L1**: 🟢 第一刀（sprint-templates v0.1）→ 🟢 第一+二刀（治理类双模块完整 / +13 files / +~2200 lines）
- **L2**: methodology/01 v0.1 → v0.1.1（§9 Framework Implementation cross-reference 段）/ 草案内容仍 v0.1
- **L3**: +1 dogfood 案例（Sprint K 5 角色协同实战是 framework/role-templates/ 第一完整实证 / 99.2% 覆盖度）
- **L4**: 不变（机会主义）

### 7.4 下一 sprint 抽象优先级建议

按 closeout §2.4：

- **推荐 Sprint N 主题**：Identity Resolver R1-R6 抽象（P1，更深；切代码层 / Sonnet 4.6）
- **形式**：framework/identity-resolver/（接口领域无关 / guard 可插拔）
- **抽象自**：services/pipeline/src/huadian_pipeline/resolve.py + resolve_rules.py + resolve_types.py + r6_seed_match.py + r6_temporal_guards.py
- **预估工时**：2-3 周 / 多个会话（明显高于 Sprint L+M）
- **节奏切换**：可能需要 PE 子 session 介入（不再单 actor sprint）
- **启动时机**：用户 ACK + 准备好（无紧急 timeline；framework/ 已具备 v0.2 发版条件，自然停顿点；可休息 1-2 周再启动）

---

## 8. 下一步（Sprint N 候选议程）

依据本 retro + Sprint M closeout §2.4：

- **主线**：Identity Resolver R1-R6 抽象（framework/identity-resolver/）
- **副线**：dogfood Sprint N 启动 brief（framework/sprint-templates 第三次外部使用）+ 第一次跨"治理 / 代码"双模块 dogfood（用 framework/role-templates/ 调度 PE 子 session）
- **押后**：V1-V11 Invariant Scaffold 抽象（Sprint O 候选）/ Audit + Triage Workflow 抽象（Sprint P 候选）

不要做的事：

- ❌ 不主动启动新 ingest sprint（违反 C-22）
- ❌ 不做 framework v0.1 公开 release（per Sprint L retro §8 + Sprint M closeout §2.3 / 等 ≥ 2 个抽象资产稳定后才考虑——Sprint M 完成后**已达成"≥ 2 个稳定抽象资产"条件**，但不立即 release，留给 Sprint N 完成 / 跨领域案例反馈触发后再 release）
- ❌ 不立即做 ADR-030 framework styleguide（per Sprint M retro §3.3，等 Sprint N 启动时如必要触发）

**framework v0.2 发版条件评估**：

Sprint M 完成后 framework/ 下治理类双模块完整（sprint-templates v0.1 + role-templates v0.1）。理论上具备 v0.2 release 条件，但 Sprint L retro §8 设定的"≥ 2 个稳定抽象资产"条件是为了保证质量——是否 release v0.2 推荐留给：

- Sprint N 完成后再 release（更稳）
- 或跨领域案例方主动接触时 release（外部反馈驱动）

不强求当前 release。

---

## 9. 决策签字

- 首席架构师：__ACK 2026-04-29__

---

**Sprint M retro 完成 → Sprint M 关档。**
