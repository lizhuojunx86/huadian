"""Lower-bound invariant — entity must have at least N matching attributes.

Template SQL:

    SELECT e.id, e.<display_field>
    FROM entities e
    WHERE <active_predicate>
      AND NOT EXISTS (
          SELECT 1 FROM entity_attributes ea
          WHERE ea.entity_id = e.id AND <attr_predicate>
      )

Returns rows where the entity has 0 (or fewer than min_count) matching
attributes. The min_count parameter is informational — typically the SQL
uses NOT EXISTS for min_count=1 cases.

HuaDian examples:
    V9 — each active person ≥ 1 primary name
    V4 — each soft-merged person ≥ 1 person_name (model-A compliance)

Cross-domain examples:
    - 法律: each active contract ≥ 1 party
    - 医疗: each active case ≥ 1 main diagnosis
    - 专利: each active patent ≥ 1 inventor

License: Apache 2.0
Source: HuaDian Sprint O.
"""

from __future__ import annotations

from typing import Any

from ..invariant import Invariant
from ..port import DBPort
from ..types import Severity, Violation


class LowerBoundInvariant(Invariant):
    """Pattern: each active entity must have ≥ N matching attributes."""

    def __init__(
        self,
        name: str,
        description: str,
        sql: str,
        min_count: int = 1,
        violation_explanation_fmt: str = "",
        severity: Severity = "critical",
    ) -> None:
        """Initialize.

        Args:
            name:                       short identifier
            description:                human-readable one-liner
            sql:                        SELECT returning entity rows that have
                                        FEWER than min_count matching attrs.
                                        For min_count=1 the typical pattern is
                                        `NOT EXISTS (SELECT 1 FROM attrs WHERE ...)`.
                                        SQL receives no positional args by default
                                        (most lower-bound queries are parameter-free).
            min_count:                  documented threshold (default 1).
                                        Note: SQL itself encodes the threshold —
                                        this field is for documentation only.
            violation_explanation_fmt:  Python format string with row keys.
            severity:                   default "critical"
        """
        super().__init__(name=name, description=description, severity=severity)
        self._sql = sql
        self._min_count = min_count
        self._explanation_fmt = violation_explanation_fmt

    @property
    def min_count(self) -> int:
        return self._min_count

    async def query_violations(self, port: DBPort) -> list[Violation]:
        rows = await port.fetch(self._sql)
        return [self._row_to_violation(row) for row in rows]

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
        min_count: int = 1,
        violation_explanation_fmt: str = "",
        severity: Severity = "critical",
    ) -> LowerBoundInvariant:
        return cls(
            name=name,
            description=description,
            sql=sql,
            min_count=min_count,
            violation_explanation_fmt=violation_explanation_fmt,
            severity=severity,
        )
