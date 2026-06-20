# Sprint ⚠️FILL-ID Stage 0 — 前置准备 / Inventory

> 复制到 `docs/sprint-logs/sprint-{id}/stage-0-{topic}-YYYY-MM-DD.md`

## 0. 目的

⚠️FILL：本 stage 解决什么准备工作问题。常见目的：

- Fixture / source data 注册
- Adapter 实现
- Domain dictionary 扩充（如需）
- Pre-flight invariant baseline
- 跨角色 inventory（如多角色 sprint）

---

## 1. 准备项清单（Checklist）

填具体动作。每项必须可量化（数字 / 文件 / 命令）。

- [ ] ⚠️FILL `fixture 文件就位`：路径 `⚠️FILL`
- [ ] ⚠️FILL `adapter 注册到 _CHAPTER_REGISTRY`（或 source registry / 等）
- [ ] ⚠️FILL `domain dictionary 扩充`：行数 ≥ ⚠️N
- [ ] ⚠️FILL `disambiguation seeds 扩充`：组数 ≥ ⚠️N（如适用）
- [ ] ⚠️FILL `Pre-flight invariant baseline`：记 V1=⚠️N / V9=⚠️N / active=⚠️N（作为 Stage 5 对照）
- [ ] ⚠️FILL `衍生债处理`（顺手做的小修，如有）
- [ ] commit C1: `⚠️FILL chore: Sprint X Stage 0 prep (...)`

---

## 2. 跨角色 inventory（仅多角色 sprint）

如果本 sprint 涉及多角色，每个角色提交一份 `inventory-{role}-YYYY-MM-DD.md`：

- [ ] PE inventory: `⚠️FILL inventory-pe-{date}.md`
- [ ] BE inventory: `⚠️FILL inventory-be-{date}.md`
- [ ] FE inventory: `⚠️FILL inventory-fe-{date}.md`
- [ ] Hist / Domain Expert inventory: `⚠️FILL inventory-{expert}-{date}.md`

每份 inventory 至少含：
1. 当前现状（数据 / 代码 / 工作流）
2. 痛点 / 缺口
3. 本 sprint 期望产出
4. 对其他角色的依赖

---

## 3. Pre-flight Verification

```bash
# 数据基线 SELECT（领域 specific 调整）
psql -c "⚠️FILL: 例如 SELECT count(*) FROM persons WHERE deleted_at IS NULL"

# Invariant baseline
pytest tests/test_invariants_*.py -q  # 必须 22/22 全绿

# 黄金集 baseline（如适用）
⚠️FILL: 例如 uv run pytest tests/test_golden_set.py -q
```

记录数字：

```
⚠️FILL: V1=0 / V9=0 / active_persons=729 / merge_log=111
```

---

## 4. Stage 0 Gate Check（→ Stage 1 解锁条件）

- [ ] 所有 §1 准备项完成
- [ ] §3 Pre-flight verification 全绿
- [ ] commit C1 已提交
- [ ] 给 Stage 1 Smoke 的输入就绪

如任一不通过 → 不得推进 Stage 1 → 排查 + 补完。

---

## 5. 给 Stage 1 的 Handoff 信号

```
✅ Sprint X Stage 0 完成
- Pre-flight baseline: ⚠️FILL
- 准备项 ⚠️N/⚠️M 完成
- commit C1: ⚠️SHA
→ Stage 1 Smoke 可启动
```

---

**Stage 0 完成 → Stage 1 启动。**
