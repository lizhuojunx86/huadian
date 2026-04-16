"""Unit tests for common cross-step rules."""

from __future__ import annotations

from typing import Any

from huadian_pipeline.qc.rules.common_rules import (
    rule_confidence_threshold,
    rule_json_schema,
)
from huadian_pipeline.qc.types import CheckpointInput


def _mk_payload(
    outputs: dict[str, Any],
    *,
    metadata: dict[str, Any] | None = None,
) -> CheckpointInput:
    return CheckpointInput(
        step_name="ner_v3",
        trace_id="t1",
        prompt_version="v1",
        model="claude-opus-4-6",
        inputs={},
        outputs=outputs,
        metadata=metadata or {},
    )


# ---------------------------------------------------------------------------
# common.json_schema
# ---------------------------------------------------------------------------

def test_json_schema_noop_when_no_schema_in_metadata() -> None:
    v = rule_json_schema(_mk_payload({"foo": 1}))
    assert v == []


def test_json_schema_passes_valid_output() -> None:
    schema: dict[str, Any] = {
        "type": "object",
        "required": ["name", "age"],
        "properties": {"name": {"type": "string"}, "age": {"type": "integer"}},
    }
    payload = _mk_payload(
        {"name": "韩信", "age": 36},
        metadata={"output_schema": schema},
    )
    assert rule_json_schema(payload) == []


def test_json_schema_flags_missing_required_field() -> None:
    schema: dict[str, Any] = {
        "type": "object",
        "required": ["name", "age"],
        "properties": {"name": {"type": "string"}, "age": {"type": "integer"}},
    }
    payload = _mk_payload(
        {"name": "韩信"},
        metadata={"output_schema": schema},
    )
    vs = rule_json_schema(payload)
    assert len(vs) == 1
    assert "age" in vs[0].message


def test_json_schema_flags_malformed_schema_metadata() -> None:
    payload = _mk_payload({}, metadata={"output_schema": "not-a-dict"})
    vs = rule_json_schema(payload)
    assert len(vs) == 1
    assert "expected dict" in vs[0].message


# ---------------------------------------------------------------------------
# common.confidence_threshold
# ---------------------------------------------------------------------------

def test_confidence_noop_when_outputs_has_no_confidence() -> None:
    v = rule_confidence_threshold(_mk_payload({"entities": []}))
    assert v == []


def test_confidence_passes_above_default_threshold() -> None:
    v = rule_confidence_threshold(_mk_payload({"confidence": 0.9}))
    assert v == []


def test_confidence_flags_below_default_threshold() -> None:
    vs = rule_confidence_threshold(_mk_payload({"confidence": 0.2}))
    assert len(vs) == 1
    assert "0.200" in vs[0].message
    assert "0.500" in vs[0].message


def test_confidence_custom_threshold_via_metadata() -> None:
    # 0.7 passes default 0.5 but fails a custom 0.9 threshold.
    payload = _mk_payload(
        {"confidence": 0.7},
        metadata={"min_confidence": 0.9},
    )
    vs = rule_confidence_threshold(payload)
    assert len(vs) == 1


def test_confidence_flags_uncoercible_value() -> None:
    payload = _mk_payload({"confidence": "not-a-number"})
    vs = rule_confidence_threshold(payload)
    assert len(vs) == 1
    assert "not coercible" in vs[0].message


def test_confidence_flags_uncoercible_threshold() -> None:
    payload = _mk_payload(
        {"confidence": 0.9},
        metadata={"min_confidence": "bogus"},
    )
    vs = rule_confidence_threshold(payload)
    assert len(vs) == 1
    assert "metadata.min_confidence" in vs[0].message
