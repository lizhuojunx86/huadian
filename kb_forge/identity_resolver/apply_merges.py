"""apply_merges() — write resolved merges to the case-domain DB.

The framework provides the merge-application orchestration; the case domain
provides the actual DB writes via the `MergeApplier` plugin.

A typical merge application involves 4 writes per merged entity:
    1. Soft-delete the non-canonical entity (set deleted_at + merged_into_id)
    2. Demote any primary names of the merged entity to alias
    3. Insert a row in the merge_log audit table
    4. (For guard-blocked pairs) insert a row in the triage / pending_review table

The case domain decides:
    - Schema: which tables, which columns, which constraints
    - Hypothesis policy: how to persist HypothesisProposals (or skip)
    - Audit semantics: what `merged_by` to record, what evidence to denormalize

License: Apache 2.0
Source: abstracted from `services/pipeline/src/huadian_pipeline/resolve.py`
        (HuaDian Sprint N first-cut framework abstraction).
"""

from __future__ import annotations

import logging
from typing import Any, Protocol

from .types import (
    BlockedMerge,
    HypothesisProposal,
    MergeGroup,
    ResolveResult,
)

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# MergeApplier plugin (required for apply_merges)
# ---------------------------------------------------------------------------


class MergeApplier(Protocol):
    """Required plugin: case-domain DB-write implementation for applied merges.

    The framework calls these methods inside a single transaction (the case
    domain manages the transaction). Each method either succeeds (counters
    increment) or raises (error logged, others continue per case-domain
    error policy).

    Reference impl: examples/huadian_classics/merge_applier.py
    """

    async def soft_delete_and_link(
        self,
        merged_id: str,
        canonical_id: str,
    ) -> None:
        """Set deleted_at and merged_into_id on the merged entity.

        Idempotent: if already deleted, the case domain may either skip or raise.
        """
        ...

    async def demote_primary_names(self, merged_id: str) -> int:
        """Demote any `primary` names on the merged entity to `alias`.

        Returns the count of names demoted (for logging).
        """
        ...

    async def write_merge_log(
        self,
        *,
        run_id: str,
        canonical_id: str,
        merged_id: str,
        merge_rule: str,
        confidence: float,
        evidence: dict[str, Any],
        merged_by: str,
    ) -> None:
        """Insert an audit row in the merge_log table."""
        ...

    async def write_hypothesis(self, hyp: HypothesisProposal) -> None:
        """Insert a row in the identity_hypotheses table (or domain equivalent).

        Implementations may use upsert / on-conflict-do-nothing semantics.
        """
        ...

    async def write_blocked_review(self, item: BlockedMerge) -> None:
        """Insert a row in the pending_merge_reviews / triage table.

        Implementations may use upsert / on-conflict-do-nothing semantics
        keyed on (entity_a_id, entity_b_id, proposed_rule, guard_type).
        """
        ...


# ---------------------------------------------------------------------------
# Helper: filter groups by skip-rules
# ---------------------------------------------------------------------------


def filter_groups_by_skip_rules(
    groups: list[MergeGroup],
    skip_rules: set[str],
) -> list[MergeGroup]:
    """Filter out merge groups whose proposals are ALL from skipped rules.

    A group is kept if at least one contributing proposal uses a non-skipped
    rule. A group is dropped only if ALL its proposals use skipped rules.

    Useful for staged rollouts: e.g. apply R1-R5 merges first, then run R6
    in a separate pass after Domain Expert reviews seed mappings.
    """
    if not skip_rules:
        return groups

    filtered: list[MergeGroup] = []
    for group in groups:
        has_non_skipped = any(prop.match.rule not in skip_rules for prop in group.proposals)
        if has_non_skipped:
            filtered.append(group)
        else:
            logger.info(
                "Skipping merge group %s (rules: %s): all proposals from skipped rules %s",
                group.canonical_name,
                [p.match.rule for p in group.proposals],
                skip_rules,
            )
    return filtered


# ---------------------------------------------------------------------------
# Public API: apply_merges
# ---------------------------------------------------------------------------


