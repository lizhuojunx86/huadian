"""HuaDian classics — R4 identity_notes regex patterns plugin.

Patterns for parsing identity_notes text in classical Chinese for references
to other persons. Used by R4 to generate hypotheses (not auto-merges).

License: Apache 2.0
Source: lifted from `services/pipeline/src/huadian_pipeline/resolve_rules.py`
        `_IDENTITY_NOTES_PATTERNS`.
"""

from __future__ import annotations

import re


class HuaDianNotesPatterns:
    """Implementation of `IdentityNotesPatterns` Protocol for HuaDian.

    Pattern semantics (Chinese):
        与X同人:    "X is the same person as ..."
        即X:        "X is none other than ..."
        X又名Y:     "X is also named Y"
        或即X:      "or possibly X"
        一说为X:    "one account says X"
    """

    _PATTERNS = [
        re.compile(r"与(.{1,8})同人"),
        re.compile(r"即(.{1,8})"),
        re.compile(r"(.{1,8})又名(.{1,8})"),
        re.compile(r"或即(.{1,8})"),
        re.compile(r"一说为(.{1,8})"),
    ]

    def get_patterns(self) -> list[re.Pattern[str]]:
        return self._PATTERNS
