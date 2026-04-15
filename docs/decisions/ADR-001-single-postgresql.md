# ADR-001: 单 PostgreSQL 数据库策略（含未来切出触发器）

- **状态**：accepted
- **日期**：2026-04-15
- **提议人**：首席架构师
- **决策人**：首席架构师（用户已授权）
- **影响范围**：整体技术栈、数据层、DevOps 运维、成本结构
- **Supersedes**：无
- **Superseded by**：无

## 背景

华典智谱需要同时承载：
1. 结构化实体数据（人、地、事、关系、典故等 8 类）
2. 全文检索（中文分词 + trigram 模糊）
3. 向量检索（Embedding 语义相似）
4. 地理查询（点/线/面 + 空间关系）
5. 审计与版本（llm_calls / extractions_history / entity_revisions）

主流选项包括：独立 Elasticsearch + 独立 Vector DB（Pinecone/Weaviate）+ 独立 PostGIS；或统一在 PostgreSQL 16 上用扩展实现。

## 选项

### 选项 A：PostgreSQL 16 + pgvector + PostGIS + pg_trgm 单库
- 优点：单一备份恢复路径；事务一致性（实体与 embedding 同步写入）；DevOps 成本极低；开发阶段心智负担小；pgvector 在 <500 万向量下性能足以支撑到 Phase 3
- 缺点：千万级向量检索延迟会上升；全文检索精度弱于 ES 的 ik 中文分词

### 选项 B：PostgreSQL + Elasticsearch + Qdrant/Weaviate
- 优点：各组件最佳实践；可水平扩展
- 缺点：三份数据同步（CDC 或双写）带来一致性隐患；DevOps 成本高；早期阶段严重过度设计

### 选项 C：PostgreSQL + 外挂 Meilisearch（轻量检索）
- 优点：部署简单；中文检索改善
- 缺点：仍引入双写；当前阶段优先级低

## 决策

**选择 A：单 PostgreSQL 16 + pgvector + PostGIS + pg_trgm**，并预留"切出触发器"（trigger-to-split）。

**切出触发器**（任一项命中即启动 ADR 评审是否切出独立组件）：
1. 任一向量表行数 > 500 万 **且** HNSW 查询 p95 > 300ms
2. 全文检索 p95 > 1s 且 pg_trgm + 词典调优后未改善
3. 空间查询 QPS > 200 **且** 单表地理行数 > 100 万
4. 单库 WAL 累积 > 50GB/天 影响备份窗口
5. DB 单机 CPU > 70% 连续 7 天

触发后的评估顺序：先垂直扩容 → 只读副本 → 分区表 → 最后才切出独立组件。

## 影响

- 正面：Phase 0~3 可在 docker-compose 下一键起；备份即 `pg_dump`；开发可本地复制生产
- 负面：Phase 4 若用户量暴涨，可能需要做搜索/向量切出；但届时架构已稳定，切出风险可控
- 迁移成本：0（这是起始态）

## 回滚方案

不适用（起始决策）。未来若触发切出，走新 ADR。

## 相关链接
- 任务卡：T-004（Monorepo 骨架）/ T-005（DB Schema）
- 相关 ADR：ADR-005（Embedding 多槽位）/ ADR-015（软删除）/ ADR-011（地理建模）
- 宪法条款：C-1 / C-13
