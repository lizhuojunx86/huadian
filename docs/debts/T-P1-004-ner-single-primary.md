# T-P1-004: NER 阶段单人多 primary 约束

- **优先级**：P1
- **登记日期**：2026-04-19
- **来源**：T-P1-002 S-5 衍生债

## 现象

NER prompt v1/v1-r2 对同一 person 产出多个 `name_type='primary'` 的 name。
例如 LLM 将"尧"和"放勋"都标为 primary（实际上"放勋"是 birth name / alias）。

T-P1-002 通过 backfill 修正了已有数据（14 active persons），但未修改 NER prompt，
下次 ingest 新书时同样的问题会再次发生。

## 根因

NER prompt 中对 `name_type` 的约束不够精确：
- 没有明确说明每个 person 只能有 1 个 primary
- 没有给出 primary vs alias vs nickname 的选择规则

## 修复方向

1. **Prompt 约束**：在 NER prompt 中添加硬约束：
   - "每个 person 恰好 1 个 name_type=primary（正式本名），其余为 alias/nickname/etc"
   - 给出选择规则：最常见的单字/双字称呼为 primary

2. **Load 层校验**：`load.py` upsert 前检查：如果 person 已有 primary，
   新 name 降级为 alias（防御性兜底）

3. **DB 约束（可选）**：考虑在 person_names 上添加 partial unique index：
   `CREATE UNIQUE INDEX ON person_names (person_id) WHERE name_type='primary'`
   — 保证每个 person 最多 1 个 primary

## 影响

- 不阻塞当前功能
- 下次 ingest（T-P0-006 周本纪）前应修复
- 不修复的后果：每次 ingest 后需要手动重跑 backfill
