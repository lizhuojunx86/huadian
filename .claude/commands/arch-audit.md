# Architecture Audit — 项目合规审计

你是华典智谱的项目审计员。请全面审核项目当前状态，对照以下标准逐项检查。
**不要修改任何代码，只做审核和报告。**

## 审核维度

### 1. 项目宪法（docs/00_项目宪法.md）合规

逐条检查 C-1 到 C-21：

- **C-1 一次结构化 N 次衍生**: 是否有为单个产品建立的独立数据表？
- **C-2 可溯源**: 实现 Traceable 接口的实体是否都有 sourceEvidenceId + provenanceTier？GraphQL schema 中暴露给用户的实体是否全部关联 SourceEvidence？
- **C-3 多源共存**: EventAccount / AccountConflict 模型是否正确建模多叙述？
- **C-4 历史原貌**: 是否有物理删除（DELETE 而非 soft-delete）？entity_revisions 审计表是否存在？
- **C-5 单 PostgreSQL**: 是否引入了独立图数据库 / 向量库 / 搜索引擎？（pgvector + pg_trgm 在 PG 内部不算违规）
- **C-6 Schema-first**: 检查最近的 commit，是否有"先写代码再补 schema"的痕迹？Drizzle schema 是否是 DDL 唯一真源？
- **C-7 无黑盒 LLM**: services/pipeline 中是否有绕过 Gateway 的直接 LLM 调用？
- **C-8 质检嵌入**: TraceGuard adapter 是否正常集成？checkpoint 是否在管线步骤中被调用？
- **C-9 可观测性先于优化**: 是否接入了 OpenTelemetry？GraphQLContext 中是否有 tracer？
- **C-10 类型端到端**: Drizzle schema → GraphQL SDL → TypeScript types 是否一致？检查 shared-types codegen 产物与 Drizzle schema 的字段名是否对齐（camelCase）
- **C-11 可回滚**: migration 是否有 down 方案？LLM 抽取是否按 prompt_version 保留？
- **C-12 多语言**: user-facing 文本字段是否使用 JSONB 多语言结构（MultiLangText）？
- **C-13 URL 稳定**: 实体是否有 slug 字段？API 是否优先使用 slug？
- **C-14 许可证前置**: 数据入库是否标注 license？
- **C-15 角色解耦**: 最近的任务卡是否尊重角色边界？
- **C-16 决策可追溯**: 非琐碎决策是否都有 ADR？
- **C-17 进度显式化**: STATUS.md 和 CHANGELOG.md 是否与实际代码状态一致？
- **C-18 跨会话接续**: 新会话是否能通过 CLAUDE.md → STATUS.md → CHANGELOG.md 在 30 分钟内理解现状？

### 2. ADR 合规

- 检查 `docs/decisions/ADR-*.md` 是否涵盖所有重大技术决策
- 检查 ADR 状态（accepted / superseded / deprecated）是否准确
- 检查 ADR 中的"后果"部分是否与实际实现匹配
- 特别检查 ADR-004（TraceGuard 集成）的 Errata（E-1~E-5）是否与代码一致

### 3. Schema 一致性

```bash
# 检查 Drizzle schema 表数量
grep -c "export const" packages/db-schema/src/schema/*.ts

# 检查 GraphQL type 数量
grep -c "^type " services/api/src/schema/*.graphql

# 检查 codegen 是否最新
pnpm codegen && git diff --exit-code
```

- Drizzle schema 中的表名（snake_case）是否与 GraphQL type 名（PascalCase）对应？
- 字段命名是否一致（Drizzle camelCase TS properties ↔ GraphQL camelCase fields）？
- shared-types 中的 JSON schema 是否与 Drizzle 的 JSONB 列定义匹配？

### 4. 测试覆盖

- TypeScript 侧：`pnpm test` 是否通过？有无测试文件？
- Python 侧：`pytest` 是否通过？当前测试数量和通过率？
- 核心路径（QC adapter、rule registry、policy、audit、replay）是否都有测试？
- 测试是否使用 mock 而非真实数据库连接？

### 5. CI/CD 完整性

- `.github/workflows/ci.yml` 是否覆盖：lint → typecheck → codegen verify → test → build？
- `.github/workflows/graphql-breaking.yml` 是否正确配置？
- `.github/workflows/pre-commit.yml` 是否与 `.pre-commit-config.yaml` 一致？
- CI 中 Python private dep（pipeline-guardian）的 git 认证是否配置？

### 6. 依赖健康

- `pnpm-lock.yaml` 是否与 `package.json` 一致（`pnpm install --frozen-lockfile` 不报错）？
- `uv.lock` 是否与 `pyproject.toml` 一致？
- 是否有已知高危依赖？检查 dependabot PR 是否有积压
- pipeline-guardian 的 git pin SHA 是否指向 `v0.1.0-huadian-baseline` tag？

### 7. 文档完整性

- STATUS.md 中所有任务状态是否准确反映实际？
- CHANGELOG.md 是否记录了所有重要变更？
- 新完成的任务卡是否标记为 done + 完成日期？
- follow-up 任务（F-1~F-6）是否都有对应的任务卡或 backlog 记录？

### 8. 安全

- 是否有 API key / token / password 出现在 git 追踪的文件中？（`git log -p | grep -i "api.key\|token\|password\|secret"` 抽查）
- `.gitignore` 是否包含 `.env`、`node_modules`、`.venv`、`__pycache__`？
- gitleaks 扫描是否在 CI 中启用且通过？

## 输出格式

```markdown
# 华典智谱 架构审计报告
**日期**: YYYY-MM-DD
**审计范围**: [commit range or branch]

## 概要
- PASS: N 项
- WARN: N 项
- FAIL: N 项

## 详细结果

### 1. 项目宪法合规
- [PASS] C-1: ...
- [WARN] C-7: 尚未实现 LLM Gateway（Phase 0 不需要，Phase 1 必须）
- [FAIL] C-XX: ... → 修复建议: ...

### 2. ADR 合规
...

### 3. Schema 一致性
...

（以此类推）

## 建议优先级
1. 🔴 [FAIL] 必须立即修复: ...
2. 🟡 [WARN] 下一个 Phase 前需解决: ...
3. 🟢 [PASS] 保持现状: ...
```

## 注意

- 这是只读审计，**不要修改任何文件**
- 如果需要运行命令来验证（如 codegen、test），在临时目录中运行，不要改变工作区状态
- 报告输出到 `docs/audits/audit-YYYY-MM-DD.md`
- Phase 0 阶段某些宪法条款（如 C-7 LLM Gateway、C-9 OpenTelemetry）可能尚未实现，标记为 WARN 而非 FAIL，注明预期实现的 Phase
