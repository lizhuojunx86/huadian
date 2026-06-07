# D-route 进度评估报告（2026-06-07）

> 范围：华典智谱全仓 · 进度 vs 目标/路线图差距评估
> 评估人：首席架构师（Claude Opus 4.8）
> 方法：6 维度多 agent 并行勘察（roadmap / L1 / L2 / L3 / 治理 / 战略纪律）→ 综合 → 对抗式批判；关键 git 事实由架构师本人独立复核
> 锚点：[ADR-028](../decisions/ADR-028-strategic-pivot-to-methodology.md) · [D-route §6](../strategy/D-route-positioning.md) · [sprint-roadmap-D-route](../strategy/sprint-roadmap-D-route.md)
> 状态：v1.0（用户已 ACK）

---

## 0. 一句话总评

**方法论写作这一条线真实高产、质量扎实；但代价是 Layer 1 框架代码与史记主案例双双冻结，而几乎所有"对外可验证"的里程碑（正式发表 / 外部引用 / outreach / 外部工程师可跑通）仍是 0。** STATUS.md 用容易产出的维度（文档、sprint 计数）的 ⭐⭐⭐ 系统性地盖住了这两处真实滞后——这**不是欺骗**（限定词如"commit 待用户本地""待外部审稿"都在文里），而是"渲染层与判据层没分离"，叠加"把单一案例 case-2 做深"的纪律拉锯。

---

## 1. 关键事实（架构师本人 git 复核，非引自 STATUS）

| 事实 | 证据 | 含义 |
|---|---|---|
| 本地 HEAD 领先 origin/main **19 commit** | `git rev-list origin/main..HEAD = 19` | 6 月全部工作未公开 |
| origin/main 停在 **2026-05-15**（GO-M-ζ `47de92e`）| `git log origin/main -1` | 公开仓滞后 ~3 周 |
| 08/09 **早期草稿**在公开仓；**10 完全未公开** | `git cat-file -e origin/main:...08/09 ✓ / 10 ✗`；origin 上 08 = "Draft v0.3 启动 partial GO-K-ε" | 精炼 v0.3 + v0.4 前置批均未公开 |
| 框架 **v0.3.0 / v0.2.0 tag 已在 origin** | `git ls-remote --tags origin` | 框架代码 release 是真公开的 |
| `framework/**/*.py` 自 **2026-05-03** 起零实质改动 | `git log -- framework/ \| 最新 2026-05-05（仅 docs/templates）` | L1 代码冻结 ~5 周 |
| `services/pipeline` 自 **2026-04-29** 起零 commit | 转型前 Sprint K 收口 | 史记主案例事实冻结 |

> **重要语境**：未 push 是**沙箱 `.git` 只读**所致——Claude 无法 push，需用户本地执行。STATUS 每条都诚实标注"commit 待用户本地"。因此"未 push"是机械待办，**不是隐藏未完成工作**；真正的硬缺口是 **0 正式发表 / 0 外部引用 / 0 outreach**。

---

## 2. 四层记分牌

| Layer | 状态 | 一句话 |
|---|---|---|
| **L1 框架代码** | 🟡 实为**冻结待触发** | 3 个 Python 模块（~9500 行）真实可跑、单测全绿、traceguard PoC 扎实；但代码冻结 ~5 周，3 条硬完成判据 0–1/3 达标 |
| **L2 方法论文档** | 🟠 behind（部分按设计） | 起草产能强（00–07 八份 + 08/09/10 三篇 + 2 篇月度日记）；但 **0 篇发表、0 外部引用、外审尚无人对接** |
| **L3 案例库** | 🟢 on-track（唯一活跃产能源）| case-2 中药事实顶替史记成为第 2 跨域案例，traceguard 第 2 domain config 真实验证可移植性；但 100% 押单案例、n=2 天花板 |
| **L4 社区/商业** | ⚪ 有意休眠 | STATUS 标 🟢 名实不符；外部触发条件零进展，但 L4 本属机会主义层，休眠可接受 |

---

## 3. 路线图里程碑逐条（D-route §6，今 2026-06-07）

