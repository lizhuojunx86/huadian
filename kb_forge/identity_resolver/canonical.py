"""Canonical entity selection — pick the representative from a merge group.

Given a merge group (multiple EntitySnapshots that have been transitively
merged), `select_canonical()` chooses one as the canonical representation.
The non-canonical entities are then soft-deleted with `merged_into_id`
pointing to the canonical.

Default selection order (5 priorities, first wins):
    1. has_pinyin_slug    — prefer entities with proper slugs over fallbacks
    2. NOT demoted        — domain hint via `CanonicalHint` plugin
    3. more surface_forms — descending (more known names = canonical)
    4. earlier created_at — ascending (older record more likely canonical)
    5. smaller id         — ascending (deterministic tiebreaker)

Case domains can:
    - Override priority 1 (has_pinyin_slug) by overriding `EntitySnapshot.has_pinyin_slug`
    - Override priority 2 (demotion) by providing a `CanonicalHint` plugin
    - Priorities 3-5 are domain-agnostic; not overridable

License: Apache 2.0
Source: extracted from `services/pipeline/src/huadian_pipeline/resolve.py`
        (HuaDian Sprint N first-cut framework abstraction).
"""

from __future__ import annotations

from .entity import EntitySnapshot
from .rules_protocols import CanonicalHint


def select_canonical(
    entities: list[EntitySnapshot],
    *,
    canonical_hint: CanonicalHint | None = None,
) -> EntitySnapshot:
    """Select the canonical entity from a merge group.

    Args:
        entities:        the merge group (must be non-empty)
        canonical_hint:  optional plugin for domain-specific demotion logic.
                         If None, all entities are treated as non-demoted
                         (priority 2 collapses to a no-op).

    Returns:
        The selected canonical EntitySnapshot.

    Priority (descending):
      1. has_pinyin_slug → True sorts before False
      2. NOT demoted → False sorts before True (demoted ones lose)
      3. more surface_forms → larger count sorts before smaller (descending)
      4. earlier created_at → ISO string ascending
      5. smaller id → string ascending (UUID stable tiebreaker)
    """

    def sort_key(p: EntitySnapshot) -> tuple[int, int, int, str, str]:
        is_demoted = canonical_hint.should_demote(p, entities) if canonical_hint else False
        return (
            0 if p.has_pinyin_slug() else 1,  # 0 = pinyin (preferred), 1 = fallback
            1 if is_demoted else 0,  # 1 = demoted (deferred), 0 = not demoted
            -len(p.surface_forms),  # more forms = lower key = preferred
            p.created_at,  # earlier ISO string = smaller = preferred
            p.id,  # UUID tiebreaker (ascending)
        )

    return min(entities, key=sort_key)
