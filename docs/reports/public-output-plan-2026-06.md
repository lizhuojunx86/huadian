# 公开输出执行计划 — 2026-06（Batch 1）

> 依据：2026-06-10 D-route 方向评估（10-agent 多视角评估 + 2-agent 平台机制核实）。
> 核心结论：方向保留，兑现模式从"闭门精修"切换为"月度公开输出 + 外部接触"。
> 本文件是跨会话追踪板：每完成一项打勾并注明日期。

---

## 0. P0 — case-2 敏感信息脱敏（先于一切发布动作）

**问题**：08/09/10 三篇及配套文档含真实产品名、批号、设备型号、精确投料量；
双产品名 + 批号组合可反向识别企业，而文章主张"记录反算造假嫌疑"（F-004）→ 法律/伦理风险。
**已核实**：真实产品名已存在于公开远端 origin/main 至少 8 个文件 + git 历史（自 commit 84f93a1 起）。

- [x] 0.1 脱敏全量扫描 + 映射表产出（2026-06-11 / 范围远超预估：除三篇文章外，主战场是 `docs/cases/tcm-extraction/` 数据树——7600 行 batch-record.json 含企业名/供应商/真实人名/全部批号；3 份工艺规程 raw txt 含**国药准字批文号**（药监局可直接反查企业）；6 个文件/目录名本身含敏感值需重命名）→ **等用户确认映射方案**
- [x] 0.2 **工作区批量脱敏完成（2026-06-11）**：两轮替换共 37 个文件约 2300 处（产品/批号/lot/设备/批文号/SOP编号体系/物料码/供应商/设备厂商/人名/企业名）+ 6 项 git mv 重命名 + 08/09/10 与 case README 加脱敏说明节；σ/极差/倍率计算输入数值全部保留原值；终验 grep 全部敏感值 = 0 命中；假名映射不落盘
- [x] 0.3a **huadian 本地历史重写完成（2026-06-12，方案 A 用户 ACK）**：mirror 备份至 `_backups/huadian-pre-rewrite-20260612.git` → `git filter-repo` 重写 437 commits（replace-text 全映射 + 6 项历史路径 rename）→ 全历史 pickaxe 验证 8 个高危词 0 命中。注意：全部 commit SHA 已变更（文档中引用的旧 SHA 失效，叙事性引用可接受）；origin remote 已被 filter-repo 按安全设计移除
- [x] 0.3b **GitHub 端处置完成（2026-06-13 用户执行）**：huadian + traceguard 双仓删仓重建同名 → push main --tags → traceguard v0.2.0 release 重建（gh release create）→ 旧备份 _backups 已删除。**两仓当前 private，待网页抽查后转 public**
- [x] 0.3c **traceguard 历史重写完成（2026-06-13 用户执行）**：filter-repo 45 commits（Already-Ran 提示answered N）→ pickaxe 验证 0 命中；PyPI 包 traceguard 0.2.0 经逐文件验证不含敏感数据（wheel/sdist 仅 src+tests），无需 yank；huadian uv.lock 已 relock（c1c1b750 → 新 SHA / commit 8572f3b）
- [x] 0.6 **三篇文章知乎导入适配（2026-06-13）**：根因 = `$` 金额被知乎当 LaTeX 公式定界符劫持 + 代码块导入器占位符复原 bug（`__CODE_BLOCK_2__` 泄漏）。修复：$ 金额全部改写"X.XX 美元"、代码块全部转引用块、表格已转列表。三篇终验 0 个 `$`、0 个代码块、0 表格
- [x] 0.4 target-venues §6 已补登记脱敏工序（2026-06-11，标记已完成）
- [x] 0.5 traceguard 仓库脱敏完成（2026-06-11：configs 本就是合成数据 ✅；examples/tcm_extraction_poc 真实批号已替换 + 批次 json 重命名，复验 0 残留。注意 traceguard 若为 public 同样有历史暴露问题，处置方式同 0.3）

## 1. 第一批文章（draft v0.1 → 用户审订 → 发布）

| 文章 | 草稿文件 | 发布渠道 | 状态 |
|------|---------|---------|------|
| Stop Rules：给 AI agent 团队设计"硬中断" | `docs/articles/2026-06-stop-rules-for-ai-agent-teams.md` | 博客/知乎 → 阮一峰周刊【开源自荐】issue | ☑ 草稿 ☑ 审订 ☑ **知乎已发（2026-06-13）** |
| 另一个项目"抄"了我们的框架之后 | `docs/articles/2026-06-when-another-project-adopted-our-schema.md` | 同上（传播性更强，优先） | ☑ 草稿 ☑ 审订 ☑ **知乎已发（2026-06-13）** |
| 一个人 + AI 扮演 10 个角色（旗舰复盘，8 周/27 sprint/34 ADR） | `docs/articles/2026-06-solo-plus-ai-multi-role-retrospective.md` | 博客 + 阮一峰周刊；后续译英文发 HN（普通链接帖，非 Show HN） | ☑ 草稿 ☑ 审订 ☑ **知乎已发（2026-06-13）** |

**GitHub 页面完善（2026-06-13）**：双仓 About 侧栏（description/topics/homepage）✅ · traceguard badges + pip install 修正（fe13f72 已 push）✅ · huadian Release v0.3.0 创建 ✅ · 两仓均 public ✅ · 知乎 3 篇链接已补进 README 延伸阅读节（352fa18）✅ · HelloGitHub + 阮一峰自荐已提交（见 §2）✅。

