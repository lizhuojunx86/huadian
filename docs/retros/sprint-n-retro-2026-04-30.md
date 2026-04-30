# Sprint N Retro

> 复制自 `framework/sprint-templates/retro-template.md`（**第三次** dogfood）
> Owner: 首席架构师

## 0. 元信息

- **Sprint ID**: N
- **完成日期**: 2026-04-30
- **主题**: Identity Resolver R1-R6 抽象（framework/identity_resolver/）
- **预估工时**: 2-3 个会话 / 1-2 周
- **实际工时**: ~3 个会话 / 1 天紧凑（开工三步 + Stage 0 inventory + Stage 1 起草 12+13+15 文件 + Stage 1.13 dogfood + Stage 4 closeout）
- **主导角色**: 首席架构师（Opus 4.7）+ PE 子 session（Sonnet 4.6 / Stage 1.13 byte-identical 跑）

---

## 1. Sprint 任务回顾

### 1.1 Stage 顺序与产出

| Stage | 主导 | 状态 | 关键产出 |
|-------|------|------|----------|
| Stage 0.1 brief | Architect | ✅ | stage-0-brief（11 段 / brief-template 第 3 次外部使用）|
| Stage 0.2 inventory | Architect | ✅ | stage-0-inventory — 6 .py / 2394 行扫描 + 9 plugin protocol 设计 + 起草顺序 |
| Stage 1 第 1-3 批 framework core | Architect | ✅ | 13 files / ~2280 lines / 10 sanity tests pass |
| Stage 1 第 4 批 examples | Architect | ✅ | 14 files / ~1440 lines（含 test_byte_identical 脚本）|
| Stage 1 第 5 批 docs | Architect | ✅ | README + CONCEPTS + cross-domain-mapping（3 files / ~550 lines）|
| Stage 1.13 dogfood | Architect + PE 子 session | ✅ | byte-identical PASSED（修 2 issue：路径深度 + alias）|
| Stage 2-3 外部审 | — | ⚪ 押后 | 等外部反馈触发 |
| Stage 4 closeout + retro | Architect | ✅ | stage-4-closeout + 本 retro |

### 1.2 数据 / 工程基线 Δ

