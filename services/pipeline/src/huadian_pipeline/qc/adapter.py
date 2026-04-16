"""TraceGuardAdapter — concrete TraceGuardPort bridging to `guardian` 0.1.0.

This is the only file that is allowed to call TG (via `_imports`).
Everything it does is one of:
  1. Translating a `CheckpointInput` into TG inputs (`StepOutput` +
     `GuardianConfig`), per Mismatch #2.
  2. Awaiting `evaluate_async`.
  3. Translating a `GuardianDecision` back into `CheckpointResult`,
     again per Mismatch #2, using `action_map.translate` for the
     action literal (Mismatch #1).
  4. Timing the round-trip so we can populate `duration_ms` (TG
     does not report this).

Policy-driven features (degrade escalation, retry backoff, PG audit
sink, rule registry) are intentionally NOT implemented here. Those are
follow-up subtasks under T-TG-002 §8 (S-6 / S-7 / S-4). What IS in
place:
  - `ActionEscalator` hook point for future `degrade` handling
  - Empty rule registry stub so tests can exercise `register_rule` later
  - `TraceGuard` original action kept in `raw["tg_action"]` for audit
"""

from __future__ import annotations

import asyncio
import importlib.metadata
import logging
import time
from collections.abc import Callable
from typing import Any

from . import _imports  # isort: skip  — importing the module, not its symbols
from .action_map import (
    ActionEscalator,
    ActionType,
    UnknownTGActionError,
    maybe_escalate,
    translate,
)
from .policy import ActionPolicy, PolicyMode, max_severity
from .port import TraceGuardPort
from .rule_registry import RuleRegistry
from .types import (
    CheckpointInput,
    CheckpointResult,
    CheckpointStatus,
    Severity,
    Violation,
)

logger = logging.getLogger(__name__)


# TG emits unstructured `issues: list[str]` with no per-issue severity.
# The Adapter wraps every TG issue at a **single fixed severity** rather
# than trying to infer one from `decision.action`. Rationale (S-4 rework):
# inference from action is double-counting — the action itself already
# governs the pipeline response. Severity is for human triage, and "major"
# is a safe default for any TG structural issue; `critical` / `info` are
# reserved for 华典-native rules where the rule author assigns them at
# registration time (see rule_registry.py).
_TG_STRUCTURAL_RULE_ID = "traceguard.structural"
_TG_STRUCTURAL_SEVERITY: Severity = "major"


# ---------------------------------------------------------------------------
# Config provider
#
# `evaluate_async` demands a fully-populated `GuardianConfig`. Production
# pipelines will build this from a YAML file per step; tests may want to
# inject it programmatically. We accept a callable so both modes work.
# Default provider returns a neutral GuardianConfig — no structural checks
# configured, `semantic.enabled = False`. TG will happily pass anything
# through such a config; it is useful for wiring tests end-to-end.
# ---------------------------------------------------------------------------

ConfigProvider = Callable[[str], "_imports.GuardianConfig"]


def _default_config_provider(_step_name: str) -> _imports.GuardianConfig:
    """Neutral GuardianConfig: no checks, semantic disabled."""
    return _imports.GuardianConfig()


