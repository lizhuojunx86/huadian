"""Audit sink — write llm_calls + extractions_history to PG (T-TG-002 S-7).

Responsibilities:

1. `write_checkpoint(payload, result)` — called by `Adapter.checkpoint`
   after every evaluation (including shadow mode). One row in
   `llm_calls` and one upsert in `extractions_history`.

2. Idempotency via the **three-tuple key**
   `(paragraph_id, step, prompt_version)`. An `ON CONFLICT DO UPDATE`
   overwrites `output` / `confidence` / `traceguard_raw` if the same
   paragraph is re-processed with the same prompt version (e.g. after
   a retry). The `llm_calls` row is always a fresh INSERT (each
   attempt is a distinct LLM invocation, cost-relevant).

3. `step_name → step enum` mapping (G-3). The Adapter uses versioned
   step names like `"ner_v3"`; the PG `pipeline_step` enum only knows
   un-versioned stems like `"ner"`. We strip the ``_v\\d+$`` suffix. If
   the result doesn't match a known enum value, the INSERT will fail
   with a PG enum CHECK — this is by-design: loud break.

4. `traceguard_checkpoint_id` (G-4). We mint a UUID4 per checkpoint
   invocation, store it in both `llm_calls.traceguard_checkpoint_id`
   and inside `traceguard_raw.checkpoint_run_id`, so the two tables
   can be joined for audit.

Dependencies:
   * `asyncpg` (added in S-7) — async PG driver, zero ORM overhead.
   * A running PostgreSQL 16 with the huadian schema migrated (incl.
     pipeline-side `0001_add_traceguard_raw_and_idempotent_idx.sql`).
"""

from __future__ import annotations

import hashlib
import json
import logging
import re
import uuid
from dataclasses import asdict
from typing import Any

import asyncpg  # type: ignore[import-untyped]

from .types import CheckpointInput, CheckpointResult

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# step_name → pipeline_step enum mapping (G-3)
# ---------------------------------------------------------------------------

# Known values from enums.ts: pipeline_step enum.
_PIPELINE_STEPS: frozenset[str] = frozenset({
    "ingestion", "preprocessing", "ner", "relations",
    "events", "disambiguation", "geocoding", "validation",
})

_VERSION_SUFFIX = re.compile(r"_v\d+$")


def _step_enum(step_name: str) -> str:
    """Map `"ner_v3"` → `"ner"`, `"relations"` → `"relations"`, etc.

    Raises `ValueError` if the de-versioned name is not in the enum
    — caller should surface this as a loud error, not silently eat it.
    """
    stem = _VERSION_SUFFIX.sub("", step_name)
    if stem not in _PIPELINE_STEPS:
        raise ValueError(
            f"step_name {step_name!r} → stem {stem!r} not in pipeline_step "
            f"enum {sorted(_PIPELINE_STEPS)}"
        )
    return stem


# ---------------------------------------------------------------------------
# Hash helpers (G-6)
# ---------------------------------------------------------------------------

def _sha256(data: Any) -> str:
    """Deterministic SHA-256 of a JSON-serialisable value."""
    raw = json.dumps(data, sort_keys=True, ensure_ascii=False)
    return hashlib.sha256(raw.encode()).hexdigest()


# ---------------------------------------------------------------------------
# llm_call_status mapping
# ---------------------------------------------------------------------------

def _llm_call_status(result: CheckpointResult) -> str:
    """Map CheckpointResult.action → llm_call_status enum."""
    if result.action == "pass_through":
        return "success"
    if result.action == "retry":
        return "retry"
    if result.action == "degrade":
        return "degraded"
    # human_queue / fail_fast
    return "failure"


# ---------------------------------------------------------------------------
# Serialisation
# ---------------------------------------------------------------------------

def _build_traceguard_raw(
    payload: CheckpointInput,
    result: CheckpointResult,
    checkpoint_run_id: uuid.UUID,
) -> dict[str, Any]:
    """Build the JSONB blob for `extractions_history.traceguard_raw`."""
    return {
        "checkpoint_run_id": str(checkpoint_run_id),
        "guardian_decision": result.raw.get("tg_decision"),
        "checkpoint_result": {
            "status": result.status,
            "action": result.action,
            "confidence": result.confidence,
            "duration_ms": result.duration_ms,
            "violations": [asdict(v) for v in result.violations],
        },
        "mode": result.raw.get("mode"),
        "attempt": payload.metadata.get("attempt", 1),
        "trace_id": payload.trace_id,
    }


# ---------------------------------------------------------------------------
# AuditSink
# ---------------------------------------------------------------------------

