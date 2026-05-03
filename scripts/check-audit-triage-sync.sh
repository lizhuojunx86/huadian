#!/usr/bin/env bash
# ============================================================
# Sprint R T-V03-FW-006 — services↔framework/audit_triage sync warning hook
# ============================================================
#
# Purpose:
#   When the production TypeScript triage implementation
#   (services/api/src/services/triage.* + resolvers/triage.* + schema/triage.*
#   + tests/triage.*) is staged for commit but
#   framework/audit_triage/examples/huadian_classics/ has NO staged change,
#   emit a warning to stderr.
#
#   This is informational only — exit 0 always. The check is a "did you
#   forget?" reminder, not a hard gate. Cross-stack abstraction sync (per
#   methodology/02 v0.1.1 §13) is the architect's responsibility, not
#   automated.
#
# How pre-commit invokes this:
#   The hook config (see .pre-commit-config.yaml) sets `pass_filenames: true`
#   plus a `files:` regex that ensures this script only fires when at least
#   one staged file matches services/api triage* OR framework/audit_triage/.
#   Pre-commit then passes the matching staged files as $@.
#
# Exit code: always 0 (informational warning only).
# ============================================================

set -u  # unset vars are errors; intentionally NOT -e (we want to continue)

# Categorize the staged files passed by pre-commit.
prod_changed=0
fw_example_changed=0
fw_core_changed=0

for f in "$@"; do
    case "$f" in
        services/api/src/services/triage.*|\
        services/api/src/resolvers/triage.*|\
        services/api/src/schema/triage.*|\
        services/api/tests/triage.*)
            prod_changed=1
            ;;
        framework/audit_triage/examples/huadian_classics/*)
            fw_example_changed=1
            ;;
        framework/audit_triage/*)
            fw_core_changed=1
            ;;
    esac
done

# Warn only when production triage changed AND framework example did NOT.
# (Framework core changes alone don't warrant a warning — the abstraction
# may legitimately evolve ahead of its huadian_classics reference impl.)
if [ "$prod_changed" -eq 1 ] && [ "$fw_example_changed" -eq 0 ]; then
    cat >&2 <<'WARN'

⚠️  services↔framework/audit_triage sync warning (Sprint R T-V03-FW-006)

You are committing changes to services/api/.../triage.* (TypeScript production)
without any change to framework/audit_triage/examples/huadian_classics/.

Per methodology/02-sprint-governance-pattern.md v0.1.1 §13 (跨 stack 抽象 pattern),
the framework Python reference implementation should track production behavior
within the same commit (or at minimum the same sprint).

Please review whether one of the following applies and act accordingly:

  1. SQL changed in production       → mirror in asyncpg_store.py SQL constants
  2. Business logic changed           → mirror in framework/audit_triage/service.py
  3. New historian added (yaml)       → no framework change needed (yaml-loaded)
  4. Pure refactor / no behavior Δ    → ack with `git commit --no-verify` is OK
                                        (or just commit again — this is a warning,
                                         not a gate)

If you are intentionally letting production drift from framework abstraction,
please document the divergence in framework/audit_triage/examples/huadian_classics/
README.md §"已知偏离" (create the section if absent).

Continuing commit anyway (this is an informational warning, not a gate).

WARN
fi

# Always exit 0 — this is informational only.
exit 0
