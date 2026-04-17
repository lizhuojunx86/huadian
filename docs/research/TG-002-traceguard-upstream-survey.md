# TG-002 · TraceGuard 上游调研 Notes

> 配套任务卡：[`T-TG-002-traceguard-adapter.md`](../tasks/T-TG-002-traceguard-adapter.md)
> 调研时间：2026-04-16
> 调研人：管线工程师（Claude Opus）
> 被调研仓库：`/Users/lizhuojun/Desktop/APP/traceguard`（本地副本，非 git submodule 挂载）
> 被调研版本：`pyproject.toml` 声明 `pipeline-guardian 0.1.0`（未发布到 PyPI，git HEAD @ 2026-04-06）

---

## 0. TL;DR

1. TraceGuard 的**对外包名是 `pipeline-guardian`，Python import 名是 `guardian`**（ADR-004 / docs/06 中写作 `from traceguard import ...` 的代码样例需按实际 import 修订）。
2. TraceGuard 是**"配置驱动的 CLI / 轻量 library"**，不是 decorator SDK。`docs/06 §二` 的 `@Checkpoint(...)` 装饰器**不存在**，那是架构文档的构想稿。
3. TraceGuard 对外暴露两个可用入口：
   - Python library：`guardian.core.guardian_node.evaluate(...)` / `evaluate_async(...)`
   - CLI：`guardian check --pipeline X.yaml --step Y --input Z.json --db URL`
   - 另有 FastAPI dashboard 和 MCP server，但不是管线运行时入口
4. TraceGuard 当前**不支持 Python 自定义规则函数注册**，structural 规则只有 YAML 声明式（schema / required_fields / length / language）；semantic 规则是 LLM-as-Judge。
5. TraceGuard 的 action 枚举是 **`pass / retry / abort / alert / passthrough`**，与 ADR-004 的 `pass_through / retry / degrade / human_queue / fail_fast` **不 1:1 对应**。`degrade` 与 `human_queue` 必须由华典 Adapter 层自行实现。
6. 存储走 SQLAlchemy ORM（默认 `sqlite:///traces.db`，理论上可切 Postgres，待验证 migration 策略）。
7. **结论：ADR-004 的 Port/Adapter 选型完全成立**。华典侧的 "Python 函数规则 + 动作编排 yml + Postgres 审计表" 必须由 Adapter 自建；TraceGuard 在 Adapter 中扮演的角色是"结构化 / 语义化评估引擎 + 自家 trace store（可选）"。

---

## 1. 仓库全貌

```
/Users/lizhuojun/Desktop/APP/traceguard/
├── guardian/                   # 真正的 Python 包（pyproject.toml wheel target）
│   ├── __init__.py             # 空
│   ├── cli.py                  # click CLI：check / suggest / serve / mcp
│   ├── env.py                  # 环境探测、endpoint 缓存
│   ├── mcp_server.py           # MCP (stdio) 入口
│   ├── core/
│   │   ├── config.py           # Pydantic 配置模型（PipelineConfig / StepConfig / GuardianConfig）
│   │   ├── guardian_node.py    # evaluate / evaluate_async（核心校验循环）
│   │   └── step.py             # StepOutput（把 JSON/文本 文件包装为 evaluate 入参）
│   ├── validators/
│   │   ├── structural.py       # JSON Schema / required_fields / length / language
│   │   └── semantic.py         # LLM-as-Judge（httpx 调 OpenAI-compatible endpoint）
│   ├── actions/alert.py        # Telegram bot 告警
│   ├── store/
│   │   ├── models.py           # SQLAlchemy：EvalTrace（单表）
│   │   ├── writer.py           # TraceWriter
│   │   └── reader.py           # TraceReader（供 suggest + dashboard 用）
│   ├── api/                    # FastAPI dashboard + REST
│   └── optimizer/              # suggest 子命令：root cause + suggestions
├── src/                        # 只有一个空 __init__.py（历史残留）
├── configs/examples/           # market_intel.yaml 等示例
├── tests/                      # pytest 套件
├── scripts/                    # 运维小脚本
├── main.py / debug_llm.py / analyze_pipeline.py / collect_traces.py / import_*.py
│                               # 独立工具脚本（与 library 解耦）
├── traces.db / *.db            # 本地 SQLite 数据库（含备份和 QR 版本）
└── pyproject.toml              # 声明包名 pipeline-guardian，scripts = { guardian, guardian-mcp }
```

