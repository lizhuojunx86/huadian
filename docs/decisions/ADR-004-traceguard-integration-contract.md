# ADR-004: TraceGuard 集成合同（Port/Adapter 契约）

- **状态**：accepted
- **日期**：2026-04-15
- **提议人**：首席架构师
- **决策人**：首席架构师（用户授权代为决定）
- **影响范围**：`services/pipeline/src/ai/` / `services/pipeline/src/qc/` / `services/api/src/middleware/` / 所有 LLM 调用路径
- **Supersedes**：`docs/06_TraceGuard集成方案.md §十` 中待用户确认的 7 个接口点问题
- **Superseded by**：无

## 背景

`docs/06` 列出了 7 个需要 TraceGuard 作者（用户本人）确认的接口细节。用户授权架构师 role 代为决定。由于架构师 agent 在当前会话无法直接读取 TraceGuard 源码仓库（位于用户本地 `/Users/lizhuojun/Desktop/APP/traceguard`，未挂载到本工作环境），本 ADR 采用 **Port/Adapter (Hexagonal Architecture) 模式**：

**不绑定 TraceGuard 的"现有"API 形态，而是定义华典智谱所需的接口契约（Port），由管线工程师在 Phase 0 实现一层 Adapter 去桥接 TraceGuard 当前版本。**

这种做法的好处：
1. TraceGuard 未来 API 升级时，只需改 Adapter，不污染业务代码
2. 若 TraceGuard 当前缺某些能力，可以用薄 shim 补齐
3. 若未来需要换底座（例如 OpenInference、Guardrails），只需重写 Adapter

## 选项

### 选项 A：直接绑定 TraceGuard 当前 SDK API
- 优点：最少代码
- 缺点：TraceGuard 升级需全盘改业务；架构耦合度高

### 选项 B：Port/Adapter 契约（本 ADR 采用）
- 优点：解耦；可替换；Adapter 中可加自有逻辑（日志、重试）
- 缺点：多一层薄封装

### 选项 C：不集成 TraceGuard，自写 QA 运行时
- 优点：完全可控
- 缺点：重复造轮子；违背用户诉求；放弃 TraceGuard 已有能力

## 决策

**选择 B**。以下为华典智谱需要 TraceGuard Adapter 对外暴露的契约（Port）：

### 一、目录结构

```
services/pipeline/src/qc/
├── traceguard_port.py          # 抽象接口（纯协议）
├── traceguard_adapter.py       # TraceGuard 具体适配（由管线工程师实现）
├── rules/                      # 华典自定义规则
│   ├── ner_rules.py
│   ├── relation_rules.py
│   ├── event_rules.py
│   ├── mention_rules.py
│   └── api_contract_rules.py
└── types.py                    # 公共数据结构
```

### 二、数据结构（Protocol）

```python
# services/pipeline/src/qc/types.py
from dataclasses import dataclass
from typing import Literal, Any

CheckpointStatus = Literal["pass", "fail", "warn"]
ActionType = Literal["pass_through", "retry", "degrade", "human_queue", "fail_fast"]

@dataclass
class CheckpointInput:
    step_name: str                  # e.g. "ner_v3"
    trace_id: str                   # 贯穿全链路
    parent_trace_id: str | None     # handoff 时填上游
    prompt_version: str             # e.g. "ner_v3.json#sha256"
    model: str                      # e.g. "claude-opus-4-6"
    inputs: dict[str, Any]          # 上游产物
    outputs: dict[str, Any]         # 本步产物
    metadata: dict[str, Any]        # 任意补充（book_id, paragraph_id 等）

@dataclass
class CheckpointResult:
    status: CheckpointStatus
    action: ActionType
    violations: list["Violation"]
    score: float                    # 0.0 ~ 1.0
    duration_ms: int
    raw: dict[str, Any]             # TraceGuard 原始响应（adapter 透传）

@dataclass
class Violation:
    rule_id: str
    severity: Literal["critical", "major", "minor", "info"]
    message: str
    location: dict[str, Any]        # e.g. {"field": "entities[2].surface_form"}
    suggested_fix: str | None
```