| 时间锚 | 计划 | 实际 | 判定 |
|---|---|---|---|
| 2026-05 (1mo) | 文档对齐 + Sprint L 启动 | Stage A–D 全完成，Sprint L→AA 共 16 个关档 | ✅ 达成 |
| **2026-06 (2mo)** | 7 份草案 v0.2 + 第 1 个跨域案例**邀约**启动 | 草案口径存疑（doc 头仍写 Draft v0.1）；邀约**未达成**——case-2 是用户自有领域、单人 self-driven，非"外部邀约"，shiji-kb 交流=0 | ⚠️ 半达成 |
| **2026-08 (4mo)** | 史记 **5–10 篇延伸级** + 产品化 demo | 史记冻结于 729 persons / 3–4 本纪、零新 ingest；demo 仅 README 一段。**里程碑已被事实放弃、由 case-2 顶替，但路线图未改写**（见 ADR-038） | 🔴 已悄悄放弃 |
| 2026-10 (6mo) | 1–2 篇文章发表 + 1 次近邻交流 | 三篇仍 v0.3 草稿、排期零 buffer；对外发布肌肉未建立 | ⏳ 前瞻风险高 |
| 2027-01 (9mo) | 框架 v0.1 release | L1 代码停滞 5 周；若继续全投 case-2，framework 侧无法成熟 | ⏳ 已现停滞信号 |
| 2027-04 (12mo) | 第 2 跨域案例验证可移植性 | case-2 **超前**达成核心目标（traceguard PoC + 第 2 domain config 真落地）| 🟢 on-track/ahead |

**North Star**：6 项仅"月度日记累计字数"1 项客观达标（2 月 ~1.2 万字，超 6mo 目标）；其余（外部 1h 跑通 / ≥1 篇被引 / 跨域邀约）= 0 或不可测。

---

## 4. 真正的强项（不被叙事注水的部分）

1. **traceguard E1–E3 PoC 是本月唯一货真价实的框架抽象产出**：从"文章内设计"落成真实可跑代码，6 批 σ 矩阵端到端 fire，dogfood 246 passed，且暴露了纯设计稿发现不了的 **E4 候选（结构化输出持久化）**。commit `b9c1767`/`a683696`/`1a341f5` 经独立核实存在。
2. **三个 framework Python 模块是真代码不是空壳**，core 与 examples 工程隔离（PEP 544 Protocol、core 零中药字样）确实落地。
3. **三篇 case-2 文章有真正学术雄心且引用可核**：08 的 12 条参考文献是真期刊卷期页码（非占位），09 引 Latour/Scott/Wenger，10 提出"易操纵⊥易暴露"反转悖论 + Simpson 稀释数学。并诚实自标 **n=2 推断边界 + "识别≠证实"**。
4. **case-3 道德经（ADR-036）正确选择"不开"**——拒绝"在两个不成熟案例间互证"的反模式。
5. **ADR 治理框架扎实**；写作短板有"架构师代笔 + 用户审稿"闭环主动补偿（已 2 次实证）。

---

## 5. 真正的差距 —— 区分"有意的 behind"和"失控的 behind"

本评估最有价值的判断：**不是所有滞后都是问题。**

### ✅ 属于 D-route 有意设计、可接受的 behind
- 史记冻结、不再做新章节（§4 Sunset 明确，宪法"3–4 篇深度 ≥ 50 篇浅度"）
- 0 篇发表（12mo deadline 在 2027-04，2 月节点未发表属预期内）
- L4 休眠

### 🔴 真正失控、需要正视的 behind

1. **L1 代码冻结已触发路线图自己的警告信号**（sprint-roadmap §6"连续 2 sprint 无 L1 抽象推进"），却被"方法论文章高产"的表象掩盖，无人鸣警。2027-01 v0.1 锚点真实进度被高估。
2. **L2 真正的人际瓶颈无人负责**：三篇全卡"待 2026-09 外审"，但"找到愿审 GMP+STS 跨域稿的外部专家"这个**代笔无法替代**的环节，全文 0 风险登记、0 de-risk、0 fallback。
3. **L1 三条硬完成判据 0–1/3 达标**：领域无关比例实测 ~56–62%（低于 70%）；`framework/` 此前无 packaging/README/starter（已于本次补，见 §6）；框架命名 ADR 此前不存在（已开 ADR-037 proposed）。**audit_triage 此前 0 单测**（已于本次补 33 个）。
4. **"12 连胜 zero-trigger / 240% over target"经 git 证伪为叙事注水**：P→AA 全部在 2026-05-03~05-05 三天内提交，工作退化为 +6/+42 行 cross-ref 微调；zero-trigger 在维护态是"无事可清"的同义反复，当 KPI 有 Goodhart 风险。
5. **case-2 边际抽象产出递减、逼近"完成度陷阱"临界**：近一月约 15 个 GO 阶段绝大多数是同三篇文章的 v0.x 微迭代 + citation 核实 + 措辞统一 + 渠道调研，单位时间"新增独立知识资产"很少。
6. **公开仓滞后 ~3 周**（见 §1）——机械待办，但对 public-facing 开源框架，活体证明锁在本地仍是真实损失。

