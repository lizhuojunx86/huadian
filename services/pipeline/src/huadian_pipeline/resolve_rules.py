"""Rules engine for person identity resolution.

Implements score_pair() which evaluates a pair of persons against rules R1–R5
using first-match-wins semantics (evaluation order: R1→R2→R3→R5→R4).

Rules:
  R1 (confidence 0.95): surface_form cross-match
  R2 (confidence 0.93): 帝X / X prefix match
  R3 (confidence 0.90): tongjia (通假字) / variant character normalization
  R5 (confidence 0.90): temple/posthumous name dictionary (miaohao)
  R4 (confidence 0.65): identity_notes cross-reference (hypothesis only)

Returns None if no rule fires.
"""

from __future__ import annotations

import logging
import re
import warnings
from pathlib import Path
from typing import TYPE_CHECKING, Any

try:
    import yaml

    _HAS_YAML = True
except ImportError:
    _HAS_YAML = False

if TYPE_CHECKING:
    from .resolve import R6PrePassResult

from .resolve_types import MatchResult

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Dictionary loading
# ---------------------------------------------------------------------------

# Resolve project-root-relative dictionary paths.
# __file__ is services/pipeline/src/huadian_pipeline/resolve_rules.py
# Project root is four levels up.
_PROJECT_ROOT = Path(__file__).resolve().parents[4]
_TONGJIA_PATH = _PROJECT_ROOT / "data" / "dictionaries" / "tongjia.yaml"
_MIAOHAO_PATH = _PROJECT_ROOT / "data" / "dictionaries" / "miaohao.yaml"


def _load_yaml_safe(path: Path) -> dict[str, Any] | None:
    """Load a YAML file, returning None on failure (warning, not crash)."""
    if not _HAS_YAML:
        warnings.warn(
            "PyYAML is not installed; dictionary-based rules (R3, R5) are disabled.",
            stacklevel=3,
        )
        return None
    if not path.exists():
        warnings.warn(
            f"Dictionary file not found: {path}; related rules are disabled.",
            stacklevel=3,
        )
        return None
    try:
        with path.open(encoding="utf-8") as fh:
            return yaml.safe_load(fh)
    except Exception as exc:  # noqa: BLE001
        warnings.warn(
            f"Failed to load dictionary {path}: {exc}; related rules are disabled.",
            stacklevel=3,
        )
        return None


def _build_tongjia_index() -> dict[str, str]:
    """Build a variant→canonical mapping from tongjia.yaml.

    Returns an empty dict if the file is unavailable.
    """
    data = _load_yaml_safe(_TONGJIA_PATH)
    if data is None:
        return {}
    index: dict[str, str] = {}
    for entry in data.get("entries", []):
        variant = entry.get("variant", "").strip()
        canonical = entry.get("canonical", "").strip()
        if variant and canonical:
            index[variant] = canonical
    return index


def _build_miaohao_index() -> dict[tuple[str, str], dict[str, Any]]:
    """Build a (name_a, name_b) → entry mapping from miaohao.yaml.

    Both orderings (a,b) and (b,a) are indexed so lookup is order-independent.
    Also indexes (canonical, alias) pairs.
    """
    data = _load_yaml_safe(_MIAOHAO_PATH)
    if data is None:
        return {}
    index: dict[tuple[str, str], dict[str, Any]] = {}
    for entry in data.get("entries", []):
        canonical = entry.get("canonical", "").strip()
        aliases = [a.strip() for a in entry.get("aliases", [])]
        dynasty = entry.get("dynasty", "")
        if not canonical:
            continue
        for alias in aliases:
            if not alias:
                continue
            meta = {
                "canonical": canonical,
                "alias": alias,
                "dynasty": dynasty,
                "source": entry.get("source", ""),
                "notes": entry.get("notes", ""),
            }
            index[(canonical, alias)] = meta
            index[(alias, canonical)] = meta
    return index


# Module-level singletons — loaded once per process.
_TONGJIA: dict[str, str] = {}
_MIAOHAO: dict[tuple[str, str], dict[str, Any]] = {}
_DICTS_LOADED = False


