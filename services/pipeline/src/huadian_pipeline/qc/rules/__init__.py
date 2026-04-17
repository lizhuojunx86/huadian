"""First batch of 华典 Python rules (T-TG-002 S-4).

Each sub-module exposes a `RULES: list[tuple[rule_id, fn, severity, step_patterns]]`
so the registry can batch-register via `RuleRegistry.register_from_module`.

Rule fns follow the uniform signature `(CheckpointInput) -> list[Violation]`.
The registry overrides `rule_id` / `severity` with its registration-time
values on every returned violation — the fn only really owns
`message` / `location` / `suggested_fix`.

Catalogue (5 rules, ADR-004 §九 minimum):

  common.json_schema              — outputs match a declared JSON Schema
  common.confidence_threshold     — output-level `confidence` >= threshold
  ner.surface_in_source           — entities[].surface_form appears in
                                     inputs.paragraph_text
  ner.no_duplicate_entities       — (surface_form, entity_type) unique
  relation.participants_exist     — relations[].subject_id / object_id
                                     point at an entity in this paragraph
"""

from __future__ import annotations

from . import common_rules, ner_rules, relation_rules

__all__ = ["common_rules", "ner_rules", "relation_rules"]
