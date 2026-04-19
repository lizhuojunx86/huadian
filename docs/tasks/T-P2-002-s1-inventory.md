# T-P2-002 S-1: Slug 现状全量调研

> 调研日期：2026-04-19
> 数据源：live DB（huadian-postgres）+ 代码库 grep

---

## 1. Bucket 统计

| Bucket | 规则 | 数量 | 占比 | 示例 |
|--------|------|------|------|------|
| A — unicode | `^u[0-9a-f]{4}(-u[0-9a-f]{4})*$` | 88 | 58.3% | u4e2d-u4e01(中丁), u53f8-u9a6c-u8fc1(司马迁), u5468-u516c(周公) |
| B — pinyin | 不含 u-prefix hex | 63 | 41.7% | huang-di(黄帝), yao(尧), shun(舜), yu(禹), tang(汤) |
| C — other | 不匹配 A/B | 0 | 0% | — |
| **合计** | | **151** | | 活跃人物（merged_into_id IS NULL AND deleted_at IS NULL）|

另有 18 个非活跃人物（12 merged + 6 deleted，含 5 non-person soft-delete + 1 honorific merge）。

### Bucket A 完整清单（88 条 unicode slug）

| slug | 中文名 | slug | 中文名 |
|------|--------|------|--------|
| u4e2d-u4e01 | 中丁 | u4e2d-u58ec | 中壬 |
| u4e3b-u58ec | 主壬 | u4e3b-u7678 | 主癸 |
| u4e49-u4f2f | 义伯 | u4e5d-u4faf | 九侯 |
| u4e5d-u4faf-u5973 | 九侯女 | u4ef2-u4f2f | 仲伯 |
| u4f0a-u965f | 伊陟 | u51a5 | 冥 |
| u5357-u5e9a | 南庚 | u53f8-u9a6c-u8fc1 | 司马迁 |
| u5468-u516c | 周公 | u5468-u6210-u738b | 周成王 |
| u5468-u6b66-u738b | 周武王 | u548e-u5355 | 咎单 |
| u5546-u5bb9 | 商容 | u5916-u4e19 | 外丙 |
| u592a-u4e01 | 太丁 | u592a-u5e9a | 太庚 |
| u592a-u620a | 太戊 | u5973-u623f | 女房 |
| u5973-u9e20 | 女鸠 | u5b54-u5b50 | 孔子 |
| u5bb0-u4e88 | 宰予 | u5c0f-u4e59 | 小乙 |
| u5c0f-u7532 | 小甲 | u5c0f-u8f9b | 小辛 |
| u5c11-u66a4-u6c0f | 少暤氏 | u5d07-u4faf-u864e | 崇侯虎 |
| u5deb-u54b8 | 巫咸 | u5deb-u8d24 | 巫贤 |
| u5e08-u6d93 | 师涓 | u5e1d-u4e0d-u964d | 帝不降 |
| u5e1d-u4e59 | 帝乙 | u5e1d-u4e88 | 帝予 |
| u5e1d-u53d1 | 帝发 | u5e1d-u5916-u58ec | 帝外壬 |
| u5e1d-u5e9a-u4e01 | 帝庚丁 | u5e1d-u5ed1 | 帝廑 |
| u5e1d-u5eea-u8f9b | 帝廪辛 | u5e1d-u6243 | 帝扃 |
| u5e1d-u631a | 帝挚 | u5e1d-u69d0 | 帝槐 |
| u5e1d-u6cc4 | 帝泄 | u5e1d-u768b | 帝皋 |
| u5e1d-u76f8 | 帝相 | u5e1d-u8292 | 帝芒 |
| u5fae | 微 | u6076-u6765 | 恶来 |
| u62a5-u4e01 | 报丁 | u62a5-u4e19 | 报丙 |
| u62a5-u4e59 | 报乙 | u632f | 振 |
| u660c-u82e5 | 昌若 | u662d-u660e | 昭明 |
| u66f9-u5709 | 曹圉 | u6731-u864e | 朱虎 |
| u68bc-u674c | 梼杌 | u6b66-u4e59 | 武乙 |
| u6b66-u5e9a | 武庚 | u6c83-u4e01 | 沃丁 |
| u6c83-u7532 | 沃甲 | u6cb3-u4eb6-u7532 | 河亶甲 |
| u6d51-u6c8c | 浑沌 | u6d82-u5c71-u6c0f | 涂山氏 |
| u718a-u7f74 | 熊罴 | u76f8-u571f | 相土 |
| u7956-u4e01 | 祖丁 | u7956-u4e59 | 祖乙 |
| u7956-u4f0a | 祖伊 | u7956-u5df1 | 祖己 |
| u7956-u5e9a | 祖庚 | u7956-u7532 | 祖甲 |
| u7956-u8f9b | 祖辛 | u7a77-u5947 | 穷奇 |
| u7ba1-u53d4 | 管叔 | u7f19-u4e91-u6c0f | 缙云氏 |
| u80e4 | 胤 | u845b-u4f2f | 葛伯 |
| u8521-u53d4 | 蔡叔 | u8d39-u4e2d | 费中 |
| u9102-u4faf | 鄂侯 | u95f3-u592d | 闳夭 |
| u9633-u7532 | 阳甲 | u96cd-u5df1 | 雍己 |
| u9955-u992e | 饕餮 | u9a69-u515c | 驩兜 |

