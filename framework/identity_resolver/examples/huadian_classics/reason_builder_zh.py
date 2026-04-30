"""HuaDian classics — Chinese-localized ReasonBuilder.

Translates rule labels and canonical-selection rationale to Chinese for
HuaDian's dry-run reports. Pass an instance to `generate_dry_run_report()`
or `resolve_identities()` to get Chinese-language output.

License: Apache 2.0
Source: extracted from `services/pipeline/src/huadian_pipeline/resolve.py`
        `_format_rule_evidence` + `_build_reason`.
"""

from __future__ import annotations

import re
from typing import Any


class HuaDianReasonBuilderZh:
    """Implementation of `ReasonBuilder` Protocol — Chinese-localized.

    Recognizes R1-R6 + the HuaDian-specific R2 帝X rule. Falls through to
    a generic format for unknown rules.
    """

    def format_rule_evidence(self, rule: str, ev: dict[str, Any]) -> str:  # noqa: PLR0911
        if rule == "R1":
            overlap = ", ".join(ev.get("overlap", []))
            return f"R1 表面形式重叠: {overlap}"
        if rule == "R2":
            direction = ev.get("direction", "")
            return f"R2 帝X 前缀: {direction}"
        if rule == "R3":
            a = ev.get("a_original") or ev.get("a_surface", "?")
            b = ev.get("b_original") or ev.get("b_surface", "?")
            norm = ev.get("normalized", "?")
            mappings = ev.get("mapping_used", {})
            src = ", ".join(f"{k}→{v}" for k, v in mappings.items()) if mappings else ""
            src_str = f" (来源: {src})" if src else ""
            return f"R3 通假字 {a}→{b} (→{norm}){src_str}"
        if rule == "R4":
            return (
                f"R4 identity_notes 交叉引用 "
                f"(a_mentions_b={ev.get('a_mentions_b')}, b_mentions_a={ev.get('b_mentions_a')})"
            )
        if rule == "R5":
            canon = ev.get("dict_canonical", "?")
            alias = ev.get("dict_alias", "?")
            source = ev.get("source", "")
            src_str = f" (来源: {source})" if source else ""
            return f"R5 庙号/谥号 {canon}/{alias}{src_str}"
        if rule == "R6":
            qid = ev.get("external_id", "?")
            source = ev.get("source", "wikidata")
            return f"R6 外部锚点 {source}:{qid}"
        return f"{rule} unknown evidence"

    def format_canonical_reason(self, canonical_name: str, canonical_slug: str) -> str:
        return "拼音 slug" if _slug_is_pinyin(canonical_slug) else "最多 surface forms"


def _slug_is_pinyin(slug: str) -> bool:
    return not bool(re.match(r"^u[0-9a-f]{4}", slug))
