# ADR-011: Person Slug Naming Scheme — Tiered Whitelist

- **状态**：accepted
- **日期**：2026-04-19
- **决策者**：用户（产品负责人）+ 架构师
- **关联任务**：T-P2-002

## 背景

persons 表的 slug 字段存在两种格式并存：
- **Pinyin**（63 个）：`huang-di`, `yao`, `shun` — 来自 `load.py` 中的 `_PINYIN_MAP` 硬编码
- **Unicode hex**（88 个）：`u4e2d-u4e01`, `u53f8-u9a6c-u8fc1` — 不在映射表中的 fallback

两种格式均合法（通过 API slug regex `^[a-z0-9]+(-[a-z0-9]+)*$`），但缺乏明文规则，
slug 生成逻辑散落在 `load.py` 内部，不可预测、不可审计。

## 决策

**采用方向 3：分层白名单（Tiered Whitelist）**

### 规则

1. **Tier-S 人物**（白名单 `data/tier-s-slugs.yaml`）→ pinyin slug
2. **所有其他人物** → unicode hex slug（`u{hex}` per character）
3. **不变量**：DB 中每个 slug 必须是 (a) 白名单中的值 或 (b) 匹配 `^u[0-9a-f]{4,5}(-u[0-9a-f]{4,5})*$`
4. **不变量由 CI 强制执行**（`test_slug_invariant.py`）

### 白名单治理

- 新增条目**必须**附带 CHANGELOG 或 ADR 记录
- 新增前**必须**验证无 slug 碰撞
- 白名单仅用于知名度高、拼音无歧义的历史人物
- 白名单文件头部注释包含治理规则

### 代码架构

- `data/tier-s-slugs.yaml` — 唯一白名单文件（single source of truth）
- `services/pipeline/src/huadian_pipeline/slug.py` — slug 生成模块
  - `generate_slug(name_zh)` — 统一入口
  - `unicode_slug(name_zh)` — unicode hex 生成
  - `get_tier_s_whitelist()` — 白名单访问
  - `classify_slug(slug)` — 分桶工具
- `load.py` — 仅调用 `slug.generate_slug()`，不再内联映射表

## 排除的方案

### 方向 1：统一到 unicode
- 简单但牺牲已有的好 URL（`/persons/huang-di` → `/persons/u9ec4-u5e1d`）
- SEO 倒退，Web 首页 6 个推荐卡片 URL 全部变丑

### 方向 2：统一到 pinyin
- 好看但多音字（传/长/和）和同音碰撞（yáo=尧=姚）是长期维护噩梦
- 需引入 pypinyin 依赖 + disambiguation 规则
- Phase 0 阶段 ROI 不合理

### 方��� 4：Unicode canonical + pinyin alias
- 面向未来最干净，但需要新增 slug_aliases 表 + redirect middleware
- 工程量大，当前无外部链接需要保护，过早优化

## 后果

### 正面
- **零 DB 变更** — 不动现有 slug，URL 稳定性 100%
- **改动最小** — 提取白名单 + 模块化，不影响其他模块
- **可预测** — 给定 name_zh，slug 结果确定性（白名单 or unicode）
- **CI 保证** — 不变量测试防止未来出现怪 slug

### 负面
- 两套格式并存，新用户看 URL 可能困惑
- 白名单需人工维护，扩量跑新书时需决定哪些人物入列
- 白名单之外的人物 URL 仍不可读

### 已知 tradeoff
- CJK Extension B（>U+FFFF）字符会产生 5-hex slug（`u20000`），
  与 4-hex 不完全一致，但 regex 已兼容 `{4,5}`
