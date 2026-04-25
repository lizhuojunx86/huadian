# Sprint H Stage 1 — T-P1-028 设计 + ADR-025 起草

> **角色**: 管线工程师 (Opus 4.7 / 1M)
> **日期**: 2026-04-26
> **依赖**: `inventory-2026-04-26.md` (Stage 0 调研)
> **输出**: 三方案 trade-off + 阈值灵敏度 + ADR-025 草稿（status=proposed）
> **状态**: 待架构师签字

---

## 1. 三方案 Trade-off (Stage 1.1)

### 1.1 方案 α — R1 函数内嵌 short-circuit

**实现方式**：在 `_rule_r1()` (resolve_rules.py:226) 现有 cross_dynasty 分支内扩展 short-circuit：
```python
if cross_dynasty:
    period_a = _get_dynasty_periods().get(a.dynasty)
    period_b = _get_dynasty_periods().get(b.dynasty)
    if period_a and period_b and abs(period_a.midpoint - period_b.midpoint) > 200:
        return None  # short-circuit, no MergeProposal generated
    # existing single-char logic...
```

**优点**：
- 改动最小（~10 行）
- 不动 R6 既有路径
- 不引入新接口

**缺点**：
- ✗ 不写入 `pending_merge_reviews`，被拦截的 pair 在审计层"消失"（vs R6 现有 BlockedMerge 路径）
- ✗ R2/R5 未来扩展同类 guard 时需重复粘贴代码
- ✗ 与 R6 既有 β 模式不一致，破坏代码统一性
- ✗ threshold 200 硬编码在 R1 里，调整需改源码

**评分**：⚠️ 低（短期成本最低，长期债最高）

---

### 1.2 方案 β — 通用 evaluate_pair_guards 接口（架构师默认倾向）

**实现方式**：扩展 `r6_temporal_guards.py` 接口为 rule-aware：

```python
# r6_temporal_guards.py (重命名 → temporal_guards.py 候选)
GUARD_THRESHOLDS = {"R1": 200, "R6": 500}

def cross_dynasty_guard(a, b, *, threshold_years: int) -> GuardResult | None: ...

def evaluate_pair_guards(a, b, *, rule: str) -> GuardResult | None:
    threshold = GUARD_THRESHOLDS[rule]
    return cross_dynasty_guard(a, b, threshold_years=threshold)
```

集成到 R1（resolve.py:462 主循环）：
```python
for i, j in pairs:
    a, b = persons[i], persons[j]
    match = score_pair(a, b)
    if match is None:
        continue
    # NEW: rule-aware guard check
    guard = evaluate_pair_guards(a, b, rule=match.rule)
    if guard is not None and guard.blocked:
        result.blocked_merges.append(BlockedMerge(...rule=match.rule, guard_type=guard.guard_type, ...))
        continue
    # existing logic: append to merge_proposals
```

**优点**：
- ✅ 与 R6 现有 β 模式一致（`_detect_r6_merges` 已用 `evaluate_guards`）
- ✅ R2/R5 未来加 guard 时只需注册新阈值，不改源码
- ✅ 被拦的 pair 写入 `pending_merge_reviews`（审计完整）
- ✅ threshold 集中配置（GUARD_THRESHOLDS dict）
- ✅ 单源真相（dynasty mapping 仅 YAML）

**缺点**：
- ⚠️ 接口扩展（`evaluate_guards` → `evaluate_pair_guards`）需调整 R6 既有调用点（resolve.py:346），向后兼容包装即可
- ⚠️ 测试面积扩大（≥ 5 单元测试 per brief）

**评分**：✅ **推荐**（与架构师默认倾向一致，符合 ADR-022/023 沉淀的"规则精化优先"哲学）

---

### 1.3 方案 γ — Post-filter 层

**实现方式**：R1 输出 MergeProposal 后，在 Union-Find 之前再过滤一遍：
```python
merge_proposals = [p for p in merge_proposals if not is_cross_dynasty_filtered(p)]
```

**优点**：
- 不改 R1/R6 既有逻辑
- 可独立 toggle 测试

