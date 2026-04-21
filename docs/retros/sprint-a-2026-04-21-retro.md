# 架构师复盘纪要 — Sprint A（T-P0-019 α β 尾巴清理 + V8 invariant 引入）

- **日期**：2026-04-21
- **任务**：T-P0-019 三阶段尾巴清理（V6 零化 / F1 代词硬 DELETE / F2 短名处置）
- **结果**：完成，三阶段全绿；产生两条新 ADR（022 / 023），不变量集扩至 V1-V8
- **成本**：$0 LLM（纯数据+规则工程）+ 2 次架构深度介入（Stage 2 三要素判定 + Stage 3 pivot to V8）
- **工时分布**：预估 2h → 实际 ~5h（Stage 3 pivot + ADR 起草 + ADR-022 首次应用校准占 3h）
- **产物**：6 commits（+1 本次 closure）、2 条新 ADR、1 条新 invariant（V8）、3 条 debt closed、1 条 debt opened

---

## 1. 原计划 vs 实际执行

原计划 3 步："修 V6 28 行 → 删 F1 代词 6 行 → 删 F2 短名 3 行"。

实际执行：

- **Stage 1**：架构师原指令 `SET is_primary = false`；工程师 Gate 0b 发现 28 行 TYPE-B 本就应为 primary（alias 分类错误）→ 改 `SET name_type = 'primary'`。**工程师 SQL 精化 PK 架构师原指令，且对 V6 等价**。
- **Stage 2**：按计划 6 行硬 DELETE，但这是**首次在项目中硬 DELETE person_names 行**，需要先立 ADR-022 才能走 → 起草 ADR-022（NER 污染清理三要素 AND + Gate 0-4 协议），立完再执行。
- **Stage 3**：原按 F2 假设计划硬 DELETE 3 行；ADR-022 三要素审计触发：3 行全部 `source_evidence_id IS NOT NULL` → 条件 #1 不满足 → **不适用硬 DELETE**。
  - 改方向：审这 3 行的原文上下文，确认为合法古汉语 anaphoric short-form（《尚书·舜典》§15 立名后"伯"短形回指 / 《史记·周本纪》"管蔡畔周"并列缩略）
  - 改产出：起草 ADR-023 + 落 V8 invariant + self-test，防御未来同类污染回归
  - 改结果：**0 DELETE / 0 数据变更 / +1 新不变量**

每次"scope 膨胀"都不是任务本身的目标扩大，而是**原计划的假设在 Gate 0b 审计下被证伪**，项目用这个机会把"应该先有规则"这件事补上。

---

## 2. 关键判例

### J1: ADR-022 首次应用即挡住错误 DELETE（Stage 3）

Stage 3 原计划 DELETE 3 行时，ADR-022 刚在 Stage 2 起草完毕。Gate 0b 审计按三要素跑，第一条（Evidence 链零依赖）直接不过——3 行 `source_evidence_id` 全部非空。

如果没有 ADR-022，按"F2 假设"硬删，会删掉 3 条**合法的古汉语别名**。ADR 在第一次应用时就自我校准，这是"不做空头 ADR"的证据：ADR 不是事后总结，是**作为防御层存在的规则本身**。

### J2: V8 α/β OR 豁免 vs ADR-022 三要素 AND 的哲学共通

- **ADR-022（清理向）**：evidence 零依赖 AND 非合法名 AND FK 零引用 → 硬 DELETE
- **ADR-023（防御向）**：evidence 非空 OR name_type=alias → 豁免 V8 违反

两者表面相反（AND vs OR），但共享同一哲学：**evidence 链是合法性的客观信号**。
- 清理时，evidence 非空 = 即使看起来像污染也不删（误删代价 >> 保留代价）
- 防御时，evidence 非空 = 即使结构像 prefix-containment 也放过（单一维度可自证合法）

这不是偶然对称，是"evidence 作为 ground truth"这个宪法级原则在两个方向上的具象化。Phase 1 之后如果 evidence 不再是最可靠信号，两条 ADR 都需要一起修订。

### J3: 工程师的 SQL 精化（Stage 1）是良性越位

架构师指令 "UPDATE SET is_primary = false"，工程师 Gate 1 pre-state 审计发现 28 行本就该是 primary（分类错，不是状态错），改 "UPDATE SET name_type = 'primary'"。

这在边界上属于"工程师选了实现路径"，但：
- 两条 SQL 对 V6 等价（`name_type != 'alias' OR is_primary = false` 都能让 V6 = 0）
- 工程师的路径更符合数据真实语义（降格为合法 primary，而不是"强制变非主名"）
- 工程师在 Stage 1 完成报告里主动告知架构师 SQL 变更

→ 记为良性越位。纠偏方式：架构师未来在下达 Stage 1 类指令时，应在任务卡里说明"架构目标是 V6 = 0，执行路径交工程师基于 Gate 1 pre-state 选择"，而不是直接下 SQL。

---

## 3. 不变量演化的里程碑

Sprint A 把不变量集从 V1-V7 扩到 V1-V8，并确立了**两条新的治理规则**：

1. **V8 与 V1-V7 同级（非 TraceGuard sample-based QC）**：prefix-containment 的未来污染必须**当次被抓**，不能等 QC sweep。self-test 强制保证检测路径活性。
2. **Invariant 豁免必须走 evidence 链**：V8 的 α/β 豁免是第一条明文依赖 `source_evidence_id` 的 invariant 规则。这把 T-P0-024 α 投入的 evidence 覆盖成果（V7 96.37%）**转为可消费的治理资产**——evidence 不再只是展示字段，是规则的输入。

