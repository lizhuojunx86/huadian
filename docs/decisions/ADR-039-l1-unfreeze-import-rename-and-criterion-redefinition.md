# ADR-039 — L1 解冻：import-root 改名 + 领域无关判据重定义

- **Status**: **accepted**（2026-06-20 用户在 B3 决策中选「改 import-root + 重定义判据（推荐）」组合）
  - **③ 判据重定义**：即时生效（本 ADR + STATUS 真相表已落）
  - **① import-root 改名**：**已执行（2026-06-20）**——用户"执行改名"令后按 §5 完成：`mv framework kb_forge` + 73 imports/51 文件 `framework.`→`kb_forge.` + pyproject + 13 活文档路径；**pytest 93 passed / 0 回归**（py3.12 via uv，沙箱默认 py3.10 不满足 requires-python≥3.12）。沙箱 `rm` 受限留下 `.__sandbox_trash/`（用户本地 `rm -rf` 清理）。diff 待用户本地 commit。
- **Date**: 2026-06-20
- **Authors**: 首席架构师（Claude）+ 用户决策
- **Related**:
  - [ADR-037](ADR-037-framework-package-naming.md) — 定 distribution name = `kb-forge`，**主动 defer import-root 改名**到"v0.1 前专门 sprint"。本 ADR **解冻该 defer**。
  - [l1-domain-agnostic-finding-2026-06-20](../reports/l1-domain-agnostic-finding-2026-06-20.md) — 本 ADR 的调研依据
  - [D-route §5/§10](../strategy/D-route-positioning.md) — L1 完成判据
  - [d-route-progress-review-2026-06-07](../reports/d-route-progress-review-2026-06-07.md) §5 #3 — L1 领域无关比例判据
- **Supersedes**: ADR-037 §2 末句"import root 暂保持 framework"（本 ADR 解冻）；D-route §10"领域无关 LOC ≥ 70%"判据（本 ADR §2.③ 重定义）

---

## 1. Context

B3「L1 解冻」调研（finding 2026-06-20）确立两个事实：

1. **core 已 0 领域字样**：framework/ 的 core(4661 行)+tests(1819 行)=64.4% 领域无关，且 core 本身无任何史记/中药字样——工程隔离（PEP 544 Protocol）已达成。逐文件核查 3 个嫌疑文件确认 examples 内全是真·领域专属（SQL 引用史记表 / 装配 V4-V11 不变量）。**无泄漏可下沉。**
2. **「≥70% LOC」是单案例阶段的失真代理**：任何"框架 + 一个丰富 example"的仓库按 LOC 都会显得领域偏重；64.4% 偏低是"只有一个 example"造成，不是工程缺陷。靠搬/砍 example 刷比例 = 损坏活体证明换数字 = 反模式。

用户据此选「①改 import-root + ③重定义判据」组合：① 是 v0.1 的真门槛、且是"真解冻 L1"最实的一步；③ 把失真的 LOC 指标换成直接测 framework-ness 的判据。

---

## 2. Decision

### ① 解冻 ADR-037 的 defer，执行 import-root 改名 `framework.*` → `kb_forge.*`

- distribution name 早已是 `kb-forge`（ADR-037）；本 ADR 让 **import root** 与之对齐。
- 从源码跑测试时 `from kb_forge.x import` 要求磁盘目录同名 → **必须 `git mv framework kb_forge`**（这是 churn 的根源，也是 ADR-037 当初 defer 的原因）。
- 执行范围见 §3（红线影响面）。**用户给最终执行令后，架构师按 §5 checklist 一次性完成，pytest 93 passed 为验收闸。**

### ③ 重定义「领域无关」判据

| | 旧（D-route §10）| 新（本 ADR） |
|---|---|---|
| 判据 | 领域无关 LOC 比例 ≥ 70% | **(a) core+tests 0 领域字样** + **(b) ≥2 个真实 domain 各自隔离复用同一 core** |
| 现状 | 64.4% → ❌ | (a) ✅ 已达成；(b) traceguard tcm PoC 为半证、完整第 2 domain 待引入 → **1/2 → 🟡** |
| 理由 | LOC 比例对单 example 阶段失真、有 Goodhart 风险 | 直接测"框架是否真领域无关 + 是否被第 2 域复用"——这才是 70% 想代理的东西 |

**注（防止被读作"为达标改标准"）**：新判据**没有把状态改成 ✅**，而是 🟡（隔离达成、第 2 domain 未到）。这是用更诚实的指标替换一个失真指标，不是粉饰；剩余 gap（第 2 domain）被显式保留。

---

## 3. import-root 改名影响面（红线 #1/#3 — 执行前 scope 披露）

> 用户对本节"明确同意"= 改名执行令。

