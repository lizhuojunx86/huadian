"""Three-round matching engine for Wikidata → HuaDian persons.

Rounds:
  R1: canonical_name → rdfs:label @zh exact match (confidence 1.00)
  R2: person_names aliases → skos:altLabel match (confidence 0.85)
  R3: ALL person_names → rdfs:label + skos:altLabel (confidence 0.70)

Multi-hit (R1 ≥ 2 candidates): not auto-mapped, queued for manual review.

ADR: ADR-021 §2.1 / T-P0-025 task card §Stage 1
"""

from __future__ import annotations

import logging
from dataclasses import asdict, dataclass, field

from .wikidata_adapter import WikidataAdapter

logger = logging.getLogger(__name__)

BATCH_SIZE = 15

# Confidence per matching round
CONF_R1_SINGLE = 1.00
CONF_R2_ALIAS = 0.85
CONF_R3_SCAN = 0.70


@dataclass
class PersonInput:
    """A HuaDian person to match against Wikidata."""

    person_id: str
    slug: str
    canonical_name: str
    dynasty: str | None
    reality_status: str
    # All person_names for R2/R3 matching
    all_names: list[str] = field(default_factory=list)
    # Subset for R2 (primary + alias type only)
    alias_names: list[str] = field(default_factory=list)


@dataclass
class MatchResult:
    """Result of matching a single person."""

    person_id: str
    slug: str
    canonical_name: str
    dynasty: str | None
    reality_status: str
    match_round: str = "none"  # r1 / r2 / r3 / multi_hit / none
    confidence: float = 0.0
    mapping_method: str = ""  # r1_exact / r2_alias / r3_name_scan
    hits: list[dict] = field(default_factory=list)  # WikidataHit as dicts
    matched_name: str = ""  # which name triggered the match
    error: str = ""

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class MatchSummary:
    """Aggregate matching statistics."""

    total: int = 0
    r1_single: int = 0
    r1_multi: int = 0
    r2_alias: int = 0
    r2_multi: int = 0
    r3_scan: int = 0
    r3_multi: int = 0
    no_match: int = 0
    http_requests: int = 0
    errors: int = 0


