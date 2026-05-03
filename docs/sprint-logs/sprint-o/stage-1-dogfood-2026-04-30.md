# Sprint O Stage 1.13 Dogfood — 11 Invariants + 4 Self-tests PASSED

> Date: 2026-04-30 (实际跑 2026-05-03 / brief 起草日为 2026-04-30)
> Owner: 首席架构师（dogfood 在用户本地 services/pipeline venv 跑）
> Anchor: Sprint O Brief §3 Stage 1.13
> **Result: ✓ DOGFOOD PASSED** — Part A 11/11 / Part B 4/4

---

## 0. 验证方法

按 brief §10 设计：用 `examples/huadian_classics/test_byte_identical.py` 在用户本地 venv 跑两部分：

- **Part A**：framework runner + 11 huadian invariants → 跑现有 729 person production 数据 → 期望全 0 violations
- **Part B**：SelfTestRunner + 4 self-tests（V8 / V9 / V10.a / V11）→ 注入违反 + 验证 catch + auto-rollback

执行命令：

```bash
cd ~/Desktop/APP/huadian
PYTHONPATH=$(pwd) \
DATABASE_URL="postgresql://huadian:huadian_dev@localhost:5433/huadian" \
  uv run --directory services/pipeline \
  python -m framework.invariant_scaffold.examples.huadian_classics.test_byte_identical
```

---

## 1. Part A — 11 invariants 跑通

| Invariant | Pattern | 结果 | 时长 |
|-----------|---------|------|------|
| V4 (deleted+merged retain names) | LowerBound | ✅ PASS | 11.5ms |
| V6 (no alias+is_primary contradiction) | CardinalityBound | ✅ PASS | 4.7ms |
| V8 (single-char prefix collision) | Containment | ✅ PASS | 7.6ms |
| V9 (active person ≥ 1 primary) | LowerBound | ✅ PASS | 4.3ms |
| V10.a (orphan target) | OrphanDetection | ✅ PASS | 8.6ms |
| V10.b (orphan entry) | OrphanDetection | ✅ PASS | 2.7ms |
| V10.c (active without evidence) | Containment | ✅ PASS | 4.3ms |
| V11 (no >1 active mapping) | CardinalityBound | ✅ PASS | 4.0ms |
| active_merged | Containment | ✅ PASS | 1.8ms |
| slug_format | Containment + Python predicate | ✅ PASS | 2.6ms |
| slug_no_collision | CardinalityBound | ✅ PASS | 2.0ms |
| **合计** | — | **11/11** | **55ms** |

**结论**：framework runner 跑出与原 services/pipeline/tests/test_invariants_v*.py 完全一致的状态（全 0 violations）。

---

## 2. Part B — 4 self-tests 全部 catch

| Self-test | Target | 结果 | 时长 |
|-----------|--------|------|------|
| v9_missing_primary | V9 | ✅ CAUGHT | 11ms |
| v10a_orphan_target | V10.a | ✅ CAUGHT | 14ms |
| v11_duplicate_mapping | V11 | ✅ CAUGHT | 9ms |
| v8_prefix_collision | V8 | ✅ CAUGHT | 7ms |
| **合计** | — | **4/4** | **41ms** |

**结论**：

- SelfTestRunner 协议（注入 + invariant.run + predicate match + auto-rollback via _RollbackSentinel）正确工作
- 4 个 invariant SQL 都能正确捕获注入的违反（不是被 happen-to-pass）
- transaction 自动回滚，DB 0 污染（dogfood 跑完 729 active persons 不变）

---

## 3. dogfood 中发现 + 修复的 issues

### 3.1 Issue #1：slug_format 第一轮跑出 135 violations（path 深度 bug 复发）

**症状**：第一轮跑 dogfood，slug_format 报 135 violations（"百里奚 / 白起 / 白乙丙" 等 158 合法 pinyin slug 全报错）。

**根因**：`invariants_slug.py:_load_tier_s_whitelist()` fallback 路径错算：

```python
path = Path(__file__).resolve().parents[5] / "data" / "tier-s-slugs.yaml"
```

`parents[5]` 跳过项目根。文件深度 5 层，应该 `parents[4]`。

**严重性**：**这是 Sprint N DGF-N-02 衍生债已登记但未处理的 bug 复发**（Sprint N 的 huadian_classics 同样犯过）。

**修复**：

1. `parents[5]` → `parents[4]`
2. 把 try/except 从 `ImportError` 扩到 `Exception`（防止 huadian_pipeline.slug 加载时抛 yaml 解析或其他 exception 时静默 fallback 失败）

修后两路径都正确加载 158 slugs。

### 3.2 Lesson — DGF-N-02 衍生债该升优先级

Sprint N retro §3.1 已经登记 DGF-N-02（"硬编码相对路径深度 fragile"），但当时优先级 P3，没立即处理。Sprint O 又踩同样坑。

