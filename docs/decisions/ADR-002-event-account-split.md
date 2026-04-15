# ADR-002: 事件双层建模（Event + EventAccount）

- **状态**：accepted
- **日期**：2026-04-15
- **提议人**：首席架构师（得历史专家 role 背书）
- **决策人**：首席架构师（用户已授权）
- **影响范围**：`events` 表、`event_accounts` 表、`account_conflicts` 表、前端事件详情页、管线 LLM 抽取流程
- **Supersedes**：v1 架构文档中单表 `events` 方案
- **Superseded by**：无

## 背景

同一历史事件在不同古籍中常常记载不一致。例如"鸿门宴"的座次、樊哙闯帐的细节、项羽"不杀刘邦"的动机——《史记·项羽本纪》《史记·高祖本纪》《汉书·高帝纪》的叙述存在冲突。

v1 架构将事件建模为单一 `events` 行，一个 `canonical_description`。这会导致：
- 必须在入库时选择"哪个版本是真的"——违反宪法 C-3（多源共存优于单源定论）
- 冲突信息丢失，无法支撑"史源对比"这一核心卖点
- 用户反馈"某细节不对"时无法定位到具体史源

## 选项

### 选项 A：保留单表 `events`，把多源内容压进 JSONB
- 优点：schema 改动小
- 缺点：冲突粒度（人物行为、时间、地点、对话）难以结构化查询；溯源链断裂

### 选项 B：Event（抽象锚）+ EventAccount（具体叙述）双层
- 优点：每个叙述可独立挂书/卷/段溯源；冲突可结构化标注；支持"时间线并列渲染"
- 缺点：schema 复杂度上升；管线需要"识别事件相同性"的消歧步骤

### 选项 C：只存最主要版本，冲突写在 feedback/notes
- 优点：最简
- 缺点：严重违反宪法；不支持商业化所需的"学术严谨"定位

## 决策

**选择 B：Event + EventAccount 双层建模**，并新增 `account_conflicts` 表显式标注冲突维度。

### 核心 schema（简述，完整见 `docs/02`）

```sql
-- Event：抽象锚，多叙述共同指向
events (
  id, slug, title_jsonb,
  time_period_start, time_period_end, time_precision,
  place_id (nullable),
  event_type, importance_score,
  created_at, updated_at
)

-- EventAccount：具体叙述，每本书/每段原文一条
event_accounts (
  id, event_id,
  book_id, volume, chapter, paragraph_id,
  narrative_jsonb,      -- {zh-Hans, zh-Hant, en} 文本
  quoted_text,          -- 原文片段
  participants JSONB,   -- [{person_id, role, action}]
  credibility_tier,     -- primary_text / scholarly_consensus / ...
  provenance_tier,
  source_book_tier      -- 史源本身的可信度
)

-- 冲突标注
account_conflicts (
  id, event_id,
  account_a_id, account_b_id,
  conflict_dimension,   -- participants / time / location / outcome / motivation
  description,
  resolution_tier       -- unresolved / scholarly_majority / ai_inferred
)
```

### 默认叙述选择规则（关联 U-02）

事件详情页的"默认展示"叙述由以下优先级决定（可被历史专家人工覆盖 `is_default=true`）：
1. `books.credibility_tier` 最高（如正史 > 野史）
2. `source_book_tier` 与事件时代最接近
3. `credibility_tier` 为 `primary_text` 优先

## 影响

- 正面：完全支持多源对比 UI；每个叙述独立溯源；用户反馈可定位到 account 级别
- 负面：管线必须跑"事件聚合"步骤（识别不同叙述指向同一事件）；前端详情页需要"时间线并列渲染"组件
- 迁移成本：起始决策，无迁移；后续一律按双层建模

## 回滚方案

不回滚。若管线聚合效果不佳，可退化为"每个 EventAccount 各自为战"（即 Event 层仅做 slug 聚合），schema 不需要改。

## 相关链接
- 任务卡：T-005（DB Schema）/ T-007（Pipeline MVP）
- 相关 ADR：ADR-001 / ADR-013（Mentions 与 Evidence 切分）/ ADR-U-002（U-02 默认叙述规则）
- 宪法条款：C-2 / C-3 / C-5
- 触发风险：F-01 ~ F-04（史源冲突）
