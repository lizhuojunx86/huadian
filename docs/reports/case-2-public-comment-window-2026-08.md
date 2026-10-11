# case-2 三篇公开评议窗口 — 登记 + 帖文 + 处置日志

> **依据**: [ADR-044](../decisions/ADR-044-v1.0-criterion-redefinition-and-stop-loss-scan-rule.md) §A1 —— v1.0 解锁条件 = author-side 完备 ✅ + **本窗口开满 6 周** + 收到意见逐条处置。
> **本文件是该判据的唯一执行记录。** 窗口状态、收到的意见、以及每条意见的处置都记在这里；v1.0 版本页的「收到意见 N 条」直接引本文件 §3。

---

## 1. 窗口登记

| 项 | 值 |
|---|---|
| 载体（记录） | **[GitHub Discussion #19](https://github.com/lizhuojunx86/huadian/discussions/19)** ✅ 已开 |
| 广播（触达） | dev.to（现有读者最多）+ 知乎（回答式分发路径已验证有互动）|
| 开窗日 | **2026-08-16** ✅（实际发布日 / 经 gh CLI 发布）|
| 关窗日 | **2026-09-30**（6 周 + 缓冲 / 实际 6.5 周；留足 10 月定稿时间）|
| 解锁 v1.0 | 关窗 + §3 处置日志逐条填完 |
| 覆盖文章 | `08-dual-reverse-calculation-pattern.md` · `09-layered-compliance-narrative-pattern.md` · `10-subchannel-stratified-detection-pattern.md` |

**为什么载体与广播分开**：载体要的是可审计、可永久引用（v1.0 里那句「处置记录见 …」得有个指得住的地方）；广播要的是触达。蒲公英已经证明单帖冷启动无效，SSRN 36 天 0 下载证明预印页不是渠道。把两件事塞进一个地方，两头都不讨好。

---

## 2. 帖文（**已于 2026-08-16 发布** → [Discussion #19](https://github.com/lizhuojunx86/huadian/discussions/19) / Category: General）

> 本节是帖文的仓内副本，**已发布版本以 Discussion #19 为准**；若线上编辑过，回填到此处保持一致。

**Title**: `Open comment window: three papers on reverse-calculated pharmaceutical batch records (closes 2026-09-30)`

---

I'm opening a six-week comment window on three working papers about data integrity in pharmaceutical manufacturing records.

The papers go to v1.0 in October whether or not anyone comments, and they will say on their face that they were not peer reviewed. This window is what stands in place of peer review, so I would rather it got used than sat here as a formality.

### What the three papers claim

**1. Dual reverse calculation** — English working paper, [SSRN 7099138](https://ssrn.com/abstract=7099138)

Across six batches, yields sit at σ ≈ 0.02 percentage points and hug the specification lower bound. Charging masses are recorded to 0.01 kg, which nobody achieves on a factory floor. The claim: those numbers were computed backwards from the specification, not measured forwards. It is the manufacturing analogue of earnings benchmark-beating, and it follows the Graham/Harvey/Rajgopal pattern where people prefer real actions to book adjustments.

**2. Layered compliance narrative** — Chinese, `docs/methodology/09-layered-compliance-narrative-pattern.md`

A GMP batch record is three things stacked. A compliance narrative on the surface, largely back-calculated. An unwritten middle layer of what the operators actually decided. A deep layer of embodied craft that nobody writes down because nobody thinks of it as information. The layers are separated by a structural gap, and any project that wants to improve manufacturing with AI has to state which layer it is touching.

**3. Sub-channel stratified detection** — Chinese, `docs/methodology/10-subchannel-stratified-detection-pattern.md`

How hard a number is to fake backwards scales as 1 / (spec value × tolerance). In one incoming-inspection lot, the range ratio across three sub-channels came out around 55×, strictly decreasing with magnitude. The corollary is the uncomfortable part: the numbers that are easiest to manipulate are the ones hardest to catch, and those are not two facts but one.

### The three questions I actually want answered

1. **On the boundary.** The evidence is one enterprise, two products. Does that sink the claim, or is an interview-confirmed mechanism enough to put the detection framework forward as a hypothesis worth testing elsewhere?
2. **On the three layers.** Is the three-layer split operationalizable as a field-research category, or does it collapse in practice into the familiar formal/informal dichotomy?
3. **On transfer.** Does "difficulty of back-calculation scales as 1 / (target × tolerance)" hold in other compliance-record domains — clinical trial records, emissions reporting, financial close, safety incident logs? If it fails somewhere, that failure is more useful to me than agreement.

A single paragraph on any one of them is a real contribution. You do not need to read the papers to answer question 3.

### What happens to a comment

Every comment gets a line in a public disposition log: taken up and where, or not taken up and why. Attribution by GitHub handle unless you ask otherwise. If the window closes with zero comments, v1.0 will say zero, because a window that reports only its successes is not a window.

### Data and licence

De-identified: product names, batch numbers, lots, equipment models, companies and people are all pseudonyms. The σ, range ratios and multipliers keep their original values, so the results recompute. CC BY 4.0.

### 中文

这是 case-2 三篇方法论文章的公开评议窗口，开到 2026-09-30，之后按 v1.0 定稿并在文中显式标注「未经外部同行评议」。

三篇分别讲：批生产记录的数字是从标准反算出来的（σ ≈ 0.02 个百分点、贴着下限、称量精确到 0.01 kg）；批记录是三层制品（合规叙事 / 未写下的实际执行 / 身体化经验），三层之间有结构性代差；以及反算难度与「标准值 × 允许误差」成反比，所以最好操纵的数恰恰最难查——这两件事是同一件事。

想听的三个问题在上面英文部分。**第 3 个问题不需要读论文就能答**：这条反比关系在别的合规记录领域（临床试验记录、排放申报、财务结账、安全事件台账）成不成立？如果哪里不成立，那比赞同有用得多。

---

## 3. 意见处置日志

> ADR-044 §A1 条件 3：收到的意见须**逐条处置**（采纳 / 说明不采纳的理由），均留痕。

| # | 日期 | 来源 | 意见摘要 | 处置 | 落点 |
|---|---|---|---|---|---|
| — | 2026-09-30 | （关窗登记） | **窗口 2026-08-16 → 2026-09-30 关闭，收到意见 0 条**（2026-10-11 经 GitHub API 核实：comments.totalCount = 0，participants = 1 即发帖人） | 无需处置 | 三篇 v1.0 版本头 + ARCHIVED.md §2 |

**触达动作留痕**：开窗当日已发 dev.to 短文一篇（见 §4）导流；知乎待办。**这是本窗口与 SSRN 预印的关键差别**——预印挂了 36 天 0 下载，因为没有任何导流动作；本窗口开窗即配广播。

**最终计数：N = 0**（关窗 2026-09-30 / 2026-10-11 核实）。知乎回答式广播**未做**——照实记：本窗口实际只配了一次 dev.to 导流。ADR-044 §A1 三条件于 2026-10-11 全部满足，三篇定 v1.0。关窗时若仍为 0，v1.0 照实写 N=0 —— 见 ADR-044 §2 A1 的负面情形条款：零意见属于「触达为零」这个已知事实，不属于「质量未验证」，不得用作推迟发布的理由。

---

## 4. 广播文案（发帖后使用）

**dev.to —— ✅ 已发（2026-08-16）**：[The easiest numbers to fake are the hardest to catch. That is one property, not two.](https://dev.to/lizhuojunx86/the-easiest-numbers-to-fake-are-the-hardest-to-catch-that-is-one-property-not-two-23k9)

改为**单发短文**而非系列内自评。理由：dev.to 的自评不进任何 feed，新文章进 tag feed（#ai #opensource #programming #datascience）+ 关注者 feed，触达差一个量级。文章正文与本窗口帖文不重复——它只讲第 3 问（反算难度 ∝ 1/(标准值×允许误差)），并用读者已熟悉的 token 计费漏报作类比（松上界的计数悄悄漂移，硬上限的计数第一次错就自曝），末尾导向 Discussion #19。

原备用文案（未采用，留档）：

> Different domain, same question. I've spent a year auditing token-accounting bugs in usage trackers; before that I spent longer looking at pharmaceutical batch records, where the numbers are computed backwards from the spec instead of measured forwards. One finding transfers and I'd like it stress-tested: **how hard a number is to fake backwards scales as 1 / (target × tolerance)** — so the easiest numbers to manipulate are the hardest to catch, and that's one property, not two. Comment window is open until Sept 30: <链接>

**知乎** —— 挑一个「数据造假 / 合规 / GMP / 药品质量」相关问题回答，末尾带窗口链接。**不要单独发文**，回答式分发是已验证有互动的那条路径（q58413890 有收藏与互动，蒲公英主题帖 0 回帖）。

---

## 5. 发布后回填清单

- [x] Discussion 实际链接填入 §1 与本仓 STATUS §2.0 —— https://github.com/lizhuojunx86/huadian/discussions/19
- [x] 实际开窗日回填 §1 —— 2026-08-16
- [x] **dev.to 广播已发** —— https://dev.to/lizhuojunx86/the-easiest-numbers-to-fake-are-the-hardest-to-catch-that-is-one-property-not-two-23k9
- [ ] ~~知乎广播~~ **未做**（窗口已关 / 2026-10-11 登记）
- [x] ~~周检任务~~ 2026-09-06 组合收口时停用；关窗由 2026-10-11 人工核实
