"""华典-side Python rule registry (T-TG-002 S-4).

A `RuleFn` is a pure function `(CheckpointInput) -> list[Violation]`
that returns zero or more findings about the payload. Each rule is
registered with:
  - `rule_id`         — stable identifier (e.g. "ner.surface_in_source")
  - `severity`        — critical / major / minor / info, **assigned at
                        registration time** (never inferred from TG
                        action or from whatever the rule fn happens to
                        put in `Violation.severity`)
  - `step_patterns`   — fnmatch globs naming the pipeline steps this
                        rule applies to (e.g. `["ner_*"]`); `None` or
                        empty means "every step"

Design notes:

* Rule fns still return `list[Violation]` — we keep the signature
  uniform with ADR-004 §四 so reviewers don't have to learn a second
  shape. The registry **overwrites** `rule_id` and `severity` on every
  returned `Violation` using the register-time values: single source
  of truth. The fn therefore only really owns `message` / `location` /
  `suggested_fix`.

* `RuleSet` is returned by `RuleRegistry.for_step(step_name)` and
  pre-filters the matching rules so the hot-path in the Adapter is
  O(rules-for-step) rather than O(all-rules) per checkpoint.

* Registration order is preserved on iteration so that unit tests can
  predict the violation order without stability gymnastics.
"""

from __future__ import annotations

import fnmatch
from collections.abc import Callable
from dataclasses import dataclass, field, replace
from typing import TYPE_CHECKING

from .types import CheckpointInput, Severity, Violation

if TYPE_CHECKING:
    from types import ModuleType

RuleFn = Callable[[CheckpointInput], list[Violation]]


@dataclass(frozen=True, slots=True)
class RegisteredRule:
    """Internal record created by `RuleRegistry.register`.

    Immutable so the registry can hand out references safely.
    """

    rule_id: str
    fn: RuleFn
    severity: Severity
    step_patterns: tuple[str, ...] = ()  # empty tuple = match every step

    def matches(self, step_name: str) -> bool:
        if not self.step_patterns:
            return True
        return any(fnmatch.fnmatchcase(step_name, pat) for pat in self.step_patterns)


class DuplicateRuleIdError(ValueError):
    """Raised when the same `rule_id` is registered twice.

    Registrations must be globally unique by `rule_id` so that
    `extractions_history.traceguard_raw` can reference a violation
    unambiguously across runs.
    """


@dataclass(slots=True)
class RuleSet:
    """A filtered, frozen view of the registry for a single step.

    Holds the matched RegisteredRule objects and knows how to run them
    against a payload, normalising the results so that the caller does
    not have to trust a third-party rule fn to set `rule_id` /
    `severity` correctly.
    """

    step_name: str
    rules: tuple[RegisteredRule, ...] = ()

    def run_all(self, payload: CheckpointInput) -> list[Violation]:
        """Execute every matching rule and return aggregated violations.

        Each `Violation` returned by a rule is **overwritten** with the
        registration-time `rule_id` and `severity` — the rule fn's own
        values for those fields are ignored on purpose. Preserves the
        fn's `message`, `location`, `suggested_fix`.
        """
        out: list[Violation] = []
        for rule in self.rules:
            findings = rule.fn(payload)
            for v in findings:
                out.append(replace(v, rule_id=rule.rule_id, severity=rule.severity))
        return out


@dataclass(slots=True)
class RuleRegistry:
    """The registry itself.

    Usage:

        reg = RuleRegistry()
        reg.register("ner.surface_in_source",
                     rule_surface_in_source,
                     severity="critical",
                     step_patterns=["ner_*"])
        # or load a module that exposes a RULES list:
        reg.register_from_module(ner_rules)

        # Later, in Adapter.checkpoint:
        violations = reg.for_step(payload.step_name).run_all(payload)
    """

    _rules: list[RegisteredRule] = field(default_factory=list)
    _ids: set[str] = field(default_factory=set)

    def register(
        self,
        rule_id: str,
        fn: RuleFn,
        *,
        severity: Severity,
        step_patterns: list[str] | None = None,
    ) -> None:
        if rule_id in self._ids:
            raise DuplicateRuleIdError(f"rule_id {rule_id!r} already registered")
        self._ids.add(rule_id)
        self._rules.append(
            RegisteredRule(
                rule_id=rule_id,
                fn=fn,
                severity=severity,
                step_patterns=tuple(step_patterns or ()),
            )
        )

    def register_from_module(self, module: ModuleType) -> None:
        """Register every `(rule_id, fn, severity, step_patterns)` tuple
        from `module.RULES`. Missing attribute raises AttributeError —
        callers should use a module that truly exposes rules.
        """
        rules: list[tuple[str, RuleFn, Severity, list[str]]] = module.RULES
        for rule_id, fn, severity, step_patterns in rules:
            self.register(rule_id, fn, severity=severity, step_patterns=step_patterns)

    def for_step(self, step_name: str) -> RuleSet:
        matched = tuple(r for r in self._rules if r.matches(step_name))
        return RuleSet(step_name=step_name, rules=matched)

    def __len__(self) -> int:
        return len(self._rules)

    @property
    def rule_ids(self) -> tuple[str, ...]:
        return tuple(r.rule_id for r in self._rules)
