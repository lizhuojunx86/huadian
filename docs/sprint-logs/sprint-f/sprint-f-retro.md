# Sprint F Retrospective — V1 根因修复 + 衍生债批清理

> **Sprint**: F
> **日期**: 2026-04-25
> **角色**: 管线工程师（执行）+ 首席架构师（brief + ACK + ADR-024）
> **触发**: Sprint E 收口 V1=94 线性增长不可接受

---

## 1. Sprint 摘要

| 指标 | Sprint E 收口 | Sprint F 收口 | 变化 |
|------|-------------|-------------|------|
| V1 (name_type) | 94 | **0** | -94 ✅ |
| V1 (is_primary) | 33 | **0** | -33 ✅ |
| V9 | N/A | **0 (新增)** | 金标准 ✅ |
| V6 | 0 | 0 | 不回归 ✅ |
| V10 | 0/0/0 | 0/0/0 | 不回归 ✅ |
| V11 | 0 | 0 | 不回归 ✅ |
| Active persons | 556 | **555** | -1 (重耳 merge) |
| Merge log | 82 | **83** | +1 |
| Tests | 317 | **317** | +3 V9 + 3 Stage 1 (skipped) |
| ADRs | 23 | **24** (ADR-024) | +1 |
| LLM cost | — | **$0.163** | v1-r5 验证 |

## 2. What Went Well

### 2.1 根因定位清晰
Stage 0 诊断 2 小时内锁定根因 100% 在 load.py `_insert_person_names`，两个独立 bug（name_type 默认值 + is_primary 硬编码 false）。没有 NER 或 merge 层的责任。这让 Stage 1 修复非常精准（~15 行改动）。

### 2.2 V9 invariant 防御到位
V1（上界 ≤1）+ V9（下界 ≥1）= 完整的 exactly-one-primary 语义。加上 load.py S1.3 函数级 guard（RuntimeError），形成三层防御。

### 2.3 衍生债批处理效率高
4 张衍生债卡（T-P1-024/025/026/T-P2-004）在 2 个会话内全部 close。其中 T-P1-024/026 在第一会话并行完成，T-P1-025 走 textbook-fact 快速路径。

## 3. Best Practices (新增)

### 3.1 textbook-fact merge 路径
T-P1-025（重耳↔晋文公）建立了"textbook-fact"类 merge 的简化流程：

**三条件直签**（满足全部则可走架构师直签，不需 historian 会话）：
1. 单一权威史源明文（《史记》本纪/世家/列传 直接陈述）
2. 无歧义 / 无通假字 / 无多源争议
3. 影响范围 ≤ 1 pair

不满足任一条件 → 仍走 historian 审核通道。

**新 merge_rule 值**: `manual_textbook_fact`（与 R1/R2/R3/R4/R5/R6/historian_correction 并列）。
当同类 textbook merge 累积 ≥3 例时，在 ADR-014 addendum 中正式登记 rule taxonomy。

### 3.2 name_zh ≠ surface_form 模式识别
Sprint F 发现 NER 输出中 name_zh 经常不在 surface_forms 中（朝代前缀、官衔+名 等），这是古籍 NER 的结构性特征。load.py 修复后正确处理此模式（name_zh 作为 canonical primary，NER primary 降为 alias）。

## 4. What Could Be Better

### 4.1 V1 定义模糊
V1 历史上定义为"name_type='primary' count"还是"is_primary=true count"没有明确文档。Sprint E 报 V1=94 实际是 name_type 维度，但 T-P1-022 描述的是 is_primary 维度。Sprint F 同时修复了两个维度，避免了未来混淆，但定义应在 ADR-024 中明确。

### 4.2 v1-r5 CRITICAL 指标定义需细化
v1-r5 dry-run 显示 4 个 CRITICAL auto-promotion，但其中 3 个是朝代前缀模式（安全，load.py 正确处理）。"CRITICAL auto-promotion"指标应区分：
- **真正 CRITICAL**：NER 输出质量问题导致数据不正确
- **结构性 promotion**：name_zh ≠ surface_form 是预期行为，load.py 正确处理

### 4.3 黄金集形式化缺失
"黄金集回归"目前无形式化测试文件。v1-r5 验证依赖推理论证（v1-r5 是 v1-r4 严格超集 + 新规则只对战国秦制模式生效）。Sprint G 应考虑建立形式化 NER 黄金集 fixture。

## 5. Commits

| # | Hash | 内容 |
|---|------|------|
| C18 | 18a3229 | docs: Stage 0 V1 root cause diagnosis |
| C19 | c3f98f1 | data: T-P1-024 tongjia (缪/穆 + 傒/奚) |
| C20 | 9dcda8f | data: T-P1-026 disambig_seeds (10 组) |
| C21 | acc9451 | fix: Stage 1 load.py V1 root cause fix |
| C22 | f21991c | chore: Stage 2 V1 backfill 94→0 |
| C23 | 5f90d4e | feat: Stage 3 V9 invariant + ADR-024 |
| C24 | bdb8941 | fix: T-P1-025 chong-er merge |
| C25 | ff889e0 | feat: T-P2-004 NER prompt v1-r5 |
| C26 | (pending) | docs: Sprint F closeout |

## 6. Closed Debt

| Task | 描述 | 结果 |
|------|------|------|
| T-P1-022 | V1 下界缺失 | Stage 1 fix + Stage 2 backfill + V9 invariant |
| T-P1-024 | tongjia 缪/穆 + 傒/奚 | 2 条新增 + 2 tests |
| T-P1-025 | 重耳↔晋文公 merge | textbook-fact merge (555 active) |
| T-P1-026 | disambig_seeds 跨国同名 | 19 条 / 8 新组 |
| T-P2-004 | NER v1-r5 | 官衔+名规则 / 5→1 CRITICAL |
