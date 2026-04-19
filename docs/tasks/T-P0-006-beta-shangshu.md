# T-P0-006-β: 《尚书·尧典 + 舜典》摄入（β 路线）

- **状态**：in-progress（S-0 + S-1）
- **主导角色**：管线工程师
- **协作角色**：古籍/历史专家（版本裁决 + 质量抽检）、架构师（6 问预裁 + 变更门控）
- **所属 Phase**：Phase 0
- **依赖任务**：T-P0-010 ✅（Pipeline 基础设施 + 真书 Pilot）、T-P0-011 ✅（跨 chunk 身份消歧）、T-P1-004 ✅（NER single-primary 约束）、T-P2-002 ✅（slug 分层白名单）、T-P1-002 ✅（name dedup）
- **创建日期**：2026-04-19
- **性质**：β 路线首次跨书、跨体裁摄入。identity_resolver 跨书归并压力测试。

---

## 目标（Why）

1. **数据**：摄入《尧典》《舜典》两篇到 persons / events / sources
2. **跨书归并**：验证 identity_resolver 把尚书里的"尧/帝尧/放勋"与五帝本纪已有的尧归并为同一 canonical
3. **体裁适配**：发现《尚书》典谟体特有的 NER 问题（官名嵌入、集合实体、训诂语言）
4. **不变量守住**：T-P1-004 single-primary / T-P2-002 slug / T-P1-002 name dedup 三条不变量全部通过

---

## 文本规模

| 篇目 | 段落数 | 字数 | 体裁 |
|------|--------|------|------|
| 尧典 | 7 | 619 | 虞书·典 |
| 舜典 | 20 | 1081 | 虞书·典 |
| **合计** | **27** | **1700** | — |

α 路线（五帝+夏+殷本纪）为 ~10k 字，β 约为 α 的 1/6。

---

## 6 问预裁（架构师批复 2026-04-19）

### Q-1 数据源 — 伪古文尚书分篇本（ctext fixtures）✅

**裁决**：采用伪古文尚书分篇本（十三经注疏本），ctext 默认即此版本。

- **理由**：后世注疏、《史记》摘引、乾嘉考据均基于此版本，上下游对照最方便；华典定位"知识入口"，选流传最广版本
- **硬约束**：`source_evidence.notes` 必须带 `version_note: 伪古文尚书（十三经注疏本）`
- **《舜典》古文序 28 字**（"曰若稽古帝舜，曰重华协于帝"）保留在正文，notes 标注"梅赜本古文补序"
- **《书序》段**：已剔除归档到 `_shushi_fragments.txt`，不进 NER 管线

### Q-2 分段策略 — 按自然段 ✅

ctext 段落划分即可。单篇 < 2000 字，无需拆分。

### Q-3 Prompt 版本 — v1-r3 起跑，设硬门槛 ✅

- **S-3a（5% smoke）**：取《尧典》第一段单独跑 NER，不入库，人工审
- **硬门槛**：
  - 官名误提取（司空/后稷/士/后/牧等）≥ 2 例 → 升 v1-r4
  - 已知人物漏提取（尧/舜/四岳个体成员）≥ 1 例 → 升 v1-r4
- **v1-r4 补丁目标（预研）**：
  - `X 作/为 Y`、`X 典 Y`、`X 司 Y` 句式下 Y 是官职不是人名
  - few-shot：`"禹作司空"` → person=禹，不提"司空"
- 如果 smoke 过，再跑全量

### Q-4 预期归并规模 — 干跑前必须 DB 定锚 ✅

- SQL 跑出 DB 现状对照表作为 S-4 dry-run 的"黄金答案"（见附录 A）
- **关键校验**：
  - 共工 vs 鲧 **必须保持独立**（两者在尧典/舜典中明确分述、分罚）
  - 伯益 vs 伯翳：β 文本使用"益"不涉及"伯翳"，R3 tongjia 暂不触发
  - 垂 vs 倕：tongjia.yaml 已有此条（垂→倕），R3 应正常触发