def ensure_dicts_loaded() -> None:
    """Load dictionaries if not already loaded (idempotent)."""
    global _TONGJIA, _MIAOHAO, _DICTS_LOADED  # noqa: PLW0603
    if _DICTS_LOADED:
        return
    _TONGJIA = _build_tongjia_index()
    _MIAOHAO = _build_miaohao_index()
    _DICTS_LOADED = True
    logger.debug(
        "Loaded dictionaries: tongjia=%d entries, miaohao=%d pairs",
        len(_TONGJIA),
        len(_MIAOHAO),
    )


# ---------------------------------------------------------------------------
# Person snapshot — a lightweight dict passed to score_pair()
# ---------------------------------------------------------------------------


class PersonSnapshot:
    """Lightweight in-memory view of a DB person row for rule evaluation.

    Attributes:
        id:             persons.id (UUID str)
        name:           canonical name (zh-Hans from name JSONB)
        slug:           persons.slug
        dynasty:        persons.dynasty or ""
        surface_forms:  set of name strings from person_names (all names)
        identity_notes: list of identity_notes strings (from person_names or
                        extracted annotations)
        created_at:     ISO timestamp string (for canonical selection tiebreaking)
        r6_result:      R6PrePassResult from seed-match pre-pass (None if not yet run)
    """

    __slots__ = (
        "id",
        "name",
        "slug",
        "dynasty",
        "surface_forms",
        "identity_notes",
        "created_at",
        "r6_result",
    )

    def __init__(
        self,
        id: str,  # noqa: A002
        name: str,
        slug: str,
        dynasty: str,
        surface_forms: set[str],
        identity_notes: list[str],
        created_at: str,
        r6_result: R6PrePassResult | None = None,
    ) -> None:
        self.id = id
        self.name = name
        self.slug = slug
        self.dynasty = dynasty
        self.surface_forms = surface_forms
        self.identity_notes = identity_notes
        self.created_at = created_at
        self.r6_result = r6_result

    def all_names(self) -> set[str]:
        """Return the union of name + all surface_forms."""
        return self.surface_forms | {self.name}

    def has_pinyin_slug(self) -> bool:
        """Return True if slug is a pinyin slug (not a u{hex} fallback)."""
        # u{hex} fallback pattern: starts with "u" followed by 4 hex digits
        return not bool(re.match(r"^u[0-9a-f]{4}", self.slug))


# ---------------------------------------------------------------------------
# Individual rule implementations
# ---------------------------------------------------------------------------

# Generic titles / self-references that must never serve as identity signals.
# These appear in multiple unrelated persons' surface_forms.
_R1_STOP_WORDS = frozenset(
    {
        # Single-char generic titles / self-references
        "王",
        "帝",
        "后",
        "朕",
        # Multi-char generic self-references
        "予一人",
        # Posthumous/honorary titles shared across dynasties (多个帝王共用)
        "武王",  # 汤(商) self-proclaimed 武王; 周武王 is a different person
    }
)


def _rule_r1(a: PersonSnapshot, b: PersonSnapshot) -> MatchResult | None:
    """R1: surface_form cross-match (confidence 0.95).

    Fires if the two persons share at least one meaningful name in their
    combined name sets (name_zh + surface_forms), after filtering:
      1. Generic title stop words (王, 帝, 武王, etc.)
      2. Cross-dynasty single-char guard (single-char overlap alone cannot
         trigger a cross-dynasty merge)
    """
    a_names = a.all_names()
    b_names = b.all_names()
    overlap = a_names & b_names
    if not overlap:
        return None

    # Step 1: Remove stop words — these are never meaningful as identity signals
    meaningful = overlap - _R1_STOP_WORDS
    if not meaningful:
        return None

    # Step 2: Cross-dynasty guard — if both persons have dynasty and they differ,
    # require at least one multi-char (>= 2) overlap. Single-char names like
    # "启" or "益" are too ambiguous across dynasties.
    cross_dynasty = a.dynasty and b.dynasty and a.dynasty != b.dynasty
    if cross_dynasty:
        meaningful = {n for n in meaningful if len(n) >= 2}
        if not meaningful:
            return None

    # Step 3: Single-char quality filter (same-dynasty) — single-char overlap
    # only counts if both persons have it in their surface_forms (not just as
    # the primary name of one).
    multi_char = {n for n in meaningful if len(n) > 1}
    if not multi_char:
        single_char = meaningful  # all remaining are single-char
        meaningful = single_char & a.surface_forms & b.surface_forms
        if not meaningful:
            return None

    return MatchResult(
        rule="R1",
        confidence=0.95,
        evidence={
            "overlap": sorted(meaningful),
            "a_names": sorted(a_names),
            "b_names": sorted(b_names),
        },
    )


