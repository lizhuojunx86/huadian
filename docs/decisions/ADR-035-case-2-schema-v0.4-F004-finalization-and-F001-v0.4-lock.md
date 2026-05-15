# ADR-035 — Case-2 Schema v0.4: F-004 fundamental_finding lock + F-001 v0.4 三层精细化 schema 化 + cross_form / cross_product scope + 边界子通道候选

- **Status**: **accepted** (用户审稿通过 / GO-M-ζ / 2026-05-15)
- **Date**: 2026-05-15
- **Authors**: 首席架构师（Claude）+ 用户审稿通过（决策点 6.1/6.2/6.4/6.5 全选推荐 / 6.3 默认 B 路径）
- **Related**:
  - ADR-028（D-route 战略转型）— Layer 3 跨领域案例机制
  - ADR-033（Case-2 schema v0.1 → v0.2：incoming_qc + 3 子通道）
  - ADR-034（Case-2 schema v0.2 → v0.3：dual_limit 6 类 + P11 + 三维交互 + 时间维度）
  - `docs/cases/tcm-extraction/schema/extraction-schema-v0.3.md`（v0.3 lock 文档 / 完整保留）
  - `docs/cases/tcm-extraction/schema/extraction-schema-v0.4.md`（v0.4 lock 文档 / 待用户 ACK 后起草）
  - `docs/cases/tcm-extraction/data/pilot-WK-B1/batch-record.json`（_meta._schema_upgrade_history 0.3.1~0.3.4 records-only patch / A-016~A-021 + Q-029/030/031/035/039/040 + F-004 + F-001 v0.4 已实证 / 211.7 KB / 7635+ 行）
  - `docs/methodology/08-dual-reverse-calculation-pattern.md` v0.3 partial（F-004 命题独立成文）
  - `docs/methodology/09-layered-compliance-narrative-pattern.md` v0.2 全本（F-001 v0.4 三层结构独立成文）
- **Supersedes**: 无（v0.3 完整保留 / 仅增量扩展）

---

## 1. Context

### 1.1 案例时间锚（截至 2026-05-15）

- Stage 0 ~ Stage 2 完成 ✅
- Stage 3：B 段 22/22 = 100% P1 lot 闭环；A 段 16/100；GO-G-γ 跨产品P2 lot-260201 + T_series 6 批 ✅
- F-001 / F-002 / F-003 / F-004 全部 fundamental_findings 状态：
  - F-001：v0.4 三层精细化 / 已落 batch-record.json `_v0_4_精细化` 字段 / **schema 文档未 lock**
  - F-002：v0.3 适用范围限定 / 已落 schema-v0.3.md ✅
  - F-003：finalized_来料检验侧_with_F004_extension_AND_condition_B_met_via_yanreqingpian / 已落 schema-v0.3.md ✅
  - F-004：finalized_X1_satisfied_with_mechanism_depth_extension_pending_X2 / 已落 batch-record.json fundamental_findings / **schema 文档未 lock**
- ADR-033 ✅ + ADR-034 ✅ + 本 ADR-035 (draft)
- D-route Layer 2 应用层文章组：08 v0.3 partial + 09 v0.2 全本 / **F-001 v0.4 + F-004 已成应用层文章核心论点**

### 1.2 v0.3 schema 的盲点（GO-D-α → GO-J-ε 累积浮现）

batch-record.json `_meta._schema_upgrade_history` 中显示，自 v0.3 lock 起累积了 4 个 records-only patch（v0.3.1 / v0.3.2 / v0.3.3 / v0.3.4），其中 v0.3.2 + v0.3.4 都在 `_note` 中明示"schema v0.4 候选累积 → 应独立 ADR-035"。具体盲点 11 项：

