# Sprint K Stage 1 Design — T-P0-028 Pending Triage UI

> 本文档是 Sprint K 实施 playbook（"怎么做"），与 ADR-027（"是什么/为什么"）配套使用。

- **架构师**: Chief Architect
- **日期**: 2026-04-29
- **状态**: 已落盘，待各角色签字（BE/FE/PE/Hist 各 ACK）
- **Brief 关联**: docs/sprint-logs/sprint-k/stage-0-brief-2026-04-28.md
- **ADR 关联**: docs/decisions/ADR-027-pending-triage-ui-workflow-protocol.md

---

## 1. 4 Inventory 汇总（cross-reference）

| 角色 | inventory commit | 关键交付 |
|------|-----------------|---------|
| BE | 60c199e | union vs interface 推荐 / Drizzle 字段表 / 工时 3.5d |
| FE | a7b2aaf | 路由方案 A / 5 shadcn 已用组件 / 工时 3.7d |
| PE | 5917416 | **pending_merge_reviews=0 真实数据警告** / V2 hook 推荐 / 数据采样 |
| Hist | f29c08f | 8 痛点 / inbox 模式 V1 必须 / hint banner / 8 E2E sample |

架构师裁决（详上一回合 architect 输出）：
- inbox V1 必须 ✅
- interface 推荐（FE 路径）✅
- URL token + cookie ✅
- deferred 在 triage_decisions 跟踪，不改源表 ✅
- 历史 markdown backfill V1 必须 ✅
- pending_merge_reviews 补跑（PE Stage 2 加项）✅

---

## 2. 数据模型（详 ADR-027 §3 + §4）

migration 0014 新表 `triage_decisions`：13 字段 + 4 索引 + 3 CHECK，schema 完整定义见 ADR-027 §3。

GraphQL interface + 3 implements + 4 queries + 1 mutation，完整 SDL 见 ADR-027 §4。

**实施约束**（BE Stage 2 必读）：
- migration 0014 SQL 文件名 `0014_add_triage_decisions.sql`
- Drizzle schema sync to `packages/db-schema/src/schema/triageDecisions.ts`
- GraphQL SDL 拆分为 `services/api/src/schema/triage.graphql`（避免污染既有 schema 文件）
- codegen 前端 client-preset 输出到 `apps/web/lib/graphql/generated/`（已有路径，per `apps/web/codegen.ts`；2026-04-29 BE Stage 2 纠正 design doc §2 typo `apps/web/src/gql/` → 实际真实路径）
- service 层文件 `services/api/src/services/triage.service.ts`

---

## 3. UI Detailed Wireframes（文字描述）

### 3.1 列表页 `/triage`

```
┌──────────────────────────────────────────────────────────────────────┐
│  Header: 华典智谱 · Triage Queue · historian: <name from cookie>     │
├──────────────────────────────────────────────────────────────────────┤
│  [Tabs: All | Seed Mappings | Guard Blocks]   [Filter: surface...]  │
├──────────────────────────────────────────────────────────────────────┤
│  Surface Cluster: "周成王/楚成王/成"  (3 items)              [↓]    │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │ #1 SeedMappingTriage  surface=周成王  pendingSince=2026-04-21 │  │
│  │ → Q39596 周成王 (西周)  conf=0.92                              │  │
│  │ Hint: 跨 sprint 已 reject 3 次 (G2/J1/...)                    │  │
│  │ [Triage →]                                                     │  │
│  └────────────────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │ #2 GuardBlockedMergeTriage  surface=成王                       │  │
│  │ A: 周成王 (西周)  ↔  B: 楚成王 (春秋)  guard=cross_dynasty    │  │
│  │ Hint: 同 surface 簇 cross-sprint reject 3 次                  │  │
│  │ [Triage →]                                                     │  │
│  └────────────────────────────────────────────────────────────────┘  │
│  ...                                                                  │
├──────────────────────────────────────────────────────────────────────┤
│  Surface Cluster: "桓公/鲁桓公/秦桓公"  (5 items)            [↓]    │
│  ...                                                                  │
└──────────────────────────────────────────────────────────────────────┘
```

**实施要点**：
- 同 surface 簇 collapse/expand（默认 expand 第一个簇，其余 collapse）
- Hint badge 用 shadcn Badge 组件
- 簇内按 pendingSince ASC 排序
- 簇间按"最早 pendingSince" ASC 排序

