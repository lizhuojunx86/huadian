"""Tests for matcher module.

Tests cover:
- R1 single match → confidence 1.00
- R1 multi hit → marked as multi_hit, not auto-mapped
- R2 alias match → confidence 0.85
- R3 full scan match → confidence 0.70
- No match → match_round = 'none'
- R3 skips names already tried in R1/R2
- MatchSummary counters correct
"""

from __future__ import annotations

from unittest.mock import AsyncMock

import pytest

from huadian_pipeline.seeds.matcher import (
    CONF_R1_SINGLE,
    CONF_R2_ALIAS,
    CONF_R3_SCAN,
    PersonInput,
    run_matching,
)
from huadian_pipeline.seeds.wikidata_adapter import SparqlResult, WikidataHit


def _person(
    pid: str,
    name: str,
    aliases: list[str] | None = None,
    all_names: list[str] | None = None,
) -> PersonInput:
    return PersonInput(
        person_id=pid,
        slug=f"slug-{pid}",
        canonical_name=name,
        dynasty="上古",
        reality_status="legendary",
        alias_names=aliases or [],
        all_names=all_names or [],
    )


def _mock_adapter(
    r1_hits: dict[str, list[WikidataHit]] | None = None,
    r2_hits: dict[str, list[WikidataHit]] | None = None,
) -> AsyncMock:
    """Create a mock WikidataAdapter with configurable responses."""
    adapter = AsyncMock()
    adapter.total_errors = 0

    # R1 batch match
    r1 = r1_hits or {}
    adapter.batch_label_match.return_value = SparqlResult(hits_by_name=r1, http_requests=1)

    # R2/R3 single altlabel match
    r2 = r2_hits or {}

    async def _altlabel(name: str) -> list[WikidataHit]:
        return r2.get(name, [])

    adapter.single_altlabel_match.side_effect = _altlabel

    # throttle is a no-op
    adapter.throttle = AsyncMock()

    return adapter


class TestR1SingleMatch:
    @pytest.mark.asyncio
    async def test_single_hit_confidence_100(self) -> None:
        p = _person("p1", "尧")
        hit = WikidataHit(qid="Q7525", label_zh="尧", description_zh="帝王")
        adapter = _mock_adapter(r1_hits={"尧": [hit]})

        results, summary = await run_matching([p], adapter)

        assert len(results) == 1
        r = results[0]
        assert r.match_round == "r1"
        assert r.confidence == CONF_R1_SINGLE
        assert r.mapping_method == "r1_exact"
        assert r.hits[0]["qid"] == "Q7525"
        assert summary.r1_single == 1

    @pytest.mark.asyncio
    async def test_no_r1_hit(self) -> None:
        p = _person("p1", "昌仆")
        adapter = _mock_adapter(r1_hits={})

        results, summary = await run_matching([p], adapter, skip_r3=True)

        assert results[0].match_round == "none"
        assert summary.no_match == 1


class TestR1MultiHit:
    @pytest.mark.asyncio
    async def test_multi_hit_not_auto_mapped(self) -> None:
        p = _person("p1", "白起")
        hits = [
            WikidataHit(qid="Q100", label_zh="白起", description_zh="将领"),
            WikidataHit(qid="Q200", label_zh="白起", description_zh="另一人"),
        ]
        adapter = _mock_adapter(r1_hits={"白起": hits})

        results, summary = await run_matching([p], adapter)

        r = results[0]
        assert r.match_round == "multi_hit"
        assert r.confidence == 0.0
        assert len(r.hits) == 2
        assert summary.r1_multi == 1


class TestR2AliasMatch:
    @pytest.mark.asyncio
    async def test_alias_hit_confidence_085(self) -> None:
        p = _person("p1", "高辛", aliases=["帝喾", "高辛氏"])
        hit = WikidataHit(qid="Q8888", label_zh="帝喾", description_zh="五帝之一")
        adapter = _mock_adapter(r1_hits={}, r2_hits={"帝喾": [hit]})

        results, summary = await run_matching([p], adapter, skip_r3=True)

        r = results[0]
        assert r.match_round == "r2"
        assert r.confidence == CONF_R2_ALIAS
        assert r.mapping_method == "r2_alias"
        assert r.matched_name == "帝喾"
        assert summary.r2_alias == 1

    @pytest.mark.asyncio
    async def test_alias_miss_still_no_match(self) -> None:
        p = _person("p1", "昌仆", aliases=["昌仆氏"])
        adapter = _mock_adapter(r1_hits={}, r2_hits={})

        results, summary = await run_matching([p], adapter, skip_r3=True)

        assert results[0].match_round == "none"
        assert summary.no_match == 1


class TestR3FullScan:
    @pytest.mark.asyncio
    async def test_r3_scan_hit_confidence_070(self) -> None:
        p = _person("p1", "高辛", aliases=["帝喾"], all_names=["帝喾高辛者", "神农"])
        hit = WikidataHit(qid="Q9999", label_zh="帝喾高辛者")
        adapter = _mock_adapter(r1_hits={}, r2_hits={"帝喾高辛者": [hit]})

        results, summary = await run_matching([p], adapter)

        r = results[0]
        assert r.match_round == "r3"
        assert r.confidence == CONF_R3_SCAN
        assert r.mapping_method == "r3_name_scan"
        assert r.matched_name == "帝喾高辛者"
        assert summary.r3_scan == 1

    @pytest.mark.asyncio
    async def test_r3_skips_already_tried_names(self) -> None:
        """R3 should not re-try canonical_name or alias_names."""
        p = _person("p1", "高辛", aliases=["帝喾"], all_names=["帝喾", "高辛氏"])
        # Only "高辛氏" is new for R3 (高辛 = canonical, 帝喾 = alias)
        adapter = _mock_adapter(r1_hits={}, r2_hits={})

        results, summary = await run_matching([p], adapter)

        # adapter.single_altlabel_match should be called for:
        # R2: "帝喾" (1 call)
        # R3: "高辛氏" (1 call, skipping "帝喾" which was tried in R2)
        r2_r3_calls = adapter.single_altlabel_match.call_args_list
        called_names = [call.args[0] for call in r2_r3_calls]
        # "帝喾" should appear once (R2), "高辛氏" once (R3)
        assert called_names.count("帝喾") == 1
        assert "高辛氏" in called_names


class TestMatchSummaryCounters:
    @pytest.mark.asyncio
    async def test_mixed_results(self) -> None:
        persons = [
            _person("p1", "尧"),  # R1 hit
            _person("p2", "高辛", aliases=["帝喾"]),  # R2 hit
            _person("p3", "昌仆"),  # no match
        ]
        r1_hit = WikidataHit(qid="Q7525", label_zh="尧")
        r2_hit = WikidataHit(qid="Q8888", label_zh="帝喾")
        adapter = _mock_adapter(
            r1_hits={"尧": [r1_hit]},
            r2_hits={"帝喾": [r2_hit]},
        )

        results, summary = await run_matching(persons, adapter, skip_r3=True)

        assert summary.total == 3
        assert summary.r1_single == 1
        assert summary.r2_alias == 1
        assert summary.no_match == 1
