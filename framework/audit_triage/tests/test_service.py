"""Service-layer unit tests for framework.audit_triage.

Covers the public API surface exercised through the in-memory
``FakeTriageStore`` (see ``conftest.py``):

  * composite item-id encode/decode (incl. malformed input)
  * decision-type narrowing (is_valid / coerce)
  * ``record_decision`` full validation order + zero-downstream write
  * ``surface_snapshot`` freezing + multi-row audit
  * inbox redirect (next-pending-excluding) incl. empty queue
  * read APIs (list/find/decisions_for_surface/decisions_for_source)
  * custom ReasonValidator override + default vocabulary sanity

License: Apache 2.0
"""

from __future__ import annotations

import pytest

from framework.audit_triage import (
    DEFAULT_REASON_SOURCE_TYPES,
    DefaultReasonValidator,
    RecordDecisionInput,
    StaticAllowlist,
    coerce_decision_type,
    decisions_for_source,
    decisions_for_surface,
    decode_item_id,
    encode_item_id,
    find_pending_item,
    is_valid_decision_type,
    list_pending_items,
    record_decision,
)

from .conftest import FakeTriageStore, make_pending

# ---------------------------------------------------------------------------
# Composite item-id encode / decode
# ---------------------------------------------------------------------------


def test_encode_decode_roundtrip():
    item_id = encode_item_id("seed_mapping", "abc-uuid")
    assert item_id == "seed_mapping:abc-uuid"
    assert decode_item_id(item_id) == ("seed_mapping", "abc-uuid")


@pytest.mark.parametrize(
    "bad",
    ["", "no-colon", "too:many:colons", ":missing-kind", "missing-source:"],
)
def test_decode_item_id_rejects_malformed(bad):
    assert decode_item_id(bad) is None


# ---------------------------------------------------------------------------
# Decision-type narrowing
# ---------------------------------------------------------------------------


@pytest.mark.parametrize("value", ["approve", "reject", "defer"])
def test_is_valid_decision_type_accepts_canonical(value):
    assert is_valid_decision_type(value) is True


@pytest.mark.parametrize("value", ["APPROVE", "yes", "", "merge"])
def test_is_valid_decision_type_rejects_others(value):
    assert is_valid_decision_type(value) is False


def test_coerce_decision_type_passthrough_and_raises():
    assert coerce_decision_type("approve") == "approve"
    with pytest.raises(ValueError):
        coerce_decision_type("APPROVE")


# ---------------------------------------------------------------------------
# record_decision — happy path
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_record_decision_success_writes_one_row(store_with_two, allowlist):
    result = await record_decision(
        store_with_two,
        allowlist,
        RecordDecisionInput(
            item_id="seed_mapping:s1",
            decision="approve",
            historian_id="chief-historian",
            reason_text="confirmed in chapter",
            reason_source_type="in_chapter",
        ),
    )
    assert result.error is None
    assert result.decision_record is not None
    assert result.decision_record.decision == "approve"
    assert result.decision_record.source_id == "s1"
    # zero-downstream: V0.1 always inserts downstream_applied=False
    assert result.decision_record.downstream_applied is False
    assert len(store_with_two.decisions) == 1


@pytest.mark.asyncio
async def test_record_decision_freezes_surface_snapshot(store_with_two, allowlist):
    result = await record_decision(
        store_with_two,
        allowlist,
        RecordDecisionInput(
            item_id="seed_mapping:s1",
            decision="reject",
            historian_id="chief-historian",
        ),
    )
    # snapshot must equal the pending item's surface at write time
    assert result.decision_record is not None
    assert result.decision_record.surface_snapshot == "周成王"


@pytest.mark.asyncio
async def test_record_decision_next_pending_excludes_decided(store_with_two, allowlist):
    result = await record_decision(
        store_with_two,
        allowlist,
        RecordDecisionInput(
            item_id="seed_mapping:s1",
            decision="approve",
            historian_id="chief-historian",
        ),
    )
    # s1 was decided; next inbox target should be s2 (still pending)
    assert result.next_pending_item_id == "seed_mapping:s2"


@pytest.mark.asyncio
async def test_record_decision_next_pending_none_when_queue_drains(allowlist):
    store = FakeTriageStore([make_pending("seed_mapping:only")])
    result = await record_decision(
        store,
        allowlist,
        RecordDecisionInput(
            item_id="seed_mapping:only",
            decision="approve",
            historian_id="chief-historian",
        ),
    )
    # the just-decided item is the sole pending row → no next target
    assert result.next_pending_item_id is None


# ---------------------------------------------------------------------------
# record_decision — validation order (each short-circuits, nothing written)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_record_decision_unauthorized(store_with_two, allowlist):
    result = await record_decision(
        store_with_two,
        allowlist,
        RecordDecisionInput(
            item_id="seed_mapping:s1",
            decision="approve",
            historian_id="eve",  # not in allowlist
        ),
    )
    assert result.decision_record is None
    assert result.error is not None
    assert result.error.code == "UNAUTHORIZED"
    assert store_with_two.decisions == []


@pytest.mark.asyncio
async def test_record_decision_invalid_decision_type(store_with_two, allowlist):
    result = await record_decision(
        store_with_two,
        allowlist,
        RecordDecisionInput(
            item_id="seed_mapping:s1",
            decision="merge",  # type: ignore[arg-type]
            historian_id="chief-historian",
        ),
    )
    assert result.error is not None
    assert result.error.code == "INVALID_DECISION_TYPE"
    assert store_with_two.decisions == []


