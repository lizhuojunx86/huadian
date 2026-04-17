# T-P0-005: LLM Gateway + TraceGuard 基础集成

- **状态**：ready
- **主导角色**：管线工程师
- **协作角色**：首席架构师（评审）、后端工程师（Drizzle llm_calls 表对齐评议）
- **所属 Phase**：Phase 0
- **依赖任务**：T-P0-002 ✅（DB Schema — llm_calls 表）、T-TG-002 ✅（TraceGuard Adapter）
- **预估工时**：2 人日（管线主）+ 0.5 人日（架构师评审）
- **创建日期**：2026-04-17

## 目标（Why）

实现 C-7（无黑盒 LLM 调用）的技术基石：一个统一的 **LLM Gateway** 抽象层，所有 LLM 调用必须经过它。

Gateway 职责：
1. **封装 provider 差异**（Anthropic 为 Phase 0 唯一 provider，但接口预留可切换）
2. **记录审计信息**（prompt_id / version / hash / model / response / cost / latency）→ 写入 `llm_calls` 表
3. **TraceGuard 集成**：每次 LLM 调用后通过 T-TG-002 的 `TraceGuardAdapter.checkpoint()` 做一次最小 checkpoint

这是 T-P0-006（鸿门宴 NER）的直接前置——没有 Gateway，管线没法合法调 LLM。

---

## 范围（What）

### 包含

1. **Gateway 接口定义**：
   - `services/pipeline/src/huadian_pipeline/ai/gateway.py`
   - `LLMGateway` Protocol / ABC，定义 `call(prompt_id, version, input, *, model, temperature, max_tokens) → LLMResponse`
   - `LLMResponse` dataclass：`content / model / input_tokens / output_tokens / cost_usd / latency_ms / prompt_hash / input_hash`

2. **Anthropic 实现**：
   - `services/pipeline/src/huadian_pipeline/ai/anthropic_provider.py`
   - 基于 `anthropic` SDK（`AsyncAnthropic`）
   - 支持 claude-sonnet-4-6（默认）和 claude-haiku-4-5（降级）
   - 重试策略：指数退避，最多 3 次，遇 429/529 自动退避
   - 成本计算：基于 Anthropic 公开的 token 定价（hardcode Phase 0，Phase 1 改为配置）

3. **配置来源**：
   - `ANTHROPIC_API_KEY`（env，必填）
   - `LLM_DEFAULT_MODEL`（env，默认 `claude-sonnet-4-6`）
   - `LLM_MAX_RETRIES`（env，默认 `3`）
   - `LLM_TIMEOUT_SECONDS`（env，默认 `60`）
   - 不引入 YAML 配置文件（Phase 0 KISS）

4. **Prompt hash + Input hash**：
   - `prompt_hash = sha256(prompt_id + version + system_prompt_text)`
   - `input_hash = sha256(input_text)`
   - 用于去重 / 缓存键 / `llm_calls` 表索引

5. **审计写入**（`llm_calls` 表）：
   - 每次调用后异步写入 `llm_calls` 表（via Drizzle 或 raw `asyncpg`）
   - 字段映射：`prompt_id / prompt_version / prompt_hash / input_hash / model / request / response / input_tokens / output_tokens / cost_usd / latency_ms / status / traceguard_checkpoint_id`
   - 写入失败不阻断 Gateway 返回（best-effort audit，与 TraceGuard audit sink 一致）

6. **TraceGuard checkpoint**：
   - 调用 `TraceGuardAdapter.checkpoint(CheckpointInput(...))` 一次
   - step_name = `f"llm_call/{prompt_id}"`
   - outputs = LLM response content
   - metadata = `{ model, prompt_version, attempt }`
   - checkpoint 结果中的 `action` 决定后续行为：
     - `pass_through` → 正常返回
     - `retry` → Gateway 内部重试（递增 attempt）
     - `degrade` → 切换到 Haiku 重试
     - `human_review` / `fail_fast` → 抛 `LLMGatewayError`，由上游管线步骤决策

