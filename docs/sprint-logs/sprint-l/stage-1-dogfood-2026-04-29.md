# Sprint L Stage 1 Track 1 — Dogfood: 用 framework/sprint-templates/ 回审 Sprint K Brief

> Date: 2026-04-29
> Owner: 首席架构师
> Anchor: Sprint L Brief §3 Stage 1.6 — "用本套模板回过头审 Sprint K brief"
> Purpose: 验证 framework v0.1 模板覆盖度 + 暴露 gap

---

## 0. 方法

把华典智谱 `docs/sprint-logs/sprint-k/stage-0-brief-2026-04-28.md` 当作"案例层 brief"，逐字段对照 `framework/sprint-templates/brief-template.md`，做两件事：

1. **覆盖度检查** — Sprint K brief 的每个章节是否都能在 template 里找到对应位置
2. **Gap 识别** — Sprint K brief 有但 template 没有 / Template 有但 Sprint K 没填 → 决定改 template 还是改 sprint K（其实只能改 template，sprint K 已落地）

---

## 1. 章节对照表

| Sprint K Brief 章节 | Template 对应 | 状态 |
|------------------|------------|------|
| §0 元信息（Architect / Brief 日期 / 形态 / 工时 / model）| §0 元信息 | ✅ 完全对齐 |
| §1.1 触发 / 1.2 痛点 / 1.3 缺口 | §1.1 前置上下文 | ✅ 概念对齐（Sprint K 拆得更细但 template 通用 ok）|
| §2 Decision / §2.1-2.5 设计 | §2 目标范围 + Track | ✅ 对齐 |
| §3 Schema / GraphQL / etc | （无 template 对应）| ⚠️ Gap 1 (见下) |
| §4 Stages | §3 Stages | ✅ 对齐 |
| §5 GraphQL queries / mutations | （无 template 对应）| ⚠️ Gap 2 (见下) |
| §6 V1 vs V2 范围 | §1.3 Negative Scope | ✅ 部分对齐（V2 list 是 negative scope 子集）|
| §7 Stop Rules | §4 Stop Rules | ✅ 完全对齐 |
| §8 角色边界 | §5 角色边界 | ✅ 完全对齐 |
| §9 收口判定 | §6 收口判定 | ✅ 完全对齐 |
| §10 节奏建议 | §7 节奏建议 | ✅ 完全对齐 |
| §11 PE 模型试用观察 | §0 元信息（PE 模型）+ retro §5.3 | ✅ 概念对齐（试用观察归到 retro 即可）|

**总体覆盖度：约 90%**。两个 Gap 都是 case-specific 内容（schema design / GraphQL specifics），属"案例层"而非"框架层"，不应该放进领域无关 template。

---

## 2. 暴露的 Gap

### Gap 1：Schema / Migration 草案位置

**Sprint K Brief §3** 含完整 SQL CREATE TABLE schema 草案 + migration 编号。

**framework template** 没有对应位置。

**评估**：这是**案例层**内容（具体表名 / 字段 / 数据类型），不应该出现在领域无关 brief template 中。

**结论**：✅ Gap 是有意的。template 设计正确。Schema 设计应该单独写到 ADR（参见 `docs/methodology/06-adr-pattern-for-ke.md` §3.4 数据迁移路径）+ 在 brief §1 / §2 引用 ADR-NNN，不内嵌 SQL。

**Action**：无需修 template。但 framework README §3 应该提一句"schema 设计 → 写 ADR，不内嵌 brief"。

### Gap 2：GraphQL queries / mutations 的"接口契约"

**Sprint K Brief §5** 含完整 GraphQL SDL（TriageItem interface / RecordTriageDecision mutation / etc）。

**framework template** 没有对应位置。

**评估**：同 Gap 1，这是案例层内容（具体接口 / 类型）。

**结论**：✅ Gap 是有意的。GraphQL SDL → 写 ADR + 引用，不内嵌 brief。

**Action**：无需修 template。但 framework README 加"接口契约 → ADR 引用"提示。

---

## 3. Template 自身的不足（需要 v0.2 迭代）

dogfood 过程中发现的可改进点：

