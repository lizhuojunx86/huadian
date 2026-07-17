"""Unit tests for qc.tg_bridge (audit-2026-07-16: bridge had zero coverage).

Covers the three fail-open guarantees documented in the module docstring plus
the feature_as_of metadata extraction — all offline, no real traceguard needed:

  1. flag unset            -> bridge disabled, side_write_trace is a no-op
  2. traceguard missing    -> import degrades, bridge disabled, nothing raises
  3. write raises          -> exception swallowed (fail-open double guard)
  4. metadata as_of        -> forwarded as feature_as_of ("as_of" preferred,
                              "feature_as_of" fallback, None when absent)
  5. HUADIAN_TRACEGUARD_DB -> custom URL reaches make_engine

The bridge resolves all state at import time (module-level ``_TRACER``), so
each test re-imports the module under a controlled env; an autouse fixture
re-imports it afterwards under the real environment so other tests are
unaffected.
"""

from __future__ import annotations

import importlib
import sys
import types
from types import SimpleNamespace

import pytest

MODULE = "huadian_pipeline.qc.tg_bridge"

_FAKE_NAMES = (
    "traceguard",
    "traceguard.bridges",
    "traceguard.bridges.guardian",
    "traceguard.sdk",
    "traceguard.sdk.tracer",
    "traceguard.store",
    "traceguard.store.models",
)


def _install_fake_traceguard(monkeypatch, write_fn):
    """Install a minimal fake traceguard package tree into sys.modules.

    Returns the list that records every make_engine(url) call.
    """
    engine_urls: list[str] = []

    class FakeTracer:
        def __init__(self, engine=None):
            self.engine = engine

    def make_engine(url):
        engine_urls.append(url)
        return ("engine", url)

    mods = {name: types.ModuleType(name) for name in _FAKE_NAMES}
    mods["traceguard.bridges.guardian"].write_trace_from_guardian = write_fn
    mods["traceguard.sdk.tracer"].Tracer = FakeTracer
    mods["traceguard.store.models"].make_engine = make_engine
    for name, mod in mods.items():
        monkeypatch.setitem(sys.modules, name, mod)
    return engine_urls


def _reload_bridge(monkeypatch, *, flag: bool, write_fn=None, missing: bool = False):
    """Fresh-import tg_bridge under a controlled env/sys.modules state."""
    if flag:
        monkeypatch.setenv("HUADIAN_TRACEGUARD", "1")
    else:
        monkeypatch.delenv("HUADIAN_TRACEGUARD", raising=False)

    if missing:
        # sys.modules[name] = None makes `import name` raise ImportError.
        for name in _FAKE_NAMES:
            monkeypatch.setitem(sys.modules, name, None)
        engine_urls = None
    else:
        engine_urls = _install_fake_traceguard(monkeypatch, write_fn or (lambda *a, **k: None))

    sys.modules.pop(MODULE, None)
    return importlib.import_module(MODULE), engine_urls


@pytest.fixture(autouse=True)
def _restore_real_bridge():
    """After each test, re-import the module under the real environment."""
    yield
    sys.modules.pop(MODULE, None)
    importlib.import_module(MODULE)


def test_flag_unset_is_noop(monkeypatch):
    calls = []
    bridge, _ = _reload_bridge(monkeypatch, flag=False, write_fn=lambda *a, **k: calls.append(a))
    assert bridge.is_enabled() is False
    assert bridge.side_write_trace(object(), object()) is None
    assert calls == []


def test_traceguard_missing_degrades_without_error(monkeypatch):
    bridge, _ = _reload_bridge(monkeypatch, flag=True, missing=True)
    assert bridge.write_trace_from_guardian is None
    assert bridge.is_enabled() is False
    # Still a safe no-op even though the flag is set.
    assert bridge.side_write_trace(object(), object()) is None


def test_enabled_forwards_project_tracer_and_as_of(monkeypatch):
    calls = []

    def write_fn(output, decision, **kwargs):
        calls.append((output, decision, kwargs))

    bridge, engine_urls = _reload_bridge(monkeypatch, flag=True, write_fn=write_fn)
    assert bridge.is_enabled() is True
    assert engine_urls  # engine was built exactly because the flag is on

    output = SimpleNamespace(metadata={"as_of": "2026-01-31"})
    decision = object()
    bridge.side_write_trace(output, decision)

    assert len(calls) == 1
    got_output, got_decision, kwargs = calls[0]
    assert got_output is output and got_decision is decision
    assert kwargs["project"] == "huadian"
    assert kwargs["tracer"] is bridge._TRACER
    assert kwargs["feature_as_of"] == "2026-01-31"


@pytest.mark.parametrize(
    ("metadata", "expected"),
    [
        ({"feature_as_of": "2025-12-01"}, "2025-12-01"),  # fallback key
        ({"as_of": "a", "feature_as_of": "b"}, "a"),  # "as_of" wins
        ({}, None),
        (None, None),  # metadata attr not a dict
    ],
)
def test_feature_as_of_extraction(monkeypatch, metadata, expected):
    calls = []
    bridge, _ = _reload_bridge(monkeypatch, flag=True, write_fn=lambda o, d, **k: calls.append(k))
    bridge.side_write_trace(SimpleNamespace(metadata=metadata), object())
    assert calls[0]["feature_as_of"] == expected


def test_write_error_is_swallowed(monkeypatch):
    def write_fn(*a, **k):
        raise RuntimeError("traceguard outage")

    bridge, _ = _reload_bridge(monkeypatch, flag=True, write_fn=write_fn)
    assert bridge.is_enabled() is True
    # Fail-open: must not raise into the caller.
    assert bridge.side_write_trace(SimpleNamespace(metadata={}), object()) is None


def test_custom_db_url_reaches_make_engine(monkeypatch):
    monkeypatch.setenv("HUADIAN_TRACEGUARD_DB", "sqlite:///custom_traces.db")
    bridge, engine_urls = _reload_bridge(monkeypatch, flag=True)
    assert bridge.is_enabled() is True
    assert engine_urls == ["sqlite:///custom_traces.db"]
