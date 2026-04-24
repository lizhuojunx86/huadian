# T-P0-029 Stage 0 Inventory — R6 Cross-Dynasty Guard

> **调查人**: 管线工程师（Claude Opus）
> **日期**: 2026-04-24
> **依据**: Stage 0 Brief `docs/sprint-logs/T-P0-029/stage-0-brief-2026-04-24.md` §3 Stage 0 六项调研
> **数据库快照**: huadian@localhost:5433/huadian（Docker `huadian-postgres`）

---

## §1 持久化字段现状

### persons（总 370 行 / 活跃 319）

| 字段 | 类型 | 非空行 / 总行 | 覆盖率 | 样本 |
|------|------|--------------|--------|------|
| `dynasty` | text | 370 / 370 | **100%** | "上古"(79), "西周"(67), "商"(61), "东周"(35), "战国"(25), "春秋"(22), "夏"(20), "先周"(6), "西汉"(2), "秦"(1), "周"(1) |
| `birth_date` | jsonb (HistoricalDate) | 0 / 370 | **0%** | — |
| `death_date` | jsonb (HistoricalDate) | 0 / 370 | **0%** | — |

> HistoricalDate 结构 = `{year_min?, year_max?, precision}`，schema 健全但从未填充。

**关联子表**：
- `person_names.start_year` / `end_year`: integer | 0 / 604 | 0%
- `disambiguation_seeds.dynasty_hint`: text | 0 / 0（表空）

### events（总 0 行 — 表空）

| 字段 | 类型 | 非空行 / 总行 | 覆盖率 |
|------|------|--------------|--------|
| `time_period_start` | jsonb (HistoricalDate) | 0 / 0 | N/A |
| `time_period_end` | jsonb (HistoricalDate) | 0 / 0 | N/A |

> 管线尚未写入任何事件；events 表无 era / dynasty 独立列。

### dictionary_entries（总 201 行 / 全 entry_type='person'）

| 字段 | 类型 | 非空行 / 总行 | 覆盖率 |
|------|------|--------------|--------|
| `attributes` | jsonb | 201 / 201 | 100%（但仅含 `description_zh` 一个 key） |
| `attributes->>'dateOfBirth'` | — | 0 / 201 | **0%** |
| `attributes->>'dateOfDeath'` | — | 0 / 201 | **0%** |
| `attributes->>'period'` | — | 0 / 201 | **0%** |

> Sprint B Wikidata seed loader 只抓了 `description_zh`，**未抓任何时间属性**。

### 附：reign_eras 表

- 0 行（schema 含 `year_start` / `year_end` integer 列，但数据未加载）

### §1 结论

| 数据源 | 可用性 | 覆盖率 |
|--------|--------|--------|
| `persons.dynasty` | ✅ 唯一可用 | 100%（粗粒度文本） |
| `persons.birth_date/death_date` | ❌ 空 | 0% |
| `events.time_period_*` | ❌ 表空 | N/A |
| `dictionary_entries.attributes` 时间属性 | ❌ 未抓 | 0% |
| `reign_eras` | ❌ 表空 | 0% |

**`persons.dynasty` 是唯一有实际数据的时间/朝代字段。**

---

## §2 当前 R6 evidence 字段结构

### R6PrePassResult（dataclass, frozen=True）

| 字段 | 类型 | 说明 |
|------|------|------|
| `status` | `R6Status` (enum: NOT_FOUND / MATCHED / BELOW_CUTOFF / AMBIGUOUS) | 匹配状态 |
| `qid` | `str \| None` | Wikidata Q-number |
| `entry_id` | `str \| None` | dictionary_entries.id UUID |
| `confidence` | `float \| None` | seed_mappings.confidence |

> 无 dynasty / 时间 / guard_reason 字段。

### MergeProposal（dataclass）

| 字段 | 类型 |
|------|------|
| `person_a_id` / `person_b_id` | str (UUID) |
| `person_a_name` / `person_b_name` | str |
| `match` | `MatchResult` (rule + confidence + evidence) |

`match.evidence` = `dict[str, Any]`，R6 路径实际值：
```json
{"external_id": "Q186544", "source": "wikidata", "pre_pass": true}
```

### _detect_r6_merges() 逻辑

位置：`resolve.py`

