# T-TG-002: TraceGuard Adapter 实现

- **状态**：ready（上游基线就绪 + Q-D1/D2/D5/D6 已决，可开工）
- **主导角色**：管线工程师
- **协作角色**：首席架构师（评审 / 仲裁 Q-D* 待决策点）、后端工程师（审 extractions_history schema）、DevOps（CI 依赖）
- **依赖任务**：
  - T-P0-002（DB Schema 落地 ✅，`llm_calls` / `extractions_history` / `pipeline_runs` 已就位）
  - T-TG-001 物理挂载子任务（**降级为 fallback**，见 §0 与 ADR-004 §E-5；主路径走 git rev pin）
  - ADR-004（TraceGuard 集成合同 ✅，含 2026-04-16 Errata E-1~E-5）
  - TG-STAB-001（上游稳定基线 ✅，2026-04-16 完成）
- **阻塞**：T-P0-005（LLM Gateway + TraceGuard 基础集成）—— 本卡是 T-P0-005 的内嵌前置
- **所属 Phase**：Phase 0
- **创建日期**：2026-04-16
- **创建人**：管线工程师（Claude Opus）
- **调研 notes**：[`docs/research/TG-002-traceguard-upstream-survey.md`](../research/TG-002-traceguard-upstream-survey.md)

---

## 0. 上游基线就绪声明（2026-04-16）

TG-STAB-001 sprint 已完成，上游 `pipeline-guardian` 公开面冻结。Adapter 实现以以下基线为准：

