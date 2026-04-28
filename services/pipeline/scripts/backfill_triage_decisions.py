"""Sprint K Stage 2 prep: backfill triage_decisions from G/H/I/J historian-review markdown.

Why
---
T-P0-028 hint banner feature requires historical decisions queryable per
``surface_snapshot``. Historians have made ~80-100 rulings across
Sprint G/H/I/J that live only in markdown files. This script parses those
rulings and INSERTs them into ``triage_decisions`` so the UI can surface
"周成王 reject 3 times" cross-sprint context.

Sources
-------
- docs/sprint-logs/T-P0-006-gamma/historian-review-2026-04-25.md
    Sprint γ (秦本纪) — 35 rulings, sprint label "γ", commit ``3280a35``
- docs/sprint-logs/T-P0-006-delta/historian-review-2026-04-25.md
    Sprint δ (项羽本纪) — 21 rulings, sprint label "δ", commit ``fdfb7cb``
- docs/sprint-logs/sprint-j/historian-review-2026-04-28.md
    Sprint ε (高祖本纪) — 23 rulings, sprint label "ε", commit ``07db893``

Sprint H ``historian-chu-huai-wang-mentions-*.md`` is intentionally
excluded — it is a mention-bucketing ruling not a Group-N merge ruling
and does not fit the schema ``(decision, surface_snapshot)`` shape.
Its context is referenced via Sprint γ / δ / ε rulings that touch the
楚怀王 cluster (G7 in Sprint J, etc.).

Format
------
Each ruling block matches ::

    ### Group N — <approve|reject|split>

    | 字段 | 值 |
    |------|-----|
    | Merge | <name_a> → <name_b>  or  <name_a> ↔ <name_b> ↔ <name_c> |
    | 裁决 | **<decision>** |
    | source_type | in_chapter, scholarly |
    | 证据 | ... |
    | 理由 | ... |

Decision mapping (ADR-027 enum is approve/reject/defer):
    historian "approve" → 'approve'
    historian "reject"  → 'reject'
    historian "split"   → 'defer'   (split = "leave entities independent, sub-merges separate")

Per-ruling row expansion:
    For a merge group with N surfaces, generate N triage_decision rows
    (one per surface). This keeps surface_snapshot indexable for hint
    banner queries (``WHERE surface_snapshot = '周成王'``).

Source ID resolution
--------------------
``triage_decisions.source_table`` ∈ {'seed_mappings', 'pending_merge_reviews'};
historian-review rulings always tag source_table='pending_merge_reviews'.

For source_id:
- If the ruling pair (name_a, name_b) matches an actual row in
  ``pending_merge_reviews`` (post-PMR-backfill), use that row's UUID.
  ``notes = 'historical-backfill, source_id from backfill_pending_merge_reviews'``.
- Otherwise, synthesise a stable UUID via ``uuid5(NAMESPACE_OID, f"{sprint}-{group_id}-{surface}")``.
  ``notes = 'historical-backfill, synthetic source_id (no underlying DB row, ruling from sprint dry-run)'``.

The synthetic-UUID approach is sanctioned by ADR-027 §3 source_id COMMENT:
"Logical FK to source_table.id; not enforced via SQL FK due to backfill
cross-table complexity. Application layer ensures integrity."

Dedup
-----
``triage_decisions`` schema permits multi-row audit (no unique constraint
on source_id) — defer → revisit → approve sequence allowed. This script's
own dedup key is ``(sprint, group_id, surface)`` to prevent double-INSERT
on re-run; existing rows with same (synthetic) source_id are detected via
SELECT then skipped.

Modes
-----
--dry-run (default)
    Parse + render summary + sample; no DB writes.
--apply
    Per-row transaction INSERT.

Pre-flight: this script ASSUMES ``triage_decisions`` table exists
(migration 0014 applied by BE) AND ``backfill_pending_merge_reviews.py``
has run successfully so guard-blocked PMR rows can be joined. If PMR is
empty, all rulings get synthetic source_id.

Usage
-----
    cd services/pipeline
    uv run python scripts/backfill_triage_decisions.py --dry-run
    uv run python scripts/backfill_triage_decisions.py --apply
"""

