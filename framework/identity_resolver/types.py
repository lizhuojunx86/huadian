"""Data contracts for the identity-resolver framework.

These types are the public API for case-domain code that consumes resolver
output (MergeProposal / MergeGroup / BlockedMerge / ResolveResult). They are
domain-agnostic — values like rule="R6" or guard_type="cross_dynasty" are
strings the case domain populates, not framework-defined enums.

License: Apache 2.0
Source: abstracted from `services/pipeline/src/huadian_pipeline/resolve_types.py`
        (HuaDian Sprint N first-cut framework abstraction).
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any


@dataclass(frozen=True, slots=True)
class MatchResult:
    """Outcome of matching two entities under a single rule.

    `rule` is a free-form string identifying which rule fired (e.g. "R1"
    "R6", or your domain rules like "drug-dosage-similarity"). The framework
    does not enforce an enum — case domains are free to invent new rules.
    """

    rule: str  # e.g. "R1" / "R6" / domain-defined name
    confidence: float  # 0.0–1.0
    evidence: dict[str, Any]  # rule-specific evidence payload for audit


@dataclass(slots=True)
class MergeProposal:
    """A proposed merge between two entities (confidence >= MERGE_THRESHOLD).

    `entity_a_id` and `entity_b_id` are case-domain identifiers (string-typed
    so UUIDs or any other ID scheme works).
    """

    entity_a_id: str
    entity_b_id: str
    entity_a_name: str
    entity_b_name: str
    match: MatchResult


@dataclass(slots=True)
class MergeGroup:
    """A connected component of entities to be soft-merged (Union-Find output).

    The framework does not prescribe how the merge is applied — that is the
    job of `MergeApplier` (see apply_merges.py). MergeGroup is just the
    structured result of grouping merge proposals via transitive closure.
    """

    canonical_id: str
    canonical_name: str
    canonical_slug: str
    merged_ids: list[str]  # IDs of non-canonical entities to be soft-deleted
    merged_names: list[str]  # names of non-canonical entities (parallel to merged_ids)
    merged_slugs: list[str]  # slugs of non-canonical entities
    reason: str  # human-readable summary of why these were grouped
    proposals: list[MergeProposal]  # all proposals that connected this group


@dataclass(slots=True)
class HypothesisProposal:
    """A proposed identity hypothesis (confidence < MERGE_THRESHOLD).

    Hypotheses are weaker signals — they should be queued for human review
    rather than auto-merged. The framework does not enforce a default
    threshold; that is configured in `rules.MERGE_CONFIDENCE_THRESHOLD`.
    """

    entity_a_id: str
    entity_b_id: str
    entity_a_name: str
    entity_b_name: str
    match: MatchResult


@dataclass(frozen=True, slots=True)
class BlockedMerge:
    """A proposed merge blocked by a guard chain.

    Written to a case-domain triage table (e.g. pending_merge_reviews) for
    Domain Expert review. Pair-order normalization (entity_a_id < entity_b_id)
    is the case domain's responsibility if their schema requires it.
    """

    entity_a_id: str
    entity_b_id: str
    entity_a_name: str
    entity_b_name: str
    proposed_rule: str  # e.g. "R6" / "R1" / domain-defined
    guard_type: str  # e.g. "cross_dynasty" / "state_prefix" / domain-defined
    guard_payload: dict[str, Any]  # structured guard evidence
    evidence: dict[str, Any]  # original rule evidence


@dataclass(slots=True)
class ResolveResult:
    """Full output of a single identity-resolution run.

    `r6_distribution` is included for cases that use the optional R6 (external
    anchor lookup) rule; cases that don't use R6 will see an empty dict. The
    framework does not gate anything on this field's presence.
    """

    run_id: str
    total_entities: int
    merge_groups: list[MergeGroup] = field(default_factory=list)
    hypotheses: list[HypothesisProposal] = field(default_factory=list)
    blocked_merges: list[BlockedMerge] = field(default_factory=list)
    errors: list[str] = field(default_factory=list)
    r6_distribution: dict[str, int] = field(default_factory=dict)

    @property
    def total_merged_entities(self) -> int:
        """Total non-canonical entities that will be soft-deleted."""
        return sum(len(g.merged_ids) for g in self.merge_groups)

    @property
    def entities_after_merge(self) -> int:
        """Estimated entity count after all merges are applied."""
        return self.total_entities - self.total_merged_entities


# ---------------------------------------------------------------------------
# Backward-compat aliases (for case domains migrating from huadian_pipeline)
# ---------------------------------------------------------------------------
# The huadian-pipeline original used "person" terminology. The framework
# uses "entity" because identity resolution is not person-specific.
# These aliases let existing case-domain code that references *_persons
# continue to work without churn.

PersonProposal = MergeProposal
"""Alias for MergeProposal (entities → persons / case-domain compatibility)."""
