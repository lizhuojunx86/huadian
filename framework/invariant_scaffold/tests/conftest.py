"""Shared pytest fixtures for framework.invariant_scaffold tests.

Provides ``FakePort`` — an in-memory :class:`DBPort` that records calls and
returns canned data. Lets every pattern test run without a database.

Cross-domain note: real impls will use asyncpg / aiopg / etc. ``FakePort``
is for unit tests only; integration tests live in
``examples/huadian_classics/test_byte_identical.py`` (Sprint N).

License: Apache 2.0
"""

from __future__ import annotations

from contextlib import asynccontextmanager
from typing import Any

import pytest

from framework.invariant_scaffold.port import DBPort


class FakePort(DBPort):
    """In-memory ``DBPort`` recording fetch / fetchval / execute calls.

    Configure return values via constructor:
        FakePort(fetch=[{...}, {...}], fetchval=42)

    Or per-call by mutating ``self.fetch_return`` / ``self.fetchval_return``
    between assertions.
    """

    def __init__(
        self,
        *,
        fetch: list[dict[str, Any]] | None = None,
        fetchval: Any = None,
    ) -> None:
        self.fetch_return: list[dict[str, Any]] = fetch or []
        self.fetchval_return: Any = fetchval
        self.fetch_calls: list[tuple[str, tuple[Any, ...]]] = []
        self.fetchval_calls: list[tuple[str, tuple[Any, ...]]] = []
        self.execute_calls: list[tuple[str, tuple[Any, ...]]] = []
        self.transaction_entered: int = 0

    async def fetch(self, sql: str, *args: Any) -> list[dict[str, Any]]:
        self.fetch_calls.append((sql, args))
        return list(self.fetch_return)

    async def fetchval(self, sql: str, *args: Any) -> Any:
        self.fetchval_calls.append((sql, args))
        return self.fetchval_return

    async def execute(self, sql: str, *args: Any) -> None:
        self.execute_calls.append((sql, args))

    def transaction(self):
        @asynccontextmanager
        async def _ctx():
            self.transaction_entered += 1
            yield None

        return _ctx()


@pytest.fixture
def fake_port() -> FakePort:
    """Default FakePort returning empty fetch + None fetchval."""
    return FakePort()
