# ADR-005: Embedding 多槽位与模型切换策略

- **状态**：accepted
- **日期**：2026-04-15
- **提议人**：首席架构师
- **决策人**：首席架构师（用户已授权）
- **影响范围**：`entity_embeddings` 表、管线 embedding 步骤、API 语义检索 resolver
- **Supersedes**：无
- **Superseded by**：无

## 背景

Embedding 模型演进极快（BGE / E5 / GTE / OpenAI text-embedding / Voyage-3 / Cohere-v4 等），质量、维度、许可协议每半年一变。v1 架构把 embedding 作为单列 `vector(1536)` 绑死一个模型，带来两个风险：

1. 换模型需"全库重跑"，耗时耗钱
2. 过渡期内新旧模型并存检索不可能

## 选项

### 选项 A：单列 `vector(1536)` 绑死 OpenAI embeddings
- 优点：实现最简
- 缺点：无法切换；无法多模型并存

### 选项 B：独立 `entity_embeddings` 表，多槽位（一行一个模型）
- 优点：支持 N 个模型共存；切换只需新增行，旧行可软删除；不同维度共存（不同 `vector(N)` 用不同索引）
- 缺点：JOIN 开销；schema 略复杂

### 选项 C：JSONB 存 embeddings
- 优点：最灵活
- 缺点：无法建 HNSW 索引；性能不可接受

## 决策

**选择 B**。

### Schema

```sql
CREATE TABLE entity_embeddings (
  id BIGSERIAL PRIMARY KEY,
  entity_type TEXT NOT NULL,        -- 'person' / 'place' / 'event' / 'allusion' ...
  entity_id UUID NOT NULL,           -- errata 2026-04-16: BIGINT → UUID (all entity PKs are UUID)
  model_id TEXT NOT NULL,           -- e.g. 'voyage-3', 'bge-large-zh-v1.5'
  model_version TEXT NOT NULL,
  dimension INT NOT NULL,
  embedding vector(1024),           -- 多个维度用多张分表或 HALF-vec；见下
  content_hash TEXT NOT NULL,       -- 源文本 hash，用于失效检测
  created_at TIMESTAMPTZ DEFAULT NOW(),
  is_active BOOLEAN DEFAULT TRUE,
  UNIQUE (entity_type, entity_id, model_id, model_version)
);

-- 每维度一个 HNSW 索引（pgvector 要求列类型固定）
-- 方案：维度不同就分表 entity_embeddings_1024, entity_embeddings_1536
-- 或使用 pgvector 0.7+ 的 halfvec 类型混存（牺牲精度）
CREATE INDEX idx_ee_1024_hnsw ON entity_embeddings
  USING hnsw (embedding vector_cosine_ops)
  WHERE dimension = 1024;
```

### 模型切换流程

1. **注册新模型**：在 `config/embeddings.yml` 声明 `model_id / version / dimension / api_endpoint`
2. **影子期（2 周）**：管线同时跑新旧两模型，新模型写入但 `is_active=FALSE`
3. **A/B 对比**：数据分析师 role 出报告（Recall@10 / NDCG）
4. **切换**：QA + 架构师签字后，新模型 `is_active=TRUE`，旧模型保留 1 个月可回滚
5. **下线**：旧模型设 `is_active=FALSE`，3 个月后批量删除

### 检索路由

`services/api/src/services/search.ts` 读 `config/embeddings.yml` 的 `primary_model`，仅查 `is_active=TRUE` 且 `model_id = primary` 的行。影子期支持 `?embedding_model=xxx` query 参数手动指定。

### 初始模型选择

- **Phase 0**：`bge-large-zh-v1.5`（开源、中文、1024 维、可本地部署免 API 成本）
- **备选**：`voyage-3`（商用，质量 SOTA，延后评估）

## 影响

- 正面：模型可切换；支持 A/B；符合宪法 C-14（演进性保留）
- 负面：表行数是实体数 × 模型数；需要定期清理；多模型 API 成本管理
- 迁移成本：0（起始态）

## 回滚方案

单模型模式下，`entity_embeddings` 表仅含一条模型行，等价于单列方案。可无损退化。

## 相关链接
- 任务卡：T-005（DB Schema）/ T-007（Pipeline MVP，含 embedding step）
- 相关 ADR：ADR-001（pgvector 单库策略）/ ADR-010（Prompt 版本化，同样用"版本化而非覆盖"思想）
- 宪法条款：C-14

## Errata

### 2026-04-16: entity_id 类型修正

- **原文**：`entity_id BIGINT NOT NULL`
- **修正**：`entity_id UUID NOT NULL`
- **原因**：所有实体表（persons / events / places 等）主键为 UUID，entity_embeddings 引用它们时类型必须匹配。原文 BIGINT 为笔误。
- **发现者**：后端工程师（T-P0-002 架构师评审 Q-4）
- **影响**：仅文档修正，无代码迁移（T-P0-002 实施时已按 UUID 落地）
