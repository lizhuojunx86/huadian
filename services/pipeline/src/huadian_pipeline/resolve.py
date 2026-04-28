"""Identity resolver — cross-chunk person deduplication.

Entry points:
  resolve_identities(pool) -> ResolveResult
      Reads all persons from DB, evaluates all O(n^2) pairs via rules engine,
      builds Union-Find connected components, returns a ResolveResult.

  apply_merges(pool, result, dry_run=True)
      Applies (or dry-runs) soft merges: sets deleted_at + merged_into_id on
      non-canonical persons, writes person_merge_log rows.

  select_canonical(persons) -> PersonSnapshot
      Canonical selection priority (ADR-010 + T-P0-013):
        1. has_pinyin_slug (not u{hex} fallback)
        2. NOT a 帝X honorific with bare-name peer in group
        3. more surface_forms (len)
        4. earlier created_at
        5. smaller id (stable tiebreaker)

  generate_dry_run_report(result) -> str
      Produces a human-readable report string.
"""

from __future__ import annotations

import logging
import uuid
from dataclasses import dataclass
from datetime import UTC, datetime
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    import asyncpg

from .r6_seed_match import R6Status
from .r6_temporal_guards import evaluate_pair_guards
from .resolve_rules import (
    MERGE_CONFIDENCE_THRESHOLD,
    PersonSnapshot,
    has_di_prefix_peer,
    score_pair,
)
from .resolve_types import (
    BlockedMerge,
    HypothesisProposal,
    MatchResult,
    MergeGroup,
    MergeProposal,
    ResolveResult,
)

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Union-Find (path compression + union by rank)
# ---------------------------------------------------------------------------


