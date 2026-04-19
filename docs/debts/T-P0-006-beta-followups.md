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

## F3: `persons` 缺 merged_into_id ↔ deleted_at CHECK 约束 — ~~P2~~ **resolved 2026-04-19** (commit c43aaf9)

- **修复**：`ALTER TABLE persons ADD CONSTRAINT persons_merge_requires_delete CHECK (merged_into_id IS NULL OR deleted_at IS NOT NULL)`
- CHECK 约束采用单向蕴涵版本（原双向等价会误伤 T-P0-014 R3-non-person 的 5 行 pure soft-delete）。详见 ADR-010 Supplement 2026-04-19
- V1-V5 invariant 全 PASS；Drizzle schema 同步

## F4: "active" 定义统一 — ~~P2~~ **resolved 2026-04-19** (via F3 CHECK, commit c43aaf9)

- **修复**：F3 CHECK 约束的逆否命题 `deleted_at IS NULL → merged_into_id IS NULL` 保证 `{deleted_at IS NULL}` 与 `{deleted_at IS NULL AND merged_into_id IS NULL}` 严格等价
- "active = deleted_at IS NULL" 现在是唯一定义，有 DB 约束背书

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

## F10: α merge source primary 未 demote — ~~P1-followup~~ **resolved 2026-04-19** (commit 7bfb287)

- **修复**：Migration 0005 批量 `UPDATE person_names SET name_type='alias'` 8 行（调研 memo §C4 预估 ≥2 行，实际 8 行覆盖全部 α merge source 残留）
- 8 行分布：7 行 primary/is_primary=true + 1 行 primary/is_primary=false（cheng-tang）
- is_primary 联动未处理，遗留给 T-P0-016（当前 alias+is_primary=true 计 18 行）
