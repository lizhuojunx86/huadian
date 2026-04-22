"""Unit tests for R6 pre-pass infrastructure and merge detection.

Tests _detect_r6_merges() (pure function, no DB) and R6PrePassResult construction.
"""

from __future__ import annotations

from huadian_pipeline.r6_seed_match import R6Status
from huadian_pipeline.resolve import R6PrePassResult, _detect_r6_merges
from huadian_pipeline.resolve_rules import PersonSnapshot


def _make_snapshot(
    *,
    id: str = "00000000-0000-0000-0000-000000000001",  # noqa: A002
    name: str = "测试",
    slug: str = "test",
    r6_result: R6PrePassResult | None = None,
) -> PersonSnapshot:
    """Create a minimal PersonSnapshot for testing."""
    return PersonSnapshot(
        id=id,
        name=name,
        slug=slug,
        dynasty="",
        surface_forms=set(),
        identity_notes=[],
        created_at="2026-01-01T00:00:00",
        r6_result=r6_result,
    )


class TestR6PrePassResult:
    """Tests for R6PrePassResult dataclass."""

    def test_matched_result(self) -> None:
        r = R6PrePassResult(status=R6Status.MATCHED, qid="Q12345", entry_id="e1", confidence=1.0)
        assert r.status == R6Status.MATCHED
        assert r.qid == "Q12345"
        assert r.confidence == 1.0

    def test_not_found_result(self) -> None:
        r = R6PrePassResult(status=R6Status.NOT_FOUND)
        assert r.status == R6Status.NOT_FOUND
        assert r.qid is None
        assert r.confidence is None

    def test_below_cutoff_result(self) -> None:
        r = R6PrePassResult(
            status=R6Status.BELOW_CUTOFF, qid="Q999", entry_id="e2", confidence=0.70
        )
        assert r.status == R6Status.BELOW_CUTOFF
        assert r.confidence == 0.70


class TestDetectR6Merges:
    """Tests for _detect_r6_merges() pure function."""

    def test_same_qid_produces_merge_proposal(self) -> None:
        """Two MATCHED persons with same QID -> 1 MergeProposal."""
        a = _make_snapshot(
            id="aaaa",
            name="甲",
            slug="jia",
            r6_result=R6PrePassResult(
                status=R6Status.MATCHED, qid="Q100", entry_id="e1", confidence=1.0
            ),
        )
        b = _make_snapshot(
            id="bbbb",
            name="乙",
            slug="yi",
            r6_result=R6PrePassResult(
                status=R6Status.MATCHED, qid="Q100", entry_id="e2", confidence=1.0
            ),
        )
        proposals = _detect_r6_merges([a, b])
        assert len(proposals) == 1
        assert proposals[0].match.rule == "R6"
        assert proposals[0].match.confidence == 1.0
        assert proposals[0].match.evidence["external_id"] == "Q100"
        assert proposals[0].match.evidence["pre_pass"] is True

    def test_different_qid_no_proposal(self) -> None:
        """Two MATCHED persons with different QIDs -> 0 proposals."""
        a = _make_snapshot(
            id="aaaa",
            name="甲",
            r6_result=R6PrePassResult(
                status=R6Status.MATCHED, qid="Q100", entry_id="e1", confidence=1.0
            ),
        )
        b = _make_snapshot(
            id="bbbb",
            name="乙",
            r6_result=R6PrePassResult(
                status=R6Status.MATCHED, qid="Q200", entry_id="e2", confidence=1.0
            ),
        )
        proposals = _detect_r6_merges([a, b])
        assert len(proposals) == 0

    def test_below_cutoff_same_qid_no_proposal(self) -> None:
        """BELOW_CUTOFF persons with same QID -> 0 proposals (裁决 4)."""
        a = _make_snapshot(
            id="aaaa",
            name="甲",
            r6_result=R6PrePassResult(
                status=R6Status.BELOW_CUTOFF, qid="Q100", entry_id="e1", confidence=0.70
            ),
        )
        b = _make_snapshot(
            id="bbbb",
            name="乙",
            r6_result=R6PrePassResult(
                status=R6Status.BELOW_CUTOFF, qid="Q100", entry_id="e2", confidence=0.70
            ),
        )
        proposals = _detect_r6_merges([a, b])
        assert len(proposals) == 0

    def test_not_found_no_proposal(self) -> None:
        """NOT_FOUND persons -> 0 proposals."""
        a = _make_snapshot(
            id="aaaa",
            r6_result=R6PrePassResult(status=R6Status.NOT_FOUND),
        )
        b = _make_snapshot(
            id="bbbb",
            r6_result=R6PrePassResult(status=R6Status.NOT_FOUND),
        )
        proposals = _detect_r6_merges([a, b])
        assert len(proposals) == 0

    def test_none_r6_result_no_proposal(self) -> None:
        """Persons with r6_result=None -> 0 proposals."""
        a = _make_snapshot(id="aaaa")
        b = _make_snapshot(id="bbbb")
        proposals = _detect_r6_merges([a, b])
        assert len(proposals) == 0

    def test_three_way_same_qid_produces_three_proposals(self) -> None:
        """Three MATCHED persons same QID -> 3 pairwise proposals."""
        matched = R6PrePassResult(
            status=R6Status.MATCHED, qid="Q100", entry_id="e1", confidence=1.0
        )
        a = _make_snapshot(id="aaaa", name="甲", r6_result=matched)
        b = _make_snapshot(id="bbbb", name="乙", r6_result=matched)
        c = _make_snapshot(id="cccc", name="丙", r6_result=matched)
        proposals = _detect_r6_merges([a, b, c])
        # C(3,2) = 3 pairwise proposals
        assert len(proposals) == 3
        assert all(p.match.rule == "R6" for p in proposals)

    def test_mixed_matched_and_not_found_same_qid(self) -> None:
        """One MATCHED + one NOT_FOUND (same QID irrelevant) -> 0 proposals."""
        a = _make_snapshot(
            id="aaaa",
            r6_result=R6PrePassResult(
                status=R6Status.MATCHED, qid="Q100", entry_id="e1", confidence=1.0
            ),
        )
        b = _make_snapshot(
            id="bbbb",
            r6_result=R6PrePassResult(status=R6Status.NOT_FOUND),
        )
        proposals = _detect_r6_merges([a, b])
        assert len(proposals) == 0