class UnionFind:
    """Disjoint-set data structure for transitive closure of merge proposals."""

    def __init__(self, ids: list[str]) -> None:
        self._parent: dict[str, str] = {i: i for i in ids}
        self._rank: dict[str, int] = {i: 0 for i in ids}

    def find(self, x: str) -> str:
        """Find root with path compression."""
        if self._parent[x] != x:
            self._parent[x] = self.find(self._parent[x])
        return self._parent[x]

    def union(self, x: str, y: str) -> None:
        """Merge the sets containing x and y (union by rank)."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return
        if self._rank[rx] < self._rank[ry]:
            rx, ry = ry, rx
        self._parent[ry] = rx
        if self._rank[rx] == self._rank[ry]:
            self._rank[rx] += 1

    def groups(self) -> dict[str, list[str]]:
        """Return a mapping of root_id → [member_ids] for groups of size >= 2."""
        from collections import defaultdict

        buckets: dict[str, list[str]] = defaultdict(list)
        for node in self._parent:
            buckets[self.find(node)].append(node)
        return {root: members for root, members in buckets.items() if len(members) >= 2}


# ---------------------------------------------------------------------------
# DB loading
# ---------------------------------------------------------------------------


async def _load_persons(conn: Any) -> list[PersonSnapshot]:
    """Load all non-deleted persons with their surface_forms from DB."""
    # Fetch persons
    person_rows = await conn.fetch(
        """
        SELECT
            p.id::text,
            p.name->>'zh-Hans' AS name_zh,
            p.slug,
            COALESCE(p.dynasty, '') AS dynasty,
            p.created_at::text
        FROM persons p
        WHERE p.deleted_at IS NULL
        ORDER BY p.created_at
        """
    )

    if not person_rows:
        return []

    person_ids = [row["id"] for row in person_rows]

    # Fetch all person_names in one query
    name_rows = await conn.fetch(
        """
        SELECT pn.person_id::text, pn.name
        FROM person_names pn
        WHERE pn.person_id = ANY($1::uuid[])
        """,
        person_ids,
    )

    # Build surface_forms map: person_id → set of name strings
    from collections import defaultdict

    names_by_person: dict[str, set[str]] = defaultdict(set)
    for row in name_rows:
        names_by_person[row["person_id"]].add(row["name"])

    # Fetch identity notes from a supplementary source if available.
    # Currently identity_notes are stored on persons via biography or a
    # dedicated column.  For Phase 0 we query person_names where name_type
    # stores notes-like data, but fall back gracefully.
    notes_by_person: dict[str, list[str]] = defaultdict(list)
    try:
        note_rows = await conn.fetch(
            """
            SELECT p.id::text, p.identity_notes
            FROM persons p
            WHERE p.deleted_at IS NULL
              AND p.identity_notes IS NOT NULL
              AND p.identity_notes != ''
            """
        )
        for row in note_rows:
            notes_by_person[row["id"]].append(row["identity_notes"])
    except Exception:  # noqa: BLE001
        # identity_notes column may not exist yet; silently ignore
        pass

    snapshots: list[PersonSnapshot] = []
    for row in person_rows:
        pid = row["id"]
        name = row["name_zh"] or ""
        slug = row["slug"] or ""
        dynasty = row["dynasty"] or ""
        created_at = row["created_at"] or ""

        surface_forms = names_by_person.get(pid, set())
        identity_notes = notes_by_person.get(pid, [])

        snapshots.append(
            PersonSnapshot(
                id=pid,
                name=name,
                slug=slug,
                dynasty=dynasty,
                surface_forms=surface_forms,
                identity_notes=identity_notes,
                created_at=created_at,
            )
        )

    return snapshots


# ---------------------------------------------------------------------------
# R6 seed-match pre-pass (T-P0-027 Sprint C)
# ---------------------------------------------------------------------------

# Cutoff mirroring r6_seed_match default — active mappings below this
# confidence are tagged BELOW_CUTOFF rather than MATCHED.
_R6_CONFIDENCE_CUTOFF = 0.80


@dataclass(frozen=True, slots=True)
class R6PrePassResult:
    """Result of the internal R6 pre-pass for a single person.

    Distinct from R6Result (external lookup mode). The pre-pass queries
    seed_mappings by target_entity_id (FK direct), never by name.
    """

    status: R6Status
    qid: str | None = None
    entry_id: str | None = None
    confidence: float | None = None


async def _r6_prepass(conn: Any, snapshots: list[PersonSnapshot]) -> dict[str, int]:
    """Batch-load active seed_mappings for all persons via FK direct query.

    For each person, derives an R6PrePassResult:
      - confidence >= cutoff → MATCHED
      - confidence < cutoff  → BELOW_CUTOFF
      - multiple active rows → AMBIGUOUS (data quality issue, logged as warning)
      - no active row        → NOT_FOUND

    Attaches result to PersonSnapshot.r6_result and returns status distribution.
    """
    person_ids = [snap.id for snap in snapshots]

    rows = await conn.fetch(
        """
        SELECT sm.target_entity_id::text AS person_id,
               de.external_id AS qid,
               de.id::text AS entry_id,
               sm.confidence
        FROM seed_mappings sm
        JOIN dictionary_entries de ON de.id = sm.dictionary_entry_id
        WHERE sm.target_entity_type = 'person'
          AND sm.target_entity_id = ANY($1::uuid[])
          AND sm.mapping_status = 'active'
        ORDER BY sm.target_entity_id, sm.confidence DESC
        """,
        person_ids,
    )

    # Group rows by person_id
    from collections import defaultdict

    by_person: dict[str, list[Any]] = defaultdict(list)
    for row in rows:
        by_person[row["person_id"]].append(row)

    distribution: dict[str, int] = {
        "matched": 0,
        "below_cutoff": 0,
        "ambiguous": 0,
        "not_found": 0,
    }

    for snap in snapshots:
        mapping_rows = by_person.get(snap.id, [])

        if not mapping_rows:
            snap.r6_result = R6PrePassResult(status=R6Status.NOT_FOUND)
            distribution["not_found"] += 1
        elif len(mapping_rows) > 1:
            logger.warning(
                "R6 pre-pass: person %s (%s) has %d active seed_mappings — "
                "marking AMBIGUOUS (data quality issue)",
                snap.id,
                snap.name,
                len(mapping_rows),
            )
            snap.r6_result = R6PrePassResult(status=R6Status.AMBIGUOUS)
            distribution["ambiguous"] += 1
        else:
            row = mapping_rows[0]
            conf = float(row["confidence"]) if row["confidence"] is not None else 0.0
            if conf >= _R6_CONFIDENCE_CUTOFF:
                snap.r6_result = R6PrePassResult(
                    status=R6Status.MATCHED,
                    qid=row["qid"],
                    entry_id=row["entry_id"],
                    confidence=conf,
                )
                distribution["matched"] += 1
            else:
                snap.r6_result = R6PrePassResult(
                    status=R6Status.BELOW_CUTOFF,
                    qid=row["qid"],
                    entry_id=row["entry_id"],
                    confidence=conf,
                )
                distribution["below_cutoff"] += 1

    logger.info(
        "R6 pre-pass complete: %d persons — matched=%d, not_found=%d, "
        "below_cutoff=%d, ambiguous=%d",
        len(snapshots),
        distribution["matched"],
        distribution["not_found"],
        distribution["below_cutoff"],
        distribution["ambiguous"],
    )
    return distribution


def _detect_r6_merges(
    snapshots: list[PersonSnapshot],
) -> tuple[list[MergeProposal], list[BlockedMerge]]:
    """Detect merge proposals from R6 pre-pass: two persons mapping to the same QID.

    Only MATCHED-status results are considered (裁决 4).
    Two persons with the same external_id (QID) produce a MergeProposal with
    rule="R6" and confidence=1.0.

    T-P0-029: Before generating a MergeProposal, runs temporal guards
    (evaluate_guards). Guard-blocked pairs are returned as BlockedMerge
    items instead of MergeProposal items.

    Returns:
        (proposals, blocked) — proposals go to Union-Find; blocked go to
        pending_merge_reviews via apply_merges().
    """
    from collections import defaultdict

    # Group MATCHED persons by QID
    by_qid: dict[str, list[PersonSnapshot]] = defaultdict(list)
    for snap in snapshots:
        if (
            snap.r6_result is not None
            and snap.r6_result.status == R6Status.MATCHED
            and snap.r6_result.qid is not None
        ):
            by_qid[snap.r6_result.qid].append(snap)

    proposals: list[MergeProposal] = []
    blocked: list[BlockedMerge] = []

    for qid, persons in by_qid.items():
        if len(persons) < 2:
            continue
        # Generate pairwise proposals within the same-QID group
        for i in range(len(persons)):
            for j in range(i + 1, len(persons)):
                a, b = persons[i], persons[j]

                r6_evidence = {
                    "external_id": qid,
                    "source": "wikidata",
                    "pre_pass": True,
                }

                # T-P0-029 + T-P1-028 (ADR-025): rule-aware temporal guard check
                guard_result = evaluate_pair_guards(a, b, rule="R6")
                if guard_result is not None and guard_result.blocked:
                    # Enforce pair order: person_a_id < person_b_id (DB CHECK)
                    if a.id < b.id:
                        aid, bid, aname, bname = a.id, b.id, a.name, b.name
                    else:
                        aid, bid, aname, bname = b.id, a.id, b.name, a.name

                    blocked.append(
                        BlockedMerge(
                            person_a_id=aid,
                            person_b_id=bid,
                            person_a_name=aname,
                            person_b_name=bname,
                            proposed_rule="R6",
                            guard_type=guard_result.guard_type,
                            guard_payload=guard_result.payload,
                            evidence=r6_evidence,
                        )
                    )
                    logger.info(
                        "R6 guard blocked: %s (%s) ↔ %s (%s) — %s",
                        a.name,
                        a.dynasty,
                        b.name,
                        b.dynasty,
                        guard_result.reason,
                    )
                    continue

                proposals.append(
                    MergeProposal(
                        person_a_id=a.id,
                        person_b_id=b.id,
                        person_a_name=a.name,
                        person_b_name=b.name,
                        match=MatchResult(
                            rule="R6",
                            confidence=1.0,
                            evidence=r6_evidence,
                        ),
                    )
                )

    if proposals or blocked:
        logger.info(
            "R6 merge detection: %d proposals, %d guard-blocked from %d same-QID groups",
            len(proposals),
            len(blocked),
            sum(1 for persons in by_qid.values() if len(persons) >= 2),
        )

    return proposals, blocked


# ---------------------------------------------------------------------------
# Canonical selection
# ---------------------------------------------------------------------------


def select_canonical(persons: list[PersonSnapshot]) -> PersonSnapshot:
    """Select the canonical person from a merge group.

    Priority (ADR-010 + T-P0-013 帝X fix):
      1. has_pinyin_slug (True sorts before False)
      2. NOT a 帝X honorific with a bare-name peer in the group (T-P0-013)
      3. more surface_forms (descending)
      4. earlier created_at (ascending lexicographic ISO string)
      5. smaller id (ascending, stable UUID tiebreaker)
    """

    def sort_key(p: PersonSnapshot) -> tuple[int, int, int, str, str]:
        return (
            0 if p.has_pinyin_slug() else 1,  # 0 = pinyin, 1 = hex fallback
            1 if has_di_prefix_peer(p, persons) else 0,  # 1 = demoted (帝X with peer)
            -len(p.surface_forms),  # more forms = lower sort key = preferred
            p.created_at,  # earlier = smaller string (ISO)
            p.id,  # UUID string tiebreaker
        )

    return min(persons, key=sort_key)


# ---------------------------------------------------------------------------
# Main resolution logic
# ---------------------------------------------------------------------------


async def resolve_identities(pool: asyncpg.Pool) -> ResolveResult:
    """Read all persons from DB, run pairwise rule evaluation, build Union-Find.

    Returns a ResolveResult with merge_groups and hypotheses.
    Does not write anything to DB (use apply_merges for that).
    """
    run_id = str(uuid.uuid4())
    result = ResolveResult(run_id=run_id, total_persons=0)

    async with pool.acquire() as conn:
        persons = await _load_persons(conn)

        # R6 pre-pass: seed-match lookup for each person (T-P0-027)
        r6_distribution = await _r6_prepass(conn, persons)

    result.total_persons = len(persons)
    result.r6_distribution = r6_distribution
    logger.info("Loaded %d persons for identity resolution (run_id=%s)", len(persons), run_id)

    if len(persons) < 2:
        return result

    # Collect merge proposals and hypothesis proposals from pairwise comparison.
    merge_proposals: list[MergeProposal] = []
    hyp_proposals: list[HypothesisProposal] = []
    errors: list[str] = []

    # O(n^2) pairwise evaluation — acceptable for Phase 0 (≤ few hundred persons)
    for i in range(len(persons)):
        for j in range(i + 1, len(persons)):
            a, b = persons[i], persons[j]
            try:
                match = score_pair(a, b)
            except Exception as exc:  # noqa: BLE001
                msg = f"score_pair failed for ({a.name}, {b.name}): {exc}"
                logger.warning(msg)
                errors.append(msg)
                continue

            if match is None:
                continue

            if match.confidence >= MERGE_CONFIDENCE_THRESHOLD:
                # T-P1-028 (ADR-025): rule-aware guard. Guards block proposals
                # for rules registered in GUARD_THRESHOLDS (R1=200yr, R6=500yr).
                # Unregistered rules (R2/R3/R5) get None and proceed unchanged.
                guard_result = evaluate_pair_guards(a, b, rule=match.rule)
                if guard_result is not None and guard_result.blocked:
                    # Pair-order normalize per pending_merge_reviews CHECK
                    if a.id < b.id:
                        aid, bid, aname, bname = a.id, b.id, a.name, b.name
                    else:
                        aid, bid, aname, bname = b.id, a.id, b.name, a.name

                    result.blocked_merges.append(
                        BlockedMerge(
                            person_a_id=aid,
                            person_b_id=bid,
                            person_a_name=aname,
                            person_b_name=bname,
                            proposed_rule=match.rule,
                            guard_type=guard_result.guard_type,
                            guard_payload=guard_result.payload,
                            evidence=match.evidence,
                        )
                    )
                    logger.info(
                        "%s guard blocked: %s (%s) ↔ %s (%s) — %s",
                        match.rule,
                        a.name,
                        a.dynasty,
                        b.name,
                        b.dynasty,
                        guard_result.reason,
                    )
                    continue

                merge_proposals.append(
                    MergeProposal(
                        person_a_id=a.id,
                        person_b_id=b.id,
                        person_a_name=a.name,
                        person_b_name=b.name,
                        match=match,
                    )
                )
            else:
                hyp_proposals.append(
                    HypothesisProposal(
                        person_a_id=a.id,
                        person_b_id=b.id,
                        person_a_name=a.name,
                        person_b_name=b.name,
                        match=match,
                    )
                )

    # R6 merge detection: two persons mapping to same QID (T-P0-027)
    # T-P0-029: also returns guard-blocked pairs for pending_merge_reviews
    r6_proposals, r6_blocked = _detect_r6_merges(persons)
    merge_proposals.extend(r6_proposals)
    result.blocked_merges.extend(r6_blocked)

    result.errors.extend(errors)
    result.hypotheses = hyp_proposals

    logger.info(
        "Pairwise evaluation complete: %d merge proposals (%d R1-R5 + %d R6), "
        "%d guard-blocked, %d hypothesis proposals",
        len(merge_proposals),
        len(merge_proposals) - len(r6_proposals),
        len(r6_proposals),
        len(r6_blocked),
        len(hyp_proposals),
    )

    if not merge_proposals:
        return result

    # Build Union-Find for transitive closure
    person_by_id = {p.id: p for p in persons}
    uf = UnionFind([p.id for p in persons])

    # Proposals indexed by (a_id, b_id) for group annotation
    proposals_by_pair: dict[tuple[str, str], MergeProposal] = {}
    for prop in merge_proposals:
        uf.union(prop.person_a_id, prop.person_b_id)
        key = (min(prop.person_a_id, prop.person_b_id), max(prop.person_a_id, prop.person_b_id))
        proposals_by_pair[key] = prop

    # Convert connected components into MergeGroups
    components = uf.groups()  # root_id → [member_ids]
    for root_id, member_ids in components.items():
        group_persons = [person_by_id[mid] for mid in member_ids]
        canonical = select_canonical(group_persons)
        non_canonical = [p for p in group_persons if p.id != canonical.id]

        # Collect all proposals that contributed to this component
        group_proposals: list[MergeProposal] = []
        for prop in merge_proposals:
            if uf.find(prop.person_a_id) == root_id or uf.find(prop.person_b_id) == root_id:
                # Normalize: check both are in this group
                if prop.person_a_id in {p.id for p in group_persons} and prop.person_b_id in {
                    p.id for p in group_persons
                }:
                    group_proposals.append(prop)

        # Build human-readable reason summary
        reason = _build_reason(canonical, non_canonical, group_proposals)

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
        "Union-Find complete: %d merge groups, %d persons to soft-delete",
        len(result.merge_groups),
        result.total_merged_persons,
    )

    return result


def _build_reason(
    canonical: PersonSnapshot,
    merged: list[PersonSnapshot],
    proposals: list[MergeProposal],
) -> str:
    """Build a human-readable reason string for a merge group."""
    parts: list[str] = []
    for prop in proposals:
        rule = prop.match.rule
        ev = prop.match.evidence
        if rule == "R1":
            overlap = ", ".join(ev.get("overlap", []))
            parts.append(f"R1 surface overlap: {overlap}")
        elif rule == "R2":
            parts.append(f"R2 帝X prefix: {ev.get('direction', '')}")
        elif rule == "R3":
            a_orig = ev.get("a_original") or ev.get("a_surface", "")
            b_orig = ev.get("b_original") or ev.get("b_surface", "")
            norm = ev.get("normalized", "")
            parts.append(f"R3 通假字 {a_orig}→{b_orig} (→{norm})")
        elif rule == "R5":
            parts.append(
                f"R5 庙号/谥号 {ev.get('dict_canonical', '')}/"
                f"{ev.get('dict_alias', '')} ({ev.get('source', '')})"
            )
        elif rule == "R4":
            parts.append("R4 identity_notes reference")
        elif rule == "R6":
            qid = ev.get("external_id", "")
            parts.append(f"R6 seed-match same QID: {qid}")

    reason_str = "; ".join(parts) if parts else "unknown"
    canon_reason = "has pinyin slug" if canonical.has_pinyin_slug() else "most surface forms"
    return f"canonical={canonical.name} ({canon_reason}); rules: {reason_str}"


# ---------------------------------------------------------------------------
# Apply merges
# ---------------------------------------------------------------------------


def _filter_groups_by_skip_rules(
    groups: list[MergeGroup],
    skip_rules: set[str],
) -> list[MergeGroup]:
    """Filter out merge groups whose proposals are ALL from skipped rules.

    A group is kept if at least one contributing proposal uses a non-skipped rule.
    A group is dropped only if ALL its proposals use skipped rules.
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
                "Skipping merge group %s (%s): all proposals from skipped rules %s",
                group.canonical_name,
                [p.match.rule for p in group.proposals],
                skip_rules,
            )

    return filtered


