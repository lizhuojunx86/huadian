"""invariant_scaffold — domain-agnostic invariant checking framework.

Quick start:

    from framework.invariant_scaffold import (
        InvariantRunner,
        UpperBoundInvariant,
        LowerBoundInvariant,
    )
    from your_case.adapters import MyDBPort

    runner = InvariantRunner(port=MyDBPort(pool))
    runner.register_all([
        UpperBoundInvariant.from_template(
            name="V1",
            description="each entity ≤ 1 primary attribute",
            sql='SELECT entity_id, COUNT(*) AS cnt FROM ... HAVING COUNT(*) > $1',
            max_count=1,
        ),
        # ... more invariants ...
    ])

    report = await runner.run_all()
    runner.assert_all_pass(report)  # raises AssertionError on critical fail

5 invariant patterns available (see `docs/methodology/04-invariant-pattern.md`):
    UpperBoundInvariant      — entity attr count ≤ N
    LowerBoundInvariant      — entity must have ≥ N matching attrs
    ContainmentInvariant     — set A ⊆ set B
    OrphanDetectionInvariant — references must point to existing rows
    CardinalityBoundInvariant — count == exact OR per-entity count in [min, max]

Self-test (verify your invariants actually catch violations):

    from framework.invariant_scaffold import SelfTest, SelfTestRunner

    class MyInjectionTest:
        name = "v9_missing_primary"
        invariant_name = "V9"
        async def setup_violation(self, port): ...
        def expected_violation_predicate(self, violation): ...

    self_runner = SelfTestRunner(port=MyDBPort(pool), invariants=runner.invariants)
    result = await self_runner.verify(MyInjectionTest())
    assert result.caught

License: Apache 2.0 (code) / CC BY 4.0 (docs)
Source: HuaDian Sprint O first-cut framework abstraction.
"""

from .invariant import Invariant
from .patterns import (
    CardinalityBoundInvariant,
    ContainmentInvariant,
    LowerBoundInvariant,
    OrphanDetectionInvariant,
    UpperBoundInvariant,
)
from .port import DBPort
from .runner import InvariantRunner
from .self_test import SelfTest, SelfTestRunner
from .types import (
    InvariantReport,
    InvariantResult,
    SelfTestResult,
    Severity,
    Violation,
)

__all__ = [
    # types
    "Severity",
    "Violation",
    "InvariantResult",
    "InvariantReport",
    "SelfTestResult",
    # base
    "Invariant",
    # 5 patterns
    "UpperBoundInvariant",
    "LowerBoundInvariant",
    "ContainmentInvariant",
    "OrphanDetectionInvariant",
    "CardinalityBoundInvariant",
    # port
    "DBPort",
    # runners
    "InvariantRunner",
    # self-test
    "SelfTest",
    "SelfTestRunner",
]

__version__ = "0.1.0"
