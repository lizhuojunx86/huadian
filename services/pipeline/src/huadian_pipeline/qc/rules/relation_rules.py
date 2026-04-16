"""Relation-step rules.

Expected payload shape (华典 relation output contract):

    payload.outputs["entities"]: list[dict]  (carry-over from NER step,
                                              Adapter is expected to
                                              include upstream outputs)
    payload.outputs["relations"]: list[dict]
        each: {
            "subject_id":  str,   # must match an entity_id in entities
            "predicate":   str,   # relation kind
            "object_id":   str,   # must match an entity_id in entities
            ...
        }

Matching `entity_id` is a local-paragraph constraint; cross-paragraph
resolution lives in the identity-hypothesis layer and is out of scope
for this rule.
"""

from __future__ import annotations

from typing import Any

from ..types import CheckpointInput, Severity, Violation

# ---------------------------------------------------------------------------
# Rule: relation.participants_exist
# ---------------------------------------------------------------------------

_RULE_ID_PARTICIPANTS = "relation.participants_exist"
_SEV_PARTICIPANTS: Severity = "critical"


def rule_participants_exist(payload: CheckpointInput) -> list[Violation]:
    """Every relation's subject_id / object_id must exist in entities."""
    entities = payload.outputs.get("entities", [])
    relations = payload.outputs.get("relations", [])

    if not isinstance(entities, list) or not isinstance(relations, list):
        return []  # shape errors handled upstream

    known_ids: set[str] = set()
    for ent in entities:
        if isinstance(ent, dict):
            eid = ent.get("entity_id")
            if isinstance(eid, str) and eid:
                known_ids.add(eid)

    out: list[Violation] = []
    for i, rel in enumerate(relations):
        if not isinstance(rel, dict):
            out.append(
                Violation(
                    rule_id=_RULE_ID_PARTICIPANTS,
                    severity=_SEV_PARTICIPANTS,
                    message=f"relation {i} not a dict",
                    location={"field": f"outputs.relations[{i}]"},
                )
            )
            continue
        for side in ("subject_id", "object_id"):
            val = rel.get(side)
            if not isinstance(val, str) or not val:
                out.append(
                    Violation(
                        rule_id=_RULE_ID_PARTICIPANTS,
                        severity=_SEV_PARTICIPANTS,
                        message=f"relation {i} missing / empty {side}",
                        location={"field": f"outputs.relations[{i}].{side}"},
                    )
                )
                continue
            if val not in known_ids:
                out.append(
                    Violation(
                        rule_id=_RULE_ID_PARTICIPANTS,
                        severity=_SEV_PARTICIPANTS,
                        message=(
                            f"relation {i} {side}={val!r} references an "
                            f"entity not present in this paragraph's entities"
                        ),
                        location={"field": f"outputs.relations[{i}].{side}"},
                        suggested_fix=(
                            "either extract the missing entity in NER step "
                            "or drop the relation"
                        ),
                    )
                )
    return out


# ---------------------------------------------------------------------------
# Registry manifest
# ---------------------------------------------------------------------------

RULES: list[tuple[str, Any, Severity, list[str]]] = [
    (_RULE_ID_PARTICIPANTS, rule_participants_exist, _SEV_PARTICIPANTS, ["relation_*"]),
]