**缺点**：
- ✗ R6 已用 β 模式；γ 后置 filter 与 R6 路径分裂（双 source of truth on filter logic）
- ✗ 被过滤的 pair 是否写 pending_merge_reviews 需要再设计一层（重复 β 已解决的问题）
- ✗ 信息丢失：MergeProposal 已构造，但被丢弃；调试时难追溯

**评分**：⚠️ 低（有 R6 先例的情况下后置 filter 是回退）

---

### 1.4 选型推荐

**方案 β**。理由：
1. 与 R6 现有 `evaluate_guards` 模式一致，避免双 path（β + γ 共存的反模式）
2. 阈值集中配置 + rule-aware dispatch 可扩展性最好
3. `pending_merge_reviews` 已就位，"被拦 pair 写审计行"零成本
4. 与 architect brief §3 §1.1 默认倾向一致 → **Stop Rule #3 不触发**

---

## 2. Dynasty Distance 阈值灵敏度 (Stage 1.2)

### 2.1 阈值表（基于 Stage 0.5 项羽δ + 秦γ 历史 dry-run 数据）

| 阈值（年） | 历史 dry-run 拦截数 | 估计 FP（误拦真合并） | 估计 FN（漏拦跨代 FP） | 推荐？ |
|------------|---------------------|----------------------|------------------------|--------|
| **100**    | 项羽δ ~9-11 / 13<br>秦γ ~10-12 / 14 | **高** — "战国 vs 秦" gap=138、"春秋战国 vs 春秋" gap=138 都被拦；可能误拦合理短称合并（如战国楚国君短称→秦末楚怀王熊心 gap=138 被误拦） | **低** — 几乎所有跨大朝代都拦 | ❌ 否 |
| **150**    | 项羽δ ~7-9 / 13<br>秦γ ~7-9 / 14 | **中** — 战国↔秦末（gap=138）勉强不拦但临界；秦末↔西汉（gap=113）放过 | **中** — 战国 vs 秦末仍漏拦，会保留楚怀王熊槐↔熊心 (战国↔秦末) FP（这正是 T-P0-031 的核心 case） | ❌ 否 — 拦不住楚怀王 case |
| **200**    | 项羽δ ~5-7 / 13<br>秦γ ~5-7 / 14 | **低** — 仅明确跨大朝代 (春秋↔战国 gap=275、西周↔春秋 gap=286) 被拦；同朝代不同国 (gap=0) 完全放过 | **高** — 春秋同朝代不同国 (鲁桓公↔秦桓公 等 gap=0) 全部漏拦；战国↔秦末 (gap=138) 漏拦楚怀王 case | ⚠️ **brief 默认起点**，部分推荐 |
| **300**    | 项羽δ ~3-4 / 13<br>秦γ ~3-4 / 14 | **极低** — 仅西周↔战国 (gap=561) 之类大跨度被拦 | **极高** — 春秋↔战国 (275)、西周↔春秋 (286) 全部漏拦 | ❌ 否 |

### 2.2 阈值推荐：**150yr**（建议覆盖 brief 默认 200yr）

**理由**：
1. **拦楚怀王 entity 跨代 case**：楚怀王(战国 -348) ↔ 熊心(秦末 假定 -210) gap = 138；如阈值 ≤ 138 才能拦
   - 但 138 太小（春秋战国 -485 vs 春秋 -623 也是 138，会误拦春秋战国之交合理 case）
2. **150yr 折中**：
   - 拦：西周/春秋 (286) ✅、春秋/战国 (275) ✅、战国/秦 (134) ❌（不拦）、战国/秦末 (138) ❌（不拦）
   - 这意味着 150 也拦不住战国↔秦末——**纯 dynasty distance 拦不住楚怀王 case**
3. **核心结论**：纯 dynasty distance 阈值（任何取值）**都拦不住春秋同朝代不同国 (gap=0)** 和 **战国↔秦末楚怀王 (gap=138)** —— Stage 0.5 已揭示。
4. **建议**：取 **200yr**（与 brief 一致），不强求拦楚怀王 case（T-P0-031 已是数据修复路径）；但在 ADR-025 §6 Future Work 明确登记"state_prefix_guard"候选，未来覆盖 gap=0 case。