### 三、Port 接口（抽象协议）

```python
# services/pipeline/src/qc/traceguard_port.py
from typing import Protocol, Iterable
from .types import CheckpointInput, CheckpointResult, Violation

class TraceGuardPort(Protocol):
    async def checkpoint(self, payload: CheckpointInput) -> CheckpointResult:
        """同步阻塞校验。返回 action 决定下一步走向（retry/degrade/queue/fail）。"""
        ...

    async def batch_checkpoint(
        self, payloads: list[CheckpointInput]
    ) -> list[CheckpointResult]:
        """批量校验，用于大规模管线跑批。"""
        ...

    def register_rule(self, rule_id: str, rule_fn, *, severity: str) -> None:
        """注册自定义规则。rule_fn 签名：(CheckpointInput) -> list[Violation]。"""
        ...

    def register_rule_bundle(self, bundle_path: str) -> None:
        """注册规则包（目录或 YAML）。"""
        ...

    async def replay(self, trace_id: str) -> CheckpointResult:
        """基于已存 trace 重放校验（用于规则演化后历史回归）。"""
        ...

    def health(self) -> dict:
        """返回 {"ok": bool, "version": str, "rules_loaded": int}"""
        ...
```

### 四、规则编写格式（华典侧统一）

```python
# services/pipeline/src/qc/rules/ner_rules.py
from ..types import CheckpointInput, Violation

def rule_ner_surface_in_source(payload: CheckpointInput) -> list[Violation]:
    """所有抽取出的实体 surface_form 必须在原文中出现。"""
    violations = []
    source_text = payload.inputs.get("paragraph_text", "")
    for i, ent in enumerate(payload.outputs.get("entities", [])):
        if ent["surface_form"] not in source_text:
            violations.append(Violation(
                rule_id="ner.surface_in_source",
                severity="critical",
                message=f"实体 surface_form 未在原文出现: {ent['surface_form']!r}",
                location={"field": f"entities[{i}].surface_form"},
                suggested_fix="检查 prompt 是否要求 grounded extraction",
            ))
    return violations

# 注册
RULES = [
    ("ner.surface_in_source", rule_ner_surface_in_source, "critical"),
    # ...
]
```

无论 TraceGuard 当前 API 如何，Adapter 都把上述 `rule_fn` 注册进 TraceGuard。

### 五、动作编排（Action Policy）

违规动作策略在 Adapter 层配置，**不依赖** TraceGuard 是否原生支持：

```yaml
# services/pipeline/config/traceguard_policy.yml
defaults:
  max_retries: 2
  retry_backoff_ms: [500, 2000]
  degrade_to: "claude-sonnet-4-6"   # 主模型失败降级
  human_queue: "qc_review_queue"

by_severity:
  critical: [retry, degrade, human_queue, fail_fast]
  major:    [retry, degrade, human_queue]
  minor:    [warn_only]
  info:     [pass_through]

by_step:
  ner_v3:
    critical: [retry, human_queue]    # NER 不做模型降级
  relation_v2:
    critical: [retry, degrade, human_queue]
```

Adapter 读取此 yml，在 `checkpoint()` 返回 `CheckpointResult.action` 前解释执行。

### 六、结果存储

**TraceGuard 原生存储能力不作为依赖**。华典侧独立负责：

1. **`llm_calls` 表**（PostgreSQL）：每次 LLM 调用落一行
2. **`extractions_history` 表**：每次抽取产出落一行，不覆盖
3. **`pipeline_runs` 表**：每次管线运行总览
4. **TraceGuard 原始 `raw` 字段**：作为 JSONB 存入 `extractions_history.traceguard_raw`

