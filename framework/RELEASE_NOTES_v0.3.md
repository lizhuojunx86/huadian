# framework v0.3.0 — Release Notes

> Release date: **2026-04-30**
> Sprints: **Sprint Q + R + S + T**（v0.3 cycle / Layer 1 第 5 刀 + maintenance + eval + release）
> Tag (待打): `v0.3.0`
> 上一 release: 4 模块各自 v0.2.0（Sprint P）

---

## 0. TL;DR

framework v0.3.0 是 **5 模块齐备**首次完整 release（vs v0.2.0 的 4 模块）。Sprint Q→R→S→T 4 个 sprint 累计：

- **新模块**：framework/audit_triage/ v0.1（Sprint Q）→ v0.3.0 同步 release
- **测试基础设施**：60 pytest tests for identity_resolver + invariant_scaffold（Sprint Q）+ T-V03-FW-005 Docker compose dogfood（Sprint T）
- **methodology 网状 cross-ref**：02 v0.1.1 (4 段元 pattern) + 01/03/04 v0.1.2 双向引用
- **release timing 决策**：ADR-030 锁定 v0.3 触发条件（6/6 全达成）
- **v0.3 patch**：5/6 v0.3 候选 land + 1 押后（T-V03-FW-005 fold 进 Sprint T 已 land）
- **0 Stop Rule 触发**：连续 4 sprint zero-trigger（P+Q+R+S）+ Sprint T 首批 dogfood 一次跑通

---

## 1. 5 模块版本一览（统一 v0.3.0）

| 模块 | 上次版本 | 本 release | 路径 | 实际改动 |
|------|---------|-----------|------|---------|
| `framework/sprint-templates/` | v0.2.0 | **v0.3.0** | sprint governance 模板 | brief-template v0.1.3 (3 类估时表 / Sprint R T-V03-FW-003) |
| `framework/role-templates/` | v0.2.0 (+v0.2.1 patch) | **v0.3.0** | 多角色协作模板 | chief-architect §工程小细节 (Sprint R T-V03-FW-004) |
| `framework/identity_resolver/` | v0.2.0 | **v0.3.0** | 身份解析框架 | README §2.5 公共 API 速查 (Sprint R T-V03-FW-001) + 33 pytest tests (Sprint Q) |
| `framework/invariant_scaffold/` | v0.2.0 | **v0.3.0** | 不变量校验框架 | 27 pytest tests (Sprint Q) / 内容无 ABI 变化 |
| `framework/audit_triage/` | v0.1.0 (Sprint Q first abstraction) | **v0.3.0** | 审计 / triage workflow 框架 | 跳跃式 bump 0.1.0 → 0.3.0 对齐统一版本号；内容自 v0.1 起无 ABI 变化 |

---

## 2. v0.3 cycle 累计 patch + feature（5 项 land + 1 押后→ fold land）

### 2.1 P3 v0.3 candidates（5 项 / Sprint R + S land）

| ID | Sprint | 类型 | 改动 |
|----|--------|------|------|
| T-V03-FW-001 | R | doc polish | identity_resolver/README §2.5 加 "公共 API 速查"段（38 export 7 类 + fork 决策树）|
| T-V03-FW-002 | R | methodology v0.2 | methodology/02 v0.1 → v0.1.1（+5 段元 pattern：Maintenance Sprint / P3 复发升级 P2 / 5 模块齐备阈值 / 跨 stack 抽象）|
| T-V03-FW-003 | R | template polish | brief-template v0.1.2 → v0.1.3（§2.1 加 Code/Docs/Closeout-Retro 3 类估时表）|
| T-V03-FW-004 | R | 流程规则 | role-templates/chief-architect §工程小细节（dataclass-grep / P3 复发升级 P2 / debt grep 实数）+ role-templates v0.2.0 → v0.2.1 |
| T-V03-FW-006 | R | pre-commit hook | scripts/check-audit-triage-sync.sh + .pre-commit-config.yaml 加 services↔framework/audit_triage sync warning hook |

### 2.2 P3 v0.3 candidate（1 项 / Sprint T fold land）

