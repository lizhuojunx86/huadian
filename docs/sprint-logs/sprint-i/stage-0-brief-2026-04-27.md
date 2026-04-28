# Sprint I Brief — T-P1-028 follow-up: state_prefix_guard

## 0. 元信息

- **架构师**: Chief Architect
- **Brief 日期**: 2026-04-27
- **Sprint 形态**: 单 track 架构扩展（ADR-025 evaluate_pair_guards 框架内新增 guard 类型）
- **预估工时**: 2-3 天
- **PE 模型**: **Sonnet 4.6 试**（架构框架已立，本卡是扩展不是创设；fallback Opus）
- **触发事件**: Sprint H 数据揭示 R1 跨国 FP 中 ~38% 是"春秋同朝代不同国 (gap=0)"，dynasty-distance guard 无法覆盖；ADR-025 §6.2 显式承诺 Sprint I 落地 state_prefix_guard

## 1. 背景

Sprint G 项羽本纪 historian review 暴露 R1 跨国 FP 占 21 组 merge proposals 中 13 组 (62%)。Sprint H 落地 dynasty-distance guard (200yr 阈值) 拦截了其中 ~36-50% (跨 dynasty 案例)，但**剩余 ~50-64% 是春秋同朝代不同国** (鲁桓公↔秦桓公 / 晋悼公↔齐悼公 / 楚庄公↔秦庄公 等)，dynasty distance = 0 无法触发。

state_prefix_guard 目标：识别 surface form 中"国名前缀+谥号"模式 (鲁/秦/楚/齐/晋/...)，前缀不同时拦截 R1 候选，与 dynasty guard 互补覆盖剩余 FP。

## 2. 目标范围

### 必做
1. **states.yaml**：春秋 + 战国时期重要诸侯国名单 (≥12 个) + 每国别名/异称 (如"晋"=唐叔虞封地)
2. **谥号 regex pattern**：识别"国名 + 谥号"模式 (鲁桓公 → 国="鲁", 谥="桓"； 秦昭襄王 → 国="秦", 谥="昭襄")
3. **state_prefix_guard 函数**：复用 ADR-025 §2.1 evaluate_pair_guards 接口扩展（新 guard chain step）
4. **R1 集成**：state_prefix_guard 在 dynasty_guard 之后调用，命中→写 pending_merge_reviews (guard_type='state_prefix')
5. **单元测试 ≥6**：guard 命中场景 (鲁桓公↔秦桓公) + guard 不命中 (无前缀名) + 边界 (国名缺失) + dynasty + state 双 guard 协同
6. **dry-run 验证**：项羽δ + 秦γ 数据回跑，state_prefix 拦截数应覆盖剩余 ~38%

### 不做
- ❌ 不重构 evaluate_pair_guards 接口 (已稳定，仅扩展 guard chain)
- ❌ 不改 dynasty-periods.yaml (已稳定)
- ❌ 不做 entity-split 类操作 (Sprint H 范畴已覆盖楚怀王单点)
- ❌ 不做内容续推 (Sprint J 才推高祖本纪)
- ❌ 不开新 ADR (state_prefix 是 ADR-025 框架内扩展，写 ADR-025 addendum)

## 3. Stages

### Stage 0 — Inventory + Design (2-3 小时)

PE 调研项：
1. **R1 现状回顾**：Sprint H S2.3 已集成 evaluate_pair_guards(rule="R1")，state_prefix 在哪个调用点插入？是 dynasty_guard 之前/之后/并列？
2. **春秋战国诸侯国列表**：从 historian 字典 / 现有 disambiguation_seeds 提取 / 维基百科参考；初步 ≥12 个候选
3. **谥号字典**：项目是否已有 miaohao.yaml / shihao.yaml？如有复用，如无新建
4. **现有 surface forms 国名前缀分布**：SELECT 统计 person_names 表中含国名前缀的 surface 数量 (如多少行以"鲁"开头, 多少以"秦"开头)
5. **regex pattern 设计**：`^(鲁|晋|齐|秦|楚|卫|宋|吴|越|魏|韩|赵)([庄桓昭襄惠成穆悼平庄孝景灵献文武]+(王|公|侯))?$` — 类似模式，需 PE 调研后细化
6. **R6 是否需要相同 guard**：理论上 R6 也可能有跨国同 QID 案例，但 R6 已强证据 (QID anchor)；评估是否本 sprint 同步加 R6 state_prefix（默认: 不加，等数据驱动）

输出：docs/sprint-logs/sprint-i/inventory-2026-04-27.md

### Stage 1 — Design + ADR-025 Addendum

1.1 设计 states.yaml 结构 (建议参考 dynasty-periods.yaml 格式)
1.2 设计 state_prefix_guard 函数签名 + GUARD_CHAIN 顺序 (R1: dynasty_guard → state_prefix_guard 或并列?)
1.3 ADR-025 addendum：在 §5.1 已落地章节追加 "5.1.2 state_prefix_guard for R1"，描述本扩展，不开新 ADR
1.4 PE 完成 1.1-1.3 后报架构师签字

