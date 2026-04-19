"""Load module — writes extracted persons to DB.

Handles:
  1. Deduplicate persons across chunks (merge by name_zh)
  2. Generate slugs from name (via slug module, ADR-011)
  3. Upsert into persons / person_names tables
"""

from __future__ import annotations

import logging
import uuid
from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    import asyncpg

from .enums import ProvenanceTier
from .extract import ExtractedPerson, SurfaceForm
from .resolve_rules import is_di_honorific
from .slug import generate_slug

logger = logging.getLogger(__name__)

# Deictic pronouns / generic honorifics that should never appear as
# person surface_forms. If NER leaks them, they poison identity_resolver
# R1 matching (e.g. '帝' would match both 尧 and 舜 → false merge).
_PRONOUN_BLACKLIST: frozenset[str] = frozenset(
    {
        "帝",
        "王",
        "后",
        "公",
        "君",
        "主",
        "上",
        "天子",
    }
)


@dataclass(slots=True)
class MergedPerson:
    """A person merged from multiple chunk extractions."""

    name_zh: str
    slug: str
    surface_forms: list[SurfaceForm]
    dynasty: str
    reality_status: str
    briefs: list[str]
    identity_notes: list[str]
    confidence: float
    chunk_ids: list[str]
    paragraph_nos: list[int]
    llm_call_ids: list[str] = field(default_factory=list)


@dataclass(slots=True)
class LoadResult:
    """Result of loading persons into DB."""

    persons_inserted: int = 0
    persons_updated: int = 0
    names_inserted: int = 0
    total_merged: int = 0
    errors: list[str] = field(default_factory=list)


def merge_persons(persons: list[ExtractedPerson]) -> list[MergedPerson]:
    """Merge extracted persons by name_zh across all chunks."""
    by_name: dict[str, MergedPerson] = {}

    for p in persons:
        key = p.name_zh.strip()
        if not key:
            continue

        if key in by_name:
            existing = by_name[key]
            # Merge surface forms (dedup by text)
            existing_texts = {sf.text for sf in existing.surface_forms}
            for sf in p.surface_forms:
                if sf.text not in existing_texts:
                    existing.surface_forms.append(sf)
                    existing_texts.add(sf.text)
            # Merge briefs
            if p.brief and p.brief not in existing.briefs:
                existing.briefs.append(p.brief)
            # Merge identity_notes
            if p.identity_notes and p.identity_notes not in existing.identity_notes:
                existing.identity_notes.append(p.identity_notes)
            # Update confidence (take max)
            existing.confidence = max(existing.confidence, p.confidence)
            # Track chunks + call_ids
            if p.chunk_id not in existing.chunk_ids:
                existing.chunk_ids.append(p.chunk_id)
            if p.chunk_paragraph_no not in existing.paragraph_nos:
                existing.paragraph_nos.append(p.chunk_paragraph_no)
            if p.llm_call_id and p.llm_call_id not in existing.llm_call_ids:
                existing.llm_call_ids.append(p.llm_call_id)
            # Prefer more specific dynasty/reality_status
            if p.dynasty and (not existing.dynasty or existing.dynasty == "上古"):
                existing.dynasty = p.dynasty
            if p.reality_status != "uncertain":
                existing.reality_status = p.reality_status
        else:
            by_name[key] = MergedPerson(
                name_zh=key,
                slug=generate_slug(key),
                surface_forms=list(p.surface_forms),
                dynasty=p.dynasty,
                reality_status=p.reality_status,
                identity_notes=[p.identity_notes] if p.identity_notes else [],
                briefs=[p.brief] if p.brief else [],
                confidence=p.confidence,
                chunk_ids=[p.chunk_id],
                paragraph_nos=[p.chunk_paragraph_no],
                llm_call_ids=[p.llm_call_id] if p.llm_call_id else [],
            )

    return list(by_name.values())


async def load_persons(
    pool: asyncpg.Pool,
    persons: list[MergedPerson],
    *,
    book_id: str,
    prompt_version: str = "",
) -> LoadResult:
    """Load merged persons into the database.

    Upserts into persons table by slug, inserts person_names.
    Each person is wrapped in its own transaction for failure isolation.
    """
    result = LoadResult(total_merged=len(persons))

    async with pool.acquire() as conn:
        for person in persons:
            try:
                async with conn.transaction():
                    person_id, is_new = await _upsert_person(conn, person)
                    names_added = await _insert_person_names(
                        conn,
                        person_id,
                        person,
                        book_id=book_id,
                        prompt_version=prompt_version,
                        llm_call_ids=person.llm_call_ids,
                    )
                # Transaction committed — safe to count
                if is_new:
                    result.persons_inserted += 1
                else:
                    result.persons_updated += 1
                result.names_inserted += names_added
            except Exception as e:
                msg = f"Failed to load person {person.name_zh}: {e}"
                logger.error(msg, exc_info=True)
                result.errors.append(msg)

    logger.info(
        "Loaded %d persons (%d new, %d updated), %d names, %d errors",
        result.total_merged,
        result.persons_inserted,
        result.persons_updated,
        result.names_inserted,
        len(result.errors),
    )
    return result


