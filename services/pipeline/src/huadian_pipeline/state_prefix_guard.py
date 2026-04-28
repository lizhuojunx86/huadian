"""State-prefix guard for R1 merge candidates (ADR-025 §5.3).

Blocks merge when both persons' primary names match (state)(shihao)(title)
and the resolved canonical states differ. Single-party semantic: if either
name does not match the pattern, the guard falls through (returns None) to
avoid over-blocking ambiguous surfaces like bare shihao "桓公".

Alias resolution: states.yaml aliases are normalised to canonical state
name before comparison (e.g., "唐" → "晋", so "唐X公" ↔ "晋X公" is not
blocked). See ADR-025 §5.3.5.

No year threshold — state_prefix is boolean (same-state pass / diff-state
block). Contrast cross_dynasty_guard which uses numeric year thresholds.

GuardResult is imported lazily inside state_prefix_guard() to break the
mutual-import cycle with r6_temporal_guards (which imports this module at
module level for GUARD_CHAINS).
"""

from __future__ import annotations

import logging
import re
import warnings
from dataclasses import dataclass, field
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from .r6_temporal_guards import GuardResult
    from .resolve_rules import PersonSnapshot

try:
    import yaml

    _HAS_YAML = True
except ImportError:
    _HAS_YAML = False

logger = logging.getLogger(__name__)

_PROJECT_ROOT = Path(__file__).resolve().parents[4]
_STATES_PATH = _PROJECT_ROOT / "data" / "states.yaml"

# ADR-025 §5.3.4 — inline at code (not in yaml); governed by PE + unit tests.
# States yaml holds the state-name dictionary; these are regex-class constants.
SHIHAO_CHARS = "庄桓昭襄惠成穆悼平孝景灵献文武康简怀厉宣幽思敬考定哀殇烈"
RULER_TITLES = ("王", "公", "侯")


# ---------------------------------------------------------------------------
# State data loading
# ---------------------------------------------------------------------------


@dataclass(frozen=True, slots=True)
class _StateEntry:
    name: str
    aliases: tuple[str, ...] = field(default_factory=tuple)


def _load_states() -> tuple[list[_StateEntry], dict[str, str]]:
    """Load states.yaml. Returns (entries, alias_to_canonical mapping)."""
    if not _HAS_YAML:
        warnings.warn(
            "PyYAML not installed; state_prefix_guard disabled.",
            stacklevel=3,
        )
        return [], {}

    if not _STATES_PATH.exists():
        warnings.warn(
            f"States file not found: {_STATES_PATH}; state_prefix_guard disabled.",
            stacklevel=3,
        )
        return [], {}

    try:
        with _STATES_PATH.open(encoding="utf-8") as fh:
            data = yaml.safe_load(fh)
    except Exception as exc:  # noqa: BLE001
        warnings.warn(
            f"Failed to load states: {exc}; state_prefix_guard disabled.",
            stacklevel=3,
        )
        return [], {}

    entries: list[_StateEntry] = []
    alias_to_canonical: dict[str, str] = {}
    for item in data.get("states", []):
        entry = _StateEntry(
            name=item["name"],
            aliases=tuple(item.get("aliases", [])),
        )
        entries.append(entry)
        alias_to_canonical[entry.name] = entry.name
        for alias in entry.aliases:
            alias_to_canonical[alias] = entry.name

    logger.debug(
        "Loaded %d state entries (%d total forms incl. aliases)",
        len(entries),
        len(alias_to_canonical),
    )
    return entries, alias_to_canonical


_states_cache: tuple[list[_StateEntry], dict[str, str]] | None = None
_pattern_cache: re.Pattern[str] | None = None


def _get_states() -> tuple[list[_StateEntry], dict[str, str]]:
    global _states_cache  # noqa: PLW0603
    if _states_cache is None:
        _states_cache = _load_states()
    return _states_cache


def _get_pattern() -> re.Pattern[str] | None:
    """Build and cache the state-prefix regex pattern."""
    global _pattern_cache  # noqa: PLW0603
    if _pattern_cache is None:
        _, alias_to_canonical = _get_states()
        if not alias_to_canonical:
            return None
        # Longest match first avoids prefix ambiguity (e.g., "句吴" before "吴")
        forms = sorted(alias_to_canonical, key=len, reverse=True)
        _pattern_cache = re.compile(
            r"^(?P<state>" + "|".join(re.escape(s) for s in forms) + r")"
            r"(?P<shihao>[" + SHIHAO_CHARS + r"]+)"
            r"(?P<title>" + "|".join(re.escape(t) for t in RULER_TITLES) + r")$"
        )
    return _pattern_cache


def reset_states_cache() -> None:
    """Reset cached state data and compiled pattern (for testing)."""
    global _states_cache, _pattern_cache  # noqa: PLW0603
    _states_cache = None
    _pattern_cache = None


def _resolve_canonical(raw: str) -> str:
    _, alias_to_canonical = _get_states()
    return alias_to_canonical.get(raw, raw)


# ---------------------------------------------------------------------------
# Guard implementation
# ---------------------------------------------------------------------------


def state_prefix_guard(
    person_a: PersonSnapshot,
    person_b: PersonSnapshot,
) -> GuardResult | None:
    """Block R1 merge when both names match (state)(shihao)(title) with different states.

    Returns GuardResult(guard_type="state_prefix", blocked=True) on mismatch.
    Returns None if either name does not match the pattern, or both resolve
    to the same canonical state (incl. alias equivalence, e.g., 唐==晋).
    """
    from .r6_temporal_guards import GuardResult  # noqa: PLC0415

    pattern = _get_pattern()
    if pattern is None:
        return None

    m_a = pattern.match(person_a.name)
    m_b = pattern.match(person_b.name)
    if m_a is None or m_b is None:
        return None

    canonical_a = _resolve_canonical(m_a.group("state"))
    canonical_b = _resolve_canonical(m_b.group("state"))
    if canonical_a == canonical_b:
        return None

    return GuardResult(
        guard_type="state_prefix",
        blocked=True,
        reason=f"state prefix mismatch: {canonical_a} vs {canonical_b}",
        payload={
            "state_a": canonical_a,
            "state_b": canonical_b,
            "raw_state_a": m_a.group("state"),
            "raw_state_b": m_b.group("state"),
            "name_a": person_a.name,
            "name_b": person_b.name,
        },
    )
