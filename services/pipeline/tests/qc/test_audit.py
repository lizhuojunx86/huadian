"""Integration tests for AuditSink (T-TG-002 S-7).

These tests hit a real PostgreSQL 16 via testcontainers. Docker must
be available on the machine; tests are auto-skipped otherwise.

We create a minimal schema (just the tables + enums audit.py touches)
rather than running the full Drizzle migration — keeps the test
hermetic and fast.
"""

from __future__ import annotations

import json
import uuid
from collections.abc import Iterator

import pytest

from huadian_pipeline.qc.audit import AuditSink, _step_enum
from huadian_pipeline.qc.types import CheckpointInput, CheckpointResult, Violation

# ---------------------------------------------------------------------------
# Docker / testcontainers availability
# ---------------------------------------------------------------------------

_docker_available = True
try:
    import docker

    docker.from_env().ping()
except Exception:
    _docker_available = False

pytestmark = pytest.mark.skipif(
    not _docker_available,
    reason="Docker not available — skip PG integration tests",
)


# ---------------------------------------------------------------------------
# Minimal schema (mirrors only what audit.py touches)
# ---------------------------------------------------------------------------

_SCHEMA_SQL = """
-- enums
DO $$ BEGIN
  CREATE TYPE pipeline_step AS ENUM(
    'ingestion','preprocessing','ner','relations',
    'events','disambiguation','geocoding','validation'
  );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE llm_call_status AS ENUM('success','failure','retry','degraded');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- tables
CREATE TABLE IF NOT EXISTS raw_texts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid()
);

CREATE TABLE IF NOT EXISTS llm_calls (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prompt_id TEXT NOT NULL,
  prompt_version TEXT NOT NULL,
  prompt_hash TEXT NOT NULL,
  input_hash TEXT NOT NULL,
  model TEXT NOT NULL,
  model_version TEXT,
  input_tokens INTEGER,
  output_tokens INTEGER,
  cost_usd NUMERIC(10,6),
  latency_ms INTEGER,
  response JSONB,
  traceguard_checkpoint_id UUID,
  status llm_call_status,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE TABLE IF NOT EXISTS extractions_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pipeline_run_id UUID,
  paragraph_id UUID NOT NULL,
  step pipeline_step NOT NULL,
  prompt_version TEXT NOT NULL,
  output JSONB NOT NULL,
  confidence NUMERIC(4,3),
  traceguard_raw JSONB,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_ext_hist_idempotent
  ON extractions_history (paragraph_id, step, prompt_version);
"""


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

@pytest.fixture(scope="module")
def pg_dsn() -> Iterator[str]:
    """Spin up a Postgres 16 container and return the DSN."""
    from testcontainers.postgres import PostgresContainer  # type: ignore[import-untyped]

    with PostgresContainer("postgres:16", driver=None) as pg:
        dsn = pg.get_connection_url().replace("+psycopg2", "")
        # Apply minimal schema
        import asyncio

        import asyncpg  # type: ignore[import-untyped]

        async def _init() -> None:
            conn = await asyncpg.connect(dsn)
            try:
                await conn.execute(_SCHEMA_SQL)
            finally:
                await conn.close()

        asyncio.get_event_loop().run_until_complete(_init())
        yield dsn


@pytest.fixture()
def para_id() -> uuid.UUID:
    return uuid.uuid4()


def _mk_payload(
    para_id: uuid.UUID,
    *,
    step: str = "ner_v3",
    attempt: int = 1,
) -> CheckpointInput:
    return CheckpointInput(
        step_name=step,
        trace_id=str(uuid.uuid4()),
        prompt_version="v3",
        model="claude-opus-4-6",
        inputs={"paragraph_text": "项羽引兵入咸阳"},
        outputs={"entities": [{"surface_form": "项羽", "entity_type": "PERSON"}]},
        metadata={"paragraph_id": str(para_id), "attempt": attempt},
    )


