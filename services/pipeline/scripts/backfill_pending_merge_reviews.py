"""Sprint K Stage 2 prep: backfill pending_merge_reviews from H/I/J dry-runs.

Why
---
apply_resolve.py was bypassed in Sprint G→J content sprints (each apply ran
on a historian-curated MergeProposal list, not on resolve_identities() output),
so guard-blocked candidates were never persisted to pending_merge_reviews.
DB currently shows 0 rows; T-P0-028 triage UI needs real data for Hist E2E.

This script reads the "Guard 拦截" tables in Sprint H/I/J dry-run markdown
reports and INSERTs missing rows. Each row's evidence JSONB is tagged with
``{_backfill: true, source_md: <path>, sprint: <H|I|J>}`` so future audits
can locate retroactively-written rows.

Sources (sprints γ/δ dry-runs report guard_blocked=0 → no contribution):
  - docs/sprint-logs/sprint-h/stage-2-dry-run-2026-04-26.md
      Sprint H combined-table format:
        | # | Pair (A vs B) | Dynasty A vs B | Gap (yr) | 来源 |
        Cell ``A ↔ B`` split on ↔, cell ``DynA / DynB`` split on /
  - docs/sprint-logs/sprint-i/dry-run-2026-04-28.md
      Per-guard-type tables; cross_dynasty header:
        | # | Person A | Person B | Dynasty A | Dynasty B | gap |
  - docs/sprint-logs/sprint-j/dry-run-resolve-2026-04-28.md
      Per-guard-type tables; cross_dynasty header (Sprint J 7fa75a0 fix):
        | # | Person A | Dynasty A | Person B | Dynasty B | gap |
      state_prefix header (I + J identical):
        | # | Person A | Person B | State A | State B |

Parser is header-driven (column position derived from header tokens) so all
three formats parse correctly.

Resolution
----------
SELECT persons WHERE name=$1 AND dynasty=$2 AND deleted_at IS NULL.
- single match → INSERT
- zero match  → skip with WARN (likely soft-deleted post-dry-run, e.g. Sprint J apply)
- multi match → fail-loud (data inconsistency; investigate before re-run)

Pair order: pending_merge_reviews CHECK requires person_a_id < person_b_id.
Normalisation done after UUID resolution.

Dedup
-----
key = (person_a_id, person_b_id, proposed_rule, guard_type) — enforced by
partial UNIQUE INDEX pending_merge_reviews_pair_uniq (WHERE status='pending')
in migration 0012. ON CONFLICT DO NOTHING absorbs cross-sprint repeats
(same pair appearing in H + I + J).

Modes
-----
--dry-run (default)
    Parse + resolve UUIDs + dedup; print sample + counts; do not write.
--apply
    Per-row transaction INSERT; on row failure, log + continue (avoid
    one bad row blocking the batch). Final summary reports written/skipped/errors.

Pre-flight
----------
Recommended (per ADR-017 + § 4 闸门): pg_dump anchor before --apply.
This script does NOT run pg_dump itself; operator is expected to capture
anchor + run V1-V11 baseline before invoking --apply.

Usage
-----
    cd services/pipeline
    uv run python scripts/backfill_pending_merge_reviews.py --dry-run
    uv run python scripts/backfill_pending_merge_reviews.py --apply
"""

from __future__ import annotations

import argparse
import asyncio
import json
import logging
import os
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import asyncpg

# Allow running from repo root or services/pipeline; resolve src/ on sys.path.
_PIPELINE_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(_PIPELINE_ROOT / "src"))

from huadian_pipeline.r6_temporal_guards import _get_dynasty_periods  # noqa: E402
from huadian_pipeline.state_prefix_guard import _resolve_canonical  # noqa: E402

logger = logging.getLogger("backfill_pmr")


# ---------------------------------------------------------------------------
# Source registry — markdown files + sprint label
# ---------------------------------------------------------------------------

_REPO_ROOT = Path(__file__).resolve().parents[3]


@dataclass(frozen=True)
class SprintSource:
    sprint: str  # "H" | "I" | "J"
    md_path: Path
    parser: str  # "h_combined" | "ij_per_type"


SPRINT_SOURCES: tuple[SprintSource, ...] = (
    SprintSource(
        sprint="H",
        md_path=_REPO_ROOT / "docs/sprint-logs/sprint-h/stage-2-dry-run-2026-04-26.md",
        parser="h_combined",
    ),
    SprintSource(
        sprint="I",
        md_path=_REPO_ROOT / "docs/sprint-logs/sprint-i/dry-run-2026-04-28.md",
        parser="ij_per_type",
    ),
    SprintSource(
        sprint="J",
        md_path=_REPO_ROOT / "docs/sprint-logs/sprint-j/dry-run-resolve-2026-04-28.md",
        parser="ij_per_type",
    ),
)


