# Sprint P Brief — v0.2 Patch + framework v0.2 Release Prep

> 起草自 `framework/sprint-templates/brief-template.md` v0.1.1
> Dogfood: brief-template **第五次**外部使用

## 0. 元信息

- **架构师**：首席架构师（Claude Opus 4.7）
- **Brief 日期**：2026-04-30
- **Sprint 形态**：**单 track / single-actor**（v0.2 patch 是 incremental fix / framework v0.2 release 是 ceremonial / 都不需要 PE 子 session）
- **预估工时**：1-2 个 Cowork 会话（与 Sprint L+M 同 scale / 轻量 patch + release）
- **PE 模型**：N/A (single-actor sprint)
- **Architect 模型**：Opus 4.7
- **触发事件**：Sprint O closeout §2.4 + retro §8 推荐 — Sprint P 候选 A "v0.2 patch sprint"，user ACK 启动
- **战略锚点**：[ADR-028](../../decisions/ADR-028-strategic-pivot-to-methodology.md) §2.3 Q3 + Sprint O closeout/retro

---

## 1. 背景

### 1.1 前置上下文

Sprint L+M+N+O 完成 framework 4 模块完整（86 files / ~10700 lines / dogfood 全过 / 20 v0.2 候选）。Sprint O retro §8 明确 Sprint P 推荐 **v0.2 patch sprint**（清债 + release）。

Sprint P 在大局中位置：

```
Sprint L → M → N → O (4 模块抽象)
                     ↓
Sprint P (v0.2 patch + release) ← 现在
                     ↓
Sprint Q (audit_triage 抽象，第 5 模块)
```

完成后：

- framework v0.2 公开 release（GitHub tag + RELEASE_NOTES）
- 14 → 6 v0.2 待办（剩余 6 项是大工作 or 押后等外部触发）
- framework 对外可见性显著升级

### 1.2 与前 4 sprint 的差异

| 维度 | Sprint L-O | **Sprint P** |
|------|-----------|------------|
| 抽象类型 | 新模块抽象 | **incremental fix + ceremonial release** |
| 抽象输入 | services/pipeline 代码 / docs | **20 项 v0.2 候选 + 4 模块版本元信息** |
| 角色配置 | single / multi actor | **single-actor**（与 L+M 同）|
| dogfood gate | covered / byte-identical / soft-equivalent | **patch 后回归测 4 模块** |
| 风险等级 | low → medium | **low**（无新代码 / 全是已识别 fix）|
| 模型选型 | Opus / Opus+Sonnet | Opus 全程 |
| 工作量 | 1-3 会话 | **1 会话**（patch + release 都是机械工作）|

### 1.3 不做的事（Negative Scope）

- ❌ **不开发新 framework 模块**（audit_triage 留 Sprint Q）
- ❌ **不动 services/pipeline 生产代码**
- ❌ **不写 framework conftest + pytest tests**（DGF-N-03 + DGF-O-02 推迟到 Sprint Q）
- ❌ **不做 cross-domain examples**（DGF-N-04 + DGF-O-03 等外部案例方触发）
- ❌ **不做 EntityLoader.load_subset**（DGF-N-05 等用户提需求）
- ❌ **不立即触发 ADR-031 plugin 协议**（per Sprint M-O 同结论）

---

## 2. 目标范围

### 2.1 单 Track — v0.2 Patch + Release

**目标**：

1. 清 8 项 v0.2 待办（1 P2 + 7 P3）→ 14 → 6 剩余
2. 4 个 framework 模块 bump version 到 v0.2
3. 写 GitHub Release Notes
4. patch 后回归验证 4 模块仍然工作（sanity tests + dogfood）

**8 项待办清单**：

| ID | 类型 | 改动 | 估时 |
|----|------|------|------|
| **DGF-O-01 (P2)** | path 改环境变量 | 5 处 examples 路径硬编码改 `HUADIAN_DATA_DIR` env var + 构造函数参数 | ~30 分钟 |
| T-P3-FW-001 | brief-template polish | §1.2 表格灵活列数说明 | ~5 分钟 |
| T-P3-FW-002 | template cross-ref | retro §4 + stop-rules-catalog §7 紧密化 | ~5 分钟 |
| T-P3-FW-003 | stage-template polish | stage-3-review §2.0 review 形式选择指南 | ~10 分钟 |
| T-P3-FW-004 | brief-template polish | §8 D-route 段措辞调整 | ~5 分钟 |
| DGF-M-01 | brief-template 结构 | §3 加纯文档抽象 sprint 的 alt 段 | ~20 分钟 |
| DGF-N-01 | test util 通用化 | byte-identical compare() 加 `__field_aliases__` 通用机制 | ~15 分钟 |
| DGF-O-04 | code nit | Containment in_python_predicate 用 `inspect.isawaitable()` 替代 `hasattr` | ~5 分钟 |
| **小计** | — | **8 项** | **~95 分钟** |

**v0.2 release 准备**：

- 4 模块 README §8 版本信息加 v0.2 行
- 写 `framework/RELEASE_NOTES_v0.2.md`（顶层 release notes）
- 4 模块 `__version__` bump（identity_resolver / invariant_scaffold；sprint-templates / role-templates 是文档无 __version__）
- `git tag v0.2.0` 准备命令（push 时打 tag）

**完成判据**（5 项）：

- ✅ 8 项待办全部 fix + ruff clean + 4 module sanity 跑通
- ✅ 4 模块 README v0.2 信息更新
- ✅ RELEASE_NOTES_v0.2.md 就位
- ✅ STATUS.md / CHANGELOG.md 更新（v0.2 release 标记）
- ✅ Sprint P closeout + retro

### 2.2 Track 2

不适用（单 track）。

---

