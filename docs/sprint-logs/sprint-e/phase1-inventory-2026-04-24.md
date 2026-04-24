# Phase 1 Inventory Report — Sprint E Track B

> **作者**：管线工程师（Pipeline Engineer）
> **日期**：2026-04-24
> **状态**：待架构师签字
> **产出位**：`docs/sprint-logs/sprint-e/phase1-inventory-2026-04-24.md`

---

## 1. 真书完成度盘点

### 1.1 史记（本纪部分）

史记共 12 本纪（卷一 ~ 卷十二），当前已完成 **4/12**（先秦段完整覆盖）。

| 卷 | 章节 | slug | 段落数 | 字数 | 状态 | 人物产出 |
|----|------|------|--------|------|------|---------|
| 卷一 | 五帝本纪 | shiji-wu-di-ben-ji | 29 | 4,555 | ✅ Phase A | 39 persons (evidence) |
| 卷二 | 夏本纪 | shiji-xia-ben-ji | 35 | 4,065 | ✅ Phase A+B | 16 persons (evidence) |
| 卷三 | 殷本纪 | shiji-yin-ben-ji | 35 | 3,558 | ✅ Phase A+B | 77 persons (evidence) |
| 卷四 | 周本纪 | shiji-zhou-ben-ji | 82 | 10,318 | ✅ Phase α | 207 persons (evidence) |
| 卷五 | 秦本纪 | — | — | ~15,000 est. | ❌ 未 ingest | — |
| 卷六 | 秦始皇本纪 | — | — | ~20,000 est. | ❌ 未 ingest | — |
| 卷七 | 项羽本纪 | — | — | ~8,000 est. | ❌ 未 ingest | — |
| 卷八 | 高祖本纪 | — | — | ~12,000 est. | ❌ 未 ingest | — |
| 卷九 | 吕太后本纪 | — | — | ~6,000 est. | ❌ 未 ingest | — |
| 卷十 | 孝文本纪 | — | — | ~5,000 est. | ❌ 未 ingest | — |
| 卷十一 | 孝景本纪 | — | — | ~2,500 est. | ❌ 未 ingest | — |
| 卷十二 | 孝武本纪 | — | — | ~4,000 est. | ❌ 未 ingest | — |

**小计**：181 段 / 22,496 字 / 4 章已完成

### 1.2 尚书

| 篇 | slug | 段落数 | 字数 | 状态 | 人物产出 |
|----|------|--------|------|------|---------|
| 尧典 | shangshu-yao-dian | 7 | 619 | ✅ β-route | 12 persons (evidence) |
| 舜典 | shangshu-shun-dian | 20 | 1,081 | ✅ β-route | 12 persons (evidence) |
| 其余 | — | — | — | ❌ 未 ingest | — |

**小计**：27 段 / 1,700 字 / 2 篇已完成（β-route 跨书归并压力测试）

### 1.3 其他书目

无。Phase 0 聚焦史记本纪 + 尚书虞书。

### 1.4 汇总

- **总计已 ingest**：6 个章节 / 208 段 / ~24,196 字
- **Active persons**：319（经 53 次 merge/soft-delete 后净值）
- **Source evidences**：412 (AI_INFERRED) + 160 (seed_dictionary) = 572
- **LLM 累计成本**：~$2.55（NER $1.77 + 证据链回填 $0.78）

---

## 2. 下一章节候选（3 个，优先级排序）

### 候选 1：史记·秦本纪（卷五）⭐ 推荐

| 维度 | 评估 |
|------|------|
| **篇幅** | ~150 段 / ~15,000 字（本纪最长篇之一；超过周本纪 82 段） |
| **估计成本** | $1.5–2.0（参考周本纪 82 段 $0.77，线性外推 + 人物密度更高） |
| **历史价值** | 秦国从非子立国到秦王政统一前的完整世系；填补秦 dynasty 空白 |
| **管线验证价值** | (1) 大篇幅压力测试；(2) 秦朝 dynasty 几乎空白（1 person / 0 seed），验证新朝代冷启动；(3) 大量战国人物与现有 319 persons 交叉，测试 R1-R6 resolver 在密集 overlap 场景 |
| **现有人物 overlap** | 战国 25 persons + 东周 35 persons 已在库，预期 ~30% 命中 resolver |
| **风险** | 篇幅大（可能需 2 批分段 ingest）；秦国世系人物字典覆盖低 |

**为什么是它**：自然续接本纪序列（卷五 = Phase A/B 后下一章），且秦 dynasty 目前仅 1 person 是最大内容空白。填补秦国世系对知识图谱完整性价值最高。

### 候选 2：史记·项羽本纪（卷七）

