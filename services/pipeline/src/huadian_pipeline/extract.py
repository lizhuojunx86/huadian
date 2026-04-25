"""Extract module — runs LLM NER on raw_text chunks via Gateway.

Handles:
  1. Load raw_text paragraphs from DB (by book_id)
  2. For each paragraph, call LLM Gateway with NER prompt
  3. Parse JSON output into ExtractedPerson models
  4. Track cumulative cost, enforce budget limits
  5. Write results to extractions_history
"""

from __future__ import annotations

import json
import logging
from dataclasses import dataclass, field
from typing import TYPE_CHECKING

from .ai.types import LLMGatewayError, LLMResponse, PromptSpec
from .prompts.loader import load_prompt, prompt_file_hash

if TYPE_CHECKING:
    import asyncpg

    from .ai.anthropic_provider import AnthropicGateway

logger = logging.getLogger(__name__)

# Budget guardrails
DEFAULT_PHASE_BUDGET_USD = 5.0
MAX_CHUNK_COST_USD = 2.0


@dataclass(frozen=True, slots=True)
class SurfaceForm:
    """A single surface form with its name type."""

    text: str
    name_type: str


@dataclass(frozen=True, slots=True)
class ExtractedPerson:
    """A single person entity extracted from a text chunk."""

    name_zh: str
    surface_forms: list[SurfaceForm]
    dynasty: str
    reality_status: str
    brief: str
    confidence: float
    identity_notes: str | None
    chunk_paragraph_no: int  # which paragraph this was extracted from
    chunk_id: str  # raw_texts.id
    llm_call_id: str | None = None  # llm_calls.id; carried from LLMResponse.call_id


@dataclass(slots=True)
class ExtractionResult:
    """Result of extracting persons from a book/chapter."""

    book_id: str
    chapter: str
    total_paragraphs: int
    processed_paragraphs: int
    failed_paragraphs: int
    persons: list[ExtractedPerson] = field(default_factory=list)
    total_cost_usd: float = 0.0
    total_input_tokens: int = 0
    total_output_tokens: int = 0
    errors: list[str] = field(default_factory=list)
    prompt_version: str = ""
    prompt_file_hash: str = ""
    model: str = ""
    budget_exceeded: bool = False