class TraceGuardAdapter(TraceGuardPort):
    """ADR-004 Port implementation bridging to pipeline-guardian 0.1.0."""

    def __init__(
        self,
        *,
        config_provider: ConfigProvider | None = None,
        escalator: ActionEscalator | None = None,
        rule_registry: RuleRegistry | None = None,
        policy: ActionPolicy | None = None,
        mode: PolicyMode = "enforce",
    ) -> None:
        # `escalator` is a raw Protocol-shaped override for tests and
        # one-off injection. When `policy` is provided, the Adapter
        # constructs an escalator per-checkpoint via
        # `policy.make_escalator(...)` and `escalator` is ignored.
        self._config_provider: ConfigProvider = (
            config_provider or _default_config_provider
        )
        self._escalator: ActionEscalator | None = escalator
        self._registry: RuleRegistry = rule_registry or RuleRegistry()
        self._policy: ActionPolicy | None = policy
        self._mode: PolicyMode = mode

    # ------------------------------------------------------------------
    # Core hot path
    # ------------------------------------------------------------------

    async def checkpoint(self, payload: CheckpointInput) -> CheckpointResult:
        """Run TG structural eval + 华典 rule registry, merge, translate.

        Steps:
          0. If `mode == "off"`: short-circuit to `pass_through`, skip
             TG and the registry entirely. Emergency kill-switch per
             ADR-004 §七.
          1. Hand the payload to TG's `evaluate_async` (structural only —
             semantic is forced off per C-7).
          2. Run every 华典 Python rule registered for this step against
             the same payload.
          3. Merge TG issues (wrapped as Violations, fixed severity) with
             registry violations (registry-assigned severity).
          4. Translate TG action via Mismatch #1; if a policy is wired,
             bind an escalator from `policy.make_escalator(...)` so the
             severity × attempt × step ladder is applied. Otherwise
             fall back to the constructor-provided `escalator` (None
             = identity).
          5. Stamp `duration_ms` on the way out.
        """
        t0 = time.perf_counter()

        if self._mode == "off":
            return CheckpointResult(
                status="pass",
                action="pass_through",
                violations=[],
                confidence=1.0,
                duration_ms=int((time.perf_counter() - t0) * 1000),
                raw={"mode": "off"},
            )

        tg_config = self._resolve_config(payload.step_name)
        step_output = self._build_step_output(payload)
        attempt = int(payload.metadata.get("attempt", 1))

        try:
            tg_decision = await _imports.evaluate_async(
                output=step_output,
                config=tg_config,
                attempt=attempt,
            )
        except Exception as exc:  # pragma: no cover — TG eval failure path
            duration_ms = int((time.perf_counter() - t0) * 1000)
            logger.exception(
                "TG evaluate_async raised; surfacing as fail_fast"
            )
            return CheckpointResult(
                status="fail",
                action="fail_fast",
                violations=[
                    Violation(
                        rule_id=f"{_TG_STRUCTURAL_RULE_ID}.eval_error",
                        severity="critical",
                        message=f"TG evaluate_async error: {exc!r}",
                    )
                ],
                confidence=0.0,
                duration_ms=duration_ms,
                raw={"tg_error": repr(exc)},
            )

        # Run 华典-side Python rules — errors inside a rule fn should not
        # poison the checkpoint; they are logged and surfaced as a
        # critical violation attached to that rule's own id.
        huadian_violations = self._run_registry(payload)

        result = self._decision_to_result(
            tg_decision,
            attempt=attempt,
            extra_violations=huadian_violations,
            step_name=payload.step_name,
        )
        result.duration_ms = int((time.perf_counter() - t0) * 1000)
        return result

    def _run_registry(self, payload: CheckpointInput) -> list[Violation]:
        try:
            return self._registry.for_step(payload.step_name).run_all(payload)
        except Exception as exc:  # pragma: no cover — defence in depth
            logger.exception(
                "rule registry raised for step %r; surfacing as critical violation",
                payload.step_name,
            )
            return [
                Violation(
                    rule_id="registry.error",
                    severity="critical",
                    message=f"rule registry raised: {exc!r}",
                )
            ]

    # ------------------------------------------------------------------
    # Stub implementations — mature in follow-up subtasks
    # ------------------------------------------------------------------

    async def batch_checkpoint(
        self, payloads: list[CheckpointInput]
    ) -> list[CheckpointResult]:
        """Naïve concurrent fan-out. Concurrency cap + policy comes later."""
        return list(await asyncio.gather(*(self.checkpoint(p) for p in payloads)))

    def register_rule(
        self,
        rule_id: str,
        rule_fn: Any,
        *,
        severity: str,
    ) -> None:
        raise NotImplementedError(
            "register_rule lands in T-TG-002 S-4 (rule registry)."
        )

    def register_rule_bundle(self, bundle_path: str) -> None:
        raise NotImplementedError(
            "register_rule_bundle lands in T-TG-002 S-4 (rule registry)."
        )

    async def replay(self, trace_id: str) -> CheckpointResult:
        raise NotImplementedError(
            "replay lands in T-TG-002 S-8 (needs extractions_history sink)."
        )

    def health(self) -> dict[str, Any]:
        try:
            tg_version = importlib.metadata.version("pipeline-guardian")
        except importlib.metadata.PackageNotFoundError:  # pragma: no cover
            tg_version = "unknown"
        return {
            "ok": True,
            "tg_version": tg_version,
            "rules_loaded": len(self._registry),
            "escalator": self._escalator is not None,
            "policy": self._policy is not None,
            "mode": self._mode,
        }

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    def _resolve_config(self, step_name: str) -> _imports.GuardianConfig:
        """Get a GuardianConfig for `step_name`, **forcing semantic off**.

        华典 never lets TG run its own LLM-as-Judge (see调研 notes §6 β1 /
        constitution C-7: no black-box LLM calls). If a provider returned
        a config with `semantic.enabled = True`, we override and warn —
        the provider is misconfigured but we don't want to crash the
        pipeline in prod.
        """
        cfg = self._config_provider(step_name)
        if cfg.semantic.enabled:
            logger.warning(
                "semantic.enabled=True from config_provider for step %r; "
                "overriding to False per C-7 (LLMGateway-only).",
                step_name,
            )
            cfg.semantic.enabled = False
        return cfg

    @staticmethod
    def _build_step_output(payload: CheckpointInput) -> _imports.StepOutput:
        """Map `CheckpointInput.outputs` → TG `StepOutput`.

        TG's `StepOutput.output_data` accepts `str | dict`. Passing a dict
        lets TG evaluate JSON-Schema + required_fields without re-parsing.
        """
        return _imports.StepOutput(
            step_name=payload.step_name,
            output_data=payload.outputs,
            metadata=dict(payload.metadata),
        )

    def _decision_to_result(
        self,
        decision: _imports.GuardianDecision,
        *,
        attempt: int,
        extra_violations: list[Violation],
        step_name: str,
    ) -> CheckpointResult:
        """Translate GuardianDecision → CheckpointResult (Mismatch #2).

        Merges `extra_violations` (华典 Python rules) with TG issues
        wrapped as Violations, then runs the action through the policy
        ladder (if configured) to decide the final ActionType.
        """
        tg_action: str = decision.action

        try:
            base_action: ActionType = translate(tg_action)
        except UnknownTGActionError:
            # Surface as fail_fast + critical violation; the contract test
            # against TG_ACTION_SET is there to catch this at CI time, so
            # this branch is defence-in-depth for prod.
            logger.exception("TG emitted unknown action %r", tg_action)
            return CheckpointResult(
                status="fail",
                action="fail_fast",
                violations=[
                    Violation(
                        rule_id=f"{_TG_STRUCTURAL_RULE_ID}.unknown_action",
                        severity="critical",
                        message=(
                            f"TG emitted unknown action {tg_action!r}; "
                            "Adapter mapping needs update."
                        ),
                    ),
                    *extra_violations,
                ],
                confidence=float(decision.score),
                raw=_raw_from_decision(decision, tg_action=tg_action),
            )

        confidence = float(decision.score)

        # TG side: wrap raw issues at the fixed structural severity. 华典 side:
        # already severity-correct (registry assigned it). Merge, TG first
        # so audit logs read top-down.
        tg_violations = _violations_from_issues(
            issues=list(decision.issues),
            retry_hint=decision.retry_hint,
        )
        violations = tg_violations + extra_violations

        # Resolve the escalator to use for this call:
        #   policy wired  → build a bound escalator from policy.make_escalator
        #   no policy     → fall back to the constructor-provided escalator
        #                   (usually None = pure translation, no degrade)
        effective_escalator: ActionEscalator | None
        if self._policy is not None:
            effective_escalator = self._policy.make_escalator(
                step_name=step_name,
                max_severity=max_severity(violations),
                mode=self._mode,
            )
        else:
            effective_escalator = self._escalator

        final_action: ActionType = maybe_escalate(
            base_action,
            confidence=confidence,
            attempt=attempt,
            escalator=effective_escalator,
        )

        status: CheckpointStatus = "pass" if not violations else "fail"

        raw = _raw_from_decision(decision, tg_action=tg_action)
        raw["mode"] = self._mode

        return CheckpointResult(
            status=status,
            action=final_action,
            violations=violations,
            confidence=confidence,
            raw=raw,
        )


# ---------------------------------------------------------------------------
# Module-level translators (keep class body lean)
# ---------------------------------------------------------------------------

def _violations_from_issues(
    *,
    issues: list[str],
    retry_hint: str | None,
) -> list[Violation]:
    return [
        Violation(
            rule_id=_TG_STRUCTURAL_RULE_ID,
            severity=_TG_STRUCTURAL_SEVERITY,
            message=msg,
            suggested_fix=retry_hint,
        )
        for msg in issues
    ]


def _raw_from_decision(
    decision: _imports.GuardianDecision,
    *,
    tg_action: str,
) -> dict[str, Any]:
    """Everything we do NOT promote to a first-class CheckpointResult field."""
    return {
        "tg_action": tg_action,
        "tg_decision": {
            "action": decision.action,
            "issues": list(decision.issues),
            "score": decision.score,
            "retry_hint": decision.retry_hint,
            "semantic_score": decision.semantic_score,
            "semantic_status": decision.semantic_status,
        },
        "semantic_score": decision.semantic_score,
        "semantic_status": decision.semantic_status,
    }
