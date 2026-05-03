# framework v0.2.0 — Release Notes

> Release date: **2026-04-30**
> Sprint: **Sprint P** (v0.2 patch + ceremonial release)
> Tag (待打): `v0.2.0`
> 上一 release: 4 模块各自 v0.1（Sprint L / M / N / O）

---

## 0. TL;DR

framework v0.2.0 是 **4 模块统一版本号**的第一刀公开 release。无新模块、无 breaking changes、无新依赖。本 release 收 Sprint L+M+N+O 累计 **8 项 v0.2 patch**（1 P2 + 7 P3），4 个模块同步打 v0.2 标记，方便跨领域案例方有正式 baseline 引用。

剩余 6 项 v0.2 候选（pytest 单测 / 跨领域 reference impl / `EntityLoader.load_subset` 等）押后 Sprint Q+ 触发条件成熟后处理。

---

## 1. 4 模块版本一览

| 模块 | 上次版本 | 本 release | 路径 | 第 N 刀 |
|------|---------|-----------|------|--------|
| `framework/sprint-templates/` | v0.1.1 | **v0.2.0** | sprint governance 模板 | L (第一刀) |
| `framework/role-templates/` | v0.1.1 | **v0.2.0** | 多角色协作模板 | M (第二刀) |
| `framework/identity_resolver/` | v0.1.0 | **v0.2.0** | 身份解析框架 | N (第三刀) |
| `framework/invariant_scaffold/` | v0.1.0 | **v0.2.0** | 不变量校验框架 | O (第四刀) |

---

## 2. 本 release 收口的 patch 清单（8 项）

### 2.1 P2（1 项）— 跨 sprint 复发的 systemic bug

**DGF-O-01** — examples 路径硬编码改环境变量（4 处）

来源：Sprint N DGF-N-02（P3 漏修）→ Sprint O 跑 dogfood 时同 bug 复发 → 升级 P2

修法：
- `framework/identity_resolver/examples/huadian_classics/` 3 处 path helper（`_default_dict_dir` / `_default_periods_path` / `_default_states_path`）
- `framework/invariant_scaffold/examples/huadian_classics/invariants_slug.py` 1 处（拆出 `_default_tier_s_path`）

新解析顺序（统一）：
1. `HUADIAN_DATA_DIR` 环境变量（如设）
2. `Path(__file__).resolve().parents[4] / "data"` walk-up fallback

跨域价值：fork 案例方（legal / medical / etc）只需设环境变量即可 inject 自己的 data dir，无需 fork code。

### 2.2 P3（7 项）

**T-P3-FW-001** — `brief-template.md` §1.2 表格列数灵活化
- 加 callout 说明：与单 sprint 对比时 2 列；与一批近 N 个 sprint 对比时聚合表头；与不同形态 sprint 各 1 个对比时 N+1 列

**T-P3-FW-002** — `retro-template.md` §4 与 `stop-rules-catalog.md` §7 双向 cross-reference 紧密化
- retro §4 表头扩展为 5 列（Rule / 类别 §X / 触发原因 / 裁决 A/B/C/D / trigger 文件路径）
- stop-rules-catalog §7 加配套引用段，指向 retro-template

**T-P3-FW-003** — `stage-3-review-template.md` §2.0 review 形式选择指南
- 新增决策表：candidates ≥ 30 → Triage UI / candidates < 10 且仅 1 次 review → Markdown / triage UI 不可用 → V1 fallback
- 选 Markdown Review 时需在 retro §3 标注是否切回 Triage UI

**T-P3-FW-004** — `brief-template.md` §8 D-route 措辞解耦项目宪法专属性
- 原稿引用 "C-22"（华典智谱专属规则编号）→ 改为通用措辞，并在脚注提示项目特定规则在子 brief 中显式引用

**DGF-M-01** — `brief-template.md` §3 加纯文档抽象 sprint 的 alt 段
- 原稿仅 5-stage 数据管线模板 → 新增 §3.A（5-stage 管线）/ §3.B（精简 1-2 阶段：framework 抽象 / 文档 / patch sprint）/ §3.0 选择指南
- 实证：Sprint L-P 全部用 §3.B 路径

