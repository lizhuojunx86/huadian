"""Load module — writes extracted persons to DB.

Handles:
  1. Deduplicate persons across chunks (merge by name_zh)
  2. Generate slugs from name
  3. Upsert into persons / person_names tables
"""

from __future__ import annotations

import logging
import re
import uuid
from dataclasses import dataclass, field
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    import asyncpg

from .extract import ExtractedPerson, SurfaceForm

logger = logging.getLogger(__name__)


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
            # Track chunks
            if p.chunk_id not in existing.chunk_ids:
                existing.chunk_ids.append(p.chunk_id)
            if p.chunk_paragraph_no not in existing.paragraph_nos:
                existing.paragraph_nos.append(p.chunk_paragraph_no)
            # Prefer more specific dynasty/reality_status
            if p.dynasty and (not existing.dynasty or existing.dynasty == "上古"):
                existing.dynasty = p.dynasty
            if p.reality_status != "uncertain":
                existing.reality_status = p.reality_status
        else:
            by_name[key] = MergedPerson(
                name_zh=key,
                slug=_generate_slug(key),
                surface_forms=list(p.surface_forms),
                dynasty=p.dynasty,
                reality_status=p.reality_status,
                identity_notes=[p.identity_notes] if p.identity_notes else [],
                briefs=[p.brief] if p.brief else [],
                confidence=p.confidence,
                chunk_ids=[p.chunk_id],
                paragraph_nos=[p.chunk_paragraph_no],
            )

    return list(by_name.values())


async def load_persons(
    pool: asyncpg.Pool,
    persons: list[MergedPerson],
    *,
    book_id: str,
) -> LoadResult:
    """Load merged persons into the database.

    Upserts into persons table by slug, inserts person_names.
    """
    result = LoadResult(total_merged=len(persons))

    async with pool.acquire() as conn:
        for person in persons:
            try:
                person_id, is_new = await _upsert_person(conn, person)
                if is_new:
                    result.persons_inserted += 1
                else:
                    result.persons_updated += 1

                # Insert person_names for each surface form
                names_added = await _insert_person_names(conn, person_id, person)
                result.names_inserted += names_added

            except Exception as e:
                msg = f"Failed to load person {person.name_zh}: {e}"
                logger.error(msg)
                result.errors.append(msg)

    logger.info(
        "Loaded %d persons (%d new, %d updated), %d names",
        result.total_merged,
        result.persons_inserted,
        result.persons_updated,
        result.names_inserted,
    )
    return result


async def _upsert_person(
    conn: asyncpg.Connection,
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
        VALUES ($1, $2, $3::jsonb, $4, $5::reality_status, 'ai_inferred', $6::jsonb)
        """,
        person_id,
        person.slug,
        name_json,
        person.dynasty or None,
        person.reality_status,
        biography_json,
    )
    return person_id, True


async def _insert_person_names(
    conn: asyncpg.Connection,
    person_id: str,
    person: MergedPerson,
) -> int:
    """Insert person_names for each surface form. Returns count inserted."""
    inserted = 0
    seen_names: set[str] = set()

    # Determine which surface form is the "primary" name
    # Use the first surface_form whose text matches name_zh, or fallback to first
    primary_name_type = "primary"
    for sf in person.surface_forms:
        if sf.text == person.name_zh:
            primary_name_type = sf.name_type
            break

    # Insert primary name (name_zh)
    if person.name_zh not in seen_names:
        existing = await conn.fetchval(
            "SELECT id FROM person_names WHERE person_id = $1 AND name = $2",
            person_id,
            person.name_zh,
        )
        if not existing:
            await conn.execute(
                """
                INSERT INTO person_names (id, person_id, name, name_type, is_primary)
                VALUES ($1, $2, $3, $4::name_type, true)
                """,
                str(uuid.uuid4()),
                person_id,
                person.name_zh,
                primary_name_type,
            )
            inserted += 1
        seen_names.add(person.name_zh)

    # Insert all surface forms with their individual name_types
    for sf in person.surface_forms:
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
                INSERT INTO person_names (id, person_id, name, name_type, is_primary)
                VALUES ($1, $2, $3, $4::name_type, false)
                """,
                str(uuid.uuid4()),
                person_id,
                sf.text,
                sf.name_type,
            )
            inserted += 1
        seen_names.add(sf.text)

    return inserted