### 3.1 brief-template.md §1.2 "与既有 sprint 的差异" 表格

**问题**：列名占位（"上一 sprint" / "本 sprint"）太少（只 2 列）。Sprint K brief 实际写了 3-4 列对比（`秦本纪 γ` / `项羽本纪 δ` / `高祖本纪 ε`）。

**Action（v0.2 迭代）**：
- 改成"灵活列数"（用 ⚠️FILL 给出说明，让用户自己加列）
- 例：`| 维度 | 上一 sprint | 上 N sprint | 本 sprint |`

### 3.2 stop-rules-catalog.md 没有"Stop Rule 触发后的 retro 回填"段

**问题**：Sprint K 实际触发 2 次 Stop Rule，retro §4 有专门段记录。catalog template 没有提示要写 retro。

**Action（v0.2 迭代）**：catalog §7 协议已经提到"retro §4 引用本决策"，但应该更显式：在 retro-template.md §4 加预填的"Stop Rule 触发回顾"段（已经有，但应该 cross-reference 更紧密）。

### 3.3 stage-3-review-template.md 没有提到"Triage UI vs Markdown Review" 选项

**问题**：实际 review 形式有 2 种（V1 Markdown / V2 Triage UI），template §2.1 已经提到，但**没说何时该用哪种**。

**Action（v0.2 迭代）**：加 §2.0 "选择 review 形式":

```
- 项目早期 / V1：用 Markdown review（low setup cost）
- 项目成熟 / V2 / 跨 sprint 决策回查需求：用 Triage UI（参见 docs/methodology/05-audit-trail-pattern.md）
- 选择后写入 brief §3 Stage 3 段
```

### 3.4 brief-template.md §8 "D-route 资产沉淀预期" 段假设是 D-route 项目

**问题**：跨领域案例方可能不走 D-route 路线（仅借鉴框架），不应该被强制要求"必须沉淀框架抽象资产"。

**Action（v0.2 迭代）**：§8 改成可选段，注明"如本项目走 D-route 路线（即同时建框架 + 案例），必填本节；否则可删"。当前 template 已有此说明（"非 D-route 项目可删本节"），但措辞可更明确。

---

## 4. Template v0.1 → v0.2 迭代清单

下一次 framework/sprint-templates/ 迭代（视 Sprint M 反馈）需修：

- [ ] brief §1.2 表格灵活列数支持
- [ ] retro §4 + stop-rules-catalog §7 cross-reference 紧密化
- [ ] stage-3-review §2.0 review 形式选择指南
- [ ] brief §8 D-route 段措辞调整（更明确"可选"）

不立即修（v0.1 状态够 dogfood）。Sprint L closeout retro 中加为衍生债。

---

## 5. Dogfood 结论

**framework/sprint-templates/ v0.1 模板可用**：

✅ 覆盖 Sprint K brief 90% 章节
✅ 缺失部分（schema / GraphQL SDL）是有意的领域分层
✅ 跨领域工程师按 README 5 分钟可启动 Sprint A
⚠️ 4 项小迭代待 v0.2（不阻塞当前使用）

**Sprint L Track 1 Stage 1 完成判据 满足**（Sprint L brief §2.1）：
- ✅ "一个完全外部的工程师能在 30 分钟内 clone + 复制模板 + 写出自己的 Sprint A brief" — README §3 提供 5 分钟快速上手 + brief 模板 ⚠️FILL 占位清晰
- ✅ "7 份 docs/methodology/ 中 §02 引用了 framework/sprint-templates/ 文件路径" — 已在 docs/methodology/02 §相关章节引用 framework
- ⏳ "模板被 dogfood：Sprint M brief（如启动）必须用这套模板写" — Sprint M 启动时验证

---

## 6. 下一步

- Track 1 第一刀完成（framework/sprint-templates/ 11 files + dogfood）
- 推进 Track 2：demo walkthrough + README "Quick demo (5 min)" 段
- Sprint L 收档时（Stage 4）做整体 retro + 衍生债登记

---

**本 dogfood 起草于 2026-04-29 / Sprint L Stage 1 Track 1**
