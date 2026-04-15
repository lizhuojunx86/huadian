# RB-001: Local Development Setup

> One-page onboarding guide. Goal: from `git clone` to running app in 15 minutes.

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Node.js | 20 LTS (see `.nvmrc`) | `nvm install` or [nodejs.org](https://nodejs.org/) |
| pnpm | 9.x (see `package.json#packageManager`) | `corepack enable && corepack prepare pnpm@latest --activate` |
| Python | 3.12.x (see `.python-version`) | [python.org](https://www.python.org/) or `pyenv install 3.12` |
| uv | latest | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| Docker | 24+ with Compose V2 | [Docker Desktop](https://www.docker.com/products/docker-desktop/) |
| pre-commit | latest | `pip install pre-commit --user` or `brew install pre-commit` |

## Step 1: Clone & install dependencies

```bash
git clone <repo-url> huadian && cd huadian

# Install git hooks (secret scanning + lint-staged)
pre-commit install

# Install JS/TS dependencies
pnpm install

# Install Python dependencies
uv sync --all-packages
```

Or use the automated pre-check:

```bash
./scripts/dev.sh
# Checks Node ≥ 20, Python ≥ 3.12, Docker, pnpm, uv, pre-commit hook
# If all pass, starts dev servers automatically
```

## Step 2: Configure environment

```bash
cp .env.example .env.local
# Edit .env.local — fill in real ANTHROPIC_API_KEY if you have one
# All other defaults work for local dev
```

### Environment variable reference

| Key | Purpose | Required locally? |
|-----|---------|-------------------|
| `DATABASE_URL` | PostgreSQL connection string | Yes (default works with docker) |
| `REDIS_URL` | Redis connection string | Yes (default works with docker) |
| `ANTHROPIC_API_KEY` | LLM calls (pipeline only) | No (only for pipeline tasks) |
| `EMBEDDING_MODEL` | Embedding model name (ADR-005) | No (default: `bge-large-zh-v1.5`) |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTel Collector endpoint | No (only if observability stack is up) |
| `POSTHOG_API_KEY` / `POSTHOG_HOST` | Product analytics | No (Phase 1+) |
| `SENTRY_DSN` | Error monitoring | No (leave empty to disable) |
| `TRACEGUARD_POLICY_FILE` | TraceGuard policy path | No (pipeline only) |
| `PORT` | API server port | No (default: 4000) |
| `NODE_ENV` | Runtime mode | No (default: development) |

### Port conventions

HuaDian defaults to **non-standard host ports** to avoid conflicts with other local stacks
(e.g., qav2 timescaledb on 5432, qav2 redis on 6379):

| Service | Container port | Host port (default) | Override env var |
|---------|---------------|--------------------|--------------------|
| PostgreSQL | 5432 | **5433** | `HUADIAN_PG_PORT` |
| Redis | 6379 | **6380** | `HUADIAN_REDIS_PORT` |
| API server | — | 4000 | `PORT` |
| Web (Next.js) | — | 3000 | — (auto-increments) |
| OTel Collector gRPC | 4317 | 4317 | — |
| OTel Collector HTTP | 4318 | 4318 | — |

`services/api` and `services/pipeline` connect via `DATABASE_URL` / `REDIS_URL` in `.env.local`,
so changing host ports doesn't require code changes. If 5433/6380 are also taken:

```bash
HUADIAN_PG_PORT=5555 HUADIAN_REDIS_PORT=6666 make up
# Then update DATABASE_URL/REDIS_URL in .env.local to match
```

## Step 3: Start infrastructure

### Two modes

| Mode | Command | Services | RAM overhead |
|------|---------|----------|-------------|
| **Core (default)** | `make up` | PG + Redis | ~300 MB |
| **+ OTel Collector** | `make up-with-otel` | PG + Redis + OTel Collector (trace → stdout) | ~400 MB |

```bash
# Phase 0 default — PG + Redis
make up

# With OTel Collector (traces output to container stdout)
make up-with-otel
# View traces: docker logs huadian-otel-collector
```

> **SigNoz UI deferred to T-P0-005a** — The SigNoz observability stack (ClickHouse + query-service + frontend)
> is commented out in `docker/compose.dev.yml`. Reason: pinned version `0.88.25` did not exist on Docker Hub;
> SigNoz 0.40+ restructured image naming. Correct approach: pin to verified version with real trace traffic
> during T-P0-005 (LLM Gateway + TraceGuard), not blind version guessing. Phase 0 observability: OTel Collector
> runs standalone, traces go to container stdout (`docker logs huadian-otel-collector`).

### Verify PostgreSQL extensions

```bash
docker exec huadian-postgres psql -U huadian -d huadian -c '\dx'
```

Must show: `vector`, `postgis`, `postgis_topology`, `pg_trgm`.

### Verify Redis

```bash
docker exec huadian-redis redis-cli ping
# → PONG
```

### Verify OTel Collector (with-otel mode only)

```bash
docker logs huadian-otel-collector
# Should show: "Everything is ready. Begin running and processing data."
```

> SigNoz UI (`http://localhost:3301`) is deferred to T-P0-005a.

### Run smoke test

```bash
./scripts/smoke.sh               # Core check (PG + Redis)
./scripts/smoke.sh --with-otel   # Also check OTel Collector
```

## Step 4: Run migrations

```bash
pnpm db:migrate
```

## Step 5: Start dev servers

```bash
pnpm dev
# → API at http://localhost:4000/graphql
# → Web at http://localhost:3000
```

## Step 6: Verify build

```bash
pnpm build          # TS packages
uv run --project services/pipeline python -c "import huadian_pipeline; print('ok')"
```

## Common commands

| Command | Effect |
|---------|--------|
| `make up` | Start all Docker services (full stack) |
| `make up-with-otel` | Start PG + Redis + OTel Collector (trace → stdout) |
| `make down` | Stop all Docker services |
| `make reset-db` | Drop & recreate database |
| `make smoke` | Run smoke tests |
| `pnpm dev` | Start API + Web dev servers |
| `pnpm lint` | Run ESLint + ruff |
| `pnpm typecheck` | Run tsc + basedpyright |
| `pnpm test` | Run vitest + pytest |
| `pnpm codegen` | Regenerate cross-language types |
| `./scripts/gen-types.sh` | Full codegen pipeline (zod → JSON Schema → Pydantic) |
| `./scripts/dev.sh` | Environment pre-check + start dev |

## Claude Code / Cowork session continuation

See [`CLAUDE.md §8`](../../CLAUDE.md#8-会话接续模板) for the session handoff template.
Agent role definitions are in [`.claude/agents/`](../../.claude/agents/).

## CI known limitations

- **CI PostgreSQL does not have pgvector**. The CI `services:` block uses `postgis/postgis:16-3.4` (no custom build) for speed. The custom image with pgvector is tested separately in the "docker smoke" step.
- **Any test that depends on `vector` columns must be skipped in CI**:
  ```typescript
  describe.skipIf(process.env.CI === "true")("pgvector tests", () => { ... });
  ```
  Or use a dedicated docker job with the custom PG image.
- This constraint will be revisited when the QA engineer sets up integration test infrastructure.

## Troubleshooting

### PG extensions missing after `docker compose up`

Init scripts in `db/init/` only run on **first** container start (empty volume).
If you added containers before the init scripts existed:

```bash
make down
docker volume rm huadian-dev_pgdata
make up
```

### PostGIS version mismatch

If `apt-cache policy postgresql-16-postgis-3` inside the PG container resolves
to a version outside 3.3.x–3.4.x range, the Dockerfile may need a pinned version:

```dockerfile
RUN apt-get install -y postgresql-16-postgis-3=3.4.*
```

Check with:
```bash
docker exec huadian-postgres dpkg -l | grep postgis
```

### pnpm install hangs or fails

```bash
# Clear pnpm store and retry
pnpm store prune
rm -rf node_modules
pnpm install
```

If behind a corporate proxy, set `HTTPS_PROXY` before install.

### uv sync fails

```bash
# Ensure Python 3.12 is active
python3 --version

# If using pyenv, ensure shims are set
pyenv local 3.12

# Retry
uv sync --all-packages
```

### pre-commit hook not running on commit

```bash
# Verify hook exists
ls -la .git/hooks/pre-commit

# If missing, reinstall
pre-commit install

# Test manually
pre-commit run --all-files
```

### Port conflicts

| Service | Default host port | Fix |
|---------|------------------|-----|
| PostgreSQL | 5433 | `HUADIAN_PG_PORT=5555 make up` + update `DATABASE_URL` |
| Redis | 6380 | `HUADIAN_REDIS_PORT=6666 make up` + update `REDIS_URL` |
| API | 4000 | Set `PORT=4001` in `.env.local` |
| Web | 3000 | Next.js auto-increments to 3001 |
| OTel gRPC | 4317 | `lsof -i :4317` |
| OTel HTTP | 4318 | `lsof -i :4318` |

### pre-commit gitleaks false positive

If gitleaks flags a test fixture or example value, add it to `.gitleaksignore` (create if needed).

### Docker build fails for PG image

The custom PG image (`docker/postgres/Dockerfile`) builds from `pgvector/pgvector:pg16`
and installs PostGIS via apt. If the build fails:

```bash
# Check what PostGIS version apt resolves to
docker run --rm pgvector/pgvector:pg16 apt-cache policy postgresql-16-postgis-3

# If version mismatch, pin explicitly in Dockerfile
```