# ---------------------------------------------------------------------------
# Parsed row dataclass
# ---------------------------------------------------------------------------


@dataclass
class GuardBlockedRow:
    sprint: str
    md_path: Path
    name_a: str
    name_b: str
    guard_type: str  # "cross_dynasty" | "state_prefix"
    proposed_rule: (
        str  # "R1" (only R1 has guard chain currently; R6 also possible but H/I/J only show R1)
    )
    # cross_dynasty fields
    dynasty_a: str | None = None
    dynasty_b: str | None = None
    gap_years: int | None = None
    # state_prefix fields
    state_a: str | None = None
    state_b: str | None = None
    # Resolved UUIDs (populated post-DB lookup)
    person_a_id: str | None = None
    person_b_id: str | None = None


# ---------------------------------------------------------------------------
# Markdown parsing
# ---------------------------------------------------------------------------


_TABLE_HEADER_RE = re.compile(r"^\s*\|(.+)\|\s*$")
_CELL_SPLIT = re.compile(r"\s*\|\s*")


def _split_md_table_row(line: str) -> list[str] | None:
    """Split a markdown table row into trimmed cells; return None if not a table row."""
    if not _TABLE_HEADER_RE.match(line):
        return None
    # Strip leading/trailing pipes then split.
    inner = line.strip().strip("|")
    return [c.strip() for c in inner.split("|")]


def _is_separator_row(cells: list[str]) -> bool:
    """Markdown table separator like ``|---|---|`` returns all dashes."""
    return all(re.fullmatch(r":?-+:?", c) for c in cells if c)


def _find_section(text: str, header_pattern: str) -> str | None:
    """Return text from first ``header_pattern`` match to next ``^## `` (exclusive).

    Pattern is matched as a regex against full lines.
    """
    lines = text.splitlines()
    start_idx = None
    pattern = re.compile(header_pattern)
    for i, line in enumerate(lines):
        if pattern.search(line):
            start_idx = i
            break
    if start_idx is None:
        return None
    end_idx = len(lines)
    for j in range(start_idx + 1, len(lines)):
        if lines[j].startswith("## ") and not lines[j].startswith("### "):
            end_idx = j
            break
    return "\n".join(lines[start_idx:end_idx])


def _parse_h_combined_table(md_text: str, source: SprintSource) -> list[GuardBlockedRow]:
    """Parse Sprint H stage-2-dry-run combined table.

    Header: ``| # | Pair (A vs B) | Dynasty A vs B | Gap (yr) | 来源 ... |``
    Cells: ``Name A ↔ Name B`` and ``DynA / DynB``.

    Returns cross_dynasty rows only (Sprint H predates state_prefix).
    """
    section = _find_section(md_text, r"^##\s+\d*\.?\s*Guard\s+拦截")
    if section is None:
        return []

    rows: list[GuardBlockedRow] = []
    in_table = False
    headers: list[str] | None = None
    for line in section.splitlines():
        cells = _split_md_table_row(line)
        if cells is None:
            in_table = False
            headers = None
            continue
        if _is_separator_row(cells):
            continue
        if headers is None:
            # First table row = header
            headers = [c.lower() for c in cells]
            # Detect Sprint H combined table by the "pair" header substring
            if not any("pair" in h or "对" in h for h in headers):
                # Not the table we want; reset and continue scanning.
                headers = None
                continue
            in_table = True
            continue
        if not in_table:
            continue

        # Find columns
        col = {h: i for i, h in enumerate(headers)}

        def get_col(
            *candidates: str,
            _col: dict[str, int] = col,
            _cells: list[str] = cells,
        ) -> str | None:
            for cand in candidates:
                for h, idx in _col.items():
                    if cand in h:
                        return _cells[idx]
            return None

        pair_str = get_col("pair", "对")
        dyn_str = get_col("dynasty")
        gap_str = get_col("gap", "(yr)")
        if pair_str is None or dyn_str is None:
            continue
        if "↔" not in pair_str:
            continue
        a, b = (s.strip() for s in pair_str.split("↔", 1))
        dyns = [s.strip() for s in re.split(r"\s*/\s*", dyn_str)]
        if len(dyns) != 2:
            continue
        dyn_a, dyn_b = dyns
        gap = None
        if gap_str:
            m = re.search(r"-?\d+", gap_str)
            if m:
                gap = int(m.group())
        rows.append(
            GuardBlockedRow(
                sprint=source.sprint,
                md_path=source.md_path,
                name_a=a,
                name_b=b,
                guard_type="cross_dynasty",
                proposed_rule="R1",
                dynasty_a=dyn_a,
                dynasty_b=dyn_b,
                gap_years=gap,
            )
        )
    return rows


