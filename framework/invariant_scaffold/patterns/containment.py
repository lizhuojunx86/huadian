"""Containment invariant — set A must be a subset of set B.

Template SQL:

    SELECT a.id, a.<display>
    FROM table_a a
    WHERE NOT EXISTS (
        SELECT 1 FROM table_b b WHERE matches_predicate(a, b)
    )

Returns rows in A that have no matching counterpart in B (= violations).

This is one of the most general patterns — many "must be one of" /
"references must satisfy condition" invariants reduce to containment.

HuaDian examples:
    V8 — short single-char names should NOT prefix-collide with long names
         (i.e. "for each unexempted single-char name, the set of long names
          that start with it must be empty in other persons")
    V10.c — every active seed_mapping ⊆ has-source-evidence
    active-merged — entities with merged_into_id ⊆ entities with deleted_at
    Slug-A — every slug ∈ (Tier-S whitelist ∪ unicode regex pattern)

Cross-domain examples:
    - 法律: every cited case ⊆ database of known cases
    - 医疗: every prescribed drug ⊆ approved formulary
    - 专利: every claim reference ⊆ existing prior art

License: Apache 2.0
Source: HuaDian Sprint O.
"""

from __future__ import annotations

from collections.abc import Awaitable, Callable
from typing import Any

from ..invariant import Invariant
from ..port import DBPort
from ..types import Severity, Violation

# Optional in-Python predicate (used when SQL alone can't express the membership,
# e.g. "must match this regex" — case domain provides Python predicate that
# inspects each row).
ContainmentPredicate = Callable[[dict[str, Any]], Awaitable[bool] | bool]


class ContainmentInvariant(Invariant):
    """Pattern: set A ⊆ set B (rows in A without matching B = violations)."""

    def __init__(
        self,
        name: str,
        description: str,
        sql: str,
        violation_explanation_fmt: str = "",
        in_python_predicate: ContainmentPredicate | None = None,
        severity: Severity = "critical",
    ) -> None:
        """Initialize.

        Args:
            name:                       short identifier
            description:                human-readable one-liner
            sql:                        SELECT returning all rows in A.
                                        - If in_python_predicate is None, every
                                          returned row is a violation (i.e. the
                                          SQL has done the NOT EXISTS filter).
                                        - If in_python_predicate is set, each
                                          row is checked in Python; rows where
                                          the predicate returns False are the
                                          violations (rows that fail the
                                          containment).
            violation_explanation_fmt:  Python format string with row keys.
            in_python_predicate:        optional async or sync callable
                                        (row -> bool). Returns True if the
                                        row is contained (= passes); False
                                        if it violates.
            severity:                   default "critical"
        """
        super().__init__(name=name, description=description, severity=severity)
        self._sql = sql
        self._explanation_fmt = violation_explanation_fmt
        self._predicate = in_python_predicate

    async def query_violations(self, port: DBPort) -> list[Violation]:
        rows = await port.fetch(self._sql)
        if self._predicate is None:
            return [self._row_to_violation(row) for row in rows]

        violations: list[Violation] = []
        for row in rows:
            result = self._predicate(row)
            if hasattr(result, "__await__"):
                result = await result
            if not result:
                violations.append(self._row_to_violation(row))
        return violations

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
        violation_explanation_fmt: str = "",
        in_python_predicate: ContainmentPredicate | None = None,
        severity: Severity = "critical",
    ) -> ContainmentInvariant:
        return cls(
            name=name,
            description=description,
            sql=sql,
            violation_explanation_fmt=violation_explanation_fmt,
            in_python_predicate=in_python_predicate,
            severity=severity,
        )
