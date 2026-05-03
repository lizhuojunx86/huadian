"""identity_resolver — domain-agnostic identity resolution framework.

This package provides R1-R6 entity-resolution algorithms with pluggable
case-domain data feeds (dictionaries / guards / DB adapters / canonical hints).

Quick start:

    from framework.identity_resolver import (
        EntitySnapshot,
        ScorePairContext,
        build_score_pair_context,
        resolve_identities,
    )
    from your_case.adapters import (
        MyEntityLoader,
        MyDictionaryLoader,
        MY_GUARD_CHAINS,
    )

    ctx = build_score_pair_context(
        dictionary_loader=MyDictionaryLoader(),
        cross_dynasty_attr="jurisdiction",  # or "dynasty" for HuaDian classics
    )
    result = await resolve_identities(
        loader=MyEntityLoader(),
        score_context=ctx,
        guard_chains=MY_GUARD_CHAINS,
    )

License: Apache 2.0 (code) / CC BY 4.0 (docs)
Source: HuaDian Sprint N first-cut framework abstraction.
"""

from .apply_merges import (
    MergeApplier,
    apply_merges,
    filter_groups_by_skip_rules,
)
from .canonical import select_canonical
from .dry_run_report import (
    DefaultReasonBuilder,
    ReasonBuilder,
    build_reason_summary,
    generate_dry_run_report,
)
from .entity import EntitySnapshot, PersonSnapshot
from .guards import GuardFn, GuardResult, evaluate_pair_guards
from .r6_seed_match import (
    R6PrePassResult,
    R6Result,
    R6Status,
    SeedMatchAdapter,
    r6_seed_match,
)
from .resolve import EntityLoader, R6PrePassRunner, resolve_identities
from .rules import (
    DEFAULT_RULE_ORDER,
    MERGE_CONFIDENCE_THRESHOLD,
    RuleFn,
    ScorePairContext,
    build_score_pair_context,
    rule_r1,
    rule_r3,
    rule_r4,
    rule_r5,
    score_pair,
)
from .rules_protocols import (
    CanonicalHint,
    DictionaryLoader,
    IdentityNotesPatterns,
    StopWordPlugin,
)
from .types import (
    BlockedMerge,
    HypothesisProposal,
    MatchResult,
    MergeGroup,
    MergeProposal,
    PersonProposal,
    ResolveResult,
)
from .union_find import UnionFind
from .utils import swap_ab_payload

__all__ = [
    # types
    "MatchResult",
    "MergeProposal",
    "PersonProposal",
    "MergeGroup",
    "HypothesisProposal",
    "BlockedMerge",
    "ResolveResult",
    # entity
    "EntitySnapshot",
    "PersonSnapshot",
    # union_find
    "UnionFind",
    # utils
    "swap_ab_payload",
    # guards
    "GuardFn",
    "GuardResult",
    "evaluate_pair_guards",
    # rules
    "MERGE_CONFIDENCE_THRESHOLD",
    "DEFAULT_RULE_ORDER",
    "RuleFn",
    "ScorePairContext",
    "build_score_pair_context",
    "rule_r1",
    "rule_r3",
    "rule_r4",
    "rule_r5",
    "score_pair",
    # rules_protocols
    "DictionaryLoader",
    "StopWordPlugin",
    "IdentityNotesPatterns",
    "CanonicalHint",
    # canonical
    "select_canonical",
    # r6_seed_match
    "R6Status",
    "R6Result",
    "R6PrePassResult",
    "SeedMatchAdapter",
    "r6_seed_match",
    # dry_run_report
    "ReasonBuilder",
    "DefaultReasonBuilder",
    "build_reason_summary",
    "generate_dry_run_report",
    # resolve (main entry)
    "EntityLoader",
    "R6PrePassRunner",
    "resolve_identities",
    # apply_merges
    "MergeApplier",
    "apply_merges",
    "filter_groups_by_skip_rules",
]

__version__ = "0.2.0"
