# Sprint H Brief — T-P0-031 楚怀王 entity-split + T-P1-028 R1 dynasty 前置过滤

## 0. 元信息

- **架构师**: Chief Architect
- **Brief 日期**: 2026-04-26
- **Sprint 形态**: 双 track 架构创设（首次 entity-split + R1 改进）
- **预估工时**: 3-4 天
- **PE 模型**: **Opus 4.6**（架构创设 sprint，不用 Sonnet）
- **触发事件**: Sprint G 发现"楚怀王" entity 在两个相隔 ~90 年的不同人之间错误共享 + Sprint G 21 组 merge proposals 中 13 组（62%）是 R1 跨国 surface match 假阳性

## 1. 背景

Sprint G 暴露 R1 surface match 在跨时段同号场景下的两类问题：

**问题 1**：当前数据已存在 entity-level 错误共享（楚怀王 = 战国熊槐 + 秦末熊心 在同一 entity 上）→ T-P0-031
**问题 2**：每次 ingest 都产生大量"跨国同名"假阳性提案，依赖 historian 人工 reject → T-P1-028

两问题互补：T-P1-028 防未来（结构性 guard），T-P0-031 修当下（数据校正）。同 sprint 推进可一次看清 R1 改进的设计空间。

## 2. 目标范围

### 必做
1. **T-P1-028**：R1 surface match 之前增加 dynasty 前置过滤（同 surface name + dynasty 显著不同 → 不进入 R1 候选，写入 pending_merge_reviews 或新通道）
2. **T-P0-031**：楚怀王 entity 数据修正——拆分为"战国楚怀王熊槐"（保留现有 entity）+"秦末楚怀王熊心"（已在 Sprint G G13 子合并产出），将所有项羽本纪 mentions 从前者迁移到后者
3. ADR-025（候选）：R1 dynasty 前置过滤的设计原则（如果改动够大）
4. V1-V11 全绿不回归 + V12 候选评估（cross-time entity-collision invariant）

### 不做
- ❌ 不做 R2-R5 的同类改进（本 sprint 仅 R1）
- ❌ 不做 entity-split 工具化（手工脚本完成楚怀王单点即可，未来类似 case 累积 ≥2 例再考虑工具化）
- ❌ 不做内容续推（Sprint I/J 才推高祖本纪）

## 3. Stages

### Stage 0 — 联合 inventory（两 track 共同基础，2-4 小时）

PE 调研项：
1. **R1 当前实现**：score_pair.py 中 R1 函数定义 / surface match 逻辑细节 / 是否已有任何 dynasty-aware 字段读取
2. **dynasty 字段成熟度**：persons.dynasty 100% 覆盖（Sprint D 已确认），但 dictionary_entries / pending_merge_reviews 是否需要新字段？
3. **dynasty 距离判定逻辑**：复用 r6_temporal_guards.py 的 dynasty mapping 还是新建？（强烈建议复用避免双源真相）
4. **楚怀王 entity 数据扫描**：
   - 现有 entity 关联的 mentions 总数
   - 按章节分桶（哪些来自秦本纪 / 周本纪 / 项羽本纪 等）
   - 哪些 mention 应迁移给熊心 entity（秦末上下文）
   - 哪些保留给熊槐 entity（战国上下文）
5. **R1 跨国 FP 历史扫描**：
   - 用历史 dry-run 数据估算"R1 dynasty 前置过滤"如启用早可避免多少 historian 工作量
   - 对秦本纪 / 项羽本纪两章数字化估算
6. **mention redirect 机制现状**：
   - 系统是否有现成的"mention 迁移"接口？还是需要直接 SQL UPDATE 关联表？
   - 哪张表存 mention（surface_forms? person_names? source_evidences? extractions?）

输出：docs/sprint-logs/sprint-h/inventory-2026-04-26.md

### Stage 1 — T-P1-028 R1 dynasty 前置过滤设计 + ADR-025

1.1 设计选项（基于 Stage 0 调研）：
   - α：R1 函数内部加 dynasty 前置 short-circuit（最简，硬编码距离阈值）
   - β：抽象出 evaluate_pair_guards(person_a, person_b) 通用接口，dynasty filter 是其中一个 guard，未来 R2-R5 可复用
   - γ：R1 输出后增加 post-filter 层

架构师默认倾向：**β**（与 r6_temporal_guards 同 pattern，避免每个 R 规则都重复 dynasty 判断逻辑）

1.2 阈值设计：
   - 阈值起点：dynasty midpoint 距离 > 200 年（比 R6 的 500 年严格——因为 R1 surface match 是更弱的证据基础）
   - 阈值由 Stage 0 历史数据观察确定

1.3 ADR-025 起草（如选 β）：
   - "R Rule Pair Guards — 通用 pair-level guard 接口"
   - 参考 ADR-022/023 结构

1.4 PE 完成 1.1-1.3 后报架构师签字，再进 Stage 2

