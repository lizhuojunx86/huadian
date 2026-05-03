"""SelfTest Protocol + SelfTestRunner — verify that invariants actually catch violations.

A "self-test" injects a violating row, runs the invariant, asserts it
catches the injection, then rolls back the transaction. This guards against
a class of bugs where the invariant SQL has a typo / logic error and silently
passes regardless of data state.

Pattern (HuaDian V9 example):

    class V9MissingPrimarySelfTest:
        name = "v9_missing_primary"
        invariant_name = "V9"

        async def setup_violation(self, port: DBPort) -> None:
            # Insert person + name with is_primary=false
            await port.execute("INSERT INTO persons ...")
            await port.execute(
                "INSERT INTO person_names (...) VALUES (..., is_primary=false)"
            )

        def expected_violation_predicate(self, violation):
            # Match the injected person by some identifier in row_data
            return violation.row_data.get("slug", "").startswith("test-v9-")

The framework provides `SelfTestRunner` that:
    1. Begins a transaction
    2. Calls `setup_violation()`
    3. Runs the invariant
    4. Verifies at least one violation matches `expected_violation_predicate`
    5. Always rolls back (no DB pollution)

License: Apache 2.0
Source: HuaDian Sprint O first-cut framework abstraction.
"""

from __future__ import annotations

import logging
import time
from typing import Protocol

from .invariant import Invariant
from .port import DBPort
from .types import SelfTestResult, Violation

logger = logging.getLogger(__name__)


class SelfTest(Protocol):
    """Protocol for an invariant self-test.

    Implementations inject a known violation, then verify the invariant
    catches it. Setup runs inside a transaction managed by SelfTestRunner;
    the transaction is always rolled back at the end (success or failure).

    Required attributes:
        name:           short identifier for the self-test (e.g. "v9_missing_primary")
        invariant_name: name of the invariant being verified (must match
                        Invariant.name registered with the runner)

    Required methods:
        setup_violation:               inject the violating row(s) via port.execute()
        expected_violation_predicate:  given a Violation returned by the
                                       invariant, return True if it matches
                                       the injected row (allowing other
                                       pre-existing violations to be ignored)
    """

    name: str
    invariant_name: str

    async def setup_violation(self, port: DBPort) -> None:
        """Inject the violating row(s) into the DB."""
        ...

    def expected_violation_predicate(self, violation: Violation) -> bool:
        """Return True if `violation` is the injected one (vs pre-existing)."""
        ...


class SelfTestRunner:
    """Run self-tests against registered invariants with transactional safety."""

    def __init__(self, port: DBPort, invariants: list[Invariant]) -> None:
        self._port = port
        self._invariants_by_name: dict[str, Invariant] = {inv.name: inv for inv in invariants}

    async def verify(self, self_test: SelfTest) -> SelfTestResult:
        """Run a single self-test:

            1. begin transaction
            2. setup_violation
            3. run target invariant
            4. check that at least one returned violation matches the predicate
            5. always rollback

        Returns a SelfTestResult with caught=True iff the invariant detected
        the injection. If the target invariant is not registered, returns
        caught=False with a diagnostic detail.
        """
        invariant = self._invariants_by_name.get(self_test.invariant_name)
        if invariant is None:
            return SelfTestResult(
                self_test_name=self_test.name,
                invariant_name=self_test.invariant_name,
                caught=False,
                duration_ms=0.0,
                detail=f"target invariant {self_test.invariant_name!r} not registered",
            )

        start = time.perf_counter()
        caught = False
        detail = ""

        # Outer try/finally ensures we always attempt rollback via the
        # transaction context manager. Any exception inside the with-block
        # is captured and reported as detail.
        try:
            async with self._port.transaction():
                await self_test.setup_violation(self._port)
                result = await invariant.run(self._port)
                caught = any(self_test.expected_violation_predicate(v) for v in result.violations)
                if not caught:
                    detail = (
                        f"invariant ran but no violation matched predicate "
                        f"(got {result.violation_count} total violations)"
                    )
                # Force rollback by raising — the transaction context manager
                # converts this into a rollback. We catch & translate below.
                raise _RollbackSentinel()
        except _RollbackSentinel:
            pass  # expected — used to force rollback
        except Exception as exc:  # noqa: BLE001
            detail = f"self-test raised exception: {exc!r}"
            caught = False

        duration_ms = (time.perf_counter() - start) * 1000
        if caught:
            logger.info(
                "[OK] self-test %s caught injected violation in %s (%.1fms)",
                self_test.name,
                self_test.invariant_name,
                duration_ms,
            )
        else:
            logger.warning(
                "[MISS] self-test %s did not catch in %s — %s",
                self_test.name,
                self_test.invariant_name,
                detail or "(no detail)",
            )
        return SelfTestResult(
            self_test_name=self_test.name,
            invariant_name=self_test.invariant_name,
            caught=caught,
            duration_ms=duration_ms,
            detail=detail,
        )

    async def verify_all(self, self_tests: list[SelfTest]) -> list[SelfTestResult]:
        """Run multiple self-tests sequentially, returning all results."""
        results: list[SelfTestResult] = []
        for st in self_tests:
            results.append(await self.verify(st))
        return results


class _RollbackSentinel(Exception):  # noqa: N818
    """Internal sentinel used by SelfTestRunner.verify() to force rollback.

    Caught immediately after — never propagates to the caller. Not named
    with an 'Error' suffix because it's not an error condition; it's a
    deliberate control-flow signal to trigger transaction rollback.
    """
