"""HuaDian classics — R2 帝X prefix rule (HuaDian-specific custom rule).

R2 fires when one entity's name is "帝" + another entity's name. This is a
specifically Chinese honorific pattern (e.g. "帝尧" / "帝舜" — pre-imperial
mythological rulers prefixed with "帝" / "Di" / "Emperor").

R2 is NOT in the default rule order. HuaDian classics opts in by passing
this rule via `ScorePairContext.custom_rules`.

Cross-domain note: other case domains will NOT use R2. It's HuaDian-specific.
This file demonstrates the pattern for adding domain-specific rules.

License: Apache 2.0
Source: extracted from `services/pipeline/src/huadian_pipeline/resolve_rules.py`
        `_rule_r2`.
"""

from __future__ import annotations

from framework.identity_resolver import EntitySnapshot, MatchResult, ScorePairContext


def is_di_honorific(name: str) -> bool:
    """Return True if `name` is a 帝X honorific (e.g. 帝尧, 帝南庚).

    Conditions:
      1. Starts with "帝"
      2. The bare portion (`name[1:]`) is 1–2 characters
    """
    if not name.startswith("帝"):
        return False
    return 1 <= len(name[1:]) <= 2


def rule_r2_di_prefix(
    a: EntitySnapshot,
    b: EntitySnapshot,
    ctx: ScorePairContext,  # noqa: ARG001 — protocol signature
) -> MatchResult | None:
    """R2: 帝X / X prefix match (confidence 0.93).

    Fires if "帝" + a.name == b.name (or vice versa), with guards:
      - Same dynasty (or one is unknown)
      - Single-char short names need at least one surface_form overlap
    """

    def _check(short: EntitySnapshot, long: EntitySnapshot) -> bool:
        expected_long = "帝" + short.name
        if long.name != expected_long:
            return False
        # Dynasty guard: same or one missing (uses domain_attrs["dynasty"])
        sd = short.domain_attrs.get("dynasty", "")
        ld = long.domain_attrs.get("dynasty", "")
        if sd and ld and sd != ld:
            return False
        # Single-char guard: short single-char names need surface_form overlap
        return not (len(short.name) == 1 and not (short.all_names() & long.all_names()))

    if _check(a, b):
        direction = f"{a.name}→帝{a.name}"
        short, long = a, b
    elif _check(b, a):
        direction = f"{b.name}→帝{b.name}"
        short, long = b, a
    else:
        return None

    return MatchResult(
        rule="R2",
        confidence=0.93,
        evidence={
            "direction": direction,
            "short_name": short.name,
            "long_name": long.name,
            "short_dynasty": short.domain_attrs.get("dynasty", ""),
            "long_dynasty": long.domain_attrs.get("dynasty", ""),
        },
    )