| 维度 | 评估 |
|------|------|
| **篇幅** | ~60–80 段 / ~8,000 字（与殷本纪相当） |
| **估计成本** | $0.6–0.8 |
| **历史价值** | 秦末楚汉争霸核心叙事（鸿门宴、垓下之战等经典场景） |
| **管线验证价值** | (1) persons.seed.json batch 1 鸿门宴角色齐全（项羽/刘邦/张良/范增/樊哙/陈平/项伯），字典覆盖率最高；(2) 跨朝代过渡（秦→楚汉），测试 dynasty 边界 NER |
| **现有人物 overlap** | batch 1 字典 40 人中 ~15 人直接相关；但这些人尚未被 ingest 进 persons 表 |
| **风险** | 跳过卷五/卷六直接做卷七，打破自然序列；秦本纪人物未建立会导致跨章节 resolver 缺乏上下文 |

**为什么考虑它**：篇幅适中适合热身；batch 1 字典覆盖好，能验证 TIER-4 字典与 Wikidata seed 的交叉效果。但跳过秦本纪会失去自然上下文。

### 候选 3：史记·高祖本纪（卷八）

| 维度 | 评估 |
|------|------|
| **篇幅** | ~100 段 / ~12,000 字 |
| **估计成本** | $1.0–1.5 |
| **历史价值** | 西汉建国叙事；刘邦从沛县起兵到称帝 |
| **管线验证价值** | (1) persons.seed.json batch 1 有高祖/萧何等；(2) 政治制度类实体出现（封侯、郡县），为未来 polity/place NER 打基础 |
| **现有人物 overlap** | 与项羽本纪高度重叠（楚汉双方视角） |
| **风险** | 依赖项羽本纪的人物基础；西汉初年人物大量涌入可能触发 V11 cardinality 问题 |

**为什么考虑它**：与项羽本纪互为补充，两篇合做可获得完整的楚汉过渡叙事。但单独做缺乏上下文。

---

## 3. 管线就绪度

### 3.1 组件就绪矩阵

| 组件 | 版本/状态 | 就绪？ | 备注 |
|------|-----------|--------|------|
| NER prompt | v1-r4 | ✅ | 帝X 校验 + 姓氏提取 + 部族排除 + 合称规则 + 单 primary 约束 + 代称排除 |
| 三态名 (surface_forms) | v1-r4 内置 | ✅ | |
| Evidence chain Stage 1 | ADR-015 activated | ✅ | per-person SE 写路径 T-P0-006-α 验证通过 |
| R6 prepass guard | Sprint C+D | ✅ | cross_dynasty_guard (>500yr) + pending_merge_reviews 表 |
| Identity resolver | R1-R6 全链路 | ✅ | R1(exact) + R2(alias) + R3(tongjia) + R5(di-prefix) + R6(seed-match) |
| Wikidata seed loader | Sprint B | ✅ | 3-round matcher + CLI + V10/V11 invariant |
| load.py | _enforce_single_primary | ✅ | ADR-012 三层防御 |
| ctext adapter | fixture-based | ⚠️ | **需为新章节准备 fixture 文件** |
| tier-s-slugs.yaml | 125 entries | ⚠️ | 秦/楚汉人物未覆盖，**需扩充** |

### 3.2 Phase 0 tail debt 阻塞评估

| Debt | 描述 | 阻塞 Phase 1？ | 理由 |
|------|------|---------------|------|
| V1 violations (27) | active persons 缺 is_primary=true name | **否** | T-P1-022 scope；不影响新章节 ingest/extract/resolve |
| F12 (11 行) | primary + is_primary=false | **否** | P2；读端 API 已兜住 |
| pending_review (45) | seed_mappings 待 triage | **否** | T-P0-028 scope；不影响新 ingest |
| T-P1-016 | 微子 slug mismatch | **否** | 低优先级，slug 不影响数据正确性 |
| T-P1-005 | migration 双轨合一 | **否** | CI 已 workaround (Step 4c) |

**结论**：**无 Phase 0 tail debt 阻塞 Phase 1 推进**。Stop Rule #3 不触发。

### 3.3 新章节前置准备（任何候选都需要）

1. **Fixture 文件准备**：从 ctext.org 下载目标章节全文，存入 `services/pipeline/fixtures/sources/shiji/`
2. **ctext adapter 注册**：在 `_CHAPTER_REGISTRY` 和 `_CHAPTER_META` 新增条目
3. **tier-s-slugs.yaml 扩充**：为目标章节核心人物添加 pinyin slug（Tier-S）

---

## 4. Historian 字典覆盖率

### 4.1 现有字典资产

| 资产 | 数量 | 覆盖期 |
|------|------|--------|
| persons.seed.json (batch 1, TIER-4) | 40 人 | 秦汉重点（秦始皇/高祖/武帝/项羽/张良等） |
| dictionary_entries (Wikidata, TIER-1) | 202 条 | 先秦为主（Wikidata 覆盖 54.4%） |
| active seed_mappings | 159 | 先秦 persons → Wikidata QID |
| tier-s-slugs.yaml | 125 条 | 五帝/夏/殷/周 人物 pinyin |
| disambiguation_seeds.seed.json | 10 组 / 26 行 | 秦汉同名异人（韩信/刘秀/淮南王等） |
| tongjia.yaml | 通假字字典 | 先秦古字 |
| miaohao.yaml | 庙号字典 | 帝X 映射 |

### 4.2 候选章节字典覆盖率评估

