"""Service-layer orchestration for audit_triage.

Pure Python — no DB, no HTTP. The service composes:

    TriageStore            (DB I/O)
    HistorianAllowlist     (authz)
    ReasonValidator        (vocabulary check, optional)
    ItemKindRegistry       (kind → source_table mapping)

into the public API:

    record_decision(...)            — write a decision audit row
    list_pending_items(...)         — read inbox queue
    decisions_for_surface(...)      — hint banner cross-reference
    decisions_for_source(...)       — full audit trail per source row
    encode_item_id / decode_item_id — composite ``"<kind>:<source_id>"``

V0.1 contract: **zero downstream**. ``record_decision`` writes to
``triage_decisions`` only — the source data layer (persons / merges /
seed_mappings.mapping_status) is NOT touched. V0.2 will add an async
:class:`DecisionApplier` job; this file's API will gain
``apply_pending(applier, store)`` then.

License: Apache 2.0
Source: extracted from services/api/src/services/triage.service.ts
        recordTriageDecision + listPendingItemRows + findNextPending +
        ID encode/decode helpers.
"""

from __future__ import annotations

from .authz import HistorianAllowlist
from .reasons import ReasonValidator
from .store import TriageStore
from .types import (
    ALL_DECISION_TYPES,
    DecisionError,
    DecisionRecord,
    ItemKind,
    ItemKindRegistry,
    PendingItem,
    RecordDecisionInput,
    RecordDecisionResult,
    TriageDecisionType,
)

# ---------------------------------------------------------------------------
# Composite item-id encoding
# ---------------------------------------------------------------------------


def encode_item_id(kind: ItemKind, source_id: str) -> str:
    """Build the composite id used as :attr:`PendingItem.item_id`."""
    return f"{kind}:{source_id}"


def decode_item_id(item_id: str) -> tuple[ItemKind, str] | None:
    """Inverse of :func:`encode_item_id`. Returns ``None`` for malformed
    input (kind missing / source_id missing / extra colons)."""
    parts = item_id.split(":")
    if len(parts) != 2:
        return None
    kind, source_id = parts[0], parts[1]
    if not kind or not source_id:
        return None
    return (kind, source_id)


# ---------------------------------------------------------------------------
# Read APIs (thin wrappers over the store, plus signature stability)
# ---------------------------------------------------------------------------


async def list_pending_items(
    store: TriageStore,
    *,
    limit: int = 50,
    offset: int = 0,
    filter_by_kind: ItemKind | None = None,
    filter_by_surface: str | None = None,
) -> tuple[list[PendingItem], int]:
    """Return ``(items, total_count)`` from the pending review queue.

    Pure pass-through to :meth:`TriageStore.list_pending`; isolated as
    a function so consumers depend on the framework module surface
    rather than the Protocol method directly.
    """
    return await store.list_pending(
        limit=limit,
        offset=offset,
        filter_by_kind=filter_by_kind,
        filter_by_surface=filter_by_surface,
    )


async def find_pending_item(
    store: TriageStore,
    item_id: str,
) -> PendingItem | None:
    """Return one pending item by composite id, or ``None``."""
    return await store.find_pending_by_id(item_id)


async def decisions_for_surface(
    store: TriageStore,
    surface: str,
    *,
    limit: int = 10,
) -> list[DecisionRecord]:
    """Hint-banner cross-reference: return historical decisions whose
    ``surface_snapshot == surface``, latest first."""
    return await store.find_decisions_for_surface(surface, limit=limit)


async def decisions_for_source(
    store: TriageStore,
    source_table: str,
    source_id: str,
    *,
    limit: int = 100,
) -> list[DecisionRecord]:
    """Full per-source audit trail (defer → revisit → approve)."""
    return await store.find_decisions_for_source(
        source_table,
        source_id,
        limit=limit,
    )


# ---------------------------------------------------------------------------
# Write API — the heart of audit_triage
# ---------------------------------------------------------------------------


