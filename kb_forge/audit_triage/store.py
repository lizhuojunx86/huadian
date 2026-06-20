"""TriageStore Protocol — DB I/O for the audit_triage framework.

A ``TriageStore`` impl is responsible for reading the pending review queue
across one or more source tables and writing decision audit rows. It is the
**only** place the framework touches the database; everything else (service
layer / authz / reasons) is pure Python.

Reference impl: ``examples/huadian_classics/asyncpg_store.py``.

Cross-domain contract (read this when implementing your own store):
    1. ``list_pending`` MUST honor the surface-cluster + FIFO ordering:
       (a) compute the earliest ``pending_since`` per surface across
           all source tables → cluster anchor;
       (b) order rows by ``(cluster_anchor ASC, surface ASC,
           pending_since ASC)``;
       (c) apply ``limit`` / ``offset`` AFTER ordering.

       This is the V1 inbox algorithm (per ADR-027 §2.3). Domains that
       prefer a different ordering should document it in their store.

    2. ``insert_decision`` MUST honor the multi-row audit rule:
       multiple rows per ``source_id`` are allowed (defer → revisit →
       approve). Do NOT enforce uniqueness on ``source_id`` alone.

    3. ``find_decisions_for_surface`` powers the hint banner — it MUST
       include rows where ``surface_snapshot`` matches even if the
       source row has been mutated since.

    4. All methods MUST be ``async`` to fit the framework's
       asyncio-first stance (consistent with identity_resolver +
       invariant_scaffold v0.2).

License: Apache 2.0
Source: extracted from services/api/src/services/triage.service.ts.
"""

from __future__ import annotations

from typing import Protocol, runtime_checkable

from .types import (
    DecisionRecord,
    ItemKind,
    PendingItem,
    RecordDecisionInput,
)


@runtime_checkable
class TriageStore(Protocol):
    """DB-facing Protocol for the pending review queue + audit table.

    All methods are async. Implementations may use any async DB driver
    (asyncpg / aiosqlite / mock-for-tests). The framework treats the
    store as a black box — it does not assume Postgres or any specific
    schema beyond the abstract contract documented per method.
    """

    # -----------------------------------------------------------------
    # Pending queue reads
    # -----------------------------------------------------------------

    async def list_pending(
        self,
        *,
        limit: int = 50,
        offset: int = 0,
        filter_by_kind: ItemKind | None = None,
        filter_by_surface: str | None = None,
    ) -> tuple[list[PendingItem], int]:
        """Return ``(items, total_count)`` for the inbox queue.

        Args:
            limit:              max rows to return (post-filter, post-sort).
            offset:             skip first ``offset`` rows.
            filter_by_kind:     narrow to one ItemKind. ``None`` = all.
            filter_by_surface:  exact-match surface filter (used by hint
                                banner cross-reference). ``None`` = all.

        Returns:
            A 2-tuple ``(items, total_count)`` where ``total_count`` is
            the count BEFORE limit/offset (used for pagination UI).

        Ordering: surface-cluster + FIFO inside cluster. See module
        docstring §1.
        """
        ...

    async def find_pending_by_id(self, item_id: str) -> PendingItem | None:
        """Return the pending item by its composite ``"<kind>:<source_id>"``
        identifier, or ``None`` if no pending row matches.

        Returns ``None`` (not raise) for both:
            - malformed ``item_id``
            - well-formed ``item_id`` whose source row is no longer pending
              (e.g. someone else just applied a decision)
        """
        ...

    async def find_next_pending_excluding(
        self,
        kind: ItemKind,
        source_id: str,
    ) -> str | None:
        """Return the next pending item id (composite) **excluding** the
        just-decided ``(kind, source_id)`` pair, or ``None`` if the queue
        is empty.

        Same ordering as :meth:`list_pending`. Used by
        :func:`record_decision` to compute the inbox redirect target —
        per V1 zero-downstream, the just-decided row would otherwise stay
        at the queue head, so we exclude it client-side.
        """
        ...

    # -----------------------------------------------------------------
    # Decision audit reads
    # -----------------------------------------------------------------

    async def find_decisions_for_source(
        self,
        source_table: str,
        source_id: str,
        *,
        limit: int = 100,
    ) -> list[DecisionRecord]:
        """Return all decision rows for ``(source_table, source_id)``,
        ordered ``decided_at DESC`` (latest first)."""
        ...

    async def find_decisions_for_surface(
        self,
        surface: str,
        *,
        limit: int = 10,
    ) -> list[DecisionRecord]:
        """Return decision rows whose ``surface_snapshot == surface``,
        ordered ``decided_at DESC``. Powers the hint banner
        (ADR-027 §2.3)."""
        ...

    # -----------------------------------------------------------------
    # Decision audit write
    # -----------------------------------------------------------------

    async def insert_decision(
        self,
        item: PendingItem,
        input: RecordDecisionInput,  # noqa: A002 — public API; renaming would break consumers
    ) -> DecisionRecord:
        """INSERT a decision audit row and return it (with id +
        decided_at populated by the DB).

        Implementations MUST:
            - Set ``surface_snapshot`` to ``item.surface`` at write time
              (NOT the surface read at decision time) so the audit row
              freezes the value for hint-banner cross-reference.
            - Set ``downstream_applied=False`` (V0.1 zero-downstream).
            - Allow multiple rows per ``source_id`` (defer → revisit
              → approve workflow).
        """
        ...