| ID | Sprint | 类型 | 改动 |
|----|--------|------|------|
| **T-V03-FW-005** | **T 批 1** | **feature** | scripts/dogfood-postgres-compose.yml + dogfood-bootstrap.sql (7 表) + dogfood-seed.sql (5 persons + 3 dict + 3 pending + 5 triage) + README-dogfood-postgres.md — 让 sandbox / CI 可跑 framework dogfood（vs v0.2 仅 user local）|

### 2.3 ADR / 决策（Sprint S）

| ADR | Sprint | 决策 |
|-----|--------|------|
| **ADR-030** | S | v0.3 release timing 决策：采用选项 B（调整触发条件 / 把"≥ 1 跨域 reference impl"改为"≥ 1 跨域已规划 + cross-domain-mapping.md v0.2"），调整后 6/6 触发条件全达成 → Sprint T = v0.3 release sprint |

### 2.4 methodology cross-ref polish（Sprint S）

3 doc v0.1.1 → v0.1.2，与 methodology/02 §10-§13 元 pattern 形成网状 cross-ref：

| methodology | 加段 |
|-------------|------|
| /01 v0.1.2 | §10 与 /02 元 pattern 关系（4 段 cross-ref + Sprint M-R 角色活跃度实证锚点）|
| /03 v0.1.2 | §9 与 /02 跨 stack 抽象 pattern 关系（4 段 cross-ref + Sprint N vs Q 对比）|
| /04 v0.1.2 | §8 与 /02 跨 stack 抽象 pattern 关系（5 段 cross-ref + 3 种 dogfood 组合 + self-test 强化模式）|

---

## 3. Breaking changes

**无。**

3 模块 `__version__` bump（0.2.0/0.1.0 → 0.3.0）是版本号同步 / 内容向后兼容：
- identity_resolver: 仅 README §2.5 文档新增 / 公共 API `__all__` 不变
- invariant_scaffold: 内容无变化（仅版本号）
- audit_triage: v0.1 → v0.3 跳跃式 bump 同 Sprint P role-templates v0.1 → v0.2 同模式 / API 完全保持

`scripts/dogfood-*` 是新增基础设施，不影响现有 framework 用户。

---

## 4. 升级指南（v0.2 → v0.3）

仅依赖 framework 的下游项目：

```bash
git pull          # 拉最新 framework/
# 无需任何代码改动 — 全部 P3 patch 都向后兼容；3 模块 __version__ bump 仅元数据
```

可选优化：

- **使用 brief-template v0.1.3 §2.1 新 3 类估时表**（per Sprint S+T 两次 dogfood 验证 < 10% 偏差 / 显著 vs v0.1.2 单一时长 1.4-1.5x 偏差）
- **使用 scripts/dogfood-postgres-compose.yml**（如果你想在 sandbox/CI 跑 framework dogfood）
- **use chief-architect §工程小细节 v0.2.1 sprint retro 沉淀规则**（dataclass-grep / P3 复发升级 P2 / debt 文档 grep 实数）
- **激活 services↔framework/audit_triage sync hook**（如果你 fork audit_triage 到自己的领域）

---

## 5. v0.2 → v0.3 演进数据点

| 维度 | v0.2.0 (Sprint P 后) | v0.3.0 (Sprint T 后) | Δ |
|------|--------------------|--------------------|---|
| 模块数 | 4 | **5** ⭐ | +1 (audit_triage) |
| pytest tests | 0 | **60** ⭐ | +60 |
| pre-commit hooks | 8 | **9** | +1 (跨 stack sync warning) |
| Docker dogfood infra | 无 | **有**（compose + bootstrap + seed + README）⭐ | +1 |
| methodology v0.1.x ≥ v0.1.1 | 4 | **5** | +1 (/05 Sprint Q) |
| methodology v0.1.x ≥ v0.1.2 | 0 | **3** ⭐ | +3 (/01 /03 /04 Sprint S) |
| ADR | 29 | **30** | +1 (ADR-030) |
| 累计 v0.x patch land | 14/20 = 70% | **23/26 = 88.5%** | +18.5pp |
| 连续 zero-trigger sprint | 1 (Sprint P) | **5** ⭐ (P+Q+R+S+T-batch1) | +4 |

