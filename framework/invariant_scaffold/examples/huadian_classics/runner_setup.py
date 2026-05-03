"""HuaDian — factory for an InvariantRunner pre-registered with all 10 invariants.

Usage:

    from framework.invariant_scaffold.examples.huadian_classics.runner_setup import (
        build_huadian_runner, build_huadian_self_test_runner,
    )

    # In production / sprint closeout
    runner = build_huadian_runner(port=HuaDianAsyncpgPort(pool))
    report = await runner.run_all()
    runner.assert_all_pass(report)

    # In dogfood
    self_runner = build_huadian_self_test_runner(port=HuaDianAsyncpgPort(pool))
    results = await self_runner.verify_all(make_huadian_self_tests())
    assert all(r.caught for r in results)
"""

from __future__ import annotations

from framework.invariant_scaffold import (
    DBPort,
    Invariant,
    InvariantRunner,
    SelfTestRunner,
)

from .invariants_active_merged import make_active_merged
from .invariants_slug import make_slug_format, make_slug_no_collision
from .invariants_v4 import make_v4
from .invariants_v6 import make_v6
from .invariants_v8 import make_v8
from .invariants_v9 import make_v9
from .invariants_v10 import make_v10a, make_v10b, make_v10c
from .invariants_v11 import make_v11


def build_huadian_invariants() -> list[Invariant]:
    """Build the full HuaDian invariant suite (10 invariants)."""
    return [
        make_v4(),
        make_v6(),
        make_v8(),
        make_v9(),
        make_v10a(),
        make_v10b(),
        make_v10c(),
        make_v11(),
        make_active_merged(),
        make_slug_format(),
        make_slug_no_collision(),
    ]


def build_huadian_runner(port: DBPort) -> InvariantRunner:
    """Build an InvariantRunner with all HuaDian invariants pre-registered."""
    runner = InvariantRunner(port=port)
    runner.register_all(build_huadian_invariants())
    return runner


def build_huadian_self_test_runner(port: DBPort) -> SelfTestRunner:
    """Build a SelfTestRunner that knows all HuaDian invariants."""
    return SelfTestRunner(port=port, invariants=build_huadian_invariants())
