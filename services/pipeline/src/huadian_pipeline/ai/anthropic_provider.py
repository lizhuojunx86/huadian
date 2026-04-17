"""AnthropicGateway — Anthropic SDK implementation of LLMGateway (C-7).

Phase 0 provider: all pipeline LLM calls go through this class.
Responsibilities:
  1. Wrap AsyncAnthropic.messages.create with retry + timeout
  2. Compute cost from token counts × hardcoded rates (Q-3)
  3. Run TraceGuard checkpoint on response (Q-1)
  4. Write audit record to llm_calls (best-effort)

Retry strategy (Q-4):
  - HTTP layer: exponential backoff on 429/529/5xx, up to max_retries
  - TraceGuard layer: semantic retry/degrade handled separately
"""

from __future__ import annotations

import asyncio
import logging
import os
import time
from typing import Any

import anthropic

from ..qc.port import TraceGuardPort
from ..qc.types import CheckpointInput, CheckpointResult
from .hashing import input_hash as compute_input_hash
from .hashing import prompt_hash as compute_prompt_hash
from .types import LLMGatewayError, LLMResponse, PromptSpec

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Token pricing (Q-3: hardcode for Phase 0)
# Prices per 1M tokens (USD), as of 2025-05 public Anthropic pricing.
# ---------------------------------------------------------------------------
_PRICING: dict[str, tuple[float, float]] = {
    # (input_per_1M, output_per_1M)
    "claude-sonnet-4-6": (3.0, 15.0),
    "claude-sonnet-4-20250514": (3.0, 15.0),
    "claude-haiku-4-5": (0.80, 4.0),
    "claude-haiku-4-5-20251001": (0.80, 4.0),
    "claude-opus-4-6": (15.0, 75.0),
    "claude-opus-4-20250514": (15.0, 75.0),
}

# Fallback pricing for unknown models
_DEFAULT_PRICING: tuple[float, float] = (3.0, 15.0)

DEFAULT_MODEL = "claude-sonnet-4-6"
DEFAULT_MAX_RETRIES = 3
DEFAULT_TIMEOUT_SECONDS = 60

# Degrade model (when TraceGuard action = "degrade")
_DEGRADE_MODEL = "claude-haiku-4-5"

# Retry base delay for HTTP-layer retries
_RETRY_BASE_DELAY = 1.0  # seconds
_RETRY_MAX_DELAY = 30.0  # seconds

# Retryable HTTP status codes
_RETRYABLE_STATUSES = frozenset({429, 529, 500, 502, 503})


def _compute_cost(model: str, input_tokens: int, output_tokens: int) -> float:
    """Compute cost in USD from token counts."""
    input_rate, output_rate = _PRICING.get(model, _DEFAULT_PRICING)
    return (input_tokens * input_rate + output_tokens * output_rate) / 1_000_000


