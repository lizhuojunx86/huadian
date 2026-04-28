"""Regression tests: generate_dry_run_report guard payload column alignment.

Bug (Sprint J S4.3'): when pair-order normalization swaps a/b in resolve.py,
guard_payload *_a/*_b keys were NOT swapped, causing the report to display
person_a_name alongside dynasty_b (transposition).

Fix: resolve.py _swap_ab_payload() is called in the else-branch of both the
R1 and R6 normalization paths to realign payload keys with normalized order.
"""

from __future__ import annotations

from huadian_pipeline.resolve import _swap_ab_payload, generate_dry_run_report
from huadian_pipeline.resolve_types import BlockedMerge, ResolveResult

# ---------------------------------------------------------------------------
# _swap_ab_payload unit tests
# ---------------------------------------------------------------------------


def test_swap_ab_payload_cross_dynasty() -> None:
    """cross_dynasty payload keys are fully swapped."""
    original = {
        "dynasty_a": "西汉",
        "dynasty_b": "春秋",
        "midpoint_a": -97,
        "midpoint_b": -623,
        "gap_years": 526,
        "threshold": 200,
    }
    swapped = _swap_ab_payload(original)
    assert swapped["dynasty_a"] == "春秋"
    assert swapped["dynasty_b"] == "西汉"
    assert swapped["midpoint_a"] == -623
    assert swapped["midpoint_b"] == -97
    assert swapped["gap_years"] == 526  # non-suffixed keys unchanged
    assert swapped["threshold"] == 200


def test_swap_ab_payload_state_prefix() -> None:
    """state_prefix payload keys are fully swapped."""
    original = {
        "state_a": "齐",
        "state_b": "晋",
        "raw_state_a": "齐",
        "raw_state_b": "晋",
        "name_a": "齐桓公",
        "name_b": "晋桓公",
    }
    swapped = _swap_ab_payload(original)
    assert swapped["state_a"] == "晋"
    assert swapped["state_b"] == "齐"
    assert swapped["name_a"] == "晋桓公"
    assert swapped["name_b"] == "齐桓公"


def test_swap_ab_payload_idempotent() -> None:
    """Applying swap twice returns the original."""
    original = {"dynasty_a": "西汉", "dynasty_b": "春秋", "gap_years": 526}
    assert _swap_ab_payload(_swap_ab_payload(original)) == original


# ---------------------------------------------------------------------------
# generate_dry_run_report column alignment tests
# ---------------------------------------------------------------------------


def _make_cross_dynasty_blocked(
    a_id: str,
    b_id: str,
    a_name: str,
    b_name: str,
    dynasty_a: str,
    dynasty_b: str,
    gap: int,
) -> BlockedMerge:
    return BlockedMerge(
        person_a_id=a_id,
        person_b_id=b_id,
        person_a_name=a_name,
        person_b_name=b_name,
        proposed_rule="R1",
        guard_type="cross_dynasty",
        guard_payload={
            "dynasty_a": dynasty_a,
            "dynasty_b": dynasty_b,
            "midpoint_a": -97 if dynasty_a == "西汉" else -623,
            "midpoint_b": -97 if dynasty_b == "西汉" else -623,
            "gap_years": gap,
            "threshold": 200,
        },
        evidence={},
    )


def test_report_person_a_dynasty_alignment_no_swap() -> None:
    """dynasty_a aligns with person_a_name when pair was not swapped."""
    result = ResolveResult(run_id="test-no-swap", total_persons=2)
    result.blocked_merges.append(
        _make_cross_dynasty_blocked(
            a_id="aaaaaaaa-0000-0000-0000-000000000001",  # a_id < b_id → no swap
            b_id="bbbbbbbb-0000-0000-0000-000000000002",
            a_name="吕后",
            b_name="秦穆公夫人",
            dynasty_a="西汉",
            dynasty_b="春秋",
            gap=526,
        )
    )
    report = generate_dry_run_report(result)
    assert "吕后(西汉)" in report, f"Expected '吕后(西汉)' in report:\n{report}"
    assert "秦穆公夫人(春秋)" in report, f"Expected '秦穆公夫人(春秋)' in report:\n{report}"


def test_report_person_a_dynasty_alignment_after_swap() -> None:
    """dynasty_a aligns with person_a_name even after pair normalization swap.

    Simulates the post-fix state: when a.id > b.id caused the swap,
    _swap_ab_payload() was called so dynasty_a now matches the new person_a.
    """
    result = ResolveResult(run_id="test-swap", total_persons=2)
    # After swap: person_a = 秦穆公夫人 (was b), person_b = 吕后 (was a).
    # Payload was also swapped: dynasty_a = 春秋 (秦穆公夫人), dynasty_b = 西汉 (吕后).
    result.blocked_merges.append(
        _make_cross_dynasty_blocked(
            a_id="aaaaaaaa-0000-0000-0000-000000000001",
            b_id="bbbbbbbb-0000-0000-0000-000000000002",
            a_name="秦穆公夫人",  # was b, now a after swap
            b_name="吕后",  # was a, now b after swap
            dynasty_a="春秋",  # swapped: matches 秦穆公夫人
            dynasty_b="西汉",  # swapped: matches 吕后
            gap=526,
        )
    )
    report = generate_dry_run_report(result)
    assert "秦穆公夫人(春秋)" in report, f"Expected '秦穆公夫人(春秋)' in report:\n{report}"
    assert "吕后(西汉)" in report, f"Expected '吕后(西汉)' in report:\n{report}"
    # Before the fix this would have been "秦穆公夫人(西汉)" — assert it's gone
    assert "秦穆公夫人(西汉)" not in report
    assert "吕后(春秋)" not in report