**(1) F-004 fundamental_finding 未 lock 进 schema 文档（batch-record.json 已落 / schema-v0.3 未 lock）**
- F-004 命题：批生产记录中存在 downward 压线博弈论反算（与 F-002 文化话语 upward 反算并存且方向相反）
- 状态：finalized X1（双产品 σ 跨批 ≈ 0 / 紧贴位置形态二种 / Q-027 用户访谈直接确证）
- F-002 vs F-004 对比表已成为 09 文章核心论点
- 不 lock 的代价：未来案例引用 F-004 时无 schema 锚点 / 三方读者无法定位

**(2) F-001 v0.4 三层精细化未 lock 进 schema 文档（A-016 + A-017 + Q-029 触发）**
- 表层：三类参数（输入/输出/衍生）
- 中层：运筹层决策（车间主任 + 排产）+ 多形态（跨批切换 / 同批并行 / A-021）
- 深层：身体化经验（自我保护 + ABAB 班次 + 真实噪声）
- 不 lock 的代价：09 文章核心论点（三层结构 / 4 mermaid 之一）无 schema 锚点

**(3) Anomaly.scope 取值未涵盖 cross_form（A-019 触发）**
- v0.3 已支持 single_record / cross_record / cross_batch / cross_product / cross_supplier / cross_time_window
- A-019（黄芩饮片 70.94 kg 领料单 L-mat-01 vs 批指令 L-mat-07）属于 form 之间不一致 / 不属于 cross_record
- 不 lock 的代价：批生产记录侧 form 间不一致问题归类不准 / 与 record 间不一致混淆

**(4) cross_product 顶层 section 未正式 schema 化（Phase 1+2 已用）**
- batch-record.json 已落 `cross_product_yanreqing_lotL-mat-07_v0_1` + `cross_product_yanreqing_T_series_v0_1` 两个顶层 section
- v0.3 schema 文档未涵盖跨产品顶层 section 的字段定义
- 不 lock 的代价：跨产品扩展（P3等）schema 不一致

**(5) 边界子通道 high_minor / high_extract 候选未决（Q-035）**
- Phase 1 黄芩苷 1.15x（标准 8% / 介于 main/minor 边界）+ 玄参浸出物 1.175x（标准 60% / 超 main 量级）
- main_component 边界值 ≥30 是否调整为 ≥10？
- 不 lock 的代价：边界物料 _subchannel 归类争议 / σ 检验组别不稳定

**(6) qualitative_LOD 反算形态候选未决（A-018 触发）**
- 跨产品 + 跨物料汞含量统一 0.1 mg/kg / 50% LOD（4 物料一致）
- F-002 命题扩展候选："仪器 LOD 边界统一填值"反算
- 不 lock 的代价：F-002 应用范围继续不精确 / 漏掉一类系统性反算

**(7) 跨产品 σ 矩阵字段未 schema 化（GO-D-α + GO-G-γ-Phase 2）**
- 收率跨 6 批 σ 数据：P1 0.0223 / P2 0.0275
- 紧贴位置 + 偏离量级二维表已成 09 文章核心实证
- 不 lock 的代价：未来案例 σ 矩阵格式不一致 / smoking gun 检验函数难复用

**(8) F-001 中层运筹层多形态字段未 schema 化（A-021 触发）**
- 跨批切换 vs 同批并行 二种实证形态
- 不 lock 的代价：中层运筹层在新案例中的形态扩展无 schema 引导

**(9) ABAB 班次轮值字段未 schema 化（A-015 / Q-006-延伸触发）**
- 12 批跨产品 100% ABAB 严格轮值（操作工 L / 操作工 Z）
- 班次配合制度三功能（互相监督 / 工资公平 / 自我保护）
- 不 lock 的代价：深层身体化经验的"班次制度"维度无 schema 锚点

**(10) P12 中药材检验原始记录页型未 lock（GO-G-γ-Phase 1 栀子触发）**
- 16 页中药材检验原始记录 / 性状描述照抄标准 / F-001 表层延伸到原始记录层
- v0.3 schema 中 P11 已 lock / P12 未 lock
- 不 lock 的代价：未来 OCR 该页型时字段定义不一致