### pyproject 要点

- 包名：`pipeline-guardian`，wheel target `packages = ["guardian"]`
- 可执行入口：`guardian = "guardian.cli:main"`，`guardian-mcp = "guardian.mcp_server:main"`
- Python 最低：3.11+（**华典 pipeline 子包当前是 3.12，兼容**）
- 依赖：pydantic / jsonschema / httpx / pyyaml / sqlalchemy / click / fastapi / uvicorn
- 未发布 PyPI（`version = "0.1.0"`）

---

## 2. 核心 API 精读

### 2.1 `evaluate_async`（最贴近 Port.checkpoint 的入口）

```python
# guardian/core/guardian_node.py
async def evaluate_async(
    output: StepOutput,
    config: GuardianConfig,
    attempt: int = 1,
    http_client: httpx.AsyncClient | None = None,
) -> GuardianDecision: ...
```

**观察**：
- 入参是 `StepOutput`（包裹单个文件内容 + 文本/JSON 判定）+ 一个**已实例化**的 `GuardianConfig`（不支持按 `step_name` 动态路由规则集）。
- 返回 `GuardianDecision`：`{action, issues: list[str], score: float 0-1, retry_hint, semantic_score: 1-5 | None, semantic_status}`。
- `issues` 是人类可读字符串列表，**没有 rule_id / severity / location 结构**——ADR-004 `Violation` 的字段在上游全部缺失。
- 重试语义是"**调用方负责再次调用**"：`_resolve_action` 里若 `attempt >= max_retries` 自动升格为 `abort`；没有内置的 retry 循环，也没有 backoff。
- Semantic check 自带 httpx 直连 OpenAI 兼容 endpoint，**不走华典的 LLMGateway**——重复付费 / 缺审计 / 绕过 TraceGuard 宪法 C-7 的风险点，Adapter 必须拦截。

### 2.2 `GuardianConfig`（YAML 模型）

```python
class GuardianConfig:
    structural: StructuralCheckConfig  # schema / required_fields / min_length / max_length / language
    semantic:   SemanticCheckConfig    # enabled / model / api_base / api_key_env / criteria / min_score
    actions:    ActionConfig           # on_structural_fail / on_semantic_low / max_retries / retry_hint / alert_channel
```

**观察**：
- 规则表达力有限：结构层只有 5 种硬编码检查。
- 没有"规则组合（AND/OR/NOT）"/"按 severity 分级"/"自定义规则函数"的钩子。
- `ActionConfig.on_structural_fail` / `on_semantic_low` 只能取 `retry / abort / alert / passthrough` 四值。
- 不支持 "sampling rate"、"shadow / enforce / off 环境切换"——完全由调用方实现。

### 2.3 `evaluate`（同步版）

- 内部用 `asyncio.run` 调 `validate_semantic`——**不能在已运行的 event loop 中直接调**（有 fallback 但不稳）。Adapter 应只用 `evaluate_async`。

### 2.4 持久化（`guardian/store/models.py`）

```python
class EvalTrace(Base):
    __tablename__ = "eval_traces"
    # id / pipeline_name / step_name / action / passed / score /
    # issues (JSON as Text) / attempt / output_preview / created_at
```

**观察**：
- **单表 schema**，无 per-trace input/output/prompt/model 字段——**无法直接替代华典侧的 `llm_calls / extractions_history` 审计表**。
- 只记 `output_preview` 前 200 字符，原始数据必须由华典自己写 `extractions_history.raw_output` + `extractions_history.traceguard_raw`。
- SQLAlchemy engine 用 `sqlite:///` 前缀，理论支持 Postgres（`postgresql+psycopg://...`），但未见相关测试；迁移策略是建表时 `Base.metadata.create_all()`——与 Drizzle 托管的 `services/api` 迁移体系会撞表名和 migration blame。**建议 TraceGuard 维持独立 SQLite，只做 dashboard；华典审计链走 PG 自有表。**

### 2.5 CLI 子进程路径

`guardian check ...`：冷启 Python + 加载 YAML + 实例化 pydantic + 调 evaluate + 写 DB，**单次 > 500ms**（未实测），不适合管线内每段落调用。Adapter 选 library 模式。

