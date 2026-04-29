# RB-002 — Demo Walkthrough（5 分钟）

> Status: v1.0
> Date: 2026-04-29
> Audience: 想快速验证 AKE 框架"真的 work"的工程师 / 学者 / 评估者
> Prerequisite: 已完成 [RB-001 Local Dev Setup](RB-001-local-dev.md)（pnpm install / docker compose up / pnpm dev）

---

## 0. 这个 walkthrough 想证明什么

5 分钟内向访客展示：

1. **AKE 框架真的产出了一个可工作的知识库**（不是 PPT）
2. **多 agent 协作的 audit trail 可见**（Triage UI / 历史决策 / Hint Banner）
3. **identity resolver R1-R6 + GUARD_CHAINS 拦截真实 FP**（不是合成数据）
4. **V1-V11 invariants 全绿**（数据正确性形式化保证）

---

## 1. 启动服务（30 秒）

```bash
# Terminal 1: 数据库 + Redis
docker compose up -d

# Terminal 2: API
cd services/api && pnpm dev
# → http://localhost:4000/graphql

# Terminal 3: Web
cd apps/web && pnpm dev
# → http://localhost:3000
```

服务全起后，浏览器打开 `http://localhost:3000/triage?historian=chief-historian`

---

## 2. Demo 路径 A — Triage UI（人机协作 audit）

### 2.1 列表页（30 秒）

URL: `http://localhost:3000/triage?historian=chief-historian`

**看到**：
- 队列列表共 63 条 PENDING（18 条 Guard Block + 45 条 Seed Mapping）
- 三个 tab：全部 / Seed Mappings / Guard Blocks
- 第 1 页 50 条 + 第 2 页 13 条
- 每条卡片显示 surface（古籍人名）+ type badge

**说明**：这些是 Sprint A-K 累积的真实 pending decisions，不是 mock 数据。

### 2.2 Detail 页 — 一条 GuardBlock（90 秒）

点列表中任一 Guard Block 卡片（推荐"周成王↔楚成王"或类似的 cross_dynasty 案例）。

**看到**：
- **Hint Banner**（蓝底）："同 surface 已有 N 条历史决策" + "高一致性"badge — 跨 sprint 决策回查证据
- **Item Detail**：surface / personA / personB / guardType（cross_dynasty）/ guardPayload（gap=286yr）/ Evidence
- **Decision Form**：
  - 3 radio：approve / reject / defer
  - 6 quick template：参考最近裁决 / in_chapter / other_classical / slug-dedup / commit hash 引用 / ADR 引用
  - reason_text textarea
  - Submit 按钮

**说明**：这是 R1-R6 + GUARD_CHAINS 自动拦截的"看似同名实为异人"案例。Domain Expert 在这里做最终裁决。

### 2.3 Detail 页 — 一条 SeedMapping（60 秒）

回列表，点任一 Seed Mapping 卡片（推荐"伯夷 → Q61314449"）。

**看到**：
- target person + biography
- mapping confidence + method
- dictionary entry：source = wikidata / license = CC0 / external_id
- provenanceTier badge（"未验证"）— 提示需要人工核对
- Hint Banner empty-state（如无历史决策）

**说明**：这是 Wikidata 字典自动 anchor 的候选，需要 Domain Expert 确认是否接受。

---

## 3. Demo 路径 B — V1-V11 Invariants（形式化质量保证）

```bash
cd services/pipeline
DATABASE_URL=postgresql://huadian:huadian_dev@127.0.0.1:5433/huadian \
  uv run pytest tests/test_invariants_*.py -q
```

**期望输出**：

```
22 passed in 0.62s
```

**说明**：22 个 invariant 测试覆盖 V1-V11 五大类（upper-bound / lower-bound / containment / orphan / cardinality）。每次 sprint 收口必跑全绿，违反 = 数据 schema 错误，立即 rollback。

---

## 4. Demo 路径 C — Identity Resolver Dry-Run（看 R1-R6 + GUARD_CHAINS 工作）

```bash
cd services/pipeline
uv run python scripts/dry_run_resolve.py | head -40
```

**期望看到**：

```
Run ID: <uuid>
Active persons: 729
Total candidates: ~16
Guard blocked: cross_dynasty=9 / state_prefix=7
...
```

**说明**：这是 identity resolver 在当前 729 active persons 上的实时检查。GUARD_CHAINS 显式拦截了 16 个本来会 auto-merge 的案例（跨朝代 9 个 + 跨诸侯国 7 个），全部推 pending_review 等 historian 决策。

---

## 5. Demo 路径 D — 数据基线（SQL 直查）

```bash
psql -U huadian -h 127.0.0.1 -p 5433 -d huadian << 'EOF'
SELECT 'Active persons' AS metric, count(*)::text AS value FROM persons WHERE deleted_at IS NULL UNION ALL
SELECT 'merge_log entries', count(*)::text FROM merge_log UNION ALL
SELECT 'pending_merge_reviews', count(*)::text FROM pending_merge_reviews UNION ALL
SELECT 'triage_decisions', count(*)::text FROM triage_decisions UNION ALL
SELECT 'seed_mappings (pending_review)', count(*)::text FROM seed_mappings WHERE mapping_status = 'pending_review' UNION ALL
SELECT 'entity_split_log', count(*)::text FROM entity_split_log;
EOF
```

**期望输出**：

```
Active persons              | 729
merge_log entries           | 111
pending_merge_reviews       | 18
triage_decisions            | 177
seed_mappings (pending_rev) | 45
entity_split_log            | 2
```

**说明**：这是 Sprint A-K 累积的真实数据基线。所有数字都可被 audit trail 反推（merge_log 每行对应一次 historian 决策 / triage_decisions 每行对应一次 audit）。

---

## 6. Demo 关闭

```bash
# Stop dev servers (Ctrl+C in each terminal)
# Stop docker
docker compose down
```

---

## 7. Demo 没展示什么（诚实声明）

- ❌ **C 端阅读器** — 不在 D-route 范围（参见 docs/strategy/D-route-positioning.md §7 Negative Space）
- ❌ **完整史记 130 篇** — 当前只 3-4 篇本纪深度结构化（D-route 不追求数据完整度）
- ❌ **公开访问的 demo URL** — 当前只有本地 dev 模式（D-route 不卷部署）
- ❌ **Mobile 端** — 不在 D-route 范围
- ❌ **古人聊天 / 古地图等创新应用** — 不在 D-route 范围

如果你想要的是上述任何方向，AKE 框架不是答案；请考虑 [shiji-kb](https://github.com/baojie/shiji-kb) 或字节识典古籍等近邻项目。

---

## 8. Demo 后的延伸阅读

- [README](../../README.md) — 项目入口
- [docs/strategy/D-route-positioning.md](../strategy/D-route-positioning.md) — 战略定位
- [docs/methodology/00-framework-overview.md](../methodology/00-framework-overview.md) — 框架概览
- [framework/sprint-templates/README.md](../../framework/sprint-templates/README.md) — Sprint 模板（你可以拿来用）

---

**Walkthrough 总耗时**：~5 分钟（不含安装 / 服务启动等待时间）

如有问题欢迎在 GitHub Issues 反馈。
