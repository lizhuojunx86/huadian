"""Sole ingress point for `guardian` (upstream: pipeline-guardian).

ADR-004 / T-TG-002 §0 hard constraint. Upstream pin:
    pipeline-guardian @ v0.1.0-huadian-baseline
    sha: 0350b0a54ec646a96e3f25949b7ce604284c49eb

RULES
-----
1. Every other file in this package MUST import TraceGuard symbols
   from this module — never `import guardian` elsewhere.
2. Only the four frozen public symbols below may be re-exported:
       evaluate_async, StepOutput, GuardianConfig, GuardianDecision
3. Any deeper import (e.g. `guardian.core.*`, `guardian.validators.*`)
   is a private upstream detail. If we must depend on one, add it
   here with an explicit `# UNSTABLE:` comment and an upgrade note.

Enforced by contract tests in tests/qc/test_traceguard_contract.py.
"""

from __future__ import annotations

from guardian import (  # type: ignore[import-untyped]
    GuardianConfig,
    GuardianDecision,
    StepOutput,
    evaluate_async,
)

# Public surface of this ingress module. Contract tests pin this list.
__all__ = [
    "GuardianConfig",
    "GuardianDecision",
    "StepOutput",
    "evaluate_async",
]

# ---------------------------------------------------------------------------
# Deeper imports (none today). Add below only with justification + upgrade
# risk acknowledged. Pattern:
#
#   # UNSTABLE: relied on `guardian.core.step._normalize` because TG 0.1.0
#   # did not expose normalization at the top level. Remove after TG >= 0.3.
#   from guardian.core.step import _normalize  # type: ignore[import-untyped]
# ---------------------------------------------------------------------------
