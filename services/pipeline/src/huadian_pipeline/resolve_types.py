"""Types for the identity resolution module.

These types are used by resolve_rules.py (scoring) and resolve.py (orchestration).
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any


@dataclass(frozen=True, slots=True)
class MatchResult:
    """Outcome of matching two persons under a single rule."""

    rule: str  # e.g. "R1", "R2", "R3", "R4", "R5"
    confidence: float  # 0.0–1.0
    evidence: dict[str, Any]  # rule-specific evidence payload for audit


@dataclass(slots=True)
class MergeProposal:
    """A proposed merge between two persons (confidence >= 0.9)."""

    person_a_id: str
    person_b_id: str
    person_a_name: str
    person_b_name: str
    match: MatchResult


@dataclass(slots=True)
class MergeGroup:
    """A connected component of persons to be soft-merged (Union-Find output)."""

    canonical_id: str
    canonical_name: str
    canonical_slug: str
    merged_ids: list[str]  # IDs of non-canonical persons to be soft-deleted
    merged_names: list[str]  # names of non-canonical persons (parallel to merged_ids)
    merged_slugs: list[str]  # slugs of non-canonical persons
    reason: str  # human-readable summary of why these were grouped
    proposals: list[MergeProposal]  # all proposals that connected this group


@dataclass(slots=True)
class HypothesisProposal:
    """A proposed identity hypothesis (confidence < 0.9, requires human review)."""

    person_a_id: str
    person_b_id: str
    person_a_name: str
    person_b_name: str
    match: MatchResult


@dataclass(slots=True)
class ResolveResult:
    """Full output of a single identity resolution run."""

    run_id: str
    total_persons: int
    merge_groups: list[MergeGroup] = field(default_factory=list)
    hypotheses: list[HypothesisProposal] = field(default_factory=list)
    errors: list[str] = field(default_factory=list)

    @property
    def total_merged_persons(self) -> int:
        """Total number of non-canonical persons that will be soft-deleted."""
        return sum(len(g.merged_ids) for g in self.merge_groups)

    @property
    def persons_after_merge(self) -> int:
        """Estimated person count after all merges are applied."""
        return self.total_persons - self.total_merged_persons
