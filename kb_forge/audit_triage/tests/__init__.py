"""Unit tests for kb_forge.audit_triage.

Added 2026-06-07 to close the gap flagged in the D-route progress review:
audit_triage (Layer 1 第 5 刀) shipped with 0 collectable unit tests — the
``60/60`` figure came entirely from identity_resolver + invariant_scaffold.
These tests exercise the pure-Python service layer against an in-memory
``FakeTriageStore`` (see ``conftest.py``); no database required.

License: Apache 2.0
"""