**DGF-N-01** — `test_byte_identical.compare()` 引入 `FIELD_ALIASES` 通用机制
- 替换 inline `d.get("a", d.get("b"))` 链 → 模块级 `FIELD_ALIASES: dict[str, tuple[str, ...]]` + `_get_aliased(d, canonical)` helper
- 跨域 fork 只需扩展 `FIELD_ALIASES`，不动 `compare()` body

**DGF-O-04** — `ContainmentInvariant.query_violations` 用 `inspect.isawaitable()`
- 替换 `hasattr(result, "__await__")` → `inspect.isawaitable(result)`
- 标准库官方 awaitable 检测，覆盖 coroutine / future / generator-based coroutine，避免误判

---

## 3. Breaking changes

**无。**

`HUADIAN_DATA_DIR` 是新增可选环境变量，未设时 fall back 到原 `parents[4]/data` 路径，行为与 v0.1 完全一致。

`FIELD_ALIASES` 是新模块级常量，原 `compare()` 行为不变（new aliases 都包括了原默认 key 在内）。

`inspect.isawaitable` 替换 `hasattr` 在所有现有 sync/async predicate 用法下行为一致（已 sanity 验证）。

---

## 4. 升级指南（v0.1 → v0.2）

仅依赖 framework 的下游项目：

```bash
git pull          # 拉最新 framework/
# 无需任何代码改动 — 全部 P3 patch 都向后兼容
```

可选优化：

- 设 `HUADIAN_DATA_DIR=/path/to/your/data` 替代 `parents[4]` 推断（更稳健）
- 跨域 fork 可在自己的 `test_byte_identical.py` 顶部 extend `FIELD_ALIASES`

---

## 5. 4 模块 dogfood 状态（截止本 release）

| Sprint | 模块 | dogfood 形式 | 结果 |
|--------|------|------------|------|
| Sprint L | sprint-templates | self-use（Sprint L brief 自己用本模板）| ✅ |
| Sprint M | role-templates | self-use（Sprint M brief 用本模板）| ✅（暴露 6 项 patch，Sprint M v0.1.1 全清）|
| Sprint N | identity_resolver | byte-identical vs 生产 (729 person 数据) | ✅（fix 2 个 path / alias bug 后通过）|
| Sprint O | invariant_scaffold | soft-equivalent + self-test 注入 (11 invariants / 4 modules) | ✅（fix slug path 复发后通过）|
| Sprint P | 4 模块全部 | 各模块 sanity import + 4 path env-var override + containment 异步检测验证 | ✅ |

---

## 6. 押后到 Sprint Q+ 的 v0.2 候选（6 项）

| ID | 描述 | 触发条件 |
|----|------|---------|
| DGF-N-03 + DGF-O-02 | identity_resolver + invariant_scaffold 加 conftest.py + pytest tests（30+ tests/模块）| Sprint Q+ 决定 |
| DGF-N-04 + DGF-O-03 | examples/legal/ + examples/medical/ 跨领域 reference impl | 跨领域案例方主动接触 |
| DGF-N-05 | EntityLoader.load_subset feature | 用户 / 案例方提需求 |

---

## 7. 公开发布 checklist

- [x] 4 模块 README §8 v0.2 行更新
- [x] 2 模块 `__version__` bump 到 "0.2.0"
- [x] 顶层 `framework/RELEASE_NOTES_v0.2.md`（本文件）
- [ ] STATUS / CHANGELOG 更新（Sprint P 收口时同步）
- [ ] git tag v0.2.0（用户在 local Terminal 执行）

```bash
# 用户在 local terminal 准备执行：
cd /Users/lizhuojun/Desktop/APP/huadian
git add framework/ docs/
git commit -m "feat(framework): v0.2.0 release — 8 v0.2 patches landed (Sprint P)"
git tag -a v0.2.0 -m "framework v0.2.0 — Sprint P v0.2 patch + ceremonial release"
git push origin main --tags
```

---

## 8. 致谢

本 release 来自 Sprint L→M→N→O→P 5 个 sprint 的累积工作。Sprint P 的"清债 + release"模式将作为 D-route 周期工作的 meta pattern 沉淀到下一版 methodology。

跨领域案例方的反馈（legal / medical / patent / 等）将驱动后续 v0.3 / v1.0 演进；欢迎在 GitHub Issue 报告。

---

**framework v0.2.0 — 2026-04-30 / Sprint P**