**(11) F-004 X2 unresolvable 显式标记未 schema 化**
- F-004 X2（跨企业访谈）已决定先放着 / 但 schema 文档未显式标"documented_unresolvable_X2"
- 不 lock 的代价：未来读者不清楚 F-004 finalize 状态的精确边界

### 1.3 不升级的代价（汇总）

如果保持 v0.3：
- F-001 v0.4 + F-004 两个 fundamental_findings 在 batch-record.json _meta 已落但 schema 文档未 lock = 数据/文档不同步
- 09 文章 v0.3 完整初稿（ETA 2026-07）写作时引用的"三层结构 schema 化"无锚点
- 08 文章 v0.3 完整初稿（ETA 2026-06）写作时引用的"F-002 vs F-004 对比表"无 schema 锚点
- A-019 cross_form scope 等新 anomaly 类无标准化方法
- 跨产品扩展（GO-G-γ 后任何新产品）schema 字段不一致

### 1.4 升级的边界（不在 v0.4 范围内）

- F-004 X2 跨企业访谈实证（已决定先放着 / X2 维持 unresolvable）
- HPLC 谱图 / TLC 板照片等"二阶 ground truth"原始记录的 schema（pp.4+ 待 Stage 5）
- Stage 5.5 三层代差地图字段（仍待更多实证）
- F-005 / F-006 候选命题（暂无候选浮现）
- B1 剩余 84 页 OCR（按 D-route §6.2 已降级 / 不依赖于 schema 升级）
- D-route 框架 invariants V12-V14 编号正式收编（属于 framework Layer 1 工作 / 与 case 正交）

---

## 2. Decision

### 2.1 升级 schema v0.3 → v0.4（完全向前兼容）

新建独立文档 `extraction-schema-v0.4.md`，v0.3 文档保留为历史 lock 快照不修订。

**用户决策结果（GO-M-ζ / 2026-05-15）**：6.1 选"仅 8 项强推荐进 v0.4 / C-5/C-6/C-9 押后 v0.5"。

**v0.4 增量内容（8 项 lock / 用户 ACK）**：

| 编号 | 变更项 | 类型 | 触发 | 影响范围 |
|------|--------|------|------|---------|
| C-1 | F-004 fundamental_finding lock | 新增 finding 入 schema 文档 | A-020 / Q-027 / GO-J-ε 09 文章 | `_meta.fundamental_findings.F-004` |
| C-2 | F-001 v0.4 三层精细化 lock | 新增字段段 | A-016 + A-017 + Q-029 / GO-K-ε 09 文章 | `_meta.fundamental_findings.F-001._v0_4_精细化` |
| C-3 | Anomaly.scope 增 `cross_form`（命名 ACK 6.5 A）| 取值扩展 | A-019 | `_meta.anomalies_found.scope` |
| C-4 | cross_product 顶层 section schema | 新增 section 类型 | GO-G-γ Phase 1+2 已用 | 顶层 `cross_product_*` |
| C-7 | 跨产品 σ 矩阵字段 schema 化 | 新增字段段 | GO-D-α + GO-G-γ Phase 2 / 09 §6.4 | `_跨产品_σ_矩阵` 字段 |
| C-8 | F-001 中层运筹层多形态字段 | 新增字段段 | A-021 | `F-001._v0_4_精细化.中层._多形态` |
| C-10 | 页型 P12 中药材检验原始记录 | taxonomy 扩展 | GO-G-γ Phase 1 栀子 | 11 类 → 12 类 |
| C-11 | F-004._X2_状态 显式 unresolvable 字段 | 新增字段 | GO-I-ε 用户决定先放着 | `F-004._X2_状态` |

**v0.4 押后清单（3 项 → v0.5 / 用户 ACK）**：

