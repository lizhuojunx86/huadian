# Sprint ⚠️FILL-ID Brief — ⚠️FILL-TOPIC

> 复制本文件到 `docs/sprint-logs/sprint-{id}/stage-0-brief-YYYY-MM-DD.md` 后填写。
> 删除本注释块。占位符用 `⚠️FILL-XXX` 标识。

## 0. 元信息

- **架构师**：⚠️FILL-NAME / 角色
- **Brief 日期**：YYYY-MM-DD
- **Sprint 形态**：⚠️FILL `单 track` / `多 track 并行` （多 track 需说明各 track 主题）
- **预估工时**：⚠️FILL `N 天 / 周`
- **PE 模型**：⚠️FILL `Sonnet 4.X` / `Opus 4.X` / `N/A (single-actor sprint)`（理由：执行类用 Sonnet / 创设类用 Opus / 单 actor sprint 填 N/A）
- **Architect 模型**：⚠️FILL `Opus 4.X`（架构师 session 通常用 Opus）
- **触发事件**：⚠️FILL `前置 sprint 的什么发现 / 衍生债驱动 / 战略转型 / etc`

---

## 1. 背景

### 1.1 前置上下文
⚠️FILL：前 N 个 sprint 已完成什么；本 sprint 在大局中的位置；战略锚点引用（如 ADR-NNN）

### 1.2 与既有 sprint 的差异
⚠️FILL（表格）：当前 sprint vs 历史最近 sprint(s) 的关键维度对比。

> **列数灵活**（DGF-Sprint-O 反馈 / Sprint P T-P3-FW-001）：
> - 与单一上一 sprint 比时：2 列表头（"上一 sprint" / "本 sprint"）
> - 与一批近 N 个 sprint 比时：表头写聚合范围（如 "Sprint L-O" / "本 sprint"）
> - 与不同形态 sprint 各 1 个对比时：N+1 列（如 "Sprint L 抽象" / "Sprint M 抽象" / "本 sprint"）
> - 维度行数也灵活：3-7 行通常足够，超 8 行说明对比维度过多 → 拆 sub-section。

| 维度 | ⚠️FILL 历史范围 | 本 sprint |
|------|------|---------|
| ⚠️FILL | ... | ... |
| ⚠️FILL | ... | ... |

### 1.3 不做的事（Negative Scope）
⚠️FILL：本 sprint 显式不做的事（防止 scope creep）

- ❌ ⚠️FILL
- ❌ ⚠️FILL

---

## 2. 目标范围

### 2.1 Track 1 — ⚠️FILL Track 主题（如单 track 此节即唯一目标）

**目标**：⚠️FILL 一句话目标

**具体动作**：
- ⚠️FILL
- ⚠️FILL

**完成判据**：
- ⚠️FILL（可量化的完成标准）

### 2.2 Track 2 — ⚠️FILL Track 主题（仅多 track 情况）

（同上结构）

---

## 3. Stages

> ⚠️ **二选一**：根据 sprint 形态选 §3.A（5-stage 数据管线模板）或 §3.B（精简 / 文档 + 框架抽象模板）。
> 不要硬填空 stage（"无"或 N/A 是负担）。
> 选择依据：见 §3.0 选择指南。

### 3.0 Stages 形态选择指南（DGF-M-01 / Sprint P 新增）

按以下顺序判断，第一个 ✅ 即采用：

| 条件 | 适用模板 |
|------|---------|
| 涉及 LLM 抽取 / DB write / Stage 3 historian review | **§3.A（5-stage 数据管线）** |
| 涉及 schema migration / production data backfill | §3.A |
| 纯 framework 抽象 / methodology 起草 / template polish / release prep | **§3.B（精简 1-2 阶段）** |
| 纯文档整理 / cross-ref 修复 / debt patch | §3.B |
| 单 actor + 全 in-memory + 0 DB write | §3.B |

实证（华典智谱）：
- Sprint A-K（数据 ingest）→ §3.A
- Sprint L-P（framework 抽象 / patch）→ §3.B
- 大多数 D-route Layer 1 抽象 sprint → §3.B