class AnthropicGateway:
    """Anthropic SDK implementation of LLMGateway.

    Usage:
        gw = AnthropicGateway(tg=traceguard_port)
        resp = await gw.call(prompt_spec, "Extract entities from: ...")
    """

    def __init__(
        self,
        *,
        tg: TraceGuardPort,
        api_key: str | None = None,
        default_model: str | None = None,
        max_retries: int | None = None,
        timeout_seconds: int | None = None,
        audit_writer: Any | None = None,
    ) -> None:
        self._tg = tg
        self._api_key = api_key or os.environ.get("ANTHROPIC_API_KEY", "")
        self._default_model = default_model or os.environ.get(
            "LLM_DEFAULT_MODEL", DEFAULT_MODEL
        )
        self._max_retries = max_retries or int(
            os.environ.get("LLM_MAX_RETRIES", str(DEFAULT_MAX_RETRIES))
        )
        self._timeout_seconds = timeout_seconds or int(
            os.environ.get("LLM_TIMEOUT_SECONDS", str(DEFAULT_TIMEOUT_SECONDS))
        )
        self._audit = audit_writer

        # The SDK client is created without built-in retries — we handle
        # retries ourselves to separate HTTP-layer from TG-layer retry.
        self._client = anthropic.AsyncAnthropic(
            api_key=self._api_key,
            max_retries=0,
            timeout=float(self._timeout_seconds),
        )

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
        """Invoke Anthropic API, checkpoint via TraceGuard, write audit."""
        effective_model = model or self._default_model
        meta = dict(metadata or {})
        p_hash = compute_prompt_hash(prompt)
        i_hash = compute_input_hash(user_input)
        tg_attempt = 1

        while True:
            # --- HTTP-layer call with retry ---
            response, latency_ms = await self._call_with_http_retry(
                prompt=prompt,
                user_input=user_input,
                model=effective_model,
                temperature=temperature,
                max_tokens=max_tokens,
            )

            input_tokens = response.usage.input_tokens
            output_tokens = response.usage.output_tokens
            content = response.content[0].text if response.content else ""
            cost = _compute_cost(effective_model, input_tokens, output_tokens)

            llm_response = LLMResponse(
                content=content,
                model=effective_model,
                input_tokens=input_tokens,
                output_tokens=output_tokens,
                cost_usd=cost,
                latency_ms=latency_ms,
                prompt_hash=p_hash,
                input_hash=i_hash,
                extra={
                    "stop_reason": response.stop_reason,
                    "response_id": response.id,
                },
            )

            # --- TraceGuard checkpoint ---
            checkpoint_result = await self._run_checkpoint(
                prompt=prompt,
                user_input=user_input,
                response=llm_response,
                attempt=tg_attempt,
                metadata=meta,
            )

            # --- Audit (best-effort) ---
            await self._write_audit(
                prompt=prompt,
                response=llm_response,
                checkpoint_result=checkpoint_result,
                metadata=meta,
            )

            # --- Route checkpoint action ---
            action = checkpoint_result.action

            if action == "pass_through":
                return llm_response

            if action == "retry":
                tg_attempt += 1
                if tg_attempt > self._max_retries:
                    raise LLMGatewayError(
                        f"TraceGuard retry exhausted after {tg_attempt - 1} attempts",
                        action="retry",
                    )
                logger.warning(
                    "TG action=retry (attempt %d/%d) for prompt %s/%s",
                    tg_attempt,
                    self._max_retries,
                    prompt.prompt_id,
                    prompt.version,
                )
                continue

            if action == "degrade":
                if effective_model == _DEGRADE_MODEL:
                    raise LLMGatewayError(
                        f"Already on degrade model {_DEGRADE_MODEL}, cannot degrade further",
                        action="degrade",
                    )
                logger.warning(
                    "TG action=degrade: switching %s → %s for prompt %s/%s",
                    effective_model,
                    _DEGRADE_MODEL,
                    prompt.prompt_id,
                    prompt.version,
                )
                effective_model = _DEGRADE_MODEL
                tg_attempt += 1
                continue

            # human_queue / fail_fast → raise
            raise LLMGatewayError(
                f"TraceGuard action={action}: "
                f"{[v.message for v in checkpoint_result.violations]}",
                action=action,
            )

    # ------------------------------------------------------------------
    # HTTP-layer retry (Q-4: independent of TraceGuard retry)
    # ------------------------------------------------------------------

    async def _call_with_http_retry(
        self,
        *,
        prompt: PromptSpec,
        user_input: str,
        model: str,
        temperature: float,
        max_tokens: int,
    ) -> tuple[anthropic.types.Message, int]:
        """Call Anthropic API with exponential backoff on retryable errors."""
        last_error: BaseException | None = None

        for attempt in range(1, self._max_retries + 1):
            try:
                t0 = time.perf_counter()
                response = await self._client.messages.create(
                    model=model,
                    max_tokens=max_tokens,
                    temperature=temperature,
                    system=prompt.system_prompt,
                    messages=[{"role": "user", "content": user_input}],
                )
                latency_ms = int((time.perf_counter() - t0) * 1000)
                return response, latency_ms

            except anthropic.AuthenticationError:
                raise LLMGatewayError(
                    "Anthropic API authentication failed — check ANTHROPIC_API_KEY",
                    action="fail_fast",
                ) from None

            except anthropic.RateLimitError as exc:
                last_error = exc
                delay = min(_RETRY_BASE_DELAY * (2 ** (attempt - 1)), _RETRY_MAX_DELAY)
                logger.warning(
                    "Rate limited (429), retry %d/%d after %.1fs",
                    attempt,
                    self._max_retries,
                    delay,
                )
                await asyncio.sleep(delay)

            except anthropic.APIStatusError as exc:
                if exc.status_code in _RETRYABLE_STATUSES:
                    last_error = exc
                    delay = min(
                        _RETRY_BASE_DELAY * (2 ** (attempt - 1)), _RETRY_MAX_DELAY
                    )
                    logger.warning(
                        "Retryable status %d, retry %d/%d after %.1fs",
                        exc.status_code,
                        attempt,
                        self._max_retries,
                        delay,
                    )
                    await asyncio.sleep(delay)
                else:
                    raise LLMGatewayError(
                        f"Anthropic API error: {exc.status_code} {exc.message}",
                        action="fail_fast",
                        cause=exc,
                    ) from exc

            except anthropic.APIConnectionError as exc:
                last_error = exc
                delay = min(_RETRY_BASE_DELAY * (2 ** (attempt - 1)), _RETRY_MAX_DELAY)
                logger.warning(
                    "Connection error, retry %d/%d after %.1fs",
                    attempt,
                    self._max_retries,
                    delay,
                )
                await asyncio.sleep(delay)

        raise LLMGatewayError(
            f"All {self._max_retries} HTTP retries exhausted",
            action="fail_fast",
            cause=last_error,
        )

    # ------------------------------------------------------------------
    # TraceGuard checkpoint
    # ------------------------------------------------------------------

    async def _run_checkpoint(
        self,
        *,
        prompt: PromptSpec,
        user_input: str,
        response: LLMResponse,
        attempt: int,
        metadata: dict[str, object],
    ) -> CheckpointResult:
        """Run a TraceGuard checkpoint on the LLM response."""
        trace_id = str(metadata.get("trace_id", ""))
        checkpoint_input = CheckpointInput(
            step_name=f"llm_call/{prompt.prompt_id}",
            trace_id=trace_id,
            prompt_version=f"{prompt.prompt_id}/{prompt.version}",
            model=response.model,
            inputs={"user_input": user_input, "system_prompt": prompt.system_prompt},
            outputs={"content": response.content},
            metadata={
                **metadata,
                "prompt_version": prompt.version,
                "attempt": attempt,
                "prompt_hash": response.prompt_hash,
                "input_hash": response.input_hash,
            },
        )
        try:
            return await self._tg.checkpoint(checkpoint_input)
        except Exception as exc:
            logger.exception(
                "TraceGuard checkpoint failed for %s; treating as pass_through",
                prompt.prompt_id,
            )
            return CheckpointResult(
                status="pass",
                action="pass_through",
                violations=[],
                confidence=0.0,
                raw={"tg_error": repr(exc)},
            )

    # ------------------------------------------------------------------
    # Audit writer (best-effort)
    # ------------------------------------------------------------------

    async def _write_audit(
        self,
        *,
        prompt: PromptSpec,
        response: LLMResponse,
        checkpoint_result: CheckpointResult,
        metadata: dict[str, object],
    ) -> None:
        """Write to llm_calls table. Failure does not block the response."""
        if self._audit is None:
            return
        try:
            await self._audit.write(
                prompt=prompt,
                response=response,
                checkpoint_result=checkpoint_result,
                metadata=metadata,
            )
        except Exception:
            logger.exception(
                "Audit write failed for prompt %s/%s; non-blocking",
                prompt.prompt_id,
                prompt.version,
            )
