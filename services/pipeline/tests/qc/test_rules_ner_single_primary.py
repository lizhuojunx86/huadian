"""Unit tests for ner.single_primary_per_person QC rule (T-P1-004 / ADR-012)."""

from __future__ import annotations

from typing import Any

from huadian_pipeline.qc.rules.ner_rules import rule_single_primary_per_person
from huadian_pipeline.qc.types import CheckpointInput


def _ner_payload(entities: list[dict[str, Any]]) -> CheckpointInput:
    return CheckpointInput(
        step_name="ner_v1",
        trace_id="t1",
        prompt_version="v1",
        model="claude-opus-4-6",
        inputs={"paragraph_text": "黄帝者，少典之子，姓公孙，名曰轩辕。"},
        outputs={"entities": entities},
        metadata={},
    )


# ---------------------------------------------------------------------------
# Pass: exactly 1 primary per person
# ---------------------------------------------------------------------------


class TestSinglePrimaryPass:
    def test_one_primary_passes(self) -> None:
        vs = rule_single_primary_per_person(
            _ner_payload(
                [
                    {
                        "name_zh": "黄帝",
                        "surface_forms": [
                            {"text": "黄帝", "name_type": "nickname"},
                            {"text": "轩辕", "name_type": "primary"},
                            {"text": "公孙", "name_type": "alias"},
                        ],
                    }
                ]
            )
        )
        assert len(vs) == 0

    def test_multiple_persons_each_one_primary(self) -> None:
        vs = rule_single_primary_per_person(
            _ner_payload(
                [
                    {
                        "name_zh": "尧",
                        "surface_forms": [
                            {"text": "尧", "name_type": "primary"},
                            {"text": "帝尧", "name_type": "nickname"},
                        ],
                    },
                    {
                        "name_zh": "舜",
                        "surface_forms": [
                            {"text": "舜", "name_type": "primary"},
                        ],
                    },
                ]
            )
        )
        assert len(vs) == 0


# ---------------------------------------------------------------------------
# Fail: multiple primaries
# ---------------------------------------------------------------------------


class TestMultiplePrimaryFail:
    def test_two_primaries_flagged(self) -> None:
        vs = rule_single_primary_per_person(
            _ner_payload(
                [
                    {
                        "name_zh": "尧",
                        "surface_forms": [
                            {"text": "尧", "name_type": "primary"},
                            {"text": "放勋", "name_type": "primary"},
                        ],
                    }
                ]
            )
        )
        assert len(vs) == 1
        assert "2 primaries" in vs[0].message
        assert "尧" in vs[0].message

    def test_three_primaries_flagged(self) -> None:
        vs = rule_single_primary_per_person(
            _ner_payload(
                [
                    {
                        "name_zh": "汤",
                        "surface_forms": [
                            {"text": "汤", "name_type": "primary"},
                            {"text": "商汤", "name_type": "primary"},
                            {"text": "天乙", "name_type": "primary"},
                        ],
                    }
                ]
            )
        )
        assert len(vs) == 1
        assert "3 primaries" in vs[0].message

    def test_only_offending_persons_flagged(self) -> None:
        """One person OK, one person has 2 primaries → only 1 violation."""
        vs = rule_single_primary_per_person(
            _ner_payload(
                [
                    {
                        "name_zh": "舜",
                        "surface_forms": [
                            {"text": "舜", "name_type": "primary"},
                        ],
                    },
                    {
                        "name_zh": "禹",
                        "surface_forms": [
                            {"text": "禹", "name_type": "primary"},
                            {"text": "文命", "name_type": "primary"},
                        ],
                    },
                ]
            )
        )
        assert len(vs) == 1
        assert "禹" in vs[0].message


# ---------------------------------------------------------------------------
# Fail: 0 primaries
# ---------------------------------------------------------------------------


class TestZeroPrimaryFail:
    def test_zero_primaries_flagged(self) -> None:
        vs = rule_single_primary_per_person(
            _ner_payload(
                [
                    {
                        "name_zh": "蚩尤",
                        "surface_forms": [
                            {"text": "蚩尤", "name_type": "alias"},
                        ],
                    }
                ]
            )
        )
        assert len(vs) == 1
        assert "0 primaries" in vs[0].message
        assert "蚩尤" in vs[0].message


# ---------------------------------------------------------------------------
# Edge: malformed data tolerance
# ---------------------------------------------------------------------------


class TestMalformedTolerance:
    def test_empty_entities_no_violation(self) -> None:
        vs = rule_single_primary_per_person(_ner_payload([]))
        assert len(vs) == 0

    def test_non_list_entities_no_crash(self) -> None:
        vs = rule_single_primary_per_person(
            _ner_payload("not a list")  # type: ignore[arg-type]
        )
        assert len(vs) == 0

    def test_missing_surface_forms_flags_zero_primary(self) -> None:
        """Missing surface_forms → 0 primaries → violation (not crash)."""
        vs = rule_single_primary_per_person(_ner_payload([{"name_zh": "某人"}]))
        assert len(vs) == 1
        assert "0 primaries" in vs[0].message

    def test_non_dict_entity_skipped(self) -> None:
        vs = rule_single_primary_per_person(
            _ner_payload(["not a dict"])  # type: ignore[list-item]
        )
        assert len(vs) == 0
