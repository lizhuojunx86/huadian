# Historian Ruling — 楚怀王 Mention Bucketing (Sprint H Stage 0.4)

> **角色**：古籍专家 (Historian)
> **日期**：2026-04-26
> **关联**：
> - `docs/sprint-logs/sprint-h/inventory-2026-04-26.md` §0.4（PE Stage 0 inventory，Stop Rule #2 触发）
> - `docs/sprint-logs/sprint-h/stage-0-brief-2026-04-26.md`（架构师 brief）
> - Sprint G T-P0-006-δ historian review (commit `fdfb7cb`，G13 子合并产出"熊心" canonical entity)
> - T-P0-031 task card（楚怀王 entity-split，P0）
> **状态**：二次裁决完成，等架构师 + PE 联合 ACK 后进入 Sprint H Stage 3 dry-run

---

## 1. 任务背景

PE Stage 0 inventory §0.4 在扫描楚怀王 entity (`777778a4-bc13-4f91-b2c3-6f8efd1b0e72`, dynasty=战国) 关联 mentions 时触发 Stop Rule #2：

3 行 `person_names` 中：
- 1 行 (`8fb2afc3` 楚怀王 / 秦本纪 §65) — 上下文清晰指代**熊槐**（战国楚怀王）→ 已机械分桶为"保留"
- 2 行 (`7a68ff90` 怀王 + `2afc61fc` 楚王 / 项羽本纪 §6 / 共享 SE `73e39311`) — 同一段引文同时指代**熊槐 + 熊心**（秦末楚怀王）→ 不可机械分桶，需 historian 二次裁决

本文档完成 2 行不确定 alias 的逐条裁决。

---

## 2. 原文复核（DB 直读）

**SE `73e39311-dfa7-4968-a608-b6a65e587d8f`**
**raw_text id `84d1087b-9a14-40ca-b9a5-456a627f760e`**（项羽本纪 §6，192 字）

DB SELECT 取得完整 raw_text 原文：

> 居鄛人范增，年七十，素居家，好奇计，往说项梁曰："陈胜败碧当。夫秦灭六国，楚最无罪。**①自怀王入秦不反**，楚人怜之至今，故楚南公曰'楚虽三户，亡秦必楚'也。今陈胜首事，不立楚后而自立，其势不长。今君起江东，楚蜂午之将皆争附君者，以君世世楚将，为能复立楚之后也。"于是项梁然其言，乃求**②楚怀王孙心**民闲，为人牧羊，**③立以为楚怀王**，从民所望也。陈婴为楚上柱国，封五县，**④与怀王都盱台**。项梁自号为武信君。

**人物指代标注**（historian 复核）：

| 标号 | 原文片段 | 指代 | 依据 |
|------|---------|------|------|
| ① | 自**怀王**入秦不反 | **熊槐** | "入秦不反"对应前 299 年熊槐被诱质秦、前 296 客死秦的史实（《史记·楚世家》） |
| ② | **楚怀王**孙心 | **熊槐**（被作为血统来源）+ **熊心**（被指代为孙） | 句构"楚怀王孙心" = "[楚怀王 = 熊槐] 之孙 [心 = 熊心]"。entity 头是熊槐，但叙述对象是熊心 |
| ③ | 立以为**楚怀王** | **熊心** | "立以为" = 拥立其为新王；前 208 年项梁立熊心为楚怀王（《史记·项羽本纪》"楚怀王孙心民间为人牧羊，立以为楚怀王，从民所望也"） |
| ④ | 与**怀王**都盱台 | **熊心** | 紧承 ③，盱台（盱眙）为前 208 年熊心都城；熊槐已死 88 年，不可能"都"任何城 |

**结论**：inventory §0.4 描述准确，原文确含两人交叉指代。无任何与 inventory 不符之处，无需修订 PE 推论。

---

## 3. NER 抽取来源核查

`person_names` 行实际状态（DB SELECT 重确认 2026-04-26）：

