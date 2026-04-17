"""Deterministic hashing for prompt and input fingerprinting.

Used for:
  - llm_calls audit (prompt_hash / input_hash columns)
  - Deduplication / cache keys (Phase 1)
  - Idempotency checks
"""

from __future__ import annotations

import hashlib

from .types import PromptSpec


def prompt_hash(spec: PromptSpec) -> str:
    """SHA-256 of (prompt_id + version + system_prompt).

    Deterministic: same inputs always produce the same hash.
    """
    payload = f"{spec.prompt_id}\n{spec.version}\n{spec.system_prompt}"
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def input_hash(text: str) -> str:
    """SHA-256 of the raw user input text."""
    return hashlib.sha256(text.encode("utf-8")).hexdigest()