7. **边界澄清：谁负责审计写库？**
   - `llm_calls` 表写入 → **Gateway 负责**（每次调用必写，无论 checkpoint 通过与否）
   - `extractions_history` 表写入 → **TraceGuard AuditSink 负责**（T-TG-002 已实现）
   - Gateway 与 AuditSink 独立，不互相调用

8. **测试**：
   - Gateway 接口 / Anthropic provider 单元测试（mock httpx / anthropic SDK）
   - TraceGuard 集成测试（使用 `MockTraceGuardPort`）
   - 审计写入测试（mock DB 或 testcontainers PG）

### 不包含（防止 scope creep）

- ❌ **缓存层**（Redis / in-memory）：Phase 1 引入（ADR-011 scope）
- ❌ **Prompt 管理系统**（prompt registry / version control）：Phase 1（ADR-011）
- ❌ **多 provider 运行时切换**（OpenAI / 本地模型等）：Phase 2+
- ❌ **流式响应（streaming）**：Phase 1+（NER 管线不需要 streaming）
- ❌ **并发限制 / rate limiter**：Phase 1（当前 dev 环境单线程足够）
- ❌ **Node.js 侧 Gateway**（API 层 checkpoint 是 Phase 1 scope，见 docs/06 §2.4）
- ❌ **前端直调 LLM**（永远不允许，C-7）

---

## 架构师决策点

### Q-1 Gateway 与 TraceGuard Adapter 的组合方式

- **选项 A**：Gateway 构造函数接收 `TraceGuardPort` 实例，每次 `call()` 内部调 `checkpoint()`
- **选项 B**：Gateway 不知道 TraceGuard；上游管线步骤自己分别调 Gateway + TraceGuard
- **架构师裁定**：**A**。理由：
  1. C-7 要求"所有 LLM 调用通过统一 Gateway"——如果 Gateway 自身不集成 checkpoint，等于把 C-8 的职责泄漏给了每个管线步骤
  2. Gateway 是 checkpoint 最自然的注入点（调用前后都在同一 scope）
  3. 上游管线步骤（如 NER）仍可在 Gateway checkpoint 之外再做步骤级 checkpoint（两层不冲突）

### Q-2 审计写入方式

- **选项 A**：通过 Drizzle ORM insert（与 API 层共享 schema）
- **选项 B**：通过 raw `asyncpg`（Pipeline 层已有 asyncpg 依赖）
- **架构师裁定**：**B**。理由：
  1. Pipeline 是 Python 进程，不运行 Node.js / Drizzle
  2. T-TG-002 的 `AuditSink` 已建立了 asyncpg 写入模式
  3. 保持管线层 DB 访问统一用 asyncpg

### Q-3 成本追踪精度

- **选项 A**：基于 token count × 公开定价 hardcode 计算
- **选项 B**：从 Anthropic response headers 读取实际计费（如果可用）
- **架构师裁定**：**A for Phase 0**。Anthropic API 目前不在 response 中返回精确计费金额；用 `input_tokens * rate + output_tokens * rate` 足够 Phase 0 的成本监控。Phase 1 可引入 billing API 校准。

### Q-4 重试策略与 TraceGuard 的关系

- **选项 A**：Gateway 自身 retry（HTTP 层 429/5xx）+ TraceGuard retry（语义层质量不达标）双层
- **选项 B**：所有 retry 统一由 TraceGuard 决定
- **架构师裁定**：**A**。理由：
  1. HTTP 层 retry（429 / 网络超时）是基础设施问题，不应进入 TraceGuard 的规则域
  2. TraceGuard retry 是语义层（"输出质量不达标，换 prompt / 降级模型"）
  3. 两层 retry 各自有独立 attempt counter

---

## 子任务拆解