- 如果共工/鲧被错误归并 → **立即停 apply**

### Q-5 体裁标签 — book 关系足够，不加 genre 字段 ✅

book 关系 + source_evidence.notes 里 version_note 够用。schema 变更必须走 ADR，β 不开此口子。

### Q-6 四岳/十二牧 — 维持"群体不提取"+ load 层兜底 ✅

- 四岳（群体总称）→ 不提取
- 十二牧（群体总称）→ 不提取
- 四岳个体成员（羲仲、羲叔、和仲、和叔）→ 提取
- 误提取的官职名 → `is_likely_non_person()` 兜底
- `X 作 Y` 结构中 Y 是官职 → 不提取 Y

---

## 步骤

### S-0: 任务卡 + 6 问预裁 ✅

- [x] 6 问提交架构师裁决
- [x] 架构师批复
- [x] 任务卡创建（本文件）

### S-1: 文本源 + fixtures + DB 现状对照表 + 预期归并清单

- [x] S-1a: fixtures 准备（由用户完成）
  - `services/pipeline/tests/fixtures/sources/shangshu/yao_dian.txt`（7 段, 619 字）
  - `services/pipeline/tests/fixtures/sources/shangshu/shun_dian.txt`（20 段, 1081 字）
  - `services/pipeline/tests/fixtures/sources/shangshu/_shushi_fragments.txt`（书序归档）
  - Historian 确认：伪古文尚书分篇本；舜典序 28 字保留标注"梅赜本古文补序"
  - Debt 登记：`docs/debts/T-P0-006-beta-ctext-filter.md`
- [x] S-1b: ctext.py adapter 扩展
  - `_BOOK_META` 增加 `shangshu`（尚书，伪古文尚书分篇本）
  - `_CHAPTER_REGISTRY` 增加 `yao-dian` / `shun-dian`
  - `_CHAPTER_META` 增加章节元信息（volume=虞书）
  - `_FIXTURES_ROOTS` 双根目录支持（fixtures/ + tests/fixtures/）
  - 验证：`load_chapter('shangshu', 'yao-dian')` → 7 段 619 字 ✅
  - 验证：`load_chapter('shangshu', 'shun-dian')` → 20 段 1081 字 ✅
- [x] S-1c: DB 现状对照表 + 预期归并清单（见附录 A + B）

### S-2: Ingest（books upsert + raw_texts 分段入库）

- [ ] books 表 upsert shangshu（slug: `shangshu`）
- [ ] raw_texts 按段落写入（source_id: `ctext:shangshu/yao-dian` / `ctext:shangshu/shun-dian`）
- [ ] pipeline_runs 记录
- **⚠️ 完成后报告等待确认**

### S-3a: 5% smoke（尧典第一段）+ 人工审 NER 输出

- [ ] 取尧典 §1 单独跑 NER v1-r3，**不入库**
- [ ] 人工审核输出：
  - 官名误提取 ≥ 2 → 升 v1-r4
  - 已知人物漏提 ≥ 1 → 升 v1-r4
- **⚠️ smoke 结果报告等待确认**

### S-3b: Prompt 决策 + 全量 NER + load 入库

- [ ] 根据 S-3a 结果决定 v1-r3 或 v1-r4
- [ ] 全量 27 段 NER 抽取
- [ ] load 入 DB（persons / person_names / identity_hypotheses）
- [ ] 成本累计追踪
- **⚠️ 完成后报告等待确认**

### S-4: Dry-run identity resolver

- [ ] 跑 dry-run → 输出 expected vs actual 对比
- [ ] 校验预期归并清单（附录 B）
- [ ] **关键检查**：
  - 共工/鲧 归并 = ❌ false positive → **立即停**
  - 垂→倕 归并 = ✅ 预期（R3 tongjia）
  - 预期归并 F1 < 90% → 停下来调规则权重
