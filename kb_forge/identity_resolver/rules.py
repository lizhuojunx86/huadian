"""R1-R5 rule implementations — domain-agnostic algorithms with plugin data feeds.

The framework provides the algorithmic structure of each rule; the case
domain provides the data (dictionaries, stop words, regex patterns) via
plugins from `rules_protocols.py`.

Rule semantics (default):
    R1 (confidence 0.95): surface_form cross-match
    R2 (confidence 0.93): prefix-honorific match (HuaDian-specific; lives in
                          examples/huadian_classics/r2_di_prefix_rule.py)
    R3 (confidence 0.90): synonym-dict normalization (e.g. variant chars)
    R4 (confidence 0.65): identity_notes cross-reference (hypothesis only)
    R5 (confidence 0.90): bidirectional alias-dict match

Evaluation order (first-match-wins): R1 → R3 → R5 → R4
(R2 is opt-in via case-domain rule registration; see ScorePairContext.)

License: Apache 2.0
Source: abstracted from `services/pipeline/src/huadian_pipeline/resolve_rules.py`
        (HuaDian Sprint N first-cut framework abstraction).
"""

from __future__ import annotations

import logging
import re
from collections.abc import Callable
from dataclasses import dataclass, field
from typing import Any

from .entity import EntitySnapshot
from .rules_protocols import (
    DictionaryLoader,
    IdentityNotesPatterns,
    StopWordPlugin,
)
from .types import MatchResult

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Threshold (case domains can override via ScorePairContext)
# ---------------------------------------------------------------------------

MERGE_CONFIDENCE_THRESHOLD = 0.90
"""Confidence threshold above which a MatchResult becomes a MergeProposal.

Below this threshold (but above ~0.5), it becomes a HypothesisProposal.
Case domains can override via `ScorePairContext.merge_threshold`.
"""


# ---------------------------------------------------------------------------
# Score pair context — bundles all plugin data for rule evaluation
# ---------------------------------------------------------------------------

# A "rule function" takes (entity_a, entity_b, ctx) and returns a MatchResult
# or None. Case-domain custom rules use the same signature.
RuleFn = Callable[
    [EntitySnapshot, EntitySnapshot, "ScorePairContext"],
    "MatchResult | None",
]


@dataclass(slots=True)
class ScorePairContext:
    """Bundle of all plugin data that R1-R5 need to evaluate a pair.

    Constructed once per resolve run and passed to each rule function.

    Required attributes:
        synonym_dict:      from `DictionaryLoader.load_synonym_dict()`
        alias_dict:        from `DictionaryLoader.load_alias_dict()`
        stop_words:        from `StopWordPlugin.get_stop_words()`
        notes_patterns:    from `IdentityNotesPatterns.get_patterns()`

    Optional attributes:
        cross_dynasty_attr:  domain attribute name used by R1's cross-dynasty
                             single-char guard (default "dynasty"; HuaDian
                             classics convention). Case domains can pass
                             None to disable this guard or supply their own
                             attribute name (e.g. "jurisdiction").
        merge_threshold:     override `MERGE_CONFIDENCE_THRESHOLD`.
        custom_rules:        additional case-domain rules appended to the
                             default rule order (after R4).
    """

    synonym_dict: dict[str, str] = field(default_factory=dict)
    alias_dict: dict[tuple[str, str], dict[str, Any]] = field(default_factory=dict)
    stop_words: frozenset[str] = field(default_factory=frozenset)
    notes_patterns: list[re.Pattern[str]] = field(default_factory=list)
    cross_dynasty_attr: str | None = "dynasty"
    merge_threshold: float = MERGE_CONFIDENCE_THRESHOLD
    custom_rules: list[RuleFn] = field(default_factory=list)


def build_score_pair_context(
    *,
    dictionary_loader: DictionaryLoader | None = None,
    stop_word_plugin: StopWordPlugin | None = None,
    notes_patterns_plugin: IdentityNotesPatterns | None = None,
    cross_dynasty_attr: str | None = "dynasty",
    merge_threshold: float = MERGE_CONFIDENCE_THRESHOLD,
    custom_rules: list[RuleFn] | None = None,
) -> ScorePairContext:
    """Build a `ScorePairContext` from plugins (or empty defaults).

    Plugins are optional — if not provided, the corresponding rule(s) silently
    skip (R3 / R5 with no dictionaries, R1 with no stop words, R4 with no
    patterns). This lets case domains start simple and add rules incrementally.
    """
    ctx = ScorePairContext(
        cross_dynasty_attr=cross_dynasty_attr,
        merge_threshold=merge_threshold,
        custom_rules=custom_rules or [],
    )
    if dictionary_loader is not None:
        ctx.synonym_dict = dictionary_loader.load_synonym_dict()
        ctx.alias_dict = dictionary_loader.load_alias_dict()
    if stop_word_plugin is not None:
        ctx.stop_words = stop_word_plugin.get_stop_words()
    if notes_patterns_plugin is not None:
        ctx.notes_patterns = notes_patterns_plugin.get_patterns()
    return ctx