### 2.3 阈值最终建议

**架构师裁决**：建议采纳 **200yr**，理由：
- 与 R6 (500yr) 同质（threshold-based），运维心智一致
- 100/150 高 FP 风险（误拦战国 vs 秦末等合理短称）
- 200 拦截能力 36-50% 已是 dynasty-only guard 的"理论上限"（gap=0 类天然不可拦）
- 楚怀王跨代 case 走 T-P0-031 数据修复路径，不依赖此 guard

**架构师如倾向 150**：可作为更激进选择（多拦 1-2 边界 case），FP 风险可接受范围内。

---

## 3. ADR-025 草稿 (Stage 1.3)

文件位置：`docs/decisions/ADR-025-r-rule-pair-guards.md`（独立文件）

**核心要点**（详见 ADR 文件本体）：

1. **Decision §2.1**: 引入 `evaluate_pair_guards(a, b, rule)` 通用接口，取代 R6-only 的 `evaluate_guards(a, b)`
2. **Decision §2.2**: GUARD_THRESHOLDS 配置：R1=200yr / R6=500yr，按规则 dispatch
3. **Decision §2.3**: 被拦 pair 一律写 `pending_merge_reviews`（与 R6 现有路径一致）
4. **Decision §2.4**: 向后兼容包装：`evaluate_guards(a, b)` 默认 `rule="R6"`
5. **Rationale §3**: 引用 ADR-022/023"规则精化优先"哲学；引用 ADR-010 §R1 不变
6. **Consequences §4.2**: 接受 dynasty-only guard 不解决 gap=0 case；登记 state_prefix_guard 为 Future Work

**与 ADR-022/023 模式一致性检查**：
- ADR-022（污染清理三要素）—— 不冲突（不同领域）
- ADR-023（V8 invariant）—— 模式相通：α/β 豁免哲学 ↔ ADR-025 rule-aware threshold dispatch（都是"规则精化"路线）
- **Stop Rule #4 不触发**

---

## 4. 角色责任分配（Stage 2 准备）

| 任务 | 角色 | 备注 |
|------|------|------|
| ADR-025 签字 | 架构师 | Stage 1 完成挂起等签字 |
| dynasty-periods.yaml 9 缺失映射补充 | 管线工程师 + historian 复核 | Stage 2 前置 |
| `evaluate_pair_guards` 实现 | 管线工程师 | Stage 2 |
| 单元测试 ≥ 5 | 管线工程师 | Stage 2 |
| dry-run 验证（项羽δ + 秦γ 数据回跑） | 管线工程师 | Stage 2 |
| T-P0-031 mention 分桶 historian 裁决 | historian | 第二会话切 historian（不在本会话 scope） |
| T-P0-031 ADR 授权路径裁决 | 架构师 | Stage 3 前置 |

---

## 5. Stop Rule 触发记录（Stage 1）

| Stop Rule | 触发? | 备注 |
|-----------|------|------|
| #3 选型与 β 不一致 | 否 | 推荐 β |
| #4 ADR-025 草稿与 ADR-022/023 冲突 | 否 | 模式相通，结构兼容 |

---

## 6. 推荐执行路径

### 第二会话（建议）
1. **Track A**（架构师签字 ADR-025 后）：T-P1-028 Stage 2 实施
   - dynasty-periods.yaml 9 缺失映射补充（historian 复核年代）
   - `evaluate_pair_guards` 实现 + 5 单元测试 + R6 兼容包装
   - dry-run 项羽δ + 秦γ 数据回跑验证拦截预测
2. **Track B**（独立 historian 会话）：T-P0-031 mention 分桶裁决
   - 对 SE 73e39311 段落两条 alias 给出迁移决策
   - 决策完成后 PE 切回，进 T-P0-031 Stage 3 dry-run

### 第三会话
- T-P0-031 Stage 3 apply（4 闸门 + ADR 授权）
- Sprint H Stage 4 V12 评估 + 收档

---

> Stage 1 设计完成。等架构师签字 ADR-025 + 阈值最终裁决。
