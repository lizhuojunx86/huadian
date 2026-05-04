# Sprint W Retro — methodology v0.2 cycle 持续 (/05 + /07 → v0.2)

> 起草自 `framework/sprint-templates/retro-template.md` v0.1.1
> Dogfood: retro-template **第 13 次**外部使用

## 0. 元信息

- **Sprint ID**: W
- **完成日期**: 2026-04-30
- **主题**: methodology v0.2 cycle 持续 / methodology/05 + /07 双 doc → v0.2
- **预估工时**: 1.5 会话
- **实际工时**: **1.5 会话 ≈ 120 min**（紧凑路径达成 ✓）
- **主导角色**: 首席架构师（Claude Opus 4.7）— single-actor sprint

---

## 1. Sprint 任务回顾

### 1.1 Stage 顺序与产出

| Stage | 主导 | 状态 | 关键产出 |
|-------|------|------|----------|
| Stage 0 inventory + brief 起草 | Architect | ✅ | brief-template **v0.1.4 第 1 次外部 dogfood** ⭐（7 子类首试）|
| Stage 1 批 1 — methodology/05 v0.1.1 → v0.2 | Architect | ✅ | + §8 Audit Immutability Pattern + §7.6 ADR-032 引用 / 532 行 |
| Stage 1 批 2 — methodology/07 v0.1 → v0.2 | Architect | ✅ | + §9 Tooling Pattern (4 子模式) / 426 行 |
| Stage 1.13 sanity | Architect | ✅ | 60/60 in 0.06s + 5 模块 |
| Stage 4 closeout + retro | Architect | ✅ | 4 docs |

### 1.2 数据 / 工程基线 Δ

| 维度 | Sprint 前 | Sprint 后 | Δ |
|------|---------|---------|-----|
| methodology v0.2 doc 数 | 1/8 (/02) | **3/8** (/02 + /05 + /07) ⭐ | +2 |
| methodology /05 版本 | v0.1.1 | **v0.2** (+§8 Audit Immutability) | 大 bump |
| methodology /07 版本 | v0.1 | **v0.2** (+§9 Tooling / 4 子模式) | 大 bump |
| ADR 数 | 32 | 32 (不变 / Sprint W 不起 ADR) | 0 |
| Stop Rule 触发 | 0 (Sprint V 接续) | **0**（连续 8 sprint）⭐⭐ | 持续强化 |
| pytest tests | 60 | 60 | 不变 |

---

## 2. 工作得好的部分（What Worked）

### 2.1 brief-template v0.1.4 §2.1 子类化第 1 次外部 dogfood ≤ 5% 偏差边缘

vs Sprint S+T+U+V 累计 4 次 v0.1.3 dogfood（Docs 主导 < 10% / Code 主导 47%）：

| Sprint | 模板版本 | 主导子类 | 偏差 |
|--------|--------|--------|------|
| S | v0.1.3 | Docs | < 10% ✓ |
| T | v0.1.3 | Code | **47%** ⚠️ |
| U | v0.1.3 | Docs | < 10% ✓ |
| V | v0.1.3 | Docs (混 ADR) | < 10% ✓ |
| **W** | **v0.1.4** | **Docs: new doc 起草子类** | **5.5% ✓** |

→ v0.1.4 子类化第 1 次实证：Docs: new doc 起草子类**精度 ≤ 5%（边缘达标）**。其他 6 子类待 Sprint X+ 用 mix 子类 sprint dogfood 验证。

**沉淀**：v0.1.4 模板对 Docs 主导 + new doc 起草子类 stable / 累积证据 1 次 / 需要更多 sprint dogfood 验证其他子类（特别是 Code: 框架 spike vs Code: 新模块抽象 是否真分得开）。

### 2.2 §8 Audit Immutability Pattern 抽出价值

audit immutability 在 v0.1 时分散在 §2.2 schema + §4 hint banner + §6.6 反模式 中，没 first-class 化。Sprint W 抽出 §8：

- 2 sub-patterns 合一（multi-row + surface_snapshot 冻结）
- 5 领域跨域 fork 启示（古籍 + 法律 + 医疗 + 金融 + hypothetical）
- 6 反模式（vs 仅 §6.6 一条）
- 与 /02 + /04 + /06 + /07 cross-ref 紧密化

