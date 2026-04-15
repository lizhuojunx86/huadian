# 华典智谱 (HuaDian)

中国古籍 AI 知识平台 — 将古籍文本结构化为可探索、可交互、可查询的知识系统。

> **Phase 0** — Monorepo skeleton & infrastructure setup

## Quick start (5 minutes)

```bash
# 1. Install dependencies
pnpm install && uv sync --all-packages

# 2. Install pre-commit hooks
pip install pre-commit --user && pre-commit install

# 3. Start infrastructure (PostgreSQL + Redis + SigNoz)
make up

# 4. Start dev servers
pnpm dev
# → API:  http://localhost:4000/graphql
# → Web:  http://localhost:3000
```

For detailed setup instructions, see [`docs/runbook/RB-001-local-dev.md`](docs/runbook/RB-001-local-dev.md).

## Project structure

```
apps/web/              → Next.js 14 frontend
services/api/          → GraphQL API (Yoga + Drizzle)
services/pipeline/     → Python data pipeline (uv)
packages/              → Shared libraries (types, schema, UI, config)
docker/                → Docker Compose + custom images
data/                  → Curated reference data (historian-owned)
docs/                  → Architecture docs, ADRs, runbooks, task cards
```

## Tech stack

| Layer | Stack |
|-------|-------|
| Frontend | Next.js 14, TypeScript, Tailwind, shadcn/ui |
| API | GraphQL Yoga, Drizzle ORM, Node.js |
| Pipeline | Python 3.12, Prefect, Anthropic SDK |
| Database | PostgreSQL 16 (pgvector + PostGIS + pg_trgm) |
| Cache | Redis 7 |
| Observability | OpenTelemetry, SigNoz, Sentry, PostHog |
| Monorepo | pnpm workspaces, Turborepo, uv |

## For Claude Code / Cowork users

This project is designed for multi-agent collaboration via Claude Code.

- **Session handoff template**: [`CLAUDE.md §8`](CLAUDE.md#8-会话接续模板)
- **Agent role definitions**: [`.claude/agents/`](.claude/agents/)
- **Project entry point**: [`CLAUDE.md`](CLAUDE.md)

## Documentation

- [Architecture overview](华典智谱_架构设计文档_v1.0.md)
- [Project constitution](docs/00_项目宪法.md)
- [Architecture Decision Records](docs/decisions/)
- [Task cards](docs/tasks/)
- [Status board](docs/STATUS.md)
- [Changelog](docs/CHANGELOG.md)

## License

Private repository. All rights reserved.