### 2.6 MCP 与 dashboard

- MCP 用于把 guardian 暴露给 Claude Desktop / Cursor（外部 agent 工具调用），**不是**华典管线的运行时依赖。
- FastAPI dashboard (`guardian serve`) 可以保留给运维观察自家 trace.db。

---

## 3. ADR-004 Port 契约 vs. TraceGuard 上游实际能力

| Port 方法 / 字段 | TraceGuard 0.1.0 现状 | Gap 程度 | Adapter 承担 |
|---|---|---|---|
| `async checkpoint(CheckpointInput) -> CheckpointResult` | 有 `evaluate_async(StepOutput, GuardianConfig, attempt)` | 接口小差 | 入参映射：把 `CheckpointInput.outputs` 序列化成 `StepOutput`；`step_name` → 动态选 GuardianConfig |
| `CheckpointResult.violations: list[Violation]`（带 rule_id / severity / location / suggested_fix） | `issues: list[str]` 只有文本 | 🟥 大 | Adapter 自写规则，产出结构化 Violation；TraceGuard issues 统一包成 `Violation(rule_id="tg.structural.*", severity="major")` |
| `CheckpointResult.action: pass_through/retry/degrade/human_queue/fail_fast` | `action: pass/retry/abort/alert/passthrough` | 🟥 大 | 策略表映射 + 华典 `traceguard_policy.yml` 叠加 `degrade / human_queue` 逻辑（TraceGuard 不感知） |
| `CheckpointResult.score: float 0-1` | 同（structural 0.4 + semantic 0.6 加权） | ✅ 一致 | 直接透传 |
| `CheckpointResult.duration_ms: int` | 无 | 🟨 小 | Adapter 自计 |
| `CheckpointResult.raw: dict` | 无直接返回，但可以把 `GuardianDecision.__dict__` 放进去 | ✅ 简单 | Adapter 透传 |
| `async batch_checkpoint(list[...])` | 无原生 batch | 🟨 中 | Adapter 并发跑 `evaluate_async`（`asyncio.gather` + 信号量） |
| `register_rule(rule_id, rule_fn, severity)` | **无**（YAML 硬编码） | 🟥 大 | Adapter 自建 registry；TraceGuard 只跑结构/语义 |
| `register_rule_bundle(bundle_path)` | 无 | 🟥 大 | Adapter 扫描目录导出 `RULES` 列表 |
| `async replay(trace_id)` | 仅 `suggest` 可回放失败模式，不能重跑 checkpoint | 🟥 大 | Adapter 需持久化完整 `CheckpointInput`，按 trace_id 重跑 |
| `health()` | 有 `/api/health` FastAPI 路由，但 library 内无 | 🟨 小 | Adapter 自建（检查 TraceGuard 版本 + rule_count + PG 连通） |
| `mode: enforce/shadow/off` | 无 | 🟨 中 | Adapter 层封装 |

**总结**：Port 的"协议形状"在上游不存在；Adapter 的净代码量会比最初设想稍多（估 800~1500 行，含测试）。**但 ADR-004 的解耦收益没有改变**——如果改绑定上游 API，ADR-004 §八 第 1、3、5、6、7 项就得全部依赖 TraceGuard 未来功能排期。

---

## 4. 三种集成路线对比

