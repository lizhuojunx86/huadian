# 华典智谱 · 项目状态板

> **本文件是项目的"现在时刻"快照，每次会话开始 / 结束都应阅读或更新。**

- **最近更新**：2026-07-16（**独立综合审计 + 红色任务批次**：① 8 维度多 agent 独立审计 + 对抗式核验 → [audits/audit-2026-07-16](audits/audit-2026-07-16.md)（FAIL 7 / WARN ~22 / INSIGHT ~15 / 首次评估编排移出架构师之手）；② **P0 二次脱敏**：审计发现公开仓残留 9 个真实/半脱敏姓名（含 pilot-status-v0.2 落盘真名→假名映射表，违反"映射不落盘"承诺）→ 用户确认映射后 **43 处替换为角色代称**（新增代称 指令人 X / 操作工 Y / 复核员 K / 检验员R6/R7 / QA C2；映射仅存会话）+ 人员字段全枚举复扫 **0 残留**；③ **用户拍板二次 filter-repo 历史重写**（残留名自 2026-05-15 在公开历史 / playbook 已交付本地执行 / 完成前后按 6 月 incident 流程）；④ 7/11 积压批次 + 本批全部 commit & push；⑤ 文档一致性修复（§1.1 L1 行 framework→kb_forge / §2.3 冻结在 4/30 的阻塞项 / §1.2 汇总句 ✅6→✅7 / kb_forge README 改名病句+Python 版本声明 / CLAUDE.md 2 坏链+C-25+ADR-038 路线图同步）；⑥ [ADR-040](decisions/ADR-040-retroactive-privacy-desensitization-program.md) retroactive 起草（6 月脱敏工程追认 + 二次收口 + 防回流机制）+ pre-commit 隐私 guard（国药准字模式 + 本地 denylist）；⑦ 外审信 C/B 收件人候选 6 名已研究交付（含公开邮箱 / 用户只剩发送）⭐）。前序编年（2026-07-11 及更早的更新链）已迁 [archive/status-history-2026H1](archive/status-history-2026H1.md) §0，事件明细见 [CHANGELOG](CHANGELOG.md)。
- **SSRN 审核通过（2026-07-14）**：abstract_id 7099138 论文页已公开（标题+摘要+PDF 下载可用 / https://ssrn.com/abstract=7099138 / 提交后第 3 天通过）→ **外审三封信解锁待发**（`reports/outreach-kit-2026-07.md` / 每封仅剩【对方姓氏】【对方论文】2 占位）；每日检查任务 `ssrn-7099138-review-watch` 已停用
- **更新人**：首席架构师（Claude）
- **战略方向**：**D-route — Agentic Knowledge Engineering 框架 + 史记参考实现**（详见 [ADR-028](decisions/ADR-028-strategic-pivot-to-methodology.md) + [strategy/D-route-positioning.md](strategy/D-route-positioning.md)）
- **当前阶段**（2026-07-17 按 [ADR-041](decisions/ADR-041-portfolio-alignment-and-dual-proposition-governance.md) 落档）：**huadian = 声誉公共品 + 方法论兵工厂**（个人项目组合主线在 SinoReg 侧，见 ADR-041 §1）。双命题：P1 KE 框架（kb_forge 93 passed 底线维持 / v0.1 release 等外部使用者触发）+ P2 制药数据完整性（case-2 学术线：08/09/10 三篇 v0.3 齐平 + SSRN 7099138 已公开 / 待 2026-09 外审 → 2026-10 v1.0；商业动作一律在 Drug101China 侧，离巢判据见 ADR-041 A2）。当期焦点见 §2.0；本行取代原"case-2 活跃主线"长段（历史版本见 archive/status-history-2026H1.md §0 前序链）。

---

## 1. 战略快照（D-route，2026-04-29 落地）