def _rule_r2(a: PersonSnapshot, b: PersonSnapshot) -> MatchResult | None:
    """R2: 帝X / X prefix match (confidence 0.93).

    Fires if "帝" + a.name == b.name or "帝" + b.name == a.name,
    with guards:
      - Same dynasty (or one is unknown)
      - Single-char names also need at least one surface_form overlap
    """

    def _check(short: PersonSnapshot, long: PersonSnapshot) -> bool:
        """Check if long.name == '帝' + short.name."""
        expected_long = "帝" + short.name
        if long.name != expected_long:
            return False
        # Dynasty guard: must be same or one is missing
        if short.dynasty and long.dynasty and short.dynasty != long.dynasty:
            return False
        # Single-char guard: if short name is 1 char, require surface overlap
        if len(short.name) == 1:
            if not (short.all_names() & long.all_names()):
                return False
        return True

    if _check(a, b):
        direction = f"{a.name}→帝{a.name}"
        short, long = a, b
    elif _check(b, a):
        direction = f"{b.name}→帝{b.name}"
        short, long = b, a
    else:
        return None

    return MatchResult(
        rule="R2",
        confidence=0.93,
        evidence={
            "direction": direction,
            "short_name": short.name,
            "long_name": long.name,
            "short_dynasty": short.dynasty,
            "long_dynasty": long.dynasty,
        },
    )


def _rule_r3(a: PersonSnapshot, b: PersonSnapshot) -> MatchResult | None:
    """R3: tongjia (通假字) / variant character normalization (confidence 0.90).

    Normalizes each character in a name using the tongjia index, then compares.
    Also handles direct variant→canonical lookup for whole names.
    """
    if not _TONGJIA:
        return None

    def _normalize_name(name: str) -> str:
        """Replace variant characters with canonical equivalents."""
        # First try whole-name lookup (e.g. "垂" → "倕" for single-char names)
        if name in _TONGJIA:
            return _TONGJIA[name]
        # Then do character-by-character substitution
        return "".join(_TONGJIA.get(ch, ch) for ch in name)

    a_normalized = _normalize_name(a.name)
    b_normalized = _normalize_name(b.name)

    # Check if normalization makes them equal, and they weren't already equal
    if a_normalized == b_normalized and a.name != b.name:
        return MatchResult(
            rule="R3",
            confidence=0.90,
            evidence={
                "a_original": a.name,
                "b_original": b.name,
                "normalized": a_normalized,
                "mapping_used": {k: v for k, v in _TONGJIA.items() if k in a.name or k in b.name},
            },
        )

    # Also check surface_forms normalization
    for sf_a in a.surface_forms:
        n_sf_a = _normalize_name(sf_a)
        for sf_b in b.surface_forms:
            n_sf_b = _normalize_name(sf_b)
            if n_sf_a == n_sf_b and sf_a != sf_b:
                return MatchResult(
                    rule="R3",
                    confidence=0.90,
                    evidence={
                        "a_surface": sf_a,
                        "b_surface": sf_b,
                        "normalized": n_sf_a,
                        "mapping_used": {
                            k: v for k, v in _TONGJIA.items() if k in sf_a or k in sf_b
                        },
                    },
                )

    return None


