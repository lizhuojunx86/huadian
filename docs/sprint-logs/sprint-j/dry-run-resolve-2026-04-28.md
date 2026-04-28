# Sprint J Stage 3 Dry-Run Report — 高祖本纪 Identity Resolver

- **日期**: 2026-04-28
- **DB 快照**: Sprint J Stage 2 收口（748 active persons / merge_log 92 / V1-V11 全绿）
- **运行 ID**: c9f9a1d8-37e9-452c-8124-e61e4fb2ba03
- **脚本**: `services/pipeline/scripts/dry_run_resolve.py`
- **baseline**: Sprint I 收口 (663 active, 16 guard blocks)

---

## 核心数字

| 指标 | Sprint I (Sprint I 收口) | Sprint J (本次) | 差值 |
|------|--------------------------|-----------------|------|
| Active persons | 663 | 748 | +85 |
| 总 guard 拦截 | 16 | **18** | +2 |
| cross_dynasty 拦截 | 9 | **11** | +2 |
| state_prefix 拦截 | 7 | **7** | 0 |
| Merge proposals (23 组) | 7 组 | **23 组** | +16 |
| R1 proposal pairs | — | 38 | — |
| 合并后预计人数 | 655 | 717 | +62 |

> **+16 merge proposals** 主要来自高祖本纪新人中：重名实同人对（刘太公↔太公, 英布↔黥布, 陈胜↔陈涉等）和 slug 重复对（纪信、武涉、郑昌、陆贾、田横 tier-s pinyin 与 unicode 两个 slug 共存）。

---

## Guard 拦截明细（18 对）

### cross_dynasty（11 对）

| # | Person A | Dynasty A | Person B | Dynasty B | gap |
|---|----------|-----------|----------|-----------|----:|
| 1 | 周成王 | 西周 | 楚成王 | 春秋 | 286yr |
| 2 | 秦康公 | 西周 | 密康公 | 春秋 | 286yr |
| 5 | 楚灵王 | 西周 | 灵王 | 春秋 | 286yr |
| 6 | 秦庄公 | 春秋 | 齐庄公 | 西周 | 286yr |
| 7 | 齐简公 | 春秋 | 秦简公 | 战国 | 275yr |
| 11 | 吕后 | 春秋 | 秦穆公夫人 | 西汉 | 526yr ⚠️ |
| 12 | 灵公 | 春秋 | 晋灵公 | 战国 | 275yr |
| 15 | 楚王 | 春秋 | 楚昭王 | 战国 | 275yr |
| 16 | 楚怀王 | 春秋 | 楚昭王 | 战国 | 275yr |
| 17 | 熊心 | 春秋 | 楚昭王 | 秦末 | 415yr |
| 18 | 刘盈 | 战国 | 秦惠文王 | 西汉 | 251yr ⚠️ |

**Sprint I → Sprint J 新增 +2 blocks（⚠️）：**
- **拦截 11**: 吕后(春秋) ↔ 秦穆公夫人(西汉) — 526yr。**NER dynasty 标记 bug**：吕后应标 `西汉`，秦穆公夫人应标 `春秋`。两者确实是不同人，block 正确，但 dynasty 标记需修复（historian 追踪）。
- **拦截 18**: 刘盈(战国) ↔ 秦惠文王(西汉) — 251yr。**NER dynasty 标记 bug**：刘盈（孝惠帝）应标 `西汉`，秦惠文王应标 `战国`。两者确实是不同人，block 正确，但 dynasty 标记需修复。

这两条新拦截由 NER 对高祖本纪人物的 dynasty 误标引入，guard 行为正确（拦住了 FP），但 dynasty label 本身有错。归入 **historian review 队列**。

### state_prefix（7 对）——与 Sprint I 相同，高祖本纪无新增

| # | Person A | Person B | State A | State B |
|---|----------|----------|---------|---------|
| 3 | 鲁桓公 | 秦桓公 | 鲁 | 秦 |
| 4 | 齐悼公 | 晋悼公 | 齐 | 晋 |
| 8 | 齐襄公 | 秦襄公 | 齐 | 秦 |
| 9 | 晋襄公 | 秦襄公 | 晋 | 秦 |
| 10 | 齐襄公 | 晋襄公 | 齐 | 晋 |
| 13 | 晋灵公 | 秦灵公 | 晋 | 秦 |
| 14 | 齐平公 | 晋平公 | 齐 | 晋 |

高祖本纪（西汉初）无春秋诸侯新人，state_prefix 拦截数量与 Sprint I 完全相同。

---

## R1 跨国 FP 治理率（Sprint G→J 目标 ≥90%）

**治理率定义**：以"国名+谥号"命名模式（如 鲁桓公 / 齐平公）且跨国（不同 state 前缀）的 R1 潜在 FP 对中，被 state_prefix_guard 正确拦截的比例。

| 时间点 | 跨国名称模式 blocked | 跨国名称模式 unblocked（进入 proposals） | 治理率 |
|--------|---------------------|----------------------------------------|--------|
| Sprint G（秦γ，pre guard） | 0 | ~5 | 0% |
| Sprint H（项羽δ，pre guard） | 0 | ~8 | 0% |
| Sprint I（state_prefix 上线） | 7 | 0 | **100%** |
| **Sprint J（高祖本纪）** | **7** | **0** | **100% ✅** |

