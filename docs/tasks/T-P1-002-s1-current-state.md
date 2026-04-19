# T-P1-002 S-1: 现状调研报告

> 调研日期：2026-04-19

## 1. DB 统计

| 指标 | 值 |
|------|-----|
| person_names 总行数 | 273 |
| 同一 person_id 下重复 (person_id, name) 对 | **0** |
| 单个 person_id 有 >1 primary 的 person 数 | **17**（14 active + 3 merged） |
| 聚合视角（canonical group）有 >1 primary 的 canonical 数 | **19** |
| 跨 person_id 重复名（canonical group 内同名不同 person_id） | **11 对** |

### 1.1 聚合视角：19 个 canonical 有多 primary

| canonical | primary 数 | names 明细 |
|-----------|-----------|------------|
| 中丁 | 3 | 中丁(primary)×2, 帝中丁(primary) |
| 倕 | 2 | 倕(primary), 垂(primary) |
| 南庚 | 2 | 南庚(primary), 帝南庚(primary) |
| 后稷 | 3 | 弃(primary)×2, 稷(primary) |
| 尧 | 2 | 尧(primary), 放勋(primary) |
| 帝喾 | 2 | 帝喾高辛者(primary), 高辛(primary) |
| 微子启 | 3 | 启(primary), 微子(primary), 微子启(primary) |
| 比干 | 2 | 比干(primary), 王子比干(primary) |
| 汤 | 4 | 商汤(primary), 天乙(primary), 汤(primary)×2 |
| 沃甲 | 2 | 帝沃甲(primary), 沃甲(primary) |
| 益 | 3 | 伯益(primary), 益(primary)×2 |
| 祖丁 | 2 | 帝祖丁(primary), 祖丁(primary) |
| 祖辛 | 2 | 帝祖辛(primary), 祖辛(primary) |
| 禹 | 2 | 文命(primary), 禹(primary) |
| 舜 | 2 | 舜(primary), 重华(primary) |
| 西伯昌 | 2 | 周文王(primary), 西伯昌(primary) |
| 阳甲 | 2 | 帝阳甲(primary), 阳甲(primary) |
| 颛顼 | 2 | 颛顼(primary), 高阳(primary) |
| 驩兜 | 2 | 欢兜(primary), 驩兜(primary) |

### 1.2 跨 person_id 重复名（11 对）

| canonical | 重复名 | 次数 | types |
|-----------|--------|------|-------|
| 中丁 | 中丁 | 2 | primary, primary |
| 后稷 | 弃 | 2 | primary, primary |
| 太戊 | 中宗 | 2 | temple, temple |
| 太甲 | 太宗 | 2 | temple, temple |
| 武乙 | 帝武乙 | 2 | posthumous, temple |
| 汤 | 成汤 | 3 | posthumous, posthumous, alias |
| 汤 | 汤 | 2 | primary, primary |
| 益 | 益 | 2 | primary, primary |
| 祖甲 | 帝甲 | 2 | temple, posthumous |
| 西伯昌 | 西伯 | 2 | nickname, nickname |
| 黄帝 | 帝鸿氏 | 2 | alias, alias |

### 1.3 关键发现

- **per-person_id 无重复**：UNIQUE (person_id, name) 约束可直接添加，无需先 dedup
- **multi-primary 来源二元**：
  - **NER 抽取**：LLM 为同一 person 产出多个 primary（14 active persons），如 尧=尧+放勋
  - **Merge 未降级**：3 merged persons (伯益→益, 商汤→汤, 帝中丁→中丁) 的 primary 未降级
- **跨 person_id 重复**：merge 后 canonical 和 merged person 持有相同 name 文本（11 对）

## 2. 代码路径分析

### 2.1 写端 — resolve.py `apply_merges()`

**位置**：`services/pipeline/src/huadian_pipeline/resolve.py:375-510`

当前 merge 操作只做两件事：
1. `UPDATE persons SET deleted_at, merged_into_id` — soft-delete 被合并方
2. `INSERT INTO person_merge_log` — 记录合并日志

**缺失**：完全不触碰 `person_names` 表。被合并方的 names 保持原样（包括 primary）。

