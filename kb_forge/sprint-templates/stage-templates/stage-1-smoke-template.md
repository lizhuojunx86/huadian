# Sprint ⚠️FILL-ID Stage 1 — Smoke

> 复制到 `docs/sprint-logs/sprint-{id}/stage-1-smoke-YYYY-MM-DD.md`

## 0. 目的

用最小子集（5 段 / 1 章节 / 10 行）跑通 pipeline，验证基础设施 + prompt + invariants 能工作。**不是性能测试，是可行性验证**。

---

## 1. Smoke 子集定义

- **子集大小**：⚠️FILL `N 段 / N 章节 / N 行`
- **来源**：⚠️FILL `具体 fixture 路径`
- **预期 LLM cost**：⚠️FILL `≤ $X`
- **预期实体抽取数**：⚠️FILL `~ N 个`

---

## 2. 执行步骤

### 2.1 跑 ingest + extract

```bash
⚠️FILL: 例如
cd services/pipeline
uv run python -m src.cli ingest --source ⚠️ --book ⚠️ --paragraphs 0:5
uv run python -m src.cli extract --book ⚠️ --steps ner,relations --paragraphs 0:5
```

### 2.2 验证 pipeline 各组件

- [ ] **NER 输出**：返回结构化结果（不是 LLM 原始字符串）
- [ ] **Identity resolver**（如适用）：R1-R6 + GUARD_CHAINS 调用正常
- [ ] **DB load**：source_evidences 写入 / persons / etc
- [ ] **TraceGuard**：prompt version + cost / latency 记录
- [ ] **Invariants**：V1-V11 全绿

### 2.3 SQL 直查验证

```bash
⚠️FILL: 例如
psql -c "SELECT count(*) FROM persons WHERE deleted_at IS NULL"
psql -c "SELECT count(*) FROM source_evidences WHERE source_book_slug = 'xxx'"
```

记录数字：

```
⚠️FILL: smoke 后 active=730 / source_evidences=+5 / merge_log=111(不变)
```

---

## 3. Gate 0 Check（→ Stage 2 解锁条件）

- [ ] LLM cost ≤ §1 预算
- [ ] V1-V11 invariants 全绿
- [ ] 输出格式符合 schema（zod / pydantic 校验通过）
- [ ] 没有 silent failure（log 中无 ERROR）
- [ ] DB 数据可见（SQL 直查吻合预期）

如任一不通过 → 不得推进 Stage 2 → 立即诊断 + 修复（小修则 sprint 内修；大修触发 Stop Rule）。

---

## 4. 常见 smoke 问题

| 症状 | 可能根因 | 处理 |
|------|---------|------|
| LLM 输出不符 schema | prompt 版本问题 / model token limit | 调 prompt + retry |
| invariant 触发 | smoke 数据本身的 schema 问题 | rollback smoke + 修 fixture |
| TraceGuard 不记录 | observability 配置问题 | 触发 DevOps 维护 |
| cost 超预期 | LLM 调用次数问题 | 检查 prompt / batching |

---

## 5. 给 Stage 2 的 Handoff 信号

```
✅ Sprint X Stage 1 Smoke 完成
- LLM cost: $⚠️X / 预算 $⚠️Y
- 实体抽取: ⚠️N / 预期 ⚠️M
- V1-V11: 全绿
- DB 数据: ⚠️FILL 数字
→ Stage 2 Full 可启动
```

---

**Stage 1 完成 → Stage 2 启动。**
