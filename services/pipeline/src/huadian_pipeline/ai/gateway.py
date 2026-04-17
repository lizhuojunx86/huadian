"""LLMGateway — abstract protocol for all LLM access (C-7).

Pipeline code depends on this Protocol, never on provider SDKs
directly. This keeps the provider swappable (Phase 2+: OpenAI,
local models, etc.) and enforces the single-gateway constraint.
"""

from __future__ import annotations

from typing import Protocol

from .types import LLMResponse, PromptSpec


class LLMGateway(Protocol):
    """Unified LLM access contract.

    Every implementation MUST:
      1. Record the call to llm_calls (audit).
      2. Run a TraceGuard checkpoint on the response.
      3. Route the checkpoint action (pass/retry/degrade/fail).
    """

    async def call(
        self,
        prompt: PromptSpec,
        user_input: str,
        *,
        model: str | None = None,
        temperature: float = 0.0,
        max_tokens: int = 4096,
        metadata: dict[str, object] | None = None,
    ) -> LLMResponse:
        """Invoke the LLM and return a structured response.

        Parameters
        ----------
        prompt : PromptSpec
            Prompt identity (id, version, system text).
        user_input : str
            The user/human message content.
        model : str | None
            Override the default model for this call.
        temperature : float
            Sampling temperature (0.0 = deterministic).
        max_tokens : int
            Maximum tokens in the response.
        metadata : dict | None
            Extra context passed to audit and TraceGuard checkpoint
            (e.g. paragraph_id, book_id, attempt).
        """
        ...
