# ARCHIVED — 华典智谱 (HuaDian) 归档声明

- **归档日期**：2026-10-11
- **决定人**：用户（李卓军）/ 首席架构师（Claude）提议
- **上位依据**：组合复盘 2026-09-06（huadian 降为「个人兴趣，不占工作时间」）→ 本文件把这个事实写成可执行的状态
- **仓库状态**：public 保留、只读维护。不再有 sprint、不再有判据周检、不再有月度决策日记。issue / PR 仍会看，但不承诺响应时限。

---

## 1. 为什么归档，而不是「维持」

2026-08-16 的 finding（`docs/decisions/ADR-041` §A1 落档后第一个完整周期）已经写明：**「维持」没有可执行定义时会静默滑成「归档」**。9/6 之后，周检任务停用、真相表停止采集、决策日记 2026-09 缺席，本仓事实上已经归档 5 周。本文件做的只是把事实登记成状态，避免 `STATUS.md` 继续描述一个不存在的进行时。

## 2. 到归档为止，这个仓库证明了什么、没证明什么

| 命题 | 结果 |
|---|---|
| P1：Agentic KE 框架（kb_forge）能被别人拿去用 | **未证明**。kb_forge 93 测试全绿、clone→pytest < 5 分钟可复现，但 6 个月 0 外部使用者、2 star。ADR-041 §A3 的触发条件（出现第 1 个真实外部使用者）从未触发。 |
| P1'：多角色 agent 团队 + 止损线 + 真相表这套治理方法本身 | **部分证明**。shiji-kb 作者 baojie 2026-06-22 实质背书思路；storyextractor 独立复用 schema；方法论文章 00–07 与决策日记 4 篇是可引用的制品。但它们没有带来第二个使用者。 |
| P2：制药批生产记录的数据完整性检测（F-001~F-004 / 三篇 / SSRN 7099138） | **机制层得到跨域确认，外部效度未证**。会计学者 C-2 把现象归入 real earnings management 并授权引用；n=2 的边界问题无人作答；公开评议窗口 0 意见；SSRN 36 天 0 下载。 |
| 「案例证明框架」这个 D-route 核心命题 | **方向反了**：案例（case-2）活了，框架没人要。 |

## 3. 资产索引（归档后仍可引用的东西）

### 3.1 P2 — 制药数据完整性（本仓最有价值的部分）
- `docs/methodology/08-dual-reverse-calculation-pattern.md` — v1.0（2026-10-11）机制：双重反算
- `docs/methodology/09-layered-compliance-narrative-pattern.md` — v1.0 结构：三层制品
- `docs/methodology/10-subchannel-stratified-detection-pattern.md` — v1.0 分辨率：子通道分层
- `docs/articles/preprints/08-dual-reverse-calculation-pattern-EN.md` — 英文工作稿；SSRN abstract 7099138（已投版本 2026-07-14；仓内副本 2026-08-19 起领先于它）
- `docs/cases/tcm-extraction/` — 脱敏数据（schema v0.4 / 28 物料 / 12 批 / 假名映射不公开）
- `docs/strategy/case-2-tcm-manufacturing-evaluation.md` §10.36–§10.37、§12.1–§12.2 — 外审线程纪要、REM 框架接入、付费方分析、中国 GMP 数据可靠性条文链（§12.1.1）
- `docs/reports/case-2-public-comment-window-2026-08.md` — 评议窗口全记录（N=0）
- 引用口径：**公开研究、未经同行评议、n=2**。三者缺一不可写。

### 3.2 P1 — 框架与方法论
- `kb_forge/` — v0.3.0 五模块，`pytest` 93 passed（2026-08-16 干净容器实测）
- `docs/methodology/00`–`07` — 框架方法论 v0.2
- `docs/methodology/decision-journals/2026-05`–`2026-08` — 决策日记（08 停在 v0.1 未定版，照实保留）
- `docs/decisions/ADR-001`–`ADR-044` — 完整决策链；ADR-044 §A4「新 ADR 须扫描下位判据」是可移植到任何单人+AI 项目的规则
- `docs/STATUS.md` §1.2 真相表 — 最后采集 2026-08-22，**已 stale**，只作历史读

### 3.3 不在本仓、但由本仓派生的线
- traceguard（`lizhuojunx86/traceguard`）— E1-E3 PoC 的 tcm config 来自 case-2
- 商业侧登记（ADR-041 §A2 边界，本仓不执行）：MAH ↔ CDMO 受托生产数据可靠性审核证据包（§12.1.1 ③），归 SinoReg / Drug101China 侧判断

## 4. 归档后仍然成立的触发（任一出现，重新评估，不自动复活）

| 触发 | 对应动作 |
|---|---|
| C-3（warm intro 的第二作者）或任何外审对象实质回复 | 评估是否把 P2 资产拆到以它自己命名的独立仓（路线 B） |
| SinoReg 客户问到受托 CDMO 数据可靠性审核 | 同上，并把 §12.1.1 条文链交商业侧 |
| 有人 clone kb_forge 并提 issue / PR | 按 ADR-041 §A3 解锁 v0.1 工程议程 |
| 第三方引用 SSRN 7099138 或三篇任一 | 更新 SSRN 修订版（仓内 08-EN 领先于已投 PDF） |

## 5. 归档时未做、明知未做的事
- SSRN 7099138 修订版未上传（需用户本机操作）
- 决策日记 2026-08 未经用户 ACK 定版；2026-09 无
- C-1 / B-1 / C-3 三位外审对象回复状态未核实（原线程在未接入会话的邮箱）
- Cowork 项目指令的云端副本需用户手动替换（仓内副本 `docs/cowork-project-instructions.md` 已改）

## 6. 对读者的一句话
如果你是因为批生产记录数据完整性来的，直接读 §3.1 的三篇和 §12.1.1；如果你是因为 agent 团队治理来的，读 ADR-044 和 `docs/00_项目宪法.md`。史记部分是冻结的 dogfood 底物，不再推进。