---

## 6. 整改计划与执行状态

| # | 行动 | 负责 | 状态（2026-06-07）|
|---|---|---|---|
| 1 | push 本地 19 commit 到 public GitHub | **用户**（沙箱 .git 只读）| ⏳ 待用户执行（命令见 §7）|
| 2 | "找外审" 与 "挂 arXiv/SSRN 预印" 解耦并行；联系 ≥3 外审人选 | **用户**（账号 + 人际）| ⏳ 待用户启动 |
| 3 | L1 收尾：framework 顶层 pyproject + README + requirements + audit_triage 单测 | 架构师 | ✅ **已完成**（33 新测试 / 全套 93 passed / ruff clean / 本次提交）|
| 4① | 正式登记"2026-08 史记里程碑由 case-2 顶替"，消除 §4/§6 矛盾 | 架构师 | ✅ ADR-038 proposed（待用户 ACK 后改 D-route §6 / roadmap §2）|
| 4② | STATUS 加"对外可验证判据真相表" + L1 状态色 🟢→🟡 | 架构师 | ✅ **已完成**（STATUS §1.2）|
| 5 | 给 case-2 主线（GO-S~AC-η）补合并 retro + 估时核对 | 架构师 | ✅ **已完成**（retros/case-2-go-s-to-ac-retro）|
| 6 | 给 case-2 设"深度止损线" | 架构师 | ✅ 已写入 case-2 retro §6（待用户确认阈值）|
| — | 框架包名拍板 | **用户**（战略决策）| ⏳ ADR-037 proposed |

---

## 7. 交给用户的可执行清单（行动 1–2）

```bash
# 行动 1：公开本地工作（在本机 Terminal，非沙箱）
cd /Users/lizhuojun/Desktop/APP/huadian
git status                     # 确认 19 commit ahead
git push origin main
# traceguard 仓的 3 commit 同理：
cd /Users/lizhuojun/Desktop/APP/traceguard && git push

# 行动 2（建议）：解耦预印与外审
# - 预印：把 08/09/10 v0.3（或 v0.4 定稿）挂 arXiv (cs.CY / stat.AP) 或 SSRN，CC BY 4.0
#   → 不需外审即产生可引用 artifact + outreach 抓手
# - 外审：本周实际联系 ≥3 人（GMP 专家 / STS 学者 / 会计学者），把人际瓶颈前移暴露
```

---

## 8. 整体判断

方向正确、治理意识强、写作质量高，但**当前节奏失衡、自我评估偏乐观**。没有失控到危险，但已到"该把容易的事（写文档、刷 sprint 计数）放一放，去啃难的事（push 公开、找外审、给框架打包、重启 L1）"的时间点。

> 最该警惕的一句话：**不要让 case-2 中药变成第二个史记式的"完成度黑洞"。**

---

## 附录：评估方法与可信度

- 6 维度由独立 subagent 并行勘察，各自落到文件路径取证；综合后再经一轮对抗式批判（catch 到综合稿的 2 处过头：①"0/3 判据"实为 0–1/3，根有 pyproject 但不覆盖 framework；②领域无关比例 56.4% vs 62.3% 口径未统一 → 本报告统一记 ~56–62%）。
- "19 commit / origin 停 2026-05-15 / 08-09 早稿在公开仓 / 10 未公开 / framework 代码冻结" 等关键事实由架构师本人 git 复核，已修正综合稿"三篇连 push 都没做到"的过头表述。
- 对抗式批判同时提醒：D-route 是有意的 long game，部分"behind"（史记冻结 / 不抢发表 / L4 休眠）是设计意图而非失败——本报告 §5 已据此分流。
