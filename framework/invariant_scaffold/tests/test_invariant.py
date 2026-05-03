"""Tests for framework.invariant_scaffold.invariant — ABC + run() wrapping."""

from __future__ import annotations

import pytest

from framework.invariant_scaffold import Invariant
from framework.invariant_scaffold.port import DBPort
from framework.invariant_scaffold.types import Violation


class _PassingInvariant(Invariant):
    async def query_violations(self, port: DBPort) -> list[Violation]:  # noqa: ARG002
        return []


class _FailingInvariant(Invariant):
    async def query_violations(self, port: DBPort) -> list[Violation]:  # noqa: ARG002
        return [
            Violation(invariant_name=self.name, row_data={"x": 1}, explanation="x"),
            Violation(invariant_name=self.name, row_data={"x": 2}, explanation="y"),
        ]


class _RaisingInvariant(Invariant):
    async def query_violations(self, port: DBPort) -> list[Violation]:  # noqa: ARG002
        raise RuntimeError("simulated DB error")


@pytest.mark.asyncio
async def test_run_wraps_zero_violations_as_passing():
    inv = _PassingInvariant("p1", "always passes")
    result = await inv.run(port=None)  # type: ignore[arg-type]
    assert result.passed is True
    assert result.violations == []
    assert result.duration_ms >= 0
    assert result.invariant_name == "p1"


@pytest.mark.asyncio
async def test_run_wraps_violations_as_failing_and_counts():
    inv = _FailingInvariant("f1", "always fails", severity="warning")
    result = await inv.run(port=None)  # type: ignore[arg-type]
    assert result.passed is False
    assert result.violation_count == 2
    assert result.severity == "warning"


@pytest.mark.asyncio
async def test_run_catches_query_exceptions_and_returns_failed_result():
    """Exception inside query_violations must NOT propagate — converted to fail row."""
    inv = _RaisingInvariant("r1", "raises")
    result = await inv.run(port=None)  # type: ignore[arg-type]
    assert result.passed is False
    assert len(result.violations) == 1
    assert "RuntimeError" in result.violations[0].explanation
