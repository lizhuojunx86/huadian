"""In-process stub implementing TraceGuardPort, with zero TG dependency.

Downstream pipeline code unit-tests against this instead of spinning up
the real Adapter + TG + SQLite. Intentionally boring: the test injects a
desired `CheckpointResult` (or a callable producing one) and reads back
the call log.
"""

from __future__ import annotations

from collections.abc import Callable
from typing import Any

from .port import TraceGuardPort
from .types import CheckpointInput, CheckpointResult

ResponseFactory = Callable[[CheckpointInput], CheckpointResult]


class MockTraceGuardPort(TraceGuardPort):
    """TraceGuardPort stub for unit tests.

    Usage patterns:

        # Fixed response
        port = MockTraceGuardPort(default_response=CheckpointResult(
            status="pass", action="pass_through"
        ))

        # Per-call response
        port = MockTraceGuardPort(factory=lambda payload: ...)

        # Inspect calls
        assert port.calls[0].step_name == "ner_v3"
    """

    def __init__(
        self,
        *,
        default_response: CheckpointResult | None = None,
        factory: ResponseFactory | None = None,
    ) -> None:
        if default_response is None and factory is None:
            default_response = CheckpointResult(
                status="pass", action="pass_through"
            )
        self._default = default_response
        self._factory = factory
        self.calls: list[CheckpointInput] = []
        self.registered_rules: list[tuple[str, Any, str]] = []
        self.registered_bundles: list[str] = []

    async def checkpoint(self, payload: CheckpointInput) -> CheckpointResult:
        self.calls.append(payload)
        if self._factory is not None:
            return self._factory(payload)
        assert self._default is not None  # guaranteed by __init__
        return self._default

    async def batch_checkpoint(
        self, payloads: list[CheckpointInput]
    ) -> list[CheckpointResult]:
        return [await self.checkpoint(p) for p in payloads]

    def register_rule(
        self,
        rule_id: str,
        rule_fn: Any,
        *,
        severity: str,
    ) -> None:
        self.registered_rules.append((rule_id, rule_fn, severity))

    def register_rule_bundle(self, bundle_path: str) -> None:
        self.registered_bundles.append(bundle_path)

    async def replay(self, trace_id: str) -> CheckpointResult:
        # Replay just echoes the most recent call's default response;
        # suitable for tests that exercise wiring rather than semantics.
        if self._factory is not None and self.calls:
            return self._factory(self.calls[-1])
        assert self._default is not None
        return self._default

    def health(self) -> dict[str, Any]:
        return {
            "ok": True,
            "tg_version": "mock",
            "rules_loaded": len(self.registered_rules),
            "mock": True,
        }
