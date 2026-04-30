"""HuaDian classics — CanonicalHint plugin (帝X demotion).

Demotes 帝X honorific entities (e.g. "帝尧") in canonical selection if a
bare-name peer (e.g. "尧") exists in the same merge group.

Rationale (ADR-012 / T-P0-013): when "尧" and "帝尧" are the same person,
we want "尧" to be canonical (it's the "real" name), not "帝尧" (the
honorific title).

License: Apache 2.0
Source: extracted from `services/pipeline/src/huadian_pipeline/resolve_rules.py`
        `is_di_honorific` + `has_di_prefix_peer`.
"""

from __future__ import annotations

from framework.identity_resolver import EntitySnapshot

from .r2_di_prefix_rule import is_di_honorific


def has_di_prefix_peer(p: EntitySnapshot, group: list[EntitySnapshot]) -> bool:
    """Return True if `p` is a 帝X honorific AND the bare X exists in group.

    Conditions (all):
      1. `p.name` starts with "帝" + 1-2 chars (`is_di_honorific`)
      2. Another entity in `group` has `name == p.name[1:]`
    """
    if not is_di_honorific(p.name):
        return False
    stripped = p.name[1:]
    return any(other.id != p.id and other.name == stripped for other in group)


class HuaDianDiHonorificHint:
    """Implementation of `CanonicalHint` Protocol for HuaDian classics.

    Demotes any 帝X entity that has a bare-name peer in the merge group.
    Used by `select_canonical()` as priority 2 (after pinyin slug).
    """

    def should_demote(
        self,
        entity: EntitySnapshot,
        group: list[EntitySnapshot],
    ) -> bool:
        return has_di_prefix_peer(entity, group)
