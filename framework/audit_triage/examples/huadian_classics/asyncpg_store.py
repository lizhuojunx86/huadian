"""HuaDian classics — asyncpg implementation of :class:`TriageStore`.

Mirrors the production TypeScript implementation at
``services/api/src/services/triage.service.ts`` but in Python + asyncpg
+ raw SQL (no Drizzle equivalent needed).

Two source tables in HuaDian:
    seed_mappings           (where ``mapping_status='pending_review'``)
    pending_merge_reviews   (where ``status='pending'``)

Inbox ordering (per ADR-027 §2.3 / V1 surface-cluster + FIFO):
    1. UNION ALL the two source tables under a common projection
    2. Compute earliest pending_since per surface → cluster anchor
    3. Order by ``(cluster_anchor ASC, surface ASC,
                    pending_since ASC, source_id ASC)``
    4. Apply LIMIT / OFFSET

License: Apache 2.0
Source: extracted from services/api/src/services/triage.service.ts
        listPendingItemRows + recordTriageDecision + findNextPendingExcluding.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

from framework.audit_triage import (
    DecisionRecord,
    ItemKind,
    PendingItem,
    RecordDecisionInput,
    encode_item_id,
)

if TYPE_CHECKING:
    import asyncpg

# ---------------------------------------------------------------------------
# SQL — pulled verbatim from production where structurally identical
# ---------------------------------------------------------------------------

_SEED_SELECT = """
    SELECT
        'seed_mapping'::text                     AS kind,
        'seed_mappings'::text                    AS source_table,
        sm.id                                    AS source_id,
        de.primary_name                          AS surface,
        sm.mapping_created_at                    AS pending_since,
        sm.target_entity_id                      AS raw_target_entity_id,
        sm.dictionary_entry_id                   AS raw_dictionary_entry_id,
        sm.confidence::text                      AS raw_confidence,
        sm.mapping_method                        AS raw_mapping_method,
        sm.notes                                 AS raw_mapping_notes,
        NULL::uuid                               AS raw_person_a_id,
        NULL::uuid                               AS raw_person_b_id,
        NULL::text                               AS raw_proposed_rule,
        NULL::text                               AS raw_guard_type,
        NULL::jsonb                              AS raw_guard_payload,
        NULL::jsonb                              AS raw_evidence
    FROM seed_mappings sm
    JOIN dictionary_entries de ON de.id = sm.dictionary_entry_id
    WHERE sm.mapping_status = 'pending_review'
      AND sm.target_entity_type = 'person'
"""

_GUARD_SELECT = """
    SELECT
        'guard_blocked_merge'::text              AS kind,
        'pending_merge_reviews'::text            AS source_table,
        pmr.id                                   AS source_id,
        COALESCE(
            pmr.guard_payload->>'surface_a',
            pmr.guard_payload->>'surface',
            (SELECT pn.name FROM person_names pn
             WHERE pn.person_id = pmr.person_a_id
             ORDER BY pn.is_primary DESC NULLS LAST, pn.created_at ASC
             LIMIT 1),
            'unknown'
        )                                        AS surface,
        pmr.created_at                           AS pending_since,
        NULL::uuid                               AS raw_target_entity_id,
        NULL::uuid                               AS raw_dictionary_entry_id,
        NULL::text                               AS raw_confidence,
        NULL::text                               AS raw_mapping_method,
        NULL::jsonb                              AS raw_mapping_notes,
        pmr.person_a_id                          AS raw_person_a_id,
        pmr.person_b_id                          AS raw_person_b_id,
        pmr.proposed_rule                        AS raw_proposed_rule,
        pmr.guard_type                           AS raw_guard_type,
        pmr.guard_payload                        AS raw_guard_payload,
        pmr.evidence                             AS raw_evidence
    FROM pending_merge_reviews pmr
    WHERE pmr.status = 'pending'
