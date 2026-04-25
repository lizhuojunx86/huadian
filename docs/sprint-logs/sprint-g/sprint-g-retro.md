# Sprint G Retro — T-P0-006-δ 项羽本纪

- **Sprint**: G
- **日期**: 2026-04-25 ~ 2026-04-26
- **角色**: 管线工程师（Sonnet 4.6 试用）+ 古籍专家 + 首席架构师
- **关联 Sprint brief**: docs/sprint-logs/sprint-g/stage-0-brief-2026-04-25.md

---

## §1 Sprint 结果摘要

| 指标 | Sprint F 收口 | Sprint G 收口 | delta |
|------|--------------|--------------|-------|
| Active persons | 555 | 663 | +108 净增 |
| Merge log | 83 | 92 | +9 |
| NER persons (new chapter) | — | +117 | — |
| LLM cost | $0.163 | $0.60 | — |
| V1 | 0 | 0 | ✅ |
| V9 | 0 | 0 | ✅ |
| V10 | 0/0/0 | 0/0/0 | ✅ |
| V11 | 0 | 0 | ✅ |
| Merge proposals | — | 21 | — |
| Approve/Reject/Split | — | 7/13/1 | — |
| Actual apply | — | 9 | — |
| New chapter | — | 史记·项羽本纪（45 段） | — |

---

## §2 Sprint F 修复真实生产验证（核心结论）

**这是本 sprint 最重要的工程结论：Sprint F load.py 修复有效性在真实楚汉数据上得到验证。**

Sprint G brief 将"V1/V9 在新数据上保持 0"列为核心 Stop Rule（#1 和 #2）。
smoke (5 段) 后 V1=0、V9=0；full ingest（45 段，117 persons）后 V1=0、V9=0。

- **Bug 1 修复验证**：楚汉 NER 输出包含大量 name_zh/surface_forms 分离的人物（刘邦/吕雉/韩成/熊心等），Sprint F _insert_person_names 修复正确处理了这些 CRITICAL auto-promotion 场景，不产生多 primary 违规
- **Bug 2 修复验证**：designated primary surface_form 的 is_primary=true 逻辑在楚汉人物 117 位中全部正确执行，0 V9 违规
- **结论**：Sprint F 修复是完整的（覆盖了所有 NER 输出路径）；V1 线性增长问题已从根源封堵

---

## §3 Sprint G 最大架构发现：楚怀王同号异人（T-P0-031）

### 问题描述

中国历史上有两个"楚怀王"：
- **熊槐**（战国，约前328–前296在位）：《史记·秦本纪》已有 entity（dynasty=战国）
- **熊心**（秦末，?–前206）：项梁借前者声望立其为"楚怀王"，项羽本纪中的"楚怀王"指此人

干跑 cross-chapter 表发现：现有"楚怀王"entity（slug=u695a-u6000-u738b，dynasty=战国）同时出现在秦本纪和项羽本纪——即项羽本纪的"楚怀王"mentions 被错误归入战国楚怀王·熊槐。

### 为什么 R1 无法检测此类问题

R1 surface match 只处理两类情况：
1. **跨国同谥号**（秦γ 大量处理）：不同诸侯国国君共用同一谥号（桓公/灵公等）
2. **同人多称**（本 sprint 的 7 approve 组）：同一人的不同称呼

但楚怀王问题属于**第三类——同国同号跨时代**：不同时代的同一国的两个人恰好使用相同称号。
R1 在全量扫描时不区分这两位楚怀王，将秦本纪和项羽本纪的"楚怀王" mentions 归入同一 entity。
这是 R1 surface match 框架的固有限制，需要 mention-level 消歧基础设施（historian 介入 + entity-level split）。

### Sprint G retro 记为"最大架构发现"的原因

1. 这不是 NER 错误（两本纪的 NER 各自正确）
2. 这不是 R1 规则错误（R1 按设计工作）
3. 这是 entity 层面的建模问题：同号异人需要两个 entity，但当前基础设施没有"同号歧义检测"机制
4. **V12 候选**（architect 注）：可考虑"同号异人跨时段 entity 完整性检查"作为新 invariant

### 处置决策

Stage 4 仅 apply 安全子合并（怀王→熊心，义帝→熊心）。
楚怀王 entity-level split（entity 拆分 + source_evidence redirect）升格为独立 task card T-P0-031（P0）。

---

## §4 textbook-fact Precedent 计数与 Convention 说明

### §4.1 当前计数：2/3 阈值

| 案例 | 关系 | Commit | Rule |
|------|------|--------|------|
| #1 重耳 → 晋文公 | 本名 → 庙号/通称 | bdb8941 (Sprint F) | manual_textbook_fact |
| #2 项籍 → 项羽 | 名 → 字（通行称呼）| e83a7a3 (Sprint G) | manual_textbook_fact |

**第 3 个 manual_textbook_fact 案例出现时，必须起草 ADR-014 addendum**，明确 textbook-fact 的判定标准、canonical 选择规则、与其他 merge rule 的优先级关系。

### §4.2 historian-override Convention（架构师记录）