def _rule_r5(a: PersonSnapshot, b: PersonSnapshot) -> MatchResult | None:
    """R5: temple/posthumous name dictionary match (confidence 0.90).

    Checks if (a.name, b.name) or any surface form pair appears in miaohao index.
    Same dynasty required (both must have dynasty set).
    """
    if not _MIAOHAO:
        return None

    # Collect all name candidates for each person
    a_all = a.all_names()
    b_all = b.all_names()

    for name_a in a_all:
        for name_b in b_all:
            if name_a == name_b:
                continue
            entry = _MIAOHAO.get((name_a, name_b))
            if entry is None:
                continue
            # Dynasty guard: if dictionary specifies a dynasty, at least one
            # of the two persons must match it.
            entry_dynasty = entry.get("dynasty", "")
            if entry_dynasty and a.dynasty and b.dynasty:
                if a.dynasty != entry_dynasty and b.dynasty != entry_dynasty:
                    continue
            return MatchResult(
                rule="R5",
                confidence=0.90,
                evidence={
                    "matched_a": name_a,
                    "matched_b": name_b,
                    "dict_canonical": entry["canonical"],
                    "dict_alias": entry["alias"],
                    "dict_dynasty": entry_dynasty,
                    "source": entry.get("source", ""),
                    "notes": entry.get("notes", ""),
                },
            )

    return None


# Identity notes pattern — matches phrases like "与X同人", "即X", "X又名Y"
_IDENTITY_NOTES_PATTERNS = [
    re.compile(r"与(.{1,8})同人"),
    re.compile(r"即(.{1,8})"),
    re.compile(r"(.{1,8})又名(.{1,8})"),
    re.compile(r"或即(.{1,8})"),
    re.compile(r"一说为(.{1,8})"),
]


def _extract_noted_names(notes: list[str]) -> set[str]:
    """Extract person names referenced in identity_notes."""
    names: set[str] = set()
    for note in notes:
        for pattern in _IDENTITY_NOTES_PATTERNS:
            for match in pattern.finditer(note):
                for group in match.groups():
                    cleaned = group.strip("，。、；：「」『』【】《》〈〉")
                    if cleaned:
                        names.add(cleaned)
    return names


def _rule_r4(a: PersonSnapshot, b: PersonSnapshot) -> MatchResult | None:
    """R4: identity_notes cross-reference (confidence 0.65).

    Parses identity_notes for patterns like "与X同人", "即X", "X又名Y".
    Only generates a hypothesis, does not trigger merge.
    """
    a_noted = _extract_noted_names(a.identity_notes)
    b_noted = _extract_noted_names(b.identity_notes)

    # Check if B's name is mentioned in A's notes, or vice versa
    a_mentions_b = b.name in a_noted or any(sf in a_noted for sf in b.surface_forms)
    b_mentions_a = a.name in b_noted or any(sf in b_noted for sf in a.surface_forms)

    if a_mentions_b or b_mentions_a:
        return MatchResult(
            rule="R4",
            confidence=0.65,
            evidence={
                "a_noted_names": sorted(a_noted),
                "b_noted_names": sorted(b_noted),
                "a_mentions_b": a_mentions_b,
                "b_mentions_a": b_mentions_a,
                "a_identity_notes": a.identity_notes,
                "b_identity_notes": b.identity_notes,
            },
        )

    return None


# ---------------------------------------------------------------------------
# Non-person entity classification (T-P0-014)
# ---------------------------------------------------------------------------

# Rulers / legendary figures whose names end in 氏 but are individual persons.
# Priority: checked BEFORE the X氏 suffix rule so they are never misclassified.
HONORIFIC_SHI_WHITELIST = frozenset(
    {
        "神农氏",
        "伏羲氏",
        "女娲氏",
        "轩辕氏",
        "少昊氏",
        "少暤氏",
        "颛顼氏",
        "高阳氏",
        "高辛氏",
        "有熊氏",
        "帝鸿氏",
        "缙云氏",
        "涂山氏",
    }
)

