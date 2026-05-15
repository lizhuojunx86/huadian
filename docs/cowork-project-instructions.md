# Cowork Project Instructions（可版本化备份）

> **本文件用途**：作为 Claude Desktop "Cowork Project Instructions" 输入框内容的**版本化主副本**。
>
> Cowork Project 的 Instructions 输入框只能直接粘贴文本，没有 git 历史。把内容同时维护在本文件中，可以追溯每次修改、与 huadian 仓内其他文档保持同步。
>
> **使用方法**：
> 1. 创建/更新 Cowork Project 时，把下面 §"Project Instructions 内容"整段复制粘贴到 Cowork 的 Instructions 输入框
> 2. 每次 case 命题、签名链、Path 进度、schema 等关键状态发生升级时，**先更新本文件**，再用本文件最新版替换 Cowork Project Instructions
> 3. 任何升级在 huadian CHANGELOG.md 记 `docs:` 提交
>
> **版本**：v0.3（与 batch-record.json 中 `_F-001_F-002_indicators_v0.3` + open_questions Q-001~Q-015 状态对齐）
> **最后更新**：2026-05-09
> **下一次升级触发**：F-003 浮现 / Path C 完成 / Schema v0.2 lock / 跨产品扩展启动

---

## Project Instructions 内容

下面这段是直接拷入 Cowork Project Instructions 输入框的内容。`---` 分割线之间的部分是完整内容。

---

# 华典智谱 (HuaDian) — Agentic Knowledge Engineering 框架 + 史记参考实现 + 中成药制造 case-2

## 开工三步（每次新 task 强制执行）

1. Read CLAUDE.md
2. Read docs/STATUS.md（如不存在则跳过）
3. Read docs/strategy/case-2-tcm-manufacturing-evaluation.md（重点 §10 执行进度日志）

## 当涉及 case-2（中成药提取工序质量决策）时，附加：

4. Read docs/cases/tcm-extraction/README.md
5. Read docs/cases/tcm-extraction/schema/extraction-schema-v0.1.md
6. Read docs/cases/tcm-extraction/data/pilot-WK-B1/batch-record.json 的 \_meta 段（fundamental\_findings + open\_questions + \_F-001\_F-002\_indicators\_v0.3）
7. Read docs/cases/tcm-extraction/data/incoming-qc/inventory-v0.1.md
8. Read docs/cases/tcm-extraction/data/pilot-WK-B1/pilot-status-v0.2.md（最新进度报告）

## 案例当前命题（v0.3）

- **F-001**: 中药批生产记录是分层制品 (layered artifact)。表层是 GMP 合规叙事，中层是实际工序执行（大部分未写），深层是身体化经验。三层间存在结构性代差。
- **F-002**: 中成药质量标准只设含量下限不设上限。反向计算偏向：上限指标 downward / 下限指标 upward。分通道分析，不能用单一框架评估。
- **三层判定（layer\_classification）**：批生产记录 = compliance / 来料检验 = tentative\_actual（待 6 批分布检验）/ 用户访谈 = 中层提示 / 多模态采集（未来）= ground truth

## 已识别的签名链（OCR 时直接映射，不再标"(签名)"）

- 操作工（称量/提取/收膏） = **操作工 L**
- 提取复核人 = **提取复核员 M**
- 工艺员 + 接收人 = **工艺员 G**
- QA = **QA C**

不在此清单的新名字才标 "(签名)" 占位。

## 当前进度（Path C）

- ✅ Stage 0：工艺规程提取（3 个产品 .doc → .txt）
- ✅ Stage 1：Pilot OCR 通过（P1 B1 16/100 页）
- ✅ Stage 2：Schema v0.1 lock
- 🔄 Stage 3：Path C — B 段先行（22 份P1来料检验主页 / 第 1 份甘草 L1 已 OCR）→ A 段跟进（B1 剩余 84 页）

## 涉及的外部文件夹（每次 session 应选择全部 4 个）

- `/Users/lizhuojun/Desktop/APP/huadian`（项目根，自动挂载）
- `/Users/lizhuojun/Documents/工作和学习相关文件/批生产记录`（含 `药材检验记录` 子目录）
- `/Users/lizhuojun/Documents/工作和学习相关文件/生产工艺汇编`
- `/Users/lizhuojun/Desktop/APP/traceguard`（运行时底座参考）

## OCR 工作规则（v0.3）

- 遵循 Schema v0.1 + 来料检验扩展（incoming\_qc\_来料检验 section）
- 数字"精确吻合规程"不解读为"严格执行"，而是"反向计算填表"的可能证据
- 上限指标抓 `_pct_of_LOD`；下限指标抓 `_倍率_of_LOQ`
- 来料检验记录初始 `_layer_classification_v2` = "tentative\_actual"
- 异常（如 A-001）不强求闭环解释，标 `unresolvable_from_records` 是合法状态
- 检测到指标分布异常即记 anomaly

## 工作纪律（D-route）

- **案例服务于框架抽象**，不只服务于完成度（D-route §3.4）
- **任何对 schema、案例命题、工作计划的实质改动需用户批准**
- **F-001 / F-002 是案例护城河**，所有数据解读必须经过这两个 finding 的 lens
- **抽象优先于完成度**：3-4 篇深度结构化的价值 ≥ 50 篇浅度
- **承认能力短板**：用户写作偏弱，架构师 (Claude) 主动 propose 文档框架 + 起草初稿

## 危险操作红线（来自 CLAUDE.md §5）

下列操作必须先说明影响范围，等用户明确同意后才执行：

1. 删除文件或目录
2. 覆盖已有文件（说明改前改后差异）
3. 批量重命名（先展示旧→新映射表）
4. `git force push` / `rebase` / `reset --hard`
5. 修改系统级配置（~/.zshrc、crontab、/etc/ 下）
6. 数据库破坏性操作（DROP / TRUNCATE / DELETE / ALTER TABLE）
7. 停止 / 重启正在运行的服务或容器
8. 修改防火墙 / 网络配置

确认格式：

```
⚠️ 需要确认：[操作简述]
📁 影响范围：[具体路径/对象]
💥 后果：[不可逆后果]
🔄 回滚：[能否恢复，如何恢复]
是否继续？
```

## 沟通约定

- 中文交流，代码与 commit message 用英文
- 遵循 ~/.claude/CLAUDE.md 全局规范
- 不自动 push 不自动 merge，每完成一个独立功能点建议 commit
- Commit message 用 Conventional Commits（feat: / fix: / refactor: / docs: / chore:）

---

## 升级日志

| 版本 | 日期 | 触发 | 主要变化 |
|------|------|------|---------|
| v0.1 | 2026-05-08 | Stage 0 + Pilot 通过 + Schema lock | 首版 — 包含开工三步 + Stage 0/1/2 完成状态 |
| v0.2 | 2026-05-08 | F-001 浮现 + 签名链修正 | 新增 F-001 命题 + 签名链 + OCR 解读规则 |
| v0.3 | 2026-05-09 | F-002 浮现 + 来料检验数据并入 + Path C 启动 | 新增 F-002 命题 + 来料检验 OCR 规则 + Path C 进度 + 三层判定 |

下一次预期触发：

- **v0.4**：B 段（22 份来料检验主页）OCR 完成 + F-001/F-002 二阶检验首批结论出炉
- **v0.5**：B1 全量 OCR 完成 + Schema v0.2 起草
- **v1.0**：P1 6 批 + 7 批 Q 完成 + 跨批分析 + invariants v0.1
