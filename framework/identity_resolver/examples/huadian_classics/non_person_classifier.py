"""HuaDian classics — non-person entity classifier (HuaDian-specific).

Detects entities that look like persons but are actually:
    - tribal_group:        部族/族群 (荤粥, 三苗, etc.)
    - clan_surname:        single-char + 氏 (姒氏, 姬氏)
    - abstract_collective: 百姓, 万国, etc.

Used by HuaDian's pipeline as a pre-resolution filter — non-person
entities are tagged for separate handling. Not part of the framework
(it's a HuaDian-specific data-quality concern), but kept here as a
reference for case domains that have similar "false person" patterns.

License: Apache 2.0
Source: lifted from `services/pipeline/src/huadian_pipeline/resolve_rules.py`
        `is_likely_non_person` + related dictionaries.
"""

from __future__ import annotations

from framework.identity_resolver import EntitySnapshot

# Rulers / legendary figures whose names end in 氏 but are individuals.
# Checked BEFORE the X氏 suffix rule so they're never misclassified.
HONORIFIC_SHI_WHITELIST = frozenset(
    {
        "神农氏",
        "伏羲氏",
        "女娲氏",
        "轩辕氏",
        "少昊氏",
        "少暤氏",
        "颛顼氏",
        "高阳氏",
        "高辛氏",
        "有熊氏",
        "帝鸿氏",
        "缙云氏",
        "涂山氏",
    }
)

# Names that are unambiguously not individual persons.
KNOWN_NON_PERSON_NAMES: dict[str, str] = {
    # Tribal / ethnic groups
    "荤粥": "tribal_group",
    "猃狁": "tribal_group",
    "鬼方": "tribal_group",
    "山戎": "tribal_group",
    "三苗": "tribal_group",
    # Abstract collectives
    "百姓": "abstract_collective",
    "万国": "abstract_collective",
}


def is_likely_non_person(p: EntitySnapshot) -> tuple[bool, str]:
    """Determine if an EntitySnapshot is likely not an individual person.

    Evaluation order:
      1. HONORIFIC_SHI_WHITELIST → keep (return False)
      2. KNOWN_NON_PERSON_NAMES  → reject (return True, category)
      3. X氏 suffix pattern:
         a. surface_forms contains the bare name → keep (ambiguous)
         b. single-char + 氏 → clan_surname
         c. multi-char + 氏 → tribal_group
    """
    name = p.name

    if name in HONORIFIC_SHI_WHITELIST:
        return (False, "")

    if name in KNOWN_NON_PERSON_NAMES:
        return (True, KNOWN_NON_PERSON_NAMES[name])

    if name.endswith("氏") and len(name) >= 2:
        bare_name = name[:-1]
        if bare_name in p.surface_forms:
            return (False, "")
        if len(bare_name) == 1:
            return (True, "clan_surname")
        return (True, "tribal_group")

    return (False, "")
