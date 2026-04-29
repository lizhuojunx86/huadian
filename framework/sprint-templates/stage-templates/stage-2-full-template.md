# Sprint ⚠️FILL-ID Stage 2 — Full

> 复制到 `docs/sprint-logs/sprint-{id}/stage-2-full-YYYY-MM-DD.md`

## 0. 目的

全量 ingest / extract / load / 等。Sprint 主体工作。

⚠️ **关键约束**：本 stage 是写入 DB 的主战场。任何错误都可能不可逆。Stop Rule 严格执行。

---

## 1. Full 范围

- **总数据量**：⚠️FILL `N 章 / N 段 / N 行 / etc`
- **预算**：⚠️FILL `LLM cost ≤ $X / 时间 ≤ Y 小时`
- **预期实体数**：⚠️FILL `~ N 个`

---

## 2. 实时监控

每 ⚠️N 段 / 每 ⚠️N 分钟报告：

- LLM 累计 cost
- 累计 new persons / new entities
- 任一异常 / silent failure

⚠️ 任一指标超 brief §3 Stop Rule 阈值 → 立即停止 + 升级架构师裁决。

---

## 3. 执行步骤

```bash
⚠️FILL: 例如
cd services/pipeline
uv run python -m src.cli ingest --source ⚠️ --book ⚠️
uv run python -m src.cli extract --book ⚠️ --steps ner,relations,events,resolve
uv run python -m src.cli load --book ⚠️
```

---

## 4. 跑后验证

### 4.1 全量 invariants

```bash
DATABASE_URL=⚠️ uv run pytest tests/test_invariants_*.py -q
# 必须 22/22 全绿（或本项目 N/N）
```

### 4.2 SQL 直查

记录关键数字：

```
active_persons: 729 → ⚠️N (Δ ⚠️+M)
merge_log: 111 → ⚠️N
source_evidences: ⚠️FILL
其他 schema-specific: ⚠️FILL
```

### 4.3 黄金集回归（如适用）

```bash
⚠️FILL: uv run pytest tests/test_golden_set.py -q
# 必须 ≥ baseline（已有章节不回归）
```

---

## 5. Gate 1 Check（→ Stage 3 解锁条件）

- [ ] 总成本 ≤ brief 预算的 1.5x（超 1.2x 提请架构师审）
- [ ] 新增实体数 ≤ brief 预期的 1.2x（超提请审）
- [ ] V1-V11 invariants 全绿（不允许任何回归）
- [ ] 黄金集回归全绿（如适用）
- [ ] 没有 silent failure
- [ ] commit C2-CN 已提交

---

## 6. Stop Rule 触发处理

如 Stage 2 触发 Stop Rule（参见 brief §4）：

1. **立即停止**当前操作
2. **不要 rollback**（保留现场便于诊断）
3. **报告架构师**：含数字 / log / 触发的 rule
4. **等架构师裁决**：继续 / rollback / 调参数 / 等

详见 `framework/sprint-templates/stop-rules-catalog.md` 处理协议。

---

## 7. 给 Stage 3 的 Handoff 信号

```
✅ Sprint X Stage 2 Full 完成
- LLM cost: $⚠️X / 预算 $⚠️Y
- 新增实体: ⚠️N / 预期 ⚠️M
- V1-V11: 22/22 全绿
- DB 数据: ⚠️FILL
- commits: C2-C⚠️N
→ Stage 3 Dry-Run + Review 可启动
```

---

**Stage 2 完成 → Stage 3 启动。**
