# Identity Resolver Dry-Run Report — T-P0-006-delta (项羽本纪)

- **Date**: 2026-04-25
- **Run ID**: b2d0d357-a256-433e-8da6-7b8c24cb1254
- **Pipeline Engineer**: PE (Sonnet 4.6 trial)
- **Status**: Awaiting historian review (Stage 4 BLOCKED per Stop Rule #4: new_persons=117 > 80)

---

## 1. Ingest Summary

| Metric | Value |
|--------|-------|
| Chapter | 史记·项羽本纪 (shiji-xiang-yu-ben-ji) |
| Paragraphs | 45 (5 smoke + 40 stage2) |
| NER prompt | v1-r5 |
| LLM cost | $0.0607 (smoke) + $0.5427 (stage2) = **$0.6034 total** |
| Tokens | ~14,015 in + 37,422 out (total) |
| Active persons before | 555 |
| Active persons after | 672 (+117 new) |
| V1 post-ingest | 0 ✅ |
| V9 post-ingest | 0 ✅ |
| V1-V11 all | GREEN ✅ |

---

## 2. Merge Proposals (21 groups, 29 merges)

### 2.1 规则命中分布

| 规则 | 命中次数 |
|------|---------|
| R1 表面形式重叠 | 31 |
| R3 通假字 | 1 |
| **合计** | **32** |

### 2.2 R6 Seed Pre-pass 分布

| 状态 | 人物数 |
|------|--------|
| matched (Wikidata) | 153 |
| not_found | 513 |
| below_cutoff | 6 |
| ambiguous | 0 |
| **cross-dynasty guard blocked** | **0** ✅ |
| **总计** | **672** |

cross-dynasty guard = 0：楚汉同时段（秦末/秦末汉初/西汉），与 brief 预期一致（Stop Rule 阈值为 >3）。

### 2.3 Cross-Chapter Persons

跨章节人物（在 史记·项羽本纪 AND 其他章节均有证据）：

| 人物 | slug | dynasty | 出现章节 |
|------|------|---------|---------|
| 楚怀王 | u695a-u6000-u738b | 战国 | 史记·秦本纪, 史记·项羽本纪 |

注：19 个被更新（updated）的人物（Stage 2 load result）不一定都有双章节 source_evidence，取决于 load.py 是否创建了新 source_evidence 行。

---

## 3. 全量 Merge Proposals 分析

### 3.1 高置信度正确合并（historian 建议 APPROVE）

| 组 | 人物 | 理由 |
|----|------|------|
| 15 | 项羽 + 项籍 | 项羽名籍，字羽；显著正确 |
| 16 | 项梁 + 武信君 | 项梁被封武信君；显著正确 |
| 17 | 陈胜 + 陈王 | 陈胜起义后称陈王；显著正确 |
| 19 | 韩成 + 韩王成 | 韩成即韩王成，同人异称；正确 |
| 20 | 刘太公 + 太公 | 刘邦之父，语境确定；正确 |
| 21 | 吕雉 + 吕后 | 同人，史记固定称谓；正确 |
| 2 | 周穆王 + 穆王 | R3 通假字 缪→穆；正确 |

### 3.2 需要 historian 精审（可能 FALSE POSITIVE）

**Group 1: 周成王 + 成 + 楚成王**
- 规则: R1 (surface form "成" / "成王")
- 问题: 周成王 (西周初，约前 1042-前 1021) vs 楚成王 (春秋楚国，约前 671-前 626) — 两人相差约 400 年，断然不同
- 建议: REJECT，全部独立保留

**Group 3: 秦康公 + 密康公**
- 规则: R1 (surface form "康公")
- 问题: 秦康公 (秦国) vs 密康公 (密国) — 不同诸侯国国君
- 建议: REJECT

**Group 4: 鲁桓公 + 秦桓公**
- 规则: R1 (surface form "桓公")
- 问题: 鲁桓公 vs 秦桓公 — 不同诸侯国国君
- 建议: REJECT

**Group 5: 晋悼公 + 齐悼公**
- 规则: R1 (surface form "悼公")
- 问题: 晋悼公 (晋国) vs 齐悼公 (齐国) — 不同诸侯国国君
- 建议: REJECT

**Group 6: 灵王 + 楚灵王**
- 规则: R1 (surface form "灵王")
- 问题: 需要确认语境中"灵王"是否特指楚灵王
- 建议: 可能正确，historian 判断语境

**Group 7: 秦庄公 + 齐庄公**
- 规则: R1 (surface form "庄公")
- 问题: 秦庄公 (秦国) vs 齐庄公 (齐国) — 不同诸侯国国君
- 建议: REJECT

**Group 8: 秦简公 + 齐简公**
- 规则: R1 (surface form "简公")
- 建议: REJECT（同类问题）

**Group 9: 秦惠公 + 惠公**
- 规则: R1 (surface form "惠公")
- 问题: "惠公"在秦本纪语境中若特指秦惠公则可合并；需要historian确认
- 建议: historian 审核语境

**Group 10: 晋惠公 + 秦襄公 + 齐襄公 + 晋襄公**
- 规则: R1 (多重 surface form 重叠："襄公"/"晋君")
- 问题: 四人都是不同诸侯国国君，此 4 人合并一组极大概率全为 false positive
- 建议: REJECT 全部；如"晋君"特指晋惠公可单独评估

**Group 11: 晋灵公 + 灵公 + 秦灵公**
- 规则: R1 (surface form "灵公" × 3)
- 建议: REJECT（同类跨国谥号问题）

**Group 12: 晋平公 + 齐平公**
- 规则: R1 (surface form "平公")
- 建议: REJECT

**Group 13: 楚怀王 + 楚昭王 + 楚王 + 熊心 + 怀王 + 义帝**
- 规则: R1 (多重"楚王"/"楚怀王"/"怀王"/"义帝"重叠)
- 分析:
  - 熊心 = 怀王 = 义帝 ← **同一人，秦末楚怀王熊心**，正确合并
  - 楚王 (泛称) 可能正确合并进楚怀王
  - 楚昭王 (战国楚国，约前 515-前 489) ≠ 楚怀王熊心 (秦末) — **错误合并**
- 建议: SPLIT，只合并 {熊心, 怀王, 义帝, (楚怀王如指秦末)}，将楚昭王独立保留

**Group 14: 秦怀公 + 怀公**
- 规则: R1 (surface form "怀公")
- 问题: 语境中"怀公"若特指秦怀公则可合并
- 建议: historian 确认

**Group 18: 韩信 + 田荣**
- 规则: R1 (surface form "齐王")
- 问题: **严重 false positive** — 韩信(淮阴侯, 被封齐王) vs 田荣(齐国贵族, 也称齐王) — 完全不同的人
- 建议: REJECT

### 3.3 Hypothesis Queue (score 0.5-0.9)

0 个 hypothesis proposals。无低置信度候选。

---

## 4. Dynasty Distribution (项羽本纪 persons)

| Dynasty | Count |
|---------|-------|
| 秦末 | 64 |
| 秦末汉初 | 23 |
| 西汉 | 20 |
| 秦 | 6 |
| 战国 | 4 |
| 战国末秦初 | 1 |
| **合计** | **118** |

---

## 5. New Persons Sample (首见于项羽本纪，前 25 位)

义帝, 乌江亭长, 二世, 侯公, 候始成, 共敖, 刘太公, 刘盈, 刘贾, 刘邦, 卿子冠军, 召平, 司马卬, 司马欣, 司马龙且, 吕后, 吕胜, 吕臣, 吕雉, 吕青, 吕马童, 吴芮, 周吕侯, 周殷, 周生 ... 共 117 人

注意:
- 吕后 和 吕雉 已在 merge proposals Group 21 中建议合并
- 刘邦 (liu-bang) 使用 tier-s pinyin slug ✅
- 刘盈 (刘太公之子，惠帝) 与 刘太公 是两个不同人，已分别入库

---

## 6. T-P1-004 Auto-Promotion Notes

以下人物触发了 CRITICAL auto-promotion（name_zh 不在 surface_forms 中）：
| name_zh | promoted_to | 说明 |
|---------|-------------|------|
| 熊心 | 楚怀王 | 史记以"楚怀王"指义帝，熊心是其本名 |
| 刘邦 | 汉王/沛公 | 楚汉时期文本以职衔称呼 |
| 韩成 | 韩王成 | 全称替代简称 |
| 田建 | 齐王建 | 全称替代简称 |
| 刘盈 | 孝惠 | 谥号替代本名 |
| 刘太公 | 太公 | 省略"刘" |
| 吕雉 | 吕后 | 后期称号替代本名 |
| 司马迁 | 太史公 | 太史公曰自称 |

这些均属正常 NER 行为（canonical name vs text surface form 不匹配）。T-P1-004 auto-promotion 机制正常运作。

---

## 7. PE Notes for Historian

1. **优先审核** Groups 15-21（楚汉核心人物，最重要）
2. **建议批量拒绝** Groups 1-8, 10-12（跨国同谥号 false positive，共约 12-15 个 reject 决定）
3. **重点关注** Group 13（楚怀王 cluster，需要 split）和 Group 18（韩信+田荣，建议 reject）
4. Group 9/14/6 需要 historian 判断语境
5. **Stop Rule #4 已触发**（117 > 80）：Stage 4 apply 须等 historian 完整审核后，由架构师 ACK 才执行

---

## 8. Stop Rule 状态

| Stop Rule | 状态 | 值 |
|-----------|------|-----|
| #1 V1≠0 | ✅ 未触发 | V1=0 |
| #2 V9≠0 | ✅ 未触发 | V9=0 |
| #3 cost>$1.50 | ✅ 未触发 | $0.60 |
| #4 new_persons>80 | ⚠️ **触发** | 117>80；Stage 4 等 historian ACK |
| #5 R6 guard>3 | ✅ 未触发 | guard_blocked=0 |
| #6 v1-r5 regression | ✅ 未触发 | 输出质量正常 |
| #7 any V invariant | ✅ 未触发 | V1-V11 all green |