**沉淀**：跨域 fork 案例方读 §8 即可独立判断 audit immutability 是否保留（vs v0.1 需要扫遍 §2-§6 才能拼出完整图像）。

### 2.3 §9 Tooling Pattern 4 子模式抽出价值

§9 抽出 cross-stack 抽象的 4 个 enabler tooling：

- §9.2 SQL Syntax Validation（pglast / 跨外部贡献者直接复用）
- §9.3 Minimum Schema Subset Docker（Approach B / 跨域 fork 直接复用）
- §9.4 Cross-Stack Sync Pre-commit Hook（Sprint R 实证 / 跨域可改 path regex 复用）
- §9.5 Hybrid Release Sprint Pattern Adaptation（/02 v0.2 §15.3 cross-ref）

每子模式都有"问题 / 做法 / 实证 / 反模式 / 收益"5 段式结构，跨域 fork 友好。

**沉淀**：tooling pattern 是 cross-stack 抽象的"可执行性"保证（vs 抽象本身只是 design intent / tooling 让 design 在 sandbox / CI 可行）。

### 2.4 8 sprint zero-trigger 持续强化（连续第 8 个）

- ADR-031 §3 #2 要求 "≥ 5 sprint zero-trigger" / 当前已 8 / **超额 60%**
- 8 sprint 覆盖 5 种形态（清债 / 新模块 / 评估 / release / 大 feature fold + methodology cycle 起步 + 持续）
- 框架 v0.3 + maintenance + eval + release + methodology cycle 节律稳定信号**全形态确认**

**沉淀**：v1.0 触发条件 #2 已**远超阈值**（5 → 8 / 60% buffer）。但其他条件（API 6 个月稳定 / 跨域 ref impl / 第三方 review / methodology 全 v0.2 / patch ≥ 95%）仍是制约因素。

---

## 3. 改进点（What Didn't Work）

### 3.1 v0.1.4 第 1 次外部 dogfood 仅验证 1 子类（Docs: new doc 起草）

7 子类只用了 1 个（Docs: new doc 起草）。Code 3 子类 + Docs cross-ref polish + Docs ADR + Closeout 仍未实证。

**改进建议**：
- 不严重（Sprint W 主题确实是纯 new doc 起草 / 用 1 子类合理）
- 但累积 dogfood 数据不足以宣布 v0.1.4 模板"全通过"
- Sprint X+ 用 mix 子类的 sprint（如 v0.5 maintenance + methodology v0.2 / 含 Code patch + Docs cross-ref + ADR）才能 round-trip 验证

### 3.2 §8 + §9 之间的 cross-ref 弱

/05 §8 Audit Immutability Pattern + /07 §9 Tooling Pattern 之间没有 inline cross-ref（仅 /05 §8.6 + /07 §8 各自 cross-ref 表中提及对方 doc / 但没 inline 跨段）。

**改进建议**：
- 不严重（/05 §8.6 + /07 §8 cross-ref 表已是高水平 cross-ref）
- 可在 v0.5 polish 时考虑（如 Tooling 让 audit immutability 在跨 stack dogfood 中 verifiable / 这种 inline 关系可在 §9.6 加段）
- 已记 v0.5 候选 / 不算独立 debt

### 3.3 用户 brief preview 时 / "我倾向 yes/no" 提前透露

类似 Sprint S+U retro §3.3 同问题：本 brief preview 已说"倾向"。但 Sprint W brief 我已收敛此风格 / 仅给推荐选项 / 由用户 ACK 决定。

**改进建议**：维持收敛风格 / Sprint X+ 同。

---

## 4. Stop Rule 触发回顾

> 触发处理协议见 `framework/sprint-templates/stop-rules-catalog.md` §7。

**无触发**（连续第 **8** 个 zero-trigger sprint：P→Q→R→S→T→U→V→W）⭐⭐。

| Rule | 类别 | 触发原因 | 架构师裁决 | trigger 文件 |
|------|------|---------|-----------|-------------|
| — | — | 无触发 | — | — |

---

## 5. Lessons Learned

### 5.1 工程层面

#### "v0.x cycle 持续 sprint" 形态成熟（Sprint W = 第 2 sprint）

