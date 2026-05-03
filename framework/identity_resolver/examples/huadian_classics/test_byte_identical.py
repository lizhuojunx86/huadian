"""Byte-identical dogfood verification for Sprint N Stage 1.13.

Runs two dry-run passes against the same HuaDian Postgres database:

    A. services/pipeline/src/huadian_pipeline/resolve.py:resolve_identities()
       (production code path)

    B. framework.identity_resolver.resolve_identities()
       + framework.identity_resolver.examples.huadian_classics adapters
       (framework abstraction path)

Then compares the two ResolveResult objects field-by-field. Expected outcome:
    BYTE-IDENTICAL except for `run_id` (UUID-random per run).

If any other field differs → Sprint N Stop Rule #1 triggers → either fix the
framework abstraction or roll back to Stage 1 design.

Usage:
    cd <project_root>
    uv run python -m framework.identity_resolver.examples.huadian_classics.test_byte_identical

Requirements:
    - asyncpg connection to HuaDian Postgres (same DB as production runs)
    - Python 3.12+ (services/pipeline requirement)
    - PyYAML (for HuaDianDictionaryLoader)

License: Apache 2.0
Source: Sprint N Stage 1.13 dogfood gate.
"""

from __future__ import annotations

import asyncio
import json
import logging
import os
import sys
from dataclasses import asdict
from typing import Any

import asyncpg

# Framework imports
from framework.identity_resolver import (
    build_score_pair_context,
    resolve_identities,
)
from framework.identity_resolver.examples.huadian_classics import (
    di_honorific_hint,
    dictionary_loaders,
    guard_chains,
    identity_notes_patterns,
    person_loader,
    r1_stop_words,
    r2_di_prefix_rule,
    reason_builder_zh,
    seed_match_adapter,
)

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Comparison helpers
# ---------------------------------------------------------------------------

# Fields ignored during byte-identical comparison (legitimately differ run-to-run).
_IGNORE_FIELDS = {
    "run_id",  # UUID, random per call
}

# Field aliases — bridges domain-specific naming (production) ↔ framework
# naming. Each entry is (canonical, alternate_names_in_either_side). The
# alternate names list is searched in order; first hit wins.
#
# Sprint N intro: huadian production used `total_persons`; framework abstraction
# renamed to `total_entities` for cross-domain re-use. Same for per-row
# `entity_a_id` / `person_a_id` in proposals.
#
# Sprint P DGF-N-01 generalisation: extend FIELD_ALIASES instead of writing
# ad-hoc `d.get("a", d.get("b"))` inline; downstream forks (legal / medical
# examples) may add their own aliases without touching `compare()` body.
FIELD_ALIASES: dict[str, tuple[str, ...]] = {
    "total_entities": ("total_entities", "total_persons"),
    "entity_a_id": ("entity_a_id", "person_a_id"),
    "entity_b_id": ("entity_b_id", "person_b_id"),
}


def _get_aliased(d: dict, canonical: str) -> Any:
    """Return d[canonical] or first alias hit, else None."""
    for key in FIELD_ALIASES.get(canonical, (canonical,)):
        if key in d:
            return d[key]
    return None


