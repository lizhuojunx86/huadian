# Sprint L Stage 4 — Closeout

> 复制自 `framework/sprint-templates/stage-templates/stage-5-closeout-template.md`（dogfood：Sprint L 用自己的产物给自己收档）
> Date: 2026-04-29
> Owner: 首席架构师

## 0. 目的

Sprint L 收档。把 Stage 0-3 的工作"封存"为可追溯的项目历史 + 提取经验为 Sprint M 输入。

---

## 1. Closeout 必备产出

### 1.1 任务卡

Sprint L 不立独立 task card（D-route Sprint L 是文档体系对齐 + 框架抽象 + demo，不在 docs/tasks/ 体系里）。

衍生债登记单独成卡（参见 §1.5）。

### 1.2 STATUS.md 更新

由架构师同步更新 docs/STATUS.md：

- Sprint L 状态：✅ Stage 1 完成 / Stage 2-3 押后到外部反馈触发
- D-route Layer 1 进度：🟡 准备中 → 🟢 第一刀落地（framework/sprint-templates/ v0.1）
- L3 案例库进度：Triage UI demo 已可走通 → demo walkthrough RB-002 落地

### 1.3 CHANGELOG.md 追加

由架构师在 docs/CHANGELOG.md 顶部追加 Sprint L 条目（详见 §1.3.1 完整模板）。

#### 1.3.1 CHANGELOG 条目模板

```markdown
## 2026-04-29 (Sprint L)

### [feat] Sprint L Stage 1 — 框架抽象第一刀 + 产品化 demo 双 track

- **角色**：首席架构师（统筹）+ 自驱执行
- **性质**：D-route 转型后第一个真正按新方向推进的 sprint；Layer 1 第一刀落地
- **关键产出**：
  - framework/sprint-templates/ v0.1（11 files / ~1500 lines）：领域无关 Sprint 治理模板首次抽出
  - dogfood 验证：用模板回审 Sprint K brief，覆盖度 90%
  - RB-002 demo walkthrough（5 分钟）+ README "Quick demo" 段
- **D-route Layer 进度**：
  - L1: 🟡 → 🟢（第一刀落地）
  - L2: docs/methodology/02 引用 framework/sprint-templates/（cross-reference 紧密化）
  - L3: demo walkthrough 落地（"框架真的 work"的活体证明）
- **commits**: c5b8740 (Stage C+D 推送) + 待 push (Sprint L Stage 1)
- **衍生债**: 4 项 v0.2 迭代候选登记（docs/debts/T-P3-XXX）
- **Stage 2-3 押后**: "朋友/用户审 framework + demo" 外部反馈类工作未做，留待 Sprint M 或外部接触触发
```

### 1.4 Sprint L Retro 起草

`docs/retros/sprint-l-retro-2026-04-29.md` 由架构师另文起草（参见 retro-template.md dogfood）。

### 1.5 衍生债登记

来自 dogfood 验证（参见 docs/sprint-logs/sprint-l/stage-1-dogfood-2026-04-29.md §3）的 4 项 v0.2 迭代：

- **T-P3-FW-001** — brief-template.md §1.2 表格灵活列数支持
- **T-P3-FW-002** — retro §4 + stop-rules-catalog §7 cross-reference 紧密化
- **T-P3-FW-003** — stage-3-review-template.md §2.0 review 形式选择指南
- **T-P3-FW-004** — brief-template.md §8 D-route 段措辞调整

全部 P3 优先级（不主动启动；Sprint M 启动时如发现可顺手做）。

来自 Stage 2-3 押后：

- **押后 1**：framework/sprint-templates/ 外部工程师走通验证（招 1-2 个朋友测）
- **押后 2**：demo walkthrough 外部访客 5 分钟走通验证（同上）

不立 task card，仅 Sprint L retro §4 标注。

### 1.6 ADR 更新

Sprint L 没有触发新 ADR / addendum / supersede。既有 ADR-001 ~ ADR-029 全部 status 不变。

---

## 2. D-route 资产沉淀盘点

### 2.1 本 sprint 沉淀的可抽象 pattern

1. **Sprint workflow 模板**（最直接产出）— domain-specific 参数：⚠️FILL 占位符体系；抽象路径：framework/sprint-templates/ 已落地
2. **5 类 Stop Rule 分类**（来自 Sprint A-K 实证）— domain-specific 参数：阈值（cost / 实体数 / etc）；抽象路径：framework/sprint-templates/stop-rules-catalog.md
3. **Gate Checklist 6-gate 协议**（来自 Sprint K 4-stage workflow）— 完全领域无关
4. **dogfood 模式**：用本 sprint 产物给自己 closeout — 这是验证模板的最佳方式（"Sprint L 用 Sprint L 产物收档" / Sprint M 启动用 Sprint L 抽出的 brief 模板）

