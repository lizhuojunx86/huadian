# kb-forge — Agentic Knowledge Engineering Framework (Layer 1)

> Domain-agnostic engineering core for building **trustworthy knowledge bases with
> AI agent teams**, extracted from the [华典智谱 (HuaDian)](../README.md) *Shiji*
> reference implementation.
>
> Status: **v0.3.0** · License: Apache 2.0 · Name: **`kb-forge`**
> (distribution name fixed in [ADR-037](../docs/decisions/ADR-037-framework-package-naming.md);
> import root renamed `framework.*` → `kb_forge.*` on 2026-06-20 per
> [ADR-039](../docs/decisions/ADR-039-l1-unfreeze-import-rename-and-criterion-redefinition.md) —
> distribution name and import root are now aligned)

This is the "it really works" engineering substrate behind the HuaDian D-route
strategy (see [`docs/strategy/D-route-positioning.md`](../docs/strategy/D-route-positioning.md)).
The companion prose — *why* and *how* — lives in
[`docs/methodology/`](../docs/methodology/).

---

## What's here

| Component | Kind | What it abstracts |
|---|---|---|
| [`identity_resolver/`](identity_resolver/) | Python pkg | R1–R6 cross-chunk entity resolution + pluggable `GUARD_CHAINS` |
| [`invariant_scaffold/`](invariant_scaffold/) | Python pkg | Formal correctness gates (the V1–V11 invariant pattern) |
| [`audit_triage/`](audit_triage/) | Python pkg | Pending-review queue + immutable decision audit trail + hint banner |
| [`sprint-templates/`](sprint-templates/) | Docs/templates | Sprint / Stage / Gate workflow + Stop Rules |
| [`role-templates/`](role-templates/) | Docs/templates | 10 domain-neutral agent role definitions + tagged-session protocol |

Each Python package ships `README.md` + `CONCEPTS.md` + `cross-domain-mapping.md`
(a fork guide for other domains) + `tests/` + an `examples/huadian_classics/`
reference implementation.

---

## Quick start (verified)

The core is **pure-Python (stdlib only)** — no database, no services needed to
run the suite. From the **repository root** (the import root for `kb_forge.*`):

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r kb_forge/requirements-dev.txt

python -m pytest \
  kb_forge/identity_resolver/tests \
  kb_forge/invariant_scaffold/tests \
  kb_forge/audit_triage/tests
# -> 93 passed
```

That is the measurable "external engineer clone + run" path
(D-route §5 Layer 1 completion criterion + §10 North Star). Requires
**Python ≥ 3.12** (matching `kb_forge/pyproject.toml`; the quick start above
installs only test deps, so the interpreter check is on you). An editable
install (`pip install -e kb_forge`) is the intended next step; naming/layout
were settled by [ADR-037](../docs/decisions/ADR-037-framework-package-naming.md)
(accepted 2026-06-07) and [ADR-039](../docs/decisions/ADR-039-l1-unfreeze-import-rename-and-criterion-redefinition.md)
(import root aligned 2026-06-20).

---

## The domain-agnostic contract

The defining design rule: **generic logic goes in the package core; everything
domain-specific goes behind a plugin Protocol and lives in `examples/<domain>/`.**

- `identity_resolver`, `invariant_scaffold`, `audit_triage` cores contain **zero**
  Shiji/TCM vocabulary — they speak in `EntitySnapshot`, `PendingItem`,
  `TriageStore`, `HistorianAllowlist`, etc.
- The HuaDian *Shiji* specifics (asyncpg stores, person-name guards, the
  `seed_mapping` / `guard_blocked_merge` item kinds) live only under
  `examples/huadian_classics/`.
- A second domain (TCM extraction) validated portability through the
  TraceGuard E1–E3 PoC and a second `domain config`
  (see [`docs/cases/tcm-extraction/traceguard-poc/`](../docs/cases/tcm-extraction/traceguard-poc/)).

**Honest status of the completion criteria** (per the 2026-06-07 progress
review, [`docs/reports/d-route-progress-review-2026-06-07.md`](../docs/reports/d-route-progress-review-2026-06-07.md)):

| Criterion (D-route §5/§10) | Target | Now |
|---|---|---|
| External engineer clone + run tests | ≤ 1 h | ✅ path exists (this README) |
| Domain-agnostic LOC ratio | ≥ 70 % | ⚠️ ~56–62 % (examples still heavy) |
| Framework name decided | yes | ✅ `kb-forge` (ADR-037 accepted) — import-root rename pending |
| Per-module unit tests | each module | ✅ as of 2026-06-07 (audit_triage backfilled) |

---

## Versioning

The three Python packages track a shared release line (currently `0.3.0`); see
[`RELEASE_NOTES_v0.3.md`](RELEASE_NOTES_v0.3.md). Public types/Protocols are kept
stable across `v0.x`; deprecate before changing.

---

## Where to read next

- New to the framework → [`docs/methodology/00-framework-overview.md`](../docs/methodology/00-framework-overview.md)
- Forking to another domain → each package's `cross-domain-mapping.md`
- The strategy this serves → [`docs/strategy/D-route-positioning.md`](../docs/strategy/D-route-positioning.md)