| 维度 | 当前状态 |
|------|---------|
| 项目身份 | Agentic KE 工程框架 + 华典智谱史记参考实现（**不是** C 端古籍 App）|
| 仓库形态 | GitHub public（https://github.com/lizhuojunx86/huadian）|
| 许可证 | 代码 Apache 2.0 / 数据·文档·方法论 CC BY 4.0（详见 [ADR-029](decisions/ADR-029-licensing-policy.md)）|
| 4-Layer 路线 | L1 框架抽象（6-12mo）/ L2 方法论文档（12-18mo）/ L3 案例库（持续）/ L4 社区机会主义 |

### 1.1 D-route Layer 进度

| Layer | 状态 | 当前焦点 |
|-------|------|---------|
| L1 框架代码抽象 | 🟡 **维护态·等触发**（冻结期已于 2026-06-20 结束：import root `framework/`→`kb_forge/` 改名执行 / [ADR-039](decisions/ADR-039-l1-unfreeze-import-rename-and-criterion-redefinition.md)，与 §1.2「代码推进 ✅」一致；v0.1 release 锚等真实外部使用者触发 — 见 [ADR-038](decisions/ADR-038-shiji-extension-milestone-superseded-by-case-2.md) + [audits/audit-2026-07-16](audits/audit-2026-07-16.md) 建议 #8）；5 模块 v0.3.0 不变 + sprint-templates v0.3.2 + role-templates v0.3.1（Sprint L→AA 16 sprint 完成）| sprint-templates **v0.3.2** + role-templates v0.3.1 + identity_resolver v0.3.0 + invariant_scaffold v0.3.0 + audit_triage v0.3.0（**2026-06-07 补 33 单测 → 全套 93 passed**）；累计 v0.2 18/20 + v0.3 6/6 + v0.4 4/4 = 28/30 patch（**内部维护账本 / ≠ L1 对外判据**，见 §1.2）+ **traceguard E1-E3 真实 PoC (GO-Z-η) validated → E4 候选** + **2026-06-07 补 framework 顶层 pyproject+README+requirements（"1h clone 跑通"路径建立）+ 命名 [ADR-037](decisions/ADR-037-framework-package-naming.md) accepted = `kb-forge`** |
| L2 方法论文档 | 🟢 **8 doc 完整 + methodology v0.2 cycle 完成 8/8 = 100% ⭐⭐⭐ + 维护态首批 v0.2.1 patch (2 doc)**：/00 v0.2 + /01 v0.2 + **/02 v0.2.1** (Sprint AA §14.4+§15.4 cross-ref polish) + /03 v0.2 + **/04 v0.2.1** (Sprint AA fold §8.6 实证+反模式) + /05 v0.2 + /06 v0.2 + /07 v0.2 + **/08 v0.3 完整初稿达成（精炼版 4015 字 / GO-K-ε §7.3 + GO-O-η §4.5.1·§5.4·§6.3.1 + GO-P-η §3.3.1·§7.2 跨域文献 + GO-Q-η §9.1 traceguard + GO-R-η 精简+§参考文献 / 全量快照 archive 存档 / 待 v0.4 审稿（GO-AA-η author-side 前置批已落：§9.1 PoC-validated+E4 / §10 卷页最终化 / §8 n=2·识别≠证实 canonical）/ case-2 应用层）⭐⭐⭐** + **/09 v0.3 完整初稿达成（精炼版 4054 字 / GO-S-η §8 五理论 Latour·Knorr Cetina+Van Maanen·Goodhart·Wenger·Scott + GO-T-η §9.2 五域文献 Studdert/B&D/Simmons/Campbell/Vaughan+Perrow + 精简 / 全量快照存档 / 待 v0.4 审稿）⭐⭐⭐** + **decision-journals/ Q5 ACK 节律首篇 2026-05.md v1.0 定版 ⭐⭐⭐**（GO-L-ε / 用户审稿通过 / 协作闭环首次实证）+ **2026-06.md v1.0 定版（GO-U-η / 6-2 用户审稿通过 / Q5 节律第 2 篇）⭐⭐⭐** + **/10 子通道分层检测 v0.3 精炼（GO-X-η / F-003 第3篇 / 三篇三角全 v0.3 齐平）⭐** | Layer 2 维护态运行中；4 类工作流 3/4 已实证；**case-2 应用层文章组 08+09+10 三篇 v0.3 齐平（三文章三角 09 结构/08 机制/10 分辨率 / 各 ~4000-4500 字 + archive 快照）/ 三篇 v0.4 author-side 四项全完成（GO-AA 08 + GO-AB 09·10 + GO-AC 渠道 / citation + n=2 + 识别≠证实 + 目标渠道 / 余外部审稿 2026-09）/ D-route §6 2026-10 v1.0 发布锚点领先 ~6-8 周** ⭐ + **2026-06-07 新增 /11 叙事语料抽取存储 schema 骨架 + storyextractor 采纳案例研究（ADR-038 #5 / 第一份真实下游采纳实证 / 对抗式核验：同域已证核心稳·跨域未证·轻量重写反证框架偏重 → 互证 §1.2 领域无关 56-62%）** |
| L3 案例库 | 🟢 主案例 + demo + 5 sprint dogfood + Sprint Q dogfood ✅ user local + Sprint T Docker dogfood ✅ sandbox PASSED + **case-2 中药提取 GO-A → GO-Z-η ⭐⭐⭐**（双产品 / **+ traceguard E1-E3 真实 PoC (GO-Z-η) → E4 候选** / 28 物料 / 12 批 / 4 fundamental findings F-001~F-004 / 22 anomalies / **3 ADR (033/034/035)** / 应用层方法论 08+09+10 三篇 v0.3 齐平（三文章三角）/ **schema v0.4 完整 lock (8 项 / 押后 3 项 v0.5) + batch-record.json _meta 0.3→0.4**） | 沉淀期 (5/15→5/31) 结束 / **GO-N-η schema v0.4 完整 lock + batch-record _meta 0.3→0.4 ✅** / **case-2 应用层文章组（08 + 09）按 D-route §6 2026-10 双文章 v1.0 发布锚点推进 / 当前领先 ~6-8 周**（v0.2 全本提前从 6 月节点达成 / GO-K-ε 08 v0.3 启动 / GO-L-ε 月度日记 v1.0 / GO-M-ζ schema v0.4 outline / GO-N-η v0.4 完整 lock）|
| L4 社区 / 商业 | ⚪ **有意休眠**（机会主义层 / 非失败）：v0.3.0 GitHub release tag 已 push + ADR-031 v1.0 候选议程评估 + ADR-032 retroactive ADR；但外部触发条件（跨域 reference impl / 第三方 review）**零进展、0 次近邻交流、0 outreach 动作** — L4 标 🟢 名实不符故改 ⚪ | v1.0 触发条件 3/7 ✅ + 2/7 ⏳ + 2/7 ❌（#4#5 外部触发未动）/ 用户主动可启动 B 跨域 outreach |

