"""framework.audit_triage — Audit Trail + Triage Workflow framework.

Layer 1 第 5 刀 (Sprint Q). Abstracts the "pending review queue +
historian decision audit + hint banner cross-reference" pattern from the
HuaDian Sprint K Triage UI (T-P0-028 / ADR-027 / methodology/05).

Public API (stable across v0.x):

Types
    TriageDecisionType (literal "approve" | "reject" | "defer")
    ItemKind (str, opaque domain identifier)
    PendingItem
    DecisionRecord
    RecordDecisionInput
    RecordDecisionResult
    DecisionError
    DecisionErrorCode

Plugin Protocols (implement these for your domain)
    TriageStore        — DB I/O (required)
    HistorianAllowlist — authz (required)
    ReasonValidator    — vocabulary check (optional, default provided)
    ItemKindRegistry   — kind → source_table mapping
    DecisionApplier    — V0.2 hook (post-decision data mutation)

Service functions
    record_decision           — write a decision audit row
    list_pending_items        — read inbox queue
    find_pending_item         — fetch one pending item
    decisions_for_surface     — hint banner (cross-sprint)
    decisions_for_source      — full per-source audit trail
    encode_item_id / decode_item_id
    is_valid_decision_type / coerce_decision_type

Convenience
    StaticAllowlist           — set-based HistorianAllowlist impl
    DefaultReasonValidator    — set-based ReasonValidator impl
    DEFAULT_REASON_SOURCE_TYPES — 6-tag default vocabulary
    ALL_DECISION_TYPES        — ("approve", "reject", "defer")

Usage minimal (see ``examples/huadian_classics/`` for a full asyncpg
reference impl):

    from framework.audit_triage import (
        StaticAllowlist, RecordDecisionInput, record_decision,
    )
    store = MyAsyncpgStore(pool)              # implement TriageStore
    authz = StaticAllowlist({"chief-historian"})
    result = await record_decision(
        store, authz,
        RecordDecisionInput(
            item_id="seed_mapping:abc-uuid",
            decision="approve",
            historian_id="chief-historian",
            reason_text="...",
            reason_source_type="in_chapter",
        ),
    )
    if result.error:
        ...  # show form-level error
    else:
        next_url = f"/triage/{result.next_pending_item_id}" if result.next_pending_item_id else "/triage"

License: Apache 2.0
"""

from .authz import HistorianAllowlist, StaticAllowlist
from .reasons import (
    DEFAULT_REASON_SOURCE_TYPES,
    DefaultReasonValidator,
    ReasonValidator,
)
from .service import (
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
from .store import TriageStore
from .types import (
    ALL_DECISION_TYPES,
    DecisionApplier,
    DecisionError,
    DecisionErrorCode,
    DecisionRecord,
    ItemKind,
    ItemKindRegistry,
    PendingItem,
    RecordDecisionInput,
    RecordDecisionResult,
    TriageDecisionType,
)

__all__ = [
    # Types
    "ALL_DECISION_TYPES",
    "DecisionError",
    "DecisionErrorCode",
    "DecisionRecord",
    "ItemKind",
    "PendingItem",
    "RecordDecisionInput",
    "RecordDecisionResult",
    "TriageDecisionType",
    # Plugin Protocols
    "DecisionApplier",
    "HistorianAllowlist",
    "ItemKindRegistry",
    "ReasonValidator",
    "TriageStore",
    # Reference impls
    "DefaultReasonValidator",
    "StaticAllowlist",
    # Service functions
    "coerce_decision_type",
    "decisions_for_source",
    "decisions_for_surface",
    "decode_item_id",
    "encode_item_id",
    "find_pending_item",
    "is_valid_decision_type",
    "list_pending_items",
    "record_decision",
    # Constants
    "DEFAULT_REASON_SOURCE_TYPES",
]

__version__ = "0.3.0"
