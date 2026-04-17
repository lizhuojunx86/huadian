"""Tests for ai/hashing.py — deterministic hash functions."""

from huadian_pipeline.ai.hashing import input_hash, prompt_hash
from huadian_pipeline.ai.types import PromptSpec


class TestPromptHash:
    def test_deterministic(self) -> None:
        spec = PromptSpec(prompt_id="ner", version="v3", system_prompt="Extract entities.")
        h1 = prompt_hash(spec)
        h2 = prompt_hash(spec)
        assert h1 == h2
        assert len(h1) == 64  # sha256 hex

    def test_different_version_different_hash(self) -> None:
        base = {"prompt_id": "ner", "system_prompt": "Extract entities."}
        h1 = prompt_hash(PromptSpec(version="v3", **base))
        h2 = prompt_hash(PromptSpec(version="v4", **base))
        assert h1 != h2

    def test_different_prompt_different_hash(self) -> None:
        h1 = prompt_hash(PromptSpec(prompt_id="ner", version="v1", system_prompt="A"))
        h2 = prompt_hash(PromptSpec(prompt_id="ner", version="v1", system_prompt="B"))
        assert h1 != h2

    def test_different_id_different_hash(self) -> None:
        h1 = prompt_hash(PromptSpec(prompt_id="ner", version="v1", system_prompt="X"))
        h2 = prompt_hash(PromptSpec(prompt_id="rel", version="v1", system_prompt="X"))
        assert h1 != h2


class TestInputHash:
    def test_deterministic(self) -> None:
        h1 = input_hash("hello world")
        h2 = input_hash("hello world")
        assert h1 == h2
        assert len(h1) == 64

    def test_different_input_different_hash(self) -> None:
        h1 = input_hash("hello")
        h2 = input_hash("world")
        assert h1 != h2

    def test_empty_string(self) -> None:
        h = input_hash("")
        assert len(h) == 64

    def test_unicode(self) -> None:
        h = input_hash("鸿门宴")
        assert len(h) == 64
