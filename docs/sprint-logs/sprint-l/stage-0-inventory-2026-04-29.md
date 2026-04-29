# Sprint L Stage 0.2 — Inventory: 领域无关 vs 案例层 边界扫描

> Date: 2026-04-29
> Owner: 首席架构师
> Anchor: Sprint L Brief §3 Stage 0.2
> Purpose: 为 Track 1 框架抽象 spike 提供输入（识别哪些代码可被抽象为领域无关 framework 层）

---

## 0. 扫描方法

按"D-route 双轴架构"（参见 `华典智谱_架构设计文档_v2.0.md` §2）分类项目所有 source / config / data 资产：

- 🟢 **领域无关 (Framework Layer)** — 可直接抽象到 framework/ 目录，零修改可被佛经 / 法律 / 医疗等其他 KE 项目复用
- 🟡 **算法领域无关 + 数据领域专属 (Boundary)** — 算法/接口领域无关，但需 inject domain-specific 配置
- 🔴 **案例层 (Case Layer / Domain-specific)** — 与史记 / 古籍 强绑定，跨领域使用需重写
- ⚫ **共享基础设施 (Shared Substrate)** — 不需要抽象，所有 KE 项目都可独立选择技术栈

每个文件 / 目录给出抽象优先级（P0 / P1 / P2 / P3 / N/A）。

---

## 1. services/pipeline/src/huadian_pipeline/ 扫描

### 1.1 文件 / 模块清单

| 文件/目录 | 分类 | 抽象优先级 | 备注 |
|----------|------|----------|------|
| `cli.py` | 🟡 Boundary | P2 | CLI 框架结构领域无关；具体 commands (`ingest --book 史记`) 领域专属 |
| `enums.py` | 🟡 Boundary | P2 | enum 定义模式领域无关；具体值（如 `licenseEnum` 含 'CC-BY' / 'public_domain' / etc）部分案例特定 |
| `extract.py` | 🟡 Boundary | P1 | LLM extract 流水线领域无关；NER prompt 模板古籍专属 |
| `ingest.py` | 🟡 Boundary | P1 | source ingestion 接口领域无关；ctext / shangshu 等 source 实现案例专属 |
| `load.py` | 🟡 Boundary | P0 | DB load 模式（idempotency / source_evidence FK / etc）领域无关；具体 schema 字段案例专属 |
| `resolve.py` | 🟢 Framework | **P0** ⭐ | identity resolver 主流程**接近完全领域无关**；只需把 GUARD_CHAINS 改为 inject |
| `resolve_rules.py` | 🟢 Framework | **P0** ⭐ | R1-R6 规则定义**完全领域无关**（参见 docs/methodology/03） |
| `resolve_types.py` | 🟢 Framework | **P0** ⭐ | Decision / GuardResult / etc 类型定义**完全领域无关** |
| `r6_seed_match.py` | 🟡 Boundary | P1 | R6 seed-match 算法领域无关；wikidata QID 锚定模式可推广（专利 / 法律 ID 锚定）|
| `r6_temporal_guards.py` | 🟡 Boundary | P1 | temporal guard 算法领域无关；dynasty-periods.yaml 案例专属 |
| `state_prefix_guard.py` | 🔴 Case Layer | P3 | 古籍春秋诸侯国专属；保留作案例参考 |
| `slug.py` | 🟢 Framework | P1 | slug 生成模式领域无关 |
| `seed_dump.py` | 🟡 Boundary | P2 | dump 流程领域无关；具体 schema 案例专属 |
| `qc/` | 🟢 Framework | **P0** | V1-V11 invariants **核心抽象目标**（参见 docs/methodology/04） |
| `prompts/` | 🔴 Case Layer | P3 | NER prompt v1-r5 / 等古籍 domain-specific |
| `seeds/` | 🔴 Case Layer | P3 | wikidata seed loader 模式可推广，但当前实现古籍专属 |
| `sources/` | 🔴 Case Layer | P3 | ctext.py / shangshu.py 等都是古籍 source adapter |
| `ai/` | 🟡 Boundary | P2 | LLM 调用 wrapper 领域无关；具体 prompt / system message 案例专属 |
| `generated/` | 🟢 Framework | N/A | codegen 产物，不直接抽象 |

### 1.2 抽象优先级总结（pipeline）

**P0 高优先（最成熟，Sprint L Track 1 重点）**：
- `resolve.py` + `resolve_rules.py` + `resolve_types.py` — identity resolver R1-R6 框架（已极成熟）
- `qc/` — V1-V11 invariants 体系
- `load.py` 的 DB load 模式（idempotency / audit FK / etc）