### 3.2 详情页 `/triage/[itemId]`

```
┌──────────────────────────────────────────────────────────────────────┐
│  Header: ← Back to queue      historian: <name>                      │
├──────────────────────────────────────────────────────────────────────┤
│  Hint Banner (跨 sprint 历史裁决):                                    │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │ 同 surface "周成王" 历史决策 (3 次):                            │  │
│  │ • Sprint G G2 REJECT  (commit 3280a35)  reason: 跨代 290yr     │  │
│  │ • Sprint J G1 REJECT  (commit 07db893)  reason: 同 G G2        │  │
│  │ • Sprint H ... REJECT (commit ...)      reason: ...            │  │
│  │ → 一致性 badge: 3/3 REJECT (高一致性)                           │  │
│  └────────────────────────────────────────────────────────────────┘  │
├──────────────────────────────────────────────────────────────────────┤
│  Item Detail (SeedMappingTriage):                                    │
│  • Surface: 周成王                                                    │
│  • Target: Person 周成王 slug=zhou-cheng-wang dynasty=西周           │
│  • Mapping Method: r2_alias_multi  Confidence: 0.92                  │
│  • Dictionary Entry: Q39596 (Wikidata 周成王 西周第二代天子)         │
│  • Source Evidence: SE id=... text="..." (with surface highlighted) │
├──────────────────────────────────────────────────────────────────────┤
│  Decision Form:                                                       │
│  Decision: ( ) APPROVE  ( ) REJECT  ( ) DEFER                        │
│  Source Type: [dropdown: in_chapter | other_classical | wikidata |   │
│                scholarly | structural]                                │
│  Reason (markdown):                                                   │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │                                                                 │  │
│  │ [textarea]                                                      │  │
│  │                                                                 │  │
│  └────────────────────────────────────────────────────────────────┘  │
│  Quick Templates:                                                     │
│  [参考 Sprint G G2 同类 reject]  [in_chapter: 见 §X]                 │
│  [other_classical: 《X》]  [slug-dedup]                              │
│  [commit hash 引用: ...]  [ADR 引用: ADR-X]                         │
│                                                                       │
│  [Submit Decision] → mutation → redirect to next pending item       │
└──────────────────────────────────────────────────────────────────────┘
```

**实施要点**：
- raw_text surface 多点高亮：用 shadcn 默认样式 + Tailwind `bg-yellow-200` highlight 包裹
- Quick Templates 触发预填 reasonText（FE 端 client-side state）
- Submit → Server Action 调 mutation → `redirect(/triage/${nextPendingItemId})` 或回 `/triage` (queue empty)

### 3.3 6 快捷模板内容（Hist Stage 0 inventory §2 + 架构师 spec）

| 模板 | 触发预填 reasonText | reasonSourceType |
|------|---------------------|------------------|
| 参考最近裁决 | `参考 [Sprint X G_id] 同 surface 已 [decision] (commit [hash])` | `structural` |
| in_chapter | `见 [章节] §[段落 id] 原文: "[quote]"` | `in_chapter` |
| other_classical | `见《[书名]·[篇名]》` | `other_classical` |
| slug-dedup | `slug 重复 (pinyin + unicode 共存清理)` | `structural` |
| commit hash 引用 | `引用 commit [hash] 中的 [section/group]` | `structural` |
| ADR 引用 | `per ADR-[NNN] §[X.Y]` | `structural` |

FE 实现：模板按钮 onClick 触发 textarea + dropdown 联动 setValue。模板文字含 placeholder 占位符 `[X]`，hist 自行填充。

---

## 4. Auth 详细 spec

### 4.1 middleware (apps/web/middleware.ts)

```typescript
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import historianAllowlist from '@/lib/historian-allowlist.yaml'; // need yaml loader

export function middleware(request: NextRequest) {
    const url = request.nextUrl.clone();
    const tokenFromQuery = url.searchParams.get('historian');
    const tokenFromCookie = request.cookies.get('historian_id')?.value;

    let historianId = tokenFromCookie;

    if (tokenFromQuery && historianAllowlist.includes(tokenFromQuery)) {
        historianId = tokenFromQuery;
        // strip query and set cookie
        url.searchParams.delete('historian');
        const response = NextResponse.redirect(url);
        response.cookies.set('historian_id', tokenFromQuery, {
            httpOnly: true,
            sameSite: 'lax',
            maxAge: 30 * 24 * 60 * 60, // 30 days
            path: '/triage',
        });
        return response;
    }

    if (!historianId || !historianAllowlist.includes(historianId)) {
        return new NextResponse('Unauthorized: visit /triage?historian=<your-id>', {
            status: 401,
        });
    }

    return NextResponse.next();
}

export const config = {
    matcher: '/triage/:path*',
};
```

