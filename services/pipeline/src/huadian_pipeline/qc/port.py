"""TraceGuardPort — ADR-004 §三 abstract protocol.

Business code (pipeline steps, LLM gateway, QA glue) depends on this
Protocol, never on the Adapter or the `guardian` package. That keeps
TG swappable (ADR-004 §八 Option C / Hexagonal Architecture).

Methods not yet implemented in this task are kept on the Protocol so
the shape is stable — the concrete Adapter raises NotImplementedError
for them until follow-up subtasks (S-8 in T-TG-002).
"""

from __future__ import annotations

from typing import Any, Protocol

from .types import CheckpointInput, CheckpointResult


class TraceGuardPort(Protocol):
    """华典 QA runtime contract. See ADR-004 §三."""

    async def checkpoint(self, payload: CheckpointInput) -> CheckpointResult:
        """Synchronous (per-step) validation. Core hot path."""
        ...

    async def batch_checkpoint(self, payloads: list[CheckpointInput]) -> list[CheckpointResult]:
        """Batched validation for large pipeline runs."""
        ...

    def register_rule(
        self,
        rule_id: str,
        rule_fn: Any,
        *,
        severity: str,
    ) -> None:
        """Register a single 华典 Python rule: (CheckpointInput) -> list[Violation]."""
        ...

    def register_rule_bundle(self, bundle_path: str) -> None:
        """Register a directory / YAML of rules."""
        ...

    async def replay(self, trace_id: str) -> CheckpointResult:
        """Re-validate a stored trace (rule evolution regression)."""
        ...

    def health(self) -> dict[str, Any]:
        """Return `{"ok": bool, "tg_version": str, "rules_loaded": int, ...}`."""
        ...