**P1 次优**：
- `extract.py` LLM extract 流水线
- `ingest.py` source ingestion 接口
- `r6_seed_match.py` 锚定模式
- `r6_temporal_guards.py` temporal guard 算法
- `slug.py` slug 生成

**P2 / P3**：
- 大部分 case layer 文件（保留作案例参考）

---

## 2. services/api/src/ 扫描

| 目录/文件 | 分类 | 抽象优先级 | 备注 |
|----------|------|----------|------|
| `index.ts` | 🟡 Boundary | P2 | server bootstrap 领域无关；具体 routes 案例专属 |
| `context.ts` | 🟡 Boundary | P2 | request context 模式领域无关 |
| `db-reset.ts` | 🟡 Boundary | P2 | reset 流程模式领域无关 |
| `errors.ts` | 🟢 Framework | P1 | error type 抽象领域无关 |
| `resolvers/` | 🔴 Case Layer | P3 | person / triage 等 resolver 案例专属（schema 也案例专属）|
| `schema/` | 🟡 Boundary | P1 | GraphQL SDL 文件结构领域无关；triage.graphql 部分**领域无关**（pending_review pattern）|
| `services/` | 🟡 Boundary | P1 | service layer 模式领域无关；具体业务逻辑案例专属 |
| `utils/` | 🟢 Framework | P2 | 通用 utils 领域无关 |

**P0 候选**（API 侧）：无单独 P0；最有价值的是 `schema/triage.graphql` 中的 **TriageItem interface + RecordTriageDecision mutation pattern**（参见 docs/methodology/05-audit-trail-pattern.md）

---

## 3. apps/web/ 扫描

| 路径 | 分类 | 抽象优先级 | 备注 |
|------|------|----------|------|
| `app/triage/` | 🟢 Framework | **P1** | Triage UI 三段结构 + Inbox mode + 6 quick templates 领域无关；只需 i18n + domain-specific config 注入 |
| `app/persons/[slug]/` | 🔴 Case Layer | P3 | Person 详情页古籍专属 |
| `app/page.tsx` | 🔴 Case Layer | P3 | 首页古籍专属 |
| `lib/historian-allowlist.{yaml,ts}` | 🟡 Boundary | P2 | 模式领域无关（middleware-based URL token auth）；具体 id 列表案例专属 |
| `middleware.ts` | 🟢 Framework | P2 | 简化 auth middleware 完全领域无关 |
| `components/triage/` | 🟢 Framework | P1 | TriageCard / HintBanner / DecisionForm / etc **几乎完全领域无关**；6 template 文案需 i18n |

**P1 候选**（Web 侧）：
- `app/triage/` 整套页面 + `components/triage/` 组件库 — Triage UI 是 framework Layer 的强候选

---

## 4. packages/ 扫描

| 包 | 分类 | 抽象优先级 |
|----|------|----------|
| `analytics-events` | 🟢 Framework | P3 |
| `config-eslint` | ⚫ Substrate | N/A |
| `config-typescript` | ⚫ Substrate | N/A |
| `db-schema` | 🟡 Boundary | P1 — 含 framework + case 双部分 |
| `design-tokens` | 🟢 Framework | P3 |
| `qc-schemas` | 🟢 Framework | P2 |
| `shared-types` | 🟡 Boundary | P2 — 含 enums 案例专属（如 `licenseEnum` 部分）|
| `ui-core` | 🟢 Framework | P3 |

`db-schema` 内部需要进一步扫（P1 spike 时执行）：
- 通用 schema（`pending_review` / `triage_decisions` / `audit_log` / `entity_revisions`）→ Framework
- 古籍专属 schema（`persons.dynasty` / `dynasty-periods` 等领域字段）→ Case

---

## 5. data/ 扫描（全部案例层）

| 文件 | 分类 | 优先级 | 备注 |
|------|------|------|------|
| `dynasty-periods.yaml` | 🔴 Case | P3 | 中国古代朝代年表 |
| `states.yaml` | 🔴 Case | P3 | 春秋诸侯国 |
| `tier-s-slugs.yaml` | 🔴 Case | P3 | 古籍 tier-s slug |
| `dictionaries/miaohao.yaml` | 🔴 Case | P3 | 庙号字典 |
| `dictionaries/tongjia.yaml` | 🔴 Case | P3 | 通假字字典 |
| `golden/` | 🔴 Case | P3 | 黄金集（古籍 NER 标注）|

→ 所有 data/ 文件都是案例层。框架层不需要复制这些；案例方需要替换为自己领域的等价表。

