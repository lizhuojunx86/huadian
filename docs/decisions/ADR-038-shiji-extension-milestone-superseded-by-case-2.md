# ADR-038 — 2026-08 史记延伸级里程碑由 case-2 顶替（路线图重对齐）

- **Status**: **proposed**（待用户 ACK — 涉及战略里程碑重定义，架构师不擅自改 D-route §6）
- **Date**: 2026-06-07
- **Authors**: 首席架构师（Claude Opus 4.8）/ 待用户 ACK
- **Related**:
  - [ADR-028](ADR-028-strategic-pivot-to-methodology.md)（D-route 战略转型 / Negative Space）
  - [D-route §6](../strategy/D-route-positioning.md)（2026-08 锚点"史记 5–10 篇典型章节延伸级 + 产品化 demo"）+ §7（Negative Space）+ §4 Sunset
  - [sprint-roadmap-D-route §2](../strategy/sprint-roadmap-D-route.md)（Sprint N 计划"吕后/孝文延伸级 ingest"）+ §5 Sunset
  - [ADR-036](ADR-036-case-3-dao-de-jing-candidacy-evaluation.md)（case-3 候选 / 2027-04 槽位已被 case-2 占用的判断）
  - `docs/reports/d-route-progress-review-2026-06-07.md` §3 + §5（里程碑漂移 gap）
- **Supersedes**: 部分修订 D-route §6 / roadmap §2 的史记延伸级条目（accepted 后执行）

---

## 1. Context

2026-06-07 进度评估发现一处**文档与实际战略的漂移**：

- D-route §6 仍写着 **2026-08：史记 5–10 篇典型章节延伸级 + 产品化 demo 上线**；sprint-roadmap §2 仍把 Sprint N 计划为"吕后/孝文本纪延伸级 ingest"。
- 但 **实际**：史记自转型（2026-04-29 / Sprint J 收口）起**零新章节 ingest**，冻结在 729 active persons / 3–4 本纪；`services/pipeline` 转型后零 commit；产能全部转向 case-2 中药案例。
- 同时 D-route **§4 Sunset 表**已把"完成史记 130 篇""大规模 ingest（>20 篇）"列为 Sunset。

于是 §4（Sunset）与 §6 / roadmap §2（仍计划延伸级 ingest）**自相矛盾**。这对一个把"可审计 / 诚实"当核心卖点的方法论项目是实打实的陈述债：未来"假装新协作者"按开工三步读到的计划与实际不符，违背"文档体系优先（人离开后能接续）"的架构师单点风险对策。

**这不是失控**——把精力从"再做几篇史记本纪"转到"case-2 跨域验证框架可移植性"，对**框架抽象**价值更高（符合 D-route mental model：案例服务于框架）。问题纯粹是**没有把这个合理的战略取舍正式登记**。本 ADR 补这一笔。

---

## 2. Decision（proposed）

**正式确认：2026-08"史记 5–10 篇延伸级"里程碑的延伸级 ingest 部分，由 case-2 中药案例顶替，不再追求史记新章节。** 史记的角色重定义为 **"已冻结的框架 dogfood 底物"**（16 个 sprint 已用它验证 R1-R6 / V1-V11 / guard chain / sprint-templates / role-templates），而非"持续延伸的活跃案例"。

具体重定义：

| 原 2026-08 里程碑分项 | 重定义后 |
|---|---|
| 史记 5–10 篇典型章节**延伸级 ingest** | **撤销**（与 §4 Sunset 一致）；史记定格 729 persons / 3–4 本纪作为 dogfood 底物 |
| 产品化 demo 上线（内部可访问）| **保留但降级**为 best-effort：现有 README Quick demo 段达到最低限；是否做独立 demo 视框架可移植性展示需要而定，不设硬 deadline |
| "第 2 个跨域案例验证可移植性"（原 2027-04 锚点）| case-2 中药**已提前进入此槽位**并达成核心目标（traceguard 第 2 domain config + E1–E3 PoC）|

---

## 3. Rationale

1. **诚实优先**：方法论项目的护城河是可信度；§4/§6 长期自相矛盾直接侵蚀它。
2. **框架价值优先于案例完成度**（D-route §6.2）：case-2 异构域（工业制造批记录）比再做几篇同质史记本纪更能扩展框架抽象边界。
3. **既成事实**：史记延伸级 ingest 已 6 周零启动；与其让计划僵尸般挂着，不如登记真相。
4. **不浪费已有资产**：史记并非废弃——它是 16 个 sprint 的 dogfood 底物，这个角色继续有效。

---

## 4. Consequences

### 正面
- §4 / §6 / roadmap §2 之间的矛盾消除；新协作者读到的计划 = 实际
- 2027-04"第 2 跨域案例"锚点状态更新为 ahead（case-2 已达成核心目标）

### 负面
- 对外叙事上"史记知识库"的"持续扩展"卖点收窄为"3–4 本纪 + 完整身份消歧/审计案例库"——但这本就符合宪法"深度 ≥ 广度"，且 §4 Sunset 已预告

### 风险
- 若未来用户改主意想恢复史记延伸 → 缓解：本 ADR 只是"当前不追求"，恢复需新 ADR + 重排，不被永久封死
- demo 降级可能让"框架真的 work 的活体证明"变弱 → 缓解：traceguard PoC + 第 2 domain config 已是更强的"可移植性活体证明"，部分替代了"史记 demo"的展示职能

---

## 5. Out of Scope
- 史记既有数据的任何改动（本 ADR 不动 729 persons / schema）
- case-2 的深度边界（见 `docs/retros/case-2-go-s-to-ac-retro-2026-06-07.md` §6 止损线提案）
- 框架命名（见 ADR-037）

---

## 6. 后续动作（accepted 后执行）
1. 修订 [D-route §6](../strategy/D-route-positioning.md) 2026-08 行：史记延伸级 → 撤销 + 注明 ADR-038；demo → best-effort；2027-04 行注 case-2 ahead
2. 修订 [sprint-roadmap §2](../strategy/sprint-roadmap-D-route.md) Sprint N：删/改"吕后/孝文延伸级 ingest"，注明被 case-2 顶替
3. STATUS §1.1 L3 行 + §4 Sunset 表注明史记"冻结 dogfood 底物"定位（部分已在本次 §1.2 真相表覆盖）
4. [ADR-000-index](ADR-000-index.md) 加索引行

---

**本 ADR 终结线**：史记延伸级里程碑的战略取舍已书面化。下次有人质疑"§4 说 Sunset、§6 却说做 5–10 篇"时，先读本 ADR。
