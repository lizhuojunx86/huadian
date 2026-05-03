"""HuaDian classics — DBPort implementation backed by asyncpg.

Wraps an asyncpg.Pool as the framework's DBPort Protocol. All queries
execute against a connection acquired from the pool; transaction()
returns a context manager that uses asyncpg's transaction.

License: Apache 2.0
Source: HuaDian Sprint O.
"""

from __future__ import annotations

from contextlib import AbstractAsyncContextManager, asynccontextmanager
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from collections.abc import AsyncIterator

    import asyncpg


class HuaDianAsyncpgPort:
    """DBPort Protocol implementation for HuaDian Postgres via asyncpg.

    Two construction modes:
        1. Pool-based (default): each method acquires a fresh connection
           from the pool — suitable for stateless invariant queries.
        2. Connection-bound (via with_connection): all methods share one
           connection — required when self-test wraps multiple statements
           in a single transaction.
    """

    def __init__(self, pool: asyncpg.Pool | None = None) -> None:
        self._pool = pool
        self._conn: asyncpg.Connection | None = None

    @classmethod
    def with_connection(cls, conn: asyncpg.Connection) -> HuaDianAsyncpgPort:
        """Build a port bound to a specific connection (for transactional self-tests)."""
        instance = cls()
        instance._conn = conn
        return instance

    async def fetch(self, sql: str, *args: Any) -> list[dict[str, Any]]:
        if self._conn is not None:
            rows = await self._conn.fetch(sql, *args)
        else:
            assert self._pool is not None, "neither pool nor bound connection set"
            async with self._pool.acquire() as conn:
                rows = await conn.fetch(sql, *args)
        return [dict(r) for r in rows]

    async def fetchval(self, sql: str, *args: Any) -> Any:
        if self._conn is not None:
            return await self._conn.fetchval(sql, *args)
        assert self._pool is not None, "neither pool nor bound connection set"
        async with self._pool.acquire() as conn:
            return await conn.fetchval(sql, *args)

    async def execute(self, sql: str, *args: Any) -> None:
        if self._conn is not None:
            await self._conn.execute(sql, *args)
            return
        assert self._pool is not None, "neither pool nor bound connection set"
        async with self._pool.acquire() as conn:
            await conn.execute(sql, *args)

    def transaction(self) -> AbstractAsyncContextManager[None]:
        """Return a context manager that wraps statements in a transaction.

        For self-test usage: the framework's SelfTestRunner forces rollback
        via _RollbackSentinel exception, so commit-on-success behavior is
        irrelevant in that path. For other uses (e.g. apply migrations) the
        context manager commits on clean exit.

        Note: when constructed via __init__(pool), this acquires a fresh
        connection internally. Most invariant code should use
        `with_connection` + caller-managed transaction for clarity.
        """
        return self._transaction_ctx()

    @asynccontextmanager
    async def _transaction_ctx(self) -> AsyncIterator[None]:
        if self._conn is not None:
            async with self._conn.transaction():
                yield
            return
        assert self._pool is not None, "neither pool nor bound connection set"
        async with self._pool.acquire() as conn, conn.transaction():
            # Bind the connection for the duration of this transaction so
            # subsequent fetch/execute calls on the same port instance use
            # the same connection (and participate in this transaction).
            self._conn = conn
            try:
                yield
            finally:
                self._conn = None