1. 过滤 `snap.r6_result.status == MATCHED`
2. 按 QID 分组
3. 同 QID ≥2 人 → pairwise MergeProposal（confidence=1.0）
4. **无任何 dynasty / 时间检查** ← T-P0-029 填洞点

### person_merge_log.evidence

类型：JSONB（nullable），存 `MatchResult.evidence` 序列化。可直接添加 guard 元数据字段（`dynasty_a`, `dynasty_b`, `dynasty_gap_years`, `guard_reason`），零迁移成本。

### seed_mappings.notes

类型：JSONB（nullable）。当前全量 45 条 pending_review 的 notes **均为 NULL**。可存储 guard reason，零迁移。

### §2 Guard Signal 挂载点评估

| 挂载位 | 方式 | 迁移成本 |
|--------|------|---------|
| `_detect_r6_merges()` 内部 | 在生成 MergeProposal 前加 dynasty 检查分支 | 零（纯 Python） |
| `MergeProposal.match.evidence` dict | 加 `dynasty_a/b`, `guard_reason` 等字段 | 零（非结构化 dict） |
| `seed_mappings.notes` JSONB | 降级时写 guard reason | 零（已有字段） |
| `person_merge_log.evidence` JSONB | 如需审计 guard 拦截也可写 | 零 |

**核心缺口**：`_detect_r6_merges()` 目前只有两个出口（MergeProposal 或静默丢弃），缺少第三出口（pending_review 降级）。T-P0-029 需新增该路径。

---

## §3 T-P0-028 pending_review 通道现状

### T-P0-028 任务卡

- 位置：`docs/tasks/T-P0-028-pending-review-triage-ui.md`
- 状态：**planned**（stub 级别，无独立 brief）
- 核心定义：历史专家一键 triage（active / rejected），后端 = `UPDATE seed_mappings` + `INSERT source_evidence`，不改 schema
- 已识别子类型：#1 Wikidata 跨实体混淆（Sprint C 产物）/ #2 R1/R2/R3 multi-hit（Sprint B 原有 44 条）

### pending_review 数据源

- **唯一存储位**：`seed_mappings.mapping_status = 'pending_review'`（无独立 triage 表）
- **现有记录数**：45 条
- **notes 字段**：全部 45 条 **NULL**，无结构化标注
- **mapping_method 分布**：

| mapping_method | 行数 | has_notes |
|---------------|------|-----------|
| r2_alias_multi | 24 | 0 |
| r1_exact_multi | 17 | 0 |
| r3_name_scan_multi | 3 | 0 |
| r2_alias | 1 | 0 |

> 最后 1 行 (r2_alias) 即 Sprint C 降级的 wei-zi-qi → Q186544。

### Guard 命中条目存储约定

**未明确定义。** Brief §2 写"具体存储位由 Stage 0 inventory 决定"，§3 写"按 Stage 0 决定的存储位写入"。

**管线工程师评估**：

现有 `seed_mappings.mapping_status + notes` 机制**功能上足够**承载 guard 降级：
- `mapping_status = 'pending_review'` → 已有枚举值
- `notes` JSONB → 可存 guard reason（`guard_type`, `dynasty_a`, `dynasty_b`, `gap_years`, `triggered_by`）

但存在 **两个待架构师对齐的问题**：

1. **notes JSONB 结构约定**：当前 45 条全为 NULL，无标准。T-P0-028 triage UI 需要靠 notes 区分子类型（#1 guard 拦截 vs #2 multi-hit），否则 UI 无法差异展示。
2. **Guard 拦截条目的来源标记**：Sprint C 手动降级的 wei-zi-qi 与 T-P0-029 自动 guard 产出在 DB 层不可区分。

> **⚠️ Stop Rule #4 预警**：pending_review notes 结构约定需架构师签字后再实现。不阻塞 Stage 0 产出，但 **阻塞 Stage 1 guard 写路径实现**。

---

## §4 R6 merge apply 历史 baseline

### person_merge_log 规则分布

| merge_rule | 行数 |
|-----------|------|
| historian-approved | 24 |
| R1 | 13 |
| transitive | 5 |
| R3-non-person | 5 |
| R3 | 2 |
| R5 | 1 |
| manual-fix | 1 |
| manual-historian | 1 |
| R4-honorific-alias | 1 |
| **R6** | **0** |

