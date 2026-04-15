#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# HuaDian — Development environment pre-check & startup
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

errors=0

check() {
  local name="$1" cmd="$2" expected="$3" fix="$4"
  if eval "$cmd" &>/dev/null; then
    printf "${GREEN}✓${NC} %s\n" "$name"
  else
    printf "${RED}✗${NC} %s — %s\n" "$name" "$expected"
    printf "  ${YELLOW}fix: %s${NC}\n" "$fix"
    errors=$((errors + 1))
  fi
}

echo "── HuaDian dev environment check ──"
echo

# Node.js ≥ 20
check "Node.js ≥ 20" \
  "[[ \$(node -v 2>/dev/null | sed 's/v//' | cut -d. -f1) -ge 20 ]]" \
  "Node.js 20+ required (see .nvmrc)" \
  "nvm install 20 && nvm use 20"

# pnpm
check "pnpm available" \
  "command -v pnpm" \
  "pnpm not found" \
  "corepack enable && corepack prepare pnpm@latest --activate"

# Python ≥ 3.12
check "Python ≥ 3.12" \
  "[[ \$(python3 -c 'import sys; print(sys.version_info.minor)' 2>/dev/null) -ge 12 ]]" \
  "Python 3.12+ required (see .python-version)" \
  "pyenv install 3.12 && pyenv local 3.12"

# uv
check "uv available" \
  "command -v uv" \
  "uv not found" \
  "curl -LsSf https://astral.sh/uv/install.sh | sh"

# Docker
check "Docker running" \
  "docker info" \
  "Docker daemon not running" \
  "open -a Docker  # or: systemctl start docker"

# pre-commit hook installed
check "pre-commit hook installed" \
  "test -f .git/hooks/pre-commit" \
  "pre-commit git hook not installed" \
  "pip install pre-commit --user && pre-commit install"

echo
if [[ $errors -gt 0 ]]; then
  printf "${RED}%d issue(s) found. Fix them before running pnpm dev.${NC}\n" "$errors"
  exit 1
else
  printf "${GREEN}All checks passed.${NC}\n"
  echo
  echo "Starting dev servers..."
  exec pnpm dev
fi
