"""Prompt loader — reads versioned .md prompt files into PromptSpec.

Each prompt file is a Markdown file with YAML frontmatter:
  ---
  prompt_id: ner
  version: v1
  description: ...
  ---
  # System Prompt
  ... (the actual system prompt text)
"""

from __future__ import annotations

import hashlib
from pathlib import Path

from ..ai.types import PromptSpec

_PROMPTS_DIR = Path(__file__).parent


def load_prompt(prompt_id: str, version: str) -> PromptSpec:
    """Load a prompt file and return a PromptSpec.

    Parameters
    ----------
    prompt_id : str
        Prompt identifier (e.g. "ner").
    version : str
        Version string (e.g. "v1").

    Returns
    -------
    PromptSpec with the system prompt text loaded from disk.
    """
    filename = f"{prompt_id}_{version}.md"
    path = _PROMPTS_DIR / filename
    if not path.exists():
        raise FileNotFoundError(f"Prompt file not found: {path}")

    raw = path.read_text(encoding="utf-8")
    system_prompt = _extract_system_prompt(raw)

    return PromptSpec(
        prompt_id=prompt_id,
        version=version,
        system_prompt=system_prompt,
    )


def prompt_file_hash(prompt_id: str, version: str) -> str:
    """Compute SHA-256 hash of the prompt file for audit tracing."""
    filename = f"{prompt_id}_{version}.md"
    path = _PROMPTS_DIR / filename
    if not path.exists():
        raise FileNotFoundError(f"Prompt file not found: {path}")
    content = path.read_bytes()
    return hashlib.sha256(content).hexdigest()


def _extract_system_prompt(raw: str) -> str:
    """Extract the system prompt text from a frontmatter+markdown file.

    Strips the YAML frontmatter (between --- delimiters) and returns
    everything after it.
    """
    lines = raw.split("\n")
    in_frontmatter = False
    frontmatter_end = 0

    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped == "---":
            if not in_frontmatter:
                in_frontmatter = True
            else:
                frontmatter_end = i + 1
                break

    body = "\n".join(lines[frontmatter_end:]).strip()
    return body