async def _upsert_person(
    conn: Any,
    person: MergedPerson,
) -> tuple[str, bool]:
    """Upsert a person by slug. Returns (person_id, is_new)."""
    import json

    # Check if exists
    existing = await conn.fetchrow(
        "SELECT id FROM persons WHERE slug = $1 AND deleted_at IS NULL",
        person.slug,
    )

    if existing:
        person_id = str(existing["id"])
        # Update biography with new briefs
        biography = {"zh-Hans": " ".join(person.briefs)} if person.briefs else None
        if biography:
            await conn.execute(
                """
                UPDATE persons SET biography = $2::jsonb, updated_at = NOW()
                WHERE id = $1
                """,
                person_id,
                json.dumps(biography, ensure_ascii=False),
            )
        return person_id, False

    person_id = str(uuid.uuid4())
    name_json = json.dumps({"zh-Hans": person.name_zh}, ensure_ascii=False)
    biography_json = (
        json.dumps({"zh-Hans": " ".join(person.briefs)}, ensure_ascii=False)
        if person.briefs
        else None
    )

    await conn.execute(
        """
        INSERT INTO persons (id, slug, name, dynasty, reality_status, provenance_tier, biography)
        VALUES ($1, $2, $3::jsonb, $4, $5::reality_status, $6, $7::jsonb)
        """,
        person_id,
        person.slug,
        name_json,
        person.dynasty or None,
        person.reality_status,
        ProvenanceTier.AI_INFERRED.value,
        biography_json,
    )
    return person_id, True


def _filter_pronoun_surfaces(
    person: MergedPerson,
) -> list[SurfaceForm]:
    """Remove deictic pronoun / generic honorific surface_forms.

    Returns a filtered list of surface_forms. If ALL surfaces are
    filtered out, returns an empty list — caller should skip this person.

    Rules:
      1. Single-char surface in _PRONOUN_BLACKLIST → remove
      2. Multi-char surface == "天子" → remove
      3. Other multi-char surfaces are kept even if they contain a
         blacklisted char (e.g. "帝尧" is fine, "帝" alone is not)
    """
    filtered = [sf for sf in person.surface_forms if sf.text not in _PRONOUN_BLACKLIST]
    removed = len(person.surface_forms) - len(filtered)
    if removed > 0:
        removed_texts = [sf.text for sf in person.surface_forms if sf.text in _PRONOUN_BLACKLIST]
        logger.warning(
            "Pronoun filter: person %r — removed %d pronoun surface(s) %s",
            person.name_zh,
            removed,
            removed_texts,
        )
    return filtered


def _enforce_single_primary(
    person: MergedPerson,
) -> list[SurfaceForm]:
    """Validate and enforce single-primary invariant on surface_forms.

    Returns a new list with at most one name_type='primary'.
    Logs warnings when corrections are applied.

    Cases:
      1. Exactly 1 primary → pass through (no change)
      2. >1 primary → keep the one matching name_zh (or shortest), demote rest
      3. 0 primary + name_zh match exists → promote it
      4. 0 primary + no name_zh match → promote shortest + WARNING
    """
    primaries = [sf for sf in person.surface_forms if sf.name_type == "primary"]

    if len(primaries) == 1:
        return list(person.surface_forms)

    name_zh = person.name_zh
    forms = list(person.surface_forms)

    if len(primaries) > 1:
        # Pick winner: prefer name_zh match, then non-帝X, then shortest
        winner: SurfaceForm | None = None
        for sf in primaries:
            if sf.text == name_zh:
                winner = sf
                break
        if winner is None:
            non_di = [sf for sf in primaries if not is_di_honorific(sf.text)]
            candidates = non_di if non_di else primaries
            winner = min(candidates, key=lambda sf: (len(sf.text), sf.text))

        demoted_names = [sf.text for sf in primaries if sf is not winner]
        logger.warning(
            "T-P1-004 auto-demotion: person %r had %d primaries %s; "
            "keeping %r, demoting %s to alias",
            name_zh,
            len(primaries),
            [sf.text for sf in primaries],
            winner.text,
            demoted_names,
        )
        forms = [
            SurfaceForm(text=sf.text, name_type="alias")
            if sf.name_type == "primary" and sf is not winner
            else sf
            for sf in forms
        ]
        return forms

    # 0 primaries — need to promote one
    name_zh_match = next((sf for sf in forms if sf.text == name_zh), None)
    if name_zh_match is not None:
        logger.warning(
            "T-P1-004 auto-promotion: person %r had 0 primaries; "
            "promoting name_zh match %r to primary",
            name_zh,
            name_zh_match.text,
        )
        return [
            SurfaceForm(text=sf.text, name_type="primary") if sf is name_zh_match else sf
            for sf in forms
        ]

    # 0 primaries + no name_zh match → promote shortest (WARNING-level)
    shortest = min(forms, key=lambda sf: (len(sf.text), sf.text))
    logger.warning(
        "T-P1-004 CRITICAL auto-promotion: person %r had 0 primaries "
        "and no name_zh match; promoting shortest %r to primary. "
        "This indicates NER quality degradation — investigate prompt.",
        name_zh,
        shortest.text,
    )
    return [
        SurfaceForm(text=sf.text, name_type="primary") if sf is shortest else sf for sf in forms
    ]


