# ADR-012: NER Single-Primary Constraint

- **状态**：accepted
- **日期**：2026-04-19
- **决策者**：用户（产品负责人）+ 管线工程师
- **关联任务**：T-P1-004

## 背景

T-P1-002 发现 19 个 canonical group 有多个 `name_type='primary'`，其中 14 个来自 NER
抽取阶段（LLM 对同一 person 输出多个 primary），3 个来自 merge 未降级。

T-P1-002 通过 backfill 修复了历史数据（17 行 primary→alias），并在 `resolve.py` 中
添加了 merge 时自动降级。但 NER prompt 本身未修改——下次 ingest 新书会再产生同样问题。

### 冲突类型分布

| 类型 | 数量 | 典型案例 |
|------|------|---------|
| 本名 + 字/号 | 4 | 尧/放勋、舜/重华、禹/文命、颛顼/高阳 |
| 本名 + 帝X | 6 | 南庚/帝南庚、沃甲/帝沃甲 |
| 全称 + 简称 | 3 | 微子启/微子/启、比干/王子比干 |
| 通假/异体/多称谓 | 3 | 倕/垂、汤/商汤/天乙 |

## 决策

**三层防御：NER prompt 硬约束 + ingest 校验兜底 + QC 规则检测**

### 层 1：NER Prompt 硬约束

在 `ner_v1.md` 中新增显式规则段落：

```
## name_type 唯一性约束（严格）

每个 person 的 surface_forms 中**恰好 1 个** name_type='primary'。违反此规则的输出无效。

选择 primary 的优先级：
1. 该人物最通行的单独称谓（如"尧"而非"放勋"，"禹"而非"文命"）
2. 与 name_zh 一致的那个 surface_form
3. 最短、最常出现的名字
4. 不确定时，选 name_zh

其余 surface_forms 的 name_type 按实际语义标注：
- 帝X → nickname
- 字/号 → courtesy / art / alias
- 敬称/全称 → nickname
- 通假字/异体字变体 → alias
```

附带 few-shot 反例，覆盖 4 类冲突模式。

### 层 2：Ingest 校验（load.py）

`_insert_person_names()` 在插入前校验 + 自动降级：

1. 统计 `surface_forms` 中 `name_type='primary'` 的数量
2. 若 >1：保留与 `name_zh` 匹配的那个为 primary（帝X 通过 `is_di_honorific` 排除），其余降级为 alias
3. 若 =0 且 name_zh match 存在：提升 name_zh match 为 primary
4. 若 =0 且无 name_zh match：提升最短 surface_form 为 primary（WARNING 级，指示 NER 质量退化）
5. 每次降级/提升都 `logger.warning`，便于事后追查

策略选择：**auto-demotion + warn**（非 raise/skip），理由：
- 一个 person 的 name_type 错误不应阻断整本书 ingest
- warn log 保证可观测性（case 4 额外标记 "CRITICAL" 以区分严重程度）
- 降级规则确定性（name_zh match → `is_di_honorific` 过滤），不会误改

### 层 3：QC 规则

新增 `ner.single_primary_per_person` 规则到 `ner_rules.py`（severity=major），
在 TraceGuard checkpoint 层检测 LLM 输出是否有多 primary 或 0 primary。
与层 2 的 auto-demotion 互补：层 3 检测问题，层 2 修正问题。

### 层 4：共享帝X检测（`is_di_honorific`）

从 `resolve_rules.py` 抽取 `is_di_honorific()` 共享函数，被 `has_di_prefix_peer()`
和 `_enforce_single_primary()` 共用。避免帝X判定逻辑重复实现。

### 不实施：DB Partial Unique Index

**评估结论：暂不添加 `CREATE UNIQUE INDEX ON person_names (person_id) WHERE name_type='primary'`**

理由：
- NER prompt + ingest 校验两层已足够防止再生
- partial unique index 要求所有写入路径都遵守（包括手动 SQL、future 迁移），约束过强
- 现有 `UNIQUE (person_id, name)` 已防止同名重复
- 登记为 T-P1-004-followup，如后续发现仍有泄漏再启用

## 后果

### 正面
- "每 person 最多 1 primary" 成为管线不变量
- 新书 ingest 无需 backfill
- prompt 退化可通过 warn log 发现

### 负面
- prompt 修订增加 token 消耗（约 +200 tokens/call，成本影响 <1%）
- auto-demotion 可能掩盖 prompt 质量退化（通过 warn log 缓解）

### 风险
- prompt cache 失效：版本号升级（v1-r3），旧 cache 按旧版本 key 保留，不受影响
- auto-demotion 规则可能不适用于极端边界（如未来新增的 name_type 枚举值）
