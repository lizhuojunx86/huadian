"""Tests for ai/gateway.py — LLMGateway Protocol conformance."""

from huadian_pipeline.ai.gateway import LLMGateway
from huadian_pipeline.ai.types import LLMResponse, PromptSpec


class _StubGateway:
    """Minimal stub to verify Protocol shape."""

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
        return LLMResponse(
            content="stub",
            model="test",
            input_tokens=0,
            output_tokens=0,
            cost_usd=0.0,
            latency_ms=0,
            prompt_hash="h",
            input_hash="h",
        )


def test_stub_satisfies_protocol() -> None:
    """A class with the right call() signature satisfies LLMGateway."""
    gw: LLMGateway = _StubGateway()
    assert gw is not None


async def test_stub_callable() -> None:
    gw = _StubGateway()
    resp = await gw.call(
        PromptSpec(prompt_id="test", version="v1", system_prompt="hi"),
        "input text",
    )
    assert resp.content == "stub"
