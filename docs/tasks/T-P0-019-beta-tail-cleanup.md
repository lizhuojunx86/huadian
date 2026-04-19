# T-P0-019: β 尾巴清理（F1 / F2 / F4 合并）

- **状态**：planned
- **主导角色**：管线工程师
- **协作角色**：后端工程师（API 行为验证）
- **所属 Phase**：Phase 0
- **关联 debt**：F1 / F2 / F4（`docs/debts/T-P0-006-beta-followups.md`）
- **创建日期**：2026-04-19

## 背景

T-P0-006-β followups 中 3 条低优先级 debt 合并为一张清理卡：

- **F1（P2）**：DB 存量 pronoun pollution — yao/shun 的 person_names 含单字"帝"（α 遗留），搜索"帝"会返回 yao/shun（语义错误）。修复：soft-delete 这些 alias 行。
- **F2（P3）**：伯 split-danger — 伯夷新增 surface `伯(alias)`（v1-r4 拆分），周/秦本纪扩量时可能与伯禽/伯邑考/伯益撞。修复：load 层 prefix-containment 检测（不加入 `_PRONOUN_BLACKLIST`）。
- **F4（P2）**：active 定义不统一 — resolver 用 `deleted_at IS NULL`，部分统计用 `merged_into_id IS NULL AND deleted_at IS NULL`。修复：ADR-010 补充"active = deleted_at IS NULL"为唯一定义（配合 F3 CHECK 约束后两定义等价）。

参见 `docs/debts/T-P0-006-beta-followups.md` F1 / F2 / F4 条目。

## 验收标准

- F1：pronoun alias 行（帝/王/后/公/君/主/上/天子）soft-delete 完成，搜索"帝"不再返回 yao/shun
- F2：load.py 新增 prefix-containment 检测，防止单字省称与其他 person 的全名前缀撞（至少 3 条测试）
- F4：代码库中"active person"的定义统一为 `deleted_at IS NULL`，不再有第二种定义
- 全部变更不引入新 schema migration

## 关联

- 前置：T-P0-020（F3 CHECK 约束，F4 依赖其结果以保证两定义等价）
- 阻塞：无（P2/P3 不阻塞 alpha，但建议 alpha 第一本书 ingest 前完成 F1）
