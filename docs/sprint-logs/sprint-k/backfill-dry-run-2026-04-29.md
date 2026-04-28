# Sprint K Stage 2 prep — Backfill Scripts Dry-Run Report

- **角色**：Pipeline Engineer (Opus 4.7 / 1M)
- **日期**：2026-04-29
- **范围**：T-P0-028 Sprint K Stage 2 prep — backfill 脚本 dry-run 验证（不动 DB）
- **关联**：
  - 架构师 brief: `docs/sprint-logs/sprint-k/stage-0-brief-2026-04-28.md`
  - PE Stage 0 inventory: `docs/sprint-logs/sprint-k/inventory-pe-2026-04-28.md` (commit `5917416`)
  - ADR-027 §9.1/§9.2: `docs/decisions/ADR-027-pending-triage-ui-workflow-protocol.md`
  - Stage 1 design §5: `docs/sprint-logs/sprint-k/stage-1-design-2026-04-29.md`
- **commits**：C1 `36fdacd` (PMR backfill script) + C2 `8d004ef` (TD backfill script)
- **mode**：仅 SELECT 只读 + markdown 解析 + UUID 合成；**未写 DB**

---

## TL;DR

| 脚本 | dry-run 行数 | brief 估算 | 偏离 | Stop Rule 状态 |
|------|--------------|------------|------|----------------|
| `backfill_pending_merge_reviews.py` | **18 unique** | ~16 | +12.5% | ✅ 落 [8, 25] 安全区间 |
| `backfill_triage_decisions.py` | **179 rows** (来自 79 rulings) | ~80-100 | +79% | ⚠️ **Stop Rule #2 触发**（>150 阈值） |

**架构师 ACK 需求**：
1. **Stop Rule #2 触发**（TD 行数 179 > 150）→ 需架构师明示是否接受 179 推进 C4 apply。
2. **PMR 可独立先行**（行数 18 在阈值内 + Hist E2E 数据基础急需）→ 是否允许 PMR 单独 apply（不等 TD ACK）。

---

## §1 backfill_pending_merge_reviews 详情

### §1.1 行数与分布

```
Parsed rows (pre-dedup): 42
Total unique rows after dedup: 18
  by guard_type: cross_dynasty=11, state_prefix=7
  by source sprint (first occurrence): H=8, I=9, J=1
Resolved UUIDs: 42
Skipped (no match in persons): 1
Fail-loud (multi-match): 0
```

**dedup 来源拆解**（first-occurrence 归属）：
- Sprint H 贡献 **8 unique**（全部 cross_dynasty，预拦截即落 H）
- Sprint I 贡献 **9 unique**（2 cross_dynasty 新 + 7 state_prefix 新）
- Sprint J 贡献 **1 unique**（1 cross_dynasty 新：刘盈↔秦惠文王 251yr 反向 gap）

**1 skip 原因**：吕后 dynasty=春秋 → DB 无 active 行（Sprint J Stage 4 apply 已 merge 到吕雉 西汉）。Skip 正确，无需修复。

**Stop Rule 状态**：
- #2 阈值 [8, 25] → 18 ✅ 通过
- #3 阈值 fail-multi-match=0 → ✅ 通过
- #4 阈值 markdown 解析失败 ≥10% → 解析失败 0/42 → ✅ 通过

### §1.2 Sample（前 10 条 unique 行）

| # | name_a | name_b | guard_type | sprint | dynasty_a → dynasty_b | gap |
|---|--------|--------|------------|--------|----------------------|----:|
| 1 | 周成王 | 楚成王 | cross_dynasty | H | 西周 → 春秋 | 286yr |
| 2 | 秦康公 | 密康公 | cross_dynasty | H | 春秋 → 西周 | 286yr |
| 3 | 楚灵王 | 灵王 | cross_dynasty | H | 春秋 → 西周 | 286yr |
| 4 | 秦庄公 | 齐庄公 | cross_dynasty | H | 西周 → 春秋 | 286yr |
| 5 | 齐简公 | 秦简公 | cross_dynasty | H | 春秋 → 战国 | 275yr |
| 6 | 灵公 | 晋灵公 | cross_dynasty | H | 战国 → 春秋 | 275yr |
| 7 | 楚王 | 楚昭王 | cross_dynasty | H | 战国 → 春秋 | 275yr |
| 8 | 楚怀王 | 楚昭王 | cross_dynasty | H | 战国 → 春秋 | 275yr |
| 9 | 灵公 | 楚灵王 | cross_dynasty | I | 春秋 → 西周 | 286yr |
| 10 | 熊心 | 楚昭王 | cross_dynasty | I | 春秋 → 秦末 | 415yr |

完整 18 行落 DB 时 evidence JSONB 标 `{_backfill: true, _backfill_label: "retroactive-backfill, sprint-K-stage-2-prep", source_md, sprint}`，guard_payload 含 dynasty/midpoint/gap/threshold（cross_dynasty）或 state/raw_state/name（state_prefix）。

