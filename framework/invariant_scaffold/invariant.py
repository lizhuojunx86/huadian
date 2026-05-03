"""Invariant ABC — base class for all invariants.

Subclass via one of the 5 pattern classes (UpperBound / LowerBound /
Containment / OrphanDetection / CardinalityBound) for common cases, or
implement `query_violations()` directly for ad-hoc invariants.

License: Apache 2.0
Source: HuaDian Sprint O first-cut framework abstraction.
"""

from __future__ import annotations

import time
from abc import ABC, abstractmethod

from .port import DBPort
from .types import InvariantResult, Severity, Violation


class Invariant(ABC):
    """Abstract base for all invariants.

    Required attributes:
        name:          short identifier (e.g. "V8", "no_orphan_target")
        description:   human-readable one-liner

    Optional:
        severity:      "critical" (default) / "warning" / "info"

    Subclasses implement `query_violations(port)` returning a list of
    `Violation`. The framework wraps the call in `run(port)` to provide
    timing + InvariantResult packaging.
    """

    name: str
    description: str
    severity: Severity

    def __init__(
        self,
        name: str,
        description: str,
        severity: Severity = "critical",
    ) -> None:
        self.name = name
        self.description = description
        self.severity = severity

    @abstractmethod
    async def query_violations(self, port: DBPort) -> list[Violation]:
        """Return list of violating rows from the case-domain DB.

        Return empty list to indicate the invariant passed.
        """

    async def run(self, port: DBPort) -> InvariantResult:
        """Run query_violations() with timing + InvariantResult wrapping."""
        start = time.perf_counter()
        try:
            violations = await self.query_violations(port)
        except Exception as exc:  # noqa: BLE001
            duration_ms = (time.perf_counter() - start) * 1000
            return InvariantResult(
                invariant_name=self.name,
                passed=False,
                severity=self.severity,
                violations=[
                    Violation(
                        invariant_name=self.name,
                        row_data={},
                        explanation=f"Invariant query raised exception: {exc!r}",
                    )
                ],
                duration_ms=duration_ms,
                description=self.description,
            )
        duration_ms = (time.perf_counter() - start) * 1000
        return InvariantResult(
            invariant_name=self.name,
            passed=len(violations) == 0,
            severity=self.severity,
            violations=violations,
            duration_ms=duration_ms,
            description=self.description,
        )

    def __repr__(self) -> str:
        return f"<{type(self).__name__} name={self.name!r} severity={self.severity!r}>"
