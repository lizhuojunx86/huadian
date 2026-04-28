# Sprint K Stage 0 — PE Inventory（T-P0-028 Triage UI · Pipeline 段）

- **角色**：Pipeline Engineer (Sonnet 4.6)
- **日期**：2026-04-28
- **范围**：Sprint K Stage 0 PE 段 inventory（仅 SELECT 只读，不动 DB）
- **关联**：架构师 brief `docs/sprint-logs/sprint-k/stage-0-brief-2026-04-28.md`
- **形态**：调研文档 — 数据采样 + V1→V2 衔接设计 + 决策语义评估

---

## TL;DR

| 项 | 结论 |
|----|------|
| seed_mappings pending_review 实数 | **45 条**（brief "~50" 估算合理） |
| pending_merge_reviews pending 实数 | **0 条**（brief "~16" 是 dry-run 累计估算 ≠ DB 实际，⚠️ 见 §1.2） |
| split_for_safety 是否属 V1 pending 范围 | **否**，已 apply 进 entity_split_log（audit-only）；brief §1 表注释口径误用，建议从 V1 scope 删除 |
| V2 hook 推荐位置 | **方案 B（PE 异步 job + 显式触发 endpoint）**；event-driven NOTIFY 排除（over-engineering for V2） |
| approve/reject/defer 在 V1 对 pipeline 影响 | **零侵入**：R6 prepass + R1-R5 resolver 行为不依赖 mapping_status 之外的任何决策字段；reject/deferred 在下次 dry-run 自然不再候选（已生效，无需新过滤） |

---

## §1 数据采样

### §1.1 seed_mappings WHERE mapping_status='pending_review'

**总数**：45 条（DB 实测，2026-04-28 14:xx CST）  
**全部 `mapping_created_at` 落在**：`2026-04-21 23:43–23:45 UTC`（同批次写入，来自 Sprint B Stage 2 execute）

**按 mapping_method 分布**：

| mapping_method | count | 含义 |
|----------------|------:|------|
| r2_alias_multi | 24 | R2（alias 匹配）多命中 → 不能自动绑定 |
| r1_exact_multi | 17 | R1（exact 主名匹配）多命中 |
| r3_name_scan_multi | 3 | R3（人名扫描）多命中 |
| r2_alias | 1 | 单命中但被 historian 显式降级（Sprint C wei-zi-qi 路径） |

> 三个 `_multi` 方法的语义共同体：在 wikidata_adapter 上一个 surface 命中多个 QID（或一个 QID 命中多个 person target），无法仲裁默认胜方 → 全部入 `pending_review` 等 historian 决断。

**代表性样本 8 条（按 surface 字典序）**：

| # | surface | QID | target_slug | target_name (zh-Hans) | dynasty | conf | method | 推测决策类型 |
|---|---------|-----|-------------|-----------------------|---------|-----:|--------|--------------|
| 1 | 于志寧 | Q1017968 | u614e-u9753-u738b | 慎靓王 | 东周 | 0.00 | r2_alias_multi | reject（surface 与 target 学术不符；同 QID 还有多个 alias 入了同一 entry） |
| 2 | 伯夷 | Q61314449 | bo-yi | 伯夷 | 上古 | 0.00 | r1_exact_multi | choose-one：本条 vs. 同 surface 第 2 条（Q10787522）择一 active |
| 3 | 伯夷 | Q10787522 | bo-yi | 伯夷 | 上古 | 0.00 | r1_exact_multi | 与 #2 互斥 |
| 4 | 司馬遷 | Q9372 | u53f8-u9a6c-u8fc1 | 司马迁 | 西汉 | 0.00 | r3_name_scan_multi | approve（繁简同人）+ 与 #12 互斥 |
| 5 | 启 | Q186544 | wei-zi-qi | 微子启 | 商 | **0.85** | r2_alias | **特例**：Sprint C 由 active 降级（架构师 ADR-014 / wei-zi-qi 后改 Q855012），保留 pending_review 待最终裁决 |
| 6 | 姚 | Q65801317 | u59da | 姚 | 西周 | 0.00 | r1_exact_multi | choose-one with #10（同 surface 多 QID） |
| 7 | 延 | Q19825596 | u8d67-u738b | 赧王 | 东周 | 0.00 | r2_alias_multi | reject（surface=单字"延" 跟"赧王"无可考关联） |
| 8 | 徐浩 | Q11070799 | u614e-u9753-u738b | 慎靓王 | 东周 | 0.00 | r2_alias_multi | reject（surface 是宋朝书法家，与"慎靓王"无关；属 wikidata seed scrape 噪音） |