async def run_matching(
    persons: list[PersonInput],
    adapter: WikidataAdapter,
    *,
    skip_r3: bool = False,
) -> tuple[list[MatchResult], MatchSummary]:
    """Run three-round Wikidata matching for a list of persons.

    Args:
        persons: List of HuaDian persons to match.
        adapter: Configured WikidataAdapter (must be used as context manager).
        skip_r3: If True, skip Round 3 (useful for dry-run speed).

    Returns:
        Tuple of (results, summary).
    """
    results: dict[str, MatchResult] = {}
    for p in persons:
        results[p.person_id] = MatchResult(
            person_id=p.person_id,
            slug=p.slug,
            canonical_name=p.canonical_name,
            dynasty=p.dynasty,
            reality_status=p.reality_status,
        )

    summary = MatchSummary(total=len(persons))

    # ── Round 1: batch label exact match ──
    logger.info("=== Round 1: exact zh label match (%d persons) ===", len(persons))
    batches = [persons[i : i + BATCH_SIZE] for i in range(0, len(persons), BATCH_SIZE)]

    for bi, batch in enumerate(batches):
        names = [p.canonical_name for p in batch]
        sparql_result = await adapter.batch_label_match(names)
        summary.http_requests += sparql_result.http_requests

        for p in batch:
            hits = sparql_result.hits_by_name.get(p.canonical_name, [])
            if len(hits) == 1:
                r = results[p.person_id]
                r.match_round = "r1"
                r.confidence = CONF_R1_SINGLE
                r.mapping_method = "r1_exact"
                r.hits = [asdict(h) for h in hits]
                r.matched_name = p.canonical_name
                summary.r1_single += 1
            elif len(hits) > 1:
                r = results[p.person_id]
                r.match_round = "multi_hit"
                r.confidence = 0.0
                r.mapping_method = "r1_exact_multi"
                r.hits = [asdict(h) for h in hits]
                r.matched_name = p.canonical_name
                summary.r1_multi += 1

        logger.info("  batch %d/%d done (%d names)", bi + 1, len(batches), len(batch))
        await adapter.throttle()

    r1_matched = {pid for pid, r in results.items() if r.match_round in ("r1", "multi_hit")}
    r1_misses = [p for p in persons if p.person_id not in r1_matched]
    logger.info(
        "Round 1: %d single + %d multi = %d matched, %d misses",
        summary.r1_single,
        summary.r1_multi,
        summary.r1_single + summary.r1_multi,
        len(r1_misses),
    )

    # ── Round 2: alias match for R1 misses ──
    logger.info("=== Round 2: alias match (%d persons) ===", len(r1_misses))
    r2_misses: list[PersonInput] = []

    for pi, p in enumerate(r1_misses):
        found = False
        alias_candidates = list(dict.fromkeys(p.alias_names))

        for alias in alias_candidates:
            hits = await adapter.single_altlabel_match(alias)
            summary.http_requests += 1

            if len(hits) == 1:
                r = results[p.person_id]
                r.match_round = "r2"
                r.confidence = CONF_R2_ALIAS
                r.mapping_method = "r2_alias"
                r.hits = [asdict(h) for h in hits]
                r.matched_name = alias
                summary.r2_alias += 1
                found = True
                break
            elif len(hits) > 1:
                # Multi-hit on alias: don't auto-map, record for review
                r = results[p.person_id]
                r.match_round = "multi_hit"
                r.confidence = 0.0
                r.mapping_method = "r2_alias_multi"
                r.hits = [asdict(h) for h in hits]
                r.matched_name = alias
                summary.r2_multi += 1
                found = True
                break

            await adapter.throttle()

        if not found:
            r2_misses.append(p)

        if (pi + 1) % 20 == 0:
            logger.info("  round2 progress: %d/%d", pi + 1, len(r1_misses))

    logger.info("Round 2: %d alias hits, %d still unmatched", summary.r2_alias, len(r2_misses))

    # ── Round 3: full person_names scan for R2 misses ──
    if not skip_r3 and r2_misses:
        logger.info("=== Round 3: full person_names scan (%d persons) ===", len(r2_misses))

        for pi, p in enumerate(r2_misses):
            found = False
            # Try all names not already tried in R1/R2
            tried = {p.canonical_name} | set(p.alias_names)
            remaining = [n for n in p.all_names if n not in tried]

            for name in remaining:
                hits = await adapter.single_altlabel_match(name)
                summary.http_requests += 1

                if len(hits) == 1:
                    r = results[p.person_id]
                    r.match_round = "r3"
                    r.confidence = CONF_R3_SCAN
                    r.mapping_method = "r3_name_scan"
                    r.hits = [asdict(h) for h in hits]
                    r.matched_name = name
                    summary.r3_scan += 1
                    found = True
                    break
                elif len(hits) > 1:
                    r = results[p.person_id]
                    r.match_round = "multi_hit"
                    r.confidence = 0.0
                    r.mapping_method = "r3_name_scan_multi"
                    r.hits = [asdict(h) for h in hits]
                    r.matched_name = name
                    summary.r3_multi += 1
                    found = True
                    break

                await adapter.throttle()

            if not found:
                summary.no_match += 1

            if (pi + 1) % 20 == 0:
                logger.info("  round3 progress: %d/%d", pi + 1, len(r2_misses))

        logger.info("Round 3: %d scan hits, %d final no-match", summary.r3_scan, summary.no_match)
    else:
        summary.no_match = len(r2_misses)
        if skip_r3:
            logger.info("Round 3: SKIPPED (%d persons unmatched)", len(r2_misses))

    summary.errors = adapter.total_errors
    total_matched = summary.r1_single + summary.r2_alias + summary.r3_scan
    total_multi = summary.r1_multi + summary.r2_multi + summary.r3_multi
    logger.info(
        "=== FINAL: %d/%d matched (%.1f%%) | R1=%d R2=%d R3=%d multi=%d(%d+%d+%d) none=%d ===",
        total_matched,
        summary.total,
        100 * total_matched / summary.total if summary.total else 0,
        summary.r1_single,
        summary.r2_alias,
        summary.r3_scan,
        total_multi,
        summary.r1_multi,
        summary.r2_multi,
        summary.r3_multi,
        summary.no_match,
    )

    return list(results.values()), summary
