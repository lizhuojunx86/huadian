"""Opt-in, fail-open side-write of a traceguard ``Trace`` per Guardian checkpoint.

This module bridges each Guardian ``GuardianDecision`` (already produced by the
existing ``TraceGuardAdapter.checkpoint`` hot path) to a standalone ``traceguard``
trace row, as a **fire-and-forget side effect**. It is purely **additive** and
exists behind a single env-var switch:

    HUADIAN_TRACEGUARD=1     enables the side-write
    HUADIAN_TRACEGUARD_DB    optional sqlalchemy URL
                             (default: ``sqlite:///huadian_traces.db``)

Hard guarantees (see task brief + upstream bridge SPEC §4.1):

  - **Does NOT touch the pinned ``pipeline-guardian`` (``guardian``) dependency**
    nor change any guardian behavior. ``traceguard`` is an independent package
    (a *different* distribution from ``guardian``); importing it here therefore
    does not violate the ``_imports.py`` guardian firewall — that firewall is
    about ``guardian``, not ``traceguard``.
  - **Default behavior is byte-for-byte unchanged.** With the flag unset (the
    default), ``_TRACER`` is ``None`` and :func:`side_write_trace` is an
    immediate no-op — nothing is imported lazily, no engine is built, no file
    is written.
  - **Fail-open, triple-guarded.** (1) ``traceguard`` missing → ``ImportError``
    caught at import → bridge disabled. (2) flag off / tracer init failed →
    ``_TRACER is None`` → no-op. (3) the upstream ``write_trace_from_guardian``
    is itself fully fail-open (swallows every error, returns ``None``), and we
    still wrap the call in our own ``try/except``. A traceguard outage can
    never break or slow the host pipeline beyond one swallowed exception.
"""

from __future__ import annotations

import logging
import os
from typing import Any

logger = logging.getLogger(__name__)

# Project label stamped on every bridged trace (completion criterion: project=huadian).
_PROJECT = "huadian"

# Env-var override for the trace store; defaults to a cwd-relative sqlite file so
# the documented verification command (`sqlite:///huadian_traces.db`) just works.
_DB_URL = os.environ.get("HUADIAN_TRACEGUARD_DB", "sqlite:///huadian_traces.db")


# --- Guard 1: traceguard absent ------------------------------------------------
# Importing an uninstalled traceguard must not break the qc package import. When
# absent, every symbol is None and the bridge degrades to a no-op.
try:
    from traceguard.bridges.guardian import write_trace_from_guardian
    from traceguard.sdk.tracer import Tracer
    from traceguard.store.models import make_engine
except ImportError:  # pragma: no cover — exercised only when traceguard is uninstalled
    write_trace_from_guardian = None  # type: ignore[assignment]
    Tracer = None  # type: ignore[assignment]
    make_engine = None  # type: ignore[assignment]


def _build_tracer() -> Any | None:
    """Build a Tracer iff the opt-in flag is set AND traceguard is importable.

    Returns ``None`` (bridge disabled) when the flag is unset, traceguard is
    missing, or engine construction fails — all fail-open paths.
    """
    if not os.environ.get("HUADIAN_TRACEGUARD"):
        return None
    if Tracer is None or make_engine is None:
        return None
    try:
        return Tracer(engine=make_engine(_DB_URL))
    except Exception:  # pragma: no cover — fail-open on engine/init error
        logger.warning("traceguard Tracer init failed; side-write disabled", exc_info=True)
        return None


# --- Guard 2: flag off ---------------------------------------------------------
# Resolved once at import. With HUADIAN_TRACEGUARD unset this is None and the
# default pipeline pays zero cost (no engine, no sqlite file).
_TRACER: Any | None = _build_tracer()


def is_enabled() -> bool:
    """True iff the opt-in side-write is live (flag set + traceguard present)."""
    return _TRACER is not None and write_trace_from_guardian is not None


def side_write_trace(output: Any, decision: Any) -> None:
    """Best-effort: persist one traceguard trace from a Guardian checkpoint.

    No-op unless :func:`is_enabled`. Fail-open: never raises into the caller.

    Args:
        output: the Guardian ``StepOutput`` handed to ``evaluate_async``.
        decision: the ``GuardianDecision`` it returned.
    """
    if not is_enabled():
        return
    try:
        # PIT stamp: prefer an explicit metadata hint, else let the bridge fall
        # back to None (no point-in-time tracking for this step).
        feature_as_of = None
        metadata = getattr(output, "metadata", None)
        if isinstance(metadata, dict):
            feature_as_of = metadata.get("as_of") or metadata.get("feature_as_of")

        write_trace_from_guardian(
            output,
            decision,
            project=_PROJECT,
            tracer=_TRACER,
            feature_as_of=feature_as_of,
        )
    except Exception:  # pragma: no cover — double guard; upstream bridge is fail-open
        logger.warning("traceguard side-write failed; ignored (fail-open)", exc_info=True)