三篇草稿均已通过敏感值泄漏检查（grep 产品名/批号/设备/批文号/人名 = 0 命中）。

**发布版（2026-06-11 生成，可直接复制发帖）**：`docs/articles/publish/` 下三篇——已剥离内部注释头、填入作者投入数据（20h / ~$100）、文末协作声明改为对外措辞。**注意顺序依赖**：旗舰复盘文与阮一峰/HelloGitHub 自荐均含 repo 链接且以"全程可查证"为卖点，须等 0.3 历史处置完成、仓库重新 public 后再发。

## 2. README 更新 + 项目自荐

- [x] 2.1a README 更新提案产出（2026-06-11，15 处变更：v0.3.0/kb-forge/34 ADRs/断链修复/首屏重写/Quick start 双路径）
- [x] 2.1b README.md 已按提案覆盖（2026-06-13，commit 2e8c126）+ 延伸阅读节加 3 篇知乎链接（352fa18）
- [x] 2.2 HelloGitHub 自荐已提交（2026-06-13 / 类别：人工智能 / 等月刊审稿，月底 28 日出刊周期）
- [x] 2.3 阮一峰周刊自荐已提交（2026-06-13 / 【开源自荐】issue，含项目 + 3 篇文章链接 / 周五发布周期，策展人单选）

**待回收的外部信号（下次 sync 检查）**：HelloGitHub issue 是否被标记收录 / 阮一峰 issue 是否进入某期周刊 / 知乎三篇阅读·点赞·评论数 → 任一非零即真相表「文章被外部引用/讨论」❌→✅ 的证据。

## 3. case-2 三篇的发布管线（脱敏完成后）

- [ ] 3.1 蒲公英制药技术论坛（https://www.ouryao.com ）注册 + 发 08 脱敏精简版试水（"数据完整性"版块对口）
- [ ] 3.2 三篇补英文摘要；08 全文英译（SSRN 要求全文英文）
- [ ] 3.3 SSRN 注册（affiliation = Independent Researcher）→ PharmSciRN 挂 08 working paper（约 3 工作日上线）
- [ ] 3.4 联系学术合作者 1-2 人（会计/IS 或药学）——同时解决：期刊单位公函、学术文体校准、arXiv endorsement 三个问题
  - 注：《中成药》《中国医药工业杂志》均要求单位盖章/推荐公函，独立作者实质无法直投；正版投稿口分别为 zcyjournal.com / cjph.com.cn（zcyzzs.cn、zgyygyzz.cn 为中介仿冒站）

## 4. 第二批：扩散 + 下一篇 + 近邻交流（2026-06-13 启动）

### 4.1 三篇已发文章扩散（B / 用户自发，文件已备）
- [x] 掘金发布 3 篇（2026-06-19）：硬中断 https://juejin.cn/post/7652526717098868751 · solo+AI https://juejin.cn/post/7652526717098885135 · 框架被抄 https://juejin.cn/post/7652630546754191360 → 已补进 README 延伸阅读
- [~] V2EX：**放弃**（发帖需邀请码，用户无）
- [ ] 检查知乎 3 篇是否加了话题标签（人工智能/LLM/开源）——影响推荐分发

### 4.2 下一篇（D / 已排版待发）
- [x] 起草 + 排版：`docs/articles/2026-07-why-llm-entities-should-not-auto-merge.md`（消歧主题 / 按 rules.py 真实语义写 / 含 1 处 [作者补充]）
- [x] 知乎版 + 掘金版已生成（`docs/articles/publish/` + `/juejin/`）
- [x] [作者补充] 已填（架构师用 Sprint F 真实通假字案例 缪/穆·傒/奚 填充 / 2026-06-19）→ 三份发布版 0 占位符
- [ ] 用户审订 → 发布（掘金新号当日限额已满，过 1-2 天再发 / 建议在 C 搭话前先发，作为技术钩子落地页）

### 4.3 近邻交流（C / shiji-kb 搭话，仅用户可发）
- [x] 核实：baojie/shiji-kb 实在 / **2112 star** / Discussions 已开 / public（2026-05-14 last push）
- [x] 草稿就绪：`docs/articles/outreach/shiji-kb-outreach-draft.md`（3 版本 / 推荐走 GitHub Discussion）
- [ ] **用户决定变体 + 自行发送**（架构师不代发：对 2112-star 同行的首次接触不可撤回，须用户亲点）→ 发后在 STATUS §1.2「近邻交流」登记

### 4.4 doc-code 修复（已完成）
- [x] methodology/03 §2.1–§2.3 + §4.1 R1-R6 语义校正（以 rules.py 为准 / 新增"匹配置信度 vs 身份-FP"区分 / v0.2.1 / 不改代码）

## 5. 后续弹药（素材已就绪，未启动）

- 决策日记 2026-05/06 → 各重写为单主题博客（每篇约半天）
- 框架代码"单点薄工具"评估：6 个月内无外部试用则降级为文档附件（per 价值地图判断）

## 5. 节律约定

- 每月 1-2 篇公开文章（素材库 = 现有 methodology/retros/日记）
- 分工：写与改 = 架构师代笔（Q5）；注册、发帖、联系真人 = 仅用户可做
- 真相表（STATUS §1.2）对应项随发布进度刷新：发表数 / 引用数 / 外审接触数 / 近邻交流数

---

*创建：2026-06-11 / 首席架构师（Claude）/ 依据 2026-06-10 方向评估*
