"""Sprint O Stage 1.13 dogfood — soft byte-identical verification.

Runs the framework's invariant runner against the live HuaDian Postgres DB
and verifies:

    A. All 10 invariants run cleanly (production data is at "0 violations"
       state, so framework runner should match).
    B. All 4 self-tests catch their injected violations (verifies framework
       SelfTestRunner + invariant SQL are correct).

If A or B fails → Sprint O Stop Rule #1 / #7 triggered.

Usage:
    cd <project_root>
    PYTHONPATH=$(pwd) DATABASE_URL=... \\
      uv run --directory services/pipeline \\
      python -m framework.invariant_scaffold.examples.huadian_classics.test_byte_identical

License: Apache 2.0
"""

from __future__ import annotations

import asyncio
import logging
import os
import sys

import asyncpg

from framework.invariant_scaffold.examples.huadian_classics.db_port import (
    HuaDianAsyncpgPort,
)
from framework.invariant_scaffold.examples.huadian_classics.runner_setup import (
    build_huadian_runner,
    build_huadian_self_test_runner,
)
from framework.invariant_scaffold.examples.huadian_classics.self_tests import (
    make_huadian_self_tests,
)

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)


async def main() -> int:
    db_url = os.environ.get("DATABASE_URL")
    if not db_url:
        print("ERROR: DATABASE_URL environment variable required.", file=sys.stderr)
        return 2

    pool = await asyncpg.create_pool(db_url, min_size=1, max_size=4)

    try:
        # ---- Part A: production invariant suite ----
        print()
        print("=" * 72)
        print("Part A: production invariant suite (expect all PASS)")
        print("=" * 72)
        port = HuaDianAsyncpgPort(pool)
        runner = build_huadian_runner(port=port)
        report = await runner.run_all()

        for r in report.results:
            print(f"  {r.format_report(max_violations_shown=3)}")

        print()
        print(report.format_summary())

        production_pass = report.all_passed
        if not production_pass:
            print()
            print(f"✗ Part A FAILED — {len(report.critical_failures)} critical failure(s)")
            for r in report.critical_failures:
                print(f"    - {r.invariant_name}: {r.violation_count} violations")

        # ---- Part B: self-test suite ----
        print()
        print("=" * 72)
        print("Part B: self-tests (expect all CAUGHT — verifies framework correctness)")
        print("=" * 72)
        # Each self-test wraps in transaction (auto-rollback) — so use a fresh
        # connection-bound port per self-test for transaction integrity.
        async with pool.acquire() as conn:
            st_port = HuaDianAsyncpgPort.with_connection(conn)
            self_runner = build_huadian_self_test_runner(port=st_port)
            self_test_results = await self_runner.verify_all(make_huadian_self_tests())

        for r in self_test_results:
            mark = "✓" if r.caught else "✗"
            print(
                f"  {mark} {r.self_test_name} (target={r.invariant_name}, "
                f"{r.duration_ms:.0f}ms){' — ' + r.detail if r.detail else ''}"
            )

        all_caught = all(r.caught for r in self_test_results)
        caught_count = sum(1 for r in self_test_results if r.caught)
        print()
        print(f"Self-tests: {caught_count}/{len(self_test_results)} caught")

        # ---- Final verdict ----
        print()
        print("=" * 72)
        print("Sprint O Stage 1.13 — invariant_scaffold dogfood verification")
        print("=" * 72)

        if production_pass and all_caught:
            print("✓ DOGFOOD PASSED")
            print(
                f"  Part A: {report.passed_count}/{len(report.results)} invariants pass "
                f"({len(report.warning_failures)} warning)"
            )
            print(f"  Part B: {caught_count}/{len(self_test_results)} self-tests caught")
            return 0

        print("✗ DOGFOOD FAILED — Sprint O Stop Rule #1 or #7 triggered")
        if not production_pass:
            print(f"  Part A: {len(report.critical_failures)} critical failures")
        if not all_caught:
            missed = [r for r in self_test_results if not r.caught]
            print(f"  Part B: {len(missed)} self-test(s) did not catch")
            for r in missed:
                print(f"    - {r.self_test_name}: {r.detail}")
        return 1
    finally:
        await pool.close()


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
