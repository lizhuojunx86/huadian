"""HuaDian classics — SeedMatchAdapter + R6PrePassRunner for seed_mappings.

Wraps the HuaDian Postgres tables:
    seed_mappings        (target_entity_id, dictionary_entry_id, confidence,
                          mapping_status)
    dictionary_entries   (id, external_id, primary_name, source_id)
    dictionary_sources   (id, source_name)

License: Apache 2.0
Source: extracted from `services/pipeline/src/huadian_pipeline/r6_seed_match.py`
        and `resolve.py:_r6_prepass`.
"""

from __future__ import annotations

import logging
from collections import defaultdict
from typing import TYPE_CHECKING

from framework.identity_resolver import (
    EntitySnapshot,
    R6PrePassResult,
    R6Result,
    R6Status,
)

if TYPE_CHECKING:
    import asyncpg

logger = logging.getLogger(__name__)


class HuaDianSeedMatchAdapter:
    """Implementation of `SeedMatchAdapter` Protocol for HuaDian.

    Used for on-demand R6 lookup (single name / single QID query).
    For batch pre-pass over many entities, use `HuaDianR6PrePassRunner`.
    """

    def __init__(self, pool: asyncpg.Pool) -> None:
        self._pool = pool

    async def lookup_by_id(
        self,
        external_id: str,
        source_name: str,
        confidence_cutoff: float,
    ) -> R6Result:
        async with self._pool.acquire() as conn:
            row = await conn.fetchrow(
                """
                SELECT sm.target_entity_id::text AS person_id,
                       sm.confidence,
                       de.id::text AS entry_id,
                       de.external_id,
                       ds.source_name
                FROM seed_mappings sm
                JOIN dictionary_entries de ON de.id = sm.dictionary_entry_id
                JOIN dictionary_sources ds ON ds.id = de.source_id
                WHERE ds.source_name = $1
                  AND de.external_id = $2
                  AND sm.mapping_status = 'active'
                """,
                source_name,
                external_id,
            )

        if row is None:
            return R6Result(
                status=R6Status.NOT_FOUND,
                detail=f"No active mapping for {source_name}:{external_id}",
            )

        conf = float(row["confidence"]) if row["confidence"] is not None else 0.0
        if conf < confidence_cutoff:
            return R6Result(
                status=R6Status.BELOW_CUTOFF,
                entity_id=row["person_id"],
                confidence=conf,
                entry_id=row["entry_id"],
                external_id=row["external_id"],
                source_name=row["source_name"],
                detail=f"Confidence {conf:.2f} < cutoff {confidence_cutoff:.2f}",
            )

        return R6Result(
            status=R6Status.MATCHED,
            entity_id=row["person_id"],
            confidence=conf,
            entry_id=row["entry_id"],
            external_id=row["external_id"],
            source_name=row["source_name"],
        )

    async def lookup_by_name(
        self,
        candidate_name: str,
        confidence_cutoff: float,
    ) -> R6Result:
        async with self._pool.acquire() as conn:
            rows = await conn.fetch(
                """
                SELECT sm.target_entity_id::text AS person_id,
                       sm.confidence,
                       de.id::text AS entry_id,
                       de.external_id,
                       ds.source_name
                FROM seed_mappings sm
                JOIN dictionary_entries de ON de.id = sm.dictionary_entry_id
                JOIN dictionary_sources ds ON ds.id = de.source_id
                WHERE de.primary_name = $1
                  AND sm.mapping_status = 'active'
                  AND sm.confidence >= $2
                """,
                candidate_name,
                confidence_cutoff,
            )

        if len(rows) == 0:
            return R6Result(
                status=R6Status.NOT_FOUND,
                detail=f"No active mapping for name '{candidate_name}'",
            )

        if len(rows) > 1:
            return R6Result(
                status=R6Status.AMBIGUOUS,
                detail=(
                    f"Multiple active mappings for name '{candidate_name}': "
                    f"{[r['external_id'] for r in rows]}"
                ),
            )

        row = rows[0]
        conf = float(row["confidence"]) if row["confidence"] is not None else 0.0
        return R6Result(
            status=R6Status.MATCHED,
            entity_id=row["person_id"],
            confidence=conf,
            entry_id=row["entry_id"],
            external_id=row["external_id"],
            source_name=row["source_name"],
        )


# ---------------------------------------------------------------------------
# R6PrePassRunner — batch attaches seed_match to each entity
# ---------------------------------------------------------------------------


class HuaDianR6PrePassRunner:
    """Implementation of `R6PrePassRunner` Protocol for HuaDian.

    Batch-loads active seed_mappings for all persons in one query (FK direct).
    Mutates each `EntitySnapshot.seed_match` to an `R6PrePassResult`.
    """

    def __init__(
        self,
        pool: asyncpg.Pool,
        confidence_cutoff: float = 0.80,
    ) -> None:
        self._pool = pool
        self._cutoff = confidence_cutoff

    async def attach_seed_matches(
        self,
        entities: list[EntitySnapshot],
    ) -> dict[str, int]:
        if not entities:
            return {"matched": 0, "below_cutoff": 0, "ambiguous": 0, "not_found": 0}

        person_ids = [e.id for e in entities]

        async with self._pool.acquire() as conn:
            rows = await conn.fetch(
                """
                SELECT sm.target_entity_id::text AS person_id,
                       de.external_id AS qid,
                       de.id::text AS entry_id,
                       sm.confidence
                FROM seed_mappings sm
                JOIN dictionary_entries de ON de.id = sm.dictionary_entry_id
                WHERE sm.target_entity_type = 'person'
                  AND sm.target_entity_id = ANY($1::uuid[])
                  AND sm.mapping_status = 'active'
                ORDER BY sm.target_entity_id, sm.confidence DESC
                """,
                person_ids,
            )

        by_person: dict[str, list] = defaultdict(list)
        for row in rows:
            by_person[row["person_id"]].append(row)

        distribution: dict[str, int] = {
            "matched": 0,
            "below_cutoff": 0,
            "ambiguous": 0,
            "not_found": 0,
        }

        for snap in entities:
            mapping_rows = by_person.get(snap.id, [])

            if not mapping_rows:
                snap.seed_match = R6PrePassResult(status=R6Status.NOT_FOUND)
                distribution["not_found"] += 1
            elif len(mapping_rows) > 1:
                logger.warning(
                    "R6 pre-pass: person %s (%s) has %d active seed_mappings — marking AMBIGUOUS",
                    snap.id,
                    snap.name,
                    len(mapping_rows),
                )
                snap.seed_match = R6PrePassResult(status=R6Status.AMBIGUOUS)
                distribution["ambiguous"] += 1
            else:
                row = mapping_rows[0]
                conf = float(row["confidence"]) if row["confidence"] is not None else 0.0
                if conf >= self._cutoff:
                    snap.seed_match = R6PrePassResult(
                        status=R6Status.MATCHED,
                        qid=row["qid"],
                        entry_id=row["entry_id"],
                        confidence=conf,
                    )
                    distribution["matched"] += 1
                else:
                    snap.seed_match = R6PrePassResult(
                        status=R6Status.BELOW_CUTOFF,
                        qid=row["qid"],
                        entry_id=row["entry_id"],
                        confidence=conf,
                    )
                    distribution["below_cutoff"] += 1

        logger.info(
            "R6 pre-pass: %d entities — matched=%d, not_found=%d, below_cutoff=%d, ambiguous=%d",
            len(entities),
            distribution["matched"],
            distribution["not_found"],
            distribution["below_cutoff"],
            distribution["ambiguous"],
        )
        return distribution
