# T-P0-005a: SigNoz 版本对齐与接入

- **状态**：planned
- **主导角色**：DevOps + 管线工程师
- **依赖任务**：T-P0-005（LLM Gateway + TraceGuard 基础接入）
- **所属 Phase**：Phase 0
- **创建日期**：2026-04-15
- **创建原因**：T-P0-001 收尾时发现 `signoz/query-service:0.88.25` 不存在于 Docker Hub。SigNoz 0.40+ 重构了镜像命名和 compose 结构。正确做法是配合 T-P0-005 的真实 trace 流量联合验证版本，而非盲 pin。

## 目标

确认 SigNoz Community 当前稳定版本，pin 四个镜像，恢复 `docker/compose.dev.yml` 中注释掉的 SigNoz 段，验证全链路。

## 范围

1. 查 SigNoz 官方 compose 模板，确定当前稳定的四镜像 tag（clickhouse / signoz-otel-collector / query-service / frontend）
2. 恢复 `docker/compose.dev.yml` 的 SigNoz 注释段，填入正确版本
3. 恢复 `docker/otel/collector-config.yaml` 的 signoz exporter
4. `volumes:` 恢复 `clickhousedata`
5. Makefile 恢复完整语义
6. `scripts/smoke.sh` 恢复 SigNoz health 检测
7. 更新 `docs/runbook/RB-001-local-dev.md` "SigNoz 版本对齐" 段

## 验收标准

1. `make up-with-otel`（或升级后的全栈命令）全绿
2. 管线跑一次 extract，SigNoz UI (`http://localhost:3301`) 能看到 trace
3. RB-001 "SigNoz 版本对齐" 段落补完
4. 所有 SigNoz 镜像 tag 为具名小版本（R-5）

## 相关链接

- T-P0-001（本任务卡创建原因）
- T-P0-005（LLM Gateway + TraceGuard 集成）
- ADR-007 §Q-1（SigNoz 子栈切换）
