"""Unit tests for NER-step rules."""

from __future__ import annotations

from typing import Any

from huadian_pipeline.qc.rules.ner_rules import (
    rule_no_duplicate_entities,
    rule_surface_in_source,
)
from huadian_pipeline.qc.types import CheckpointInput

_PARAGRAPH = "项羽引兵入咸阳，烧秦宫室，火三月不灭。韩信为楚将，后归刘邦。"


def _ner_payload(entities: list[dict[str, Any]]) -> CheckpointInput:
    return CheckpointInput(
        step_name="ner_v3",
        trace_id="t1",
        prompt_version="v1",
        model="claude-opus-4-6",
        inputs={"paragraph_text": _PARAGRAPH},
        outputs={"entities": entities},
        metadata={},
    )


# ---------------------------------------------------------------------------
# ner.surface_in_source
# ---------------------------------------------------------------------------


def test_surface_in_source_passes_when_every_surface_is_present() -> None:
    vs = rule_surface_in_source(
        _ner_payload(
            [
                {"surface_form": "项羽", "entity_type": "PERSON"},
                {"surface_form": "咸阳", "entity_type": "PLACE"},
                {"surface_form": "韩信", "entity_type": "PERSON"},
            ]
        )
    )
    assert vs == []


def test_surface_in_source_flags_missing_span() -> None:
    vs = rule_surface_in_source(
        _ner_payload(
            [
                {"surface_form": "刘邦", "entity_type": "PERSON"},  # in source
                {"surface_form": "曹操", "entity_type": "PERSON"},  # NOT in source
            ]
        )
    )
    assert len(vs) == 1
    assert "'曹操'" in vs[0].message


def test_surface_in_source_flags_empty_surface() -> None:
    vs = rule_surface_in_source(_ner_payload([{"surface_form": "", "entity_type": "PERSON"}]))
    assert len(vs) == 1
    assert "missing" in vs[0].message or "empty" in vs[0].message


def test_surface_in_source_flags_non_dict_entity() -> None:
    vs = rule_surface_in_source(
        _ner_payload(["项羽"])  # type: ignore[list-item]
    )
    assert len(vs) == 1
    assert "not a dict" in vs[0].message


def test_surface_in_source_flags_non_str_paragraph_text() -> None:
    payload = CheckpointInput(
        step_name="ner_v3",
        trace_id="t1",
        prompt_version="v1",
        model="m",
        inputs={"paragraph_text": 123},  # wrong type
        outputs={"entities": []},
    )
    vs = rule_surface_in_source(payload)
    assert len(vs) == 1
    assert "paragraph_text" in vs[0].message


# ---------------------------------------------------------------------------
# ner.no_duplicate_entities
# ---------------------------------------------------------------------------


def test_no_duplicate_passes_when_all_unique() -> None:
    vs = rule_no_duplicate_entities(
        _ner_payload(
            [
                {"surface_form": "项羽", "entity_type": "PERSON"},
                {"surface_form": "韩信", "entity_type": "PERSON"},
                {"surface_form": "咸阳", "entity_type": "PLACE"},
            ]
        )
    )
    assert vs == []


def test_no_duplicate_flags_exact_duplicate() -> None:
    vs = rule_no_duplicate_entities(
        _ner_payload(
            [
                {"surface_form": "项羽", "entity_type": "PERSON"},
                {"surface_form": "韩信", "entity_type": "PERSON"},
                {"surface_form": "项羽", "entity_type": "PERSON"},
            ]
        )
    )
    assert len(vs) == 1
    assert "first_at" in vs[0].location
    assert vs[0].location["first_at"] == 0


def test_no_duplicate_allows_same_surface_different_type() -> None:
    # 项羽 as PERSON and "项羽" as a literary allusion TOKEN should
    # coexist — different entity_type.
    vs = rule_no_duplicate_entities(
        _ner_payload(
            [
                {"surface_form": "项羽", "entity_type": "PERSON"},
                {"surface_form": "项羽", "entity_type": "ALLUSION"},
            ]
        )
    )
    assert vs == []
