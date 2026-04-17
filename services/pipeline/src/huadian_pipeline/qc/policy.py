"""ActionPolicy — action escalation driven by severity × attempt × step.

Implements ADR-004 §五. The Adapter owns the decision of "what to do
when a checkpoint yields violations"; policy.yml owns "how to escalate
across attempts". Keeping the two decoupled means the yml file can be
hot-edited without touching Python.

Wire-up with the rest of qc/ (relevant design points):

* `ActionPolicy.make_escalator(...)` returns an object satisfying the
  existing `ActionEscalator` Protocol in `action_map.py` — no new
  abstraction. The Adapter keeps calling `maybe_escalate(...)` and the
  policy just fills the hook.

* `resolve(...)` is the pure policy-decision function; `make_escalator`
  is the adapter glue that binds step_name + max_severity + mode into
  the Protocol shape (which only carries base_action / confidence /
  attempt). Tests hit both surfaces.

* `mode="shadow"` forces `pass_through` regardless of severity, so the
  pipeline **records** findings without blocking — useful for new
  rules in observation period. `mode="off"` is handled at the Adapter
  level (before TG is even called); not policy's job.
"""

from __future__ import annotations

import fnmatch
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Literal

import yaml

from .action_map import ActionEscalator, ActionType
from .types import Severity, Violation

PolicyMode = Literal["enforce", "shadow", "off"]

# Severity ordering. Higher = worse. `None` in max_severity means
# "no violations at all" — handled separately.
_SEVERITY_RANK: dict[Severity, int] = {
    "info": 0,
    "minor": 1,
    "major": 2,
    "critical": 3,
}

_ALLOWED_ACTIONS: frozenset[str] = frozenset(
    {"pass_through", "retry", "degrade", "human_queue", "fail_fast"}
)


class PolicyConfigError(ValueError):
    """Raised when traceguard_policy.yml is structurally invalid."""


@dataclass(frozen=True, slots=True)
class PolicyDefaults:
    retry_backoff_ms: tuple[int, ...] = ()
    degrade_to: str = ""
    human_queue: str = ""