def _parse_ij_per_type_tables(md_text: str, source: SprintSource) -> list[GuardBlockedRow]:
    """Parse Sprint I/J per-guard-type tables.

    Sprint I cross_dynasty header: ``| # | Person A | Person B | Dynasty A | Dynasty B | gap |``
    Sprint J cross_dynasty header: ``| # | Person A | Dynasty A | Person B | Dynasty B | gap |``
        (Sprint J 7fa75a0 fixed column ordering display bug)
    state_prefix header (I + J identical):
        ``| # | Person A | Person B | State A | State B |``

    Header-driven parser uses header tokens to map columns regardless of order.
    """
    section = _find_section(md_text, r"^##\s+Guard\s+拦截")
    if section is None:
        return []

    rows: list[GuardBlockedRow] = []
    current_guard: str | None = None
    in_table = False
    headers: list[str] | None = None

    for line in section.splitlines():
        # Detect ### sub-section headers (cross_dynasty / state_prefix)
        sub = re.match(r"^###\s+(cross_dynasty|state_prefix)", line)
        if sub:
            current_guard = sub.group(1)
            in_table = False
            headers = None
            continue

        cells = _split_md_table_row(line)
        if cells is None:
            in_table = False
            headers = None
            continue
        if _is_separator_row(cells):
            continue
        if headers is None:
            headers_lower = [c.lower() for c in cells]
            # Header detection: must include "person a" and "person b"
            if not (
                any("person a" in h for h in headers_lower)
                and any("person b" in h for h in headers_lower)
            ):
                headers = None
                continue
            headers = headers_lower
            in_table = True
            continue
        if not in_table or current_guard is None:
            continue

        col = {h: i for i, h in enumerate(headers)}

        def find_col_idx(
            *candidates: str,
            _col: dict[str, int] = col,
        ) -> int | None:
            for cand in candidates:
                for h, idx in _col.items():
                    if cand in h:
                        return idx
            return None

        idx_a = find_col_idx("person a")
        idx_b = find_col_idx("person b")
        if idx_a is None or idx_b is None:
            continue
        name_a = cells[idx_a]
        name_b = cells[idx_b]

        if current_guard == "cross_dynasty":
            idx_da = find_col_idx("dynasty a")
            idx_db = find_col_idx("dynasty b")
            idx_gap = find_col_idx("gap")
            if idx_da is None or idx_db is None:
                continue
            dyn_a = cells[idx_da]
            dyn_b = cells[idx_db]
            gap = None
            if idx_gap is not None:
                m = re.search(r"-?\d+", cells[idx_gap])
                if m:
                    gap = int(m.group())
            rows.append(
                GuardBlockedRow(
                    sprint=source.sprint,
                    md_path=source.md_path,
                    name_a=name_a,
                    name_b=name_b,
                    guard_type="cross_dynasty",
                    proposed_rule="R1",
                    dynasty_a=dyn_a,
                    dynasty_b=dyn_b,
                    gap_years=gap,
                )
            )
        elif current_guard == "state_prefix":
            idx_sa = find_col_idx("state a")
            idx_sb = find_col_idx("state b")
            if idx_sa is None or idx_sb is None:
                continue
            rows.append(
                GuardBlockedRow(
                    sprint=source.sprint,
                    md_path=source.md_path,
                    name_a=name_a,
                    name_b=name_b,
                    guard_type="state_prefix",
                    proposed_rule="R1",
                    state_a=cells[idx_sa],
                    state_b=cells[idx_sb],
                )
            )
    return rows


def parse_all_sources() -> list[GuardBlockedRow]:
    """Parse all SPRINT_SOURCES and return concatenated rows."""
    all_rows: list[GuardBlockedRow] = []
    for src in SPRINT_SOURCES:
        if not src.md_path.exists():
            logger.warning("Source not found: %s — skipping", src.md_path)
            continue
        text = src.md_path.read_text(encoding="utf-8")
        if src.parser == "h_combined":
            rows = _parse_h_combined_table(text, src)
        elif src.parser == "ij_per_type":
            rows = _parse_ij_per_type_tables(text, src)
        else:
            raise ValueError(f"unknown parser: {src.parser}")
        logger.info("Parsed %d rows from Sprint %s (%s)", len(rows), src.sprint, src.md_path.name)
        all_rows.extend(rows)
    return all_rows