**关联 SE**：seed_mappings 写入时同步写 `source_evidences (kind='seed_dictionary')` per ADR-021；当前 active=159 行，pending=45 行的 SE 已存在但 evidence_kind 标签为 seed_dictionary（与决策状态正交）。

### §1.2 pending_merge_reviews WHERE status='pending'

**总数**：0 条（DB 实测）

**按 status × guard_type 分布**：

| status | guard_type | count |
|--------|------------|------:|
| (no rows) | — | 0 |

⚠️ **与 brief §1 表"~16 条"严重不符**。Brief 数字是 dry-run 报告中累计观察到的拦截数（Sprint H 8 + Sprint I 7 state_prefix + Sprint J 11 cross + 7 state = 累计观察值），但 DB **从未真正 INSERT 过 pending_merge_reviews 行**。

**根因分析**（基于 `services/pipeline/src/huadian_pipeline/resolve.py:867-883` + `scripts/apply_resolve.py`）：

1. `pending_merge_reviews` 仅在 `apply_merges()` 内 `dry_run=False` 路径写入（同事务、ON CONFLICT DO NOTHING、partial unique index 仅在 status=pending）。
2. Sprint G/H/I/J 各章 apply 阶段，**ResolveResult 是 historian 复审过的人工 curation list**（merged_by 标签为 `pipeline:stage4-historian-XXXXX`），并非 `resolve_identities()` 直跑结果。
3. 这种 simplified ResolveResult 不带（或被刻意清空）`blocked_merges` 字段 → INSERT 循环 0 次执行 → DB 空。
4. dry-run 观察到的拦截只存在于 `docs/sprint-logs/sprint-{g,h,i,j}/dry-run-resolve-*.md` 报告内，**没有持久化通道**。

**代表性形态样本**（取自 `docs/sprint-logs/sprint-j/dry-run-resolve-2026-04-28.md`，假如这些拦截被持久化时的 row 形态）：

| # | guard_type | proposed_rule | name_a | dynasty_a | name_b | dynasty_b | gap_yr | payload 关键字段 |
|---|------------|---------------|--------|-----------|--------|-----------|------:|------------------|
| 1 | cross_dynasty | R1 | 周成王 | 西周 | 楚成王 | 春秋 | 286 | midpoint_a/b, gap_years, threshold=200 |
| 2 | cross_dynasty | R1 | 秦康公 | 西周 | 密康公 | 春秋 | 286 | 同上 |
| 3 | cross_dynasty | R1 | 楚灵王 | 西周 | 灵王 | 春秋 | 286 | 同上 |
| 4 | state_prefix | R1 | 鲁桓公 | 春秋 | 秦桓公 | 春秋 | 0 | state_a=鲁, state_b=秦, raw_state_*, name_* |
| 5 | state_prefix | R1 | 齐悼公 | 春秋 | 晋悼公 | 春秋 | 0 | state_a=齐, state_b=晋 |
| 6 | state_prefix | R1 | 齐襄公 | 春秋 | 秦襄公 | 春秋 | 0 | state_a=齐, state_b=秦 |
| 7 | cross_dynasty | R6 | (R6 路径示例) | — | — | — | — | proposed_rule=R6, threshold=500 |

> 说明：以上 7 条是"如果 Sprint J Stage 4 走 apply_resolve.py 完整路径会写入"的形态；当前 DB 0 行是因为 Sprint G→J apply 走的是 historian-curated list 路径，blocked_merges 在过程中被旁路。

### §1.3 split_for_safety 不在 V1 范围（口径澄清）

Brief §1 表格列了"split_for_safety guard blocks"作为 pending_merge_reviews 的 guard_type 之一，**但代码事实**：

- `pending_merge_reviews.guard_type` 当前只能为 `cross_dynasty` / `state_prefix`（GUARD_CHAINS 注册的两个 guard `r6_temporal_guards.py:173-181`）
- `split_for_safety` 是 **`entity_split_log.operation` 的枚举值**（ADR-026 协议产物，audit-only 表，CHECK constraint：`operation IN ('redirect','split_for_safety')`）
- entity_split_log 当前 2 行（Sprint H T-P0-031 楚怀王案）— **均为已 apply 的审计行，无 pending 概念**