### Bucket B 完整清单（63 条 pinyin slug）

| slug | 中文名 | slug | 中文名 |
|------|--------|------|--------|
| bi-gan | 比干 | bo-yi | 伯夷 |
| chang-pu | 昌仆 | chang-xian | 常先 |
| chang-yi | 昌意 | cheng-tang | 成汤 → merged |
| chi-you | 蚩尤 | chui | 倕 |
| da-hong | 大鸿 | da-ji | 妲己 |
| dan-zhu | 丹朱 | di-ku | 帝喾 |
| fang-qi | 放齐 | feng-hou | 风后 |
| fu-yue | 傅说 | gao-yao | 皋陶 |
| gong-gong | 共工 | gou-wang | 句望 |
| gu-sou | 瞽叟 | gun | 鲧 |
| he-shu | 和叔 | he-zhong | 和仲 |
| hou-ji | 后稷 | huang-di | 黄帝 |
| ji-zi | 箕子 | jian-di | 简狄 |
| jiao-ji | 蟜极 | jie | 桀 |
| jing-kang | 敬康 | kong-jia | 孔甲 |
| kui | 夔 | lei-zu | 嫘祖 |
| li-mu | 力牧 | liu-lei | 刘累 |
| long | 龙 | pan-geng | 盘庚 |
| peng-zu | 彭祖 | qi | 启 |
| qiao-niu | 桥牛 | qiong-chan | 穷蝉 |
| shang-jun | 商均 | shao-dian | 少典 |
| shao-kang | 少康 | shen-nong-shi | 神农氏 |
| shun | 舜 | tai-jia | 太甲 |
| tai-kang | 太康 | tang | 汤 |
| wei-zi-qi | 微子启 | wu-ding | 武丁 |
| xi-bo-chang | 西伯昌 | xi-shu | 羲叔 |
| xi-zhong | 羲仲 | xiang | 象 |
| xie | 契 | xuan-xiao | 玄嚣 |
| yan-di | 炎帝 | yao | 尧 |
| yi | 益 | yi-yin | 伊尹 |
| yu | 禹 | zhong-kang | 中康 |
| zhou-xin | 纣 | zhuan-xu | 颛顼 |

> 注：cheng-tang（成汤）已 merged into tang（汤），但仍占有独立 slug 行。

---

## 2. Slug 生成源头分析

### 2.1 唯一生成入口

**文件**：`services/pipeline/src/huadian_pipeline/load.py:341-358`

```python
def _generate_slug(name_zh: str) -> str:
    if name_zh in _PINYIN_MAP:       # 74 条硬编码映射
        return _PINYIN_MAP[name_zh]
    # Fallback: unicode hex
    slug_parts = []
    for char in name_zh:
        slug_parts.append(f"u{ord(char):04x}")
    slug = "-".join(slug_parts)
    slug = re.sub(r"[^a-z0-9-]", "", slug)
    return slug or f"unknown-{uuid.uuid4().hex[:8]}"
```

**关键发现**：
- **NER prompt 不产 slug** — NER 只抽取人名/surface forms，slug 完全由 load 阶段确定性生成
- 之前怀疑 LLM 偶发产 pinyin 的假设**不成立** — 所有 pinyin slug 来自 `_PINYIN_MAP`
- `_PINYIN_MAP` 有 74 条（覆盖五帝本纪 + 夏本纪 + 殷本纪的主要人物）
- DB 中 63 个 pinyin slug 说明有 5 个映射命中了合并/别名人物

