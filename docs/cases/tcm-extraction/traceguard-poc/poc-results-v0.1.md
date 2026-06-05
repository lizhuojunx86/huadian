# traceguard E1-E3 真实 PoC — 结果 + 差异报告 (v0.1)

> **日期**：2026-06-04
> **状态**：S0-S5 全部完成 ✅ / 沙箱 .git 只读 → commit 命令交用户本地跑
> **配套**：[poc-brief-v0.1.md](./poc-brief-v0.1.md)（scope + stage 拆分）
> **代码位置**：traceguard 仓库（generic 进 core / 中药进 configs）

---

## 1. 结论一句话

methodology/08 §9.1 的**文章内设计**（E1-E3 + V13 伪代码）已落成 traceguard **真实可跑代码 + 22 个新测试**，端到端跑通真实 case-2 6 批 σ 信号；并暴露了纯设计稿发现不了的 **E4 扩展点**。三扩展点从"设计"升级为"PoC-validated 的 generic 能力"。

---

## 2. 做了什么（generic 进 core / domain 进 config）

| 扩展点 | core 改动（generic / 无中药字样） | 验证 |
|--------|----------------------------------|------|
| **E2** check 注册/dispatch | `validators/structural.py`：`register_structural_check` + `CheckContext`/`CheckOutcome` + 按名 dispatch；4 旧 check 重注册为 byte-identical | 224 基线全绿 + 6 注册测试 |
| **E1** reverse_calc 检测器 | `config.py`：`ReverseCalcConfig`+`SpecEdge`；`structural.py`：`_check_reverse_calc`（σ-floor + edge-band 通用统计）+ 标量回取（解析 `output_preview`） | 10 检测测试（真 6 批 fire / 自然方差不 fire / 5 类 no-op 边界） |
| **E3** audit-flag 语义 | `models.py`：`EvalTrace.flag_type` + 幂等 `ensure_schema()`；`writer.py`/`reader.py`/`guardian_node.py`/`cli.py`：`flag_type` 全链贯通；`get_step_stats` 把 suspicion 排除出 `pass_rate`/`avg_score`，新增 `suspicion_count` | 6 flag_type 测试（含 forward-only migration） |

domain 参数全在 `configs/examples/tcm_extraction.yaml`（P1 interval_low 40.0 / P2 benchmark 38.3 / Q-027 σ_floor 0.5pp）。

**dogfood**：`246 passed`（224 基线 + 22 新 / 0 回归）。my files `ruff check` 全 clean；whole-tree 15 个 ruff error 为**既有债**（6 个未触碰文件 / 我**零新增**）。

---

## 3. 端到端真跑证据（DEGRADED / 无 LLM）

**正样本**（真实 GO-D-α：yields `[40.27,40.26,40.30,40.28,40.32,40.30]`）：

- 真实 CLI `guardian check` → `action=alert`，issue：`reverse-calc suspicion (sigma_floor) on 'yield_pct': sigma=0.0203 < floor/20=0.0250, mean=40.288 within 1.0 of interval_low edge 40.0 (n=6)`
- `get_step_stats` → `total=6, pass_rate=1.0, avg_score=1.0, suspicion_count=1`（**E3 不污染**：5/5 standard 而非 5/6）
- 嫌疑 trace 落 eval_store / `action=alert`（不 abort / 数据保留 / 永不 auto-apply）= §9.1.7 人工复核 hand-off

**负对照**（自然方差 σ≈1.4pp）→ `action=pass` / 不 fire。

**DEGRADED 确认**：`GUARDIAN_LLM_API_KEY` 未设 / `semantic.enabled=false` / reverse_calc 是 structural 层 → 照常运行。注册器：`['json_schema','required_fields','length','language','reverse_calc']`。

---

## 4. 差异报告：真 PoC vs §9.1 设计稿（= 框架抽象产出）

设计稿是对的，但真跑暴露/修正了 5 点：