---

## 6. docs/ 扫描

| 路径 | 分类 |
|------|------|
| `methodology/` | 🟢 Framework | (Stage C 已起草 7 份草案 v0.1)
| `decisions/` (ADRs) | 🟡 Boundary | 模板领域无关；具体决策内容案例专属 |
| `sprint-logs/sprint-{a..k}/` | 🔴 Case | 案例素材库 |
| `tasks/` | 🟡 Boundary | 任务卡格式领域无关 |
| `retros/` | 🔴 Case |
| `00_项目宪法.md` | 🟡 Boundary | C-1~C-21 大部分领域无关；C-22~C-25 D-route 专属 |
| `03/04/05` 操作文档 | 🟡 Boundary | (Stage C 已加 framework 视角)|

---

## 7. Sprint L Track 1 抽象 Spike 选定

按 ADR-028 §Appendix B 优先级 + 本 inventory 综合：

### 7.1 Track 1 第一刀建议

依据 Sprint L Brief §2.1 + 本 inventory，**Sprint workflow 抽象**仍然是最佳第一刀：

- **抽象成熟度**：⭐⭐⭐⭐⭐（Sprint A-K 11 个 sprint 实证）
- **抽象工作量**：中等（主要是 docs/methodology/02 内容 + 模板文件）
- **dogfood 容易**：用同一套模板审 Sprint K brief 即可验证
- **跨领域可推广性**：极高（任何 KE 项目都用 sprint）

### 7.2 抽象产物计划

```
framework/sprint-templates/
├── README.md                    # 如何用本套模板（含跨领域指南）
├── brief-template.md            # Sprint Brief 领域无关模板
├── stage-templates/
│   ├── stage-0-prep-template.md
│   ├── stage-1-smoke-template.md
│   ├── stage-2-full-template.md
│   ├── stage-3-review-template.md
│   ├── stage-4-apply-template.md
│   └── stage-5-closeout-template.md
├── retro-template.md
├── stop-rules-catalog.md        # 5 类 Stop Rule 模板
└── gate-checklist-template.md
```

### 7.3 Track 2 demo 产物计划（待用户 ACK 形态后）

依据 Sprint L Brief §2.2，待用户 ACK A/B/C 后落实。我推荐 B（本地 demo + README "Quick demo" 段）。

---

## 8. 暴露的"案例耦合点"（C-23 标注）

下面这些当前实现含 domain-specific 参数，抽象到 framework 时需显式标注：

| 模块 | domain-specific 参数 | 抽象建议 |
|------|------------------|---------|
| `resolve.py` GUARD_CHAINS | guard chain 配置（cross_dynasty / state_prefix）| 改为 yaml/json inject |
| `r6_temporal_guards.py` | dynasty-periods.yaml 路径 | 改为构造函数 inject |
| `triage UI` 6 quick templates | 文案（"in_chapter" / "other_classical" / etc）| 改为 i18n + config |
| `historian-allowlist.yaml` | 具体 historian id 列表 | 改为案例方注入 |
| `apps/web/app/persons/[slug]` | 古籍 Person 详情页结构 | 不抽象，案例层独立 |
| NER prompts | 18 类古籍实体 NER 范畴 | 不抽象（domain inherently specific）|
| `tier-s-slugs.yaml` | 古籍人名 slug | 不抽象 |

---

## 9. 下一步（Sprint L Stage 1）

待 Stage 0.3 用户 ACK demo 形态后，并行启动：

- **Track 1**：依据本 inventory §7 起 `framework/sprint-templates/` 目录骨架
- **Track 2**：依据用户 ACK 选项（A/B/C）落实 demo

Stage 1 工作量预估：**1 周（5 工作日）**。

### 9.1 Stage 1 优先级排序

1. `framework/README.md` — 总入口（30 min）
2. `brief-template.md` — 从 Sprint K Stage 0 brief 提取领域无关版（1 hr）
3. 5 个 stage 模板（2 hr / 5 模板）
4. `retro-template.md` + `stop-rules-catalog.md` + `gate-checklist-template.md`（2 hr）
5. dogfood：用模板回审 Sprint K brief（1 hr）

总 ~6.5 小时纯写作 + 1 hr review = 1 工作日。剩余时间做 Track 2 demo。

---

## 10. 决策签字

- 首席架构师：__ACK 2026-04-29__
- 信号：Stage 0.2 inventory 完成 → 等用户 ACK Stage 0.3 demo 形态 → Sprint L Stage 1 启动

---

**本 inventory 起草于 2026-04-29 / Sprint L Stage 0.2**