@dataclass(slots=True)
class ActionPolicy:
    """In-memory representation of traceguard_policy.yml."""

    defaults: PolicyDefaults
    by_severity: dict[Severity, list[ActionType]]
    by_step: dict[str, dict[Severity, list[ActionType]]] = field(default_factory=dict)

    # ------------------------------------------------------------------
    # Loading
    # ------------------------------------------------------------------

    @classmethod
    def from_yaml(cls, path: str | Path) -> ActionPolicy:
        p = Path(path)
        with p.open("r", encoding="utf-8") as f:
            raw = yaml.safe_load(f)
        if not isinstance(raw, dict):
            raise PolicyConfigError(f"{p}: top-level must be a mapping")
        return cls.from_dict(raw)

    @classmethod
    def from_dict(cls, raw: dict[str, Any]) -> ActionPolicy:
        defaults = _parse_defaults(raw.get("defaults", {}))
        by_severity = _parse_severity_table(raw.get("by_severity", {}), where="by_severity")
        if not by_severity:
            raise PolicyConfigError("by_severity is required and must cover at least one severity")
        by_step_raw: Any = raw.get("by_step", {}) or {}
        if not isinstance(by_step_raw, dict):
            raise PolicyConfigError("by_step must be a mapping")
        by_step: dict[str, dict[Severity, list[ActionType]]] = {}
        for step_pat, table in by_step_raw.items():
            if not isinstance(step_pat, str):
                raise PolicyConfigError(f"by_step key must be str, got {step_pat!r}")
            by_step[step_pat] = _parse_severity_table(table or {}, where=f"by_step[{step_pat!r}]")
        return cls(defaults=defaults, by_severity=by_severity, by_step=by_step)

    # ------------------------------------------------------------------
    # Decision
    # ------------------------------------------------------------------

    def resolve(
        self,
        *,
        step_name: str,
        max_severity: Severity | None,
        attempt: int,
        tg_action: ActionType,
        mode: PolicyMode = "enforce",
    ) -> ActionType:
        """Decide the final ActionType.

        Shape of the decision (roughly):
          * mode == "off"       → pass_through (belt-and-braces; the
                                   Adapter normally skips policy entirely
                                   when mode is off)
          * mode == "shadow"    → pass_through regardless of severity
          * no violations       → TG action stands; policy is transparent
          * otherwise           → walk the severity ladder by attempt,
                                   bounded by `fail_fast` once exhausted
        """
        if mode in ("off", "shadow"):
            return "pass_through"

        if max_severity is None:
            # No 华典 violations and (if TG complained) we trust TG's
            # action. policy is a no-op.
            return tg_action

        ladder = self._ladder_for(step_name, max_severity)
        if not ladder:
            # Severity not configured anywhere → defensive fail_fast
            return "fail_fast"

        idx = max(0, attempt - 1)
        if idx >= len(ladder):
            return "fail_fast"
        return ladder[idx]

    def _ladder_for(self, step_name: str, severity: Severity) -> list[ActionType]:
        # First fnmatch hit in by_step wins (insertion order preserved
        # by dict since 3.7). Fall back to by_severity.
        for pat, table in self.by_step.items():
            if fnmatch.fnmatchcase(step_name, pat):
                if severity in table:
                    return table[severity]
        return self.by_severity.get(severity, [])

    # ------------------------------------------------------------------
    # Adapter glue — produces an ActionEscalator
    # ------------------------------------------------------------------

    def make_escalator(
        self,
        *,
        step_name: str,
        max_severity: Severity | None,
        mode: PolicyMode = "enforce",
    ) -> ActionEscalator:
        """Return an `ActionEscalator`-shaped callable bound to context.

        The Protocol in `action_map.py` only carries base_action /
        confidence / attempt — the other policy inputs (step_name,
        max_severity, mode) come from the surrounding Adapter call
        and are captured here via closure.
        """

        def _escalator(
            base_action: ActionType,
            *,
            confidence: float,  # noqa: ARG001 — reserved; confidence not yet used in policy
            attempt: int,
        ) -> ActionType:
            return self.resolve(
                step_name=step_name,
                max_severity=max_severity,
                attempt=attempt,
                tg_action=base_action,
                mode=mode,
            )

        return _escalator


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def max_severity(violations: list[Violation]) -> Severity | None:
    """Return the highest severity seen, or None if violations is empty.

    Kept as a module function (not method) so callers do not need a
    policy instance to compute this.
    """
    if not violations:
        return None
    best: Severity = "info"
    best_rank = _SEVERITY_RANK["info"]
    for v in violations:
        if _SEVERITY_RANK[v.severity] > best_rank:
            best = v.severity
            best_rank = _SEVERITY_RANK[v.severity]
    return best


def _parse_defaults(raw: Any) -> PolicyDefaults:
    if not isinstance(raw, dict):
        raise PolicyConfigError("defaults must be a mapping")
    backoff_raw = raw.get("retry_backoff_ms", [])
    if not isinstance(backoff_raw, list):
        raise PolicyConfigError("defaults.retry_backoff_ms must be a list")
    try:
        backoff = tuple(int(x) for x in backoff_raw)
    except (TypeError, ValueError) as err:
        raise PolicyConfigError(f"defaults.retry_backoff_ms must be ints: {err}") from err
    return PolicyDefaults(
        retry_backoff_ms=backoff,
        degrade_to=str(raw.get("degrade_to", "")),
        human_queue=str(raw.get("human_queue", "")),
    )


def _parse_severity_table(raw: Any, *, where: str) -> dict[Severity, list[ActionType]]:
    if not isinstance(raw, dict):
        raise PolicyConfigError(f"{where} must be a mapping of severity → ladder")
    out: dict[Severity, list[ActionType]] = {}
    for sev, ladder in raw.items():
        if sev not in _SEVERITY_RANK:
            raise PolicyConfigError(
                f"{where}: unknown severity {sev!r}; expected one of {sorted(_SEVERITY_RANK)}"
            )
        if not isinstance(ladder, list):
            raise PolicyConfigError(f"{where}[{sev!r}] must be a list of actions")
        validated: list[ActionType] = []
        for action in ladder:
            if action not in _ALLOWED_ACTIONS:
                raise PolicyConfigError(
                    f"{where}[{sev!r}]: unknown action {action!r}; "
                    f"expected one of {sorted(_ALLOWED_ACTIONS)}"
                )
            # action is validated above — the Literal type check is
            # pyright-only, so this cast is safe at runtime.
            validated.append(action)  # type: ignore[arg-type]
        out[sev] = validated  # type: ignore[index]
    return out
