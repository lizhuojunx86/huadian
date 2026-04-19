# T-P0-015: 帝鸿氏/缙云氏 Canonical 归并裁决

- **状态**：done
- **主导角色**：古籍/历史专家（historian）
- **协作角色**：管线工程师（DB 查询 + SQL 生成）
- **所属 Phase**：Phase 0
- **依赖任务**：T-P0-014 ✅（B-class 实体推迟至本任务）
- **创建日期**：2026-04-19
- **开始日期**：2026-04-19
- **完成日期**：2026-04-19

## 目标

裁决两个"X氏"尊称类人物是否应 merge 入黄帝 canonical：
- 帝鸿氏 (slug: `u5e1d-u9e3f-u6c0f`, id: `19ef3926-eaf1-42e1-ba4b-f0fc4b9de9dd`)
- 缙云氏 (slug: `u7f19-u4e91-u6c0f`, id: `ae47eddd-804b-4715-974a-d1eb99a19509`)

这两个条目在 T-P0-014 S-1 调研中被划为 B-class（historian ruled keep, no delete），
但"是否 merge 入黄帝"的归并决定被推迟到本任务。

## 范围（IN SCOPE）

1. 史源证据调研（五帝本纪 P24 + 左传注疏）
2. Historian 归并裁决（MERGE / KEEP-independent / 混合）
3. 如裁决 MERGE：dry-run JSON + merge SQL（soft-merge via merged_into_id）
4. DB 写入（红线操作，需用户确认）
5. 验证 + 收尾

## 风险

| # | 描述 | 缓解 |
|---|------|------|
| R1 | 帝鸿氏/缙云氏 merge 后，搜索"帝鸿氏"将返回黄帝 | 符合学术共识，API resolveCanonical 已支持别名穿透 |
| R2 | 缙云氏与黄帝的关系存在争议（黄帝别称 vs 黄帝时官名） | historian 裁决附依据，可被后续 ADR 推翻 |
| R3 | 四凶叙事中四个族系并列，merge 两个入同一 canonical 会破坏叙事结构 | 仅 merge 帝鸿氏（共识度高），缙云氏保留独立 |

## 交付物

- `services/pipeline/scripts/T-P0-015-s1-evidence.md` — 证据调研文档
- `services/pipeline/scripts/T-P0-015-dry-run.json` — merge 预览（如适用）
- `services/pipeline/scripts/T-P0-015-merge.sql` — merge SQL（如适用）
- `docs/STATUS.md` + `docs/CHANGELOG.md` 更新

## 验收标准

- [x] Historian 裁决有明确结论 + 史源依据 — (c) 混合：帝鸿氏 MERGE, 缙云氏 KEEP
- [x] active persons 152 → 151 ✅
- [x] person_merge_log 1 row (R4-honorific-alias) ✅
- [x] 黄帝 names 含帝鸿氏(alias) ✅
- [x] lint / typecheck / test 全绿 — pnpm test 52 pass + pytest 195 pass ✅