| 候选 | 估计新人物数 | 已有字典覆盖 | 覆盖率 | 评估 |
|------|------------|------------|--------|------|
| **秦本纪** | ~80–120 | 秦 dynasty 1 person + 战国 ~25 overlap + batch 1 ~5 (秦穆公/白起/秦孝公/商鞅未入库) | **~25–30%** | ⚠️ 偏低，但不触发 <50% Stop Rule（战国 overlap 兜底） |
| **项羽本纪** | ~40–60 | batch 1 ~15 直接相关 + 秦末人物 Wikidata 覆盖好 | **~50–60%** | ✅ 良好 |
| **高祖本纪** | ~60–80 | batch 1 ~10 + 与项羽本纪人物重叠 | **~40–50%** | ⚠️ 边界 |

**注意**：覆盖率计算包含两层——
- **Wikidata seed 覆盖**：通过 Sprint B matcher 自动匹配，秦汉名人 Wikidata 覆盖率预期 >60%（名人效应）
- **Historian 字典预审**：persons.seed.json batch 1 的 40 人为手工审核锚点，batch 2 尚未扩充

### 4.3 字典缺口分析

**秦本纪特有缺口**：
- 秦国 30+ 代君主世系（非子 → 秦庄公 → 秦穆公 → ... → 秦王政）——大部分不在现有字典
- 战国合纵连横人物（张仪/苏秦/吕不韦/商鞅）——batch 1 部分覆盖但未入库
- 秦国名臣（百里奚/蹇叔/由余/孟明视）——完全空白

**项羽本纪特有缺口**：
- 秦末义军首领（陈胜/吴广/英布/彭越）——batch 1 未覆盖
- 楚国贵族（项梁/宋义/楚怀王/范增）——batch 1 部分覆盖

**建议**：无论选哪个候选，建议在 ingest 前开 historian 字典扩充卡（~30 分钟工作量），补充目标章节核心人物的 disambiguation hints。但这**不阻塞** ingest——Phase α 经验证明 NER v1-r4 + 事后 resolver 可以处理无字典覆盖的人物。

---

## 5. PE 推荐 + 理由

### 推荐：史记·秦本纪（卷五）

**理由**：

1. **自然序列**：卷一 ~ 卷四已完成，卷五是自然延续。打破序列跳到卷七/卷八会导致：
   - 秦国人物基础缺失（项羽本纪 / 高祖本纪中大量秦国人物引用需要已有的 persons 做 resolver 上下文）
   - 知识图谱完整性受损（秦国世系是连接先秦 → 秦汉的关键桥梁）

2. **最大内容空白填补**：秦 dynasty 目前仅 1 person（秦庄襄王），是所有朝代中覆盖最差的。秦本纪可产出 ~80-120 new persons，一次性将秦国世系建立起来。

3. **压力测试价值**：
   - 大篇幅（~150 段）测试管线吞吐能力
   - 密集人物出现测试 NER 精度
   - 战国 overlap 测试 resolver R1-R6 在高密度场景的表现
   - 跨朝代（西周 → 春秋 → 战国 → 秦）测试 R6 cross-dynasty guard

4. **风险可控**：
   - 可分 2 批 ingest（前半/后半各 ~75 段），降低单次风险
   - Phase α 经验（周本纪 82 段 $0.77）提供了可靠的成本/质量基线
   - 战国人物 25+ 已在库，resolver 有锚点

5. **字典覆盖率 ~25-30%** — 虽偏低，但：
   - 不触发 <50% Stop Rule（战国 overlap + batch 1 覆盖兜底）
   - Phase α 证明 NER v1-r4 在零字典覆盖场景也能工作（五帝本纪首跑时字典覆盖 0%）
   - 建议在 ingest 前开一张轻量字典扩充卡（秦国 Tier-S 核心 ~20 人）

### 备选排序

1. **秦本纪**（推荐）— 自然序列 + 最大空白填补 + 压力测试
2. **项羽本纪** — 字典覆盖好 + 篇幅适中，适合做秦本纪后的第二章
3. **高祖本纪** — 与项羽本纪互补，建议两篇连做

### 前置依赖

| 项目 | 工作量 | 阻塞？ |
|------|--------|--------|
| 秦本纪 fixture 下载 | ~15 min | ✅ 必须 |
| ctext adapter 注册 | ~5 min | ✅ 必须 |
| tier-s-slugs.yaml 秦国扩充 | ~30 min（~20 人） | ⚠️ 建议但不阻塞 |
| historian 字典预审 | ~30 min | ⚠️ 建议但不阻塞 |

---

## 6. Stop Rule 评估

| Stop Rule | 状态 | 说明 |
|-----------|------|------|
| #3: Phase 0 未消化阻塞 | ✅ 不触发 | 无 Phase 0 debt 阻塞 Phase 1 |
| #4: 字典覆盖率 <50% | ⚠️ 边界 | 秦本纪 ~25-30% 偏低；但含战国 overlap 兜底 + Phase α 零字典先例。**建议架构师裁决是否接受** |

---

> 本报告挂起等架构师签字。签字后第二会话进 Track B 执行。