from __future__ import annotations

import argparse
import asyncio
import logging
import os
import re
import sys
import uuid
from dataclasses import dataclass, field
from pathlib import Path

import asyncpg

logger = logging.getLogger("backfill_td")


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

_REPO_ROOT = Path(__file__).resolve().parents[3]

# A stable namespace UUID for synthesising source_id values. Use uuid5
# rather than uuid4 so re-runs are idempotent (per ACK D2 + ADR-017
# forward-only spirit).
TRIAGE_BACKFILL_NAMESPACE = uuid.UUID("9d4f1c3e-7a2b-4e6d-b1f8-3c5a8e7d2f01")

DECISION_MAP = {
    "approve": "approve",
    "reject": "reject",
    "split": "defer",
}

# Allowlisted reason_source_type values per ADR-027 §3.
VALID_SOURCE_TYPES = {
    "in_chapter",
    "other_classical",
    "wikidata",
    "scholarly",
    "structural",
    "historical-backfill",
}

NOTES_REAL = "historical-backfill, source_id from backfill_pending_merge_reviews"
NOTES_SYNTHETIC = (
    "historical-backfill, synthetic source_id (no underlying DB row, ruling from sprint dry-run)"
)


@dataclass(frozen=True)
class HistorianSource:
    sprint_label: str  # "γ" | "δ" | "ε"
    md_path: Path
    historian_commit_ref: str  # short commit hash


HISTORIAN_SOURCES: tuple[HistorianSource, ...] = (
    HistorianSource(
        sprint_label="γ",
        md_path=_REPO_ROOT / "docs/sprint-logs/T-P0-006-gamma/historian-review-2026-04-25.md",
        historian_commit_ref="3280a35",
    ),
    HistorianSource(
        sprint_label="δ",
        md_path=_REPO_ROOT / "docs/sprint-logs/T-P0-006-delta/historian-review-2026-04-25.md",
        historian_commit_ref="fdfb7cb",
    ),
    HistorianSource(
        sprint_label="ε",
        md_path=_REPO_ROOT / "docs/sprint-logs/sprint-j/historian-review-2026-04-28.md",
        historian_commit_ref="07db893",
    ),
)


# ---------------------------------------------------------------------------
# Parsed dataclasses
# ---------------------------------------------------------------------------


@dataclass
class RawRuling:
    sprint_label: str
    group_id: str  # e.g. "G2" (raw from heading; combined with sprint elsewhere)
    decision_md: str  # raw "approve" | "reject" | "split"
    surfaces: list[str]  # extracted from Merge field
    reason_source_type: str | None
    reason_text: str | None
    md_path: Path
    historian_commit_ref: str

    @property
    def composite_id(self) -> str:
        return f"{self.sprint_label}-{self.group_id}"


@dataclass
class TriageDecisionRow:
    """One triage_decisions INSERT candidate."""

    source_table: str  # always 'pending_merge_reviews' for historian-review backfill
    source_id: str  # uuid (real PMR UUID or synthetic uuid5)
    surface_snapshot: str
    decision: str  # 'approve' | 'reject' | 'defer'
    reason_text: str | None
    reason_source_type: str | None
    historian_id: str  # 'historical-backfill'
    historian_commit_ref: str
    decided_at: str | None  # ISO timestamp; None → DB default now()
    notes: str
    # Diagnostic fields (not written; for reporting)
    sprint_label: str = ""
    group_id: str = ""
    is_synthetic: bool = True


# ---------------------------------------------------------------------------
# Markdown parsing
# ---------------------------------------------------------------------------


_GROUP_HEADER_RE = re.compile(
    r"^####?\s+Group\s+(\S+?)\s*—\s*(approve|reject|split)\b", re.IGNORECASE
)
_TABLE_ROW_RE = re.compile(r"^\s*\|\s*([^|]+?)\s*\|\s*(.+?)\s*\|\s*$")
_TABLE_SEP_RE = re.compile(r"^\s*\|[\s\-:|]+\|\s*$")


