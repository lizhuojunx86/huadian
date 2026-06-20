"""Agentic Knowledge Engineering framework (Layer 1).

Domain-agnostic core extracted from the HuaDian (华典智谱) Shiji reference
implementation. Importable subpackages:

    kb_forge.identity_resolver   — R1-R6 + guard-chain entity resolution
    kb_forge.invariant_scaffold  — formal correctness gates (V1-V11 pattern)
    kb_forge.audit_triage        — pending-review queue + decision audit trail

(The ``sprint-templates/`` and ``role-templates/`` sibling directories are
documentation/templates, not importable Python.)

This top-level ``__init__`` is intentionally inert — it does NOT import the
subpackages, so callers only pay for what they import. The aggregate
``__version__`` tracks the framework release line (per-module ``__version__``
may differ during a staggered bump).

NAME: distribution name = ``kb-forge`` (ADR-037, accepted 2026-06-07); import
root = ``kb_forge`` (renamed from ``framework`` on 2026-06-20, ADR-039).

License: Apache 2.0
"""

__version__ = "0.3.0"