### §1.3 后续处理

**期望 apply 后**：
- DB `pending_merge_reviews` 行数 0 → 18
- `merge_log` / `persons` / `seed_mappings` 无影响
- V1-V11 全绿（pending_merge_reviews 是新数据写入，不影响其他不变量）
- ON CONFLICT DO NOTHING 保证幂等可重跑

---

## §2 backfill_triage_decisions 详情

### §2.1 行数与分布

```
Parsed rulings: 79
  by sprint: γ=35, δ=21, ε=23
Expanded triage_decision rows: 179
  by decision: approve=82, defer=40, reject=57
  with real PMR source_id: 0       (dry-run 时 PMR 表为空)
  with synthetic source_id: 179
```

**展开倍率**：每 ruling 平均 `179/79 = 2.27 surfaces`，与 architect "~80-100" 估算（隐含 1.0-1.3 倍率）相比偏高 **1.79×**。

**展开倍率分布**（推断）：
- 2 surfaces 占多数（典型 "A → B" 双成员 merge group）
- 3 surfaces（如 γ-G6 缪公 + 秦缪公 → 秦穆公）
- 5 surfaces（如 γ-G16 晋惠公↔秦襄公↔齐襄公↔夷吾↔晋襄公 split — 单 ruling 5 行）
- 4 surfaces（如 γ-G26 太子圉↔子圉↔怀公↔秦怀公）
- 5 surfaces（如 ε-G7 熊心↔楚王↔楚怀王↔怀王↔义帝 split）

### §2.2 ⚠️ Stop Rule #2 触发分析

**触发**：179 > 150 上限阈值。

**根因**：D2 设计 ACK 时确定"每 ruling 展开为 N surface 行"用于 hint banner indexable lookup（per ADR-027 §3 surface_snapshot 索引），但 architect "80-100" 估算未考虑 split 组高展开倍率（split 组占 9 from γ + 1 from δ + 1 from ε = 11 splits，平均 4 surfaces ≈ 44 行 vs 11 行单 surface），加上多成员 approve 组的多 surface（如 G6 三成员），总和上浮 ~80%。

**评估方案**：

| 选项 | 行数 | 优劣 |
|------|------|------|
| **A. 保留 179**（推荐） | 179 | hint banner 数据完整，每 surface 都可独立 query；缺点是 split 组语义稀释（5 行同 reason） |
| B. 仅保留每 ruling 1 行（surfaces 拼接） | 79 | 落入估算区间；缺点是 hint banner 必须全表 LIKE 扫描，不能命中 idx_triage_decisions_surface partial index |
| C. 每 ruling 仅保留 2 个 surfaces（pair 主对） | ~158 | 中间方案；缺点是 split 组多人 surface 信息丢失 |

**PE 推荐**：A（保留 179），理由：
1. ADR-027 §3 显式建立 `idx_triage_decisions_surface` 索引以支撑 hint banner，按 surface 1-1 行才能命中此索引
2. Hist 痛点 #1 "周成王 reject 3 次" 形成依赖于多 surface 多 row 的可聚合数据
3. split 组的 5 surfaces 每行同 reason 不算冗余 — 因为每 surface 在 hint banner 不同上下文下单独被查
4. 179 行 + idx_triage_decisions_surface 查询性能可控（远未达 PG 索引扫描瓶颈）

**等架构师 ACK** 决定 A/B/C。

### §2.3 Sample（前 10 条 expanded rows，全 SYNTH）

| # | sprint-group | surface | decision | src_type | commit |
|---|--------------|---------|----------|----------|--------|
| 1 | γ-G4 | 孝王 | approve | in_chapter | 3280a35 |
| 2 | γ-G4 | 周孝王 | approve | in_chapter | 3280a35 |
| 3 | γ-G6 | 缪公 | approve | in_chapter | 3280a35 |
| 4 | γ-G6 | 秦缪公 | approve | in_chapter | 3280a35 |
| 5 | γ-G6 | 秦穆公 | approve | in_chapter | 3280a35 |
| 6 | γ-G12 | 儋 | approve | in_chapter | 3280a35 |
| 7 | γ-G12 | 太史儋 | approve | in_chapter | 3280a35 |
| 8 | γ-G13 | 献公 | approve | in_chapter | 3280a35 |
| 9 | γ-G13 | 秦献公 | approve | in_chapter | 3280a35 |
| 10 | γ-G14 | 秦孝公 | approve | structural | 3280a35 |

