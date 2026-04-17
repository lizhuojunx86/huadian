"""Root conftest — ensure editable src is on sys.path.

Hatchling editable installs produce .pth files that some uv/venv
combinations fail to process (quoted paths, stale duplicates).
This conftest provides a reliable fallback so that
``import huadian_pipeline`` always resolves to
``services/pipeline/src/huadian_pipeline``.
"""

from __future__ import annotations

import sys
from pathlib import Path

_SRC = str(Path(__file__).resolve().parent.parent / "src")
if _SRC not in sys.path:
    sys.path.insert(0, _SRC)
