"""Dry-run report generator — human-readable text summary of a ResolveResult.

The framework provides a domain-agnostic report skeleton; case domains can
inject custom evidence formatting via the `ReasonBuilder` plugin (e.g. to
localize labels into Chinese, or use domain terminology for rule names).

The default report uses English / generic labels:
    - "Run ID:" / "Total entities:" / "Auto-merge groups:" / etc.

HuaDian classics provides a Chinese-localized `ReasonBuilder` reference
implementation in `examples/huadian_classics/reason_builder_zh.py`.

License: Apache 2.0
Source: extracted from `services/pipeline/src/huadian_pipeline/resolve.py`
        (HuaDian Sprint N first-cut framework abstraction).
"""

from __future__ import annotations

import re
from typing import Any, Protocol

from .types import ResolveResult


class ReasonBuilder(Protocol):
    """Plugin for formatting rule evidence into human-readable strings.

    The default `DefaultReasonBuilder` uses generic labels:
      "R1 surface overlap: a, b, c"
      "R3 synonym dict: 倕→垂"

    Case domains can implement this protocol to localize / customize:
      - HuaDian classics: Chinese labels ("R1 表面形式重叠: ...")
      - Medical:           "R3 drug variant: Tylenol → acetaminophen"
      - Legal:             "R3 citation variant: U.S. → United States"
    """

    def format_rule_evidence(self, rule: str, evidence: dict[str, Any]) -> str:
        """Format a rule + evidence dict into a one-line human description."""
        ...

    def format_canonical_reason(
        self,
        canonical_name: str,
        canonical_slug: str,
    ) -> str:
        """Format the canonical-selection rationale (e.g. 'has pinyin slug')."""
        ...


class DefaultReasonBuilder:
    """Generic English / domain-agnostic ReasonBuilder.

    Recognizes R1 / R3 / R4 / R5 / R6 — uses pass-through formatting for
    other rules (just shows rule name + evidence keys).
    """

    def format_rule_evidence(self, rule: str, ev: dict[str, Any]) -> str:  # noqa: PLR0911
        if rule == "R1":
            overlap = ", ".join(ev.get("overlap", []))
            return f"R1 surface overlap: {overlap}"
        if rule == "R3":
            a = ev.get("a_original") or ev.get("a_surface", "?")
            b = ev.get("b_original") or ev.get("b_surface", "?")
            norm = ev.get("normalized", "?")
            mappings = ev.get("mapping_used", {})
            src = ", ".join(f"{k}→{v}" for k, v in mappings.items()) if mappings else ""
            src_str = f" (mappings: {src})" if src else ""
            return f"R3 synonym dict {a}→{b} (→{norm}){src_str}"
        if rule == "R4":
            return (
                f"R4 identity_notes cross-reference "
                f"(a_mentions_b={ev.get('a_mentions_b')}, b_mentions_a={ev.get('b_mentions_a')})"
            )
        if rule == "R5":
            canon = ev.get("dict_canonical", "?")
            alias = ev.get("dict_alias", "?")
            source = ev.get("source", "")
            src_str = f" (source: {source})" if source else ""
            return f"R5 alias dict {canon}/{alias}{src_str}"
        if rule == "R6":
            qid = ev.get("external_id", "?")
            source = ev.get("source", "wikidata")
            return f"R6 external anchor {source}:{qid}"
        # Unknown rule (custom rule from case domain) — pass through
        return f"{rule} evidence: {ev}"

    def format_canonical_reason(self, canonical_name: str, canonical_slug: str) -> str:
        return "has pinyin slug" if _slug_is_pinyin(canonical_slug) else "most surface forms"


def _slug_is_pinyin(slug: str) -> bool:
    """Default heuristic: True if slug is not a `u{4hex}` Unicode fallback."""
    return not bool(re.match(r"^u[0-9a-f]{4}", slug))


def build_reason_summary(
    canonical_name: str,
    canonical_slug: str,
    proposals: list[Any],
    builder: ReasonBuilder,
) -> str:
    """Build a one-line reason string for a merge group.

    Combines the canonical-selection rationale + each contributing proposal
    into a semicolon-separated summary. Used by resolve.py when constructing
    `MergeGroup.reason`.
    """
    parts: list[str] = [
        builder.format_rule_evidence(prop.match.rule, prop.match.evidence) for prop in proposals
    ]
    rules_str = "; ".join(parts) if parts else "unknown"
    canon_reason = builder.format_canonical_reason(canonical_name, canonical_slug)
    return f"canonical={canonical_name} ({canon_reason}); rules: {rules_str}"


