# T-P0-025 — 字典加载器（persons.seed.json → DB）

- **状态**：backlog
- **优先级**：P0（α 后补，不阻塞 α）
- **主导角色**：管线工程师
- **依赖**：T-P0-023 Stage 1d（seed_dictionary enum，已 done）

## 背景

data/dictionaries/persons.seed.json 含 40 个精校人物（朝代 / 名 / 字 / 号 / 简介），目前仅静态存在于仓内，未入库。T-P0-023 扩了 provenance_tier.seed_dictionary 枚举值为此任务铺路。

## 目标

- 写 JSON → DB 加载器（新建 scripts/load_seed_dictionary.py 或 cli 子命令）
- 每条字典条目产出：persons 行 + person_names 行（primary + aliases） + source_evidences 行
- evidence 行 provenance_tier = seed_dictionary；llm_call_id = NULL；prompt_version = "seed/v1.0"；raw_text_id 留 NULL 或绑定字典文件的 blob hash（实施前做决策）

## 非目标

- 不涉及新 LLM 调用
- 不自动执行（人工触发的 admin 命令）

## 开放问题

1. evidence 行的 raw_text_id 策略（NULL vs 字典文件 hash 伪 raw_text）
2. 重跑时是 upsert 还是 skip（幂等性）
3. 字典 schema 是否需要在 JSON 侧固定（JSON Schema）

## Sprint 启动前动作

Pre-checkin：读现有 load.py / seed_dump.py；决定是否复用 _insert_person_names legacy path 还是另写专用 inserter（避免 NER 特有字段污染）。
