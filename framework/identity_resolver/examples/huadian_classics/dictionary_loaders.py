"""HuaDian classics — DictionaryLoader plugin (R3 + R5 dictionaries).

Loads two YAML dictionaries used by R3 (variant char) and R5 (alias):

    tongjia.yaml   — variant character mappings (e.g. 倕→垂)
    miaohao.yaml   — temple/posthumous name aliases (e.g. 文王/姬昌)

Both files live under `data/dictionaries/` in the HuaDian project root.

License: Apache 2.0
Source: extracted from `services/pipeline/src/huadian_pipeline/resolve_rules.py`
        `_build_tongjia_index` + `_build_miaohao_index`.
"""

from __future__ import annotations

import logging
import os
import warnings
from pathlib import Path
from typing import Any

try:
    import yaml

    _HAS_YAML = True
except ImportError:
    _HAS_YAML = False

logger = logging.getLogger(__name__)


def _default_dict_dir() -> Path:
    """Locate `data/dictionaries/` for HuaDian classics example.

    Resolution priority (per Sprint P DGF-O-01 P2 patch):
        1. ``HUADIAN_DATA_DIR`` environment variable (if set)
           → returns ``$HUADIAN_DATA_DIR/dictionaries``
        2. Fallback: walk up from this file location.
           This file lives at
               framework/identity_resolver/examples/huadian_classics/dictionary_loaders.py
           so the project root is 4 levels up:
               parents[0]=huadian_classics, [1]=examples, [2]=identity_resolver,
               [3]=framework, [4]=<project_root>

    Cross-domain re-use note: callers may also pass ``dict_dir`` directly to
    :class:`HuaDianDictionaryLoader` to override entirely.
    """
    env = os.environ.get("HUADIAN_DATA_DIR")
    if env:
        return Path(env) / "dictionaries"
    return Path(__file__).resolve().parents[4] / "data" / "dictionaries"


def _load_yaml_safe(path: Path) -> Any:
    """Load a YAML file, returning None on failure (warning, not crash)."""
    if not _HAS_YAML:
        warnings.warn(
            "PyYAML is not installed; HuaDian dictionary-based rules disabled.",
            stacklevel=3,
        )
        return None
    if not path.exists():
        warnings.warn(
            f"HuaDian dictionary file not found: {path}; related rule disabled.",
            stacklevel=3,
        )
        return None
    try:
        with path.open(encoding="utf-8") as fh:
            return yaml.safe_load(fh)
    except Exception as exc:  # noqa: BLE001
        warnings.warn(
            f"Failed to load HuaDian dictionary {path}: {exc}; rule disabled.",
            stacklevel=3,
        )
        return None


class HuaDianDictionaryLoader:
    """Implementation of `DictionaryLoader` Protocol for HuaDian classics.

    Lazy-loads tongjia.yaml + miaohao.yaml on first call to each method.
    Subsequent calls return cached dicts.
    """

    def __init__(self, dict_dir: Path | None = None) -> None:
        self._dict_dir = dict_dir or _default_dict_dir()
        self._tongjia_cache: dict[str, str] | None = None
        self._miaohao_cache: dict[tuple[str, str], dict[str, Any]] | None = None

    def load_synonym_dict(self) -> dict[str, str]:
        """Load tongjia.yaml → variant→canonical mapping (used by R3)."""
        if self._tongjia_cache is not None:
            return self._tongjia_cache

        data = _load_yaml_safe(self._dict_dir / "tongjia.yaml")
        index: dict[str, str] = {}
        if data is not None:
            for entry in data.get("entries", []):
                variant = entry.get("variant", "").strip()
                canonical = entry.get("canonical", "").strip()
                if variant and canonical:
                    index[variant] = canonical
        self._tongjia_cache = index
        logger.debug("HuaDian tongjia loaded: %d entries", len(index))
        return index

    def load_alias_dict(self) -> dict[tuple[str, str], dict[str, Any]]:
        """Load miaohao.yaml → bidirectional alias pair → entry mapping (R5).

        Both orderings (a, b) and (b, a) are indexed so lookup is
        order-independent. Each entry's "dynasty" field is used by R5's
        cross-dynasty guard.
        """
        if self._miaohao_cache is not None:
            return self._miaohao_cache

        data = _load_yaml_safe(self._dict_dir / "miaohao.yaml")
        index: dict[tuple[str, str], dict[str, Any]] = {}
        if data is not None:
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
        self._miaohao_cache = index
        logger.debug("HuaDian miaohao loaded: %d pairs", len(index))
        return index

    def reset_cache(self) -> None:
        """Reset cached dictionaries (for testing)."""
        self._tongjia_cache = None
        self._miaohao_cache = None
