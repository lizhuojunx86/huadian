"""Tests for AnthropicGateway — mock Anthropic SDK + MockTraceGuardPort."""

from __future__ import annotations

from typing import Any
from unittest.mock import AsyncMock, MagicMock, patch

import anthropic
import pytest

from huadian_pipeline.ai.anthropic_provider import (
    AnthropicGateway,
    _compute_cost,
    _DEGRADE_MODEL,
)
from huadian_pipeline.ai.types import LLMGatewayError, LLMResponse, PromptSpec
from huadian_pipeline.qc.mock import MockTraceGuardPort
from huadian_pipeline.qc.types import CheckpointInput, CheckpointResult, Violation


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

PROMPT = PromptSpec(prompt_id="ner", version="v3", system_prompt="Extract entities.")
USER_INPUT = "鸿门宴者，项羽与刘邦之事也。"


def _make_anthropic_response(
    text: str = "entities found",
    input_tokens: int = 50,
    output_tokens: int = 20,
    model: str = "claude-sonnet-4-6",
) -> MagicMock:
    """Build a mock anthropic.types.Message."""
    content_block = MagicMock()
    content_block.text = text

    usage = MagicMock()
    usage.input_tokens = input_tokens
    usage.output_tokens = output_tokens

    msg = MagicMock()
    msg.content = [content_block]
    msg.usage = usage
    msg.model = model
    msg.stop_reason = "end_turn"
    msg.id = "msg_test_123"
    return msg


def _make_gateway(
    tg: MockTraceGuardPort | None = None,
    audit_writer: Any = None,
    max_retries: int = 3,
) -> AnthropicGateway:
    return AnthropicGateway(
        tg=tg or MockTraceGuardPort(),
        api_key="test-key",
        default_model="claude-sonnet-4-6",
        max_retries=max_retries,
        timeout_seconds=10,
        audit_writer=audit_writer,
    )


# ---------------------------------------------------------------------------
# Cost calculation
# ---------------------------------------------------------------------------


class TestComputeCost:
    def test_sonnet_pricing(self) -> None:
        # 100 input + 50 output at sonnet rates: 3/1M * 100 + 15/1M * 50
        cost = _compute_cost("claude-sonnet-4-6", 100, 50)
        assert abs(cost - (300 / 1_000_000 + 750 / 1_000_000)) < 1e-10

    def test_haiku_pricing(self) -> None:
        cost = _compute_cost("claude-haiku-4-5", 1000, 500)
        expected = (1000 * 0.80 + 500 * 4.0) / 1_000_000
        assert abs(cost - expected) < 1e-10

    def test_unknown_model_uses_default(self) -> None:
        cost = _compute_cost("unknown-model", 100, 50)
        # default = sonnet pricing
        expected = (100 * 3.0 + 50 * 15.0) / 1_000_000
        assert abs(cost - expected) < 1e-10


# ---------------------------------------------------------------------------
# Happy path
# ---------------------------------------------------------------------------


class TestHappyPath:
    async def test_basic_call(self) -> None:
        tg = MockTraceGuardPort()
        gw = _make_gateway(tg=tg)

        mock_resp = _make_anthropic_response()
        with patch.object(
            gw._client.messages, "create", new_callable=AsyncMock, return_value=mock_resp
        ):
            resp = await gw.call(PROMPT, USER_INPUT)

        assert isinstance(resp, LLMResponse)
        assert resp.content == "entities found"
        assert resp.model == "claude-sonnet-4-6"
        assert resp.input_tokens == 50
        assert resp.output_tokens == 20
        assert resp.cost_usd > 0
        assert resp.latency_ms >= 0
        assert len(resp.prompt_hash) == 64
        assert len(resp.input_hash) == 64

        # TraceGuard was called
        assert len(tg.calls) == 1
        assert tg.calls[0].step_name == "llm_call/ner"

    async def test_custom_model_and_temperature(self) -> None:
        tg = MockTraceGuardPort()
        gw = _make_gateway(tg=tg)

        mock_resp = _make_anthropic_response(model="claude-opus-4-6")
        with patch.object(
            gw._client.messages, "create", new_callable=AsyncMock, return_value=mock_resp
        ) as mock_create:
            resp = await gw.call(
                PROMPT,
                USER_INPUT,
                model="claude-opus-4-6",
                temperature=0.5,
                max_tokens=2048,
            )

        assert resp.model == "claude-opus-4-6"
        call_kwargs = mock_create.call_args
        assert call_kwargs.kwargs["temperature"] == 0.5
        assert call_kwargs.kwargs["max_tokens"] == 2048

    async def test_metadata_passed_to_checkpoint(self) -> None:
        tg = MockTraceGuardPort()
        gw = _make_gateway(tg=tg)

        mock_resp = _make_anthropic_response()
        with patch.object(
            gw._client.messages, "create", new_callable=AsyncMock, return_value=mock_resp
        ):
            await gw.call(
                PROMPT,
                USER_INPUT,
                metadata={"paragraph_id": "abc-123", "trace_id": "trace-1"},
            )

        cp_input = tg.calls[0]
        assert cp_input.metadata["paragraph_id"] == "abc-123"
        assert cp_input.trace_id == "trace-1"


