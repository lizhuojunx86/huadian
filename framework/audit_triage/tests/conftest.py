"""Shared fixtures for framework.audit_triage tests.

Provides a minimal in-memory ``TriageStore`` so the pure-Python service
layer (``record_decision`` validation order, read APIs, inbox redirect)
can be tested without a database. Cross-domain forks can copy this fake
as a starting point for their own store unit tests.

The fake honors the two contracts the service layer depends on:
  * ``insert_decision`` freezes ``surface_snapshot`` to the pending item's
    surface at write time (per store.py contract §2 + ADR-027);
  * multiple decision rows per ``source_id`` are allowed (defer → approve).

License: Apache 2.0
"""

from __future__ import annotations

from collections.abc import Callable
from datetime import UTC, datetime, timedelta

import pytest

from framework.audit_triage import (
    DecisionRecord,
    ItemKind,
    PendingItem,
    RecordDecisionInput,
    StaticAllowlist,
)

#: Deterministic base time; per-row offsets keep ordering stable in tests.
EPOCH = datetime(2026, 1, 1, tzinfo=UTC)


class FakeTriageStore:
    """In-memory ``TriageStore`` implementation for unit tests.

    Seeded with a list of :class:`PendingItem`; records decisions into
    ``self.decisions``. Reproduces the ordering contract (FIFO by
    ``pending_since``, then ``surface``) at a level sufficient for
    service-layer tests.
    """

    def __init__(self, pending: list[PendingItem]) -> None:
        self._pending: dict[str, PendingItem] = {p.item_id: p for p in pending}
        self.decisions: list[DecisionRecord] = []
        self._id_counter = 0

    def _ordered(self) -> list[PendingItem]:
        return sorted(
            self._pending.values(),
            key=lambda p: (p.pending_since, p.surface, p.item_id),
        )

    async def list_pending(
        self,
        *,
        limit: int = 50,
        offset: int = 0,
        filter_by_kind: ItemKind | None = None,
        filter_by_surface: str | None = None,
    ) -> tuple[list[PendingItem], int]:
        rows = self._ordered()
        if filter_by_kind is not None:
            rows = [r for r in rows if r.kind == filter_by_kind]
        if filter_by_surface is not None:
            rows = [r for r in rows if r.surface == filter_by_surface]
        total = len(rows)
        return rows[offset : offset + limit], total

    async def find_pending_by_id(self, item_id: str) -> PendingItem | None:
        return self._pending.get(item_id)

    async def find_next_pending_excluding(
        self,
        kind: ItemKind,
        source_id: str,
    ) -> str | None:
        excluded = f"{kind}:{source_id}"
        for row in self._ordered():
            if row.item_id != excluded:
                return row.item_id
        return None

    async def find_decisions_for_source(
        self,
        source_table: str,
        source_id: str,
        *,
        limit: int = 100,
    ) -> list[DecisionRecord]:
        rows = [
            d for d in self.decisions if d.source_table == source_table and d.source_id == source_id
        ]
        rows.sort(key=lambda d: d.decided_at, reverse=True)
        return rows[:limit]

    async def find_decisions_for_surface(
        self,
        surface: str,
        *,
        limit: int = 10,
    ) -> list[DecisionRecord]:
        rows = [d for d in self.decisions if d.surface_snapshot == surface]
        rows.sort(key=lambda d: d.decided_at, reverse=True)
        return rows[:limit]

    async def insert_decision(
        self,
        item: PendingItem,
        input: RecordDecisionInput,  # noqa: A002 — mirrors public API name
    ) -> DecisionRecord:
        self._id_counter += 1
        record = DecisionRecord(
            id=f"dec-{self._id_counter}",
            source_table=item.source_table,
            source_id=item.source_id,
            surface_snapshot=item.surface,  # freeze surface at write time
            decision=input.decision,
            historian_id=input.historian_id,
            decided_at=EPOCH + timedelta(seconds=self._id_counter),
            reason_text=input.reason_text,
            reason_source_type=input.reason_source_type,
            historian_commit_ref=input.historian_commit_ref,
            architect_ack_ref=input.architect_ack_ref,
            downstream_applied=False,
        )
        self.decisions.append(record)
        return record


def make_pending(
    item_id: str,
    *,
    kind: str = "seed_mapping",
    source_table: str = "seed_mappings",
    source_id: str | None = None,
    surface: str = "周成王",
    offset_seconds: int = 0,
) -> PendingItem:
    """Build a :class:`PendingItem`; ``source_id`` defaults to the part
    after the colon in ``item_id`` so the two stay consistent."""
    if source_id is None:
        source_id = item_id.split(":", 1)[1]
    return PendingItem(
        item_id=item_id,
        kind=kind,
        source_table=source_table,
        source_id=source_id,
        surface=surface,
        pending_since=EPOCH + timedelta(seconds=offset_seconds),
    )


@pytest.fixture
def make_pending_item() -> Callable[..., PendingItem]:
    return make_pending


@pytest.fixture
def allowlist() -> StaticAllowlist:
    return StaticAllowlist({"chief-historian"})


@pytest.fixture
def store_with_two() -> FakeTriageStore:
    """Two pending items, distinct surfaces, FIFO order s1 → s2."""
    return FakeTriageStore(
        [
            make_pending("seed_mapping:s1", surface="周成王", offset_seconds=0),
            make_pending("seed_mapping:s2", surface="楚成王", offset_seconds=10),
        ]
    )
