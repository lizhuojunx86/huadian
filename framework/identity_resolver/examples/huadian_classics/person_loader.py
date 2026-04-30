"""HuaDian classics — EntityLoader for the `persons` table (PostgreSQL).

Loads all non-deleted persons from the HuaDian Postgres schema:
    persons         (id, name JSONB, slug, dynasty, identity_notes, ...)
    person_names    (person_id, name)

Implements the framework's `EntityLoader` Protocol. Maps the HuaDian-specific
schema columns into domain-agnostic `EntitySnapshot` instances:

    persons.dynasty          → EntitySnapshot.domain_attrs["dynasty"]
    person_names.name        → EntitySnapshot.surface_forms
    persons.identity_notes   → EntitySnapshot.identity_notes

License: Apache 2.0
Source: extracted from `services/pipeline/src/huadian_pipeline/resolve.py`
        `_load_persons`.
"""

from __future__ import annotations

from collections import defaultdict
from typing import TYPE_CHECKING

from framework.identity_resolver import EntitySnapshot

if TYPE_CHECKING:
    import asyncpg


class HuaDianPersonLoader:
    """Implementation of `EntityLoader` Protocol for HuaDian's `persons` table.

    Constructor takes an asyncpg connection pool; `load_all()` acquires a
    connection from the pool, runs the queries, and releases the connection
    before returning.
    """

    def __init__(self, pool: asyncpg.Pool) -> None:
        self._pool = pool

    async def load_all(self) -> list[EntitySnapshot]:
        """Load all non-deleted persons with surface_forms and identity_notes."""
        async with self._pool.acquire() as conn:
            return await self._load(conn)

    async def _load(self, conn: asyncpg.Connection) -> list[EntitySnapshot]:
        # Fetch persons (non-deleted, ordered by created_at for stable canonical
        # selection tiebreaks).
        person_rows = await conn.fetch(
            """
            SELECT
                p.id::text,
                p.name->>'zh-Hans' AS name_zh,
                p.slug,
                COALESCE(p.dynasty, '') AS dynasty,
                p.created_at::text
            FROM persons p
            WHERE p.deleted_at IS NULL
            ORDER BY p.created_at
            """
        )

        if not person_rows:
            return []

        person_ids = [row["id"] for row in person_rows]

        # Fetch all person_names in one query
        name_rows = await conn.fetch(
            """
            SELECT pn.person_id::text, pn.name
            FROM person_names pn
            WHERE pn.person_id = ANY($1::uuid[])
            """,
            person_ids,
        )

        names_by_person: dict[str, set[str]] = defaultdict(set)
        for row in name_rows:
            names_by_person[row["person_id"]].add(row["name"])

        # Fetch identity_notes (HuaDian-specific column on persons)
        notes_by_person: dict[str, list[str]] = defaultdict(list)
        try:
            note_rows = await conn.fetch(
                """
                SELECT p.id::text, p.identity_notes
                FROM persons p
                WHERE p.deleted_at IS NULL
                  AND p.identity_notes IS NOT NULL
                  AND p.identity_notes != ''
                """
            )
            for row in note_rows:
                notes_by_person[row["id"]].append(row["identity_notes"])
        except Exception:  # noqa: BLE001
            # identity_notes column may not exist in all deployments
            pass

        snapshots: list[EntitySnapshot] = []
        for row in person_rows:
            pid = row["id"]
            snapshots.append(
                EntitySnapshot(
                    id=pid,
                    name=row["name_zh"] or "",
                    slug=row["slug"] or "",
                    surface_forms=names_by_person.get(pid, set()),
                    created_at=row["created_at"] or "",
                    domain_attrs={"dynasty": row["dynasty"] or ""},
                    identity_notes=notes_by_person.get(pid, []),
                )
            )

        return snapshots
