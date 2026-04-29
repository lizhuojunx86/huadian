# Sprint M Stage 0 — Inventory: Multi-Role Coordination 抽象的领域耦合扫描

> Date: 2026-04-29
> Owner: 首席架构师
> Anchor: Sprint M Brief §3 Stage 0
> Purpose: 为 Stage 1 起草 `framework/role-templates/` 提供输入（识别 10 份角色定义文件中"哪段领域无关 / 哪段需 ⚠️FILL 占位"）+ Sprint K Tagged Sessions 实战数据提取 + 抽象优先级排序 + cross-reference 计划

---

## 0. 扫描方法

沿用 Sprint L Stage 0 inventory 同款分类（参见 `docs/sprint-logs/sprint-l/stage-0-inventory-2026-04-29.md` §0）：

- 🟢 **完全领域无关** — 可直接抽象到 framework/role-templates/，零修改即可被任何 KE 项目复用
- 🟡 **结构领域无关 + 内容部分领域专属** — 段落框架领域无关，但具体字段需 ⚠️FILL 占位（路径名 / 技术栈 / 性能阈值 / domain dictionary 等）
- 🔴 **领域专属为主** — 内容大段是史记 / 古籍 / shadcn / etc 案例细节，跨领域使用需大段 ⚠️FILL 替换
- ⚪ **D-route 元描述段** — 2026-04-29 Stage C-11 加的"在 AKE 框架中的领域无关定义"段；本身是元描述，无需再抽象

每份角色文件给出"⚠️FILL 字段密度"（高 / 中 / 低）和"抽象优先级"（先抽 / 后抽）。

---

## 1. 10 份 .claude/agents/ 扫描总表

| # | 文件 | 行数 | 整体分类 | ⚠️FILL 密度 | 抽象优先级 |
|---|------|-----|---------|-----------|----------|
| 1 | `chief-architect.md` | 102 | 🟢 完全领域无关 | 低（仅路径名）| **先抽**（结构最干净）|
| 2 | `historian.md` | 152 | 🔴 领域专属为主 | **极高**（古籍内容大段）| **特别处理**（重命名为 domain-expert.md + 大段 ⚠️FILL）|
| 3 | `pipeline-engineer.md` | 235 | 🟡 结构领域无关 | 中高（NER / dictionary / etc）| 后抽（最长，需精读）|
| 4 | `backend-engineer.md` | 122 | 🟢 完全领域无关 | 低（技术栈名 / 路径）| 先抽 |
| 5 | `frontend-engineer.md` | 132 | 🟢 完全领域无关 | 中（古风设计要点）| 中抽 |
| 6 | `qa-engineer.md` | 130 | 🟢 完全领域无关 | 低（黄金集文件名）| 先抽 |
| 7 | `devops-engineer.md` | 143 | 🟢 完全领域无关 | 低（runbook / 技术栈）| 先抽 |
| 8 | `product-manager.md` | 99 | 🟢 完全领域无关 | 低（PRD 模板）| 先抽（最短最干净）|
| 9 | `ui-ux-designer.md` | 138 | 🟢 完全领域无关 | 中（古风样式指南）| 中抽 |
| 10 | `data-analyst.md` | 132 | 🟢 完全领域无关 | 低（埋点字典）| 先抽 |

**关键观察**：

- **9 / 10 角色完全领域无关**（所有除 historian），印证 docs/methodology/01 §2 "10 个角色中只有 1 个需要 instantiate"
- **historian 是唯一需要重命名 + 大段重写**的文件 → 在 framework/role-templates/ 中改名为 `domain-expert.md`
- 其余 9 份角色文件 ⚠️FILL 字段密度普遍低（< 10 处占位），说明 framework/role-templates/ 复制即用门槛极低

---

## 2. 各角色"领域耦合点"详细标注

### 2.1 chief-architect.md — 🟢 完全领域无关 / 先抽

**领域无关段（直接复制）**：

- §角色定位（"技术决策最终责任人"等）
- §核心职责（架构决策 / ADR / 风险识别 / 仲裁 / 修宪 / 技术选型 等 8 项）
- §决策权限 / §禁区 / §工作风格
- §度量自己

