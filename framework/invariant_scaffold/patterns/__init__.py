"""5 invariant patterns from `docs/methodology/04-invariant-pattern.md`.

Each pattern is an Invariant subclass with a `from_template()` classmethod
that lets case domains construct an instance via SQL + parameter values
without needing to subclass.

Patterns:
    UpperBoundInvariant     — entity attr count must be ≤ N
    LowerBoundInvariant     — active entity must have ≥ N attribute
    ContainmentInvariant    — set A must be subset of set B
    OrphanDetectionInvariant — references must point to existing rows
    CardinalityBoundInvariant — entity-attr count must == N or in [min, max]

Source: docs/methodology/04 §2 + HuaDian V4/V6/V8/V9/V10/V11 实证.
"""

from __future__ import annotations

from .cardinality_bound import CardinalityBoundInvariant
from .containment import ContainmentInvariant
from .lower_bound import LowerBoundInvariant
from .orphan_detection import OrphanDetectionInvariant
from .upper_bound import UpperBoundInvariant

__all__ = [
    "CardinalityBoundInvariant",
    "ContainmentInvariant",
    "LowerBoundInvariant",
    "OrphanDetectionInvariant",
    "UpperBoundInvariant",
]
