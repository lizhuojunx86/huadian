.PHONY: up up-with-otel down dev lint typecheck test build smoke reset-db codegen install clean

# ── Dependencies ──────────────────────────────────────────────
install:
	pnpm install
	uv sync --all-packages

# ── Docker ────────────────────────────────────────────────────
up:
	docker compose -f docker/compose.dev.yml up -d

up-with-otel:
	docker compose -f docker/compose.dev.yml --profile observability up -d

down:
	docker compose -f docker/compose.dev.yml down

# ── Development ───────────────────────────────────────────────
dev:
	pnpm dev

# ── Quality gates ─────────────────────────────────────────────
lint:
	pnpm lint

typecheck:
	pnpm typecheck

test:
	pnpm test

build:
	pnpm build

codegen:
	pnpm codegen

# ── Database ──────────────────────────────────────────────────
reset-db:
	./scripts/db-reset.sh

# ── Smoke test ────────────────────────────────────────────────
smoke:
	./scripts/smoke.sh

# ── Cleanup ───────────────────────────────────────────────────
clean:
	pnpm clean
