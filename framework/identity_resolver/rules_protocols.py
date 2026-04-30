"""Plugin protocols for case-domain rule implementations.

Identity resolution rules R1-R5 share a common structure: each rule fires
based on (entity_a, entity_b) attributes plus zero-or-more domain dictionaries
or pattern lists. The framework keeps the *algorithm* of each rule, but the
*data feeding the algorithm* is the case domain's responsibility.

This module defines 4 plugin protocols that case domains implement:

    DictionaryLoader       — feeds R3 (synonym/variant) and R5 (alias dict)
    StopWordPlugin         — feeds R1 (ignore-list of generic terms)
    IdentityNotesPatterns  — feeds R4 (regex patterns for cross-references)
    CanonicalHint          — feeds canonical selection (domain-specific demotion)

All protocols use PEP 544 `typing.Protocol` (structural / duck-typed) — case
domains do not need to inherit from them, just implement the methods.

Plugin requirement matrix:

    Plugin                  | Required? | Behavior if not provided
    ------------------------|-----------|---------------------------
    DictionaryLoader        | optional  | R3 + R5 silently skip
    StopWordPlugin          | optional  | R1 uses empty stop-word set
    IdentityNotesPatterns   | optional  | R4 silently skips
    CanonicalHint           | optional  | canonical uses default 5-rule order

License: Apache 2.0
Source: extracted from `services/pipeline/src/huadian_pipeline/resolve_rules.py`
        (HuaDian Sprint N first-cut framework abstraction).
"""

from __future__ import annotations

import re
from typing import Any, Protocol

from .entity import EntitySnapshot


class DictionaryLoader(Protocol):
    """Plugin for R3 (variant char) and R5 (bidirectional alias) dictionaries.

    Case domains implement one or both methods depending on which rules
    they need.

    Example reference impl:
        - HuaDian classics: tongjia.yaml (R3) + miaohao.yaml (R5)
        - Medical domain:   drug-variant.yaml (R3) + drug-aliases.yaml (R5)
        - Legal domain:     citation-variants.yaml (R3) + case-aliases.yaml (R5)
    """

    def load_synonym_dict(self) -> dict[str, str]:
        """Variant → canonical mapping (used by R3).

        Returns:
            dict where each `variant` key maps to its `canonical` form.
            Empty dict disables R3.
        """
        ...

    def load_alias_dict(self) -> dict[tuple[str, str], dict[str, Any]]:
        """Bidirectional alias pair → entry mapping (used by R5).

        Both orderings (a, b) and (b, a) MUST be indexed so lookup is
        order-independent. Each entry value is a dict containing at least
        `canonical` and `alias` keys; case domains can add extra fields
        (e.g. `dynasty`, `jurisdiction`, `source`).

        Returns:
            dict[tuple[name_a, name_b], entry_dict]. Empty dict disables R5.
        """
        ...


class StopWordPlugin(Protocol):
    """Plugin for R1 stop words — generic terms that should NOT trigger merges.

    Stop words are surface forms that appear in many unrelated entities and
    therefore carry no identity signal. HuaDian classics example: "王" / "帝"
    are titles shared by many rulers; merging on "王" alone would be absurd.

    The plugin returns a frozenset for fast lookup. Empty set disables stop
    word filtering (R1 will use raw surface overlap).

    Example reference impl:
        - HuaDian classics: {"王", "帝", "后", "朕", "予一人", "武王"}
        - Medical domain:   {"patient", "ICU"} (terms in many notes)
        - Legal domain:     {"plaintiff", "defendant", "court"}
    """

    def get_stop_words(self) -> frozenset[str]:
        """Return the set of stop words to exclude from R1 surface overlap."""
        ...


class IdentityNotesPatterns(Protocol):
    """Plugin for R4 identity_notes regex patterns.

    R4 parses each entity's `identity_notes` (free-text annotations like
    "可能是淮阴侯韩信" or "see also: Brown v. Board of Education") for
    references to other entities. Case domains supply the regex patterns
    that match those references.

    The framework provides the matching engine (regex + cross-check); the
    plugin provides the patterns. Empty list disables R4.

    Example reference impl (HuaDian classics):
        [
            re.compile(r"与(.{1,8})同人"),       # "X is the same person as ..."
            re.compile(r"即(.{1,8})"),           # "X is none other than ..."
            re.compile(r"(.{1,8})又名(.{1,8})"), # "X is also named ..."
        ]
    """

    def get_patterns(self) -> list[re.Pattern[str]]:
        """Return regex patterns to extract referenced names from notes."""
        ...


class CanonicalHint(Protocol):
    """Plugin for `select_canonical()` — domain-specific demotion logic.

    `select_canonical()` picks one entity from a merge group as the canonical
    representation. The default order (5 rules):

        1. has_pinyin_slug (or domain equivalent — see EntitySnapshot)
        2. NOT demoted by `should_demote()`         ← this plugin
        3. more surface_forms (descending)
        4. earlier created_at (ascending)
        5. smaller id (ascending tiebreaker)

    `should_demote()` lets case domains add domain-specific demotion logic.
    HuaDian's example: a 帝X honorific (e.g. "帝尧") should be demoted in
    favor of the bare-name peer ("尧") if both exist in the same group.

    If no plugin is provided, the framework treats `should_demote` as
    "always False" — pure 4-rule canonical selection.
    """

    def should_demote(self, entity: EntitySnapshot, group: list[EntitySnapshot]) -> bool:
        """Return True if `entity` should be deprioritized as canonical.

        Args:
            entity: the entity being evaluated for demotion
            group:  the full merge group entity is part of

        Returns:
            True → entity is demoted (canonical selection prefers another)
            False → entity is eligible for canonical (no demotion)
        """
        ...
