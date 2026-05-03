"""Tests for framework.invariant_scaffold.types — Violation / Result / Report shapes."""

from __future__ import annotations

from framework.invariant_scaffold.types import (
    InvariantReport,
    InvariantResult,
    Violation,
)


def test_violation_round_trips_row_data_and_explanation():
    v = Violation(
        invariant_name="V8",
        row_data={"person_id": "p1", "cnt": 3},
        explanation="person p1 has 3 primaries",
    )
    assert v.invariant_name == "V8"
    assert v.row_data["cnt"] == 3
    assert "p1" in v.explanation


def test_invariant_result_aggregates_pass_or_fail():
    passed = InvariantResult(
        invariant_name="V1",
        passed=True,
        severity="critical",
        violations=[],
        duration_ms=5.5,
        description="V1: must be empty",
    )
    failed = InvariantResult(
        invariant_name="V1",
        passed=False,
        severity="critical",
        violations=[Violation(invariant_name="V1", row_data={"x": 1}, explanation="bad")],
        duration_ms=10.0,
        description="V1: must be empty",
    )
    assert passed.passed and passed.violation_count == 0
    assert not failed.passed and failed.violation_count == 1


def test_invariant_report_separates_critical_and_warning_failures():
    crit_pass = InvariantResult(
        invariant_name="C1",
        passed=True,
        severity="critical",
        violations=[],
        duration_ms=1.0,
        description="",
    )
    crit_fail = InvariantResult(
        invariant_name="C2",
        passed=False,
        severity="critical",
        violations=[Violation(invariant_name="C2", row_data={}, explanation="x")],
        duration_ms=1.0,
        description="",
    )
    warn_fail = InvariantResult(
        invariant_name="W1",
        passed=False,
        severity="warning",
        violations=[Violation(invariant_name="W1", row_data={}, explanation="x")],
        duration_ms=1.0,
        description="",
    )
    report = InvariantReport(
        results=[crit_pass, crit_fail, warn_fail],
        total_duration_ms=3.0,
    )
    crit_failures = [r.invariant_name for r in report.critical_failures]
    warn_failures = [r.invariant_name for r in report.warning_failures]
    assert crit_failures == ["C2"]
    assert warn_failures == ["W1"]
