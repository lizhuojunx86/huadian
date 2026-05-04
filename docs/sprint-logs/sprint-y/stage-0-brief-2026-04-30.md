# Sprint Y Stage 0 — Brief

> Status: draft → 待用户 ACK
> Date: 2026-04-30
> Brief-template version: **v0.1.4 第 3 次外部 dogfood**
> 主导：Architect Opus 4.7 (single-actor)
> Subject: methodology v0.2 cycle 持续 / /00 + /01 → v0.2 / 1 会话紧凑

---

## 1. 目标

methodology v0.2 cycle 持续推进（per Sprint X retro §8 候选 A）：

1. **批 1**: methodology/00 v0.1.1 → v0.2
   - + §X cross-doc 网状图（8 doc 互引图 + Layer cross-ref）
   - 把当前散落 §2 表格 + §6 上手路径里的 cross-ref 沉淀成 first-class 章节
2. **批 2**: methodology/01 v0.1.2 → v0.2
   - + §X Role Evolution Pattern first-class（Sprint M + role-templates v0.2.1+0.3.1 实证 + ADR-032 retroactive 对架构师角色的影响）

methodology v0.2 cycle 进度推进：**5/8 → 7/8** ⭐（距 ADR-031 #7 触发仅剩 /03）

---

## 2. 估时表（brief-template v0.1.4 7 子类 / 第 3 次外部 dogfood）

| 子类 | 本 sprint 任务 | 估时 | 实际（待回填）|
|------|--------------|------|--------------|
| Code: 框架 spike | — | — | — |
| Code: 新模块抽象 | — | — | — |
| Code: patch / version bump | — | — | — |
| Docs: cross-ref polish | — | — | — |
| **Docs: new doc 起草** | /00 v0.2 + /01 v0.2 | **~75-90 min** (~30 + ~50) | TBD |
| Docs: ADR / 决策记录 | — | — | — |
| **Closeout / Retro** | stage-4-closeout + retro + STATUS + CHANGELOG + debts | **~25-30 min** | TBD |

**总估时**: ~100-120 min ≈ **1 会话紧凑**（vs Sprint W/X 1.5 会话 / 减少 17-25%）

**v0.1.4 第 3 次 dogfood 关注点**：
- Sprint W (5.5%) + Sprint X (0% + -12.5%) 累计趋势 → Sprint Y 验证连续 4 次 dogfood 是否收敛 ≤ 5% 平均
- Closeout / Retro 子类第 2 次独立验证（Sprint X 第 1 次 / Sprint Y 累积）

---

## 3. Stage 路径

```
Stage 0 — brief 起草（本文件）✅
Stage 1 批 1 — methodology/00 v0.1.1 → v0.2（小工作）
Stage 1 批 2 — methodology/01 v0.1.2 → v0.2（中等工作）
Stage 1.13 — sanity 回归（60 pytest + 5 模块 + ruff/format）
Stage 4 — closeout + retro + STATUS/CHANGELOG + Sprint Z 候选
```

不需 Stage 2/3。**1 会话紧凑路径 / 不中场 commit**（vs Sprint V/W/X 中场 push）。

---

## 4. 改动设计（细节）

### 4.1 批 1 — methodology/00 v0.1.1 → v0.2

**当前 (v0.1.1)**：220 行 / §0-§9 / Sprint U 批 4 加第 7 项 cross-stack pattern

**v0.2 加段**：

#### 4.1.1 §X Cross-Doc 网状图 (新 first-class section)

placement：在 §2 7 大核心抽象后 / §3 框架形态前（§2.5 或 §3 之前 / 新 §3）。

内容 sub-sections：
- §X.1 8 doc 角色 + Layer 关系图
  - 8 doc 分类：1 入口 (/00) / 5 核心 pattern (/01-/05) / 2 跨 framework (/06 ADR / /07 cross-stack)
  - ASCII art 或 markdown 表格图示 8 doc 互引关系
- §X.2 cross-ref 速查矩阵
  - 8x8 矩阵（or compact list）/ 每对 doc 关系简注
- §X.3 read order by 角色
  - 5 类读者：framework 工程师 / 研究者 / 项目管理者 / 数据科学家 / 跨域 fork 团队
  - fold §6 上手路径 (4 类) + 加第 5 类 "跨域 fork 团队"
- §X.4 v0.2 cycle 进度速查（live 更新）
  - 8 doc 当前版本 + Sprint Y 后状态 (Y 后 7/8) + Sprint Z 完成预测

#### 4.1.2 § 修订历史 §9 → §10 重编号

**估算**: ~80-100 行加 / 300-320 总行（小 doc / 远内于任何阈值 / Stop Rule N/A）