# ---------------------------------------------------------------------------
# DB resolution
# ---------------------------------------------------------------------------


@dataclass
class ResolveStats:
    resolved: int = 0
    skipped_no_match: list[tuple[str, str]] = field(default_factory=list)  # (name, dynasty)
    fail_multi_match: list[tuple[str, str, int]] = field(
        default_factory=list
    )  # (name, dynasty, count)


async def _resolve_uuid(
    conn: asyncpg.Connection,
    name: str,
    dynasty: str | None,
    cache: dict[tuple[str, str | None], str | None],
    stats: ResolveStats,
) -> str | None:
    """Look up persons.id by (name, dynasty); cache results."""
    key = (name, dynasty)
    if key in cache:
        return cache[key]

    # persons.name is jsonb {"zh-Hans": "..."}; match by zh-Hans key.
    #
    # Strategy: try (name + dynasty) first for exactness. If zero match,
    # fall back to name-only — handles cases where:
    #   - markdown dynasty has display-bug transposition (Sprint J early rows)
    #   - DB dynasty was later corrected (e.g. Sprint J NER bug on 吕后/刘盈)
    # If name-only returns >1, fail-loud (real ambiguity).
    # If name-only returns 0, skip (truly soft-deleted, e.g. post-merge).
    rows = []
    if dynasty:
        rows = await conn.fetch(
            """
            SELECT id::text AS id
            FROM persons
            WHERE (name->>'zh-Hans') = $1
              AND dynasty = $2
              AND deleted_at IS NULL
            """,
            name,
            dynasty,
        )
    if not rows:
        rows = await conn.fetch(
            """
            SELECT id::text AS id
            FROM persons
            WHERE (name->>'zh-Hans') = $1
              AND deleted_at IS NULL
            """,
            name,
        )

    if len(rows) == 0:
        cache[key] = None
        stats.skipped_no_match.append((name, dynasty or ""))
        logger.warning("Person not found (likely soft-deleted): name=%s dynasty=%s", name, dynasty)
        return None
    if len(rows) > 1:
        cache[key] = None
        stats.fail_multi_match.append((name, dynasty or "", len(rows)))
        logger.error(
            "Multiple persons with same (name=%s, dynasty=%s); count=%d — fail-loud, fix data first",
            name,
            dynasty,
            len(rows),
        )
        return None
    person_id = rows[0]["id"]
    cache[key] = person_id
    stats.resolved += 1
    return person_id


async def resolve_all_uuids(pool: asyncpg.Pool, rows: list[GuardBlockedRow]) -> ResolveStats:
    """Populate person_a_id / person_b_id on each row in-place."""
    stats = ResolveStats()
    cache: dict[tuple[str, str | None], str | None] = {}
    async with pool.acquire() as conn:
        for r in rows:
            # state_prefix rows have no dynasty in markdown — fall back to name-only lookup
            r.person_a_id = await _resolve_uuid(conn, r.name_a, r.dynasty_a, cache, stats)
            r.person_b_id = await _resolve_uuid(conn, r.name_b, r.dynasty_b, cache, stats)
    return stats


# ---------------------------------------------------------------------------
# Pair-order normalisation + payload reconstruction
# ---------------------------------------------------------------------------


def _build_payload(row: GuardBlockedRow) -> dict[str, Any]:
    """Reconstruct guard_payload matching live r6_temporal_guards / state_prefix output."""
    if row.guard_type == "cross_dynasty":
        # Look up midpoints from yaml; fall back to None if missing
        periods = _get_dynasty_periods()
        period_a = periods.get(row.dynasty_a) if row.dynasty_a else None
        period_b = periods.get(row.dynasty_b) if row.dynasty_b else None
        midpoint_a = period_a.midpoint if period_a else None
        midpoint_b = period_b.midpoint if period_b else None
        # Threshold per rule: R1=200, R6=500. Backfill rows are all R1.
        threshold = 200 if row.proposed_rule == "R1" else 500
        return {
            "dynasty_a": row.dynasty_a,
            "dynasty_b": row.dynasty_b,
            "midpoint_a": midpoint_a,
            "midpoint_b": midpoint_b,
            "gap_years": row.gap_years,
            "threshold": threshold,
        }
    elif row.guard_type == "state_prefix":
        canonical_a = _resolve_canonical(row.state_a or "")
        canonical_b = _resolve_canonical(row.state_b or "")
        return {
            "state_a": canonical_a,
            "state_b": canonical_b,
            "raw_state_a": row.state_a,
            "raw_state_b": row.state_b,
            "name_a": row.name_a,
            "name_b": row.name_b,
        }
    raise ValueError(f"unknown guard_type: {row.guard_type}")


