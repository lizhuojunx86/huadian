"""Slug generation module — single source of truth for person slug rules.

Implements the tiered slug strategy (ADR-011):
  - Tier-S names (from data/tier-s-slugs.yaml whitelist) → pinyin slug
  - All other names → unicode hex fallback (u{hex} per character)

Both formats satisfy the API slug regex: /^[a-z0-9]+(-[a-z0-9]+)*$/
"""

from __future__ import annotations

import re
import uuid
from pathlib import Path
from typing import Final

import yaml

# ---------- Whitelist loading ----------

_WHITELIST_PATH: Final = Path(__file__).resolve().parents[4] / "data" / "tier-s-slugs.yaml"

_TIER_S_PINYIN: dict[str, str] | None = None


def _load_whitelist() -> dict[str, str]:
    """Load the Tier-S pinyin whitelist from YAML. Cached after first call."""
    global _TIER_S_PINYIN  # noqa: PLW0603
    if _TIER_S_PINYIN is not None:
        return _TIER_S_PINYIN

    with _WHITELIST_PATH.open(encoding="utf-8") as f:
        raw = yaml.safe_load(f)

    if not isinstance(raw, dict):
        msg = f"tier-s-slugs.yaml must be a YAML mapping, got {type(raw).__name__}"
        raise TypeError(msg)

    # Validate: all values must be valid slugs
    slug_re = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
    for name, slug in raw.items():
        if not isinstance(slug, str) or not slug_re.match(slug):
            msg = f"Invalid slug in whitelist: {name!r} → {slug!r}"
            raise ValueError(msg)

    _TIER_S_PINYIN = dict(raw)
    return _TIER_S_PINYIN


def get_tier_s_whitelist() -> dict[str, str]:
    """Return a copy of the Tier-S pinyin whitelist (name_zh ��� slug)."""
    return dict(_load_whitelist())


def reset_whitelist_cache() -> None:
    """Clear cached whitelist. For testing only."""
    global _TIER_S_PINYIN  # noqa: PLW0603
    _TIER_S_PINYIN = None


# ---------- Slug generation ----------

# Regex for validating unicode-format slugs
UNICODE_SLUG_RE: Final = re.compile(r"^u[0-9a-f]{4,5}(-u[0-9a-f]{4,5})*$")

# Regex for validating any legal slug (pinyin or unicode)
VALID_SLUG_RE: Final = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")


def generate_slug(name_zh: str) -> str:
    """Generate a URL-safe slug from a Chinese name.

    Strategy (ADR-011 — tiered whitelist):
      1. If name_zh is in the Tier-S whitelist → return pinyin slug
      2. Otherwise → return unicode hex slug (u{hex} per character)

    Both formats satisfy VALID_SLUG_RE.
    """
    whitelist = _load_whitelist()

    if name_zh in whitelist:
        return whitelist[name_zh]

    return unicode_slug(name_zh)


def unicode_slug(name_zh: str) -> str:
    """Generate a unicode hex slug from a Chinese name.

    Each character is encoded as u{hex_codepoint}, joined by hyphens.
    Supports BMP (4-hex) and supplementary planes (5-hex).

    Examples:
        "中丁" → "u4e2d-u4e01"
        "黄帝" → "u9ec4-u5e1d"
    """
    if not name_zh:
        return f"unknown-{uuid.uuid4().hex[:8]}"

    parts = []
    for char in name_zh:
        cp = ord(char)
        # Use 4-hex for BMP (U+0000–U+FFFF), 5-hex for supplementary
        parts.append(f"u{cp:04x}")

    slug = "-".join(parts)

    # Safety: strip anything non-alphanumeric except hyphens
    slug = re.sub(r"[^a-z0-9-]", "", slug)
    return slug or f"unknown-{uuid.uuid4().hex[:8]}"


def is_valid_slug(slug: str) -> bool:
    """Check if a slug is in a valid format (pinyin or unicode)."""
    return bool(VALID_SLUG_RE.match(slug))


def is_tier_s_slug(slug: str) -> bool:
    """Check if a slug is a known Tier-S pinyin slug."""
    whitelist = _load_whitelist()
    return slug in whitelist.values()


def is_unicode_slug(slug: str) -> bool:
    """Check if a slug is in unicode hex format."""
    return bool(UNICODE_SLUG_RE.match(slug))


def classify_slug(slug: str) -> str:
    """Classify a slug into its bucket.

    Returns:
        "pinyin" — if the slug is a Tier-S pinyin slug
        "unicode" — if the slug matches unicode hex format
        "unknown" — if neither (should not happen in a healthy DB)
    """
    if is_tier_s_slug(slug):
        return "pinyin"
    if is_unicode_slug(slug):
        return "unicode"
    return "unknown"
