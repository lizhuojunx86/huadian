"""Guard chain protocol — pluggable per-rule guards that block merges.

A "guard" is a domain-specific function that examines a candidate merge pair
and decides whether to block it. Examples from HuaDian:

    cross_dynasty_guard:  block R6 (QID match) if dynasty midpoints are
                          > 500 years apart (different historical eras).
    state_prefix_guard:   block R1 (surface match) if both names are
                          (state)(shihao)(title) with different states.

The framework provides:
    1. The `GuardResult` data type (what guards return).
    2. The `GuardFn` Callable protocol (what guards look like).
    3. `evaluate_pair_guards()` — first-blocked-wins dispatcher.

The framework provides NO concrete guards — those are domain-specific.
HuaDian's `cross_dynasty_guard` and `state_prefix_guard` live in
`framework/identity-resolver/examples/huadian_classics/` as reference
implementations.

License: Apache 2.0
Source: abstracted from `services/pipeline/src/huadian_pipeline/r6_temporal_guards.py`
        (HuaDian Sprint N first-cut framework abstraction).
"""

from __future__ import annotations

from collections.abc import Callable
from dataclasses import dataclass
from typing import Any

from .entity import EntitySnapshot


@dataclass(frozen=True, slots=True)
class GuardResult:
    """Outcome of a single guard evaluation.

    If `blocked=True`, the candidate merge should NOT become a `MergeProposal`
    — it should be written to the case domain's triage table (e.g.
    `pending_merge_reviews`) for Domain Expert review.

    `guard_type` is a free-form string identifying which guard fired. Case
    domains can use any naming scheme: "cross_dynasty" / "jurisdiction_split"
    / "drug_class_mismatch" / etc.

    `payload` is structured evidence written to the triage table for the
    Domain Expert to review. Payload schema is the case domain's choice;
    the framework only requires it be JSON-serializable.
    """

    guard_type: str
    blocked: bool
    reason: str  # human-readable explanation
    payload: dict[str, Any]  # structured data for triage review


# A guard function takes two EntitySnapshots and returns either:
#   - GuardResult(blocked=True, ...)  → block the merge
#   - GuardResult(blocked=False, ...) → guard ran but did not block
#   - None → guard could not evaluate (e.g. missing required attribute)
GuardFn = Callable[[EntitySnapshot, EntitySnapshot], "GuardResult | None"]


def evaluate_pair_guards(
    entity_a: EntitySnapshot,
    entity_b: EntitySnapshot,
    *,
    rule: str,
    guard_chains: dict[str, list[GuardFn]],
) -> GuardResult | None:
    """Rule-aware guard chain dispatch (first-blocked-wins).

    Iterates `guard_chains[rule]` in order and returns the first blocking
    `GuardResult`. Rules not in `guard_chains` receive no guard (returns
    `None` — guards are opt-in per rule).

    Args:
        entity_a, entity_b: candidate merge pair
        rule:               rule name string (e.g. "R1", "R6", or domain-defined)
        guard_chains:       dict mapping rule name → ordered list of guards;
                            case domains construct this dict themselves.

    Returns:
        `GuardResult` with `blocked=True` if any guard blocks the merge;
        `None` if no guard fires or the rule has no registered chain.

    Example (HuaDian classics reference impl):

        from framework.identity_resolver.examples.huadian_classics.guard_chains \\
            import HUADIAN_GUARD_CHAINS

        result = evaluate_pair_guards(
            person_a, person_b,
            rule="R6",
            guard_chains=HUADIAN_GUARD_CHAINS,
        )
        if result and result.blocked:
            ...  # write to pending_merge_reviews
    """
    for guard_fn in guard_chains.get(rule, []):
        result = guard_fn(entity_a, entity_b)
        if result is not None and result.blocked:
            return result
    return None