**建议**：V1 triage UI scope **不含 entity_split_log**。如未来需要 historian 复核 entity-split 操作（"事后回滚"），属 V3+ 议题（ADR-026 §3 第 5 闸门 / T-P2-009 backlog 范畴）。

### §1.4 数据采样小结

| 类别 | brief 估值 | 实测 | 偏差原因 |
|------|-----------|------|----------|
| seed_mappings pending_review | ~50 | **45** | 估算合理 |
| pending_merge_reviews pending | ~16 | **0** | dry-run 拦截累计 ≠ DB 实际写库；apply 旁路问题 |
| split_for_safety | "16 条之一" | N/A | 口径混淆 entity_split_log audit ≠ pending queue |

⚠️ **Stage 1 设计请确认**：架构师是否要求 V1 把"dry-run 累积观察到的拦截"也作为 triage 入口（即 BE 加补写 pending_merge_reviews 的胶水层）？还是 V1 仅消费当前 DB 实际行？两种方案对 BE/FE 工作量差异巨大。

---

## §2 V1 → V2 衔接点（hook 位置评估）

### §2.1 V1 决策语义（brief §2 已锁定）

V1 仅做 status mark：
- **approve seed_mapping**：`UPDATE seed_mappings SET mapping_status='active' WHERE id=$1`
- **reject seed_mapping**：`UPDATE seed_mappings SET mapping_status='rejected' WHERE id=$1`
- **defer seed_mapping**：状态保持 `pending_review`（或加 `triage_decisions` 关联记 deferred 标记）
- **approve/reject/defer pending_merge_reviews**：`UPDATE pending_merge_reviews SET status=$2, resolved_at=now(), resolved_by=$3 WHERE id=$1`

**V1 不触发任何下游 pipeline 行为**。

### §2.2 V2 候选下游行为

| 决策 | V2 自动动作 | 影响表/逻辑 |
|------|-------------|-------------|
| approve seed_mapping | 已经是 `mapping_status='active'`，无需额外 SQL，但应**触发 R6 prepass 重跑**（让新增 active mapping 在下次 resolve 时生效） | `_r6_prepass()` cache 失效 + 后续 ingest 章节自动用新 seed |
| approve pending_merge_reviews | 调 `apply_merges()` 路径，把这一对 person 实际 merge（写 person_merge_log + 更新 persons.deleted_at/merged_into_id）。**注意 ADR-014 merge 铁律 + § 数据形态契约级决策**：这条路径必须经过 4 闸门 + 架构师 ACK，不能 V2 直跑。 | `persons` / `person_merge_log` |
| reject seed_mapping / merge | V1 已足够（status 变即生效），V2 无需新动作 | — |
| defer | V1/V2 同语义，都是"等下次再说" | — |

### §2.3 三个 hook 方案对比

#### 方案 A — BE service 层 hook（同步）

```
Mutation.recordTriageDecision(itemId, decision)
  ↓ BE service 层
  ├─ UPDATE triage_decisions
  ├─ UPDATE seed_mappings.mapping_status / pending_merge_reviews.status
  └─ if V2 && decision=='approve':
      ├─ if seed_mapping: 调 PE HTTP endpoint /pipeline/r6-prepass-refresh
      └─ if merge: 调 PE HTTP endpoint /pipeline/apply-merge-pair（带 4 闸门 token）
```

| 优势 | 劣势 |
|------|------|
| 实现简单（mutation 同步链） | BE 多承一道下游契约 |
| 错误反馈即时（mutation 失败可回滚 status） | apply_merges 是重操作（事务 + 多表写），同步阻塞 mutation 数百 ms~秒级 |
| 决策可回滚（同事务） | BE 需调用 PE → 跨语言/跨服务 RPC，失败语义复杂 |
|  | 违反 ADR-014：架构师 ACK 闸门必须人工，不可同步 RPC 自动绕过 |

#### 方案 B — PE 异步 job（轮询/拉取） ⭐推荐

```
Mutation.recordTriageDecision(itemId, decision)
  ↓ BE service 层（仅写 triage_decisions + status，事务结束）
  ↓
PE 侧 cron/Prefect job（每 5 min 或手工触发）
  ↓ SELECT triage_decisions WHERE downstream_applied=false
  ├─ 对 approve seed_mapping 行 → reset _r6_prepass cache（轻量、幂等）
  └─ 对 approve merge 行 → **不自动 apply**，而是产出 candidate.json 给 PE 人工 4 闸门走
  ↓ UPDATE triage_decisions SET downstream_applied=true
```