每行落 DB 时：
- `source_table` = `'pending_merge_reviews'`
- `source_id` = `uuid5(NAMESPACE_OID, f"{sprint}-{group_id}-{surface}")`（synthetic 稳定 UUID）
- `historian_id` = `'historical-backfill'`
- `historian_commit_ref` = sprint commit hash（3280a35 / fdfb7cb / 07db893）
- `notes` = `'historical-backfill, synthetic source_id (no underlying DB row, ruling from sprint dry-run)'`
- `decided_at` = DB 默认 `now()` (无原始 timestamp)
- `downstream_applied` = `false`（V2 hook 占位）

### §2.4 PMR/TD 顺序协同

dry-run 阶段 PMR 表为空 → 所有 179 行均为 SYNTH。

apply 阶段（**先 PMR --apply 后 TD --apply**）：
- PMR apply 后：18 行 pending_merge_reviews 落地
- TD apply 时：`expand_to_decision_rows()` 内部 SELECT pending_merge_reviews JOIN persons：
  - 双成员 ruling 的两 surface 与 PMR 行 (person_a, person_b) 名对匹配 → 用真实 PMR UUID + `notes=NOTES_REAL`
  - 三成员+ ruling 或非 guard-blocked pair → 仍 SYNTH
- 预计真实 PMR source_id 的 row 数：≤ 18 PMR rows × 2 surfaces = ≤36 rows；其余 143-179 行 SYNTH

### §2.5 后续处理

**期望 apply 后**：
- DB `triage_decisions` 行数 0 → 179（如选 A）
- `WHERE notes LIKE '%synthetic%'` 可定位 ~143 SYNTH 行；`WHERE notes LIKE '%source_id from backfill_pending%'` 可定位 ~36 REAL 行
- `WHERE historian_id='historical-backfill'` 反查清理路径完整（per ADR-027 §8.3 回滚）
- 预 INSERT SELECT idempotency check 保证可重跑

---

## §3 跨脚本 Stop Rule 评估总结

| Stop Rule | 描述 | 状态 |
|-----------|------|------|
| #1 backfill 脚本无法解析 ≥10% markdown ruling | 解析失败 0/79 = 0% | ✅ 通过 |
| #2 PMR 行数 ([8,25]) | 18 ✅ | ✅ 通过 |
| #2 TD 行数 ([50,150]) | **179** ⚠️ | **⚠️ 触发，等架构师 ACK** |
| #3 真 apply 后 V1-V11 任一回归 | 未 apply | 待 C4 验证 |
| #4 跨 sprint group_id 映射失败 ≥5 行 | 跨 sprint group_id 用 sprint label prefix（γ-G2/δ-G1/ε-G7）+ uuid5 合成，无映射失败 | ✅ 通过 |

---

## §4 架构师 ACK 请求清单

请架构师签署：

- [ ] **#1 PMR backfill 18 行可 apply**（落入 [8,25] 安全区间，符合 brief 估算 ~16）
- [ ] **#2 TD backfill 179 行处理**（三选一）：
    - [ ] **方案 A — 保留 179 行**（PE 推荐，hint banner 数据完整、命中索引、ADR-027 §3 surface 索引设计意图一致）
    - [ ] 方案 B — 缩减至 79 行（每 ruling 1 行 surface 拼接，缺点 hint banner 全表扫描）
    - [ ] 方案 C — 缩减至 ~158 行（每 ruling 2 surfaces，缺点 split 组多人信息丢失）
- [ ] **#3 PMR 与 TD 是否独立 apply**：
    - [ ] PMR + TD 同 sprint 一起 apply（推荐）
    - [ ] PMR 先单独 apply（hist E2E 急需）→ TD 等架构师下一回合 ACK
- [ ] **#4 BE migration 0014 ready 信号**：本会话不 apply；等架构师转发"migration 0014 ready"后启动 C4。

ACK 后 PE 即推进 C4 真 apply（顺序：PMR --apply → V1-V11 验证 → TD --apply → V1-V11 验证 → SELECT 抽样 5 条验证 surface_snapshot/decision/historian_commit_ref 字段）。

---

## §5 文件引用

- 脚本路径：
  - `services/pipeline/scripts/backfill_pending_merge_reviews.py`（C1 `36fdacd`, 788 行）
  - `services/pipeline/scripts/backfill_triage_decisions.py`（C2 `8d004ef`, 717 行）
- 解析的 markdown 来源（dry-run 命中）：
  - PMR: `sprint-h/stage-2-dry-run-2026-04-26.md` + `sprint-i/dry-run-2026-04-28.md` + `sprint-j/dry-run-resolve-2026-04-28.md`
  - TD: `T-P0-006-gamma/historian-review-2026-04-25.md`(3280a35) + `T-P0-006-delta/historian-review-2026-04-25.md`(fdfb7cb) + `sprint-j/historian-review-2026-04-28.md`(07db893)
- ADR-027 §3 schema、§5 merge 铁律、§9 backfill spec 全部对齐

---

**End of dry-run report. Awaiting architect ACK.**
