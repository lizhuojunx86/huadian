"""Data contracts for the invariant_scaffold framework.

Public types consumed by case-domain code:
    - Severity:        critical / warning / info
    - Violation:       one row that violates an invariant
    - InvariantResult: outcome of running one invariant
    - InvariantReport: aggregate of running multiple invariants
    - SelfTestResult:  outcome of one self-test (verify a violation is caught)

License: Apache 2.0
Source: HuaDian Sprint O first-cut framework abstraction.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Literal

Severity = Literal["critical", "warning", "info"]
"""Invariant severity level.

    critical → must pass for sprint to close (assert fail)
    warning  → reported but does not block (warnings.warn)
    info     → diagnostic / sanity check (e.g. row-count guards)
"""


@dataclass(frozen=True, slots=True)
class Violation:
    """One row that violates an invariant.

    `row_data` is opaque dict from the case-domain SQL — schema is whatever
    the invariant's SELECT returns. `explanation` is a human-readable line
    suitable for inclusion in assertion error messages.
    """

    invariant_name: str
    row_data: dict[str, Any]
    explanation: str


@dataclass(frozen=True, slots=True)
class InvariantResult:
    """Outcome of running one invariant against the DB."""

    invariant_name: str
    passed: bool
    severity: Severity
    violations: list[Violation]
    duration_ms: float
    description: str = ""

    @property
    def violation_count(self) -> int:
        return len(self.violations)

    def format_report(self, max_violations_shown: int = 10) -> str:
        """Multi-line report string for logs / console."""
        status = "PASS" if self.passed else "FAIL"
        header = f"[{status}] {self.invariant_name} ({self.severity}, {self.duration_ms:.1f}ms)"
        if self.passed:
            return header
        lines = [header, f"  {self.violation_count} violation(s):"]
        for v in self.violations[:max_violations_shown]:
            lines.append(f"    - {v.explanation}")
        if self.violation_count > max_violations_shown:
            lines.append(f"    ... and {self.violation_count - max_violations_shown} more")
        return "\n".join(lines)


@dataclass(slots=True)
class InvariantReport:
    """Aggregate report of running an entire invariant suite."""

    results: list[InvariantResult] = field(default_factory=list)
    total_duration_ms: float = 0.0

    @property
    def all_passed(self) -> bool:
        """True iff every invariant passed."""
        return all(r.passed for r in self.results)

    @property
    def critical_failures(self) -> list[InvariantResult]:
        """Failed invariants whose severity is 'critical' (block sprint)."""
        return [r for r in self.results if not r.passed and r.severity == "critical"]

    @property
    def warning_failures(self) -> list[InvariantResult]:
        """Failed invariants whose severity is 'warning' (do not block)."""
        return [r for r in self.results if not r.passed and r.severity == "warning"]

    @property
    def passed_count(self) -> int:
        return sum(1 for r in self.results if r.passed)

    @property
    def failed_count(self) -> int:
        return sum(1 for r in self.results if not r.passed)

    def format_summary(self) -> str:
        """One-line summary suitable for CI / logs."""
        return (
            f"Invariants: {self.passed_count}/{len(self.results)} pass "
            f"({len(self.critical_failures)} critical, "
            f"{len(self.warning_failures)} warning) "
            f"in {self.total_duration_ms:.0f}ms"
        )


@dataclass(frozen=True, slots=True)
class SelfTestResult:
    """Outcome of running one self-test (inject violation + verify catch)."""

    self_test_name: str
    invariant_name: str
    caught: bool  # True iff the injected violation was detected
    duration_ms: float
    detail: str = ""
