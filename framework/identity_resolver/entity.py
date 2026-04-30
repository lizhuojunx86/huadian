"""EntitySnapshot — domain-agnostic in-memory representation of a resolvable entity.

The huadian original called this `PersonSnapshot`. The framework renames it
to `EntitySnapshot` because identity resolution is not person-specific — it
applies equally to legal cases, drug records, patents, places, etc.

A backward-compat alias `PersonSnapshot = EntitySnapshot` is provided so
case domains migrating from huadian_pipeline don't need code churn.

License: Apache 2.0
Source: abstracted from `services/pipeline/src/huadian_pipeline/resolve_rules.py`
        (HuaDian Sprint N first-cut framework abstraction).
"""

from __future__ import annotations

import re
from typing import Any

# Note: avoid forward-referencing to break cyclic imports. SeedMatchResult
# (used by the optional R6 rule) is referenced only as a type hint that
# accepts Any to keep this module dependency-free for cases that don't use R6.


class EntitySnapshot:
    """Lightweight in-memory view of an entity row, passed to rule evaluators.

    Required attributes (every case domain must populate):
        id:             primary key (str — UUID, integer-as-str, etc.)
        name:           canonical / primary name string
        slug:           URL-safe identifier (used for canonical selection)
        surface_forms:  set of all known name strings for this entity
                        (must include `name` itself)
        created_at:     ISO 8601 timestamp string (used for canonical
                        selection tiebreak)

    Optional / domain-flavored attributes (populate as your domain needs):
        domain_attrs:   freeform dict — case domains store dynasty / jurisdiction
                        / drug_class / patent_year / etc. Rule plugins can
                        introspect this for guards.
        identity_notes: list of free-text notes that may reference other
                        entities (used by R4 cross-reference rule).
        seed_match:     attached by the optional R6 pre-pass; opaque to rules
                        that don't use R6.

    Why a class and not a dataclass:
        - We need `__slots__` for memory efficiency at O(n) entity counts.
        - We expose `has_pinyin_slug()` (a default canonical-selection hint
          based on slug shape) as a method — case domains can override this
          via the `CanonicalHint` plugin if their slug semantics differ.
    """

    __slots__ = (
        "id",
        "name",
        "slug",
        "surface_forms",
        "created_at",
        "domain_attrs",
        "identity_notes",
        "seed_match",
    )

    def __init__(
        self,
        id: str,  # noqa: A002 — id is the natural name here
        name: str,
        slug: str,
        surface_forms: set[str],
        created_at: str,
        *,
        domain_attrs: dict[str, Any] | None = None,
        identity_notes: list[str] | None = None,
        seed_match: Any = None,
    ) -> None:
        self.id = id
        self.name = name
        self.slug = slug
        self.surface_forms = surface_forms
        self.created_at = created_at
        self.domain_attrs = domain_attrs or {}
        self.identity_notes = identity_notes or []
        self.seed_match = seed_match

    def all_names(self) -> set[str]:
        """Return the union of `name` and all `surface_forms`.

        Used by R1 (surface overlap) and other rules that consider all known
        names of an entity.
        """
        return self.surface_forms | {self.name}

    def has_pinyin_slug(self) -> bool:
        """Default check: True if slug is not a `u{4hex}` fallback.

        HuaDian uses pinyin slugs like `liu-bang`, falling back to `u5b88`
        (Unicode escape) for characters with no romanization. Other domains
        likely don't have this convention — they should either override via
        `CanonicalHint` plugin or accept the default behavior (which always
        returns True for non-`u{hex}` slugs).
        """
        return not bool(re.match(r"^u[0-9a-f]{4}", self.slug))


# ---------------------------------------------------------------------------
# Backward-compat alias
# ---------------------------------------------------------------------------

PersonSnapshot = EntitySnapshot
"""Alias for `EntitySnapshot`.

HuaDian-pipeline code that imports `PersonSnapshot` continues to work:

    from framework.identity_resolver.entity import PersonSnapshot
"""