# ---------------------------------------------------------------------------
# Rule R1 — surface_form cross-match
# ---------------------------------------------------------------------------


def rule_r1(
    a: EntitySnapshot,
    b: EntitySnapshot,
    ctx: ScorePairContext,
) -> MatchResult | None:
    """R1: surface_form cross-match (confidence 0.95).

    Fires if the two entities share a meaningful name in their combined
    name sets, after filtering:
      1. stop words (from `ctx.stop_words`)
      2. cross-domain single-char guard (if `ctx.cross_dynasty_attr` is set
         and both entities have a value AND those values differ, require
         multi-char overlap — single chars too ambiguous across domains)
      3. single-char quality guard (single-char overlap counts only if both
         entities have it in surface_forms, not just primary name)

    The "cross-domain attribute" is configurable: HuaDian uses "dynasty",
    other case domains might use "jurisdiction" / "drug_class" / etc.
    """
    a_names = a.all_names()
    b_names = b.all_names()
    overlap = a_names & b_names
    if not overlap:
        return None

    meaningful = overlap - ctx.stop_words
    if not meaningful:
        return None

    # Cross-domain guard: if both entities have the cross-domain attribute
    # set and the values differ, require multi-char overlap.
    if ctx.cross_dynasty_attr is not None:
        attr_a = a.domain_attrs.get(ctx.cross_dynasty_attr, "")
        attr_b = b.domain_attrs.get(ctx.cross_dynasty_attr, "")
        cross_domain = attr_a and attr_b and attr_a != attr_b
        if cross_domain:
            meaningful = {n for n in meaningful if len(n) >= 2}
            if not meaningful:
                return None

    # Single-char quality guard
    multi_char = {n for n in meaningful if len(n) > 1}
    if not multi_char:
        single_char = meaningful
        meaningful = single_char & a.surface_forms & b.surface_forms
        if not meaningful:
            return None

    return MatchResult(
        rule="R1",
        confidence=0.95,
        evidence={
            "overlap": sorted(meaningful),
            "a_names": sorted(a_names),
            "b_names": sorted(b_names),
        },
    )


# ---------------------------------------------------------------------------
# Rule R3 — synonym-dict normalization
# ---------------------------------------------------------------------------


def rule_r3(
    a: EntitySnapshot,
    b: EntitySnapshot,
    ctx: ScorePairContext,
) -> MatchResult | None:
    """R3: synonym-dict / variant-character normalization (confidence 0.90).

    Normalizes each character (or whole-name) using `ctx.synonym_dict`,
    then compares. If empty dict, R3 silently skips.

    The dict semantics: variant → canonical form. HuaDian classics example
    uses tongjia.yaml ("通假字" / variant Chinese characters). Other case
    domains might use:
      - drug name variants (e.g. "Tylenol" → "acetaminophen")
      - legal citation variants (e.g. "U.S." → "United States")
      - patent classification variants
    """
    if not ctx.synonym_dict:
        return None

    syn = ctx.synonym_dict

    def _normalize_name(name: str) -> str:
        if name in syn:
            return syn[name]
        return "".join(syn.get(ch, ch) for ch in name)

    a_normalized = _normalize_name(a.name)
    b_normalized = _normalize_name(b.name)

    if a_normalized == b_normalized and a.name != b.name:
        return MatchResult(
            rule="R3",
            confidence=0.90,
            evidence={
                "a_original": a.name,
                "b_original": b.name,
                "normalized": a_normalized,
                "mapping_used": {k: v for k, v in syn.items() if k in a.name or k in b.name},
            },
        )

    # Also check surface_forms normalization
    for sf_a in a.surface_forms:
        n_sf_a = _normalize_name(sf_a)
        for sf_b in b.surface_forms:
            n_sf_b = _normalize_name(sf_b)
            if n_sf_a == n_sf_b and sf_a != sf_b:
                return MatchResult(
                    rule="R3",
                    confidence=0.90,
                    evidence={
                        "a_surface": sf_a,
                        "b_surface": sf_b,
                        "normalized": n_sf_a,
                        "mapping_used": {k: v for k, v in syn.items() if k in sf_a or k in sf_b},
                    },
                )

    return None


# ---------------------------------------------------------------------------
# Rule R5 — bidirectional alias-dict match
# ---------------------------------------------------------------------------