### 4.2 allowlist (apps/web/lib/historian-allowlist.yaml)

```yaml
# Historian sign-off allowlist for /triage UI access (V1).
# Each id corresponds to a historian agent role / human reviewer.
# V2 will replace with SSO; this file is retired.

historians:
  - id: chief-historian
    display_name: Chief Historian (default)
  - id: backfill-script
    display_name: Historical Backfill Script (system)
  # add more as needed (≤10)
```

### 4.3 GraphQL mutation 校验 historianId

BE service 层校验 `historianId` 在 allowlist 中：
```typescript
const allowlist = readHistorianAllowlist();
if (!allowlist.includes(input.historianId)) {
    return { error: { code: 'UNAUTHORIZED', message: '...' } };
}
```

FE Server Action 从 cookie 读 historianId 传给 mutation。

---

## 5. PE Stage 2 关键脚本 spec

### 5.1 pending_merge_reviews 补跑脚本

文件：`services/pipeline/scripts/backfill_pending_merge_reviews.py`

```python
"""
Sprint K Stage 2 prep: backfill pending_merge_reviews from Sprint G/H/I/J dry-run reports.

Why: apply_resolve.py was bypassed in content sprints, so guard-blocked candidates
weren't persisted to pending_merge_reviews. This script reads dry-run reports and
INSERTs the missing rows (with notes='retroactive-backfill, sprint-K-stage-2-prep').

Process:
1. Find dry-run-resolve-*.md in sprint-logs/T-P0-006-{gamma,delta,epsilon}/
2. Parse "Guard 拦截" section + extract (person_a, person_b, guard_type, ...)
3. Cross-ref with current persons table to find UUIDs
4. INSERT into pending_merge_reviews (status='pending', guard_type set, evidence captured)
5. Skip if already exists (UNIQUE index on person_a/b/rule/guard_type per migration 0012)
6. Output count of inserted rows + skipped (already exists)

Estimated rows: ~16 (per architect brief estimate).
Pre-flight: V1-V11 baseline. Post-flight: V1-V11 unchanged (new rows in pending_merge_reviews don't affect existing invariants).
"""
```

PE 实施关键约束：
- 单事务 per insert，避免某条失败拖垮整批
- pre-flight pg_dump anchor (ADR-017)
- 跑后 SELECT 验证 pending_merge_reviews 行数符合预期
- commit message: `feat(pipeline): backfill pending_merge_reviews from G/H/I/J dry-runs (sprint K prep)`

### 5.2 Historian markdown backfill 脚本

文件：`services/pipeline/scripts/backfill_triage_decisions.py`

```python
"""
Sprint K Stage 2 prep: backfill triage_decisions from Sprint G/H/I/J historian-review markdown files.

Why: hint banner feature requires historical decisions queryable per surface.
This script parses markdown rulings and INSERTs to triage_decisions table.

Process:
1. Find historian-review-*.md in sprint-logs/T-P0-006-{gamma,delta,epsilon}/ + sprint-logs/sprint-h/
2. Parse each ruling block (pattern: "G_X surface ... → DECISION ...")
3. Cross-ref with corresponding dry-run-resolve-*.md to get (group_id → row UUID)
4. INSERT triage_decisions:
   - source_table: 'pending_merge_reviews' (most rulings) or 'seed_mappings' (Sprint B context)
   - source_id: from dry-run group lookup
   - surface_snapshot: from markdown
   - decision: parsed (approve/reject/defer)
   - reason_text: markdown reason snippet
   - reason_source_type: parsed if available, else 'structural'
   - historian_id: 'historical-backfill'
   - historian_commit_ref: <markdown file's commit hash>
   - decided_at: <commit timestamp>
   - downstream_applied: false (V1 doesn't distinguish)
5. Output count per sprint + total
6. Verify: each surface has ≥1 triage_decision (hint banner ready)

Estimated rows: ~80-100.
"""
```