- **⚠️ dry-run 结果报告等待确认**

### S-5: Historian 抽检（5/5 正确制）+ 红线协议 apply

- [ ] Historian 审 dry-run 结果
- [ ] 确认后走红线协议 apply：
  ```
  ⚠️ 需要确认：merge apply N 组归并
  📁 影响范围：persons / person_merge_log
  💥 后果：soft merge（可逆）
  🔄 回滚：person_merge_log 有完整记录
  是否继续？
  ```

### S-6: 3 条不变量验证 + CI 全绿

- [ ] single-primary（ADR-012）
- [ ] slug 分层白名单（ADR-011）
- [ ] name dedup UNIQUE（T-P1-002）
- [ ] ruff + basedpyright + pytest 全绿

### S-7: STATUS / CHANGELOG / 衍生债登记

- [ ] STATUS.md 更新
- [ ] CHANGELOG.md 追加
- [ ] 衍生债登记（如有）

---

## 成本预算

| 项目 | 预算 |
|------|------|
| 总 cap | $0.50 |
| 报警线 | $0.30（超出先停报告） |
| 单 chunk 上限 | $2.00（超出立即停止） |
| α 参考 | $1.77 / 3 books / 169 persons |
| β 预期 | ~$0.30（文本量约 α 的 1/6） |

---

## 红线

- ⚡ 真实 API 调用花钱 — S-3a smoke 前必须用户确认
- 🚫 `merge apply` 必须走红线协议
- 🚫 Prompt 版本号必须升级（v1-r3 → v1-r4 if needed），不覆盖已有 cache key
- 🚫 任何 DB schema 变更绝对禁止 — 走 ADR 流程
- 🚫 不触碰 CI Step 4c workaround（T-P1-005 另外处理）
- 🚫 共工/鲧被错误归并 → 立即停 apply
- 🚫 禁止 TRUNCATE / DROP / ALTER TABLE

---

## 风险表

| # | 风险 | 概率 | 影响 | 缓解 |
|---|------|------|------|------|
| 1 | v1-r3 对典谟体召回不足（漏人物） | 中 | 需升 v1-r4 | S-3a smoke 门槛 |
| 2 | 官名误提取（司空/后稷/士等） | 高 | 脏数据 | prompt 规则 + is_likely_non_person() |
| 3 | identity_resolver 过度归并 | 低 | 错误 merge | dry-run + historian 审 |
| 4 | 今文/古文版本差异 | 低 | 已裁决 | Q-1 锁定伪古文分篇本 |
| 5 | 舜典古文序 28 字 provenance | 低 | 数据真实性 | notes 标注"梅赜本古文补序" |
| 6 | Tier-S slug 白名单需扩列 | 低 | unicode hex slug | 可接受，后续 ADR-011 流程 |
| 7 | resolver 评分阈值跨书场景需调 | 中 | 误/漏归并 | S-4 dry-run F1 对照 |
| 8 | 伪古文版本裁决长期锁定 | 中 | 未来切换 | source_evidence.notes 带 version_note |
| 9 | 丹朱 vs 朱（胤子朱）部分匹配 | 中 | 漏归并 | S-4 对照清单标注 |

---

## LLM 配置

- 模型：`claude-sonnet-4-6`（AnthropicGateway 默认）
- Temperature: 0.0
- max_tokens: 4096
- 重试：3 次指数退避（Gateway 内置）

---

## 附录 A: DB 现状对照表（S-1c 产出）

> 以下为 2026-04-19 DB 快照，151 active persons 中与《尧典》《舜典》预期重叠的 25 条。