# Names that are unambiguously not individual persons.
# Values are the classification category.
_KNOWN_NON_PERSON_NAMES: dict[str, str] = {
    # Tribal / ethnic groups (部族/族群)
    "荤粥": "tribal_group",  # 匈奴古称
    "猃狁": "tribal_group",  # 周代北方族群
    "鬼方": "tribal_group",  # 商周北方族群
    "山戎": "tribal_group",  # 北方游牧族
    "三苗": "tribal_group",  # 上古南方族群
    # Abstract collectives (抽象集合)
    "百姓": "abstract_collective",
    "万国": "abstract_collective",
}


def is_likely_non_person(p: PersonSnapshot) -> tuple[bool, str]:
    """Determine if a PersonSnapshot is likely not an individual person.

    Evaluation order:
      1. HONORIFIC_SHI_WHITELIST — known rulers with 氏 suffix → keep
      2. _KNOWN_NON_PERSON_NAMES — hardcoded non-person dictionary → reject
      3. X氏 suffix pattern:
         a. If surface_forms contains the bare name (without 氏), the entity
            may represent both a clan and a specific person → keep (ambiguous)
         b. Otherwise → reject as tribal_group or clan_surname

    Args:
        p: PersonSnapshot to evaluate.

    Returns:
        (True, category) if likely non-person.
          category is one of: 'tribal_group', 'clan_surname', 'abstract_collective'
        (False, '') if should be kept.
    """
    name = p.name

    # 1. Whitelist — known rulers whose names end in 氏
    if name in HONORIFIC_SHI_WHITELIST:
        return (False, "")

    # 2. Hardcoded non-person dictionary
    if name in _KNOWN_NON_PERSON_NAMES:
        return (True, _KNOWN_NON_PERSON_NAMES[name])

    # 3. X氏 suffix pattern
    if name.endswith("氏") and len(name) >= 2:
        bare_name = name[:-1]
        # Guard: if surface_forms contains the bare name, this entity may
        # simultaneously refer to a clan AND a specific person (e.g. 羲氏
        # with surface_form "羲") → do not classify as non-person.
        if bare_name in p.surface_forms:
            return (False, "")
        # Single char + 氏 (e.g. 姒氏, 姬氏) → clan surname
        if len(bare_name) == 1:
            return (True, "clan_surname")
        # Multi-char + 氏 (e.g. 昆吾氏, 有扈氏) → tribal group
        return (True, "tribal_group")

    return (False, "")


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

# Evaluation order as per ADR-010: R1 → R2 → R3 → R5 → R4
# First match wins.
_RULE_ORDER = [_rule_r1, _rule_r2, _rule_r3, _rule_r5, _rule_r4]

# Confidence threshold below which we produce a hypothesis rather than a merge proposal
MERGE_CONFIDENCE_THRESHOLD = 0.90


def is_di_honorific(name: str) -> bool:
    """Return True if *name* is a 帝X honorific (e.g. 帝尧, 帝南庚).

    Conditions (all must hold):
      1. Starts with "帝"
      2. The bare portion (name[1:]) is 1–2 characters

    Shared by resolve_rules (canonical selection) and load (primary
    demotion for 帝X surface_forms).  See ADR-012 / T-P1-004.
    """
    if not name.startswith("帝"):
        return False
    return 1 <= len(name[1:]) <= 2


def has_di_prefix_peer(p: PersonSnapshot, group: list[PersonSnapshot]) -> bool:
    """Return True if p.name is a 帝X honorific and the bare name X exists in group.

    Conditions (all must hold):
      1. p.name starts with "帝"
      2. The stripped name (p.name[1:]) is 1–2 characters
      3. Another person in the same group has name == stripped

    When True, p should be deprioritised in canonical selection so the
    bare-name peer becomes canonical instead.
    """
    if not is_di_honorific(p.name):
        return False
    stripped = p.name[1:]
    return any(other.id != p.id and other.name == stripped for other in group)


def score_pair(a: PersonSnapshot, b: PersonSnapshot) -> MatchResult | None:
    """Evaluate a pair of persons against all rules (first-match-wins).

    Returns the first matching MatchResult, or None if no rule fires.
    Dictionaries are loaded lazily on first call.
    """
    ensure_dicts_loaded()

    for rule_fn in _RULE_ORDER:
        result = rule_fn(a, b)
        if result is not None:
            return result

    return None