## 3. Stages（精简 — patch sprint 不需要 5-stage 模板）

### Stage 0 — 已完成（本 brief 即 inventory）

8 项待办 + release 准备已在 §2.1 列清。无需独立 inventory 文档。

### Stage 1 — Patch + Release Prep

按以下顺序：

1. **批 1：path 修复 (DGF-O-01)** — 5 处 examples，加 `HUADIAN_DATA_DIR` env var fallback
2. **批 2：template polish (5 项)** — T-P3-FW-001~004 + DGF-M-01
3. **批 3：code patches (2 项)** — DGF-N-01 (alias mechanism) + DGF-O-04 (isawaitable)
4. **批 4：v0.2 release prep** — 4 README 版本 + RELEASE_NOTES + version bumps
5. **批 5：sanity 回归** — 4 模块 import + framework core 各 module sanity 跑通

### Stage 1.13 — N/A（无 dogfood gate）

vs Sprint N+O，本 sprint 不需要严格 dogfood — patch 后回归测试足够。

### Stage 4 — Closeout

- 标记 14 → 6 待办
- methodology / framework versioning
- STATUS / CHANGELOG / retro / 衍生债（剩余 6 项）
- Sprint Q 候选议程

---

## 4. Stop Rules

1. **path patch 后任一 framework module 跑不通** → Stop，立即 revert + 重新审 path 修法
2. **template polish 后 brief-template 自我 dogfood 失败**（即下次 sprint brief 起草不顺）→ Stop，回滚改动
3. **DGF-O-04 isawaitable 改动破坏 ContainmentInvariant 测试** → Stop，revert + 保留 hasattr
4. **Sprint P 工时 > 2 会话** → Stop，评估是否拆 P.1 / P.2
5. **触发新 ADR ≥ 1** → Stop（patch sprint 不应该触发 ADR）
6. **v0.2 release 准备发现重大未发现 bug** → Stop，加做 patch（不强行 release）

---

## 5. 角色边界

| 角色 | 活跃度 | 主要职责 |
|------|-------|---------|
| 首席架构师 | 🟢 主导 | 全 stage / 单 actor |
| 其余 9 角色 | ⚪ 暂停 | — |

---

## 6. 收口判定

- ✅ 8 项 v0.2 待办全部 fix
- ✅ 4 模块 ruff clean + sanity tests pass
- ✅ 4 模块 README v0.2 版本信息
- ✅ RELEASE_NOTES_v0.2.md 就位
- ✅ docs/STATUS.md / CHANGELOG.md 更新
- ✅ Sprint P retro 含 D-route 资产盘点
- ✅ 衍生债登记（剩余 6 项）
- ✅ Sprint Q 候选议程（推荐 audit_triage 抽象）
- ✅ git tag v0.2.0 命令准备就位

---

## 7. 节奏建议

**单会话压缩**（推荐）：

会话 1（~2-3 小时）：
- Stage 1 第 1-3 批（path + template + code patches，~95 分钟）
- Stage 1 第 4-5 批（release prep + sanity 回归，~40 分钟）
- Stage 4 closeout + retro（~30 分钟）
- commit + push 命令准备

**舒缓 2 会话**（备选）：
- 会话 1：Stage 1 第 1-3 批 patch
- 会话 2：release prep + closeout

---

## 8. D-route 资产沉淀预期

- [x] **新增 methodology 草案**: 不预期（patch sprint 不抽新模式）
- [x] **已有 methodology 草案 v0.x → v0.(x+1) 迭代**: 不预期（patch 不改 methodology）
- [x] **框架代码 spike**: 4 模块 v0.2 release（vs v0.1 / v0.1.1）
- [x] **案例素材积累**: retro 中标注 v0.2 patch 元 pattern（"清债 sprint"作为 D-route 周期工作）
- [x] **跨领域 mapping 表更新**: 不预期

至少 2 项预期 → 满足 ADR-028 / C-22 的 ≥ 1 项要求。

**Layer 进度推进预期**：

- L1: 4 模块 v0.1 → v0.2（公开 release）
- L2: 不变
- L3: 不变（dogfood 已经在 Sprint L-O 完成）
- L4: framework v0.2 release = **L4 第一刀触发**（项目对外可见性升级 / GitHub release tag / 跨领域案例方更易发现）

---

## 9. 模型选型

- **Architect 主 session**：Opus 4.7（与 L+M+N+O 同）
- **理由**：patch + release 是机械工作 + 文档撰写，Opus 充分

---

## 10. Dogfood 设计

### 10.1 brief-template 第 5 次外部使用

本 brief 是 brief-template v0.1.1 的第 5 次使用。无新发现（template polish 项已在 Sprint M-O 识别）。

### 10.2 Sprint P 后 4 模块 v0.2 release 是 framework 的"出厂检验"

framework 4 模块 v0.2 release 标志：

- 4 sprint 的 dogfood 全部完成
- 主要 v0.2 衍生债清完（剩余 6 项是大工作或押后）
- 项目对外可见性升级（GitHub release tag）
- 跨领域案例方有正式 v0.2 baseline 可参考

→ 这是 D-route 的"L4 触发点"（per ADR-028 §2.3 Q3 推荐 framework v0.x release 是 L4 入口）。

### 10.3 起草本 brief 暴露的发现（即时登记）

无新 brief-template 改进候选 — DGF-M-01~03 + Sprint M v0.1.1 patch 之后 brief-template 用着顺手。

---

## 11. 决策签字

- 首席架构师：__ACK 待签 (2026-04-30)__
- 用户：__ACK 待签 (2026-04-30)__
- 信号：本 brief 用户 ACK 后 → Sprint P Stage 1 启动

---

**本 brief 起草于 2026-04-30 / brief-template v0.1.1 第五次外部使用**
