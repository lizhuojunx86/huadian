# 外审 / 学术合作者对接流程 SOP（2026-06-20）

> 目的：把"找到愿意审 GMP+STS 跨域稿的外部专家"这个**代笔无法替代、当前 0 进展、全文 0 风险登记**的人际瓶颈，拆成可执行步骤。
> 背景：真相表（STATUS §1.2）「外部审稿人已对接」长期 ❌；进度评估 [d-route-progress-review-2026-06-07](d-route-progress-review-2026-06-07.md) §5 把它列为"真正失控的 behind"之一。
> 分工铁律：**写稿/改稿 = 架构师（Claude）；注册账号、发邮件、联系真人 = 只有你能做。** 本 SOP 是给"你"的操作手册。
> 作者：首席架构师（Claude）/ 状态：待用户执行

---

## 0. 最重要的一个观念：解耦"预印"和"外审"

现在三篇卡在"等 2026-09 外审"，但**外审和预印是两件可以并行、且预印应该先做的事**：

- **预印（preprint）**：不需要任何人同意，自己挂上去就有一个**可引用、有时间戳、带链接**的 artifact。这是 outreach 的"敲门砖"——你联系任何人时，附一个 SSRN 链接，比附一个 Word 附件可信得多。
- **外审（peer review）**：需要真人，是慢变量，瓶颈在"找到人"。

**所以正确时序是：先挂预印（本周可做）→ 拿预印链接去联系人（下周起）→ 外审/正式投稿（2026-09）。** 不要等外审才动预印。

---

## 1. 三篇的对口对象（谁会愿意看）

三篇是跨域稿，对口三类不同的人。**不要拿一篇去找所有人**，按篇配人：

| 文章 | 主题 | 对口对象类型 | 他们能验证什么 |
|------|------|------------|--------------|
| **08** 双向反算 | 数据完整性检测方法 | A. 制药 QA / 数据完整性实务专家；C. 会计/审计学者（反算=earnings management 近亲）| 方法在真实 GMP 场景成不成立、σ 阈值合不合理 |
| **09** 分层合规叙事 | 合规文本 vs 实际执行的代差 | B. STS / 科学技术学学者；A. GMP 实务 | F-001 三层结构是不是普遍现象、理论锚点用得对不对 |
| **10** 子通道分层检测 | 检测分辨率 / 信号稀释 | C. 会计/审计 + 统计；A. 实验室/分析化学 | Simpson 稀释数学、分层协议工程上可不可行 |

三类对象画像：
- **A 制药 QA / 数据完整性实务**：在药企质量部、CRO、第三方审计、药监核查员转行做咨询的人。最懂 F-001/F-004 是不是真的。
- **B STS 学者**：研究"科学/合规如何在组织里实际运作"的社会学/人类学/科技与社会学者。最懂 09 的理论框架。
- **C 会计 / 信息系统 / 审计学者**：earnings management、fraud detection、Benford 分析方向。最懂 08/10 的统计与"反算"逻辑（这在会计里是成熟领域）。

---

## 2. 去哪里找这些人（渠道）

按"性价比 + 可独立操作"排序：

1. **预印平台的同主题作者**（最高性价比）：在 SSRN / arXiv 搜 "data integrity pharmaceutical" / "earnings management detection" / "Benford forensic" / "compliance decoupling"（STS 术语），看近 2 年发文的作者，邮箱通常在论文首页。他们正在这个题目上活跃，回复率最高。
2. **Google Scholar**：搜你引用的那些理论锚点（Goodhart、Latour、Scott、Wenger、Spence、Nigrini）的**近期引用者**——引用这些经典的人，就是和你同框架的人。
3. **ResearchGate**：可直接站内私信，门槛低于冷邮件。
4. **学术 X / 中文学术圈**：会计/审计、STS 方向有活跃账号；小木虫（emuch.net）制药/分析化学版块有大量实务+学术混合人群。
5. **制药实务社区**：蒲公英（ouryao.com）数据完整性版块、医药质量人的微信群/知识星球——A 类对象密度最高的地方（也和"商业试探"重叠，见 [pharma-data-integrity-forum-probe](../articles/2026-06-pharma-data-integrity-detection-forum.md)）。
6. **中文期刊编辑部**：《中成药》（zcyjournal.com）/《中国医药工业杂志》（cjph.com.cn）——注意**正版投稿口**，zcyzzs.cn / zgyygyzz.cn 是中介仿冒站。这两家要单位公函/盖章，独立作者直投受阻 → 这正是"找学术合作者"要解决的问题之一。

---

## 3. 话术模板（冷接触）

**原则**：短、具体、给链接、提一个明确的小请求（不要一上来求"帮我审全文"）。