def _split_block_at_next_section(lines: list[str], start: int) -> tuple[int, int]:
    """Return (start, end_exclusive) for the block starting at ``start``.

    A block ends at the next ``### ``/``## ``/``# `` heading or EOF.
    """
    end = len(lines)
    for i in range(start + 1, len(lines)):
        line = lines[i]
        if (
            line.startswith("### ")
            or line.startswith("#### ")
            or line.startswith("## ")
            or line.startswith("# ")
        ):
            end = i
            break
    return start, end


def _extract_table_field(block: list[str], field_name: str) -> str | None:
    """Find the first table row whose first cell contains ``field_name``.

    Returns the second cell's content, or None if not found.
    """
    for line in block:
        m = _TABLE_ROW_RE.match(line)
        if not m:
            continue
        if _TABLE_SEP_RE.match(line):
            continue
        key, val = m.group(1).strip(), m.group(2).strip()
        if field_name in key:
            return val
    return None


def _strip_md_emphasis(s: str) -> str:
    """Strip ``**text**``, ``*text*``, backticks, and brackets/parens content
    that is markdown formatting noise."""
    s = re.sub(r"\*\*(.+?)\*\*", r"\1", s)
    s = re.sub(r"\*(.+?)\*", r"\1", s)
    s = re.sub(r"`([^`]+)`", r"\1", s)
    return s.strip()


def _extract_surfaces(merge_field: str) -> list[str]:
    """Extract person surfaces from a ``Merge`` field value.

    Handles formats like::

        名A → 名B
        名A + 名B → 名C            (Sprint γ G6: "缪公 + 秦缪公 → 秦穆公")
        名A ↔ 名B ↔ 名C
        名A ↔ 名B (字方向)         (Sprint J prose annotations)

    Strategy: split on any of {↔, →, +} and filter the resulting tokens
    by stripping markdown noise + parenthetical descriptions.
    """
    raw = _strip_md_emphasis(merge_field)
    # Drop trailing parenthetical descriptions and slug annotations
    tokens = re.split(r"\s*[↔→+]\s*", raw)
    out: list[str] = []
    for tok in tokens:
        # Drop ``(slug=...)`` and ``(字方向)`` style annotations attached to a name
        cleaned = re.sub(r"\([^)]*\)", "", tok).strip()
        # Drop trailing roman/colour markers
        cleaned = cleaned.strip("*_`「」 ")
        if not cleaned:
            continue
        # Skip overly-long tokens (likely commentary, not a name)
        if len(cleaned) > 12:
            continue
        out.append(cleaned)
    # Dedup while preserving order
    seen: set[str] = set()
    deduped: list[str] = []
    for n in out:
        if n in seen:
            continue
        seen.add(n)
        deduped.append(n)
    return deduped


def _extract_source_type(raw: str) -> str | None:
    """Take the first allowlisted token from a comma-separated source_type cell."""
    if not raw:
        return None
    raw = _strip_md_emphasis(raw)
    parts = re.split(r"[,，、]\s*", raw)
    for p in parts:
        token = p.strip().lower()
        if token in VALID_SOURCE_TYPES:
            return token
    return None


def _extract_reason(block: list[str]) -> str | None:
    """Concatenate ``理由`` then ``证据`` cell text, truncated to ~500 chars."""
    parts: list[str] = []
    for field_name in ("理由", "证据"):
        val = _extract_table_field(block, field_name)
        if val:
            parts.append(_strip_md_emphasis(val))
    if not parts:
        return None
    text = " | ".join(parts)
    if len(text) > 500:
        text = text[:497] + "…"
    return text


