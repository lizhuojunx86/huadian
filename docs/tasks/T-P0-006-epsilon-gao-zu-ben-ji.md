# T-P0-006-ε — 高祖本纪摄入 + identity resolution

- **状态**: done
- **开始**: 2026-04-28
- **完成**: 2026-04-28
- **优先级**: P0
- **主导角色**: 管线工程师
- **协作角色**: 首席架构师（Stage 0 brief + 闸门 ACK + S4.3' inline 裁决）/ 古籍专家（Stage 3 merge review）
- **依赖**: Sprint J Stage 2 ✅（748 active / V1-V11 全绿）
- **所属 Sprint**: Sprint J

## 背景

Sprint J 主线任务。高祖本纪是《史记》十二本纪第八篇（本次摄入），聚焦汉高祖刘邦建立汉朝全程。
人物密度高（+85 新人），以汉初功臣群体为主线；slug dedup 问题（5 对 pinyin/unicode 并存）是本 sprint 的技术债主线。

S4.3' 新增：`_swap_ab_payload()` bug fix — guard_payload dynasty/state 列位
transpose bug（pair-order normalization 触发 swap 时 payload 未同步），附 5 个 regression tests。

## 结果

| 指标 | 值 |
|------|-----|
| 新增章节 | 史记·高祖本纪 |
| NER persons | +85 新增（ingest 后 663→748） |
| LLM 成本 | $0.79（$0.04 smoke + $0.75 full） |
| Merge proposals | 23 组（dry-run） |
| Historian 裁决 | 14 approve + 7 reject + 2 G7 sub-merges |
| 实际 apply | 19 soft-deletes（9 confirm + 2 textbook-fact + 6 slug-dedup + 2 G7 sub-merges） |
| Active persons | 663 → 748 (ingest) → 729 (post-merge) |
| merge_log 总计 | 111（pre: 92，new: 19） |
| R1 FP 治理率 | 100%（state_prefix_guard 7/7 拦截，0 漏） |
| Guard 拦截 | 18（cross_dynasty 11 / state_prefix 7） |

## Commits

| Hash | 描述 |
|------|------|
| `203cb7c` | docs: T-P0-006-ε dry-run correction §correction-2026-04-28（display-layer dynasty transpose） |
| `7fa75a0` | fix(pipeline): dry_run_report Dynasty A/B column ordering (_swap_ab_payload + 5 tests) |
| `a85f599` | fix(pipeline): T-P0-006-ε Stage 4 apply (19 merges, historian 07db893) |

## 关键裁决

### S4.3 Stop Rule 触发 → 架构师 inline 裁决 A+C+D

- **Stop Rule 原因**：S4.3 pre-flight SELECT 发现 吕后=西汉、刘盈=西汉，与 dry-run report 显示值不符
- **裁决 A**：跳过 S4.3 DB fix（DB 值正确；报告有 display bug，不是 DB bug）
- **裁决 C**：修正 dry-run 报告（§correction-2026-04-28，commit 203cb7c）
- **裁决 D**：修复底层 Python bug（`_swap_ab_payload()` + 5 regression tests，commit 7fa75a0）
- **T-P1-031 NOT created**（无真实 dynasty bug）

### Textbook-fact 累计 4 次 → ADR-014 addendum

| # | Sprint | 对 | 关系 |
|---|--------|-----|------|
| 1 | Sprint E | 重耳 → 晋文公 | 名→庙号 |
| 2 | Sprint G | 项籍 → 项羽 | 名→字 |
| 3 | Sprint J | 嬴政 → 始皇帝 | 名→尊号 |
| 4 | Sprint J | 陈胜 → 陈涉 | 名→字 |

4 次 ≥ 3 次阈值 → T-P1-030 候选（ADR-014 addendum 草案）

### G7 楚怀王 entity-split sub-merges

G7a 怀王（高祖本纪新实例）→ 熊心（canonical）
G7b 义帝（高祖本纪新实例）→ 熊心（canonical）
merge_rule = `R1+historian-split-sub`

### 田广 §4.5 slug dedup

SELECT 确认仅 1 active 田广，不追加第 20 条 SD。

## 衍生债务

| 任务 | 类型 | 来源 |
|------|------|------|
| T-P1-030 | ADR-014 addendum（textbook-fact × 4） | 本 sprint |
| T-P1-027 增项 | dry-run report display-layer 审查 | S4.3' |
| T-P2-005 增项 | V13 alias uniqueness invariant 候选 | G7 alias 重复 |
| T-P2-009 升级候选 | 架构师 inline 裁决局限性 → formal protocol | S4.3' |

## Sprint J → Sprint K 传递

- Active persons: **729**
- merge_log: **111**
- V1=0, V9=0, V10=0, V11=0（全绿）
- 下一章节候选：高后本纪 / 吕太后本纪（接续西汉初）