| 优势 | 劣势 |
|------|------|
| BE / PE 完全解耦（BE 只写 status，PE 只读） | 决策→生效有延迟（job 周期） |
| ADR-014 4 闸门约束自然保留（PE job 只产 candidate，不自动 apply） | 需建 triage_decisions 表 + downstream_applied 字段 |
| 失败可重试（job 幂等，下次再跑） | 多一份 PE 周期任务运维 |
| BE mutation 始终轻量（不阻塞 historian UI） |  |

#### 方案 C — Event-driven (PG NOTIFY → PE listener)

```
Mutation.recordTriageDecision(...)
  ↓ BE 事务 INSERT triage_decisions + NOTIFY triage_event payload=item_id
  ↓
PE 长连接 LISTEN triage_event
  ↓ 收到 notify → 立即处理（同方案 B 的 PE 侧逻辑）
```

| 优势 | 劣势 |
|------|------|
| 实时性高（毫秒级） | PE 需常驻 listener 进程 → DevOps 多一个常驻服务 |
| 解耦同 B（BE 不调用 PE） | NOTIFY payload 8KB 限制；多消费者协调复杂 |
| 自然支持多 historian 并发场景 | V1 单 historian、V2 也大概率只有 1 hist → 实时性需求弱 |
|  | listener 崩溃 → notify 丢失（需补 fallback poller，回到方案 B） |

**评估**：
- V2 多 historian / 高吞吐场景 = 不存在（架构现状 1 historian / 60 条积压）
- 方案 C 提供的实时性收益几乎为 0（hist 不会盯着 UI 等 60 秒结果）
- 方案 C 引入常驻进程 + 容错复杂度，**over-engineering for V2**
- **排除方案 C**，保留为 V3+ design space 备忘（如未来真有跨 historian 协作 + 实时仪表盘需求再评估）

### §2.4 推荐：方案 B（PE 异步 job + 显式触发 endpoint）

**推荐理由**：
1. **ADR-014 兼容**：merge 铁律要求架构师 ACK，PE job 只产 candidate 不自动 COMMIT，天然合规
2. **BE 简洁**：mutation 仅 1 张表 UPDATE，事务短小、回滚明确
3. **PE 自治**：R6 prepass cache 失效是 PE 内部细节，不暴露给 BE
4. **V1 → V2 升级路径平滑**：V1 不实施 PE job，但 V1 schema 已留 `downstream_applied` 字段（默认 false）+ 加索引；V2 才添 PE 端 job 实现

**V1 schema 建议（BE 起 ADR-027 时确认）**：
```sql
CREATE TABLE triage_decisions (
  id uuid PRIMARY KEY,
  item_type text NOT NULL CHECK (item_type IN ('seed_mapping','pending_merge_review')),
  item_id uuid NOT NULL,
  decision text NOT NULL CHECK (decision IN ('approve','reject','defer')),
  decided_by text NOT NULL,
  decided_at timestamptz NOT NULL DEFAULT now(),
  reason text,
  downstream_applied boolean NOT NULL DEFAULT false,    -- V2 hook
  downstream_applied_at timestamptz,                    -- V2 hook
  notes jsonb
);
CREATE INDEX idx_triage_decisions_pending_downstream
  ON triage_decisions (decided_at)
  WHERE downstream_applied = false;
```

> `downstream_applied=false` 在 V1 永远保留（PE job 不存在），V2 才被 PE job UPDATE。

---

## §3 决策状态对 pipeline 影响评估

### §3.1 当前 pipeline 路径对决策状态的依赖

代码路径审计（`services/pipeline/src/huadian_pipeline/resolve.py`）：

| 路径 | 读取字段 | 状态过滤 |
|------|----------|----------|
| `_r6_prepass()` | `seed_mappings.target_entity_id` | **`WHERE mapping_status='active'`**（idx_seed_mappings_target partial index） |
| `_load_persons()` | `persons.deleted_at IS NULL` | 不读 seed_mappings/pending_merge_reviews |
| `evaluate_pair_guards()` | 仅 PersonSnapshot.dynasty / name | 不读决策表 |
| `apply_merges()` 写 pending_merge_reviews | INSERT ON CONFLICT WHERE status='pending' | partial unique index 仅 pending |