### 2.2 本 sprint 暴露的"案例耦合点"

1. brief-template.md §1.2 与既有 sprint 对比 — 当前固定 2 列，跨 sprint 多对比时需灵活 → v0.2 修订
2. stage-3-review-template.md review 形式 — Triage UI vs Markdown review 的选择缺指南 → v0.2 修订
3. brief-template.md §8 D-route 段 — 默认假设走 D-route，跨领域案例方可能不走 → v0.2 措辞放宽

### 2.3 Layer 进度推进

- **L1 框架代码**：+1500 行抽象代码（framework/sprint-templates/ v0.1）/ +3 个抽象资产（workflow templates / stop-rules / gate-checklist）
- **L2 方法论文档**：cross-reference 紧密化（docs/methodology/02 ↔ framework/sprint-templates/）；草案内容未变（仍 v0.1）
- **L3 案例库**：+RB-002 demo walkthrough（活体证明就位）；+1 dogfood 案例（Sprint L 自身）

### 2.4 下一 sprint 抽象优先级建议

依据本 sprint 经验 + Sprint L 抽象优先级表（参见 docs/sprint-logs/sprint-l/stage-0-inventory-2026-04-29.md §7）：

**Sprint M 候选主题**：
- **A. Multi-role coordination 抽象（P0）**：
  - `framework/role-templates/`（10 角色模板，复用 Sprint L 的 ⚠️FILL 占位符模式）
  - `framework/role-templates/tagged-sessions-protocol.md`（multi-session 协调协议）
  - 抽象自 docs/methodology/01 + .claude/agents/* + Sprint K Tagged Sessions 实战
- **B. Identity resolver R1-R6 抽象（P1，更深）**：
  - `framework/identity-resolver/`（接口领域无关，guard 可插拔）
  - 复杂度高，需要从代码层面动手（vs Sprint L 主要是文档抽象）
- **C. V1-V11 invariant scaffold 抽象（P1）**：
  - `framework/invariant-scaffold/`（5 大类 pattern + bootstrap test 模板）

**架构师推荐 Sprint M 选 A**（Multi-role）：
- 与 Sprint L Sprint workflow 抽象相邻（同属"治理 / 协作"层），知识体系连续
- 工作量与 Sprint L 接近（~1500 行模板 + dogfood）
- 不需要动代码（vs B / C 需要重构 services/pipeline）
- 完成后 framework/ 下"治理类"抽象完整，可对外发版 v0.2

---

## 3. 给 Sprint M 的 Handoff

```
✅ Sprint L Stage 1 完成（Stage 2-3 押后）
- framework/sprint-templates/ v0.1 落地
- demo walkthrough RB-002 落地
- dogfood 验证模板覆盖度 90%
- 4 项 v0.2 衍生债登记

→ Sprint M 候选主题：Multi-role coordination 抽象（推荐）
→ Sprint M brief 起草用 framework/sprint-templates/brief-template.md
→ 启动时机：用户 ACK + 准备好（无紧急 timeline）
```

---

## 4. Closeout Gate Check（→ Sprint L 关档条件）

- [x] §1.1 任务卡（不立卡，按本 sprint 性质合理）
- [x] §1.2 STATUS.md 更新（待架构师执行）
- [x] §1.3 CHANGELOG 追加（待架构师执行）
- [x] §1.4 retro 起草（另文）
- [x] §1.5 衍生债登记（4 项 P3 / 2 项押后）
- [x] §1.6 ADR 更新（无需）
- [x] §2 D-route 资产盘点
- [ ] commit 已提交（待 push 后勾选）

---

## 5. Sprint L 关档信号

```
✅ Sprint L 完成（Stage 1 + Stage 4，Stage 2-3 押后到外部反馈）
- Layer 1 第一刀：framework/sprint-templates/ v0.1
- Layer 3 demo: RB-002 walkthrough + README Quick demo
- dogfood 验证：模板覆盖度 90%
- 衍生债: 4 项 P3 / 2 项押后
- 下一 sprint 候选: Multi-role coordination 抽象（推荐 Sprint M）
→ Sprint L 关档 / Sprint M 准备（无紧急启动）
```

---

**Sprint L 关档。**

---

**本 closeout 起草于 2026-04-29 / Sprint L Stage 4**
