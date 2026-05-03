"""Tests for LowerBoundInvariant — entities lacking ≥ N attrs."""

from __future__ import annotations

import pytest

from framework.invariant_scaffold import LowerBoundInvariant


@pytest.mark.asyncio
async def test_no_violations_when_no_entities_below_threshold(fake_port):
    fake_port.fetch_return = []
    inv = LowerBoundInvariant(
        name="V9",
        description="every active person has ≥1 primary",
        sql="SELECT person_id FROM persons WHERE NOT EXISTS (...)",
        min_count=1,
    )
    assert await inv.query_violations(fake_port) == []


@pytest.mark.asyncio
async def test_each_offending_entity_row_becomes_violation(fake_port):
    fake_port.fetch_return = [
        {"person_id": "p1"},
        {"person_id": "p2"},
        {"person_id": "p3"},
    ]
    inv = LowerBoundInvariant(
        name="V9",
        description="...",
        sql="...",
        min_count=1,
        violation_explanation_fmt="person {person_id} has no primary",
    )
    violations = await inv.query_violations(fake_port)
    assert len(violations) == 3
    assert "p1" in violations[0].explanation
    assert "p3" in violations[2].explanation


@pytest.mark.asyncio
async def test_min_count_property_exposes_documented_threshold(fake_port):  # noqa: ARG001
    inv = LowerBoundInvariant(
        name="V9",
        description="...",
        sql="...",
        min_count=2,
    )
    assert inv.min_count == 2