| 编号 | 变更项 | 押后理由 | v0.5 触发条件 |
|------|--------|---------|--------------|
| C-5 | 边界子通道 high_minor / high_extract | 仅 2 候选样本（黄芩苷 + 玄参浸出物 + 石膏边界）/ n 仍小 | case-3 跨产品扩展后或 ≥ 5 边界样本 |
| C-6 | qualitative_LOD 反算形态 | 仅 4 汞样本（A-018）/ Q-034 实验室咨询未完成 | Q-034 实验室咨询返回 + qualitative_LOD ≥ 8 样本 |
| C-9 | ABAB 班次轮值字段 | case-2 specific（仅 1 提取车间 + 2 产品 12 批）/ 跨案例迁移性弱 | case-3 跨车间扩展 + 班次模式实证 |

**F-004 lock 路径（6.4 A ACK）**：直接复制 batch-record.json `fundamental_findings.F-004` 既有内容（~80 行 / 含 F-002_vs_F-004 对比表 + X1 finalize verdict）入 schema-v0.4.md / batch-record.json 内容为权威。

### 2.2 不动的部分

- v0.1 / v0.2 / v0.3 schema 文档：完整保留为 lock 快照
- 既有 batch-record.json 数据：v0.1 / v0.2 / v0.3 字段不变；v0.4 新字段以补充方式追加
- F-002 / F-003 fundamental_findings：内容保留；v0.4 仅增量新增 F-004 + F-001 v0.4
- inventory v0.3：内容沿用（v0.4 schema 不影响 inventory 主分析逻辑）
- F-003 status：保持 finalized_来料检验侧（不动）
- F-004 status：保持 finalized_X1_satisfied（不升级 X2 / X2 unresolvable 显式标）
- 22 物料 + 12 批 + 4 fundamental findings 的既有解读：完整保留

### 2.3 v0.4 升级对 GO-D-α ~ GO-J-ε 已落字段的回溯整合

records-only patch v0.3.1 ~ v0.3.4 期间（2026-05-10 → 2026-05-12 → 2026-05-14）已经在 batch-record.json 中以 candidate / non-locked 方式落了如下字段：

- `fundamental_findings.F-004` 全部子字段（150+ 行 / line 1161-1240+）
- `fundamental_findings.F-001._v0_4_精细化` 全部子字段（line 870-913）
- `cross_product_yanreqing_lotL-mat-07_v0_1` + `cross_product_yanreqing_T_series_v0_1` 顶层 section
- A-015 ~ A-021 anomalies（含 cross_form / cross_product scope）
- Q-029 ~ Q-040 open_questions

本 ADR 把这些字段值正式锁定为 v0.4 schema 的合法定义，**无需重抽数据 / 无需修改既有 records**。

### 2.4 框架抽象产出（D-route §6.2 强制评估）

按 ADR-028 §2.3 Q4 + CLAUDE.md §6.2 "案例服务于框架"原则，本 ADR 必须显式说明对框架抽象的产出（不能纯 case-only）：

✅ **强框架抽象产出**：
- C-3 cross_form scope = `audit_triage` Anomaly.scope 命名空间在 form 间不一致维度的扩展（与 ADR-034 cross_supplier / cross_time_window 同思路 / 案例 invariants 命名空间持续扩展模式实证）
- C-4 cross_product 顶层 section schema = 跨案例数据集结构的工程化模板（D-route Layer 3 多案例集成的 schema 锚点 / 未来 case-3 可复用）
- C-1 + C-2 F-004 + F-001 v0.4 lock = fundamental_findings 跨案例承载结构稳定性实证（schema 不只是字段，更是命题载体）
- C-7 跨产品 σ 矩阵字段 = D-route Layer 2 09 文章 §6.4 "代差量化具体计算"方法论的 schema 化锚点 / 未来案例可直接套用 σ 矩阵格式

✅ **方法论实证产出**：
- ADR-035 是 case-2 第三个正式 ADR（033/034/035）= ADR-pattern 在新领域的持续实证 / 06 文章 v0.2 §8 ADR Template Comparison Pattern 的活体案例
- v0.3 → v0.4 渐进升级（11 项变更 / 完全向前兼容）= ADR-pattern 中 schema versioning 的复用最佳实践

