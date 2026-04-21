"""R6 seed-match rule — external dictionary anchor lookup.

Provides a pure lookup function that checks whether a candidate entity
has an active seed_mapping with sufficient confidence. Used by the
identity resolver as the highest-priority rule (before R1-R5 heuristics).

ADR: ADR-010 §R6 / ADR-021 §3.3
"""

from __future__ import annotations

import logging
from dataclasses import dataclass
from enum import StrEnum
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    import asyncpg

logger = logging.getLogger(__name__)


class R6Status(StrEnum):
    """R6 lookup result status."""

    MATCHED = "matched"
    BELOW_CUTOFF = "below_cutoff"
    AMBIGUOUS = "ambiguous"
    NOT_FOUND = "not_found"


@dataclass(frozen=True, slots=True)
class R6Result:
    """Result of an R6 seed-match lookup."""

    status: R6Status
    person_id: str | None = None
    confidence: float = 0.0
    entry_id: str | None = None
    external_id: str | None = None
    source_name: str | None = None
    detail: str = ""


async def r6_seed_match(
    conn: asyncpg.Connection,
    *,
    candidate_name: str,
    candidate_qid: str | None = None,
    dictionary_source: str = "wikidata",
    confidence_cutoff: float = 0.80,
) -> R6Result:
    """Look up active seed_mapping by QID or by primary_name.

    Primary path (candidate_qid provided):
        JOIN dictionary_sources → dictionary_entries → seed_mappings
        WHERE source_name = dictionary_source AND external_id = qid
        AND mapping_status = 'active' AND confidence >= cutoff

    Fallback path (name only):
        dictionary_entries.primary_name = candidate_name
        Single match → return; multi-match → ambiguous

    Returns R6Result with status in {matched, below_cutoff, ambiguous, not_found}.
    """
    # ── Primary path: QID lookup ──
    if candidate_qid:
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
            dictionary_source,
            candidate_qid,
        )

        if row is None:
            return R6Result(
                status=R6Status.NOT_FOUND,
                detail=f"No active mapping for {dictionary_source}:{candidate_qid}",
            )

        conf = float(row["confidence"]) if row["confidence"] is not None else 0.0
        if conf < confidence_cutoff:
            return R6Result(
                status=R6Status.BELOW_CUTOFF,
                person_id=row["person_id"],
                confidence=conf,
                entry_id=row["entry_id"],
                external_id=row["external_id"],
                source_name=row["source_name"],
                detail=f"Confidence {conf:.2f} < cutoff {confidence_cutoff:.2f}",
            )

        return R6Result(
            status=R6Status.MATCHED,
            person_id=row["person_id"],
            confidence=conf,
            entry_id=row["entry_id"],
            external_id=row["external_id"],
            source_name=row["source_name"],
        )

    # ── Fallback path: name lookup ──
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
        person_id=row["person_id"],
        confidence=conf,
        entry_id=row["entry_id"],
        external_id=row["external_id"],
        source_name=row["source_name"],
    )
