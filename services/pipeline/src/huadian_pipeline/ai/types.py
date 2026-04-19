"""LLM Gateway data types.

These are 华典-owned wire types between the pipeline and the LLM
abstraction layer. Provider-specific details (Anthropic SDK objects,
HTTP responses) never leak past this boundary.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any


@dataclass(frozen=True, slots=True)
class PromptSpec:
    """Identity tuple for a versioned prompt.

    Used by Gateway.call() to build prompt_hash and to populate
    llm_calls audit records.
    """

    prompt_id: str  # e.g. "ner"
    version: str  # e.g. "v3"
    system_prompt: str  # full system prompt text


@dataclass(frozen=True, slots=True)
class LLMResponse:
    """Structured result from a single LLM invocation.

    Every field is provider-agnostic. Provider-specific metadata
    (stop_reason, raw headers, etc.) can go into `extra`.
    """

    content: str
    model: str
    input_tokens: int
    output_tokens: int
    cost_usd: float
    latency_ms: int
    prompt_hash: str
    input_hash: str
    extra: dict[str, Any] = field(default_factory=dict)
    call_id: str | None = None  # llm_calls.id from audit writer; filled by AnthropicGateway


class LLMGatewayError(Exception):
    """Raised when the Gateway cannot fulfil a call.

    Covers both infrastructure failures (auth, timeout, rate-limit
    after all retries exhausted) and TraceGuard-driven rejections
    (human_review, fail_fast actions).
    """

    def __init__(
        self,
        message: str,
        *,
        action: str | None = None,
        cause: BaseException | None = None,
    ) -> None:
        super().__init__(message)
        self.action = action
        self.cause = cause