@pytest.mark.asyncio
async def test_record_decision_invalid_reason_source_type(store_with_two, allowlist):
    result = await record_decision(
        store_with_two,
        allowlist,
        RecordDecisionInput(
            item_id="seed_mapping:s1",
            decision="approve",
            historian_id="chief-historian",
            reason_source_type="made_up_tag",
        ),
    )
    assert result.error is not None
    assert result.error.code == "INVALID_REASON_SOURCE_TYPE"


@pytest.mark.asyncio
async def test_record_decision_invalid_item_id_format(store_with_two, allowlist):
    result = await record_decision(
        store_with_two,
        allowlist,
        RecordDecisionInput(
            item_id="no-colon-here",
            decision="approve",
            historian_id="chief-historian",
        ),
    )
    assert result.error is not None
    assert result.error.code == "INVALID_ITEM_ID_FORMAT"


@pytest.mark.asyncio
async def test_record_decision_item_not_found(store_with_two, allowlist):
    result = await record_decision(
        store_with_two,
        allowlist,
        RecordDecisionInput(
            item_id="seed_mapping:ghost",  # well-formed but not pending
            decision="approve",
            historian_id="chief-historian",
        ),
    )
    assert result.error is not None
    assert result.error.code == "ITEM_NOT_FOUND"


@pytest.mark.asyncio
async def test_authz_short_circuits_before_item_lookup(store_with_two, allowlist):
    # Both historian and item are bad; authz is checked first → UNAUTHORIZED.
    result = await record_decision(
        store_with_two,
        allowlist,
        RecordDecisionInput(
            item_id="garbage",
            decision="approve",
            historian_id="eve",
        ),
    )
    assert result.error is not None
    assert result.error.code == "UNAUTHORIZED"


@pytest.mark.asyncio
async def test_custom_reason_validator_overrides_default(store_with_two, allowlist):
    legal_vocab = DefaultReasonValidator(allowed=("contract_text", "case_law"))
    # a tag valid in the legal vocab but NOT in the default set
    result = await record_decision(
        store_with_two,
        allowlist,
        RecordDecisionInput(
            item_id="seed_mapping:s1",
            decision="approve",
            historian_id="chief-historian",
            reason_source_type="contract_text",
        ),
        reason_validator=legal_vocab,
    )
    assert result.error is None
    assert result.decision_record is not None


# ---------------------------------------------------------------------------
# Multi-row audit (defer → approve)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_multi_row_audit_per_source(allowlist):
    store = FakeTriageStore([make_pending("seed_mapping:s1", surface="周成王")])
    common = dict(item_id="seed_mapping:s1", historian_id="chief-historian")
    await record_decision(store, allowlist, RecordDecisionInput(decision="defer", **common))
    await record_decision(store, allowlist, RecordDecisionInput(decision="approve", **common))
    trail = await decisions_for_source(store, "seed_mappings", "s1")
    assert [d.decision for d in trail] == ["approve", "defer"]  # latest first


# ---------------------------------------------------------------------------
# Read APIs
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_list_pending_items_returns_total_before_pagination(store_with_two):
    items, total = await list_pending_items(store_with_two, limit=1)
    assert total == 2  # total is pre-limit
    assert len(items) == 1
    assert items[0].item_id == "seed_mapping:s1"  # FIFO head


@pytest.mark.asyncio
async def test_list_pending_items_filter_by_surface(store_with_two):
    items, total = await list_pending_items(store_with_two, filter_by_surface="楚成王")
    assert total == 1
    assert items[0].item_id == "seed_mapping:s2"


@pytest.mark.asyncio
async def test_list_pending_items_filter_by_kind(allowlist):
    store = FakeTriageStore(
        [
            make_pending("seed_mapping:s1", kind="seed_mapping"),
            make_pending("guard_blocked_merge:g1", kind="guard_blocked_merge"),
        ]
    )
    items, total = await list_pending_items(store, filter_by_kind="guard_blocked_merge")
    assert total == 1
    assert items[0].kind == "guard_blocked_merge"


@pytest.mark.asyncio
async def test_find_pending_item_found_and_missing(store_with_two):
    assert (await find_pending_item(store_with_two, "seed_mapping:s1")) is not None
    assert (await find_pending_item(store_with_two, "seed_mapping:ghost")) is None


@pytest.mark.asyncio
async def test_decisions_for_surface_hint_banner(store_with_two, allowlist):
    await record_decision(
        store_with_two,
        allowlist,
        RecordDecisionInput(
            item_id="seed_mapping:s1",
            decision="reject",
            historian_id="chief-historian",
        ),
    )
    hits = await decisions_for_surface(store_with_two, "周成王")
    assert len(hits) == 1
    assert hits[0].surface_snapshot == "周成王"
    # a surface with no decisions returns empty
    assert await decisions_for_surface(store_with_two, "楚成王") == []


# ---------------------------------------------------------------------------
# Vocabulary + convenience impls sanity
# ---------------------------------------------------------------------------


def test_default_reason_source_types_shape():
    assert "in_chapter" in DEFAULT_REASON_SOURCE_TYPES
    assert len(DEFAULT_REASON_SOURCE_TYPES) == 6
    # default validator agrees with the default vocabulary
    v = DefaultReasonValidator()
    assert all(v.validate(t) for t in DEFAULT_REASON_SOURCE_TYPES)
    assert v.validate("not_a_tag") is False


def test_static_allowlist_membership():
    al = StaticAllowlist({"chief-historian", "alice"})
    assert al.is_allowed("alice") is True
    assert al.is_allowed("eve") is False
    assert "chief-historian" in al
    assert len(al) == 2