# Simple pinyin mapping for common historical names (Phase 0).
# Production should use pypinyin or similar.
_PINYIN_MAP: dict[str, str] = {
    "黄帝": "huang-di",
    "炎帝": "yan-di",
    "蚩尤": "chi-you",
    "神农氏": "shen-nong-shi",
    "少典": "shao-dian",
    "嫘祖": "lei-zu",
    "玄嚣": "xuan-xiao",
    "昌意": "chang-yi",
    "颛顼": "zhuan-xu",
    "帝喾": "di-ku",
    "帝尧": "di-yao",
    "尧": "yao",
    "帝舜": "di-shun",
    "舜": "shun",
    "禹": "yu",
    "鲧": "gun",
    "皋陶": "gao-yao",
    "契": "xie",
    "后稷": "hou-ji",
    "伯夷": "bo-yi",
    "夔": "kui",
    "龙": "long",
    "倕": "chui",
    "益": "yi",
    "彭祖": "peng-zu",
    "丹朱": "dan-zhu",
    "商均": "shang-jun",
    "瞽叟": "gu-sou",
    "象": "xiang",
    "放勋": "fang-xun",
    "重华": "chong-hua",
    "高阳": "gao-yang",
    "高辛": "gao-xin",
    "穷蝉": "qiong-chan",
    "敬康": "jing-kang",
    "句望": "gou-wang",
    "桥牛": "qiao-niu",
    "蟜极": "jiao-ji",
    "风后": "feng-hou",
    "力牧": "li-mu",
    "常先": "chang-xian",
    "大鸿": "da-hong",
    "羲仲": "xi-zhong",
    "羲叔": "xi-shu",
    "和仲": "he-zhong",
    "和叔": "he-shu",
    "放齐": "fang-qi",
    "欢兜": "huan-dou",
    "共工": "gong-gong",
    "昌仆": "chang-pu",
    "挚": "zhi",
    # 夏本纪
    "启": "qi",
    "太康": "tai-kang",
    "中康": "zhong-kang",
    "少康": "shao-kang",
    "孔甲": "kong-jia",
    "桀": "jie",
    "刘累": "liu-lei",
    # 殷本纪
    "成汤": "cheng-tang",
    "汤": "tang",
    "伊尹": "yi-yin",
    "太甲": "tai-jia",
    "盘庚": "pan-geng",
    "武丁": "wu-ding",
    "傅说": "fu-yue",
    "纣": "zhou-xin",
    "帝辛": "di-xin",
    "妲己": "da-ji",
    "比干": "bi-gan",
    "微子启": "wei-zi-qi",
    "箕子": "ji-zi",
    "西伯昌": "xi-bo-chang",
    "武王": "wu-wang",
    "简狄": "jian-di",
}


def _generate_slug(name_zh: str) -> str:
    """Generate a URL-safe slug from a Chinese name.

    Uses a simple transliteration approach. For production,
    this should use pypinyin or similar.
    """
    if name_zh in _PINYIN_MAP:
        return _PINYIN_MAP[name_zh]

    # Fallback: use character codes for unknown names
    slug_parts = []
    for char in name_zh:
        slug_parts.append(f"u{ord(char):04x}")
    slug = "-".join(slug_parts)

    # Ensure slug is URL-safe
    slug = re.sub(r"[^a-z0-9-]", "", slug)
    return slug or f"unknown-{uuid.uuid4().hex[:8]}"
