"""NER-step rules.

Expected payload shape (华典 NER output contract):

    payload.inputs["paragraph_text"]: str
    payload.outputs["entities"]: list[dict]
        each: {
            "surface_form": str,   # literal text span
            "entity_type":  str,   # e.g. PERSON / PLACE / EVENT
            "entity_id":    str,   # disambiguation target; per-paragraph
                                    # uniqueness not required (same person
                                    # may appear twice with different
                                    # surface_form)
            "confidence":   float,
            ...
        }

Rules here tolerate missing / mistyped fields by returning violations
rather than crashing: a malformed entity is *itself* a finding.
"""

from __future__ import annotations

from typing import Any

from ..types import CheckpointInput, Severity, Violation

# ---------------------------------------------------------------------------
# Rule: ner.surface_in_source
# ---------------------------------------------------------------------------

_RULE_ID_SURFACE = "ner.surface_in_source"
_SEV_SURFACE: Severity = "critical"


def rule_surface_in_source(payload: CheckpointInput) -> list[Violation]:
    """Every `entities[i].surface_form` must be a substring of the source.

    Grounded extraction is a core 华典 constitution invariant (C-2 /
    C-7). If the model paraphrases rather than quotes, we cannot later
    align the mention back to the raw_text, breaking provenance.
    """
    source_text = payload.inputs.get("paragraph_text", "")
    if not isinstance(source_text, str):
        # defensively flag; a non-str paragraph_text is a pipeline bug
        return [
            Violation(
                rule_id=_RULE_ID_SURFACE,
                severity=_SEV_SURFACE,
                message=(
                    f"inputs.paragraph_text expected str, got "
                    f"{type(source_text).__name__}"
                ),
                location={"field": "inputs.paragraph_text"},
            )
        ]

    entities = payload.outputs.get("entities", [])
    if not isinstance(entities, list):
        return [
            Violation(
                rule_id=_RULE_ID_SURFACE,
                severity=_SEV_SURFACE,
                message=(
                    f"outputs.entities expected list, got "
                    f"{type(entities).__name__}"
                ),
                location={"field": "outputs.entities"},
            )
        ]

    out: list[Violation] = []
    for i, ent in enumerate(entities):
        if not isinstance(ent, dict):
            out.append(
                Violation(
                    rule_id=_RULE_ID_SURFACE,
                    severity=_SEV_SURFACE,
                    message=f"entity {i} not a dict",
                    location={"field": f"outputs.entities[{i}]"},
                )
            )
            continue
        surface = ent.get("surface_form")
        if not isinstance(surface, str) or not surface:
            out.append(
                Violation(
                    rule_id=_RULE_ID_SURFACE,
                    severity=_SEV_SURFACE,
                    message=f"entity {i} missing / empty surface_form",
                    location={"field": f"outputs.entities[{i}].surface_form"},
                )
            )
            continue
        if surface not in source_text:
            out.append(
                Violation(
                    rule_id=_RULE_ID_SURFACE,
                    severity=_SEV_SURFACE,
                    message=(
                        f"entity surface_form {surface!r} not found in "
                        f"paragraph_text"
                    ),
                    location={"field": f"outputs.entities[{i}].surface_form"},
                    suggested_fix=(
                        "ensure prompt enforces grounded extraction "
                        "(quote verbatim spans)"
                    ),
                )
            )
    return out


# ---------------------------------------------------------------------------
# Rule: ner.no_duplicate_entities
# ---------------------------------------------------------------------------

_RULE_ID_NO_DUP = "ner.no_duplicate_entities"
_SEV_NO_DUP: Severity = "major"


def rule_no_duplicate_entities(payload: CheckpointInput) -> list[Violation]:
    """No two entities share the same `(surface_form, entity_type)`.

    We allow the same *person* (identity) to appear twice with
    different surface forms — the identity layer lives upstream in
    person_names / identity_hypotheses. What we forbid here is the
    model emitting the *literal same extraction twice*, which would
    double-count mentions downstream.
    """
    entities = payload.outputs.get("entities", [])
    if not isinstance(entities, list):
        return []  # shape errors are surface_in_source's territory

    seen: dict[tuple[str, str], int] = {}
    out: list[Violation] = []
    for i, ent in enumerate(entities):
        if not isinstance(ent, dict):
            continue
        key = (
            str(ent.get("surface_form", "")),
            str(ent.get("entity_type", "")),
        )
        if key[0] == "" or key[1] == "":
            continue  # surface_in_source will flag
        if key in seen:
            out.append(
                Violation(
                    rule_id=_RULE_ID_NO_DUP,
                    severity=_SEV_NO_DUP,
                    message=(
                        f"duplicate entity (surface_form={key[0]!r}, "
                        f"entity_type={key[1]!r}) at indexes "
                        f"{seen[key]} and {i}"
                    ),
                    location={"field": f"outputs.entities[{i}]", "first_at": seen[key]},
                    suggested_fix="dedupe in the prompt or in post-processing",
                )
            )
        else:
            seen[key] = i
    return out


# ---------------------------------------------------------------------------
# Registry manifest
# ---------------------------------------------------------------------------

RULES: list[tuple[str, Any, Severity, list[str]]] = [
    (_RULE_ID_SURFACE, rule_surface_in_source,   _SEV_SURFACE, ["ner_*"]),
    (_RULE_ID_NO_DUP,  rule_no_duplicate_entities, _SEV_NO_DUP,  ["ner_*"]),
]