async def _insert_person_names(
    conn: Any,
    person_id: str,
    person: MergedPerson,
    *,
    book_id: str | None = None,
    prompt_version: str = "",
    llm_call_ids: list[str] | None = None,
) -> int:
    """Insert primary + alias names for one person. Returns count inserted.

    When all three evidence kwargs are provided (production path via
    load_persons -> cli.py), first writes a source_evidences row and
    threads its id into every person_names row via source_evidence_id.

    When evidence kwargs are omitted (legacy / mock test path), writes
    person_names rows with source_evidence_id = NULL. This path is
    retained for backward compatibility with pre-ADR-015 fixtures; new
    production callers MUST supply all three evidence kwargs.

    V7 invariant (Stage 2) will warn on active person_names with
    source_evidence_id IS NULL.

    Enforces single-primary invariant (T-P1-004 / ADR-012):
    at most one name_type='primary' per person.
    """
    inserted = 0
    seen_names: set[str] = set()

    # L0: Strip pronoun/honorific surfaces before primary enforcement
    filtered_forms = _filter_pronoun_surfaces(person)
    if not filtered_forms:
        logger.warning(
            "Pronoun filter: person %r has NO valid surfaces after filtering — skipping",
            person.name_zh,
        )
        return 0

    # Create source_evidences row (ADR-015 Stage 1, per-person granularity)
    source_evidence_id: str | None = None
    if book_id is not None:
        _call_ids = llm_call_ids or []
        source_evidence_id = str(
            await conn.fetchval(
                """
                INSERT INTO source_evidences
                  (raw_text_id, book_id, provenance_tier, prompt_version, llm_call_id)
                VALUES ($1::uuid, $2::uuid, $3::provenance_tier, $4, $5::uuid)
                RETURNING id
                """,
                person.chunk_ids[0] if person.chunk_ids else None,
                book_id,
                ProvenanceTier.AI_INFERRED.value,
                prompt_version,
                _call_ids[0] if _call_ids else None,
            )
        )

    # Temporarily replace person's surface_forms for _enforce_single_primary
    original_forms = person.surface_forms
    person.surface_forms = filtered_forms

    # Enforce single-primary invariant before any DB writes
    validated_forms = _enforce_single_primary(person)

    # Restore original forms
    person.surface_forms = original_forms

    # Determine which surface form is the "primary" name
    # Use the first validated form whose text matches name_zh, or fallback
    primary_name_type = "primary"
    for sf in validated_forms:
        if sf.text == person.name_zh:
            primary_name_type = sf.name_type
            break

    # Insert primary name (name_zh)
    # T-P0-016 step 1b: is_primary must mirror name_type semantics.
    # When _enforce_single_primary demotes name_zh to alias, the INSERT must
    # reflect is_primary=false. Previously hardcoded `true` produced V6 violations
    # (5 active samples observed: fu-yue / shen-nong-shi / 少暤氏 / 缙云氏 / 微子启).
    is_primary_value = primary_name_type == "primary"
    if person.name_zh not in seen_names:
        existing = await conn.fetchval(
            "SELECT id FROM person_names WHERE person_id = $1 AND name = $2",
            person_id,
            person.name_zh,
        )
        if not existing:
            await conn.execute(
                """
                INSERT INTO person_names (id, person_id, name, name_type, is_primary, source_evidence_id)
                VALUES ($1, $2, $3, $4::name_type, $5, $6::uuid)
                """,
                str(uuid.uuid4()),
                person_id,
                person.name_zh,
                primary_name_type,
                is_primary_value,
                source_evidence_id,
            )
            inserted += 1
        seen_names.add(person.name_zh)

    # Insert all surface forms with their validated name_types
    for sf in validated_forms:
        if sf.text in seen_names:
            continue
        existing = await conn.fetchval(
            "SELECT id FROM person_names WHERE person_id = $1 AND name = $2",
            person_id,
            sf.text,
        )
        if not existing:
            await conn.execute(
                """
                INSERT INTO person_names (id, person_id, name, name_type, is_primary, source_evidence_id)
                VALUES ($1, $2, $3, $4::name_type, false, $5::uuid)
                """,
                str(uuid.uuid4()),
                person_id,
                sf.text,
                sf.name_type,
                source_evidence_id,
            )
            inserted += 1
        seen_names.add(sf.text)

    return inserted
