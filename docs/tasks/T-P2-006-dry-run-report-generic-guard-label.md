# T-P2-006 — generate_dry_run_report Guard 标签泛化

## 元信息

| 字段 | 值 |
|------|-----|
| ID | T-P2-006 |
| 优先级 | P2 |
| 状态 | registered |
| 主导角色 | 管线工程师 |
| 创建日期 | 2026-04-27 |
| 触发 | Sprint H Stage 2 dry-run 验证（commit `8501ab9`）|

## 背景

`services/pipeline/src/huadian_pipeline/resolve.py:generate_dry_run_report()` 在显示 guard 拦截时硬编码 "R6 guard 拦截：N 对" 标签。Sprint H ADR-025 落地后 R1 也走 evaluate_pair_guards 接口，guard 拦截可能由 R1 / R6 / 未来 R2/R5 任一规则触发，但报告标签仍写 R6，造成显示混淆。

## 现象

- 实际逻辑正确（pending_merge_reviews 写入区分 proposed_rule 列）
- 仅显示 bug：用户看到 "R6 guard 拦截 8 对" 但实际 8 对全是 R1=200yr 拦截
- Sprint H Stage 2 dry-run 报告 §2.1 已加注释解释，作为短期 workaround

## 建议改动

```python
# Before:
print(f"R6 guard 拦截: {len(blocked)} 对")

# After:
print(f"Guard 拦截: {len(blocked)} 对")  # 含 R1/R6 等所有 rule-aware guard
for blk in blocked:
    print(f"  ({blk.proposed_rule}) {a} ↔ {b} — {blk.guard_type} ...")
```

## 验收条件

- [ ] generate_dry_run_report 移除硬编码 "R6"
- [ ] 每行拦截显示触发 rule（R1/R6/...）
- [ ] dry-run 测试用例覆盖 R1 拦截显示
