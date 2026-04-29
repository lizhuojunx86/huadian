# ADR-029 — Open Source Licensing Policy (Project-level)

- **Status**: accepted
- **Date**: 2026-04-29
- **Authors**: 首席架构师
- **Related**:
  - ADR-008（License 策略 — workspace package.json licenseEnum） — 不同 scope，不冲突；本 ADR 是项目级 release license，ADR-008 是 source data licenseEnum 的 schema 选择
  - ADR-028（战略转型）— 本 ADR 是 D-route 公开化的前置条件
  - 项目宪法 C-14（许可证与版权前置）
- **Supersedes**: 无
- **Triggered by**: 项目转 public（2026-04-29）+ 用户明确"商业可用 + 须 attribution"需求

---

## 1. Context

### 1.1 触发事件

- 2026-04-29 项目仓库由 private 转 public
- 用户明确许可证要求："别人可在该项目基础上的后续开发用于商业目的，但必须引用来源"
- ADR-028 §2.1 定位项目为开源框架 + 案例参考实现
- 当前 repo 根目录无 LICENSE 文件 → 默认全权保留版权 → 比 private 还糟糕（外部访客以为不可用）

### 1.2 既有许可证相关上下文

ADR-008（2026-04-17）解决的是**不同问题**：项目内部 schema 中 `Book.license` 字段如何 enum 化（即源数据的许可证标识符的 schema 表达），不是项目本身的 release license。两个 ADR 互不冲突。

`packages/shared-types/src/enums.ts` 现有 `licenseEnum`：
```ts
export const licenseEnum = z.enum([
  "CC0",
  "CC-BY",
  "public_domain",
  "proprietary",
  "unknown",
]);
```
仍然有效，描述的是我们 ingest 的源材料的许可证（如 ctext.org → public_domain；wikidata → CC0）。

### 1.3 项目内容类型 (license scope inventory)

| 类型 | 路径 | 适用 license |
|------|------|-------------|
| 应用代码 | `apps/web/`, `services/api/src/`, `services/pipeline/src/` | Apache 2.0 |
| 共享包 | `packages/*/src/` | Apache 2.0 |
| 脚本 | `scripts/`, `services/pipeline/scripts/` | Apache 2.0 |
| Build 配置 | `*.json` / `*.toml` / `*.yaml` / `Dockerfile` / `Makefile` | Apache 2.0 |
| Schema 定义 | `*.graphql`, `*.sql` migrations, Drizzle schema TS files | Apache 2.0 |
| 数据 | `data/`, `services/pipeline/fixtures/sources/`, `services/pipeline/data/` | CC BY 4.0 |
| 文档 | `docs/`, repo 根 `*.md`, `CLAUDE.md` | CC BY 4.0 |
| 方法论 | `docs/methodology/`, `docs/strategy/` | CC BY 4.0 |
| ADR | `docs/decisions/` | CC BY 4.0 |
| Sprint logs / retros | `docs/sprint-logs/`, `docs/retros/` | CC BY 4.0 |

---

## 2. Decision

### 2.1 双许可证结构

- **代码 → Apache License 2.0** (`LICENSE`)
- **数据 + 文档 + 方法论 → Creative Commons Attribution 4.0 International** (`LICENSE-DATA`)
- **NOTICE 文件**记录第三方 attribution（Apache 2.0 §4(d) 强制要求衍生项目保留）

### 2.2 边界规则

如果某个文件的"代码 vs 数据/文档"归属模糊，按以下规则裁定：

1. **首要**：按文件位置（apps/services/packages/scripts/ → 代码；docs/data/fixtures/sources/ → 数据/文档）
2. **次要**：按文件内容主体性质（可执行 / 可被 import / 是 build 产物 → 代码；可读性叙述 / 结构化数据 / 表格 → 数据/文档）
3. **repo 根 `*.md` 文件**（README / CONTRIBUTING / NOTICE 本身、CLAUDE.md、华典智谱_架构设计文档）→ CC BY 4.0
4. **repo 根 `*.json` / `*.toml` / `*.yaml` 等 build 配置**→ Apache 2.0

### 2.3 第三方源数据归属

源材料 license 兼容性已审计：

| 源 | License | 与我们 Apache 2.0 / CC BY 4.0 兼容 |
|---|---------|-----|
| 史记原文（司马迁，~100 BCE）| Public Domain (worldwide by age) | ✅ 完全兼容 |
| ctext.org 数字化版本 | 平台 ToS 鼓励学术使用 + attribution；文本本身 PD | ✅ 兼容（NOTICE 中已 attribute）|
| Wikidata 字典数据 | CC0 1.0 | ✅ 完全兼容（CC0 无传染性） |
| Apache/MIT/BSD 第三方代码依赖 | 各 OSI 许可证 | ✅ 与 Apache 2.0 兼容 |
| GPL 第三方代码依赖 | 强 copyleft | ❌ **禁用** — 不引入 GPL/LGPL/AGPL 依赖 |

