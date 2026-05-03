"""Decision-reason source-type vocabulary + ReasonValidator Protocol.

When a historian records a decision, they may tag the rationale with a
``reason_source_type`` — a short controlled-vocabulary tag indicating
**where** the evidence came from (e.g. "in_chapter" vs "wikidata").

This vocabulary is shared across HuaDian and is offered as a default
``DEFAULT_REASON_SOURCE_TYPES`` for cross-domain re-use. Domains that
need a different vocabulary can pass their own
:class:`ReasonValidator` to :func:`record_decision`.

The 6 default tags (reflecting Sprint K Triage UI's quick templates):

    in_chapter         — evidence found in the same chapter being processed
    other_classical    — evidence in another classical text (e.g. cross-ref)
    wikidata           — evidence from Wikidata or similar structured KB
    scholarly          — modern academic paper / annotated edition
    structural         — evidence is a structural / schema-level conclusion
                         (e.g. "slug-dedup", "split-for-safety")
    historical-backfill — bulk-backfill artifact (Sprint K Stage 2.5)

License: Apache 2.0
Source: extracted from services/api/src/services/triage.service.ts
        REASON_SOURCE_TYPES constant + ADR-027 §3 column comment.
"""

from __future__ import annotations

from collections.abc import Iterable
from typing import Protocol, runtime_checkable

#: Default 6-tag controlled vocabulary. Cross-domain forks may extend
#: this set or replace it via a custom :class:`ReasonValidator`.
DEFAULT_REASON_SOURCE_TYPES: tuple[str, ...] = (
    "in_chapter",
    "other_classical",
    "wikidata",
    "scholarly",
    "structural",
    "historical-backfill",
)


@runtime_checkable
class ReasonValidator(Protocol):
    """Validates a ``reason_source_type`` value.

    The framework calls :meth:`validate` once per :func:`record_decision`
    invocation when ``reason_source_type`` is set (it's optional — None /
    empty string is always accepted, no validator call). On failure:
    ``DecisionError(code="INVALID_REASON_SOURCE_TYPE", ...)``.

    Implementations are expected to be cheap (synchronous, no I/O).
    """

    def validate(self, reason_source_type: str) -> bool:
        """Return ``True`` if the value is acceptable for this domain."""
        ...


class DefaultReasonValidator:
    """Reference impl: validates against an explicit set of allowed tags.

    By default uses :data:`DEFAULT_REASON_SOURCE_TYPES`. Domains can
    construct with a custom set:

        >>> v = DefaultReasonValidator(allowed=("contract_text", "case_law"))
        >>> v.validate("contract_text")
        True
        >>> v.validate("in_chapter")
        False
    """

    __slots__ = ("_allowed",)

    def __init__(self, allowed: Iterable[str] | None = None) -> None:
        if allowed is None:
            self._allowed = frozenset(DEFAULT_REASON_SOURCE_TYPES)
        else:
            self._allowed = frozenset(allowed)

    def validate(self, reason_source_type: str) -> bool:
        return reason_source_type in self._allowed

    def __contains__(self, reason_source_type: str) -> bool:
        return reason_source_type in self._allowed

    def __repr__(self) -> str:
        return f"DefaultReasonValidator(allowed={sorted(self._allowed)!r})"
