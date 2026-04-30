"""R6 — external dictionary anchor lookup (optional rule).

R6 is the highest-priority rule when applicable: if two entities both map
to the same external authority record (e.g. a Wikidata QID, a UMLS CUI,
an ISBN), they almost certainly refer to the same real-world thing.

This module provides:
    - R6Status enum (matched / below_cutoff / ambiguous / not_found)
    - R6Result + R6PrePassResult dataclasses
    - SeedMatchAdapter Protocol — case domain provides the actual DB queries
    - r6_seed_match() — domain-agnostic dispatcher

The case domain implements `SeedMatchAdapter` for their own DB schema.
Reference impl: framework/identity-resolver/examples/huadian_classics/
                seed_match_adapter.py

License: Apache 2.0
Source: abstracted from `services/pipeline/src/huadian_pipeline/r6_seed_match.py`
        (HuaDian Sprint N first-cut framework abstraction).
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol

# StrEnum was added in Python 3.11; fallback for older versions so the
# framework is usable on a wider Python range. HuaDian classics requires
# Python 3.12+ (per the original huadian_pipeline), but cross-domain case
# adopters may use 3.10.
try:
    from enum import StrEnum
except ImportError:  # pragma: no cover — Python < 3.11
    from enum import Enum

    # noqa rationale: UP042 suggests inheriting from `enum.StrEnum`, but
    # this entire `except ImportError` block exists precisely because
    # `enum.StrEnum` is unavailable on Python < 3.11.
    class StrEnum(str, Enum):  # type: ignore[no-redef]  # noqa: UP042
        """Backport of Python 3.11 StrEnum for older Python."""


class R6Status(StrEnum):
    """R6 lookup result status."""

    MATCHED = "matched"  # active mapping with confidence >= cutoff
    BELOW_CUTOFF = "below_cutoff"  # active mapping with confidence < cutoff
    AMBIGUOUS = "ambiguous"  # multiple active mappings — data quality issue
    NOT_FOUND = "not_found"  # no active mapping


@dataclass(frozen=True, slots=True)
class R6Result:
    """Result of an on-demand R6 seed-match lookup."""

    status: R6Status
    entity_id: str | None = None
    confidence: float = 0.0
    entry_id: str | None = None  # opaque ID of the dictionary entry
    external_id: str | None = None  # the authority ID (e.g. Wikidata QID)
    source_name: str | None = None  # which authority source (e.g. "wikidata")
    detail: str = ""


@dataclass(frozen=True, slots=True)
class R6PrePassResult:
    """Result of the pre-pass R6 lookup, attached to each EntitySnapshot.

    Distinct from R6Result (single on-demand lookup): the pre-pass queries
    seed_mappings by target_entity_id (FK direct), never by name. This is
    used by `_detect_r6_merges()` in resolve.py to propose merges between
    two entities sharing the same QID.
    """

    status: R6Status
    qid: str | None = None  # external_id (kept as `qid` for HuaDian compat)
    entry_id: str | None = None
    confidence: float | None = None


class SeedMatchAdapter(Protocol):
    """Plugin for R6 seed-match DB queries — case domain provides this.

    The framework calls `lookup_by_id()` or `lookup_by_name()` and gets back
    an `R6Result`. The case domain decides:
      - which external authority sources to support
      - what DB schema (PostgreSQL / MongoDB / API call / etc) to use
      - what counts as "active" (mapping_status, deleted_at, etc)

    Required methods:
        lookup_by_id      — find entity mapped to a given external_id
        lookup_by_name    — fallback: find entity by name lookup

    Example reference impl: examples/huadian_classics/seed_match_adapter.py
    (uses the seed_mappings → dictionary_entries → dictionary_sources tables).
    """

    async def lookup_by_id(
        self,
        external_id: str,
        source_name: str,
        confidence_cutoff: float,
    ) -> R6Result:
        """Find the entity mapped to (source_name, external_id).

        Args:
            external_id:        the authority ID (e.g. "Q9192" for Wikidata)
            source_name:        the authority name (e.g. "wikidata")
            confidence_cutoff:  minimum confidence; below → BELOW_CUTOFF

        Returns:
            R6Result with status in {matched, below_cutoff, not_found}.
        """
        ...

    async def lookup_by_name(
        self,
        candidate_name: str,
        confidence_cutoff: float,
    ) -> R6Result:
        """Fallback: find entity by primary_name lookup (no external ID).

        Returns AMBIGUOUS if multiple active mappings match the name.
        """
        ...


async def r6_seed_match(
    adapter: SeedMatchAdapter,
    *,
    candidate_name: str,
    candidate_qid: str | None = None,
    dictionary_source: str = "wikidata",
    confidence_cutoff: float = 0.80,
) -> R6Result:
    """Domain-agnostic R6 lookup dispatcher.

    Args:
        adapter:            case-domain `SeedMatchAdapter` implementation
        candidate_name:     entity name (used as fallback path)
        candidate_qid:      external authority ID (preferred path; if provided)
        dictionary_source:  authority name. Default "wikidata"; case domains
                            can pass "umls" / "doi" / their own.
        confidence_cutoff:  minimum confidence to count as MATCHED

    Returns:
        R6Result. Primary path (QID) preferred; falls through to name lookup
        if qid is None.
    """
    if candidate_qid:
        return await adapter.lookup_by_id(candidate_qid, dictionary_source, confidence_cutoff)
    return await adapter.lookup_by_name(candidate_name, confidence_cutoff)
