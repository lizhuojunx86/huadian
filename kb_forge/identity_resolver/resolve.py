"""resolve_identities() — main entity-resolution orchestration.

This is the framework entry point that ties together:
    - EntityLoader plugin (DB / API / file source)
    - SeedMatchAdapter plugin (optional R6 pre-pass)
    - rules.score_pair() (R1-R5 + custom rules)
    - guards.evaluate_pair_guards() (case-domain guards)
    - canonical.select_canonical() (merge group representative)
    - UnionFind (transitive closure)
    - dry_run_report.build_reason_summary() (human-readable reason)

The flow is domain-agnostic. The case domain provides plugins; the framework
runs the algorithm.

License: Apache 2.0
Source: abstracted from `services/pipeline/src/huadian_pipeline/resolve.py`
        (HuaDian Sprint N first-cut framework abstraction).
"""

from __future__ import annotations

import logging
import uuid
from collections import defaultdict
from typing import Protocol

from .canonical import select_canonical
from .dry_run_report import (
    DefaultReasonBuilder,
    ReasonBuilder,
    build_reason_summary,
)
from .entity import EntitySnapshot
from .guards import GuardFn, evaluate_pair_guards
from .r6_seed_match import R6PrePassResult, R6Status
from .rules import ScorePairContext, score_pair
from .rules_protocols import CanonicalHint
from .types import (
    BlockedMerge,
    HypothesisProposal,
    MatchResult,
    MergeGroup,
    MergeProposal,
    ResolveResult,
)
from .union_find import UnionFind
from .utils import swap_ab_payload

logger = logging.getLogger(__name__)

_R6_CONFIDENCE_CUTOFF_DEFAULT = 0.80


# ---------------------------------------------------------------------------
# Plugin protocols (case-domain implements these)
# ---------------------------------------------------------------------------


class EntityLoader(Protocol):
    """Required plugin: load all resolvable entities from the case-domain DB.

    Returns a flat list of `EntitySnapshot` (or `PersonSnapshot`) objects.
    The framework does not care where the data came from — Postgres, MongoDB,
    a CSV file, an API call, etc.

    Reference impl: examples/huadian_classics/person_loader.py
    """

    async def load_all(self) -> list[EntitySnapshot]:
        """Return all entities to be considered for resolution."""
        ...


class R6PrePassRunner(Protocol):
    """Optional plugin: pre-pass loader that attaches R6 seed-match to entities.

    The pre-pass differs from on-demand R6 lookup (`SeedMatchAdapter`) in that
    it operates on a batch — given a list of entities, it queries each one's
    seed_mapping in a single bulk operation and attaches an `R6PrePassResult`
    to each entity (`entity.seed_match`).

    The case domain implements this for efficiency. If not provided, R6 is
    not pre-passed (it can still be evaluated on-demand via SeedMatchAdapter,
    but pre-pass is the standard pattern for batch resolution).

    Reference impl: examples/huadian_classics/r6_prepass_runner.py
    """

    async def attach_seed_matches(
        self,
        entities: list[EntitySnapshot],
    ) -> dict[str, int]:
        """Mutate each entity to set `entity.seed_match` (an R6PrePassResult).

        Returns:
            Distribution dict, e.g. {"matched": 12, "not_found": 716, ...}
            for ResolveResult.r6_distribution.
        """
        ...


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------


