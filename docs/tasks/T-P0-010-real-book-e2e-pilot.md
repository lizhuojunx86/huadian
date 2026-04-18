# T-P0-010: Pipeline 基础设施建设 + 真书端到端 Pilot — 史记·本纪（前 3 篇）

- **状态**：in-progress
- **主导角色**：管线工程师
- **协作角色**：古籍/历史专家（质量抽检 + NER prompt review）
- **所属 Phase**：Phase 0
- **依赖任务**：T-P0-002 ✅（DB Schema）、T-P0-005 ✅（LLM Gateway）、T-TG-002 ✅（TraceGuard Adapter）、T-P0-004 批次 1 ✅（字典种子）
- **创建日期**：2026-04-18
- **性质**：Phase 0 pipeline 基础设施建设 + 首次真实数据 pilot 的复合任务。S-prep 1~8 属于 feat（首次实现），不是 chore；会在 CHANGELOG 独立记录。

---

## 目标（Why）

**双重目标**：
1. **建设管线基础设施**（S-prep）：从零实现 ingest / extract / load 全链路代码，补齐 CLAUDE.md §7 中规划但尚未实现的管线命令
2. **首次真实数据 pilot**（Phase A/B）：用史记·本纪前 3 篇跑完端到端，验证管线 + LLM 抽取 + TraceGuard + 审计的实际表现

预期会发现 bug — 那正是任务的意义所在。

---

## 书目选择（分阶段验收）

| Phase | 篇目 | 估计字数 | 成本上限 |
|-------|------|---------|---------|
| A (smoke) | 五帝本纪 | ~3k 字 | $5 |
| B (扩容) | 夏本纪 + 殷本纪 | ~7k 字 | $15 |
| C (不在本 session) | 周本纪及以后 | TBD | TBD |

**总预算上限**：$20（Phase A + B）
**单 chunk 成本 > $2 → 立即停止报错**

---

## 失败策略

- 单 chunk LLM 失败：退避重试 3 次（Gateway 内置）
- 仍失败：记录到 failure log，继续后续 chunk，不中断
- 整篇失败率 > 20% → 停止 Phase 推进，分析原因

---

## 持久化策略

- 抽取结果通过正常 pipeline 路径写入 DB（books / raw_texts / persons / person_names / identity_hypotheses）
- 同时 dump SQL seed 到 `services/pipeline/seeds/pilot-shiji-benji/{五帝,夏,殷}.sql`
- seed 可重放，方便复现和测试

---

## S-prep: 基础设施建设（feat，非 chore）

现状核查发现管线代码几乎为零（只有 ai/ 和 qc/ 子包），以下 8 个模块从零实现。

### S-prep-1: 修复 Python 模块导入
- **问题**：`uv run python -m huadian_pipeline.cli` 失败（`.pth` 文件存在但不被 Python 处理）
- **要求**：先 debug 根因，15 分钟内定位不到 → 简报给用户再继续
- **commit**：`fix(pipeline): fix Python module resolution for uv run`

### S-prep-2: ctext 数据源 adapter（最小版）
- **路径**：`services/pipeline/src/huadian_pipeline/sources/ctext.py`
- **数据文件**：`services/pipeline/fixtures/sources/shiji/` 目录（不放 src/）
  - 每个文件头部加注释：`# Source: https://ctext.org/shiji/wu-di-ben-ji` + 取用日期
- **功能**：从 fixtures 加载五帝本纪全文（硬编码避免网络依赖）
- **follow-up**：记录 T-P1-XXX（真正的 ctext adapter）到 T-000-index.md "已规划"区
- **commit**：`feat(pipeline): add ctext source adapter with shiji fixtures`

### S-prep-3: ingest 模块
- **路径**：`services/pipeline/src/huadian_pipeline/ingest.py`
- **功能**：
  - 接收 source adapter 输出
  - 写入 `books` 表（upsert by slug）
  - 写入 `raw_texts` 表（按段落拆分）
  - 记录 `pipeline_runs`
