# T-P0-006 — α 扩量跑（周本纪）

- **状态**：in_progress
- **开始**：2026-04-19
- **优先级**：P0（α 最后 blocker）
- **主导角色**：管线工程师
- **协作角色**：首席架构师（mini-RFC + 闸门 ACK + historian 代行）
- **依赖**：T-P0-023 Stage 1（证据链激活，✅ done）/ T-P0-016（V6 不变量，✅ done）/ T-P0-022+020（F10/F3/F4 清理，✅ done）

## 背景

α 里程碑要求 pipeline 完整路径在"非 β 章节"上跑通。史记本纪已完成 3 章（五帝/夏/殷），周本纪是 α 门槛的首个扩量章节。本 sprint 同时承担：

1. 证据链 Stage 1（ADR-015）首次实弹验证 — source_evidences 表从 0 行到 N 行
2. 跨书 identity resolution 在 200+ persons 规模下的首次验证
3. α 里程碑的"扩量路径可行性"证明

## 当前 DB 快照（sprint 起点）

| 指标 | 值 |
|------|-----|
| books | 5（shiji×3 + shangshu×2） |
| raw_texts | 126（29+35+35+7+20） |
| persons | 174 total（153 active / 16 merge-deleted / 5 pure-deleted） |
| person_names | 282（0 with evidence） |
| source_evidences | **0 行** |
| person_merge_log | 23 行（R1×12 / R3-non-person×5 / R3×2 / R5×1 / R4-honorific-alias×1 / manual-fix×1 / manual-historian×1） |
| provenance_tier enum | 6 值（含 seed_dictionary） |
| V1-V6 | ✅ 全绿 |
| V7 | ⚠️ warning 级（0/249 = 0.0% 覆盖率） |

## Scope

**In**：
- ingest + extract + load 周本纪单章
- source_evidences 首批行写入 + FK 正确性验证（ADR-015 Stage 1 实弹）
- resolve_identities() 全库重跑 → merge 候选报告（按新-新 / 新-旧 / 旧-旧 分类）
- 对 historian 审通过的候选执行 apply_merges()
- V1-V7 扩量后仍全绿（V7 warn 级，覆盖率监控）
- F12 W2 增量统计（不修）
- Tier-S slug 白名单预扩（周文王等）

**Out**：
- 秦本纪 / 秦始皇本纪 / 其他本纪（留给 α 后常规运营）
- F12 W2 对称修复（独立 T-P0-026）
- Stage 2 text-search backfill（T-P0-024）
- 字典加载器（T-P0-025）

## 验收标准

- [ ] 周本纪全章 ingest 完成，raw_texts + persons + person_names 行数据入库
- [ ] source_evidences 表首批行写入，5 列（raw_text_id / book_id / provenance_tier=ai_inferred / prompt_version / llm_call_id）全部正确
- [ ] 本 sprint 新增 person_names 的 source_evidence_id 覆盖率 100%
- [ ] V1-V7 全绿（V7 warning 级，老 249 行仍 NULL 为预期）
- [ ] merge 候选 dry-run 报告分三类输出，historian 审通过的 groups 已 apply
- [ ] Tier-S slug 白名单更新，周本纪 tier-S 人物无 unicode hex fallback
- [ ] F12 增量记入 debts，T-P0-026 任务卡已建骨架

## LLM 成本预算

| 项目 | 预算 |
|------|------|
| 总 cap | $2.00 |
| 报警线 | $1.00（超出先停报告） |
| 单 chunk 上限 | $2.00（超出立即停止） |
| 预估 | $0.4-1.8（周本纪 ~40-60 段，v1-r4 prompt） |
| 参考 | α 前三章 $1.77 / 99 段 / 169 persons |

## 红线

- ⚡ 真实 API 调用花钱 — Stage 1 narrow smoke 前必须用户确认
- 🚫 `merge apply` 必须走红线协议（ADR-014 唯一入口）
- 🚫 任何 DB schema 变更绝对禁止 — 走 ADR 流程
- 🚫 不触碰 CI Step 4c workaround（T-P1-005 另外处理）
- 🚫 禁止 TRUNCATE / DROP / ALTER TABLE

## Stage 拆分

| Stage | 内容 | 产出 |
|-------|------|------|
| **0a** | 创建本任务卡 | `docs/tasks/T-P0-006-alpha.md` |
| **0b** | 读周本纪正文 → Tier-S slug candidate → 架构师给 mapping → 更新 `tier-s-slugs.yaml` | slug 白名单扩列 |
| **0c** | 4 闸门 Gate 1-4 | pg_dump 锚点 / schema / 缓存进程 / V1-V7 基线 |
| **0d** | CLI resolve 子命令评估（如需） | CLI 扩展或 Python 脚本 |
| **1** | Narrow smoke：ingest 1-2 段 → load → 验证 source_evidences 首行 | evidence 首弹验证 |
| **2** | 全章 ingest 周本纪 → load → V1-V7 | 全章数据入库 |
| **3** | resolve_identities() → 三分类 dry-run 报告 | merge 候选报告 |
| **4** | Historian 审 → apply_merges() → V1-V7 | merge 执行 |
| **5** | F12 增量 + sprint 产出报告 | 统计报告 |
| **6** | Book-keeping：STATUS / CHANGELOG / T-P0-026 新建 | 收尾文档 |

## 关联文档

- mini-RFC：架构师会话 2026-04-19
- ADR-014（apply_merges 唯一入口）
- ADR-015 §9 Implementation Notes（evidence 写路径决策）
- T-P0-023 sprint 收官（STATUS + CHANGELOG 2026-04-19）
- T-P0-006-beta-shangshu.md（β 路线参考）
- docs/debts/T-P0-006-beta-followups.md（F8 / F12 等遗留）

## Commit 风格

```
# Stage 0（合并提交）
docs: T-P0-006-alpha Stage 0 — task card + slug whitelist + gates

# Stage 1
feat(pipeline): T-P0-006-alpha Stage 1 — evidence narrow smoke (N段)

# Stage 2
feat(pipeline): T-P0-006-alpha Stage 2 — zhou-ben-ji full ingest (N paragraphs, M persons)

# Stage 3
feat(pipeline): T-P0-006-alpha Stage 3 — identity resolver dry-run (N candidates)

# Stage 4
feat(pipeline): T-P0-006-alpha Stage 4 — merge apply (N groups)

# Stage 5-6
docs: T-P0-006-alpha close — STATUS + CHANGELOG + T-P0-026
```
