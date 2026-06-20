"""Upper-bound invariant — entity attribute count must be ≤ N.

Template SQL:

    SELECT entity_id, COUNT(*) AS x_count
    FROM entity_attributes
    WHERE <predicate>
    GROUP BY entity_id
    HAVING COUNT(*) > {max_count}

Returns rows where the count exceeds the threshold (= violations).

HuaDian example (V1 — implicit, no independent test):

    UpperBoundInvariant.from_template(
        name="V1",
        description="each person ≤ 1 primary name",
        sql='''
            SELECT person_id, COUNT(*) AS cnt
            FROM person_names
            WHERE is_primary = true
            GROUP BY person_id
            HAVING COUNT(*) > $1
        ''',
        max_count=1,
        violation_explanation_fmt="person {person_id} has {cnt} primary names",
    )

Cross-domain examples:
    - 法律: each contract ≤ 1 primary party
    - 医疗: each case ≤ 1 main diagnosis
    - 专利: each patent ≤ 1 first inventor

License: Apache 2.0
Source: HuaDian Sprint O.
"""

from __future__ import annotations

from typing import Any

from ..invariant import Invariant
from ..port import DBPort
from ..types import Severity, Violation


class UpperBoundInvariant(Invariant):
    """Pattern: entity attr count must be ≤ N."""

    def __init__(
        self,
        name: str,
        description: str,
        sql: str,
        max_count: int = 0,
        violation_explanation_fmt: str = "",
        severity: Severity = "critical",
    ) -> None:
        """Initialize.

        Args:
            name:                       short identifier
            description:                human-readable one-liner
            sql:                        SELECT returning (entity_id, count) rows
                                        where count > max_count is the violation.
                                        Pass max_count as the SQL parameter
                                        (will be the only positional arg).
            max_count:                  threshold to compare against (default 0
                                        — anything > 0 is a violation, used
                                        for "must be empty" patterns)
            violation_explanation_fmt:  Python format string with row keys, e.g.
                                        "person {person_id} has {cnt} primaries".
                                        If empty, uses repr(row).
            severity:                   default "critical"
        """
        super().__init__(name=name, description=description, severity=severity)
        self._sql = sql
        self._max_count = max_count
        self._explanation_fmt = violation_explanation_fmt

    async def query_violations(self, port: DBPort) -> list[Violation]:
        rows = await port.fetch(self._sql, self._max_count)
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
        max_count: int = 0,
        violation_explanation_fmt: str = "",
        severity: Severity = "critical",
    ) -> UpperBoundInvariant:
        """Convenience classmethod (same signature as __init__).

        Provided to make case-domain registration code more declarative:

            invariants = [
                UpperBoundInvariant.from_template(...),
                LowerBoundInvariant.from_template(...),
            ]
        """
        return cls(
            name=name,
            description=description,
            sql=sql,
            max_count=max_count,
            violation_explanation_fmt=violation_explanation_fmt,
            severity=severity,
        )