| slug | name_zh | DB all_names | dynasty |
|------|---------|-------------|---------|
| yao | 尧 | 尧, 帝, 帝尧, 放勋, 陶唐 | 上古 |
| shun | 舜 | 帝, 帝舜, 有虞, 舜, 虞帝, 虞舜, 重华 | 上古 |
| yu | 禹 | 伯禹, 夏后, 夏禹, 大禹, 姒, 帝禹, 文命, 禹 | 夏 |
| gao-yao | 皋陶 | 皋陶 | 上古 |
| xie | 契 | 契, 殷契 | 上古 |
| hou-ji | 后稷 | 后稷, 弃, 稷 | 上古 |
| yi | 益 | 益 | 上古 |
| gong-gong | 共工 | 共工 | 上古 |
| gun | 鲧 | 鲧 | 上古 |
| u9a69-u515c | 驩兜 | 欢兜, 驩兜 | 上古 |
| dan-zhu | 丹朱 | 丹朱 | 上古 |
| fang-qi | 放齐 | 放齐 | 上古 |
| xi-zhong | 羲仲 | 羲仲 | 上古 |
| xi-shu | 羲叔 | 羲叔 | 上古 |
| he-zhong | 和仲 | 和仲 | 上古 |
| he-shu | 和叔 | 和叔 | 上古 |
| chui | 倕 | 倕 | 上古 |
| kui | 夔 | 夔 | 上古 |
| long | 龙 | 龙 | 上古 |
| gu-sou | 瞽叟 | 瞽叟 | 上古 |
| xiang | 象 | 象 | 上古 |
| bo-yi | 伯夷 | 伯夷 | 上古 |
| u6731-u864e | 朱虎 | 朱虎 | 上古 |
| u718a-u7f74 | 熊罴 | 熊罴 | 上古 |
| shang-jun | 商均 | 商均, 舜之子商均 | 上古 |

---

## 附录 B: 预期归并清单（S-4 dry-run 黄金答案）

### B-1: 预期跨书归并（should merge）

| # | 尚书 NER 预期 name_zh | 尚书预期 surface_forms | DB 已有 slug | 预期规则 | 备注 |
|---|---------------------|----------------------|-------------|---------|------|
| 1 | 尧 | 帝尧, 放勋, 帝 | yao | R1 surface | 尧典 §1-§7。尧典全文"尧"字 0 次独立出现；依赖 load.py tie-break promote"帝尧"为 primary，R1 surface match 合并到 DB yao |
| 2 | 舜 | 帝舜, 重华, 虞舜, 舜 | shun | R1 surface | 尧典 §7 + 舜典全篇 |
| 3 | 禹 | 伯禹, 禹 | yu | R1 surface | 舜典 §9 |
| 4 | 皋陶 | 皋陶 | gao-yao | R1 surface | 舜典 §9, §12 |
| 5 | 契 | 契 | xie | R1 surface | 舜典 §9, §11 |
| 6 | 弃/后稷 | 弃, 后稷, 稷 | hou-ji | R1 surface | 舜典 §9, §10 |
| 7 | 益 | 益 | yi | R1 surface | 舜典 §14 |
| 8 | 共工 | 共工 | gong-gong | R1 surface | 尧典 §4 + 舜典 §6 |
| 9 | 鲧 | 鲧 | gun | R1 surface | 尧典 §5 + 舜典 §6 |
| 10 | 驩兜 | 驩兜 | u9a69-u515c | R1 surface | 尧典 §4 + 舜典 §6 |
| 11 | 放齐 | 放齐 | fang-qi | R1 surface | 尧典 §3 |
| 12 | 羲仲 | 羲仲 | xi-zhong | R1 surface | 尧典 §2 |
| 13 | 羲叔 | 羲叔 | xi-shu | R1 surface | 尧典 §2 |
| 14 | 和仲 | 和仲 | he-zhong | R1 surface | 尧典 §2 |
| 15 | 和叔 | 和叔 | he-shu | R1 surface | 尧典 §2 |
| 16 | 垂 | 垂 | chui | R3 tongjia | 舜典 §13；tongjia.yaml: 垂→倕 |
| 17 | 夔 | 夔 | kui | R1 surface | 舜典 §15, §16 |
| 18 | 龙 | 龙 | long | R1 surface | 舜典 §15, §17 |
| 19 | 象 | 象 | xiang | R1 surface | 尧典 §7 "象傲" |
| 20 | 朱虎 | 朱虎 | u6731-u864e | R1 surface | 舜典 §14 |
| 21 | 熊罴 | 熊罴 | u718a-u7f74 | R1 surface | 舜典 §14 |
| 22 | 伯夷 | 伯夷, 伯 | bo-yi | R1 surface | 舜典 §15 |