async def apply_merges(
    pool: asyncpg.Pool,
    result: ResolveResult,
    *,
    dry_run: bool = True,
    merged_by: str = "pipeline:resolve",
    skip_rules: set[str] | None = None,
) -> dict[str, Any]:
    """Apply (or dry-run) soft merges from a ResolveResult.

    Soft merge = set deleted_at + merged_into_id on non-canonical persons
                 + insert a person_merge_log row per merge.

    Returns a summary dict with counts.

    Args:
        pool:       asyncpg connection pool
        result:     ResolveResult from resolve_identities()
        dry_run:    if True, produce report without writing to DB (default: True)
        merged_by:  attribution string written to person_merge_log
        skip_rules: set of rule names (e.g. {"R6"}) to exclude from apply.
                    Groups whose ALL proposals are from skipped rules are dropped.
    """
    active_groups = _filter_groups_by_skip_rules(result.merge_groups, skip_rules or set())

    summary: dict[str, Any] = {
        "run_id": result.run_id,
        "dry_run": dry_run,
        "groups": len(active_groups),
        "groups_skipped": len(result.merge_groups) - len(active_groups),
        "skip_rules": sorted(skip_rules) if skip_rules else [],
        "persons_soft_deleted": 0,
        "log_rows_inserted": 0,
        "hypotheses_queued": len(result.hypotheses),
        "guard_blocked": len(result.blocked_merges),
        "guard_reviews_written": 0,
        "errors": [],
    }

    if dry_run:
        # Count without writing
        for group in active_groups:
            summary["persons_soft_deleted"] += len(group.merged_ids)
            summary["log_rows_inserted"] += len(group.merged_ids)
        logger.info(
            "[DRY RUN] Would soft-delete %d persons across %d groups "
            "(%d groups skipped via --skip-rule, %d guard-blocked)",
            summary["persons_soft_deleted"],
            summary["groups"],
            summary["groups_skipped"],
            summary["guard_blocked"],
        )
        return summary

    now = datetime.now(UTC)

    async with pool.acquire() as conn, conn.transaction():
        for group in active_groups:
            for merged_id in group.merged_ids:
                # Determine the rule + confidence from best proposal for this pair
                relevant = [
                    p for p in group.proposals if merged_id in (p.person_a_id, p.person_b_id)
                ]
                best = max(relevant, key=lambda p: p.match.confidence) if relevant else None
                merge_rule = best.match.rule if best else "transitive"
                confidence = best.match.confidence if best else 0.0
                evidence = best.match.evidence if best else {}

                try:
                    # Soft-delete the non-canonical person
                    await conn.execute(
                        """
                            UPDATE persons
                            SET deleted_at = $2, merged_into_id = $3
                            WHERE id = $1 AND deleted_at IS NULL
                            """,
                        merged_id,
                        now,
                        group.canonical_id,
                    )

                    # T-P1-002 + T-P0-016: Demote merged person's primary names to alias,
                    # and sync is_primary=false to prevent nameType=alias + isPrimary=true
                    # UX contradiction (GraphQL read-side would otherwise expose
                    # semantically inconsistent state).
                    demoted = await conn.execute(
                        """
                            UPDATE person_names
                            SET name_type = 'alias', is_primary = false
                            WHERE person_id = $1 AND name_type = 'primary'
                            """,
                        merged_id,
                    )
                    demoted_count = int(demoted.split()[-1]) if demoted else 0
                    if demoted_count > 0:
                        logger.info(
                            "Demoted %d primary name(s) to alias for merged person %s",
                            demoted_count,
                            merged_id,
                        )

                    # Insert merge log row
                    import json as _json

                    log_id = str(uuid.uuid4())
                    await conn.execute(
                        """
                            INSERT INTO person_merge_log
                                (id, run_id, canonical_id, merged_id,
                                 merge_rule, confidence, evidence,
                                 merged_by, merged_at)
                            VALUES ($1, $2, $3, $4, $5, $6, $7::jsonb, $8, $9)
                            """,
                        log_id,
                        result.run_id,
                        group.canonical_id,
                        merged_id,
                        merge_rule,
                        confidence,
                        _json.dumps(evidence, ensure_ascii=False),
                        merged_by,
                        now,
                    )

                    summary["persons_soft_deleted"] += 1
                    summary["log_rows_inserted"] += 1

                except Exception as exc:  # noqa: BLE001
                    msg = f"Failed to merge person {merged_id} into {group.canonical_id}: {exc}"
                    logger.error(msg)
                    summary["errors"].append(msg)

        # Insert identity_hypotheses for R4 proposals
        for hyp in result.hypotheses:
            try:
                import json as _json

                hyp_id = str(uuid.uuid4())
                await conn.execute(
                    """
                        INSERT INTO identity_hypotheses
                            (id, canonical_person_id, hypothesis_person_id,
                             relation_type, scholarly_support, evidence_ids,
                             accepted_by_default, notes)
                        VALUES ($1, $2, $3, 'possibly_same', $4, $5::jsonb, false, $6)
                        ON CONFLICT DO NOTHING
                        """,
                    hyp_id,
                    hyp.person_a_id,
                    hyp.person_b_id,
                    f"Rule {hyp.match.rule} match (confidence {hyp.match.confidence:.2f})",
                    _json.dumps(hyp.match.evidence, ensure_ascii=False),
                    str(hyp.match.evidence),
                )
            except Exception as exc:  # noqa: BLE001
                msg = (
                    f"Failed to insert hypothesis ({hyp.person_a_name}, {hyp.person_b_name}): {exc}"
                )
                logger.warning(msg)
                summary["errors"].append(msg)

        # T-P0-029: Write guard-blocked merges to pending_merge_reviews
        for item in result.blocked_merges:
            try:
                import json as _json

                await conn.execute(
                    """
                    INSERT INTO pending_merge_reviews
                        (person_a_id, person_b_id, proposed_rule, guard_type,
                         guard_payload, evidence)
                    VALUES ($1::uuid, $2::uuid, $3, $4, $5::jsonb, $6::jsonb)
                    ON CONFLICT (person_a_id, person_b_id, proposed_rule, guard_type)
                        WHERE status = 'pending'
                    DO NOTHING
                    """,
                    item.person_a_id,
                    item.person_b_id,
                    item.proposed_rule,
                    item.guard_type,
                    _json.dumps(item.guard_payload, ensure_ascii=False),
                    _json.dumps(item.evidence, ensure_ascii=False),
                )
                summary["guard_reviews_written"] += 1
            except Exception as exc:  # noqa: BLE001
                msg = (
                    f"Failed to write pending_merge_review for "
                    f"{item.person_a_name} ↔ {item.person_b_name}: {exc}"
                )
                logger.error(msg)
                summary["errors"].append(msg)

    logger.info(
        "Applied merges: %d persons soft-deleted, %d log rows, %d guard reviews written, %d errors",
        summary["persons_soft_deleted"],
        summary["log_rows_inserted"],
        summary["guard_reviews_written"],
        len(summary["errors"]),
    )
    return summary