**⚠️FILL 占位（5 处）**：

- 工作启动 §1-§7 中的路径名（CLAUDE.md / docs/STATUS.md / etc）→ 跨领域案例方需要按自己仓库结构调整
- §交付物格式 中"`docs/04 §二`"等模板引用 → 案例方按自己 docs 编号调整
- §输出 中具体文件路径 (`docs/decisions/ADR-NNN-*.md` 等) → 跨领域 ADR 路径可能不同
- §度量自己 中"`docs/04 §十`清单"引用 → 同上

**D-route 元描述段（整段保留作 cross-domain 注脚 / 不抽出）**：

- §"D-route 框架抽象的元描述" 段不进 framework/role-templates/（这是华典智谱专属上下文）
- 但 framework/role-templates/README.md 应有"如何 instantiate D-route 元描述段（可选）"的指引

### 2.2 historian.md — 🔴 领域专属为主 / 改名 domain-expert.md + 大段 ⚠️FILL

**这是 10 份中最特殊的文件**。需要：

1. **重命名**：`historian.md` → `domain-expert.md`（参见 methodology/01 §8 Step 2）
2. **领域无关段（直接复制）**：
   - §角色定位结构（"内容质量的最终守护者"模式）
   - §核心职责的**模式**（实体歧义仲裁 / 术语库管理 / 黄金集标注 / 抽样审核 / "默认叙述"判定）
   - §决策权限（实体身份归属 / 术语库内容 / 默认叙述选择）
   - §禁区（不写代码 / 不决定 schema 字段名 / 不决定技术架构）
   - §工作风格（学术严谨 / 不臆断 / 多源比对 / 标准化命名）
3. **⚠️FILL 占位（高密度）**：
   - 角色名："古籍 / 历史学家 (Historian)" → ⚠️FILL（lawyer / physician / buddhologist / etc）
   - 项目名："华典智谱" → ⚠️FILL
   - 字典文件名（6 个 yaml 文件名）→ ⚠️FILL（每个领域不同）
   - 黄金集文件名 → ⚠️FILL
   - 字典格式 yaml example（"韩信"案例）→ ⚠️FILL（替换为领域案例）
   - 黄金集格式 json example（"项王军壁垓下"）→ ⚠️FILL
   - "古籍版本学"等术语 → ⚠️FILL（替换为领域术语）

**特别 Note**：domain-expert.md 模板应附"5 个跨领域 instantiation 范例"段（佛经 / 法律 / 医疗 / 专利 / 地方志），帮助案例方快速对照（参见 §6 cross-domain-mapping.md 计划）。

### 2.3 pipeline-engineer.md — 🟡 结构领域无关 / 后抽

**领域无关段（直接复制）**：

- §角色定位 / §核心职责（古籍摄入 / 预处理 / AI 抽取 / 实体消歧 / 地理编码 / 质量校验 / LLM Gateway / Prompt 版本化 / 任务编排 / 断点续跑 / 成本监控 — 全部模式）
- §决策权限 / §禁区
- §工作协议（**完整保留** — 数据形态契约级决策 / 4 闸门敏感操作协议 / mini-RFC 流程 — 这些是 KE 项目共通的工程协议，跨领域 100% 适用）
- §工作风格 / §标准任务流程 / §度量

**⚠️FILL 占位（中高密度，约 15 处）**：

- 路径名（services/pipeline/src/ingestion/ 等）→ ⚠️FILL
- "古籍" 字样（多处）→ ⚠️FILL
- "ctext / wikisource" 等具体 source → ⚠️FILL
- "prompts/ner_v3.py" → ⚠️FILL（每个领域 NER 范畴不同）
- "data/dictionaries/" → ⚠️FILL
- 具体 ADR 引用（ADR-014 / ADR-010 / ADR-004）→ ⚠️FILL（案例方用自己 ADR 编号）
- TraceGuard 路径 → ⚠️FILL
- "黄金集回归 F1" → ⚠️FILL（不是所有领域用 F1）