- **commit**：`feat(pipeline): add ingest module (books + raw_texts)`

### S-prep-4: NER prompt 模板 v1（高风险环节）
- **路径**：`services/pipeline/src/huadian_pipeline/prompts/ner_v1.md`（版本化文件，禁止硬编码在 Python 里）
- **加载器**：`services/pipeline/src/huadian_pipeline/prompts/loader.py`（读 .md → PromptSpec）
- **要求**：
  - Few-shot 举例从已知人物选（黄帝、舜、禹等五帝本纪角色）
  - 每次 extract 时把 prompt 版本号 + 文件 hash 写入 audit 表
  - Phase A 第一次跑真数据前，historian 角色先 review 这个 prompt（写评审意见记在本任务卡）
- **commit**：`feat(pipeline): add NER prompt template v1 (person extraction)`

### S-prep-5: extract 模块
- **路径**：`services/pipeline/src/huadian_pipeline/extract.py`
- **功能**：
  - 对每个 raw_text chunk 调用 LLM Gateway（走 PromptSpec + TraceGuard）
  - 解析 LLM JSON 输出为 Pydantic 模型
  - 去重 + 合并同人物
  - 写入 `extractions_history`
  - 成本累计追踪 + 超限报警
- **commit**：`feat(pipeline): add extract module (NER via LLM Gateway)`

### S-prep-6: validate + load 模块
- **路径**：`services/pipeline/src/huadian_pipeline/load.py`
- **功能**：
  - 校验抽取结果的 schema 合规性
  - slug 生成（name pinyin → slug）
  - 写入 `persons` / `person_names` / `identity_hypotheses` 表
  - upsert 逻辑（by slug，避免重复）
- **commit**：`feat(pipeline): add validate + load module (persons to DB)`

### S-prep-7: CLI 升级
- **路径**：修改 `services/pipeline/src/huadian_pipeline/cli.py`
- **功能**：
  - `huadian-pipeline ingest --book 五帝本纪` — 实际跑 ingest
  - `huadian-pipeline extract --book 五帝本纪 --steps ner` — 实际跑 NER 抽取
  - `huadian-pipeline pilot --book 五帝本纪` — 一键跑 ingest + extract + load
  - 成本追踪 + 进度输出
- **commit**：`feat(pipeline): upgrade CLI from stub to functional`

### S-prep-8: seed dump 工具
- **路径**：`services/pipeline/src/huadian_pipeline/seed_dump.py`
- **格式要求**：
  - 导出顺序稳定（按 slug 排序），重跑不产生 diff
  - 每个 INSERT 前加注释：`-- Extracted from 五帝本纪 §N (chunk_id)`
  - 文件头注释写清 prompt 版本、模型、抽取时间、总成本
- **commit**：`feat(pipeline): add seed dump utility`

---

## Phase A: 五帝本纪 smoke

### S-A1: ingest 五帝本纪
- 从 ctext adapter 加载五帝本纪全文
- 写入 `books` 表（slug: `shiji-wudi-benji`）
- 按段落拆分写入 `raw_texts` 表
- 记录 `pipeline_runs`（step: ingestion, status: success/failure）
- **commit**：`feat(pipeline): ingest 五帝本纪 raw text (N paragraphs)`

### S-A2: chunking 策略
- 按段落作为 chunk 单位（自然段落边界）
- 每段 > 2000 字则拆分（本篇预计无需）
- 生成 chunk 列表供 S-A3 消费

### S-A3: LLM extract（⚠️ 决策点：首次真实 API 调用前必须用户确认）
- 对每个 chunk 调用 AnthropicGateway.call() with NER prompt v1
- 记录每 chunk：tokens / cost / latency / TraceGuard 结果
- 累计成本追踪，接近 $5 时警报
- 单 chunk > $2 → 停止
- 写入 `llm_calls`（audit）+ `extractions_history`
- **commit**：`feat(pipeline): extract persons from 五帝本纪 (N tokens, $X.XX)`