---

## 6. 5 模块 dogfood 状态（截止本 release）

| Sprint | 模块 | dogfood 形式 | 结果 |
|--------|------|------------|------|
| L | sprint-templates | self-use（brief 自用 + 8 次外部使用累计）| ✅ |
| M | role-templates | self-use（brief / closeout / retro 用本模板）| ✅ |
| N | identity_resolver | byte-identical vs 生产 (729 person 数据) | ✅ |
| O | invariant_scaffold | soft-equivalent + self-test 注入 (11 invariants / 4 modules) | ✅ |
| Q | audit_triage | soft-equivalent vs 生产 (64 pending + 7 historical decisions) | ✅ user local PASSED |
| **T (本 release 内)** | **audit_triage** | **soft-equivalent vs Docker compose seed**（list_pending 6/6 + 4 surfaces 全一致）| ✅ **sandbox PASSED** ⭐ |

→ v0.3 release 是 framework 第一次 **5 模块全实证** + **dogfood 既支持生产又支持 Docker**（per T-V03-FW-005）。

---

## 7. 押后到 v0.4+ 的候选（3 项）

| ID | 描述 | 触发条件 |
|----|------|---------|
| DGF-N-04（合并 DGF-O-03）| examples/legal/ + examples/medical/ 跨域 reference impl | 跨域案例方主动接触 |
| DGF-N-05 | EntityLoader.load_subset feature | 用户/案例方提需求 |
| T-V04-FW-001 | chief-architect §工程小细节 v0.2.2 加 commit message hygiene 规则（来源 Sprint R commit 35f371d 残留问题）| Sprint U+ patch sprint 时 fold |

---

## 8. 公开发布 checklist

- [x] 5 模块 README §0 + §8 v0.3.0 行更新（Sprint T 批 2）
- [x] 3 模块 `__version__` bump 0.2.0/0.1.0 → 0.3.0（identity_resolver / invariant_scaffold / audit_triage）
- [x] 顶层 `framework/RELEASE_NOTES_v0.3.md`（本文件 / Sprint T 批 3）
- [ ] STATUS / CHANGELOG 更新（Sprint T 批 4 同步）
- [ ] git tag v0.3.0（用户在 local Terminal 执行）
- [ ] ADR-030 §5 Validation Criteria 6 条 checklist 回填（Sprint T 批 5）

```bash
# 用户在 local terminal 准备执行：
cd /Users/lizhuojun/Desktop/APP/huadian
git add framework/ docs/ scripts/
git commit -m "feat(framework): v0.3.0 release — 5 模块齐备 + Docker dogfood + methodology 网状 cross-ref (Sprint Q→T cycle)"
git tag -a v0.3.0 -m "framework v0.3.0 — Sprint Q→T cycle (5 模块齐备 + audit_triage v0.1→v0.3 + 60 pytest + Docker dogfood + methodology 网状 cross-ref + ADR-030)"
git push origin main --tags
```

---

## 9. 致谢 + 节奏

本 release 来自 Sprint Q→R→S→T 4 个 sprint 的累积（vs v0.2.0 仅 Sprint L→P 5 个 sprint）。**v0.3 cycle 节奏更快**：

| Cycle | 涉及 sprint | 时间跨度 |
|-------|----------|---------|
| v0.2.0 | L → M → N → O → P (5 sprint / 4 模块抽象 + 1 patch + release) | 2026-04-29 → 2026-04-30 |
| v0.3.0 | Q → R → S → T (4 sprint / 1 新模块 + maintenance + eval + release) | 2026-04-30 (单日) |

→ framework v0.3 是 v0.2.0 之后的"成熟度上升"release（量化指标见 §5）。下一 release 节奏取决于跨域案例方接触（DGF-N-04 触发 v0.4 release）+ 累计 v0.4 候选成熟度（当前仅 1 项 / T-V04-FW-001）。

跨域案例方接触可关注：legal 优先（per Sprint Q debt §1.1 推荐）。

---

**framework v0.3.0 — 2026-04-30 / Sprint T**