> **结论**: R1 跨国 FP 治理率 = **100%**，超过 ≥90% 目标。  
> 高祖本纪为西汉初题材，无新增春秋诸侯人物，state_prefix 拦截集合不变。  
> ADR-025 §5.3 state_prefix_guard 设计目标在 Sprint G→J 全章节验证中达成。

---

## Merge Proposals（23 组，建议入 historian review）

### 明确合理 proposals（legitimate same-person pairs）
| 组 | 合并对 | 规则 | 共享 surface | 性质 |
|----|--------|------|-------------|------|
| 3 | 子婴 ↔ 秦王 | R1 | 秦王 | 同人（秦末降王） |
| 8 | 嬴政 ↔ 始皇帝 | R1 | 始皇帝 | 同人 |
| 9 | 胡亥 ↔ 二世 ↔ 秦二世 | R1 | 二世 | 同人 |
| 11 | 陈胜 ↔ 陈涉 | R1 | 陈涉/陈王 | 同人 |
| 12 | 英布 ↔ 黥布 | R1 | 黥布 | 同人 |
| 15 | 赵歇 ↔ 赵王歇 | R1 | 赵王歇 | 同人 |
| 16 | 纪信(ji-xin) ↔ 纪信(unicode) | R1 | 纪信 | slug 重복（tier-s + unicode 共存） |
| 17 | 魏豹 ↔ 魏王豹 | R1 | 魏王豹 | 同人 |
| 18 | 郑昌(pinyin) ↔ 郑昌(unicode) | R1 | 郑昌 | slug 重복 |
| 19 | 田横(pinyin) ↔ 田横(unicode) | R1 | 田横 | slug 重複 |
| 20 | 刘太公(pinyin) ↔ 刘太公(unicode) ↔ 太公 | R1 | 刘太公/太公 | slug 重複 + T-P1-004 多 load |
| 21 | 吕后 ↔ 吕雉 | R1 | 吕后 | 同人 |
| 22 | 武涉(pinyin) ↔ 武涉(unicode) | R1 | 武涉 | slug 重複 |
| 23 | 陆贾(pinyin) ↔ 陆贾(unicode) | R1 | 陆贾 | slug 重複 |

### 需 historian 仲裁的 proposals
| 组 | 合并对 | 规则 | 共享 surface | 问题 |
|----|--------|------|-------------|------|
| 1 | 周成王 ↔ 成 | R1 | 成 | 单字 NER artifact，historian reject 预期 |
| 2 | 秦惠公 ↔ 惠公 | R1 | 惠公 | 裸谥号，historian 核实 |
| 4 | 晋惠公 ↔ 晋襄公 | R1 | 晋君 | 同国同朝但不同人？historian 核实 |
| 5 | 秦怀公 ↔ 怀公 | R1 | 怀公 | 裸谥号 |
| 6 | 秦灵公 ↔ 灵公 | R1 | 灵公 | 裸谥号 |
| 7 | 熊心 ↔ 楚王 ↔ 楚怀王 ↔ 怀王 ↔ 义帝 | R1 | 楚王/怀王/义帝 | 熊心即义帝，T-P0-031 entity-split 已处理楚怀王，historian 复核 |
| 10 | 司马欣 ↔ 董翳 | R1 | 塞王欣 | **FP**（不同人；塞王欣是司马欣的职衔，非共享 identity） |
| 13 | 田广 ↔ 田荣 ↔ 田广 ↔ 韩信 ↔ 齐王 | R1 | 齐王 | **FP**（韩信与田氏是不同人，均称"齐王"于不同时期） |
| 14 | 宋义 ↔ 卿子冠军 | R1 | 卿子冠军 | 卿子冠军是宋义职衔，同人，historian 确认 |

**slug 重複对（组 16/18/19/22/23）**：5 对因 Stage 0 新增 tier-s slug 导致 pinyin-slug 与 unicode-slug 并存，需 load 层修复（Stage 4/5 scope）。

---

## Stop Rule 检查

| Rule | 条件 | 本次 | 触发？ |
|------|------|------|--------|
| #1 V1/V9 ≠ 0 | V1=0/V9=0 | 0/0 | ❌ |
| #2 cost > $1.80 | $0.79 | — | ❌ |
| #3 new persons > 120 | +85 (9 smoke + 76 full) | < 120 | ❌ |
| #4 FP 治理率 < 70% | 100% | ≥ 90% | ❌ |
| #5 NER regression | v1-r5 无原有章节新违例 | — | ❌ |
| #6 V invariant regression | V8/V9/V10/V11 全绿 | — | ❌ |

**全部 stop rules 通过。**

---

## 待 historian review 项目

1. **slug 重複 5 对**（组 16/18/19/22/23）→ load 层修复（Stage 4/5）
2. **FP proposals** 2 对（组 10 司马欣↔董翳 / 组 13 田广↔韩信）→ historian reject
3. **NER dynasty bug** 2 个（吕后 dynasty=春秋 / 刘盈 dynasty=战国）→ T-P0-031 data fix
4. **裸谥号 proposals** 4 对（组 2/5/6/14）→ historian 逐一审核

---

## 结论

Sprint J Stage 3 通过。R1 跨国 FP 治理率达 **100%**，超过 ≥90% 目标。
state_prefix_guard (ADR-025 §5.3) 在全链路（五帝→高祖本纪）验证完毕。
Stage 4/5 待 historian 仲裁完成后推进。