async def extract_persons(
    pool: asyncpg.Pool,
    gateway: AnthropicGateway,
    *,
    book_id: str,
    chapter_name: str,
    budget_usd: float = DEFAULT_PHASE_BUDGET_USD,
) -> ExtractionResult:
    """Extract person entities from all paragraphs of a book/chapter.

    Parameters
    ----------
    pool : asyncpg.Pool
        Database connection pool.
    gateway : AnthropicGateway
        LLM Gateway instance.
    book_id : str
        UUID of the book in the books table.
    chapter_name : str
        Chapter name for logging.
    budget_usd : float
        Maximum total cost for this extraction run.
    """
    # Load prompt
    prompt = load_prompt("ner", "v1-r5")
    file_hash = prompt_file_hash("ner", "v1-r5")

    result = ExtractionResult(
        book_id=book_id,
        chapter=chapter_name,
        total_paragraphs=0,
        processed_paragraphs=0,
        failed_paragraphs=0,
        prompt_version=f"{prompt.prompt_id}/{prompt.version}",
        prompt_file_hash=file_hash,
    )

    # Fetch paragraphs
    async with pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT id, paragraph_no, raw_text
            FROM raw_texts
            WHERE book_id = $1 AND deleted_at IS NULL
            ORDER BY paragraph_no
            """,
            book_id,
        )

    result.total_paragraphs = len(rows)
    logger.info(
        "Extracting persons from %s: %d paragraphs, budget=$%.2f",
        chapter_name,
        len(rows),
        budget_usd,
    )

    for row in rows:
        chunk_id = str(row["id"])
        paragraph_no = row["paragraph_no"]
        raw_text = row["raw_text"]

        # Budget check before each call
        if result.total_cost_usd >= budget_usd:
            logger.warning(
                "Budget exhausted ($%.4f >= $%.2f), stopping extraction",
                result.total_cost_usd,
                budget_usd,
            )
            result.budget_exceeded = True
            break

        try:
            persons, llm_response = await _extract_chunk(
                gateway,
                prompt,
                raw_text=raw_text,
                paragraph_no=paragraph_no,
                chunk_id=chunk_id,
                book_id=book_id,
            )

            # Cost tracking
            result.total_cost_usd += llm_response.cost_usd
            result.total_input_tokens += llm_response.input_tokens
            result.total_output_tokens += llm_response.output_tokens
            if not result.model:
                result.model = llm_response.model

            # Single chunk cost guard
            if llm_response.cost_usd > MAX_CHUNK_COST_USD:
                msg = f"Chunk §{paragraph_no} cost ${llm_response.cost_usd:.4f} > ${MAX_CHUNK_COST_USD} limit!"
                logger.error(msg)
                result.errors.append(msg)
                result.budget_exceeded = True
                break

            result.persons.extend(persons)
            result.processed_paragraphs += 1

            logger.info(
                "  §%d: %d persons, $%.4f (%d+%d tokens)",
                paragraph_no,
                len(persons),
                llm_response.cost_usd,
                llm_response.input_tokens,
                llm_response.output_tokens,
            )

        except LLMGatewayError as e:
            result.failed_paragraphs += 1
            msg = f"§{paragraph_no} LLM error: {e}"
            logger.error(msg)
            result.errors.append(msg)
            continue
        except Exception as e:
            result.failed_paragraphs += 1
            msg = f"§{paragraph_no} unexpected error: {e}"
            logger.exception(msg)
            result.errors.append(msg)
            continue

    # Check failure rate
    if result.total_paragraphs > 0:
        failure_rate = result.failed_paragraphs / result.total_paragraphs
        if failure_rate > 0.2:
            logger.error(
                "Failure rate %.0f%% > 20%%, extraction quality suspect",
                failure_rate * 100,
            )

    logger.info(
        "Extraction complete: %d persons from %d/%d paragraphs, $%.4f total",
        len(result.persons),
        result.processed_paragraphs,
        result.total_paragraphs,
        result.total_cost_usd,
    )

    return result


async def _extract_chunk(
    gateway: AnthropicGateway,
    prompt: PromptSpec,
    *,
    raw_text: str,
    paragraph_no: int,
    chunk_id: str,
    book_id: str,
) -> tuple[list[ExtractedPerson], LLMResponse]:
    """Extract persons from a single text chunk."""
    response = await gateway.call(
        prompt,
        raw_text,
        metadata={
            "paragraph_no": paragraph_no,
            "chunk_id": chunk_id,
            "book_id": book_id,
            "task": "ner",
        },
    )

    persons = _parse_response(
        response.content, paragraph_no, chunk_id, llm_call_id=response.call_id
    )
    return persons, response


def _extract_last_json_array(text: str) -> list[object] | None:
    """Extract the last top-level JSON array from text with multiple blocks.

    Handles LLM "self-correction" outputs where the model produces an initial
    JSON array, adds explanatory text, then outputs a corrected array.
    Returns the parsed last array, or None if no valid array found.
    """
    last_end = text.rfind("]")
    while last_end >= 0:
        # Walk backwards to find the matching '['
        depth = 1
        pos = last_end - 1
        while pos >= 0 and depth > 0:
            if text[pos] == "]":
                depth += 1
            elif text[pos] == "[":
                depth -= 1
            pos -= 1
        if depth == 0:
            candidate = text[pos + 1 : last_end + 1]
            try:
                data = json.loads(candidate)
                if isinstance(data, list):
                    return data
            except json.JSONDecodeError:
                pass
        # Try the next ']' leftward
        last_end = text.rfind("]", 0, last_end)
    return None


def _parse_response(
    content: str,
    paragraph_no: int,
    chunk_id: str,
    llm_call_id: str | None = None,
) -> list[ExtractedPerson]:
    """Parse LLM JSON response into ExtractedPerson list."""
    # Strip markdown code fences if present
    text = content.strip()
    if text.startswith("```"):
        lines = text.split("\n")
        # Remove first and last lines (```json and ```)
        lines = [ln for ln in lines if not ln.strip().startswith("```")]
        text = "\n".join(lines).strip()

    try:
        data = json.loads(text)
    except json.JSONDecodeError:
        # Fallback: LLM sometimes self-corrects, producing multiple JSON
        # blocks separated by explanation text. Extract the last complete
        # JSON array (the corrected version).
        data = _extract_last_json_array(text)
        if data is None:
            logger.warning("§%d: Failed to parse any JSON array from response", paragraph_no)
            logger.debug("Raw content: %s", content[:500])
            return []
        logger.info(
            "§%d: Recovered JSON from multi-block LLM self-correction output",
            paragraph_no,
        )

    if not isinstance(data, list):
        logger.warning("§%d: Expected JSON array, got %s", paragraph_no, type(data).__name__)
        return []

    persons: list[ExtractedPerson] = []
    for item in data:
        if not isinstance(item, dict):
            continue
        try:
            # Parse structured surface_forms (object array or string array fallback)
            raw_sf = item.get("surface_forms", [])
            surface_forms = _parse_surface_forms(raw_sf)

            person = ExtractedPerson(
                name_zh=item.get("name_zh", ""),
                surface_forms=surface_forms,
                dynasty=item.get("dynasty", ""),
                reality_status=_normalize_reality_status(item.get("reality_status", "uncertain")),
                brief=item.get("brief", ""),
                confidence=float(item.get("confidence", 0.5)),
                identity_notes=item.get("identity_notes"),
                chunk_paragraph_no=paragraph_no,
                chunk_id=chunk_id,
                llm_call_id=llm_call_id,
            )
            if person.name_zh:
                persons.append(person)
        except (TypeError, ValueError) as e:
            logger.warning("§%d: Skipping malformed person entry: %s", paragraph_no, e)

    return persons


def _parse_surface_forms(raw: list[object]) -> list[SurfaceForm]:
    """Parse surface_forms from LLM output.

    Handles both structured format [{"text": ..., "name_type": ...}]
    and legacy flat format ["name1", "name2"] (fallback).
    """
    result: list[SurfaceForm] = []
    for item in raw:
        if isinstance(item, dict):
            text = item.get("text", "")
            name_type = _normalize_name_type(item.get("name_type", "alias"))
            if text:
                result.append(SurfaceForm(text=text, name_type=name_type))
        elif isinstance(item, str) and item:
            # Fallback: flat string list → all treated as alias
            result.append(SurfaceForm(text=item, name_type="alias"))
    return result


def _normalize_name_type(raw: str) -> str:
    """Normalize name_type to match DB enum values."""
    mapping = {
        "primary": "primary",
        "courtesy": "courtesy",
        "art": "art",
        "studio": "studio",
        "posthumous": "posthumous",
        "temple": "temple",
        "nickname": "nickname",
        "self_ref": "self_ref",
        "alias": "alias",
    }
    return mapping.get(raw.lower(), "primary")


def _normalize_reality_status(raw: str) -> str:
    """Normalize reality_status to match DB enum values."""
    mapping = {
        "historical": "historical",
        "legendary": "legendary",
        "mythical": "mythical",
        "fictional": "fictional",
        "composite": "composite",
        "uncertain": "uncertain",
    }
    return mapping.get(raw.lower(), "uncertain")
