# T-P1-004 S-1: 现状分析报告

> 调研日期：2026-04-19

## 1. NER Prompt 现状

**文件**：`services/pipeline/src/huadian_pipeline/prompts/ner_v1.md`（版本 v1-r2）

### 1.1 name_type 相关指令

| 行号 | 内容 | 问题 |
|------|------|------|
| L48-57 | `name_type` 枚举定义：primary / courtesy / art / posthumous / nickname / alias 等 | 仅说明"primary = 本名/最常用名"，**未约束数量** |
| L20 | "为**每个称谓单独标注 name_type**" | 隐含允许多个 primary |
| L80 | "每个称谓各自标注 name_type" | 同上 |
| L111 | 合称规则："帝喾高辛者" → 帝喾=nickname, 高辛=primary | 正确示例，但缺少反例 |

### 1.2 Few-shot 示例分析

| 示例 | name_zh | surface_forms | primary 数 | 分析 |
|------|---------|---------------|-----------|------|
| 黄帝（L128-141） | 黄帝 | 黄帝/nickname, 轩辕/primary, 公孙/alias | 1 ✅ | 正确 |
| 蚩尤（L174-184） | 蚩尤 | 蚩尤/primary | 1 ✅ | 正确 |
| 舜（L204-215） | 舜 | 舜/primary, 虞舜/alias | 1 ✅ | 正确 |
| 尧（L217-228） | 尧 | 帝尧/nickname, 尧/primary | 1 ✅ | 正确 |

**关键发现**：few-shot 示例都是正确的（每人 1 primary），但 prompt 正文**缺少显式约束**。
LLM 在 few-shot 不覆盖的边界情况下会产出多 primary。

## 2. load.py 代码路径

**文件**：`services/pipeline/src/huadian_pipeline/load.py:195-256`

### 2.1 `_insert_person_names()` 流程

```
1. 确定 primary_name_type（L204-210）：
   遍历 surface_forms，找到 text==name_zh 的，用其 name_type

2. 插入 name_zh（L213-231）：
   is_primary=true, name_type=primary_name_type（来自步骤 1）

3. 插入其他 surface_forms（L234-254）：
   is_primary=false, name_type=sf.name_type（直接用 LLM 输出）
```

### 2.2 问题

- **无 primary 数量校验**：如果 LLM 输出 `[{text:"尧", name_type:"primary"}, {text:"放勋", name_type:"primary"}]`，
  step 2 插入"尧"时 name_type='primary'，step 3 插入"放勋"时 name_type='primary'（直接透传 LLM 输出）
- **`is_primary` vs `name_type`**：`is_primary` boolean 只给 name_zh（正确），但 `name_type` enum 字段
  完全由 LLM 控制，多 primary 从此泄漏

## 3. 14 NER-source 多 primary 冲突类型分类

基于 T-P1-002 S-1 数据（19 canonical 多 primary），排除 3 个 merge-source（伯益→益、商汤→汤、帝中丁→中丁的 merged 方），
剩余 14 active persons + 2 merged persons 的 NER-source 多 primary 分类：

### 类型 A：本名 + 字/号（4 个）

| person | primary 1 | primary 2 | 应该 |
|--------|-----------|-----------|------|
| 尧 | 尧 | 放勋 | 尧=primary, 放勋=alias（放勋为名，尧为通行称谓） |
| 舜 | 舜 | 重华 | 舜=primary, 重华=alias（重华为名） |
| 禹 | 禹 | 文命 | 禹=primary, 文命=alias（文命为名） |
| 颛顼 | 颛顼 | 高阳 | 颛顼=primary, 高阳=alias（高阳为号/封地名） |

**模式**：LLM 将"字/号/本名"与"最通行称谓"同时标为 primary

### 类型 B：本名 + 帝X 前缀（6 个）

| person | primary 1 | primary 2 | 应该 |
|--------|-----------|-----------|------|
| 南庚 | 南庚 | 帝南庚 | 南庚=primary, 帝南庚=nickname |
| 沃甲 | 沃甲 | 帝沃甲 | 沃甲=primary, 帝沃甲=nickname |
| 祖丁 | 祖丁 | 帝祖丁 | 祖丁=primary, 帝祖丁=nickname |
| 祖辛 | 祖辛 | 帝祖辛 | 祖辛=primary, 帝祖辛=nickname |
| 阳甲 | 阳甲 | 帝阳甲 | 阳甲=primary, 帝阳甲=nickname |
| 中丁 | 中丁 | 帝中丁 | 中丁=primary, 帝中丁=nickname |

**模式**：LLM 将"帝X"也标为 primary，应为 nickname（已有帝号规则但未覆盖 name_type）

### 类型 C：全称/敬称 + 简称（3 个）

| person | primary names | 应该 |
|--------|--------------|------|
| 微子启 | 微子启, 微子, 启 | 微子启=primary, 微子=nickname, 启=alias |
| 比干 | 比干, 王子比干 | 比干=primary, 王子比干=nickname |
| 西伯昌 | 西伯昌, 周文王 | 西伯昌=primary, 周文王=posthumous |

**模式**：LLM 将全称与简称同时标为 primary

### 类型 D：特殊（3 个）

| person | primary names | 应该 |
|--------|--------------|------|
| 帝喾 | 帝喾高辛者, 高辛 | 高辛=primary, 帝喾高辛者=alias（复合称呼不应为 primary） |
| 汤 | 汤, 商汤, 天乙 | 汤=primary, 商汤=alias, 天乙=alias |
| 倕/垂 | 倕, 垂 | 倕=primary, 垂=alias（通假字变体） |
| 驩兜/欢兜 | 驩兜, 欢兜 | 驩兜=primary, 欢兜=alias（异体字变体） |

**模式**：通假字/异体字/多称谓全标 primary

## 4. 冲突类型统计

| 类型 | 数量 | 模式 | NER prompt 修复策略 |
|------|------|------|---------------------|
| A：本名+字/号 | 4 | 尧/放勋, 舜/重华 | 规则：最通行称谓=primary，其余=alias |
| B：本名+帝X | 6 | 南庚/帝南庚 | 规则：帝X=nickname（已有帝号规则，需扩展到 name_type） |
| C：全称+简称 | 3 | 微子启/微子/启 | 规则：name_zh=primary，全称/敬称=nickname |
| D：特殊 | 3 | 倕/垂, 汤/商汤/天乙 | 规则：通假/异体/多称谓一律 alias |

## 5. 结论

- NER prompt 的 few-shot 示例正确但不充分，LLM 在未覆盖的边界案例（本名+号、帝X、通假字）上产出多 primary
- load.py 完全信任 LLM 的 name_type 输出，无任何校验
- 修复需要两层：
  1. **NER prompt**：添加显式 single-primary 约束 + 冲突类型 few-shot
  2. **load.py**：defensive validation，确保即使 LLM 违反约束也不污染 DB