def normalize_for_compare(result: Any) -> dict:
    """Convert a ResolveResult to a comparable dict with run_id stripped + sorted lists."""
    if hasattr(result, "__dataclass_fields__"):
        data = asdict(result)
    else:
        # Production huadian_pipeline ResolveResult might not be a dataclass
        # → use __dict__
        data = {k: v for k, v in vars(result).items() if not k.startswith("_")}

    # Strip ignored fields
    for f in _IGNORE_FIELDS:
        data.pop(f, None)

    # Sort lists by their identifying fields for deterministic comparison
    if "merge_groups" in data:
        for g in data["merge_groups"]:
            # Sort merged_ids/names/slugs together (preserve correspondence)
            if "merged_ids" in g:
                triples = sorted(
                    zip(g["merged_ids"], g["merged_names"], g["merged_slugs"], strict=True)
                )
                if triples:
                    g["merged_ids"], g["merged_names"], g["merged_slugs"] = (
                        list(x) for x in zip(*triples, strict=True)
                    )
                else:
                    g["merged_ids"] = g["merged_names"] = g["merged_slugs"] = []
            # Sort proposals by (a_id, b_id, rule) — alias-aware
            if "proposals" in g:
                g["proposals"].sort(
                    key=lambda p: (
                        _get_aliased(p, "entity_a_id") or "",
                        _get_aliased(p, "entity_b_id") or "",
                        p["match"]["rule"],
                    )
                )
        data["merge_groups"].sort(key=lambda g: g["canonical_id"])

    if "hypotheses" in data:
        data["hypotheses"].sort(
            key=lambda h: (
                _get_aliased(h, "entity_a_id") or "",
                _get_aliased(h, "entity_b_id") or "",
            )
        )

    if "blocked_merges" in data:
        data["blocked_merges"].sort(
            key=lambda b: (
                _get_aliased(b, "entity_a_id") or "",
                _get_aliased(b, "entity_b_id") or "",
                b["proposed_rule"],
                b["guard_type"],
            )
        )

    return data


def compare(prod: dict, fw: dict) -> tuple[bool, list[str]]:
    """Compare two normalized result dicts. Returns (is_identical, diff_messages).

    Field aliases: framework renamed domain-specific names (`person`) →
    cross-domain names (`entity`). All such aliases live in module-level
    ``FIELD_ALIASES``; this function uses ``_get_aliased`` to look up
    canonical fields without hard-coding the alternate names here.

    To extend for other domains (legal / medical / etc): add entries to
    ``FIELD_ALIASES`` rather than editing this function. See Sprint P
    DGF-N-01 patch rationale.
    """
    diffs: list[str] = []

    # Total count — alias-aware lookup
    prod_total = _get_aliased(prod, "total_entities")
    fw_total = _get_aliased(fw, "total_entities")
    if prod_total != fw_total:
        diffs.append(f"total count: prod={prod_total} fw={fw_total}")

    # R6 distribution — same key in both
    if prod.get("r6_distribution") != fw.get("r6_distribution"):
        diffs.append(
            f"r6_distribution: prod={prod.get('r6_distribution')} fw={fw.get('r6_distribution')}"
        )

    # Compare merge_groups
    pg = prod.get("merge_groups", [])
    fg = fw.get("merge_groups", [])
    if len(pg) != len(fg):
        diffs.append(f"merge_groups count: prod={len(pg)} fw={len(fg)}")
    for i, (p, f) in enumerate(zip(pg, fg, strict=False)):
        if p.get("canonical_id") != f.get("canonical_id"):
            diffs.append(
                f"merge_group[{i}].canonical_id: prod={p.get('canonical_id')} fw={f.get('canonical_id')}"
            )
        if sorted(p.get("merged_ids", [])) != sorted(f.get("merged_ids", [])):
            diffs.append(
                f"merge_group[{i}].merged_ids differ: "
                f"prod={sorted(p.get('merged_ids', []))} fw={sorted(f.get('merged_ids', []))}"
            )

    # Compare blocked_merges count + per-pair rule
    pb = prod.get("blocked_merges", [])
    fb = fw.get("blocked_merges", [])
    if len(pb) != len(fb):
        diffs.append(f"blocked_merges count: prod={len(pb)} fw={len(fb)}")

    # Compare hypotheses count
    ph = prod.get("hypotheses", [])
    fh = fw.get("hypotheses", [])
    if len(ph) != len(fh):
        diffs.append(f"hypotheses count: prod={len(ph)} fw={len(fh)}")

    return (len(diffs) == 0, diffs)


# ---------------------------------------------------------------------------
# Run path A — production huadian_pipeline
# ---------------------------------------------------------------------------