vs Sprint V 起步 sprint（maintenance + main doc bump 合并），Sprint W 是纯 v0.x cycle 持续 sprint：

| 形态 | 实证 sprint | typical 工时 | 触发条件 |
|------|-----------|-----------|---------|
| v0.x cycle **起步** sprint | Sprint V | 1.5-2 会话 | maintenance + main doc bump 合并 |
| **v0.x cycle 持续 sprint** | **Sprint W** | **1.5 会话** | **每 sprint 1-2 doc bump** |

→ v0.x cycle 持续 sprint 已实证 stable。methodology/02 v0.3 候选段（待 Sprint X+ 起草）应正式收录。

**沉淀**：methodology v0.2 cycle 完成预估 = **Sprint W (本) + 3 sprint** = Sprint W+X+Y+Z（共 4 sprint × 2 doc/sprint = 8 doc 全 v0.2）/ 与 Sprint U residual debts §5 估算（4-5 sprint）一致。

#### Audit Immutability Pattern 是 audit 类 framework 的核心约束

§8 抽出后回看 Sprint Q audit_triage 抽象（multi-row + surface_snapshot 冻结）的设计：

- 当时 (Sprint Q) 仅在 framework code 中实现 / 没 first-class 化为 methodology pattern
- Sprint U 起草 /07 cross-stack abstraction pattern / methodology 视角扩展
- Sprint V 起 ADR-032 retroactive / decision 视角补全
- **Sprint W 起 §8 Audit Immutability** / pattern 视角抽出

→ 4 sprint 累积才把 audit_triage 抽象的"complete picture"沉淀完整（framework code + ADR + cross-stack pattern + immutability pattern）。

**沉淀**：framework v0.x 抽象的"complete picture"经常需要 ≥ 3-4 sprint 才能沉淀完整（vs single sprint 落地代码 / 但 methodology + ADR 都需要后续 sprint）。Sprint U+V+W 的 audit_triage 三连抽象是该 pattern 的实证。

#### Tooling Pattern 是跨 stack 抽象的"使能"

§9 4 子模式实证：

- 没 §9.2 (SQL syntax validation) → 编辑 cycle 慢 5-10x
- 没 §9.3 (Minimum schema Docker) → sandbox / CI 不能跑 dogfood
- 没 §9.4 (Pre-commit hook) → 跨 stack drift 风险
- 没 §9.5 (Hybrid release) → 大 feature 等单独 mini-sprint / 节奏混乱

→ 跨 stack 抽象不仅是"abstract code design"，更是"toolchain 使能"。

**沉淀**：未来跨 stack 抽象 sprint 应该把 tooling 作为 first-class deliverable（vs 临时凑工具）。

### 5.2 协作层面

Sprint W 是 single-actor sprint，无跨角色协作。

但 §8 Audit Immutability + §9 Tooling 让跨外部贡献者**有清晰 fork 起点**：
- §8 是"何时保留 immutability 约束"
- §9 是"如何使能跨 stack 抽象"
- 两者合一 = 跨域 fork 案例方的"complete starter pack"

**沉淀**：methodology v0.2 cycle 的核心价值不只是"加段"，而是让跨外部贡献者从"理解 framework"升级到"独立 fork + 实施"。

### 5.3 模型选型 retro

**Architect = Opus 4.7（全程）**：合适。

§8 + §9 起草需要：
- 综合多 sprint 实证（/05 §8 ← Sprint Q+G+H / /07 §9 ← Sprint R+T+U）
- 写作风格统一（与原 §1-§7 一致）
- 跨 doc cross-ref（/05 §8.6 + /07 §8 cross-ref 表）
- 4 子模式 + 6 反模式的精确表格设计

→ Opus 必要。Sonnet 风险点：表格设计偶尔 inconsistent / 多 doc cross-ref 易漂移。

未来 v0.x cycle 持续 sprint 都应保 Opus。Sonnet 仅适合**纯 polish / 模板化** sprint（未来如 maintenance fold pure patch）。

---

## 6. 衍生债登记

本 sprint 收口后：**新 0 项 v0.5 候选**（Sprint W 是 methodology iter / 未触发新发现）。