### §3.2 V1 决策对 pipeline 影响（逐条）

| 决策 | mapping_status / status 变化 | 对 pipeline 影响 |
|------|-----------------------------|------------------|
| approve seed_mapping (pending_review → active) | seed_mappings 进入 R6 prepass 候选池 | ⚠️ **影响下次 dry-run**：新加一个 active mapping → R6 prepass 多一个 QID 桶 → 可能产生新 R6 merge proposal。**V1 mutation 单纯变 status 不重跑 prepass**，但**下次有人手动跑 dry_run_resolve.py 时，新 mapping 会自动生效**。这不是问题，是预期行为。 |
| reject seed_mapping (pending_review → rejected) | 退出 R6 prepass 候选池 | **零影响**：rejected 行已被 `WHERE mapping_status='active'` 过滤；下次 dry-run 自然不再被消费 |
| defer seed_mapping (status 不变) | mapping_status 保持 pending_review | **零影响**：pending_review 本来就不在 active partial index → 当前不影响 R6 prepass。`triage_decisions.decision='defer'` 行只对 UI 有意义，pipeline 不读 |
| approve pending_merge_reviews (pending → accepted) | partial unique index 不再覆盖该行 | **V1 零影响**：pipeline 不读 `accepted` 行；apply_merges 写时 ON CONFLICT WHERE pending → 不冲突，可重复写 pending（但 V1 也不写）。**V2 hook 才会调 apply_merges() 做实际 person merge** |
| reject pending_merge_reviews (pending → rejected) | partial unique index 不再覆盖 | **零影响**，下次 dry-run 如再次产出同对 → ON CONFLICT 是 status=pending，rejected 行不阻碍重新 INSERT pending（即 historian 之前 reject 过的对，下次 dry-run 重跑会再写一条新 pending → 这是潜在问题 §3.4） |
| defer pending_merge_reviews (status 仍 pending) | 不变 | **零影响**，可被下次 dry-run 重写（ON CONFLICT DO NOTHING） |

### §3.3 V1 不影响的证据汇总

1. **R6 prepass 仅读 active**：`idx_seed_mappings_target ... WHERE mapping_status='active'` 保证 reject/deferred/pending_review 永不进入 R6 候选池
2. **R1-R5 resolver 不读决策表**：score_pair 只读 PersonSnapshot（name/dynasty/aliases），与 seed_mappings / pending_merge_reviews 完全无关
3. **V11 invariant 也不读 status**：只读 active person → seed_mappings → entry → 同 entry 多 active 的违反（只在 active 范围内）
4. **apply_merges 写 pending_merge_reviews 时只关心 partial unique index 上的 pending 行**，与 accepted/rejected/deferred 隔离

**结论**：V1 仅状态变更**无任何 pipeline 行为副作用**，PE 端零集成工作量。

### §3.4 隐患：rejected pending_merge_reviews 在下次 dry-run 重写

**场景**：historian 在 V1 把某条 cross_dynasty 拦截 reject 了；下个 sprint 跑 dry_run_resolve.py，因为 person 仍存在、guard 仍判定 blocked → 又写一条 status=pending 的新行。

**当前行为**：partial unique index `WHERE status='pending'`，旧 rejected 行不冲突，新 pending 行成功 INSERT → historian 看到"一样的拦截又来了"。

**V1 短期可接受**（积压低、historian 一次决策影响轻），**V2 改进候选**：
- 选项 1：`apply_merges` 写 pending 前查同对 `(person_a_id, person_b_id, proposed_rule, guard_type)` 是否有近期 rejected 记录 → 跳过
- 选项 2：UI 列表显示"曾被 reject"提示（需 BE join 历史决策）
- 选项 3：建 `merge_review_blocklist` 表，PE 端 dry-run 时主动过滤

**推荐**：登记衍生债 T-P2-XXX（V2 启动前评估），V1 不处理。

### §3.5 approve seed_mapping 下次 dry-run 自然生效（确认）

**场景**：historian 在 V1 把某条 r1_exact_multi 的两条候选之一 approve 为 active。

**预期**：下次 PE 跑 dry_run_resolve.py 时，`_r6_prepass()` 读到这条新 active mapping，候选池多一个 QID 入口，可能产出新 R6 proposal（同 QID 多 person）。

