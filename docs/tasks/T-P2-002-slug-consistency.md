# T-P2-002: persons.slug 命名一致性清理

- **状态**：done
- **主导角色**：管线工程师 + 后端工程师
- **所属 Phase**：Phase 2（技术债）
- **依赖任务**：T-P0-014 ✅（非人实体清理时发现该问题）
- **创建日期**：2026-04-19
- **登记来源**：T-P0-014 historian KEEP 决策（`龙` slug=long 与 unicode 格式不一致）

## 目标

确立 slug 命名的**单一事实源**（single source of truth），让未来每次 ingest 产出的 slug
都可预测、可验证、无冲突。同时处理历史遗留的不一致，保证 URL 稳定性（不能让老链接 404）。

## 现状摘要

- **活跃人物**：151 个（merged_into_id IS NULL AND deleted_at IS NULL）
- **Bucket A (unicode)**：88 个（58.3%）— `u{4hex}(-u{4hex})*` 格式
- **Bucket B (pinyin)**：63 个（41.7%）— 来自 `_PINYIN_MAP`（58 条硬编码映射）
- **Bucket C (other)**：0 个
- **当前无 slug 碰撞**（所有 slug 唯一）
- **当前无同名碰撞**（所有活跃人物 name->'zh-Hans' 唯一）

## 范围（IN SCOPE）

1. 统一 slug 生成策略（选择方向）
2. 管线侧 slug 生成模块明文化（`slug.py` + pytest）
3. NER/load 流程中 slug 生成规范化
4. 历史数据迁移（如需要）
5. URL 稳定性保障（重定向 or 保持）
6. Web 首页硬编码 slug 更新（如需要）
7. ADR 决策记录
8. seed 文件同步

## 范围（OUT OF SCOPE）

- 非 persons 表的 slug（events/places — 尚未大量产出）
- CJK Extension B（>U+FFFF）支持（当前语料无此需求）
- pypinyin 库集成（留待 Phase 1+ 评估）

## 风险

| # | 描述 | 缓解 |
|---|------|------|
| R1 | slug 更名 = URL 契约变更，外部链接 404 | 加 slug_aliases 表或应用层 301 重定向 |
| R2 | pinyin 同音字碰撞（如 yáo=尧=姚） | 当前库无碰撞；方向选择需考虑 disambiguation 规则 |
| R3 | seed 文件 slug 与迁移后 DB 不一致 | seed 文件同步更新 |
| R4 | Web 首页 6 个硬编码 slug 失效 | 同步更新 FEATURED_SLUGS |
| R5 | CJK Ext B 字符（5-hex）破坏 `u{4hex}` 模式 | slug 生成函数用 LPAD 或可变位数 |

## 交付物

- `docs/tasks/T-P2-002-s1-inventory.md` — S-1 调研报告
- `docs/decisions/ADR-NNN-slug-naming.md` — 决策记录
- 管线 slug 生成模块（明文化规则 + pytest）
- DB 迁移脚本（如方向需要）
- 回滚脚本
- Web 首页更新（如方向需要）
- seed 文件同步

## 验收标准

- [x] `SELECT slug, count(*) FROM persons GROUP BY slug HAVING count(*)>1` → 0 rows（唯一性）✅
- [x] 所有活跃 persons.slug 符合 ADR-011 不变量（test_slug_invariant.py 3 cases pass）✅
- [x] slug 生成函数有 pytest 覆盖（23 cases in test_slug.py）✅
- [x] Web 首页 6 个推荐人物卡片 URL 不变（方向 3 零迁移）✅
- [x] 无 DB 迁移（方向 3 保持现有 slug 不变）✅
- **扩列治理**：未来向 `data/tier-s-slugs.yaml` 新增条目必须附带 ADR 或 CHANGELOG 记录，不能无记录 commit

## 工作步骤

- [x] S-0：创建任务卡
- [x] S-1：现状全量调研（只读，不改 DB）
- [x] S-2：方向选择 → **方向 3（分层白名单）**
- [x] S-3：实施（YAML 白名单 + slug.py 模块 + load.py 重构 + 23 unit tests + 3 invariant tests + ADR-011）
- [x] S-4：DB 写入 — **跳过**（方向 3 无 DB 变更）
- [x] S-5：验证 + 收尾（ruff 0 errors / basedpyright 0/0/0 / 218 pipeline tests / 61 api tests / 55 web tests 全绿）