"""

_INSERT_DECISION_SQL = """
    INSERT INTO triage_decisions (
        source_table, source_id, surface_snapshot, decision,
        reason_text, reason_source_type, historian_id,
        historian_commit_ref, architect_ack_ref, notes
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
    RETURNING id, source_table, source_id, surface_snapshot, decision,
              reason_text, reason_source_type, historian_id,
              historian_commit_ref, architect_ack_ref,
              decided_at, downstream_applied,
              downstream_applied_at, downstream_applied_by, notes
"""

_DECISIONS_FOR_SOURCE_SQL = """
    SELECT id, source_table, source_id, surface_snapshot, decision,
           reason_text, reason_source_type, historian_id,
           historian_commit_ref, architect_ack_ref,
           decided_at, downstream_applied,
           downstream_applied_at, downstream_applied_by, notes
    FROM triage_decisions
    WHERE source_table = $1 AND source_id = $2
    ORDER BY decided_at DESC
    LIMIT $3
"""

_DECISIONS_FOR_SURFACE_SQL = """
    SELECT id, source_table, source_id, surface_snapshot, decision,
           reason_text, reason_source_type, historian_id,
           historian_commit_ref, architect_ack_ref,
           decided_at, downstream_applied,
           downstream_applied_at, downstream_applied_by, notes
    FROM triage_decisions
    WHERE surface_snapshot = $1
    ORDER BY decided_at DESC
    LIMIT $2
"""


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _row_to_pending_item(row: Any) -> PendingItem:  # noqa: ANN401
    """Convert an asyncpg Record (or any dict-like) to :class:`PendingItem`."""
    raw = {
        "raw_target_entity_id": row["raw_target_entity_id"],
        "raw_dictionary_entry_id": row["raw_dictionary_entry_id"],
        "raw_confidence": row["raw_confidence"],
        "raw_mapping_method": row["raw_mapping_method"],
        "raw_mapping_notes": row["raw_mapping_notes"],
        "raw_person_a_id": row["raw_person_a_id"],
        "raw_person_b_id": row["raw_person_b_id"],
        "raw_proposed_rule": row["raw_proposed_rule"],
        "raw_guard_type": row["raw_guard_type"],
        "raw_guard_payload": row["raw_guard_payload"],
        "raw_evidence": row["raw_evidence"],
    }
    return PendingItem(
        item_id=encode_item_id(row["kind"], str(row["source_id"])),
        kind=row["kind"],
        source_table=row["source_table"],
        source_id=str(row["source_id"]),
        surface=row["surface"],
        pending_since=row["pending_since"],
        raw_payload=raw,
    )


def _row_to_decision_record(row: Any) -> DecisionRecord:  # noqa: ANN401
    return DecisionRecord(
        id=str(row["id"]),
        source_table=row["source_table"],
        source_id=str(row["source_id"]),
        surface_snapshot=row["surface_snapshot"],
        decision=row["decision"],
        historian_id=row["historian_id"],
        decided_at=row["decided_at"],
        reason_text=row["reason_text"],
        reason_source_type=row["reason_source_type"],
        historian_commit_ref=row["historian_commit_ref"],
        architect_ack_ref=row["architect_ack_ref"],
        downstream_applied=row["downstream_applied"],
        downstream_applied_at=row["downstream_applied_at"],
        downstream_applied_by=row["downstream_applied_by"],
        notes=row["notes"],
    )


def _build_list_query(
    *,
    include_seed: bool,
    include_guard: bool,
    surface_filter: str | None,
) -> tuple[str, list[Any]]:
    """Build the UNION ALL query + parameter list for list_pending."""
    args: list[Any] = []
    seed_sql = _SEED_SELECT
    guard_sql = _GUARD_SELECT

    if surface_filter is not None:
        # Use $1 placeholder shared between both branches; that means we
        # bind it twice if both branches active. We use named replacement
        # with explicit $-numbering.
        args.append(surface_filter)
        idx = len(args)
        seed_sql += f" AND de.primary_name = ${idx}"
        guard_sql += (
            f" AND COALESCE(pmr.guard_payload->>'surface_a',"
            f" pmr.guard_payload->>'surface') = ${idx}"
        )

    if include_seed and include_guard:
        union_part = f"({seed_sql}) UNION ALL ({guard_sql})"
    elif include_seed:
        union_part = seed_sql
    else:
        union_part = guard_sql

    return union_part, args


# ---------------------------------------------------------------------------
# AsyncpgTriageStore
# ---------------------------------------------------------------------------


class AsyncpgTriageStore:
    """``TriageStore`` impl backed by an asyncpg connection pool.

    Args:
        pool:  an ``asyncpg.Pool`` already connected to the HuaDian DB.

    The store does NOT manage the pool's lifecycle; callers must
    create / close the pool themselves.
    """

    __slots__ = ("_pool",)

    def __init__(self, pool: asyncpg.Pool) -> None:
        self._pool = pool

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
        include_seed = filter_by_kind in (None, "seed_mapping")
        include_guard = filter_by_kind in (None, "guard_blocked_merge")
        if not include_seed and not include_guard:
            return [], 0

        union_part, args = _build_list_query(
            include_seed=include_seed,
            include_guard=include_guard,
            surface_filter=filter_by_surface,
        )

        # Total count
        count_sql = (
            f"WITH all_pending AS ({union_part}) SELECT count(*)::int AS total FROM all_pending"
        )
        # Data with cluster ordering
        data_sql = f"""
            WITH all_pending AS ({union_part}),
                 clusters AS (
                     SELECT surface, MIN(pending_since) AS anchor
                     FROM all_pending
                     GROUP BY surface
                 )
            SELECT ap.*, c.anchor
            FROM all_pending ap
            JOIN clusters c ON c.surface = ap.surface
            ORDER BY c.anchor ASC, ap.surface ASC,
                     ap.pending_since ASC, ap.source_id ASC
            LIMIT ${len(args) + 1} OFFSET ${len(args) + 2}
        """

        async with self._pool.acquire() as conn:
            count_row = await conn.fetchrow(count_sql, *args)
            data_rows = await conn.fetch(data_sql, *args, limit, offset)

        total = count_row["total"] if count_row else 0
        items = [_row_to_pending_item(r) for r in data_rows]
        return items, total

    async def find_pending_by_id(self, item_id: str) -> PendingItem | None:
        from framework.audit_triage import decode_item_id

        decoded = decode_item_id(item_id)
        if decoded is None:
            return None
        kind, source_id = decoded

        if kind == "seed_mapping":
            sql = _SEED_SELECT + " AND sm.id = $1"
        elif kind == "guard_blocked_merge":
            sql = _GUARD_SELECT + " AND pmr.id = $1"
        else:
            return None

        async with self._pool.acquire() as conn:
            try:
                row = await conn.fetchrow(sql, source_id)
            except Exception:  # noqa: BLE001 — bad uuid format etc → not found
                return None

        if row is None:
            return None
        return _row_to_pending_item(row)

    async def find_next_pending_excluding(
        self,
        kind: ItemKind,
        source_id: str,
    ) -> str | None:
        # Same ordering as list_pending; we filter out the just-decided row
        # in Python (cheap — N≤page size). For a more SQL-native path use
        # a WHERE NOT (kind=$1 AND source_id=$2) — but the projection
        # complicates the predicate; client-side filter is clearer.
        items, _ = await self.list_pending(limit=2, offset=0)
        for it in items:
            if not (it.kind == kind and it.source_id == source_id):
                return it.item_id
        return None

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
        async with self._pool.acquire() as conn:
            rows = await conn.fetch(_DECISIONS_FOR_SOURCE_SQL, source_table, source_id, limit)
        return [_row_to_decision_record(r) for r in rows]

    async def find_decisions_for_surface(
        self,
        surface: str,
        *,
        limit: int = 10,
    ) -> list[DecisionRecord]:
        async with self._pool.acquire() as conn:
            rows = await conn.fetch(_DECISIONS_FOR_SURFACE_SQL, surface, limit)
        return [_row_to_decision_record(r) for r in rows]

    # -----------------------------------------------------------------
    # Decision audit write
    # -----------------------------------------------------------------

    async def insert_decision(
        self,
        item: PendingItem,
        input: RecordDecisionInput,  # noqa: A002 — Protocol signature
    ) -> DecisionRecord:
        async with self._pool.acquire() as conn:
            row = await conn.fetchrow(
                _INSERT_DECISION_SQL,
                item.source_table,
                item.source_id,
                item.surface,  # surface_snapshot (frozen at write time)
                input.decision,
                input.reason_text,
                input.reason_source_type,
                input.historian_id,
                input.historian_commit_ref,
                input.architect_ack_ref,
                input.notes,
            )
        if row is None:
            raise RuntimeError("triage_decisions INSERT returned no rows")
        return _row_to_decision_record(row)