---

### 3.A — 5-stage 数据管线模板（数据 sprint 用）

#### Stage 0 — 前置准备 / Inventory

⚠️FILL：本 sprint 启动前需要的准备工作（fixture / adapter / inventory / etc）

输出：⚠️FILL `docs/sprint-logs/sprint-{id}/stage-0-{topic}.md`

#### Stage 1 — Smoke

**子集大小**：⚠️FILL `5 段 / 1 章节 / 10 行 / etc`

**Gate 0**：
- ⚠️FILL LLM cost 不超过 $⚠️N
- ⚠️FILL invariants 全绿
- ⚠️FILL 输出格式符合 schema

#### Stage 2 — Full

**Gate 1**：
- ⚠️FILL 总成本 ≤ $⚠️N（brief 预算的 1.5x 内）
- ⚠️FILL 新增实体数 ≤ ⚠️N（brief 预期的 1.2x 内）
- ⚠️FILL 没有任何 invariant 回归

#### Stage 3 — Dry-Run + Review

⚠️FILL：本 sprint 的 review 类型（merge candidates / split candidates / mapping verification / etc）

**Gate 2**：
- ⚠️FILL Domain Expert 完成 review
- ⚠️FILL Architect ACK 决策
- ⚠️FILL apply input file 就绪

#### Stage 4 — Apply

**关键约束**：
- ⚠️FILL idempotency unique key
- pre-apply pg_dump anchor（必备）
- rollback 策略：⚠️FILL

**Gate 3**：
- ⚠️FILL DB 写入数与决策数一致（误差 ≤ 5%）
- ⚠️FILL invariants 仍全绿
- ⚠️FILL audit log 完整

#### Stage 5 — Closeout

输出：
- 任务卡 → done
- STATUS / CHANGELOG 更新
- retro 文档（含 D-route 资产盘点段）
- 衍生债登记

---

### 3.B — 精简模板（framework 抽象 / 纯文档 / patch sprint 用）

实证：Sprint L / M / N / O / P 全部用本路径。

#### Stage 0 — Inventory（轻量；如已在 brief §2 列清，可写"§2 即 inventory，无独立文档"）

⚠️FILL：本 sprint 抽出的源代码 / 文档清单 / 待 patch 候选清单。

输出（任选）：
- 独立文档 `docs/sprint-logs/sprint-{id}/stage-0-inventory-YYYY-MM-DD.md`
- **或**直接在 brief §2.1 列清，不另起文档（patch / polish sprint 推荐此模式）

#### Stage 1 — 抽象 / Patch / Polish 主体

按批次组织（每批 ≤ ~30 分钟工作量）：

1. **批 1：⚠️FILL 主题** — ⚠️FILL 文件 / 估时
2. **批 2：⚠️FILL 主题** — ⚠️FILL 文件 / 估时
3. **批 N：⚠️FILL 主题** — ⚠️FILL

**Gate 1.B**：
- ⚠️FILL ruff check + format clean（仅当涉及代码改动）
- ⚠️FILL 改动文件 sanity import / smoke test 通过
- ⚠️FILL 涉及的 cross-ref（README / methodology / STATUS）已联动更新

#### Stage 1.13 — Dogfood（可选，仅当抽象 / patch 涉及代码 path）

⚠️FILL：dogfood 验证形式（byte-identical 对比生产 / soft-equivalent self-test 注入 / 仅 import sanity / etc）。

非代码 sprint（纯文档 / template polish）→ 写"无 dogfood，下一 sprint 起草过程即下游 dogfood"。

#### Stage 4.B — Closeout（精简版）

输出：
- 8 项判据回填（见 §6）
- STATUS / CHANGELOG 更新
- retro 文档（含 D-route 资产盘点段）
- 衍生债登记
- 下一 sprint 候选议程建议

> 注意 §3.B 路径下 **无 Stage 2 / 3 / 5 编号**——这是精简模板的特性，不是 stages 缺失。retro / closeout 模板里不要硬填 "Stage 2 / 3" 行。

---