| 维度 | Sprint N 前 | Sprint N 后 | Δ |
|------|-----------|-----------|-----|
| framework/sprint-templates/ | v0.1.1 / 11 files | v0.1.1（不变）| 0 |
| framework/role-templates/ | v0.1.1 / 13 files | v0.1.1（不变）| 0 |
| **framework/identity_resolver/** | 不存在 | **28 files / ~3996 lines + 3 docs** | **新增 L1 第三刀** |
| docs/methodology/03 | v0.1（无 cross-reference）| v0.1.1（§X Framework Implementation 段）| +紧密化 |
| services/pipeline/ 生产代码 | (Sprint A-K 状态) | 完全未改 | 0 ✅ |
| Production data validation | 无 framework dogfood | byte-identical 通过（729 person）| +1 严格证明 |
| docs/sprint-logs/sprint-n/ | 不存在 | brief / inventory / dogfood / closeout 4 文件 | +sprint 完整记录 |

---

## 2. 工作得好的部分（What Worked）

### 2.1 Stage 0 inventory 路径分层把 Stage 1 起草拆成可执行的 5 批

inventory 阶段把 13 framework core 文件按依赖关系分 3 批（数据契约 / 核心算法 / 主流程）+ 14 examples 文件分 3 sub-batch（简单 / 中等 / DB adapter）+ 3 文档。整体起草过程**没有卡顿** — 每批完成后做 syntax check 就开始下一批。

→ inventory 不是浪费时间，是决策的前置投资。Sprint L+M+N 都确证此点。

### 2.2 byte-identical dogfood 是抽象正确性的最强证明

vs Sprint L+M 的"覆盖度"dogfood（90% / 99.2% — 是 structural / qualitative 验证），Sprint N 的 byte-identical 是**严格的等价证明**：framework code + huadian_classics adapters 跑出与 production 完全一致的输出（除合理 alias）。

这个 gate 触发了 2 次中间 issue：

1. 路径深度 bug — 如果没有 byte-identical 验证，会以为 framework 抽象 OK，但实际 dictionary / guards 全跳过 → R1 多了 8 个不该 merge 的 group。这是**严重**抽象错误，但单元测试不容易抓
2. alias 命名 — 这不算抽象错，但 dogfood 自身需要 dogfood

→ **任何代码层抽象都应该有 byte-identical dogfood gate**。这是 Sprint N retro 的核心 lesson。

### 2.3 9 Plugin Protocol 设计经实战验证

brief §3 设计 7 个 Plugin，inventory §3 调整到 9 个（加 R6PrePassRunner / EntityLoader / ReasonBuilder）。Stage 1.13 dogfood 全部跑通 = 9 个 Protocol 设计**没有 over-engineering**（每个都用上了）+ **没有 under-engineering**（没漏什么）。

### 2.4 GuardChain 不是 Plugin 是参数 — 设计赢了

如果按 huadian_pipeline 原模式，GuardChain 是 module-level globals（`GUARD_CHAINS = {...}`）。但 Sprint N 改设计为 `resolve_identities(guard_chains=...)` 参数注入。

**收益**：

- 跨领域案例方在 resolve 调用时传入自己的 guards
- 不会污染 framework module state
- 容易测试 / mock
- 一个项目里跑多种 guard 配置（experimentation）

byte-identical 通过 = 这个设计变化不影响 production 行为。

### 2.5 person → entity 命名通用化 + alias 兼容验证有效

framework 用 `EntitySnapshot` / `entity_a_id` 等通用名，但保留 `PersonSnapshot = EntitySnapshot` alias 让 huadian_pipeline 代码无缝迁移。

dogfood 中 `total_persons` vs `total_entities` 字段名差异是合理的（不同抽象层各说各话）— compare() 函数处理 alias 即可。

### 2.6 单 sprint 跨 3 会话节奏舒适 + 第 3 会话 byte-identical 验证有惊喜

会话 1：开工 + Stage 0 + Stage 1 第 1-3 批（framework core）
会话 2：Stage 1 第 4-5 批（examples + docs）
会话 3：Stage 1.13 dogfood（含 PE 子 session 跑）+ Stage 4 closeout / retro

3 会话节奏比 L+M 的 1 会话舒缓很多 — 适合代码层抽象的复杂度。dogfood 的 2 次 fail-then-fix 让会话 3 有"活的工程感"（vs L+M 都是 cosmetic dogfood）。

---

## 3. 改进点（What Didn't Work）

### 3.1 路径深度 bug — 应该早期 sanity check 就能抓

`Path(__file__).parents[5]` 看起来对（5 层就是 5 层），但实际是 `parents[4]` 才到项目根。我**算错了**。

**根因**：抽象时手算路径深度，没用 `print(__file__)` 验证一次。

**改进建议**：未来 examples/ 抽象**必须**包含一个 quick sanity test（如 `python -c "from .dictionary_loaders import _default_dict_dir; print(_default_dict_dir())"`）— 早期发现路径错误。

→ 登记 DGF-N-02：framework/identity_resolver/examples/huadian_classics/ 路径配置改为环境变量 / 构造函数参数（不依赖 `parents[N]`）。

### 3.2 byte-identical compare() 自身的 bug — dogfood test 的 dogfood

第一轮跑 byte-identical 出 `total_persons / total_entities` 差异，我 reflexively 以为是 framework bug，但实际是 **test 的 compare() 函数硬编码字段名漏掉 alias 处理**。

**根因**：写 test 时 normalize_for_compare 想到了 alias（PersonSnapshot = EntitySnapshot），但 compare() 写成"字段名一一对应"模式。

**改进建议**：登记 DGF-N-01 — byte-identical compare() 加 `__field_aliases__` 通用机制（让案例方扩展 alias mapping）。

**元 lesson**：dogfood test 自身是 framework 的一部分，需要 dogfood test。Sprint M dogfood-on-template 元 pattern 第 N 次确证。

### 3.3 framework/identity_resolver/ 没有自己的 unit tests

Sprint N 有 sanity tests（10 个）+ byte-identical dogfood，但没有**结构化 pytest unit tests**。这意味着：

- 一旦未来重构，没有快速回归测试
- 跨领域案例方做 fork 时缺乏 testing 范本

**改进建议**：登记 DGF-N-03 — framework/identity_resolver/ 加 conftest.py + 单元测试（vs 当前的 sanity check shell oneliner）。

### 3.4 examples 只有 huadian_classics — 跨领域抽象未实证

cross-domain-mapping.md 设计了 6 领域 R1-R6 适配，但**只有 huadian_classics 真的跑了**。其他 5 领域（佛经 / 法律 / 医疗 / 专利 / 地方志）只有 mapping 表，没有完整 reference impl。

**改进建议**：登记 DGF-N-04 — 至少添加 examples/legal/ 或 examples/medical/ 一个跨领域 reference impl，证明 Plugin Protocol 真的跨领域可用（vs 只对 huadian 可用）。

---

## 4. Stop Rule 触发回顾

| Rule | 触发？ | 路径 |
|------|------|------|
| #1 byte-identical 验证失败 | ⚠️ 临时触发 2 次 | 第 1 次 dictionary 路径错 → 修 3 文件 / 第 2 次 alias 命名错 → 修 test compare() |
| #2-#8 | ❌ 未触发 | — |

**Stop Rule #1 触发处理过程**：

- 第 1 次 fail：merge_groups=8 vs 16 + blocked=17 vs 0。看 log 立即识别根因（"dictionary file not found" warnings）。修复 3 文件 path。
- 第 2 次 fail：所有数据等价但 test 报字段名差异。识别根因（test 自身 bug）。修 compare()。

→ 两次都**当场修复 < 5 分钟**。Stop Rule 设计的"触发 → Architect 仲裁 → 修复 / rollback"在实际中良好工作。

→ Sprint N 是 medium-risk sprint（per brief §1.2 vs L+M low-risk）— Stop Rule #1 临时触发证明 dogfood gate 有效抓抽象 bug。

---

## 5. Lessons Learned

### 5.1 工程层面

- **byte-identical dogfood 是代码抽象的 must-have gate**：vs 文档抽象的覆盖度判定，代码抽象必须严格等价。Sprint N 抓出 2 个 issue 都是 byte-identical 抓的，单元测试 / sanity check 不容易抓
- **硬编码相对路径深度脆弱**：未来抽象例子时用环境变量或构造函数参数，不要依赖 `parents[N]`
- **dogfood test 自身需要 dogfood**：Sprint M 元 pattern 在 Sprint N 第 8 次实例验证（compare() bug 案例）
- **9 个 Plugin Protocol 是 sweet spot**：少了功能不全 / 多了 over-engineering。Sprint N inventory 7→9 调整正好

### 5.2 抽象层面

- **GuardChain 改参数化是关键设计赢**：如果保留 module-level globals 模式，跨领域案例方迁移会非常痛苦
- **person → entity 通用化 + alias 兼容**是处理"案例 vs 通用"命名冲突的好范本，可推广到未来 framework 模块（如 invariant_scaffold 把 huadian_pipeline 的 V1-V11 名字保留为 alias）
- **Examples 是 framework 的实证**：framework/identity_resolver/ + examples/huadian_classics/ 双层结构让跨领域案例方"看着学"非常容易（vs 只看 framework abstract code 难学）

### 5.3 协作层面

- **Architect 主 + PE 子 session 协调首次实战**（vs L+M 都是 single actor）：role-templates/tagged-sessions-protocol.md 第一次"非 Sprint K"实战。结果良好——PE 子 session 跑 byte-identical 完全自动化（用户只 copy-paste 命令）
- **dogfood 自报告 + Architect 修 framework 的循环**：byte-identical 失败时 PE 报告 diff，Architect 看 diff → 改 framework code → PE 重跑。3 个循环（路径错 → alias 错 → 通过）非常顺畅

### 5.4 模型选型 retro

- **Architect Opus 4.7**：Stage 0 inventory（9 plugin protocol 设计）+ Stage 1 起草（13+14+3 文件）+ Stage 4 closeout — 全程 Opus 充分
- **PE Sonnet 4.6 子 session**（Stage 1.13）：跑 dry-run + 看 diff + 报告 — Sonnet 充分（执行 + 比对类任务）
- 主 Opus + 子 Sonnet 模式 Sprint K + Sprint N 双案例确证有效

---

## 6. 衍生债登记

### 6.1 Sprint N 新增 v0.2 候选（5 项）

| ID | 描述 | 优先级 | 来源 |
|----|------|--------|------|
| DGF-N-01 | test_byte_identical.py compare() 加 `__field_aliases__` 通用机制 | P3 | dogfood §2.2 |
| DGF-N-02 | examples/huadian_classics/ 路径硬编码改环境变量 / 构造函数参数 | P3 | dogfood §2.1 |
| DGF-N-03 | framework/identity_resolver/ 加 conftest.py + 单元测试 | P3 | retro §3.3 |
| DGF-N-04 | 至少加 examples/legal/ 或 examples/medical/ 跨领域 reference impl | P3 | retro §3.4 |
| DGF-N-05 | EntityLoader Protocol 加 `load_subset(filters)` 方法（增量 resolve）| P3 | inventory 评估时考虑 / 未实施 |

### 6.2 累计 v0.2 候选（Sprint L+M+N 合并）

| Sprint | 总数 | 已 patch | 仍待 v0.2 |
|--------|------|---------|----------|
| L | 4 | 0 | 4 |
| M | 7 | 6 (DGF-M-02~07) | 1 (DGF-M-01) |
| N | 5 | 0 | 5 |
| **合计** | **16** | **6** | **10** |

→ v0.2 release 触发条件：累计 ≥ 15 项 ✅ 已达 / 或框架第 4 模块完成（待 Sprint O）/ 或跨领域案例方主动接触触发。

### 6.3 押后

| 押后项 | 触发条件 |
|--------|---------|
| framework/identity_resolver/ 外部工程师走通验证 | 1-2 个朋友 / 跨领域案例方主动接触 |
| 跨领域案例方真用 cross-domain-mapping.md 做 instantiation | 同上 |

---

## 7. D-route 资产沉淀盘点

### 7.1 本 sprint 沉淀的可抽象 pattern

1. Identity Resolver R1-R6 框架（最直接产出）— framework/identity_resolver/ v0.1
2. 9 Plugin Protocol 体系（DictionaryLoader / etc）
3. byte-identical dogfood pattern（vs covered/structural dogfood）— **代码层抽象 must-have gate**
4. GuardChain 参数化 design pattern（vs module-level globals）
5. person → entity 命名通用化 + alias 兼容 pattern
6. examples/case-domain/ 完整 reference impl pattern
7. Architect 主 + PE 子 session 协调首次"非 Sprint K"实战 — role-templates/tagged-sessions-protocol.md 验证有效

### 7.2 本 sprint 暴露的"案例耦合点"

1. `parents[N]` 硬编码路径（→ DGF-N-02）
2. byte-identical compare() 字段名硬编码（→ DGF-N-01）
3. R1 cross_dynasty_attr 默认 "dynasty" + R6 source 默认 "wikidata" 是 HuaDian-friendly（已在 cross-domain-mapping.md 强调）
4. examples/ 只有 huadian — 跨领域未实证（→ DGF-N-04）

### 7.3 Layer 进度推进

- **L1**: 🟢 治理类双模块 → 🟢 **治理 + 代码层第一刀**（+~3996 行 / +28 files / +1 抽象资产模块）
- **L2**: methodology/03 v0.1 → v0.1.1（cross-reference 紧密化）/ 草案内容仍 v0.1
- **L3**: +1 严格 dogfood 案例（华典 729 person production data byte-identical 等价）
- **L4**: 不变（v0.2 release 候选条件已全面达成 — 留给 Sprint O 完成或外部反馈触发）

### 7.4 下一 sprint 抽象优先级建议

按 closeout §2.4：

- **推荐 Sprint O 主题**：V1-V11 Invariant Scaffold 抽象（P1）
- **形式**：framework/invariant_scaffold/（5 大 invariant pattern + bootstrap test 模板）
- **抽象自**：services/pipeline/src/huadian_pipeline/qc/ + docs/methodology/04
- **预估工时**：与 N 接近（~2-3 会话）
- **节奏**：可以单 actor + Opus 全程（invariants 抽象比 identity resolver 简单）
- **启动时机**：用户 ACK + 准备好（无紧急 timeline；framework v0.2 release 也可在此 sprint 完成时考虑）

---

## 8. 下一步（Sprint O 候选议程）

依据本 retro + Sprint N closeout §2.4：

- **主线**：V1-V11 Invariant Scaffold 抽象（framework/invariant_scaffold/）
- **副线**：framework v0.2 release 准备（CHANGELOG + version bumps + GitHub release notes）
- **押后**：Audit + Triage Workflow 抽象（Sprint P 候选）/ examples/legal 或 medical 跨领域 reference impl（DGF-N-04）

不要做的事：

- ❌ 不主动启动新 ingest sprint（违反 C-22）
- ❌ 不立即做 framework v0.2 公开 release（per Sprint M retro §8 + Sprint N retro §3.4 — 推荐 Sprint O 完成或跨领域反馈后再 release）
- ❌ 不立即触发 ADR-031 plugin 协议标准化（per Sprint N inventory §7 — 等跨领域案例方反馈触发）

---

## 9. 决策签字

- 首席架构师：__ACK 2026-04-30__

---

**Sprint N retro 完成 → Sprint N 关档。**