**特别 Note**：§工作协议（`数据形态契约级决策` / `4 闸门` / `mini-RFC`）是华典智谱 T-P0-006-β 复盘沉淀的精华——这些是**完全领域无关**的 KE 工程协议，应在 framework/role-templates/ 中显眼保留（不要因为长就裁剪）。

### 2.4 backend-engineer.md — 🟢 完全领域无关 / 先抽

**领域无关段（直接复制）**：

- §角色定位 / §核心职责（Schema / 迁移 / GraphQL / 服务层 / DAL / API 性能 / 类型同步 / 测试）
- §决策权限 / §禁区 / §工作风格 / §标准开发流程 / §编码规范

**⚠️FILL 占位（低密度，约 8 处）**：

- 技术栈："Drizzle" / "GraphQL" / "Yoga" → ⚠️FILL（案例方可换 Prisma / REST / etc）
- 路径名（services/api/src/db/schema.ts 等）→ ⚠️FILL
- 性能基线（"person query p95 < 300ms"）→ ⚠️FILL（每领域可调）
- "provenance_tier 字段必须返回（C-2 宪法）"→ ⚠️FILL（C-2 是华典专属宪法编号）

**特别 Note**：技术栈替换需要案例方对应改 §标准开发流程 中"drizzle-kit generate"等具体工具命令。

### 2.5 frontend-engineer.md — 🟢 完全领域无关 / 中抽

**领域无关段（直接复制）**：

- §角色定位 / §核心职责（路由 / 组件 / GraphQL 客户端 / 地图 / 关系图 / 时间线 / a11y / 埋点 / Sentry / i18n / 测试）
- §决策权限 / §禁区 / §工作风格 / §标准开发流程 / §性能基线 / §不要做的（反模式）

**⚠️FILL 占位（中密度，约 10 处）**：

- 技术栈："Next.js / React / Tailwind / shadcn / TanStack Query / MapLibre / D3 / G6" → ⚠️FILL
- 路径名（apps/web/app/...）→ ⚠️FILL
- §古风设计实现要点（思源宋体 / 行高 1.8 / 朝代色 / 古今对照 / 证据徽标）→ ⚠️FILL（这是华典美学，跨领域案例方可整段删除或替换）
- "soulful loading"古风加载文案（"史官查阅中..."）→ ⚠️FILL

**特别 Note**：§古风设计实现要点段是案例美学专属。在 framework/role-templates/frontend-engineer.md 中应留为 ⚠️FILL 整段，附注"案例方根据领域美学填写或删除"。

### 2.6 qa-engineer.md — 🟢 完全领域无关 / 先抽

**领域无关段（直接复制）**：

- §角色定位 / §核心职责（质检规则 / 黄金集 / 回归测试 / 契约测试 / E2E / Lighthouse CI / 反馈分诊 / 缺陷定位 / 季度质量报告）
- §决策权限 / §禁区 / §工作风格 / §反馈分诊流程 / §度量

**⚠️FILL 占位（低密度，约 6 处）**：

- 黄金集文件名（data/golden/ner_v1.jsonl 等 5 个）→ ⚠️FILL（案例方按自己抽取任务列表）
- 路径名 → ⚠️FILL
- "黄金集回归 F1" → ⚠️FILL（同 PE）

**特别 Note**：§反馈分诊流程"factual_error → 历史专家 / misleading → 历史专家 + PM"应改为通用 routing："factual_error → DomainExpert / etc"。

### 2.7 devops-engineer.md — 🟢 完全领域无关 / 先抽

**领域无关段（直接复制）**：

- §角色定位 / §核心职责（本地开发 / CI/CD / DB / 缓存 / 任务编排 / 可观测性 / 错误监控 / 产品分析 / TraceGuard 运行时 / 密钥管理 / 域名 / 日志归档）
- §决策权限 / §禁区 / §工作风格 / §标准开发流程 / §必备 runbook 清单 / §监控指标基线 / §备份策略 / §安全基线

**⚠️FILL 占位（低密度，约 8 处）**：

- 技术栈具体名（PostgreSQL 16 / Redis 7 / Prefect / OTel / Sentry / PostHog / Doppler / 1Password / Vault）→ ⚠️FILL
- "docker-compose.yml" 等具体文件 → ⚠️FILL
- TraceGuard 引用 → ⚠️FILL（这是华典专属技术栈）

