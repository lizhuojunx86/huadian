# T-P0-006-β Followup Debts

> Consolidated from β 路线《尚书·尧典 + 舜典》ingest (2026-04-19).
> Each item tagged with priority and triggering context.

---

## F1: DB 存量 pronoun pollution — **P2**

- **现状**：yao 和 shun 的 person_names 含单字 `帝`（α 路线遗留）
- **影响**：搜索"帝"会返回 yao/shun（语义错），但 R1 stop words 已拦截 merge 误触
- **扫描 SQL**：
  ```sql
  SELECT pn.person_id, p.slug, pn.name
  FROM person_names pn JOIN persons p ON p.id = pn.person_id
  WHERE pn.name IN ('帝','王','后','公','君','主','上','天子')
    AND p.deleted_at IS NULL;
  ```
- **修复**：soft-delete 这些 alias 行，保留审计

## F2: "伯" split-danger — **P3**

- **现状**：伯夷 新增 surface `伯(alias)`（v1-r4 拆分）
- **影响**：当前无误合并风险（其他 person 无单独"伯" surface），但周本纪/秦本纪扩量时可能撞 伯禽/伯邑考/伯益
- **建议**：不加入 `_PRONOUN_BLACKLIST`（会杀掉合法省称），改用 load 层 prefix-containment 检测

## F3: `persons` 缺 merged_into_id ↔ deleted_at CHECK 约束 — **P2**

- **现状**：T-P0-015 帝鸿氏 partial-merge bug 暴露 schema 无强制约束
- **修复 SQL**：
  ```sql
  ALTER TABLE persons ADD CONSTRAINT persons_soft_merge_paired
    CHECK ((merged_into_id IS NULL) = (deleted_at IS NULL));
  ```
- **注意**：需先清理 F10（α merge source primary 未 demote），否则 CHECK 可能与其他治理冲突

## F4: "active" 定义统一 — **P2**

- **现状**：resolver 用 `deleted_at IS NULL`，部分统计用 `merged_into_id IS NULL AND deleted_at IS NULL`
- **修复**：ADR-010 补充 "active = deleted_at IS NULL" 为唯一定义（配合 F3 CHECK 约束，两定义等价）

## F5 / F11: is_primary 不跟 name_type 同步 demote — **P0-followup**

- **现状**：`apply_merges()` 只改 `name_type = 'alias'`，不改 `is_primary = false`
- **影响**：GraphQL 返回 `nameType=alias + isPrimary=true` 语义矛盾（用户可见 UX 问题）
- **裁决预案**：
  - 方案 Y（倾向）：`apply_merges()` 同时设 `is_primary=false`
  - 方案 X：read 层 `findPersonNamesWithMerged` 对 non-canonical 强制 `isPrimary=false`
- **待开**：T-P0-016

## F8: person_names.source_evidence_id 全表 NULL — **P0-followup**

- **现状**：Phase 0 `load.py` 不填 evidence FK，282/282 行全 NULL
- **影响**：name 无法溯源到抽取原文，挑战"一次结构化 N 次衍生"宪法
- **待开**：ADR-015 或 T-P0-020 专项
- **状态（2026-04-19）**：ADR-015 已 accepted（渐进式三阶段）。Stage 1 → T-P0-023；Stage 2 → T-P0-024；Stage 3 延后至 α 后。

## F9: extract_persons() NER 输出不落盘 — **P1-followup**

- **现状**：`extract_persons()` 仅返回内存对象，无磁盘持久化
- **影响**：无法 replay load.py（β 弃重建踩坑）、无法离线 A/B prompt 迭代、无法提供 historian 黄金集对比样本
- **建议**：extract 完成后 dump JSONL 到 `services/pipeline/outputs/ner/{run_id}.jsonl`

## F10: α merge source primary 未 demote — **P1-followup**

- **现状**：hou-ji 聚合里 α 旧行 u5f03 的 `name_type='primary'` 未被 demote
- **待验证**：扫 α 12 条 merge 的 source person_names，统计 `name_type='primary'` 残留数
- **修复**：补丁 SQL 批量 `UPDATE name_type='alias' WHERE person_id IN (merged sources) AND name_type='primary'`