def _build_evidence(row: GuardBlockedRow) -> dict[str, Any]:
    """Backfill evidence: mark provenance as retroactive."""
    return {
        "_backfill": True,
        "_backfill_label": "retroactive-backfill, sprint-K-stage-2-prep",
        "source_md": str(row.md_path.relative_to(_REPO_ROOT)),
        "sprint": row.sprint,
    }


def normalise_pair(row: GuardBlockedRow) -> tuple[str, str, str, str, dict[str, Any]]:
    """Return (a_id, b_id, a_name, b_name, payload) with a_id < b_id (lex compare on UUID strings).

    Also swap *_a/*_b payload keys when names are swapped, mirroring the
    _swap_ab_payload helper in resolve.py.
    """
    a_id = row.person_a_id
    b_id = row.person_b_id
    assert a_id is not None and b_id is not None
    payload = _build_payload(row)
    if a_id < b_id:
        return a_id, b_id, row.name_a, row.name_b, payload
    # Swap
    swapped = dict(payload)
    for k_a, k_b in (
        ("dynasty_a", "dynasty_b"),
        ("midpoint_a", "midpoint_b"),
        ("state_a", "state_b"),
        ("raw_state_a", "raw_state_b"),
        ("name_a", "name_b"),
    ):
        if k_a in swapped and k_b in swapped:
            swapped[k_a], swapped[k_b] = swapped[k_b], swapped[k_a]
    return b_id, a_id, row.name_b, row.name_a, swapped


# ---------------------------------------------------------------------------
# Dedup
# ---------------------------------------------------------------------------


def dedup_rows(rows: list[GuardBlockedRow]) -> list[GuardBlockedRow]:
    """Drop duplicate (a_id, b_id, proposed_rule, guard_type) keeping first occurrence.

    First occurrence keeps the earliest sprint's evidence (Sprint H first per
    SPRINT_SOURCES order).
    """
    seen: set[tuple[str, str, str, str]] = set()
    out: list[GuardBlockedRow] = []
    for r in rows:
        if r.person_a_id is None or r.person_b_id is None:
            continue
        a, b = sorted([r.person_a_id, r.person_b_id])
        key = (a, b, r.proposed_rule, r.guard_type)
        if key in seen:
            continue
        seen.add(key)
        out.append(r)
    return out


# ---------------------------------------------------------------------------
# Apply
# ---------------------------------------------------------------------------


@dataclass
class ApplyStats:
    written: int = 0
    skipped_conflict: int = 0
    errors: list[str] = field(default_factory=list)


async def apply_inserts(pool: asyncpg.Pool, rows: list[GuardBlockedRow]) -> ApplyStats:
    """INSERT each row in its own transaction; ON CONFLICT DO NOTHING."""
    stats = ApplyStats()
    async with pool.acquire() as conn:
        for r in rows:
            try:
                a_id, b_id, _aname, _bname, payload = normalise_pair(r)
                evidence = _build_evidence(r)
                async with conn.transaction():
                    inserted = await conn.fetchval(
                        """
                        INSERT INTO pending_merge_reviews
                            (person_a_id, person_b_id, proposed_rule, guard_type,
                             guard_payload, evidence)
                        VALUES ($1::uuid, $2::uuid, $3, $4, $5::jsonb, $6::jsonb)
                        ON CONFLICT (person_a_id, person_b_id, proposed_rule, guard_type)
                            WHERE status = 'pending'
                        DO NOTHING
                        RETURNING id
                        """,
                        a_id,
                        b_id,
                        r.proposed_rule,
                        r.guard_type,
                        json.dumps(payload, ensure_ascii=False),
                        json.dumps(evidence, ensure_ascii=False),
                    )
                if inserted is None:
                    stats.skipped_conflict += 1
                else:
                    stats.written += 1
            except Exception as exc:  # noqa: BLE001
                msg = f"INSERT failed for {r.name_a} ↔ {r.name_b} ({r.guard_type}): {exc}"
                logger.error(msg)
                stats.errors.append(msg)
    return stats


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------