### 2.8 product-manager.md — 🟢 完全领域无关 / 先抽

**领域无关段（直接复制）**：

- 全文几乎可以直接复制（PRD 撰写 / 功能取舍 / 用户场景 / 商业化 / A/B 实验目标 / 等）
- §决策权限 / §禁区 / §工作风格 / §PRD 模板要素

**⚠️FILL 占位（低密度，约 4 处）**：

- "U-01~U-07 等"未决项编号 → ⚠️FILL
- "docs/prd/_template.md"路径 → ⚠️FILL
- "docs/01_风险与决策清单_v2.md" → ⚠️FILL

**特别 Note**：本文件是 10 份中最干净的——结构完全领域无关。

### 2.9 ui-ux-designer.md — 🟢 完全领域无关 / 中抽

**领域无关段（直接复制）**：

- §角色定位 / §核心职责（视觉风格 / 组件规范 / 交互原型 / 空错加载 / 响应式 / a11y）
- §决策权限 / §禁区 / §工作风格 / §设计规范文档模板

**⚠️FILL 占位（中密度，约 10 处）**：

- §设计风格参考（故宫数字博物馆 / Smithsonian / JSTOR Daily 等参考）→ ⚠️FILL（案例方按领域调整）
- §古今对照 / §朝代色 / §证据徽标 5 tier 等具体实现 → ⚠️FILL
- "思源宋体 + 行高 1.8" → ⚠️FILL
- 路径（packages/design-tokens/）→ ⚠️FILL

### 2.10 data-analyst.md — 🟢 完全领域无关 / 先抽

**领域无关段（直接复制）**：

- §角色定位 / §核心职责（埋点 / PostHog / A/B / 内容热度 / 用户分群 / 反馈信号挖掘 / 商业化指标 / 季度报告）
- §决策权限 / §禁区 / §工作风格 / §埋点设计原则 / §标准 A/B 实验流程 / §仪表盘必备分类 / §典型分析问题清单 / §隐私与合规

**⚠️FILL 占位（低密度，约 5 处）**：

- 技术栈（PostHog / 等）→ ⚠️FILL
- 埋点字典路径（packages/shared-types/src/analytics.ts）→ ⚠️FILL
- §典型分析问题中"古籍引用最多但访问最少"等案例 → ⚠️FILL

---

## 3. 抽象优先级 + 起草顺序

依据 §1 总表 ⚠️FILL 密度 + 文件长度，建议 Stage 1 起草顺序：

### 3.1 第一批（先抽，结构最干净，约 30 分钟）

1. `product-manager.md` — 最短最干净，作为"模板成形"参照
2. `chief-architect.md` — 完全领域无关，但要保留 D-route 元描述段为 cross-reference
3. `data-analyst.md` — 全文几乎可直接复制
4. `qa-engineer.md` — invariant pattern 暴露的反馈分诊流程通用度高
5. `devops-engineer.md` — 基础设施 / SRE 模式跨领域 100% 适用

### 3.2 第二批（中抽，需 ⚠️FILL 较多设计相关字段，约 40 分钟）

6. `frontend-engineer.md` — 古风设计要点需整段处理
7. `ui-ux-designer.md` — 设计风格参考 / 古今对照 / 朝代色等需 ⚠️FILL
8. `backend-engineer.md` — 技术栈 ⚠️FILL（Drizzle / GraphQL / Yoga）

### 3.3 第三批（后抽，最长 + 最特殊，约 60-90 分钟）

9. `pipeline-engineer.md` — 235 行最长，§工作协议（数据形态契约级 / 4 闸门 / mini-RFC）需精读完整保留
10. `domain-expert.md`（重命名自 historian.md）— 大段 ⚠️FILL + 5 跨领域 instantiation 范例段

### 3.4 之后起草的伴随文件

- `tagged-sessions-protocol.md`（参见 §4 Sprint K 实战数据）
- `README.md`（参见 §5 README 计划）
- `cross-domain-mapping.md`（参见 §6 cross-domain 计划）
- `docs/methodology/01-role-design-pattern.md` cross-reference 段更新（参见 §7）