### 4.2 批 2 — methodology/01 v0.1.2 → v0.2

**当前 (v0.1.2)**：414 行 / §0-§10 + 修订历史 §11 / Sprint S 批 2 加 §10 元 pattern cross-ref

**v0.2 加段**：

#### 4.2.1 §X Role Evolution Pattern (新 first-class section)

placement：在 §6 角色活跃度调整后 / §7 反模式前（新 §7 / 旧 §7-§10 重编 §8-§11 / 修订历史 §11→§12）。

内容 sub-sections：
- §X.1 角色不是静态契约，是演化的工程实体
  - "role 定义 v0.x → v0.(x+1)" 概念引入
- §X.2 实证：Sprint M role-templates v0.2.1+0.3.1 演化轨迹
  - v0.2.0 (Sprint M 初创) → v0.2.1 (Sprint Q 加 §工程小细节) → v0.3.0 (Sprint T release prep) → v0.3.1 (Sprint V/V 加 commit hygiene)
  - 每次 patch 触发条件 + 演化模式
- §X.3 ADR-032 retroactive 对架构师角色的影响
  - retroactive ADR 决策机制对架构师"何时起 ADR"的更新（per /06 §8.4）
  - chief-architect §工程小细节 v0.3.1 加第 4 条 commit hygiene 的演化 case study
- §X.4 角色版本号约定
  - role.{major}.{minor}.{patch} 与 framework 模块版本耦合的契约
- §X.5 跨域 fork 启示
  - 跨域 fork 时不要"全盘 copy 角色定义"/ 应该"copy 后基于自己的 retro 演化角色 patch"

#### 4.2.2 § 重编 §7→§8 / §8→§9 / §9→§10 / §10→§11 / 修订历史 §11→§12

**估算**: ~90-110 行加 / 504-524 总行（vs 阈值 600 / 84-87% 容量 / Stop Rule N/A）

---

## 5. 关键文件清单

修改：
- `docs/methodology/00-framework-overview.md` (v0.1.1 → v0.2)
- `docs/methodology/01-role-design-pattern.md` (v0.1.2 → v0.2)
- `docs/STATUS.md` (Layer 1+2+4 + §2.2.13 Sprint Y + §2.3 Sprint Z)
- `docs/CHANGELOG.md` (Sprint Y 块前置)

新建：
- `docs/sprint-logs/sprint-y/stage-0-brief-2026-04-30.md` (本文件)
- `docs/sprint-logs/sprint-y/stage-4-closeout-2026-04-30.md`
- `docs/retros/sprint-y-retro-2026-04-30.md`
- `docs/debts/sprint-y-residual-debts.md`

无 framework code 改动（pure docs sprint）/ 无 ADR 起草。

---

## 6. 收口判据（5 项）

1. methodology/00 v0.1.1 → v0.2（+§X Cross-Doc 网状图 / 4 sub-sections）
2. methodology/01 v0.1.2 → v0.2（+§X Role Evolution Pattern / 5 sub-sections / 全 §7-§10 + 修订历史重编号）
3. 5 模块 sanity 不回归 + 60 pytest 全绿
4. STATUS / CHANGELOG / retro / 衍生债 + Sprint Z 候选 全 land
5. methodology v0.2 cycle 进度更新：5/8 → **7/8** ⭐（距 ADR-031 #7 触发仅剩 /03）

---

## 7. Stop Rule 风险评估

| Rule | 风险 | 应对 |
|------|------|------|
| #1 单 batch 工时超 1.5x | 低 | Docs new doc 子类已实证连续 2 次 dogfood / 偏差 [-12.5%, +5.5%] |
| #2 单 batch 改动 file > 5 | 低 | 各批仅 1 file |
| #3 doc 总行 > 600 (/00) | **极低** | /00 当前仅 220 行 / +80-100 = 300-320 / 远内于阈值 |
| #4 doc 总行 > 600 (/01) | 低 | /01 当前 414 行 / +90-110 = 504-524 / 84-87% 容量 |
| #5 跨 sprint 决策残留 | 低 | 无 fold target |

**当前预测**：连续第 10 个 zero-trigger sprint 概率高（双 doc 都体量内 / 1 会话紧凑）。10 sprint 里程碑 ⭐⭐⭐ → ADR-031 #2 进 100% over target。

---

## 8. 下一步

待用户 ACK 本 brief → Architect 启动 Stage 1 批 1（methodology/00 v0.2）→ 直接 Stage 1 批 2（methodology/01 v0.2 / 不中场 commit / 1 会话紧凑）→ Stage 1.13 + Stage 4 → 一次 commit + push (2 commits 整体)。

---

**brief 起草完成 / brief-template v0.1.4 第 3 次外部 dogfood / 待用户 ACK**