### S-1 调研与对齐（0.2 天）
- [ ] 阅读 `docs/06_TraceGuard集成方案.md` §2.3（LLM Gateway 层）参考实现
- [ ] 阅读 `services/pipeline/src/huadian_pipeline/qc/adapter.py`（TraceGuardAdapter 接口）
- [ ] 阅读 `services/pipeline/src/huadian_pipeline/qc/types.py`（CheckpointInput / CheckpointResult）
- [ ] 确认 `llm_calls` 表 Drizzle 定义 vs asyncpg 写入的字段映射
- [ ] 提出 Q-1~Q-4 以外的任何新问题

### S-2 接口定义（0.3 天）
- [ ] `services/pipeline/src/huadian_pipeline/ai/__init__.py`
- [ ] `services/pipeline/src/huadian_pipeline/ai/types.py`：`LLMResponse` / `LLMGatewayError` / `PromptSpec`
- [ ] `services/pipeline/src/huadian_pipeline/ai/gateway.py`：`LLMGateway` Protocol
- [ ] `services/pipeline/src/huadian_pipeline/ai/hashing.py`：`prompt_hash()` / `input_hash()`
- [ ] 单元测试：hash 确定性 + 类型验证

### S-3 Anthropic 实现（0.5 天）
- [ ] `services/pipeline/src/huadian_pipeline/ai/anthropic_provider.py`
- [ ] `AnthropicGateway(LLMGateway)` 实现
- [ ] 重试逻辑（指数退避 + 429/529 特殊处理）
- [ ] 成本计算（token count × rate）
- [ ] 单元测试（mock anthropic SDK，覆盖 happy / retry / timeout / auth error）
- [ ] **Checkpoint commit**

### S-4 TraceGuard 集成（0.3 天）
- [ ] `AnthropicGateway.__init__` 接收 `TraceGuardPort` 参数
- [ ] `call()` 内部：LLM 调用后调 `self._tg.checkpoint(CheckpointInput(...))`
- [ ] checkpoint action 路由：pass_through / retry / degrade / fail_fast
- [ ] 集成测试：使用 `MockTraceGuardPort`（T-TG-002 已提供）
- [ ] **Checkpoint commit**

### S-5 审计写入 + 端到端测试（0.5 天）
- [ ] `services/pipeline/src/huadian_pipeline/ai/audit.py`：`LLMCallAuditWriter`（asyncpg insert into llm_calls）
- [ ] `AnthropicGateway.call()` 末尾调 audit writer（best-effort）
- [ ] Integration 测试（testcontainers PG）：一次 Gateway call → 验证 llm_calls 表有记录
- [ ] 端到端冒烟测试：mock Anthropic → Gateway → checkpoint → audit → 验证全链路
- [ ] **Checkpoint commit**

### S-6 收尾（0.2 天）
- [ ] basedpyright 0/0/0
- [ ] 更新 STATUS.md / CHANGELOG.md / T-000-index.md
- [ ] git commit

---

## 交付物（Deliverables）

- [ ] `services/pipeline/src/huadian_pipeline/ai/` 目录：
  - `__init__.py` / `types.py` / `gateway.py` / `anthropic_provider.py` / `hashing.py` / `audit.py`
- [ ] 单元测试 + 集成测试
- [ ] 文档更新：STATUS / CHANGELOG / T-000-index

---

## 完成定义（DoD）

1. `LLMGateway` Protocol 定义完整，支持至少 `call()` 方法
2. `AnthropicGateway` 可通过 `ANTHROPIC_API_KEY` 环境变量调用 Anthropic API
3. 每次 `call()` 自动触发 `TraceGuardAdapter.checkpoint()` 并根据 action 路由（pass / retry / degrade / fail）
4. 每次 `call()` 异步写入 `llm_calls` 表（所有 schema 要求的字段）
5. 重试策略：HTTP 层 3 次指数退避 + TraceGuard 语义层独立 retry
6. `prompt_hash` / `input_hash` 确定性计算且有测试覆盖
7. 单元测试 ≥ 15 个 test case
8. Integration 测试 ≥ 3 个 test case（MockTraceGuardPort + testcontainers PG）
9. basedpyright 0 errors / 0 warnings / 0 notes
10. STATUS.md / CHANGELOG.md / T-000-index.md 已更新