→ **Sprint O retro 应该把 DGF-N-02 + DGF-O-01（同 bug 第二实例）合并升级到 P2，可能下次 sprint 优先处理**。

或者：直接在 Sprint O closeout 顺手做 v0.2 patch（与 Sprint M v0.1.1 patch 同模式 — 当场修了再说）。

---

## 4. dogfood 关键证明

### 4.1 framework 抽象正确性

- 11 invariants 全部跑通 = 5 pattern subclass + DBPort + InvariantRunner 设计正确
- 与 production pytest 测试输出等价（都 0 violations 状态）

### 4.2 4 个 Plugin 全部跑通

- `DBPort` ✅ — HuaDianAsyncpgPort（pool + with_connection 双模式）
- `Invariant` ABC ✅ — 11 invariants 通过 from_template 创建 + run() wrapper
- `SelfTest` Protocol ✅ — 4 self-tests 通过 setup_violation + predicate 实现
- `SelfTestRunner` ✅ — `_RollbackSentinel` 强制 rollback 工作，DB 0 污染

### 4.3 5 pattern 跨 invariant 重用证明

- LowerBound: V4 + V9 — 同一 pattern 复用 in 不同 schema
- Containment: V8 + V10.c + active_merged + slug_format — 4 个不同 invariant 用同 pattern
- OrphanDetection: V10.a + V10.b — count_only 模式工作
- CardinalityBound: V6 + V11 + slug_no_collision — exact_total + per_entity_range 双模式都工作

→ pattern 抽象**经实证 valid**（vs 假设 valid）。

### 4.4 with_connection vs pool 双模式 DBPort

- Part A：HuaDianAsyncpgPort(pool) — 每个 invariant 独立 acquire connection
- Part B：HuaDianAsyncpgPort.with_connection(conn) — 共享 connection 让 transaction 跨多 statement

两路径都工作，证明 DBPort 设计灵活。

---

## 5. Stop Rule 触发情况

Sprint O 7 条 Stop Rule，本 sprint 触发情况：

| # | Rule | 触发？ | 处理 |
|---|------|------|------|
| 1 | invariant runner 跑非 0 violations | ⚠️ 临时触发 1 次 | slug_format 135 violations → 修 path bug → re-run all pass |
| 2 | 抽象边界判定混淆 | ❌ 未触发 | 5 pattern 100% 覆盖 11 invariants |
| 3 | 触碰 services/pipeline/tests 生产代码 | ❌ 未触发 | git diff: 0 changes |
| 4 | examples 无法跑 | ❌ 未触发 | path 修后跑通 |
| 5 | Sprint O 工时 > 3 会话 | ❌ 未触发 | 2 会话完成 |
| 6 | 触发新 ADR ≥ 1 | ❌ 未触发 | 0 ADR |
| 7 | self-test 注入不能被 catch | ❌ 未触发 | 4/4 都 catch |
| 8 | framework 代码量 > 2500 | ❌ 未触发 | core ~1335 行 |

→ Stop Rule #1 临时触发 1 次但当场修复（与 Sprint N 第一次 dogfood 同形态）。

---

## 6. dogfood 元 pattern 累计

Sprint O 是 framework 第 4 个抽象模块。dogfood-on-template 累计实例：

| Sprint | dogfood 形式 | 覆盖度 / 结果 |
|--------|-------------|-------------|
| L | sprint-templates 自审 | 90% |
| M | brief / closeout / retro template + role-templates 自审 | 99.2% |
| N | identity_resolver byte-identical | 100% 等价 |
| O | invariant_scaffold runner + 4 self-tests | 11/11 + 4/4 |

→ 4 个 sprint / 4 种 dogfood 形态都通过。证明 framework 模块可重复构建 + 验证。

---

## 7. Gate 1.13 自检

- [x] 11 invariants 跑出 0 critical violations（与 production pytest 一致）
- [x] 4 self-tests 全部 catch 注入违反
- [x] 5 pattern subclass 跨 invariant 复用证明
- [x] DBPort + Invariant + SelfTest + SelfTestRunner 4 个抽象全部跑通
- [x] services/pipeline/tests/ 完全未改（git diff 验证）

→ **Stage 1.13 dogfood gate PASSED** / Sprint O Stop Rule #1 已修复 / Stage 4 closeout unblock。

---

## 8. 已就绪信号

```
✓ Sprint O Stage 1.13 dogfood gate PASSED
- Part A: 11/11 invariants pass (0 critical / 0 warning / 55ms total)
- Part B: 4/4 self-tests caught (auto-rollback worked, DB 0 pollution)
- 修复 1 次中间 issue (slug path bug — DGF-N-02 同 bug 复发)
- 5 pattern 实证跨 11 invariants 100% 覆盖
- 0 services/pipeline 生产代码改动
→ Stage 4 closeout unblock
```

---

**本 dogfood 报告起草于 2026-04-30 / Sprint O Stage 1.13**