### 2.4 Inbound = Outbound

贡献者通过 PR 提交内容即视为按对应 license（Apache 2.0 / CC BY 4.0）授予项目权利。CONTRIBUTING.md §1 形式化此规则。

**当前不要求单独的 CLA**。Apache 2.0 §5 已经为贡献提交建立了等效法律框架。如未来需要 CLA（例如形成法律实体或商业许可时），将以新 ADR 公告，**不溯及既有贡献**。

### 2.5 商标

"华典智谱" / "HuaDian" 名称未注册商标。Apache 2.0 §6 默认不授予商标使用权，但本项目不主张商标。任何衍生项目可以使用名称表述"基于华典智谱"/"derived from HuaDian"，但不应在自己的 LICENSE 文件、合规通告、商业宣传中暗示华典智谱项目的官方背书。

---

## 3. Rationale (Why Apache 2.0 + CC BY 4.0)

### 3.1 为什么 Apache 2.0 (vs MIT / BSD)

| 优势 | 解释 |
|------|------|
| 显式专利授予 (§3) | 框架抽象（identity resolver / GUARD_CHAINS / V1-V11 invariants 等）有可能被未来某个公司申请专利反告用户。Apache 2.0 显式禁止贡献者这么做。MIT / BSD 缺此条款 |
| NOTICE 文件机制 (§4(d)) | 强制衍生项目保留 NOTICE，attribution 可追溯。MIT 只要求"保留 license 文件"，企业用户的 attribution 义务模糊 |
| 商标保护 (§6) | 显式不授予商标，避免衍生项目混用名义 |
| 企业法务友好 | 大公司法务部门对 Apache 2.0 流程标准化，机构合作障碍最小 |
| Anthropic 项目对齐 | Claude Cookbook 等 Anthropic 自己开源项目多走 Apache 2.0，未来合作不需要切换 |

代价：license 文本长（10000+ 字 vs MIT 170 字），但只在 LICENSE 文件 + 每个文件的 boilerplate header 出现，对开发体验无影响。

### 3.2 为什么 CC BY 4.0 (vs CC0 / GPL / CC BY-SA)

| 选项 | 不选理由 |
|------|----------|
| CC0 | 放弃 attribution 要求 → 用户明确反对；方法论被人拿去做培训课程不署名也无法追究 |
| GPL / AGPL | copyleft 传染性 → 衍生项目必须开源 → 与"商业可用"需求冲突 |
| CC BY-SA 4.0 | ShareAlike 传染性 → 衍生作品必须同许可 → 限制商业再发布 → 与用户需求冲突 |
| CC BY-NC 4.0 | NonCommercial 直接禁止商业 → 与用户需求冲突；shiji-kb 走此路，其商业化路径有问题（详见 ADR-028 §1.2 第三方调研） |
| **CC BY 4.0** | ✅ **选定** — 商业允许 + 强制 attribution，正好匹配 |

### 3.3 为什么双许可证而不是单一

- 代码 / 数据本质不同：代码需要专利 + 商标条款，数据不需要
- 单 Apache 2.0 用于数据：法律不严谨（Apache 是"软件许可证"，对数据/文档表达力弱）
- 单 CC BY 4.0 用于代码：CC 系列明确不为代码设计（CC 官方建议代码用 OSI 许可证）
- 双许可证是业界主流（Mozilla / GitLab / 多数知识图谱项目走此路）

### 3.4 为什么不为不同子目录用更细粒度的多许可证

理论上可以：framework 抽象代码用 Apache 2.0、华典智谱史记案例代码用 MIT、第三方学者贡献用各自许可证。但：

- 复杂度爆炸
- 贡献者认知负担过重
- 兼容性矩阵难以维护
- 当前项目阶段不需要这么细

未来如有特定子目录需要单独许可证（如商业版分支），通过新 ADR 决定。

---

## 4. Consequences

### 4.1 Positive

- 项目可被任何人合法使用 / 修改 / 分发，包括商业用途
- attribution 强制保留，社区贡献者获得长期可见的署名
- 双许可证清晰边界，下游用户对自己的合规义务清晰
- 与开源主流（Apache 2.0 + CC BY 4.0）对齐，集成 / 引用便利
- 从技术品牌角度：选择 Apache 2.0 信号"项目认真长期做"

### 4.2 Negative / Risk

| 风险 | 缓解 |
|------|------|
| 商业用户不 attribution（违规但难追究）| 接受，open source 普遍如此；NOTICE 机制至少使违规可识别 |
| 衍生项目滥用"华典智谱"名号 | Apache 2.0 §6 + ADR-029 §2.5 不授予商标；可发警告函但不主张诉讼 |
| 未来想商业化（双重许可）| Apache 2.0 + CC BY 4.0 不阻止双重许可。我们可同时提供商业版，只要清晰区分。需要时新 ADR 决策 |
| GPL 依赖意外引入 | CI 添加 license-checker（建议 P2 衍生债 T-P2-XXX）|
| 数据贡献者认为 CC BY 4.0 不够保护原创性 | CC BY 已是数据领域最严的"商业允许"许可；如需 SA 应在 ADR-028 §5 阻塞条件层面重评 |