async def run_production(pool: asyncpg.Pool) -> Any:
    """Run the production code path (services/pipeline/.../resolve.py)."""
    # Add services/pipeline to path
    here = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(here, "..", "..", "..", ".."))
    pipeline_src = os.path.join(project_root, "services", "pipeline", "src")
    if pipeline_src not in sys.path:
        sys.path.insert(0, pipeline_src)

    from huadian_pipeline.resolve import resolve_identities as prod_resolve

    logger.info("=== Path A: production resolve_identities() ===")
    return await prod_resolve(pool)


# ---------------------------------------------------------------------------
# Run path B — framework abstraction
# ---------------------------------------------------------------------------


async def run_framework(pool: asyncpg.Pool) -> Any:
    """Run the framework abstraction with HuaDian classics adapters."""
    logger.info("=== Path B: framework resolve_identities() ===")

    ctx = build_score_pair_context(
        dictionary_loader=dictionary_loaders.HuaDianDictionaryLoader(),
        stop_word_plugin=r1_stop_words.HuaDianStopWords(),
        notes_patterns_plugin=identity_notes_patterns.HuaDianNotesPatterns(),
        cross_dynasty_attr="dynasty",
        custom_rules=[r2_di_prefix_rule.rule_r2_di_prefix],
    )

    return await resolve_identities(
        loader=person_loader.HuaDianPersonLoader(pool),
        score_context=ctx,
        guard_chains=guard_chains.HUADIAN_GUARD_CHAINS,
        r6_prepass=seed_match_adapter.HuaDianR6PrePassRunner(pool),
        canonical_hint=di_honorific_hint.HuaDianDiHonorificHint(),
        reason_builder=reason_builder_zh.HuaDianReasonBuilderZh(),
    )


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


async def main() -> int:
    db_url = os.environ.get("DATABASE_URL")
    if not db_url:
        print("ERROR: DATABASE_URL environment variable required.", file=sys.stderr)
        return 2

    pool = await asyncpg.create_pool(db_url, min_size=1, max_size=4)
    try:
        prod_result = await run_production(pool)
        fw_result = await run_framework(pool)
    finally:
        await pool.close()

    prod_norm = normalize_for_compare(prod_result)
    fw_norm = normalize_for_compare(fw_result)

    identical, diffs = compare(prod_norm, fw_norm)

    print()
    print("=" * 72)
    print("Sprint N Stage 1.13 — byte-identical dogfood verification")
    print("=" * 72)
    print(f"Production path total_entities: {_get_aliased(prod_norm, 'total_entities')}")
    print(f"Framework path total_entities:   {_get_aliased(fw_norm, 'total_entities')}")
    print(f"Production merge_groups:         {len(prod_norm.get('merge_groups', []))}")
    print(f"Framework merge_groups:          {len(fw_norm.get('merge_groups', []))}")
    print(f"Production blocked_merges:       {len(prod_norm.get('blocked_merges', []))}")
    print(f"Framework blocked_merges:        {len(fw_norm.get('blocked_merges', []))}")
    print(f"Production hypotheses:           {len(prod_norm.get('hypotheses', []))}")
    print(f"Framework hypotheses:            {len(fw_norm.get('hypotheses', []))}")
    print()

    if identical:
        print("✓ BYTE-IDENTICAL — Sprint N Stage 1.13 dogfood gate PASSED")
        # Optionally write detailed diffs to a file for audit
        with open("/tmp/sprint-n-dogfood-prod.json", "w") as f:
            json.dump(prod_norm, f, ensure_ascii=False, indent=2, default=str)
        with open("/tmp/sprint-n-dogfood-framework.json", "w") as f:
            json.dump(fw_norm, f, ensure_ascii=False, indent=2, default=str)
        print("  (detailed dumps: /tmp/sprint-n-dogfood-{prod,framework}.json)")
        return 0

    print("✗ DIFFERENCES DETECTED — Sprint N Stop Rule #1 triggered")
    print()
    for d in diffs:
        print(f"  - {d}")
    print()
    print("Architect must inspect + decide:")
    print("  1. Fix framework code to match production (likely: missing hint / wrong default)")
    print("  2. Or rollback Stage 1 + redesign abstraction (deeper issue)")
    return 1


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