1. **★ E4 候选（最重要 / 纯设计稿发现不了）**：§9.1 伪代码 `yields = [t["yield_pct"] for t in prior]` 假设 `EvalTrace` 有结构化标量列。真实 schema 只有 `output_preview`（且 CLI 截断到 **200 字符**）。PoC 解法 = 解析 `output_preview` JSON 回取标量（小批记录可行 / `_extract_field` 对截断/非 JSON 防御式返回 None → 数据不足则 no-op）。**结构化输出持久化 = E4 扩展点**（eval_store 增结构化标量列 / 或 metadata JSON 列），是 D-route 2027-01 框架 v0.1 的新候选输入。
2. **方法名修正**：伪代码 `output.as_dict()` 真名 `output.output_as_dict()`。
3. **mode 去领域化**：设计稿 `mode: "F004_sigma_floor"` → core 用 generic `"sigma_floor"`（core 不得含 F004；F-004 语义在 config 注释）。
4. **字段去单位化**：设计稿 `sigma_floor_pp`/`edge_band_pp` → core 用 `sigma_floor`/`edge_band`（generic core 不假设"百分点"单位；pp 在 config 注释）。
5. **suspicion 通道 ≠ failure 通道**：现有 `suggest`（失败模式分类：语言/长度/字段/schema）无"反算嫌疑"分支，且 DEGRADED LLM 探针在沙箱抛 `RemoteProtocolError`（env.py 仅捕获 `ConnectError` / **既有 gap / 未修 / 属 advisory 层 / 与 E1-E3 正交**）。⇒ suspicion→advisory 宜有**专用 advisory 生成器**（config 驱动领域建议，如"建议现场访谈/多模态采集确证"）。这是 E3 的延伸候选。

**框架红线遵守**：core `guardian/` 零中药字样；通用能力进 core、领域参数进 config 的分离经第 2 个 domain config（`tcm_extraction.yaml` 与 `market_intel.yaml` 并列）验证。

---

## 5. 文件清单（commit 用）

traceguard 仓库：

- 改：`guardian/validators/structural.py`（E2 注册 + E1 reverse_calc）
- 改：`guardian/core/config.py`（`ReverseCalcConfig`+`SpecEdge`）
- 改：`guardian/store/models.py`（`flag_type` + `ensure_schema`）
- 改：`guardian/store/writer.py` / `guardian/store/reader.py`（flag_type 持久化 + 统计 quarantine）
- 改：`guardian/core/guardian_node.py`（reader 贯通 + `GuardianDecision.flag_type`）
- 改：`guardian/cli.py`（reader 贯通 + flag_type 写入 + TraceReader top import）
- 新：`tests/test_check_registry.py`(6) / `tests/test_reverse_calc.py`(10) / `tests/test_flag_type.py`(6)
- 新：`configs/examples/tcm_extraction.yaml`
- 新：`examples/tcm_extraction_poc/`（run_poc.py + README + batches/B6.json）

huadian 仓库：

- 新：`docs/cases/tcm-extraction/traceguard-poc/poc-brief-v0.1.md` + `poc-results-v0.1.md`(本文)

---

## 6. 提议的 backfill（⚠️ 实质改动 / 待用户审，未写入 live 文档）

### 6a. case-2 strategy §10.30（执行日志条目，提议文本）

> ### 10.30 GO-Z-η — traceguard E1-E3 真实 PoC（Layer 1 框架 / case→框架）（2026-06-04 ✅ 完成）
> 把 08 §9.1（文章内设计）落成 traceguard 真实可跑代码。E2 check 注册/dispatch + E1 generic `reverse_calc`（σ-floor + edge-band / 标量回取解析 output_preview）+ E3 audit-flag（`EvalTrace.flag_type` + `get_step_stats` quarantine + 幂等 `ensure_schema`）。真实 6 批 σ 矩阵端到端 fire（CLI `action=alert` / σ=0.0203 / pass_rate 不污染）+ 自然方差负对照不 fire / DEGRADED 跑。dogfood 246 passed（+22 / 0 回归）。**新暴露 E4 候选（结构化输出持久化）= 纯设计稿发现不了 / 框架抽象产出**。generic 进 core / 中药进 configs/examples/tcm_extraction.yaml（第 2 个 domain config）。详见 `docs/cases/tcm-extraction/traceguard-poc/poc-results-v0.1.md`。

### 6b. methodology/08 §9.1（标注，提议文本）

> 在 §9.1 标题后加：**[PoC-validated 2026-06-04]** E1-E3 已在 traceguard 真实架构落地并端到端跑通（见 case-2 traceguard-poc）。真跑修正：`output.output_as_dict()` 方法名；core mode `"sigma_floor"`（去 F004）；core 字段 `sigma_floor`/`edge_band`（去 pp 单位）。**新增 E4 候选（结构化输出持久化）**：`EvalTrace` 仅存 `output_preview`（截断），跨批标量需结构化持久化——纯设计稿未覆盖。

> ⚠️ 因 08 正处 v0.4 审稿周期（§10.28 审稿计划），上述 §9.1 标注是否现在并入、还是并入 v0.4 审稿批次，**请你定**。