Adapter 的 `checkpoint()` 内部同时：
- 调 TraceGuard（真正做校验）
- 写 `llm_calls` / `extractions_history`（OTel span 关联 trace_id）
- 返回 `CheckpointResult`

### 七、环境与降级

```python
# services/pipeline/src/qc/traceguard_adapter.py
class TraceGuardAdapter(TraceGuardPort):
    def __init__(self, mode: Literal["enforce", "shadow", "off"] = "enforce"):
        self.mode = mode
        # enforce: 校验失败阻断
        # shadow:  只记录不阻断（用于新规则观察期）
        # off:    完全跳过（紧急降级）
```

### 八、对 `docs/06 §十` 的 7 个问题逐项回答

| # | 原问题 | 本 ADR 的回答 |
|---|-------|--------------|
| 1 | TraceGuard 当前是否有 Python/Node 客户端 | **不假设**。Python Adapter 用 `subprocess`/HTTP/SDK 任一形式桥接皆可；若无 Node 客户端，API 层校验走 HTTP 调用 Python 侧 Adapter 服务，或在 Node 侧实现薄 shim 直接调 TraceGuard HTTP |
| 2 | Checkpoint 返回值结构 / 是否异步 | 由 Port 规定：**异步** + `CheckpointResult` 结构。若 TraceGuard 目前是同步，Adapter 用 `asyncio.to_thread` 包装 |
| 3 | 规则编写格式 | 华典侧统一用 **纯函数 `(CheckpointInput) -> list[Violation]`**；Adapter 负责把它翻译成 TraceGuard 当前支持的形式（decorator / config / class 均可） |
| 4 | 结果存储 | **不依赖 TraceGuard 存储**；华典侧存 PG（`llm_calls` / `extractions_history`）；TraceGuard 原始输出作为 JSONB 透传存储 |
| 5 | 规则组合（AND/OR/NOT） | Port 不要求 TraceGuard 支持组合。组合逻辑由华典侧的 `rule_fn` 自行实现（函数内部可任意组合）或由 Adapter 聚合多个 rule 结果 |
| 6 | 动作编排（retry/degrade/queue） | **不依赖 TraceGuard**；由华典侧 `traceguard_policy.yml` 在 Adapter 层实现 |
| 7 | Sampling / 环境分组 | 由 Adapter 的 `mode` 字段 + `by_step` 策略实现；不依赖 TraceGuard 原生支持 |

### 九、Adapter 实现任务（Phase 0 必交付）

创建新任务卡 **T-TG-002：TraceGuard Adapter 实现**（主导：管线工程师；协作：架构师）。交付物：
1. `traceguard_port.py` 接口文件
2. `traceguard_adapter.py` 具体实现（读 TraceGuard 本地仓库后对齐）
3. `rules/*.py` 至少 5 条初始规则
4. `traceguard_policy.yml` 默认策略
5. `mock_traceguard.py` 单测用桩
6. `tests/test_adapter.py` 单测

**依赖**：T-TG-001（挂载 TraceGuard 仓库到项目 submodule 或 symlink，由 DevOps 完成）。

## 影响

- 正面：业务代码与 TraceGuard 版本解耦；未来可替换；可 mock 测试；动作策略可配置而非硬编码
- 负面：需要维护 Adapter 一层；首次实现需管线工程师阅读 TraceGuard 源码
- 迁移成本：0（起始态）

## 回滚方案

若 Adapter 层被证明开销过大，允许下沉为"极薄 pass-through"（直接暴露 TraceGuard SDK）。但 `types.py` 的数据结构必须保留作为内部交换格式。

## 相关链接
- 文档：`docs/06_TraceGuard集成方案.md`
- 任务卡：T-TG-001（仓库挂载）/ T-TG-002（Adapter 实现）
- 相关 ADR：ADR-010（Prompt 版本化，提供 checkpoint 的 `prompt_version` 字段）
- 宪法条款：C-7 / C-8 / C-14