### B-2: 可能归并（需 NER 输出确认）

| # | 问题 | 原文 | 可能映射 | 备注 |
|---|------|------|---------|------|
| A | 丹朱 vs 朱 | 尧典 §3 "胤子朱启明" | dan-zhu | NER 可能提取"朱"或"胤子朱"，与 DB "丹朱" 非精确匹配；R1 可能不触发 |
| B | 瞽叟 vs 瞽子 | 尧典 §7 "瞽子，父顽" | gu-sou | "瞽子"=瞽叟之子（指舜），NER 可能不提取瞽叟 |

### B-3: 预期新增 person（should NOT merge）

| # | name_zh | 预期 surface_forms | 来源段落 | 备注 |
|---|---------|-------------------|---------|------|
| 1 | 殳斨 | 殳斨 | 舜典 §13 | "让于殳斨暨伯与" |
| 2 | 伯与 | 伯与 | 舜典 §13 | "殳斨暨伯与" |

### B-4: 绝对不可归并（false positive guard）

| # | Person A | Person B | 原因 |
|---|----------|----------|------|
| 1 | 共工 (gong-gong) | 鲧 (gun) | 尧典 §4-§5 分述、舜典 §6 分罚（"流共工于幽洲""殛鲧于羽山"） |
| 2 | 朱 (胤子朱) | 朱虎 | "朱"是丹朱的省称，"朱虎"是舜臣 |

### B-5: 不提取实体（NER 应跳过）

| # | 文本 | 类型 | 规则 |
|---|------|------|------|
| 1 | 四岳 | 群体总称 | "群体性称谓不提取" |
| 2 | 十二牧 | 群体总称 | 同上 |
| 3 | 三苗 | 部族 | "部族/国族不提取" |
| 4 | 羲和 | 合称 | 下文有分称（羲仲/羲叔/和仲/和叔），合称不建 person |
| 5 | 司空/司徒/秩宗/纳言 | 官职名 | "X 作 Y"中 Y 是官职 |
| 6 | 百揆 | 官职总称 | 非人名 |

### B-6: tongjia.yaml 核查结果

| 条目 | 状态 | 备注 |
|------|------|------|
| 垂→倕 | ✅ 已有 | tongjia.yaml entries[0]，R3 应正常触发 |
| 伯翳→伯益 | ⚠️ 未注册 | β 文本使用"益"不涉及"伯翳"，暂不阻塞；周本纪/秦本纪扩量时需补 |
| 方齐→放齐 | ✅ 已有 | tongjia.yaml entries[2]，但 β 文本用"放齐"不触发 |

---

## Commit 风格

```
# S-1（1 commit）
feat(pipeline): T-P0-006-β S-1 — shangshu ctext adapter + task card

# S-2
feat(pipeline): T-P0-006-β S-2 — ingest 尧典+舜典 (27 paragraphs)

# S-3
feat(pipeline): T-P0-006-β S-3 — NER extract 尧典+舜典 (v1-r3|v1-r4)

# S-4
feat(pipeline): T-P0-006-β S-4 — identity resolver dry-run (N merges)

# S-5
feat(pipeline): T-P0-006-β S-5 — merge apply (N groups)

# S-6~S-7
docs: T-P0-006-β close — STATUS + CHANGELOG
```