def parse_one_md(source: HistorianSource) -> list[RawRuling]:
    """Parse one historian-review markdown into RawRuling list."""
    if not source.md_path.exists():
        logger.warning("Source not found: %s", source.md_path)
        return []
    text = source.md_path.read_text(encoding="utf-8")
    lines = text.splitlines()

    rulings: list[RawRuling] = []
    i = 0
    while i < len(lines):
        m = _GROUP_HEADER_RE.match(lines[i])
        if not m:
            i += 1
            continue
        group_id = "G" + m.group(1).lstrip("G")  # normalise to "GN"
        decision_md = m.group(2).lower()
        block_start, block_end = _split_block_at_next_section(lines, i)
        block = lines[block_start:block_end]

        merge_field = _extract_table_field(block, "Merge")
        surfaces = _extract_surfaces(merge_field) if merge_field else []
        source_type_raw = _extract_table_field(block, "source_type")
        reason_source_type = _extract_source_type(source_type_raw or "")
        reason_text = _extract_reason(block)

        if not surfaces:
            logger.warning(
                "Ruling %s-%s has no extractable surfaces (Merge=%r) — fail-loud, "
                "review markdown format",
                source.sprint_label,
                group_id,
                merge_field,
            )
            # Fail-loud per S2.3 spec: do NOT silently skip.
            raise ValueError(
                f"Cannot extract surfaces for ruling {source.sprint_label}-{group_id} "
                f"in {source.md_path.name}; Merge field={merge_field!r}"
            )

        rulings.append(
            RawRuling(
                sprint_label=source.sprint_label,
                group_id=group_id,
                decision_md=decision_md,
                surfaces=surfaces,
                reason_source_type=reason_source_type,
                reason_text=reason_text,
                md_path=source.md_path,
                historian_commit_ref=source.historian_commit_ref,
            )
        )
        i = block_end
    return rulings


def parse_all_rulings() -> list[RawRuling]:
    out: list[RawRuling] = []
    for src in HISTORIAN_SOURCES:
        rulings = parse_one_md(src)
        logger.info(
            "Parsed %d rulings from Sprint %s (%s)",
            len(rulings),
            src.sprint_label,
            src.md_path.name,
        )
        out.extend(rulings)
    return out


# ---------------------------------------------------------------------------
# Source ID resolution: try real PMR UUID, else synthetic uuid5
# ---------------------------------------------------------------------------


def _synthesize_source_id(sprint_label: str, group_id: str, surface: str) -> str:
    """Stable uuid5 from (sprint, group, surface) to ensure idempotent re-runs."""
    name = f"{sprint_label}-{group_id}-{surface}"
    return str(uuid.uuid5(TRIAGE_BACKFILL_NAMESPACE, name))


async def _resolve_pmr_uuid_for_pair(
    conn: asyncpg.Connection,
    surface_a: str,
    surface_b: str,
) -> str | None:
    """Try to find a pending_merge_reviews row matching the (a, b) name pair.

    Match strategy: JOIN persons twice via name->>'zh-Hans' on either column
    order. Returns row id::text or None.
    """
    rows = await conn.fetch(
        """
        SELECT pmr.id::text AS id
        FROM pending_merge_reviews pmr
        JOIN persons pa ON pa.id = pmr.person_a_id
        JOIN persons pb ON pb.id = pmr.person_b_id
        WHERE (
            ((pa.name->>'zh-Hans') = $1 AND (pb.name->>'zh-Hans') = $2) OR
            ((pa.name->>'zh-Hans') = $2 AND (pb.name->>'zh-Hans') = $1)
        )
        AND pmr.status = 'pending'
        LIMIT 1
        """,
        surface_a,
        surface_b,
    )
    return rows[0]["id"] if rows else None


