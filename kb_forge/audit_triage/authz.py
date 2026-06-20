"""HistorianAllowlist Protocol + StaticAllowlist reference impl.

Authz is intentionally minimal: a Protocol that returns ``True`` /
``False`` for a historian id. The framework does not assume SSO, RBAC,
or any specific identity scheme. V0.1 reference impl is a static set;
V0.x case domains may swap in SSO assertion lookups, OAuth claims, etc.

License: Apache 2.0
Source: extracted from services/api/src/services/triage.service.ts
        (HISTORIAN_ALLOWLIST constant + recordTriageDecision §1 authz check).
"""

from __future__ import annotations

from collections.abc import Iterable
from typing import Protocol, runtime_checkable


@runtime_checkable
class HistorianAllowlist(Protocol):
    """Decision-maker authz Protocol.

    The framework calls :meth:`is_allowed` once per
    :func:`record_decision` invocation; failures short-circuit with
    ``DecisionError(code="UNAUTHORIZED", ...)``.

    Implementations are expected to be cheap (synchronous, in-memory).
    For SSO / OAuth-backed authz, cache the decision per request before
    calling the framework.
    """

    def is_allowed(self, historian_id: str) -> bool:
        """Return ``True`` if ``historian_id`` may record decisions."""
        ...


class StaticAllowlist:
    """Reference impl: static set-based allowlist.

    Use when the historian roster is a small, hand-curated list (the
    HuaDian production case). Initialize from any iterable; comparison
    is exact-match (no normalization).

    Example:
        >>> allowlist = StaticAllowlist(["chief-historian", "alice", "bob"])
        >>> allowlist.is_allowed("alice")
        True
        >>> allowlist.is_allowed("eve")
        False
    """

    __slots__ = ("_allowed",)

    def __init__(self, allowed: Iterable[str]) -> None:
        self._allowed: frozenset[str] = frozenset(allowed)

    def is_allowed(self, historian_id: str) -> bool:
        return historian_id in self._allowed

    def __contains__(self, historian_id: str) -> bool:
        # Convenience: ``"alice" in allowlist``
        return historian_id in self._allowed

    def __len__(self) -> int:
        return len(self._allowed)

    def __repr__(self) -> str:
        return f"StaticAllowlist({sorted(self._allowed)!r})"
