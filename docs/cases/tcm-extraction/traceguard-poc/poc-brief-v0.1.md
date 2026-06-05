# traceguard E1-E3 真实 PoC — Stage 0 Brief (v0.1)

> **日期**：2026-06-04
> **角色**：管线工程师 + 首席架构师（框架抽象）
> **定位**：D-route Layer 1 框架代码抽象 / case-2 → traceguard 框架抽象产出
> **状态**：Stage 0（brief + 基线）✅ / S1-S5 待执行
> **用户 ACK**：范围 = 全量 E1+E2+E3 + 真跑；E3 = 新增 `EvalTrace.flag_type` 列 + `get_step_stats` 过滤；commit 交用户本地跑（沙箱 .git 只读）

---

## 1. 目标与定位

methodology/08 §9.1（GO-Q-η）给出的是**文章内**的 V12-V14 完整实现设计；archive 第 4 批明确写"E1-E3 扩展点的真实 PoC 代码属 Layer 1 框架工作（不在本文范围）"。**本 PoC 就是补这块被显式 defer 的 Layer 1 工作**：把 §9.1 的设计稿落成 traceguard 真实可跑代码，验证三个扩展点（E1/E2/E3）作为 **generic 能力**成立，并暴露纯设计稿发现不了的扩展点。

核心纪律（C-22 / D-route §6.2 / traceguard CLAUDE.md）：
- **通用能力进 `guardian/` core**，**中药参数进 `configs/examples/tcm_extraction.yaml`**。core 代码**不得出现**中药 / P1 / P2字样。
- 案例服务于框架抽象，不只服务于"让P1 fire 一条 alert"。**首要产出 = E1-E3(±E4) 的 generic 验证**。

---

## 2. 真实代码核对（地基 / 已对 traceguard HEAD 逐行核）

三个扩展点对真实代码确认**都是真缺口**：

| 扩展点 | 真实代码现状（仓库路径） | 缺口确认 |
|--------|------------------------|----------|
| **E1** reverse_calc 检查类型 | `core/config.py::StructuralCheckConfig` 仅 `schema_path/required_fields/max_length/min_length/language` | 无统计反算块 → 真缺 |
| **E2** check 可插拔注册 | `validators/structural.py::validate_structural()` 把 4 个 `_check_*` **硬顺序调用**，无注册表 | 无法按 config 声明启用新 check → 真缺 |
| **E3** suspicion≠failure 语义 | `core/guardian_node.py::evaluate()` structural fail → `_compute_score` 打低 `score` 且 `passed=False`；`store/reader.py::get_step_stats()` 算 `pass_rate = passed/total` | 嫌疑 flag 会污染 `pass_rate`/`avg_score` → 真缺 |

**额外发现（设计稿未覆盖的真实 gap，PoC 核心看点）**：
- §9.1 伪代码 `yields = [t["yield_pct"] for t in prior]`，但 `query_traces()` 返回的 `EvalTrace` **只有 `output_preview`（截断 Text），无结构化标量列**（见 `store/models.py`：id/pipeline_name/step_name/action/passed/score/issues/attempt/output_preview/created_at）。⇒ "stateless × 跨批 σ" 在真实 eval_store 上**不能照搬**。
  - **PoC 解法（推荐）**：`output_preview` 存完整 JSON，V13 从中 `json.loads` 解析 `target_field` 标量序列。
  - 若该解法触及"preview 被截断/非 JSON"边界 ⇒ 登记 **E4 候选 = 结构化输出持久化**（eval_store 增结构化标量列 / 或 metadata JSON 列）。**E4 是真 PoC 才暴露的框架抽象产出**。
- **trivial 修正**：§9.1 伪代码 `output.as_dict()` 的真实方法名是 `output.output_as_dict()`（`core/step.py`）。
- **DEGRADED 成立**：reverse_calc 落 structural 层，`env.py` 无 LLM 进 DEGRADED（structural-only）时照跑 → §9.1 稳健性论断属实。
- **schema 机制**：`TraceReader.__init__` 用 `Base.metadata.create_all()`，**无 Alembic**。⇒ E3 新列：模型加列后新库 create_all 自动获得；既有库（如 traces.db）需**幂等 additive `ensure_schema()`**（`PRAGMA table_info` 检测 + `ALTER TABLE ADD COLUMN`，forward-only / 不 DROP，遵 ADR-017 spirit）。

---

## 3. generic / config 切分

| 进 core（generic / 无中药字样） | 进 config（`configs/examples/tcm_extraction.yaml`，中药专属） |
|-------------------------------|-----------------------------------------------------------|
| E1 `reverse_calc` 子模型 + `_check_reverse_calc` 检测逻辑 | `mode`=F004_sigma_floor / `window_batches`=6 / `target_field`=`yield_pct` |
| E2 check 注册表 + 按名 dispatch | `sigma_floor_pp`=0.5（★ ground truth 来自访谈 Q-027，非常量默认） |
| E3 `flag_type` 列 + `ensure_schema()` + `get_step_stats` 过滤 | `edge_band_pp` / `spec_edges`：`P1 {interval_low, 40.0}` / `P2 {benchmark, 38.3}` |
| 标量回取（解析 `output_preview` JSON） | `on_structural_fail: alert` / `max_retries: 0` / `semantic.enabled: false` |