async def expand_to_decision_rows(
    pool: asyncpg.Pool,
    rulings: list[RawRuling],
) -> list[TriageDecisionRow]:
    """Expand each ruling into N triage_decision rows (one per surface).

    Real source_id resolution rules (per ACK D2 + notes detail):
    - If exactly 2 surfaces in the ruling AND a pending_merge_reviews row
      exists for that pair → use real PMR UUID for ALL N rows; notes=NOTES_REAL.
    - Otherwise → all rows get synthetic uuid5 source_id; notes=NOTES_SYNTHETIC.

    Note: with 3+ surface rulings (e.g. Sprint γ G16 五成员 split), no single
    PMR row covers them all → fall through to synthetic. This is correct
    semantics (the ruling is broader than any one PMR pair).
    """
    out: list[TriageDecisionRow] = []
    async with pool.acquire() as conn:
        for r in rulings:
            real_pmr_id: str | None = None
            if len(r.surfaces) == 2:
                real_pmr_id = await _resolve_pmr_uuid_for_pair(conn, r.surfaces[0], r.surfaces[1])

            for surface in r.surfaces:
                decision = DECISION_MAP[r.decision_md]
                if real_pmr_id is not None:
                    src_id = real_pmr_id
                    notes = NOTES_REAL
                    is_synth = False
                else:
                    src_id = _synthesize_source_id(r.sprint_label, r.group_id, surface)
                    notes = NOTES_SYNTHETIC
                    is_synth = True
                out.append(
                    TriageDecisionRow(
                        source_table="pending_merge_reviews",
                        source_id=src_id,
                        surface_snapshot=surface,
                        decision=decision,
                        reason_text=r.reason_text,
                        reason_source_type=r.reason_source_type,
                        historian_id="historical-backfill",
                        historian_commit_ref=r.historian_commit_ref,
                        decided_at=None,  # use DB now() default; we don't have per-ruling timestamps
                        notes=notes,
                        sprint_label=r.sprint_label,
                        group_id=r.group_id,
                        is_synthetic=is_synth,
                    )
                )
    return out


# ---------------------------------------------------------------------------
# Apply
# ---------------------------------------------------------------------------


@dataclass
class TDApplyStats:
    written: int = 0
    skipped_existing: int = 0
    errors: list[str] = field(default_factory=list)


async def apply_inserts(pool: asyncpg.Pool, rows: list[TriageDecisionRow]) -> TDApplyStats:
    """INSERT each row in own transaction.

    Idempotency: triage_decisions has no unique constraint on synthetic
    source_id, so a SELECT pre-check by (source_id, surface_snapshot, historian_id)
    is used to avoid double-writes on re-run.
    """
    stats = TDApplyStats()
    async with pool.acquire() as conn:
        for r in rows:
            try:
                async with conn.transaction():
                    # Pre-check for idempotency
                    existing = await conn.fetchval(
                        """
                        SELECT id FROM triage_decisions
                        WHERE source_id = $1::uuid
                          AND surface_snapshot = $2
                          AND historian_id = $3
                        LIMIT 1
                        """,
                        r.source_id,
                        r.surface_snapshot,
                        r.historian_id,
                    )
                    if existing is not None:
                        stats.skipped_existing += 1
                        continue
                    await conn.execute(
                        """
                        INSERT INTO triage_decisions
                            (source_table, source_id, surface_snapshot,
                             decision, reason_text, reason_source_type,
                             historian_id, historian_commit_ref, notes)
                        VALUES ($1, $2::uuid, $3, $4, $5, $6, $7, $8, $9)
                        """,
                        r.source_table,
                        r.source_id,
                        r.surface_snapshot,
                        r.decision,
                        r.reason_text,
                        r.reason_source_type,
                        r.historian_id,
                        r.historian_commit_ref,
                        r.notes,
                    )
                    stats.written += 1
            except Exception as exc:  # noqa: BLE001
                msg = (
                    f"INSERT failed for {r.sprint_label}-{r.group_id} "
                    f"surface={r.surface_snapshot!r}: {exc}"
                )
                logger.error(msg)
                stats.errors.append(msg)
    return stats


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------


def render_summary(rulings: list[RawRuling], rows: list[TriageDecisionRow]) -> str:
    by_sprint: dict[str, int] = {}
    by_decision: dict[str, int] = {}
    real_count = sum(1 for r in rows if not r.is_synthetic)
    synth_count = sum(1 for r in rows if r.is_synthetic)
    for r in rulings:
        by_sprint[r.sprint_label] = by_sprint.get(r.sprint_label, 0) + 1
    for r in rows:
        by_decision[r.decision] = by_decision.get(r.decision, 0) + 1
    lines = [
        f"Parsed rulings: {len(rulings)}",
        "  by sprint: " + ", ".join(f"{k}={v}" for k, v in sorted(by_sprint.items())),
        f"Expanded triage_decision rows: {len(rows)}",
        "  by decision: " + ", ".join(f"{k}={v}" for k, v in sorted(by_decision.items())),
        f"  with real PMR source_id: {real_count}",
        f"  with synthetic source_id: {synth_count}",
    ]
    return "\n".join(lines)


