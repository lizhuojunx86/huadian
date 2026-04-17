"""Unit tests for relation-step rules."""

from __future__ import annotations

from typing import Any

from huadian_pipeline.qc.rules.relation_rules import rule_participants_exist
from huadian_pipeline.qc.types import CheckpointInput


def _rel_payload(
    entities: list[dict[str, Any]],
    relations: list[dict[str, Any]],
) -> CheckpointInput:
    return CheckpointInput(
        step_name="relation_v2",
        trace_id="t1",
        prompt_version="v1",
        model="claude-opus-4-6",
        inputs={},
        outputs={"entities": entities, "relations": relations},
        metadata={},
    )


def test_participants_exist_passes_when_all_ids_resolve() -> None:
    vs = rule_participants_exist(
        _rel_payload(
            entities=[
                {"entity_id": "e1", "surface_form": "项羽"},
                {"entity_id": "e2", "surface_form": "刘邦"},
            ],
            relations=[{"subject_id": "e1", "predicate": "attacks", "object_id": "e2"}],
        )
    )
    assert vs == []


def test_participants_exist_flags_missing_subject() -> None:
    vs = rule_participants_exist(
        _rel_payload(
            entities=[{"entity_id": "e2", "surface_form": "刘邦"}],
            relations=[{"subject_id": "e1", "predicate": "attacks", "object_id": "e2"}],
        )
    )
    assert len(vs) == 1
    assert "subject_id" in vs[0].message
    assert "'e1'" in vs[0].message


def test_participants_exist_flags_missing_object() -> None:
    vs = rule_participants_exist(
        _rel_payload(
            entities=[{"entity_id": "e1", "surface_form": "项羽"}],
            relations=[{"subject_id": "e1", "predicate": "attacks", "object_id": "eX"}],
        )
    )
    assert len(vs) == 1
    assert "object_id" in vs[0].message


def test_participants_exist_flags_empty_id() -> None:
    vs = rule_participants_exist(
        _rel_payload(
            entities=[{"entity_id": "e1", "surface_form": "项羽"}],
            relations=[{"subject_id": "", "predicate": "attacks", "object_id": "e1"}],
        )
    )
    assert len(vs) == 1
    assert "empty subject_id" in vs[0].message


def test_participants_exist_noop_on_malformed_shape() -> None:
    # Shape errors are surface_in_source / json_schema territory, not ours.
    vs = rule_participants_exist(
        _rel_payload(entities="not-a-list", relations=[])  # type: ignore[arg-type]
    )
    assert vs == []