**这是正确行为**，非 bug。V1 不需要"立即重跑"，PE 在下章 ingest 后自然跑 dry-run 时拾取。

---

## §4 V1 PE 端工时估计

### §4.1 V1 PE 端预期工作量

**核心结论**：**V1 PE 端集成工时 ≈ 0**。

理由：
- V1 mutation 仅写 `triage_decisions` + `seed_mappings.mapping_status` / `pending_merge_reviews.status`，全在 BE 范围
- pipeline 现有路径（R6 prepass / resolver / apply_merges）已正确处理状态过滤，**无需任何代码改动**
- V1 不实施 V2 hook，PE 不写新 job

### §4.2 PE Stage 4 任务（仅"集成测试 + 文档"）

per brief §3 Stage 4：

| 任务 | 工时估计 | 说明 |
|------|----------|------|
| 4.1 评估决策 status 变更下游影响 | 0.5h | 已在本 inventory §3 完成，Stage 4 仅复审 |
| 4.2 单元测试：决策 status 变更后 resolver / R6 prepass 行为不变 | 1-2h | 写 1-2 个 pytest：Setup pending_review 行 → mark active → 跑 _r6_prepass()，断言 active 行被消费、rejected 行不被消费 |
| 4.3 V1 → V2 演进清单文档 | 0.5h | docs/sprint-logs/sprint-k/v2-evolution-checklist.md，登记 §2.4 推荐 + §3.4 隐患 + §1.2 dry-run apply 旁路问题 |

**Stage 4 总工时**：**约 2-3 小时**（半天内完成，符合 brief Day 5 节奏）

### §4.3 Stage 0 / Stage 1 PE 协同工时（本会话）

- 本会话 inventory 文档：**约 1.5h**（已完成）
- Stage 1 review BE 设计 + 提 PE 视角反馈：**约 0.5h**（架构师设计后 review）

**Sprint K 期内 PE 总投入**：约 4-5 小时（Stage 0 + Stage 1 review + Stage 4 集成）

---

## §5 跨角色依赖（向 BE 提的 mutation 副作用约束）

### §5.1 BE Mutation 必须满足的契约

`Mutation.recordTriageDecision(...)` 实施时请遵守：

1. **保持事务原子性**：UPDATE `seed_mappings.mapping_status` / `pending_merge_reviews.status` + INSERT `triage_decisions` **必须同事务**。任一失败回滚全部，避免 status 变了但 audit 没记。

2. **写库前先校验 item 当前状态**：
   - seed_mapping：approve 仅当前 status='pending_review' 才允许（不能 approve 已经 active 的）
   - pending_merge_reviews：approve / reject / defer 仅当前 status='pending' 才允许
   - 否则 BE 返回 error code `INVALID_TRANSITION`

3. **不要绕过 ADR-014 merge 铁律**：V1 approve pending_merge_reviews **只 mark status，不调 apply_merges()**。即便未来 V2 也不允许 BE service 层直接 SQL UPDATE persons.deleted_at（必须经 PE apply_merges + 4 闸门）。**请在 ADR-027 §X 明文写入此条款**。

4. **不要写 entity_split_log**：该表是 audit-only，仅 PE 在 ADR-026 协议下写入。V1 triage UI 不消费、不写 entity_split_log。

5. **partial unique index 兼容**：UPDATE `pending_merge_reviews.status` 从 pending → accepted/rejected/deferred 后，partial index 自动失效该行。如果同一对又被未来 dry-run 写新 pending 行，新行能成功 INSERT（不冲突）。BE 不必干预。

6. **defer 的语义建议**：建议 `seed_mappings` 的 defer 不改 mapping_status（保持 pending_review），仅 INSERT 一条 `triage_decisions(decision='defer')` 行。这样下次 hist 进 UI 看到"上次已 defer"的标记。pipeline 端不读 triage_decisions，不影响。

### §5.2 BE/FE/Hist 跨角色协同输入需求

**向 BE 提的需求**：
- ADR-027 草案中 §"merge 铁律继承"明文条款（per §5.1.3）
- triage_decisions 表 `downstream_applied` 字段保留（per §2.4 V1 → V2 升级 schema）
- mutation 输入校验 INVALID_TRANSITION 错误码契约（per §5.1.2）

