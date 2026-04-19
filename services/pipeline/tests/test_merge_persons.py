"""Unit tests for merge_persons llm_call_id accumulation (T-P0-023 Stage 1e)."""

from __future__ import annotations

from huadian_pipeline.extract import ExtractedPerson, SurfaceForm
from huadian_pipeline.load import merge_persons


def _ep(name_zh: str, chunk_id: str, llm_call_id: str | None = None) -> ExtractedPerson:
    """Helper: create an ExtractedPerson with minimal fields."""
    return ExtractedPerson(
        name_zh=name_zh,
        surface_forms=[SurfaceForm(text=name_zh, name_type="primary")],
        dynasty="上古",
        reality_status="legendary",
        brief="test",
        confidence=0.9,
        identity_notes=None,
        chunk_paragraph_no=1,
        chunk_id=chunk_id,
        llm_call_id=llm_call_id,
    )


def test_merge_persons_accumulates_llm_call_ids():
    """Two same-name persons from different chunks -> both call_ids preserved."""
    persons = [
        _ep("黄帝", "chunk-1", "call-1"),
        _ep("黄帝", "chunk-2", "call-2"),
    ]
    merged = merge_persons(persons)
    assert len(merged) == 1
    assert merged[0].llm_call_ids == ["call-1", "call-2"]


def test_merge_persons_skips_none_call_id():
    """If one ExtractedPerson has llm_call_id=None, it is not added to the list."""
    persons = [
        _ep("黄帝", "chunk-1", "call-1"),
        _ep("黄帝", "chunk-2", None),
    ]
    merged = merge_persons(persons)
    assert len(merged) == 1
    assert merged[0].llm_call_ids == ["call-1"]


def test_merge_persons_all_none_call_ids():
    """If all ExtractedPersons have llm_call_id=None, the list stays empty."""
    persons = [
        _ep("黄帝", "chunk-1", None),
        _ep("黄帝", "chunk-2", None),
    ]
    merged = merge_persons(persons)
    assert len(merged) == 1
    assert merged[0].llm_call_ids == []


def test_merge_persons_deduplicates_call_ids():
    """Duplicate call_ids (same chunk re-extraction) are not duplicated."""
    persons = [
        _ep("黄帝", "chunk-1", "call-1"),
        _ep("黄帝", "chunk-1", "call-1"),
    ]
    merged = merge_persons(persons)
    assert len(merged) == 1
    assert merged[0].llm_call_ids == ["call-1"]
