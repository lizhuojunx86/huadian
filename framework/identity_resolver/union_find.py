"""UnionFind — disjoint-set data structure for transitive merge closure.

When R rules fire on multiple pairs (A↔B, B↔C), we need to recognize that
A, B, C all belong to the same merge group. UnionFind gives O(α(n)) per
operation (effectively O(1) for practical N).

Standard algorithm with path compression + union by rank. No domain
specifics — directly usable in any KE project.

License: Apache 2.0
Source: lifted verbatim from `services/pipeline/src/huadian_pipeline/resolve.py`
        (HuaDian Sprint N first-cut framework abstraction).
"""

from __future__ import annotations

from collections import defaultdict


class UnionFind:
    """Disjoint-set data structure for transitive closure of merge proposals.

    Usage:

        uf = UnionFind(["a", "b", "c", "d"])
        uf.union("a", "b")
        uf.union("c", "d")
        uf.union("b", "c")   # connects all four
        uf.find("a") == uf.find("d")   # True
        uf.groups()                    # {root: ["a", "b", "c", "d"]}
    """

    def __init__(self, ids: list[str]) -> None:
        self._parent: dict[str, str] = {i: i for i in ids}
        self._rank: dict[str, int] = {i: 0 for i in ids}

    def find(self, x: str) -> str:
        """Find root with path compression."""
        if self._parent[x] != x:
            self._parent[x] = self.find(self._parent[x])
        return self._parent[x]

    def union(self, x: str, y: str) -> None:
        """Merge the sets containing x and y (union by rank)."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return
        if self._rank[rx] < self._rank[ry]:
            rx, ry = ry, rx
        self._parent[ry] = rx
        if self._rank[rx] == self._rank[ry]:
            self._rank[rx] += 1

    def groups(self) -> dict[str, list[str]]:
        """Return a mapping of root_id → [member_ids] for groups of size >= 2.

        Singletons (entities with no merges) are excluded — only
        connected components with >= 2 members are returned.
        """
        buckets: dict[str, list[str]] = defaultdict(list)
        for node in self._parent:
            buckets[self.find(node)].append(node)
        return {root: members for root, members in buckets.items() if len(members) >= 2}