def render_summary(rows_resolved: list[GuardBlockedRow], stats: ResolveStats) -> str:
    by_guard: dict[str, int] = {}
    by_sprint: dict[str, int] = {}
    for r in rows_resolved:
        by_guard[r.guard_type] = by_guard.get(r.guard_type, 0) + 1
        by_sprint[r.sprint] = by_sprint.get(r.sprint, 0) + 1
    lines = [
        f"Total unique rows after dedup: {len(rows_resolved)}",
        "  by guard_type: " + ", ".join(f"{k}={v}" for k, v in sorted(by_guard.items())),
        "  by source sprint (first occurrence): "
        + ", ".join(f"{k}={v}" for k, v in sorted(by_sprint.items())),
        f"Resolved UUIDs: {stats.resolved}",
        f"Skipped (no match in persons): {len(stats.skipped_no_match)}",
        f"Fail-loud (multi-match): {len(stats.fail_multi_match)}",
    ]
    if stats.skipped_no_match:
        lines.append("  no-match samples (max 5):")
        for n, d in stats.skipped_no_match[:5]:
            lines.append(f"    - name={n!r}, dynasty={d!r}")
    if stats.fail_multi_match:
        lines.append("  multi-match samples (max 5):")
        for n, d, c in stats.fail_multi_match[:5]:
            lines.append(f"    - name={n!r}, dynasty={d!r}, count={c}")
    return "\n".join(lines)


def render_sample(rows: list[GuardBlockedRow], n: int = 5) -> str:
    out: list[str] = []
    for r in rows[:n]:
        a_id, b_id, aname, bname, payload = normalise_pair(r)
        evidence = _build_evidence(r)
        out.append(
            f"  - {aname} ({a_id[:8]}…) ↔ {bname} ({b_id[:8]}…) "
            f"| guard={r.guard_type} rule={r.proposed_rule} sprint={r.sprint}\n"
            f"    payload: {json.dumps(payload, ensure_ascii=False)}\n"
            f"    evidence: {json.dumps(evidence, ensure_ascii=False)}"
        )
    return "\n".join(out)


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------


async def amain(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument(
        "--dry-run",
        action="store_true",
        default=True,
        help="Parse + resolve UUIDs + print sample; no DB writes (default).",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="INSERT rows to pending_merge_reviews (overrides --dry-run).",
    )
    parser.add_argument(
        "--sample-size",
        type=int,
        default=5,
        help="Number of sample rows to print in summary (default 5).",
    )
    args = parser.parse_args(argv)
    apply_mode = bool(args.apply)

    logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")

    rows_raw = parse_all_sources()
    if not rows_raw:
        print("No rows parsed; aborting.", file=sys.stderr)
        return 2

    db_url = os.environ.get(
        "DATABASE_URL",
        "postgresql://huadian:huadian_dev@localhost:5433/huadian",
    )
    pool = await asyncpg.create_pool(db_url, min_size=1, max_size=2)
    assert pool is not None

    try:
        resolve_stats = await resolve_all_uuids(pool, rows_raw)
        if resolve_stats.fail_multi_match:
            print(
                "ERROR: multi-match person rows detected; aborting before apply.",
                file=sys.stderr,
            )
            print(render_summary(rows_raw, resolve_stats), file=sys.stderr)
            return 3

        rows_dedup = dedup_rows(rows_raw)

        print("=" * 72)
        print(f"backfill_pending_merge_reviews — mode={'APPLY' if apply_mode else 'DRY-RUN'}")
        print("=" * 72)
        print(f"Parsed rows (pre-dedup): {len(rows_raw)}")
        print(render_summary(rows_dedup, resolve_stats))
        print()
        print(f"Sample (first {args.sample_size}):")
        print(render_sample(rows_dedup, args.sample_size))
        print()

        if not apply_mode:
            print("[DRY-RUN] No DB writes performed. Re-run with --apply to commit.")
            return 0

        print("[APPLY] Inserting rows…")
        apply_stats = await apply_inserts(pool, rows_dedup)
        print(f"  written:           {apply_stats.written}")
        print(f"  skipped_conflict:  {apply_stats.skipped_conflict}")
        print(f"  errors:            {len(apply_stats.errors)}")
        if apply_stats.errors:
            for e in apply_stats.errors:
                print(f"    - {e}")
        return 0 if not apply_stats.errors else 1
    finally:
        await pool.close()


def main() -> int:
    return asyncio.run(amain(sys.argv[1:]))


if __name__ == "__main__":
    raise SystemExit(main())
