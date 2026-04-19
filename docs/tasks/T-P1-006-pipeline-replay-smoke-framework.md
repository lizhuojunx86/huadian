# T-P1-006 — Pipeline Replay-based Smoke Framework

- **状态**：backlog / deferred
- **优先级**：P1（非阻塞）
- **主导角色**：QA 工程师 + 管线工程师

## 动机

T-P0-023 Stage 1e 无法做零成本 smoke ingest 验证：
- pilot 命令需要真实 ANTHROPIC_API_KEY + 产生 LLM 费用
- data/test/ 不存在；项目无 mock LLM / replay 离线 smoke 框架

## 目标

- 录制一次真实 ingest 的 LLM request/response pairs → 固化为 fixture
- 建立 replay 模式：pipeline CLI 支持 `--replay <fixture>` 参数，跳过真实 LLM 调用
- 纳入 CI 作为 smoke 验证（与单测 / 集成测试互补）

## 非目标

- 不替代 DB 集成测试
- 不做性能 / LLM 质量压测（另起任务）

## 触发条件

积累到 2+ 个"因无 smoke 无法验证"的场景时启动。