def rule_r5(
    a: EntitySnapshot,
    b: EntitySnapshot,
    ctx: ScorePairContext,
) -> MatchResult | None:
    """R5: bidirectional alias-dict match (confidence 0.90).

    Checks if (a.name, b.name) — or any surface form pair — appears in
    `ctx.alias_dict`. Both orderings (a,b) and (b,a) MUST be indexed in
    the dict by the case-domain plugin.

    The alias entry can carry a domain-specific attribute used as a guard:
    if the entry's "dynasty" (or `cross_dynasty_attr`) field is set, at
    least one of the two entities' corresponding domain_attr must match.
    This prevents cross-domain false positives (e.g. two namesakes from
    different jurisdictions).
    """
    if not ctx.alias_dict:
        return None

    a_all = a.all_names()
    b_all = b.all_names()

    cross_attr = ctx.cross_dynasty_attr
    a_attr = a.domain_attrs.get(cross_attr, "") if cross_attr else ""
    b_attr = b.domain_attrs.get(cross_attr, "") if cross_attr else ""

    for name_a in a_all:
        for name_b in b_all:
            if name_a == name_b:
                continue
            entry = ctx.alias_dict.get((name_a, name_b))
            if entry is None:
                continue

            entry_attr = entry.get(cross_attr, "") if cross_attr else ""
            if entry_attr and a_attr and b_attr:
                if a_attr != entry_attr and b_attr != entry_attr:
                    continue

            return MatchResult(
                rule="R5",
                confidence=0.90,
                evidence={
                    "matched_a": name_a,
                    "matched_b": name_b,
                    "dict_canonical": entry.get("canonical", ""),
                    "dict_alias": entry.get("alias", ""),
                    "dict_attr": entry_attr,
                    "source": entry.get("source", ""),
                    "notes": entry.get("notes", ""),
                },
            )

    return None


# ---------------------------------------------------------------------------
# Rule R4 — identity_notes cross-reference (hypothesis only)
# ---------------------------------------------------------------------------


# Punctuation stripped from R4-extracted names (Chinese + Western).
_NAME_STRIP_CHARS = "，。、；：「」『』【】《》〈〉,.;:'\"()[]{}"


def _extract_noted_names(
    notes: list[str],
    patterns: list[re.Pattern[str]],
) -> set[str]:
    """Extract entity names referenced in identity_notes via regex patterns.

    Strips common Chinese / Western punctuation from extracted matches.
    Returns empty set if no patterns provided.
    """
    if not patterns:
        return set()
    names: set[str] = set()
    for note in notes:
        for pattern in patterns:
            for match in pattern.finditer(note):
                for group in match.groups():
                    cleaned = group.strip(_NAME_STRIP_CHARS)
                    if cleaned:
                        names.add(cleaned)
    return names


def rule_r4(
    a: EntitySnapshot,
    b: EntitySnapshot,
    ctx: ScorePairContext,
) -> MatchResult | None:
    """R4: identity_notes cross-reference (confidence 0.65 — hypothesis only).

    Parses each entity's `identity_notes` for references to the other entity
    using `ctx.notes_patterns`. R4 produces a HypothesisProposal (below the
    merge threshold) — the Domain Expert decides whether to confirm.

    Empty patterns list disables R4.
    """
    if not ctx.notes_patterns:
        return None

    a_noted = _extract_noted_names(a.identity_notes, ctx.notes_patterns)
    b_noted = _extract_noted_names(b.identity_notes, ctx.notes_patterns)

    a_mentions_b = b.name in a_noted or any(sf in a_noted for sf in b.surface_forms)
    b_mentions_a = a.name in b_noted or any(sf in b_noted for sf in a.surface_forms)

    if a_mentions_b or b_mentions_a:
        return MatchResult(
            rule="R4",
            confidence=0.65,
            evidence={
                "a_noted_names": sorted(a_noted),
                "b_noted_names": sorted(b_noted),
                "a_mentions_b": a_mentions_b,
                "b_mentions_a": b_mentions_a,
                "a_identity_notes": a.identity_notes,
                "b_identity_notes": b.identity_notes,
            },
        )

    return None


# ---------------------------------------------------------------------------
# Public API — score_pair (rule dispatcher)
# ---------------------------------------------------------------------------

# Default evaluation order — R1 → R3 → R5 → R4 (first-match-wins).
# R2 is intentionally absent; case domains opt in by registering it as a
# custom rule (see ScorePairContext.custom_rules).
DEFAULT_RULE_ORDER: list[RuleFn] = [rule_r1, rule_r3, rule_r5, rule_r4]


def score_pair(
    a: EntitySnapshot,
    b: EntitySnapshot,
    ctx: ScorePairContext,
) -> MatchResult | None:
    """Evaluate a pair of entities against all rules (first-match-wins).

    Returns the first matching MatchResult (highest priority rule that fires),
    or None if no rule fires. Custom rules from `ctx.custom_rules` are
    appended to the default order.
    """
    rules = DEFAULT_RULE_ORDER + ctx.custom_rules
    for rule_fn in rules:
        try:
            result = rule_fn(a, b, ctx)
        except Exception:  # noqa: BLE001
            logger.warning(
                "Rule %s raised an exception evaluating (%s, %s); skipping",
                rule_fn.__name__,
                a.name,
                b.name,
                exc_info=True,
            )
            continue
        if result is not None:
            return result
    return None
