"""Orphan detection invariant — references must point to existing rows.

Template SQL (typical):

    SELECT count(*)
    FROM child c
    LEFT JOIN parent p ON p.id = c.parent_id
    WHERE p.id IS NULL  -- or p.deleted_at IS NOT NULL, etc.

This is technically a special case of Containment, but kept as its own
pattern because the SQL idiom (LEFT JOIN ... IS NULL) is so common and
universally recognized.

HuaDian examples:
    V10.a — active seed_mappings → live (non-deleted, non-merged) persons
    V10.b — seed_mappings.dictionary_entry_id → existing dictionary_entries

Cross-domain examples:
    - 法律: every cited case ID points to a real case row
    - 医疗: every drug code references active formulary entry
    - 专利: every prior art reference points to existing patent

License: Apache 2.0
Source: HuaDian Sprint O.
"""

from __future__ import annotations

from typing import Any

from ..invariant import Invariant
from ..port import DBPort
from ..types import Severity, Violation


class OrphanDetectionInvariant(Invariant):
    """Pattern: references must point to existing (live) rows.

    Two query modes:
        1. count_only=True (default): SQL returns COUNT(*). Violations are
           collapsed to a single Violation with the count in row_data.
        2. count_only=False: SQL returns one row per orphan. Each row → 1
           Violation (use this when the explanation needs row-level detail).
    """

    def __init__(
        self,
        name: str,
        description: str,
        sql: str,
        count_only: bool = True,
        violation_explanation_fmt: str = "",
        severity: Severity = "critical",
    ) -> None:
        """Initialize.

        Args:
            name:                       short identifier
            description:                human-readable one-liner
            sql:                        SELECT either COUNT(*) of orphans
                                        (count_only=True) or per-orphan rows
                                        (count_only=False).
            count_only:                 if True, SQL returns scalar count via
                                        fetchval(); if False, SQL returns rows
                                        via fetch().
            violation_explanation_fmt:  Python format string. For count_only,
                                        the special key {count} is the orphan
                                        count. For row mode, all SELECT columns
                                        are available.
            severity:                   default "critical"
        """
        super().__init__(name=name, description=description, severity=severity)
        self._sql = sql
        self._count_only = count_only
        self._explanation_fmt = violation_explanation_fmt

    async def query_violations(self, port: DBPort) -> list[Violation]:
        if self._count_only:
            count = await port.fetchval(self._sql)
            count_int = int(count) if count is not None else 0
            if count_int == 0:
                return []
            return [
                Violation(
                    invariant_name=self.name,
                    row_data={"count": count_int},
                    explanation=self._format_count(count_int),
                )
            ]

        rows = await port.fetch(self._sql)
        return [self._row_to_violation(row) for row in rows]

    def _format_count(self, count: int) -> str:
        if self._explanation_fmt:
            try:
                return self._explanation_fmt.format(count=count)
            except KeyError as exc:
                return f"{count} orphan(s) (explanation_fmt missing key: {exc!r})"
        return f"{count} orphan reference(s) detected"

    def _row_to_violation(self, row: dict[str, Any]) -> Violation:
        if self._explanation_fmt:
            try:
                explanation = self._explanation_fmt.format(**row)
            except KeyError as exc:
                explanation = f"row {row!r} (explanation_fmt missing key: {exc!r})"
        else:
            explanation = repr(row)
        return Violation(
            invariant_name=self.name,
            row_data=row,
            explanation=explanation,
        )

    @classmethod
    def from_template(
        cls,
        name: str,
        description: str,
        sql: str,
        count_only: bool = True,
        violation_explanation_fmt: str = "",
        severity: Severity = "critical",
    ) -> OrphanDetectionInvariant:
        return cls(
            name=name,
            description=description,
            sql=sql,
            count_only=count_only,
            violation_explanation_fmt=violation_explanation_fmt,
            severity=severity,
        )
