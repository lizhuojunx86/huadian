# T-P1-004: NER 阶段单人多 primary 约束 — RESOLVED

- **优先级**：P1
- **登记日期**：2026-04-19
- **解决日期**：2026-04-19
- **来源**：T-P1-002 S-5 衍生债
- **解决方案**：ADR-012（三层防御：NER prompt 硬约束 + ingest auto-demotion + QC 规则）

## 现象

NER prompt v1/v1-r2 对同一 person 产出多个 `name_type='primary'` 的 name。
例如 LLM 将"尧"和"放勋"���标为 primary（实际上"放勋"是 birth name / alias）。

T-P1-002 通过 backfill 修正了已有数据（14 active persons），但未修改 NER prompt，
下次 ingest 新书时同样的问题会再次发生。

## 根因

NER prompt 中对 `name_type` 的约束不够精确：
- 没有明确说明每个 person 只能有 1 个 primary
- 没有给出 primary vs alias vs nickname 的选择规则

## 修复（ADR-012）

1. **NER prompt v1-r3**：添加 `## name_type 唯一性约束（严格）` 段落 + 反例 few-shot
2. **load.py `_enforce_single_primary()`**：auto-demotion + warn（4 种 case 全覆盖）
3. **QC 规则 `ner.single_primary_per_person`**：severity=major，在 TraceGuard 层检测
4. **共享 `is_di_honorific()`**：从 `resolve_rules.py` 抽取，帝X 判定复用

## 验证

- 250 pipeline + 61 api + 55 web tests 全绿
- ruff 0 / basedpyright 0/0/0
- 32 new tests（load validation 18 + QC rule 8 + is_di_honorific 6）