| 项目 | 值 |
|------|----|
| Tag | `v0.1.0-huadian-baseline` |
| SHA | `0350b0a54ec646a96e3f25949b7ce604284c49eb` |
| Repo | `https://github.com/lizhuojunx86/traceguard` |
| CI 证据 | [run 24493213186](https://github.com/lizhuojunx86/traceguard/actions/runs/24493213186)（Python 3.12.13, 237 passed） |
| 公开符号（4 个，0.2.0 前不改） | `evaluate_async` / `StepOutput` / `GuardianConfig` / `GuardianDecision` |
| 翻译规范 | ADR-004 §Errata E-3（两张 Mismatch 表，本卡不再重复） |
| 契约测试要求 | ADR-004 §Errata E-4（3 条防御性断言） |
| 依赖坐标 | ADR-004 §Errata E-5（git rev pin） |

**Adapter 实现硬约束**：

1. 所有上游 import 必须集中到 `services/pipeline/src/huadian_pipeline/qc/_imports.py` 单一文件，仅 re-export 公开 4 符号；任何 deeper import 在该文件内显式注释、自担升级风险。
2. Adapter 翻译逻辑必须以 ADR-004 §E-3 两张 Mismatch 表为唯一规范；如发现表内未覆盖的 case，**先升 ADR-004 errata，再改 Adapter**，禁止 Adapter 单方面"自由发挥"。
3. ADR-004 §E-4 的 3 条契约测试位于 `services/pipeline/tests/qc/test_traceguard_contract.py`，独立于 Adapter 单测，**先于** Adapter 实现编写（test-first）。

---

## 1. 背景

ADR-004 把 TraceGuard 集成定为 Port/Adapter 模式：华典智谱**不绑定 TraceGuard 的现有 API 形态**，而是定义自身所需的 `TraceGuardPort` 协议，由管线工程师写一层 Adapter 桥接当前版本。本任务落地该 Adapter。

2026-04-16 完成对本地 TraceGuard 副本（`/Users/lizhuojun/Desktop/APP/traceguard`，pipeline-guardian 0.1.0）的源码调研。核心发现（详见调研 notes）：

1. **上游包名 `pipeline-guardian`，import 名 `guardian`**（非 ADR-004 / docs/06 写作的 `traceguard`）
2. 上游是配置驱动的 CLI / library（`guardian.core.guardian_node.evaluate_async`），**没有 decorator SDK**
3. 上游**不支持 Python 自定义规则函数**（structural 只有 YAML 硬编码 5 种检查）
4. 上游 action 枚举是 `pass / retry / abort / alert / passthrough`，**没有** `degrade` / `human_queue` —— Adapter 层自实现
5. 上游 semantic 走 httpx 直连 OpenAI 兼容 endpoint，**绕过华典 LLMGateway**（违反宪法 C-7）—— Adapter 强制禁用上游 semantic，改由华典自写 Python 规则走 LLMGateway
6. 上游存储走 SQLAlchemy 单表 `eval_traces`，只存 `output_preview[:200]` —— **不能替代**华典 `llm_calls / extractions_history`；华典审计链走 PG，TraceGuard 自留 SQLite dashboard

**结论**：ADR-004 的 Port 设计完全成立，且 Adapter 量比预期稍大（估 800~1500 行，含测试）。

---

## 2. 目标

在 `services/pipeline/src/huadian_pipeline/qc/` 下落地一套可工作的 TraceGuard Adapter，使上层管线代码可以：

```python
from huadian_pipeline.qc import get_traceguard

tg = get_traceguard()
result = await tg.checkpoint(CheckpointInput(
    step_name="ner_v3",
    trace_id=...,
    prompt_version="ner_v3.json#sha256:abc",
    model="claude-opus-4-6",
    inputs={"paragraph_text": ...},
    outputs={"entities": [...]},
    metadata={"book_id": ..., "paragraph_id": ...},
))

if result.action == "fail_fast":
    raise PipelineAbort(result.violations)
elif result.action == "human_queue":
    await enqueue_for_review(result)
elif result.action == "retry":
    ...
elif result.action == "degrade":
    ...
```

并让审计链（`llm_calls` / `extractions_history`）在每次 checkpoint 时自动写入。

---

## 3. 范围

### 3.1 In scope

1. `traceguard_port.py` — ADR-004 §三 协议原样落地
2. `types.py` — ADR-004 §二 数据结构落地（`CheckpointInput` / `CheckpointResult` / `Violation`）
3. `traceguard_adapter.py` — 桥接 `pipeline-guardian` 0.1.0
4. `rules/` — 首批 ≥5 条 Python 规则（ADR-004 §九）
5. `rule_registry.py` — 规则注册、查询、按 step 路由
6. `policy.py` + `config/traceguard_policy.yml` — action 策略矩阵（ADR-004 §五）
7. `mock_traceguard.py` — 单测用桩（实现 `TraceGuardPort`，不依赖 guardian 包）
8. `tests/` — 单测 + 集成测
9. `services/pipeline/pyproject.toml` — 新增 `pipeline-guardian` 依赖（方式见 §6）
10. 审计写库：Adapter `checkpoint()` 内在 Violation 固化后写 `llm_calls` / `extractions_history`（ADR-004 §六）
11. 文档：`services/pipeline/src/huadian_pipeline/qc/README.md`（面向后续管线工程师）

### 3.2 Out of scope（留给后续任务）

- LLM Gateway 本身（T-P0-005 主体）
- 实际的 NER / Relations / Events prompt（T-P0-006）
- TraceGuard 自带 dashboard 的部署（本地 `guardian serve` 即可，无需容器化）
- TraceGuard 上游源码修改（见 Q-D7）
- 迁移 TraceGuard 存储到 PG（见 Q-D4 / §7 γ2）

---

## 4. 目录结构

```
services/pipeline/src/huadian_pipeline/qc/
├── __init__.py
├── types.py                       # CheckpointInput / CheckpointResult / Violation
├── traceguard_port.py             # Protocol（ADR-004 §三）
├── traceguard_adapter.py          # 具体实现
├── mock_traceguard.py             # 单测桩
├── rule_registry.py               # RuleRegistry + for_step() 路由
├── policy.py                      # ActionPolicy（读 yml + resolve）
├── audit.py                       # 写 llm_calls / extractions_history
├── rules/
│   ├── __init__.py
│   ├── common_rules.py            # json_schema / confidence_threshold
│   ├── ner_rules.py               # surface_in_source / no_duplicate_entities / dynasty_consistency
│   ├── relation_rules.py          # direction_semantic_valid / participants_exist
│   └── event_rules.py             # (Phase 0.5) 占位，留给 T-P0-006 后扩展
├── README.md                      # 规则开发指南 + Adapter 使用说明
└── tests/
    ├── test_adapter.py            # 用 mock 上游测 Adapter 行为
    ├── test_rules_ner.py
    ├── test_policy.py
    └── test_audit.py

services/pipeline/config/
└── traceguard_policy.yml          # ADR-004 §五 策略
```

---

## 5. DoD / 交付物清单

对齐 ADR-004 §九，逐项列可验收条目：

| # | 交付物 | 验收标准 |
|---|---|---|
| 1 | `traceguard_port.py` | Protocol 与 ADR-004 §三字节一致；basedpyright 通过 |
| 2 | `traceguard_adapter.py` | 实现 `TraceGuardPort` 全部方法；基于真实 `pipeline-guardian` 0.1.0；**不调用 TraceGuard semantic**（强制 `semantic.enabled = False`） |
| 3 | `rules/*.py` | 至少 5 条初始规则，覆盖 ner.* / relation.* / common.json_schema / common.confidence_threshold；每条规则独立 unit test |
| 4 | `traceguard_policy.yml` | 默认策略见 ADR-004 §五示例；`by_step` 至少覆盖 `ner_v*` / `relation_v*` |
| 5 | `mock_traceguard.py` | 实现 Port 协议；**零**依赖 guardian 包；供其他管线 unit test 用 |
| 6 | `tests/test_adapter.py` | ≥ 10 条 case：pass / fail / retry / degrade / human_queue / fail_fast / batch / replay / health / shadow-mode |
| 7 | 审计写库 | Adapter 每次 `checkpoint()` 必写 1 行 `llm_calls` + 1 行 `extractions_history`；`traceguard_raw` 字段装 `GuardianDecision.__dict__` |
| 8 | 三元幂等键 | `(paragraph_id, step_name, prompt_version)` 唯一；重入不重复写 `extractions_history`（但重跑 checkpoint 仍允许） |
| 9 | `README.md` | 至少含：如何写规则 / 如何配 policy / 如何在 CI 跑黄金集回归 |
| 10 | CI | `pnpm -C services/pipeline test` 通过；`pnpm lint` / `pnpm typecheck` 通过 |
| 11 | 成本探针 | `CheckpointResult.raw` 包含 `duration_ms`；Adapter 记录 structural/rules/audit 三段耗时，超 50ms 日志 WARN |

---

## 6. 依赖声明方式（Q-D1 / Q-D2 已决，2026-04-16）

> 本节原为待决策点，TG-STAB-001 完成后已敲定。详见 ADR-004 §E-5。

**主方案**（采用）：

```toml
# services/pipeline/pyproject.toml
[project]
dependencies = [
    # TG (TraceGuard / pipeline-guardian) — pinned to v0.1.0-huadian-baseline
    # SHA: 0350b0a54ec646a96e3f25949b7ce604284c49eb
    # CI:  https://github.com/lizhuojunx86/traceguard/actions/runs/24493213186
    # See: docs/decisions/ADR-004 §Errata for translation contract
    "pipeline-guardian @ git+https://github.com/lizhuojunx86/traceguard.git@v0.1.0-huadian-baseline",
]
```

**Fallback**（仅在 CI 无 GitHub 出网权限时启用）：git submodule `vendor/traceguard` + `[tool.uv.sources] pipeline-guardian = { path = "../../vendor/traceguard", editable = true }`。Fallback 路径由 T-TG-001 负责。

**Q-D1 / Q-D2 状态**：
- Q-D1（仓库公开 + CI 可拉取）：✅ 已决 —— 仓库已公开，CI 可直接 `git clone`，主方案启用
- Q-D2（上游发 PyPI 排期）：✅ 已决 —— 不要求，git rev pin 充分

**对 Dockerfile / CI / 本地 `uv sync` 的影响**：
- Dockerfile：`uv sync` 阶段需开放 `https://github.com` 出网；现有镜像无障碍
- CI：GitHub Actions 默认有 `github.com` 访问，无需额外配置
- 本地：`uv sync` 首次会拉 ~2MB 上游仓 + 编译 wheel

---

## 7. 待决策问题一览（2026-04-16 已部分裁定）

| # | 问题 | 状态 | 决议 / 默认方案 | 拍板人 |
|---|------|------|-----------------|--------|
| Q-D1 | 仓库公开性 + CI 拉取 | ✅ **已决** | git rev pin（仓库已公开，见 §6） | 架构师 |
| Q-D2 | 上游发 PyPI 排期 | ✅ **已决** | 不要求，git rev pin 充分 | 架构师 |
| Q-D3 | 禁用 TraceGuard 原生 semantic，华典自写 | ✅ **已决** | 是 —— Adapter 强制 `GuardianConfig.semantic.enabled = False`，避免上游 httpx 直连 OpenAI 绕过华典 LLMGateway（违反宪法 C-7） | 架构师 |
| Q-D4 | TraceGuard 存储独立 SQLite 还是并入 PG | ✅ **已决** | 独立 SQLite —— 上游 `eval_traces` 仅作为 TG 自带 dashboard 的本地数据源；华典审计链走 PG `llm_calls` / `extractions_history`；不强求统一 | 架构师 + 后端 |
| Q-D5 | `alert` → `human_queue` 映射 | ✅ **已决** | 是 —— 见 ADR-004 §E-3 Mismatch #1 | 架构师 |
| Q-D6 | `passthrough` / `pass` 都 → `pass_through` | ✅ **已决** | 是，合并 + warning 日志在 raw 保留区分 —— 见 ADR-004 §E-3 Mismatch #1 | 架构师 |
| Q-D7 | 允许修改上游（加 client 注入钩子等）？ | ✅ **已决** | 否（MVP 不改上游业务逻辑）—— TG-STAB-001 已确立"上游 baseline 安全边界"，所有差异由华典 Adapter 翻译消化 | 架构师 |
| Q-D8 | 首批规则数量 & 覆盖步骤 | open | ≥5 条，ner + relation + common；规则定义待历史专家审 | 架构师 + 历史专家 |
| Q-D9 | TraceGuard 依赖版本冲突 | open | pinning 时实测；上游已通过 Python 3.12 CI 验证，预期无冲突 | 管线工程师 |
| Q-D10 | TraceGuard `StepOutput` 体量上限 | open | 实测 + 必要时 chunk（首段鸿门宴 paragraph 集成测时验证） | 管线工程师 |

**剩余 open 项不阻塞开工**：Q-D8 在 S-4 子任务内回答（编写首批规则时与历史专家协作）；Q-D9 / Q-D10 在 S-2 / S-9 实测中暴露与解决。

---

## 8. 子任务分解（供后续执行参考）

| # | 子任务 | 预估产出 | 依赖 |
|---|--------|----------|------|
| S-1 | 决策 Q-D1~Q-D7（架构师评审） | 评审结论 + 更新本卡 / 补 ADR-004 errata | — |
| S-2 | 挂载 TraceGuard（git submodule or rev pin） | `pyproject.toml` + `uv.lock` + `uv sync` 通过 | S-1 |
| S-3 | types.py + Port + mock | 3 文件 + basedpyright 绿 | S-2 |
| S-4 | 首批 Python 规则 + registry + unit test | `rules/*` + `rule_registry.py` + tests | S-3 |
| S-5 | Adapter 核心 `checkpoint()` | 走通 pass 路径 | S-3, S-4 |
| S-6 | policy.yml + `policy.py` + `_ACTION_MAP` | degrade / human_queue / retry 路径 | S-5 |
| S-7 | 审计写库 `audit.py` + 三元幂等键 | `llm_calls` / `extractions_history` 落盘 | S-5 |
| S-8 | `batch_checkpoint` / `replay` / `health` | 剩余 Port 方法 | S-5, S-7 |
| S-9 | 集成测：跑一段真实鸿门宴 paragraph（mock LLM） | end-to-end 证明通路 | S-6, S-7 |
| S-10 | README + 规则开发指南 + 在本卡回填决策 | 文档提交 | S-1, S-9 |

---

## 9. 验收测试用例（粗纲）

1. **T-01 pass 路径**：一段合法 NER 输出，所有规则通过 → `action = pass_through`，`violations = []`，`llm_calls` + `extractions_history` 各落 1 行
2. **T-02 structural fail**：输出 JSON 缺字段 → TraceGuard 返回 `retry` → Adapter 映射为 `retry`，`retry_hint` 透传
3. **T-03 华典 rule critical**：NER entity 不在原文中 → `surface_in_source` critical violation → 策略矩阵匹配 `ner_v3.critical = [retry, human_queue]` → `action = retry`（attempt=1）→ 第 2 次 `action = human_queue`
4. **T-04 degrade 路径**：`relation_v2` critical + max_retries 用尽 → `action = degrade`（主模型降 sonnet）
5. **T-05 fail_fast**：所有路径用尽 → `action = fail_fast`，Adapter 抛 `PipelineAbort`
6. **T-06 shadow mode**：`mode=shadow` 下 critical violation 仍返回 `pass_through`，但 audit 记 `shadow_violation=True`
7. **T-07 幂等**：重复调用 `checkpoint` 同 `(paragraph_id, step, prompt_version)` → `extractions_history` 不重复落
8. **T-08 batch**：10 段并发 `batch_checkpoint`，并发度受限（信号量）
9. **T-09 replay**：按 trace_id 重跑，input/output 从 `extractions_history` 读取
10. **T-10 health**：返回 `{ok: True, tg_version: "0.1.0", rules_loaded: N, pg: "ok"}`

---

## 10. 风险

| # | 风险 | 缓解 |
|---|------|------|
| R-1 | 上游 API 不稳定（0.1.0 无语义版本承诺） | Adapter 层隔离 + 集成测回归 + rev pin |
| R-2 | 性能不达标（> 50ms/checkpoint） | 结构化轻量路径走热路径；heavy rules 走 sampling；超限日志告警 |
| R-3 | TraceGuard 依赖拖累 pipeline 镜像体积（fastapi / uvicorn 传递依赖） | library 路径实际只需 pydantic / jsonschema / sqlalchemy / pyyaml；Docker 层面裁剪；必要时 push 上游做 `optional-dependencies` 拆分（Q-D7） |
| R-4 | SQLite `traces.db` 在多机开发机不一致 | `.gitignore` + `data/traceguard.db` 定向；CI 跑时用 `:memory:` |
| R-5 | Q-D1 决策延迟 | 先走 β 本地 path，切 γ 只需改 `pyproject.toml` 一行 |

---

## 11. 相关链接

- ADR-004 TraceGuard 集成合同 + Errata（含两张 Mismatch 表 + 契约测试要求 + 依赖坐标）：[`docs/decisions/ADR-004-traceguard-integration-contract.md`](../decisions/ADR-004-traceguard-integration-contract.md)
- 原集成方案（v1，已被 ADR-004 部分取代）：[`docs/06_TraceGuard集成方案.md`](../06_TraceGuard集成方案.md)
- 调研 notes：[`docs/research/TG-002-traceguard-upstream-survey.md`](../research/TG-002-traceguard-upstream-survey.md)
- 管线工程师定位：[`.claude/agents/pipeline-engineer.md`](../../.claude/agents/pipeline-engineer.md)
- **上游公开仓库**：https://github.com/lizhuojunx86/traceguard
- **上游冻结基线**：[`v0.1.0-huadian-baseline`](https://github.com/lizhuojunx86/traceguard/releases/tag/v0.1.0-huadian-baseline) @ `0350b0a54ec646a96e3f25949b7ce604284c49eb`
- **上游 CI 证据**：[Actions run 24493213186](https://github.com/lizhuojunx86/traceguard/actions/runs/24493213186)
- 上游本地副本（开发参考）：`/Users/lizhuojun/Desktop/APP/traceguard`
- 依赖任务：T-P0-002 ✅ / TG-STAB-001 ✅ / T-TG-001（物理挂载）已降级为 fallback

---

## 12. 本卡的下一步

1. ~~本卡状态 = review~~ → **本卡状态 = ready（2026-04-16）**：架构师已就 Q-D1~Q-D7 拍板，结论入 ADR-004 §Errata E-1~E-5；上游已冻结 `v0.1.0-huadian-baseline`
2. **管线工程师按 §8 子任务顺序开工**，建议第一刀切：
   - S-2：写依赖（ADR-004 §E-5 坐标，一行 `pipeline-guardian @ git+...@v0.1.0-huadian-baseline`）+ `uv sync` 验证拉得到
   - 同时新建 `services/pipeline/tests/qc/test_traceguard_contract.py` 把 ADR-004 §E-4 的 3 条契约测试**先写出来**（test-first）—— 这 3 条会立刻红，因为还没有 Adapter，但保证 Adapter 实现完后这 3 条必须绿
3. 各子任务完成后逐项更新 §5 DoD 勾选状态，CHANGELOG 留痕
4. 全部子任务完成后，本卡转 `done`，T-P0-005 解除阻塞
