"""HuaDian classics — reference impl of the audit_triage framework.

Three pieces:

    AsyncpgTriageStore             — :class:`TriageStore` backed by asyncpg
    load_huadian_historian_allowlist — :class:`StaticAllowlist` from yaml
    schema.sql                     — reference DDL (copy + edit)

Usage minimal:

    import asyncpg
    from framework.audit_triage import (
        RecordDecisionInput, record_decision, DefaultReasonValidator,
    )
    from framework.audit_triage.examples.huadian_classics import (
        AsyncpgTriageStore,
        load_huadian_historian_allowlist,
    )

    pool = await asyncpg.create_pool(DATABASE_URL)
    store = AsyncpgTriageStore(pool)
    authz = load_huadian_historian_allowlist()
    validator = DefaultReasonValidator()  # 6-tag default vocabulary

    result = await record_decision(
        store, authz,
        RecordDecisionInput(
            item_id="seed_mapping:abc-uuid",
            decision="approve",
            historian_id="chief-historian",
            reason_text="同章节明确互称",
            reason_source_type="in_chapter",
        ),
        reason_validator=validator,
    )

License: Apache 2.0
"""

from .allowlist import load_huadian_historian_allowlist
from .asyncpg_store import AsyncpgTriageStore

__all__ = [
    "AsyncpgTriageStore",
    "load_huadian_historian_allowlist",
]