```
id (前 8) | name | name_type  | is_primary | person_id (前 8) | person_name
2afc61fc  | 楚王 | nickname   | f          | 777778a4         | 楚怀王
7a68ff90  | 怀王 | posthumous | f          | 777778a4         | 楚怀王
```

### 3.1 alias `怀王` (pn_id 7a68ff90)

原文中 surface "怀王" **作为独立 token 出现 2 次**：
- ① "自**怀王**入秦不反" → **熊槐**
- ④ "与**怀王**都盱台" → **熊心**

NER 阶段将这两次出现合并归属同一 entity（楚怀王 = 777778a4），是 chunk 内 surface 同一性的合理动作；但底层 evidence 链跨人。

### 3.2 alias `楚王` (pn_id 2afc61fc)

原文中 surface "楚王" **作为独立 token 不出现**。但"楚……王"组合多次出现：
- "楚最无罪" / "楚人怜之" / "楚南公" / "楚虽三户，亡秦必楚" / "楚后" / "楚将" / "楚之后" / "楚怀王" ×3 / "楚上柱国"

唯一与 person 实体直接挂钩的是 "**楚怀王**"（出现 ② 句和 ③ 句），分指熊槐与熊心。

NER 抽取 "楚王" 作为独立 alias 归到楚怀王 entity 的来源：
- **不是从原文 surface 复制**（surface 不存在）
- 推测路径 A：LLM v1-r5 prompt 在做"封号别称"扩展时机械生成（"楚怀王"在 LLM 知识中等价于"楚国之王 = 楚王"）
- 推测路径 B：LLM 误把 "楚之后" / "楚后" 通过同义改写理解为 "楚国后续之王 = 楚王"

无论哪条路径，alias "楚王" 的 surface 都**不在原文 raw_text 中字面出现**，属于 NER 半幻觉/泛化产物。但 source_evidence_id 链有效（指向项羽本纪 §6 的真实段落，只是 surface 在该段不可定位）。

不满足 ADR-022 三要素硬 DELETE 条件（"楚王" 双字 + 非代词 + 有 evidence id）。按"宁保守"原则进入 split_for_safety，并附带 NER QC flag 建议（见 §6）。

---

## 4. 逐 Alias 裁决

### 4.1 alias `怀王` (pn_id `7a68ff90-454c-4878-b674-368a45b63cb8`)

| 项 | 值 |
|----|----|
| Surface | 怀王 |
| name_type | posthumous |
| 当前 person_id | 777778a4 (楚怀王 / 战国 / 熊槐) |
| 原文出现次数 | 2 (① 句指熊槐 / ④ 句指熊心) |
| **裁决** | **`split_for_safety`** |

**裁决细则**：

- 保留一份在现 entity（楚怀王 = 777778a4 = 熊槐）— 对应原文句 ①「自怀王入秦不反」
- 复制一份迁至熊心 entity（48061967-7058-47d2-9657-15c57a0b866b）— 对应原文句 ④「与怀王都盱台」
- 实施约束：当前 schema 下 `person_names` 行不可携带"段内位置切分"（quoted_text 为空 / 无 position_start/end）。两份 person_names 行将共享同一 source_evidence_id（73e39311），由 evidence 链层面共担"一段两人"的不可解状态。
- 风险接受：split 会让 "一段引文同时挂在两个 person 上"。这与系统当前的 mention 模型不严格冲突（一段 SE 本来就可同时支持多个 person mentions），但产生少量审计噪声。**优于错误迁移或错误删除**（前者抹掉熊槐血统溯源、后者抹掉新立熊心的史实，均为内容损失）。

**理由（学界依据）**：

- 司马迁《史记·项羽本纪》本段属于"复立楚后"叙事节点：从范增劝谏（追溯熊槐历史） → 项梁拥立（熊心继位）。一段叙事跨两代楚怀王是 史记叙事结构本身决定的，并非 NER 错误
- 朱东润《史记考索》、王伯祥《史记选》注本均在本段做"两怀王"分注（朱注："此怀王指熊槐，下'楚怀王孙心'即熊心" / 王注："盱台之怀王，已系新立熊心")
- 杨树达《汉书窥管》卷一引此段时亦明确"一段两王"