**总计 53 条 merge log，R6 = 0 条。符合预期。**

> Sprint C path A 确认未 apply R6 merge。唯一的 R6 MergeProposal（启 ↔ 微子启）被 historian 拦截，未执行。

---

## §5 四候选方案可行性评估

### 数据源可用性矩阵

| 方案 | 时间源 | Phase 0 覆盖率 | 可行性 |
|------|--------|---------------|--------|
| **α** | `persons.dynasty` | **100%**（319/319 active） | ✅ 可行 |
| **β** | `events` JOIN time_period | **0%**（表空） | ❌ 不可行 |
| **γ** | `dictionary_entries.attributes.dateOfBirth` | **0%**（未抓） | ❌ 不可行 |
| **δ** | hybrid α + β fallback | α=100% / β=0% / γ=0% → 退化为纯 α | ⚠️ 名义可行，实质冗余 |

### 逐方案评估

**方案 α — `persons.dynasty` 单源**
- 优：唯一有实际数据的源；100% 覆盖；实现最简（~30 行 Python + 静态 dynasty→year_range 映射）
- 劣：粗粒度（"上古" / "西周" 等文本，非精确年份）；需维护 dynasty→year_range 静态映射
- 实现要点：
  - 新增 `DYNASTY_YEAR_RANGES: dict[str, tuple[int, int]]`（约 11 个朝代，从当前 active persons 的 dynasty 值枚举）
  - `_detect_r6_merges()` 内在 pairwise MergeProposal 生成前加 dynasty gap 检查
  - gap > 500 年 → 不生成 proposal，走 pending_review 降级
- 精度评估：对于"夏 vs 商"（gap ~470 年 via range edges）至"夏 vs 春秋"等明显跨代场景足够；对相邻朝代（如"商末周初 vs 西周"）需谨慎处理重叠

**方案 β — events JOIN time_period**
- 不可行原因：events 表 0 行。Phase 0 管线尚未摄入任何事件。
- 远期价值：Phase 1+ 事件摄入后可作为 α 的补充源
- 判定：**SKIP**

**方案 γ — dictionary_entries.attributes.dateOfBirth**
- 不可行原因：Sprint B Wikidata seed loader 只抓了 `description_zh`，未抓 P569(dateOfBirth) / P570(dateOfDeath) / P2348(period)
- 修复成本：需改 `wikidata_adapter.py` 扩展抓取字段 + 回填 201 行 → 属 T-P0-025b 或独立卡范围
- 判定：**SKIP**（不在 T-P0-029 范围内修复）

**方案 δ — hybrid**
- 实质：α 有数据 + β 无数据 + γ 无数据 → 退化为纯 α，β/γ 分支为死代码
- 架构师 brief 默认倾向 δ（"单一源覆盖率不足是常态"），但实际观察 α 已 100% → hybrid 的降级价值为零
- 判定：**不推荐**。引入死分支增加实现与测试复杂度，无实际收益

### 推荐

> **推荐方案 α**（persons.dynasty 单源 + 静态 dynasty→year_range 映射）

理由：
1. 唯一有实际数据的源（100% 覆盖）
2. β/γ 全失，hybrid δ 退化为纯 α
3. 实现最简，测试最少
4. 粗粒度对 >500 年跨代检测**足够**（本卡目标是拦截明显跨代冲突，不是精确年份匹配）
5. 远期升级路径清晰：Phase 1 有 events/dateOfBirth 数据后可平滑升级为 δ

> **⚠️ Stop Rule #5 触发**：推荐 α 与 brief 默认倾向 δ 不一致。需架构师签字确认。

---

## §6 阈值 500 年的实际数据感觉

### 同 QID 多 active person 查询

```sql
-- active seed_mappings JOIN persons，按 QID 分组，HAVING count >= 2
```

**结果**：仅 1 组 —

| QID | Wikidata 名 | 人数 | 华典 slug | dynasty |
|-----|------------|------|-----------|---------|
| Q468747 | 周公旦 | 2 | u5468-u516c（周公） | 西周 |
| Q468747 | 周公旦 | 2 | u5468-u516c-u65e6（周公旦） | 西周 |

> **同朝代**（西周 vs 西周），dynasty gap = 0 年。**不会触发 500 年 guard**。这是一个合法的 R6 merge 候选（两个 person 指同一人）。

