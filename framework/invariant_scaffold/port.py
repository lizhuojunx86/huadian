"""DBPort Protocol — case-domain implements this for their database backend.

Framework reference impl: examples/huadian_classics/db_port.py uses asyncpg
on PostgreSQL. Other case domains can use aiopg / SQLAlchemy / etc.

Self-test infrastructure relies on `transaction()` for safe rollback —
case-domain impl must support nested transaction or savepoint semantics.

License: Apache 2.0
Source: HuaDian Sprint O first-cut framework abstraction.
"""

from __future__ import annotations

from contextlib import AbstractAsyncContextManager
from typing import Any, Protocol


class DBPort(Protocol):
    """Database access protocol for invariant queries.

    Methods:
        fetch         — return list of row-dicts
        fetchval      — return single scalar value
        execute       — run INSERT/UPDATE/DELETE without returning rows
        transaction   — async context manager for atomic units
                        (used by self-tests for safe rollback)

    All methods are async to allow non-blocking IO.

    SQL placeholder convention: case-domain implementations decide on
    placeholder syntax ($1/$2 for asyncpg, %s for aiopg, etc). Framework
    invariant queries are passed through verbatim — the case domain writes
    the SQL with their own placeholder style.
    """

    async def fetch(self, sql: str, *args: Any) -> list[dict[str, Any]]:
        """Run SELECT and return list of row-dicts.

        Empty list = no rows matched.
        """
        ...

    async def fetchval(self, sql: str, *args: Any) -> Any:
        """Run SELECT and return the first column of the first row.

        Returns None if no rows matched.
        """
        ...

    async def execute(self, sql: str, *args: Any) -> None:
        """Run INSERT/UPDATE/DELETE without returning rows."""
        ...

    def transaction(self) -> AbstractAsyncContextManager[None]:
        """Return an async context manager that wraps statements in a transaction.

        Used by SelfTestRunner to inject violations + auto-rollback.

        Implementation must support being used as:

            async with port.transaction():
                await port.execute(...)
                ...
                # On exit, commit if no exception, else rollback.

        For tests + self-tests, the case domain may want a "rollback always"
        variant — implementations are free to provide both modes.
        """
        ...
