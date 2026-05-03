"""Tests for CardinalityBoundInvariant — exact_total + per_entity_range modes."""

from __future__ import annotations

import pytest

from framework.invariant_scaffold import CardinalityBoundInvariant


@pytest.mark.asyncio
async def test_exact_total_passes_when_count_matches_expected(fake_port):
    fake_port.fetchval_return = 22
    inv = CardinalityBoundInvariant(
        name="V_count",
        description="22 chapters total",
        sql="SELECT COUNT(*) FROM chapters",
        mode="exact_total",
        expected_count=22,
    )
    assert await inv.query_violations(fake_port) == []


@pytest.mark.asyncio
async def test_exact_total_violates_when_count_drifts(fake_port):
    fake_port.fetchval_return = 21
    inv = CardinalityBoundInvariant(
        name="V_count",
        description="...",
        sql="...",
        mode="exact_total",
        expected_count=22,
    )
    violations = await inv.query_violations(fake_port)
    assert len(violations) == 1
    assert violations[0].row_data == {"count": 21, "expected": 22}


@pytest.mark.asyncio
async def test_per_entity_range_emits_violation_per_out_of_range_row(fake_port):
    """slug_no_collision style: max=1 → cnt > 1 violations come back as rows."""
    fake_port.fetch_return = [
        {"slug": "x", "cnt": 2},
        {"slug": "y", "cnt": 3},
    ]
    inv = CardinalityBoundInvariant(
        name="V_uniq",
        description="...",
        sql="SELECT slug, COUNT(*) cnt FROM ...",
        mode="per_entity_range",
        max_count=1,
        violation_explanation_fmt="{slug} appears {cnt} times",
    )
    violations = await inv.query_violations(fake_port)
    assert len(violations) == 2
    assert "x appears 2 times" in violations[0].explanation