**v0.5 候选清单（不变 / 累计 2 项）**：
- (Sprint V 留) T-V05-FW-001：methodology/06 v0.2 起草时 fold ADR-032 §5 retroactive lessons
- (Sprint V 留) T-V05-FW-002：methodology/02 v0.2.1 polish §14+§15 cross-ref

押后清单（不变）：
- v0.2: 2 项（DGF-N-04 + DGF-N-05 / 等外部触发）

详见 `docs/debts/sprint-w-residual-debts.md`。

---

## 7. D-route 资产沉淀盘点

### 7.1 本 sprint 沉淀的可抽象 pattern

1. **"v0.x cycle 持续 sprint" 形态成熟**（Sprint V 起步 + Sprint W 持续 = 2 sprint 实证 / 待 methodology/02 v0.3 收录）
2. **§8 Audit Immutability Pattern**（multi-row + surface_snapshot 冻结 / first-class 抽出）
3. **§9 Tooling Pattern for Cross-Stack Abstraction**（4 子模式 / pglast + Docker minimum + sync hook + Hybrid release）
4. **"framework 抽象 complete picture 需 ≥ 3-4 sprint" 元规律**（Sprint Q+U+V+W 4 sprint 累积才把 audit_triage 抽象沉淀完整）
5. **brief-template v0.1.4 子类化首验证**（≤ 5% 偏差 / 但仅 1 子类实证）

### 7.2 本 sprint 暴露的"案例耦合点"

无新案例耦合（pure methodology iter）。

### 7.3 Layer 进度推进

- L1: 5 模块 v0.3.0 不变
- L2: methodology v0.2 cycle 1/8 → **3/8** ⭐（/05 + /07 加入）/ 距 ADR-031 #7 达成 5 doc / 推荐 Sprint X+N 每 sprint 1-2 doc
- L3: 不变
- L4: 不变（Sprint W 不起 ADR）

### 7.4 下一 sprint 抽象优先级建议

per Sprint W retro §3 + ADR-031 §6.4 + Sprint V residual debts §5：

剩余 5 doc 待 v0.2：
- /00 framework-overview v0.1.1 → v0.2（小工作 / §2 v0.1.1 已加 7 大核心抽象 / v0.2 加 cross-doc 网状结构图）
- /01 role-design v0.1.2 → v0.2（推荐 / 加新 first-class section / Sprint M+role-templates v0.2.1+0.3.1 实证支撑）
- /03 identity-resolver v0.1.2 → v0.2（推荐 / 加 byte-identical dogfood pattern first-class）
- /04 invariant v0.1.2 → v0.2（推荐 / 加 self-test pattern first-class）
- /06 adr-pattern v0.1.1 → v0.2（推荐 / fold T-V05-FW-001 retroactive lessons / 加 release-trigger vs release-eval ADR 模板对比 first-class）

**Sprint X 候选 A**（推荐）：methodology v0.2 cycle 持续 / 1-2 doc / 1.5 会话
- 推荐 1: /06 + 推荐 2: /04（双 doc / Sprint W 同模式）
- 或 1 doc 深度 polish

**Sprint X 候选 B**：v0.5 maintenance（v0.5 仅 2 候选 / 不急）

**Sprint X 候选 C**：跨域 outreach（押后等触发）

---

## 8. 下一步（Sprint X 候选议程）

依据本 retro 发现：

- **优先选 候选 A（methodology v0.2 cycle 持续 / 推荐 /06 + /04 双 doc / 1.5 会话）**
- /06 fold T-V05-FW-001 retroactive lessons（同 sprint 顺手 / per Sprint V residual debts §3.1）
- /04 加 self-test pattern first-class（与 §02 v0.2 §13 跨 stack invariance 实证锚点同 sprint 强化）

不要做的事：
- ❌ 不在同 sprint 同时 bump > 2 doc（避免 scope creep）
- ❌ 不立即 release v1.0 / v0.4
- ❌ 不动 framework v0.3 ABI

---

## 9. 决策签字

- 首席架构师：__ACK 2026-04-30 (Architect)__
- 用户：__ACK 待签__
- 信号：本 retro 用户 ACK + commit + push → **Sprint W 关档 / Sprint X 候选议程激活（推荐 /06 + /04 → v0.2）**

---

**Sprint W retro 起草于 2026-04-30 / retro-template v0.1.1 第 13 次外部使用 / Architect Opus**
