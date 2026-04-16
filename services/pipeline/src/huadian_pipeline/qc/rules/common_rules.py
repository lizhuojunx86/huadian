"""Cross-step common rules.

These apply to every LLM extraction step regardless of entity type.
Keep the dependency surface minimal — only `jsonschema` is brought in
(transitive via TG, but we also list it directly in pyproject once
rules are wired into production CI).
"""

from __future__ import annotations

from typing import Any

import jsonschema
from jsonschema.exceptions import ValidationError

from ..types import CheckpointInput, Severity, Violation

# ---------------------------------------------------------------------------
# Rule: common.json_schema
# ---------------------------------------------------------------------------

_RULE_ID_JSON_SCHEMA = "common.json_schema"
_SEV_JSON_SCHEMA: Severity = "critical"


def rule_json_schema(payload: CheckpointInput) -> list[Violation]:
    """Validate `payload.outputs` against a JSON Schema carried in metadata.

    The Adapter pipes `payload.metadata["output_schema"]` from the prompt
    version manifest. If the schema is missing this rule is a no-op (we
    would rather not fire than fire on every step that hasn't declared
    one yet). Schema *present but invalid* is reported as a critical
    violation so misconfigured prompts fail loud.
    """
    schema = payload.metadata.get("output_schema")
    if schema is None:
        return []
    if not isinstance(schema, dict):
        return [
            Violation(
                rule_id=_RULE_ID_JSON_SCHEMA,
                severity=_SEV_JSON_SCHEMA,
                message=(
                    f"metadata.output_schema expected dict, got "
                    f"{type(schema).__name__}"
                ),
                location={"field": "metadata.output_schema"},
                suggested_fix="check prompt version manifest",
            )
        ]
    try:
        jsonschema.validate(instance=payload.outputs, schema=schema)
    except ValidationError as err:
        path = ".".join(str(p) for p in err.absolute_path) or "<root>"
        return [
            Violation(
                rule_id=_RULE_ID_JSON_SCHEMA,
                severity=_SEV_JSON_SCHEMA,
                message=f"JSON Schema validation failed at {path}: {err.message}",
                location={"field": path, "schema_path": list(err.absolute_schema_path)},
                suggested_fix="check prompt outputs shape or update schema",
            )
        ]
    return []


# ---------------------------------------------------------------------------
# Rule: common.confidence_threshold
# ---------------------------------------------------------------------------

_RULE_ID_CONFIDENCE = "common.confidence_threshold"
_SEV_CONFIDENCE: Severity = "major"
_DEFAULT_MIN_CONFIDENCE = 0.5


def rule_confidence_threshold(payload: CheckpointInput) -> list[Violation]:
    """Check a top-level `confidence` field in outputs meets a threshold.

    Threshold default 0.5, overridable via
    `payload.metadata["min_confidence"]`. The rule is a no-op when the
    output is not a dict or when it does not declare `confidence`
    (some prompts don't emit one — use a JSON-Schema rule to force
    presence if you want that).
    """
    if not isinstance(payload.outputs, dict):
        return []
    if "confidence" not in payload.outputs:
        return []

    threshold_any: Any = payload.metadata.get(
        "min_confidence", _DEFAULT_MIN_CONFIDENCE
    )
    try:
        threshold = float(threshold_any)
    except (TypeError, ValueError):
        return [
            Violation(
                rule_id=_RULE_ID_CONFIDENCE,
                severity=_SEV_CONFIDENCE,
                message=(
                    f"metadata.min_confidence not coercible to float: "
                    f"{threshold_any!r}"
                ),
                location={"field": "metadata.min_confidence"},
            )
        ]

    raw_conf = payload.outputs["confidence"]
    try:
        conf = float(raw_conf)
    except (TypeError, ValueError):
        return [
            Violation(
                rule_id=_RULE_ID_CONFIDENCE,
                severity=_SEV_CONFIDENCE,
                message=f"outputs.confidence not coercible to float: {raw_conf!r}",
                location={"field": "outputs.confidence"},
                suggested_fix="ensure prompt emits numeric confidence",
            )
        ]

    if conf < threshold:
        return [
            Violation(
                rule_id=_RULE_ID_CONFIDENCE,
                severity=_SEV_CONFIDENCE,
                message=(
                    f"outputs.confidence {conf:.3f} below threshold "
                    f"{threshold:.3f}"
                ),
                location={"field": "outputs.confidence"},
                suggested_fix="raise prompt quality, switch to a stronger model, or lower threshold",
            )
        ]
    return []


# ---------------------------------------------------------------------------
# Registry manifest
# ---------------------------------------------------------------------------

# (rule_id, fn, severity, step_patterns)  — step_patterns=[] means "all steps".
RULES: list[tuple[str, Any, Severity, list[str]]] = [
    (_RULE_ID_JSON_SCHEMA,  rule_json_schema,          _SEV_JSON_SCHEMA,  []),
    (_RULE_ID_CONFIDENCE,   rule_confidence_threshold, _SEV_CONFIDENCE,   []),
]