async def record_decision(
    store: TriageStore,
    authz: HistorianAllowlist,
    input: RecordDecisionInput,  # noqa: A002 — public API; renaming would break consumers
    *,
    reason_validator: ReasonValidator | None = None,
    item_kind_registry: ItemKindRegistry | None = None,  # noqa: ARG001 reserved for v0.2
) -> RecordDecisionResult:
    """Record a historian decision against a pending triage item.

    V0.1 zero-downstream contract: writes a row into ``triage_decisions``
    only. Does NOT mutate the source table (per ADR-027 §2.5).

    Validation order (short-circuits on first failure):
        1. ``input.historian_id`` is in the allowlist
        2. ``input.decision`` is one of ALL_DECISION_TYPES
        3. ``input.reason_source_type`` (if non-empty) passes the
           validator (default: :class:`DefaultReasonValidator`)
        4. ``input.item_id`` decodes cleanly
        5. The pending item still exists

    On success: returns
    :class:`RecordDecisionResult` with ``decision_record`` set + the
    ``next_pending_item_id`` for inbox redirect (or None when queue
    empty).

    On failure: returns :class:`RecordDecisionResult` with ``error``
    set; nothing is written to the store.

    Args:
        store:                 :class:`TriageStore` impl (DB).
        authz:                 :class:`HistorianAllowlist` impl.
        input:                 the decision payload.
        reason_validator:      optional :class:`ReasonValidator`. If None
                               and ``input.reason_source_type`` is set,
                               a fresh :class:`DefaultReasonValidator` is
                               instantiated for the validation.
        item_kind_registry:    reserved for v0.2 (currently unused — the
                               store is responsible for kind→table
                               mapping in v0.1).
    """
    # 1. Authz
    if not authz.is_allowed(input.historian_id):
        return RecordDecisionResult(
            decision_record=None,
            next_pending_item_id=None,
            error=DecisionError(
                code="UNAUTHORIZED",
                message=(f"historianId '{input.historian_id}' is not in the allowlist"),
            ),
        )

    # 2. Decision type
    if input.decision not in ALL_DECISION_TYPES:
        return RecordDecisionResult(
            decision_record=None,
            next_pending_item_id=None,
            error=DecisionError(
                code="INVALID_DECISION_TYPE",
                message=(f"decision '{input.decision}' is not one of {ALL_DECISION_TYPES}"),
            ),
        )

    # 3. Reason source-type (optional; only validated when non-empty)
    if input.reason_source_type:
        validator = reason_validator
        if validator is None:
            # Lazy import to avoid pulling reasons.py for callers who
            # always pass an explicit validator.
            from .reasons import DefaultReasonValidator

            validator = DefaultReasonValidator()
        if not validator.validate(input.reason_source_type):
            return RecordDecisionResult(
                decision_record=None,
                next_pending_item_id=None,
                error=DecisionError(
                    code="INVALID_REASON_SOURCE_TYPE",
                    message=(
                        f"reason_source_type '{input.reason_source_type}' is not in the allowed set"
                    ),
                ),
            )

    # 4. Item-id decode
    decoded = decode_item_id(input.item_id)
    if decoded is None:
        return RecordDecisionResult(
            decision_record=None,
            next_pending_item_id=None,
            error=DecisionError(
                code="INVALID_ITEM_ID_FORMAT",
                message=(
                    f"itemId '{input.item_id}' has invalid format (expected '<kind>:<source_id>')"
                ),
            ),
        )
    kind, source_id = decoded

    # 5. Verify still pending
    item = await store.find_pending_by_id(input.item_id)
    if item is None:
        return RecordDecisionResult(
            decision_record=None,
            next_pending_item_id=None,
            error=DecisionError(
                code="ITEM_NOT_FOUND",
                message=(f"triage item '{input.item_id}' does not exist or is no longer pending"),
            ),
        )

    # 6. INSERT decision row
    record = await store.insert_decision(item, input)

    # 7. Compute next pending (inbox redirect target)
    next_id = await store.find_next_pending_excluding(kind, source_id)

    return RecordDecisionResult(
        decision_record=record,
        next_pending_item_id=next_id,
        error=None,
    )


# ---------------------------------------------------------------------------
# Convenience: explicit decision-type narrowing
# ---------------------------------------------------------------------------


def is_valid_decision_type(value: str) -> bool:
    """Return ``True`` iff ``value`` is one of :data:`ALL_DECISION_TYPES`.

    Useful for caller-side input validation before constructing a
    :class:`RecordDecisionInput`.
    """
    return value in ALL_DECISION_TYPES


def coerce_decision_type(value: str) -> TriageDecisionType:
    """Return ``value`` as :data:`TriageDecisionType` or raise ``ValueError``.

    Strict checked variant for callers that want hard fail on bad input
    (vs. the soft :func:`is_valid_decision_type`).
    """
    if value not in ALL_DECISION_TYPES:
        raise ValueError(
            f"{value!r} is not a valid TriageDecisionType (expected one of {ALL_DECISION_TYPES})"
        )
    return value  # type: ignore[return-value]
