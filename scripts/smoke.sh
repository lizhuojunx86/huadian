#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# HuaDian — Post-docker smoke test
#
# Usage:
#   ./scripts/smoke.sh               # Core check (PG + Redis)
#   ./scripts/smoke.sh --with-otel   # Also check OTel Collector
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

CHECK_OTEL=false
if [[ "${1:-}" == "--with-otel" ]]; then
  CHECK_OTEL=true
fi

errors=0

smoke() {
  local name="$1" cmd="$2"
  if eval "$cmd" &>/dev/null; then
    printf "${GREEN}✓${NC} %s\n" "$name"
  else
    printf "${RED}✗${NC} %s\n" "$name"
    errors=$((errors + 1))
  fi
}

echo "── HuaDian smoke test ──"
echo

# ── PostgreSQL ─────────────────────────────────────────────────
smoke "PostgreSQL is reachable" \
  "docker exec huadian-postgres pg_isready -U huadian -d huadian"

smoke "Extension: vector" \
  "docker exec huadian-postgres psql -U huadian -d huadian -t -c '\dx' | grep -q vector"

smoke "Extension: postgis" \
  "docker exec huadian-postgres psql -U huadian -d huadian -t -c '\dx' | grep -q postgis"

smoke "Extension: pg_trgm" \
  "docker exec huadian-postgres psql -U huadian -d huadian -t -c '\dx' | grep -q pg_trgm"

# ── Redis ──────────────────────────────────────────────────────
smoke "Redis PONG" \
  "docker exec huadian-redis redis-cli ping | grep -q PONG"

# ── OTel Collector (--with-otel) ───────────────────────────────
if [[ "$CHECK_OTEL" == true ]]; then
  echo
  echo "── OTel Collector ──"

  smoke "OTel Collector running" \
    "docker ps --filter name=huadian-otel-collector --format '{{.Status}}' | grep -q Up"

  # Health extension check (collector-contrib includes health_check by default on :13133)
  smoke "OTel Collector healthy" \
    "docker exec huadian-otel-collector wget -q -O /dev/null http://localhost:13133/ 2>/dev/null || curl -sf http://localhost:13133/ >/dev/null 2>&1"
fi

# ── Summary ────────────────────────────────────────────────────
echo
if [[ $errors -gt 0 ]]; then
  printf "${RED}%d check(s) failed.${NC}\n" "$errors"
  exit 1
else
  printf "${GREEN}All smoke tests passed.${NC}\n"
fi
