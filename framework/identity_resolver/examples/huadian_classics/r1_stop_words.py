"""HuaDian classics — R1 stop words plugin.

Generic Chinese titles / self-references that must never serve as identity
signals (they appear in many unrelated persons' surface_forms).

License: Apache 2.0
Source: lifted from `services/pipeline/src/huadian_pipeline/resolve_rules.py`
        `_R1_STOP_WORDS`.
"""

from __future__ import annotations


class HuaDianStopWords:
    """Implementation of the `StopWordPlugin` Protocol for HuaDian classics.

    Stop word categories:
        - Single-char generic titles: 王 / 帝 / 后 / 朕
        - Multi-char self-references: 予一人 ("I, the One")
        - Posthumous titles shared across dynasties: 武王
          (e.g. 商汤 self-titled 武王; 周武王 is a different person)
    """

    _STOP_WORDS = frozenset(
        {
            "王",
            "帝",
            "后",
            "朕",
            "予一人",
            "武王",
        }
    )

    def get_stop_words(self) -> frozenset[str]:
        return self._STOP_WORDS