### 4.3 What Changes

| 文件 | 操作 |
|------|------|
| `LICENSE` | 新建（Apache 2.0 全文）|
| `LICENSE-DATA` | 新建（CC BY 4.0 全文）|
| `NOTICE` | 新建（Apache 2.0 §4(d) 强制）|
| `README.md` | §License 段重写（"Private repository. All rights reserved." → 双许可证声明）|
| `CONTRIBUTING.md` | 新建（§1 inbound = outbound 形式化）|
| `CLAUDE.md` §1 | 更新"Repo private (未来可能开源 / 商业化)" → "已开源（Apache 2.0 + CC BY 4.0）"（Stage A.5 微更新；详细重写在 Stage B）|
| `ADR-028` §6 | 更新："框架命名 ADR-029" → "ADR-030"（因 ADR-029 被本许可证决策占用）|
| `packages/*/package.json` 里的 `"license"` 字段 | 当前可能是 "UNLICENSED" 或缺失 → 改为 "Apache-2.0"（建议 P1 衍生债）|

### 4.4 What Doesn't Change

- 既有 ADR-008 schema 决策（`licenseEnum` 描述源数据 license）
- 既有项目宪法（C-14 已经预设 license 前置原则）
- 既有 source data 许可证（ctext PD / Wikidata CC0 不变）
- 既有代码 / 数据 / 文档（视为"在本 ADR 接受时刻起"按双许可证发布；既有贡献者贡献时已默示同意 inbound = outbound）

---

## 5. 不可逆点

### 5.1 已不可逆（本 ADR 接受后即生效）

- 历史发布的代码 / 数据 / 文档**不能撤回**已授予的许可（Apache 2.0 §2 + CC BY 4.0 §2 irrevocable grant）
- 即使未来项目转向其他许可证，已发布快照仍然有效

### 5.2 可逆但需新 ADR

| 决策 | 重评条件 | 触发后 ADR |
|------|---------|-----------|
| Apache 2.0 → 其他 OSI 许可证 | 法务建议 / 社区强烈反弹 | ADR-XXX (only for future contributions) |
| CC BY 4.0 → CC0 | 完全开放方法论传播需求 | ADR-XXX |
| CC BY 4.0 → CC BY-SA 4.0 | 防止衍生闭源化需求 | ADR-XXX |
| 引入 CLA | 法律实体形成 / 复杂多方贡献 | ADR-XXX |
| 引入双重商业许可 | 商业版本计划成熟 | ADR-XXX |

---

## 6. 阻塞条件 (本 ADR 应被重评的情况)

1. 法务专业意见认为 Apache 2.0 / CC BY 4.0 不适合本项目场景 → 暂停 + 重评
2. 第三方源数据被发现 license 不兼容（如某 fixture 来自我们以为 PD 但实际有版权的源）→ 暂停相关数据，不影响代码部分
3. shiji-kb 团队或 ctext.org 团队明确反对我们的 attribution 方式 → 修订 NOTICE / CONTRIBUTING

---

## 7. Implementation Checklist

Stage A.5 落地（本 ADR 接受后立即执行）：

- [x] `LICENSE` (Apache 2.0)
- [x] `LICENSE-DATA` (CC BY 4.0)
- [x] `NOTICE`
- [x] `README.md` 重写（含 license 段）
- [x] `CONTRIBUTING.md`
- [x] `ADR-029-licensing-policy.md` (本文件)
- [ ] `ADR-028` §6 序号修订（待执行）
- [ ] `CLAUDE.md` §1 微更新（待执行）

后续阶段（Stage B 期间或之后）：

- [ ] `packages/*/package.json` `"license"` 字段统一为 `"Apache-2.0"`（P1 衍生债，登记为 T-P1-XXX）
- [ ] `services/pipeline/pyproject.toml` `license` classifier 添加 `Apache-2.0`（同上）
- [ ] CI 加 license-checker，禁止 GPL/AGPL 传染性依赖混入（P2 衍生债 T-P2-XXX）
- [ ] 每个代码文件加 SPDX header `// SPDX-License-Identifier: Apache-2.0`（可选，Apache 2.0 推荐但不强制；P2 衍生债）

---

## 8. 决策签字

- 首席架构师：__ACK 2026-04-29__
- 信号：本 ADR 接受 → Stage A.5 实施完成 → Stage B 启动

---

**本 ADR 起草于 2026-04-29 / Stage A.5 of D-route doc realignment.**