## 4. Stop Rules

> 详见 `framework/sprint-templates/stop-rules-catalog.md` 5 类模板。
> 至少列 5 条具体可触发的中止条件，每条含具体阈值。

1. ⚠️FILL `成本类`：例如 "Stage 2 cost > $X → Stop"
2. ⚠️FILL `数据正确性类`：例如 "任一 V invariant 回归 → Stop"
3. ⚠️FILL `输出量类`：例如 "新实体 > X → Stop"
4. ⚠️FILL `治理类`：例如 "review reject 率 > X% → Stop"
5. ⚠️FILL `跨 sprint 一致性类`：例如 "黄金集回归任一回归 → Stop"

---

## 5. 角色边界

| 角色 | 活跃度 | 主要职责 |
|------|-------|---------|
| 首席架构师 | 🟢/🟡/⚪ | ⚠️FILL |
| Domain Expert（⚠️FILL 角色名）| 🟢/🟡/⚪ | ⚠️FILL |
| 管线工程师 | 🟢/🟡/⚪ | ⚠️FILL |
| 后端 / 前端 / QA / DevOps / PM / Designer / Analyst | 🟢/🟡/⚪ | ⚠️FILL |

🟢 高 / 🟡 维护 / ⚪ 暂停。

> ⚠️ **Single-actor sprint 简化**（适用于纯文档抽象 / framework abstraction 类 sprint）：
> 如本 sprint 仅 Architect 主导，可仅列 1 行（Architect 🟢）并加注脚 "其余 9 角色全 ⚪ 暂停（不参与本 sprint）"，无需逐行填全。
> 实证：Sprint L / Sprint M 都是 single-actor sprint，整表 1 行 + 注脚足以。

---

## 6. 收口判定（Definition of Done）

至少列 5 条"sprint 算完成"的明确标准：

- ✅ ⚠️FILL
- ✅ ⚠️FILL
- ✅ ⚠️FILL
- ✅ ⚠️FILL
- ✅ ⚠️FILL

---

## 7. 节奏建议

⚠️FILL：哪些 stage 可在同一 session，哪些必须分 session；预估每 stage 工时。

---

## 8. D-route 资产沉淀预期（D-route 风格项目适用 — 详见 `framework/README.md` D-route 段；非 D-route 项目可删本节）

D-route 风格的项目（"框架抽象 + 参考实现"双轨）要求**每个 sprint 至少沉淀 1 项可被后续 sprint / 跨领域案例方复用的框架资产**，避免出现"纯案例完成度推进、对框架抽象 0 贡献"的 sprint。本节即对该规则做 sprint-level 自检。

本 sprint 预期沉淀以下框架抽象资产（**至少勾 ≥ 1 项**；若 0 项请回到 §1.1 重审 sprint 设计是否仅服务案例完成度）：

- [ ] 新增 `docs/methodology/*.md` 草案
- [ ] 已有 methodology 草案的 v0.x → v0.(x+1) 迭代
- [ ] 框架代码 spike（具体路径）
- [ ] 案例素材积累（retro 中标注 ≥1 个可抽象 pattern）
- [ ] 跨领域 mapping 表更新

> 本项目特定的不可变约束（如华典智谱 C-22 项目宪法）请在子 brief 中显式引用；模板本身不绑定具体项目宪法编号。

---

## 9. 决策签字

- 首席架构师：__ACK __日期 (待签)__
- 信号：本 brief 接受 + 用户 ACK 后 → Sprint Stage 0 启动

---

**本 brief 模板版本**：framework/sprint-templates v0.1.2

变更日志：
- v0.1 (Sprint L) — 初版
- v0.1.1 (Sprint M DGF-M-02~07 patch) — §3 加 Stage 0 inventory / §5 single-actor 注脚 / §8 跨域 mapping checklist 等
- **v0.1.2 (Sprint P 批 2 polish)** — §1.2 灵活列数说明 / §3 拆分 §3.A 5-stage 与 §3.B 精简模板 + §3.0 选择指南 / §8 措辞解耦 C-22 项目宪法专属性