### Stage 2 — T-P1-028 实施

2.1 实现 evaluate_pair_guards（如选 β）+ R1 集成
2.2 dynasty mapping 复用 r6_temporal_guards.py（不重建数据源）
2.3 命中 guard 的 R1 候选写入 pending_merge_reviews（新 guard_type='r1_cross_dynasty'）
2.4 单元测试 ≥5：
   - guard 命中场景（构造跨 dynasty 同 surface 案例）
   - guard 不命中场景（同 dynasty 同 surface 应继续走 R1）
   - dynasty mapping 复用正确
   - V11 回归测试
   - 边界：dynasty 字段缺失时 fallback 行为
2.5 dry-run 跑一次秦本纪 + 项羽本纪现有数据，验证 guard 拦截数与 Stage 0 历史扫描预测一致

### Stage 3 — T-P0-031 楚怀王 entity-split 实施

3.1 手工 SQL 脚本 ops/scripts/one-time/split_chu_huai_wang_entity.py：
   - 逻辑：从现有"楚怀王"entity 上分离秦末上下文 mentions
   - 决策依据：根据 Stage 0 §4 mention 分桶清单
   - 安全约束：单事务 + dry-run 模式 + 跑后 V1-V11

3.2 mention 迁移目标：迁移到 Sprint G G13 子合并已建立的"楚怀王熊心"entity（canonical=熊心）

3.3 跑 dry-run，输出 docs/sprint-logs/sprint-h/chu-huai-wang-split-dry-run.md
- 列出每条 mention 的迁移决策
- 等架构师 + historian 联合 ACK 后才 apply

3.4 apply：单事务 + V1-V11 全跑

### Stage 4 — V12 候选评估 + 验证 + 收档

4.1 V12 invariant 候选：
- "无 entity 包含跨 ≥500 年的 mentions"
- 评估实施可行性（需要 mention timestamp 字段）
- 如可行 → 起草 V12 SQL + ADR；如不可行 → 退路：登记为 backlog risk
- 不强制本 sprint 落地 V12，评估即可

4.2 重新跑 dry-run 秦本纪 + 项羽本纪，验证：
- T-P1-028 guard 在新场景命中（应可见拦截日志）
- T-P0-031 修复后楚怀王 entity 状态正确（cross-chapter mention 列表干净）
- V1-V11 全绿

4.3 收档：
- T-P0-031 task card 状态 done，回填 commit hashes
- T-P1-028 task card 状态 done
- ADR-025 finalize（如选 β 路径）
- STATUS / CHANGELOG / Sprint H retro
- 衍生债登记（如有）

## 4. Stop Rules

1. **Stage 0 调研发现 R1 实现与文档严重不符** → Stop，单独诊断
2. **Stage 0 楚怀王 mention 分桶发现需要 historian 二次裁决**（如某 mention 上下文模糊） → Stop，切 historian 会话
3. **Stage 1 设计选型与架构师 β 倾向不一致** → Stop 报架构师签字
4. **Stage 2 dry-run guard 拦截数远超 Stage 0 预测**（>2x） → Stop，意味着阈值或 dynasty mapping 有 bug
5. **Stage 3 mention 迁移影响 source_evidences 关联** → Stop，evidence 链是数据正确性核心，不能误伤
6. **任一 V invariant 回归** → 立即 Stop
7. **V12 评估发现需要 schema 变更**（如新增 mention timestamp 字段） → Stop，不在本 sprint 实施

## 5. 角色边界

| 角色 | 职责 |
|------|------|
| 管线工程师（Opus） | Stages 0-4 全部 |
| 架构师 | 本 brief + Stage 1 设计签字 + ADR-025 起草签字 + Stage 3 dry-run 联合 ACK + V12 设计裁决 |
| Historian | Stage 0 §4 mention 分桶复核（如需）+ Stage 3 mention 迁移联合 ACK |
| 后端工程师 | Stage 1 如涉及 schema 变更（V12 字段）则 consult |

## 6. 收口判定

- ✅ T-P1-028 R1 dynasty 前置过滤上线 + 5+ 单元测试 + dry-run 验证
- ✅ T-P0-031 楚怀王 entity 数据修复完成 + mention 迁移正确
- ✅ V1-V11 全绿
- ✅ ADR-025 落地（如选 β 路径）
- ✅ V12 候选评估报告（落地 or backlog 决定）
- ✅ Sprint G 暴露的 R1 跨国 FP 数量在新 dry-run 中显著降低

## 7. 节奏建议

- 第一会话：Stage 0 inventory + Stage 1 设计 → 挂起等架构师 ADR-025 签字
- 第二会话：Stage 2 T-P1-028 实施 + Stage 3 T-P0-031 dry-run → 挂起等联合 ACK
- 第三会话：Stage 3 apply + Stage 4 验证收档

不要在一个会话内塞 entity-split 数据修复——这是不可逆操作，需要架构师 + historian 双 ACK。
