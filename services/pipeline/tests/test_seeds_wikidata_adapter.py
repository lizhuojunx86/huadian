"""Tests for wikidata_adapter module.

Tests cover:
- SPARQL query building (label batch, altLabel single)
- QID parsing
- Binding parsing and deduplication
"""

from __future__ import annotations

from huadian_pipeline.seeds.wikidata_adapter import (
    WikidataHit,
    build_altlabel_query,
    build_label_batch_query,
    parse_bindings,
    parse_qid,
)


class TestBuildLabelBatchQuery:
    def test_single_name(self) -> None:
        q = build_label_batch_query(["尧"])
        assert '"尧"@zh' in q
        assert "wdt:P31 wd:Q5" in q
        assert "VALUES ?name" in q

    def test_multiple_names(self) -> None:
        q = build_label_batch_query(["尧", "舜", "禹"])
        assert '"尧"@zh' in q
        assert '"舜"@zh' in q
        assert '"禹"@zh' in q

    def test_empty_list(self) -> None:
        q = build_label_batch_query([])
        assert "VALUES ?name {  }" in q


class TestBuildAltlabelQuery:
    def test_single_alias(self) -> None:
        q = build_altlabel_query("帝尧")
        assert '"帝尧"@zh' in q
        assert "skos:altLabel" in q
        assert "rdfs:label" in q
        assert "LIMIT 5" in q


class TestParseQid:
    def test_full_uri(self) -> None:
        assert parse_qid("http://www.wikidata.org/entity/Q7525") == "Q7525"

    def test_bare_qid(self) -> None:
        assert parse_qid("Q7525") == "Q7525"

    def test_empty(self) -> None:
        assert parse_qid("") == ""


class TestParseBindings:
    def test_single_binding(self) -> None:
        bindings = [
            {
                "item": {"value": "http://www.wikidata.org/entity/Q7525"},
                "itemLabel": {"value": "尧"},
                "name": {"value": "尧"},
                "description": {"value": "上古帝王"},
            }
        ]
        result = parse_bindings(bindings)
        assert "尧" in result
        assert len(result["尧"]) == 1
        assert result["尧"][0] == WikidataHit(qid="Q7525", label_zh="尧", description_zh="上古帝王")

    def test_deduplicates_same_qid(self) -> None:
        bindings = [
            {
                "item": {"value": "http://www.wikidata.org/entity/Q7525"},
                "itemLabel": {"value": "尧"},
                "name": {"value": "尧"},
                "description": {"value": "desc1"},
            },
            {
                "item": {"value": "http://www.wikidata.org/entity/Q7525"},
                "itemLabel": {"value": "尧"},
                "name": {"value": "尧"},
                "description": {"value": "desc2"},
            },
        ]
        result = parse_bindings(bindings)
        assert len(result["尧"]) == 1  # deduplicated

    def test_multiple_qids_same_name(self) -> None:
        bindings = [
            {
                "item": {"value": "http://www.wikidata.org/entity/Q100"},
                "itemLabel": {"value": "白起"},
                "name": {"value": "白起"},
                "description": {"value": "战国将领"},
            },
            {
                "item": {"value": "http://www.wikidata.org/entity/Q200"},
                "itemLabel": {"value": "白起"},
                "name": {"value": "白起"},
                "description": {"value": "另一人"},
            },
        ]
        result = parse_bindings(bindings)
        assert len(result["白起"]) == 2

    def test_empty_bindings(self) -> None:
        result = parse_bindings([])
        assert result == {}

    def test_fallback_to_item_label(self) -> None:
        """When 'name' field is missing, falls back to itemLabel."""
        bindings = [
            {
                "item": {"value": "http://www.wikidata.org/entity/Q7525"},
                "itemLabel": {"value": "尧"},
                "description": {"value": "帝王"},
            }
        ]
        result = parse_bindings(bindings)
        assert "尧" in result
