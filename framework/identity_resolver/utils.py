"""Utility helpers for identity resolution — domain-agnostic.

License: Apache 2.0
Source: extracted from `services/pipeline/src/huadian_pipeline/resolve.py`
        (HuaDian Sprint N first-cut framework abstraction).
"""

from __future__ import annotations

from typing import Any


def swap_ab_payload(payload: dict[str, Any]) -> dict[str, Any]:
    """Swap *_a/*_b suffixed keys in a guard payload dict.

    Called when pair order is normalized (e.g. higher-UUID entity moved to
    the B slot for a DB CHECK constraint) — keeps report columns aligned
    with the post-swap entity order.

    Keys without _a/_b suffix (e.g. gap_years, threshold, name_a_normalized)
    are copied unchanged. The function preserves dict identity for keys
    without the suffix pattern.

    Example:
        >>> swap_ab_payload({"dynasty_a": "Han", "dynasty_b": "Tang", "gap": 5})
        {"dynasty_b": "Han", "dynasty_a": "Tang", "gap": 5}
    """
    result: dict[str, Any] = {}
    for k, v in payload.items():
        if k.endswith("_a"):
            result[k[:-2] + "_b"] = v
        elif k.endswith("_b"):
            result[k[:-2] + "_a"] = v
        else:
            result[k] = v
    return result
