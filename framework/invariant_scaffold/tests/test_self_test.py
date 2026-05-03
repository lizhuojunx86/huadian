"""Tests for SelfTestRunner — transactional injection + always-rollback."""

from __future__ import annotations

import pytest

from framework.invariant_scaffold import Invariant, SelfTestRunner
from framework.invariant_scaffold.port import DBPort
from framework.invariant_scaffold.types import Violation


class _AlwaysHasInjected(Invariant):
    """Invariant that returns the injected violation on every run."""

    async def query_violations(self, port: DBPort) -> list[Violation]:  # noqa: ARG002
        return [
            Violation(
                invariant_name=self.name,
                row_data={"injected": True},
                explanation="injected violation found",
            )
        ]


class _SelfTestImpl:
    """Minimal SelfTest impl matching the Protocol shape."""

    def __init__(self, name: str, invariant_name: str) -> None:
        self.name = name
        self.invariant_name = invariant_name
        self.setup_calls = 0

    async def setup_violation(self, port: DBPort) -> None:
        self.setup_calls += 1
        await port.execute("INSERT INTO ... -- inject")

    def expected_violation_predicate(self, violation: Violation) -> bool:
        return violation.row_data.get("injected") is True


@pytest.mark.asyncio
async def test_self_test_runs_setup_inside_transaction_and_always_rolls_back(fake_port):
    inv = _AlwaysHasInjected("v8", "...")
    runner = SelfTestRunner(fake_port, [inv])
    st = _SelfTestImpl("v8_self_test", "v8")

    result = await runner.verify(st)

    assert result.caught is True
    # Setup must have run exactly once
    assert st.setup_calls == 1
    # The transaction context manager was entered exactly once
    assert fake_port.transaction_entered == 1
    # The execute (INSERT injection) ran inside that transaction
    assert len(fake_port.execute_calls) == 1