🟡 **case-only 产出**（占比应当受限）：
- C-5 边界子通道候选（high_minor / high_extract）= 仅对 case-2 边界物料有意义（其他案例可能无需）
- C-6 qualitative_LOD = 仅对中药案例有意义（其他案例可能无需）
- C-9 ABAB 班次轮值 = 仅对中药提取车间有强相关（其他案例形态可能不同）

🟢 **D-route §6.2 评估通过**（用户 ACK 后 8 项 lock 范围）：8 项变更中 4 项强框架抽象 (C-3/C-4/C-7/C-1+C-2 部分) + 3 项方法论实证 (C-1/C-2/C-11) + 1 项 case 桥接 (C-8/C-10) / **强框架占比 50% > 案例完成度占比 / 押后 case-only 偏向的 C-5/C-6/C-9 进一步降低耦合 / 通过 D-route §6.2 服务框架优先判定 ⭐**

**押后判断对框架的正向贡献**：用户选择押后 C-5/C-6/C-9 三项 case-only 偏向变更 = D-route §6.2"案例服务于框架"原则的二次实证 / 不堆叠样本不足的字段 = ADR-pattern + 06 文章 §8 ADR Template Comparison Pattern 的"小步迭代"实证。

---

## 3. Consequences

### 3.1 即时影响（用户 ACK 后本 session）

- 起草 `extraction-schema-v0.4.md`（独立文档 / 不覆盖 v0.3）
- 修改 `batch-record.json` `_meta.schema_version` `0.3.4` → `0.4` + `_schema_upgrade_history` 追加 v0.4 条目（**这是 schema 改动 / 需用户 ACK 后才执行**）
- case-2 §10 追加 §10.17 GO-M-ζ 进度日志
- inventory v0.4：不动（v0.3 已涵盖核心设计 / v0.4 增量不影响 inventory）
- STATUS.md L3 行加 "ADR-035 + schema v0.4 lock"
- CHANGELOG 追加 v0.4 lock 行

### 3.2 短期影响（5/15 → 5/31 沉淀期 + 2026-06 起 v0.3 写作）

- A 段 B1 剩余 84 页 OCR（如启动）按 v0.4 schema 输出（含 F-004 + F-001 v0.4 字段）/ 但本 sprint 不启动
- 08 v0.3 完整初稿（ETA 2026-06 起）F-002 vs F-004 对比表可直接引用 schema-v0.4 锚点
- 09 v0.3 完整初稿（ETA 2026-07 起）F-001 v0.4 三层结构可直接引用 schema-v0.4 锚点
- 跨产品扩展（如 case-2.1 P3 / 暂未启动）按 v0.4 schema 输出 / 跨产品顶层 section 已 lock

### 3.3 长期影响（D-route Layer 2 + Layer 3 + 框架抽象）

- D-route Layer 2 文章 v1.0（2026-10 双发布锚点）F-001 + F-004 schema 化引用稳定 / 学界外审时 schema 文档可作为命题严谨性证据
- D-route Layer 3 案例库扩展时 cross_product / cross_form 等 schema 字段可复用
- D-route 框架抽象 Sprint AB 后续若启动，audit_triage 命名空间扩展 + ADR-pattern schema versioning 模式可参考本 ADR
- F-004 命题 lock 后跨案例迁移路径打开（金融 / 教师 / 临床 / 核电等 09 §9.2 跨域案例可显式调用 F-004 框架）

### 3.4 风险与回滚

**风险 1：边界子通道 high_minor / high_extract 仅 2 个候选样本（黄芩苷 + 玄参浸出物 + 石膏边界）**
- n 仍小 / 边界值 ≥30 改 ≥10 决策可能过早
- 缓解：v0.4 把 high_minor / high_extract 标为 candidate 状态 / 待 case-3 跨产品扩展后再调；或本 ADR 决策"先不收 C-5 / 留 v0.5"

