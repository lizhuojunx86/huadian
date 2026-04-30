"""HuaDian classics — cross-dynasty temporal guard.

Blocks merge candidates whose dynasty midpoints differ by more than a
configured threshold (in years). Used by R1 (200yr threshold) and R6
(500yr threshold) — see `guard_chains.py`.

Loads dynasty period definitions from `data/dynasty-periods.yaml`.

License: Apache 2.0
Source: extracted from `services/pipeline/src/huadian_pipeline/r6_temporal_guards.py`
        `DynastyPeriod` + `cross_dynasty_guard`.
"""

from __future__ import annotations

import logging
import warnings
from dataclasses import dataclass, field
from pathlib import Path

try:
    import yaml

    _HAS_YAML = True
except ImportError:
    _HAS_YAML = False

from framework.identity_resolver import EntitySnapshot, GuardResult

logger = logging.getLogger(__name__)


def _default_periods_path() -> Path:
    """Locate `data/dynasty-periods.yaml` relative to the HuaDian project root.

    parents[0]=huadian_classics, [1]=examples, [2]=identity_resolver,
    [3]=framework, [4]=<project_root>
    """
    return Path(__file__).resolve().parents[4] / "data" / "dynasty-periods.yaml"


@dataclass(frozen=True, slots=True)
class DynastyPeriod:
    """A historical dynasty / period with approximate year range."""

    name: str
    start_year: int  # negative = BCE
    end_year: int
    midpoint: int
    aliases: tuple[str, ...] = field(default_factory=tuple)


def _load_dynasty_periods(path: Path | None = None) -> dict[str, DynastyPeriod]:
    """Load dynasty→period mapping from YAML.

    Returns a dict keyed by dynasty name AND each alias, all pointing
    to the same `DynastyPeriod` instance.
    """
    path = path or _default_periods_path()

    if not _HAS_YAML:
        warnings.warn(
            "PyYAML not installed; dynasty period mapping unavailable — "
            "cross_dynasty_guard disabled.",
            stacklevel=3,
        )
        return {}

    if not path.exists():
        warnings.warn(
            f"Dynasty periods file not found: {path}; cross_dynasty_guard disabled.",
            stacklevel=3,
        )
        return {}

    try:
        with path.open(encoding="utf-8") as fh:
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


# Module-level lazy singleton.
_dynasty_periods: dict[str, DynastyPeriod] | None = None


def _get_dynasty_periods() -> dict[str, DynastyPeriod]:
    global _dynasty_periods  # noqa: PLW0603
    if _dynasty_periods is None:
        _dynasty_periods = _load_dynasty_periods()
    return _dynasty_periods


def reset_dynasty_cache() -> None:
    """Reset cached dynasty periods (for testing)."""
    global _dynasty_periods  # noqa: PLW0603
    _dynasty_periods = None


def cross_dynasty_guard(
    entity_a: EntitySnapshot,
    entity_b: EntitySnapshot,
    *,
    threshold_years: int,
) -> GuardResult | None:
    """Block merge when dynasty midpoint gap > threshold_years.

    Reads the "dynasty" attribute from `domain_attrs` on each entity.
    If either entity is missing the attribute or has an unknown dynasty
    name, returns None (guard cannot evaluate; defers to other guards
    or allows merge).
    """
    periods = _get_dynasty_periods()

    dynasty_a = entity_a.domain_attrs.get("dynasty", "")
    dynasty_b = entity_b.domain_attrs.get("dynasty", "")

    if not dynasty_a or not dynasty_b:
        return None

    period_a = periods.get(dynasty_a)
    period_b = periods.get(dynasty_b)

    if period_a is None or period_b is None:
        unknown = dynasty_a if period_a is None else dynasty_b
        logger.warning(
            "cross_dynasty_guard: unknown dynasty '%s', skipping for %s ↔ %s",
            unknown,
            entity_a.name,
            entity_b.name,
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