### Sprint C 案例回顾（已降级，不在 active 中）

| QID | slug | dynasty | mapping_status |
|-----|------|---------|---------------|
| Q186544 | qi（启） | 夏 | active |
| Q186544 | wei-zi-qi（微子启） | 商 | **pending_review** |

> 夏(~-2070~-1600) vs 商(~-1600~-1046)：年代范围 gap ≈ 0~470 年（range edges 相邻）。但基于 midpoint 计算 ~500 年。该案例在 Sprint C 已手动降级。

### 阈值 500 年感觉

**当前 active 数据中，跨 >500 年同 QID 的 pair = 0 对。**

原因：
1. Phase 0 数据量有限（319 active persons / 158 active seed_mappings）
2. Sprint C 唯一的跨代案例（启↔微子启）已手动修复
3. Phase 0 涵盖的朝代跨度（夏~战国 + 极少西汉/秦）相对集中

**但 500 年阈值仍有意义**：
- 随着 seed coverage 从 49.5% → 80%+（T-P0-025b 扩充），类似跨代误匹配概率上升
- "上古"（~前3000+年）vs 任何有纪年朝代的 gap 远超 500 年
- 500 年作为起点保守合理（historian 建议值）

### dynasty 年代范围参考映射

| dynasty | 约始（BCE） | 约终（BCE） | 中位点（BCE） |
|---------|-----------|-----------|-------------|
| 上古 | -3000（极不确定） | -2070 | -2535 |
| 夏 | -2070 | -1600 | -1835 |
| 商 | -1600 | -1046 | -1323 |
| 先周 | -1200 | -1046 | -1123 |
| 西周 | -1046 | -771 | -909 |
| 春秋 | -770 | -476 | -623 |
| 东周 | -770 | -256 | -513 |
| 战国 | -475 | -221 | -348 |
| 秦 | -221 | -207 | -214 |
| 西汉 | -202 | 9 | -97 |
| 周 | -1046 | -256 | -651 |
| 商末周初 | -1100 | -1000 | -1050 |

> 使用 midpoint 距离 > 500 年时，"夏 vs 商" gap = |−1835−(−1323)| = 512 年 → 刚好触发。
> 使用 range gap（两区间无重叠部分）时，"夏 vs 商" gap = |−1600−(−1600)| = 0 年（边界相邻）→ 不触发。

**建议**：采用 **midpoint 距离**（非 range gap），更符合"跨朝代"的语义直觉。500 年阈值在 midpoint 度量下恰好可拦截 Sprint C 案例。

---

## Stop Rule 状态汇总

| # | 条件 | 状态 | 说明 |
|---|------|------|------|
| 1 | 三源全失 | ✅ **未触发** | `persons.dynasty` 100% 覆盖 |
| 2 | dry-run 拦截 0 个 | — | Stage 2 才检查 |
| 3 | invariant 回归 | — | Stage 2 才检查 |
| 4 | T-P0-028 数据源约定不清 | ⚠️ **预警** | notes JSONB 结构未定义；不阻塞 Stage 0，**阻塞 Stage 1 写路径**；需架构师对齐 |
| 5 | 选型与 brief δ 不一致 | ⚠️ **触发** | 推荐 α（persons.dynasty 单源），理由：β/γ 数据全失，δ 退化为纯 α |

---

## 管线工程师建议（待架构师签字）

1. **方案选型**：α（persons.dynasty 单源 + 静态 dynasty→year_range 映射 + midpoint 距离 > 500 年）
2. **Guard 挂载点**：`_detect_r6_merges()` 内 pairwise 循环加 cross-dynasty 检查分支
3. **降级路径**：guard 命中 → `seed_mappings.mapping_status = 'pending_review'` + `notes` JSONB 写结构化 reason
4. **前置裁决需求**：
   - (a) 方案 α vs δ 签字（Stop Rule #5）
   - (b) `seed_mappings.notes` JSONB 结构约定（Stop Rule #4 预警，建议最小约定：`{reason: str, guard_type: str, dynasty_a: str, dynasty_b: str, gap_years: int, triggered_by: str}`）
5. **Q468747（周公/周公旦）**：同朝代合法 R6 候选，不受 guard 影响。建议 Stage 2 dry-run 中确认不误伤。