**风险 2：qualitative_LOD 仅 4 个汞样本实证（A-018）**
- 跨产品仅 1 个（P2 3 物料 + P1 1 物料）
- 缓解：v0.4 把 qualitative_LOD 标为 candidate 状态 / Q-034 联系实验室确认仪器精度后再升 finalized；或本 ADR 决策"先不收 C-6 / 留 v0.5"

**风险 3：F-004 X2 unresolvable 标记可能影响学界外审**
- 跨企业访谈缺失是 generalizability 短板
- 缓解：F-004._X2_状态 字段含 `_remediation_path`（v0.3 文献综述 / 行业研究文献可补强）+ 09 §11.4 局限性章节明示 / 学界外审时透明承认局限 = 比硬撑伪 generalizability 更稳健

**风险 4：ABAB 班次轮值字段仅P1 + P2 12 批实证（A-015 + A-020）**
- 仅 2 产品 / 1 提取车间 / 仅手工提取工艺
- 缓解：v0.4 把 ABAB 字段标为 case-2 specific（不强制要求其他案例提供）/ 或本 ADR 决策"先不收 C-9 / 留 case-3 跨车间扩展"

**回滚机制**：
- 极端情况：v0.4 升级被"忽略"（不删除 v0.4 文档，但 v0.5 不引用）/ 所有 OCR 回到 v0.3 兼容字段
- batch-record.json 已落字段保留为有效信息（fully_forward_compatible 设计保证）
- v0.4 任何字段如争议 → 标 deprecated 而非删除

### 3.5 与 D-route 战略的对接

本 ADR 是 Case-2 的第三个正式 ADR（继 ADR-033 / ADR-034）。D-route §3.4 跨领域案例机制要求每个案例对框架抽象有产出。本 ADR 的框架抽象产出已在 §2.4 显式列出（强框架占比 36%）。

**与 D-route §6 路线图对接**：
- 2026-10 双文章 v1.0 发布锚点 / F-001 v0.4 + F-004 schema 化是文章引用稳定性的关键
- 2027-01 框架代码抽象 v0.1 release / cross_form / cross_product 等 scope 字段可作为框架案例 invariants 命名空间扩展的活体案例
- 2027-04 第 2 个跨领域案例验证 / cross_product 顶层 section schema 可直接复用于 case-3

**与 ADR-031 v1.0 触发条件评估**：本 ADR 不在 ADR-031 评估范围内（case-2 工作 / 不是 framework 代码工作）/ v1.0 触发条件状态保持 3/7 ✅ + 2/7 ⏳ + 2/7 ❌。

---

## 4. Implementation

| 步骤 | 文件 | 状态 | 触发 / 备注 |
|------|------|------|------|
| 起草本 ADR (ADR-035 draft) | `huadian/docs/decisions/ADR-035-...md` | ✅ 完成 | 用户选 D5（沉淀期并行）+ 5/15 GO-M-ζ |
| 用户审稿决策（6.1/6.2/6.4/6.5 + 6.3 默认 B）| §6 决策点 | ✅ 完成（用户全选推荐）| 8 项 lock + outline 路径 + 复制 + cross_form |
| Status: draft → accepted | 本 ADR 文件头 | ✅ 完成 | 用户 ACK |
| 起草 schema-v0.4.md outline (~50-80 行 / 路径 6.2 B) | `huadian/docs/cases/tcm-extraction/schema/extraction-schema-v0.4.md` | ✅ 完成（本 session）| 详细字段定义留 5/28 后续 session |
| schema_version 0.3.4 → 0.4-outline + history 追加 | `batch-record.json` `_meta` | ⏳ **推迟**（路径 6.2 B / 6.3 B）| 5/28 后 schema 完整起草 session 同步执行 |
| F-004 / F-001 v0.4 / cross_product 顶层 section 字段正式 lock | `batch-record.json` 已落字段维持 | ⏳ **推迟**（路径 6.2 B）| 同上 / batch-record 既有字段维持 records-only patch v0.3.4 状态 |
| case-2 §10 追加 §10.17 GO-M-ζ 进度日志 | `case-2-tcm-manufacturing-evaluation.md` | ✅ 完成（本 session）| finalize 后 |
| STATUS.md L3 + CHANGELOG 更新 | `STATUS.md` + `CHANGELOG.md` | ✅ 完成（本 session）| finalize 后 |