def generate_dry_run_report(
    result: ResolveResult,
    *,
    builder: ReasonBuilder | None = None,
    merge_threshold: float = 0.90,
    known_guard_types: tuple[str, ...] = (),
) -> str:
    """Generate a human-readable dry-run report from a ResolveResult.

    Args:
        result:             the ResolveResult to format
        builder:            ReasonBuilder for evidence formatting; defaults
                            to `DefaultReasonBuilder` (generic English).
        merge_threshold:    threshold value to display in headers (default 0.90)
        known_guard_types:  tuple of guard_type values the case domain
                            recognizes; unknown ones are bucketed as "unknown"
                            with a warning (e.g. ("cross_dynasty", "state_prefix"))

    Format (default English):
        Run ID: <run_id>
        Total entities: N
        Auto-merge groups: K (score >= 0.9)
          Group 1: [name(slug), ...] → canonical=name (reason: ...)
            Rule: R3 synonym dict 倕→垂 (→垂)
            Confidence: 0.90
        ...
    """
    if builder is None:
        builder = DefaultReasonBuilder()

    lines: list[str] = []
    lines.append(f"Run ID: {result.run_id}")
    lines.append(f"Total entities: {result.total_entities}")
    lines.append(f"Auto-merge groups: {len(result.merge_groups)} (score >= {merge_threshold})")

    for idx, group in enumerate(result.merge_groups, start=1):
        all_members = [(group.canonical_name, group.canonical_slug)] + list(
            zip(group.merged_names, group.merged_slugs, strict=True)
        )
        members_str = ", ".join(f"{name}({slug})" for name, slug in all_members)
        canon_reason = builder.format_canonical_reason(group.canonical_name, group.canonical_slug)
        lines.append(
            f"  Group {idx}: [{members_str}] → canonical={group.canonical_name} (reason: {canon_reason})"
        )

        for prop in group.proposals:
            rule_label = builder.format_rule_evidence(prop.match.rule, prop.match.evidence)
            lines.append(f"    Rule: {rule_label}")
            lines.append(f"    Confidence: {prop.match.confidence:.2f}")

    lines.append("")
    lines.append(
        f"Hypothesis proposals: {len(result.hypotheses)} (0.5 <= score < {merge_threshold})"
    )
    for idx, hyp in enumerate(result.hypotheses, start=1):
        lines.append(
            f"  Candidate {idx}: {hyp.entity_a_name}({hyp.entity_a_id[:8]}…) "
            f"? {hyp.entity_b_name}({hyp.entity_b_id[:8]}…)"
        )
        rule_label = builder.format_rule_evidence(hyp.match.rule, hyp.match.evidence)
        lines.append(f"    Rule: {rule_label}")
        lines.append(f"    Confidence: {hyp.match.confidence:.2f}")

    if result.errors:
        lines.append("")
        lines.append(f"Errors: {len(result.errors)}")
        for err in result.errors:
            lines.append(f"  - {err}")

    if result.blocked_merges:
        lines.append("")
        lines.append(f"Guard-blocked merges: {len(result.blocked_merges)} pairs")
        guard_type_counts: dict[str, int] = {}
        for item in result.blocked_merges:
            guard_type_counts[item.guard_type] = guard_type_counts.get(item.guard_type, 0) + 1
        for gt in known_guard_types:
            if gt in guard_type_counts:
                lines.append(f"  {gt}: {guard_type_counts[gt]} pairs")
        unknown_count = sum(v for k, v in guard_type_counts.items() if k not in known_guard_types)
        if unknown_count > 0:
            lines.append(f"  unknown: {unknown_count} pairs ⚠️")
        for idx, item in enumerate(result.blocked_merges, start=1):
            lines.append(
                f"  Block {idx}: {item.entity_a_name} ↔ {item.entity_b_name} "
                f"— {item.guard_type} ({item.proposed_rule})"
            )

    if result.r6_distribution:
        lines.append("")
        lines.append("R6 seed-match pre-pass distribution:")
        for status_key in ("matched", "not_found", "below_cutoff", "ambiguous"):
            count = result.r6_distribution.get(status_key, 0)
            lines.append(f"  {status_key}: {count}")
        lines.append(f"  total: {sum(result.r6_distribution.values())}")

    rule_counts: dict[str, int] = {}
    for group in result.merge_groups:
        for prop in group.proposals:
            rule_counts[prop.match.rule] = rule_counts.get(prop.match.rule, 0) + 1
    if rule_counts:
        lines.append("")
        lines.append("Rule distribution (merge proposals):")
        for rule_name in sorted(rule_counts):
            lines.append(f"  {rule_name}: {rule_counts[rule_name]}")

    lines.append("")
    lines.append(
        f"Estimated entity count after merge: {result.entities_after_merge} "
        f"(net -{result.total_merged_entities})"
    )

    return "\n".join(lines)
