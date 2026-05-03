"""Tests for OrphanDetectionInvariant — count_only vs row mode."""

from __future__ import annotations

import pytest

from framework.invariant_scaffold import OrphanDetectionInvariant


@pytest.mark.asyncio
async def test_count_only_with_zero_orphans_passes(fake_port):
    fake_port.fetchval_return = 0
    inv = OrphanDetectionInvariant(
        name="V11",
        description="orphan refs",
        sql="SELECT COUNT(*) FROM ...",
        count_only=True,
    )
    assert await inv.query_violations(fake_port) == []


@pytest.mark.asyncio
async def test_count_only_with_nonzero_collapses_to_single_violation(fake_port):
    fake_port.fetchval_return = 7
    inv = OrphanDetectionInvariant(
        name="V11",
        description="...",
        sql="...",
        count_only=True,
        violation_explanation_fmt="{count} orphan rows detected",
    )
    violations = await inv.query_violations(fake_port)
    assert len(violations) == 1
    assert violations[0].row_data["count"] == 7
    assert "7 orphan" in violations[0].explanation


@pytest.mark.asyncio
async def test_row_mode_emits_one_violation_per_orphan_row(fake_port):
    fake_port.fetch_return = [
        {"orphan_id": "o1", "ref_table": "merge_log"},
        {"orphan_id": "o2", "ref_table": "merge_log"},
    ]
    inv = OrphanDetectionInvariant(
        name="V11",
        description="...",
        sql="SELECT orphan_id, ref_table FROM ...",
        count_only=False,
        violation_explanation_fmt="orphan {orphan_id} in {ref_table}",
    )
    violations = await inv.query_violations(fake_port)
    assert len(violations) == 2
    assert "o1 in merge_log" in violations[0].explanation