def render_sample(rows: list[TriageDecisionRow], n: int = 5) -> str:
    out: list[str] = []
    # Pick a mix without duplicates: walk through and take first 2 real + first 3 synth
    real_pick: list[TriageDecisionRow] = []
    synth_pick: list[TriageDecisionRow] = []
    for r in rows:
        if not r.is_synthetic and len(real_pick) < 2:
            real_pick.append(r)
        elif r.is_synthetic and len(synth_pick) < 3:
            synth_pick.append(r)
        if len(real_pick) >= 2 and len(synth_pick) >= 3:
            break
    sample = real_pick + synth_pick
    # Top up if still short (e.g. zero real rows in dry-run)
    if len(sample) < n:
        for r in rows:
            if r in sample:
                continue
            sample.append(r)
            if len(sample) >= n:
                break
    sample = sample[:n]
    for r in sample:
        marker = "REAL" if not r.is_synthetic else "SYNTH"
        out.append(
            f"  - [{marker}] {r.sprint_label}-{r.group_id} surface={r.surface_snapshot!r} "
            f"decision={r.decision} src_type={r.reason_source_type} "
            f"commit={r.historian_commit_ref}\n"
            f"    source_id: {r.source_id}\n"
            f"    notes: {r.notes}\n"
            f"    reason: {(r.reason_text or '')[:120]!r}"
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
        help="Parse + render summary; no DB writes (default).",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="INSERT rows to triage_decisions (overrides --dry-run).",
    )
    parser.add_argument(
        "--sample-size",
        type=int,
        default=5,
        help="Number of sample rows to print (default 5).",
    )
    args = parser.parse_args(argv)
    apply_mode = bool(args.apply)

    logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")

    rulings = parse_all_rulings()
    if not rulings:
        print("No rulings parsed; aborting.", file=sys.stderr)
        return 2

    db_url = os.environ.get(
        "DATABASE_URL",
        "postgresql://huadian:huadian_dev@localhost:5433/huadian",
    )
    pool = await asyncpg.create_pool(db_url, min_size=1, max_size=2)
    assert pool is not None

    try:
        rows = await expand_to_decision_rows(pool, rulings)

        print("=" * 72)
        print(f"backfill_triage_decisions — mode={'APPLY' if apply_mode else 'DRY-RUN'}")
        print("=" * 72)
        print(render_summary(rulings, rows))
        print()
        print(f"Sample (first {args.sample_size}, mixed real/synthetic):")
        print(render_sample(rows, args.sample_size))
        print()

        if not apply_mode:
            print("[DRY-RUN] No DB writes performed. Re-run with --apply to commit.")
            print(
                "Note: --apply requires triage_decisions table to exist "
                "(BE migration 0014) AND backfill_pending_merge_reviews.py "
                "to have been --apply'd (so guard-blocked rulings get real source_id)."
            )
            return 0

        # --apply requires migration 0014 + PMR backfill
        async with pool.acquire() as conn:
            tbl_exists = await conn.fetchval(
                "SELECT to_regclass('public.triage_decisions') IS NOT NULL"
            )
        if not tbl_exists:
            print(
                "ERROR: triage_decisions table does not exist. Apply BE migration 0014 first.",
                file=sys.stderr,
            )
            return 4

        print("[APPLY] Inserting rows…")
        apply_stats = await apply_inserts(pool, rows)
        print(f"  written:          {apply_stats.written}")
        print(f"  skipped_existing: {apply_stats.skipped_existing}")
        print(f"  errors:           {len(apply_stats.errors)}")
        if apply_stats.errors:
            for e in apply_stats.errors[:10]:
                print(f"    - {e}")
        return 0 if not apply_stats.errors else 1
    finally:
        await pool.close()


def main() -> int:
    return asyncio.run(amain(sys.argv[1:]))


if __name__ == "__main__":
    raise SystemExit(main())