---

## 1.2 对外可验证判据真相表（2026-06-07 新增 / per [d-route-progress-review-2026-06-07](reports/d-route-progress-review-2026-06-07.md)）

> **设立理由**：§1.1 用大量 ⭐ + "领先 6-8 周" + "240% over target" 渲染容易产出的维度（文档 / sprint 计数），系统性盖住了"对外可验证里程碑"的真实状态。本表与 ⭐ 叙事**物理分离**，只用二元 done / not-done 记录**外界能验证**的硬判据，每次 sync 强制更新。**这不是否定 §1.1 的产能，是给它配一个去乐观偏差的对照。**

| 对外可验证判据 | 目标 | 客观现状（2026-06-07）| 达成 |
|---|---|---|---|
| 本地工作已 push 到 public GitHub | origin 持续更新；**机制（2026-07-16 起 / audit #10）：未提交积压 > 7 天本行自动降 🟡** | **✅ 2026-07-16 已 push**（红色+黄色批次全部落库；二次历史重写后 origin 与本地同步）| ✅ |
| 方法论文章正式发表数 | 12mo ≥ 4（D-route §5 L2）| **5**（知乎 2026-06-13 发 3 篇 + 掘金镜像；第 4 篇「LLM 实体为何不应自动合并」2026-06-20；**第 5 篇 2026-07 dev.to 英文首发「多 agent 模型分层政策审计 / 34 天 22.6% 偏离」**——首个英文渠道 + traceguard 相关；case-2 学术三篇仍走 SSRN/期刊线未计入）| ✅ 5/4 |
| 文章被外部真实引用 / 讨论 | 12mo ≥ 1（≥3 更佳）| **🟡 首次实质讨论（2026-07-16）**：shiji-kb 作者 baojie 就第 5 篇（YAML 政策审计）核心观点实质回应"很对的，我现在做的 harness 层也是把政策写成 yaml 的"= **独立技术收敛**（用户 Discussion 内分享 / 非独立引用，故 🟡 不计 ✅）。旁证：知乎回答式分发 5 收藏为最强单点；huadian 首个 star；HelloGitHub #3347 待出刊 / 阮一峰 #10313 未选 | 🟡 |
| 外部审稿人已对接 | 三篇 2026-09 外审需真人；**判据锚点（2026-07-16 重定 / audit #10）：以「收到实质回复」改判 ✅，「已发信」只到 🟡——发信可控、回信由身份资本决定** | **0 人在接触**（信 C/B/A 成品 + 收件人候选 6 名已备〔2026-07-16〕，只剩用户发送）| ❌ |
| 近邻项目（shiji-kb 等）实质交流 | 2026-10 ≥ 1 次 | **✅ 已达成（2026-06-22）**：shiji-kb 作者 baojie（2112 star / 30+yr）在 [Discussion #114](https://github.com/baojie/shiji-kb/discussions/114) 实质回复——"多角色 agent team 思路是对的、往下能走得通"，且自述兴趣已从史记转向 harness 框架（与 kb-forge 同赛道）。首个外部同行实质背书，领先目标锚（2026-10）约 4 个月 | ✅ |
| L1 外部工程师 clone+跑通 starter | ≤ 1h（D-route §10）| **路径已建立**（2026-06-07 补 framework README+pyproject+requirements / `pytest → 93 passed` 可测量）；外部实测尚未发生 | 🟡 |
| L1 领域隔离（判据 2026-06-20 重定义 / [ADR-039](decisions/ADR-039-l1-unfreeze-import-rename-and-criterion-redefinition.md)）| (a) core+tests 0 领域字样 + (b) ≥2 domain 各自隔离（替代失真的"≥70% LOC"，理由见 [l1-domain-agnostic-finding](reports/l1-domain-agnostic-finding-2026-06-20.md)）| (a) **✅ 已达成**（core 0 领域字样 / 实测 64.4% LOC 仅作参考，已判定为单-example 假象）；(b) 第 2 真实 domain 待引入（traceguard tcm PoC 为半证）→ **1/2** | 🟡 |
| L1 框架命名确定 | yes（D-route §5）| **✅ `kb-forge`**（ADR-037 accepted 2026-06-07 / web 核实无占用 / import root 改名延 v0.1 前）| ✅ |
| 每模块有单元测试 | 各模块 | **✅**（2026-06-07 补 audit_triage 33 单测 → 全套 93 passed）| ✅ |
| 月度决策日记累计字数 | 6mo ≥ 6000 字 | **✅ ~1.2 万字 / 2 月**（North Star 唯一硬达标项）| ✅ |
| 框架代码近期有推进 | 不连续 2 sprint 停滞 | **✅ 2026-06-20 import-root 改名已执行**（[ADR-039](decisions/ADR-039-l1-unfreeze-import-rename-and-criterion-redefinition.md) / `framework/`→`kb_forge/` 目录重命名 + 73 imports·51 文件改写 + pyproject + 13 活文档 / **pytest 93 passed / 0 回归**）——core 自 2026-05-03 的冻结期结束，L1 真解冻 | ✅ |

**一句话**：内部产能（文档 / 治理 / sprint 计数）很高；**对外可验证判据 11 项里 2026-07-16 复核 = ✅ 7、🟡 2、❌ 2**（push / 命名 / 单测 / 日记 / **发表 4/4** / **代码推进（import-root 改名已执行·93 passed）** / **近邻交流（2026-06-22 baojie 实质回复）** ✅；clone 路径 / **领域隔离判据重定义后 1/2** 🟡；引用讨论 / 外审对接 ❌）。较 2026-06-07（✅4/🟡2/❌5）净改善 5 项。**仅剩的 2 个 ❌（引用讨论 / 外审对接）全部需用户真人动作——引用靠时间发酵，外审靠联系真人（SOP 已备）。**（2026-07-16 审计注：外审判据的改判锚点应为「收到回复」而非「发出信件」——发信可控、回信由身份资本决定；且"未提交积压 > 7 天"应触发 push 行自动降 🟡，详见 [audits/audit-2026-07-16](audits/audit-2026-07-16.md)。） 整改见 [d-route-progress-review-2026-06-07](reports/d-route-progress-review-2026-06-07.md) §6 + 外审包 [case-2-external-review-package](methodology/case-2-external-review-package-v0.1.md) + 对接 SOP [external-review-outreach-process](reports/external-review-outreach-process-2026-06-20.md)。

---

## 2. 当前焦点（这周）

> 历史快照（原 §2.1~§2.2.15、§5~§7 及 Phase 0 遗留段）已于 2026-07-17 迁入 [archive/status-history-2026H1](archive/status-history-2026H1.md)（audit #14 / 内容无删减）。

### 2.0 本周真实焦点（2026-07-16 更新）

1. ✅ **P0 隐私收口完成（2026-07-16）**：二次脱敏落地 + **二次 filter-repo 历史重写已执行**（全 refs 重写 / 远端+本地全历史 0 残留 / 仓已恢复 public——详见 ADR-040 执行注）；残余仅 GitHub 侧 PR 缓存 refs（接受，可选 support ticket）
2. 🔴 **外审信 C/B 发送**（收件人候选 6 名已研究交付，材料只剩粘贴姓名+论文名；SSRN 7/14 过审的新鲜度在衰减）
3. 🟡 q58413890 知乎回答发布（6/21 成稿，发布成本≈0）
4. 🟡 **7/25 三路信号统一回收**：蒲公英回帖 + SSRN 下载数 + 外审回信 → 回填真相表 + 决策 09/10 预印化
5. 🟡 审计黄色批次待议：双命题 ADR / 7/6 仓外重排落档 / v0.1 release 锚冻结 ADR / 身份反推残余风险 ADR（见 [audits/audit-2026-07-16](audits/audit-2026-07-16.md) 建议 #5-#11）

### 2.3 阻塞 / 风险 / 等待项（2026-07-16 刷新）

- **待用户真人动作**：① 外审信 C/B 发送（收件人候选 6 名已交付）② q58413890 回答发布 ③ ADR-040/041/042 审阅（已按用户"实施黄色批次"指令 accepted，可复核）〔历史重写已于 2026-07-16 由会话执行完毕，不再待办〕
- **定时点**：7/25 三路信号统一回收（蒲公英 / SSRN / 外审回信）
- 2026-04-30 Sprint AA 时点的等待项（下列历史条目）已全部完成或过期，保留供追溯：
- ~~无阻塞。Sprint AA 关档。**Layer 2 维护态首 sprint 模板验证**。~~
- ~~待用户在 local Terminal 执行：`git commit + push`（2 commits 详见 `docs/sprint-logs/sprint-aa/stage-4-closeout-2026-04-30.md` §9）~~（已于 6 月完成）
- **连续 12 个 zero-trigger sprint** P→Q→R→S→T→U→V→W→X→Y→Z→AA ⭐⭐⭐ → 强化 ADR-031 §3 #2（≥ 5 zero-trigger / 当前 12 / **240% over target**）
- methodology v0.2 cycle 完成 8/8 不变（维护态 v0.2.1 patch 不影响 cycle 完成判据）
- **v1.0 触发条件状态**（不变 / 维护态不影响 v1.0）：3/7 ✅ + 2/7 ⏳ + 2/7 ❌
- **新发现**：brief-template v0.1.4 Docs: cross-ref polish 子类首独立验证 -33% 大幅低估 / 待 ≥ 2-3 次 dogfood 后再决定 v0.1.6 调整
- **Sprint AB 默认推荐 — D 等候触发** ⭐（v0.5 maintenance 触发条件未达成 / 候选 ≤ 2 / 阈值 ≥ 3 / per Sprint AA retro §7.4）
- **Sprint AB 用户主动启动选项**：
  - A. v0.5 maintenance sprint（仅 1 candidate + 2 待评估 / 累积 ≤ 2 / **不推荐**）
  - B. 跨域 outreach 主动启动（v1.0 #4 + #5 触发探索 / 战略层工作）
- 维护态工作流 4 类已实证 3/4：v0.2.x patch ✅ / v0.5 maintenance ✅ / v1.0 评估更新 ✅ / 跨域 outreach ⏳ 等触发
- v1.0 路径预测（per ADR-031 §5 / 不变）：2026-10 (乐观) ~ 2027-04 (保守) / 进入"等触发"维护态

---

## 3. 当前数据 / 工程基线（Sprint K 完成时刻）

### 3.1 DB 数据状态

| 维度 | 数值 | 备注 |
|------|------|------|
| Active persons | **729** | Sprint J 收口数 |
| merge_log entries | **111** | Sprint A-J 累计 9+9+...+19 merges |
| pending_merge_reviews | **18** rows | Sprint K Stage 2 PE backfill 写入；2 行已被 Hist Stage 5 决策（reject）|
| triage_decisions | **177** rows | 175 backfill + 2 Hist E2E 真决策（1 reject + 1 approve）|
| seed_mappings (pending_review) | **45** | Sprint G/H/I/J 累积，等 Hist 处理 |
| entity_split_log | **2 rows** | 楚怀王 entity-split (Sprint H) |
| V1-V11 invariants | **22 / 22 全绿** | 0 回归 |

---

## 4. Sunset / 降级 方向（D-route 不再做的事）

依据 D-route §7 Negative Space：

| 方向 | 状态 |
|------|------|
| C 端古籍阅读 App（核心产品形态）| ⚪ Sunset |
| 移动端（iOS / Android）| ⚪ Sunset |
| 与字节识典古籍同等数据完整度 | ⚪ Sunset |
| 古人模拟器 / 断案游戏 / 跨时空群聊 | ⚪ Sunset（永不主动启动）|
| 自建 frontend 组件库 / UI design system | ⚪ Sunset |
| 大规模数据 ingest（>20 篇章节）| ⚪ Sunset |
| DAU 增长 / 用户留存指标 | ⚪ Sunset |
| 抢首发"首个 X 框架"叙事 | ⚪ Sunset |
| 完成史记 130 篇 | ⚪ Sunset（5-10 篇典型即停）|

---


---

## 历史归档

> 2026-07-17 瘦身（audit-2026-07-16 建议 #14 / 用户确认映射）：原 §2.1~§2.2.15（Stage A-D + Sprint L→AA 十六表）、§5 Sprint L 议程、§6 历史档案、§7 归档、以及 L364 起的全部 Phase 0 遗留段（已完成 / 进行中 / 下一步候选 / 阻塞项 / 最近决策 / 健康度指标 / 更新日志 / 技术债索引）**整体迁入** [archive/status-history-2026H1](archive/status-history-2026H1.md)，内容无删减。本文件回归"现在时刻快照"职能（宪法 C-18）。
