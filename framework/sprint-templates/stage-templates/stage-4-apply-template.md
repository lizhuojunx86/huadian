# Sprint ⚠️FILL-ID Stage 4 — Apply

> 复制到 `docs/sprint-logs/sprint-{id}/stage-4-apply-YYYY-MM-DD.md`

## 0. 目的

根据 Stage 3 决策真改数据库。

⚠️ **最关键的 stage**：本 stage 是不可逆的 DB mutation。任何错误必须立即 rollback（pre-apply pg_dump anchor 是必备安全网）。

---

## 1. Pre-Apply 准备

### 1.1 数据库备份（必备）

```bash
pg_dump -U ⚠️ -h ⚠️ -d ⚠️ -F c \
  -f ops/rollback/pre-sprint-X-stage-4-$(date +%Y%m%d-%H%M%S).dump
```

记录文件路径 + 大小：

```
⚠️FILL: ops/rollback/pre-sprint-X-stage-4-20260429-073031.dump (⚠️N MB)
```

### 1.2 Idempotency 准备

确认 apply 脚本支持 idempotency（重跑安全）：

- unique key 设计：`⚠️FILL: 例如 (source_id, surface, historian_id)`
- skip 已存在行（不重写，不报错）

### 1.3 Architect ACK Apply 启动

```
Architect ACK: 已审 Stage 3 决策 + 备份就位 → Apply 启动
```

---

## 2. Apply 执行

```bash
⚠️FILL: 例如
cd services/pipeline
uv run python scripts/apply_resolve.py \
  --input docs/sprint-logs/sprint-{id}/dry-run-resolve-YYYY-MM-DD.md \
  --apply
```

记录：

- Started at: ⚠️TIMESTAMP
- Completed at: ⚠️TIMESTAMP
- Rows written: ⚠️N
- Rows skipped (idempotency): ⚠️N
- Errors: 0（必须 0）

---

## 3. Post-Apply 验证

### 3.1 SQL 直查行数

```bash
psql -c "SELECT count(*) FROM ⚠️ WHERE ⚠️"
# 期望: ⚠️N
```

### 3.2 V1-V11 Invariants 跑

```bash
DATABASE_URL=⚠️ uv run pytest tests/test_invariants_*.py -q
# 必须 22/22 全绿（任一回归 → 立即 rollback）
```

### 3.3 黄金集回归（如适用）

```bash
⚠️FILL: uv run pytest tests/test_golden_set.py -q
# 必须 ≥ baseline
```

### 3.4 Audit log 完整性

```bash
psql -c "SELECT count(*) FROM merge_log WHERE created_at > '⚠️stage4-start'"
# 期望: ⚠️N (与 §2 写入数对齐)
```

---

## 4. Gate 3 Check（→ Stage 5 解锁条件）

- [ ] DB 写入数 vs 决策数误差 ≤ 5%（超出触发 Stop Rule）
- [ ] V1-V11 invariants 全绿（任一回归 → rollback）
- [ ] audit log 完整
- [ ] errors = 0
- [ ] commit 已提交（含 apply 脚本输出 log）

---

## 5. 触发 Rollback 协议

如任一 Gate 3 检查失败：

```bash
# 立即恢复 pg_dump
pg_restore -U ⚠️ -h ⚠️ -d ⚠️ -c ⚠️FILL: ops/rollback/pre-sprint-X-stage-4-*.dump

# 验证 rollback 成功
DATABASE_URL=⚠️ uv run pytest tests/test_invariants_*.py -q
# 22/22 全绿（与 Stage 0 baseline 一致）
```

报告：

- Rollback 触发原因: ⚠️FILL
- 影响数据: ⚠️N rows
- 恢复时刻: ⚠️TIMESTAMP
- 下一步: ⚠️FILL（继续修因 + 再 apply / 终止 sprint / 等）

---

## 6. 给 Stage 5 的 Handoff 信号

```
✅ Sprint X Stage 4 Apply 完成
- Rows written: ⚠️N (skipped ⚠️M / errors 0)
- Pre-apply anchor: ⚠️FILL
- V1-V11: 22/22 全绿
- audit log: ⚠️N rows
→ Stage 5 Closeout 可启动
```

---

**Stage 4 完成 → Stage 5 启动。**