**预估总时长**：约 3-4 小时纯起草工作（与 Sprint L Stage 1 起草 11 个 sprint-templates 文件耗时接近）。

---

## 4. Sprint K Tagged Sessions 实战数据提取

### 4.1 角色与 Stage 数据

来自 `docs/sprint-logs/sprint-k/stage-6-closeout-2026-04-29.md` §1.1 + §2.1：

| 维度 | 数值 |
|------|------|
| 协同角色数 | **5**（PE / BE / FE / Hist / Architect）|
| Stage 数 | **6**（Inventory / Design / BE schema + PE backfill / FE / 集成 smoke / Hist E2E + Closeout）|
| 总耗时 | **~1 工作日**（多 session 并行）|
| 预估单 session 耗时 | 3-5 天 |
| 协议首次完整使用 | ✅ Sprint K 是 Tagged Sessions 协议首次实战 |
| Stop Rule 触发次数 | **2 次**（PE 175 vs 179 / FE provenanceTier 文案）|
| Commits 数 | ~20+ |

### 4.2 5 类跨 Session Handoff 信号实例（已运行）

来自 docs/methodology/01 §3.3 + Sprint K 实战 + CLAUDE.md §8.1：

| # | 上游信号 | 下游 unblock | Sprint K 实战时机 |
|---|---------|------------|------------------|
| 1 | 【BE】SDL ready | 【FE】codegen unblock | Stage 2 BE 完成 → Stage 3 FE 启动 |
| 2 | 【BE】migration NNNN applied | 【PE】backfill apply unblock | migration 0014 落地 → PE backfill 启动 |
| 3 | 【PE】Stage 2 apply done | 【Architect】给 Hist 发 review prompt | PE backfill 175 TD + 18 PMR 完成 → Architect 给 Hist E2E |
| 4 | 【Hist】review report done | 【Architect】给 PE 发 Stage 4 apply 指令 | Hist 1 reject + 1 approve → Architect 启动 Stage 4 集成 smoke |
| 5 | 【Architect】Stop Rule 裁决 | 发回原触发 session | PE 175 vs 179 / FE provenanceTier 文案两次裁决 |

### 4.3 仲裁案例 3 例

来自 docs/methodology/01 §4.3 + sprint-k closeout §2.2：

| # | 仲裁主题 | 角色 | 仲裁结果 | 仲裁依据 |
|---|---------|------|---------|---------|
| 1 | PE 175 vs 179 backfill stop rule | PE → Architect | R1+R3 混合（接受 175 + 透明度文档）| ADR-014 idempotency 设计意图 |
| 2 | provenanceTier 文案 "未验证" vs "待补来源" | FE → Architect | Option A（统一"未验证"）| ADR-027 enum 一致性 |
| 3 | GraphQL TriageItem interface vs union | BE/FE → Architect | interface（Traceable + lazy person load）| 实现复杂度 + 性能 |

### 4.4 模型选型实证

来自 sprint-k closeout §6.3：

- **主 Architect session**：Opus 4.7（战略 / ADR / 仲裁）
- **子 PE / BE / FE / Hist sessions**：Sonnet 4.6（执行 / 实现 / 报告 / E2E）
- **结论**：multi-role 协作 sprint 推荐 **主 Opus + 子 Sonnet** 模式

### 4.5 抽到 tagged-sessions-protocol.md 的内容清单

framework/role-templates/tagged-sessions-protocol.md 必须涵盖：

1. **协议元素 1：Tag 命名约定**（来自 docs/methodology/01 §3.2 + CLAUDE.md §8.1）
   - 7 个 tag：【Architect】/【PE】/【BE】/【FE】/【DomainExpert】（⚠️FILL 案例方填）/【QA】/【DevOps】
   - 标识规则：`【Tag】Sprint X Stage Y` 开头