| 维度 | 范围 | 风险 / 缓解 |
|---|---|---|
| **目录重命名** | `framework/` → `kb_forge/`（`git mv`，含其下 45 个非 .py：sprint-templates / role-templates / READMEs / pyproject / schema.sql）| 红线 #1。`git mv` 全程在 git，可一条 `git mv` 回滚 |
| **.py import 改写** | 51 文件 / 73 处 `from framework.` `import framework` → `kb_forge` | 红线 #3。机械 sed；examples 的 `parents[4]` 数据路径**靠目录深度不靠名字 → 改名后深度不变、不受影响**（已核） |
| **外部 .py 依赖** | **0**（framework/ 之外全仓 0 个 `import framework.*`）| 爆炸半径 contained 在原 framework/ 内 |
| **packaging** | `framework/pyproject.toml`：`packages.find include` `framework*` → `kb_forge*` + 注释里 defer 说明改为 done | pytest 验收 |
| **framework 内部文档** | README / CONCEPTS / cross-domain-mapping 里 `framework.` import 范例 + `framework/` 路径 | 随 dir 一起 mv，内文 sed |
| **live 文档路径引用** | ~36 个 live .md（CLAUDE.md / STATUS / strategy / methodology/03 / ADR-037 等）里的 `framework/` 路径 → `kb_forge/` | 文档 churn，sed + 复核 |
| **历史文档** | 41 个 sprint-logs/retros 里的 `framework/` | **不改**（dated 快照，改了等于篡改历史）；在改名 commit message 注明"历史日志保留旧路径名" |
| **git tag** | v0.3.0 / v0.2.0 指向 commit，**不受路径改名影响** | 无需动 tag |
| **pinned 下游** | traceguard pin 的是 guardian tag；storyextractor 借模式不 import kb-forge（ADR-038）→ **无下游 import 受影响** | 已核 |
| **验收闸** | `pytest framework→kb_forge 三个 tests 目录` 必须 **93 passed / 0 回归** + ruff clean | 不过则 `git reset` 回滚 |
| **回滚** | 全部在一个 commit；未 push 前 `git reset --hard` 即恢复 | 用户 review diff 后再本地 commit |

---

## 4. Alternatives Considered

| 方案 | 说明 | 否决理由 |
|---|---|---|
| **A. 目录重命名 `framework/`→`kb_forge/`（采纳）** | 真·import-root 改名，source + installed 都干净 | churn 大，但唯一干净解 |
| B. 保留 `framework/` 目录，靠 `package_dir={"kb_forge":"framework"}` 映射 | 仅 installed 有效 | 从源码跑测试 `from kb_forge.x` 仍失败（测试跑在源码态）→ 不解决问题 |
| C. 加 `kb_forge` 顶层 shim re-export framework | 双导入名并存 | 不是"改名"是"加别名"，更乱，违 ADR-037 干净化意图 |
| D. 维持 `framework`，永不改 | 零 churn | import 名与 dist 名（kb-forge）长期不一致，v0.1 release 前提不达标 |

---

## 5. Execution Checklist（用户给执行令后，一次性完成）

1. `git mv framework kb_forge`
2. sed 51 文件 73 处：`framework.` → `kb_forge.`（`from framework` / `import framework`）
3. 改 `kb_forge/pyproject.toml`：include 列表 + 注释（defer→done）
4. sed framework 内部文档（README/CONCEPTS/cross-domain-mapping）import 范例 + 路径
5. sed ~36 个 live 文档 `framework/`→`kb_forge/`（**跳过 sprint-logs/retros 41 个历史快照**）
6. 改 CLAUDE.md（§2.4 路径 / §7 命令 / 其它 framework/ 引用）
7. `pytest` 三个 tests 目录 → 必须 93 passed；ruff check + format
8. ADR-037 状态加注"import-root 改名由 ADR-039 解冻并执行（2026-06-20）"；本 ADR-039 状态 ① → executed
9. STATUS：真相表「框架代码近期有推进」🟡→✅（解冻+改名）；「L1 命名」补 import-root 对齐；CHANGELOG 记 `refactor(framework)!: rename import root framework.* -> kb_forge.* [ADR-039]`
10. ADR-000-index 加 039 行
11. **diff 交用户 review → 用户本地 commit**（沙箱 .git 只读）

---

## 6. Consequences

**正面**：L1 真解冻（核心结构改动，非补测试）；import 名 = dist 名（kb-forge）一致；v0.1 release 路径上最后一个 packaging 障碍清除；判据从失真 LOC 换成诚实的"隔离+多域"。

**负面/成本**：一次性大 churn（~50 .py + ~36 doc）；历史日志路径名与现状不一致（已决定保留快照 + commit 注明）；改名 commit 体积大（review 成本）。

**风险**：sed 误伤字符串里非 import 的 "framework"（缓解：限定 `from framework` / `import framework` / `framework/` 精确模式，diff 复核）；pytest 回归（缓解：93 passed 硬闸 + git 回滚）。

---

## 7. Out of Scope

- PyPI 实际发布 / `pip install -e` editable 安装验证（留 v0.1）
- framework 从 huadian 单仓拆出（独立决策）
- 第 2 个真实 domain example 的引入（③(b) 的达成路径，留 2027 路线图"可移植性验证"里程碑）

---

**本 ADR 终结线**：L1「领域无关」不再用失真 LOC 比例衡量；import-root 改名已获原则批准，执行 gated 在用户对 §3 的最终执行令。
