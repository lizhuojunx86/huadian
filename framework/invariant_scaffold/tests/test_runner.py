"""Tests for InvariantRunner — register / run_all / assert_all_pass."""

from __future__ import annotations

import pytest

from framework.invariant_scaffold import Invariant, InvariantRunner
from framework.invariant_scaffold.port import DBPort
from framework.invariant_scaffold.types import Violation


class _Pass(Invariant):
    async def query_violations(self, port: DBPort) -> list[Violation]:  # noqa: ARG002
        return []


class _Fail(Invariant):
    async def query_violations(self, port: DBPort) -> list[Violation]:  # noqa: ARG002
        return [Violation(invariant_name=self.name, row_data={}, explanation="bad")]


@pytest.mark.asyncio
async def test_run_all_aggregates_results_per_invariant(fake_port):
    runner = InvariantRunner(fake_port)
    runner.register_all([_Pass("p1", "..."), _Fail("f1", "...")])
    report = await runner.run_all()
    assert len(report.results) == 2
    by_name = {r.invariant_name: r.passed for r in report.results}
    assert by_name == {"p1": True, "f1": False}


def test_register_collision_raises_value_error(fake_port):
    runner = InvariantRunner(fake_port)
    runner.register(_Pass("v1", "..."))
    with pytest.raises(ValueError, match="collision"):
        runner.register(_Fail("v1", "..."))


@pytest.mark.asyncio
async def test_assert_all_pass_raises_on_critical_failure(fake_port):
    runner = InvariantRunner(fake_port)
    runner.register(_Fail("v_critical", "...", severity="critical"))
    report = await runner.run_all()
    with pytest.raises(AssertionError, match="failed"):
        runner.assert_all_pass(report)


@pytest.mark.asyncio
async def test_assert_all_pass_ignores_warning_unless_promoted(fake_port):
    runner = InvariantRunner(fake_port)
    runner.register(_Fail("v_warn", "...", severity="warning"))
    report = await runner.run_all()
    # Default: warning failures don't raise
    runner.assert_all_pass(report)
    # treat_warnings_as_errors=True: now they raise
    with pytest.raises(AssertionError):
        runner.assert_all_pass(report, treat_warnings_as_errors=True)