PE 实施关键约束：
- 跨 sprint group_id 命名空间不冲突（用 sprint label prefix 如 'G-G2' / 'J-G1'）
- markdown 解析鲁棒（容许格式微差，fail-loud 错条目）
- commit message: `feat(pipeline): backfill triage_decisions from historian-review markdown (sprint K prep)`

---

## 6. Stage 调度（6-8 天总长）

### Day 2（本回合）：架构师 Stage 1 ✅

- ✅ ADR-027 起草落盘
- ✅ Stage 1 design doc 落盘（本文档）
- ⏳ 各角色签字（BE/FE/PE/Hist 4 个 session ACK）

### Day 3-5：Stage 2 BE + Stage 3 FE 并行 + PE 补跑脚本

**【BE Stage 2】**（3.5 天）
- Day 3：migration 0014 + Drizzle schema + SDL 编写
- Day 4：service 层 + resolvers + personById query
- Day 5：unit tests + codegen 同步

**【FE Stage 3】**（3.7 天，并行）
- Day 3：路由 scaffold + middleware + auth
- Day 4：列表页 + Hint Banner + 6 快捷模板
- Day 5：详情页 + form + Server Action + E2E test

**【PE Stage 2 prep】**（1.5 天，可与 BE/FE 并行）
- Day 3：pending_merge_reviews 补跑脚本（0.5 天）
- Day 4-5：historian markdown backfill 脚本（1 天）

**关键路径**：BE 必须 Day 4 中完成 SDL → FE Day 4 才能跑 codegen。BE/FE 同步点必须打通。

### Day 6：Stage 4 PE 集成 smoke

- PE 跑 backfill 脚本进 DB（先 dry-run 验证，再 apply）
- PE + FE 联调 mutation/query 全链路
- pre/post V1-V11 验证

### Day 7：Stage 5 Hist E2E

- Hist 启动 UI（PE/FE 协助本地起服务）
- 按 8 sample 优先级 triage 5-10 条
- 反馈记录到 `historian-e2e-feedback-2026-04-XX.md`
- V1.1/V2 改进 backlog 登记

### Day 8：Stage 6 收档

- T-P0-028 task card 状态 done + 全 commit hash 回填
- STATUS / CHANGELOG / Sprint K retro
- ADR-027 architect sign-off + status accepted
- Phase 0 graduation 评估段（架构师本侧关注）

---

## 7. Stop Rules（详 brief §4 + 本设计新增）

| # | 触发条件 | 动作 |
|---|---------|------|
| 1 | BE migration 0014 schema 与 ADR-027 §3 不一致 | Stop，BE 重对照 ADR |
| 2 | FE codegen 失败（SDL 与 client mismatch） | Stop，BE/FE 联调 |
| 3 | PE 补跑脚本写入异常（V1-V11 回归 / 重复行 INSERT） | Stop，pg_restore 评估 |
| 4 | PE markdown backfill 脚本无法解析 ≥10% markdown ruling | Stop，markdown 格式化 |
| 5 | Hist E2E 反馈核心流程不可用（如 Submit mutation 报错） | Stop，FE/BE 修复后重 E2E |
| 6 | Auth middleware 配置错误导致 /triage 全员 403 | Stop，FE 修复 |
| 7 | 任一 V invariant 回归 | Stop |
| 8 | Day 5 收尾时 BE/FE 关键路径未对齐（codegen 跑不通） | Stop，架构师协调延期 |

---

## 8. 各角色 Stage 2/3 启动 prompt 数据准备（架构师下回合给）

下回合 prompt 各 session：

- **【BE Stage 2】**：实施 migration 0014 + GraphQL SDL + service layer + tests，参考 ADR-027 §3-§5 + 本 design doc §2/§5 spec
- **【FE Stage 3】**：实施 /triage 路由 + middleware + 列表/详情页 + 快捷模板 + Server Action，参考本 design doc §3/§4
- **【PE Stage 2 prep】**：实施补跑脚本（5.1）+ markdown backfill 脚本（5.2），ADR-026 §3 协议借鉴

3 session 可全并行（依赖图：BE SDL → FE codegen / PE 脚本 + BE 表创建后才跑）。

---

## 9. 工时关键路径分析

