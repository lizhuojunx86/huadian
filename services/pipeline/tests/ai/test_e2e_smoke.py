"""End-to-end smoke test: mock Anthropic → Gateway → checkpoint → audit.

Verifies the full pipeline wiring without real external calls.
"""

from __future__ import annotations

from unittest.mock import AsyncMock, MagicMock, patch

from huadian_pipeline.ai.anthropic_provider import AnthropicGateway
from huadian_pipeline.ai.types import PromptSpec
from huadian_pipeline.qc.mock import MockTraceGuardPort
from huadian_pipeline.qc.types import CheckpointResult

PROMPT = PromptSpec(prompt_id="ner", version="v3", system_prompt="Extract entities.")
USER_INPUT = "鸿门宴者，项羽与刘邦之事也。"


def _make_anthropic_response() -> MagicMock:
    content_block = MagicMock()
    content_block.type = "text"
    content_block.text = '{"entities": [{"name": "项羽"}, {"name": "刘邦"}]}'

    usage = MagicMock()
    usage.input_tokens = 120
    usage.output_tokens = 45

    msg = MagicMock()
    msg.content = [content_block]
    msg.usage = usage
    msg.model = "claude-sonnet-4-6"
    msg.stop_reason = "end_turn"
    msg.id = "msg_smoke_001"
    return msg


class TestE2ESmoke:
    async def test_full_pipeline_happy_path(self) -> None:
        """Mock Anthropic → Gateway → TG checkpoint → audit → return."""
        tg = MockTraceGuardPort(
            default_response=CheckpointResult(
                status="pass",
                action="pass_through",
                confidence=0.95,
            )
        )
        audit = AsyncMock()

        gw = AnthropicGateway(
            tg=tg,
            api_key="test-key",
            default_model="claude-sonnet-4-6",
            max_retries=3,
            timeout_seconds=10,
            audit_writer=audit,
        )

        mock_resp = _make_anthropic_response()
        with patch.object(
            gw._client.messages, "create", new_callable=AsyncMock, return_value=mock_resp
        ):
            resp = await gw.call(
                PROMPT,
                USER_INPUT,
                metadata={
                    "paragraph_id": "para-001",
                    "book_id": "shiji",
                    "trace_id": "trace-001",
                },
            )

        # 1. Response correct
        assert "项羽" in resp.content
        assert resp.model == "claude-sonnet-4-6"
        assert resp.input_tokens == 120
        assert resp.output_tokens == 45
        assert resp.cost_usd > 0
        assert len(resp.prompt_hash) == 64
        assert len(resp.input_hash) == 64

        # 2. TraceGuard checkpoint was called
        assert len(tg.calls) == 1
        cp = tg.calls[0]
        assert cp.step_name == "llm_call/ner"
        assert cp.trace_id == "trace-001"
        assert cp.model == "claude-sonnet-4-6"
        assert cp.metadata["paragraph_id"] == "para-001"
        assert cp.metadata["attempt"] == 1

        # 3. Audit writer was called
        audit.write.assert_awaited_once()
        write_kwargs = audit.write.call_args.kwargs
        assert write_kwargs["prompt"].prompt_id == "ner"
        assert write_kwargs["response"].content == resp.content
        assert write_kwargs["metadata"]["book_id"] == "shiji"

    async def test_retry_then_pass_flow(self) -> None:
        """TG retry once → second attempt passes → full chain verified."""
        call_count = 0

        def tg_factory(payload: object) -> CheckpointResult:
            nonlocal call_count
            call_count += 1
            if call_count == 1:
                return CheckpointResult(status="fail", action="retry")
            return CheckpointResult(status="pass", action="pass_through")

        tg = MockTraceGuardPort(factory=tg_factory)
        audit = AsyncMock()

        gw = AnthropicGateway(
            tg=tg,
            api_key="test-key",
            default_model="claude-sonnet-4-6",
            max_retries=3,
            timeout_seconds=10,
            audit_writer=audit,
        )

        mock_resp = _make_anthropic_response()
        with patch.object(
            gw._client.messages, "create", new_callable=AsyncMock, return_value=mock_resp
        ):
            resp = await gw.call(PROMPT, USER_INPUT)

        assert resp.content is not None
        # Two TG calls (attempt 1 retry + attempt 2 pass)
        assert len(tg.calls) == 2
        # Two audit writes (one per attempt)
        assert audit.write.await_count == 2

    async def test_degrade_flow(self) -> None:
        """TG degrade → second attempt on haiku → passes."""
        call_count = 0

        def tg_factory(payload: object) -> CheckpointResult:
            nonlocal call_count
            call_count += 1
            if call_count == 1:
                return CheckpointResult(status="fail", action="degrade")
            return CheckpointResult(status="pass", action="pass_through")

        tg = MockTraceGuardPort(factory=tg_factory)

        gw = AnthropicGateway(
            tg=tg,
            api_key="test-key",
            default_model="claude-sonnet-4-6",
            max_retries=3,
            timeout_seconds=10,
        )

        mock_resp = _make_anthropic_response()
        with patch.object(
            gw._client.messages, "create", new_callable=AsyncMock, return_value=mock_resp
        ) as mock_create:
            resp = await gw.call(PROMPT, USER_INPUT)

        assert resp.content is not None
        # Second call should use haiku model
        second_call = mock_create.call_args_list[1]
        assert second_call.kwargs["model"] == "claude-haiku-4-5"
