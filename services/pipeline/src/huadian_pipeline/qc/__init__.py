"""华典 QA runtime — TraceGuard Port/Adapter (ADR-004, T-TG-002).

Business code should import only from this module. The upstream
`guardian` package must never appear in an import statement outside
`_imports.py` (enforced by review + the contract tests).
"""

from __future__ import annotations

from .action_map import (
    TG_ACTION_SET,
    ActionEscalator,
    ActionType,
    UnknownTGActionError,
)
from .adapter import TraceGuardAdapter
from .audit import AuditSink
from .mock import MockTraceGuardPort
from .policy import (
    ActionPolicy,
    PolicyConfigError,
    PolicyDefaults,
    PolicyMode,
    max_severity,
)
from .port import TraceGuardPort
from .rule_registry import (
    DuplicateRuleIdError,
    RegisteredRule,
    RuleFn,
    RuleRegistry,
    RuleSet,
)
from .types import (
    CheckpointInput,
    CheckpointResult,
    CheckpointStatus,
    Severity,
    Violation,
)

__all__ = [
    "ActionEscalator",
    "ActionPolicy",
    "ActionType",
    "AuditSink",
    "CheckpointInput",
    "CheckpointResult",
    "CheckpointStatus",
    "DuplicateRuleIdError",
    "MockTraceGuardPort",
    "PolicyConfigError",
    "PolicyDefaults",
    "PolicyMode",
    "RegisteredRule",
    "RuleFn",
    "RuleRegistry",
    "RuleSet",
    "Severity",
    "TG_ACTION_SET",
    "TraceGuardAdapter",
    "TraceGuardPort",
    "UnknownTGActionError",
    "Violation",
    "max_severity",
]
