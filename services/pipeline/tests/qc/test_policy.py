"""Unit tests for ActionPolicy (T-TG-002 S-6).

Covers:
  * YAML round-trip (real config file + from_dict)
  * by_severity ladder walk by attempt
  * by_step override beats by_severity
  * ladder exhaustion → fail_fast
  * degrade appears at the right step in the ladder
  * shadow mode forces pass_through regardless of severity
  * off mode short-circuits to pass_through
  * no violations → TG action stands
  * make_escalator binds context correctly (matches ActionEscalator Protocol)
  * PolicyConfigError on malformed input
  * max_severity helper
"""

from __future__ import annotations

from pathlib import Path

import pytest

from huadian_pipeline.qc.action_map import ActionType
from huadian_pipeline.qc.policy import (
    ActionPolicy,
    PolicyConfigError,
    max_severity,
)
from huadian_pipeline.qc.types import Violation

# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

_CONFIG_YML = Path(__file__).resolve().parents[2] / "config" / "traceguard_policy.yml"


def _minimal_policy() -> ActionPolicy:
    return ActionPolicy.from_dict(
        {
            "defaults": {},
            "by_severity": {
                "critical": ["retry", "degrade", "human_queue", "fail_fast"],
                "major": ["retry", "degrade", "human_queue"],
                "minor": ["pass_through"],
                "info": ["pass_through"],
            },
            "by_step": {
                "ner_v*": {
                    "critical": ["retry", "human_queue", "fail_fast"],
                },
            },
        }
    )


def _v(sev: str, rid: str = "r") -> Violation:
    # Cast via Any: the Literal is enforced by the Violation dataclass
    # at runtime via the registry, but tests bypass that.
    return Violation(rule_id=rid, severity=sev, message="x")  # type: ignore[arg-type]


# ---------------------------------------------------------------------------
# YAML loading
# ---------------------------------------------------------------------------


def test_loads_the_real_config_file() -> None:
    assert _CONFIG_YML.exists(), f"expected {_CONFIG_YML} to be present"
    p = ActionPolicy.from_yaml(_CONFIG_YML)
    assert "critical" in p.by_severity
    # Step-level override comes from traceguard_policy.yml:
    assert "ner_v*" in p.by_step
    # defaults carried through:
    assert p.defaults.degrade_to == "claude-sonnet-4-6"
    assert p.defaults.retry_backoff_ms == (500, 2000)


def test_malformed_top_level_raises() -> None:
    with pytest.raises(PolicyConfigError):
        _ = ActionPolicy.from_dict({"by_severity": {}})  # empty by_severity is rejected


def test_unknown_severity_raises() -> None:
    with pytest.raises(PolicyConfigError):
        _ = ActionPolicy.from_dict({"by_severity": {"SEVERE": ["retry"]}})


def test_unknown_action_raises() -> None:
    with pytest.raises(PolicyConfigError):
        _ = ActionPolicy.from_dict({"by_severity": {"critical": ["warn_only"]}})


# ---------------------------------------------------------------------------
# by_severity ladder walk
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    ("attempt", "expected"),
    [
        (1, "retry"),
        (2, "degrade"),
        (3, "human_queue"),
        (4, "fail_fast"),
        (5, "fail_fast"),  # exhausted
        (99, "fail_fast"),  # exhausted (still fail_fast, not IndexError)
    ],
)
def test_by_severity_critical_ladder(attempt: int, expected: ActionType) -> None:
    p = _minimal_policy()
    assert (
        p.resolve(
            step_name="relation_v2",  # does NOT match ner_v* override
            max_severity="critical",
            attempt=attempt,
            tg_action="retry",
        )
        == expected
    )


def test_by_severity_major_ladder_has_no_fail_fast_before_exhaustion() -> None:
    p = _minimal_policy()
    # major ladder = [retry, degrade, human_queue]
    assert (
        p.resolve(
            step_name="generic_step",
            max_severity="major",
            attempt=3,
            tg_action="retry",
        )
        == "human_queue"
    )
    # Exhausted → fail_fast (policy's safety net).
    assert (
        p.resolve(
            step_name="generic_step",
            max_severity="major",
            attempt=4,
            tg_action="retry",
        )
        == "fail_fast"
    )


def test_by_severity_minor_is_pass_through() -> None:
    p = _minimal_policy()
    assert (
        p.resolve(
            step_name="any",
            max_severity="minor",
            attempt=1,
            tg_action="retry",
        )
        == "pass_through"
    )