### S-A4: validate + load
- 解析 LLM JSON 输出
- schema 校验（Pydantic）
- slug 生成 + 去重
- 写入 `persons` / `person_names` / `identity_hypotheses`
- **commit**：`feat(pipeline): load 五帝本纪 persons to DB (N persons, M names)`

### S-A5: seed dump
- 导出 SQL seed 到 `services/pipeline/seeds/pilot-shiji-benji/五帝.sql`
- **commit**：`feat(pipeline): seed dump 五帝本纪`

### S-A6: 质量抽检（historian 角色）
- 从 DB 随机抽 10 个 person
- 核对：姓名是否正确 / 朝代是否合理 / surface_form 是否在原文中出现
- 标注：correct / incorrect / uncertain
- 生成 `docs/reports/T-P0-010-phase-a-quality.md`
- **commit**：`docs(reports): T-P0-010 Phase A quality report`

### S-A7: Phase A 简报
- 汇报：成本 / 抽检结果 / 发现的问题
- 等用户点头再进 Phase B

---

## Phase B: 夏本纪 + 殷本纪 扩容

### S-B1~S-B6: 同 Phase A 流程
- 新书目：夏本纪（slug: `shiji-xia-benji`）、殷本纪（slug: `shiji-yin-benji`）
- 成本上限：额外 $15

### S-B7: 合并质量报告 + 趋势分析
- 错误模式是否稳定
- 准确率趋势
- **commit**：`docs(reports): T-P0-010 Phase B quality report`

---

## 收尾

### S-X1: 总结报告
- 编写 `docs/reports/T-P0-010-findings.md`
- 内容：成本实测 vs 预算 / 质量指标 / bug 清单 / 改进建议

### S-X2: STATUS / CHANGELOG 更新

### S-X3: CI 稳定验证

---

## LLM 配置

- 模型：`claude-sonnet-4-6`（AnthropicGateway 默认）
- Temperature: 0.0
- max_tokens: 4096
- 重试：3 次指数退避（Gateway 内置）

---

## 红线

- ⚡ 真实 API 调用会花钱 — 第一次发请求前必须用户确认
- 🚫 禁止 TRUNCATE llm_calls / extractions_history / pipeline_runs
- 🚫 禁止 DROP / ALTER TABLE
- 🚫 LLM 抽取质量 < 30% 正确率 → Phase A 完即停
- 🚫 单 chunk 成本 > $2 → 立即停止

---

## 决策点（必须停下来问）

1. 首次真实 API 调用前（S-A3 开跑前）
2. S-prep-1 如果 15 分钟定位不到根因
3. 发现 schema 不够用需要加字段（触发架构师 ADR）
4. NER prompt review 时 historian 角色觉得质量不够

---

## 质量不做数字 gate

生成报告即可，不设硬性 pass/fail 阈值。这是探索性任务。

---

## NER Prompt Review（historian 角色评审记录）

> _待 S-prep-4 完成后填写_

---

## Commit 风格

```
# S-prep（每项独立 commit，约 8 个）
fix(pipeline): fix Python module resolution for uv run
feat(pipeline): add ctext source adapter with shiji fixtures
feat(pipeline): add ingest module (books + raw_texts)
feat(pipeline): add NER prompt template v1 (person extraction)
feat(pipeline): add extract module (NER via LLM Gateway)
feat(pipeline): add validate + load module (persons to DB)
feat(pipeline): upgrade CLI from stub to functional
feat(pipeline): add seed dump utility

# Phase A（约 6 个）
feat(pipeline): ingest 五帝本纪 raw text
feat(pipeline): extract persons from 五帝本纪
feat(pipeline): load 五帝本纪 persons to DB
feat(pipeline): seed dump 五帝本纪
docs(reports): T-P0-010 Phase A quality report

# Phase B（约 6 个）
feat(pipeline): ingest + extract + load 夏本纪 + 殷本纪
docs(reports): T-P0-010 Phase B quality report

# 收尾
docs(reports): T-P0-010 findings summary
docs: update STATUS, CHANGELOG for T-P0-010
```