# ---------------------------------------------------------------------------
# TraceGuard action routing
# ---------------------------------------------------------------------------


class TestCheckpointActions:
    async def test_retry_action(self) -> None:
        """TG returns retry → Gateway retries, then pass_through."""
        call_count = 0

        def factory(payload: CheckpointInput) -> CheckpointResult:
            nonlocal call_count
            call_count += 1
            if call_count == 1:
                return CheckpointResult(status="fail", action="retry")
            return CheckpointResult(status="pass", action="pass_through")

        tg = MockTraceGuardPort(factory=factory)
        gw = _make_gateway(tg=tg)

        mock_resp = _make_anthropic_response()
        with patch.object(
            gw._client.messages, "create", new_callable=AsyncMock, return_value=mock_resp
        ):
            resp = await gw.call(PROMPT, USER_INPUT)

        assert resp.content == "entities found"
        assert len(tg.calls) == 2
        # Second call has attempt=2
        assert tg.calls[1].metadata["attempt"] == 2

    async def test_retry_exhausted(self) -> None:
        """TG always returns retry → Gateway raises after max_retries."""
        tg = MockTraceGuardPort(
            default_response=CheckpointResult(status="fail", action="retry")
        )
        gw = _make_gateway(tg=tg, max_retries=2)

        mock_resp = _make_anthropic_response()
        with patch.object(
            gw._client.messages, "create", new_callable=AsyncMock, return_value=mock_resp
        ):
            with pytest.raises(LLMGatewayError, match="retry exhausted"):
                await gw.call(PROMPT, USER_INPUT)

    async def test_degrade_action(self) -> None:
        """TG returns degrade → Gateway switches to haiku model."""
        call_count = 0

        def factory(payload: CheckpointInput) -> CheckpointResult:
            nonlocal call_count
            call_count += 1
            if call_count == 1:
                return CheckpointResult(status="fail", action="degrade")
            return CheckpointResult(status="pass", action="pass_through")

        tg = MockTraceGuardPort(factory=factory)
        gw = _make_gateway(tg=tg)

        mock_resp = _make_anthropic_response()
        with patch.object(
            gw._client.messages, "create", new_callable=AsyncMock, return_value=mock_resp
        ):
            resp = await gw.call(PROMPT, USER_INPUT)

        assert resp.content == "entities found"
        # Second call should use degrade model
        assert tg.calls[1].model == _DEGRADE_MODEL

    async def test_degrade_already_on_haiku(self) -> None:
        """TG returns degrade when already on haiku → error."""
        tg = MockTraceGuardPort(
            default_response=CheckpointResult(status="fail", action="degrade")
        )
        gw = _make_gateway(tg=tg)

        mock_resp = _make_anthropic_response(model="claude-haiku-4-5")
        with patch.object(
            gw._client.messages, "create", new_callable=AsyncMock, return_value=mock_resp
        ):
            with pytest.raises(LLMGatewayError, match="cannot degrade further"):
                await gw.call(PROMPT, USER_INPUT, model="claude-haiku-4-5")

    async def test_fail_fast_action(self) -> None:
        tg = MockTraceGuardPort(
            default_response=CheckpointResult(
                status="fail",
                action="fail_fast",
                violations=[Violation(rule_id="test", severity="critical", message="bad output")],
            )
        )
        gw = _make_gateway(tg=tg)

        mock_resp = _make_anthropic_response()
        with patch.object(
            gw._client.messages, "create", new_callable=AsyncMock, return_value=mock_resp
        ):
            with pytest.raises(LLMGatewayError, match="fail_fast"):
                await gw.call(PROMPT, USER_INPUT)

    async def test_human_queue_action(self) -> None:
        tg = MockTraceGuardPort(
            default_response=CheckpointResult(status="fail", action="human_queue")
        )
        gw = _make_gateway(tg=tg)

        mock_resp = _make_anthropic_response()
        with patch.object(
            gw._client.messages, "create", new_callable=AsyncMock, return_value=mock_resp
        ):
            with pytest.raises(LLMGatewayError, match="human_queue"):
                await gw.call(PROMPT, USER_INPUT)


