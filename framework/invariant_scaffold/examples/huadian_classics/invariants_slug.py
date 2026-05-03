"""Slug invariants — Tier-S whitelist OR unicode-hex regex + no collisions.

Two invariants:
    Slug-A: every active person's slug must be either Tier-S whitelist
            value OR match unicode-hex pattern ^u[0-9a-f]{4,5}(-u[0-9a-f]{4,5})*$
            (Pattern: ContainmentInvariant with python predicate)
    Slug-B: no two active persons share the same slug
            (Pattern: CardinalityBoundInvariant per_entity_range, max=1)

Source: services/pipeline/tests/test_slug_invariant.py
ADR: ADR-011 (slug naming convention)
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Any

from framework.invariant_scaffold import (
    CardinalityBoundInvariant,
    ContainmentInvariant,
)

UNICODE_SLUG_RE = re.compile(r"^u[0-9a-f]{4,5}(-u[0-9a-f]{4,5})*$")

SLUG_SELECT_ALL_SQL = """
    SELECT slug, name->>'zh-Hans' AS name_zh
    FROM persons
    WHERE merged_into_id IS NULL AND deleted_at IS NULL
    ORDER BY slug
"""

SLUG_COLLISION_SQL = """
    SELECT slug, COUNT(*) AS cnt
    FROM persons
    WHERE merged_into_id IS NULL AND deleted_at IS NULL
    GROUP BY slug
    HAVING COUNT(*) > 1
"""


def _load_tier_s_whitelist() -> set[str]:
    """Load Tier-S slug whitelist values from data/tier-s-slugs.yaml.

    The huadian_pipeline package provides get_tier_s_whitelist() which
    returns dict[chinese_name, slug]; we need the set of slug values.

    Path note: this file lives at
        framework/invariant_scaffold/examples/huadian_classics/invariants_slug.py
    so the project root is 4 levels up:
        parents[0]=huadian_classics, [1]=examples, [2]=invariant_scaffold,
        [3]=framework, [4]=<project_root>
    """
    # Primary path: import from huadian_pipeline (catch any exception, not
    # just ImportError — yaml loader inside slug.py can also raise).
    try:
        from huadian_pipeline.slug import get_tier_s_whitelist  # type: ignore

        return set(get_tier_s_whitelist().values())
    except Exception:  # noqa: BLE001
        pass

    # Fallback: parse the YAML directly
    try:
        import yaml  # type: ignore
    except ImportError:
        return set()
    path = Path(__file__).resolve().parents[4] / "data" / "tier-s-slugs.yaml"
    if not path.exists():
        return set()
    with path.open(encoding="utf-8") as fh:
        data = yaml.safe_load(fh) or {}
    return set(data.values()) if isinstance(data, dict) else set()


def _slug_predicate_factory() -> Any:
    """Build a closure that closes over the loaded whitelist."""
    whitelist = _load_tier_s_whitelist()

    def predicate(row: dict[str, Any]) -> bool:
        slug = row.get("slug", "")
        is_tier_s = slug in whitelist
        is_unicode = bool(UNICODE_SLUG_RE.match(slug))
        return is_tier_s or is_unicode

    return predicate


def make_slug_format() -> ContainmentInvariant:
    """Slug-A — every slug ∈ (Tier-S whitelist ∪ unicode-hex regex)."""
    return ContainmentInvariant.from_template(
        name="slug_format",
        description="every active slug must be Tier-S whitelist OR unicode-hex regex",
        sql=SLUG_SELECT_ALL_SQL,
        in_python_predicate=_slug_predicate_factory(),
        violation_explanation_fmt="slug {slug} ({name_zh}) violates ADR-011 format",
        severity="critical",
    )


def make_slug_no_collision() -> CardinalityBoundInvariant:
    """Slug-B — no two active persons share the same slug."""
    return CardinalityBoundInvariant.from_template(
        name="slug_no_collision",
        description="no two active persons share the same slug",
        sql=SLUG_COLLISION_SQL,
        mode="per_entity_range",
        max_count=1,
        violation_explanation_fmt="slug {slug} appears {cnt} times among active persons",
        severity="critical",
    )