---

## 5. 参考与延伸

- 实证基础（lot-L1 单 lot）：`docs/cases/tcm-extraction/data/incoming-qc/lot-L1-summary-v0.1.md`
- 实证基础（跨 lot 跨物料）：`docs/cases/tcm-extraction/data/incoming-qc/lot-L2-and-auxiliary-summary-v0.1.md`
- 实证基础（6 批跨批 σ）：`docs/cases/tcm-extraction/data/pilot-WK-B1/cross-batch-T-summary-v0.1.md`
- 实证基础（用户访谈 5 题）：`docs/cases/tcm-extraction/data/user-interview-v0.1-go-e-alpha.md`
- 实证基础（跨产品 7 飲片 + 6 批）：`batch-record.json` `cross_product_yanreqing_*` sections
- ADR-033：v0.1 → v0.2 升级（incoming_qc + 3 子通道）
- ADR-034：v0.2 → v0.3 升级（dual_limit 6 类 + P11 + 三维交互 + 时间维度）
- schema-v0.3.md：v0.3 lock 快照（完整保留）
- schema-v0.4.md：本 ADR 同步起草（待用户 ACK）
- batch-record.json：22 records + cross_product 2 sections / 22 anomalies + A-022 候选 / 40 open_questions / **211.7 KB / 7635+ 行**
- 09 文章：`docs/methodology/09-layered-compliance-narrative-pattern.md` v0.2 全本（F-001 v0.4 三层结构 / 4 mermaid / 950 行）
- 08 文章：`docs/methodology/08-dual-reverse-calculation-pattern.md` v0.3 partial（F-002 vs F-004 对比表 / §7.3 学术理论 / 717 行）
- 2026-05 月度日记：`docs/methodology/decision-journals/2026-05.md` v1.0 定版（§4 #4 已标 ADR-035 schema v0.4 lock 为非阻塞 / 中等优先级候选）

### 5.1 v0.4 后下一步触发链

```
v0.4 (本 ADR / 待 ACK) → 沉淀期（5/15 → 5/31）→ 2026-06 起 08 v0.3 完整初稿引用 v0.4 锚点
                                              → 2026-07 起 09 v0.3 完整初稿引用 v0.4 锚点
                                              → 触发 v0.5 候选（C-5 边界子通道 / C-6 qualitative_LOD finalize / 跨产品 case-3 扩展）
                                              → 或触发 D-route Layer 2 文章 v1.0（2026-10 双发布锚点）
                                              → 或触发 D-route Layer 3 case-3 启动（2027-04 锚点）
```

---

## 6. 用户决策点（draft → accepted 前必答）

按 project_instructions"任何对 schema 的实质改动需用户批准"+ CLAUDE.md §5 红线，以下决策点需用户明确选择后才能 finalize：

### 6.1 11 项变更全选 / 部分选择 / 全否决？

| 编号 | 变更项 | 风险 | 推荐 |
|------|--------|------|------|
| C-1 | F-004 fundamental_finding lock | 低 | ✅ 强烈推荐（08+09 文章核心引用）|
| C-2 | F-001 v0.4 三层精细化 lock | 低 | ✅ 强烈推荐（同上）|
| C-3 | Anomaly.scope 增 cross_form | 低 | ✅ 推荐（A-019 已实证）|
| C-4 | cross_product 顶层 section schema | 中 | ✅ 推荐（已用 / 不 lock 数据/文档不同步）|
| C-5 | 边界子通道 high_minor / high_extract | **中-高 / 仅 2 样本** | 🟡 候选 vs 押后 v0.5 |
| C-6 | qualitative_LOD 反算形态 | **中-高 / 仅 4 样本** | 🟡 候选 vs 押后 v0.5 |
| C-7 | 跨产品 σ 矩阵字段 schema 化 | 低 | ✅ 推荐（09 §6.4 已用 / 文章引用稳定）|
| C-8 | F-001 中层运筹层多形态字段 | 低 | ✅ 推荐（A-021 已实证）|
| C-9 | ABAB 班次轮值字段 | 中 | 🟡 推荐 vs 押后（仅 case-2 specific）|
| C-10 | 页型 P12 中药材检验原始记录 | 低 | ✅ 推荐（栀子 16 页已实证）|
| C-11 | F-004._X2_状态 显式 unresolvable 字段 | 低 | ✅ 推荐（透明承认局限）|

