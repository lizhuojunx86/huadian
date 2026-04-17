"""LLM Gateway — unified AI access layer (C-7).

All pipeline LLM calls MUST go through this package. Direct use of
provider SDKs (anthropic, openai, etc.) outside this package is
prohibited per project constitution C-7.

Public surface:
  - LLMGateway          — Protocol / abstract contract
  - AnthropicGateway    — Anthropic SDK implementation (Phase 0)
  - LLMResponse         — structured call result
  - LLMGatewayError     — gateway-level error
  - PromptSpec          — prompt identity tuple
  - prompt_hash         — deterministic prompt fingerprint
  - input_hash          — deterministic input fingerprint
"""

from .gateway import LLMGateway
from .hashing import input_hash, prompt_hash
from .types import LLMGatewayError, LLMResponse, PromptSpec

__all__ = [
    "LLMGateway",
    "LLMGatewayError",
    "LLMResponse",
    "PromptSpec",
    "input_hash",
    "prompt_hash",
]