# ---------------------------------------------------------------------------
# by_step override
# ---------------------------------------------------------------------------


def test_by_step_override_beats_by_severity() -> None:
    p = _minimal_policy()
    # ner_v* critical ladder = [retry, human_queue, fail_fast]
    # — no `degrade` at position 2.
    assert (
        p.resolve(
            step_name="ner_v3",
            max_severity="critical",
            attempt=2,
            tg_action="retry",
        )
        == "human_queue"
    )  # would be `degrade` under by_severity


def test_by_step_falls_through_for_unmatched_severity() -> None:
    p = _minimal_policy()
    # ner_v* only overrides `critical`. A `major` violation on a ner step
    # must fall through to the by_severity table.
    assert (
        p.resolve(
            step_name="ner_v3",
            max_severity="major",
            attempt=1,
            tg_action="retry",
        )
        == "retry"
    )


# ---------------------------------------------------------------------------
# degrade
# ---------------------------------------------------------------------------


def test_degrade_appears_for_relation_critical() -> None:
    p = _minimal_policy()
    # relation_v* is not overridden, falls to by_severity critical
    # [retry, degrade, human_queue, fail_fast] — degrade at attempt 2.
    assert (
        p.resolve(
            step_name="relation_v2",
            max_severity="critical",
            attempt=2,
            tg_action="retry",
        )
        == "degrade"
    )


# ---------------------------------------------------------------------------
# mode
# ---------------------------------------------------------------------------


def test_shadow_mode_forces_pass_through() -> None:
    p = _minimal_policy()
    assert (
        p.resolve(
            step_name="ner_v3",
            max_severity="critical",
            attempt=1,
            tg_action="retry",
            mode="shadow",
        )
        == "pass_through"
    )


def test_off_mode_also_passes_through() -> None:
    # Defensive: mode=off is normally intercepted at the Adapter level
    # before policy is called, but the policy itself still short-circuits.
    p = _minimal_policy()
    assert (
        p.resolve(
            step_name="ner_v3",
            max_severity="critical",
            attempt=1,
            tg_action="retry",
            mode="off",
        )
        == "pass_through"
    )


# ---------------------------------------------------------------------------
# no-violations passthrough
# ---------------------------------------------------------------------------


def test_no_violations_yields_tg_action() -> None:
    p = _minimal_policy()
    assert (
        p.resolve(
            step_name="ner_v3",
            max_severity=None,
            attempt=1,
            tg_action="pass_through",
        )
        == "pass_through"
    )
    # If TG had asked for retry with no 华典 violations, policy trusts TG.
    assert (
        p.resolve(
            step_name="ner_v3",
            max_severity=None,
            attempt=1,
            tg_action="retry",
        )
        == "retry"
    )


# ---------------------------------------------------------------------------
# make_escalator
# ---------------------------------------------------------------------------


def test_make_escalator_binds_step_and_severity() -> None:
    p = _minimal_policy()
    escalator = p.make_escalator(
        step_name="ner_v3",
        max_severity="critical",
        mode="enforce",
    )
    # ner_v3 critical ladder = [retry, human_queue, fail_fast]
    assert escalator("retry", confidence=0.9, attempt=1) == "retry"
    assert escalator("retry", confidence=0.9, attempt=2) == "human_queue"
    assert escalator("retry", confidence=0.9, attempt=3) == "fail_fast"
    assert escalator("retry", confidence=0.9, attempt=9) == "fail_fast"


def test_make_escalator_shadow_mode_forces_pass_through() -> None:
    p = _minimal_policy()
    escalator = p.make_escalator(
        step_name="ner_v3",
        max_severity="critical",
        mode="shadow",
    )
    # Regardless of attempt, critical severity, etc., shadow short-circuits.
    assert escalator("retry", confidence=0.9, attempt=1) == "pass_through"
    assert escalator("retry", confidence=0.9, attempt=99) == "pass_through"


# ---------------------------------------------------------------------------
# max_severity helper
# ---------------------------------------------------------------------------


def test_max_severity_empty_is_none() -> None:
    assert max_severity([]) is None


def test_max_severity_picks_highest() -> None:
    assert max_severity([_v("info"), _v("critical"), _v("major")]) == "critical"
    assert max_severity([_v("minor"), _v("major")]) == "major"
    assert max_severity([_v("info"), _v("minor")]) == "minor"
    assert max_severity([_v("info")]) == "info"