class AuditSink:
    """Write llm_calls + extractions_history to PG after each checkpoint.

    Usage (inside Adapter.checkpoint):

        sink = AuditSink(dsn)
        await sink.write_checkpoint(payload, result)

    The pool is lazily created on first call and reused thereafter.
    Call `await sink.close()` during graceful shutdown.
    """

    def __init__(self, dsn: str, *, pool_min: int = 1, pool_max: int = 5) -> None:
        self._dsn = dsn
        self._pool_min = pool_min
        self._pool_max = pool_max
        self._pool: asyncpg.Pool | None = None

    async def _ensure_pool(self) -> asyncpg.Pool:
        if self._pool is None:
            self._pool = await asyncpg.create_pool(
                self._dsn, min_size=self._pool_min, max_size=self._pool_max,
            )
        return self._pool

    async def close(self) -> None:
        if self._pool is not None:
            await self._pool.close()
            self._pool = None

    async def write_checkpoint(
        self,
        payload: CheckpointInput,
        result: CheckpointResult,
    ) -> uuid.UUID:
        """Write one llm_calls row + upsert one extractions_history row.

        Returns the checkpoint_run_id (UUID) that links the two rows.
        """
        checkpoint_run_id = uuid.uuid4()
        pool = await self._ensure_pool()

        async with pool.acquire() as conn:
            async with conn.transaction():
                await self._insert_llm_call(
                    conn, payload, result, checkpoint_run_id,
                )
                await self._upsert_extraction(
                    conn, payload, result, checkpoint_run_id,
                )

        logger.debug(
            "audit: wrote checkpoint %s for step=%s para=%s",
            checkpoint_run_id,
            payload.step_name,
            payload.metadata.get("paragraph_id"),
        )
        return checkpoint_run_id

    # ------------------------------------------------------------------
    # SQL
    # ------------------------------------------------------------------

    @staticmethod
    async def _insert_llm_call(
        conn: Any,  # asyncpg.Connection | PoolConnectionProxy
        payload: CheckpointInput,
        result: CheckpointResult,
        checkpoint_run_id: uuid.UUID,
    ) -> None:
        prompt_hash = _sha256(payload.prompt_version)
        input_hash = _sha256(payload.inputs)
        await conn.execute(
            """
            INSERT INTO llm_calls (
                prompt_id, prompt_version, prompt_hash, input_hash,
                model, latency_ms, response,
                traceguard_checkpoint_id, status
            ) VALUES ($1, $2, $3, $4, $5, $6, $7::jsonb, $8, $9::llm_call_status)
            """,
            payload.step_name,            # prompt_id
            payload.prompt_version,       # prompt_version
            prompt_hash,                  # prompt_hash
            input_hash,                   # input_hash
            payload.model,                # model
            result.duration_ms,           # latency_ms
            json.dumps(payload.outputs, ensure_ascii=False),  # response
            checkpoint_run_id,            # traceguard_checkpoint_id
            _llm_call_status(result),     # status
        )

    @staticmethod
    async def _upsert_extraction(
        conn: Any,  # asyncpg.Connection | PoolConnectionProxy
        payload: CheckpointInput,
        result: CheckpointResult,
        checkpoint_run_id: uuid.UUID,
    ) -> None:
        paragraph_id_raw = payload.metadata.get("paragraph_id")
        if paragraph_id_raw is None:
            logger.warning(
                "audit: skipping extractions_history — no paragraph_id in "
                "metadata for step %s",
                payload.step_name,
            )
            return

        try:
            paragraph_id = uuid.UUID(str(paragraph_id_raw))
        except ValueError:
            logger.warning(
                "audit: skipping extractions_history — paragraph_id %r is not "
                "a valid UUID",
                paragraph_id_raw,
            )
            return

        step_enum = _step_enum(payload.step_name)  # G-3 mapping
        tg_raw = _build_traceguard_raw(payload, result, checkpoint_run_id)

        await conn.execute(
            """
            INSERT INTO extractions_history (
                paragraph_id, step, prompt_version,
                output, confidence, traceguard_raw
            ) VALUES (
                $1, $2::pipeline_step, $3,
                $4::jsonb, $5, $6::jsonb
            )
            ON CONFLICT (paragraph_id, step, prompt_version) DO UPDATE SET
                output          = EXCLUDED.output,
                confidence      = EXCLUDED.confidence,
                traceguard_raw  = EXCLUDED.traceguard_raw
            """,
            paragraph_id,                                          # $1
            step_enum,                                             # $2
            payload.prompt_version,                                # $3
            json.dumps(payload.outputs, ensure_ascii=False),       # $4
            float(result.confidence),                              # $5
            json.dumps(tg_raw, ensure_ascii=False, default=str),   # $6
        )

    # ------------------------------------------------------------------
    # Migration helper
    # ------------------------------------------------------------------

    @staticmethod
    async def run_migration(conn: asyncpg.Connection) -> None:
        """Apply pipeline-side migration idempotently.

        Safe to call on every startup — uses IF NOT EXISTS / IF NOT EXISTS.
        """
        await conn.execute(
            "ALTER TABLE extractions_history "
            "ADD COLUMN IF NOT EXISTS traceguard_raw JSONB"
        )
        await conn.execute(
            "CREATE UNIQUE INDEX IF NOT EXISTS idx_ext_hist_idempotent "
            "ON extractions_history (paragraph_id, step, prompt_version)"
        )
