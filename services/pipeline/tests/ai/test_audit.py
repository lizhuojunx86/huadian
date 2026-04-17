"""Tests for ai/audit.py — LLMCallAuditWriter."""

from __future__ import annotations

from unittest.mock import AsyncMock, patch

from huadian_pipeline.ai.audit import LLMCallAuditWriter, _llm_call_status
from huadian_pipeline.ai.types import LLMResponse, PromptSpec
from huadian_pipeline.qc.types import CheckpointResult

# ---------------------------------------------------------------------------
# Status mapping
# ---------------------------------------------------------------------------


class TestLLMCallStatus:
    def test_pass_through(self) -> None:
        r = CheckpointResult(status="pass", action="pass_through")
        assert _llm_call_status(r) == "success"

    def test_retry(self) -> None:
        r = CheckpointResult(status="fail", action="retry")
        assert _llm_call_status(r) == "retry"

    def test_degrade(self) -> None:
        r = CheckpointResult(status="fail", action="degrade")
        assert _llm_call_status(r) == "degraded"

    def test_fail_fast(self) -> None:
        r = CheckpointResult(status="fail", action="fail_fast")
        assert _llm_call_status(r) == "failure"

    def test_human_queue(self) -> None:
        r = CheckpointResult(status="fail", action="human_queue")
        assert _llm_call_status(r) == "failure"


# ---------------------------------------------------------------------------
# Writer unit test (mock pool)
# ---------------------------------------------------------------------------

PROMPT = PromptSpec(prompt_id="ner", version="v3", system_prompt="Extract.")
RESPONSE = LLMResponse(
    content="entities",
    model="claude-sonnet-4-6",
    input_tokens=50,
    output_tokens=20,
    cost_usd=0.00045,
    latency_ms=350,
    prompt_hash="a" * 64,
    input_hash="b" * 64,
    extra={"stop_reason": "end_turn", "response_id": "msg_123"},
)
CHECKPOINT = CheckpointResult(status="pass", action="pass_through")


class TestLLMCallAuditWriter:
    async def test_write_calls_pool_execute(self) -> None:
        mock_pool = AsyncMock()
        writer = LLMCallAuditWriter("postgresql://test:test@localhost/test")

        with patch.object(writer, "_ensure_pool", return_value=mock_pool):
            row_id = await writer.write(
                prompt=PROMPT,
                response=RESPONSE,
                checkpoint_result=CHECKPOINT,
                metadata={"paragraph_id": "abc"},
            )

        assert row_id is not None
        mock_pool.execute.assert_awaited_once()

        # Verify SQL params
        call_args = mock_pool.execute.call_args
        args = call_args[0]
        assert "INSERT INTO llm_calls" in args[0]
        # args: [0]=SQL [1]=row_id [2]=prompt_id [3]=prompt_version
        # [4]=prompt_hash [5]=input_hash [6]=model [7]=input_tokens
        # [8]=output_tokens [9]=cost_usd [10]=latency_ms [11]=response
        # [12]=tg_checkpoint_id [13]=status
        assert args[2] == "ner"  # prompt_id
        assert args[3] == "ner/v3"  # prompt_version
        assert args[7] == 50  # input_tokens
        assert args[8] == 20  # output_tokens
        assert args[10] == 350  # latency_ms

    async def test_write_with_tg_checkpoint_id(self) -> None:
        """If checkpoint_result.raw has checkpoint_run_id, use it."""
        mock_pool = AsyncMock()
        writer = LLMCallAuditWriter("postgresql://test:test@localhost/test")

        cp = CheckpointResult(
            status="pass",
            action="pass_through",
            raw={"checkpoint_run_id": "12345678-1234-1234-1234-123456789abc"},
        )

        with patch.object(writer, "_ensure_pool", return_value=mock_pool):
            await writer.write(
                prompt=PROMPT,
                response=RESPONSE,
                checkpoint_result=cp,
                metadata={},
            )

        call_args = mock_pool.execute.call_args[0]
        # $12 = traceguard_checkpoint_id
        import uuid

        assert call_args[12] == uuid.UUID("12345678-1234-1234-1234-123456789abc")

    async def test_close(self) -> None:
        writer = LLMCallAuditWriter("postgresql://test:test@localhost/test")
        mock_pool = AsyncMock()
        writer._pool = mock_pool

        await writer.close()
        mock_pool.close.assert_awaited_once()
        assert writer._pool is None
