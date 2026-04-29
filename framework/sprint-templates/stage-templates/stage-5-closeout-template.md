# Sprint ⚠️FILL-ID Stage 5 — Closeout

> 复制到 `docs/sprint-logs/sprint-{id}/stage-5-closeout-YYYY-MM-DD.md`

## 0. 目的

Sprint 收档。把 Stage 0-4 的工作"封存"为可追溯的项目历史 + 提取经验为下一 sprint 输入。

---

## 1. Closeout 必备产出

### 1.1 任务卡 → done

更新 `docs/tasks/T-NNN-*.md`：

- 状态：`pending → in_progress → review → done`
- 完成日期：⚠️YYYY-MM-DD
- 实际工时：⚠️N（vs brief 预估的 ⚠️M）
- 交付物清单：✅ 全部勾选

### 1.2 STATUS.md 更新

更新 `docs/STATUS.md` 含：

- 当前 Sprint 状态（→ ✅ 完成）
- 数据基线（active entities / merge_log / etc 的 Δ）
- 当前 V1-V11 invariants 状态
- 下一 sprint 候选议程（根据本 sprint 发现）

### 1.3 CHANGELOG.md 追加

```markdown
## YYYY-MM-DD

### [feat / fix / refactor / docs] Sprint X — ⚠️topic

- **角色**：⚠️FILL
- **性质**：⚠️FILL
- **关键产出**：⚠️FILL
- **数据 Δ**：⚠️FILL
- **commits**：⚠️SHA list
- **衍生债**：⚠️FILL
- **累计**：⚠️FILL（cost / migration / new tests / 等）
```

### 1.4 Sprint Retro 起草

复制 `framework/sprint-templates/retro-template.md` 到 `docs/retros/sprint-X-retro-YYYY-MM-DD.md` 起草。

⚠️ retro 必含 D-route 资产盘点段（如本项目走 D-route）。

### 1.5 衍生债登记

每个本 sprint 暴露但不立即处理的问题登记到 `docs/debts/T-PN-XXX-{slug}.md`：

```markdown
# T-PN-XXX: ⚠️FILL

- **状态**: registered
- **优先级**: P1 / P2 / P3
- **来源 sprint**: Sprint X
- **触发**: ⚠️FILL
- **影响**: ⚠️FILL
- **建议处理时机**: ⚠️FILL
```

### 1.6 ADR 更新（如有架构决策变更）

如本 sprint 触发架构决策 / addendum / supersede，更新 `docs/decisions/`：

- 新决策 → 新 ADR（参见 `docs/methodology/06-adr-pattern-for-ke.md`）
- 既有 ADR 扩展 → addendum（不删原文）
- 既有 ADR 推翻 → supersede（标记原 status: superseded）

---

## 2. D-route 资产沉淀盘点（D-route 项目专用）

依据 `docs/methodology/02-sprint-governance-pattern.md` §11.3 retro 必加段：

### 2.1 本 sprint 沉淀的可抽象 pattern
1. ⚠️FILL pattern 名 — domain-specific 参数 [...] / 抽象路径 [...]
2. ...

### 2.2 本 sprint 暴露的"案例耦合点"
1. ⚠️FILL pattern 名 当前与 ⚠️domain 紧密耦合，抽象时需 [...]
2. ...

### 2.3 Layer 进度推进
- L1 框架代码：⚠️N 行抽象代码 / ⚠️N 行删除领域耦合
- L2 方法论文档：⚠️N 字 / ⚠️N 个 pattern 案例
- L3 案例库：⚠️N 篇 / ⚠️N 类实体覆盖

### 2.4 下一 sprint 抽象优先级建议
⚠️FILL（根据本 sprint 发现的下一步推荐）

---

## 3. 给下一 Sprint 的 Handoff

如本 sprint 完成 + 下一 sprint 候选议程清晰，准备 Sprint X+1 brief：

- [ ] 创建 `docs/sprint-logs/sprint-{X+1}/` 目录
- [ ] 复制 `framework/sprint-templates/brief-template.md` 起草
- [ ] 在本文件附录列出"建议主题"

---

## 4. Closeout Gate Check（→ Sprint X 关档条件）

- [ ] §1.1 任务卡更新
- [ ] §1.2 STATUS.md 更新
- [ ] §1.3 CHANGELOG 追加
- [ ] §1.4 retro 起草
- [ ] §1.5 衍生债登记（如有）
- [ ] §1.6 ADR 更新（如适用）
- [ ] §2 D-route 资产盘点（D-route 项目）
- [ ] commit 已提交

如任一不通过 → 不得标 sprint 为完成 → 补完所有项。

---

## 5. Sprint 关档信号

```
✅ Sprint X 完成
- Closeout: 所有 §4 项 ✓
- 数据 Δ: ⚠️FILL
- V1-V11: 22/22 全绿
- 衍生债: ⚠️N 项登记
- 下一 sprint 候选: ⚠️FILL
→ Sprint X 关档 / Sprint X+1 准备
```

---

**Sprint X 关档。**