def _detect_r6_merges(
    entities: list[EntitySnapshot],
    *,
    guard_chains: dict[str, list[GuardFn]] | None,
) -> tuple[list[MergeProposal], list[BlockedMerge]]:
    """Detect merge proposals from R6 pre-pass: two entities mapping to same QID.

    Only MATCHED-status results are considered. Two entities sharing the
    same `external_id` produce a MergeProposal with rule="R6" and
    confidence=1.0.

    Before generating each proposal, runs the case domain's guard chain
    for rule "R6". Guard-blocked pairs become BlockedMerge instead.
    """
    by_qid: dict[str, list[EntitySnapshot]] = defaultdict(list)
    for snap in entities:
        sm = snap.seed_match
        if (
            sm is not None
            and isinstance(sm, R6PrePassResult)
            and sm.status == R6Status.MATCHED
            and sm.qid is not None
        ):
            by_qid[sm.qid].append(snap)

    proposals: list[MergeProposal] = []
    blocked: list[BlockedMerge] = []

    for qid, group in by_qid.items():
        if len(group) < 2:
            continue
        for i in range(len(group)):
            for j in range(i + 1, len(group)):
                a, b = group[i], group[j]
                r6_evidence = {
                    "external_id": qid,
                    "source": "wikidata",  # case domains override via SeedMatchAdapter
                    "pre_pass": True,
                }

                guard_result = (
                    evaluate_pair_guards(a, b, rule="R6", guard_chains=guard_chains)
                    if guard_chains is not None
                    else None
                )
                if guard_result is not None and guard_result.blocked:
                    if a.id < b.id:
                        aid, bid, aname, bname = a.id, b.id, a.name, b.name
                        guard_payload = guard_result.payload
                    else:
                        aid, bid, aname, bname = b.id, a.id, b.name, a.name
                        guard_payload = swap_ab_payload(guard_result.payload)

                    blocked.append(
                        BlockedMerge(
                            entity_a_id=aid,
                            entity_b_id=bid,
                            entity_a_name=aname,
                            entity_b_name=bname,
                            proposed_rule="R6",
                            guard_type=guard_result.guard_type,
                            guard_payload=guard_payload,
                            evidence=r6_evidence,
                        )
                    )
                    logger.info(
                        "R6 guard blocked: %s ↔ %s — %s",
                        a.name,
                        b.name,
                        guard_result.reason,
                    )
                    continue

                proposals.append(
                    MergeProposal(
                        entity_a_id=a.id,
                        entity_b_id=b.id,
                        entity_a_name=a.name,
                        entity_b_name=b.name,
                        match=MatchResult(rule="R6", confidence=1.0, evidence=r6_evidence),
                    )
                )

    return proposals, blocked


# ---------------------------------------------------------------------------
# Public API: resolve_identities
# ---------------------------------------------------------------------------


