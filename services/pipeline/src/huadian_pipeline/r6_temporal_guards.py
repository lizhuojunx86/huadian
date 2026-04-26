"""Temporal guards — cross-dynasty / temporal distance checks for R rules.

Guard functions evaluate whether a proposed merge should be blocked based
on temporal distance between the two persons involved.

Architecture (T-P0-029 + T-P1-028 / ADR-025):
  evaluate_pair_guards(person_a, person_b, *, rule) -> GuardResult | None
    Rule-aware dispatch: looks up GUARD_THRESHOLDS[rule] and runs the
    cross_dynasty_guard with that threshold. Future guards (state_prefix,
    wikidata_attr) can be registered per-rule.

  evaluate_guards(person_a, person_b)  [DEPRECATED]
    Backward-compat wrapper for T-P0-029 callers; defaults to rule="R6".
    Retained until Sprint I closeout (ADR-025 §2.4).

Threshold rationale (ADR-025 §2.2):
  R1 (surface match, conf=0.95) → 200yr  (weak evidence, stricter guard)
  R6 (QID anchor,    conf=1.00) → 500yr  (strong evidence, looser guard)

Extension point:
  Add new guard functions and register per-rule thresholds. Future:
    - state_prefix_guard (Sprint I — covers gap=0 cross-state cases)
    - events-based temporal distance
    - dateOfBirth distance from Wikidata attributes
"""

from __future__ import annotations

import logging
import warnings
from dataclasses import dataclass, field
from pathlib import Path
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from .resolve_rules import PersonSnapshot

try:
    import yaml

    _HAS_YAML = True
except ImportError:
    _HAS_YAML = False

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Dynasty period mapping
# ---------------------------------------------------------------------------

_PROJECT_ROOT = Path(__file__).resolve().parents[4]
_DYNASTY_PERIODS_PATH = _PROJECT_ROOT / "data" / "dynasty-periods.yaml"


@dataclass(frozen=True, slots=True)
class DynastyPeriod:
    """A historical dynasty / period with approximate year range."""

    name: str
    start_year: int  # negative = BCE
    end_year: int
    midpoint: int
    aliases: tuple[str, ...] = field(default_factory=tuple)


def _load_dynasty_periods() -> dict[str, DynastyPeriod]:
    """Load dynasty→period mapping from YAML.

    Returns a dict keyed by dynasty name AND each alias, all pointing
    to the same DynastyPeriod instance.
    """
    if not _HAS_YAML:
        warnings.warn(
            "PyYAML not installed; dynasty period mapping unavailable — "
            "cross_dynasty_guard disabled.",
            stacklevel=3,
        )
        return {}

    if not _DYNASTY_PERIODS_PATH.exists():
        warnings.warn(
            f"Dynasty periods file not found: {_DYNASTY_PERIODS_PATH}; "
            "cross_dynasty_guard disabled.",
            stacklevel=3,
        )
        return {}

    try:
        with _DYNASTY_PERIODS_PATH.open(encoding="utf-8") as fh:
            data = yaml.safe_load(fh)
    except Exception as exc:  # noqa: BLE001
        warnings.warn(
            f"Failed to load dynasty periods: {exc}; cross_dynasty_guard disabled.",
            stacklevel=3,
        )
        return {}

    result: dict[str, DynastyPeriod] = {}
    for entry in data.get("periods", []):
        period = DynastyPeriod(
            name=entry["name"],
            start_year=entry["start_year"],
            end_year=entry["end_year"],
            midpoint=entry["midpoint"],
            aliases=tuple(entry.get("aliases", [])),
        )
        result[period.name] = period
        for alias in period.aliases:
            result[alias] = period

    logger.debug("Loaded %d dynasty period entries", len(result))
    return result


# Module-level lazy singleton
_dynasty_periods: dict[str, DynastyPeriod] | None = None


def _get_dynasty_periods() -> dict[str, DynastyPeriod]:
    """Get dynasty periods (lazy-loaded, cached)."""
    global _dynasty_periods  # noqa: PLW0603
    if _dynasty_periods is None:
        _dynasty_periods = _load_dynasty_periods()
    return _dynasty_periods


def reset_dynasty_cache() -> None:
    """Reset cached dynasty periods (for testing)."""
    global _dynasty_periods  # noqa: PLW0603
    _dynasty_periods = None


# ---------------------------------------------------------------------------
# Guard result type
# ---------------------------------------------------------------------------