**向 FE 提的需求**：
- pending_merge_reviews 详情页面：除显示 guard_payload + evidence 外，建议补"重复出现次数"（如 same pair 被 reject 又 dry-run 写 pending → 显示历史决策提示，per §3.4）。V1 可不做，登记 V2 UX 衍生债。
- seed_mappings 详情页面：显示 surface / target_slug / target_name (zh-Hans) / dynasty / mapping_method / confidence 至少这 6 字段（参考 §1.1 8 条样本格式）
- 多命中视图：同 dictionary_entry_id 的 N 条 pending_review 应**分组展示**（hist 一次决策 N 选 1，常见交互形态）

**向 Hist 提的需求**：
- E2E 验证场景应至少覆盖：
  - approve r2_alias_multi 多命中场景（24 条 → 选最相关 QID active，其余 rejected）
  - reject 误关联场景（如 §1.1 #8 "徐浩→慎靓王" 噪音）
  - 启→Q186544 conf=0.85 特殊降级 case（§1.1 #5）：是否 reject（确定 wei-zi-qi 对应 Q855012 而非 Q186544）
- pending_merge_reviews 暂无可 E2E 数据（DB 0 行）→ Stage 5 验证前需 Hist 与架构师协商：是否手工 INSERT 几条 fixture 测试，还是先跑一次 apply_resolve.py 完整路径产生真实 pending（推荐后者，但属架构师 + DevOps 决策）

**向架构师提的开放问题**：
1. 是否在 Stage 1 设计中要求"Sprint K 期间补跑一次 apply_resolve.py 完整路径以产出真实 pending_merge_reviews 行供 hist E2E"？（per §1.4 ⚠️）
2. ADR-027 §"merge 铁律继承"条款（per §5.1.3）请明文起草
3. §3.4 隐患（rejected merge 重写 pending）是否在 Sprint K scope 内解决，还是登记 T-P2-XXX 衍生债？

---

## 附录 A — 数据采样原始 SQL（可重放）

```sql
-- §1.1 seed_mappings pending sample
SELECT sm.id::text AS sm_id,
       de.primary_name AS surface,
       de.external_id AS qid,
       sm.target_entity_type AS tgt_type,
       p.slug AS target_slug,
       p.name AS target_name,
       p.dynasty AS target_dynasty,
       sm.confidence,
       sm.mapping_method,
       to_char(sm.mapping_created_at,'YYYY-MM-DD') AS created
FROM seed_mappings sm
JOIN dictionary_entries de ON de.id = sm.dictionary_entry_id
LEFT JOIN persons p ON p.id = sm.target_entity_id
WHERE sm.mapping_status='pending_review'
ORDER BY de.primary_name, sm.confidence DESC
LIMIT 14;

-- §1.1 mapping_method 分布
SELECT mapping_method, COUNT(*)
FROM seed_mappings
WHERE mapping_status='pending_review'
GROUP BY mapping_method ORDER BY COUNT(*) DESC;

-- §1.2 pending_merge_reviews 分布
SELECT status, guard_type, COUNT(*)
FROM pending_merge_reviews
GROUP BY status, guard_type ORDER BY status, guard_type;

-- §1.3 entity_split_log 复核
SELECT operation, COUNT(*)
FROM entity_split_log GROUP BY operation;
```

## 附录 B — 关键文件引用

- `services/pipeline/src/huadian_pipeline/resolve.py:867-883` — pending_merge_reviews INSERT 路径
- `services/pipeline/src/huadian_pipeline/resolve.py:340-420` — _detect_r6_merges + guard chain 集成
- `services/pipeline/src/huadian_pipeline/r6_temporal_guards.py:163-181` — GUARD_CHAINS 注册（cross_dynasty + state_prefix）
- `services/pipeline/src/huadian_pipeline/state_prefix_guard.py` — Sprint I state_prefix_guard 实现
- `services/pipeline/scripts/apply_resolve.py` — 完整 apply 路径入口（Sprint G→J 各 sprint 实际未走此脚本）
- `services/pipeline/migrations/0012_add_pending_merge_reviews.sql` — 表创建
- `services/pipeline/migrations/0013_add_entity_split_log.sql` — entity_split_log 表
- `docs/decisions/ADR-014` — merge 铁律
- `docs/decisions/ADR-021` — Dictionary Seed Strategy
- `docs/decisions/ADR-025` — R Rule Pair Guards
- `docs/decisions/ADR-026` — Entity Split Protocol

---

**End of PE Inventory.**
