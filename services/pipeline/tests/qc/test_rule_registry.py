"""Unit tests for RuleRegistry wiring.

Covers: register / register_from_module / for_step fnmatch routing /
severity + rule_id override / duplicate detection / empty registry
no-op. Adapter-level integration (TG + registry merge) lives in a
future `test_adapter.py`.
"""

from __future__ import annotations

import pytest

from huadian_pipeline.qc.rule_registry import (
    DuplicateRuleIdError,
    RuleRegistry,
)
from huadian_pipeline.qc.rules import ner_rules
from huadian_pipeline.qc.types import CheckpointInput, Violation


def _payload(step: str = "ner_v3") -> CheckpointInput:
    return CheckpointInput(
        step_name=step,
        trace_id="t1",
        prompt_version="v1",
        model="m",
        inputs={"paragraph_text": "项羽 韩信"},
        outputs={"entities": [{"surface_form": "曹操", "entity_type": "PERSON"}]},
    )


def test_empty_registry_for_step_returns_no_violations() -> None:
    reg = RuleRegistry()
    vs = reg.for_step("ner_v3").run_all(_payload())
    assert vs == []
    assert len(reg) == 0


def test_register_and_run_one_rule() -> None:
    reg = RuleRegistry()

    def one_rule(_p: CheckpointInput) -> list[Violation]:
        # Return a deliberately wrong rule_id / severity so we can
        # assert the registry overrides both.
        return [
            Violation(
                rule_id="WRONG",
                severity="info",
                message="hi",
            )
        ]

    reg.register("my.rule", one_rule, severity="critical", step_patterns=None)
    vs = reg.for_step("ner_v3").run_all(_payload())
    assert len(vs) == 1
    assert vs[0].rule_id == "my.rule"  # override kicked in
    assert vs[0].severity == "critical"  # override kicked in
    assert vs[0].message == "hi"  # preserved


def test_register_duplicate_rule_id_raises() -> None:
    reg = RuleRegistry()
    reg.register("r", lambda _p: [], severity="minor")
    with pytest.raises(DuplicateRuleIdError):
        reg.register("r", lambda _p: [], severity="minor")


def test_for_step_filters_by_fnmatch_pattern() -> None:
    reg = RuleRegistry()
    ner_fired = {"n": 0}
    rel_fired = {"n": 0}

    def ner_fn(_p: CheckpointInput) -> list[Violation]:
        ner_fired["n"] += 1
        return []

    def rel_fn(_p: CheckpointInput) -> list[Violation]:
        rel_fired["n"] += 1
        return []

    reg.register("ner.x", ner_fn, severity="minor", step_patterns=["ner_*"])
    reg.register("rel.y", rel_fn, severity="minor", step_patterns=["relation_*"])

    reg.for_step("ner_v3").run_all(_payload("ner_v3"))
    assert ner_fired["n"] == 1 and rel_fired["n"] == 0

    reg.for_step("relation_v2").run_all(_payload("relation_v2"))
    assert ner_fired["n"] == 1 and rel_fired["n"] == 1

    reg.for_step("event_v1").run_all(_payload("event_v1"))
    # neither fires on unrelated step
    assert ner_fired["n"] == 1 and rel_fired["n"] == 1


def test_empty_step_patterns_matches_every_step() -> None:
    reg = RuleRegistry()
    fired = {"n": 0}

    def fn(_p: CheckpointInput) -> list[Violation]:
        fired["n"] += 1
        return []

    reg.register("universal", fn, severity="minor", step_patterns=[])
    for step in ("ner_v3", "relation_v2", "events_v1"):
        reg.for_step(step).run_all(_payload(step))
    assert fired["n"] == 3


def test_register_from_module_loads_rules_list() -> None:
    reg = RuleRegistry()
    reg.register_from_module(ner_rules)
    # ner_rules exposes RULES with 2 entries — this is also a regression
    # guard against someone silently dropping a rule from that module.
    assert len(reg) == 2
    assert set(reg.rule_ids) == {
        "ner.surface_in_source",
        "ner.no_duplicate_entities",
    }

    # When aimed at a ner step, both rules fire and the surface rule
    # catches our intentionally broken fixture.
    vs = reg.for_step("ner_v3").run_all(_payload("ner_v3"))
    assert any(v.rule_id == "ner.surface_in_source" for v in vs)

    # Pointed at a non-ner step, step_patterns filters them all out.
    assert reg.for_step("relation_v2").run_all(_payload("relation_v2")) == []


def test_rule_ids_preserves_registration_order() -> None:
    reg = RuleRegistry()
    reg.register("a", lambda _p: [], severity="minor")
    reg.register("b", lambda _p: [], severity="minor")
    reg.register("c", lambda _p: [], severity="minor")
    assert reg.rule_ids == ("a", "b", "c")
