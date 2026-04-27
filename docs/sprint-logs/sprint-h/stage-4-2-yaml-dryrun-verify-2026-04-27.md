# Sprint H S4.2 — dynasty-periods.yaml 合流后 dry-run 验证

> **角色**：管线工程师 (Opus 4.7 / 1M)
> **日期**：2026-04-27
> **关联**：
> - Hist Track B commit `d7f79b7`（dynasty mapping 9 项独立复核）
> - PE Sprint H S2.5 commit `8501ab9`（Stage 2 dry-run baseline 8 拦截 / 1.14×）
> - ADR-025 §6.1（9 缺失映射 follow-up）
> **目的**：验证 Hist Track B 3 项 yaml 修订后 dry-run guard 拦截结果未引入 bug
> **Stop Rule 检查**：Stop Rule #1（拦截数偏离 1.14× baseline >2×）

---

## 1. 修订内容

| # | dynasty | 修订前 (PE draft) | 修订后 (Hist Track B) | 类别 |
|---|---------|------------------|-----------------------|------|
| 1 | 秦末汉初 | midpoint -205 | midpoint **-206** | floor convention 统一 |
| 2 | 战国·秦/秦/韩/魏 alias | 注释 "midpoint < 50yr" | 注释加 future-risk（差异 32-46yr 临近 50yr 上限） | minor 文档 |
| 3 | 春秋战国 | -500 ~ -450 / mid -475 | **-481 ~ -403 / mid -442** | 学界标准断代修订（major） |

yaml 文件头新增 floor convention 明文："rounding away from zero for negative midpoints"。

---

## 2. 单元测试结果

```
tests/test_r6_temporal_guards.py — 22 passed (含 2 deprecation warnings 由 evaluate_guards 包装产生)
tests/test_evaluate_pair_guards.py — 15 passed
合计 37 tests 全绿
```

无回归。

---

## 3. Dry-run 结果（663 active persons）

```
Run ID: f5d97368-805e-4e72-8a69-ad2cbb30ae41
合并 proposals: 10 (R1×15 命中)
Hypotheses: 0
Guard blocked pairs: 8
R6 prepass: matched 153 / not_found 504 / below_cutoff 6 / ambiguous 0
Errors: 0
```

### 3.1 8 guard 拦截对照（vs Stage 2.5 baseline `8501ab9`）

| # | Pair | Dynasty A vs B | Gap (yr) | Stage 2.5 baseline | 本次 dry-run | 一致? |
|---|------|----------------|---------:|--------------------|---------------|:------|
| 1 | 周成王 ↔ 楚成王 | 西周 / 春秋 | 286 | ✅ | ✅ | ✅ |
| 2 | 秦康公 ↔ 密康公 | 春秋 / 西周 | 286 | ✅ | ✅ | ✅ |
| 3 | 楚灵王 ↔ 灵王 | 春秋 / 西周 | 286 | ✅ | ✅ | ✅ |
| 4 | 秦庄公 ↔ 齐庄公 | 春秋 / 西周 | 286 | ✅ | ✅ | ✅ |
| 5 | 齐简公 ↔ 秦简公 | 春秋 / 战国 | 275 | ✅ | ✅ | ✅ |
| 6 | 灵公 ↔ 晋灵公 | 春秋 / 战国 | 275 | ✅ | ✅ | ✅ |
| 7 | 楚王 ↔ 楚昭王 | 春秋 / 战国 | 275 | ✅ | ✅ | ✅ |
| 8 | 楚怀王 ↔ 楚昭王 | 春秋 / 战国 | 275 | ✅ | ✅ | ✅ |

**8/8 完全一致**（pair / dynasty / gap / 顺序）。

### 3.2 春秋战国 midpoint -442 影响评估

修订前（mid=-475）vs 修订后（mid=-442）的 gap 差异：
- 春秋战国（mid=-442）↔ 春秋（mid=-623）gap 181yr（修订前 148yr）→ 200yr 阈值下**仍不拦**
- 春秋战国（mid=-442）↔ 战国（mid=-348）gap 94yr（修订前 127yr）→ 仍不拦
- 春秋战国（mid=-442）↔ 西周（mid=-909）gap 467yr → 仍**应拦**（但 DB 中 3 个春秋战国 persons 与西周不形成 R1 surface match → 实际 0 拦截）

**结论**：8 拦截全部与"春秋战国" dynasty 无关，midpoint -475 → -442 修订对当前 dry-run 拦截**零影响**。

### 3.3 秦末汉初 midpoint -206 影响评估

修订前（mid=-205）vs 修订后（mid=-206）的 gap 变化均 ≤ 1yr，对 200yr 阈值判定无影响。无 dynasty pair 因此修订改变拦截状态。

---

## 4. Stop Rule #1 检查

| 项 | 值 |
|----|----|
| Stage 2.5 baseline 拦截数 | 8（1.14× single-chapter 上限 7） |
| 本次 yaml 合流后拦截数 | **8** |
| 偏离倍数 | **1.0×**（无变化） |
| Stop Rule #1 阈值 (>2× baseline) | 16 |
| **Stop Rule #1 触发?** | **❌ 不触发** |

---

## 5. 结论

- ✅ Hist Track B 3 项修订全部落地（yaml head + 战国 alias 注释 + 春秋战国 + 秦末汉初）
- ✅ 单元测试 37/37 全绿
- ✅ Dry-run 8 拦截与 baseline 100% 一致
- ✅ Stop Rule #1 不触发，可推进 S4.3
