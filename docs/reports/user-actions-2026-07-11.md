# 你的行动清单（2026-07-11 / 三件事 / 全部材料已备好）

> 原则：每件事你只做"打开→复制→粘贴→点发送"级别的操作。做完任意一件，随手告诉架构师，我来回填真相表。

---

## ① 蒲公英发帖 — ✅ 已完成（2026-07-11 / https://www.ouryao.com/thread-816324-1-1.html / 闸 1 启动，7/25 左右回收回帖信号）

1. 打开 `docs/articles/publish/ouryao-data-integrity-post-ready.md`
2. 登录 ouryao.com → 找"数据完整性"版块（没有就发"质量保证 QA"版块）
3. 复制文件里的**标题**（推荐第 1 个）和 ════ 之间的**纯文本正文**，粘贴，发布
4. 发完就关掉，两周内不看数据（7/25 左右一并回收信号）

有人回帖/私信时：同文件"回帖应对预案"有 4 种情形的现成回复，照抄即可。

---

## ② SSRN 挂 08 英文预印 — ✅ 已完成（2026-07-11 / abstract_id 7099138 / staff review 1-5 个工作日）

**要上传的文件**：`docs/articles/preprints/08-dual-reverse-calculation-pattern-EN.pdf`（已生成，14 页）

1. 打开 **ssrn.com** → 右上角 **Register**（免费）。邮箱用 **lizhuojun@gmail.com**（与 arXiv 等学术站一致，保持统一学术身份）；姓名填**真实姓名**（这将是论文署名）；机构选 **Independent**（输入框里输 independent 会出现无机构选项）
2. 登录后 → 顶部 **Submit a Paper**
3. 逐项填写（以下可直接复制）：
   - **Title**：
     `The Dual Reverse-Calculation Pattern: A Methodology for Auditing Compliance Narratives in Traditional Chinese Medicine Manufacturing`
   - **Date Written**：July 2026
   - **Abstract**：打开同目录的 `.md` 文件，复制 `## Abstract` 段全文粘贴（约 300 词）
   - **Keywords**：
     `compliance narrative; reverse calculation; Goodhart's law; data integrity; Traditional Chinese Medicine; GMP audit; agentic knowledge engineering; invariant detection; sigma-floor; game theory`
   - **JEL codes**：可跳过（选填 M42 Auditing）
4. **Upload**：上传上面那个 PDF
5. **Classification / eJournal**：搜索 `Pharmaceutical` → 勾选 **PharmSciRN**（其余可不选）
6. 提交。提交完成页会给出 `https://ssrn.com/abstract=XXXXXXX` 链接（SSRN 人工审核 1-5 个工作日后公开，但链接立刻可用）
7. **把这个链接发给架构师** → 我回填真相表 + 你进入第 ③ 步

---

## ③ 外审第一批 3 封信（⏳ 等 SSRN 审核通过后再发 / 每封 ~10 分钟 / 信中 SSRN 链接已填好）

> 时序说明（2026-07-11 用户判断）：审核通过前链接无公开内容，发信不妥。已设每日 09:05 自动检查任务（ssrn-7099138-review-watch），通过即提醒你发信。

1. 打开 `docs/reports/outreach-kit-2026-07.md`
2. 按每封信上方的"找人配方"（10 分钟）找到 1 个真实对象
3. 复制信件，替换 2 个【】占位（对方姓氏 / 对方论文），发送
4. 三封对应三类：**信 C** 会计/审计学者（英文）→ **信 B** STS 学者（英文）→ **信 A** 药企 QA 实务（中文，可等蒲公英回帖里自然出现人选）
5. 每发一封，在 kit 的追踪表填一行；**发出第一封的当天**，真相表「外审对接」❌ 即改判

---

## ④ 本地 commit（顺手 / ~1 分钟）

沙箱无法 commit，请在本地 Terminal 执行：

```bash
cd ~/Desktop/APP/huadian
git add docs/methodology/decision-journals/2026-07.md \
        docs/articles/publish/ouryao-data-integrity-post-ready.md \
        docs/articles/preprints/08-dual-reverse-calculation-pattern-EN.md \
        docs/articles/preprints/08-dual-reverse-calculation-pattern-EN.pdf \
        docs/reports/outreach-kit-2026-07.md \
        docs/reports/user-actions-2026-07-11.md \
        docs/STATUS.md docs/CHANGELOG.md
git commit -m "docs: 2026-07 journal v0.1 + external-action kits (ouryao post, SSRN pkg, outreach letters)"
git push
```

---

## 完成判定（做完打勾）

- [x] 蒲公英帖已发（https://www.ouryao.com/thread-816324-1-1.html / 2026-07-11）
- [x] SSRN 已提交（https://ssrn.com/abstract=7099138 / 2026-07-11 / staff review 中）
- [ ] 外审信已发 ＿ 封（见 outreach-kit 追踪表）
- [ ] 已 commit + push
- [ ] 已把结果告诉架构师（回填真相表 + 定 7 月底信号回收）

*另有一份待你审稿：`docs/methodology/decision-journals/2026-07.md`（月度日记 v0.1，审完我定版 v1.0。不急，可放在三件事之后。）*