### 6.2 schema-v0.4.md 文档起草节奏

- A. 用户 ACK 后本 session 起草完整 schema-v0.4.md（~150-250 行 / 与 v0.3 同量级）
- B. 用户 ACK 后**仅起草 schema-v0.4.md outline**（~50-80 行 / 详细字段定义留 5/28 起更精细 session）
- C. 推迟 schema-v0.4.md / 仅 lock ADR-035 / 等沉淀期后再起草 schema-v0.4.md

### 6.3 batch-record.json _meta 修改窗口

按 CLAUDE.md §5 红线 #2（覆盖已有文件需说明改前改后差异），修改 `batch-record.json` `_meta.schema_version` + `_schema_upgrade_history` 需要用户 ACK 后才执行。建议：

- A. 与 schema-v0.4.md 起草同步执行（用户 ACK 后本 session 完成）
- B. 推迟到 schema-v0.4.md 完整起草后单独 ACK 一次

### 6.4 F-004 fundamental_finding lock 路径

- A. F-004 直接复制 batch-record.json 既有 finding 内容入 schema 文档（保持 batch-record 内容权威）
- B. F-004 在 schema 文档重新精炼（schema 文档为权威 / batch-record 后续与 schema 对齐）

### 6.5 命名争议 — `cross_form` vs `cross_form_consistency`

- A. `cross_form`（与既有 cross_record / cross_batch / cross_product / cross_supplier / cross_time_window 命名一致）
- B. `cross_form_consistency`（更显式表达"form 间一致性问题"语义）

---

## 7. 决策状态

- 本 ADR 状态：**accepted（GO-M-ζ / 2026-05-15 / 用户审稿通过）**
- 用户决策（GO-M-ζ）：6.1 选"仅 8 项强推荐进 v0.4 / 押后 C-5/C-6/C-9 到 v0.5" / 6.2 B（schema outline 路径 / 详细字段留 5/28 后续 session）/ 6.3 默认 B（与 6.2 B 一致 / batch-record.json _meta 修改推迟）/ 6.4 A（复制 batch-record.json 既有 finding 入 schema）/ 6.5 A（cross_form 命名）
- batch-record.json _meta 状态：维持 records-only patch v0.3.4（未升 0.4-outline / 不动 schema_version）/ 待 5/28 后 schema 完整起草 session 同步升级
- v0.5 触发条件（押后 3 项）：见 §2.1 押后清单表 v0.5 触发条件列
- 拒绝 / 重大调整：本 ADR 已 accepted / 任何后续修订需 起 ADR-035-revised 或 ADR-036（视情况）
- v0.4 outline → v0.4 完整 lock 路径（5/28 后续 session）：见 §4 Implementation 表 ⏳ 行

---

> 本 ADR 是 Case-2 第三个正式 ADR（033 / 034 / 035）。后续 Case-2 ADR（ADR-036+）视新触发条件（case-3 启动 / F-005 浮现 / v0.5 schema 升级等）按编号链延续。
> 本 ADR 起草于 GO-M-ζ（2026-05-15）/ D-route §6.2 服务框架优先判定通过 / 沉淀期并行项（D5 选择）/ 不阻塞 5/28 起 2026-06 月度日记节律。
