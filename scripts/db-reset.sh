#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# HuaDian — Database reset
# Delegates to services/api db:reset (R-3: execution lives in services/api)
# Does NOT call drizzle-kit directly.
# ============================================================

echo "[db-reset] Resetting database via @huadian/api..."
pnpm --filter @huadian/api db:reset
echo "[db-reset] Done."