### 2.2 Seed 文件

**路径**：`services/pipeline/seeds/pilot-shiji-benji/`
- `wu_di_ben_ji.sql`：62 persons（43 pinyin + 19 unicode）
- `xia_ben_ji.sql`：84 persons（含五帝重复 + 夏新增）
- `yin_ben_ji.sql`：169 persons（含前两卷重复 + 殷新增）

Seed 文件由 `dump_seed.py` 从 DB 导出，slug 与 DB 一致。

### 2.3 API 侧验证

**文件**：`services/api/src/utils/slug.ts`
- Regex：`/^[a-z0-9]+(-[a-z0-9]+)*$/`
- 仅做格式校验，不关心 unicode vs pinyin 语义
- 两种格式都通过此校验

---

## 3. 硬编码依赖清单

| # | 文件 | 行号 | 内容 | 影响 |
|---|------|------|------|------|
| D1 | `apps/web/app/page.tsx` | 26-33 | `FEATURED_SLUGS = ["huang-di","yao","shun","yu","tang","xi-bo-chang"]` | Web 首页推荐卡片 |
| D2 | `apps/web/__tests__/components/FeaturedPersonCard.test.tsx` | 9,16,23,26,32,40 | `slug="huang-di"` 测试 fixture | 单测 |
| D3 | `services/api/tests/person-search.integration.test.ts` | 多处 | 搜索测试引用 pinyin + unicode slug | 集成测试 |
| D4 | `services/api/tests/person-names-dedup.integration.test.ts` | 多处 | dedup 测试引用 slug | 集成测试 |
| D5 | `services/api/tests/fixtures/search-golden.json` | 多处 | 黄金测试集含 slug | 基准测试 |
| D6 | `services/pipeline/src/huadian_pipeline/load.py` | 261-338 | `_PINYIN_MAP`（74 条） | slug 生成源头 |
| D7 | `services/pipeline/seeds/pilot-shiji-benji/*.sql` | 全文件 | INSERT INTO persons ... slug ... | 种子数据 |
| D8 | `services/pipeline/tests/resolve/test_resolve_rules.py` | 389+ | unicode slug 测试 fixture | 管线测试 |

---

## 4. 潜在冲突分析

### 4.1 当前碰撞：无

```sql
SELECT slug, count(*) FROM persons GROUP BY slug HAVING count(*)>1;
-- 0 rows
```

### 4.2 同名碰撞：无

```sql
SELECT name->>'zh-Hans', count(*) FROM persons
WHERE merged_into_id IS NULL AND deleted_at IS NULL
GROUP BY 1 HAVING count(*)>1;
-- 0 rows
```

### 4.3 未来碰撞风险（如果选方向 2 全 pinyin）

| 场景 | 风险 | 当前是否存在 |
|------|------|-------------|
| 同音字（yáo=尧=姚） | 需 disambiguation | ❌ 当前无 |
| 多音字（传 chuán/zhuàn） | 需选读音规则 | ❌ 当前无 |
| 单字名碰撞（qi=启=契?） | 契已映射为 xie | ❌ 当前无 |
| 跨朝代同名人物 | 未来扩量跑可能出现 | ⚠️ 潜在风险 |

### 4.4 CJK Extension B 风险

当前所有人物名均在 BMP（U+0000–U+FFFF）范围内。
`_generate_slug()` 使用 `f"u{ord(char):04x}"` — 对 >U+FFFF 的字符会产生 5-hex（如 `u20000`），
破坏 `^u[0-9a-f]{4}` 正则假设。
**当前不影响**，但 slug 生成函数应修复为可变位数或 LPAD 到统一位数。

---

## 5. 关键发现总结

1. **Pinyin slug 不是 LLM 偶发产出** — 全部来自 `_PINYIN_MAP` 硬编码，规则确定性
2. **占比 42% 不算"少数"** — 74 条映射覆盖了三卷本纪的主要人物
3. **Web 首页 6 个推荐人物全部是 pinyin slug** — 改动需同步
4. **当前无任何碰撞** — 不论选哪个方向都不需要处理现有冲突
5. **真正的问题是"两套规则并存"** — `_PINYIN_MAP` 是人工维护的白名单，没映射到的就 fallback unicode
6. **Seed 文件是 DB 快照导出** — 会随迁移自动同步（重新 dump 即可）