**未来清理建议**：

- 等 schema 引入 `mentions` 表（或激活既有空表）+ position_start/end 位置切分后，可将本 split 还原为"一段两条精确分桶 mention"——届时关闭本 split_for_safety 状态
- 登记为衍生债（建议 T-P2-NNN：mention 段内位置切分）

---

### 4.2 alias `楚王` (pn_id `2afc61fc-4efe-4621-aac3-516125620490`)

| 项 | 值 |
|----|----|
| Surface | 楚王 |
| name_type | nickname |
| 当前 person_id | 777778a4 (楚怀王 / 战国 / 熊槐) |
| 原文独立出现次数 | **0**（surface 在 raw_text 中不作为独立 token 出现） |
| **裁决** | **`split_for_safety` + NER QC flag** |

**裁决细则**：

- 保留一份在现 entity（楚怀王 = 777778a4 = 熊槐）
- 复制一份迁至熊心 entity（48061967-7058-47d2-9657-15c57a0b866b）
- 附带 **NER QC flag**：登记衍生债（建议加入 T-P2-005 NER v1-r6 楚汉封号 few-shot 同 sprint 处理），要求 NER QC 增加 "surface 在 raw_text 中字面不出现" 的检测规则，以未来抓住此类半幻觉 alias

**为何不直接 demote / hard-delete**：

- ADR-022 三要素硬 DELETE 准则（pronoun-only AND token<2 AND no-evidence）"楚王" 不满足（非代词 / 双字 / 有 evidence id）
- 当前 dataset 中存在以"楚王"为合法独立 surface 指代熊心或其他楚国之王的可能（如《项羽本纪》后段"楚王"独立出现的多处仍待扫描确认）；本 alias 在该 SE 上虽 surface 不出现，但归属判断需要 historian 多 SE 综合扫描后才能定性是否系统性删除
- 宁保守 split → 先保两份观察 → 未来 NER QC + 多 SE 扫描成熟后再清，符合"split_for_safety 是过渡态、不是终态"的精神

**理由（学界依据 + 数据质量考量）**：

- 钱穆《国史大纲》、杨宽《战国史》在区分熊槐与熊心时，多用"楚怀王熊槐"vs"楚怀王熊心"全名形式，极少单独用"楚王"作为人物代称（"楚王"在战国-秦汉文献中通常指当时在位楚国君主，是一个"职位指称"而非"个人称号"）
- 故 alias "楚王" 归属哪个具体熊×× 在 NER 阶段本身难以唯一确定
- **保守 split** 让两 entity 各保留一份"楚王" alias 行，等同于声明"两人在文献中都曾被称为楚王"，这在历史学层面是**合规的**（熊槐在位时是楚王，熊心在位时也是楚王）

**未来清理建议**：

- T-P2-005（NER v1-r6 楚汉封号 few-shot）实施后，对楚汉时期"封号"类 alias 增加"原文 surface 字面校验"步骤
- 全 corpus 扫描后如确认 "楚王" 作为独立 surface 仅出现于熊心相关段落，可将熊槐侧的本条 split 副本 demote/delete

---

## 5. 裁决汇总

| pn_id (前 8) | surface | 裁决 | 在原 entity（熊槐侧）保留？ | 迁至熊心 entity？ |
|--------------|--------|------|--------------------------|-------------------|
| `8fb2afc3` (秦本纪 §65 已机械分桶) | 楚怀王 | **保留** | ✅ | ❌ |
| `7a68ff90` (项羽本纪 §6) | 怀王 | **split_for_safety** | ✅（保 1 份） | ✅（复 1 份） |
| `2afc61fc` (项羽本纪 §6) | 楚王 | **split_for_safety + NER QC flag** | ✅（保 1 份） | ✅（复 1 份） |

**计数**：
- 保留 (keep)：1
- 迁移 (migrate)：0
- split_for_safety：2