@dataclass(frozen=True, slots=True)
class GuardResult:
    """Outcome of a single guard evaluation.

    If blocked=True, the merge candidate should NOT become a MergeProposal
    and should instead be written to pending_merge_reviews.
    """

    guard_type: str  # e.g. "cross_dynasty"
    blocked: bool
    reason: str  # human-readable explanation
    payload: dict[str, Any]  # structured data for pending_merge_reviews.guard_payload


# ---------------------------------------------------------------------------
# Guard implementations
# ---------------------------------------------------------------------------

# Backward-compat: T-P0-029 used CROSS_DYNASTY_THRESHOLD_YEARS as a module
# constant. ADR-025 makes the threshold per-rule (GUARD_THRESHOLDS below).
# This constant is preserved so older imports continue to work; it equals
# the R6 threshold for historical compatibility.
CROSS_DYNASTY_THRESHOLD_YEARS = 500

# ADR-025 §2.2 — rule-aware guard thresholds
GUARD_THRESHOLDS: dict[str, int] = {
    "R1": 200,  # T-P1-028: surface match, weak evidence → stricter guard
    "R6": 500,  # T-P0-029: QID anchor, strong evidence → looser guard
}


def cross_dynasty_guard(
    person_a: PersonSnapshot,
    person_b: PersonSnapshot,
    *,
    threshold_years: int,
) -> GuardResult | None:
    """Block merge when dynasty midpoint gap > threshold_years.

    threshold_years is required (ADR-025 §2.4). Callers should use
    evaluate_pair_guards() which dispatches via GUARD_THRESHOLDS.

    Returns GuardResult with blocked=True if the temporal distance exceeds
    the threshold, None if the guard cannot evaluate (missing data) or
    the pair is within threshold.
    """
    periods = _get_dynasty_periods()

    dynasty_a = person_a.dynasty
    dynasty_b = person_b.dynasty

    if not dynasty_a or not dynasty_b:
        return None

    period_a = periods.get(dynasty_a)
    period_b = periods.get(dynasty_b)

    if period_a is None or period_b is None:
        unknown = dynasty_a if period_a is None else dynasty_b
        logger.warning(
            "cross_dynasty_guard: unknown dynasty '%s', skipping guard for %s ↔ %s",
            unknown,
            person_a.name,
            person_b.name,
        )
        return None

    gap_years = abs(period_a.midpoint - period_b.midpoint)

    if gap_years > threshold_years:
        return GuardResult(
            guard_type="cross_dynasty",
            blocked=True,
            reason=(
                f"dynasty midpoint gap {gap_years}yr > "
                f"{threshold_years}yr threshold "
                f"({dynasty_a} vs {dynasty_b})"
            ),
            payload={
                "dynasty_a": dynasty_a,
                "dynasty_b": dynasty_b,
                "midpoint_a": period_a.midpoint,
                "midpoint_b": period_b.midpoint,
                "gap_years": gap_years,
                "threshold": threshold_years,
            },
        )

    return None


# ---------------------------------------------------------------------------
# Public API — rule-aware dispatch (ADR-025)
# ---------------------------------------------------------------------------


def evaluate_pair_guards(
    person_a: PersonSnapshot,
    person_b: PersonSnapshot,
    *,
    rule: str,
) -> GuardResult | None:
    """Rule-aware guard chain dispatch (ADR-025 §2.1).

    Looks up GUARD_THRESHOLDS[rule] and runs cross_dynasty_guard with that
    threshold. Rules not in GUARD_THRESHOLDS receive no guard (returns
    None — guard is opt-in per rule).

    Args:
        person_a, person_b: candidate merge pair
        rule: rule name string ("R1", "R6", ...)

    Returns:
        GuardResult with blocked=True if any guard blocks the merge;
        None if no guard fires or the rule has no registered threshold.
    """
    threshold = GUARD_THRESHOLDS.get(rule)
    if threshold is None:
        return None

    result = cross_dynasty_guard(person_a, person_b, threshold_years=threshold)
    if result is not None and result.blocked:
        return result
    return None


def evaluate_guards(
    person_a: PersonSnapshot,
    person_b: PersonSnapshot,
) -> GuardResult | None:
    """[DEPRECATED — Sprint I removal] Run guards for R6 (legacy callers).

    Use evaluate_pair_guards(a, b, rule='R6') instead. Retained per
    ADR-025 §2.4 until Sprint I closeout to give third-party callers
    time to migrate.
    """
    warnings.warn(
        "evaluate_guards() is deprecated; use evaluate_pair_guards(a, b, rule='R6'). "
        "Will be removed at Sprint I closeout (ADR-025 §2.4).",
        DeprecationWarning,
        stacklevel=2,
    )
    return evaluate_pair_guards(person_a, person_b, rule="R6")
