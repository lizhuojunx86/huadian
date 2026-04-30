"""HuaDian classics — MergeApplier for HuaDian DB writes.

Implements the framework's `MergeApplier` Protocol for HuaDian's tables:
    persons                  (soft-delete: deleted_at + merged_into_id)
    person_names             (demote primary → alias on merged person)
    person_merge_log         (audit row per merge)
    identity_hypotheses      (R4 hypotheses for human review)
    pending_merge_reviews    (guard-blocked merges for triage)

License: Apache 2.0
Source: extracted from `services/pipeline/src/huadian_pipeline/resolve.py`
        `apply_merges()`.
"""

from __future__ import annotations

import json as _json
import logging
import uuid
from datetime import UTC, datetime
from typing import TYPE_CHECKING, Any

from framework.identity_resolver import BlockedMerge, HypothesisProposal

if TYPE_CHECKING:
    import asyncpg

logger = logging.getLogger(__name__)


class HuaDianMergeApplier:
    """Implementation of `MergeApplier` Protocol for HuaDian classics.

    Constructor takes an asyncpg pool. The framework calls each method
    individually; the case domain manages its own transaction by passing
    a connection that's already inside a transaction context.

    Usage pattern:

        async with pool.acquire() as conn, conn.transaction():
            applier = HuaDianMergeApplier.with_connection(conn)
            await apply_merges(applier=applier, result=result, dry_run=False)

    The `with_connection()` factory returns an applier bound to a single
    connection (so all writes happen in the same transaction).
    """

    def __init__(self, pool: asyncpg.Pool | None = None) -> None:
        self._pool = pool
        self._conn: asyncpg.Connection | None = None
        self._now: datetime = datetime.now(UTC)

    @classmethod
    def with_connection(cls, conn: asyncpg.Connection) -> HuaDianMergeApplier:
        """Build an applier bound to a specific connection (for transactions)."""
        instance = cls()
        instance._conn = conn
        return instance

    async def _get_conn(self) -> asyncpg.Connection:
        """Return the bound connection, or acquire from pool."""
        if self._conn is not None:
            return self._conn
        if self._pool is not None:
            return await self._pool.acquire()
        raise RuntimeError("HuaDianMergeApplier needs either a pool or a bound connection")

    async def soft_delete_and_link(
        self,
        merged_id: str,
        canonical_id: str,
    ) -> None:
        conn = await self._get_conn()
        await conn.execute(
            """
            UPDATE persons
            SET deleted_at = $2, merged_into_id = $3
            WHERE id = $1 AND deleted_at IS NULL
            """,
            merged_id,
            self._now,
            canonical_id,
        )

    async def demote_primary_names(self, merged_id: str) -> int:
        conn = await self._get_conn()
        result = await conn.execute(
            """
            UPDATE person_names
            SET name_type = 'alias', is_primary = false
            WHERE person_id = $1 AND name_type = 'primary'
            """,
            merged_id,
        )
        # asyncpg returns "UPDATE N" — parse the count
        try:
            return int(result.split()[-1])
        except (ValueError, IndexError):
            return 0

    async def write_merge_log(
        self,
        *,
        run_id: str,
        canonical_id: str,
        merged_id: str,
        merge_rule: str,
        confidence: float,
        evidence: dict[str, Any],
        merged_by: str,
    ) -> None:
        conn = await self._get_conn()
        log_id = str(uuid.uuid4())
        await conn.execute(
            """
            INSERT INTO person_merge_log
                (id, run_id, canonical_id, merged_id,
                 merge_rule, confidence, evidence,
                 merged_by, merged_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7::jsonb, $8, $9)
            """,
            log_id,
            run_id,
            canonical_id,
            merged_id,
            merge_rule,
            confidence,
            _json.dumps(evidence, ensure_ascii=False),
            merged_by,
            self._now,
        )

    async def write_hypothesis(self, hyp: HypothesisProposal) -> None:
        conn = await self._get_conn()
        hyp_id = str(uuid.uuid4())
        await conn.execute(
            """
            INSERT INTO identity_hypotheses
                (id, canonical_person_id, hypothesis_person_id,
                 relation_type, scholarly_support, evidence_ids,
                 accepted_by_default, notes)
            VALUES ($1, $2, $3, 'possibly_same', $4, $5::jsonb, false, $6)
            ON CONFLICT DO NOTHING
            """,
            hyp_id,
            hyp.entity_a_id,
            hyp.entity_b_id,
            f"Rule {hyp.match.rule} match (confidence {hyp.match.confidence:.2f})",
            _json.dumps(hyp.match.evidence, ensure_ascii=False),
            str(hyp.match.evidence),
        )

    async def write_blocked_review(self, item: BlockedMerge) -> None:
        conn = await self._get_conn()
        await conn.execute(
            """
            INSERT INTO pending_merge_reviews
                (person_a_id, person_b_id, proposed_rule, guard_type,
                 guard_payload, evidence)
            VALUES ($1::uuid, $2::uuid, $3, $4, $5::jsonb, $6::jsonb)
            ON CONFLICT (person_a_id, person_b_id, proposed_rule, guard_type)
                WHERE status = 'pending'
            DO NOTHING
            """,
            item.entity_a_id,
            item.entity_b_id,
            item.proposed_rule,
            item.guard_type,
            _json.dumps(item.guard_payload, ensure_ascii=False),
            _json.dumps(item.evidence, ensure_ascii=False),
        )