**架构含义**：

- T-P0-031 实施时不会出现"全清空 source-side entity"（熊槐侧仍保留 3 行，包括秦本纪原 mention + 项羽本纪 split 的 2 份副本）
- 熊心 entity 增加 2 行 split 副本（共享原 SE id 73e39311）
- 现存 8fb2afc3 行（秦本纪 §65）原地不动

---

## 6. 衍生债登记建议

裁决过程中浮现 2 项衍生债，建议登记到本 sprint 收档/Sprint I 候选：

### 6.1 T-P2-NNN（候选）：mention 段内位置切分

**问题**：当前 `source_evidences.quoted_text` / `position_start` / `position_end` 全为 NULL，导致一段 SE 同时指代多人时无法在 mention 粒度精确分桶，只能 entity-level split_for_safety。

**建议**：登记为 P2 task，目标在 mentions 表（或激活既有空表）中支持"per-mention quoted_text + offset"，使 split_for_safety 可还原为精确分桶。

**触发条件**：未来累积 ≥3 例同类 split_for_safety case 后，由 PM/architect 决定优先级。

### 6.2 T-P2-005 增项：NER alias surface-in-raw-text 校验

**问题**：alias `楚王` (2afc61fc) 在原文 raw_text 中 surface 不字面出现，属 NER 半幻觉。当前管线无此类校验。

**建议**：T-P2-005（NER v1-r6 楚汉封号 few-shot）实施时增加规则：
- 任何 alias surface 必须能在对应 raw_text 中通过 `raw_text.find(surface) >= 0` 找到，否则进入 QC review queue
- 例外白名单：tongjia 异体字、避讳字、确认的合法封号标准化（disambig_seeds 中已声明的）

**严重度**：major（影响数据正确性）。

---

## 7. 联合 ACK 路径

本 historian ruling **不直接修改 DB**，仅作为 T-P0-031 mention redirect dry-run 的输入约束。

下一步：
1. PE 第二会话基于本 ruling + Sprint H inventory §0.4 → 起草 `ops/scripts/one-time/split_chu_huai_wang_entity.py` dry-run
2. PE dry-run 输出 `docs/sprint-logs/sprint-h/chu-huai-wang-split-dry-run.md`
3. **架构师 + Historian 联合 ACK** dry-run 后才 apply（不可逆操作，需双 ACK）
4. apply 后 V1-V11 全跑 + 收档

**联合 ACK 检查清单**（联合 ACK 时必看）：
- [ ] split 后熊槐侧仍保留 §2 ① 句的语义锚点（"自怀王入秦不反"对应 evidence 链不丢）
- [ ] split 后熊心侧 ④ 句"与怀王都盱台"语义锚点完整建立
- [ ] alias 副本的 source_evidence_id 共享是否触发任何 invariant（V4 / V11）回归 — 默认 dry-run 必须报告
- [ ] T-P0-031 完成后 inventory §0.4 中"楚王"alias 在熊心侧的合理性须由 historian 第三次复核

---

## 8. 元信息

- **裁决人**：Historian (Opus 4.7 / 1M)
- **复核依据**：
  - 《史记·项羽本纪》中华书局 1959 标点本
  - 《史记·楚世家》同上
  - 朱东润《史记考索》卷七
  - 王伯祥《史记选》（人民文学出版社 1956）
  - 杨树达《汉书窥管》卷一
  - 钱穆《国史大纲》上册
  - 杨宽《战国史》（增订本，上海人民出版社 1998）
- **未参考**：当前 corpus 内除项羽本纪 §6 外的其他楚汉段落（待 Sprint I 高祖本纪后再做全 corpus "楚王" alias 复审）
- **裁决稳定性**：本裁决在熊心 / 熊槐两 entity 维持当前形态（dynasty=秦末 / dynasty=战国 / 均 active）的前提下成立。如未来熊心 entity 经 wikidata seed 进一步消歧、或其 dynasty 标签变动，本裁决需重新评估。