检测器只认 config 给的 `target_field` / `spec_edges` / `sigma_floor_pp`——换任何"阈值+自填权限"场景（财报压线、KPI 贴标）只改 config 不改 core。

---

## 4. Fixtures

- **正样本（应 fire）**：GO-D-α 真实 6 批 σ 矩阵 —— `yield_pct = [40.27, 40.26, 40.30, 40.28, 40.32, 40.30]`，σ=0.022pp，全贴 40% 规程下限。期望：V13 判 `σ << floor 且 near_edge` → `passed=False` / `action=alert` / `flag_type=suspicion`。
- **负对照（不应 fire）**：自然方差批 —— 如 `[39.1, 41.8, 40.3, 42.5, 38.7, 41.0]`（σ≈1.4pp，未贴边压平）。期望：`passed=True` / 无 suspicion。
- **数据不足（no-op）**：< `window_batches` 批 → `passed=True`，不下结论。
- **σ_floor ground truth**：0.5pp（访谈 Q-027），写进 config，不进 core。

---

## 5. Stage 拆分（已并入用户 ACK 的决策）

| Stage | 内容 | Gate / dogfood |
|------|------|----------------|
| **S0** ✅ | 本 brief + 基线 | **224 tests 全绿**（`uv run pytest`，排除可选 mcp extra）= 回归基线 |
| **S1 — E2** | `validators/structural.py` 引入 check 注册表 + 按名 dispatch；4 旧 check 行为 byte-identical | 224 全绿 + 注册机制新单测 |
| **S2 — E1** | `StructuralCheckConfig` 加 generic `ReverseCalcConfig` 子模型 + `_check_reverse_calc`；解决标量回取（解析 `output_preview`；必要时登记 E4） | 合成单测：低σ贴边 fire / 自然方差不 fire / 数据不足 no-op |
| **S3 — E3** | `EvalTrace.flag_type` 列 + 幂等 `ensure_schema()`；`StructuralResult.flag_type → GuardianDecision → writer.write()` 贯通；`get_step_stats` 把 `flag_type=suspicion` 行排除出 `pass_rate`/`avg_score` 并新增 `suspicion_count` | 单测：suspicion trace 不拉低 `pass_rate` |
| **S4 — 真跑** | 写 `configs/examples/tcm_extraction.yaml`（真 spec 边界 + Q-027 σ_floor）+ seed 真 6 批 σ 矩阵 + `examples/tcm_extraction_poc/` 跑脚本；`guardian check` 端到端 → fire → alert → `generate_suggestions()` advisory；DEGRADED 跑；负对照 | 端到端嫌疑→advisory 闭环截图/日志 |
| **S5 — dogfood + 回填** | 224+新测全绿 + ruff/format clean；写"真 PoC vs §9.1 设计稿"差异报告（含 E4 候选）；回填 08 §9.1（标 PoC-validated）+ case-2 §10.30（待用户审）；出每扩展点一 commit 的命令清单 | 全绿 + 差异报告 + commit 清单 |

执行顺序：E2 → E1 → E3（E1 的 reverse_calc 检查需 E2 的 dispatch 才能被声明启用；E3 的 suspicion 由 E1 检查产生）。

---

## 6. Stop Rules（沿 traceguard 设计约束 + 项目纪律）

1. **generic 红线**：core `guardian/` 任何文件出现中药/P1/P2字样 → 立即停、回退到 config。
2. **dogfood 回归**：任一 stage 后 224 基线 tests 转红且非预期 → 停、修复或上报，不带病推进。
3. **suggest 永不 auto-apply**：advisory 报告仅人工复核（traceguard 硬约束）。
4. **schema 改动需 ACK**：E3 的 `flag_type` 列已获用户 ACK；若 S2 触发 E4（再动 eval_store schema）→ 停、先报用户再动。
5. **σ_floor 是 ground truth 不是常量**：检测阈值取自访谈 Q-027，写 config；不在 core 硬编码默认值掩盖其来源。
6. **沙箱 .git 只读**：不在沙箱 commit；每扩展点一个 commit 的命令清单交用户本地跑。

---

## 7. 决策记录（用户 ACK 2026-06-04）

- **范围深度** = 全量三扩展点 + 真跑（S0-S5 全程）。
- **E3 落地** = 新增 `EvalTrace.flag_type` 列 + `get_step_stats` 过滤（最贴"不污染 pass_rate"原意 / 含 forward-only 幂等 migration）。
- **代码落地** = 真实 traceguard 连接目录；**commit 命令交用户本地跑**。
- **方法论回填**（S5 改 08 §9.1 + case-2 §10.30）= 实质改动，**定稿前先给用户审**（C / 项目纪律）。

---

## 8. 框架抽象产出预期（= 本 PoC 对 D-route 的价值）

1. E1/E2/E3 三扩展点从"文章内设计"升级为"**真实可跑 + 有测试**的 generic 能力" → D-route 2027-01 框架代码 v0.1 release 候选输入。
2. 大概率新增 **E4（结构化输出持久化）** = 真 PoC 才暴露、纯设计稿发现不了的扩展点 → 印证"案例验证框架"的方法论价值（D-route §6.2）。
3. tcm_extraction.yaml = 第 2 个 domain config（与 market_intel.yaml 并列）→ 验证 traceguard "generic system" 跨域可移植性。
