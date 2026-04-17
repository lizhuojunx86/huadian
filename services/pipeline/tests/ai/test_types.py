"""Tests for ai/types.py — LLMResponse, LLMGatewayError, PromptSpec."""

from huadian_pipeline.ai.types import LLMGatewayError, LLMResponse, PromptSpec


class TestPromptSpec:
    def test_frozen(self) -> None:
        spec = PromptSpec(prompt_id="ner", version="v3", system_prompt="Extract entities.")
        assert spec.prompt_id == "ner"
        assert spec.version == "v3"

    def test_equality(self) -> None:
        a = PromptSpec(prompt_id="ner", version="v3", system_prompt="text")
        b = PromptSpec(prompt_id="ner", version="v3", system_prompt="text")
        assert a == b

    def test_slots(self) -> None:
        spec = PromptSpec(prompt_id="ner", version="v1", system_prompt="x")
        assert not hasattr(spec, "__dict__")


class TestLLMResponse:
    def test_fields(self) -> None:
        resp = LLMResponse(
            content="hello",
            model="claude-sonnet-4-6",
            input_tokens=10,
            output_tokens=5,
            cost_usd=0.001,
            latency_ms=123,
            prompt_hash="abc",
            input_hash="def",
        )
        assert resp.content == "hello"
        assert resp.cost_usd == 0.001
        assert resp.extra == {}

    def test_frozen(self) -> None:
        resp = LLMResponse(
            content="x",
            model="m",
            input_tokens=0,
            output_tokens=0,
            cost_usd=0.0,
            latency_ms=0,
            prompt_hash="a",
            input_hash="b",
        )
        try:
            resp.content = "y"  # type: ignore[misc]
            raise AssertionError("Should be frozen")
        except AttributeError:
            pass


class TestLLMGatewayError:
    def test_message_and_action(self) -> None:
        err = LLMGatewayError("rate limited", action="fail_fast")
        assert str(err) == "rate limited"
        assert err.action == "fail_fast"
        assert err.cause is None

    def test_with_cause(self) -> None:
        cause = ValueError("bad")
        err = LLMGatewayError("wrapped", cause=cause)
        assert err.cause is cause