### Stage 2 — Implementation + 单元测试

2.1 states.yaml 落盘 (≥12 国，每国含别名/异称)
2.2 谥号 regex 实现 + 国名提取函数
2.3 state_prefix_guard 函数实现，复用 ADR-025 GuardResult 类型
2.4 evaluate_pair_guards 集成 (R1 链路 dynasty + state_prefix)
2.5 单元测试 ≥6 (本 brief §2 必做 #5)
2.6 R6 路径回归测试 (确保 R6 unchanged)

### Stage 3 — Dry-Run 验证 + Historian 复核 (条件触发)

3.1 当前 DB (663 active persons) re-run dry_run_resolve.py
3.2 输出 docs/sprint-logs/sprint-i/dry-run-2026-04-XX.md
3.3 验证拦截数：
- 总 R1 拦截 = dynasty_guard + state_prefix_guard 联合
- state_prefix_guard 单独拦截数应 ≈ Sprint H S2.5 留下的"春秋同朝代不同国"残余
- 偏离 >2x 预测 → Stop Rule
3.4 如 states.yaml 国名列表有争议（如"巴/蜀/吴"是否春秋诸侯）→ 切 historian 微 session 复核

### Stage 4 — Closeout

4.1 T-P1-028 task card 状态 done (Sprint H 已部分 done，本 sprint 完成 follow-up)
4.2 ADR-025 status 保持 accepted，addendum 已加入
4.3 STATUS.md / CHANGELOG.md / sprint-i-retro.md
4.4 衍生债登记 (如有，建议关注 NER prompt 的国名识别质量)

## 4. Stop Rules

1. **states.yaml 国名争议**：≥1 国名 PE 起草后无法确定（如"邾/莒/越"等次要诸侯）→ Stop 切 historian 微 session
2. **regex 过度匹配**：guard 在 dry-run 中拦截非"国+谥号"模式的 person pair (false positive on guard 本身) → Stop 重设计 regex
3. **dry-run state_prefix 拦截 0 个**：意味着实现失效或 R1 baseline 已变化 → Stop 诊断
4. **dry-run state_prefix 拦截 >2x 预测**：阈值或 regex 过宽 → Stop
5. **R6 路径回归测试任一失败** → Stop 回滚

## 5. 关联 & Follow-up

- 上游：Sprint H Sprint H ADR-025 §6.2 显式承诺
- 平行：T-P0-028 triage UI (本卡产出新 pending_merge_reviews 行 → triage UI 数据源)
- 下游：Sprint J 高祖本纪 ingest (state_prefix_guard 上线后跨秦汉 FP 应大幅降低)
- ADR-025 addendum (不开新 ADR)
- T-P2-007 mention 段内位置切分 (本卡不动)
- T-P2-009 ADR-026 §3 第 5 闸门 (本卡不动 entity-split，故第 5 闸门暂不需立即落地)

## 6. 角色边界

| 角色 | 职责 |
|------|------|
| 管线工程师 (Sonnet 4.6 试) | Stages 0-4 全部 |
| 架构师 | 本 brief + Stage 1 设计签字 + ADR-025 addendum 签字 + Stop Rule 裁决 |
| Historian | 仅 Stage 0 §2 国名列表复核 + Stage 3.4 争议国名裁决 (条件触发，不强制开会话) |
| 后端工程师 | 不参与 |

## 7. 收口判定

- ✅ states.yaml ≥12 国落地，含别名
- ✅ state_prefix_guard 函数 + ≥6 单元测试 + R6 路径无回归
- ✅ ADR-025 addendum 落地 (不新开 ADR)
- ✅ 当前 DB dry-run state_prefix 拦截数 ≈ Sprint H 残余 38%（项羽δ+秦γ 累计 ~10 对）
- ✅ V1-V11 全绿不回归
- ✅ Sprint G 暴露的 R1 跨国 FP 在 Sprint G→H→I 累计降至 ≤10%（架构师 Sprint J 跑后验证）

## 8. 节奏建议

第一会话：Stage 0 inventory + Stage 1 design + ADR-025 addendum draft → 挂起等架构师 ADR-025 签字
第二会话：Stage 2 实施 + Stage 3 dry-run + Stage 4 收档（如 Stage 3 触发 Stop Rule #1 国名争议则切 historian 微 session）

不要把 Stage 0-4 全塞一个会话——design 阶段需要架构师签字插入。

## 9. Sonnet 4.6 试用观察重点

本 sprint 适合 Sonnet 试因：
- 框架已立 (ADR-025 evaluate_pair_guards)，本卡是扩展不是创设
- 类似 Sprint G 真书 ingest 的"按 pattern 执行"性质
- Stop Rule 已细化

观察项：
- Stage 0 数据调研精度 (sprint H 已暴露 PE Sonnet 列名错的 yellow flag, 本 sprint 看是否复现)
- regex 设计的边界 case 处理
- TodoList 与 brief 1:1 对齐度
- dry-run vs apply 区分