```
Day 2: Architect (本回合) ─────────┐
                                    │
Day 3: BE [migration + SDL]──────┐ │
       FE [routing + middleware] │ │
       PE [backfill 脚本 #1]      │ │
                                  │ │
Day 4: BE [service + resolvers]  │ │
       FE ⟵ [waiting on SDL] ─── ┘ │ ← 关键路径同步点
       FE [list page + hint]      │
       PE [backfill 脚本 #2]       │
                                   │
Day 5: BE [tests + codegen]       │
       FE [detail page + form]    │
       PE [脚本验证 + dry-run]     │
                                   │
Day 6: PE Stage 4 集成 ────────────┘
       PE 跑 backfill 进 DB
       BE/FE smoke

Day 7: Hist Stage 5 E2E

Day 8: 收档
```

**关键路径**：BE Day 4 SDL 完成 → FE Day 4 codegen 跑通。如延误 → 整 sprint 延 1 天。

---

## 10. 各角色签字 checklist（执行 Stage 2/3 前必填）

请各角色在 ACK 时回复：

**【BE】签字**（2026-04-29 BE Stage 2 启动前回填）：
- [x] ADR-027 §2.2 interface 设计接受
- [x] ADR-027 §3 triage_decisions schema 实施可行
- [x] ADR-027 §4 GraphQL SDL 编写计划清晰
- [x] 本 design doc §2 实施约束（SDL 路径、service 路径）接受（codegen 路径 typo 已纠正）
- [x] 工时 3.5d 估计准确

**【FE】签字**（2026-04-29 FE Stage 3 启动时回填，commit pending — 见 C1 / C6）：
- [x] ADR-027 §2.2 interface + __typename type guard 实施清晰
- [x] ADR-027 §2.3 inbox V1 必须实现接受
- [x] ADR-027 §2.4 Auth middleware 实施 spec 接受
- [x] 本 design doc §3 wireframes 落地清晰
- [x] 本 design doc §4 middleware 代码 spec 可直接用
- [x] 工时 3.7d 估计准确

**FE 实施期 2 处 deviation**（架构师 Stage 3 prompt 已 ACK）：

1. **路径以 FE 实际项目结构为准（非 `src/app/`）**：
   - 项目实际结构（Stage 0 FE inventory commit `a7b2aaf` §1 已确认）：路由用 `apps/web/app/triage/` 而非 `apps/web/src/app/triage/`；utils/middleware 在 `apps/web/lib/*.ts` + `apps/web/middleware.ts`。
   - 与现有 `/persons` 路由模式同构，零结构重组。§2 codegen 路径 typo 已由 BE Stage 2 纠正；§3 wireframes 是文字描述无具体路径，按实际结构落地。

2. **middleware 不直接 `import yaml`，改用 `.ts` mirror**：
   - 本 design doc §4.1 spec 写 `import historianAllowlist from '@/lib/historian-allowlist.yaml'`，但 Next.js 14 middleware 默认 edge runtime **不支持** YAML 直接 import（无 fs / 无 yaml loader without webpack rewrite）。
   - 实施路径：保留 `apps/web/lib/historian-allowlist.yaml` 作为人类可读 source of truth + V2 SSO 注释；新增 `apps/web/lib/historian-allowlist.ts` 作为 runtime mirror（middleware 实际 import 这个）。
   - `.ts` 文件头注释明示"⚠️ Mirrored from historian-allowlist.yaml; if updating, edit yaml first then sync .ts"。
   - V2 SSO 升级时两文件一并退役，middleware 直接接 SSO 校验。

**【PE】签字**：
- [ ] ADR-027 §5 merge 铁律继承条款接受
- [ ] 本 design doc §5.1 pending_merge_reviews 补跑 spec 实施可行
- [ ] 本 design doc §5.2 markdown backfill spec 实施可行
- [ ] 工时 1.5d（两脚本 +）估计准确

**【Hist】签字**：
- [ ] ADR-027 §1.2 + §2.6 痛点解决方案接受
- [ ] 本 design doc §3 wireframes 符合理想 UI 设计
- [ ] 本 design doc §3.3 6 快捷模板内容接受（如需调整请明示）
- [ ] Stage 5 E2E 8 sample 优先级接受

任一签字未通过 → 报架构师 micro-revise design 后重签。