---

## 依赖分析

| 依赖 | 状态 | 阻塞？ |
|------|------|--------|
| T-P0-002 DB Schema（llm_calls 表） | ✅ done | 否 |
| T-TG-002 TraceGuard Adapter | ✅ done | 否 |
| `anthropic` Python SDK | 需新增依赖（架构师批准） | 否 |
| `ANTHROPIC_API_KEY` 环境变量 | `.env.example` 已预留 | 否 |

**新依赖申请**：
- `anthropic>=0.40.0`（Anthropic 官方 Python SDK）— 请架构师批准

---

## 风险与缓解

| 风险 | 缓解 |
|------|------|
| Anthropic SDK 版本变更导致 response 结构变化 | Pin 小版本；单元测试覆盖 response 解析 |
| `llm_calls` 表结构与 Drizzle 定义不完全对齐（Pipeline 用 asyncpg 直接写） | S-1 阶段显式对比字段映射；后续 T-TG-002-F6 统一 |
| TraceGuard checkpoint 延迟影响 Gateway 吞吐 | checkpoint 是 async，Gateway 不等 audit sink；必要时可降级为 shadow mode |
| 成本计算基于 hardcode 定价，Anthropic 调价后不准确 | Phase 0 可接受；Phase 1 引入配置文件 or billing API |
| `anthropic` SDK 与 `pipeline-guardian` 的 httpx 版本冲突 | S-1 调研时验证依赖树；必要时 pin httpx 区间 |

---

## 宪法条款检查清单

- [ ] **C-7** 所有 LLM 调用通过统一 Gateway，记录 prompt/model/cost/latency
- [ ] **C-8** Gateway 内置 TraceGuard checkpoint（质检嵌入）
- [ ] **C-9** 审计数据入 `llm_calls` 表（可观测性先于优化）
- [ ] **C-11** 调用记录幂等（prompt_hash + input_hash 可用于去重）
- [ ] **C-20** TraceGuard checkpoint 校验 LLM 输出质量

---

## 协作交接

- **← T-TG-002**：`TraceGuardAdapter` / `CheckpointInput` / `MockTraceGuardPort`
- **← T-P0-002**：`llm_calls` 表 schema
- **→ T-P0-006**：Pipeline NER 步骤通过 Gateway 调 LLM
- **→ T-P0-005a**：SigNoz OTel 集成可在 Gateway 增加 span
- **→ 后端工程师**：`llm_calls` 表 asyncpg 写入与 Drizzle 定义的字段对齐验证（T-TG-002-F6）

---

## 接续提示

```
本任务 ID：T-P0-005
你将担任：管线工程师
请先读：
1. CLAUDE.md → docs/STATUS.md → docs/CHANGELOG.md 最近 5 条
2. .claude/agents/pipeline-engineer.md
3. docs/tasks/T-P0-005-llm-gateway.md（本文件）
4. docs/06_TraceGuard集成方案.md §2.3（LLM Gateway 参考实现）
5. services/pipeline/src/huadian_pipeline/qc/adapter.py（TraceGuardAdapter）
6. services/pipeline/src/huadian_pipeline/qc/types.py（CheckpointInput/Result）
7. services/pipeline/src/huadian_pipeline/qc/mock.py（MockTraceGuardPort）
8. packages/db-schema/src/schema/pipeline.ts（llm_calls 表 Drizzle 定义）

架构师已预裁定 Q-1~Q-4（见本文件）。
按子任务 S-1→S-6 顺序执行。新依赖 `anthropic` 已申请批准。
```

---

## 修订历史

- 2026-04-17 v1：首席架构师起草，Q-1~Q-4 预裁定，状态 ready
