"""HuaDian classics — HistorianAllowlist reference impl.

Reads ``apps/web/lib/historian-allowlist.yaml`` to bootstrap a
:class:`StaticAllowlist` (or any custom set). Falls back to the
hard-coded production roster if the YAML is missing.

Resolution priority (per Sprint P DGF-O-01 pattern):
    1. ``HUADIAN_DATA_DIR`` / ``HUADIAN_HISTORIAN_ALLOWLIST_PATH`` env var
    2. ``apps/web/lib/historian-allowlist.yaml`` walk-up fallback
    3. Hard-coded production set

License: Apache 2.0
Source: extracted from services/api/src/services/triage.service.ts
        HISTORIAN_ALLOWLIST constant + apps/web/lib/historian-allowlist.yaml.
"""

from __future__ import annotations

import logging
import os
from pathlib import Path

from framework.audit_triage import StaticAllowlist

try:
    import yaml

    _HAS_YAML = True
except ImportError:
    _HAS_YAML = False

logger = logging.getLogger(__name__)

# Hard-coded fallback — kept in sync with services/api triage.service.ts.
# Update both when adding / removing historians.
_HARD_CODED_ALLOWLIST: tuple[str, ...] = (
    "chief-historian",
    "backfill-script",
    "e2e-test",
    "historical-backfill",
)


def _default_allowlist_path() -> Path:
    """Locate ``historian-allowlist.yaml`` for HuaDian classics example.

    Priority:
        1. ``HUADIAN_HISTORIAN_ALLOWLIST_PATH`` (explicit override)
        2. ``HUADIAN_DATA_DIR`` env var → ``$HUADIAN_DATA_DIR/historian-allowlist.yaml``
        3. Walk-up to ``<project_root>/apps/web/lib/historian-allowlist.yaml``
           parents[0]=huadian_classics, [1]=examples, [2]=audit_triage,
           [3]=framework, [4]=<project_root>
    """
    explicit = os.environ.get("HUADIAN_HISTORIAN_ALLOWLIST_PATH")
    if explicit:
        return Path(explicit)
    data_dir = os.environ.get("HUADIAN_DATA_DIR")
    if data_dir:
        return Path(data_dir) / "historian-allowlist.yaml"
    return Path(__file__).resolve().parents[4] / "apps" / "web" / "lib" / "historian-allowlist.yaml"


def load_huadian_historian_allowlist(
    path: Path | None = None,
) -> StaticAllowlist:
    """Build a :class:`StaticAllowlist` from the HuaDian YAML roster.

    Falls back to the hard-coded production set when:
        - PyYAML is not installed
        - The YAML file is missing
        - The YAML file exists but cannot be parsed
    """
    if not _HAS_YAML:
        logger.warning("PyYAML not installed; using hard-coded HuaDian historian allowlist.")
        return StaticAllowlist(_HARD_CODED_ALLOWLIST)

    yaml_path = path or _default_allowlist_path()
    if not yaml_path.exists():
        logger.warning(
            "HuaDian historian-allowlist.yaml not found at %s; using hard-coded fallback.",
            yaml_path,
        )
        return StaticAllowlist(_HARD_CODED_ALLOWLIST)

    try:
        with yaml_path.open(encoding="utf-8") as fh:
            data = yaml.safe_load(fh) or {}
    except Exception as exc:  # noqa: BLE001
        logger.warning(
            "Failed to load HuaDian historian-allowlist.yaml (%s); using hard-coded fallback.",
            exc,
        )
        return StaticAllowlist(_HARD_CODED_ALLOWLIST)

    # YAML may be:
    #   {"historians": ["chief-historian", "alice", ...]}      (preferred shape)
    #   ["chief-historian", "alice", ...]                      (flat list shape)
    if isinstance(data, dict):
        ids = data.get("historians", [])
    elif isinstance(data, list):
        ids = data
    else:
        logger.warning(
            "Unexpected historian-allowlist.yaml shape (%s); using hard-coded fallback.",
            type(data).__name__,
        )
        return StaticAllowlist(_HARD_CODED_ALLOWLIST)

    if not ids:
        logger.warning("historian-allowlist.yaml empty; using hard-coded fallback.")
        return StaticAllowlist(_HARD_CODED_ALLOWLIST)

    return StaticAllowlist(str(x) for x in ids)