G13 楚怀王 cluster 的 canonical 选择：historian 选择**熊心**（本名）而非义帝（posthumous title）。

这与 T-P1-025 先例（重耳→晋文公；晋文公 = posthumous title 优先于本名 重耳）有轻微偏离。

**登记如下**：
- G13 canonical=熊心 是 historian 领域判定 override T-P1-025 convention（personal-name vs posthumous-title）
- historian 的理由：义帝是项羽的政治操作，传统史学未必视为正式庙号；熊心是史记明载本名
- **未来同类 case 的默认规则**：仍应优先遵循 T-P1-025 convention（posthumous title 作为 canonical），需要 historian override 时，historian 必须在 review 报告中显式标注 override 理由
- 这条记录是为了防止 PE 错误推广为"personal name 总是 canonical"

---

## §5 Sonnet 4.6 PE 试用评估（架构师视角）

Sprint G brief §8 注明本 sprint 是检测 PE 角色用 Sonnet 4.6 是否胜任的试用场景。

### §5.1 正面观察

| 观察 | 具体表现 |
|------|---------|
| 数字精度 | 预期 663 = 672 - 9，实际 663；merge_log 预期 92 = 83 + 9，实际 92；完全精确 |
| 澄清主动性 | Stage 4 前主动澄清 G13 canonical 和 pg_dump 路径两个关键问题，而非自行推断 |
| Stop Rule 遵守 | Stop Rule #4 触发（117>80）正确识别并等待 historian ACK |
| 干跑 vs apply 区分 | 无提前 apply 倾向；正确识别 T-P0-031 不在本 sprint 范畴 |
| TodoList 对齐度 | Stage 4/5 TodoList 与 brief 规格高度对齐 |
| 脚本质量 | apply 脚本与 γ 版本风格一致，G2 的"满"entity 说明注释准确 |

### §5.2 反面观察（历史）

| 观察 | Sprint 来源 |
|------|------------|
| dry-run 报告姓名列表有少量错误（历史 session）| Sprint G Stage 3 |

### §5.3 总评估

Sonnet 4.6 在 PE 角色的 **Stage 4/5 执行（本会话）表现良好**：
- 数字精确、边界 case 捕捉正确、脚本格式规范
- 主动澄清两个关键决策（G13 canonical + dump 路径），体现了"不自行推理关键选择"的正确姿态
- 无 yellow flag 触发（本会话）

综合 Stage 0-3（历史 session，Sonnet 4.5）和 Stage 4-5（本会话，Sonnet 4.6）的全 sprint 表现：
**Sonnet 4.6 可以胜任 PE 角色的内容产出 sprint，但历史 session 的 dry-run 报告质量（姓名列表精度）是潜在关注点。**
建议：下一 ingest sprint 继续使用 Sonnet 4.6，重点观察 Stage 3 dry-run 报告的 entity ID 精度。

---

## §6 R1 False Positive 延续与 T-P1-028 优先级评估

### §6.1 数据

| Sprint | 总 proposals | Reject | Reject 率 | 跨国同名 FP |
|--------|-------------|--------|----------|------------|
| γ 秦本纪 | 35 | 5 reject + 9 split | ~40% | 约 14 组 |
| δ 项羽本纪 | 21 | 13 reject + 1 split | ~67% | 12 组（秦γ 残留）+ 1 组（新） |

**项羽本纪的 13 个 reject 中，12 个是秦γ 已裁决过的残留**——每次全量 resolver 扫描都会重新产生，historian 需要重复审核。

### §6.2 建议

T-P1-028（R1 dynasty 前置过滤）的优先级应提升。评估方案 C（跨国谥号黑名单）成本最低，可在不影响正常合并的前提下消除大多数跨国 FP。具体黑名单条目：桓、灵、惠、庄、简、悼、平、成、康、宣、穆、昭 等。

---

## §7 架构师本侧改进项（来自 brief 路径 typo）

Sprint G brief（stage-0-brief-2026-04-25.md）§S4.1 写"ops/dumps/"，实际项目 convention 是"ops/rollback/"。
PE 在执行前主动询问，避免了路径错误。

**改进项**：未来 sprint brief 中统一使用"ops/rollback/"；brief 模板中添加路径 glossary 部分，避免 PE 需要逐次澄清。

---

## §8 下一步建议

| 优先级 | 任务 | 理由 |
|--------|------|------|
| 🔴 P0 | T-P0-031 楚怀王 entity-split | 数据正确性 critical；项羽本纪 mentions 错误归入战国楚怀王 entity |
| 🟡 P1 | T-P1-028 R1 dynasty 前置过滤 | 每次 ingest 都会产生大量 historian 重复审核工作量 |
| 🟡 P1 | T-P1-027 disambig_seeds 楚汉扩充 | 下一楚汉人物 sprint 前完成，减少新的 FP |
| 🟡 中 | T-P0-028 pending_review triage UI | 楚汉人物 Wikidata 覆盖率不足，手动 triage 需要 UI 支持 |
| ⚪ P2 | T-P2-005 NER v1-r6 | 楚汉"X王Y"格式改进 |