async def apply_merges(
    *,
    applier: MergeApplier,
    result: ResolveResult,
    dry_run: bool = True,
    merged_by: str = "framework:identity-resolver",
    skip_rules: set[str] | None = None,
) -> dict[str, Any]:
    """Apply (or dry-run) soft merges from a ResolveResult.

    Args:
        applier:     case-domain `MergeApplier` plugin
        result:      ResolveResult from `resolve_identities()`
        dry_run:     if True, count without writing (default True)
        merged_by:   attribution string written to the merge_log
        skip_rules:  set of rule names (e.g. {"R6"}) to exclude from apply.
                     Groups whose ALL proposals are from skipped rules drop.

    Returns:
        Summary dict with counts:
            run_id, dry_run, groups, groups_skipped, skip_rules,
            entities_soft_deleted, log_rows_inserted, hypotheses_queued,
            guard_blocked, guard_reviews_written, errors

    Note:
        Transaction management is the applier's responsibility — the framework
        does not start / commit transactions. Reference impls typically use:

            async with self.pool.acquire() as conn, conn.transaction():
                ...
    """
    active_groups = filter_groups_by_skip_rules(result.merge_groups, skip_rules or set())

    summary: dict[str, Any] = {
        "run_id": result.run_id,
        "dry_run": dry_run,
        "groups": len(active_groups),
        "groups_skipped": len(result.merge_groups) - len(active_groups),
        "skip_rules": sorted(skip_rules) if skip_rules else [],
        "entities_soft_deleted": 0,
        "log_rows_inserted": 0,
        "hypotheses_queued": len(result.hypotheses),
        "guard_blocked": len(result.blocked_merges),
        "guard_reviews_written": 0,
        "errors": [],
    }

    if dry_run:
        for group in active_groups:
            summary["entities_soft_deleted"] += len(group.merged_ids)
            summary["log_rows_inserted"] += len(group.merged_ids)
        logger.info(
            "[DRY RUN] Would soft-delete %d entities across %d groups "
            "(%d groups skipped, %d guard-blocked)",
            summary["entities_soft_deleted"],
            summary["groups"],
            summary["groups_skipped"],
            summary["guard_blocked"],
        )
        return summary

    for group in active_groups:
        for merged_id in group.merged_ids:
            relevant = [p for p in group.proposals if merged_id in (p.entity_a_id, p.entity_b_id)]
            best = max(relevant, key=lambda p: p.match.confidence) if relevant else None
            merge_rule = best.match.rule if best else "transitive"
            confidence = best.match.confidence if best else 0.0
            evidence = best.match.evidence if best else {}

            try:
                await applier.soft_delete_and_link(merged_id, group.canonical_id)

                demoted_count = await applier.demote_primary_names(merged_id)
                if demoted_count > 0:
                    logger.info(
                        "Demoted %d primary name(s) to alias for merged entity %s",
                        demoted_count,
                        merged_id,
                    )

                await applier.write_merge_log(
                    run_id=result.run_id,
                    canonical_id=group.canonical_id,
                    merged_id=merged_id,
                    merge_rule=merge_rule,
                    confidence=confidence,
                    evidence=evidence,
                    merged_by=merged_by,
                )

                summary["entities_soft_deleted"] += 1
                summary["log_rows_inserted"] += 1
            except Exception as exc:  # noqa: BLE001
                msg = f"Failed to merge entity {merged_id} into {group.canonical_id}: {exc}"
                logger.error(msg)
                summary["errors"].append(msg)

    # Hypotheses
    for hyp in result.hypotheses:
        try:
            await applier.write_hypothesis(hyp)
        except Exception as exc:  # noqa: BLE001
            msg = f"Failed to insert hypothesis ({hyp.entity_a_name}, {hyp.entity_b_name}): {exc}"
            logger.warning(msg)
            summary["errors"].append(msg)

    # Guard-blocked merges → triage table
    for item in result.blocked_merges:
        try:
            await applier.write_blocked_review(item)
            summary["guard_reviews_written"] += 1
        except Exception as exc:  # noqa: BLE001
            msg = (
                f"Failed to write blocked review for "
                f"{item.entity_a_name} ↔ {item.entity_b_name}: {exc}"
            )
            logger.error(msg)
            summary["errors"].append(msg)

    logger.info(
        "Applied: %d entities soft-deleted, %d log rows, %d guard reviews, %d errors",
        summary["entities_soft_deleted"],
        summary["log_rows_inserted"],
        summary["guard_reviews_written"],
        len(summary["errors"]),
    )
    return summary