| 路线 | 描述 | 优点 | 缺点 | 推荐 |
|---|---|---|---|---|
| **A. Library 直 import** | TraceGuard 作 Python 依赖，Adapter 直接 `from guardian.core.guardian_node import evaluate_async` | ① 零 IPC 开销；② 可直接传 async httpx client 复用连接池；③ 调试栈清晰 | ① 版本强耦合（TraceGuard 改 API 要升 Adapter）；② 需要发布 / 本地 path 依赖 | ✅ **推荐（MVP）** |
| B. 子进程 CLI | `subprocess` 调 `guardian check ...` | ① 隔离；② 版本升级只需换 bin | ① 每次冷启慢；② 大批量跑批 CPU 炸裂；③ 难传复杂 context | ❌ |
| C. 独立 HTTP 服务 | `guardian serve` + 新写一个 REST check endpoint | ① 完全解耦；② 便于多租户 | ① TraceGuard 当前**没有** POST `/check` 端点（仅 GET /api/*）；② 需改上游；③ 网络开销 | ❌（未来 Phase 3 商业化再评估） |

**选 A**。依赖声明方式三选一（详见 §5）。

---

## 5. 依赖声明方式（待决策点 D-1）

### 选项 α：git submodule
```
vendor/traceguard/   # submodule
# pipeline/pyproject.toml:
[tool.uv.sources]
pipeline-guardian = { path = "../../vendor/traceguard", editable = true }
```
- 优点：版本锁 SHA；不需要上游发布
- 缺点：开发者要多一步 `git submodule update`；Dockerfile 需多加 clone 步骤

### 选项 β：`tool.uv.sources` 直指本地绝对 path
```
[tool.uv.sources]
pipeline-guardian = { path = "/Users/lizhuojun/Desktop/APP/traceguard", editable = true }
```
- 优点：零改动
- 缺点：非开发者机器跑不起来；CI 不可复现；**否决**

### 选项 γ：git url
```
[tool.uv.sources]
pipeline-guardian = { git = "https://github.com/lizhuojunx86/traceguard.git", rev = "<sha>" }
```
- 优点：无需 submodule；CI 友好；锁 rev 可复现
- 缺点：上游必须公开或配 SSH key；仓库重命名后 rev 失效

**建议**：默认走 γ（git url + SHA pin），CI 用 https + deploy key；开发机可 override 为 β 以便热改 TraceGuard。submodule 不推荐（心智负担高）。

**需要用户 / 架构师决定**：
- Q-D1：TraceGuard 仓库是否已公开？是否允许华典 CI 拉取？
- Q-D2：是否接受"TraceGuard 下 sprint 内发 PyPI 0.2.0"？若发，直接走 `pipeline-guardian = "^0.2.0"`（最清爽）。

---

## 6. Semantic evaluation 与华典 LLMGateway 的冲突（待决策点 D-2）

`guardian/validators/semantic.py` 内部用 `httpx.AsyncClient().post(api_base + "/chat/completions", ...)` 直连 LLM，绕过了华典的：
- 宪法 C-7（无黑盒 LLM 调用）
- `llm_calls` 审计表
- TraceGuard 策略矩阵（sampling / cost cap / 降级）

**选项**：
- β1：Adapter **禁用 TraceGuard 原生 semantic**（`semantic.enabled = False` 始终强制），华典自写 LLM-as-Judge 规则（作为 Python 规则函数，走 LLMGateway）
- β2：魔改 TraceGuard，把 `httpx.AsyncClient` 注入点抽出来，让华典传一个"调 LLMGateway 的假 client"进去——需改上游
- β3：先接受重复调用，Phase 2 再优化

**推荐 β1**。原因：①架构干净；②一个"LLM-as-Judge"规则作为 Python 函数可用到各种 step 而非绑定 TraceGuard 配置层；③避免绕过审计表。**TraceGuard 在华典这里的定位就缩窄为"结构校验 + 动作编排协议统一"**，LLM 质检完全由华典方主控。

---

## 7. 存储与迁移冲突（待决策点 D-3）

两种模式：
- γ1：TraceGuard 维持独立 SQLite（`services/pipeline/data/traceguard.db`），dashboard 继续用
- γ2：把 TraceGuard 指到华典的 PG（`postgresql+psycopg://huadian:...`），`eval_traces` 表与华典业务表共库

γ2 的问题：
- TraceGuard 建表走 `Base.metadata.create_all()`，**不会**跑 Drizzle migration；`eval_traces` 会成为 Drizzle 不认识的"外部表"，后端工程师评审会卡
- TraceGuard 不知道 PG schema 隔离，要么让它建在 `public`（污染），要么手动改上游支持 `search_path`

**推荐 γ1**。华典的审计链走 PG 的 `llm_calls / extractions_history / pipeline_runs`；TraceGuard 自家 SQLite 只是其 dashboard 用。等 Phase 3 商业化再考虑将 TraceGuard 接 PG 或引独立 trace store。

---

## 8. Adapter 最小骨架（草稿，待 T-TG-002 正式实现）

```python
# services/pipeline/src/huadian_pipeline/qc/traceguard_adapter.py
from __future__ import annotations

import json
import time
from pathlib import Path
from typing import Literal

from guardian.core.config import GuardianConfig, StructuralCheckConfig, SemanticCheckConfig, ActionConfig
from guardian.core.guardian_node import evaluate_async, GuardianDecision
from guardian.core.step import StepOutput

from .traceguard_port import TraceGuardPort
from .types import CheckpointInput, CheckpointResult, Violation

# TraceGuard action → ADR-004 action
_ACTION_MAP: dict[str, str] = {
    "pass":        "pass_through",
    "retry":       "retry",
    "abort":       "fail_fast",
    "alert":       "human_queue",   # 华典语义里 alert = 送人工队列
    "passthrough": "pass_through",
}

class TraceGuardAdapter(TraceGuardPort):
    def __init__(
        self,
        rule_registry: "RuleRegistry",
        policy_path: Path,
        mode: Literal["enforce", "shadow", "off"] = "enforce",
    ):
        self._rules = rule_registry
        self._policy = _load_policy(policy_path)
        self._mode = mode

    async def checkpoint(self, payload: CheckpointInput) -> CheckpointResult:
        t0 = time.perf_counter()

        # 1. 跑华典 Python 规则（TraceGuard 不感知）
        huadian_violations: list[Violation] = []
        for rule_id, rule_fn, severity in self._rules.for_step(payload.step_name):
            huadian_violations.extend(rule_fn(payload))

        # 2. 把 payload.outputs 序列化成 StepOutput，喂 TraceGuard 做结构校验
        tg_config = self._tg_config_for(payload.step_name)
        tg_config.semantic.enabled = False   # 禁用原生 semantic（见 §6）
        step_output = _make_step_output(payload)
        tg_decision: GuardianDecision = await evaluate_async(
            output=step_output,
            config=tg_config,
            attempt=payload.metadata.get("attempt", 1),
        )

        # 3. 把 TG issues 包成 Violation
        for msg in tg_decision.issues:
            huadian_violations.append(Violation(
                rule_id="traceguard.structural",
                severity=_severity_from_tg(tg_decision),
                message=msg,
                location={"step": payload.step_name},
                suggested_fix=tg_decision.retry_hint,
            ))

        # 4. 应用策略矩阵（degrade / human_queue 由此诞生）
        action = self._policy.resolve(
            step=payload.step_name,
            severity=_max_severity(huadian_violations),
            tg_action=_ACTION_MAP.get(tg_decision.action, "fail_fast"),
            attempt=payload.metadata.get("attempt", 1),
            mode=self._mode,
        )

        return CheckpointResult(
            status="pass" if not huadian_violations else "fail",
            action=action,
            violations=huadian_violations,
            score=tg_decision.score,
            duration_ms=int((time.perf_counter() - t0) * 1000),
            raw={"traceguard": tg_decision.__dict__},
        )

    # batch_checkpoint / replay / register_rule / health — 见任务卡 DoD
```

（完整实现见 T-TG-002 交付物。）

---

## 9. 待确认问题清单（抛给架构师 / 用户）

| # | 问题 | 影响 | 默认方案（若不决策） |
|---|------|------|----------------------|
| Q-D1 | TraceGuard 仓库是公开的吗？华典 CI 能否 `pip install` 其 git url？ | 依赖声明方式 | 暂以 `path = ../../vendor/traceguard` + git submodule fallback |
| Q-D2 | 是否要求 TraceGuard 在本 sprint 发 PyPI 0.2.0？ | 发布节奏 | 不要求，走 git rev pin |
| Q-D3 | Semantic LLM-as-Judge 是否完全由华典侧自写（走 LLMGateway），禁用 TraceGuard 原生 semantic？ | 架构清洁度 / 成本 | **默认 yes**（§6 β1） |
| Q-D4 | TraceGuard 存储保持独立 SQLite 还是合并到 PG？ | 迁移策略 | **默认保留 SQLite**（§7 γ1） |
| Q-D5 | TraceGuard action `alert` 是否等价于华典 `human_queue`？ | 映射表 | **默认 yes**（见 `_ACTION_MAP`） |
| Q-D6 | TraceGuard action `passthrough` 与 `pass` 都映射成 `pass_through`，是否合理？ | 映射表 | **默认 yes**，但 `passthrough` 触发时 Adapter 额外记 warning |
| Q-D7 | 允许 Adapter 修改上游吗？（例如给 `semantic.py` 加一个 client 注入钩子） | 工作量 | **默认不修改**，Adapter 只调上游稳定 API |
| Q-D8 | 首批华典自定义规则数量 & 覆盖步骤？ | DoD | **默认 ADR-004 §九**：至少 5 条（ner + relations + 通用 schema + surface_in_source + confidence） |
| Q-D9 | TraceGuard 依赖 `pydantic>=2.0` / `fastapi>=0.115` / `sqlalchemy>=2.0`，与华典 pipeline 子包是否兼容？ | 依赖版本冲突 | 调研期：华典 pipeline 当前只装了 basedpyright + 生成的 pydantic 模型，无冲突；pinning 见实现时 |
| Q-D10 | TraceGuard 的 `StepOutput.output_as_string()` 最大支持多少字符？是否需要为"鸿门宴段落 + NER 输出"再拆 chunk？ | 性能 | 查 `core/step.py` + 实测 |

---

## 10. 风险登记

| 风险 | 级别 | 说明 | 缓解 |
|---|---|---|---|
| R-1 上游 API 不稳定 | 🟨 中 | TraceGuard 0.1.0 无语义版本承诺，下一个版本可能重命名 `evaluate_async` | Adapter 层包装 + 集成测试黄金集锁行为 |
| R-2 性能不达标 | 🟨 中 | structural 只用 jsonschema，每段落~1ms 应 OK；但 semantic 或华典 Python 规则可能超 50ms | 分层：热路径仅结构；heavy rules 走 sampling |
| R-3 TraceGuard 依赖引起华典 pipeline 子包体积膨胀 | 🟩 小 | 新增 fastapi / uvicorn 传递依赖（其实 library 路径不需要） | 评估是否能在 `pipeline-guardian` pyproject 加 `optional-dependencies`：`core` / `cli` 分离（上游改动，Q-D7） |
| R-4 Adapter 测试需要一个"假 TraceGuard" | 🟩 小 | ADR-004 §九 要求 `mock_traceguard.py` | 用 `MockTraceGuardPort` 而非 mock 上游内部——单测解耦 |
| R-5 SQLite trace.db 跨开发机不同步 | 🟩 小 | 本地开发多机环境不一致 | `.gitignore` + docker volume；产生报告用 `extractions_history` |

---

## 11. 附录 · 关键代码快照

### A. evaluate_async 签名
```python
# guardian/core/guardian_node.py:143
async def evaluate_async(
    output: StepOutput,
    config: GuardianConfig,
    attempt: int = 1,
    http_client: httpx.AsyncClient | None = None,
) -> GuardianDecision:
```

### B. GuardianDecision 结构
```python
@dataclass
class GuardianDecision:
    action: str                        # 'pass' / 'retry' / 'abort' / 'alert' / 'passthrough'
    issues: list[str]
    score: float                       # 0.0 ~ 1.0
    retry_hint: str | None
    semantic_score: int | None         # 1 ~ 5
    semantic_status: str | None        # 'evaluated' / 'skipped ...' / None
```

### C. EvalTrace 表（上游唯一持久化实体）
```sql
-- guardian/store/models.py:35
CREATE TABLE eval_traces (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  pipeline_name   VARCHAR(255) NOT NULL,
  step_name       VARCHAR(255) NOT NULL,
  action          VARCHAR(50)  NOT NULL,
  passed          BOOLEAN      NOT NULL,
  score           FLOAT        NOT NULL,
  issues          TEXT         NOT NULL DEFAULT '[]',
  attempt         INTEGER      NOT NULL DEFAULT 1,
  output_preview  TEXT         NULL,
  created_at      DATETIME     NOT NULL
);
```

---

## 12. 本调研的限制

- 未实际跑通 `guardian check` 命令（只读源码）；§5 依赖声明待实测
- 未测 TraceGuard 对 Postgres 后端的兼容度（§7 的推荐基于源码推演）
- 未评估 TraceGuard 的测试套件覆盖哪些用例 → 是否能作为华典回归信号
- 未审 `guardian/env.py`（endpoint cache）和 `optimizer/*`（suggest）对华典是否有价值

这些留给 T-TG-002 实施阶段处理。
