"""CText source adapter — loads classical Chinese texts from local fixtures.

Phase 0 implementation: reads pre-downloaded texts from
  services/pipeline/fixtures/sources/shiji/
to avoid runtime network dependency on ctext.org.

Follow-up: T-P1-XXX will implement a real ctext.org API adapter.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path

# Fixtures root relative to this file
_FIXTURES_ROOT = Path(__file__).resolve().parents[3] / "fixtures" / "sources"

# Chapter registry: maps (book_slug, chapter_slug) → fixture filename
_CHAPTER_REGISTRY: dict[tuple[str, str], str] = {
    ("shiji", "wu-di-ben-ji"): "shiji/wu_di_ben_ji.txt",
    ("shiji", "xia-ben-ji"): "shiji/xia_ben_ji.txt",
    ("shiji", "yin-ben-ji"): "shiji/yin_ben_ji.txt",
}

# Book metadata
_BOOK_META: dict[str, dict[str, str]] = {
    "shiji": {
        "title_zh": "史记",
        "title_en": "Records of the Grand Historian",
        "author": "司马迁",
        "dynasty": "西汉",
    },
}

# Chapter metadata: maps chapter_slug → display info
_CHAPTER_META: dict[str, dict[str, str]] = {
    "wu-di-ben-ji": {
        "title_zh": "五帝本纪",
        "title_en": "Basic Annals of the Five Emperors",
        "volume": "卷一",
    },
    "xia-ben-ji": {
        "title_zh": "夏本纪",
        "title_en": "Basic Annals of the Xia Dynasty",
        "volume": "卷二",
    },
    "yin-ben-ji": {
        "title_zh": "殷本纪",
        "title_en": "Basic Annals of the Yin Dynasty",
        "volume": "卷三",
    },
}


@dataclass(frozen=True, slots=True)
class RawTextRow:
    """A single paragraph of raw text ready for DB insertion."""

    source_id: str  # e.g. "ctext:shiji/wu-di-ben-ji"
    book_slug: str  # e.g. "shiji"
    chapter: str  # e.g. "五帝本纪"
    volume: str  # e.g. "卷一"
    paragraph_no: int  # 1-based
    raw_text: str  # simplified Chinese
    text_original: str | None = None  # traditional Chinese (not available in Phase 0)


@dataclass(slots=True)
class ChapterData:
    """Loaded chapter with metadata and paragraphs."""

    book_slug: str
    chapter_slug: str
    title_zh: str
    title_en: str
    volume: str
    book_title_zh: str
    book_title_en: str
    author: str
    dynasty: str
    paragraphs: list[RawTextRow] = field(default_factory=list)

    @property
    def source_url(self) -> str:
        return f"https://ctext.org/{self.book_slug}/{self.chapter_slug}/zhs"


def list_available_chapters(book_slug: str = "shiji") -> list[str]:
    """List chapter slugs available for a given book."""
    return [chapter_slug for (b, chapter_slug) in _CHAPTER_REGISTRY if b == book_slug]


def load_chapter(book_slug: str, chapter_slug: str) -> ChapterData:
    """Load a chapter from local fixtures.

    Parameters
    ----------
    book_slug : str
        Book identifier (e.g. "shiji").
    chapter_slug : str
        Chapter identifier (e.g. "wu-di-ben-ji").

    Returns
    -------
    ChapterData with parsed paragraphs.

    Raises
    ------
    FileNotFoundError
        If the fixture file does not exist.
    KeyError
        If the chapter is not registered.
    """
    key = (book_slug, chapter_slug)
    if key not in _CHAPTER_REGISTRY:
        available = list_available_chapters(book_slug)
        raise KeyError(
            f"Chapter {chapter_slug!r} not registered for book {book_slug!r}. "
            f"Available: {available}"
        )

    fixture_path = _FIXTURES_ROOT / _CHAPTER_REGISTRY[key]
    if not fixture_path.exists():
        raise FileNotFoundError(f"Fixture not found: {fixture_path}")

    raw = fixture_path.read_text(encoding="utf-8")
    paragraphs = _parse_paragraphs(raw)

    book_meta = _BOOK_META.get(book_slug, {})
    chapter_meta = _CHAPTER_META.get(chapter_slug, {})
    source_id = f"ctext:{book_slug}/{chapter_slug}"

    rows = [
        RawTextRow(
            source_id=source_id,
            book_slug=book_slug,
            chapter=chapter_meta.get("title_zh", chapter_slug),
            volume=chapter_meta.get("volume", ""),
            paragraph_no=i + 1,
            raw_text=para,
        )
        for i, para in enumerate(paragraphs)
    ]

    return ChapterData(
        book_slug=book_slug,
        chapter_slug=chapter_slug,
        title_zh=chapter_meta.get("title_zh", chapter_slug),
        title_en=chapter_meta.get("title_en", ""),
        volume=chapter_meta.get("volume", ""),
        book_title_zh=book_meta.get("title_zh", book_slug),
        book_title_en=book_meta.get("title_en", ""),
        author=book_meta.get("author", ""),
        dynasty=book_meta.get("dynasty", ""),
        paragraphs=rows,
    )


def _parse_paragraphs(raw: str) -> list[str]:
    """Parse fixture text into paragraphs.

    Skips comment lines (starting with #) and blank lines.
    Consecutive non-blank, non-comment lines form one paragraph.
    Paragraphs are separated by blank lines.
    """
    lines = raw.strip().split("\n")
    paragraphs: list[str] = []
    current: list[str] = []

    for line in lines:
        stripped = line.strip()
        # Skip comment lines
        if stripped.startswith("#"):
            continue
        if stripped == "":
            if current:
                paragraphs.append("".join(current))
                current = []
        else:
            current.append(stripped)

    if current:
        paragraphs.append("".join(current))

    # Filter out very short "paragraphs" that are likely artifacts
    return [p for p in paragraphs if len(p) >= 4]
