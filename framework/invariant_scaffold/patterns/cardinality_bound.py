"""Cardinality-bound invariant — count must equal exact value or be in [min, max].

Two sub-modes:

  Mode A (exact count): the SQL returns COUNT(*); violation iff count != expected_count.
                        Typical use: "must be 0" patterns (V6 / V11).

  Mode B (per-entity range): the SQL returns one row per entity with a count;
                              violations are entities whose count is outside [min, max].
                              Typical use: V11 ("no entity has > 1 active mapping" =
                              per-entity count must be ≤ 1).

HuaDian examples:
    V6  — count(person_names with alias + is_primary=true) must be 0  → Mode A
    V11 — per-person count of active seed_mappings must be ≤ 1         → Mode B (max=1)
    Slug-B — per-slug count must == 1 (no collisions)                  → Mode B (exact=1)

Cross-domain examples:
    - 法律: per-case count of "primary" cited cases must be exactly 1
    - 医疗: per-patient count of active prescriptions must be in [0, 50]
    - 专利: per-invention count of independent claims must be ≥ 1

License: Apache 2.0
Source: HuaDian Sprint O.
"""

from __future__ import annotations

from typing import Any

from ..invariant import Invariant
from ..port import DBPort
from ..types import Severity, Violation


class CardinalityBoundInvariant(Invariant):
    """Pattern: count must match exact value or be in [min, max] per entity."""

    def __init__(
        self,
        name: str,
        description: str,
        sql: str,
        mode: str = "exact_total",
        expected_count: int | None = None,
        min_count: int | None = None,
        max_count: int | None = None,
        violation_explanation_fmt: str = "",
        severity: Severity = "critical",
    ) -> None:
        """Initialize.

        Args:
            name:                       short identifier
            description:                human-readable one-liner
            sql:                        For mode='exact_total': SELECT returning
                                        scalar count via fetchval.
                                        For mode='per_entity_range': SELECT
                                        returning rows with at least a 'cnt'
                                        column (entities outside the range
                                        are violations).
            mode:                       'exact_total' (default) | 'per_entity_range'
            expected_count:             For exact_total mode (default 0).
            min_count, max_count:       For per_entity_range mode. Either or
                                        both can be set; None = unbounded on
                                        that side.
            violation_explanation_fmt:  Python format string. For exact_total,
                                        keys are {count} and {expected}. For
                                        per_entity_range, all SELECT columns
                                        are available (typically including 'cnt').
            severity:                   default "critical"
        """
        super().__init__(name=name, description=description, severity=severity)
        if mode not in ("exact_total", "per_entity_range"):
            raise ValueError(f"unknown mode: {mode!r}")
        self._sql = sql
        self._mode = mode
        self._expected = expected_count if expected_count is not None else 0
        self._min = min_count
        self._max = max_count
        self._explanation_fmt = violation_explanation_fmt

    async def query_violations(self, port: DBPort) -> list[Violation]:
        if self._mode == "exact_total":
            return await self._exact_total(port)
        return await self._per_entity_range(port)

    async def _exact_total(self, port: DBPort) -> list[Violation]:
        count = await port.fetchval(self._sql)
        count_int = int(count) if count is not None else 0
        if count_int == self._expected:
            return []
        return [
            Violation(
                invariant_name=self.name,
                row_data={"count": count_int, "expected": self._expected},
                explanation=self._format_exact(count_int),
            )
        ]

    def _format_exact(self, count: int) -> str:
        if self._explanation_fmt:
            try:
                return self._explanation_fmt.format(count=count, expected=self._expected)
            except KeyError as exc:
                return f"count={count} expected={self._expected} (fmt missing: {exc!r})"
        return f"count={count} (expected {self._expected})"

    async def _per_entity_range(self, port: DBPort) -> list[Violation]:
        rows = await port.fetch(self._sql)
        violations: list[Violation] = []
        for row in rows:
            cnt = row.get("cnt")
            if cnt is None:
                # Row schema doesn't have 'cnt' — treat as violation
                violations.append(self._row_to_violation(row))
                continue
            cnt_int = int(cnt)
            below = self._min is not None and cnt_int < self._min
            above = self._max is not None and cnt_int > self._max
            if below or above:
                violations.append(self._row_to_violation(row))
        return violations

    def _row_to_violation(self, row: dict[str, Any]) -> Violation:
        if self._explanation_fmt:
            try:
                explanation = self._explanation_fmt.format(**row)
            except KeyError as exc:
                explanation = f"row {row!r} (explanation_fmt missing key: {exc!r})"
        else:
            range_str = f"[{self._min}, {self._max}]"
            explanation = f"row {row!r} outside cardinality {range_str}"
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
        mode: str = "exact_total",
        expected_count: int | None = None,
        min_count: int | None = None,
        max_count: int | None = None,
        violation_explanation_fmt: str = "",
        severity: Severity = "critical",
    ) -> CardinalityBoundInvariant:
        return cls(
            name=name,
            description=description,
            sql=sql,
            mode=mode,
            expected_count=expected_count,
            min_count=min_count,
            max_count=max_count,
            violation_explanation_fmt=violation_explanation_fmt,
            severity=severity,
        )