# ---------------------------------------------------------------------------
# HTTP-layer retry
# ---------------------------------------------------------------------------


@patch("huadian_pipeline.ai.anthropic_provider.asyncio.sleep", new_callable=AsyncMock)
class TestHTTPRetry:
    async def test_auth_error_no_retry(self, _sleep: AsyncMock) -> None:
        """AuthenticationError raises immediately, no retry."""
        gw = _make_gateway()

        with patch.object(
            gw._client.messages,
            "create",
            new_callable=AsyncMock,
            side_effect=_make_auth_error(),
        ):
            with pytest.raises(LLMGatewayError, match="authentication"):
                await gw.call(PROMPT, USER_INPUT)

    async def test_rate_limit_retry_then_success(self, _sleep: AsyncMock) -> None:
        """429 retried, then succeeds."""
        gw = _make_gateway(max_retries=3)
        mock_resp = _make_anthropic_response()

        call_count = 0

        async def side_effect(**kwargs: Any) -> MagicMock:
            nonlocal call_count
            call_count += 1
            if call_count == 1:
                raise _make_rate_limit_error()
            return mock_resp

        with patch.object(gw._client.messages, "create", new_callable=AsyncMock, side_effect=side_effect):
            resp = await gw.call(PROMPT, USER_INPUT)

        assert resp.content == "entities found"
        assert call_count == 2

    async def test_all_retries_exhausted(self, _sleep: AsyncMock) -> None:
        """All HTTP retries fail → LLMGatewayError."""
        gw = _make_gateway(max_retries=2)

        with patch.object(
            gw._client.messages,
            "create",
            new_callable=AsyncMock,
            side_effect=_make_rate_limit_error(),
        ):
            with pytest.raises(LLMGatewayError, match="retries exhausted"):
                await gw.call(PROMPT, USER_INPUT)


# ---------------------------------------------------------------------------
# Audit writer
# ---------------------------------------------------------------------------


class TestAuditWriter:
    async def test_audit_called(self) -> None:
        audit = AsyncMock()
        gw = _make_gateway(audit_writer=audit)

        mock_resp = _make_anthropic_response()
        with patch.object(
            gw._client.messages, "create", new_callable=AsyncMock, return_value=mock_resp
        ):
            await gw.call(PROMPT, USER_INPUT)

        audit.write.assert_awaited_once()

    async def test_audit_failure_non_blocking(self) -> None:
        audit = AsyncMock()
        audit.write.side_effect = RuntimeError("DB down")
        gw = _make_gateway(audit_writer=audit)

        mock_resp = _make_anthropic_response()
        with patch.object(
            gw._client.messages, "create", new_callable=AsyncMock, return_value=mock_resp
        ):
            # Should not raise despite audit failure
            resp = await gw.call(PROMPT, USER_INPUT)
            assert resp.content == "entities found"


# ---------------------------------------------------------------------------
# TraceGuard checkpoint failure
# ---------------------------------------------------------------------------


class TestCheckpointFailure:
    async def test_tg_exception_treated_as_pass(self) -> None:
        """If TG checkpoint itself raises, treat as pass_through."""
        tg = MockTraceGuardPort()
        tg.checkpoint = AsyncMock(side_effect=RuntimeError("TG down"))  # type: ignore[method-assign]
        gw = _make_gateway(tg=tg)

        mock_resp = _make_anthropic_response()
        with patch.object(
            gw._client.messages, "create", new_callable=AsyncMock, return_value=mock_resp
        ):
            resp = await gw.call(PROMPT, USER_INPUT)
            assert resp.content == "entities found"


# ---------------------------------------------------------------------------
# Helpers to create Anthropic SDK exceptions
# ---------------------------------------------------------------------------


def _make_auth_error() -> anthropic.AuthenticationError:
    mock_response = MagicMock()
    mock_response.status_code = 401
    mock_response.headers = {}
    mock_response.json.return_value = {"error": {"message": "invalid api key"}}
    return anthropic.AuthenticationError(
        message="invalid api key",
        response=mock_response,
        body={"error": {"message": "invalid api key"}},
    )


def _make_rate_limit_error() -> anthropic.RateLimitError:
    mock_response = MagicMock()
    mock_response.status_code = 429
    mock_response.headers = {"retry-after": "1"}
    mock_response.json.return_value = {"error": {"message": "rate limited"}}
    return anthropic.RateLimitError(
        message="rate limited",
        response=mock_response,
        body={"error": {"message": "rate limited"}},
    )