**后续 invariant 设计原则**：新 invariant 若要做例外豁免，首选 evidence-backed + semantic-typed 双信号 OR 组合，避免强制 AND（会误伤"只被分类未被回填"的合法行）。

---

## 4. 副产品：T-P1-021（canonical merge missed pairs）

V8 probe 暴露 `管叔 vs 管叔鲜` / `蔡叔 vs 蔡叔度` 是两组应被 canonical merge 的遗漏。这条债不属于 Sprint A 范围，登记 T-P1-021 由 ADR-014 execution model 在下个 canonical merge 周期覆盖。

**方法论意义**：V8 SQL 作为 probe 顺手发现的问题，比专门写 audit 脚本去查 canonical merge 遗漏**更自然**。未来 invariant 设计应主动考虑"probe 出的副产品是否有价值"——defense in depth 顺便 audit。

---

## 5. 遗留 / 建议

### 5.1 遗留不处理（非 Sprint A 范畴）

- **V7 残余 ≈13 names**：7 短名夏王（T-P1-015 scope 部分 = T-P1-016）+ 2 微子 + 4 misc。Sprint A 不触（已从 96.37% 推到 97.49% 达标，更上一层需 ingest 覆盖）。
- **F12 residual（11 行 primary + is_primary=false）**：W2 路径遗产，P2 优先级，不在本 Sprint 范畴。

### 5.2 建议下一步

候选顺序（推荐度↓）：

1. **T-P0-025 字典加载器**（基于 ADR-021 open-data-first + Wikidata TIER-1）：本 Sprint 并行立的 ADR-021 有配套任务待启动，Phase 0 字典扩充是 Phase 1 产品能力的前置。
2. **T-P1-021 canonical merge missed pairs**：V8 probe 副产品，走 ADR-014 execution model 即可，规模小（2 组）。
3. **T-P0-005a SigNoz 接入**：可观测性基建补齐，为 Phase 1 上线做准备。
4. **T-P0-004 批次 2 字典扩展**：历史专家主导，秦汉二线人物 + 封国 / 战役地，非阻塞项。

架构师推荐 **T-P0-025 字典加载器**：ADR 已立，工程师熟悉上下文（刚完成 V8 实现，同一工作流），路径短收益大。

### 5.3 流程改进

- **Stage 指令交付格式**：架构目标与 SQL 实现路径应分开表达（参见 J3），避免工程师 Gate 1 发现 pre-state 与假设不符时需要被动反推。
- **ADR 起草时机**："需要硬 DELETE"这类首次出现的破坏性操作，应在 Gate 0 之前完成 ADR 起草 + Gate 0c 加入 ADR 约束审计，本 Sprint Stage 2 是 Gate 0 期间才起草 ADR-022，时序上**险过**。
- **Sprint 命名规范**：本 Sprint 事后命名 "Sprint A"，前期只有任务 ID 无 Sprint 名。建议未来多阶段任务开 Sprint 前先定名（Sprint A / B / C 或按主题）。

---

## 6. 成本与产出对账

| 维度 | 数值 | 备注 |
|------|------|------|
| Commits on main | 6 | 5639868 / b986891 / af7581d / 7629726 / 2dd53c9 / （本次 closure） |
| pg_dump anchors | 2 | Stage 1 前 + Stage 2 前 |
| LLM 成本 | $0 | 纯数据+规则工程 |
| 新 ADR | 3 | ADR-021（并行）+ ADR-022 + ADR-023 |
| 新 invariant | 1 | V8 prefix-containment |
| 新 pipeline tests | 3 | V8 self-test（282 pass） |
| Debt closed | 3 | T-P1-013 / T-P1-014 / T-P1-015 |
| Debt opened | 1 | T-P1-021 |
| V6 violations | 28 → 0 | ✅ 转绿 |
| V7 机械性 | 96.37% → 97.49% | +1.12pp（分母 524→518） |
| V8 violations | — → 0 | 生产数据无违反 |

---

## 7. 给后续会话的 hand-off 提示

- **ADR-022 / ADR-023 是活 ADR**：下次再遇到"看起来像污染"的单字人名或短名，先按 ADR-022 三要素跑 Gate 0b 审计，不要假设需要 DELETE。
- **V8 是 CI 硬门**：新 ingest 完成后，除 V1-V7 外必看 V8；若 V8 报违反，优先查 α/β 豁免是否真的都不满足，而不是直接删行。
- **evidence 链是规则输入**：未来任何 invariant 设计如需豁免，优先考虑 evidence-backed OR semantic-typed 组合。
- **T-P0-024 α 的 V7=96.37% 成果被本 Sprint 消费**：V7 不只是指标，是 V8 豁免规则的输入；evidence 覆盖率低的年代，V8 会误伤更多合法别名——这是 Phase 0 前期不急着上 V8 的原因之一，也是 Sprint A 能落地 V8 的前提。

---

> Sprint A 标志 Phase 0 数据治理层从"修具体违反"过渡到"立规则+自动防御"。后续 Sprint 推荐优先完成 ADR-021 对应的工程化（T-P0-025），让字典层接住 Phase 1 的产品需求。
