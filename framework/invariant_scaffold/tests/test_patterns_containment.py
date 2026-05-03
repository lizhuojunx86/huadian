"""Tests for ContainmentInvariant — set A ⊆ set B with optional Python predicate."""

from __future__ import annotations

import pytest

from framework.invariant_scaffold import ContainmentInvariant


@pytest.mark.asyncio
async def test_no_predicate_treats_every_returned_row_as_violation(fake_port):
    """When predicate is None the SQL has done the NOT EXISTS filter."""
    fake_port.fetch_return = [
        {"id": "1", "name": "X"},
        {"id": "2", "name": "Y"},
    ]
    inv = ContainmentInvariant(
        name="V8b",
        description="...",
        sql="SELECT a.id, a.name FROM a WHERE NOT EXISTS (...)",
        violation_explanation_fmt="row {id} ({name}) violates containment",
    )
    violations = await inv.query_violations(fake_port)
    assert len(violations) == 2
    assert "1 (X)" in violations[0].explanation


@pytest.mark.asyncio
async def test_sync_predicate_filters_passing_rows(fake_port):
    """Predicate True = contained = passes; False = violation."""
    fake_port.fetch_return = [
        {"slug": "u4e00"},
        {"slug": "bad-slug"},
        {"slug": "u5b50"},
    ]
    inv = ContainmentInvariant(
        name="slug_format",
        description="...",
        sql="...",
        in_python_predicate=lambda row: row["slug"].startswith("u"),
    )
    violations = await inv.query_violations(fake_port)
    assert len(violations) == 1
    assert violations[0].row_data["slug"] == "bad-slug"


@pytest.mark.asyncio
async def test_async_predicate_is_awaited_via_inspect_isawaitable(fake_port):
    """Sprint P DGF-O-04 patch — inspect.isawaitable detects coroutines."""
    fake_port.fetch_return = [{"slug": "ok"}, {"slug": "fail"}]

    async def async_pred(row):
        return row["slug"] == "ok"

    inv = ContainmentInvariant(
        name="async_test",
        description="...",
        sql="...",
        in_python_predicate=async_pred,
    )
    violations = await inv.query_violations(fake_port)
    assert len(violations) == 1
    assert violations[0].row_data["slug"] == "fail"


@pytest.mark.asyncio
async def test_from_template_classmethod_constructs_same_object(fake_port):
    """Convenience classmethod is purely declarative sugar over __init__."""
    inv = ContainmentInvariant.from_template(
        name="t",
        description="d",
        sql="select 1",
        violation_explanation_fmt="x",
        severity="warning",
    )
    fake_port.fetch_return = [{"id": "x"}]
    violations = await inv.query_violations(fake_port)
    assert inv.severity == "warning"
    assert len(violations) == 1
