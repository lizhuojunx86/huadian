"""InvariantRunner — registers + runs an invariant suite + emits report.

Typical usage at sprint closeout:

    runner = InvariantRunner(port=my_db_port)
    runner.register_all([
        UpperBoundInvariant.from_template(...),
        LowerBoundInvariant.from_template(...),
        ...
    ])

    report = await runner.run_all()
    print(report.format_summary())

    # Inside a pytest fixture: assert no critical failures
    runner.assert_all_pass(report)

License: Apache 2.0
Source: HuaDian Sprint O first-cut framework abstraction.
"""

from __future__ import annotations

import logging
import time

from .invariant import Invariant
from .port import DBPort
from .types import InvariantReport, InvariantResult

logger = logging.getLogger(__name__)


class InvariantRunner:
    """Register invariants + run them as a suite."""

    def __init__(self, port: DBPort) -> None:
        self._port = port
        self._invariants: list[Invariant] = []

    def register(self, invariant: Invariant) -> None:
        """Register a single invariant."""
        if any(i.name == invariant.name for i in self._invariants):
            raise ValueError(f"invariant name collision: {invariant.name!r}")
        self._invariants.append(invariant)

    def register_all(self, invariants: list[Invariant]) -> None:
        """Register multiple invariants (convenience)."""
        for inv in invariants:
            self.register(inv)

    @property
    def invariants(self) -> list[Invariant]:
        """Read-only view of registered invariants."""
        return list(self._invariants)

    async def run_all(self) -> InvariantReport:
        """Run every registered invariant + return aggregated report."""
        if not self._invariants:
            logger.warning("InvariantRunner.run_all() called with no invariants registered")

        start = time.perf_counter()
        results: list[InvariantResult] = []
        for inv in self._invariants:
            logger.debug("Running invariant %s", inv.name)
            result = await inv.run(self._port)
            results.append(result)
            if result.passed:
                logger.info(
                    "[PASS] %s (%s, %.1fms)",
                    result.invariant_name,
                    result.severity,
                    result.duration_ms,
                )
            else:
                logger.warning(
                    "[FAIL] %s (%s): %d violation(s)",
                    result.invariant_name,
                    result.severity,
                    result.violation_count,
                )

        total_ms = (time.perf_counter() - start) * 1000
        return InvariantReport(results=results, total_duration_ms=total_ms)

    async def run_one(self, name: str) -> InvariantResult:
        """Run a single registered invariant by name."""
        for inv in self._invariants:
            if inv.name == name:
                return await inv.run(self._port)
        raise KeyError(f"invariant {name!r} not registered")

    def assert_all_pass(
        self,
        report: InvariantReport,
        *,
        treat_warnings_as_errors: bool = False,
    ) -> None:
        """Raise AssertionError if any critical invariant failed.

        Suitable for use in pytest fixtures or CI gates:

            report = await runner.run_all()
            runner.assert_all_pass(report)

        With `treat_warnings_as_errors=True`, also fails on warning-level
        invariants (useful when promoting a previously-warning invariant
        to mandatory).
        """
        failures = report.critical_failures
        if treat_warnings_as_errors:
            failures = failures + report.warning_failures

        if not failures:
            return

        lines = ["Invariant suite failed:"]
        for r in failures:
            lines.append(r.format_report())
        raise AssertionError("\n".join(lines))
