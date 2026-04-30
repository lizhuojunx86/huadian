"""HuaDian classics — guard chain registration for R1 / R6.

Defines `HUADIAN_GUARD_CHAINS` — the dict[rule_name, list[GuardFn]] that
the case domain passes to `resolve_identities()`.

Per ADR-025 (HuaDian Sprint H/I):
    R1 (surface match, conf 0.95): cross_dynasty(200yr) → state_prefix
    R6 (QID anchor, conf 1.00):    cross_dynasty(500yr)

Threshold rationale:
    - R6 (strong evidence) gets a looser temporal threshold (500yr).
    - R1 (weak evidence) gets a stricter temporal threshold (200yr) AND
      a state_prefix guard for Spring-Autumn ruler-name disambiguation.

License: Apache 2.0
Source: extracted from `services/pipeline/src/huadian_pipeline/r6_temporal_guards.py`
        `GUARD_CHAINS` + `GUARD_THRESHOLDS`.
"""

from __future__ import annotations

from framework.identity_resolver import GuardFn

from .dynasty_guard import cross_dynasty_guard
from .state_prefix_guard import state_prefix_guard

# Threshold values per rule (ADR-025 §2.2)
HUADIAN_GUARD_THRESHOLDS: dict[str, int] = {
    "R1": 200,
    "R6": 500,
}

# Ordered guard chain per rule; first-blocked-wins.
HUADIAN_GUARD_CHAINS: dict[str, list[GuardFn]] = {
    "R1": [
        lambda a, b: cross_dynasty_guard(a, b, threshold_years=HUADIAN_GUARD_THRESHOLDS["R1"]),
        state_prefix_guard,
    ],
    "R6": [
        lambda a, b: cross_dynasty_guard(a, b, threshold_years=HUADIAN_GUARD_THRESHOLDS["R6"]),
    ],
}

# Known guard types (for dry_run_report subgroup display).
HUADIAN_KNOWN_GUARD_TYPES: tuple[str, ...] = ("cross_dynasty", "state_prefix")