2. **协议元素 2：5 类跨 Session 关键信号**（§4.2 表）
3. **协议元素 3：Session 启动模板**（来自 docs/methodology/01 §5.1，6 步）
4. **协议元素 4：Session 收尾模板**（来自 docs/methodology/01 §5.2，5 步）
5. **协议元素 5：冲突升级 3 级机制**（来自 docs/methodology/01 §4.1，附仲裁记录格式）
6. **协议元素 6：模型选型策略**（主 Opus + 子 Sonnet，附 Sprint K 实证）
7. **协议元素 7：协议反模式**（来自 docs/methodology/01 §7.1-7.5，5 个）
8. **附录：Sprint K 实证案例段**（5 角色 / 6 stage / ~1 工作日 / 2 次 Stop Rule / 3 次仲裁 — 完整数据）

---

## 5. README.md 计划

参照 `framework/sprint-templates/README.md` 8 段结构（参见 Sprint L Stage 1 已抽）：

| 段 | 内容 |
|----|------|
| §0 这是什么 | 一套领域无关的 10 角色 KE 团队协作模板（含 multi-session 协调协议）|
| §1 何时用 | KE 项目多人/多 agent 协作；明确"何时不用"（小团队 / 单人项目）|
| §2 文件清单 | 10 角色 + tagged-sessions-protocol + cross-domain-mapping + README |
| §3 5 分钟快速上手 | cp -r 复制 + 重命名 historian.md → 你的 domain-expert.md + 改填 ⚠️FILL |
| §4 跨领域使用指南 | 4.1 必须 instantiate 字段（domain-expert 大段）/ 4.2 角色 tag 调整 / 4.3 协议反模式跨领域复用 |
| §5 设计哲学 | LLM 窗口 = 角色边界 / 决策权 vs 执行权 / RACI 契约 / 越位禁区强制化 |
| §6 反模式（不要这么做）| 万能角色 / 模糊决策权 / 跳级协作 / 口头交接 / 跳过升级机制 |
| §7 反馈与贡献 | 同 sprint-templates README §7 |
| §8 版本信息 | v0.1 / 2026-04-29 / Sprint M Stage 1 first abstraction |

---

## 6. cross-domain-mapping.md 计划

扩充 `framework/sprint-templates/README.md` §4.1 已有的 4 列 mapping 表（古籍 / 法律 / 医疗 / 专利），覆盖 5-6 领域：

| 领域 | Domain Expert 角色名 | 核心术语库 | 主要 source 类型 | NER 实体类别 |
|------|------------------|-----------|----------------|------------|
| 古籍（华典）| Historian | dynasty-periods.yaml / disambiguation_seeds.yaml | ctext / wikisource / 善本 OCR | 18 类（人 / 地 / 事件 / 官职 / etc）|
| 佛经 | Buddhologist | sutras-classification.yaml / lineage-master.yaml | CBETA / 大正藏 / 各宗派记录 | 经 / 论 / 师 / 寺院 / 译者 / 等 |
| 法律 | Legal Expert / 律师 | jurisdictions.yaml / case-citations.yaml | LexisNexis / Westlaw / 中国裁判文书网 | 当事方 / 法条 / 案号 / 法域 / 主审法官 / 律所 |
| 医疗 | Clinical Expert / 医师 | clinical-codes.yaml / drug-mappings.yaml | UpToDate / 临床指南 PDF / 病例库 | 患者 / 诊断 / 药品 / 手术 / 症状 / 检查 |
| 专利 | Patent Attorney | patent-classification.yaml / inventor-disambig.yaml | USPTO / 国家知识产权局 | 专利号 / 发明人 / 申请人 / IPC / 引用专利 / 权利要求 |
| 地方志 | Local History Scholar | regions.yaml / local-events.yaml | 地方志数据库 / 县志志书 | 地名 / 人物 / 事件 / 物产 / 寺观 / 学校 |

每行附"特别说明"段（如医疗的 PHI 隐私要求 / 法律的判例外推规则 / 专利的 IPC 多级分类等）。

---

## 7. methodology/01 cross-reference 计划

参照 Sprint L methodology/02 ↔ framework/sprint-templates/ 紧密化模式：

`docs/methodology/01-role-design-pattern.md` 加 cross-reference 段（位置：§9 修订历史之前），内容：