# ---------------------------------------------------------------------------
# Dry-run report generator
# ---------------------------------------------------------------------------


def generate_dry_run_report(result: ResolveResult) -> str:
    """Generate a human-readable dry-run report from a ResolveResult.

    Format:
        运行 ID: <run_id>
        总人数: N
        建议自动合并组: K (score >= 0.9)
          组 1: [名A(slug-a), 名B(slug-b)] → canonical=名A (理由: ...)
            规则: R3 通假字 倕→垂 (来源: ...)
            confidence: 0.90
        建议生成 hypothesis: M (0.5 <= score < 0.9)
          ...
    """
    lines: list[str] = []
    lines.append(f"运行 ID: {result.run_id}")
    lines.append(f"总人数: {result.total_persons}")
    lines.append(
        f"建议自动合并组: {len(result.merge_groups)} (score >= {MERGE_CONFIDENCE_THRESHOLD})"
    )

    for idx, group in enumerate(result.merge_groups, start=1):
        # Format group member list: [名(slug), 名(slug), ...]
        all_members = [(group.canonical_name, group.canonical_slug)] + list(
            zip(group.merged_names, group.merged_slugs, strict=True)
        )
        members_str = ", ".join(f"{name}({slug})" for name, slug in all_members)
        canonical_reason = (
            "has pinyin slug" if _slug_is_pinyin(group.canonical_slug) else "most surface forms"
        )
        lines.append(
            f"  组 {idx}: [{members_str}] → canonical={group.canonical_name} (理由: {canonical_reason})"
        )

        # List each contributing proposal
        for prop in group.proposals:
            rule = prop.match.rule
            ev = prop.match.evidence
            rule_label = _format_rule_evidence(rule, ev)
            lines.append(f"    规则: {rule_label}")
            lines.append(f"    confidence: {prop.match.confidence:.2f}")

    lines.append("")
    lines.append(
        f"建议生成 hypothesis: {len(result.hypotheses)} (0.5 <= score < {MERGE_CONFIDENCE_THRESHOLD})"
    )

    for idx, hyp in enumerate(result.hypotheses, start=1):
        lines.append(
            f"  候选 {idx}: {hyp.person_a_name}({hyp.person_a_id[:8]}…) "
            f"? {hyp.person_b_name}({hyp.person_b_id[:8]}…)"
        )
        rule_label = _format_rule_evidence(hyp.match.rule, hyp.match.evidence)
        lines.append(f"    规则: {rule_label}")
        lines.append(f"    confidence: {hyp.match.confidence:.2f}")

    if result.errors:
        lines.append("")
        lines.append(f"错误: {len(result.errors)}")
        for err in result.errors:
            lines.append(f"  - {err}")

    # T-P0-029 / T-P2-006: guard-blocked merges with guard_type subgroup breakdown
    if result.blocked_merges:
        lines.append("")
        lines.append(f"Guard 拦截: {len(result.blocked_merges)} 对")
        guard_type_counts: dict[str, int] = {}
        for item in result.blocked_merges:
            guard_type_counts[item.guard_type] = guard_type_counts.get(item.guard_type, 0) + 1
        for gt in ("cross_dynasty", "state_prefix"):
            if gt in guard_type_counts:
                lines.append(f"  {gt}: {guard_type_counts[gt]} 对")
        known_types = {"cross_dynasty", "state_prefix"}
        unknown_count = sum(v for k, v in guard_type_counts.items() if k not in known_types)
        if unknown_count > 0:
            logger.warning(
                "Guard 拦截出现未知 guard_type: %s — 请检查 GUARD_CHAINS 注册",
                {k: v for k, v in guard_type_counts.items() if k not in known_types},
            )
            lines.append(f"  unknown: {unknown_count} 对  ⚠️")
        for idx, item in enumerate(result.blocked_merges, start=1):
            payload = item.guard_payload
            dynasty_a = payload.get("dynasty_a", "?")
            dynasty_b = payload.get("dynasty_b", "?")
            gap = payload.get("gap_years", "?")
            lines.append(
                f"  拦截 {idx}: {item.person_a_name}({dynasty_a}) ↔ "
                f"{item.person_b_name}({dynasty_b}) — "
                f"{item.guard_type} gap {gap}yr"
            )

    # R6 pre-pass distribution (T-P0-027)
    if result.r6_distribution:
        lines.append("")
        lines.append("R6 seed-match pre-pass 分布:")
        for status_key in ("matched", "not_found", "below_cutoff", "ambiguous"):
            count = result.r6_distribution.get(status_key, 0)
            lines.append(f"  {status_key}: {count}")
        lines.append(f"  总计: {sum(result.r6_distribution.values())}")

    # Rule distribution across all merge proposals
    rule_counts: dict[str, int] = {}
    for group in result.merge_groups:
        for prop in group.proposals:
            rule_counts[prop.match.rule] = rule_counts.get(prop.match.rule, 0) + 1
    if rule_counts:
        lines.append("")
        lines.append("规则命中分布 (merge proposals):")
        for rule_name in sorted(rule_counts):
            lines.append(f"  {rule_name}: {rule_counts[rule_name]}")

    lines.append("")
    lines.append(
        f"合并后预计人数: {result.persons_after_merge} (减少 {result.total_merged_persons} 人)"
    )

    return "\n".join(lines)