### 模板 A — 给实务专家 / 学者（英文 / SSRN 预印已挂后）

> Subject: A detection method for reverse-calculated batch records — would value your read
>
> Dear Dr. ___,
>
> I'm an independent researcher working on data-integrity detection in pharmaceutical manufacturing records. I've just posted a working paper [SSRN link] proposing a method to flag *reverse-calculated* batch records — where values appear to be back-filled to fit spec lower bounds, producing a detectable distributional fingerprint.
>
> Your work on [their specific paper] is closely related to the [σ-edge-band / decoupling / Benford-stratification] angle. I'd be grateful for even a brief reaction to one question: **[does the single-enterprise n=2 boundary undercut the core claim, in your view?]**
>
> No obligation to read the full paper — a one-paragraph reaction would already help me a lot. Happy to share data details (de-identified) if useful.
>
> Best, [name] (Independent Researcher)

### 模板 B — 给潜在学术合作者（中文 / 解决公函+endorsement+文体）

> ___老师您好，
>
> 我是独立研究者，做制药数据完整性方向。有一篇方法稿（检测"反算填表"的批记录，含 σ 分布检验 + 分通道分层），已挂 SSRN 预印 [链接]。
>
> 想请教/探讨合作的可能：稿子如果投《中成药》或国际会计/STS 期刊，独立作者在 ① 单位推荐公函 ② arXiv endorsement ③ 学术文体校准 上有实际困难。如果方向您也感兴趣，是否可能以共同作者形式合作推进？我可以先发全文请您评估是否值得。
>
> 不论是否合作，若您愿意指一两个该补强的点，我都非常感谢。
>
> [署名]

**注**：模板里的方括号是你发前要替换的具体内容（对方某篇论文、某个具体问题）。每封都改一处具体的——群发会被识别为群发。

---

## 4. 时序（建议 4 周节奏）

| 周 | 动作 | 谁 |
|----|------|----|
| 第 1 周 | 08 英文 working paper 收口（补 2 处 [AUTHOR TO SUPPLY]）→ 注册 SSRN（affiliation=Independent Researcher）→ 挂 PharmSciRN | 你（架构师已起草英文稿 [preprints/08-EN](../articles/preprints/08-dual-reverse-calculation-pattern-EN.md)）|
| 第 1 周 | 用 §2 渠道列 **10 个候选人**（每类 3-4 个，记姓名/单位/对口篇/一句"为什么是他"）| 你 |
| 第 2 周 | 发 **第一批 3-5 封**（模板 A，每封改具体处）；ResearchGate 私信 2-3 个 | 你 |
| 第 3 周 | 跟进无回复者一次（一句话 bump）；据回复挑 1-2 个谈合作（模板 B）| 你 |
| 第 4 周 | 收口：把"已接触 N 人 / 回复 M 人 / 愿审 K 人"登记进真相表「外部审稿人已对接」| 你 + 架构师回填 STATUS |

**任一封发出**：真相表「外部审稿人已对接」就从 ❌ 变成可量化（接触数 > 0）。**任一人给实质反馈**：「文章被外部引用/讨论」也有了证据。

---

## 5. 风险登记（此前 0 条，现补）

| 风险 | 影响 | 缓解 |
|------|------|------|
| 冷邮件 0 回复 | outreach 停摆 | 先挂预印降低门槛；优先联系"近期同主题作者"（回复率最高）；ResearchGate 私信门槛更低 |
| 独立作者身份被轻视 | 学者不回 | 预印链接 + 具体到对方论文的提问，证明是同行而非民科；引用经典锚点建立坐标 |
| 中文期刊要公函卡死 | 中文域内发不出 | 把"解决公函"作为找合作者的明确诉求（模板 B）；或先走 SSRN/会议不要求公函的渠道 |
| 数据 n=2 被审稿人一票否决 | 核心结论被质疑 | 三篇已自标"n=2 推断边界 + 识别≠证实"——主动暴露弱点比被抓到好；把 reviewer 的质疑当 v0.4 输入 |
| 主动联系真人有心理门槛（用户写作/外联偏弱）| 拖延 | 本 SOP 把它拆成"列 10 个人 + 发 3 封"的小动作；架构师代写每一封的初稿，你只需改具体处 + 点发送 |

---

## 6. 本周最小动作（如果只做一件）

**注册 SSRN + 挂 08 英文预印。** 这一件解锁后面所有 outreach（有了链接才好敲门），且不依赖任何人同意，纯自己可完成。英文稿架构师已起草好（[preprints/08-EN](../articles/preprints/08-dual-reverse-calculation-pattern-EN.md)），你只需补 2 处作者信息 + 走注册流程。

---

*创建：2026-06-20 / 首席架构师（Claude）/ 应用户 C7 请求*
