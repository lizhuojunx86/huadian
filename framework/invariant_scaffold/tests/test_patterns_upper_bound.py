"""Tests for UpperBoundInvariant — count > N detection."""

from __future__ import annotations

import pytest

from framework.invariant_scaffold import UpperBoundInvariant


@pytest.mark.asyncio
async def test_returns_no_violations_when_query_returns_empty(fake_port):
    fake_port.fetch_return = []
    inv = UpperBoundInvariant(
        name="V8",
        description="must be empty",
        sql="SELECT person_id, COUNT(*) cnt FROM ...",
        max_count=0,
    )
    violations = await inv.query_violations(fake_port)
    assert violations == []
    # SQL was called with max_count as positional arg (per pattern contract)
    assert fake_port.fetch_calls[0][1] == (0,)


@pytest.mark.asyncio
async def test_each_returned_row_becomes_one_violation(fake_port):
    fake_port.fetch_return = [
        {"person_id": "p1", "cnt": 3},
        {"person_id": "p2", "cnt": 5},
    ]
    inv = UpperBoundInvariant(
        name="V8",
        description="primaries",
        sql="...",
        max_count=1,
        violation_explanation_fmt="person {person_id} has {cnt} primaries",
    )
    violations = await inv.query_violations(fake_port)
    assert len(violations) == 2
    assert "p1 has 3" in violations[0].explanation
    assert "p2 has 5" in violations[1].explanation


@pytest.mark.asyncio
async def test_explanation_falls_back_to_repr_when_fmt_missing_key(fake_port):
    fake_port.fetch_return = [{"unexpected_field": "x"}]
    inv = UpperBoundInvariant(
        name="V8",
        description="...",
        sql="...",
        violation_explanation_fmt="person {person_id} has {cnt}",
    )
    violations = await inv.query_violations(fake_port)
    assert len(violations) == 1
    assert "missing key" in violations[0].explanation