### 2.2 读端 — person.service.ts `findPersonNamesWithMerged()`

**位置**：`services/api/src/services/person.service.ts:259-278`

当前查询逻辑：
1. 找到所有 `merged_into_id = canonicalId` 的 person IDs
2. 用 `inArray(personNames.personId, allIds)` 查所有 name 行
3. 直接 `rows.map(toGraphQLPersonName)` 返回 — **无 dedup，无 name_type 重写**

### 2.3 手动 merge（T-P0-015 等）

T-P0-015 帝鸿氏 merge 时手动插入了一行 `person_names (黄帝.id, '帝鸿氏', 'alias')`。
但帝鸿氏自身的 person_names 里也有 `(帝鸿氏.id, '帝鸿氏', 'alias')`，导致聚合视角出现帝鸿氏×2。

## 3. 方向 A/B 利弊对比

### 方向 A：写端修复

在 `apply_merges()` 和 backfill 中修改 person_names 数据。

| 维度 | 评价 |
|------|------|
| **数据干净度** | ✅ 底层数据干净，读端无负担 |
| **查询性能** | ✅ 无运行时 dedup 开销 |
| **一致性** | ✅ 所有消费者（API / 未来 export / 直接 SQL 查询）看到一致的数据 |
| **复杂度** | 中等。需 backfill 脚本 + 修改 apply_merges() + 处理跨 person_id 重复 |
| **可逆性** | ⚠️ backfill 后原 name_type 丢失（但 merge_log 可追溯） |
| **风险** | ⚠️ backfill 出错可能误改数据；需要 dry-run 验证 |

**具体修改**：
1. `apply_merges()` 新增：merge 后 UPDATE merged person 的 primary → alias
2. backfill 脚本：对现有 17 个 multi-primary person，保留 persons.name->'zh-Hans' 对应的 name 为 primary，其余降为 alias
3. 跨 person_id 重复处理：DELETE merged person 的重复 name 行（保留 canonical 方的）
4. 或者替代方案：不删跨 person_id 重复，而是在 API 层 dedup（混合方案）

### 方向 B：读端修复

在 API `findPersonNamesWithMerged()` 中做 dedup + name_type 重写。

| 维度 | 评价 |
|------|------|
| **数据干净度** | ❌ 底层 "多 primary" 问题不变，直接查 DB 仍会看到脏数据 |
| **查询性能** | ⚠️ 每次查询额外 dedup 计算（小代价，但存在） |
| **一致性** | ❌ 只有通过 API 的消费者看到干净数据；export / SQL 查询仍脏 |
| **复杂度** | 较低。只改 person.service.ts 一处 |
| **可逆性** | ✅ 底层数据不动，随时可调 |
| **风险** | 较低。纯读端，不可能损坏数据 |

**具体修改**：
1. `findPersonNamesWithMerged()` 返回前：按 name 文本去重（保留优先级最高的 name_type）
2. name_type 降级：来自 merged person 的 primary → alias
3. UNIQUE 约束仍然要加（防止未来 per-person_id 重复）

### 方向 C（混合，建议考虑）

**写端处理 primary 降级 + UNIQUE 约束；读端处理跨 person_id 去重**

| 维度 | 评价 |
|------|------|
| **数据干净度** | ✅ primary 唯一性在数据层保证 |
| **查询性能** | ⚠️ 极小 dedup 开销（只去名字文本重复） |
| **复杂度** | 中等 |
| **可逆性** | 混合 |

**具体修改**：
1. `apply_merges()` 新增 primary → alias UPDATE（写端）
2. backfill 现有 multi-primary（写端）
3. `findPersonNamesWithMerged()` 按 name 文本 dedup（读端，处理跨 person_id 重复）
4. UNIQUE (person_id, name) 约束
5. 不删除跨 person_id 重复行（保留数据完整性）

## 4. 建议

**推荐方向 C（混合）**，理由：
- primary 降级是数据层问题，应在数据层修复（每个 person_id 最多 1 个 primary）
- 跨 person_id 重复是 merge 设计的副作用（names 保留在原 person_id 下），读端 dedup 更安全
- UNIQUE 约束无论哪个方向都必须加

等待用户裁决。
