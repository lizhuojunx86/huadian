#!/usr/bin/env python3
"""Enumerate person-field values in case-2 JSON data for redaction review.

ADR-040 §4: the 2026-06-11 desensitization verified itself by grepping a
known-term list — which cannot find terms missing from the list (the
2026-07-16 audit found 9 residual names exactly this way). This script
implements the stronger check: enumerate EVERY value of person-like fields
and print the unique set for human review. Anything that is not a role
pseudonym (操作工 L / 检验员R6 / QA C2 / ...) is a leak candidate.

Usage:
    python3 scripts/verify-person-fields.py [json_file ...]
    # default: docs/cases/tcm-extraction/data/pilot-WK-B1/batch-record.json

Exit code is always 0 — this is a review aid, not a gate; the commit gate
is scripts/check-privacy-sensitive.sh.
"""

from __future__ import annotations

import json
import re
import sys

PERSON_KEY = re.compile(r"(人|员|者|复核|审核|批准|QA|操作|递交|接收|指令|报告|检验|清场|称量)")
# values that are clearly not names (dates, lot codes, room codes, ...)
NON_NAME = re.compile(r"^[0-9L(2〔TE\-]|^\(签名\)$")

DEFAULT = ["docs/cases/tcm-extraction/data/pilot-WK-B1/batch-record.json"]


def walk(obj, found: dict[str, set[str]]) -> None:
    if isinstance(obj, dict):
        for key, val in obj.items():
            if isinstance(val, str) and PERSON_KEY.search(key) and 0 < len(val) <= 12:
                if not NON_NAME.match(val):
                    found.setdefault(val, set()).add(key)
            walk(val, found)
    elif isinstance(obj, list):
        for item in obj:
            walk(item, found)


def main(paths: list[str]) -> None:
    for path in paths:
        with open(path, encoding="utf-8") as fh:
            data = json.load(fh)
        found: dict[str, set[str]] = {}
        walk(data, found)
        print(f"== {path}: {len(found)} unique person-field values ==")
        for val in sorted(found):
            keys = ", ".join(sorted(found[val])[:4])
            print(f"  {val!r}  <- {keys}")
        print("Review: every value above must be a role pseudonym (ADR-040).")


if __name__ == "__main__":
    main(sys.argv[1:] or DEFAULT)
