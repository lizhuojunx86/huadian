"""HuaDian classics — reference implementation of identity_resolver plugins.

This subpackage provides a complete, runnable case-domain instantiation of
the framework using HuaDian Shiji (Records of the Grand Historian) data:

    - dictionary_loaders.py    — tongjia.yaml + miaohao.yaml loaders (R3 / R5)
    - r1_stop_words.py         — Chinese honorific stop words (R1)
    - identity_notes_patterns.py — Chinese cross-reference regex (R4)
    - di_honorific_hint.py     — 帝X demotion (CanonicalHint)
    - non_person_classifier.py — clan / tribe filter (HuaDian-specific)
    - dynasty_guard.py         — cross-dynasty temporal guard
    - state_prefix_guard.py    — Spring-Autumn ruler-state guard
    - guard_chains.py          — HUADIAN_GUARD_CHAINS dict (R1 / R6 chains)
    - person_loader.py         — PostgreSQL EntityLoader for `persons` table
    - seed_match_adapter.py    — SeedMatchAdapter for `seed_mappings` schema
    - merge_applier.py         — MergeApplier for HuaDian DB writes
    - reason_builder_zh.py     — Chinese-localized ReasonBuilder
    - r2_di_prefix_rule.py     — R2 帝X prefix rule (HuaDian opt-in custom rule)

Cross-domain adopters: copy this folder to your project, rename to your
domain (e.g. `medical/` / `legal/` / `patents/`), then replace each file's
domain-specific content with your own. The plugin protocol contract stays
the same.

License: Apache 2.0 (code) / CC BY 4.0 (data files referenced by loaders)
"""

__version__ = "0.1.0"
