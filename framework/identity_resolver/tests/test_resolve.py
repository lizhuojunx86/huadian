"""Smoke tests for framework.identity_resolver.resolve — end-to-end orchestration.

These tests use a fake :class:`EntityLoader` to drive the orchestration
without a database. Goal: prove the contract (load → score → group →
package), not exercise R1-R6 (those are tested in test_rules.py).
"""

from __future__ import annotations

import pytest

from framework.identity_resolver import (
    EntitySnapshot,
    build_score_pair_context,
    resolve_identities,
)
from framework.identity_resolver.resolve import EntityLoader


class _FakeLoader(EntityLoader):
    """In-memory EntityLoader for tests."""

    def __init__(self, entities: list[EntitySnapshot]) -> None:
        self._entities = entities

    async def load_all(self) -> list[EntitySnapshot]:
        return list(self._entities)


def _e(id, name, slug=None, surface=None):  # noqa: A002
    return EntitySnapshot(
        id=id,
        name=name,
        slug=slug or name,
        surface_forms=set(surface) if surface else {name},
        created_at="2026-01-01T00:00:00Z",
    )


@pytest.mark.asyncio
async def test_resolve_identities_with_zero_entities_returns_empty_result():
    loader = _FakeLoader([])
    ctx = build_score_pair_context()
    result = await resolve_identities(loader=loader, score_context=ctx)
    assert result.total_entities == 0
    assert result.merge_groups == []
    assert result.hypotheses == []
    assert result.blocked_merges == []
    assert result.run_id  # UUID populated even on empty input


@pytest.mark.asyncio
async def test_resolve_identities_groups_entities_with_overlapping_surfaces():
    """Two entities sharing 'X' should produce ≥1 merge group via R1."""
    a = _e("a", "周成王", surface={"周成王", "成王"})
    b = _e("b", "成王传", surface={"成王传", "成王"})
    loader = _FakeLoader([a, b])
    ctx = build_score_pair_context()
    result = await resolve_identities(loader=loader, score_context=ctx)
    assert result.total_entities == 2
    # R1 should fire on the shared "成王" → 1 merge group
    assert len(result.merge_groups) == 1
    g = result.merge_groups[0]
    members = {g.canonical_id, *g.merged_ids}
    assert members == {"a", "b"}
