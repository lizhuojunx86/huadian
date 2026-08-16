# case-2 三篇公开评议窗口 — 登记 + 帖文 + 处置日志

> **依据**: [ADR-044](../decisions/ADR-044-v1.0-criterion-redefinition-and-stop-loss-scan-rule.md) §A1 —— v1.0 解锁条件 = author-side 完备 ✅ + **本窗口开满 6 周** + 收到意见逐条处置。
> **本文件是该判据的唯一执行记录。** 窗口状态、收到的意见、以及每条意见的处置都记在这里；v1.0 版本页的「收到意见 N 条」直接引本文件 §3。

---

## 1. 窗口登记

| 项 | 值 |
|---|---|
| 载体（记录） | GitHub Discussion @ `lizhuojunx86/huadian` |
| 广播（触达） | dev.to（现有读者最多）+ 知乎（回答式分发路径已验证有互动）|
| 开窗日 | **2026-08-17**（帖子发布日；发布后回填实际日期）|
| 关窗日 | **2026-09-30**（6 周 + 缓冲；留足 10 月定稿时间）|
| 解锁 v1.0 | 关窗 + §3 处置日志逐条填完 |
| 覆盖文章 | `08-dual-reverse-calculation-pattern.md` · `09-layered-compliance-narrative-pattern.md` · `10-subchannel-stratified-detection-pattern.md` |

**为什么载体与广播分开**：载体要的是可审计、可永久引用（v1.0 里那句「处置记录见 …」得有个指得住的地方）；广播要的是触达。蒲公英已经证明单帖冷启动无效，SSRN 36 天 0 下载证明预印页不是渠道。把两件事塞进一个地方，两头都不讨好。

---

## 2. 待发布帖文（GitHub Discussion / Category: General 或 Ideas）

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
| — | — | — | *（窗口开启中，暂无）* | — | — |

**当前计数：N = 0**（截至开窗日）。关窗时若仍为 0，v1.0 照实写 N=0 —— 见 ADR-044 §2 A1 的负面情形条款：零意见属于「触达为零」这个已知事实，不属于「质量未验证」，不得用作推迟发布的理由。

---

## 4. 广播文案（发帖后使用）

**dev.to** —— 在「Auditing AI usage trackers」系列最新一篇下自评一条，或单发短文：

> Different domain, same question. I've spent a year auditing token-accounting bugs in usage trackers; before that I spent longer looking at pharmaceutical batch records, where the numbers are computed backwards from the spec instead of measured forwards. One finding transfers and I'd like it stress-tested: **how hard a number is to fake backwards scales as 1 / (target × tolerance)** — so the easiest numbers to manipulate are the hardest to catch, and that's one property, not two. Comment window is open until Sept 30: <链接>

**知乎** —— 挑一个「数据造假 / 合规 / GMP / 药品质量」相关问题回答，末尾带窗口链接。**不要单独发文**，回答式分发是已验证有互动的那条路径（q58413890 有收藏与互动，蒲公英主题帖 0 回帖）。

---

## 5. 发布后回填清单

- [ ] Discussion 实际链接填入 §1 与本仓 STATUS §2.0
- [ ] 实际开窗日回填 §1（若非 2026-08-17）
- [ ] dev.to / 知乎 广播已发，链接记入 §4
- [ ] 周检任务（`huadian 判据周检`）会自动盯本窗口是否开启，开启后改盯意见数
