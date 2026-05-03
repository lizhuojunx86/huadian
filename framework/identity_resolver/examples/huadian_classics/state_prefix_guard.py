"""HuaDian classics — state-prefix guard for R1 merge candidates.

Blocks R1 (surface match) candidates whose primary names both match
`(state)(shihao)(title)` with different canonical states.

Example:
    "晋桓公" vs "齐桓公" — both match `(state)(shihao=桓)(title=公)`,
    but the states differ (晋 ≠ 齐) → block the merge.

Aliases are normalized to canonical state name before comparison
(e.g. "唐" → "晋", so "唐X公" ↔ "晋X公" is NOT blocked — they're the
same state in different naming conventions).

License: Apache 2.0
Source: lifted from `services/pipeline/src/huadian_pipeline/state_prefix_guard.py`.
"""

from __future__ import annotations

import logging
import os
import re
import warnings
from dataclasses import dataclass, field
from pathlib import Path

try:
    import yaml

    _HAS_YAML = True
except ImportError:
    _HAS_YAML = False

from framework.identity_resolver import EntitySnapshot, GuardResult

logger = logging.getLogger(__name__)


def _default_states_path() -> Path:
    """Locate `data/states.yaml` for HuaDian classics example.

    Resolution priority (per Sprint P DGF-O-01 P2 patch):
        1. ``HUADIAN_DATA_DIR`` environment variable (if set)
           → ``$HUADIAN_DATA_DIR/states.yaml``
        2. Fallback: walk up from this file
           parents[0]=huadian_classics, [1]=examples, [2]=identity_resolver,
           [3]=framework, [4]=<project_root>

    Cross-domain re-use note: callers may also pass ``path`` directly to
    :func:`_load_states` to override entirely.
    """
    env = os.environ.get("HUADIAN_DATA_DIR")
    if env:
        return Path(env) / "states.yaml"
    return Path(__file__).resolve().parents[4] / "data" / "states.yaml"


# ADR-025 §5.3.4 — inline at code (not in yaml); governed by PE + unit tests.
SHIHAO_CHARS = "庄桓昭襄惠成穆悼平孝景灵献文武康简怀厉宣幽思敬考定哀殇烈"
RULER_TITLES = ("王", "公", "侯")


@dataclass(frozen=True, slots=True)
class _StateEntry:
    name: str
    aliases: tuple[str, ...] = field(default_factory=tuple)


def _load_states(path: Path | None = None) -> tuple[list[_StateEntry], dict[str, str]]:
    """Load states.yaml. Returns (entries, alias_to_canonical mapping)."""
    path = path or _default_states_path()

    if not _HAS_YAML:
        warnings.warn(
            "PyYAML not installed; state_prefix_guard disabled.",
            stacklevel=3,
        )
        return [], {}

    if not path.exists():
        warnings.warn(
            f"States file not found: {path}; state_prefix_guard disabled.",
            stacklevel=3,
        )
        return [], {}

    try:
        with path.open(encoding="utf-8") as fh:
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
        # Longest match first avoids prefix ambiguity (e.g., "句吴" before "吴").
        forms = sorted(alias_to_canonical, key=len, reverse=True)
        _pattern_cache = re.compile(
            r"^(?P<state>"
            + "|".join(re.escape(s) for s in forms)
            + r")"
            + r"(?P<shihao>["
            + SHIHAO_CHARS
            + r"]+)"
            + r"(?P<title>"
            + "|".join(re.escape(t) for t in RULER_TITLES)
            + r")$"
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


def state_prefix_guard(
    entity_a: EntitySnapshot,
    entity_b: EntitySnapshot,
) -> GuardResult | None:
    """Block R1 merge when both names match `(state)(shihao)(title)` with diff states.

    Returns `GuardResult(guard_type="state_prefix", blocked=True)` on mismatch.
    Returns `None` if either name does not match the pattern, or both
    resolve to the same canonical state (incl. alias equivalence).
    """
    pattern = _get_pattern()
    if pattern is None:
        return None

    m_a = pattern.match(entity_a.name)
    m_b = pattern.match(entity_b.name)
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
            "name_a": entity_a.name,
            "name_b": entity_b.name,
        },
    )