```markdown
## §X. Framework Implementation

本模式的 v0.1 框架实现位于 `framework/role-templates/`：

- 10 角色模板（chief-architect / domain-expert / pipeline-engineer / etc）→ 复制即可使用
- tagged-sessions-protocol.md → 多 session 协调实操协议
- cross-domain-mapping.md → 6 领域 instantiation 速查表
- README.md → 5 分钟上手指南

跨领域案例方应**先复制 framework/role-templates/ 改填**，再回过头读本文件理解设计哲学。

| 本文件章节 | framework/role-templates/ 对应实现 |
|---------|--------------------------------|
| §2.1 角色定义模板（8 段）| 10 份 \*.md 文件结构 |
| §3 Tagged Sessions 协议 | tagged-sessions-protocol.md |
| §4 冲突升级机制 | tagged-sessions-protocol.md §5 |
| §5 启动 / 收尾标准化 | tagged-sessions-protocol.md §3-§4 |
| §7 反模式 5 项 | README.md §6 + tagged-sessions-protocol.md §7 |
| §8 跨领域使用指南 | cross-domain-mapping.md + README.md §3-§4 |
```

修订历史 §9 加新行：

```markdown
| Draft v0.1.1 | 2026-04-29 | 首席架构师 | Sprint M Stage 1 cross-reference 段加（紧密化 framework/role-templates/）|
```

---

## 8. Stage 1 起草工作量预估

| 文件 | 预估行数 | 预估时长 |
|------|---------|---------|
| chief-architect.md | ~100 | 15 分钟 |
| domain-expert.md（大改 historian.md）| ~200（含 5 instantiation 范例）| 40 分钟 |
| pipeline-engineer.md | ~250 | 30 分钟 |
| backend-engineer.md | ~130 | 15 分钟 |
| frontend-engineer.md | ~140 | 20 分钟 |
| product-manager.md | ~100 | 10 分钟 |
| ui-ux-designer.md | ~140 | 20 分钟 |
| qa-engineer.md | ~130 | 15 分钟 |
| devops-engineer.md | ~140 | 15 分钟 |
| data-analyst.md | ~130 | 15 分钟 |
| tagged-sessions-protocol.md | ~250 | 40 分钟 |
| README.md | ~150 | 20 分钟 |
| cross-domain-mapping.md | ~120 | 25 分钟 |
| methodology/01 cross-reference | ~30（追加段）| 5 分钟 |
| Stage 1 dogfood 报告 | ~200 | 30 分钟 |
| **合计** | **~2210 行** | **~5.2 小时** |

→ 单 Cowork 会话内可完成（与 Sprint L 极致压缩节奏相同；如分会话则会话 1 第一批 + 第二批 / 会话 2 第三批 + tagged-sessions-protocol + README + cross-domain-mapping / 会话 3 dogfood + closeout + retro）。

---

## 9. Gate 0 自检

- [x] 10 份 .claude/agents/ 都标了"哪段领域无关 / 哪段需 ⚠️FILL"（参见 §2 各角色详细标注）
- [x] 抽象优先级表就位（参见 §3 三批顺序）
- [x] methodology/01 ↔ framework/role-templates/ 的 cross-reference 计划就位（参见 §7）
- [x] Sprint K Tagged Sessions 实战数据提取完成（参见 §4）
- [x] tagged-sessions-protocol.md 内容清单就位（参见 §4.5）
- [x] README.md 8 段结构就位（参见 §5）
- [x] cross-domain-mapping.md 6 领域表就位（参见 §6）
- [x] 工作量预估就位（参见 §8）

→ Stage 0 完成 / Stage 1 unblock。

---

## 10. 已就绪信号

```
✅ Sprint M Stage 0 inventory 完成
- 10 份 .claude/agents/ 全部标注完成
- 9 / 10 完全领域无关（仅 historian 需大改）
- ⚠️FILL 占位密度普遍低 → 案例方迁移成本极低
- Sprint K Tagged Sessions 实战数据提取就位（5 角色 / 6 stage / ~1 工作日 / 2 stop rule / 3 仲裁）
- 起草顺序 + 工作量预估完成（~2210 行 / ~5.2 小时）
→ Stage 1 起草 unblock
```

---

**本 inventory 起草于 2026-04-29 / Sprint M Stage 0**
