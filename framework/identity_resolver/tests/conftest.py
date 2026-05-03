"""Shared pytest fixtures for framework.identity_resolver tests.

These fixtures are intentionally minimal — the goal is to give cross-domain
forks a starting point, not to lock in any case-specific shape. Fixture
naming follows pytest conventions: `make_*` for factories, `sample_*` for
single instances.

License: Apache 2.0
"""

from __future__ import annotations

from typing import Any

import pytest

from framework.identity_resolver import EntitySnapshot

# ---------------------------------------------------------------------------
# Entity factories
# ---------------------------------------------------------------------------


@pytest.fixture
def make_entity():
    """Factory: build an :class:`EntitySnapshot` with sensible defaults.

    Pass any kwargs to override; everything has a default to keep tests
    short.
    """

    def _make(
        id: str = "e-1",  # noqa: A002
        name: str = "周成王",
        slug: str = "zhou-cheng-wang",
        surface_forms: set[str] | None = None,
        created_at: str = "2026-01-01T00:00:00Z",
        domain_attrs: dict[str, Any] | None = None,
        identity_notes: list[str] | None = None,
        seed_match: Any = None,
    ) -> EntitySnapshot:
        return EntitySnapshot(
            id=id,
            name=name,
            slug=slug,
            surface_forms=surface_forms if surface_forms is not None else {name},
            created_at=created_at,
            domain_attrs=domain_attrs,
            identity_notes=identity_notes,
            seed_match=seed_match,
        )

    return _make


@pytest.fixture
def sample_entity_a(make_entity) -> EntitySnapshot:
    return make_entity(
        id="a-1",
        name="周成王",
        slug="zhou-cheng-wang",
        surface_forms={"周成王", "成王", "姬诵"},
        domain_attrs={"dynasty": "周"},
    )


@pytest.fixture
def sample_entity_b(make_entity) -> EntitySnapshot:
    return make_entity(
        id="b-1",
        name="楚成王",
        slug="chu-cheng-wang",
        surface_forms={"楚成王", "成王"},
        domain_attrs={"dynasty": "楚"},
    )