def _mk_result(
    *,
    action: str = "pass_through",
    confidence: float = 0.95,
    violations: list[Violation] | None = None,
    mode: str = "enforce",
) -> CheckpointResult:
    return CheckpointResult(
        status="pass" if not violations else "fail",
        action=action,  # type: ignore[arg-type]
        violations=violations or [],
        confidence=confidence,
        duration_ms=12,
        raw={"mode": mode, "tg_action": "pass", "tg_decision": {}},
    )


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_write_checkpoint_inserts_both_tables(
    pg_dsn: str, para_id: uuid.UUID
) -> None:
    sink = AuditSink(pg_dsn)
    try:
        payload = _mk_payload(para_id)
        result = _mk_result()
        run_id = await sink.write_checkpoint(payload, result)

        pool = await sink._ensure_pool()
        async with pool.acquire() as conn:
            llm_row = await conn.fetchrow(
                "SELECT * FROM llm_calls WHERE traceguard_checkpoint_id = $1",
                run_id,
            )
            ext_row = await conn.fetchrow(
                "SELECT * FROM extractions_history WHERE paragraph_id = $1",
                para_id,
            )
        assert llm_row is not None
        assert llm_row["prompt_version"] == "v3"
        assert llm_row["model"] == "claude-opus-4-6"
        assert llm_row["status"] == "success"

        assert ext_row is not None
        assert ext_row["step"] == "ner"
        assert ext_row["prompt_version"] == "v3"
        raw = json.loads(ext_row["traceguard_raw"])
        assert raw["checkpoint_run_id"] == str(run_id)
        assert raw["mode"] == "enforce"
    finally:
        await sink.close()


@pytest.mark.asyncio
async def test_upsert_overwrites_on_conflict(
    pg_dsn: str, para_id: uuid.UUID
) -> None:
    sink = AuditSink(pg_dsn)
    try:
        payload = _mk_payload(para_id)
        result_v1 = _mk_result(confidence=0.5)
        await sink.write_checkpoint(payload, result_v1)

        result_v2 = _mk_result(confidence=0.99)
        await sink.write_checkpoint(payload, result_v2)

        pool = await sink._ensure_pool()
        async with pool.acquire() as conn:
            ext_row = await conn.fetchrow(
                "SELECT confidence FROM extractions_history WHERE paragraph_id = $1",
                para_id,
            )
        # Should have the v2 confidence, not v1
        assert float(ext_row["confidence"]) == pytest.approx(0.99, abs=0.01)

        # But llm_calls should have 2 rows (each attempt is a distinct invocation)
        async with pool.acquire() as conn:
            count = await conn.fetchval(
                "SELECT count(*) FROM llm_calls WHERE prompt_version = 'v3' AND model = 'claude-opus-4-6'"
            )
        assert count >= 2
    finally:
        await sink.close()


@pytest.mark.asyncio
async def test_shadow_mode_still_writes(
    pg_dsn: str, para_id: uuid.UUID
) -> None:
    sink = AuditSink(pg_dsn)
    try:
        payload = _mk_payload(para_id)
        result = _mk_result(mode="shadow")
        await sink.write_checkpoint(payload, result)

        pool = await sink._ensure_pool()
        async with pool.acquire() as conn:
            ext_row = await conn.fetchrow(
                "SELECT traceguard_raw FROM extractions_history WHERE paragraph_id = $1",
                para_id,
            )
        raw = json.loads(ext_row["traceguard_raw"])
        assert raw["mode"] == "shadow"
    finally:
        await sink.close()


@pytest.mark.asyncio
async def test_missing_paragraph_id_skips_extraction(pg_dsn: str) -> None:
    """If metadata has no paragraph_id, llm_calls is written but
    extractions_history is gracefully skipped."""
    sink = AuditSink(pg_dsn)
    try:
        payload = CheckpointInput(
            step_name="ner_v3",
            trace_id="t1",
            prompt_version="v3",
            model="m",
            inputs={},
            outputs={"entities": []},
            metadata={},  # no paragraph_id
        )
        result = _mk_result()
        run_id = await sink.write_checkpoint(payload, result)

        pool = await sink._ensure_pool()
        async with pool.acquire() as conn:
            llm_row = await conn.fetchrow(
                "SELECT * FROM llm_calls WHERE traceguard_checkpoint_id = $1",
                run_id,
            )
        assert llm_row is not None  # llm_calls written
    finally:
        await sink.close()


@pytest.mark.asyncio
async def test_run_migration_is_idempotent(pg_dsn: str) -> None:
    import asyncpg as apg  # type: ignore[import-untyped]

    conn = await apg.connect(pg_dsn)
    try:
        # Should succeed twice without error
        await AuditSink.run_migration(conn)
        await AuditSink.run_migration(conn)
    finally:
        await conn.close()


# ---------------------------------------------------------------------------
# Unit tests (no PG needed)
# ---------------------------------------------------------------------------

@pytest.mark.parametrize(
    ("step_name", "expected"),
    [
        ("ner_v3", "ner"),
        ("relations", "relations"),
        ("disambiguation", "disambiguation"),
        ("events_v1", "events"),
    ],
)
def test_step_enum_mapping(step_name: str, expected: str) -> None:
    assert _step_enum(step_name) == expected


def test_step_enum_rejects_unknown() -> None:
    with pytest.raises(ValueError, match="not in pipeline_step enum"):
        _step_enum("llm_judge_v2")