def _slug_is_pinyin(slug: str) -> bool:
    """Return True if slug looks like a pinyin slug (not u{hex} fallback)."""
    import re

    return not bool(re.match(r"^u[0-9a-f]{4}", slug))


def _format_rule_evidence(rule: str, ev: dict[str, Any]) -> str:
    """Format a rule + evidence into a human-readable string."""
    if rule == "R1":
        overlap = ", ".join(ev.get("overlap", []))
        return f"R1 表面形式重叠: {overlap}"
    elif rule == "R2":
        direction = ev.get("direction", "")
        return f"R2 帝X前缀: {direction}"
    elif rule == "R3":
        a = ev.get("a_original") or ev.get("a_surface", "?")
        b = ev.get("b_original") or ev.get("b_surface", "?")
        norm = ev.get("normalized", "?")
        mappings = ev.get("mapping_used", {})
        src = ", ".join(f"{k}→{v}" for k, v in mappings.items()) if mappings else ""
        src_str = f" (来源: {src})" if src else ""
        return f"R3 通假字 {a}→{b} (→{norm}){src_str}"
    elif rule == "R4":
        return (
            f"R4 identity_notes 交叉引用 "
            f"(a_mentions_b={ev.get('a_mentions_b')}, b_mentions_a={ev.get('b_mentions_a')})"
        )
    elif rule == "R5":
        canon = ev.get("dict_canonical", "?")
        alias = ev.get("dict_alias", "?")
        source = ev.get("source", "")
        src_str = f" (来源: {source})" if source else ""
        return f"R5 庙号/谥号 {canon}/{alias}{src_str}"
    elif rule == "R6":
        qid = ev.get("external_id", "?")
        source = ev.get("source", "wikidata")
        return f"R6 外部锚点 {source}:{qid}"
    else:
        return f"{rule} unknown evidence"
