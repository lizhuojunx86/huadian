"""LLM call audit writer — asyncpg insert into llm_calls (C-7/C-9).

Distinct from qc/audit.py (TraceGuard AuditSink which writes
extractions_history). This writer is responsible ONLY for the
llm_calls table, recording every LLM invocation regardless of
TraceGuard outcome.

Per task card §7: Gateway owns llm_calls; AuditSink owns
extractions_history. They are independent.
"""

from __future__ import annotations

import json
import logging
import uuid
from typing import Any

import asyncpg  # type: ignore[import-untyped]

from ..qc.types import CheckpointResult
from .types import LLMResponse, PromptSpec

logger = logging.getLogger(__name__)


def _llm_call_status(checkpoint_result: CheckpointResult) -> str:
    """Map checkpoint action → llm_call_status enum value."""
    action = checkpoint_result.action
    if action == "pass_through":
        return "success"
    if action == "retry":
        return "retry"
    if action == "degrade":
        return "degraded"
    return "failure"


class LLMCallAuditWriter:
    """Write llm_calls rows via asyncpg.

    Usage:
        writer = LLMCallAuditWriter(dsn)
        await writer.write(prompt, response, checkpoint_result, metadata)
        # ... on shutdown:
        await writer.close()

    The pool is lazily created on first write.
    """

    def __init__(self, dsn: str, *, pool_min: int = 1, pool_max: int = 5) -> None:
        self._dsn = dsn
        self._pool_min = pool_min
        self._pool_max = pool_max
        self._pool: asyncpg.Pool | None = None

    async def _ensure_pool(self) -> asyncpg.Pool:
        if self._pool is None:
            self._pool = await asyncpg.create_pool(
                self._dsn,
                min_size=self._pool_min,
                max_size=self._pool_max,
            )
        return self._pool

    async def close(self) -> None:
        if self._pool is not None:
            await self._pool.close()
            self._pool = None

    async def write(
        self,
        *,
        prompt: PromptSpec,
        response: LLMResponse,
        checkpoint_result: CheckpointResult,
        metadata: dict[str, object],
    ) -> uuid.UUID:
        """Insert one row into llm_calls. Returns the generated row ID."""
        pool = await self._ensure_pool()
        row_id = uuid.uuid4()

        # traceguard_checkpoint_id from checkpoint raw if available
        tg_checkpoint_id: uuid.UUID | None = None
        raw_cp_id = checkpoint_result.raw.get("checkpoint_run_id")
        if raw_cp_id:
            try:
                tg_checkpoint_id = uuid.UUID(str(raw_cp_id))
            except ValueError:
                pass

        response_json: dict[str, Any] = {
            "content": response.content,
            "stop_reason": response.extra.get("stop_reason"),
            "response_id": response.extra.get("response_id"),
        }

        await pool.execute(
            """
            INSERT INTO llm_calls (
                id, prompt_id, prompt_version, prompt_hash, input_hash,
                model, input_tokens, output_tokens, cost_usd,
                latency_ms, response, traceguard_checkpoint_id, status
            ) VALUES (
                $1, $2, $3, $4, $5,
                $6, $7, $8, $9::numeric,
                $10, $11::jsonb, $12, $13::llm_call_status
            )
            """,
            row_id,  # $1
            prompt.prompt_id,  # $2
            f"{prompt.prompt_id}/{prompt.version}",  # $3
            response.prompt_hash,  # $4
            response.input_hash,  # $5
            response.model,  # $6
            response.input_tokens,  # $7
            response.output_tokens,  # $8
            str(response.cost_usd),  # $9
            response.latency_ms,  # $10
            json.dumps(response_json, ensure_ascii=False),  # $11
            tg_checkpoint_id,  # $12
            _llm_call_status(checkpoint_result),  # $13
        )

        logger.debug(
            "audit: wrote llm_call %s for prompt=%s/%s model=%s cost=$%.6f",
            row_id,
            prompt.prompt_id,
            prompt.version,
            response.model,
            response.cost_usd,
        )
        return row_id