async def resolve_identities(
    *,
    loader: EntityLoader,
    score_context: ScorePairContext,
    guard_chains: dict[str, list[GuardFn]] | None = None,
    r6_prepass: R6PrePassRunner | None = None,
    canonical_hint: CanonicalHint | None = None,
    reason_builder: ReasonBuilder | None = None,
) -> ResolveResult:
    """Run identity resolution end-to-end.

    Args:
        loader:           required EntityLoader plugin (case-domain DB source)
        score_context:    bundle of plugin data for R1-R5 (build via
                          `rules.build_score_pair_context()`)
        guard_chains:     optional dict[rule_name, list[GuardFn]]; if None,
                          no guards run (no merges are blocked)
        r6_prepass:       optional R6 pre-pass plugin; if None, R6 detection
                          is skipped (other rules still run)
        canonical_hint:   optional plugin for domain-specific canonical demotion
        reason_builder:   optional plugin for evidence formatting (default
                          English `DefaultReasonBuilder`)

    Returns:
        ResolveResult with merge_groups / hypotheses / blocked_merges.
        Does not write to DB — use `apply_merges()` for that.
    """
    run_id = str(uuid.uuid4())
    result = ResolveResult(run_id=run_id, total_entities=0)
    builder = reason_builder or DefaultReasonBuilder()

    entities = await loader.load_all()
    result.total_entities = len(entities)

    # Optional R6 pre-pass
    if r6_prepass is not None:
        result.r6_distribution = await r6_prepass.attach_seed_matches(entities)

    logger.info("Loaded %d entities for identity resolution (run_id=%s)", len(entities), run_id)

    if len(entities) < 2:
        return result

    merge_proposals: list[MergeProposal] = []
    hyp_proposals: list[HypothesisProposal] = []
    errors: list[str] = []

    # O(n^2) pairwise evaluation (acceptable for batch sizes up to a few thousand)
    for i in range(len(entities)):
        for j in range(i + 1, len(entities)):
            a, b = entities[i], entities[j]
            try:
                match = score_pair(a, b, score_context)
            except Exception as exc:  # noqa: BLE001
                msg = f"score_pair failed for ({a.name}, {b.name}): {exc}"
                logger.warning(msg)
                errors.append(msg)
                continue

            if match is None:
                continue

            if match.confidence >= score_context.merge_threshold:
                guard_result = (
                    evaluate_pair_guards(a, b, rule=match.rule, guard_chains=guard_chains)
                    if guard_chains is not None
                    else None
                )
                if guard_result is not None and guard_result.blocked:
                    if a.id < b.id:
                        aid, bid, aname, bname = a.id, b.id, a.name, b.name
                        guard_payload = guard_result.payload
                    else:
                        aid, bid, aname, bname = b.id, a.id, b.name, a.name
                        guard_payload = swap_ab_payload(guard_result.payload)

                    result.blocked_merges.append(
                        BlockedMerge(
                            entity_a_id=aid,
                            entity_b_id=bid,
                            entity_a_name=aname,
                            entity_b_name=bname,
                            proposed_rule=match.rule,
                            guard_type=guard_result.guard_type,
                            guard_payload=guard_payload,
                            evidence=match.evidence,
                        )
                    )
                    logger.info(
                        "%s guard blocked: %s ↔ %s — %s",
                        match.rule,
                        a.name,
                        b.name,
                        guard_result.reason,
                    )
                    continue

                merge_proposals.append(
                    MergeProposal(
                        entity_a_id=a.id,
                        entity_b_id=b.id,
                        entity_a_name=a.name,
                        entity_b_name=b.name,
                        match=match,
                    )
                )
            else:
                hyp_proposals.append(
                    HypothesisProposal(
                        entity_a_id=a.id,
                        entity_b_id=b.id,
                        entity_a_name=a.name,
                        entity_b_name=b.name,
                        match=match,
                    )
                )

    # R6 same-QID merge detection (uses pre-pass results)
    r6_proposals, r6_blocked = _detect_r6_merges(entities, guard_chains=guard_chains)
    merge_proposals.extend(r6_proposals)
    result.blocked_merges.extend(r6_blocked)

    result.errors.extend(errors)
    result.hypotheses = hyp_proposals

    logger.info(
        "Pairwise evaluation: %d merge proposals (%d R1-R5, %d R6), "
        "%d guard-blocked, %d hypotheses",
        len(merge_proposals),
        len(merge_proposals) - len(r6_proposals),
        len(r6_proposals),
        len(r6_blocked) + (len(result.blocked_merges) - len(r6_blocked)),
        len(hyp_proposals),
    )

    if not merge_proposals:
        return result

    # Build Union-Find for transitive closure
    entity_by_id = {p.id: p for p in entities}
    uf = UnionFind([p.id for p in entities])
    for prop in merge_proposals:
        uf.union(prop.entity_a_id, prop.entity_b_id)

    # Convert connected components into MergeGroups
    components = uf.groups()
    for _root_id, member_ids in components.items():
        member_set = set(member_ids)
        group_entities = [entity_by_id[mid] for mid in member_ids]
        canonical = select_canonical(group_entities, canonical_hint=canonical_hint)
        non_canonical = [p for p in group_entities if p.id != canonical.id]

        group_proposals = [
            prop
            for prop in merge_proposals
            if prop.entity_a_id in member_set and prop.entity_b_id in member_set
        ]

        reason = build_reason_summary(
            canonical_name=canonical.name,
            canonical_slug=canonical.slug,
            proposals=group_proposals,
            builder=builder,
        )

        result.merge_groups.append(
            MergeGroup(
                canonical_id=canonical.id,
                canonical_name=canonical.name,
                canonical_slug=canonical.slug,
                merged_ids=[p.id for p in non_canonical],
                merged_names=[p.name for p in non_canonical],
                merged_slugs=[p.slug for p in non_canonical],
                reason=reason,
                proposals=group_proposals,
            )
        )

    logger.info(
        "Union-Find: %d merge groups, %d entities to soft-delete",
        len(result.merge_groups),
        result.total_merged_entities,
    )

    return result
